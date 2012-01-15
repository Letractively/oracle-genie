<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	String owner = request.getParameter("owner");
	String syn = request.getParameter("name");
	Connect cn = (Connect) session.getAttribute("CN");

	if (cn==null) {
%>	
		Connection lost. Please log in again.
<%
		return;
	}

	// incase owner is null & table has owner info
	if (owner==null && syn!=null && syn.indexOf(".")>0) {
		int idx = syn.indexOf(".");
		owner = syn.substring(0, idx);
		syn = syn.substring(idx+1);
	}
		
	String catalog = cn.getSchemaName();

	Connection conn = cn.getConnection();

	Statement stmt = conn.createStatement();
	ResultSet rs = stmt.executeQuery("SELECT * FROM USER_SYNONYMS WHERE SYNONYM_NAME='" + syn +"'");

	String oname = "";
	if (rs.next()) {
		
		owner = rs.getString("TABLE_OWNER");
		oname = rs.getString("TABLE_NAME");
	}
	
	rs.close();
	stmt.close();
	
	stmt = conn.createStatement();
	rs = stmt.executeQuery("SELECT * FROM ALL_OBJECTS WHERE OWNER='" + owner +
			"' AND OBJECT_NAME='" + oname + "' ORDER BY OBJECT_TYPE");

	String otype = "";
	if (rs.next()) {
		otype = rs.getString("OBJECT_TYPE");
	}
	
	rs.close();
	stmt.close();

%>
<h2>SYNONYM: <%= syn %> &nbsp;&nbsp;</h2>

&nbsp;&nbsp;&nbsp;<%= owner %>.<%= oname %>  (<%= otype %>)

<% if (otype.equals("TABLE")) { %>
	<jsp:include page="detail-table.jsp">
		<jsp:param value="<%= owner %>" name="owner"/>
		<jsp:param value="<%= oname %>" name="table"/>
	</jsp:include>
<% } else if (otype.equals("PACKAGE")) { %>
	<jsp:include page="detail-package.jsp">
		<jsp:param value="<%= owner %>" name="owner"/>
		<jsp:param value="<%= oname %>" name="name"/>
	</jsp:include>
<% } else if (otype.equals("VIEW")) { %>
	<jsp:include page="detail-view.jsp">
		<jsp:param value="<%= owner %>" name="owner"/>
		<jsp:param value="<%= oname %>" name="view"/>
	</jsp:include>
<% } %>	
