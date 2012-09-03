(:~ 
: trees as svg
: @author andy bunce
: @since sept 2012
:)

module namespace web = 'apb.hedge.web';
declare default function namespace 'apb.hedge.web'; 
import module namespace tree = 'apb.tree' at "hedgetree/treedraw.xqm";
declare namespace rest = 'http://exquery.org/ns/restxq';


declare 
%rest:GET %rest:path("hedge") 
%output:method("html5")
%rest:form-param("hedge","{$hedge}","{github|https://github.com/apb2006/hedgetree}(ab({tree|#treexml}))") 
function hedge($hedge) {
	let $ehedge:=fn:encode-for-uri($hedge)
	 
	let $xml:=try{
	           tree:hedge2xml($hedge)
		      }catch * {
			  <node label="{$err:description}"/>
			  }
	let $layout:=tree:layout($xml,1)
	let $svg:=tree:svg($layout)
	 
	return <html>
	<head>
		<title>hedge/tree UI</title>
<script type="text/javascript"><![CDATA[
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-34544921-1']);
  _gaq.push(['_setDomainName', 'rhcloud.com']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
]]></script>
		</head>
		<body>
		<h1>Drawing trees with XQuery and SVG
		 </h1>
		 <form method="get" action="./hedge">
		 <p>
		 Enter a  string representing a tree in the form below; use letters for nodes and () to enclose subnodes. Use {{...}} for multi character names.
		 {{name|href}} will create a link.
		 <p> Source: @github:<iframe src="http://ghbtns.com/github-btn.html?user=apb2006&amp;repo=hedgetree&amp;type=watch"
      allowtransparency="true" frameborder="0" scrolling="0" width="62px" height="20px"></iframe>, Author:
     <iframe title="Twitter Follow Button" style="width: 140px; height: 20px;" class="twitter-follow-button" 
     src="http://platform.twitter.com/widgets/follow_button.html?id=twitter-widget-2&amp;lang=en&amp;screen_name=apb1704&amp;show_count=false&amp;show_screen_name=true&amp;size=m" 
     allowtransparency="true" scrolling="no" frameborder="0"></iframe>.
     </p>       
		  </p>
		  <p>
		  Examples: <a href="?hedge=a(bcd(ef))">a(bcd(ef))</a>, buggy: <a href="?hedge=a(bcd)e(fgh)">a(bcd)e(fgh)</a>
		  </p>
		      
		 <textarea name="hedge" rows="3" cols="60">{$hedge}</textarea>
		 <button type="submit">update</button>
		</form>
		   <h2 id="isvg">Inline SVG</h2>
		 <div style="width:500px;height:200px">{$svg}</div>
		 
		<h2 id="svg">Object with <a href="hedge/svg?hedge={$ehedge}">svg</a>, 
		(download <a href="hedge/svg?dl=1&amp;hedge={$ehedge}">svg</a> file)</h2>
		<object height="150" width="500" data="hedge/svg?hedge={$ehedge}" 
		style="border:5px solid red;" type="image/svg+xml">
		SVG Here
		</object>
		<h2 id="svgxml">SVG xml</h2>
		<pre>
		 {fn:serialize($svg)}
		 </pre>
		 <h2 id="layout">Layout xml</h2>    
		<pre>
		 {fn:serialize($layout)}
		 </pre>
		  <h2 id="treexml">Tree xml</h2>
		<pre>
		 {fn:serialize($xml)}
		 </pre>
		  <h2>About</h2>
</body>
	</html>
};

(:~ @return svg for hedge with download option.
:)
declare 
%rest:GET %rest:path("hedge/svg")
%rest:form-param("hedge","{$hedge}") 
%rest:form-param("dl","{$dl}")
function hedge-svg($hedge,$dl) {
	let $xml:=tree:hedge2xml($hedge)
	let $layout:=tree:layout($xml,1)
	let $svg:=tree:svg($layout)
	let $down:=<rest:response> 
            <http:response>
            <http:header name="Content-Disposition" value='attachment;filename="hedge.svg"'/>              
           </http:response>
       </rest:response>
	return ($down[$dl],$svg) 
};

 