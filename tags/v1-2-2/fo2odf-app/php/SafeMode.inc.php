<?php

define("SAFE_MODE_PATH_SEPAR", "--");

require_once("StringUtils.inc.php");
require_once("filesystem.inc.php");

/**
 * Utils for PHP's paranoid 'safe_mode'.
 */
class SafeMode {

	/**
	 * @access public
	 * @static	 
	 */
	function isActive() {
		return ini_get("safe_mode");
	}
	
	/**
	 * @access public
	 * @static	 
	 */	 	
	function mkdir($dirname, $mode = 0777, $recursive = false) {
		if (SafeMode::isActive()) {
			return -1;
		}
		$res = mkdir($dirname, $mode, $recursive);
		if ($res) {
			// we need to set the $mode once again as 'umask' could alter it within mkdir() - see http://stackoverflow.com/questions/6229353/permissions-with-mkdir-wont-work
			chmod($dirname, $mode);
		}
		return $res;
	}
	
	/**
	 * @access public
	 * @static	 
	 */
	function getFilepath($normalPath) {
		return SafeMode::isActive() ? str_replace("/", SAFE_MODE_PATH_SEPAR, $normalPath) : $normalPath;
	}
	
	/**
	 * @access public
	 * @static	 
	 */
	function removeDir($dirname) {
		if (SafeMode::isActive()) {
			foreach (scandir(".") as $filename) {
				if (StringUtils::startsWith($filename, SafeMode::getFilepath($dirname) . SAFE_MODE_PATH_SEPAR)
						&& is_file($filename)) {
					unlink($filename);
				}
			}
		} else {
			removeDir($dirname);
		}
	}
	
	/**
	 * @access public
	 * @static	 
	 */
	function scandir($dirname) {
		if (SafeMode::isActive()) {
			$filenames = array();
			foreach (scandir(".") as $filename) {
				if (StringUtils::startsWith($filename, $dirname . SAFE_MODE_PATH_SEPAR) && is_file($filename)) {
					$filenames[] = $filename;
				}
			}
			return $filenames;
		} else {
			return scandir($dirname);
		}
	}
	
}

?>
