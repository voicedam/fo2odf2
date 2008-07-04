<?php

/**
 * @requires PHP 4.3+
 * @package Images
 * @author Petr Bodnar <p.bodnar@centrum.cz>
 */ 
class ImageInfo {

	/**
	 * @var int	
	 * @access public 
	 */	 	
	var $width;
	
	/**
	 * @var int	
	 * @access public
	 */	 	
	var $height;
	
	/**
	 * Corresponds to a PHP's IMAGETYPE_... constant.
	 * 	 
	 * @var int
	 * @access public
	 */	 	
	var $type;
	
	/**
	 * f.e. 'width="400" height="300"'.
	 *
	 * @var string 	
	 * @access public
	 */	 	
	var $sizeHtmlString;
	
	/**
	 * 3 for RGB images, 4 for CMYK images.
	 * 	 
	 * @var int
	 * @access public
	 */	 	
	var $channels;
	
	/**
	 * Number of bits for each color.
	 * 	 
	 * @var int
	 * @access public
	 */	 	
	var $bits;
	
	/**
	 * MIME type of the image. Can be used in the "Content-type" response header.
	 * 	 
	 * @var string
	 * @access public
	 */	 	
	var $mime;
	
	/**
	 * @param $info array  array returned by getimagesize()
	 * @access public
	 */ 	 	
	function ImageInfo($info) {
		$this->width = $info[0];
		$this->height = $info[1];
		$this->type = $info[2];
		$this->sizeHtmlString = $info[3];
		@$this->channels = $info["channels"];
		@$this->bits = $info["bits"];
		$this->mime = $info["mime"];
	}
	
}

?>