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
<a href="cpas-customtreeview.jsp" target="_blank">CPAS Custom Tree View</a> | 
<a href="cpas-process.jsp" target="_blank">CPAS Process</a>
<br/><br/>
<li><a href="Javascript:q('BATCHCAT')">BATCHCAT</a></li>
<li><a href="Javascript:q('ERRORCAT')">ERRORCAT</a></li>
<li><a href="Javascript:q('REPORTCAT')">REPORTCAT</a></li>
<li><a href="Javascript:q('REQUESTCAT')">REQUESTCAT</a></li>
<li><a href="Javascript:q('TASKCAT')">TASKCAT</a></li>
<br/>

<li><a href="Javascript:q('CPAS_CATALOG')">CPAS_CATALOG</a></li>
<li><a href="Javascript:q('CPAS_CODE')">CPAS_CODE</a></li>
<li><a href="Javascript:q('CPAS_WIZARD')">CPAS_WIZARD</a></li>
<li><a href="Javascript:q('CPAS_VALIDATION')">CPAS_VALIDATION</a></li>
<li><a href="Javascript:q('CPAS_ROLE')">CPAS_ROLE</a></li>
<br/>

<li><a href="Javascript:q('CPAS_ACTION')">CPAS_ACTION</a></li>
<li><a href="Javascript:q('CPAS_AGE')">CPAS_AGE</a></li>
<li><a href="Javascript:q('CPAS_DATE')">CPAS_DATE</a></li>
<li><a href="Javascript:q('CPAS_CALCTYPE')">CPAS_CALCTYPE</a></li>
<li><a href="Javascript:q('CPAS_JML')">CPAS_JML</a></li>
<br/>

<li><a href="Javascript:q('CPAS_GROUP')">CPAS_GROUP</a></li>
<li><a href="Javascript:q('CPAS_TABLE')">CPAS_TABLE</a></li>
<li><a href="Javascript:q('CPAS_LAYOUT')">CPAS_LAYOUT</a></li>
<br/>

<li><a href="Javascript:q('CPAS_SEARCHTYPE')">CPAS_SEARCHTYPE</a></li>
<li><a href="Javascript:q('CPASFIND')">CPASFIND</a></li>
<br/>

<li><a href="Javascript:q('CPAS_DOC')">CPAS_DOC</a></li>
<li><a href="Javascript:q('CPAS_FORM')">CPAS_FORM</a></li>
<br/>

<li><a href="Javascript:q('CPAS_PARAMETER')">CPAS_PARAMETER</a></li>
<br/>

<form id="form1" name="form1" target=_blank action="query.jsp" method="post">
<input id="sql" name="sql" type="hidden" value="select * from tab"/>
</form>

