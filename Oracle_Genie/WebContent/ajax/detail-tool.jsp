<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	String owner = request.getParameter("owner");
	String tool = request.getParameter("name");
	Connect cn = (Connect) session.getAttribute("CN");

	String catalog = cn.getSchemaName();

	String qry=null;
	if (tool.equalsIgnoreCase("dictionary"))
		qry = "SELECT * FROM DICTIONARY ORDER BY 1";
	else if (tool.equalsIgnoreCase("sequence"))
		qry = "SELECT * FROM USER_SEQUENCES ORDER BY 1";
	else if (tool.equalsIgnoreCase("db link"))
		qry = "SELECT * FROM USER_DB_LINKS ORDER BY 1";
	else if (tool.equalsIgnoreCase("User role priv")) 
		qry = "SELECT * FROM USER_ROLE_PRIVS";
	else if (tool.equalsIgnoreCase("User sys priv")) 
		qry = "SELECT * FROM USER_SYS_PRIVS";
	else if (tool.equalsIgnoreCase("search program")) 
		qry = "SELECT * FROM USER_SOURCE WHERE lower(text) like lower('%[Search Keyword (ex: insert into TABLE )]%')";
	else if (tool.equalsIgnoreCase("invalid objects")) 
		qry = "SELECT owner, object_type, object_name, status FROM all_objects WHERE status != 'VALID' ORDER BY owner, object_type, object_name";
	else if (tool.equalsIgnoreCase("oracle version"))
		qry = "SELECT * FROM GV$VERSION";
%>
<h2><%= tool %> &nbsp;&nbsp;</h2>

<% if (qry != null)  {%>
<jsp:include page="detail-tool-query.jsp">
	<jsp:param value="<%= qry %>" name="qry"/>
	
</jsp:include>

<% } %>

<% if (tool.equalsIgnoreCase("search db content")) { %>
<jsp:include page="content-search.jsp"/>
<% } %>

<% if (tool.equalsIgnoreCase("user defined page")) { %>
<jsp:include page="udp.jsp"/>
<% } %>
