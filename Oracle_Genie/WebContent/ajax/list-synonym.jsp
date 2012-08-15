<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.Connect" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String filter = request.getParameter("filter");

	String qry = "SELECT SYNONYM_NAME, TABLE_OWNER, TABLE_NAME FROM USER_SYNONYMS ORDER BY 1"; 	
	List<String[]> list = cn.query(qry);

	int totalCnt = list.size();
	int selectedCnt = 0;
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i)[1].contains(filter)) continue;
		selectedCnt ++;
	}

%>
Found <%= selectedCnt %> synonym(s).
<br/><br/>
<%	
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i)[1].contains(filter)) continue;
%>
	<li><a href="javascript:loadSynonym('<%=list.get(i)[1]%>');"><%=list.get(i)[1]%></a> <span class="rowcountstyle"><%= cn.getTableRowCount(list.get(i)[2], list.get(i)[3]) %></span></li>
<% 
	} 
%>

