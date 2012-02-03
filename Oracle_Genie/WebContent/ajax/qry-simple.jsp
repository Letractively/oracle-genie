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
	String id = request.getParameter("id");
	
	
	String dataLink = request.getParameter("dataLink");
	boolean dLink = (dataLink != null && dataLink.equals("1"));  

	String showFK = request.getParameter("showFK");
	boolean showFKLink = (showFK != null && showFK.equals("1"));  
	
	if (sql==null) sql = "SELECT * FROM TABLE";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	Connect cn = (Connect) session.getAttribute("CN");
	Query q = QueryCache.getInstance().getQueryObject(sql);
	if (q==null) {
		q = new Query(cn, sql);
		QueryCache.getInstance().addQuery(sql, q);
	}
	if (q.isError()) {
%>
		<%= q.getMessage() %>
<%		
		return;
	}
	
	q.removeFilter();
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
		
		fkLinkTab.add(rTable);
		fkLinkCol.add(linkCol);
	}
	
	// Primary Key for PK Link
	String pkName = cn.getPrimaryKeyName(tname);
	int pkColIndex = -1;
//	System.out.println("sql=" + sql);
//	System.out.println("pkName=" + pkName);
	
	boolean hasPK = false;
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

		hasPK = pkColList.size() > 0;
	}
%>

<%-- <b><%= tname %></b> --%> 
<%--<%= cn.getComment(tname) --%>
<table id="table-<%= id %>" border=1 class="gridBody">
<tr>

<%
	int offset = 0;
	if (hasPK && dLink) {
		offset ++;
%>
	<th class="headerRow"><b>Link</b></th>
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
%>
<th class="headerRow"><b><a 
	href="Javascript:hideColumn('table-<%= id %>', <%= colIdx + offset %>);" title="<%= tooltip %>"><%=colName%></a></b>
<%
	} 
%>
</tr>


<%
	int rowCnt = 0;

	q.rewind(1000, 1);
	
	while (q.next()) {
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";
%>
<tr class="simplehighlight">

<%
	if (hasPK && q.hasData() && dLink) {
		String keyValue = null;
	
		for (int i=0;q.hasData() && i<pkColList.size(); i++) {
			String v = q.getValue(pkColList.get(i));
			if (i==0) keyValue = v;
			else keyValue = keyValue + "^" + v; 
		}
		
		String linkUrlTree = "data-tree.jsp?table=" + tname + "&key=" + Util.encodeUrl(keyValue);
%>
	<td class="<%= rowClass%>">
		<a href='<%= linkUrlTree %>'><img src="image/follow.gif" border=0 title="Data tree"></a>
	</td>
<%
	}

	colIdx=0;
		for  (int i = 0; q.hasData() && i < q.getColumnCount(); i++){

				colIdx++;
				String val = q.getValue(i);
				String valDisp = Util.escapeHtml(val);
				if (val != null && val.endsWith(" 00:00:00")) valDisp = val.substring(0, val.length()-9);
				if (val==null) valDisp = "<span class='nullstyle'>null</span>";
				if (val !=null && val.length() > 50) {
					id = Util.getId();
					String id_x = Util.getId();
					valDisp = valDisp.substring(0,50) + "<a id='"+id_x+"' href='Javascript:$(\"#"+id_x+"\").hide();$(\"#"+id+"\").show();'>...</a><span id='"+id+"' style='display: none;'>" + valDisp.substring(50) + "</span>";
				}
				
				String colName = q.getColumnLabel(i);
				String lTable = linkTable.get(colName);
				String keyValue = val;
				boolean isLinked = false;
				String linkUrl = "";
				String linkImage = "image/view.png";
				if (lTable != null  && dLink) {
					isLinked = true;
					linkUrl = "data-tree.jsp?table=" + lTable + "&key=" + Util.encodeUrl(keyValue);
				} else if (val != null && val.startsWith("BLOB ")) {
					isLinked = true;
					String tpkName = cn.getPrimaryKeyName(tbl);
					String tpkCol = cn.getConstraintCols(tpkName);
					String tpkValue = q.getValue(tpkCol);
					
					linkUrl ="ajax/blob.jsp?table=" + tbl + "&col=" + colName + "&key=" + Util.encodeUrl(tpkValue);
				}
/*				
				if (pkColIndex >0 && i == pkColIndex) {
					isLinked = true;
					linkUrl = "ajax/pk-link.jsp?table=" + tname + "&key=" + Util.encodeUrl(keyValue);
					linkImage = "image/link.gif";
				}
*/
%>
<td class="<%= rowClass%>" <%= (numberCol[colIdx])?"align=right":""%>><%=valDisp%>
<%= (val!=null && isLinked?"<a href='" + linkUrl  + "'><img border=0 src='" + linkImage + "'></a>":"")%>
</td>
<%
		}
%>
</tr>
<%		if (q.hasData()) counter++;
		if (counter >= 20) break;
	}
	
%>
</table>
<% if (counter >= 20) { %>
Stopped at 20 rows. You can use query builder to see the result set.
<% } %>


<% if (!showFKLink) return; %>

<%
for (int i=0; i<fkLinkTab.size(); i++) {
	String ft = fkLinkTab.get(i);
	String fc = fkLinkCol.get(i);
	
	String keyValue = null;
	String[] colnames = fc.split("\\,");
	for (int j=0; j<colnames.length; j++) {
		String x = colnames[j].trim();
		String v = q.getValue(x);
//		System.out.println("x,v=" +x +"," + v);
		if (keyValue==null)
			keyValue = v;
		else
			keyValue += "^" + v;
	}
	
	String fsql = cn.getPKLinkSql(ft, keyValue);
	id = Util.getId();
%>

<br/>
<a style="margin-left: 30px;" href="javascript:loadData('<%=id%>',1)"><b><%=ft%></b> <img id="img-<%=id%>" src="image/open.jpg"></a>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= fsql%></div>
<div id="div-<%=id%>" style="margin-left: 30px; display: none;"></div>
<% } %>

