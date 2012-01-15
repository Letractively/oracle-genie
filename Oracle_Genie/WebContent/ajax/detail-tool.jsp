<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	String owner = request.getParameter("owner");
	String tool = request.getParameter("name");
	Connect cn = (Connect) session.getAttribute("CN");

	if (cn==null) {
%>	
		Connection lost. Please log in again.
<%
		return;
	}

	String catalog = cn.getSchemaName();

	Connection conn = cn.getConnection();

	String qry=null;
	if (tool.equalsIgnoreCase("dictionary"))
		qry = "SELECT * FROM DICTIONARY ORDER BY 1";
	else if (tool.equalsIgnoreCase("sequence"))
		qry = "SELECT * FROM USER_SEQUENCES ORDER BY 1";
	else if (tool.equalsIgnoreCase("db link"))
		qry = "SELECT * FROM USER_DB_LINKS ORDER BY 1";
	
%>
<h2>TOOL: <%= tool %> &nbsp;&nbsp;</h2>

<jsp:include page="detail-tool-query.jsp">
	<jsp:param value="<%= qry %>" name="qry"/>
</jsp:include>
