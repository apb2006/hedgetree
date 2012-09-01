(:~ 
: tress as svg
: @author andy bunce
: @since sept 2012
:)

module namespace sr = 'apb.hedge.web';
declare default function namespace 'apb.hedge.web'; 
import module namespace web = 'apb.hedgetree.rest' at "hedgetree/web2.xqm";


declare %rest:path("hedge") %output:method("html5")
function hedge() {
 "hello"
};

