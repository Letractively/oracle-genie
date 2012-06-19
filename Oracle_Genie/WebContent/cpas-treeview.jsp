<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="spencer.genie.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
%>

<html>
<head>
<title>CPAS Tree View</title>

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
#outer-sdi {
    background-color: #FFFFFF;
    border: 1px solid #999999;
    width: 250px;
    height: 600px;
    overflow: auto;
    float: left;
    padding: 4px;
}

#outer-tv {
    background-color: #FFFFFF;
    border: 1px solid #999999;
    width: 350px;
    height: 600px;
    overflow: auto;
    float: left;
    padding: 4px;
}

#outer-tvstmt {
    background-color: #FFFFFF;
    border: 1px solid #999999;
    width: 600px;
    height: 600px;
    overflow: auto;
    float: left;
    padding: 4px;
}

</style>

<script type="text/javascript">
var selectedSdi = "";
$(window).resize(function() {
	checkResize();
});

$(document).ready(function(){
	checkResize();
	loadSdi();
})

	function checkResize() {
		var w = $(window).width();
		var h = $(window).height();
	
		if (h > 500) {
			var newH = h - 80;
			var diff = $('#outer-sdi').position().top - $('#outer-sdi').position().top;

			$('#outer-sdi').height(newH);
			$('#outer-tv').height(newH);
			$('#outer-tvstmt').height(newH);
			
			var tmp = w - $('#outer-sdi').width() - $('#outer-tv').width() - 45; 

			if (tmp < 660) tmp = 660;
			$('#outer-tvstmt').width(tmp);			
		}
	}

function loadSdi() {
	$("#inner-tv").html('');
	$("#inner-tvstmt").html('');
	$.ajax({
		url: "ajax-cpas/load-sdi.jsp?t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-sdi").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function loadTV(sdi) {
	selectedSdi = sdi;
	$("#inner-tvstmt").html('');
	$.ajax({
		url: "ajax-cpas/load-TV.jsp?sdi=" + sdi + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-tv").html(data);
			openAll();
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}	

function loadChildTV(sdi, parentid, divName) {
	$.ajax({
		url: "ajax-cpas/load-TV.jsp?sdi=" + sdi + "&parentid=" + parentid,
		success: function(data){
			$("#"+divName).html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}	

function loadSTMT(sdi, actionid, treekey) {
	$.ajax({
		url: "ajax-cpas/load-STMT.jsp?sdi=" + sdi + "&actionid=" + actionid + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-tvstmt").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}	

function toggleChild(sdi, parentid){
	var imgsrc = $("#img-"+parentid).attr("src");
	if (imgsrc.indexOf("plus.gif") >0 ) {
		imgsrc=imgsrc.replace("plus","minus");
		$("#img-"+parentid).attr("src", imgsrc);
	} else {
		imgsrc=imgsrc.replace("minus","plus");
		$("#img-"+parentid).attr("src", imgsrc);
	}
	//alert(imgsrc);
	var divName = "div-" + sdi + "-" + parentid;
	$("#"+divName).toggle();
	
	var html = $("#"+divName).html();
	if (html=='') {
		//$("#"+divName).html('abc');
		loadChildTV(sdi, parentid, divName)
	}
}

function openAll() {
	$("img.toggle").each(function(index) {
		var id = $(this).attr('id').substring(4);
		
	    //alert(id);
		toggleChild(selectedSdi, id);
	});
	
}
</script>

</head>

<body>

	<table width=100% border=0>
		<td><img src="image/cpas.jpg"
			title="Version <%=Util.getVersionDate()%>" /></td>
		<td valign=bottom><h3><%=cn.getUrlString()%></h3></td>
		<td>&nbsp;</td>

		<td></td>
		<td align=right><h2 style="color: blue;">CPAS Tree View</h2></td>
	</table>

	<table border=0 cellspacing=0>
		<td valign=top>
			<div id="outer-sdi">
				<div id="inner-sdi">
				</div>
			</div>
		</td>
		<td valign=top>
			<div id="outer-tv">
				<div id="inner-tv"></div>
			</div>
		</td>
		<td valign=top>
			<div id="outer-tvstmt">
				<div id="inner-tvstmt"></div>
			</div>
		</td>
	</table>

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql" name="sql" type="hidden"/>
</form>


</body>
</html>