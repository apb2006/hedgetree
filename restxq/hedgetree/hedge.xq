xquery version "3.0";
(:~
: Node tree from a string
: based on http://www.xml.com/lpt/a/1472
:) 
declare namespace svg= "http://www.w3.org/2000/svg";
declare variable $hedge.scale:=10;

declare function local:hedge2xml($hedge as xs:string) as element(node)*{
  if($hedge="") then ()
  else if (fn:substring($hedge, 1, 1)="{") then
    local:hedge2xml(fn:substring-before(fn:substring($hedge,2), '}'),fn:substring-after($hedge, '}'))
  else
    local:hedge2xml(fn:substring($hedge,1,1),fn:substring($hedge,2))  
};

declare %private function local:hedge2xml($head as xs:string,$rest as xs:string) as element(node)* {
 if($head="(" or $head=")"  or $head="") then
   fn:error() 
 else if (fn:substring($rest,1, 1)="(") then
   let $endPos:=local:closingParenPos2($rest,2,1)
   return (<node label="{$head}">{local:hedge2xml(substring($rest, 2, $endPos -2 ))}</node>
           ,local:hedge2xml(substring($rest, 1+$endPos))
           )        
 else 
     (<node label="{$head}"/> ,local:hedge2xml($rest))
};


declare function local:closingParenPos($text as xs:string,$pos as xs:integer ,$depth as xs:integer ) as xs:integer{
  switch (fn:true())
  (:  Found closing ) which is not nested. We are done. :)
  case fn:substring($text, $pos, 1) = ')' and $depth = 1 
        return $pos
  (: Found opening (. Increase nesting depth and continue. :)
  case fn:substring($text,  $pos, 1) = '(' 
        return local:closingParenPos($text, $pos+1, $depth + 1)
  (: Found closing ) which is nested. Unwrap and continue on a shallower level. :)
  case fn:substring($text, $pos, 1) = ')' 
        return local:closingParenPos($text, $pos+1, $depth - 1)
  (: End of text while nested. Something is wrong with input. :)
  case ($pos > string-length($text))  and $depth != 0 
        return fn:error()
  default
        return local:closingParenPos($text, $pos+1, $depth)      
};


(:---  alternative closingParenPos mades no difference ---:)

(:~
: @param $arg string to be searched
: @param $substring what to look for
: @param $startpos first position to search
: @return index or -1 if not found   
:)
declare function local:string-index 
( $arg as xs:string? , $substring as xs:string , $startPos as xs:integer )  as xs:integer {
  let $s:=substring($arg,$startPos)       
  return if (contains($s, $substring))
         then $startPos+string-length(substring-before($s, $substring))
         else -1
};

declare function local:closingParenPos2($text as xs:string,$pos as xs:integer ,$depth as xs:integer ) as xs:integer{
  let $start:=local:string-index($text,"(",$pos)
  let $end:=local:string-index($text,")",$pos)
  let $pos:=trace($pos,   $start || "," || $end || "::")
  return 
      if($end=-1 or $start=-1 or $end < $start ) then
          if($depth=1) then 
          $end else 
          local:closingParenPos2($text,$end+1,$depth -1)        
      else  local:closingParenPos2($text,$start+1,$depth+1)     
};

(: insert depth and width :)
declare function local:layout($element as element(),$depth) as element() {
   element {node-name($element)}
      {$element/@*,
       attribute{ "depth"}{ $depth},
       attribute{ "width"}{local:width($element)},
      for $child in $element/*
      return local:layout($child,$depth+1)
      }
};
declare function local:width($e){
  max((1,sum($e/*/local:width(.))))
};
declare function local:svg($layout){
let $maxDepth:=4
return 
<svg:svg viewBox = "0 0 {sum($layout/node/@width) * 2 * $hedge.scale} {$maxDepth * 2 * $hedge.scale}">
    <!-- Note that some SVG implementations work better when you set explicit width and height also.
         In that case add following attributes to svg element:
            width="{sum($layout/node/@width)*5}mm"
            depth = "{$maxDepth*5}mm"
            preserveAspectRatio="xMidYMid meet" -->
    <svg:g transform = "translate(0,-{$hedge.scale div 2}) scale({$hedge.scale})">
      {for $node in $layout return local:drawnode($node)}
    </svg:g>
  </svg:svg>
};

declare function local:drawnode($node){
  (: Calculate X coordinate :)
  let $x:=(sum(preceding::node[$node/@depth = current()/$node/@depth or (not($node/node) and $node/@depth <= current()/@depth)]/@width) + ($node/@width div 2)) * 2
  (: Calculate Y coordinate :)
  let $y := $node/@depth * 2
  (: Draw label of node :)
  return 
  (: text :)
  (<svg:text x = "{$x}"
            y = "{$y - 0.2}"
            style = "text-anchor: middle; font-size: 0.9;">
    {$node/@label}
  </svg:text>,
  (: rectangle :)
  <svg:rect x = "{$x - 0.9}" y="{$y - 1}" width = "1.8" height="1"
            rx = "0.4" ry = "0.4"
            style = "fill: none; stroke: black; stroke-width: 0.1;"/>,
  (: lines :)
  for $n in $node/node
  return  
    <svg:line x1 = "{$x}"
              y1 = "{$y}"
              x2 = "{(sum($node/preceding::node[@depth = current()/@depth or (not($node/node) and @depth  <= current()/@depth)]/@width) + ($node/@width div 2)) * 2}"
              y2 = "{$node/@depth * 2 - 1}"
              style = "stroke-width: 0.1; stroke: black;"/>
 ,
 (: Draw sub-nodes :)
 for $n in  $node/node
 return local:drawnode($n)
};

let $hedge:="a(bcdef)"
let $t:=local:hedge2xml($hedge)
return  $t!local:layout(.,1)