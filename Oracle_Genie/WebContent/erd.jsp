<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String table = request.getParameter("tname");
	String owner = request.getParameter("owner");
	
	// incase owner is null & table has owner info
	if (owner==null && table!=null && table.indexOf(".")>0) {
		int idx = table.indexOf(".");
		owner = table.substring(0, idx);
		table = table.substring(idx+1);
	}
	
	System.out.println("owner=" + owner);
	
//	String catalog = null;
	String tname = table;
	int idx = table.indexOf(".");
/* 	if (idx>0) {
		catalog = table.substring(0, idx);
		tname = table.substring(idx+1);
	}
	if (catalog==null) catalog = cn.getSchemaName();
 */
	String pkName = cn.getPrimaryKeyName(tname);
	ArrayList<String> pk = cn.getPrimaryKeys(owner, tname);
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
	<title>Genie - ERD</title>
    <script src="script/jquery.js" type="text/javascript"></script>
    <script src="script/data-link.js" type="text/javascript"></script>

    <script src="script/jquery.colorbox-min.js"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
    <link rel="stylesheet" href="css/colorbox.css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    
<script type="text/javascript">
	function toggleDiv(id) {
		var img = $("#img-"+ id).attr("src");
		if (img.indexOf("plus")>=0) {
			$("#img-"+ id).attr("src","image/minus.gif");
			$("#sub-"+id).slideDown();
		} else {
			$("#img-"+ id).attr("src","image/plus.gif");
			$("#sub-"+id).slideUp();
		}
	}
	
	function hideDiv(id) {
		$("#div-"+id).slideUp();
	}
	
	function openAll() {
		$("div ").each(function() {
			var divName = $(this).attr('id');
			if (divName != null && divName.indexOf("sub-")>=0) {
				$("#"+divName).slideDown();
				$("#img-"+divName.substring(4)).attr("src", "image/minus.gif");
			}
		});
	}
	
	function closeAll() {
		$("div ").each(function() {
			var divName = $(this).attr('id');
			if (divName != null && divName.indexOf("sub-")>=0) {
				$("#"+divName).slideUp();
				$("#img-"+divName.substring(4)).attr("src", "image/plus.gif");
			}
		});
	}
	
</script>
</head> 

<body>

<img src="image/data-link.png" align="middle"/>
<%= cn.getUrlString() %>

<br/>

<h3>ERD</h3>

<a href="Javascript:openAll()">Open All</a>
<a href="Javascript:closeAll()">Close All</a>
<br/><br/>


<div id="parentDiv" style="width: 100%; overflow:auto;">
&nbsp;

<% for (ForeignKey rec: fks) { 
	List<TableCol> list1 = cn.getTableDetail(owner, rec.rTableName);
	ArrayList<String> pk1 = cn.getPrimaryKeys(owner, rec.rTableName);
	String id = Util.getId();
%>
<div id="div-<%=id%>" style="margin-left: 20px; background-color: #ffffcc; width:220px; border: 1px solid #cccccc; float: left;">
<a href="erd.jsp?tname=<%= rec.rTableName %>"><%= rec.rTableName %></a>
<a href="javascript:toggleDiv('<%= id %>')"><img id="img-<%=id%>" align=top src="image/plus.gif"></a>
<a href="javascript:hideDiv('<%= id %>')">x</a>

<div id="sub-<%=id%>" style="display: none;">
<table>
<%
for (TableCol t: list1) {
	String colDisp = t.getName().toLowerCase();
	if (pk1.contains(t.getName())) colDisp = "<b>" + colDisp + "</b>";
%>
<tr>
<td width="20">&nbsp;</td>
<td>
<%= colDisp %>
</td>
<td>
<%= t.getTypeName() %>
</td>
</tr>
<% } %>
</table>
</div>
</div>
<% } %>

</div>

<% if (fks.size() >0 ) { %>
<img style="margin-left:170px;" src="image/arrow_up.jpg">
<% } %>

<%
	String id = Util.getId();
%>
<div id="mainDiv" style="margin-left: 80px; background-color: #99FFFF; width:220px; border: 1px solid #cccccc;">
<b><%= tname %></b>
<a href="javascript:toggleDiv('<%= id %>')"><img id="img-<%=id%>" align=top src="image/minus.gif"></a>
<div id="sub-<%=id%>" style="display: block;">
<table>
<%
for (TableCol t: list) {
	String colDisp = t.getName().toLowerCase();
	if (pk.contains(t.getName())) colDisp = "<b>" + colDisp + "</b>";
%>
<tr>
<td width="20">&nbsp;</td>
<td>
<%= colDisp %>
</td>
<td>
<%= t.getTypeName() %>
</td>
</tr>
<% } %>
</table>
</div>
</div>

<% if (refTabs.size() >0 ) { %>
<img style="margin-left:170px;" src="image/arrow_up.jpg">
<% } %>

<div id="childDiv">

<% for (String tbl: refTabs) { 
	List<TableCol> list1 = cn.getTableDetail(owner, tbl);
	ArrayList<String> pk1 = cn.getPrimaryKeys(owner, tbl);
	id = Util.getId();
%>
<div id="div-<%=id%>" style="margin-left: 20px; background-color: #ffffcc; width:220px; border: 1px solid #cccccc; float: left;">
<a href="erd.jsp?tname=<%= tbl %>"><%= tbl %></a>
<a href="javascript:toggleDiv('<%= id %>')"><img id="img-<%=id%>" align=top src="image/plus.gif"></a>
<a href="javascript:hideDiv('<%= id %>')">x</a>

<div id="sub-<%=id%>" style="display: none;">
<table>
<%
for (TableCol t: list1) {
	String colDisp = t.getName().toLowerCase();
	if (pk1.contains(t.getName())) colDisp = "<b>" + colDisp + "</b>";
%>
<tr>
<td width="20">&nbsp;</td>
<td>
<%= colDisp %>
</td>
<td>
<%= t.getTypeName() %>
</td>
</tr>
<% } %>
</table>
</div>
</div>
<% } %>
</div>


</body>
</html>