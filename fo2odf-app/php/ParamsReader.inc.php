<?php

/**
 * Class for getting parameters f.e. from $_GET, $_POST and other arrays.
 *
 * @package library
 * @author Petr Bodnár <p.bodnar@centrum.cz>
 */
class ParamsReader
{

	var $source;

	var $altSource;

	var $setParamsToAltSource = false;

	/**
	 * Constructor
	 *
	 * @param array $source  an associative array
	 * @access public
	 */
	function ParamsReader(&$source)
	{
		$this->source = &$source;
	}

	/**
	 * Sets an alternative source array
	 *
	 * @param array $altSource  an alternative source array
	 * @access public
	 */
	function setAltSource(&$source, $setParamsToAltSource = false) {
		$this->altSource = &$source;
		$this->setParamsToAltSource = $setParamsToAltSource;
	}

	/**
	 * Gathers a parameter from the {@link $source} array.
	 *
	 * @param string $name
	 * @param mixed $valueIfEmpty
	 * @return mixed
	 * @access public
	 */
	function getParam($name, $valueIfEmpty = null)
	{
		$source = &$this->source;
		if (isset($source[$name])) {
			// the param is in the source
			$param = &$source[$name];
			if (is_string($param)) {
				$trimmed = trim($param);
				$result = ($trimmed == "") ? $valueIfEmpty : $trimmed;
			} else {
				$result = &$param;
			}
		} else {
			// the param isn't in the source
			if (!isset($valueIfEmpty)) {
				$this->onMissingParam($name);
			}
			$result = $valueIfEmpty;
		}
		return $result;
	}

	/**
	 * Gathers a parameter from the {@link $source} array, or from the {@link $altSource} array.
	 * If {@link $setParamsToAltSource} is true (default false), then the parameter value is set to
	 * the alternative source array (f.e. $_SESSION could be used).
	 *
	 * @param string $name
	 * @param string $altName
	 * @param mixed $valueIfEmpty
	 * @return mixed
	 * @access public
	 */
	function getParamAlt($name, $altName, $valueIfEmpty = null)
	{
		$source = &$this->source;
		if (isset($source[$name])) {
			// the param is in the source
			$param = &$source[$name];
			if (is_string($param)) {
				$trimmed = trim($param);
				$result = ($trimmed == "") ? $valueIfEmpty : $trimmed;
			} else {
				$result = &$param;
			}
		} else if (isset($this->altSource) && isset($this->altSource[$altName])) {
			// the param is in the alternative source
			$result = $this->altSource[$altName];
		} else {
			// the param isn't in any source
			if (!isset($valueIfEmpty)) {
				$this->onMissingParam($name);
			}
			$result = $valueIfEmpty;
		}
		if (isset($this->altSource) && $this->setParamsToAltSource) {
			// set the param to the alternative source
			$this->altSource[$altName] = $result;
		}
		return $result;
	}

	/**
	 * @return void
	 * @access protected
	 */
	function onMissingParam($name)
	{
		exit("Missing parameter(s)! ($name)");
	}

}

?>