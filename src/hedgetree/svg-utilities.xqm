module namespace svg-util='http://code.google.com/p/xrx/svg-util';
declare namespace svg="http://www.w3.org/2000/svg";

(: some simple functions to make a wild guess on the font sizes.  We just need to get
close to create a box around the text so four categories of font sizes works fine for
99.9% of my data element names :)

(: A very rough guess at the width of this string in pixels since we don't have font-width information :)
declare function svg-util:string-width($input as xs:string) as xs:double {
   let $very-wide := svg-util:count-very-wide($input) * 15.0
   let $wide := svg-util:count-wide($input) * 11.1
   let $normal-lower-case := svg-util:count-normal-lower-case($input) * 8.9
   let $narrow := svg-util:count-narrow($input) * 4
   return $very-wide + $wide + $normal-lower-case + $narrow
};

(: Count only the uppercase letters by replaceing all lowercase, numbers and special chars with nulls. :)
declare function svg-util:count-upper-case($input as xs:string) as xs:integer {
  string-length(replace($input, '^[a-z0-9_\-]*', ''))
};

(: Count only the lowercase letters by replaceing all uppercase, numbers and special chars with nulls. :)
declare function svg-util:count-lower-case($input as xs:string) as xs:integer {
  string-length(replace($input, '^[A-Z0-9_\-]*', ''))
};

(: The number of very wide letters like "M" and "W" letters in a string :)
declare function svg-util:count-very-wide($input as xs:string) as xs:integer {
  string-length(replace($input, '[^MWmw]*', ''))
};

(: The number of non-mw uppercase letters in a string :)
declare function svg-util:count-wide($input as xs:string) as xs:integer {
   string-length(replace($input, '[^ABCDEFGHIJKLNOPQRSTUVXYZ]*', ''))
};

(: The number of normal lowercase letters, number, -, _ except i and l :)
declare function svg-util:count-normal-lower-case($input as xs:string) as xs:integer {
   string-length(replace($input, '[^abcdefghknopqrstuvxyz234567890_\-]*', ''))
};

(: The number of narrow letters like "i" and "l" the number "1" in a string :)
declare function svg-util:count-narrow($input as xs:string) as xs:integer {
   string-length(replace($input, '[^il1]*', ''))
};