#############################################################################
##
#W  color.gd                 	XGAP library                     Frank Celler
##
#H  @(#)$Id: color.gd,v 1.5 1999/01/17 23:45:50 gap Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
Revision.pkg_xgap_lib_color_gd :=
    "@(#)$Id: color.gd,v 1.5 1999/01/17 23:45:50 gap Exp $";


#############################################################################
#1
##  Depending on the type of display you are using, there may be more or
##  less colors available. You should write your programs always such that
##  they work even on monochrome displays. In {\XGAP} these differences can
##  be read off from the so called ``color model''. The global variable
##  `COLORS' contains all available information.


#############################################################################
##
#C  IsColor . . . . . . . . . . . . . . . . . . . . . . .  category of colors
##
DeclareCategory( "IsColor", IsObject );
DeclareSynonym( "IsColour", IsColor );


#############################################################################
##
#O  ColorId( <color> )  . . . . . . . . . . . . . . . . . color id of a color
##
DeclareOperation( "ColorId", [ IsColor ] );
DeclareSynonym( "ColourId", ColorId );


#############################################################################
##
#V  ColorFamily . . . . . . . . . . . . . . . . . . . . . .  family of colors
##
BindGlobal( "ColorFamily", NewFamily( "ColorFamily" ) );
DeclareSynonym( "ColourFamily", ColorFamily );


#############################################################################
##
#V  COLORS  . . . . . . . . . . . . . . . . . . . .  list of available colors
##
##  The variable  `COLORS' contains a list  of available colors.  If an entry
##  is `false' this  color is not available  on your screen.  Possible colors
##  are: \"black\", \"white\", \"lightGrey\", \"dimGrey\", \"red\", \"blue\",
##  and \"green\".
##
##  The  following example opens   a new graphic sheet  (see "GraphicSheet"),
##  puts  a black box (see  "Box") onto it and  changes its color.  Obviously
##  you need a color display for this example.
##
##  \beginexample
##      gap> sheet := GraphicSheet( "Nice Sheet", 300, 300 );
##      <graphic sheet "Nice Sheet">
##      gap> box := Box( sheet, 10, 10, 290, 290 );
##      <box>
##      gap> Recolor( box, COLORS.green );
##      gap> Recolor( box, COLORS.blue );
##      gap> Recolor( box, COLORS.red );
##      gap> Recolor( box, COLORS.lightGrey );
##      gap> Recolor( box, COLORS.dimGrey );
##      gap> Close(sheet);
##  \endexample
##
##  The component `model' is always a string. It is `monochrome', if the 
##  display does not support colors. It is `gray' if we only have gray shades
##  and `colorX' if we have colors. The ``X'' can be either 3 or 5, depending
##  on how many colors are available.
##
DeclareGlobalFunction( "CreateColors" );
DeclareGlobalVariable( "COLORS" );
DeclareSynonym( "COLOURS", COLORS );


#############################################################################
##

#E  color.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

