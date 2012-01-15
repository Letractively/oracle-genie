<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.Connect" 
	pageEncoding="ISO-8859-1"
%>

<%
	String table = request.getParameter("table");
	Connect cn = (Connect) session.getAttribute("CN");

	if (cn==null) {
%>	
		Connection lost. Please log in again.
<%
		return;
	}
		
	Connection conn = cn.getConnection();

	String catalog = null;
	String tname = table;
	
	int idx = table.indexOf(".");
	if (idx>0) {
		catalog = table.substring(0, idx);
		tname = table.substring(idx+1);
	}
	
	if (catalog==null) catalog = cn.getSchemaName();
	
	if (table==null) { 
%>

Please select a Table to see the detail.

<%
		return;
	}
	
	String divId="div2_" + table;
	divId = divId.replaceAll("\\.","-");
%>

<div id="<%= divId %>">
<a href="Javascript:copyPaste('<%=table %>');"><b><%= table %></b></a><br/>

<table border=0 width=620>
<tr>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
</tr>
<tr>
<%	
	DatabaseMetaData dbm = conn.getMetaData();
	ResultSet rs1 = dbm.getColumns(catalog,"%",tname,"%");

	// primary key
	ArrayList<String> pk = cn.getPrimaryKeys(catalog, tname);

	//System.out.println("Detail for " + table);
	int colCnt = 0;
	while (rs1.next()){
		String col_name = rs1.getString("COLUMN_NAME");
		String data_type = rs1.getString("TYPE_NAME");
		int data_size = rs1.getInt("COLUMN_SIZE");
		int decimal_digits = rs1.getInt("DECIMAL_DIGITS");
		int nullable = rs1.getInt("NULLABLE");
		
		String nulls = (nullable==1)?"N":"";
		
		String dType = data_type.toLowerCase();
		
		String colDisp = col_name.toLowerCase();
		if (dType.equals("varchar") || dType.equals("varchar2") || dType.equals("char"))
			dType += "(" + data_size + ")";
		if (dType.equals("number")) {
			if (data_size > 0 && decimal_digits > 0)
				dType += "(" + data_size + "," + decimal_digits +")";
			else if (data_size > 0)
				dType += "(" + data_size + ")";
		}
		
		colCnt ++;
		if (pk.contains(col_name)) colDisp = "<b>" + colDisp + "</b>";
			
		String tooltip = dType;
%>
<td>&nbsp;<a href="Javascript:copyPaste('<%=col_name.toLowerCase()%>');" title="<%= tooltip %>"><%= colDisp %></a></td>
<%
		if (colCnt%5==0) out.println("</tr><tr>");
	}
	
	rs1.close();
	
%>

</tr></table>
<br/>
</div>