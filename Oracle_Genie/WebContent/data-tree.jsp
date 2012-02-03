<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");

	String table = request.getParameter("table");
	String key = request.getParameter("key");
	List<String> refTabs = cn.getReferencedTables(table);

	String sql = cn.getPKLinkSql(table, key);
//System.out.println("sql=" + sql);	
	Query q = QueryCache.getInstance().getQueryObject(sql);
	if (q==null) {
		q = new Query(cn, sql);
		QueryCache.getInstance().addQuery(sql, q);
	}
	// Foreign keys - For FK lookup
	List<ForeignKey> fks = cn.getForeignKeys(table);
//System.out.println("fks.size()=" + fks.size());	
	Hashtable<String, String>  linkTable = new Hashtable<String, String>();

	List<String> fkLinkTab = new ArrayList<String>();
	List<String> fkLinkCol = new ArrayList<String>();
	
	for (int i=0; i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String linkCol = cn.getConstraintCols(rec.constraintName);
		String rTable = cn.getTableNameByPrimaryKey(rec.rConstraintName);
		
		fkLinkTab.add(rTable);
		fkLinkCol.add(linkCol);
	}

	List<String> autoLoadFK = new ArrayList<String>();
	List<String> autoLoadChild = new ArrayList<String>();
%>


<html>
<head> 
	<title>Genie - Data Tree</title>
    <script src="script/jquery.js" type="text/javascript"></script>
    <script src="script/data-tree.js" type="text/javascript"></script>

    <script src="script/jquery.colorbox-min.js"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
    <link rel="stylesheet" href="css/colorbox.css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    
</head> 

<body>

<img src="image/icon_query.png" align="middle"/>
<%= cn.getUrlString() %>

<br/><br/>


<a href="Javascript:hideNullColumn()">Hide Null</a>
&nbsp;&nbsp;
<a href="Javascript:showAllColumn()">Show All</a>
<br/><br/>

<%
	String id = Util.getId();
%>
<b><%= table %></b>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<br/>
<div id="data-div">
<jsp:include page="ajax/qry-simple.jsp">
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="0" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>
<br/>

<% if (fkLinkTab.size() > 0) {%>
	<b><a href="Javascript:$('#div-fk').toggle();">Foreign Key</a></b><br/>
<div id="div-fk">
<% } %>
<%
	for (int i=0; i<fkLinkTab.size(); i++) {
		String ft = fkLinkTab.get(i);
		String fc = fkLinkCol.get(i);
		
		String keyValue = null;
		String[] colnames = fc.split("\\,");
		for (int j=0; j<colnames.length; j++) {
			String x = colnames[j].trim();
			String v = (q==null?"":q.getValue(x));
//			System.out.println("x,v=" +x +"," + v);
			if (keyValue==null)
				keyValue = v;
			else
				keyValue += "^" + v;
		}
		
		String fsql = cn.getPKLinkSql(ft, keyValue);
		id = Util.getId();
		autoLoadFK.add(id);
%>
<a style="margin-left: 30px;" href="javascript:loadData('<%=id%>',1)"><b><%=ft%></b> <img id="img-<%=id%>" src="image/open.jpg"></a>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= fsql%></div>
<div id="div-<%=id%>" style="margin-left: 30px; display: none;"></div>
<br/>
<% } %>

<% if (fkLinkTab.size() > 0) {%>
</div>
<% } %>

<div style="display: none;">
<form name="form0" id="form0" action="query.jsp">
<input id="sql" name="sql" type="hidden" value=""/>
<input id="dataLink" name="dataLink" type="hidden" value="1"/>
<input id="id" name="id" type="hidden" value=""/>
<input id="showFK" name="showFK" type="hidden" value="0"/>
</form>
</div>

<br/>


<%
	// Primary Key for PK Link
	String pkName = cn.getPrimaryKeyName(table);
	String pkCols = null;
	String pkColName = null;
	int pkColIndex = -1;
	if (pkName != null) {
		pkCols = cn.getConstraintCols(pkName);
		int colCount = Util.countMatches(pkCols, ",") + 1;
		pkColName = pkCols;
	}

	int cntRef = 0;
	for (int i=0; i<refTabs.size(); i++) {
		String refTab = refTabs.get(i);
//System.out.println("refTab="+refTab);		
		String fkColName = cn.getRefConstraintCols(table, refTab);
//System.out.println("fkColName="+fkColName);		
		int recCount = cn.getPKLinkCount(refTab, fkColName , key);
		if (recCount==0) continue;
		String refsql = cn.getRelatedLinkSql(refTab, fkColName, key);

		id = Util.getId();
		autoLoadChild.add(id);
		cntRef++;
%>

<% if (cntRef == 1) {%>
	<b><a href="Javascript:$('#div-child').toggle();">Child Table</a></b><br/>
<div id="div-child">
<% } %>

<a style="margin-left: 30px;" href="javascript:loadData('<%=id%>',0)"><b><%= refTab %></b> (<%= recCount %>) <img id="img-<%=id%>" src="image/open.jpg"></a>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= refsql%></div>
<div id="div-<%=id%>" style="margin-left: 30px; display: none;"></div>
<br/>
<%	
	}	
%>

<% if (cntRef > 1) {%>
</div>
<% } %>

<br/><br/>
<a href="Javascript:window.close()"><img src="image/exit.png" title="Exit" border=0></a>
<br/><br/>

<script type="text/javascript">
$(document).ready(function() {
<%
	for (String id1: autoLoadFK) {
%>
	loadData(<%=id1%>,1);
<%
	}
%>

<%
if (autoLoadChild.size() <= 5) {
	for (String id1: autoLoadChild) {
%>
loadData(<%=id1%>,0);
<%
	}
}
%>
});	    
</script>

</body>
</html>

