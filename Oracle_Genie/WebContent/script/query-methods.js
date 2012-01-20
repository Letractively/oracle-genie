var doMode = 'copy';

	function download() {
		$("#form1").attr("action", "download.jsp");
		$("#form1").submit();
		$("#form1").attr("action", "query.jsp");
		//document.forms["form1"].action="download.jsp";
		//document.forms["form1"].submit();
		//document.forms["form1"].action="query.jsp";
	}
	
	function endsWith(str, suffix) {
    	return str.indexOf(suffix, str.length - suffix.length) !== -1;
	}
	
	function startsWith (str, prefix) {
		if( str.indexOf(prefix) == 0 ) return true;
   		return false;
	}
	
	function web() {
		$('#dataTable td')
			.each(
				function() {
					var value = $(this).html();
					if (startsWith(value.toLowerCase(), "http://") && (endsWith(value.toLowerCase(), ".jpg") || endsWith(value.toLowerCase(), ".gif") || endsWith(value.toLowerCase(), ".png"))) {
						value = "<img src='" + value + "'>" + "<br>" + value ;
						$(this).html(value);
					} else if (startsWith(value.toLowerCase(), "http://")) {
						value = "<br>" + "<a href='" + value + "' target=_blank>open</a>" + "<br>" + value ;
						$(this).html(value);
					} else if (startsWith(value.toLowerCase(), "www.")) {
						value = "<a href='http://" + value + "' target=_blank>open</a>" + "<br>" + value ;
						$(this).html(value);
					}
				}
			);
	}
	
	$.fn.hideCol = function(col){
	    // Make sure col has value
	    if(!col){ col = 1; }
	    $('tr td:nth-child('+col+'), tr th:nth-child('+col+')', this).hide();
	    return this;
	};	
	
	$.fn.showCol = function(col){
	    // Make sure col has value
	    if(!col){ col = 1; }
	    $('tr td:nth-child('+col+'), tr th:nth-child('+col+')', this).show();
	    return this;
	};	
	
	function hide(col) {
		$('table#dataTable').hideCol(col);
	}
	
	function show(col) {
		$('table#dataTable').showCol(col);
	}
	
	function hideInspectComment() {
		$('table#inspectTable').hideCol(3);
	}	
	
	function showTable(tbl) {
		$("#table-detail").append("<div id='wait'><img src='image/loading.gif'/></div>");
		
		$.ajax({
			url: "table_col.jsp?table=" + tbl + "&t=" + (new Date().getTime()),
			success: function(data){
				$("#table-detail").append(data);
				$("#wait").remove();
			}
		});	
	}

	function loadDataDiv(sql) {
		$("#data-div").append("<div id='wait'><img src='image/loading.gif'/></div>");
		$.ajax({
			type: 'POST',
			url: "ajax/qry.jsp?",
			data: $("#form1").serialize(),
			success: function(data){
				$("#data-div").append(data);
				$("#wait").remove();
				$(".inspect").colorbox({transition:"none", width:"800", height:"600"});
			}
		});	
	}
	
	function gotoPage(pageNo) {
		$("#pageNo").val(pageNo);
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		$.ajax({
			type: 'POST',
			url: "ajax/qry.jsp",
			data: $("#form1").serialize(),
			success: function(data){
				$("#data-div").append(data);
				$("#wait").remove();
				$(".inspect").colorbox({transition:"none", width:"800", height:"600"});
				hideIfAny();
			}
		});	
	}
	
	function showTableCols(tbl) {
		$("#tableColumns").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		$.ajax({
			url: "table_col2.jsp?table=" + tbl + "&t=" + (new Date().getTime()),
			success: function(data){
				$("#tableColumns").html(data);
				//$("#wait").remove();
			}
		});	
	}

	function setDoMode(mode) {
		var select = "";

		doMode = mode;

		$("#modeCopy").css("font-weight", "");
		$("#modeHide").css("font-weight", "");
		$("#modeSort").css("font-weight", "");
		$("#modeFilter").css("font-weight", "");

		if (mode == "copy") {
			select = "modeCopy";
		} else if (mode == "hide") {
			select = "modeHide";
		} else if (mode == "sort") {
			select = "modeSort";
		} else if (mode == "filter") {
			select = "modeFilter";
			filter('0');
		}
		
		$("#" + select).css("font-weight", "bold");
	}
	
	function doAction(val, idx) {
		if (doMode=='copy') {
			copyPaste(val);
		} else if (doMode=='hide') {
			var cols = $("#hideColumn").val();
			if (cols == "") cols = idx;
			else cols += "," + idx;
			
			$("#hideColumn").val(cols);
			hide(idx);
			$("#showAllCol").show();
		} else if (doMode=='sort') {
			sort(val);
		} else if (doMode=='filter') {
			filter(val);
		} else {
			alert("mode=" + doMode);
		}
	}

	function showAllColumn() {
		var hiddenCols = $("#hideColumn").val();
		if (hiddenCols != '') {
			var cols = hiddenCols.split(",");
			for(var i = 0;i<cols.length;i++){
				show(cols[i]);
			}
		}

		$("#showAllCol").hide();
		$("#hideColumn").val('');
	}
	
	function sort(col) {
		$("#pageNo").val(1);
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		var prevSortColumn = $("#sortColumn").val();
		var prevSortDirection = $("#sortDirection").val();
		var newSortDirection = "0";
		
		if (prevSortColumn==col && prevSortDirection=="0") { 
			newSortDirection = "1";  
		}
		$("#sortColumn").val(col);
		$("#sortDirection").val(newSortDirection);
		
		$.ajax({
			type: 'POST',
			url: "ajax/qry.jsp",
			data: $("#form1").serialize(),
			success: function(data){
				$("#data-div").append(data);
				$("#wait").remove();
				$(".inspect").colorbox({transition:"none", width:"800", height:"600"});
				hideIfAny();
			}
		});	
	}

	function filter(col) {
		$("#filter-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		$("#filterColumn").val(col);
		
		$.ajax({
			type: 'POST',
			url: "ajax/filter.jsp",
			data: $("#form1").serialize(),
			success: function(data){
				$("#filter-div").append(data);
				$("#wait").remove();
			}
		});	
	}	
	
	function applyFilter(value) {
		$("#pageNo").val(1);
		$("#filterValue").val(value);
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		$.ajax({
			type: 'POST',
			url: "ajax/qry.jsp",
			data: $("#form1").serialize(),
			success: function(data){
				$("#data-div").append(data);
				$("#wait").remove();
				$(".inspect").colorbox({transition:"none", width:"800", height:"600"});
				hideIfAny();
			}
		});	
	}

	function hideIfAny() {
		var hiddenCols = $("#hideColumn").val();
		if (hiddenCols != '') {
			var cols = hiddenCols.split(",");
			for(var i = 0;i<cols.length;i++){
//				alert('before ' + cols[i]);
				hide(cols[i]);
//				alert('after ' + cols[i]);
			}
		}
	}

	function rowsPerPage(rows) {
		$("#rowsPerPage").val(rows);
		$("#pageNo").val(1);
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		$.ajax({
			type: 'POST',
			url: "ajax/qry.jsp",
			data: $("#form1").serialize(),
			success: function(data){
				$("#data-div").append(data);
				$("#wait").remove();
				$(".inspect").colorbox({transition:"none", width:"800", height:"600"});
				hideIfAny();
			}
		});	
	}

	function removeFilter() {
		$("#pageNo").val(1);
		$("#filter-div").html('');
		$("#filterValue").val('');
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		$.ajax({
			type: 'POST',
			url: "ajax/qry.jsp",
			data: $("#form1").serialize(),
			success: function(data){
				$("#data-div").append(data);
				$("#wait").remove();
				$(".inspect").colorbox({transition:"none", width:"800", height:"600"});
			}
		});	
	}
	
	function copyPaste(val) {
		$("#sql").insertAtCaret(" " + val);
	}

	function removeDiv(divId) {
		$("#"+divId).remove();
	}	
	
$.fn.insertAtCaret = function (tagName) {
	return this.each(function(){
		if (document.selection) {
			//IE support
			this.focus();
			sel = document.selection.createRange();
			sel.text = tagName;
			this.focus();
		}else if (this.selectionStart || this.selectionStart == '0') {
			//MOZILLA/NETSCAPE support
			startPos = this.selectionStart;
			endPos = this.selectionEnd;
			scrollTop = this.scrollTop;
			this.value = this.value.substring(0, startPos) + tagName + this.value.substring(endPos,this.value.length);
			this.focus();
			this.selectionStart = startPos + tagName.length;
			this.selectionEnd = startPos + tagName.length;
			this.scrollTop = scrollTop;
		} else {
			this.value += tagName;
			this.focus();
		}
	});
};	
	
function selectOption(select_id, option_val) {
    $('#'+select_id+' option:selected').removeAttr('selected');
    $('#'+select_id+' option[value='+option_val+']').attr('selected','selected');       
}

function linkPk(tname, cname, value, backTable) {
	$.ajax({
		url: "ajax/pk-link-query.jsp?table=" + tname + "&col=" + cname +
			"&backTable=" + backTable +
			"&key=" + value + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#pkLink").html(data);
		}
	});		
}

function backTolinkPk(tname, value) {
	$.ajax({
		url: "ajax/pk-link.jsp?table=" + tname +  
			"&key=" + value + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#pkLink").html(data);
		}
	});		
}

