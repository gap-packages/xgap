#############################################################################
##
#W  color.gi                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: color.gi,v 1.3 1998/03/06 13:14:53 gap Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
Revision.pkg_xgap_lib_color_gi :=
    "@(#)$Id: color.gi,v 1.3 1998/03/06 13:14:53 gap Exp $";


#############################################################################
##

#R  IsColorRep  . . . . . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsColorRep",
    IsComponentObjectRep,
    [ "colorId", "name" ],
    IsObject );

DeclareSynonym( "IsColourRep", IsColorRep );


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
#F  CreateColors()
#V  COLORS
##
InstallGlobalFunction( CreateColors, function()
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

end );

InstallValue( COLORS, CreateColors() );


#############################################################################
##

#E  color.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

