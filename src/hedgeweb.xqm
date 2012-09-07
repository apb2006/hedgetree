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
%rest:form-param("hedge","{$hedge}")
%rest:form-param("url","{$url}") 
function hedge($hedge,$url) {
	let $ehedge:=if($url) then "" else fn:encode-for-uri($hedge)
	let $xml:=getxml($hedge,$url) 
	let $layout:=tree:layout($xml)
	let $svg:=tree:svg($layout)
	 
	return <html>
	<head>
		<title>Drawing trees with XQuery and SVG</title>
		<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta name="description" content="tree xquery svg" />
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
		<style type="text/css">pre {{background-color:#FFFFDD;}}</style>
		</head>
		<body>
		<h1>Drawing trees with XQuery and SVG</h1>
		<p>Enter a  string representing a tree in the form below; use letters for nodes and () to enclose subnodes. Use {{...}} for multi character names. {{name|href}} will create a link. Examples: <a href="?hedge=a(bcd(ef))">a(bcd(ef))</a>,
                  <a href="?hedge={{github|https://github.com/apb2006/hedgetree}}(ab({{tree|%23treexml}}))">another </a>
		buggy: <a href="?hedge=a(bcd)e(fgh)">a(bcd)e(fgh)</a>.</p>
		<p> Or enter a Url to a xml document examples:
		<a href="?url=hedgetree/samples/sample1.xml">sample1</a>,
	<a href="?url=hedgetree/samples/hedgeweb.xml">hedgeweb</a>
	<a href="?url=https://raw.github.com/apb2006/hedgetree/master/src/hedgetree/samples/hedgeweb.xml">remote</a>
		  </p>
		 <form method="get" action="./hedge" style="background-color:#EEEEEE;padding:8px;">
		 
		  	      
		 <textarea name="hedge" rows="2" cols="80">{$hedge}</textarea>
		 <p></p>
		  <p>Or enter the url to a node XML source
		 <input name="url"  value="{$url}" style="width:30em"/></p>
		 <button type="submit">Redraw</button>
		</form >
		   <h2 id="isvg">Inline SVG</h2>
		 <div style="width:300px;height:200px">{$svg}</div>
		 
		<h2 id="svg">Object referencing <a href="hedge/svg?hedge={$ehedge}&amp;url={$url}">svg</a>, 
		( <a href="hedge/svg?dl=1&amp;hedge={$ehedge}&amp;url={$url}">download</a> svg)</h2>
		<object height="150" width="300" data="hedge/svg?hedge={$ehedge}&amp;url={$url}" 
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
		  <p> Source: @github:<iframe src="http://ghbtns.com/github-btn.html?user=apb2006&amp;repo=hedgetree&amp;type=watch"
      allowtransparency="true" frameborder="0" scrolling="0" width="62px" height="20px"></iframe>, Twitter:
     <a href="https://twitter.com/share" class="twitter-share-button" data-via="apb1704" data-count="none">Tweet</a>
<script>!function(d,s,id){{var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){{js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}}}(document,"script","twitter-wjs");</script>.
     </p>
</body>
	</html>
};

(:~ @return svg for hedge with download option.
:)
declare 
%rest:GET %rest:path("hedge/svg")
%rest:form-param("hedge","{$hedge}")
%rest:form-param("url","{$url}")  
%rest:form-param("dl","{$dl}")
function hedge-svg($hedge,$url,$dl) {
	let $xml:=getxml($hedge,$url)
	let $layout:=tree:layout($xml)
	let $svg:=tree:svg($layout)
	let $down:=<rest:response> 
            <http:response>
            <http:header name="Content-Disposition" value='attachment;filename="hedge.svg"'/>              
           </http:response>
       </rest:response>
	return ($down[$dl],$svg) 
};

(:~  use hedge or url :)
declare %private function getxml($hedge,$url){
 if($url) then
    try{fn:doc(fn:resolve-uri($url))/*} catch * { <node label="{$err:description}"/>}
else	
	try{ tree:hedge2xml($hedge)} catch * { <node label="{$err:description}"/>}				
};				   