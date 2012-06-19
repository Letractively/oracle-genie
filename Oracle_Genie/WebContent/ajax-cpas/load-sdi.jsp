<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.Connect" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	
	String qry = "SELECT SDI, NAME FROM CPAS_SDI WHERE ORDERBY > 0 ORDER BY NAME"; 	
	List<String[]> list = cn.queryMultiCol(qry, 2, true);
	
	int totalCnt = list.size();

	for (int i=0; i<list.size();i++) {
%>
	<li><a href="javascript:loadTV('<%=list.get(i)[1]%>');"><%=list.get(i)[2]%></a> <%=list.get(i)[1]%></li>
<% 
	} 
%>
