<%@ page language="java" 
	import="java.util.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>


<%
	session.removeAttribute("CN");

	String cookieName = "url";
	String email = "";
	Cookie cookies [] = request.getCookies ();
	Cookie myCookie = null;
	if (cookies != null) {
		for (int i = 0; i < cookies.length; i++) {
			if (cookies [i].getName().equals (cookieName)) {
				myCookie = cookies[i];
				break;
			}
		}	
		for (int i = 0; i < cookies.length; i++) {
			if (cookies [i].getName().equals ("email")) {
				email = cookies[i].getValue();
				break;
			}
		}	
	}
	
	String cookieUrls = "";
	if (myCookie != null) cookieUrls = myCookie.getValue();
	
	// default login info
	String initJdbcUrl = "jdbc:oracle:thin:@localhost:1521/SID";
	String initUserName = "userid";
	
	// get the last login from cookie
	if (cookieUrls != null && cookieUrls.length()>1) {
		StringTokenizer st = new StringTokenizer(cookieUrls);
	    if (st.hasMoreTokens()) {
	    	String token = st.nextToken();
	    	int idx = token.indexOf("@");
	    	initUserName = token.substring(0, idx);
	    	initJdbcUrl = token.substring(idx+1);
	    }
	}
	
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Genie</title>

	<meta name="description" content="Genie is an open-source, web based oracle database schema navigator." />
	<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
	<meta name="author" content="Spencer Hwang" />

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script type="text/javascript">
    	function setLogin(jdbcUrl, userId) {
    		$("#url").val(jdbcUrl);
    		$("#username").val(userId);
    	}
    	
    </script>
  </head>
  
  <body>
	<img src="http://www.cpas.com/images/layout_01.jpg">
  <img src="image/genie2.jpg" title="Version <%= Util.getVersionDate() %>"/>
    <h2>Welcome to CPAS Genie.</h2>

<b>Connect to database</b>
<select id="dbSelect" onchange="setLogin(this.options[this.selectedIndex].value, '');">
<option></option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/ACAW">S-ORA-001.ACAW</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/BMO">S-ORA-001.BMO</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/CIBCGIC">S-ORA-001.CIBCGIC</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/COGNOS">S-ORA-001.COGNOS</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/CQ2">S-ORA-001.CQ2</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/DALLAS">S-ORA-001.DALLAS</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/MCERA">S-ORA-001.MCERA</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/OE">S-ORA-001.OE</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/OEFREEZ2">S-ORA-001.OEFREEZ2</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/PSAC">S-ORA-001.PSAC</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/RKLARGUS">S-ORA-001.RKLARGUS</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/SASKATN">S-ORA-001.SASKATN</option>
<option value="jdbc:oracle:thin:@s-ora-001.cpas.com:1521/TEMPLATE">S-ORA-001.TEMPLATE</option>
<option></option>

<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1526/AIARC">S-ORA-002.AIARC</option>
<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1526/GOODYEAR">S-ORA-002.GOODYEAR</option>
<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1521/RKLDBV3">S-ORA-002.RKLDBV3</option>
<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1521/SDCDEV">S-ORA-002.SDCDEV</option>
<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1521/SDCERA">S-ORA-002.SDCERA</option>
<option value="jdbc:oracle:thin:@s-ora-002.cpas.com:1521/SSGQA">S-ORA-002.SSGQA</option>
<option></option>

<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/BALTIMOR">S-ORA-003.BALTIMOR</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/CAAT">S-ORA-003.CAAT</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/CAPITAL">S-ORA-003.CAPITAL</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1521/DEV10G">S-ORA-003.DEV10G</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1521/MPI">S-ORA-003.MPI</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/NDRIO">S-ORA-003.NDRIO</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/NTCA">S-ORA-003.NTCA</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PAOC">S-ORA-003.PAOC</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1521/PENSCO">S-ORA-003.PENSCO</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PEPP">S-ORA-003.PEPP</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PMRS">S-ORA-003.PMRS</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/SIGMA">S-ORA-003.SIGMA</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1521/VANGUARD">S-ORA-003.VANGUARD</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/VCENTER">S-ORA-003.VCENTER</option>
<option value="jdbc:oracle:thin:@s-ora-003.cpas.com:1526/VUPDATE">S-ORA-003.VUPDATE</option>
<option></option>

<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/ACTRA">S-ORA-004.ACTRA</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/CCCERA">S-ORA-004.CCCERA</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/CQDEV">S-ORA-004.CQDEV</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/GENDYN">S-ORA-004.GENDYN</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/IBT">S-ORA-004.IBT</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/INTEGRA">S-ORA-004.INTEGRA</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/KCERA">S-ORA-004.KCERA</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/KEYSTONE">S-ORA-004.KEYSTONE</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/OEFROZEN">S-ORA-004.OEFROZEN</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/PMRS">S-ORA-004.PMRS</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/PPL">S-ORA-004.PPL</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/SAXON55">S-ORA-004.SAXON55</option>
<option value="jdbc:oracle:thin:@s-ora-004.cpas.com:1521/SVB">S-ORA-004.SVB</option>
<option></option>

<option value="jdbc:oracle:thin:@s-ora-005.cpas.com:1521/MERCED">S-ORA-005.MERCED</option>
<option value="jdbc:oracle:thin:@s-ora-005.cpas.com:1521/NTCA">S-ORA-005.NTCA</option>
<option value="jdbc:oracle:thin:@s-ora-005.cpas.com:1521/TAIKANG">S-ORA-005.TAIKANG</option>
<option value="jdbc:oracle:thin:@s-ora-005.cpas.com:1521/TCERADEV">S-ORA-005.TCERADEV</option>
<option value="jdbc:oracle:thin:@s-ora-005.cpas.com:1521/WYATT">S-ORA-005.WYATT</option>
<option></option>

<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/AFM">S-ORA-006.AFM</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/APA">S-ORA-006.APA</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/ARGUS">S-ORA-006.ARGUS</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/CIBC">S-ORA-006.CIBC</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/CIBC2">S-ORA-006.CIBC2</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/COR">S-ORA-006.COR</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/DALLAS">S-ORA-006.DALLAS</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/GOODYEAR">S-ORA-006.GOODYEAR</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/LUTHERAN">S-ORA-006.LUTHERAN</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/NAV">S-ORA-006.NAV</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/PENSCO">S-ORA-006.PENSCO</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/RECKEEP">S-ORA-006.RECKEEP</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/SAXON">S-ORA-006.SAXON</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/SEARSDB">S-ORA-006.SEARSDB</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/SEARSDC">S-ORA-006.SEARSDC</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1526/TTC">S-ORA-006.TTC</option>
<option value="jdbc:oracle:thin:@s-ora-006.cpas.com:1521/UNILEASE">S-ORA-006.UNILEASE</option>

</select>

	<form action="connect_new.jsp" method="POST">
    <table border=0>
    <tr>
    	<td>JDBC URL</td>
    	<td><input size=60 name="url" id="url" value="<%= initJdbcUrl %>"/></td>
    </tr>
    <tr>
    	<td>User Name</td>
    	<td><input name="username" id="username" value="<%= initUserName %>"/></td>
    </tr>
    <tr>
    	<td>Password</td>
    	<td><input name="password" type="password"/></td>
    </tr>
    <tr>
    	<td>Your Email</td>
    	<td><input name="email" id="email" value="<%= email %>"/> Genie will send query logs by email.</td>
    </tr>
    </table>
    <input type="submit" value="Connect"/>
	</form>

<br/>


<div>

<%
	StringTokenizer st = new StringTokenizer(cookieUrls);
    while (st.hasMoreTokens()) {
    	String token = st.nextToken();
    	int idx = token.indexOf("@");
    	String userid = token.substring(0, idx);
    	String jdbcUrl = token.substring(idx+1);
%>
<a href="javascript:setLogin('<%= jdbcUrl %>', '<%= userid %>')"><%= token %></a>
<a href="remove-cookie.jsp?value=<%= token %>"><img border=0 src="image/clear.gif"></a>
<br/>

<%
	}
%>
</div>

<br/><hr>
<b>CPAS Databases:</b><br/>

<div style="margin: 20px; padding:5px; width:600px; height:300px; overflow: scroll; border: 1px solid #666666;">

ACTRA
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-004.CPAS.COM:1521/ACTRA', 'cpasdba')">cpasdba@jdbc:oracle:thin:@s-ora-004.CPAS.COM:1521/ACTRA</a></li>
<br/>

AFM (MPF)
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-006.cpas.com:1521/AFM', '')">@jdbc:oracle:thin:@s-ora-006.cpas.com:1521/AFM</a></li>
<br/>

AIARC
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-002.cpas.com:1521/AIARC', 'aiarc')">aiarc@jdbc:oracle:thin:@s-ora-002.cpas.com:1521/AIARC</a></li>
<br/>

APA
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-006.CPAS.COM:1526/APA', 'apa_client')">apa_client@jdbc:oracle:thin:@s-ora-006.CPAS.COM:1526/APA</a></li>
<br/>

BALTIMOR
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1526/BALTIMOR', 'client_55bld')">client_55bld@jdbc:oracle:thin:@s-ora-003.cpas.com:1526/BALTIMOR</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1526/BALTIMOR', 'client_55blt')">client_55blt@jdbc:oracle:thin:@s-ora-003.cpas.com:1526/BALTIMOR</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1526/BALTIMOR', 'client_55blm')">client_55blm@jdbc:oracle:thin:@s-ora-003.cpas.com:1526/BALTIMOR</a></li>
<br/>

BMO
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-001.cpas.com:1521/BMO', 'client_54')">client_54@jdbc:oracle:thin:@s-ora-001.cpas.com:1521/BMO</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-001.cpas.com:1521/BMO', 'client_54_qa')">client_54_qa@jdbc:oracle:thin:@s-ora-001.cpas.com:1521/BMO</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-002.cpas.com:1521/SSGQA', 'client_54')">client_54@jdbc:oracle:thin:@s-ora-002.cpas.com:1521/SSGQA</a></li>
<br/>

CAPITAL
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1526/CAPITAL', 'test_capital')">test_capital@jdbc:oracle:thin:@s-ora-003.cpas.com:1526/CAPITAL</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1526/CAPITAL', 'prd_capital')">prd_capital@jdbc:oracle:thin:@s-ora-003.cpas.com:1526/CAPITAL</a></li>
<br/>

CCCERA
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-004.cpas.com:1521/CCCERA', 'client_54_dev')">client_54_dev@jdbc:oracle:thin:@s-ora-004.cpas.com:1521/CCCERA</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-004.cpas.com:1521/CCCERA', 'client_54_prd')">client_54_prd@jdbc:oracle:thin:@s-ora-004.cpas.com:1521/CCCERA</a></li>
<br/>

CIBC
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1521/IMPTEST', 'cpasdba')">cpasdba@jdbc:oracle:thin:@S-ORA-003.cpas.com:1521/IMPTEST</a></li>
<br/>

COR
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-006.CPAS.COM:1526/COR', 'cor_client_577')">cor_client_577@jdbc:oracle:thin:@s-ora-006.CPAS.COM:1526/COR</a></li>
<br/>

DALLAS
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-001.cpas.com:1521/DALLAS', 'client_55dl')">client_55dl@jdbc:oracle:thin:@s-ora-001.cpas.com:1521/DALLAS</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-001.cpas.com:1521/DALLAS', 'client_55d')">client_55d@jdbc:oracle:thin:@s-ora-001.cpas.com:1521/DALLAS</a></li>
<br/>

GOODYEAR
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-002.cpas.com:1526/GOODYEAR', 'gy_client')">gy_client@jdbc:oracle:thin:@s-ora-002.cpas.com:1526/GOODYEAR</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-006.cpas.com:1526/GOODYEAR', 'gy_client')">gy_client@jdbc:oracle:thin:@s-ora-006.cpas.com:1526/GOODYEAR</a></li>
<br/>

KCERA
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-004.cpas.com:1521/KCERA', 'client_55kcd')">client_55kcd@jdbc:oracle:thin:@s-ora-004.cpas.com:1521/KCERA</a></li>
<br/>

MCERA
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-001.cpas.com:1521/MCERA', 'client_55mc')">client_55mc@jdbc:oracle:thin:@s-ora-001.cpas.com:1521/MCERA</a></li>
<br/>

MERCED
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-005.cpas.com:1521/MERCED', 'CLIENT_55MD')">CLIENT_55MD@jdbc:oracle:thin:@s-ora-005.cpas.com:1521/MERCED</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-005.cpas.com:1521/MERCED', 'CLIENT_55MDT')">CLIENT_55MDT@jdbc:oracle:thin:@s-ora-005.cpas.com:1521/MERCED</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-005.cpas.com:1521/MERCED', 'CLIENT_55MDM')">CLIENT_55MDM@jdbc:oracle:thin:@s-ora-005.cpas.com:1521/MERCED</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-005.cpas.com:1521/MERCED', 'CLIENT_55MDC')">CLIENT_55MDC@jdbc:oracle:thin:@s-ora-005.cpas.com:1521/MERCED</a></li>
<br/>

PEPP
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PEPP', 'test_pepp')">test_pepp@jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PEPP</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PEPP', 'prd_pepp')">prd_pepp@jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PEPP</a></li>
<br/>

PMRS
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PMRS', 'pmrs_client')">pmrs_client@jdbc:oracle:thin:@s-ora-003.cpas.com:1526/PMRS</a></li>
<br/>

PPL
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-002.cpas.com:1521/WE8MSWIN', 'client_54')">client_54@jdbc:oracle:thin:@s-ora-002.cpas.com:1521/WE8MSWIN</a></li>
<br/>

RKLARGUS
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-001.cpas.com:1521/RKLARGUS', 'client_55')">client_55@jdbc:oracle:thin:@s-ora-001.cpas.com:1521/RKLARGUS</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-001.cpas.com:1521/RKLARGUS', 'client_55_sit')">client_55_sit@jdbc:oracle:thin:@s-ora-001.cpas.com:1521/RKLARGUS</a></li>
<br/>

TCERA
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-005.cpas.com:1521/TCERADEV', 'client_55tc')">client_55tc@jdbc:oracle:thin:@s-ora-005.cpas.com:1521/TCERADEV</a></li>
<li style="margin-left: 100px;"><a href="javascript:setLogin('jdbc:oracle:thin:@s-ora-005.cpas.com:1521/TCERADEV', 'client_55tcm')">client_55tcm@jdbc:oracle:thin:@s-ora-005.cpas.com:1521/TCERADEV</a></li>
<br/>


</div>

<br/>
Please contact Spencer Hwang(<a href="mailto:spencerh@cpas.com">spencerh@cpas.com</a>) to add more database locations.

</div>

<br/><br/><br/><br/><br/>
  </body>
</html>
