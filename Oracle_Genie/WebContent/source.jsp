<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	import="org.apache.commons.lang3.StringEscapeUtils" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<head>
	<script src="script/jquery.js" type="text/javascript"></script>
	<script src="script/main.js" type="text/javascript"></script>
	<script type="text/javascript" src="script/shCore.js"></script>
	<script type="text/javascript" src="script/shBrushSql.js"></script>
    <link href='css/shCore.css' rel='stylesheet' type='text/css' > 
    <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css" rel="stylesheet" type="text/css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
</head>
<%
	String name = request.getParameter("name");
	String owner = request.getParameter("owner");
	
	Connect cn = (Connect) session.getAttribute("CN");
		
	String catalog = cn.getSchemaName();

	String qry = "SELECT TEXT FROM USER_SOURCE WHERE NAME='" + name +"' ORDER BY TYPE, LINE";
	if (owner != null) qry = "SELECT TEXT FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' ORDER BY TYPE, LINE";

	List<String> list = cn.queryMulti(qry);
	
	String text = "";
	for (int i=0;i<list.size();i++) {
		text += Util.escapeHtml(list.get(i));
	}
%>
<h2><%= name %></h2>

<pre class='brush: sql'>
<%= text %>
</pre>

<a href="javascript:window.close()"><img src="image/exit.png" title="Exit" border=0></a>

<script type="text/javascript">
$(document).ready(function(){
     SyntaxHighlighter.all();
})
</script>

