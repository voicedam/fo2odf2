<?php

/**
 * This file is included by the main FO2ODF Converter script.
 */

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta name="description" content="FO2ODF Converter [<?php print $versionNumber;?> from <?php print $versionDate;?>]">
<meta name="keywords" content="FO2ODF, Converter, XSL FO, ODF, XSLT, OpenDocument Format, Formatting Objects">
<title>FO2ODF Converter <?php print $versionNumber;?><?php if ($inputFilename != "") { print " - Convert '$inputFilename' to ODF"; }?></title>
<script type="text/javascript" src="common.js"></script>
<script type="text/javascript">
function checkForm(form) {
	try {
		if (form.file.value.trim() == '') {
			form.method = "get";
			form.enctype="application/x-www-form-urlencoded";
		} else {
			form.method = "post";
			form.enctype="multipart/form-data";
		}
	} catch (e) {
		// alert(e);
	}
	if (form.silent.checked) {
		document.getElementById("waitForSilentResult").style.display = "inline";
		document.getElementById("resultsBlock").style.display = "none";
	}
	return true;
}

function checkDisableSampleFilename() {
	var form = document.getElementById("fo2odfForm");
	form.sampleFilename.disabled = form.file.value.trim() != '';
}

function toggleXsltMessages(clickedElem) {
	var msgs = document.getElementById("xsltMessages");
	var hide = msgs.style.display == "block";
	msgs.style.display = hide ? "none" : "block";
	clickedElem.innerHTML = hide ? "Show XSLT messages" : "Hide XSLT messages";
}
</script>
<style type="text/css">
h1 a {
	text-decoration: none;
	color: black;
}

form {
	margin: 10px;
}

acronym { /* Note: IE doesn't support <abbr> well, so acronym is used instead */
	border-bottom: 1px dashed;
}

.withHelp {
	cursor: help;
}

tr.standard td {
	vertical-align: top;
}

.separator {
	margin-top: 8px;
	margin-bottom: 8px;
	border-top: 1px solid black;
}
</style>
</head>
<body>
<h1><a href="<?php print $_SERVER['PHP_SELF'];?>">FO2ODF Converter <?php print $versionNumber;?></a> <span style="font-size: 10pt">(from <?php print $versionDate;?>)</span></h1>

<p>Description: Converts
	<a href="http://en.wikipedia.org/wiki/XSL_Formatting_Objects"><acronym title="XSL Formatting Objects" style="speak: spell-out">XSL FO</acronym></a>
	document to
	<a href="http://en.wikipedia.org/wiki/OpenDocument"><acronym title="OpenDocument format" style="speak: spell-out">ODF</acronym></a>
document.
	Pure <a href="http://en.wikipedia.org/wiki/Xslt"><acronym title="XSL Transformations" style="speak: spell-out">XSLT </acronym></a> 1.0
	with <a href="http://en.wikipedia.org/wiki/EXSLT"><acronym title="EXSLT" style="speak: spell-out">EXSLT</acronym></a>
is used for the transformation.</p>

<div class="separator"></div>

<form action="<?php print $_SERVER['PHP_SELF'];?>" method="post" id="fo2odfForm" enctype="multipart/form-data" onsubmit="return checkForm(this);">
<table cellspacing="0" cellpadding="7" width="100%">
	<col width="200">
  	<col width="*">
	<tr class="standard">
		<td>
			<label class="withHelp" for="sampleFilename" title="Source FO document saved on server">Use sample FO document: </label>
		</td>
		<td>
			<select name="sampleFilename" id="sampleFilename" onchange="document.getElementById('selectedSampleName').innerHTML = this.value; document.getElementById('selectedSampleLink').href = '<?php print $_SERVER['PHP_SELF'] . "?downloadSample="?>' + this.value">
				<?php
				$selectedSample = $sampleFilename ? $sampleFilename : $sampleFilenames[0];
				printFormOptions2($sampleFilenames, $sampleFilenames, $selectedSample);
				?>
			</select>
			&nbsp;&nbsp;
			<a id="selectedSampleLink" href="<?php print $_SERVER['PHP_SELF'] . "?downloadSample=" . urlencode($selectedSample);?>">Download the '<span id="selectedSampleName"><?php print $selectedSample;?></span>'</a>
		</td>
	</tr>
	<tr class="standard">
		<td>
			<label class="withHelp" for="file" title="Source FO document from your disk">...or upload FO document: </label>
		</td>
		<td>
			<input type="file" name="file" id="file" onkeyup="checkDisableSampleFilename();" onchange="checkDisableSampleFilename();">
		</td>
	</tr>
	<tr class="standard">
		<td>
			<label class="withHelp" for="autoDownload" title="Whether to automatically redirect the browser to the result document after transformation">Automatically download: </label>
		</td>
		<td>
			<input type="checkbox" name="autoDownload" id="autoDownload" <?php printChecked($autoDownload);?>>
		</td>
	</tr>
	<tr class="standard">
		<td>
			<label class="withHelp" for="flatODF" title="If selected, the result document will be one XML file which can be open in OpenOffice when the appropriate XML filter is installed">Flat ODF: </label>
		</td>
		<td>
			<input type="checkbox" name="flatODF" id="flatODF" <?php printChecked($flatODF);?>>
		</td>
	</tr>
	<tr class="standard">
		<td>
			<label class="withHelp" for="silent" title="If selected, the result document will be returned immediately, without reloading this page">Silent (as a service): </label>
		</td>
		<td>
			<input type="checkbox" name="silent" id="silent" <?php printChecked($silent);?>>
		</td>
	</tr>
	<tr class="standard">
		<td colspan="2" style="font-style: italic">XSLT stylesheet parameters:</td>
	</tr>
	<tr class="standard">
		<td>
			<label class="withHelp" for="loggingLevel" title="Sets level of logging messages which the stylesheet will send and which will be displayed here. (Non-logging messages will be always displayed.)">Logging level: </label>
		</td>
		<td>
			<select name="loggingLevel" id="loggingLevel">
				<?php printFormOptions($loggingLevels, $loggingLevel); ?>
			</select>
		</td>
	</tr>
	<tr class="standard">
		<td></td>
		<td>
			<input type="submit" name="convert" value="Convert" title="Perform the conversion">
			<span id="waitForSilentResult" style="display: none">&nbsp;&nbsp;You chose the 'silent' transformation - please wait until the download dialog or a page with errors appears...</span>
		</td>
	</tr>
</table>
</form>

<div class="separator"></div>

<script type="text/javascript">
<!--
checkDisableSampleFilename();
//-->
</script>