<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.Connect" 
	pageEncoding="ISO-8859-1"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String filter = request.getParameter("filter");

	if (cn==null) {
%>	
		Connection lost. Please log in again.
<%
		return;
	}	

	Connection conn = cn.getConnection();
%>
<% 
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<cn.getTables().size();i++) { 
		if (filter != null && !cn.getTable(i).contains(filter)) continue;
%>
	<li><a href="javascript:loadTable('<%=cn.getTable(i)%>');"><%=cn.getTable(i)%></a></li>
<% 
	} 
%>

