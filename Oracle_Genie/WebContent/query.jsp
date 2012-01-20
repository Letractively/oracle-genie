<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%

	Connect cn = (Connect) session.getAttribute("CN");
	
	if (cn==null) {
%>	
		Connection lost. <a href="Javascript:window.close()">Close</a>
<%
		return;
	}

	int counter = 0;
	String sql = request.getParameter("sql");
	if (sql==null) sql = "SELECT * FROM TAB";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	if (sql.endsWith("/")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	String norun = request.getParameter("norun");
	
	Connection conn = cn.getConnection();
	System.out.println(request.getRemoteAddr()+": " + sql +";");
	
	int lineLength = Util.countLines(sql);
	if (lineLength <3) lineLength = 3;
	
	QueryCache.getInstance().removeQuery(sql);
	Query q = new Query(cn, sql);
	QueryCache.getInstance().addQuery(sql, q);
	
	// get table name
	String tbl = null;
	//String temp = sql.replaceAll("\n", " ").trim();
	String temp=sql.replaceAll("[\n\r\t]", " ");
	
	int idx = temp.toUpperCase().indexOf(" FROM ");
	if (idx >0) {
		temp = temp.substring(idx + 6);
		idx = temp.indexOf(" ");
		if (idx > 0) temp = temp.substring(0, idx).trim();
		
		tbl = temp.trim();
		
		
		idx = tbl.indexOf(" ");
		if (idx > 0) tbl = tbl.substring(0, idx);
	}
	System.out.println("XXX TBL=" + tbl);
	
	String tname = tbl;
	if (tname.indexOf(".") > 0) tname = tname.substring(tname.indexOf(".")+1);

	// Foreign keys - For FK lookup
	List<ForeignKey> fks = cn.getForeignKeys(tname);
	Hashtable<String, String>  linkTable = new Hashtable<String, String>();
//	Hashtable<String, String>  linkTable2 = new Hashtable<String, String>();
	
	List<String> fkLinkTab = new ArrayList<String>();
	List<String> fkLinkCol = new ArrayList<String>();
	
	for (int i=0; q.hasData() && i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String linkCol = cn.getConstraintCols(rec.constraintName);
		String rTable = cn.getTableNameByPrimaryKey(rec.rConstraintName);
		
		System.out.println("linkCol=" + linkCol);
		System.out.println("rTable=" + rTable);
		
		int colCount = Util.countMatches(linkCol, ",") + 1;
		if (colCount == 1) {
			if (rTable != null) linkTable.put(linkCol, rTable);
			System.out.println("linkTable");
		} else {
			// check if columns are part of result set
			int matchCount = 0;
			String[] t = linkCol.split("\\,");
			for (int j=0;j<t.length;j++) {
				String colName = t[j].trim();
				for  (int k = 0; k< q.getColumnCount(); k++){
					String col = q.getColumnLabel(k);
					if (col.equalsIgnoreCase(colName)) {
						matchCount++;
						continue;
					}
				}
			}
			if (rTable != null && matchCount==colCount) {
				fkLinkTab.add(rTable);
				fkLinkCol.add(linkCol);
			}
			System.out.println("linkTable2");
		}
	}
	
	// Primary Key for PK Link
	String pkName = cn.getPrimaryKeyName(tname);
	boolean pkLink = false;
	int pkColIndex = -1;
	
	List<String> pkColList = null;
	if (pkName != null) {
		pkColList = cn.getConstraintColList(pkName);
		
		// check if PK columns are in the result set
		int matchCount = 0;
		for (int j=0;j<pkColList.size();j++) {
			String colName = pkColList.get(j);
			for  (int i = 0; i< q.getColumnCount(); i++){
				String col = q.getColumnLabel(i);
				if (col.equalsIgnoreCase(colName)) {
					matchCount++;
					continue;
				}
			}
		}

		// there should be other tables that has FK to this
		List<String> refTabs = cn.getReferencedTables(tname);
		if (matchCount == pkColList.size() && refTabs.size()>0) {
			pkLink = true;
		}
	}
%>
<html>
<head> 
	<title>Query result - Genie</title>
    <link rel='stylesheet' type='text/css' href='css/style.css'>
    <link rel="stylesheet" href="css/colorbox.css" />
    <script src="script/jquery.js" type="text/javascript"></script>
    <script src="script/jquery.colorbox-min.js"></script>
    <script src="script/query-methods.js" type="text/javascript"></script>
    
    <script type="text/javascript">
	$(document).ready(function() {
		showTable('<%=tbl%>');
//		var sql = $("#sql").val();
//		loadDataDiv(sql);
		setDoMode('copy');
		$(".inspect").colorbox({transition:"none", width:"800", height:"600"});
	});	    
    </script>
</head> 

<body>
<table>
<td><br><img src="image/icon_query.png"/></td>
<td><%= cn.getUrlString() %></td>
</table>

Table
<select size=1 id="selectTable" name=""selectTable"" onChange="showTable(this.options[this.selectedIndex].value);"">
	<option></option>
<% for (int i=0; i<cn.getTables().size();i++) { %>
	<option value="<%=cn.getTable(i)%>"><%=cn.getTable(i)%></option>
<% } %>
</select>

<input id="input-table" size=30 value="" onChange="showTable(this.value)"/>
<br/>

<div id="table-detail"></div>

<a href="Javascript:copyPaste('SELECT');">SELECT</a>&nbsp;
<a href="Javascript:copyPaste('COUNT(*)');">COUNT(*)</a>&nbsp;
<a href="Javascript:copyPaste('FROM');">FROM</a>&nbsp;
<a href="Javascript:copyPaste('WHERE');">WHERE</a>&nbsp;
<a href="Javascript:copyPaste('=');">=</a>&nbsp;
<a href="Javascript:copyPaste('LIKE');">LIKE</a>&nbsp;
<a href="Javascript:copyPaste('IS');">IS</a>&nbsp;
<a href="Javascript:copyPaste('NOT');">NOT</a>&nbsp;
<a href="Javascript:copyPaste('NULL');">NULL</a>&nbsp;
<a href="Javascript:copyPaste('AND');">AND</a>&nbsp;
<a href="Javascript:copyPaste('OR');">OR</a>&nbsp;
<a href="Javascript:copyPaste('IN');">IN</a>&nbsp;
<a href="Javascript:copyPaste('()');">()</a>&nbsp;
<a href="Javascript:copyPaste('EXISTS');">EXISTS</a>&nbsp;
<a href="Javascript:copyPaste('GROUP BY');">GROUP-BY</a>&nbsp;
<a href="Javascript:copyPaste('HAVING');">HAVING</a>&nbsp;
<a href="Javascript:copyPaste('ORDER BY');">ORDER-BY</a>&nbsp;
<a href="Javascript:copyPaste('DESC');">DESC</a>&nbsp;

<form name="form1" id="form1" method="post" action="query.jsp">
<input type="hidden" id="sortColumn" name="sortColumn" value="">
<input type="hidden" id="sortDirection" name="sortDirection" value="0">
<input type="hidden" id="hideColumn" name="hideColumn" value="">
<input type="hidden" id="filterColumn" name="filterColumn" value="">
<input type="hidden" id="filterValue" name="filterValue" value="">
<input type="hidden" id="pageNo" name="pageNo" value="1">
<input type="hidden" id="rowsPerPage" name="rowsPerPage" value="20">
<textarea id="sql" name="sql" cols=100 rows=<%= lineLength %>><%= sql %></textarea><br/>
<input type="submit" value="Submit"/>
&nbsp;
<input type="button" value="Download" onClick="Javascript:download()"/>
</form>

<%= q.getMessage() %>

<%
	if (norun!=null || !q.hasMetaData()) {
%>
<br/><br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

</body>
</html>
<%
		return;		
	}
%>

<a id="modeCopy" href="Javascript:setDoMode('copy')">Copy&amp;Paste</a>&nbsp;
<a id="modeHide" href="Javascript:setDoMode('hide')">Hide</a>&nbsp;
<span id="showAllCol" style="display: none;"><a id="modeHide" href="Javascript:showAllColumn()">Show All Column</a>&nbsp;</span>
<a id="modeSort" href="Javascript:setDoMode('sort')">Sort</a>&nbsp;
<a id="modeFilter" href="Javascript:setDoMode('filter')">Filter</a>&nbsp;
<span id="filter-div"></span>
<div id="data-div">
<jsp:include page="ajax/qry.jsp">
	<jsp:param value="<%= sql%>" name="sql"/>
	<jsp:param value="1" name="pageNo"/>
	<jsp:param value="" name="sortColumn"/>
	<jsp:param value="0" name="sortDirection"/>
	<jsp:param value="" name="hideColumn"/>
	<jsp:param value="" name="filterColumn"/>
	<jsp:param value="" name="filterValue"/>
	<jsp:param value="" name="hideColumn"/>
</jsp:include>
</div>

<br/><br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

</body>
</html>