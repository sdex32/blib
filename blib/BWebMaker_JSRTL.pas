unit BWebMaker_JSRTL;

interface

// Java Script  -  Run Time Library
const
//------------------------------------------------------------------------------
rtl_max       : string = 'function max($0, $1) { return ($0 > $1 ? $0 : $1); }';
//------------------------------------------------------------------------------
rtl_min       : string = 'function min($0, $1)'
               +#13#10 + '{'
               +#13#10 + '   return ($0 < $1 ? $0 : $1);'
               +#13#10 + '};' ;
//------------------------------------------------------------------------------
rtl_ord       : string = 'function ord($0)'
               +#13#10 + '{'
               +#13#10 + '   return $0.charCodeAt(0);'
               +#13#10 + '};' ;
//------------------------------------------------------------------------------
rtl_chr       : string = 'function chr($0)'
               +#13#10 + '{'
               +#13#10 + '   return String.fromCharCode($0);'
               +#13#10 + '};' ;
//------------------------------------------------------------------------------
rtl_lowercase : string = 'function lowercase($0)'
               +#13#10 + '{'
               +#13#10 + '   return $0.toLocaleLowerCase();'
               +#13#10 + '};' ;
//------------------------------------------------------------------------------
rtl_uppercase : string = 'function uppercase($0)'
               +#13#10 + '{'
               +#13#10 + '   return $0.toLocaleUpperCase();'
               +#13#10 + '};' ;
//------------------------------------------------------------------------------
rtl_round     : string = 'function round($0)'
               +#13#10 + '{'
               +#13#10 + '   return Math.round($0);'
               +#13#10 + '};' ;
//------------------------------------------------------------------------------
rtl_floor     : string = 'function floor($0)'
               +#13#10 + '{'
               +#13#10 + '   return Math.floor($0);'
               +#13#10 + '};' ;


//------------------------------------------------------------------------------
webdom_getbodyelement
              : string = 'function webdom_getbodyelement()'
               +#13#10 + '{'
               +#13#10 + '   return window.document.getElementsByTagName("body")[0];'
               +#13#10 + '};' ;
//------------------------------------------------------------------------------
webdom_createhtmlelement
              : string = 'function webdom_createhtmlelement(tagname)'
               +#13#10 + '{'
               +#13#10 + '   return window.document.createElement(tagname);'
               +#13#10 + '};' ;
//------------------------------------------------------------------------------
webdom_addhtmlelement
              : string = 'function webdom_addhtmlelement(parent, element)'
               +#13#10 + '{'
               +#13#10 + '   parent.appendChild(element);'
               +#13#10 + '};' ;
//------------------------------------------------------------------------------
webdom_inserthtmlelement
              : string = 'function webdom_inserthtmlelement(parent, beforeelement, element)'
               +#13#10 + '{'
               +#13#10 + '   if (beforeelement)'
               +#13#10 + '      parent.insertBefore(element, beforeelement);'
               +#13#10 + '   else'
               +#13#10 + '      parent.insertBefore(element, parent.firstChild);'
               +#13#10 + '};' ;
//------------------------------------------------------------------------------
webdom_removehtmlelement
              : string = 'function webdom_removehtmlelement(parent, element)'
               +#13#10 + '{'
               +#13#10 + '   if (parent && element)'
               +#13#10 + '      parent.removeChild(element);'
               +#13#10 + '};' ;
//------------------------------------------------------------------------------
webdom_freehtmlelement
              : string = 'function webdom_freehtmlelement(parent, element)'
               +#13#10 + '{'
               +#13#10 + '   var $r;'
               +#13#10 + '   if (parent && element)'
               +#13#10 + '      try'
               +#13#10 + '      {'
               +#13#10 + '         parent.removeChild(element);'
               +#13#10 + '      }'
               +#13#10 + '      finally'
               +#13#10 + '      {'
               +#13#10 + '         element = null;'
               +#13#10 + '         $r = element;'
               +#13#10 + '      }'
               +#13#10 + '   else'
               +#13#10 + '      $r = null;'
               +#13#10 + '   return $r;'
               +#13#10 + '};' ;



function Compress_JavaScript( const Sourcec: AnsiString ) :AnsiString;


implementation

function Compress_JavaScript( const Sourcec: AnsiString ) :AnsiString;
begin

end;


end.
