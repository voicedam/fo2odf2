<?php

/**
 * Functions for the main FO2ODF Converter script.
 */

require_once("StringUtils.inc.php");
require_once("ParamsReader.inc.php");
require_once("ParamsReaderGP.inc.php");
require_once("SafeMode.inc.php");
require_once("filesystem.inc.php");
require_once("functions_called_from_xslt.inc.php");

/**
 * Returns names of sample FO documents. Filenames are sorted alphabetically.
 *
 * @param string $samplesDir directory where sample FO documents are stored.
 * @return array  array of filenames ending with ".fo"
 */
function getSampleFilenames($samplesDir) {
	$origDir = getcwd();
	// chdir($samplesDir);
	$filenames = array();
	// Note: glob() not used as it is not working on all systems
	foreach (scandir($samplesDir) as $filename) {
		if (StringUtils::endsWith($filename, ".fo")) {
			$filenames[] = $filename;
		}
	}
	// chdir($origDir);
	return $filenames;
}

/**
 * Deletes all files and directories in a given directory whose date of modification is before
 * (now - the given cleanup interval in seconds). This function is PHP 'safe_mode' aware.
 */
function deleteOldFiles($dir, $cleanupInterval) {
	$thresholdTime = time() - $cleanupInterval;
	foreach (SafeMode::scandir($dir) as $filename) {
		if ($filename == "." || $filename == "..") {
			continue;
		}
		$filepath = SafeMode::isActive() ? $filename : "$dir/$filename";
		if (is_dir($filepath)) {
			deleteOldFiles($filepath, $cleanupInterval);
			if (count(scandir($filepath)) <= 2) {
				rmdir($filepath);
			}
		} else {
			if (filemtime($filepath) < $thresholdTime) {
				unlink($filepath);
			}
		}
	}
}

/**
 * Error handler function for handling messages from the XSLT transformation.
 */
function myErrorHandler($errno, $errstr, $errfile, $errline) {
    global $startTime;
    global $xsltError;
    global $xsltMessagesCount;
	global $silent;
	global $useDefaultErrorHandler;
	
    if ($useDefaultErrorHandler) {
		return false;
	}
	 
	$xsltMessagesCount++;
	if ($xsltMessagesCount == 1) {

?>
<script type="text/javascript">
<!--
document.write('\<div\>[\<a onclick=\"toggleXsltMessages(this)\" href="#"\>Hide XSLT messages\</a\>]\</div\>\n');
//-->
</script>
<div id="xsltMessages" style="display: block">
<?php

	}

	// remove unnecessary "text arround the message"
	$msg = str_replace("XSLTProcessor::transformToDoc() [<a href='function.XSLTProcessor-transformToDoc'>function.XSLTProcessor-transformToDoc</a>]: ", "", $errstr);
	$time = number_format(microtime(true) - $startTime, 3, '.', '');
	echo "<div><b>XSLT transformation message at $time s:</b> $msg</div>\n";
	if (!$silent) {
		ob_flush();flush();
	}

	if (strpos($msg, "FATAL:") === 0) {
		$xsltError = $msg;
	}

	/* Don't execute PHP internal error handler */
	return true;
}

/**
 * Sends result of transformation to the client.
 */
function sendResultFile($mustStartWith, $filepath) {
	$goBackStr = "<a href=\"" . $_SERVER['PHP_SELF'] . "\">Go back to the main page.</a>";
	if (strpos($filepath, $mustStartWith) !== 0 || strpos($filepath, "..") !== false) {
		// maybe an attack
		exit("ERROR: Invalid file path '$filepath'. $goBackStr");
	} else if (file_exists(SafeMode::getFilepath($filepath))) {
		header("Content-Type: application/octet-stream");
		$filename = basename($filepath);
		header("Content-Disposition: attachment; filename=\"$filename\"");
		header("Content-Length: " . (string)filesize(SafeMode::getFilepath($filepath)));// will be ignored if "Transfer-Encoding: chunked" is automatically used by PHP/Apache
		readfile(SafeMode::getFilepath($filepath));
		exit();
	} else {
		exit("ERROR: File '$filepath' not found on server. $goBackStr");
	}
}

/**
 * Sends sample FO document to the client.
 */
function sendSampleFile($filename) {
	global $samplesDir;
	global $sampleFilenames;
	
	$goBackStr = "<a href=\"" . $_SERVER['PHP_SELF'] . "\">Go back to the main page.</a>";
	$filepath = $samplesDir . "/" . $filename;
	if (in_array($filename, $sampleFilenames) && file_exists($filepath)) {
		header("Content-Type: application/octet-stream");
		header("Content-Disposition: attachment; filename=\"$filename\"");
		header("Content-Length: " . (string)filesize($filepath));// will be ignored if "Transfer-Encoding: chunked" is automatically used by PHP/Apache
		readfile($filepath);
		exit();
	} else {
		exit("ERROR: Sample file '$filename' not found on the server. $goBackStr");
	}
}

function toHtmlNumber($number) {
	return str_replace(" ", "&nbsp;", number_format($number, 0, ",", " "));
}

/* ===== Common utils ===== */

/**
 * Prints HTML form options for the SELECT element.
 *
 * @param array $valuesLabels associative array of values and labels
 * @param mixed $selectedValue
 */
function printFormOptions($valuesLabels, $selectedValue = null) {
	printFormOptions2(array_keys($valuesLabels), array_values($valuesLabels), $selectedValue);
}

/**
 * Prints HTML form options for the SELECT element.
 *
 * @param array $values
 * @param array $labels
 * @param mixed $selectedValue
 */
function printFormOptions2($values, $labels, $selectedValue = null) {
	for ($i = 0; $i < count($labels); $i++) {
		$value = $values[$i];
		$label = $labels[$i];
		$selectedStr = isset($selectedValue) && ($value == $selectedValue) ? " selected" : "";
		print "<option value=\"$value\"$selectedStr>$label</option>\n";
	}
}

/**
 * @param boolean $checked
 */
function printChecked($checked) {
	printBooleanAttribute("checked", $checked);
}

/**
 * @param boolean $disabled
 */
function printDisabled($disabled) {
	printBooleanAttribute("disabled", $disabled);
}

/**
 * Implementation differs for HTML and XHTML. This is done for HTML.
 */
function printBooleanAttribute($name, $value = true) {
	print $value ? "$name" : "";
}

?>