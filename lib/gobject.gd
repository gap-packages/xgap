#############################################################################
##
#W  gobject.gd                 	XGAP library                     Frank Celler
##
#H  @(#)$Id: gobject.gd,v 1.2 1997/12/09 12:36:59 frank Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
Revision.pkg_xgap_lib_gobject_gd :=
    "@(#)$Id: gobject.gd,v 1.2 1997/12/09 12:36:59 frank Exp $";


#############################################################################
##

#F  IsAlive . . . . . . . . . . . . . . . filter for living displayed objects
##
IsAlive    := NewFilter( "IsAlive" );
HasIsAlive := Tester(IsAlive);


#############################################################################
##

#C  IsGraphicObject . . . . . . . . . . . . . . . category of graphic objects
##
IsGraphicObject := NewCategory(
    "IsGraphicObject",
    IsObject );


#############################################################################
##
#O  GraphicObject( <catrep>, <sheet>, <defaults> )  . . .  new graphic object
##
GraphicObject := NewOperation(
    "GraphicObject",
    [ IsObject, IsGraphicSheet, IsRecord ] );


#############################################################################
##
#O  Destroy( <object> ) . . . . . . . . . . . . . . . detroy a graphic object
##
Destroy := NewOperation(
    "Destroy",
    [ IsGraphicObject ] );


#############################################################################
##
#O  Draw( <object> )  . . . . . . . . . . . . . . . (re)draw a graphic object
##
Draw := NewOperation(
    "Draw",
    [ IsGraphicObject ] );


#############################################################################
##
#O  Move( <object>, <x>, <y> )  . . . . . . . . . . . . . . . . absolute move
##
Move := NewOperation(
    "Move",
    [ IsGraphicObject, IsInt, IsInt ] );


#############################################################################
##
#O  MoveDelta( <object>, <dx>, <dy> ) . . . . . . . . . . . . . .  delta move
##
MoveDelta := NewOperation(
    "MoveDelta",
    [ IsGraphicObject, IsInt, IsInt ] );


#############################################################################
##
#O  PrintInfo( <object> ) . . . . . . . . . . . . . . . . .  print debug info
##
PrintInfo := NewOperation(
    "PrintInfo",
    [ IsGraphicObject ] );


#############################################################################
##
#O  Recolor( <object>, <col> )  . . . . . . . . . . . . . . . .  change color
##
Recolor := NewOperation(
    "Recolor",
    [ IsGraphicObject, IsColor ] );

Recolour := Recolor;


#############################################################################
##

#O  Box( <sheet>, <x>, <y>, <w>, <h> )  . . . . . . . . draw a box in a sheet
#O  Box( <sheet>, <x>, <y>, <w>, <h>, <defaults> )  . . draw a box in a sheet
##
##
##  creates a new graphic object,  namely a filled black  box, on the graphic
##  sheet <sheet> and  returns a {\GAP} record describing  this  object.  The
##  for    corners     of  the    box    are   $(<x>,<y>)$,  $(<x>+<w>,<y>)$,
##  $(<x>+<w>,<y>+<h>)$, and $(<x>,<y>+<h>)$.
##
##  Note that the box is $<w>+1$ pixel wide and $<h>+1$ pixels high.
##
##  The following functions   can be  used  for  boxes: `in'  (see "in  for
##  Graphic   Objects"), `Reshape'   (see  "Reshape"),  `Move'  (see "Move"),
##  `MoveDelta' (see   "MoveDelta"), `Recolor' (see "Recolor"),  and `Delete'
##  (see "Delete").
##
##  If a record <defaults> is given and contains a component `color' of value
##  <color>, the  function like the first version  of  'Box', except that the
##  color of the box will be <color>.  See "Color Models" for how to select a
##  <color>.
##
Box := NewOperation(
    "Box",
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsInt, IsRecord ] );


#############################################################################
##

#E  gobject.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
