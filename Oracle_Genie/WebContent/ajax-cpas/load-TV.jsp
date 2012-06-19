<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String sdi = request.getParameter("sdi");
	String parentid = request.getParameter("parentid");
	if (parentid==null || parentid.equals("")) parentid = "1";
%>

<% if (parentid.equals("1")) {
	String qry = "SELECT NAME FROM CPAS_SDI WHERE SDI='" + sdi +"'"; 	
	String name = cn.queryOne(qry);
	
	String sql = "SELECT * FROM TREEVIEW WHERE SDI='" + sdi + "'";
	String id = Util.getId();
%>
<b><%= name %></b>
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=sql%>"/></a>
<a href="Javascript:openAll();">Open All</a>
<a href="Javascript:closeAll();">Close All</a>
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>

<br/><br/>
<% } %>

<%
	
	String qry = "SELECT caption, treekey, actionid, sortorder, itemid, parentid, image, (select count(*) from TREEVIEW where sdi=A.sdi and parentid=A.itemid) as cnt " +
		"FROM TREEVIEW A WHERE SDI = '" + sdi + 
		"' and parentid=" + parentid + " order by sortorder";
	List<String[]> list = cn.query(qry);

	int totalCnt = list.size();
%>

<%
	for (int i=0; i<list.size();i++) {
		String itemid = list.get(i)[5];
		String childCnt = list.get(i)[8];
		String tv = list.get(i)[2];
%>
<a href="javaScript:toggleChild('<%=sdi%>', <%= itemid %>)">
<% if (childCnt.equals("0")) { %>
	<span style="margin-left: 19px;"></span>
<% } else { %>
	<img id="img-<%=itemid%>" src="image/plus.gif" class="toggle"></a>
<% } %>
<a href="javascript:loadSTMT('<%= sdi %>', <%=list.get(i)[3]%>, '<%= tv %>');"><%=Util.escapeHtml(list.get(i)[1])%></a><br/>
<div id="div-<%=sdi%>-<%=itemid%>" style="margin-left: 20px; display:none;"></div>
<% 
	} 
%>
