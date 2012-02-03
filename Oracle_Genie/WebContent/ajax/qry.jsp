<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>


<%
	int counter = 0;
	String sql = request.getParameter("sql");
	String sortColumn = request.getParameter("sortColumn");
	String sortDirection = request.getParameter("sortDirection");
	String pageNo = request.getParameter("pageNo");
	String dataLink = request.getParameter("dataLink");

	boolean dLink = dataLink != null && dataLink.equals("1");  
	
	int pgNo = 1;
	if (pageNo != null) pgNo = Integer.parseInt(pageNo);

	String rowsPerPage = request.getParameter("rowsPerPage");
	int linesPerPage = 20;
	if (rowsPerPage != null) linesPerPage = Integer.parseInt(rowsPerPage);
	
	String filterColumn = request.getParameter("filterColumn");
	String filterValue = request.getParameter("filterValue");
	String searchValue = request.getParameter("searchValue");
	if (searchValue==null) searchValue = "";

	String hideColumn = request.getParameter("hideColumn");
	if (hideColumn == null) hideColumn = "";
	
	String hiddenColumns[] = hideColumn.split("\\,");
	
//System.out.println("filterColumn=" + filterColumn);
//System.out.println("filterValue=" + filterValue);
//System.out.println("pageNo=" + pgNo);
//System.out.println("rowsPerPage=" + rowsPerPage);

	if (sql==null) sql = "SELECT * FROM TABLE";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	String norun = request.getParameter("norun");
	
	Connect cn = (Connect) session.getAttribute("CN");
//	System.out.println(request.getRemoteAddr()+": " + sql +";");
	
	int lineLength = Util.countLines(sql);
	if (lineLength <5) lineLength = 5;
	
	Query q = QueryCache.getInstance().getQueryObject(sql);
	if (q==null) {
		q = new Query(cn, sql);
		QueryCache.getInstance().addQuery(sql, q);
	} else {
//		System.out.println("*** REUSE Query");
	}

	if (q.isError()) {
%>
		<%= q.getMessage() %>
<%		
		return;
	}
	
	q.removeFilter();

	if (sortColumn != null && !sortColumn.equals("")) q.sort(sortColumn, sortDirection);
	if (filterColumn != null && !filterColumn.equals("")) {
		if (filterColumn.equals("0")) {
			filterColumn = q.getColumnLabel(0);
		}
		q.filter(filterColumn, filterValue);
	}
	
	if (searchValue !=null && !searchValue.equals("")) {
		q.search(searchValue);
	}
	
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
//	System.out.println("XXX TBL=" + tbl);

	boolean hasDataLink = false;
	String tname = tbl;
	if (tname.indexOf(".") > 0) tname = tname.substring(tname.indexOf(".")+1);

	// Foreign keys - For FK lookup
	List<ForeignKey> fks = cn.getForeignKeys(tname);
	Hashtable<String, String>  linkTable = new Hashtable<String, String>();
//	Hashtable<String, String>  linkTable2 = new Hashtable<String, String>();
	
	List<String> fkLinkTab = new ArrayList<String>();
	List<String> fkLinkCol = new ArrayList<String>();
	
	for (int i=0; i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String linkCol = cn.getConstraintCols(rec.constraintName);
		String rTable = cn.getTableNameByPrimaryKey(rec.rConstraintName);
		
//		System.out.println("linkCol=" + linkCol);
//		System.out.println("rTable=" + rTable);
		
		int colCount = Util.countMatches(linkCol, ",") + 1;
		if (colCount == 1) {
			if (rTable != null) linkTable.put(linkCol, rTable);
//			System.out.println("linkTable");
		} else {
			// check if columns are part of result set
			int matchCount = 0;
			String[] t = linkCol.split("\\,");
			for (int j=0;j<t.length;j++) {
				String colName = t[j].trim();
				for  (int k = 0; k<= q.getColumnCount()-1; k++){
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
//			System.out.println("linkTable2");
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
			for  (int i = 0; i<= q.getColumnCount()-1; i++){
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
			hasDataLink = true;
		}
	}
	
	// check if FK links are there
	if (!hasDataLink) {
		for  (int i = 0; q.hasData() && i < q.getColumnCount(); i++){
			String colName = q.getColumnLabel(i);
			String lTable = linkTable.get(colName);
			if (lTable != null) {
				hasDataLink = true;
				break;
			}
		}
	}
	
	int totalCount = q.getRecordCount();
	int filteredCount = q.getFilteredCount();
	int totalPage = q.getTotalPage(linesPerPage);
%>
<% if (totalCount>0 && hasDataLink) { 
		String txt = "Hide DataLink";
		if (!dLink) txt = "Show DataLink"; 
%>
<a id="dataLinkText" href="Javascript:toggleDataLink()"><%= txt %></a>
<% } %>

<% if (pgNo>1) { %>
<a href="Javascript:gotoPage(<%= pgNo - 1%>)"><img border=0 src="image/btn-prev.png" align="top"></a>
<% } %>

<% if (totalPage > 1) { %>
Page: <b><%= pgNo %></b> of <%= totalPage %>
<% } %>

<% if (q.getTotalPage(linesPerPage) > pgNo) { %>
<a href="Javascript:gotoPage(<%= pgNo + 1%>)"><img border=0 src="image/btn-next.png" align="top"></a>
<% } %>


Records: <%= filteredCount %>
<% if (totalCount > filteredCount) {%>
(<%= totalCount %>)
<% } %>

<% if (filteredCount > 10) {%>
Shows 
<select id="linePerPage" name="linePerPage" onChange="rowsPerPage(this.options[this.selectedIndex].value);">
<option value="10" <%= (linesPerPage==10?"SELECTED":"") %>>10</option>
<option value="20" <%= (linesPerPage==20?"SELECTED":"") %>>20</option>
<option value="50" <%= (linesPerPage==50?"SELECTED":"") %>>50</option>
<option value="100" <%= (linesPerPage==100?"SELECTED":"") %>>100</option>
<option value="200" <%= (linesPerPage==200?"SELECTED":"") %>>200</option>
<option value="500" <%= (linesPerPage==500?"SELECTED":"") %>>500</option>
<option value="1000" <%= (linesPerPage==1000?"SELECTED":"") %>>1000</option>
</select>

<% } %>

&nbsp;&nbsp;Search<input id="search" name="search" value="<%= searchValue %>" size=20 onChange="searchRecords($(this).val())">
<a href="Javascript:clearSearch()"><img border="0" src="image/clear.gif"></a>

<table id="dataTable" border=1 class="gridBody">
<tr>

<%
	int offset = 0;
	if (pkLink && dLink) {
		offset ++;
%>
	<th class="headerRow"><b>PK</b></th>
<%
	}
	if (fkLinkTab.size()>0 && dLink) {
		offset ++;
%>
	<th class="headerRow"><b>FK Link</b></th>
<%
	}
	boolean numberCol[] = new boolean[500];

	boolean hasData = q.hasMetaData();
	int colIdx = 0;
	for  (int i = 0; i<= q.getColumnCount()-1; i++){
	
		String colName = q.getColumnLabel(i);

			//System.out.println(i + " column type=" +rs.getMetaData().getColumnType(i));
			colIdx++;
			int colType = q.getColumnType(i);
			if (colType == 2 || colType == 4 || colType == 8) numberCol[colIdx] = true;
			
			String tooltip = q.getColumnTypeName(i);
			String comment =  cn.getComment(tname, colName);
			if (comment != null && comment.length() > 0) tooltip += " " + comment;
		
			boolean highlight=false;
			if (colName.equals(filterColumn)) highlight = true;
			
			String extraImage = "";
			if (colName.equals(sortColumn)) {
				if (sortDirection.equals("0"))
					extraImage = "<img src='image/sort-ascending.png'>";
				else
					extraImage = "<img src='image/sort-descending.png'>";
			}
			
%>
<th class="headerRow"><b><a <%= ( highlight?"style='background-color:yellow;'" :"")%>
	href="Javascript:doAction('<%=colName%>', <%= colIdx + offset %>);" title="<%= tooltip %>"><%=colName%></a></b>
	<%= extraImage %>
	<%-- <a href="Javascript:hide(<%=colIdx + offset%>)">x</a> --%></th>
<%
	} 
%>
</tr>


<%
	int rowCnt = 0;

//System.out.println("pageNo=" + pgNo);
//System.out.println("linesPerPage=" + linesPerPage);
	q.rewind(linesPerPage, pgNo);
	
	while (q.next() && rowCnt < linesPerPage) {
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";
%>
<tr class="simplehighlight">

<%
	if (pkLink && q.hasData() && dLink) {
		String keyValue = null;
	
		for (int i=0;q.hasData() && i<pkColList.size(); i++) {
			String v = q.getValue(pkColList.get(i));
			if (i==0) keyValue = v;
			else keyValue = keyValue + "^" + v; 
		}
		
		String linkUrl = "ajax/pk-link.jsp?table=" + tname + "&key=" + Util.encodeUrl(keyValue);
		String linkUrlTree = "data-link.jsp?table=" + tname + "&key=" + Util.encodeUrl(keyValue);
%>
	<td class="<%= rowClass%>"><a class='inspect' href='<%= linkUrl %>'><img border=0 src="image/link.gif" title="Related Tables"></a>
		&nbsp;
		<a href='<%= linkUrlTree %>'><img src="image/follow.gif" border=0 title="Drill down"></a>
	</td>
<%
	}
if (fkLinkTab.size()>0 && dLink) {
%>
<td class="<%= rowClass%>">
<% 
	for (int i=0;q.hasData() && i<fkLinkTab.size();i++) { 
		String t = fkLinkTab.get(i);
		String c = fkLinkCol.get(i);
		
		String keyValue = null;
		String[] colnames = c.split("\\,");
		for (int j=0; q.hasData() && j<colnames.length; j++) {
			String x = colnames[j].trim();
			String v = q.getValue(x);
//			System.out.println("x,v=" +x +"," + v);
			if (keyValue==null)
				keyValue = v;
			else
				keyValue += "^" + v;
		}
		
		String url = "ajax/fk-lookup.jsp?table=" + t + "&key=" + Util.encodeUrl(keyValue);
%>
<a class="inspect" href="<%= url%>"><%=t%><img border=0 src="image/view.png"></a>&nbsp;

<%			} %>
</td>
<%		}
		colIdx=0;
		for  (int i = 0; q.hasData() && i < q.getColumnCount(); i++){

				colIdx++;
				String val = q.getValue(i);
				String valDisp = Util.escapeHtml(val);
				if (val != null && val.endsWith(" 00:00:00")) valDisp = val.substring(0, val.length()-9);
				if (val==null) valDisp = "<span style='color: #999999;'>null</span>";

				String colName = q.getColumnLabel(i);
				String lTable = linkTable.get(colName);
				String keyValue = val;
				boolean isLinked = false;
				String linkUrl = "";
				String linkImage = "image/view.png";
				if (lTable != null  && dLink) {
					isLinked = true;
					linkUrl = "ajax/fk-lookup.jsp?table=" + lTable + "&key=" + Util.encodeUrl(keyValue);
				} else if (val != null && val.startsWith("BLOB ")) {
					isLinked = true;
					String tpkName = cn.getPrimaryKeyName(tbl);
					String tpkCol = cn.getConstraintCols(tpkName);
					String tpkValue = q.getValue(tpkCol);
					
					linkUrl ="ajax/blob.jsp?table=" + tbl + "&col=" + colName + "&key=" + Util.encodeUrl(tpkValue);
				}
				
				if (pkColIndex >0 && i == pkColIndex) {
					isLinked = true;
					linkUrl = "ajax/pk-link.jsp?table=" + tname + "&key=" + Util.encodeUrl(keyValue);
					linkImage = "image/link.gif";
				}

%>
<td class="<%= rowClass%>" <%= (numberCol[colIdx])?"align=right":""%>><%=valDisp%>
<%= (val!=null && isLinked?"<a class='inspect' href='" + linkUrl  + "'><img border=0 src='" + linkImage + "'></a>":"")%>
</td>
<%
		}
%>
</tr>
<%		if (q.hasData()) counter++;
		if (counter >= 1000) break;
		
//		if (!q.next()) break;
	}
	
	//q.close();

%>
</table>

<input id="recordCount" value="<%= q.getRecordCount() %>" type="hidden">

<%--
<%= counter %> rows found.<br/>
Elapsed Time <%= q.getElapsedTime() %>ms.<br/>
--%>