#############################################################################
##
#W  color.gi                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: color.gi,v 1.1 1997/12/18 15:12:14 frank Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
Revision.pkg_xgap_lib_color_gi :=
    "@(#)$Id: color.gi,v 1.1 1997/12/18 15:12:14 frank Exp $";


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

#F  color.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

