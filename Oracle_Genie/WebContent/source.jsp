<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	import="org.apache.commons.lang3.StringEscapeUtils" 
	pageEncoding="ISO-8859-1"
%>

<head>
	<script src="script/jquery.js" type="text/javascript"></script>
	<script src="script/main.js" type="text/javascript"></script>
	<script type="text/javascript" src="script/shCore.js"></script>
	<script type="text/javascript" src="script/shBrushSql.js"></script>
    <link href='css/shCore.css' rel='stylesheet' type='text/css' > 
    <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css" rel="stylesheet" type="text/css" />

</head>
<%
	String name = request.getParameter("name");
	String owner = request.getParameter("owner");
	
	Connect cn = (Connect) session.getAttribute("CN");

	if (cn==null) {
%>	
		Connection lost. Please log in again.
<%
		return;
	}
		
	String catalog = cn.getSchemaName();

	Connection conn = cn.getConnection();

	Statement stmt = conn.createStatement();
	String qry = "SELECT * FROM USER_SOURCE WHERE NAME='" + name +"' ORDER BY TYPE, LINE";
	if (owner != null) qry = "SELECT * FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' ORDER BY TYPE, LINE";
	ResultSet rs = stmt.executeQuery(qry);

	String text = "";
	while (rs.next()) {
		String line = rs.getString("TEXT");
		text += Util.escapeHtml(line);
	}
	
	rs.close();
	stmt.close();
	
%>
<h2><%= name %></h2>


<pre class='brush: sql'>
<%= text %>
</pre>

<a href="javascript:window.close()">Close</a>

<script type="text/javascript">
$(document).ready(function(){
     SyntaxHighlighter.all();
})
</script>

