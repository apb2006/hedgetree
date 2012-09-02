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
function hedge() {
<html>
    <body>
     <form method="post" action="./hedge">
     <input type="text" name="hedge" value="a(bc)"/>
     <button type="submit">Go</button>
    </form>
    </body>
</html>
};

declare 
%rest:POST %rest:path("hedge")
%rest:form-param("hedge","{$hedge}") 
%output:method("xhtml")
%output:omit-xml-declaration("no")
%output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
%output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
function hedge-post($hedge) {
let $xml:=tree:hedge2xml($hedge)
let $layout:=tree:layout($xml,1)
let $svg:=tree:svg($layout)
return <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
    <title>hedge</title>
    </head>
    <body>
    <div>{$hedge}
    <div>
    {$svg}
    </div>
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
     </div>
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