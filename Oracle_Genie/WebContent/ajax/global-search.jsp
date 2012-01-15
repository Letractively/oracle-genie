<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	String keyword = request.getParameter("keyword").toUpperCase();
	Connect cn = (Connect) session.getAttribute("CN");

	if (cn==null) {
%>	
		Connection lost. Please log in again.
<%
		return;
	}
		
	String catalog = cn.getSchemaName();

	Connection conn = cn.getConnection();
%>

<h2>Search Result for "<%= keyword %>"</h2>

<b>Table:</b><br/>
<%
	Statement stmt = conn.createStatement();
	ResultSet rs = stmt.executeQuery("SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME LIKE '%" + keyword +"%' ORDER BY TABLE_NAME");

	String text = "";
	while (rs.next()) {
		text = rs.getString("TABLE_NAME");
%>
	&nbsp;&nbsp;
	<a href="javascript:loadTable('<%=text%>');"><%=text%></a><br/>
	
<%
	}
	
	rs.close();
	stmt.close();
%>

<br/>
<b>View:</b><br/>
<%
	stmt = conn.createStatement();
	rs = stmt.executeQuery("SELECT VIEW_NAME FROM USER_VIEWS WHERE VIEW_NAME LIKE '%" + keyword +"%' ORDER BY VIEW_NAME");

	text = "";
	while (rs.next()) {
		text = rs.getString("VIEW_NAME");
%>
	&nbsp;&nbsp;
	<a href="javascript:loadView('<%=text%>');"><%=text%></a><br/>
	
<%
	}
	
	rs.close();
	stmt.close();
%>

<br/>
<b>Program:</b><br/>
<%
	stmt = conn.createStatement();
	rs = stmt.executeQuery("SELECT OBJECT_NAME FROM USER_OBJECTS WHERE object_type IN ('PACKAGE','PROCEDURE','FUNCTION','TYPE') AND OBJECT_NAME LIKE '%" + keyword +"%' ORDER BY OBJECT_NAME");

	text = "";
	while (rs.next()) {
		text = rs.getString("OBJECT_NAME");
%>
	&nbsp;&nbsp;
	<a href="javascript:loadPackage('<%=text%>');"><%=text%></a><br/>
	
<%
	}
	
	rs.close();
	stmt.close();
%>

<br/>
<b>Synonym:</b><br/>
<%
	stmt = conn.createStatement();
	rs = stmt.executeQuery("SELECT OBJECT_NAME FROM USER_OBJECTS WHERE object_type='SYNONYM' AND OBJECT_NAME LIKE '%" + keyword +"%' ORDER BY OBJECT_NAME");

	text = "";
	while (rs.next()) {
		text = rs.getString("OBJECT_NAME");
%>
	&nbsp;&nbsp;
	<a href="javascript:loadSynonym('<%=text%>');"><%=text%></a><br/>
<%
	}
	
	rs.close();
	stmt.close();
%>

<br/>
<b>Column:</b><br/>
<%
	stmt = conn.createStatement();
	rs = stmt.executeQuery("SELECT * FROM USER_TAB_COLUMNS WHERE COLUMN_NAME='" + keyword +"' ORDER BY TABLE_NAME");

	text = "";
	while (rs.next()) {
		String tname = rs.getString("TABLE_NAME");
		String cname = rs.getString("COLUMN_NAME");

		String data_type = rs.getString("DATA_TYPE");
		int data_length = rs.getInt("DATA_LENGTH");
		int data_prec = rs.getInt("DATA_PRECISION");
		int data_scale = rs.getInt("DATA_SCALE");
		String dType = data_type.toLowerCase();
		
		if (dType.equals("varchar") || dType.equals("varchar2") || dType.equals("char"))
			dType += "(" + data_length + ")";
//		if (nullable==1) dType +=" not null";

		if (dType.equals("number")) {
			if (data_prec > 0 && data_scale > 0)
				dType += "(" + data_prec + "," + data_scale +")";
			else if (data_prec > 0)
				dType += "(" + data_prec + ")";
		}
%>
	&nbsp;&nbsp;
	<a href="javascript:loadTable('<%=tname%>');"><%=tname%></a>.<%= cname.toLowerCase() %> <%= dType %><br/>
	
<%
	}
	
	rs.close();
	stmt.close();
%>


<br/>
<b>Table Comments:</b><br/>
<%
	stmt = conn.createStatement();
	rs = stmt.executeQuery("SELECT * FROM USER_TAB_COMMENTS WHERE UPPER(COMMENTS) LIKE '%" + keyword +"%' ORDER BY TABLE_NAME");

	text = "";
	while (rs.next()) {
		String tname = rs.getString("TABLE_NAME");
		String comments = rs.getString("COMMENTS");
%>
	&nbsp;&nbsp;
	<a href="javascript:loadTable('<%=tname%>');"><%=tname%></a> <%= comments %><br/>
<%
	}
	
	rs.close();
	stmt.close();
%>


<br/>
<b>Column Comments:</b><br/>
<%
	stmt = conn.createStatement();
	rs = stmt.executeQuery("SELECT * FROM USER_COL_COMMENTS WHERE UPPER(COMMENTS) LIKE '%" + keyword +"%' ORDER BY TABLE_NAME");

	text = "";
	while (rs.next()) {
		String tname = rs.getString("TABLE_NAME");
		String cname = rs.getString("COLUMN_NAME");
		String comments = rs.getString("COMMENTS");
%>
	&nbsp;&nbsp;
	<a href="javascript:loadTable('<%=tname%>');"><%=tname%></a>.<%= cname %> <%= comments %><br/>
<%
	}
	
	rs.close();
	stmt.close();
%>

