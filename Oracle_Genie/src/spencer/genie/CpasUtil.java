package spencer.genie;

import java.sql.Connection;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.List;

public class CpasUtil {
	private Connect cn = null;
	Hashtable<String, String> htCode = new Hashtable<String, String>();
	Hashtable<String, String> htCapt = new Hashtable<String, String>();
	HashSet<String> hsTable = new HashSet<String>();
	HashSet<String> hsTableLoaded = new HashSet<String>();
	boolean isCpas = false;
	int cpasType = 1;

	String[] exceptions = { 
			"MEMBER_STATUS.VALUE", 
			"PLAN_STATUS.VALUE",
			"EMPLOYER_STATUS.VALUE", 
			"MEMBER_EMPLOYER_STATUS.VALUE",
			"MEMBER_PLAN_STATUS.VALUE", 
			"PERSON_STATUS.VALUE", 
			"CALC_STATUS.VALU",
			"-MEMBER_SERVICE.SRVCODE" 
	};

	String calcStage[][] = {
			{"AA", "Request"},
			{"SA", "Saving"},
			{"ZZ", "Processed"},
			{"CC", "Cancelled"},
			{"RR", "Recalculated"},
			{"FF", "Finalizing"}
	};
	
	public static String logicalLink2[][] = {
			{"MKEY", "CLNT", "MEMBER"},
			{"ERKEY", "CLNT", "EMPLOYER"},
			{"PLAN", "CLNT", "SV_PLAN"},
			{"PAYMENTID", "PENID", "PENSIONER_PAYMENT"}
	};
			
	public static String logicalLink[][] = {
			{"PROCESSID", "BATCH"},
			{"PENID", "PENSIONER"},
			{"PERSONID", "PERSON"},
			{"ACCOUNTID", "ACCOUNT"},
			{"CALCID", "CALC"},
			{"ERRORID", "ERRORCAT"},
			{"REQUESTID", "REQUEST"},
			{"BATCHKEY", "BATCHCAT"},
			{"REPORTID", "REPORTCAT"},
			{"REQUESTKEY", "REQUESTCAT"},
			{"FUND", "FUND"},
			{"CTYPE", "CPAS_CALCTYPE"},
			{"SESSIONID", "CPASSESSION"},
			{"CHEQUEID", "CHEQUE"},
			{"TAXID", "TAX"},
			{"LUMPSUMID", "LUMPSUM"},
			{"GLID", "GL_ACCOUNT"},
			{"ORGID", "ORGANIZATION"},
			{"COUNTRY", "COUNTRY"},
			{"CURRENCY", "CURRENCY"},
			{"JMLFILEID", "CPAS_DEFLOB"},
			{"TAXTYPE", "TAXTYPE"}
	};
	
	public CpasUtil(Connect cn) {
		this.cn = cn;

		for (String ex : exceptions) {
			int idx = ex.indexOf(".");
			String tname = ex.substring(0, idx);
			String cname = ex.substring(idx + 1);

			htCode.put(tname + "." + cname, "");
			htCapt.put(tname + "." + cname, "");
			hsTable.add(tname);
		}

		String qry = "SELECT distinct table_name FROM user_tab_cols where column_name in ('CLNT','ERKEY','CTYPE') UNION  "
				+ "SELECT TNAME FROM CPAS_TABLE A WHERE EXISTS (SELECT 1 FROM TAB WHERE TNAME=A.TNAME)";
		List<String> tbls = cn.queryMulti(qry);
		for (String tbl : tbls) {
			hsTable.add(tbl);
			isCpas = true;
			cpasType = 1;
		}

		if (!isCpas) {
			qry = "SELECT distinct table_name FROM user_tab_cols where column_name in ('CLNT','ERKEY','CTYPE') UNION  "
					+ "SELECT TNAME FROM ADD$TABLE A WHERE EXISTS (SELECT 1 FROM TAB WHERE TNAME=A.TNAME)";
			tbls = cn.queryMulti(qry);
			for (String tbl : tbls) {
				hsTable.add(tbl);
				isCpas = true;
				cpasType = 2;
			}
		}

		System.out.println("cpasType="+cpasType);
	}
/*
	public String getCodeValueCustom(String tname, String cname, String value, Query q) {
		// exception handling
		String temp = tname + "." + cname;

		// handle exception
		if (temp.equals("CALC.STAGE")) {
			for (int i=0; i<calcStage.length;i++) {
				if (value.equals(calcStage[i][0])) return calcStage[i][1];
			}
			return null;
		} else if (temp.equals("BATCH_QUEUE.TASKKEY")) {
			String qry = "SELECT TASKNAME FROM BATCHCAT_TASK WHERE BATCHKEY='" + q.getValue("BATCHKEY") + "' AND TASKKEY = '" + value + "'";
			
			return cn.queryOne(qry);
		}
		
		return null;
	}
*/
	
	public String getCodeValue(String tname, String cname, String value, Query q) {
		if (!isCpas)
			return "";

		loadTable(tname);
		if (value == null || value.equals(""))
			return null;

		// exception handling
		String temp = tname + "." + cname;
		for (String ex : exceptions) {
			if (temp.equals(ex)) {
				String grup = q.getValue("GRUP");

				return getGrupValue(grup, value, q);
			}
		}

		// handle exception
		if (temp.equals("CALC.STAGE")) {
			for (int i=0; i<calcStage.length;i++) {
				if (value.equals(calcStage[i][0])) return calcStage[i][1];
			}
			return null;
		} else if (temp.equals("BATCH_QUEUE.TASKKEY")) {
			String qry = "SELECT TASKNAME FROM BATCHCAT_TASK WHERE BATCHKEY='" + q.getValue("BATCHKEY") + "' AND TASKKEY = '" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.equals("CALC_DATE.RDATE") /* && value.startsWith("1800")*/ ) {
			String qry = "SELECT NAME FROM CPAS_DATE WHERE RDATE= TO_DATE('" + value + "','YYYY-MM-DD')";
			return cn.queryOne(qry);
		} else if (temp.equals("TASK.TTYPE")) {
			String qry = "SELECT CAPT FROM CPAS_TASKTYPE WHERE TTYPE='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".VKEY") && !tname.equals("CPAS_VALIDATION")) {
			String qry = "SELECT CAPTION FROM CPAS_VALIDATION WHERE VKEY='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".BATCHKEY") && !tname.equals("BATCHCAT")) {
			String qry = "SELECT BATCHNAME FROM BATCHCAT WHERE BATCHKEY='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".GLID") && !tname.equals("GL_ACCOUNT")) {
			String qry = "SELECT DESCR FROM GL_ACCOUNT WHERE GLID='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".ORGID") && !tname.equals("ORGANIZATION")) {
			String qry = "SELECT SNAME FROM ORGANIZATION WHERE ORGID='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".COUNTRY") && !tname.equals("COUNTRY")) {
			String qry = "SELECT NAME FROM COUNTRY WHERE COUNTRY='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".CURRENCY") && !tname.equals("CURRENCY")) {
			String qry = "SELECT LNAME FROM CURRENCY WHERE CURRENCY='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".TAXTYPE") && !tname.equals("TAXTYPE")) {
			String qry = "SELECT NAME FROM TAXTYPE WHERE TAXTYPE='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".FUND") && !tname.equals("FUND")) {
			String qry = "SELECT SNAME FROM FUND WHERE FUND='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".PERSONID") && !tname.equals("PERSON")) {
			String qry = "SELECT UNAME FROM PERSON WHERE PERSONID='" + value + "'";
			return cn.queryOne(qry);
		}
		
		String key = (tname + "." + cname).toUpperCase();
		if (key.equals("MEMBER_STATUS.GRUP") || key.equals("CALC_STATUS.GRUP")) {
			String qry = "SELECT CAPTION FROM CPAS_CODE WHERE grup = '" + value + "'";
			if (cpasType==2) 
				qry = "SELECT CAPT FROM CODE_CAPTION WHERE grup = '" + value + "'";
//			System.out.println("**** " + qry);
			
			return cn.queryOne(qry);
		}
		
		String grup = htCode.get(key);
		if (grup == null) {
			if (cname.equals("CLNT"))
				grup = "CL";
			if (cname.equals("ERKEY"))
				grup = "ER";
			if (cname.equals("CTYPE"))
				grup = "CTC";
		}

		String qry = "SELECT SOURCE, SELECTSTMT FROM CPAS_CODE WHERE GRUP='"
				+ grup + "'";
		if (cpasType == 2)
			qry = "SELECT TYPE, (SELECT STMTCODE FROM CODE_SELECT WHERE GRUP=A.GRUP) STMT FROM CODE A WHERE GRUP='"
					+ grup + "'";
		List<String[]> list = cn.query(qry);
//System.out.println(qry);

		if (list.size() < 1) {
			return null;
		}
		
		String source = list.get(0)[1];
		String selectstmt = list.get(0)[2];

		if (source.equals("P")) {  // procedure call
			if (grup.equals("FN")) {
				grup = "FND";
			
				qry = "SELECT SOURCE, SELECTSTMT FROM CPAS_CODE WHERE GRUP='" + grup + "'";
				if (cpasType == 2)
					qry = "SELECT TYPE, (SELECT STMTCODE FROM CODE_SELECT WHERE GRUP=A.GRUP) STMT FROM CODE A WHERE GRUP='"
						+ grup + "'";
				list = cn.query(qry);

				if (list.size() < 1) return null;
				source = list.get(0)[1];
				selectstmt = list.get(0)[2];
			}
			if (cpasType ==2) {
				qry = "SELECT SOURCE, SELECTSTMT FROM CPAS_CODE WHERE GRUP='" + grup + "'";
				if (cpasType == 2)
					qry = "SELECT TYPE, (SELECT STMTCODE FROM CODE_SELECT WHERE GRUP=A.GRUP) STMT FROM CODE A WHERE GRUP='"
						+ grup + "'";
				list = cn.query(qry);

				if (list.size() < 1) return null;
				source = list.get(0)[1];
				selectstmt = list.get(0)[2];
			}
		}
		
//System.out.println("source=" + source);
		if (source.equals("T")) {
			qry = "SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='" + grup
					+ "' AND VALU='" + value + "'";
			String name = cn.queryOne(qry);
			return name;
		}

		if (source.equals("S") || source.equals("3") || source.equals("A")) {
			qry = getQryStr(selectstmt, value, q);
			return qry;
		}

		if (cpasType == 2) {
			if (source.equals("C") || source.equals("P")) {
				qry = getQryStr(selectstmt, value, q);
				return qry;
			}
			
			qry = "SELECT NAME FROM CODE_VALUE_NAME WHERE GRUP='" + grup
					+ "' AND VALU='" + value + "'";
			String name = cn.queryOne(qry);
			return name;
		}

		return source;
	}

	public String getGrupValue(String grup, String value, Query q) {
		if (value == null || value.equals(""))
			return null;

		String qry = "SELECT SOURCE, SELECTSTMT FROM CPAS_CODE WHERE GRUP='"
				+ grup + "'";
		if (cpasType == 2)
			qry = "SELECT TYPE, (SELECT STMTCODE FROM CODE_SELECT WHERE GRUP=A.GRUP) STMT FROM CODE A WHERE GRUP='"
					+ grup + "'";
		List<String[]> list = cn.query(qry);

		if (list.size() < 1)
			return null;
		String source = list.get(0)[1];
		String selectstmt = list.get(0)[2];

		if (source.equals("T")) {
			qry = "SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='" + grup
					+ "' AND VALU='" + value + "'";
			String name = cn.queryOne(qry);
			return name;
		}

		if (source.equals("S")) {
			qry = getQryStr(selectstmt, value, q);
			return qry;
		}

		if (source.equals("U")) {
			selectstmt = "SELECT NAME FROM CODE_VALUE_NAME WHERE GRUP='" + grup +"' AND VALU ='" + value + "'";
			qry = cn.queryOne(selectstmt);
			return qry;
		}

		return source;
	}

	public String getCodeCapt(String tname, String cname) {
		loadTable(tname);
		String key = tname + "." + cname;

		// exception handling
		for (String ex : exceptions) {
			if (key.equals(ex)) {
				return "code/value for GRUP";
			}
		}
		String capt = htCapt.get(key);

		if (capt == null) {
			if (cname.equals("CLNT"))
				return "Client";
			if (cname.equals("ERKEY"))
				return "Employer";
		}

		return capt;
	}

	public String getCpasComment(String tname) {
		if (!isCpas)
			return "";
		String qry = "SELECT DESCR FROM CPAS_TABLE WHERE TNAME='" + tname + "'";
		if (cpasType == 2)
			qry = "SELECT DESCR FROM ADD$TABLE WHERE TNAME='" + tname + "'";

		String res = cn.queryOne(qry);

		if (res == null)
			res = "";
		return res;
	}

	public String getCodeGrup(String tname, String cname) {
		loadTable(tname);

		String key = tname + "." + cname;
		String grup = htCode.get(key);
		if (grup == null) {
			if (cname.equals("CLNT"))
				grup = "CL";
			if (cname.equals("ERKEY"))
				grup = "ER";
		}

		return grup;
	}

	public String getQryStr(String selectstmt, String value, Query q) {
		if (selectstmt == null)
			return null;
		String qry = selectstmt.replaceAll("\n", " ");

		String dynamic[] = { ":CLNT", ":MKEY", ":PLAN", ":ERKEY", ":LANG", ":GRUP" };
		// :CLNT, :MKEY
		if (qry.indexOf(":") > 0) {
			for (String token : dynamic) {
				int idx = qry.indexOf(token);
				if (idx > 0) {
					String col = token.substring(1);
					String val = q.getValue(col);
					if (col.equals("LANG"))
						val = "E"; // English
					if (val != null && !val.startsWith("Out of Index")) {
						if (val.equals("")) {
							qry = qry.replaceAll(token, token.substring(1));
						} else {
							qry = qry.replaceAll(token, "'" + val + "'");
						}
					} else
						qry = qry.replaceAll(token, col);
				}
			}
			// System.out.println(qry);
		}

		// if qry contains :, discard
		if (qry.indexOf(":") > 0) {
			qry = qry.replaceAll(":", "");
			//return qry;
			//return null;
		}
//System.out.println(qry);
		// remove order by
		int idx = qry.indexOf(" ORDER BY ");
		if (idx > 0)
			qry = qry.substring(0, idx);

		List<String[]> list = cn.query(qry);
		if (list.size() < 1)
			return null;

		for (int i = 0; i < list.size(); i++) {
			String code = list.get(i)[1];
			if (code != null && code.equals(value))
				return list.get(i)[2];
		}
		return null;
	}

	public boolean hasTable(String tname) {
		if (!isCpas)
			return false;
		loadTable(tname);
		return hsTable.contains(tname);
	}

	public void loadTable(String tname) {
		if (!isCpas)
			return;
		if (hsTableLoaded.contains(tname))
			return;

		String qry = "SELECT TNAME, CNAME, CODE, CAPT FROM CPAS_TABLE_COL WHERE TNAME = '"
				+ tname + "' " + " AND (CODE IS NOT NULL OR CAPT IS NOT NULL)";
		if (cpasType == 2)
			qry = "SELECT TNAME, CNAME, CODE, CAPT FROM ADD$TABLE_COL WHERE TNAME = '"
					+ tname
					+ "' "
					+ " AND (CODE IS NOT NULL OR CAPT IS NOT NULL)";

		List<String[]> list = cn.query(qry);

		for (String[] row : list) {
			String cname = row[2];
			String code = row[3];
			String capt = row[4];

			String key = tname + "." + cname;

			if (code != null && !code.equals(""))
				htCode.put(key, code);
			if (capt != null && !capt.equals(""))
				htCapt.put(key, capt);
		}
		hsTableLoaded.add(tname);
	}

	public String getQryReplaced(String qry) {
		// get the maximum sessionid
		String sid = cn.queryOne("SELECT MAX(SESSIONID) FROM CONNSESSION",
				false);
		String clnt = cn
				.queryOne("SELECT tagcvalue FROM CONNSESSION_DATA WHERE SESSIONID = "
						+ sid + " AND tagname='CLNT'");
		String mkey = cn
				.queryOne("SELECT tagcvalue FROM CONNSESSION_DATA WHERE SESSIONID = "
						+ sid + " AND tagname='MKEY'");
		String plan = cn
				.queryOne("SELECT tagcvalue FROM CONNSESSION_DATA WHERE SESSIONID = "
						+ sid + " AND tagname='PLAN'");
		String personid = cn
				.queryOne("SELECT tagnvalue FROM CONNSESSION_DATA WHERE SESSIONID = "
						+ sid + " AND tagname='PERSONID'");

		String q = qry;
		q = q.replaceAll(":S.CLNT", "'" + clnt + "'");
		q = q.replaceAll(":S.MKEY", "'" + mkey + "'");
		q = q.replaceAll(":S.PLAN", "'" + plan + "'");
		q = q.replaceAll(":S.PERSONID", "'" + personid + "'");

		return q;
	}

	public String getColumnCaption(String tname, String cname) {
		String qry = "SELECT CAPT FROM CPAS_TABLE_COL WHERE TNAME='" + tname
				+ "' AND CNAME='" + cname + "'";
		if (cpasType == 2)
			qry = "SELECT CAPT FROM ADD$TABLE_COL WHERE TNAME='" + tname
					+ "' AND CNAME='" + cname + "'";
		String caption = cn.queryOne(qry);

		return caption;
	}

	public String getColumnType(String tname, String cname) {
		String qry = "SELECT TYPE FROM CPAS_TABLE_COL WHERE TNAME='" + tname
				+ "' AND CNAME='" + cname + "'";
		if (cpasType == 2)
			qry = "SELECT TYPE FROM ADD$TABLE_COL WHERE TNAME='" + tname
					+ "' AND CNAME='" + cname + "'";
		String type = cn.queryOne(qry);

		return type;
	}

	public String getColumnPict(String tname, String cname) {
		String qry = "SELECT PICT FROM CPAS_TABLE_COL WHERE TNAME='" + tname
				+ "' AND CNAME='" + cname + "'";
		if (cpasType == 2)
			qry = "SELECT PICT FROM ADD$TABLE_COL WHERE TNAME='" + tname
					+ "' AND CNAME='" + cname + "'";
		String pict = cn.queryOne(qry);

		return pict;
	}

	public boolean isCpas() {
		return this.isCpas;
	}
	
	public String getCpasCodeTable() {
		if (cpasType==1) return "CPAS_CODE";
		if (cpasType==2) return "CODE";
		
		return "CPAS_CODE";
	}
/*
	public static String parseNavigatorQuery(String cQuery) {

		String cLeftQry = null;
		String cRightQry = null;

		char cChr;
		char cParamType = 0; // A, P, S
		boolean lIsSpecial = false; // indicates if a parameter is :Something
									// type

		String cParam = null;
		Object oParamValue = null;

		if (cQuery == null || cQuery.indexOf(":") == -1)
			// if it's not a query -> return cQuery as is
			return cQuery;

		// search :X.parameter in the query (X could be any letter from the
		// predefined types)
		int nTokenPos = 0;
		int nFrom = 0;

		nTokenPos = cQuery.indexOf(":");
		while (nTokenPos != -1) {

			// check if there is a parameter
			if (nTokenPos != -1) {

				if (cQuery.charAt(nTokenPos + 2) == '.') {

					// parameter has the :X.something form
					cParamType = cQuery.charAt(nTokenPos + 1);

					nFrom = nTokenPos + 3;
					lIsSpecial = false;
				} else if (!Character.isLetter(cQuery.charAt(nTokenPos + 1))) {
					// this is not a parameter at all the character following
					// the ':' a whitespace or coma or dot etc.
					// so we just skip this one
					cParamType = 0;
					nFrom = nTokenPos + 1;
					lIsSpecial = true;
				} else {
					// parameter has the :Something form, so it must be either
					// an output
					// parameter or a parameter that can be taked from UserData,
					// thus
					// param type is S
					cParamType = 'S';

					nFrom = nTokenPos + 1;
					lIsSpecial = true;
				}

				// look for a character to find the end of the parameter
				boolean lOut = false;
				while (!lOut && nFrom < cQuery.length()) {
					cChr = cQuery.charAt(nFrom);
					if (cChr == '\n' || cChr == ' ' || cChr == ','
							|| cChr == '.' || cChr == '=' || cChr == ')'
							|| cChr == '\'' || cChr == '/' || cChr == 10
							|| cChr == 13)
						lOut = true;
					else
						nFrom++;
				}

				// take the right and left part of the query
				cRightQry = "";
				cLeftQry = cQuery.substring(0, nTokenPos);

				if (nFrom < cQuery.length()) {

					// take parameter
					if (lIsSpecial)
						cParam = cQuery.substring(nTokenPos + 1, nFrom);
					else
						cParam = cQuery.substring(nTokenPos + 3, nFrom);

					cRightQry = cQuery.substring(nFrom);
				} else {
					if (lIsSpecial)
						cParam = cQuery.substring(nTokenPos + 1);
					else
						cParam = cQuery.substring(nTokenPos + 3);
				}

				// take the param value from oData
				if (cParam.length() > 0) {
					// if the length of the parameter is 0
					// the ':' used in a query did not signify the begining
					// of the parameter to be replaced
					try {

						// check if there is a variable assignment ( := ) like
						// for an output
						if (cQuery.substring(nTokenPos, nTokenPos + 2).equals(
								":=")) {
							cRightQry = cQuery.substring(nTokenPos + 2);
							cQuery = cLeftQry + ":=" + cRightQry;
						} else if (cParam.equalsIgnoreCase("EXC")
								|| cParam.equalsIgnoreCase("cNew")) {

							// is one of the predefined output params, add
							// question mark to the query
							cQuery = cLeftQry + "?" + cRightQry;
						} else {
							// regular variable
							oParamValue = getParameterValue(cParamType, cParam);
							// modify the query adding the proper value
							cQuery = cLeftQry + oParamValue + cRightQry;
						}
					} catch (Exception epbe) {

						// there is no data in the parent browser, just make the
						// query retrieve nothing
						// cQuery = cLeftQry + "NULL AND " +
						// getLastQueryField(cLeftQry) + " <> NULL " +
						// cRightQry;
						cQuery = cLeftQry + "NULL " + cRightQry;
					}
				}
			} // if nTokenPos != -1

			nTokenPos = cQuery.indexOf(":",
					cQuery.length() - cRightQry.length());

		} // while

		return cQuery;

	} // parseNavigatorQuery


	private static Object getParameterValue(char cParamType, String cParamName) {

		Object oReturnValue = null;

		String cMsg = null;

		switch (Character.toUpperCase(cParamType)) {

		case 'A':
			break;
		case 'P':
			break;
		case 'S':
			try {
				oReturnValue = oUserData.getParameterValue(cParamName,
						oTreeView);
			} catch (UserDataException ude) {
				throw new NavigatorToolException(ude.getMessage());
			}
			if (oReturnValue == null) {
				oReturnValue = "NULL";
			}

			break;
		default:
			cMsg = "Unrecognized variable type :" + cParamType + "."
					+ cParamName;
			Logger.log(cMsg, "NavigatorTools.getParameterValue()", null,
					oUserData.getUser());
			throw new NavigatorToolException(cMsg);
		}

		// enclose the value into single quotes only for upper case types
		// eg - use single quotes for :A, but no quotes for :a
		// if the value is a String, but is not :S.OWNER (common schema),
		// :S.CAPTION or a NULL, the
		// value will be enclosed by single quotes (to form a valid query)
		if ((oReturnValue instanceof String)
				&& Character.isUpperCase(cParamType)
				&& !(cParamType == 'S' && (cParamName.equals("OWNER")
						|| (cParamName.equals("CAPTION")) || (oReturnValue
							.equals("NULL")))))
			oReturnValue = "'" + oReturnValue + "'";

		// if it's a Date, it will be converted appropriately
		oReturnValue = convertDateFormat(oReturnValue);

		return oReturnValue;

	} // getParameterValue
*/
}
