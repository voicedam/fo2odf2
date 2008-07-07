import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

import javax.imageio.ImageIO;

import sun.misc.BASE64Encoder;

/**
 * This class contains functions which are called from XSLT stylesheet during
 * XSLT transformation. In case of an error, the functions return string which
 * starts with 'Error: ' prefix so the XSLT stylesheet can recognize that an
 * error occured.
 * 
 * @author Petr Bodnar
 */
public class MyJavaUtils {

	/**
	 * 'baseURI' of the currently processed XML document.
	 */
	private static String baseURI = ".";

	/**
	 * Saves 'baseURI' of the currently processed XML document. It can be used
	 * later for obtaining files whose location is specified as a relative path.
	 * <p>
	 * Because the 'baseURI' is a static field in this class, there must not be
	 * any other call to this function until the whole XML document is
	 * transformed. I.e. paralel access to this class from more transformations
	 * don't have to end with correct results.
	 * 
	 * @param aBaseURI
	 */
	public static void saveBaseURI(String aBaseURI) {
		baseURI = aBaseURI;
	}

	/**
	 * Returns information about a given image in this format: 'width:
	 * &lt;number&gt;; height: &lt;number&gt;;'.
	 * 
	 * @param filepath
	 * @param pixelsToPointsRatio
	 * @return 'width: &lt;number&gt;; height: &lt;number&gt;' for the given
	 *         image.
	 */
	public static String getImageInfo(String filepath,
			double pixelsToPointsRatio) {
		try {
			InputStream imageInputStream = getInputStream(filepath);
			BufferedImage image = ImageIO.read(imageInputStream);
			if (image == null) {
				return "Error: "
						+ "The specified file was not recognized to be an image in any supported image format";
			} else {
				return "width: "
						+ Math.round(image.getWidth() * pixelsToPointsRatio)
						+ "; height: "
						+ Math.round(image.getHeight() * pixelsToPointsRatio)
						+ ";";
			}
		} catch (Throwable e) {
			return "Error: " + e;
		}
	}

	/**
	 * Returns content of a given file. The content is encoded in BASE64.
	 * 
	 * @param filepath
	 * @return content of the file in BASE64 encoding.
	 */
	public static String getFileInBase64(String filepath) {
		try {
			byte[] bytes = getFileContents(filepath);
			BASE64Encoder encoder = new BASE64Encoder();
			return encoder.encode(bytes);
		} catch (Throwable e) {
			return "Error: " + e;
		}
	}

	private static byte[] getFileContents(String filepath) throws Exception {
		InputStream inputStream;
		inputStream = getInputStream(filepath);
		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
		byte[] buffer = new byte[1024];
		int bytesRead;
		while ((bytesRead = inputStream.read(buffer)) != -1) {
			outputStream.write(buffer, 0, bytesRead);
		}
		return outputStream.toByteArray();
	}

	private static InputStream getInputStream(String filepath) throws Exception {
		InputStream inputStream;
		if (isURL(filepath)) {
			inputStream = new URL(filepath).openConnection().getInputStream();
		} else {
			String absFilepath = null;
			File file = new File(filepath);
			if (!file.isAbsolute()) {
				absFilepath = baseURI + "/" + filepath;
			} else {
				absFilepath = filepath;
			}
			inputStream = new FileInputStream(absFilepath);
		}
		return inputStream;
	}

	private static boolean isURL(String str) {
		try {
			new URL(str);
		} catch (MalformedURLException e) {
			return false;
		}
		return true;
	}
}
