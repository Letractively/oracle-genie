<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");
	
	if (cn==null) {
%>	
		Connection lost. <a href="Javascript:window.close()">Close</a>
<%
		return;
	}
	Connection conn = cn.getConnection();

	String table = request.getParameter("table");
	String key = request.getParameter("key");
	
	String pkName = cn.getPrimaryKeyName(table);
	String conCols = cn.getConstraintCols(pkName);
//	if (conCols.length() > 2) conCols = conCols.substring(1, conCols.length()-1);
	
	String condition = Util.buildCondition(conCols, key);

	String sql = "SELECT * FROM " + table + " WHERE " + condition;
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	Query q = new Query(cn, sql, request);
	ResultSet rs = q.getResultSet();
	
	// get table name
	String tbl = null;
	//String temp = sql.replaceAll("\n", " ").trim();
	String temp=sql.replaceAll("[\n\r\t]", " ");
	
	int idx = temp.toUpperCase().indexOf(" FROM ");
	if (idx >0) {
		temp = temp.substring(idx + 6);
		idx = temp.indexOf(" ");
		if (idx > 0) temp = temp.substring(0, idx).trim();
		
		tbl = temp.trim();
		
		
		idx = tbl.indexOf(" ");
		if (idx > 0) tbl = tbl.substring(0, idx);
		
	}
	System.out.println("XXX TBL=" + tbl);
%>
<script language="Javascript">

function selectOption(select_id, option_val) {
    $('#'+select_id+' option:selected').removeAttr('selected');
    $('#'+select_id+' option[value='+option_val+']').attr('selected','selected');       
}

	$(document).ready(function() {
		$('table.striped tbody tr:odd').addClass('odd');
		$('table.striped tbody tr:even').addClass('even');
	});	

	</script>

<form name="formQry" target="_blank" action="query.jsp">
<input name="sql" type="hidden" value="<%= sql %>">
</form>

SQL = <%= sql %> <a href="javascript:document.formQry.submit()"><img border=0 src="image/query.gif" title="Open Query"></a>

<table id="inspectTable" class="striped" border=0 width=600>
<tr>
	<th><b>Column Name</b></th>
	<th><b>Value</b></th>
	<th><b>Comment</b> <a href="Javascript:hideInspectComment()">x</a></th> 
</tr>

<%
	boolean numberCol[] = new boolean[500];

	boolean hasData = false;
	if (rs != null) hasData = rs.next();
	int colIdx = 0;
	for  (int i = 1; rs != null && i<= rs.getMetaData().getColumnCount(); i++){
	
		String colName = q.getColumnLabel(i);

			colIdx++;
			int colType = q.getColumnType(i);
			if (colType == 2 || colType == 4 || colType == 8) numberCol[colIdx] = true;
			
			String val = q.getValue(i);
			String valDisp = Util.escapeHtml(val);
			if (val != null && val.endsWith(" 00:00:00")) valDisp = val.substring(0, val.length()-9);
			if (val==null) valDisp = "<span style='color: #999999;'>null</span>";
			
			if (val!=null && val.equals("Exhausted Resultset")) valDisp = "<span style='color: #999999;'>null</span>";
%>
	<tr>
		<td><b><%=colName%></b></td>
		<td <%= (numberCol[colIdx])?"align=right":""%>><%= valDisp %></td>
		<td><%= cn.getComment(table, colName) %></td>
	</tr>
<%
	}	
%>
</tr>
</table>