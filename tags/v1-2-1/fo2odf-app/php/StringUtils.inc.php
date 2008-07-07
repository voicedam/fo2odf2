<?php

/**
 * @package library
 */

$base64Characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-,";

/**
 * This class contains various methods for working with strings - transformation, checking and so on.
 *
 * @package library
 * @author Petr Bodnár <p.bodnar@centrum.cz>
 */
class StringUtils
{

	/**
	 * @param string $str
	 * @param integer $len  how much from the end of the string should be omitted
	 * @return string
	 * @static
	 */
	function truncate($str, $len)
	{
		return (string) substr($str, 0, strlen($str) - $len);
	}

	/**
	 * @param string $str
	 * @return string
	 * @static
	 */
	function addSlashes($str)
	{
		return get_magic_quotes_gpc() ? $str : addslashes($str);
	}

	/**
	 * @param string $str
	 * @return string
	 * @static
	 */
	function stripSlashes($str)
	{
		return get_magic_quotes_gpc() ? stripslashes($str) : $str;
	}

	/**
	 * @param string $str
	 * @return string
	 * @static
	 */
	function mysqlRealEscape($str)
	{
		return mysql_real_escape_string(StringUtils::stripSlashes($str));
	}

	/**
	 * @param string $str
	 * @param boolean $stripSlashes
	 * @return string
	 * @static
	 */
	function toHtmlText($str, $stripSlashes = true)
	{
		return htmlspecialchars($stripSlashes ? StringUtils::stripSlashes($str) : $str);
	}

	/**
	 * @param string $str
	 * @return boolean
	 * @static
	 */
	function isValidEmail($str)
	{
		$len = strlen($str);
		$lastPos = $len - 1;
		$atPos = strrpos($str, "@");
		if ($atPos < 1 || $atPos == $lastPos) {
			return false;
		}
		$dotPos = strrpos($str, ".");
		if ($dotPos < $atPos || $dotPos == $lastPos) {
			return false;
		}
		return true;
	}

	/**
	 * @param string $str
	 * @param integer $maxLength
	 * @return string
	 * @static
	 */
	function truncateWithThreeDotsIfLonger($str, $maxLength)
	{
		return StringUtils::truncateIfLonger($str, $maxLength, "...");
	}

	/**
	 * @param string $str
	 * @param integer $maxLength
	 * @param string $truncator
	 * @return string
	 * @static
	 */
	function truncateIfLonger($str, $maxLength, $truncator = "")
	{
		$length = strlen($str);
		if ($maxLength < 0) {
			$maxLength = 0;
		}
		if ($length <= $maxLength) {
			return $str;
		}
		$str = substr($str, 0, $maxLength).$truncator;
		return $str;
	}

	/**
	 * @param string $str
	 * @return boolean
	 * @static
	 */
	function isTwoDigits($str)
	{
		return preg_match("/^\d{2}\$/", $str);
	}

	/**
	 * Returns the parameter converted to <samp>'name="value", ...'</samp> string.
	 *
	 * @param array $attributes
	 * @param string $quoteChar  <samp>"</samp> (default) or <samp>'</samp>
	 * @return string
	 * @static
	 */
	function toHtmlAttributes($attributes, $quoteChar = "\"")
	{
		$result = "";
		if (!is_array($attributes)) {
			return $result;
		}
		foreach ($attributes as $name => $value) {
			if ($value === false) {
				continue;
			}
			$result .= "$name=$quoteChar$value$quoteChar ";
		}
		return substr($result, 0, strlen($result) - 1);
	}

	/**
	 * @param string $str
	 * @return number false if the string doesn't have the right format
	 * @static
	 */
	function toNumber($str)
	{
		$n = str_replace(",", ".", $str);
		return is_numeric($n) ? 1*$n : false;
	}

	/**
	 * @param string $str
	 * @return integer false if the string doesn't have the right format
	 * @static
	 */
	function toInteger($str)
	{
		$n = StringUtils::toNumber($str);
		return ($n !== false && is_integer($n)) ? $n : false;
	}

	/**
	 * @param string $str
	 * @return string all occurences of " " are replaced by "&nbsp;"
	 * @static
	 */
	function spaceToNbsp($str)
	{
		return str_replace(" ", "&nbsp;", $str);
	}

	/**
	 * Returns whether a string ends with another string
	 *
	 * @param string $str
	 * @param string $end
	 * @return boolean
	 * @access public
	 * @since 1.2.0
	 * @static
	 */
	function endsWith($str, $end)
	{
		return substr($str, -strlen($end)) == $end;
	}

	/**
	 * @since 1.2.0
	 * @static
	 */
	function removeBoundaryString($str, $bstr)
	{
		$blength = strlen($bstr);
		// 1) remove the start boundary
		if (StringUtils::startsWith($str, $bstr)) {
			$str = substr($str, $blength);
		}
		// 2) remove the end boundary
		if (StringUtils::endsWith($str, $bstr)) {
			$str = substr($str, 0, -$blength);
		}
		return $str;
	}

	/**
	 * Returns $str with these modifications:
	 * @todo Description
	 *
	 * The returned string can then be used as a pattern with the preg_... functions.
	 *
	 * @param string $str
	 * @return string the converted string
	 * @since 1.2.0
	 * @static
	 */
	function toPregPattern($str)
	{
		$result = $str;
		if (preg_match("/^\**$/", $str)) { // empty string OR only one or more '*' characters
			return "";
		}
		$start = "";
		$end = "";
		if (!StringUtils::startsWith($result, "*")) {
			// $str should start at the beginning
			$start = "^";
		} else {
			// remove the opening *-s
			$result = preg_replace("/^\**/", "", $result);
		}
		if (!StringUtils::endsWith($result, "*")) {
			// $str should end at the end
			$end = "\$";
		} else {
			// remove the closing *-s
			$result = preg_replace("/\**$/", "", $result);
		}
		// replace every '?' by '.'
		$result = str_replace("?", ".", $result);
		// replace every '*' by '.*?' (non-greedy)
		$result = str_replace("*", ".*?", $result);
		// replace every non-alphanumeric character by an escape sequence (except these: .*? and _)
		$result = preg_replace("/[^\w\.\*\?]/", "\\\\$0", $result);
		return $start . $result . $end;
	}

	/**
	 * For positive numbers it returns the number preceded with "+", otherwise
	 * it just only returns the number.
	 *
	 * @param number $num
	 * @return mixed "+$num" or $num
	 * @since new
	 * @static
	 */
	function addSign($num)
	{
		if ($num > 0) {
			$num = "+" . $num;
		}
		return (string)$num;
	}

	/**
	 * Returns whether a string starts with another string
	 *
	 * @param string $str
	 * @param string $start
	 * @return boolean
	 * @access public
	 * @static
	 */
	function startsWith($str, $start)
	{
		return substr($str, 0, strlen($start)) == $start;
	}

	/**
	 * Replaces any subsequent whitespace characters by
	 * exactly one space character and trims the string from both sides.
	 *
	 * @param string $str
	 * @return string  normalized string
	 * @access public
	 * @static
	 */
	function normalizeSpace($str) {
		return trim(preg_replace("/\s+/", " ", $str));
	}

	/**
	 * Returns string which can be used for safe inserting of a decimal number into database.
	 *
	 * @param number $number
	 * @param int $decimals  number of decimals
	 * @return string
	 * @access public
	 * @static
	 */
	function toDbNumber($number, $decimals) {
		return number_format($number, $decimals, ".", "");
	}

}

?>