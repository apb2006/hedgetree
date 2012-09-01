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

