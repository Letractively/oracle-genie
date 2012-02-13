package spencer.genie;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

public class ContentSearch {

	private Connect cn;
	
	private String searchKeyword;
	private String matchType;
	private String caseType;

	private static ContentSearch instance = null;
	private static boolean running = false;
	private static String progressStr;
	private int totalTableCount;
	private int currentTaleIndex;
	
	private ContentSearch() {
	}
	
	public static ContentSearch getInstance() {
		if (instance==null) {
			instance = new ContentSearch();
		}
		return instance; 
	}
	
	public List<String> search(Connect cn, String searchKeyword, String inclTable, String exclTable, String owner, String matchType, String caseType) {

		this.cn = cn;
		
		this.searchKeyword = searchKeyword;
		this.matchType = matchType;
		this.caseType = caseType;

		this.progressStr = "";

		if (caseType.equals("ignore")) {
			this.searchKeyword = searchKeyword.toUpperCase();
		}
		
		running = true;
		List<String> tables = new ArrayList<String>();
		
		String qry = "SELECT TABLE_NAME FROM USER_TABLES WHERE 1=1 ";
		
		if (inclTable !=null && inclTable.length()>0) {
			qry += " AND ( ";
			StringTokenizer st = new StringTokenizer(inclTable, " ");
			int i = 0;
			while (st.hasMoreTokens()) {
				i ++;
				String token = st.nextToken();
				if (i>1) qry += " OR ";
				qry += "TABLE_NAME LIKE '%" + token.toUpperCase() + "%' ";
			}
			qry += " )";
		}
		if (exclTable !=null && exclTable.length()>0) {
			StringTokenizer st = new StringTokenizer(exclTable, " ");
			while (st.hasMoreTokens()) {
				String token = st.nextToken();
				qry += " AND TABLE_NAME NOT LIKE '%" + token.toUpperCase() + "%' ";
			}
		}
		
		String qry2 = "SELECT SYNONYM_NAME FROM USER_SYNONYMS A WHERE EXISTS (select 1 from ALL_TABLES WHERE OWNER=A.TABLE_OWNER AND TABLE_NAME=A.TABLE_NAME) ";

		if (inclTable !=null && inclTable.length()>0) {
			qry2 += " AND ( ";
			StringTokenizer st = new StringTokenizer(inclTable, " ");
			int i = 0;
			while (st.hasMoreTokens()) {
				i ++;
				String token = st.nextToken();
				if (i>1) qry2 += " OR ";
				qry2 += "SYNONYM_NAME LIKE '%" + token.toUpperCase() + "%' ";
			}
			qry2 += " )";
		}
		if (exclTable !=null && exclTable.length()>0) {
			StringTokenizer st = new StringTokenizer(exclTable, " ");
			while (st.hasMoreTokens()) {
				String token = st.nextToken();
				qry2 += " AND SYNONYM_NAME NOT LIKE '%" + token.toUpperCase() + "%' ";
			}
		}
		
		if (owner.equals("both")) qry += " UNION ALL " + qry2;
		else if (owner.equals("other")) qry = qry2;

		if (owner.equals("dict")) {
			qry = "SELECT TABLE_NAME FROM DICTIONARY WHERE TABLE_NAME LIKE 'USER_%' ";

			if (inclTable !=null && inclTable.length()>0) {
				qry += " AND ( ";
				StringTokenizer st = new StringTokenizer(inclTable, " ");
				int i = 0;
				while (st.hasMoreTokens()) {
					i ++;
					String token = st.nextToken();
					if (i>1) qry += " OR ";
					qry += "TABLE_NAME LIKE '%" + token.toUpperCase() + "%' ";
				}
				qry += " )";
			}
			if (exclTable !=null && exclTable.length()>0) {
				StringTokenizer st = new StringTokenizer(exclTable, " ");
				while (st.hasMoreTokens()) {
					String token = st.nextToken();
					qry += " AND TABLE_NAME NOT LIKE '%" + token.toUpperCase() + "%' ";
				}
			}
		}

		qry += "ORDER BY 1";
		System.out.println("qry=" + qry);

		List<String> tlist = cn.queryMulti(qry);
		totalTableCount = tlist.size();
		currentTaleIndex = 0;
		for (String tname : tlist) {
			currentTaleIndex ++;
			progressStr = tname + "<br/>" + progressStr;
			String foundColumn = searchTable(tname);
			if (foundColumn!=null) {
				//System.out.println(tname + "." + foundColumn);
				tables.add(tname + "." + foundColumn.toLowerCase());
				progressStr = "&nbsp;&nbsp;&nbsp;<b>" + tname + "." + foundColumn.toLowerCase() + "</b><br/>" + progressStr;
			}
			
			if (!running) break; 
		}

		running = false;
		return tables;
	}
	
	public String searchTable(String tname) {
		String foundColumn = null;
		
		String qry = "SELECT * FROM " + tname;
		//System.out.println("qry=" + qry);
		OldQuery q = new OldQuery(cn, qry, null);
		
		ResultSet rs = q.getResultSet();
		try {
			int cnt=0;
			while (rs !=null && rs.next() && cnt <= 5000) {
				if (!running) break; 
				cnt++;
				for  (int i = 1; i<= rs.getMetaData().getColumnCount(); i++){
					String val = q.getValue(i);
					if (val==null || val.equals("")) continue;
					if (caseType.equals("ignore")) val = val.toUpperCase();
					
					//System.out.println(val + "," + searchKeyword);
					if (matchType.equals("exact")) {

						if (val.equals(searchKeyword)) {
							foundColumn = q.getColumnLabel(i);
							break;
						}
					} else {
						if (val.contains(searchKeyword)) {
							foundColumn = q.getColumnLabel(i);
							break;
						}
					}
				}
				
				if (foundColumn != null) break;
			}
			q.close();
			
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
		
		return foundColumn;
	}
	
	public void cancel() {
		running = false; 
	}
	
	public String getProgress() {
		int percent = 0;
		
		if (totalTableCount >0)
			percent = (100 * currentTaleIndex) / totalTableCount;
		
		String status = "Processing " + currentTaleIndex + " of " + totalTableCount +
				" ( " + percent + "% )<br/><br/>";

		if (!running)
			status = "Finished " + currentTaleIndex + " of " + totalTableCount +
				" ( " + percent + "% )<br/><br/>";
		
		return status + progressStr;
		
	}
}
