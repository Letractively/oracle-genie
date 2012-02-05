	$.fn.showCol = function(col){
	    // Make sure col has value
	    if(!col){ col = 1; }
	    $('tr td:nth-child('+col+'), tr th:nth-child('+col+')', this).show();
	    return this;
	};	
	$.fn.hideCol = function(col){
	    // Make sure col has value
	    if(!col){ col = 1; }
	    $('tr td:nth-child('+col+'), tr th:nth-child('+col+')', this).hide();
	    return this;
	};		
	function hideColumn(tableId, col) {
		$('table#'+tableId).hideCol(col);
    }

	function showColumn(tableId, col) {
		$('table#'+tableId).showCol(col);
    }

	function loadData(id, showFK) {
		var sql = $("#sql-" + id).html();
		var divName = "div-" + id;
		
		var imgSrc = $("#img-" + id).attr("src");
		//alert(imgSrc);
		if (imgSrc.indexOf("open") > 0) {
			$("#img-" + id).attr("src","image/close.jpg");
		} else {
			$("#img-" + id).attr("src","image/open.jpg");
			$("#" + divName).slideUp();
			return;
		}

		if ($("#" + divName).html().length > 10){
    		$("#" + divName).slideDown();
    		return;
    	}
		
		$("#sql").val(sql);
		$("#id").val(id);
		$("#pageNo").val("1");

		$("#showFK").val(showFK);
		$("#" + divName).hide();
		$.ajax({
			type: 'POST',
			url: "ajax/qry-simple.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#" + divName).html(data);
				$('.simplehighlight').hover(function(){
					$(this).children().addClass('datahighlight');
				},function(){
					$(this).children().removeClass('datahighlight');
				});
				$("#" + divName).slideDown();
			}
		});	
    	
	}

	function openQuery(id) {
		var sql = $("#sql-" + id).html();
		var divName = "div-" + id;
		//alert(sql);
		
		$("#sql").val(sql);
		document.form0.submit();
	}

    $(document).ready(function() {
		$('.simplehighlight').hover(function(){
			$(this).children().addClass('datahighlight');
		},function(){
			$(this).children().removeClass('datahighlight');
		});
    });	    

    function showAllColumn() {
		$("table ").each(function() {
			var divName = $(this).attr('id');
			if (divName.indexOf("table-")>=0) {
				showAllColumnTable(divName);
			}
		});
    }

    function showAllColumnTable(divName) {
   	 	var colCnt = numCol(divName);

   	    for (var col = 0; col < colCnt; col++) {
   	    	showColumn(divName, col+1);
   	    }
	}
	
	function hideNullColumn() {
		$("table ").each(function() {
			var divName = $(this).attr('id');
			if (divName.indexOf("table-")>=0) {
				hideNullColumnTable(divName);
			}
		});
	}
	
    function hideNullColumnTable(divName) {
    	var rowCount = $('#' + divName + ' tr').length;
    	
    	//if (rowCount > 2) return;
    	
   	    //var row = 1;
   	 	var hideCol = []; 
   	 	var colCnt = numCol(divName);
   	 	//alert(rowCount + "," +colCnt);
    	for (var col = 0; col < colCnt; col++) {
   	 		var nullValue = true;
       	 	for (var row=1; row<rowCount;row++) {
	    		var value = $("#" + divName).children().children()[row].children[col].innerHTML;
    			if (value.indexOf(">null<")<=0) {
   				nullValue = false;
	    		}
   	    	}
   	    	if (nullValue) hideCol.push(col+1);
   	    }
   	    
   	 	for (var i = 0, l = hideCol.length; i < l; ++i) {
   	 		//alert('hide ' + hideCol[i] );
   	 		hideColumn(divName, hideCol[i]);
   	    }
   	    
    }
    
    function numCol(table) {
        var maxColNum = 0;

        var i=0;
        var trs = $("#"+table).find("tr");

        for ( i=0; i<trs.length; i++ ) {
            maxColNum = Math.max(maxColNum, getColForTr(trs[i]));
        }

        return maxColNum;
    }
	
    function getColForTr(tr) {

        var tds = $(tr).find("td");

        var numCols = 0;

        var i=0;
        for ( i=0; i<tds.length; i++ ) {
            var span = $(tds[i]).attr("colspan");

            if ( span )
                numCols += parseInt(span);
            else {
                numCols++;
            }
        }
        return numCols;
    }

    function toggleFK() {
    	$('#div-fk').toggle();
    }

    function toggleChild() {
    	$('#div-child').toggle();
    }

    function toggleText(arg1, arg2) {
    	$('#'+arg1).toggle();
    	$('#'+arg2).toggle();
    }
    
	function gotoPage(id, pageNo) {
		$("#pageNo").val(pageNo);

		reloadData(id);
	}
	    
	function reloadData(id) {
		var divName = "div-" + id;
		var sql = $("#sql-" + id).html();
		$("#sql").val(sql);
		$("#id").val(id);

		$.ajax({
			type: 'POST',
			url: "ajax/qry-simple.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#"+divName).html(data);
				$(".inspect").colorbox({transition:"none", width:"800", height:"600"});
				//hideIfAny(divName);
				
				$('.simplehighlight').hover(function(){
					$(this).children().addClass('datahighlight');
				},function(){
					$(this).children().removeClass('datahighlight');
				});
			}
		});	
	}

	function hideIfAny(divName) {
		var hiddenCols = $("#hideColumn").val();
		if (hiddenCols != '') {
			var cols = hiddenCols.split(",");
			for(var i = 0;i<cols.length;i++){
				hide(cols[i]);
			}
		}
	}
	
	function setColumnMode(id, mode) {
		$("#modeHide-"+id).css("background-color", "");
		$("#modeSort-"+id).css("background-color", "");
		$("#modeHide-"+id).css("font-weight", "");
		$("#modeSort-"+id).css("font-weight", "");

		$("#mode-"+id).html(mode);
//		alert('mode=' + mode);
//		alert('mode2=' + $("#mode-"+id).html());
		if (mode =="sort") {
			$("#modeSort-"+id).css("background-color", "yellow");
			$("#modeSort-"+id).css("font-weight", "bold");
		} else if (mode == "hide") {
			$("#modeHide-"+id).css("background-color", "yellow");
			$("#modeHide-"+id).css("font-weight", "bold");
		}
		
	}
	
	function setColumn(id, colName, colIdx) {
		var mode = $("#mode-"+id).html();
//		alert(mode);
		
		if (mode=='hide') {
			hideColumn('table-'+id, colIdx);
		} else if (mode=='sort') {
			//alert('sort');
			sort(id, colName);
		}
	}
	
	function sort(id, col) {
		$("#pageNo").val(1);
		var prevSortColumn = $("#sortColumn").val();
		var prevSortDirection = $("#sortDirection").val();
		var newSortDirection = "0";
		
		if (prevSortColumn==col && prevSortDirection=="0") { 
			newSortDirection = "1";  
		}
		$("#sortColumn").val(col);
		$("#sortDirection").val(newSortDirection);
		
		reloadData(id);
	}	

	function hideIfAny(id) {
		var hiddenCols = $("#hideColumn").val();
		if (hiddenCols != '') {
			var cols = hiddenCols.split(",");
			for(var i = 0;i<cols.length;i++){
				hide(cols[i]);
			}
		}
	}	
	
	function searchTable(id, key) {
		$("#pageNo").val(1);
		$("#searchValue").val(key);

		reloadData(id);
	}

	function clearSearch(id) {
		$("#search"+id).val("");
		$("#pageNo").val(1);
		searchTable(id, '');
	}
	