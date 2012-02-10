<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String table = request.getParameter("table");
	String owner = request.getParameter("owner");
	
	// incase owner is null & table has owner info
	if (owner==null && table!=null && table.indexOf(".")>0) {
		int idx = table.indexOf(".");
		owner = table.substring(0, idx);
		table = table.substring(idx+1);
	}
	
	System.out.println("owner=" + owner);
	
	String catalog = null;
	String tname = table;
	int idx = table.indexOf(".");
	if (idx>0) {
		catalog = table.substring(0, idx);
		tname = table.substring(idx+1);
	}
	if (catalog==null) catalog = cn.getSchemaName();

	String pkName = cn.getPrimaryKeyName(tname);
	if (pkName == null && owner != null) pkName = cn.getPrimaryKeyName(owner, tname);

	String pkCols = cn.getConstraintCols(pkName);
	if (pkName != null && pkCols.equals(""))
		pkCols = cn.getConstraintCols(owner, pkName);
	
	List<ForeignKey> fks = cn.getForeignKeys(tname);
	if (owner != null) fks = cn.getForeignKeys(owner, tname);
	
	List<String> refTabs = cn.getReferencedTables(owner, tname);
	
	List<TableCol> list = cn.getTableDetail(owner, tname);	
%>

<html>
<head> 
	<title>Genie - Data Link</title>
    <script src="script/jquery.js" type="text/javascript"></script>
    <script src="script/data-link.js" type="text/javascript"></script>

    <script src="script/jquery.colorbox-min.js"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
    <link rel="stylesheet" href="css/colorbox.css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    
</head> 
<body>

<div id="parentDiv" style="width:220px; height: 300px; overflow: auto; border: 1px solid #cccccc; float: left">
<div>
<% for (ForeignKey rec: fks) { %>

<a href="erd.jsp?table=<%= rec.rTableName %>"><%= rec.rTableName %></a><br/>

<% } %>
</div>
</div>

<img style="float:left;" src="image/blue_arrow_left.png">

<div id="mainDiv" style="width:220px; height: 300px; overflow: auto; border: 1px solid #cccccc; float: left">
<%= tname %><br/>
<hr>
<table>
<% for (TableCol t: list) { %>
<tr>
<td width="20">&nbsp;</td>
<td>
<%= t.getName().toLowerCase() %>
</td>
<td>
<%= t.getTypeName() %>
</td>
</tr>
<% } %>
</table>
</div>


<img style="float:left;" src="image/blue_arrow_left.png">

<div id="childDiv" style="width:220px; height: 300px; overflow: auto; border: 1px solid #cccccc; float: left">
<div>
<% for (String t: refTabs) { %>
<a href="erd.jsp?table=<%= t %>"><%= t %></a><br/>
<% } %>
</div>
</div>

<br clear="all"/>


</body>
</html>