<?php

/**
 * Server settings for the FO2ODF Converter.
 */

// Version of this converter.
$versionNumber = "v1.2.1";
$versionDate = "2008-06-28";

// Directory where XSLT stylesheets implementing the FO2ODF conversion reside.
$stylesheetsDir = "../xsl/odf";
// Directory where sample FO documents are saved.
$samplesDir = "../samples";
// Directory for working files and for resulting ODF files.
$tempDir = "temp";
// Directory for uploaded files.
$uploadDir = "../../tmp";

$maxUploadedFileSize = 1024 * 1024;// Maximum size of uploaded files (in bytes).
$showXmlErrors = false;// Security note: error messages contain path to temporary file on the server.
$cleanupInterval = 3 * 60;// How long a generated file remains on the server (in seconds).

// XSLT logging levels - "value" => "label".
$loggingLevels = array(
	"off" => "off",
	"error" => "error",
	"warn" => "warn",
	"info" => "info",
	"debug" => "debug",
	"trace" => "trace",
);

$errorForAdminStr = "Please contact the administrator if this problem persists.";

?>