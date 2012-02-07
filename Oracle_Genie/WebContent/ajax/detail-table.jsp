<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String table = request.getParameter("table");
	String owner = request.getParameter("owner");
	
	// incase owner is null & table has owner info
	if (owner==null && table!=null && table.indexOf(".")>0) {
		int idx = table.indexOf(".");
		owner = table.substring(0, idx);
		table = table.substring(idx+1);
	}
	
	System.out.println("owner=" + owner);
	
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
	<th bgcolor=#ccccff>Remarks</th>
</tr>

<%	
	List<TableCol> list = cn.getTableDetail(owner, tname);
	for (int i=0;i<list.size();i++) {
		TableCol rec = list.get(i);
		
		// check if primary key
		String col_disp = rec.getName();
		if (rec.isPrimaryKey()) col_disp = "<span class='primary-key'>" + col_disp + "</span>";
%>
<tr>
	<td>&nbsp;</td>
	<td><%= col_disp %></td>
	<td><%= rec.getTypeName() %></td>
	<td><%= rec.getNullable()==0?"N":"" %></td>
	<td><%= rec.getDefaults() %></td>
	<td><%= rec.getRemarks() %></td>
</tr>

<%
	}
%>
</table>
</form>


<%
	String pkName = cn.getPrimaryKeyName(tname);
	if (pkName == null && owner != null) pkName = cn.getPrimaryKeyName(owner, tname);

	String pkCols = cn.getConstraintCols(tname, pkName);
	if (pkName != null && pkCols.equals(""))
		pkCols = cn.getConstraintCols(owner, tname, pkName);
	
	List<ForeignKey> fks = cn.getForeignKeys(tname);
	if (owner != null) fks = cn.getForeignKeys(owner, tname);
	
	List<String> refTabs = cn.getReferencedTables(owner, tname);
	List<String> refPkgs = cn.getReferencedPackages(tname);
	List<String> refViews = cn.getReferencedViews(tname);
	List<String> refTrgs = cn.getReferencedTriggers(tname);
	List<String> refIdx = cn.getIndexes(owner, tname);
%>

<hr>


<% if (pkName != null)  {%>
<b>Primary Key</b><br/>
&nbsp;&nbsp;&nbsp;&nbsp;<%= pkName %> (<%= pkCols.toLowerCase() %>) 

<br/><br/>
<% } %>


<% 
	if (fks.size()>0) { 
%>
<b>Foreign Key</b><br/>
<%

	for (int i=0; i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String rTable = rec.rTableName;
		boolean tabLink = true;
		if (rTable == null) {
			rTable = rec.rTableName;
			tabLink = false;
			tabLink = true;
		}
%>
&nbsp;&nbsp;&nbsp;&nbsp;<%= rec.constraintName %>
	(<%= cn.getConstraintCols(rec.owner, rec.tableName, rec.constraintName) %>)
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
	(<%= cn.getConstraintCols(rec.rOwner, rec.rTableName, rec.rConstraintName) %>)
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
<b>Index</b><br/>
<%

	for (int i=0; i<refIdx.size(); i++) {
		String indexName = refIdx.get(i);
%>
	&nbsp;&nbsp;&nbsp;&nbsp;<%= indexName %> 
	<%= cn.getIndexColumns(owner, tname, indexName).toLowerCase() %>
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
<b>Related Table</b>
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
<b>Related Program</b>
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
<b>Related View</b>
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
<b>Related Trigger</b>
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