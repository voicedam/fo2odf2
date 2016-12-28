<?php

/**
 * Removes a given directory with all its content (recursively).
 */
function removeDir($dir) {
	if (is_dir($dir)) {
		foreach (scandir($dir) as $file) {
			if ($file == "." || $file == "..") {
				continue;
			}
			$file = "$dir/$file";
			if (is_dir($file)) {
				removeDir($file);
			} else {
				unlink($file);
			}
		}
		rmdir($dir);
	}
}

?>