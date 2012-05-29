<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>


<%

	Connect cn = (Connect) session.getAttribute("CN");
	
	int counter = 0;
	String sql = request.getParameter("sql");
	String upto = request.getParameter("upto");
	if (upto == null || upto.equals("")) upto = "1000";
	
	int maxRow = Integer.parseInt(upto);
	
	if (sql==null) sql = "SELECT * FROM TAB";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	if (sql.endsWith("/")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	String norun = request.getParameter("norun");
	
	int lineLength = Util.countLines(sql);
	if (lineLength <3) lineLength = 4;
	if (lineLength >50) lineLength = 50;
	
	cn.queryCache.removeQuery(sql);
	Query q = null;
	
	if (norun==null) {
		q = new Query(cn, sql, maxRow);
		System.out.println(cn.getUrlString() + " " + request.getRemoteAddr() + " " + (new Date()) + "\n" + sql);
		if (q.isError()) System.out.println("Error: " + q.getMessage());
		else System.out.println("Count: " + q.getRecordCount());

		if (!q.isError())
			cn.queryCache.addQuery(sql, q);
	}
	
	// get table name
	String tbl = null;
	List<String> tbls = Util.getTables(sql); 
	if (tbls.size()>0) tbl = tbls.get(0);
//	System.out.println("XXX TBL=" + tbl);
	
	String title = sql;
%>

<html>
<head> 
	<title><%= title %></title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>

    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/query-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
    
    <script type="text/javascript">
	$(document).ready(function() {
<% for (String tname : tbls) { %>		
		showTable('<%=tname%>');
<% } %>
		setDoMode('sort');
		var cnt = $("#recordCount").val();
		if (cnt != "0") $("#buttonsDiv").slideDown();
	});	    
	
    $(document).ready(function(){
    	setHighlight();
      });
    </script>
</head> 

<body>

<img src="image/icon_query.png" align="middle"/> <b>QUERY</b>
&nbsp;&nbsp;
<%= cn.getUrlString() %>

&nbsp;&nbsp;&nbsp;
<a href="q.jsp" target="_blank">Q</a> |
<a href="worksheet.jsp" target="_blank">Work Sheet</a>

<br/><br/>
<a href="Javascript:toggleHelp()"><img  style="float: left" id="helpDivImage" border="0" src="image/minus.gif"></a>
<div id="div-help" style="float: left">
	<a id="showERD" href="Javascript:showERD('<%=tbl%>')">Show ERD</a>
	<div id="tableList1" style="margin-left: 5px;">
<%-- 	<a href="Javascript:showRelatedTables('<%=tbl%>')">Show Related Tables</a>
 --%>
 	</div>

	<div id="table-detail"></div>

	<div>
	<a href="Javascript:copyPaste('SELECT');">SELECT</a>&nbsp;
	<a href="Javascript:copyPaste('*');">*</a>&nbsp;
	<a href="Javascript:copyPaste('FROM');">FROM</a>&nbsp;
	<a href="Javascript:copyPaste('WHERE');">WHERE</a>&nbsp;
	<a href="Javascript:copyPaste('=');">=</a>&nbsp;
	<a href="Javascript:copyPaste('LIKE');">LIKE</a>&nbsp;
	<a href="Javascript:copyPaste('\'%\'');">'%'</a>&nbsp;
	<a href="Javascript:copyPaste('IS');">IS</a>&nbsp;
	<a href="Javascript:copyPaste('NOT');">NOT</a>&nbsp;
	<a href="Javascript:copyPaste('NULL');">NULL</a>&nbsp;
	<a href="Javascript:copyPaste('AND');">AND</a>&nbsp;
	<a href="Javascript:copyPaste('OR');">OR</a>&nbsp;
	<a href="Javascript:copyPaste('IN');">IN</a>&nbsp;
	<a href="Javascript:copyPaste('( )');">( )</a>&nbsp;
	<a href="Javascript:copyPaste('EXISTS');">EXISTS</a>&nbsp;
	<a href="Javascript:copyPaste('ORDER BY');">ORDER-BY</a>&nbsp;
	<a href="Javascript:copyPaste('DESC');">DESC</a>&nbsp;
<!-- 
	<br/>
	&nbsp;&nbsp;&nbsp;
	<a href="Javascript:copyPaste('LOWER( )');">LOWER( )</a>&nbsp;
	<a href="Javascript:copyPaste('UPPER( )');">UPPER( )</a>&nbsp;
	<a href="Javascript:copyPaste('SUBSTR( )');">SUBSTR( )</a>&nbsp;
	<a href="Javascript:copyPaste('TRIM( )');">TRIM( )</a>&nbsp;
	<a href="Javascript:copyPaste('LENGTH( )');">LENGTH( )</a>&nbsp;
	&nbsp;&nbsp;&nbsp;
	<a href="Javascript:copyPaste('TO_DATE( )');">TO_DATE( )</a>&nbsp;
	<a href="Javascript:copyPaste('TO_NUMBER( )');">TO_NUMBER( )</a>&nbsp;
	<a href="Javascript:copyPaste('TO_CHAR( )');">TO_CHAR( )</a>&nbsp;

 -->
 	<br/>
	&nbsp;&nbsp;&nbsp;
	<a href="Javascript:copyPaste('GROUP BY');">GROUP-BY</a>&nbsp;
	<a href="Javascript:copyPaste('HAVING');">HAVING</a>&nbsp;
	<a href="Javascript:copyPaste('COUNT(*)');">COUNT(*)</a>&nbsp;
	<a href="Javascript:copyPaste('SUM( )');">SUM( )</a>&nbsp;
	<a href="Javascript:copyPaste('AVG( )');">AVG( )</a>&nbsp;
	<a href="Javascript:copyPaste('MIN( )');">MIN( )</a>&nbsp;
	<a href="Javascript:copyPaste('MAX( )');">MAX( )</a>&nbsp;
	
	</div>
</div>
<br clear="all"/>

<form name="form1" id="form1" method="post" action="query.jsp">
<textarea id="sql1" name="sql" cols=100 rows=<%= lineLength %>><%= sql %></textarea><br/>
Up to 
<select name="upto">
<option value="100" <%= maxRow==100?"SELECTED":"" %>>100</option>
<option value="500" <%= maxRow==500?"SELECTED":"" %>>500</option>
<option value="1000" <%= maxRow==1000?"SELECTED":"" %>>1,000</option>
<option value="5000" <%= maxRow==5000?"SELECTED":"" %>>5,000</option>
<option value="10000" <%= maxRow==10000?"SELECTED":"" %>>10,000</option>
</select>
<input type="submit" value="Submit"/>
&nbsp;
<input type="button" value="Download" onClick="Javascript:download()"/>
</form>

<form name="form0" id="form0">
<textarea style="display: none;" id="sql" name="sql" ><%= sql %></textarea>
<input type="hidden" id="sortColumn" name="sortColumn" value="">
<input type="hidden" id="sortDirection" name="sortDirection" value="0">
<input type="hidden" id="hideColumn" name="hideColumn" value="">
<input type="hidden" id="filterColumn" name="filterColumn" value="">
<input type="hidden" id="filterValue" name="filterValue" value="">
<input type="hidden" id="searchValue" name="searchValue" value="">
<input type="hidden" id="pageNo" name="pageNo" value="1">
<input type="hidden" id="rowsPerPage" name="rowsPerPage" value="20">
<input type="hidden" id="dataLink" name="dataLink" value="1">
<input type="hidden" id="preFormat" name="preFormat" value="0">
</form>

<%= q==null?"":q.getMessage() %>

<%
	if (norun!=null || !q.hasMetaData()) {
%>
<br/><br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

</body>
</html>
<%
		return;		
	}
%>
<BR/>
<div id="buttonsDiv" style="display: none;">
<TABLE>
<TD><a class="qryBtn" id="modeSort" href="Javascript:setDoMode('sort')">Sort</a>
<TD><a class="qryBtn" id="modeCopy" href="Javascript:setDoMode('copy')">Copy&amp;Paste</a></TD>
<TD><a class="qryBtn" id="modeHide" href="Javascript:setDoMode('hide')">Hide Column</a>
	<span id="showAllCol" style="display: none;">
		<a href="Javascript:showAllColumn()">Show All Column</a>&nbsp;
	</span>
</TD>
</TD>
<TD><a class="qryBtn" id="modeFilter" href="Javascript:setDoMode('filter')">Filter</a></TD>
<TD><span id="filter-div"></span></TD>
</TABLE>
</div>
<BR/>

<div id="data-div">
<jsp:include page="ajax/qry.jsp">
	<jsp:param value="<%= sql%>" name="sql"/>
	<jsp:param value="1" name="pageNo"/>
	<jsp:param value="" name="sortColumn"/>
	<jsp:param value="0" name="sortDirection"/>
	<jsp:param value="" name="filterColumn"/>
	<jsp:param value="" name="filterValue"/>
	<jsp:param value="1" name="dataLink"/>
</jsp:include>
</div>

<br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

</body>
</html>