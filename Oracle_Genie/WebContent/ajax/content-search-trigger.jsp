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
%>

<script type="text/javascript">
function startSearch() {
	var key = $("#searchKey").val();
	if (key.trim() == "") {
		alert("Please enter search keyword");
		return;
	}
	
	$("#startButton").attr("disabled", true);
	$("#searchResult").html("Searching...");
	$("#searchResult").append("<div id='wait'><img src='image/loading.gif'/></div>");
	$.ajax({
		type: 'POST',
		url: "ajax/search-trigger.jsp",
		data: $("#form0").serialize(),
		success: function(data){
			$("#searchResult").html(data);
			$("#wait").remove();
			$("#startButton").attr("disabled", false);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
	
}

</script>

<form id="form0" name="form0">
<table>
<tr>
	<td>Search For</td>
	<td><input id="searchKey" name="searchKey" size="30"> (in trigger body)</td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td>
		<input id="startButton" type="button" value="Start Search" onclick="startSearch()">
	</td>
</tr>
</table>

</form>

<div id="searchResult">
</div>

<br/><br/>

<br clear=all>

<form id="form_qry" target=_blank method="post" action="query.jsp">
<input id="sql" name="sql" value="" style="display: none;">
</form>