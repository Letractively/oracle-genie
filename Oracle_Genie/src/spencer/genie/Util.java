package spencer.genie;

import java.io.UnsupportedEncodingException;

import org.apache.commons.lang3.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;

/**
 * Utility class for Genie
 * 
 * @author spencer.hwang
 *
 */
public class Util {

	public static int countLines(String str) {
		String[] lines = str.split("\r\n|\r|\n");
		return lines.length;
	}
	
	public static int countMatches(String str, String value) {
		int count = StringUtils.countMatches(str, value);
		return count;
	}
	
	public static String buildCondition(String col, String key) {
		String res=null;
		
		if (key==null || col==null) return null;
		
		String[] cols = col.split(",");
		String[] keys = key.split("\\^");
		if (cols.length != keys.length) {
			
			System.out.println(col + " " + key);
			System.out.println(cols.length + " " + keys.length);
			return "ERROR";
		}
		
		for(int i =0; i < cols.length; i++) {
			if (res==null) {
				res = cols[i].trim() + "='" + keys[i] +"'";
			} else {
				res = res + " AND " + cols[i].trim() + "='" + keys[i] + "'";
			}
		}
			
		return res;
	}
	
	public static String escapeHtml(String str) {
		return StringEscapeUtils.escapeHtml3(str);
	}
	
	public static String encodeUrl(String str) throws UnsupportedEncodingException {
		if (str==null) return null;
		return java.net.URLEncoder.encode(str, "ISO-8859-1");
	}
	
}
