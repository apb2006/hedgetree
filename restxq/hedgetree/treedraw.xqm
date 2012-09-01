(:~
: based on http://www.xml.com/lpt/a/1472
:)
module namespace hedge = 'apb.tree';
declare default function namespace 'apb.tree';
declare namespace svg= "http://www.w3.org/2000/svg";
declare variable $hedge:scale:=10;

declare function hedge:svg($layout){
let $maxDepth:=4
return 
<svg:svg viewBox = "0 0 {fn:sum($layout/node/@width) * 2 * $hedge:scale} {$maxDepth * 2 * $hedge:scale}">
    <!-- Note that some SVG implementations work better when you set explicit width and height also.
         In that case add following attributes to svg element:
            width="{fn:sum($layout/node/@width)*5}mm"
            depth = "{$maxDepth*5}mm"
            preserveAspectRatio="xMidYMid meet" -->
    <svg:g transform = "translate(0,-{$hedge:scale div 2}) scale({$hedge:scale})">
      {for $node in $layout return hedge:drawnode($node)}
    </svg:g>
  </svg:svg>
};

declare function hedge:drawnode($node){
  (: Calculate X coordinate :)
  let $x:=(fn:sum($node/preceding::node[@depth = current/$node/@depth or (fn:not($node/node) and $node/@depth <= current/@depth)]/@width) + ($node/@width div 2)) * 2
  (: Calculate Y coordinate :)
  let $y := $node/@depth * 2
 
  return 
  (: Draw label of node :)
  (<svg:text x = "{$x}" y = "{$y - 0.2}" style = "text-anchor: middle; font-size: 0.9;">
    {$node/@label}
  </svg:text>,
  (: rectangle :)
  <svg:rect x = "{$x - 0.9}" y="{$y - 1}" width = "1.8" height="1" rx = "0.4" ry = "0.4"
            style = "fill: none; stroke: black; stroke-width: 0.1;"/>,
  (: lines :)
  for $n in $node/node
     let $x2:=(fn:sum($node/preceding::node[@depth = current/@depth or (fn:not($node/node) and @depth  <= current/@depth)]/@width) + ($node/@width div 2)) * 2  
    return  <svg:line x1 = "{$x}"
              y1 = "{$y}"
              x2 = "{$x2}"
              y2 = "{$node/@depth * 2 - 1}"
              style = "stroke-width: 0.1; stroke: black;"/>
 ,
 (: Draw sub-nodes :)
 for $n in  $node/node
 return hedge:drawnode($n)
 )
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