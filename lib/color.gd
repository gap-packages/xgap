#############################################################################
##
#W  color.gd                 	XGAP library                     Frank Celler
##
#H  @(#)$Id: color.gd,v 1.4 1998/11/27 14:50:47 ahulpke Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
Revision.pkg_xgap_lib_color_gd :=
    "@(#)$Id: color.gd,v 1.4 1998/11/27 14:50:47 ahulpke Exp $";


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
DeclareGlobalFunction( "CreateColors" );
DeclareGlobalVariable( "COLORS" );
DeclareSynonym( "COLOURS", COLORS );


#############################################################################
##

#E  color.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

