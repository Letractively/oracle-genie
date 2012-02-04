<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.Connect" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	if (cn!=null) {
		try {
			cn.disconnect();
		} catch (Exception e) {}
	}
	
	session.removeAttribute("CN");
%>

<html>
  <head>
    <title>Genie</title>
    <link rel='stylesheet' type='text/css' href='css/style.css'> 
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
  </head>

 <img src="image/genie2.jpg"/>

<h2>Disconnected. Good Bye!</h2>

<br/>
<a href="index.jsp">Home</a>

</html>