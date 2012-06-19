<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.Connect" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	
	String qry = "SELECT TYPE, NAME FROM CPAS_PROCESSTYPE ORDER BY ORDERBY"; 	
	//String qry = "SELECT TAB, NAME FROM CPAS_TAB ORDER BY ORDERBY"; 	
	List<String[]> list = cn.query(qry);
	if (list.size()==0) {
		qry = "SELECT TAB, NAME FROM CPAS_TAB ORDER BY ORDERBY"; 	
		list = cn.query(qry);
	}
	
	int totalCnt = list.size();
%>
<b>Process Type</b>
<%
	for (int i=0; i<list.size();i++) {
%>
	<li><a href="javascript:loadProcess('<%=list.get(i)[1]%>');"><%=list.get(i)[2]%></a> <%=list.get(i)[1]%></li>
<% 
	} 
%>
