<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	if (cn==null) {
%>	
		Connection lost. Please log in again.
<%
		return;
	}

	String table = request.getParameter("table");
	String owner = request.getParameter("owner");
	
	// incase owner is null & table has owner info
	if (owner==null && table!=null && table.indexOf(".")>0) {
		int idx = table.indexOf(".");
		owner = table.substring(0, idx);
		table = table.substring(idx+1);
	}
	
	System.out.println("owner=" + owner);
	
	Connection conn = cn.getConnection();

	String catalog = null;
	String tname = table;
	int idx = table.indexOf(".");
	if (idx>0) {
		catalog = table.substring(0, idx);
		tname = table.substring(idx+1);
	}
	if (catalog==null) catalog = cn.getSchemaName();
	
	String formName = "FORM_" + tname;
	String divName = "DIV_" + tname;
	if (table==null) { 
%>

Please select a Table to see the detail.

<%
		return;
	}
	
%>

<h2>TABLE: <%= table %> &nbsp;&nbsp;<a href="Javascript:runQuery('','<%=tname%>')"><img border=0 src="image/icon_query.png" title="query"></a>
</h2>

<%= owner==null?cn.getComment(tname):cn.getSynTableComment(owner, tname) %><br/>

<div id="<%= divName %>">
<form id="<%= formName %>">
<input name="table" type="hidden" value="<%= table %>"/>
<input name="query" type="hidden" value=""/>
<table id="TABLE_<%=tname%>" width=640 border=0>
<tr>
	<th></th>
	<th bgcolor=#ccccff>Column Name</th>
	<th bgcolor=#ccccff>Type</th>
	<th bgcolor=#ccccff>Null</th>
	<th bgcolor=#ccccff>Default</th>
	<th bgcolor=#ccccff>Comments</th>
</tr>

<%	

	DatabaseMetaData dbm = conn.getMetaData();
	ResultSet rs1 = dbm.getColumns(catalog,"%",tname,"%");

	// primary key
	ArrayList<String> pk = cn.getPrimaryKeys(catalog, tname);
	
	//System.out.println("Detail for " + table);
	while (rs1.next()){
		String col_name = rs1.getString("COLUMN_NAME");
		String data_type = rs1.getString("TYPE_NAME");
		int data_size = rs1.getInt("COLUMN_SIZE");
		int decimal_digits = rs1.getInt("DECIMAL_DIGITS");
		int nullable = rs1.getInt("NULLABLE");
		
		String nulls = (nullable==1)?"":"N";
		String colDef = rs1.getString("COLUMN_DEF");
		if (colDef==null) colDef="";
		
		String dType = data_type.toLowerCase();
		
		if (dType.equals("varchar") || dType.equals("varchar2") || dType.equals("char"))
			dType += "(" + data_size + ")";
//		if (nullable==1) dType +=" not null";

		if (dType.equals("number")) {
			if (data_size > 0 && decimal_digits > 0)
				dType += "(" + data_size + "," + decimal_digits +")";
			else if (data_size > 0)
				dType += "(" + data_size + ")";
		}
		
		// check if primary key
		String col_disp = col_name;
		if (pk.contains(col_name)) col_disp = "<font color=blue><b>" + col_disp + "</b></font>";
%>
<tr>
	<td>&nbsp;</td>
	<td><%= col_disp.toLowerCase() %></td>
	<td><%= dType %></td>
	<td><%= nulls %></td>
	<td><%= colDef %></td>
	<td><%= owner==null?cn.getComment(tname, col_name):cn.getSynColumnComment(owner, tname, col_name) %></td>
</tr>

<%
	}
	
	rs1.close();
	
%>
</table>
</form>


<%
	String pkName = cn.getPrimaryKeyName(tname);
	if (pkName == null && owner != null) pkName = cn.getPrimaryKeyName(owner, tname);

	String pkCols = cn.getConstraintCols(pkName);
	if (pkName != null && pkCols.equals(""))
		pkCols = cn.getConstraintCols(owner, pkName);
	
	List<ForeignKey> fks = cn.getForeignKeys(tname);
	if (owner != null) fks = cn.getForeignKeys(owner, tname);
	
	List<String> refTabs = cn.getReferencedTables(owner, tname);
	List<String> refPkgs = cn.getReferencedPackages(tname);
	List<String> refViews = cn.getReferencedViews(tname);
	List<String> refTrgs = cn.getReferencedTriggers(tname);
	List<String> refIdx = cn.getIndexes(owner, tname);
%>

<% if (pkName != null)  {%>
Primary Key:<br/>
&nbsp;&nbsp;&nbsp;&nbsp;<%= pkName %> (<%= pkCols.toLowerCase() %>) 

<br/><br/>
<% } %>


<% 
	if (fks.size()>0) { 
%>
Foreign Key:<br/>
<%

	for (int i=0; i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String rTable = cn.getTableNameByPrimaryKey(rec.rConstraintName);
		boolean tabLink = true;
		if (rTable == null) {
//			rTable = rec.rOwner + "." + rec.rConstraintName;

			rTable = cn.getTableNameByPrimaryKey(rec.rOwner, rec.rConstraintName);
			
//			rTable = rec.rOwner + "." + rec.tableName;
			tabLink = false;
			tabLink = true;
		}
%>
&nbsp;&nbsp;&nbsp;&nbsp;<%= rec.constraintName %>
	(<%= cn.getConstraintCols(rec.owner, rec.constraintName).toLowerCase() %>)
	->
<%
	if (tabLink) {
%>
	<a href="Javascript:loadTable('<%= rTable %>')"><%= rTable %></a>
<%
	} else {
%>	
	<%= rTable %>
<%
	}
%>
	(<%= cn.getConstraintCols(rec.rOwner, rec.rConstraintName).toLowerCase() %>)
	<br/>
<%
 }
%>
	<br/>
<%
} 
%>



<% 
	if (refIdx.size()>0) { 
%>
Index:<br/>
<%

	for (int i=0; i<refIdx.size(); i++) {
		String indexName = refIdx.get(i);
%>
	&nbsp;&nbsp;&nbsp;&nbsp;<%= indexName %> 
	<%= cn.getIndexColumns(owner, indexName).toLowerCase() %>
	<br/>
<%
	}
%>
<br/>
<%
}
%>


<% 
	if (refTabs.size()>0) { 
%>
Related Table:
<table border=0>
<td width=10>&nbsp;</td>
<td valign=top>
<%
	int listSize = (refTabs.size() / 3) + 1;
	int cnt = 0;
	for (int i=0; i<refTabs.size(); i++) {
		String refTab = refTabs.get(i);
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top>
<%
		cnt = 1;
	} 
%>

		<a href="Javascript:loadTable('<%= refTab %>')"><%= refTab %></a>&nbsp;&nbsp;<br/>		
<% }
%>
</td>
</table>
<% }
%>


<br/>
<% 
	if (refPkgs.size()>0) { 
%>
Related Program:
<table border=0>
<td width=10>&nbsp;</td>
<td valign=top>
<%
	int listSize = (refPkgs.size() / 3) + 1;
	int cnt = 0;
	for (int i=0; i<refPkgs.size(); i++) {
		String refPkg = refPkgs.get(i);
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top>
<%
		cnt = 1;
	} 
%>

		<a href="Javascript:loadPackage('<%= refPkg %>')"><%= refPkg %></a>&nbsp;&nbsp;<br/>		
<% }
%>
</td>
</table>

<%
}
%>

<br/>
<% 
	if (refViews.size()>0) { 
%>
Related View:
<table border=0>
<td width=10>&nbsp;</td>
<td valign=top>
<%
	int listSize = (refViews.size() / 3) + 1;
	int cnt = 0;
	for (int i=0; i<refViews.size(); i++) {
		String refView = refViews.get(i);
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top>
<%
		cnt = 1;
	} 
%>

		<a href="Javascript:loadView('<%= refView %>')"><%= refView %></a>&nbsp;&nbsp;<br/>		
<% }
%>
</td>
</table>
<%
	}
%>



<br/>
<% 
	if (refTrgs.size()>0) { 
%>
Related Trigger:
<table border=0>
<td width=10>&nbsp;</td>
<td valign=top>
<%
	int listSize = (refTrgs.size() / 3) + 1;
	int cnt = 0;
	for (int i=0; i<refTrgs.size(); i++) {
		String refTrg = refTrgs.get(i);
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top>
<%
		cnt = 1;
	} 
%>

		<a href="Javascript:loadPackage('<%= refTrg %>')"><%= refTrg %></a>&nbsp;&nbsp;<br/>		
<% }
}
%>
</td>
</table>

</div>