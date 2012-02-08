<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	String view = request.getParameter("view");
	String owner = request.getParameter("owner");
	
	Connect cn = (Connect) session.getAttribute("CN");

	// incase owner is null & table has owner info
	if (owner==null && view!=null && view.indexOf(".")>0) {
		int idx = view.indexOf(".");
		owner = view.substring(0, idx);
		view = view.substring(idx+1);
	}
	
	String catalog = cn.getSchemaName();

	String qry = "SELECT TEXT FROM USER_VIEWS WHERE VIEW_NAME='" + view +"'";
	if (owner != null) 
		qry = "SELECT TEXT FROM ALL_VIEWS WHERE OWNER='" + owner + "' AND VIEW_NAME='" + view +"'"; 
	String text = cn.queryOne(qry);
%>
<h2>VIEW: <%= view %> &nbsp;&nbsp;<a href="Javascript:runQuery('<%=catalog%>','<%=view%>')"><img border=0 src="image/icon_query.png" title="query"></a></h2>

<table id="TABLE_<%=view%>" width=640 border=0>
<tr>
	<th></th>
	<th bgcolor=#ccccff>Column Name</th>
	<th bgcolor=#ccccff>Type</th>
	<th bgcolor=#ccccff>Null</th>
	<th bgcolor=#ccccff>Default</th>
<!-- 	<th bgcolor=#ccccff>Remarks</th>
 -->
 </tr>

<%	
	List<TableCol> list = cn.getTableDetail(owner, view);
	for (int i=0;i<list.size();i++) {
		TableCol rec = list.get(i);
		
		// check if primary key
		String col_disp = rec.getName().toLowerCase();
		if (rec.isPrimaryKey()) col_disp = "<span class='primary-key'>" + col_disp + "</span>";
%>
<tr>
	<td>&nbsp;</td>
	<td><%= col_disp %></td>
	<td><%= rec.getTypeName() %></td>
	<td><%= rec.getNullable()==0?"N":"" %></td>
	<td><%= rec.getDefaults() %></td>
<!-- 	<td></td>
 --></tr>

<%
	}
%>
</table>

<hr>

<b>Definition</b> 
<pre class='brush: sql'>
<%= text %>
</pre>
<hr>

<b>Related Table</b><br/>

<%
	qry = "SELECT REFERENCED_NAME, REFERENCED_OWNER FROM USER_DEPENDENCIES WHERE NAME='" + view +"' AND REFERENCED_TYPE='TABLE' ORDER BY REFERENCED_NAME";
	if (owner != null)
		qry = "SELECT REFERENCED_NAME, REFERENCED_OWNER FROM ALL_DEPENDENCIES WHERE OWNER='" + owner + "' AND NAME='" + view +"' AND REFERENCED_TYPE='TABLE' ORDER BY REFERENCED_NAME";

	List<String[]> lst = cn.queryMultiCol(qry, 2);
	
	for (int i=0;i<lst.size();i++) {
		String tname = lst.get(i)[1];
		String rOwner = lst.get(i)[2];
%>
	&nbsp;&nbsp;
	<a href="javascript:loadTable('<%=tname%>');"><%=tname%></a><br/>
<%
	}
%>


<br/>
<b>Related Program</b><br/>
<%

	qry = "SELECT REFERENCED_NAME, REFERENCED_OWNER FROM USER_DEPENDENCIES WHERE NAME='" + view +"' AND REFERENCED_TYPE='PACKAGE' ORDER BY REFERENCED_NAME";
	if (owner != null)
		qry = "SELECT REFERENCED_NAME, REFERENCED_OWNER FROM ALL_DEPENDENCIES WHERE OWNER = '" + owner + "' AND NAME='" + view +"' AND REFERENCED_TYPE='PACKAGE' ORDER BY REFERENCED_NAME";

	List<String[]> list2 = cn.queryMultiCol(qry, 2);
	for (int i=0;i<list2.size();i++) {
		String tname = list2.get(i)[1];
		String rOwner = list2.get(i)[2];
%>
	&nbsp;&nbsp;
	<a href="javascript:loadPackage('<%=tname%>');"><%=tname%></a><br/>
<%
	}
%>

