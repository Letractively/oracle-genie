<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");

	String table = request.getParameter("table");
	String key = request.getParameter("key");
	List<String> refTabs = cn.getReferencedTables(table);

	String sql = cn.getPKLinkSql(table, key);
	Query q = QueryCache.getInstance().getQueryObject(sql);
	if (q==null) {
		q = new Query(cn, sql);
		QueryCache.getInstance().addQuery(sql, q);
	}
	// Foreign keys - For FK lookup
	List<ForeignKey> fks = cn.getForeignKeys(table);
	Hashtable<String, String>  linkTable = new Hashtable<String, String>();

	List<String> fkLinkTab = new ArrayList<String>();
	List<String> fkLinkCol = new ArrayList<String>();
	
	for (int i=0; i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String linkCol = cn.getConstraintCols(rec.constraintName);
		String rTable = cn.getTableNameByPrimaryKey(rec.rConstraintName);
		
		fkLinkTab.add(rTable);
		fkLinkCol.add(linkCol);
	}
	
%>


<html>
<head> 
	<title>Data Drill Down - Genie</title>
    <script src="script/jquery.js" type="text/javascript"></script>

    <script src="script/jquery.colorbox-min.js"></script>
    <script src="script/query-methods.js" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
    <link rel="stylesheet" href="css/colorbox.css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    
    <script type="text/javascript">

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

	function loadData(tname) {
		tname = tname.replace(".", "-");
		var sql = $("#sql-" + tname).html();
		var divName = "div-" + tname;
		
		var imgSrc = $("#img-" + tname).attr("src");
		//alert(imgSrc);
		if (imgSrc.indexOf("open") > 0) {
			$("#img-" + tname).attr("src","image/close.jpg");
		} else {
			$("#img-" + tname).attr("src","image/open.jpg");
			$("#" + divName).slideUp();
			return;
		}
/*
		if ($("#" + divName).length > 10){
    		$("#" + divName).toggle();
    		return;
    	}
*/    	
    	$("#sql").val(sql);
		//alert(sql);
		$("#" + divName).append("<div id='wait'><img src='image/loading.gif'/></div>");
		
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

	function openQuery(tname) {
		tname = tname.replace(".", "-");
		var sql = $("#sql-" + tname).html();
		var divName = "div-" + tname;
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

	function showAllColumn(tname) {
    	var divName = 'dataTable-' + tname;
   	 	var colCnt = numCol(divName);

   	    for (var col = 0; col < colCnt; col++) {
   	    	showColumn(divName, col+1);
   	    }
	}
	
    function hideNull(tname) {
    	var divName = 'dataTable-' + tname;
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
    </script>
</head> 

<body>
<table>
<td><br><img src="image/icon_query.png"/></td>
<td><%= cn.getUrlString() %></td>
</table>



<b><%= table %></b>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=table%>')""><img src="image/view.png"/></a>
&nbsp;<a href="Javascript:hideNull('<%= table%>')">Hide null</a>
&nbsp;<a href="Javascript:showAllColumn('<%= table%>')">Show all</a>
<div style="display: none;" id="sql-<%=table.replaceAll("\\.", "-")%>"><%= sql%></div>
<br/>
<div id="data-div">
<jsp:include page="ajax/qry-simple.jsp">
	<jsp:param value="<%= sql%>" name="sql"/>
	<jsp:param value="0" name="dataLink"/>
</jsp:include>
</div>
<br/>
<hr>

<%
	for (int i=0; i<fkLinkTab.size(); i++) {
		String ft = fkLinkTab.get(i);
		String fc = fkLinkCol.get(i);
		
		String keyValue = null;
		String[] colnames = fc.split("\\,");
		for (int j=0; j<colnames.length; j++) {
			String x = colnames[j].trim();
			String v = q.getValue(x);
			System.out.println("x,v=" +x +"," + v);
			if (keyValue==null)
				keyValue = v;
			else
				keyValue += "^" + v;
		}
		
		String fsql = cn.getPKLinkSql(ft, keyValue);
%>
&nbsp;&nbsp;&nbsp;&nbsp;
<a href="javascript:loadData('<%=ft%>')"><b><%= ft %></b> <img id="img-<%=ft.replaceAll("\\.", "-")%>" src="image/open.jpg"></a>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=ft%>')""><img src="image/view.png"/></a>
&nbsp;<a href="Javascript:hideNull('<%= ft%>')">Hide null</a>
&nbsp;<a href="Javascript:showAllColumn('<%= ft%>')">Show all</a>
<div style="display: none;" id="sql-<%=ft.replaceAll("\\.", "-")%>"><%= fsql%></div>
<div id="div-<%=ft.replaceAll("\\.", "-")%>" style="margin-left: 20px; display: none;"></div>
<br/>
<% } %>


<div style="display: none;">
<form name="form0" id="form0" action="query.jsp">
<input id="sql" name="sql" type="hidden" value=""/>
<input id="dataLink" name="dataLink" type="hidden" value="1"/>
</form>
</div>

<hr>
<%

	// Primary Key for PK Link
	String pkName = cn.getPrimaryKeyName(table);
	String pkCols = null;
	String pkColName = null;
	int pkColIndex = -1;
	if (pkName != null) {
		pkCols = cn.getConstraintCols(pkName);
		int colCount = Util.countMatches(pkCols, ",") + 1;
		pkColName = pkCols;
	}

	for (int i=0; i<refTabs.size(); i++) {
		String refTab = refTabs.get(i);
		int recCount = cn.getPKLinkCount(refTab, pkColName, key);
		if (recCount==0) continue;
		String refsql = cn.getRelatedLinkSql(refTab, pkColName, key);

%>

&nbsp;&nbsp;&nbsp;&nbsp;
<a href="javascript:loadData('<%=refTab%>')"><b><%= refTab %></b> (<%= recCount %>) <img id="img-<%=refTab%>" src="image/open.jpg"></a>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=refTab%>')""><img src="image/view.png"/></a>
&nbsp;<a href="Javascript:hideNull('<%= refTab%>')">Hide null</a>
&nbsp;<a href="Javascript:showAllColumn('<%= refTab%>')">Show all</a>
<div style="display: none;" id="sql-<%=refTab.replaceAll("\\.", "-")%>"><%= refsql%></div>
<div id="div-<%=refTab%>" style="margin-left: 20px; display: none;"></div>
<br/>
<%	
	}	
%>

<br/><br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>


<script type="text/javascript">
$(document).ready(function() {
<%
	for (int i=0; i<fkLinkTab.size(); i++) {
		String ft = fkLinkTab.get(i);
%>
	loadData('<%=ft%>');
<%
	}

	for (int i=0; i<refTabs.size(); i++) {
		String refTab = refTabs.get(i);
		int recCount = cn.getPKLinkCount(refTab, pkColName, key);
		if (recCount==0) continue;		
%>
loadData('<%=refTab%>');
<%
	}
%>
});	    
</script>

</body>
</html>

