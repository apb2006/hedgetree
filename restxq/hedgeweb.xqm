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
 <form method="post" action="./hedge">
 <input type="text" name="hedge" value="a(bc)"/>
 <button type="submit">Go</button>
</form>
};

declare 
%rest:POST %rest:path("hedge")
%rest:form-param("hedge","{$hedge}") 
%output:method("html5")
function hedge-post($hedge) {
let $xml:=tree:hedge2xml($hedge)
let $layout:=tree:layout($xml,1)
let $svg:=tree:svg($layout)
return <div>{$hedge}
<div>
{$svg}
</div>
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
};
