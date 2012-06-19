<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String process = request.getParameter("process");
	String event = request.getParameter("event");
/*
	String qry = "SELECT POSITION, TYPE, CAPTION, SECLABEL, SDI, UDATA, TREEKEY FROM CPAS_PROCESS_EVENT_VIEW WHERE PROCESS = '" + process + 
			"' AND EVENT='" + event + "' ORDER BY POSITION"; 	
	List<String[]> list = cn.queryMultiCol(qry, 7, true);
*/
	String qry = "SELECT * FROM CPAS_PROCESS_EVENT_VIEW WHERE PROCESS = '" + process + 
			"' AND EVENT='" + event + "' ORDER BY POSITION"; 	
	Query q = new Query(cn, qry, false);

	String ename = cn.queryOne("SELECT NAME FROM CPAS_PROCESS_EVENT WHERE PROCESS='" + process+"' AND EVENT='" + event + "'");
	String id = Util.getId();
%>
<b>Event View</b> - <%= ename %> [<%= process %>,<%= event %>]
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=qry%>"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= qry%></div>
<br/>

<table id="dataTable" border=1 class="gridBody">
<tr>
	<th class="headerRow">Description</th>
	<th class="headerRow">Position</th>
	<th class="headerRow">Privilege</th>
	<th class="headerRow">SDI Window</th>
	<th class="headerRow">Treeview Key</th>
	<th class="headerRow">UData</th>
</tr>


<%
	int rowCnt = 0;
	q.rewind(1000, 1);
	while (q.next() && rowCnt < 1000) {
		String descr = q.getValue("caption");
		String position = q.getValue("position");
		String seclabel = q.getValue("seclabel");
		String sdi = q.getValue("sdi");
		String tv = q.getValue("treekey");
		String udata = q.getValue("udata");

		rowCnt ++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";		
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>" nowrap><%= descr==null?"":descr %></td>
	<td class="<%= rowClass%>" nowrap><%= position %></td>
	<td class="<%= rowClass%>" nowrap><%= seclabel==null?"":seclabel %></td>
	<td class="<%= rowClass%>" nowrap><%= sdi==null?"":sdi %></td>
	<td class="<%= rowClass%>" nowrap><%= tv==null?"":tv %>
<% if (tv!=null && sdi!=null) {
	qry = "SELECT * FROM TREEACTION_STMT WHERE (sdi, actionid) in (SELECT sdi, actionid FROM TREEVIEW WHERE SDI = '" + sdi + "' AND TREEKEY='" + tv +"')";
	id = Util.getId();
%>
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=qry%>"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= qry%></div>
	
<% } %>
	</td>
	<td class="<%= rowClass%>" nowrap><%= udata==null?"":udata %></td>
</tr>
<%
	} 
%>
</table>
