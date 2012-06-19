package spencer.genie;

import java.sql.Connection;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.List;

public class CpasUtil {
	private Connect cn = null;
	Hashtable <String, String> htCode = new Hashtable <String, String>();
	Hashtable <String, String> htCapt = new Hashtable <String, String>();
	HashSet <String> hsTable = new HashSet<String>();
	HashSet <String> hsTableLoaded = new HashSet<String>();

	String[] exceptions = {"MEMBER_STATUS.VALUE", "PLAN_STATUS.VALUE", "EMPLOYER_STATUS.VALUE", "MEMBER_EMPLOYER_STATUS.VALUE", 
			"MEMBER_PLAN_STATUS.VALUE", "PERSON_STATUS.VALUE", "-MEMBER_SERVICE.SRVCODE"};

	public CpasUtil(Connect cn) {
		this.cn = cn;
/*		
		String qry = "SELECT TNAME, CNAME, CODE, CAPT FROM CPAS_TABLE_COL WHERE TNAME IN (" +
				"SELECT TNAME FROM CPAS_TABLE A WHERE EXISTS (SELECT 1 FROM TAB WHERE TNAME=A.TNAME) " +
				") AND (CODE IS NOT NULL OR CAPT IS NOT NULL) ";
		
		List<String[]> list = cn.queryMultiCol(qry, 4);
		
		for (String[] row : list) {
			String tname = row[1];
			String cname = row[2];
			String code = row[3];
			String capt = row[4];
		
			htCode.put(tname + "." + cname, code);
			htCapt.put(tname + "." + cname, capt);
			hsTable.add(tname);
//			System.out.println(tname + "," + cname + "," + code);
		}
*/
		
		for (String ex: exceptions) {
			int idx = ex.indexOf(".");
			String tname = ex.substring(0,idx);
			String cname = ex.substring(idx+1);

			htCode.put(tname + "." + cname, "");
			htCapt.put(tname + "." + cname, "");
			hsTable.add(tname);
		}
		
		String qry = "SELECT distinct table_name FROM user_tab_cols where column_name in ('CLNT','ERKEY','CTYPE') UNION  " +
				"SELECT TNAME FROM CPAS_TABLE A WHERE EXISTS (SELECT 1 FROM TAB WHERE TNAME=A.TNAME)";
		List<String>tbls =  cn.queryMulti(qry);
		for (String tbl: tbls) {
			hsTable.add(tbl);
		}
		
	}
	
	public String getCodeValue(String tname, String cname, String value, Query q) {
		loadTable(tname);
		if (value==null || value.equals("")) return null;

		// exception handling
		String temp = tname + "." + cname;
		for (String ex: exceptions) {
			if (temp.equals(ex)) {
				String grup = q.getValue("GRUP");

				return getGrupValue(grup, value, q);
			}
		}

		String key = tname + "." + cname;
		String grup = htCode.get(key);
		if (grup == null) {
			if (cname.equals("CLNT")) grup = "CL";
			if (cname.equals("ERKEY")) grup = "ER";
			if (cname.equals("CTYPE")) grup = "CTC";
		}

		String qry = "SELECT SOURCE, SELECTSTMT FROM CPAS_CODE WHERE GRUP='" + grup + "'";
		List<String[]> list = cn.queryMultiCol(qry, 2);
		
		if (list.size()<1) return null;
		String source = list.get(0)[1];
		String selectstmt = list.get(0)[2];
		
		if (source.equals("T")) {
			qry = "SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='" + grup + "' AND VALU='" + value + "'";
			String name = cn.queryOne(qry);
			return name;
		}
		
		if (source.equals("S")) {
			qry = getQryStr(selectstmt, value, q);
			return qry;
		}
		
		return source;
	}

	public String getGrupValue(String grup, String value, Query q) {
		if (value==null || value.equals("")) return null;
		
		String qry = "SELECT SOURCE, SELECTSTMT FROM CPAS_CODE WHERE GRUP='" + grup + "'";
		List<String[]> list = cn.queryMultiCol(qry, 2);
		
		if (list.size()<1) return null;
		String source = list.get(0)[1];
		String selectstmt = list.get(0)[2];
		
		if (source.equals("T")) {
			qry = "SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='" + grup + "' AND VALU='" + value + "'";
			String name = cn.queryOne(qry);
			return name;
		}
		
		if (source.equals("S")) {
			qry = getQryStr(selectstmt, value, q);
			return qry;
		}
		
		return source;
	}
	
	public String getCodeCapt(String tname, String cname) {
		loadTable(tname);
		String key = tname + "." + cname;

		// exception handling
		for (String ex: exceptions) {
			if (key.equals(ex)) {
				return "code/value for GRUP";
			}
		}		
		String capt = htCapt.get(key);
		
		if (capt == null) {
			if (cname.equals("CLNT")) return "Client";
			if (cname.equals("ERKEY")) return "Employer";
		}

		return capt;
	}

	public String getCpasComment(String tname) {
		String qry = "SELECT DESCR FROM CPAS_TABLE WHERE TNAME='" + tname + "'";
		String res = cn.queryOne(qry);
		
		if (res==null) res = "";
		return res;
	}
	
	public String getCodeGrup(String tname, String cname) {
		loadTable(tname);

		String key = tname + "." + cname;
		String grup = htCode.get(key);
		if (grup == null) {
			if (cname.equals("CLNT")) grup = "CL";
			if (cname.equals("ERKEY")) grup = "ER";
		}

		return grup;
	}

	public String getQryStr(String selectstmt, String value, Query q) {
		String qry = selectstmt.replaceAll("\n", " ");

		String dynamic[] = {":CLNT", ":MKEY", ":PLAN", ":ERKEY"};
		// :CLNT, :MKEY
		if (qry.indexOf(":")> 0 ) {
			for (String token : dynamic) {
				int idx = qry.indexOf(token);
				if (idx > 0) {
					String col = token.substring(1);
					String val = q.getValue(col);
					if (val!=null && !val.startsWith("Out of Index"))
						qry = qry.replaceAll(token, "'" + val + "'");
					else
						qry = qry.replaceAll(token, col);
				}
			}
			//System.out.println(qry);
		}
		
		// if qry contains :, discard
		if (qry.indexOf(":")>0) return null;
		
		// remove order by
		int idx = qry.indexOf(" ORDER BY ");
		if (idx > 0) qry = qry.substring(0, idx);
		
		List<String[]> list = cn.queryMultiCol(qry, 2);
		if (list.size()<1) return null;

		for (int i=0; i<list.size();i++) {
			String code = list.get(i)[1];
			if (code != null && code.equals(value))
				return list.get(i)[2];
		}
		return null;
	}
	
	public boolean hasTable(String tname) {
		loadTable(tname);
		return hsTable.contains(tname);
	}
	
	public void loadTable(String tname) {
		if (hsTableLoaded.contains(tname)) return;
		
		String qry = "SELECT TNAME, CNAME, CODE, CAPT FROM CPAS_TABLE_COL WHERE TNAME = '" + tname + "' " +
				" AND (CODE IS NOT NULL OR CAPT IS NOT NULL)";
		
		List<String[]> list = cn.queryMultiCol(qry, 4);
		
		for (String[] row : list) {
			String cname = row[2];
			String code = row[3];
			String capt = row[4];
		
			String key = tname + "." + cname;

			if (code != null && !code.equals("")) htCode.put(key, code);
			if (capt != null && !capt.equals("")) htCapt.put(key, capt);
		}
		hsTableLoaded.add(tname);
	}
}

