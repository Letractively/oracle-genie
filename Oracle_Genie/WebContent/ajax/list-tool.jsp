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

	List<String> list = new ArrayList<String>();
	list.add("Dictionary");
	list.add("Sequence");
	list.add("DB link");
%>
<% 
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i).toUpperCase().contains(filter)) continue;
%>
	<li><a href="javascript:loadTool('<%=list.get(i)%>');"><%=list.get(i)%></a></li>
<% 
	} 
%>

