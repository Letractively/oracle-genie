<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*"
	import="org.apache.commons.lang3.StringEscapeUtils" 
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
	String col = request.getParameter("col");
	String key = request.getParameter("key");
	
	String pkName = cn.getPrimaryKeyName(table);
	String conCols = cn.getConstraintCols(pkName);
	

	String sql = "SELECT " + col + " FROM " + table + " WHERE " + conCols + "='" + key +"'";
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	System.out.println(request.getRemoteAddr()+": " + sql +";");
	
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

SQL = <%= sql %>

<%
	boolean numberCol[] = new boolean[500];

	boolean hasData = false;
	if (rs != null) hasData = rs.next();
	int colIdx = 0;
	for  (int i = 1; rs != null && i<= rs.getMetaData().getColumnCount(); i++){
	
		int colType = q.getColumnType(i);
		String val = q.getBlob(i);
		String escaped = Util.escapeHtml(val);
%>
<pre>
<%= escaped %>
</pre>
<%
	}	
%>

