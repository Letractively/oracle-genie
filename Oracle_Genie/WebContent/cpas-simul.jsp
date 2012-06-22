<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");

	String sdi = request.getParameter("sdi");
	String actionid = request.getParameter("actionid");
	String tv = request.getParameter("treekey");

	if (actionid==null && tv != null) {
		actionid = cn.queryOne("SELECT actionid FROM TREEVIEW WHERE SDI = '" + sdi + "' AND TREEKEY='" + tv + "'");
	}
	
	String mainQry = cn.queryOne("SELECT ACTIONSTMT FROM TREEACTION_STMT WHERE SDI = '"+sdi+"' AND ACTIONID=" + actionid + " AND ACTIONTYPE='MS'");
	String subQry = cn.queryOne("SELECT ACTIONSTMT FROM TREEACTION_STMT WHERE SDI = '"+sdi+"' AND ACTIONID=" + actionid + " AND ACTIONTYPE='DS'");
	String mainLayout = cn.queryOne("SELECT ACTIONSTMT FROM TREEACTION_STMT WHERE SDI = '"+sdi+"' AND ACTIONID=" + actionid + " AND ACTIONTYPE='MT'");
	String subLayout = cn.queryOne("SELECT ACTIONSTMT FROM TREEACTION_STMT WHERE SDI = '"+sdi+"' AND ACTIONID=" + actionid + " AND ACTIONTYPE='DT'");
	
	if (mainQry==null) mainQry="";
	if (subQry==null) subQry="";

	List<String[]> q = cn.query("SELECT caption, treekey FROM TREEVIEW WHERE SDI='"+sdi+"' and actionid="+actionid);
	String caption = "";
	String treekey = "";
	if (q != null && q.size()>0) {
		caption = q.get(0)[1];
		treekey = q.get(0)[2];
	}
	
	String clnt = "";
	String mkey = "";
	String erkey = "";
	String plan = "";
	String accountid = "";
	String personid = "";
	String sessionid = "";
	String seclevel = "";
	String memberid = "";
	String taskid = "";
		
	q = cn.query("SELECT tagname, tagcvalue, tagnvalue, tagdvalue, tagtype FROM CONNSESSION_DATA A WHERE SESSIONID=(SELECT  MAX(SESSIONID) FROM CONNSESSION)");
	for (String[] row : q) {
		String value = row[2];
		if (row[5].equals("N")) value = row[3];
		if (row[5].equals("D")) value = row[4];
		
		if (row[1].equals("CLNT")) clnt = value;
		if (row[1].equals("MKEY")) mkey = value;
		if (row[1].equals("ERKEY")) erkey = value;
		if (row[1].equals("PLAN")) plan = value;
		if (row[1].equals("ACCOUNTID")) accountid = value;
		if (row[1].equals("PERSONID")) personid = value;
		
		if (row[1].equals("SESSIONID")) sessionid = value;
		if (row[1].equals("SECLEVEL")) seclevel = value;
		if (row[1].equals("MEMBERID")) memberid = value;
		if (row[1].equals("TASKID")) taskid = value;
	}

	if (clnt==null) clnt = "";
	if (mkey==null) mkey = "";
	if (erkey==null) erkey = "";
	if (plan==null) plan = "";
	if (accountid==null) accountid = "";
	if (personid==null) personid = "";

	if (sessionid==null) sessionid = "";
	if (seclevel==null) seclevel = "";
	if (memberid==null) memberid = "";
	if (taskid==null) taskid = "";
	
//	String mQry = cn.getCpasUtil().getQryReplaced(mainQry);
%>


<html>
<head> 
	<title>CPAS Simulator <%= sdi %> <%= actionid %> <%= treekey %></title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
    
<script type="text/javascript">

$(document).ready(function() {
	$("select").change(function() {
	    var sid = $(this).val();
	    // display based on the value
	    //alert(sid);
	    loadSessionValue(sid);
	});

});	    

function loadSessionValue(sid) {
	$.ajax({
		url: "ajax-cpas/load-connsession.jsp?sid=" + sid + "&t=" + (new Date().getTime()),
		dataType: 'json',
		success: function(data){
			//$("#ERD").html(data);
			//alert(data);
			var jo=data;
			$("#CLNT").val(jo.CLNT);
			$("#MKEY").val(jo.MKEY);
			$("#ERKEY").val(jo.ERKEY);
			$("#PLAN").val(jo.PLAN);
			$("#ACCOUNTID").val(jo.ACCOUNTID);
			$("#PERSONID").val(jo.PERSONID);
			$("#SESSIONID").val(jo.SESSIONID);
			$("#SECLEVEL").val(jo.SECLEVEL);
			$("#MEMBERID").val(jo.MEMBERID);
			$("#TASKID").val(jo.TASKID);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function run() {
	runMain();
}

function runMain() {
	var mainQry = $("#mainQry").html();

	var clnt = $("#CLNT").val();
	var mkey = $("#MKEY").val();
	var erkey = $("#ERKEY").val();
	var plan = $("#PLAN").val();
	var accountid = $("#ACCOUNTID").val();
	var personid = $("#PERSONID").val();
	var sessionid = $("#SESSIONID").val();
	var seclevel = $("#SECLEVEL").val();
	var memberid = $("#MEMBERID").val();
	var taskid = $("#TASKID").val();
	
	var newQry=mainQry.replace(new RegExp(":S.CLNT", 'g'), "'" + clnt + "'");
	newQry=newQry.replace(new RegExp(":S.MKEY", 'g'), "'" + mkey + "'");
	newQry=newQry.replace(new RegExp(":S.ERKEY", 'g'), "'" + erkey + "'");
	newQry=newQry.replace(new RegExp(":S.PLAN", 'g'), "'" + plan + "'");
	newQry=newQry.replace(new RegExp(":S.ACCOUNTID", 'g'), "'" + accountid + "'");
	newQry=newQry.replace(new RegExp(":S.PERSONID", 'g'), "'" + personid + "'");
	newQry=newQry.replace(new RegExp(":S.SESSIONID", 'g'), "'" + sessionid + "'");
	newQry=newQry.replace(new RegExp(":S.SECLEVEL", 'g'), "'" + seclevel + "'");
	newQry=newQry.replace(new RegExp(":S.MEMBERID", 'g'), "'" + memberid + "'");
	newQry=newQry.replace(new RegExp(":S.TASKID", 'g'), "'" + taskid + "'");
	
//	alert(mainQry);
	$("#sql-1").html(newQry);
	$("#layout").val('<%=mainLayout%>');
	$("#sql2").val($("#subQry").html());
//	alert(newQry);

	$("#div-1").html("");
	$("#div-2").html("");
	reloadData(1);
}

function reloadData(id) {
	var divName = "div-" + id;
	var sql = $("#sql-" + id).html();

//	alert("pageNo=" + $("#pageNo").val());

	//	alert("id=" + id);
//	alert("sql=" + sql);		
	$("#sql").val(sql);
	$("#id").val(id);
	$("#sortColumn").val($("#sort-"+id).val());
	$("#sortDirection").val($("#sortdir-"+id).val());

	$("#"+divName).html("<div id='wait'><img src='image/loading.gif'/></div>");
	//$('body').css('cursor', 'wait'); 
	$.ajax({
		type: 'POST',
		url: "ajax/qry-simul.jsp",
		data: $("#form0").serialize(),
		success: function(data){
			$("#"+divName).html(data);
			hideIfAny(id);
			
			setHighlight();
			//$('body').css('cursor', 'default'); 
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function queryDetail(fields, values) {
//	alert("Query Detail");
	
	runSub(fields, values);
}

function runSub(fields, values) {
	var subQry = $("#subQry").html();

	var clnt = $("#CLNT").val();
	var mkey = $("#MKEY").val();
	var erkey = $("#ERKEY").val();
	var plan = $("#PLAN").val();
	var accountid = $("#ACCOUNTID").val();
	var personid = $("#PERSONID").val();
	var sessionid = $("#SESSIONID").val();
	var seclevel = $("#SECLEVEL").val();
	var memberid = $("#MEMBERID").val();
	var taskid = $("#TASKID").val();

	var newQry=subQry.replace(new RegExp(":S.CLNT", 'g'), "'" + clnt + "'");
	newQry=newQry.replace(new RegExp(":S.MKEY", 'g'), "'" + mkey + "'");
	newQry=newQry.replace(new RegExp(":S.ERKEY", 'g'), "'" + erkey + "'");
	newQry=newQry.replace(new RegExp(":S.PLAN", 'g'), "'" + plan + "'");
	newQry=newQry.replace(new RegExp(":S.ACCOUNTID", 'g'), "'" + accountid + "'");
	newQry=newQry.replace(new RegExp(":S.PERSONID", 'g'), "'" + personid + "'");
	newQry=newQry.replace(new RegExp(":S.SESSIONID", 'g'), "'" + sessionid + "'");
	newQry=newQry.replace(new RegExp(":S.SECLEVEL", 'g'), "'" + seclevel + "'");
	newQry=newQry.replace(new RegExp(":S.MEMBERID", 'g'), "'" + memberid + "'");
	newQry=newQry.replace(new RegExp(":S.TASKID", 'g'), "'" + taskid + "'");

	var keys=fields.split("|");
	var vals=values.split("|");

	for (var i = 0; i < keys.length; i++) {
		newQry=newQry.replace(new RegExp(":A."+keys[i], 'g'), "'"+vals[i]+ "'");
	}
	
	$("#sql-2").html(newQry);
	$("#sql2").val("");
	$("#layout").val('<%=subLayout%>');
//	alert(newQry);

	$("#div-2").html("");
	reloadData(2);
}

function openQuery(id) {
	var sql = $("#sql-" + id).html();
	var divName = "div-" + id;
	//alert(sql);
	
	$("#sql_q").val(sql);
	document.FORM_query.submit();
}

function toggleLayout(id) {
	var val = $("#applylayout").val();
	if (val=="0")
		$("#applylayout").val("1");
	else
		$("#applylayout").val("0");
	
	if (id=="1") {
		$("#layout").val('<%=mainLayout%>');
		$("#sql2").val($("#subQry").html());
	} else {
		$("#sql2").val('');
		$("#layout").val('<%=subLayout%>');
	}
	reloadData(id);
}

</script>
</head> 

<body>

<img src="image/icon_query.png" align="middle"/> <b>CPAS Simulator</b>
&nbsp;&nbsp;
<%= cn.getUrlString() %>

&nbsp;&nbsp;&nbsp;
<a href="query.jsp" target="_blank">Query</a> |
<a href="worksheet.jsp" target="_blank">Work Sheet</a>

<br/><br/>


<b><%= caption %></b> [<%= treekey %>]
<hr/>

<%
	List<String[]> connsession = cn.query("SELECT SESSIONID, USERID, SDATE FROM CONNSESSION ORDER BY SESSIONID DESC", 20, false);
%>

<div style="padding: 4px;">
<b>Paramaters</b>
<select id="CONNSESSION">
<% for (String[] s : connsession) {%>
<option value="<%=s[1]%>"><%=s[1] + " " + s[2] + " " + s[3]%></option>
<% } %>
</select>
<form>
<table>
<tr>
	<td>CLNT</td>
	<td>MKEY</td>
	<td>ERKEY</td>
	<td>PLAN</td>
	<td>ACCOUNTID</td>
	<td>PERSONID</td>
	<td>SESSIONID</td>
	<td>SECLEVEL</td>
	<td>MEMBERID</td>
	<td>TASKID</td>
	
</tr>
<tr>
	<td><input name="CLNT" id="CLNT" value="<%= clnt %>" size=10 maxlength=10></td>
	<td><input name="MKEY" id="MKEY" value="<%= mkey %>" size=10 maxlength=10></td>
	<td><input name="ERKEY" id="ERKEY" value="<%= erkey %>" size=10 maxlength=10></td>
	<td><input name="PLAN" id="PLAN" value="<%= plan %>" size=10 maxlength=10></td>
	<td><input name="ACCOUNTID" id="ACCOUNTID" value="<%= accountid %>" size=10 maxlength=10></td>
	<td><input name="PERSONID" id="PERSONID" value="<%= personid %>" size=10 maxlength=10></td>
	<td><input name="SESSIONID" id="SESSIONID" value="<%= sessionid %>" size=10 maxlength=10></td>
	<td><input name="SECLEVEL" id="SECLEVEL" value="<%= seclevel %>" size=10 maxlength=10></td>
	<td><input name="MEMBERID" id="MEMBERID" value="<%= memberid %>" size=10 maxlength=10></td>
	<td><input name="TASKID" id="TASKID" value="<%= taskid %>" size=10 maxlength=10></td>
</tr>
</table>
<input type="button" value="Submit" onClick="javascript:run()"/>
</form>
</div>

<hr/>

<b>Master</b> [<%= mainLayout %>]
<div style="padding: 4px;">
	<div id="mainQry"><%= mainQry %></div>
	<div id="div-1"></div>
</div>

<hr/>

<b>Detail</b> [<%= subLayout %>]
<div style="padding: 4px;">
	<div id="subQry"><%= subQry %></div>
	<div id="div-2"></div>
</div>


<div style="display: none;">
<form name="form0" id="form0" action="query.jsp">
<input id="sql" name="sql" type="hidden" value=""/>
<input id="sql2" name="sql2" type="hidden" value=""/>
<input id="dataLink" name="dataLink" type="hidden" value="1"/>
<input id="id" name="id" type="hidden" value=""/>
<input id="showFK" name="showFK" type="hidden" value="0"/>
<input type="hidden" id="sortColumn" name="sortColumn" value="">
<input type="hidden" id="sortDirection" name="sortDirection" value="0">
<input type="hidden" id="hideColumn" name="hideColumn" value="">
<input type="hidden" id="filterColumn" name="filterColumn" value="">
<input type="hidden" id="filterValue" name="filterValue" value="">
<input type="hidden" id="searchValue" name="searchValue" value="">
<input type="hidden" id="pageNo" name="pageNo" value="1">
<input type="hidden" id="rowsPerPage" name="rowsPerPage" value="10">
<input type="hidden" id="layout" name="layout" value="">
<input type="hidden" id="applylayout" name="applylayout" value="0">
</form>
</div>

<div style="display: none;" id="sql-1"></div>
<div style="display: none;" id="mode-1">sort</div>
<div style="display: none;" id="hide-1"></div>
<div style="display: none;" id="sort-1"></div>
<div style="display: none;" id="sortdir-1">0</div>

<div style="display: none;" id="sql-2"></div>
<div style="display: none;" id="mode-2">sort</div>
<div style="display: none;" id="hide-2"></div>
<div style="display: none;" id="sort-2"></div>
<div style="display: none;" id="sortdir-2">0</div>

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql_q" name="sql" type="hidden"/>
<input name="norun_" type="hidden" value="YES"/>
</form>

</div>


</body>
</html>

