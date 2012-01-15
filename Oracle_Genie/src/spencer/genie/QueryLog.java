package spencer.genie;

import java.util.Date;

/**
 * Record for query log
 * 
 * @author spencer.hwang
 *
 */
public class QueryLog {
	Date qryTime = new Date();	
	String qryString;
	
	public QueryLog(String q) {
		qryString = q;
	}
	
	public String getQueryString() {
		return qryString;
	}
	
	public Date getTime() {
		return qryTime;
	}
}
