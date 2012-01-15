<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	Connection conn = cn.getConnection();
	
	HashMap<String, QueryLog> map = cn.getQueryHistory();
	
%>

<html>
<head> 
	<title>Genie</title>
    <link rel='stylesheet' type='text/css' href='css/style.css'> 
    <script src="script/jquery.js" type="text/javascript"></script>
	<script src="script/main.js" type="text/javascript"></script>
	<style>
		tr.even {  background-color: #e0e0ff; }
		tr.odd {  background-color: #eeeeee;}	
	</style>

<script language="Javascript">
	$(document).ready(function() {
		$('table.striped tbody tr:odd').addClass('odd');
		$('table.striped tbody tr:even').addClass('even');
	});
	
	function run(divName) {
		var qry = $("#" + divName).html();
		$("#sql").val(qry);
		//alert(qry);
		$("#form1").submit();
		//document.forms["form1"].submit();
		
		
	}	
</script>
	
</head>
<body>

<table>
<td><br><img src="image/small-genie.gif"/></td>
<td><%= cn.getUrlString() %> Database: <%= cn.getSchemaName() %></td>
</table>

<table id="dataTable" class="striped" border=0 width=800>
<th>Run</th>
<th>Query</th>
<th>Time</th>
</td>

<%
	Iterator iterator = map.values().iterator();
	int idx = 0;
	while  (iterator.hasNext()) {
		idx ++;
		QueryLog ql = (QueryLog) iterator.next();
		String divName ="QRY-" + idx;
%>
	<tr>
		<td><a href="Javascript:run('<%= divName %>')">run</a></td>
		<td><div id="<%= divName %>"><%= ql.getQueryString() %></div></td>
		<td><%= ql.getTime() %></td>
	</tr>
<%
	}
 %>

</table>

<form id="form1" name="form1" target=_blank action="query.jsp" method="post">
<input id="sql" name="sql" type="hidden" value="select * from tab"/>
</form>

<br/><br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

</body>
</html>