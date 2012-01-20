<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	if (cn==null) {
%>	
		Connection lost. Please log in again.
<%
		return;
	}

	String owner = request.getParameter("owner");
	String name = request.getParameter("name");

	// incase owner is null & table has owner info
	if (owner==null && name!=null && name.indexOf(".")>0) {
		int idx = name.indexOf(".");
		owner = name.substring(0, idx);
		name = name.substring(idx+1);
	}
	
	if (owner==null) owner = cn.getSchemaName().toUpperCase();
	
	String catalog = cn.getSchemaName();

	Connection conn = cn.getConnection();

	String sourceUrl = "source.jsp?name=" + name;
	if (owner != null) sourceUrl += "&owner=" + owner;
	
	String typeName = cn.getObjectType(owner, name);
%>

<h2><%= typeName %>: <%= name %> &nbsp;&nbsp;<a href="<%=sourceUrl%>" target="_blank"><img border=0 src="image/icon_query.png" title="Source code"></a></h2>


<%

	Statement stmt2 = conn.createStatement();
	String qry = "SELECT distinct PROCEDURE_NAME FROM all_procedures where owner='" + owner + "' and object_name='" + name + "' and PROCEDURE_NAME is not null order by 1";
	ResultSet rs2 = stmt2.executeQuery(qry);

	int cnt = 0;
	while (rs2.next()) {
		String proc = rs2.getString("PROCEDURE_NAME");
		cnt ++;
%>
<% if (cnt==1) { %>Procedures:<br/><% } %>
	&nbsp;&nbsp;&nbsp;&nbsp;<%= proc.toLowerCase() %><br/>
<%	
	}
	
	rs2.close();
	stmt2.close();
	

%>
<br/>

Dependencies:

<table>
<tr>
	<td>&nbsp;</td>
	<td bgcolor=#ccccff>Program</td>
	<td bgcolor=#ccccff>Table</td>
	<td bgcolor=#ccccff>View</td>
	<td bgcolor=#ccccff>Synonym</td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td valign=top><%= cn.getDependencyPackage(owner, name) %></td>
	<td valign=top><%= cn.getDependencyTable(owner, name) %></td>
	<td valign=top><%= cn.getDependencyView(owner, name) %></td>
	<td valign=top><%= cn.getDependencySynonym(owner, name) %></td>
</tr>
</table>
<br/>

