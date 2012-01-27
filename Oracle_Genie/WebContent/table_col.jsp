<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	String table = request.getParameter("table");
	Connect cn = (Connect) session.getAttribute("CN");

	if (!table.startsWith("\"")) table = table.toUpperCase();
	
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
	
	String divId="div_" + table;
	divId = divId.replaceAll("\\.","-");
%>

<div id="<%= divId %>">
<a href="Javascript:copyPaste('<%=table %>');"><b><%= table %></b></a> <a href="Javascript:removeDiv('<%= divId %>')">x</a><br/>

<table border=0 width=780>
<tr>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
</tr>
<tr>
<%	

	List<TableCol> cols = cn.getTableDetail(catalog, tname);
	ArrayList<String> pk = cn.getPrimaryKeys(catalog, tname);

	for (int i=0; i<cols.size();i++) {
		TableCol col = cols.get(i);
		String colName = col.getName();
		String colDisp = col.getName().toLowerCase();
		if (pk.contains(colName)) colDisp = "<b>" + colDisp + "</b>";
/*
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
		int nullable = rs1.getInt("NULLABLE");
		
		String nulls = (nullable==1)?"N":"";
		
		String dType = data_type.toLowerCase();
		
		String colDisp = col_name.toLowerCase();
		if (dType.equals("varchar") || dType.equals("char"))
			dType += "(" + data_size + ")";
			colCnt ++;
			if (pk.contains(col_name)) colDisp = "<b>" + colDisp + "</b>";
			
		String tooltip = dType;
		String comment =  cn.getComment(tname, col_name);
		if (comment != null && comment.length() > 0) tooltip += " " + comment;
*/

%>
<td>&nbsp;<a href="Javascript:copyPaste('<%=colName%>');" title="<%= col.getTypeName() %>"><%= colDisp%></a></td>
<%
		if ((i+1)%5==0) out.println("</tr><tr>");
	}
	
//	rs1.close();
	
%>

</tr></table>
<br/>
</div>