<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	String view = request.getParameter("view");
	String owner = request.getParameter("owner");
	
	Connect cn = (Connect) session.getAttribute("CN");

	if (cn==null) {
%>	
		Connection lost. Please log in again.
<%
		return;
	}


	// incase owner is null & table has owner info
	if (owner==null && view!=null && view.indexOf(".")>0) {
		int idx = view.indexOf(".");
		owner = view.substring(0, idx);
		view = view.substring(idx+1);
	}
	
	String catalog = cn.getSchemaName();

	Connection conn = cn.getConnection();

	Statement stmt = conn.createStatement();
	String qry = "SELECT * FROM USER_VIEWS WHERE VIEW_NAME='" + view +"'";
	if (owner != null) 
		qry = "SELECT * FROM ALL_VIEWS WHERE OWNER='" + owner + "' AND VIEW_NAME='" + view +"'"; 
	ResultSet rs = stmt.executeQuery(qry);

	String text = "";
	if (rs.next()) {
		text = rs.getString("TEXT");
	}
	
	rs.close();
	stmt.close();
	

%>
<h2>VIEW: <%= view %> &nbsp;&nbsp;<a href="Javascript:runQuery('<%=catalog%>','<%=view%>')"><img border=0 src="image/icon_query.png" title="query"></a></h2>

Definition: 
<pre class='brush: sql'>
<%= text %>
</pre>

Related Table: <br/>

<%
	stmt = conn.createStatement();
	qry = "SELECT * FROM USER_DEPENDENCIES WHERE NAME='" + view +"' AND REFERENCED_TYPE='TABLE' ORDER BY REFERENCED_NAME";
	if (owner != null)
		qry = "SELECT * FROM ALL_DEPENDENCIES WHERE OWNER='" + owner + "' AND NAME='" + view +"' AND REFERENCED_TYPE='TABLE' ORDER BY REFERENCED_NAME";

	rs = stmt.executeQuery(qry);

	text = "";
	while (rs.next()) {
		String tname = rs.getString("REFERENCED_NAME");
		String rOwner = rs.getString("REFERENCED_OWNER");
		
		if(!rOwner.equalsIgnoreCase(cn.getSchemaName()))
			tname = rOwner + "." + tname;
%>
	&nbsp;&nbsp;
	<a href="javascript:loadTable('<%=tname%>');"><%=tname%></a><br/>
<%
	}
	
	rs.close();
	stmt.close();
%>


<br/>
Related Package: <br/>
<%
	stmt = conn.createStatement();
	qry = "SELECT * FROM USER_DEPENDENCIES WHERE NAME='" + view +"' AND REFERENCED_TYPE='PACKAGE' ORDER BY REFERENCED_NAME";
	if (owner != null)
		qry = "SELECT * FROM ALL_DEPENDENCIES WHERE OWNER = '" + owner + "' AND NAME='" + view +"' AND REFERENCED_TYPE='PACKAGE' ORDER BY REFERENCED_NAME";

	rs = stmt.executeQuery(qry);

	text = "";
	while (rs.next()) {
		String tname = rs.getString("REFERENCED_NAME");
		String rOwner = rs.getString("REFERENCED_OWNER");
%>
	&nbsp;&nbsp;
	<a href="javascript:loadPackage('<%=tname%>');"><%=tname%></a><br/>
<%
	}
	
	rs.close();
	stmt.close();
%>

