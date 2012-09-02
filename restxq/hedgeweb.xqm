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
%rest:form-param("hedge","{$hedge}","{top}({next}{level}({more}{or}{less}))") 
function hedge($hedge) {
let $xml:=tree:hedge2xml($hedge)
let $layout:=tree:layout($xml,1)
let $svg:=tree:svg($layout)
return <html>
<head>
    <title>hedge</title>
    </head>
    <body>
     <form method="get" action="./hedge">
     <textarea name="hedge" rows="5" cols="50">{$hedge}</textarea>
     <button type="submit">Go</button>
    </form>
    
    <h2 id="svg"><a href="svg?hedge={$hedge}">svg</a> object</h2>
    <object height="150" width="500" data="svg?hedge={$hedge}" 
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
       <h2 id="isvg">svg inline</h2>
       {$svg}
         <h2 id="xsvg">svg test</h2>
          <svg:svg xmlns:svg="http://www.w3.org/2000/svg" version="1.1" height="190">
              <svg:polygon points="100,10 40,180 190,60 10,60 160,180" style="fill:lime;stroke:purple;stroke-width:5;fill-rule:evenodd;"></svg:polygon>
            </svg:svg>
    </body>
</html>
};


declare 
%rest:GET %rest:path("svg")
%rest:form-param("hedge","{$hedge}") 
function hedge-svg($hedge) {
let $xml:=tree:hedge2xml($hedge)
let $layout:=tree:layout($xml,1)
let $svg:=tree:svg($layout)
return 
    $svg
};