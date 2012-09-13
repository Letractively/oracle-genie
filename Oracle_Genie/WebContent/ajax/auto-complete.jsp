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
	String term = request.getParameter("term");
	String filter = term;

	String qry = "SELECT TABLE_NAME, NUM_ROWS FROM USER_TABLES ORDER BY 1"; 	
	List<String[]> list = cn.query(qry, true);
	
	int totalCnt = list.size();
	int selectedCnt = 0;
	if (filter !=null) filter = filter.toUpperCase();
%>

[
<%	
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i)[1].startsWith(filter)) continue;
		if (getNumRows(list.get(i)[2]).equals("0")) continue;
		selectedCnt++;
%>
"<%=list.get(i)[1]%>",
<% 
		if (selectedCnt >= 50) break;
	} 
	// if not found, search partial match
	if (selectedCnt <= 30) {
		for (int i=0; i<list.size();i++) {
			if (filter != null && !list.get(i)[1].contains(filter)) continue;
			if (list.get(i)[1].startsWith(filter)) continue;
			if (getNumRows(list.get(i)[2]).equals("0")) continue;
			selectedCnt++;
%>
"<%=list.get(i)[1]%>",
<% 
			if (selectedCnt >= 50) break;
		}
	}
%>
<%
	// if not found, search views
	if (selectedCnt <= 30) {

		qry = "SELECT VIEW_NAME FROM USER_VIEWS ORDER BY 1"; 	
		List<String> list2 = cn.queryMulti(qry);
		
		for (int i=0; i<list2.size();i++) {
			if (filter != null && !list2.get(i).startsWith(filter)) continue;
			selectedCnt++;
%>
"<%=list2.get(i)%>",
<% 
			if (selectedCnt >= 50) break;
		}
	}
%>
<%
	// if not found, search views
	if (selectedCnt <= 30) {

		qry = "SELECT VIEW_NAME FROM USER_VIEWS ORDER BY 1"; 	
		List<String> list2 = cn.queryMulti(qry);
		
		for (int i=0; i<list2.size();i++) {
			if (filter != null && !list2.get(i).contains(filter)) continue;
			selectedCnt++;
%>
"<%=list2.get(i)%>",
<% 
			if (selectedCnt >= 50) break;
		}
	}
%>

""]
