<?php

/**
 * FO2ODF Converter - PHP interface for launching the XSLT transformation.
 *
 * The logic of this script is following:
 *
 * <ol>
 * <li>If this is request on downloading a resulting file, then send the file to client and END.</li>
 * <li>OTHERWISE delete all old temporary files which were created by previous requests.</li>
 * <li>Get names of all sample FO documents saved on server.</li>
 * <li>Obtain request parameters from GET or POST (as JavaScript is called on conversion form submit and changes the POST method to GET method if no file is to be uploaded).</li>
 * <li>Save uploaded file to temporary directory if it sent by client.</li>
 * <li>Otherwise if sample FO document name is in the request, check that it is the name of some of the sample FO documents.</li>
 * <li>Output the page start and the conversion form.</li>
 * <li>If no trasnformation is requested (uploaded nor sample file specified), then output page end and END.</li>
 * <li>OTHERWISE prepare the temporary directory where generated files will be saved for this request ("session").</li>
 * <li>Open the uploaded or sample file as a DOM document.</li>
 * <li>Prepare new instance of XSLT processor and set all necessary parameters according to the request parameters.</li>
 * <li>Run the XSLT transformation, capture all XSLT messages by own error handler.</li>
 * <li>Make an ODF archive (i.e. ZIP) from the files output by the XSLT transformation if "flat ODF" was not requested.</li>
 * <li>Print transformation results and offer the resulting ODF file for download by the client.</li>
 * <li>Delete all temporary files which are no longer necessary.</li>
 * <li>If automatic download was requested, then redirect the client to the resulting file (by JavaScript).</li>
 * </ol>
 *
 * Note: This script is written in the style that it can be executed on any server even if 'safe_mode' PHP directory is on.
 * Note: This script can run "as a service" as well - by passing a non-empty parameter named "silent".
 *  
 * TODO Enable to use uploaded images in the conversion process as well. This can be probably done only by enabling the user to upload a ZIP archive
 * instead of a simple FO. The archive must contain one *.fo file in the root and other files in the archive will be expected to be images. Now images
 * are searched only in the samples directory. 
 *
 * @author Petr Bodnár <p.bodnar@centrum.cz>
 * @require PHP 5.4+ (although the script is written in a PHP 4 style) with libxslt 1.1.?+ (it must implement all EXSLT functions used)
 * @version 1.0
 * @created 2008-03-24
 */

// suppress warnings from the new PHP versions:
error_reporting(E_ALL ^ E_DEPRECATED ^ E_STRICT ^ E_NOTICE);

require_once("utils.inc.php");

$gpReader = new ParamsReaderGP();

/* ===== Configuration ===== */

require_once("serverSettings.inc.php");

/* ===== The logic starts here...  ===== */

if ($gpReader->getParam("downloadResult", false)) {
	sendResultFile($tempDir. "/", $gpReader->getParam("downloadResult"));
	exit();
}

$sampleFilenames = getSampleFilenames($samplesDir);

if ($gpReader->getParam("downloadSample", false)) {
	sendSampleFile($gpReader->getParam("downloadSample"));
	exit();
}

deleteOldFiles($tempDir, $cleanupInterval);

/* ===== Process request parameters ===== */

$enterNewTransformationLink = "[<a href=\"" . $_SERVER['PHP_SELF'] . "\" title=\"Enter new transformation parameters\">Enter new</a>]";

$autoDownload = $gpReader->getParam("autoDownload", false);
$flatODF = $gpReader->getParam("flatODF", false);
$silent = $gpReader->getParam("silent", false);
$loggingLevel = $gpReader->getParam("loggingLevel", "warn");
if (!in_array($loggingLevel, array("off", "error", "warn", "info", "debug", "trace"))) {
	$loggingLevel = "warn";
}
$sampleFilename = $gpReader->getParam("sampleFilename", "");

$errors = array();

$fileUploaded = false;
if (is_array($_FILES['file'])) {
	/* Handle uploaded FO document instead of sample FO document */
	$fileUploaded = true;
	do {
		$uploadedFilepath = null;
		$uploadedFile = &$_FILES['file'];
		$uploadedFilename = $uploadedFile['name'];

		if ($uploadedFile['size'] == 0) {
			$errors[] = "Size of the uploaded file is null. Maybe you specified a wrong path to file on your disk? Or maybe it is too big.";
			break;
		}
		if ($uploadedFile['size'] > $maxUploadedFileSize) {
			$errors[] = "The uploaded file is too big (" . toHtmlNumber($uploadedFile['size'] / 1024) . "&nbsp;KB). Maximum allowed uploaded file size is "
					. toHtmlNumber($maxUploadedFileSize / 1024) . "&nbsp;KB.";
			break;
		}

		// the uploaded file can't be read from the temp directory on server so we must move it now
		$uploadedFilepath = tempnam($uploadDir, "tempFO");
		if ($uploadedFilepath === false) {
			$errors[] = "Failed to create a temporary file on the server. $errorForAdminStr";
			break;
		}
		if (!move_uploaded_file($uploadedFile['tmp_name'], $uploadedFilepath)) {
			$errors[] = "Failed to read the uploaded file. $errorForAdminStr";
			break;
		}
	} while (false);
} else if ($gpReader->getParam("sampleFilename", false)) {
	/* Convert a sample FO document */
	if (!in_array($sampleFilename, $sampleFilenames)) {
		$errors[] = "Sample file '$sampleFilename' does not exist on the server.";
	}
} else {
	// Perform no action, just display the form.
}

$inputFilename = $fileUploaded ? $uploadedFilename : $sampleFilename;

$doTheConversion = !$errors && $inputFilename != "";

if ($doTheConversion && $silent) {
	ob_start();
}

/* ===== Output page start and the conversion form ===== */
require("pageStartAndForm.inc.php");

$transformationSuccessful = false;// initial value

print "<div id=\"resultsBlock\">\n";

if ($doTheConversion) {
	/* ===== Transformation is requested and no error occured yet - perform the transformation. ===== */

	do {
		/* Prepare the transformation */
		$tempSessionDir = $tempDir . "/session" . md5(uniqid(rand(), true));
		if (!is_dir($tempSessionDir) && !SafeMode::mkdir($tempSessionDir, 0777, true/* recursive*/)) {
			$errors[] = "Failed to create temporary directory for this session. $errorForAdminStr";
			break;
		}
	
		$outputFilename = $inputFilename . ($flatODF ? ".oft" : ".odt");
		$outputFilepath = "$tempSessionDir/$outputFilename";
		$downloadOutputURL = $_SERVER['PHP_SELF'] . "?downloadResult=" . urlencode($outputFilepath);
		
		// --- MAKE THE TRANSFORMATION
		@set_time_limit(60);// 1 minute; function can be disabled for security reasons on the server

		// Load the stylesheet as a DOM document
		$xsl = new DomDocument();
		$stylesheetFilename = $flatODF ? "fo2odf-one_xml.xsl" : "fo2odf-archive.xsl";
		$orig = ini_set("track_errors", 1);
		if (!@$xsl->load("$stylesheetsDir/$stylesheetFilename")) {
			$errors[] = "Failed to load the stylesheet file '$stylesheetFilename'. $errorForAdminStr";
			if ($showXmlErrors) {
				$errors[count($errors) - 1] .= " Error message: $php_errormsg";
			}
			break;
		}

		// Load the input XML file as a DOM document
		$inputdom = new DomDocument();
		if (!@$inputdom->load($fileUploaded ? $uploadedFilepath : "$samplesDir/$sampleFilename")) {
			$errors[] = "Failed to load the source FO document '$inputFilename' - it is probably not a valid XML file.";
			if ($showXmlErrors) {
				$errors[count($errors) - 1] .= " Error message: $php_errormsg";
			}
			break;
		}
		ini_set("track_errors", $orig);

		// Create the XSLT processor and import the stylesheet
		$proc = new XsltProcessor();
		if (!$proc->hasExsltSupport()) {
		    $errors[] = "EXSLT support not available! $errorForAdminStr";
		    break;
		}
		$proc->registerPHPFunctions();
		$proc->importStylesheet($xsl);

		// Prepare temporary directories for transformation
		$transfDir = "$tempSessionDir/transformed";
		if (!$flatODF) {
			SafeMode::mkdir($transfDir . "/META-INF", 0777, true);// creates META-INF subdir as well
			$proc->setParameter("", "output-dir", $transfDir . "/");
			$proc->setParameter("", "php-safe_mode", SafeMode::isActive() ? "yes" : "no");
			
			// Note: This is necessary after this security feature was implemented in PHP 5.4.0: https://bugs.php.net/bug.php?id=54446
			$proc->setSecurityPrefs(XSL_SECPREF_NONE);
		}

		// Set stylesheet parameters
		$proc->setParameter("", "global-log-level", $loggingLevel);

		// Perform the XSLT transformation
		print "<p>Starting transformation of '$inputFilename'... $enterNewTransformationLink</p>";
		$enterNewTransformationLink = "";
		if (!$silent) {
			ob_flush();flush();// sends output to client so he immediately sees what's happening
		}
		$useDefaultErrorHandler = false;
		set_error_handler("myErrorHandler", E_WARNING);
		$xsltMessagesCount = 0;// modified by the error handler if a message occurs
		$xsltError = "";// modified by the error handler

		$startTime = microtime(true);
		$newdom = $proc->transformToDoc($inputdom);
		$endTime = microtime(true);

		if ($xsltMessagesCount > 0) {
?>
</div>
<?php

		}

		restore_error_handler();
		$transformationTime = round($endTime - $startTime, 3);

		// Print results of transformation
		print "<p>Transformation took " . $transformationTime . " seconds</p>\n";

		if ($newdom === false || $xsltError) {
			$errors[] = "XSLT transformation failed";
			break;
		}

		if ($flatODF) {
			// --- RETURN FLAT ODF DOCUMENT - 1 XML file
			$newdom->encoding = "utf-8";// without this line entities would be used for non-ascii characters
			$newdom->save(SafeMode::getFilepath($outputFilepath));
		} else {
			// --- MAKE THE ODF ZIP ARCHIV
			$zip = new ZipArchive();

			// Note: As of PHP 5.2.6 CREATE flag needs to be supplied as well (see http://php.net/manual/en/ziparchive.open.php#88765):
			if ($zip->open(SafeMode::getFilepath($outputFilepath), ZipArchive::CREATE | ZipArchive::OVERWRITE) !== TRUE) {
			    $errors[] = "Cannot open file for creating the ODF zip file. $errorForAdminStr";
			    break;
			}

			// TODO Probably ALL files from the $transfDir and subdirs could be packed...
			$odfFiles = array(
				"mimetype",
				"content.xml",
				"meta.xml",
				"settings.xml",
				"styles.xml",
				"META-INF/manifest.xml",
			);

			foreach ($odfFiles as $odfFile) {
				$zip->addFile(SafeMode::getFilepath("$transfDir/$odfFile"), "$odfFile");
			}

			// print "ZIP numfiles: " . $zip->numFiles . "\n";
			// print "status:" . $zip->status . "\n";
			if ($zip->status != 0) {
				$errors[] = "Error appeared while adding files to the ODF zip file. $errorForAdminStr";
			}
			$zip->close();
		}
		
		$transformationSuccessful = true;

?>
<p>
    <span style="color: green">FO to ODF conversion successful, download the result file:
    [<a href="<?php print $downloadOutputURL;?>"><?php print $outputFilename;?></a>].</span>
    Warning: The file will be automatically deleted from this server after some time.
</p>
<?php

		if ($autoDownload && !$silent) {

?>
<script type="text/javascript">
<!--
function offerFileDownload() {
	document.location = "<?php print $downloadOutputURL;?>";
}
window.setTimeout("offerFileDownload()", 1000);
//-->
</script>

<?php

		}
	} while (false);

} //~~ if ($doTheConversion)

/* Cleanup... */
if (isset($uploadedFilepath) && file_exists($uploadedFilepath)) {
	unlink($uploadedFilepath);
}
if (!empty($transfDir)) {
	SafeMode::removeDir($transfDir);
}

/* Display errors if any... */
if ($errors) {
	print "<p style=\"color: red\">Transformation failed because there were errors: $enterNewTransformationLink</p>\n<ul id=\"errors\">";
	foreach ($errors as $error) {
		print "<li>$error</li>\n";
	}
	print "</ul>\n";
}

if ($doTheConversion && $silent) {
	if ($transformationSuccessful) {
		/* Send the result file to client */
		ob_end_clean();
		sendResultFile($tempDir. "/", $outputFilepath);
		exit();
	} else {
		/* Display the page with errors */
		ob_end_flush();
		print "<p>(Silent transformation failed)</p>";
	}
}

print "</div>\n";// id="resultsBlock"

?>

</body>
</html>