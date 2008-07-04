<?php

/**
 * This file contains functions which are called from XSLT stylesheet during transformation.
 * In case of an error, the functions return string which starts with 'Error: ' prefix so
 * the XSLT stylesheet can recognize that an error occured.  
 */
 
require_once("ImageUtils.inc.php");

/**
 * Returns information about a given image in this format: 'width: &lt;number&gt;; height: &lt;number&gt;;'.
 * 
 * TODO Capturing of error messages for passing them to XSLT doesn't work well yet. Maybe use exceptions (available siince PHP 5)?
 *   
 * @param string $filepath
 * @param number $pixelsToPointsRatio
 * @return string  'width: &lt;number&gt;; height: &lt;number&gt;' for the given image.  
 * @access public  
 */
function getImageInfo($filepath, $pixelsToPointsRatio) {
	global $useDefaultErrorHandler;
	global $uploadDir;
	
	$orig = ini_set("track_errors", 1);
	$useDefaultErrorHandler = true;
	
	$contents = getXSLTFileContents($filepath);
	if ($contents === false) {
		$result = "Error: Failed to get file contents";
	} else {
		$tempImageName = tempnam($uploadDir, "tempImage");
		file_put_contents($tempImageName, $contents);
		$imgInfo = ImageUtils::getImageInfo($tempImageName);
		if (!$imgInfo) {
			$result = "Error: Failed to get image info";
		} else {
			$result = "width: " . round($imgInfo->width * $pixelsToPointsRatio)
					. "; height: ". round($imgInfo->height * $pixelsToPointsRatio) . ";";
		}
		unlink($tempImageName);
	}
	ini_set("track_errors", $orig);
	$useDefaultErrorHandler = false;
	
	return $result;
}

/**
 * Returns content of a given file. The content is encoded in BASE64.
 * 
 * @param string $filepath
 * @return string  content of the file in BASE64 encoding.
 * @access public  
 */
function getFileInBase64($filepath) {
	global $useDefaultErrorHandler;
	
	$orig = ini_set("track_errors", 1);
	$useDefaultErrorHandler = true;
	$contents = getXSLTFileContents($filepath);
	if ($contents === false) {
		$result = "Error: Failed to get file contents";
	} else {
		$result = base64_encode($contents);
	}
	ini_set("track_errors", $orig);
	$useDefaultErrorHandler = false;
	
	return $result;
}

/**
 * @access private
 */ 
function getXSLTFileContents($filepath) {
	global $samplesDir;
	global $tempDir;
	global $tempSessionDir;
	
	//$filepath = getXSLTFilepath($filepath);
	
	//$tempSessionImagesDir = SafeMode::isActive() ? $tempDir : $tempSessionDir;
	$origIncludePath = get_include_path();
	set_include_path(implode(PATH_SEPARATOR, array($samplesDir /* TODO Only when a sample file is processed */)));

	$contents = file_get_contents(((parse_url($filepath, PHP_URL_SCHEME) == "") ? $samplesDir . "/" : "") . $filepath);
	
	set_include_path($origIncludePath);
	
	return $contents;
}

/**
 * @access private
 */ 
function getXSLTFilepath($filepath) {
	global $samplesDir;
	global $tempDir;
	global $tempSessionDir;

	$tempSessionImagesDir = SafeMode::isActive() ? $tempDir : $tempSessionDir;
	
	if (SafeMode::isActive() && (parse_url($filepath, PHP_URL_SCHEME) == "")) {
		$filepath = SafeMode::getFilepath($tempSessionDir . "/" . $filepath);
	}
	
	return $filepath;
}

?>