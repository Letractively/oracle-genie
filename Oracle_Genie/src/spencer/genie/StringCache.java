package spencer.genie;

import java.util.Enumeration;
import java.util.Hashtable;

/**
 * Singleton object for managing Query object caching
 * 
 * @author Spencerh
 *
 */
public class StringCache {

/*	static StringCache instance = null;
	static String urlString = null;
*/	Hashtable<String, String> strings = new Hashtable<String, String>();
			
	private StringCache() {
	}
	
	public static StringCache getInstance() {
/*		if (instance==null && urlString==null) {
			urlString = urlStr;
			instance = new StringCache();
		}*/
		return  new StringCache();
	}
	
	public String get(String str) {
		String res = strings.get(str);
		return res;
	}
	
	public void add(String sql, String str) {
		if (str ==null) return;
		strings.put(sql, str);
	}
	
	public void remove(String sql) {
		strings.remove(sql);
	}
	
	public void clearAll() {
		strings.clear();
	}

	public Enumeration<String> getKeys() {
		return strings.keys();
	}
	
}
