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
	boolean isCpas = false;
	int cpasType = 1;

	String[] exceptions = {"MEMBER_STATUS.VALUE", "PLAN_STATUS.VALUE", "EMPLOYER_STATUS.VALUE", "MEMBER_EMPLOYER_STATUS.VALUE", 
			"MEMBER_PLAN_STATUS.VALUE", "PERSON_STATUS.VALUE", "-MEMBER_SERVICE.SRVCODE"};

	public CpasUtil(Connect cn) {
		this.cn = cn;
		
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
			isCpas = true;
			cpasType = 1;
		}
		
		if (!isCpas) {
			qry = "SELECT distinct table_name FROM user_tab_cols where column_name in ('CLNT','ERKEY','CTYPE') UNION  " +
					"SELECT TNAME FROM ADD$TABLE A WHERE EXISTS (SELECT 1 FROM TAB WHERE TNAME=A.TNAME)";
			tbls =  cn.queryMulti(qry);
			for (String tbl: tbls) {
				hsTable.add(tbl);
				isCpas = true;
				cpasType = 2;
			}
		}
		
	}
	
	public String getCodeValue(String tname, String cname, String value, Query q) {
		if (!isCpas) return "";

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
		if (cpasType==2)
			qry = "SELECT TYPE, (SELECT STMTCODE FROM CODE_SELECT WHERE GRUP=A.GRUP) STMT FROM CODE A WHERE GRUP='" + grup + "'";
		List<String[]> list = cn.query(qry);
		
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

		if (cpasType==2) {
			qry = "SELECT NAME FROM CODE_VALUE_NAME WHERE GRUP='" + grup + "' AND VALU='" + value + "'";
			String name = cn.queryOne(qry);
			return name;
		}

		return source;
	}

	public String getGrupValue(String grup, String value, Query q) {
		if (value==null || value.equals("")) return null;
		
		String qry = "SELECT SOURCE, SELECTSTMT FROM CPAS_CODE WHERE GRUP='" + grup + "'";
		if (cpasType==2)
			qry = "SELECT TYPE, (SELECT STMTCODE FROM CODE_SELECT WHERE GRUP=A.GRUP) STMT FROM CODE A WHERE GRUP='" + grup + "'";		
		List<String[]> list = cn.query(qry);
		
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
		if (!isCpas) return "";
		String qry = "SELECT DESCR FROM CPAS_TABLE WHERE TNAME='" + tname + "'";
		if (cpasType==2) qry = "SELECT DESCR FROM ADD$TABLE WHERE TNAME='" + tname + "'";
		
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
		if (selectstmt==null) return null;
		String qry = selectstmt.replaceAll("\n", " ");

		String dynamic[] = {":CLNT", ":MKEY", ":PLAN", ":ERKEY", ":LANG"};
		// :CLNT, :MKEY
		if (qry.indexOf(":")> 0 ) {
			for (String token : dynamic) {
				int idx = qry.indexOf(token);
				if (idx > 0) {
					String col = token.substring(1);
					String val = q.getValue(col);
					if (col.equals("LANG")) val = "E"; // English
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
		
		List<String[]> list = cn.query(qry);
		if (list.size()<1) return null;

		for (int i=0; i<list.size();i++) {
			String code = list.get(i)[1];
			if (code != null && code.equals(value))
				return list.get(i)[2];
		}
		return null;
	}
	
	public boolean hasTable(String tname) {
		if (!isCpas) return false;
		loadTable(tname);
		return hsTable.contains(tname);
	}
	
	public void loadTable(String tname) {
		if (!isCpas) return;
		if (hsTableLoaded.contains(tname)) return;
		
		String qry = "SELECT TNAME, CNAME, CODE, CAPT FROM CPAS_TABLE_COL WHERE TNAME = '" + tname + "' " +
				" AND (CODE IS NOT NULL OR CAPT IS NOT NULL)";
		if (cpasType==2) qry = "SELECT TNAME, CNAME, CODE, CAPT FROM ADD$TABLE_COL WHERE TNAME = '" + tname + "' " +
				" AND (CODE IS NOT NULL OR CAPT IS NOT NULL)";
			
		List<String[]> list = cn.query(qry);
		
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
	
	public String getQryReplaced(String qry) {
		// get the maximum sessionid
		String sid = cn.queryOne("SELECT MAX(SESSIONID) FROM CONNSESSION", false);
		String clnt = cn.queryOne("SELECT tagcvalue FROM CONNSESSION_DATA WHERE SESSIONID = " + sid + " AND tagname='CLNT'");
		String mkey = cn.queryOne("SELECT tagcvalue FROM CONNSESSION_DATA WHERE SESSIONID = " + sid + " AND tagname='MKEY'");
		String plan = cn.queryOne("SELECT tagcvalue FROM CONNSESSION_DATA WHERE SESSIONID = " + sid + " AND tagname='PLAN'");
		String personid = cn.queryOne("SELECT tagnvalue FROM CONNSESSION_DATA WHERE SESSIONID = " + sid + " AND tagname='PERSONID'");
		
		String q=qry;
		q = q.replaceAll(":S.CLNT", "'" + clnt + "'");
		q = q.replaceAll(":S.MKEY", "'" + mkey + "'");
		q = q.replaceAll(":S.PLAN", "'" + plan + "'");
		q = q.replaceAll(":S.PERSONID", "'" + personid + "'");
		
		return q;
	}
	
	public String getColumnCaption(String tname, String cname) {
		String qry = "SELECT CAPT FROM CPAS_TABLE_COL WHERE TNAME='" + tname + "' AND CNAME='" + cname + "'";
		if (cpasType==2) qry = "SELECT CAPT FROM ADD$TABLE_COL WHERE TNAME='" + tname + "' AND CNAME='" + cname + "'";
		String caption = cn.queryOne(qry);
		
		return caption;
	}
	
	public String getColumnType(String tname, String cname) {
		String qry = "SELECT TYPE FROM CPAS_TABLE_COL WHERE TNAME='" + tname + "' AND CNAME='" + cname + "'";
		if (cpasType==2) qry = "SELECT TYPE FROM ADD$TABLE_COL WHERE TNAME='" + tname + "' AND CNAME='" + cname + "'";
		String type = cn.queryOne(qry);
		
		return type;
	}
	
	public String getColumnPict(String tname, String cname) {
		String qry = "SELECT PICT FROM CPAS_TABLE_COL WHERE TNAME='" + tname + "' AND CNAME='" + cname + "'";
		if (cpasType==2) qry = "SELECT PICT FROM ADD$TABLE_COL WHERE TNAME='" + tname + "' AND CNAME='" + cname + "'";
		String pict = cn.queryOne(qry);
		
		return pict;
	}
	
	public boolean isCpas() {
		return this.isCpas;
	}
}

