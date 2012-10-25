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
	
	String qry1 = "SELECT * FROM CPAS_PROCESS WHERE PROCESS = '" + process + "'";
	Query q1 = new Query(cn, qry1, false);
	
	String qry0 = "SELECT * FROM CPAS_PROCESS_EVENT WHERE PROCESS = '" + process + "' AND EVENT = '" + event + "'"; 
	
	Query q0 = new Query(cn, qry0, false);
	
	String defaultSdi = null;
	String defaultActionId = null;
	String defaultTv = null;;	
	
	String pname = cn.queryOne("SELECT NAME FROM CPAS_PROCESS WHERE PROCESS='" + process+"'");
	String id = Util.getId();
%>

<b>Process</b>
<br/>
<table id="dataTable" border=1 class="gridBody">
<tr>
	<th class="headerRow">Process Name</th>
	<th class="headerRow">Process</th>
	<th class="headerRow">Description</th>
	<th class="headerRow">Privilege</th>
</tr>
<%
	int rowCnt = 0;

	q1.rewind(1000, 1);
	while (q1.next() && rowCnt < 1000) {
		String name = q1.getValue("NAME");
		String descr = q1.getValue("DESCR");
		String seclabel = q1.getValue("SECLABEL");
		String logflag = q1.getValue("LOGFLAG");
		String rkey = q1.getValue("RKEY");

		rowCnt ++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";
		
		String secName = cn.queryOne("SELECT CAPTION FROM SECSWITCH WHERE LABEL ='" + seclabel + "'");
%>

<tr class="simplehighlight">
	<td class="<%= rowClass%>" nowrap><%= name %></td>
	<td class="<%= rowClass%>" nowrap><%= process==null?"":process %></td>
	<td class="<%= rowClass%>" nowrap><%= descr==null?"":descr %></td>
	<td class="<%= rowClass%>" nowrap><%= seclabel==null?"":seclabel  + " <span class='cpas'>" + secName + "</span>"%></td>
 </tr>
<%
	} 
%>
</table>

<br/> 


<b>Event</b>
<table id="dataTable" border=1 class="gridBody">
<tr>
	<th class="headerRow">Event Name</th>
	<th class="headerRow">Event</th>
	<th class="headerRow">PEvent</th>
	<th class="headerRow">Position</th>
	<th class="headerRow">Action</th>
	<th class="headerRow">Privilege</th>
	<th class="headerRow">Uparam</th>
<!--
 	<th class="headerRow">Log</th>
	<th class="headerRow">RKey</th>
 -->
 </tr>

<%
	rowCnt = 0;
	q0.rewind(1000, 1);
	while (q0.next() && rowCnt < 1000) {
//		String event = q.getValue("event");
		String pevent = q0.getValue("pevent");
		String name = q0.getValue("name");
		String position = q0.getValue("position");
		String action = q0.getValue("action");
		String uparam = q0.getValue("uparam");
		String seclabel = q0.getValue("seclabel");
		String log = q0.getValue("log");
		String rkey = q0.getValue("rkey");

		rowCnt ++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";		
		String actionName = cn.queryOne("SELECT NAME FROM CPAS_ACTION WHERE ACTION ='" + action + "'");
		String secName = cn.queryOne("SELECT CAPTION FROM SECSWITCH WHERE LABEL ='" + seclabel + "'");
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>" nowrap><%= pevent==null?"":"&nbsp;&nbsp;&nbsp;&nbsp;" %><%= name %></td>
	<td class="<%= rowClass%>" nowrap><%= event==null?"":event %></td>
	<td class="<%= rowClass%>" nowrap><%= pevent==null?"":pevent %></td>
	<td class="<%= rowClass%>" nowrap><%= position==null?"":position %></td>
	<td class="<%= rowClass%>" nowrap><%= action==null?"":action + " <span class='cpas'>" + actionName + "</span>"%></td>
	<td class="<%= rowClass%>" nowrap><%= seclabel==null?"":seclabel + " <span class='cpas'>" + secName + "</span>"%></td>
	<td class="<%= rowClass%>" nowrap><%= uparam==null?"":uparam %></td>
<%--
 	<td class="<%= rowClass%>" nowrap><%= log==null?"":log %></td>
	<td class="<%= rowClass%>" nowrap><%= rkey==null?"":rkey %></td>
 --%>
</tr>
<%
	} 
%>
</table>




<%
	String qry = "SELECT * FROM CPAS_PROCESS_EVENT_VIEW WHERE PROCESS = '" + process + 
			"' AND EVENT='" + event + "' AND SECLABEL != 'SC_NEVER' ORDER BY POSITION"; 	
	Query q = new Query(cn, qry, false);

	String ename = cn.queryOne("SELECT NAME FROM CPAS_PROCESS_EVENT WHERE PROCESS='" + process+"' AND EVENT='" + event + "'");
	id = Util.getId();
%>

<br/>

<b>Event View</b> - <%= ename %> [<%= process %>,<%= event %>]
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=qry%>"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= qry%></div>
<br/>

<table id="dataTable" border=1 class="gridBody">
<tr>
	<th rowspan=2 class="headerRow">Description</th>
	<th rowspan=2 class="headerRow">Position</th>
	<th rowspan=2 class="headerRow">SDI,Treeview Key</th>
	<th rowspan=2 class="headerRow">UData</th>
	<th rowspan=2 class="headerRow">Read</th>
	<th class="headerRow" colspan="3">Upper Browser</th>
	<th class="headerRow" colspan="3">Lower Browser</th>
</tr>
<tr>
	<th class="headerRow">Add</th>
	<th class="headerRow">Upd</th>
	<th class="headerRow">Del</th>
	<th class="headerRow">Add</th>
	<th class="headerRow">Upd</th>
	<th class="headerRow">Del</th>
</tr>


<%
	rowCnt = 0;
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
		
		String actionId = cn.queryOne("SELECT actionid FROM TREEVIEW WHERE SDI = '" + sdi + "' AND TREEKEY='" + tv +"'");
		String secName = cn.queryOne("SELECT CAPTION FROM SECSWITCH WHERE LABEL ='" + seclabel + "'");
		String sdiName = cn.queryOne("SELECT NAME FROM CPAS_SDI WHERE SDI ='" + sdi + "'");

		if (defaultActionId==null && actionId != null /*position.equals("0")*/) {
			defaultSdi = sdi;
			defaultActionId = actionId;
			defaultTv = tv;;	
		}
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>" nowrap>
	<% if (actionId==null) { %>
		<%= descr==null?"":descr %>
	<% } else { %>
		<a href="javascript:loadSTMT('<%= sdi %>', <%= actionId %>, '<%= tv %>')"><%= descr==null?"":descr %></a>
	<% } %>
	</td>
	<td class="<%= rowClass%>" nowrap><%= position %></td>
<%-- 	<td class="<%= rowClass%>" nowrap><%= sdi==null?"":sdi /* + " <span class='cpas'>" + sdiName + "</span>" */%></td>
 --%>
 	<td class="<%= rowClass%>" nowrap><%= sdi==null?"":"[" + sdi +"] "%><%= tv==null?"":tv %>
<%
String read = "";
String uadd = "";
String uupd = "";
String udel = "";
String ladd = "";
String lupd = "";
String ldel = "";

//cn.queryOne("SELECT actionstmt")
if (tv!=null && sdi!=null && actionId != null) {
	
	qry = "SELECT * FROM TREEACTION_STMT WHERE (sdi, actionid) in (SELECT sdi, actionid FROM TREEVIEW WHERE SDI = '" + sdi + "' AND TREEKEY='" + tv +"')";
	id = Util.getId();

	read = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE sdi='"+sdi+"' AND actionid="+actionId+" AND actiontype='AW'");
	uadd = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE sdi='"+sdi+"' AND actionid="+actionId+" AND actiontype='MN'");
	uupd = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE sdi='"+sdi+"' AND actionid="+actionId+" AND actiontype='ME'");
	udel = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE sdi='"+sdi+"' AND actionid="+actionId+" AND actiontype='MR'");

	ladd = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE sdi='"+sdi+"' AND actionid="+actionId+" AND actiontype='DN'");
	lupd = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE sdi='"+sdi+"' AND actionid="+actionId+" AND actiontype='DE'");
	ldel = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE sdi='"+sdi+"' AND actionid="+actionId+" AND actiontype='DR'");
	
	read = read==null?"":read;
	uadd = uadd==null?"":uadd;
	uupd = uupd==null?"":uupd;
	udel = udel==null?"":udel;
	ladd = ladd==null?"":ladd;
	lupd = lupd==null?"":lupd;
	ldel = ldel==null?"":ldel;
%>
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=qry%>"/></a>
<%-- 
<br/>
<a href="javascript:openSimul('<%=sdi%>','<%=tv%>')">Simulator</a>
<a href="cpas-treeview.jsp?sdi=<%= sdi %>&treekey=<%= tv %>" target="_blank">Treeview</a>
 --%>
<div style="display: none;" id="sql-<%=id%>"><%= qry%></div>
	
<% } %>
	</td>
	<td class="<%= rowClass%>" nowrap><%= udata==null?"":udata %></td>
	<td class="<%= rowClass%>" nowrap><%= read %></td>
	<td class="<%= rowClass%>" nowrap><%= uadd %></td>
	<td class="<%= rowClass%>" nowrap><%= uupd %></td>
	<td class="<%= rowClass%>" nowrap><%= udel %></td>
	<td class="<%= rowClass%>" nowrap><%= ladd %></td>
	<td class="<%= rowClass%>" nowrap><%= lupd %></td>
	<td class="<%= rowClass%>" nowrap><%= ldel %></td>
</tr>
<%
	} 
%>
</table>

<br/>
<div id="inner-tvstmt"></div>

<script type="text/javascript">
<% if (defaultActionId != null) { %>
	loadSTMT('<%= defaultSdi %>', <%= defaultActionId %>, '<%= defaultTv %>');
<% } %>
</script>