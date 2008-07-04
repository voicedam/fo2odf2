<?php

require_once("ParamsReader.inc.php");

/**
 * Class for getting parameters from $_GET and/or $_POST
 *
 * @package library
 * @author Petr Bodnár <p.bodnar@centrum.cz>
 */
class ParamsReaderGP extends ParamsReader
{

	/**
	 * Constructor
	 *
	 * @access public
	 */
	function ParamsReaderGP()
	{
		$source = array_merge($_GET, $_POST);// $_POST has higher "priority" than $_GET (and $_COOKIE higher than $_POST)
		parent::ParamsReader($source);
	}

}

?>