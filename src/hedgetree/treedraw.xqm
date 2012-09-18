(:~
: based on http://www.xml.com/lpt/a/1472
:)
module namespace hedge = 'apb.tree';
declare default function namespace 'apb.tree';
import module namespace svg-util='http://code.google.com/p/xrx/svg-util' at "svg-utilities.xqm";
declare namespace svg= "http://www.w3.org/2000/svg";
declare namespace  xlink="http://www.w3.org/1999/xlink";
declare variable $hedge:scale:=10;

(:~
: svg from node xml
:)
declare function hedge:svg($layout as element(node)) as element(svg:svg){
    let $maxDepth:=fn:max($layout//@depth)
    let $width:=$layout/@width
    return 
    <svg xmlns = "http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
    viewBox = "0 0 {$width * 2 * $hedge:scale} {$maxDepth * 2 * $hedge:scale}"
    version="1.1" width="100%" height="100%" preserveAspectRatio="xMidYMid meet">
	<defs>
	<style type="text/css">
    @namespace "http://www.w3.org/2000/svg";
    text  {{font-family: Verdana, Sans-serif;  }}
    .line {{stroke-width: 0.05; stroke: black; }}
	.node {{fill: yellow; stroke: black; stroke-width: 0.05;}}
  </style>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#E3A820;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#FFFFFF;stop-opacity:1" />
    </linearGradient>
    <marker id="Triangle"
                viewBox="0 0 10 10"
                refX="10" refY="5"
                markerWidth="4"
                markerHeight="4"
                orient="auto">
            <path d="M 0 0 L 10 5 L 0 10 z" />
        </marker>
  </defs>
	 <rect x = "0" y="0" width = "100%" height="100%" fill="url(#grad1)"/>
        <g transform = "translate(0,-{$hedge:scale div 2}) scale({$hedge:scale})">
          {if($layout/@label) then hedge:draw-node($layout)
           else for $n in $layout/* 
                return hedge:draw-node($n)
           }
        </g>
      </svg>
};

declare function hedge:draw-node($node  as element(node)){
  (: Calculate X coordinate :)
  let $x1:=fn:sum($node/preceding::node[@depth = $node/@depth or (fn:not(node) and @depth <= $node/@depth)]/@width)
  let $x:=($x1 + ($node/@width div 2)) * 2
  (: Calculate Y coordinate :)
  let $y := $node/@depth * 2
  let $width:=svg-textlen($node/@label)
  return ( 
 
  <g xmlns = "http://www.w3.org/2000/svg">
  <a >
      {if($node/@href) then 
       attribute xlink:href {$node/@href/fn:string()}
       else ()}
       <title>{$node/@label/fn:string()}</title>
      <rect class="node" x = "{$x - 0.9*$width}" y="{$y - 1}" width = "{1.8 * $width}" height="1" rx = "0.3" ry = "0.3"
               />
      <text x = "{$x}" y = "{$y - 0.2}" font-size="0.9" text-anchor="middle">
        {$node/@label/fn:string()}
      </text>
      </a>
  </g>,          
  (: lines :)
  for $n in $node/node
     let $x1:=fn:sum($n/preceding::node[@depth = $n/@depth or (fn:not(node) and @depth <= $n/@depth)]/@width)
     let $x2:=($x1 + ($n/@width div 2)) * 2  
    return  <line class="line" x1 = "{$x}" y1 = "{$y}" 
                  x2 = "{$x2}" y2 = "{$n/@depth * 2 - 1}" marker-end="url(#Triangle)"/>
  ,
 (: Draw sub-nodes :)
 for $n in  $node/node return hedge:draw-node($n)
 )
};

(:~ guess svg text size :)
declare function svg-textlen($text) as xs:double{
  if($text) 
  then svg-util:string-width($text) div 20 
  else 0
};

(: insert depth and width :)
declare function layout($node as element(node)) as element(node) {
    layout($node,if($node/@label) then 1 else 0) (:dummy node check:)
};

declare %private function layout($node as element(node),$depth) as element(node) {
  element {fn:node-name($node)}
          {$node/@*,
           attribute{ "depth"}{ $depth},
           attribute{ "width"}{node-width($node)},
          for $child in $node/*
          return layout($child,$depth+1)
          }
};

(:~ node with is greater of text size and child widths :)
declare %private function  node-width($e as element(node)) {
  fn:max((svg-textlen($e/@label),fn:sum($e/*/node-width(.))))
};


(:~
: convert string to xml node representation
:)
declare function hedge2xml($hedge as xs:string) as element(node){
let $t:=hedge-head($hedge)
return if(fn:count($t)>1)then <node>{$t}</node> else $t
};

(:~
: convert string to xml node representation
:)
declare function hedge-head($hedge as xs:string) as element(node)*{
  if($hedge="") then ()
  else if (fn:substring($hedge, 1, 1)="{") then
    hedge2xml(fn:substring-before(fn:substring($hedge,2), '}'),fn:substring-after($hedge, '}'))
  else
    hedge2xml(fn:substring($hedge,1,1),fn:substring($hedge,2))  
};

declare %private function hedge2xml($head as xs:string,$rest as xs:string) as element(node)* { 
 if($head="(" or $head=")"  or $head="") then
   fn:error(xs:QName('hedge:hedge2xml'),"Syntax error processing '" || $head ||"' remaining string: '" || $rest || "'.") 
 else if (fn:substring($rest,1, 1)="(") then
   let $endPos:=closingParenPos2($rest,2,1)
   return (node-parse($head,hedge-head(fn:substring($rest, 2, $endPos -2 )))
           ,hedge-head(fn:substring($rest, 1+$endPos)))        
 else 
     (node-parse($head,()) 
	 ,hedge-head($rest))
};

(:~
: create node for name, extracting link if present
:)
declare %private function node-parse($name as xs:string,$content) as element(node){
	if(fn:contains($name,"|")) then 
	   let $label:=fn:substring-before($name,"|")
	   let $href:=fn:substring-after($name,"|")
	   return <node label="{$label}" href="{$href}">{$content}</node>
	else 
	    <node label="{$name}">{$content}</node>
};

(:~
: find string position tarting search at given position
: @param $arg string to be searched
: @param $substring what to look for
: @param $startpos first position to search
: @return index or -1 if not found   
:)
declare function string-index 
( $arg as xs:string? , $substring as xs:string , $startPos as xs:integer )  as xs:integer {
  let $s:=fn:substring($arg,$startPos)       
  return if (fn:contains($s, $substring))
         then $startPos+fn:string-length(fn:substring-before($s, $substring))
         else -1
};

(:~
: locate closing ) starting as pos
:)
declare function closingParenPos2($text as xs:string,$pos as xs:integer ,$depth as xs:integer ) as xs:integer{
  let $start:=string-index($text,"(",$pos)
  let $end:=string-index($text,")",$pos)
  return 
      if($end=-1 or $start=-1 or $end < $start ) then
          if($depth=1) then 
          $end 
          else closingParenPos2($text,$end+1,$depth -1)        
      else  closingParenPos2($text,$start+1,$depth+1)     
};