<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.Connect" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%! 
	public String getNumRows (String numRows) {
		if (numRows==null) numRows = "";
		else {
			int n = Integer.parseInt(numRows);
			if (n < 1000) {
				numRows = numRows;
			} else if (n < 1000000) {
				numRows = Math.round(n /1000) + "K";
			} else {
				numRows = (Math.round(n /100000) / 10.0 )+ "M";
			}
		}
		return numRows;
	}

%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String filter = request.getParameter("filter");

	String qry = "SELECT TABLE_NAME, NUM_ROWS FROM USER_TABLES ORDER BY 1"; 	
	//List<String> list = cn.queryMulti(qry);
	List<String[]> list = cn.queryMultiCol(qry, 2, true);
	
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i)[1].contains(filter)) continue;
		
		
%>
	<li><a href="javascript:loadTable('<%=list.get(i)[1]%>');"><%=list.get(i)[1]%></a> <%= getNumRows(list.get(i)[2]) %></li>
<% 
	} 
%>
