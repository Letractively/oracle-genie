<%@ page language="java" 
	import="java.util.*" 
	import="spencer.genie.Connect" 
	pageEncoding="ISO-8859-1"
%>

<%
	String url = request.getParameter("url");
	String username = request.getParameter("username");
	String password = request.getParameter("password");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Slide Show</title>
    <link rel='stylesheet' type='text/css' href='css/style.css'> 
    <link rel='stylesheet' type='text/css' href='css/slideshow.css'> 
    <script src="script/jquery.js" type="text/javascript"></script>

<script type="text/javascript">
function slideSwitch() {
    var $active = $('#slideshow IMG.active');

    if ( $active.length == 0 ) $active = $('#slideshow IMG:last');

    var $next =  $active.next().length ? $active.next()
        : $('#slideshow IMG:first');

    $active.addClass('last-active');

    $next.css({opacity: 0.0})
        .addClass('active')
        .animate({opacity: 1.0}, 1000, function() {
            $active.removeClass('active last-active');
        });
}

$(function() {
    setInterval( "slideSwitch()", 2000 );
});

</script>
    
  </head>
  
  <body>
  
<div id="slideshow">
    <img src="image/nature1.jpg" alt="" class="active" />
    <img src="image/nature2.jpg" alt=""/>
    <img src="image/nature3.jpg" alt=""/>
    <img src="image/nature4.jpg" alt=""/>
    <img src="image/nature5.jpg" alt=""/>
</div>


  </body>
</html>



