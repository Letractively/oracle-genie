<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.Connect" 
	pageEncoding="ISO-8859-1"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String filter = request.getParameter("filter");

	String qry = "SELECT VIEW_NAME FROM USER_VIEWS ORDER BY 1"; 	
	List<String> list = cn.queryMulti(qry);
	
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i).contains(filter)) continue;
%>
	<li><a href="javascript:loadView('<%=list.get(i)%>');"><%=list.get(i)%></a></li>
<% 
	} 
%>

