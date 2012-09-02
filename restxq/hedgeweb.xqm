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
%rest:form-param("hedge","{$hedge}","a(bc)") 
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
     <input type="text" name="hedge" value="{$hedge}"/>
     <button type="submit">Go</button>
    </form>
    <a href="svg?hedge={$hedge}">svg</a>
    <object height="150" width="500" data="svg?hedge={$hedge}" 
    style="border:5px solid red;" type="image/svg+xml">
    SVG Here
    </object>
    <pre>
     {fn:serialize($svg)}
     </pre>
    <pre>
     {fn:serialize($layout)}
     </pre>
    <pre>
     {fn:serialize($xml)}
     </pre>
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