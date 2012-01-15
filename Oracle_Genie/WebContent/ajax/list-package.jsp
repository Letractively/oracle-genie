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
	
	Statement stmt = conn.createStatement();
	ResultSet rs = stmt.executeQuery("SELECT * FROM USER_OBJECTS WHERE object_type IN ('PACKAGE','PROCEDURE','FUNCTION','TYPE') order by 1");
	
	List<String> list = new ArrayList<String>();
	while (rs.next()) {
		String oname = rs.getString(1);
		list.add(oname);
	}
	
	rs.close();
	stmt.close();
	
%>
<% 
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i).contains(filter)) continue;
%>
	<li><a href="javascript:loadPackage('<%=list.get(i)%>');"><%=list.get(i)%></a></li>
<% 
	} 
%>

