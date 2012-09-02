(:~
: based on http://www.xml.com/lpt/a/1472
:)
module namespace hedge = 'apb.tree';
declare default function namespace 'apb.tree';
import module namespace svg-util='http://code.google.com/p/xrx/svg-util' at "svg-utilities.xqm";
declare namespace svg= "http://www.w3.org/2000/svg";
declare namespace  xlink="http://www.w3.org/1999/xlink";
declare variable $hedge:scale:=10;

declare function hedge:svg($layout){
    let $maxDepth:=fn:max($layout//@depth)
    let $width:=fn:sum($layout/@width)
    return 
    <svg xmlns = "http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
    viewBox = "0 0 {$width * 2 * $hedge:scale} {$maxDepth * 2 * $hedge:scale}"
    version="1.1" width="100%" height="100%" preserveAspectRatio="xMidYMid meet">
        <g transform = "translate(0,-{$hedge:scale div 2}) scale({$hedge:scale})">
          {for $node in $layout return hedge:draw-node($node)}
        </g>
      </svg>
};

declare function hedge:draw-node($node  as element(node)){
  (: Calculate X coordinate :)
  let $x1:=fn:sum($node/preceding::node[@depth = $node/@depth or (fn:not($node/node) and @depth <= $node/@depth)]/@width)
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
      <title>Debug info: x coord= {$x1}</title>
      <rect x = "{$x - 0.9*$width}" y="{$y - 1}" width = "{1.8 * $width}" height="1" rx = "0.4" ry = "0.4"
                style = "fill: yellow; stroke: black; stroke-width: 0.1;"/>
      <text x = "{$x}" y = "{$y - 0.2}" font-size="0.9" text-anchor="middle">
        {$node/@label/fn:string()}
      </text>
      </a>
  </g>,          
  (: lines :)
  for $n in $node/node
     let $x1:=fn:sum($n/preceding::node[@depth = $n/@depth or (fn:not($n/node) and @depth <= $n/@depth)]/@width)
     let $x2:=($x1 + ($n/@width div 2)) * 2  
    return  <line x1 = "{$x}"
              y1 = "{$y}"
              x2 = "{$x2}"
              y2 = "{$n/@depth * 2 - 1}"
              style = "stroke-width: 0.1; stroke: black;"/>
 ,
 (: Draw sub-nodes :)
 for $n in  $node/node return hedge:draw-node($n)
 )
};

declare function svg-textlen($text as xs:string){
  (: @TODO better label width 
  fn:string-length($text) :)
  svg-util:string-width($text) div 20
};

(: insert depth and width :)
declare function layout($element as element(node)*,$depth) as element(node)* {
for $n in $element
return element {fn:node-name($n)}
      {$n/@*,
       attribute{ "depth"}{ $depth},
       attribute{ "width"}{width($n)},
   (:    attribute{ "href"}{"http://github.com"}, :)
      for $child in $n/*
      return layout($child,$depth+1)
      }
};

declare function width($e as element(node)) {
  fn:max((svg-textlen($e/@label),fn:sum($e/*/width(.))))
};

declare function hedge2xml($hedge as xs:string) as element(node)*{
  if($hedge="") then ()
  else if (fn:substring($hedge, 1, 1)="{") then
    hedge2xml(fn:substring-before(fn:substring($hedge,2), '}'),fn:substring-after($hedge, '}'))
  else
    hedge2xml(fn:substring($hedge,1,1),fn:substring($hedge,2))  
};

declare %private function hedge2xml($head as xs:string,$rest as xs:string) as element(node)* {
 if($head="(" or $head=")"  or $head="") then
   fn:error() 
 else if (fn:substring($rest,1, 1)="(") then
   let $endPos:=closingParenPos2($rest,2,1)
   return (<node label="{$head}">{hedge2xml(fn:substring($rest, 2, $endPos -2 ))}</node>
           ,hedge2xml(fn:substring($rest, 1+$endPos))
           )        
 else 
     (<node label="{$head}"/> ,hedge2xml($rest))
};

(:~
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