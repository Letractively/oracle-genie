<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");
	
	if (cn==null) {
%>	
		Connection lost. <a href="Javascript:window.close()">Close</a>
<%
		return;
	}
	Connection conn = cn.getConnection();

	String table = request.getParameter("table");
	String key = request.getParameter("key");
	
	List<String> refTabs = cn.getReferencedTables(table);
%>

<div id="pkLink">

<% if (refTabs.size() > 0) { %>
Linked Tables: <br/>

<table class="gridBody" border=1>
<tr class="rowHeader">
	<td>Table Name</td>
	<td>Records</td>
	<td>Comment</td>
</tr>
<%
	// Primary Key for PK Link
	String pkName = cn.getPrimaryKeyName(table);
	String pkCols = null;
	String pkColName = null;
	int pkColIndex = -1;
	if (pkName != null) {
		pkCols = cn.getConstraintCols(pkName);
		int colCount = Util.countMatches(pkCols, ",") + 1;
		System.out.println("pkCols=" + pkCols + ", colCount=" + colCount);
	
		pkColName = pkCols;
	}


	for (int i=0; i<refTabs.size(); i++) {
		String refTab = refTabs.get(i);
		int recCount = cn.getPKLinkCount(refTab, pkColName, key);
		String rowClass = "odd";
		if ((i+1)%2 == 0) rowClass = "even";
%>
	<tr class="<%=rowClass%>">
		<td><%=(recCount>0?"<b>":"")%>
			<a href="javascript:linkPk('<%= refTab %>','<%= pkColName %>','<%= Util.encodeUrl(key) %>','<%= table %>')"><%= refTab %></a>
			<%=(recCount>0?"</b>":"")%>
		</td>
		<td align=right><%= recCount %></td>
		<td><%= cn.getComment(refTab) %></td>
	</tr>
<% }
}
%>
</table>
</div>