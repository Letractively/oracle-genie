<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	HashMap<String, QueryLog> map = cn.getQueryHistory();
	
%>
<head>
<script type="text/javascript">

	function q(tname) {
		$("#sql").val("SELECT * FROM " + tname);
		$("#form1").submit();
	}	
</script>
	
</head>

<b>CPAS Catalog</b>
<br/><br/>
<a href="cpas-treeview.jsp" target="_blank">CPAS Tree View</a> | 
<a href="cpas-process.jsp" target="_blank">CPAS Process</a>
<br/><br/>
<li><a href="Javascript:q('CPAS_CATALOG')">CPAS Catalog</a></li>
<li><a href="Javascript:q('BATCHCAT')">Batch</a></li>
<li><a href="Javascript:q('ERRORCAT')">Error</a></li>
<li><a href="Javascript:q('REPORTCAT')">Report</a></li>
<li><a href="Javascript:q('CPAS_CODE')">Code</a></li>
<li><a href="Javascript:q('CPAS_WIZARD')">Wizard</a></li>
<li><a href="Javascript:q('CPAS_ROLE')">CPAS Role</a></li>

<form id="form1" name="form1" target=_blank action="query.jsp" method="post">
<input id="sql" name="sql" type="hidden" value="select * from tab"/>
</form>

