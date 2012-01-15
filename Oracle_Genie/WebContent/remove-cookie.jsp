<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="spencer.genie.Connect" 
	pageEncoding="ISO-8859-1"
%>

<%!
	public String getCookie(HttpServletRequest request, String cookieName) {
		String value = null;
		
		Cookie cookies [] = request.getCookies ();
		Cookie myCookie = null;
		if (cookies != null) {
			for (int i = 0; i < cookies.length; i++) {
				if (cookies [i].getName().equals (cookieName)) {
					myCookie = cookies[i];
					break;
				}
			}	
		}
		
		if (myCookie != null) value = myCookie.getValue();		
		return value;
	}
%>

<%
	String value = request.getParameter("value");
	
	// get cookie
	String oldUrls = getCookie(request, "url");
		
	String newValue = oldUrls.replace(value, "").trim();
	Cookie cookie = new Cookie ("url", newValue);
	cookie.setMaxAge(365 * 24 * 60 * 60);
	response.addCookie(cookie);
		
	// redirect to homepage
	response.sendRedirect("login.jsp");
%>
