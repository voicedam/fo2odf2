<?php

require_once(dirname(__FILE__) . "/ImageInfo.inc.php");

/**
 * @package Images
 * @author Petr Bodnar <p.bodnar@centrum.cz>
 */ 
class ImageUtils {

	/**
	 * Returns image info from a file.
	 * 	 	
	 * @param string $filename
	 * @return ImageInfo
	 * @access public
	 * @static
	 */
	function getImageInfo($filename) {
		$info = getimagesize($filename);
		if (!$info) {
			return $info;
		}
		$iinfo = new ImageInfo($info);
		return $iinfo;
	}

} 

?>