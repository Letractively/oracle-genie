<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%

	Connect cn = (Connect) session.getAttribute("CN");
	
	if (cn==null) {
%>	
		Connection lost. <a href="Javascript:window.close()">Close</a>
<%
		return;
	}

%>
<select size=1 id="selectTable" name=""selectTable"" onChange="showTable(this.options[this.selectedIndex].value);"">
	<option></option>
<% for (int i=0; i<cn.getTables().size();i++) { %>
	<option value="<%=cn.getTable(i)%>"><%=cn.getTable(i)%></option>
<% } %>
</select>

<input id="input-table" size=30 value="" onChange="showTable(this.value)"/>

