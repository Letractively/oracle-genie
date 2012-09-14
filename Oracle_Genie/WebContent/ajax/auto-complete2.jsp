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

	String qry = "SELECT object_name FROM user_objects WHERE object_type in ('TABLE','VIEW','PACKAGE','SYNONYM') order by 1";
	List<String[]> list = cn.query(qry, 10000, true);
	
	int totalCnt = list.size();
	int selectedCnt = 0;
	if (filter !=null) filter = filter.toUpperCase();
	
	List<String> res1 = new ArrayList<String>();
	int cnt = 0;
	for (int i=0; i<list.size();i++) {
		if (list.get(i)[1].startsWith(filter)) { 
			res1.add(list.get(i)[1].toLowerCase());
			cnt ++;
		}
		if (cnt >= 50) break; 
	}	

if (cnt < 50) {
	for (int i=0; i<list.size();i++) {
		if (!list.get(i)[1].startsWith(filter) && list.get(i)[1].contains(filter)) {
			res1.add(list.get(i)[1].toLowerCase());
			cnt ++;
		}
		if (cnt >= 50) break; 
	}	
}
%>

[
<%	
	for (int i=0; i<res1.size();i++) {
%>
"<%=res1.get(i)%>",
<% 
	} 
%>
""]

<%--
[
<%	
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i)[1].startsWith(filter)) continue;
//		if (getNumRows(list.get(i)[2]).equals("0")) continue;
		selectedCnt++;
%>
"<%=list.get(i)[1].toLowerCase()%>",
<% 
		if (selectedCnt >= 50) break;
	} 
	// if not found, search partial match
	if (selectedCnt <= 30) {
		for (int i=0; i<list.size();i++) {
			if (filter != null && !list.get(i)[1].contains(filter)) continue;
			if (list.get(i)[1].startsWith(filter)) continue;
//			if (getNumRows(list.get(i)[2]).equals("0")) continue;
			selectedCnt++;
%>
"<%=list.get(i)[1].toLowerCase()%>",
<% 
			if (selectedCnt >= 50) break;
		}
	}
%>

""]
 --%>