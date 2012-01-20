<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	int counter = 0;
	String filterColumn = request.getParameter("filterColumn");
	
	String sql = request.getParameter("sql");

System.out.println("filterColumn=" + filterColumn);

	if (sql==null) sql = "SELECT * FROM TABLE";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	Connect cn = (Connect) session.getAttribute("CN");
	
	if (cn==null) {
%>	
		Connection lost. <a href="Javascript:window.close()">Close</a>
<%
		return;
	}
	Connection conn = cn.getConnection();
	
//	Query q = (Query) session.getAttribute(sql);
	Query q = QueryCache.getInstance().getQueryObject(sql);
	if (q==null) {
		q = new Query(cn, sql);
		QueryCache.getInstance().addQuery(sql, q);
	} else {
		System.out.println("*** REUSE Query");
	}

	if (filterColumn.equals("0")) {
		filterColumn = q.getColumnLabel(0);
	}

	List<String> list = q.getFilterList(filterColumn);
%>

Filter for <%= filterColumn %>
<select id="filterSelect" onchange="applyFilter(this.options[this.selectedIndex].value);">
<option value="">All</option>
<% for (int i=0; i<list.size(); i++) { %>
	<option value="<%= list.get(i) %>"><%= list.get(i) %></option>
<% } %>
</select>

<a href="Javascript:removeFilter()">Remove Filter</a>