<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");

	String table = "MEMBER";
	String key = request.getParameter("mkey");
	if (key==null) key="";

	String sql = "SELECT * FROM MEMBER WHERE MKEY='" + key +"'";

	Query q = new Query(cn, sql);
	
%>

<html>
<head> 
	<title>Genie - CPAS Member</title>
    <script src="script/jquery.js" type="text/javascript"></script>
    <script src="script/data-link.js" type="text/javascript"></script>

    <script src="script/jquery.colorbox-min.js"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
    <link rel="stylesheet" href="css/colorbox.css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.17/themes/base/jquery-ui.css" type="text/css" media="all" />
	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.17/jquery-ui.min.js" type="text/javascript"></script>
    
</head> 

<body>
<%
	String id = Util.getId();
%>

<img src="image/data-link.png" align="middle"/>
<%= cn.getUrlString() %>

<br/>

<a href="Javascript:hideNullColumn()">Hide Null</a>
&nbsp;&nbsp;
<a href="Javascript:showAllColumn()">Show All</a>
&nbsp;&nbsp;
<br/><br/>

<form method="get">
MKEY=<input name="mkey" value="<%=key%>"><input type="submit">
</form>

<% 
	if (key==null || key.equals("")) {
		return;
	}	
%>

<%
	id = Util.getId();
	sql = "SELECT * FROM PERSON WHERE PERSONID IN (SELECT PERSONID FROM MEMBER WHERE MKEY='"+key+"')";
%>
<b style="margin-left:20px;"><%= "PERSON" %></b>
<a href="Javascript:toggleDiv('img-<%= id %>','div-<%= id %>')"><img id="img-<%= id %>" border=0 src="image/minus.gif"></a>
<div id="div-<%= id %>" style="margin-left:20px;">
<jsp:include page="ajax/qry-simple.jsp">
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>
<br/>

<%
	id = Util.getId();
	sql = "SELECT * FROM CLIENT WHERE CLNT IN (SELECT CLNT FROM MEMBER WHERE MKEY='"+key+"')";
%>
<b style="margin-left:20px;"><%= "CLIENT" %></b>
<a href="Javascript:toggleDiv('img-<%= id %>','div-<%= id %>')"><img id="img-<%= id %>" border=0 src="image/minus.gif"></a>
<div id="div-<%= id %>" style="margin-left:20px;">
<jsp:include page="ajax/qry-simple.jsp">
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>
<br/>



<%
	id = Util.getId();
%>
<b><%= table %></b>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 title="<%=sql%>"/></a>
<%-- <%= sql %> --%>
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="mode-<%=id%>">hide</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<br/>
<div id="data-div" style1="padding: 5px; background-color: gray;">
<jsp:include page="ajax/qry-simple.jsp">
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="0" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
	<jsp:param value="1" name="main" />
</jsp:include>
</div>
<br/>


<%
	id = Util.getId();
	sql = "SELECT * FROM PLAN WHERE PLAN IN (SELECT PLAN FROM MEMBER_PLAN WHERE MKEY='" + key + "')";
%>
<b style="margin-left:20px;"><%= "PLAN" %></b>
<a href="Javascript:toggleDiv('img-<%= id %>','div-<%= id %>')"><img id="img-<%= id %>" border=0 src="image/minus.gif"></a>
<div id="div-<%= id %>" style="margin-left:20px;">
<jsp:include page="ajax/qry-simple.jsp">
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>
<br/>




<%
	id = Util.getId();
	sql = "SELECT * FROM ACCOUNT WHERE ACCOUNTID IN (SELECT ACCOUNTID FROM MEMBER_PLAN_ACCOUNT WHERE MKEY='"+key+"')";
%>
<b style="margin-left:20px;"><%= "ACCOUNT" %></b>
<a href="Javascript:toggleDiv('img-<%= id %>','div-<%= id %>')"><img id="img-<%= id %>" border=0 src="image/minus.gif"></a>
<div id="div-<%= id %>" style="margin-left:20px;">
<jsp:include page="ajax/qry-simple.jsp">
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>
<br/>


<%
	id = Util.getId();
	List<String> autoLoadChild = new ArrayList<String>();
	autoLoadChild.add(id);
	sql = "SELECT * FROM ACCOUNT_FUND WHERE ACCOUNTID IN (SELECT ACCOUNTID FROM MEMBER_PLAN_ACCOUNT WHERE MKEY='"+key+"')"; 
%>
<b style="margin-left:20px;"><%= "ACCOUNT_FUND" %></b>
<a href="Javascript:toggleDiv('img-<%= id %>','div-<%= id %>')"><img id="img-<%= id %>" border=0 src="image/plus.gif"></a>

<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="display: none;" id="sort-<%=id%>"></div>
<div style="display: none;" id="sortdir-<%=id%>">0</div>
<div style="display: none;" id="mode-<%=id%>">sort</div>

<div id="div-<%=id%>" style="margin-left: 20px; display: none;"></div>
<br/>



<%
	id = Util.getId();
	autoLoadChild.add(id);
	sql = "SELECT * FROM ACCOUNT_FUND_TRANS WHERE ACCOUNTID IN (SELECT ACCOUNTID FROM MEMBER_PLAN_ACCOUNT WHERE MKEY='"+key+"')"; 
%>
<b style="margin-left:20px;"><%= "ACCOUNT_FUND_TRANS" %></b>
<a href="Javascript:toggleDiv('img-<%= id %>','div-<%= id %>')"><img id="img-<%= id %>" border=0 src="image/plus.gif"></a>
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="display: none;" id="sort-<%=id%>"></div>
<div style="display: none;" id="sortdir-<%=id%>">0</div>
<div style="display: none;" id="mode-<%=id%>">sort</div>

<div id="div-<%=id%>" style="margin-left: 20px; display: none;"></div>
<br/>


<br/><br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

<script type="text/javascript">
$(document).ready(function() {
<%	
	for (String id1: autoLoadChild) {
%>
		loadData(<%=id1%>,0);
<%
	}
%>
});	
</script>


<div style="display: none;">
<form name="form0" id="form0" action="query.jsp">
<input id="sql" name="sql" type="hidden" value=""/>
<input id="dataLink" name="dataLink" type="hidden" value="1"/>
<input id="id" name="id" type="hidden" value=""/>
<input id="showFK" name="showFK" type="hidden" value="0"/>
<input type="hidden" id="sortColumn" name="sortColumn" value="">
<input type="hidden" id="sortDirection" name="sortDirection" value="0">
<input type="hidden" id="hideColumn" name="hideColumn" value="">
<input type="hidden" id="filterColumn" name="filterColumn" value="">
<input type="hidden" id="filterValue" name="filterValue" value="">
<input type="hidden" id="searchValue" name="searchValue" value="">
<input type="hidden" id="pageNo" name="pageNo" value="1">
<input type="hidden" id="rowsPerPage" name="rowsPerPage" value="20">
</form>
</div>


</body>
</html>

