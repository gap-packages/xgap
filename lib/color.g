#############################################################################
##
#W  color.g                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: color.g,v 1.1 1997/12/08 21:48:00 frank Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
Revision.pkg_xgap_lib_color_g :=
    "@(#)$Id: color.g,v 1.1 1997/12/08 21:48:00 frank Exp $";


#############################################################################
##

#C  IsColor . . . . . . . . . . . . . . . . . . . . . . .  category of colors
##
IsColor := NewCategory(
    "IsColor",
    IsObject );

IsColour := IsColor;


#############################################################################
##
#R  IsColorRep  . . . . . . . . . . . . . . . . . . .  default representation
##
IsColorRep := NewRepresentation(
    "IsColorRep",
    IsComponentObjectRep,
    [ "colorId", "name" ],
    IsObject );

IsColourRep := IsColorRep;


#############################################################################
##
#O  ColorId( <color> )  . . . . . . . . . . . . . . . . . color id of a color
##
ColorId := NewOperation(
    "ColorId",
    [ IsColor ] );

ColourId := ColorId;


#############################################################################
##

#V  ColorFamily . . . . . . . . . . . . . . . . . . . . . .  family of colors
##
ColorFamily := NewFamily( "ColorFamily" );

ColourFamily := ColorFamily;


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
CreateColors := function()
    local   type,  color,  model;
    
    # get color type
    type := NewType( ColorFamily, IsColor and IsColorRep );

    # "black" and "white" are alway displayable
    color           := rec();
    color.black     := Objectify( type,
                             rec( colorId := 0, name := "black" ) );
    color.white     := Objectify( type,
                             rec( colorId := 1, name := "white" ) );
    color.lightGray := false;
    color.dimGray   := false;
    color.red       := false;
    color.blue      := false;
    color.green     := false;

    # check for other colors
    model := WindowCmd(["XCN"])[1];
    if   model = 1  then
        color.model     := "monochrome";
    elif model = 2  then
        color.model     := "gray";
        color.lightGray := Objectify( type, 
                                 rec( colorId := 2, name := "light gray" ) );
        color.dimGray   := Objectify( type,
                                 rec( colorId := 3, name := "dim gray" ) );
    elif model = 3  then
        color.model     := "color3";
        color.red       := Objectify( type, 
                                 rec( colorId := 4, name := "red" ) );
        color.blue      := Objectify( type,
                                 rec( colorId := 5, name := "blue" ) );
        color.green     := Objectify( type,
                                 rec( colorId := 6, name := "green" ) );
    elif model = 4  then
        color.model     := "color5";
        color.lightGray := Objectify( type,
                                 rec( colorId := 2, name := "light gray" ) );
        color.dimGray   := Objectify( type,
                                 rec( colorId := 3, name := "dim gray" ) );
        color.red       := Objectify( type,
                                 rec( colorId := 4, name := "red" ) );
        color.blue      := Objectify( type,
                                 rec( colorId := 5, name := "blue" ) );
        color.green     := Objectify( type,
                                 rec( colorId := 6, name := "green" ) );
    fi;

    # fix spelling of grey
    color.lightGrey := color.lightGray;
    color.dimGrey   := color.dimGray;

    # and return
    return color;

end;

COLORS  := CreateColors();
COLOURS := COLORS;


#############################################################################
##

#M  ColorId( <color> )  . . . . . . . . . . . . . . . . . color id of a color
##
InstallMethod( ColorId,
    "for color",
    true,
    [ IsColor and IsColorRep ],
    0,

function( color )
    return color!.colorId;
end );


#############################################################################
##
#M  ViewObj( <color> )  . . . . . . . . . . . . . . . .  pretty print a color
##
InstallMethod( ViewObj,
    "for color",
    true,
    [ IsColor and IsColorRep ],
    0,

function( color )
    Print( "<color ", color!.name, ">" );
end );


#############################################################################
##
#M  PrintObj( <color> ) . . . . . . . . . . . . . . . .  pretty print a color
##
InstallMethod( PrintObj,
    "for color",
    true,
    [ IsColor and IsColorRep ],
    0,

function( color )
    Print( "<color ", color!.name, ">" );
end );


#############################################################################
##
#M  \=( <color>, <color> )  . . . . . . . . . . . . . . . . . . equality test
##
InstallMethod( \=,
    "for colors",
    IsIdenticalObj,
    [ IsColor and IsColorRep,
      IsColor and IsColorRep ],
    0,

function( c1, c2 )
    return c1!.colorId = c2!.colorId;
end );


#############################################################################
##
#M  \<( <color>, <color> )  . . . . . . . . . . . . . . . . . comparison test
##
InstallMethod( \<,
    "for colors",
    IsIdenticalObj,
    [ IsColor and IsColorRep,
      IsColor and IsColorRep ],
    0,

function( c1, c2 )
    return c1!.colorId < c2!.colorId;
end );


#############################################################################
##

#F  color.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

