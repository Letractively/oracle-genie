<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="spencer.genie.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String id = request.getParameter("id");
	String process = request.getParameter("process");
	String event = request.getParameter("event");
%>

<html>
<head>
<title>CPAS Process</title>

<meta name="description"
	content="Genie is an open-source, web based oracle database schema navigator." />
<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
<meta name="author" content="Spencer Hwang" />

<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
<script src="script/jquery-ui-1.8.18.custom.min.js"
	type="text/javascript"></script>
<script src="script/genie.js?<%=Util.getScriptionVersion()%>"
	type="text/javascript"></script>
<%--
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
	<script src="script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/query-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
--%>
<link rel="icon" type="image/png" href="image/Genie-icon.png">
<link rel="stylesheet"
	href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css" />
<link rel='stylesheet' type='text/css'
	href='css/style.css?<%=Util.getScriptionVersion()%>'>

<style>

.selected { 
    background-color: yellow;
    font-weight: bold;
//    border:  1px solid #2F557B;
}

#outer-ptype {
    background-color: #FFFFFF;
    border: 1px solid #999999;
    width: 300px;
    height: 600px;
    overflow: auto;
    float: left;
    padding: 4px;
}

#outer-process {
    background-color: #FFFFFF;
    border: 1px solid #999999;
    width: 300px;
    height: 300px;
    overflow: auto;
    float: left;
    padding: 4px;
}

</style>

<script type="text/javascript">
$(window).resize(function() {
	checkResize();
});

$(document).ready(function(){
	checkResize();
	loadPtype();
<% if (id != null ) {%>
	loadProcess('<%=id%>');
<% } %>


window.setTimeout(function() {
<% if (process != null ) {%>
	loadEvent('<%=process%>');
<% } %>
}, 250);

window.setTimeout(function() {
	<% if (event != null ) {%>
		loadEventView('<%=process%>','<%=event%>');
	<% } %>
	}, 500);
})

	function checkResize() {
		var w = $(window).width();
		var h = $(window).height();
	
		if (h > 500) {
			var newH = h - 80;
			var diff = $('#outer-ptype').position().top - $('#outer-ptype').position().top;

			$('#outer-ptype').height(newH);
			$('#outer-process').height(newH);
			
			var tmp = w - $('#outer-ptype').width() - 45; 

			if (tmp < 660) tmp = 660;
			$('#outer-process').width(tmp);			
		}
	}

function loadPtype() {
	$("#inner-process").html('');
	$("#inner-event").html('');
	$("#inner-eventview").html('');
	$.ajax({
		url: "ajax-cpas/load-Ptype.jsp?t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-ptype").html(data);
			setHighlight();
			$('#inner-ptype a').click( function(e) {
			    //Remove the selected class from all of the links
			    $('#inner-ptype a.selected').removeClass('selected');
			    //Add the selected class to the current link
			    $(this).addClass('selected');
			});
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function loadProcess(ptype) {
	$("#inner-event").html('');
	$("#inner-eventview").html('');
	$.ajax({
		url: "ajax-cpas/load-Process.jsp?ptype=" + ptype + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-process").html(data);
			setHighlight();
			$('#inner-process a').click( function(e) {
			    //Remove the selected class from all of the links
			    $('#inner-process a.selected').removeClass('selected');
			    //Add the selected class to the current link
			    $(this).addClass('selected');
			});
			$("#pt-"+ptype).addClass('selected');	
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}	

function loadEvent(process) {
	$("#inner-eventview").html('');
	$.ajax({
		url: "ajax-cpas/load-Event.jsp?process=" + process + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-event").html(data);
			setHighlight();
			$('#inner-event a').click( function(e) {
			    //Remove the selected class from all of the links
			    $('#inner-event a.selected').removeClass('selected');
			    //Add the selected class to the current link
			    $(this).addClass('selected');
			});
			$("#pr-"+process).addClass('selected');	
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}	

function loadEventView(process, event) {
	$.ajax({
		url: "ajax-cpas/load-EventView.jsp?process=" + process + "&event="+event +"&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-eventview").html(data);
			setHighlight();
			$('#inner-eventview a').click( function(e) {
			    //Remove the selected class from all of the links
			    $('#inner-eventview a.selected').removeClass('selected');
			    //Add the selected class to the current link
			    $(this).addClass('selected');
			});
			$("#ev-"+event).addClass('selected');	
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}	

/*
function openSimulator() {
	$("#formSimul").submit();
}
*/

function openSimul(sdi, tkey) {
	$("#formSimulSdi").val(sdi);
	$("#formSimulTkey").val(tkey);
	$("#formSimul").submit();
}

function processSearch(keyword) {
	//keyword = keyword.trim();
	keyword = $.trim(keyword);
	$("#inner-process").html("<img src='image/loading.gif'/>");
	$("#inner-event").html('');
	$("#inner-eventview").html('');

	$.ajax({
		url: "ajax-cpas/process-search.jsp?keyword=" + keyword + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-process").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});
}
</script>

</head>

<body>

	<table width=100% border=0>
		<td><img src="image/cpas.jpg"
			title="Version <%=Util.getVersionDate()%>" /></td>
		<td><h2 style="color: blue;">CPAS Process</h2></td>
		<td>&nbsp;</td>

		<td>
		<a href="index.jsp">Home</a> |
<a href="query.jsp" target="_blank">Query</a> |
<a href="cpas-treeview.jsp" target="_blank">CPAS TreeView</a> 
		</td>
		<td align=left><h3><%=cn.getUrlString()%></h3></td>
		<td align=right nowrap>
<b>Process Search</b> <input id="globalSearch" style="width: 200px;" onChange="processSearch($('#globalSearch').val())"/>
<!-- <a href="Javascript:clearField2()"><img border=0 src="image/clear.gif"></a>
 -->
<input type="button" value="Find" onClick="Javascript:processSearch($('#globalSearch').val())"/>
</td>
	</table>

	<table border=0 cellspacing=0>
		<tr>
		<td valign=top>
			<div id="outer-ptype">
				<div id="inner-ptype">
				</div>
			</div>
		</td>
		<td valign=top>
			<div id="outer-process">
				<div id="inner-process"></div>
				<br/>
				<div id="inner-event" style="margin-left:20px;"></div>
				<br/>
				<div id="inner-eventview" style="margin-left:40px;"></div>
				
			</div>
		</td>
		</tr>
	</table>

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql" name="sql" type="hidden"/>
</form>

<form id="formSimul" target="_blank" action="cpas-simul.jsp">
<input id="formSimulSdi" name="sdi" type="hidden"/>
<input id="formSimulTkey" name="treekey" type="hidden"/>
</form>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

</body>
</html>