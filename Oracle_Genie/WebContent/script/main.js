var gMode = 'table';

function loadSchema(sName) {
	$("#searchFilter").val("");
	$("#inner-table").html("<img src='image/loading.gif'/>");
	$.ajax({
		url: "schema.jsp?schema=" + sName + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-table").html(data);
			checkResize();
			CATALOG = catName;
		}
	});	
}

function addHistory(value) {
	var current = $("#inner-result2").html();
	var newItem = "<li>" + value + "</li>"; 
	current = current.replace(newItem,"");
	$("#inner-result2").html(newItem + current);
}

function loadTable(tName) {
	var tableName = tName;
	$("#inner-result1").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax/detail-table.jsp?table=" + tableName + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-result1").html(data);
			//alert(data);
			//$("body").css("cursor", "auto");
			
		}
	});	
	
	addHistory("<a href='Javascript:loadTable(\""+tName+"\")'>" + tName + "</a>");
}

function globalSearch(keyword) {
	$("#inner-result1").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax/global-search.jsp?keyword=" + keyword + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-result1").html(data);
		}
	});
	
	addHistory("<a href='Javascript:globalSearch(\""+keyword+"\")'>" + keyword + "</a>");
}

function loadView(vName) {
	$("#inner-result1").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax/detail-view.jsp?view=" + vName + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-result1").html(data);
			//SyntaxHighlighter.all();
		}
	});	
	addHistory("<a href='Javascript:loadView(\""+vName+"\")'>" + vName + "</a>");
}

function loadPackage(pName) {
	$("#inner-result1").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax/detail-package.jsp?name=" + pName + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-result1").html(data);
		}
	});	
	addHistory("<a href='Javascript:loadPackage(\""+pName+"\")'>" + pName + "</a>");
}

function loadSynonym(sName) {
	$("#inner-result1").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax/detail-synonym.jsp?name=" + sName + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-result1").html(data);
		}
	});	
	addHistory("<a href='Javascript:loadSynonym(\""+sName+"\")'>" + sName + "</a>");
}

function loadTool(name) {
	$("#inner-result1").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax/detail-tool.jsp?name=" + name + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-result1").html(data);
			$('table.striped tbody tr:odd').addClass('odd');
			$('table.striped tbody tr:even').addClass('even');
		}
	});	
	addHistory("<a href='Javascript:loadTool(\""+name+"\")'>" + name + "</a>");
	

}


function selectAll(tab) {
	var form = "FORM_" + tab;
    $("#" + form +" input[type='checkbox']:not([disabled='disabled'])").attr('checked', true);
}

function selectNone(tab) {
	var form = "FORM_" + tab;
    $("#" + form + " input[type='checkbox']:not([disabled='disabled'])").attr('checked', false);
}

function buildQuery(table) {
	var sList = "";
	var boxes = $(":checkbox:checked");

	$(':checkbox:checked').each(function () {
		if (sList=='') sList = this.name;
		else
			sList += ", " + this.name;
	});
	
	if (sList=='') sList = "*";
	
	var query = "SELECT " + sList + "\n" + "FROM " + table
	
	//alert(query);
	//document.forms["query"].sql.value = query;
}

function runQuery(catalog,tab) {
	var sList = "";
	var form = "DIV_" + tab; 

	$("#" + form + ' :checkbox:checked').each(function () {
		if (sList=='') sList = this.name;
		else
			sList += ", " + this.name;
	});
	
	if (sList=='') sList = "*";
	
//	var query = "SELECT " + sList + "\n" + "FROM " + catalog + "." + tab + " A"
	var query = "SELECT " + sList + "\n" + "FROM " + tab + " A"
	
//	alert(query);
	$("#sql").val(query);
	$("#FORM_query").submit();
	//document.forms["FORM_query"].sql.value = query;
	//document.forms["FORM_query"].submit();
}


	
	function openTable(divName, tname, fkColName,formName) {
		$("#"+divName).html("<img src='image/loading.gif'/>");
		//document.getElementById(divName).innerHTML = "<img src='image/loading.gif'/>";
		//$("#"+divName).html("<img src='image/loading.gif'/>");
		$.ajax({
			url: "fktable.jsp?table=" + tname + "&fkColName=" + fkColName + "&formName=" + formName,
			success: function(data){
				//alert(data);
				$("#"+divName).html(data);
				//document.getElementById(divName).innerHTML = data;
				//$("#" + divName).html(data);
			}
		});	
	}

	function cleanPage() {
		$("#searchFilter").val("");
		$("#inner-table").html('');
		//$("#inner-result1").html('');
	}
	
	function setMode(mode) {
		var gotoUrl = "";
		var select = "";
		
		if (mode == "table") {
			gotoUrl = "ajax/list-table.jsp";
			select = "selectTable";
		} else if (mode == "view") {
			gotoUrl = "ajax/list-view.jsp";
			select = "selectView";
		} else if (mode == "package") {
			gotoUrl = "ajax/list-package.jsp";
			select = "selectPackage";
//		} else if (mode == "type") {
//			gotoUrl = "ajax/list-type.jsp";
//			select = "selectType";
		} else if (mode == "synonym") {
			gotoUrl = "ajax/list-synonym.jsp";
			select = "selectSynonym";
		} else if (mode == "tool") {
			gotoUrl = "ajax/list-tool.jsp";
			select = "selectTool";
		}

		$("#selectTable").css("font-weight", "");
		$("#selectView").css("font-weight", "");
		$("#selectPackage").css("font-weight", "");
//		$("#selectType").css("font-weight", "");
		$("#selectSynonym").css("font-weight", "");
		$("#selectTool").css("font-weight", "");

		cleanPage();
		$.ajax({
			url: gotoUrl,
			success: function(data){
				$("#inner-table").html(data);
			}
		});

		$("#" + select).css("font-weight", "bold");

		gMode = mode;
	}
	
	function searchWithFilter(filter) {
		var mode = gMode;
		var gotoUrl = "";
		
		if (mode == "table") {
			gotoUrl = "ajax/list-table.jsp?filter=" + filter;
		} else if (mode == "view") {
			gotoUrl = "ajax/list-view.jsp?filter=" + filter;
		} else if (mode == "package") {
			gotoUrl = "ajax/list-package.jsp?filter=" + filter;
		} else if (mode == "type") {
			gotoUrl = "ajax/list-type.jsp?filter=" + filter;
		} else if (mode == "synonym") {
			gotoUrl = "ajax/list-synonym.jsp?filter=" + filter;
		} else if (mode == "tool") {
			gotoUrl = "ajax/list-tool.jsp?filter=" + filter;
		}

		$.ajax({
			url: gotoUrl,
			success: function(data){
				$("#inner-table").html(data);
			}
		});
		
	}
	
	function clearField() {
		$("#searchFilter").val("");
		searchWithFilter('');
	}
	
	function clearField2() {
		$("#globalSearch").val("");
		$("#globalSearch").focus();
	}	
	
	function queryHistory() {
		$("#inner-result1").html("<img src='image/loading.gif'/>");
		
		$.ajax({
			url: "ajax/query-history.jsp",
			success: function(data){
				$("#inner-result1").html(data);
				$('table.striped tbody tr:odd').addClass('odd');
				$('table.striped tbody tr:even').addClass('even');
			}
		});
	}
	
	function aboutGenie() {
		
		
	}
	
	