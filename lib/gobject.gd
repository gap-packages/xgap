#############################################################################
##
#W  gobject.gd                 	XGAP library                     Frank Celler
##
#H  @(#)$Id: gobject.gd,v 1.5 1998/11/27 14:50:50 ahulpke Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
Revision.pkg_xgap_lib_gobject_gd :=
    "@(#)$Id: gobject.gd,v 1.5 1998/11/27 14:50:50 ahulpke Exp $";


#############################################################################
##
#C  IsGraphicObject . . . . . . . . . . . . . . . category of graphic objects
##
DeclareCategory( "IsGraphicObject", IsObject );


#############################################################################
##
#V  GraphicObjectFamily
##
BindGlobal( "GraphicObjectFamily",
    NewFamily( "GraphicObjectFamily", IsGraphicObject ) );


#############################################################################
##
#O  GraphicObject( <catrep>, <sheet>, <defaults> )  . . .  new graphic object
##
DeclareOperation( "GraphicObject", [ IsObject, IsGraphicSheet, IsRecord ] );


#############################################################################
##
#O  Delete( <sheet>, <object> ) . . .  delete a graphic object from its sheet
#O  Delete( <object> )  . . . . . . .  delete a graphic object from its sheet
##
DeclareOperation( "Delete", [ IsGraphicSheet, IsGraphicObject ] );


#############################################################################
##
#O  Destroy( <object> ) . . . . . . . . . . . . . .  destroy a graphic object
##
##  Note that <object> is *not* deleted from the list of objects on its
##  graphic sheet <sheet>.  In order to delete <object> from <sheet>,
##  use `Delete( <sheet>, <obj> )', which calls `Destroy' for <obj>.
##
DeclareOperation( "Destroy", [ IsGraphicObject ] );


#############################################################################
##
#O  Revive( <object> ) . . . . . . . . . . . . . revive a dead graphic object
##
##  Note that <object> is this is only possible for `Destroyed', not
##  for `Deleted' graphic objects.
##
DeclareOperation( "Revive", [ IsGraphicObject ] );


#############################################################################
##
#O  Draw( <object> )  . . . . . . . . . . . . . . . (re)draw a graphic object
##
DeclareOperation( "Draw", [ IsGraphicObject ] );


#############################################################################
##
#O  Move( <object>, <x>, <y> )  . . . . . . . . . . . . . . . . absolute move
##
DeclareOperation( "Move", [ IsGraphicObject, IsInt, IsInt ] );


#############################################################################
##
#O  MoveDelta( <object>, <dx>, <dy> ) . . . . . . . . . . . . . .  delta move
##
DeclareOperation( "MoveDelta", [ IsGraphicObject, IsInt, IsInt ] );


#############################################################################
##
#O  PrintInfo( <object> ) . . . . . . . . . . . . . . . . .  print debug info
##
DeclareOperation( "PrintInfo", [ IsGraphicObject ] );
#T regard this as a special case of `Display'?


#############################################################################
##
#O  PSString( <object> )  . . . . . . . . . . . . . . . . . PostScript string
##
DeclareOperation( "PSString", [ IsGraphicObject ] );


#############################################################################
##
#O  Recolor( <object>, <col> )  . . . . . . . . . . . . . . . .  change color
##
DeclareOperation( "Recolor", [ IsGraphicObject, IsColor ] );

DeclareSynonym( "Recolour", Recolor );


#############################################################################
##
#O  Reshape( <object>, ... )  . . . . . . . . . . . . . . . reshape an object
##
DeclareOperation( "Reshape", [ IsGraphicObject, IsObject ] );


#############################################################################
##
#O  Change( <object>, ... ) . . . . . . . . . . . . . . . .  change an object
##
DeclareOperation( "Change", [ IsGraphicObject, IsObject ] );


#############################################################################
##
#O  Relabel( <object>, ... )  . . . . . . . . . . . . . . . relabel an object
##
DeclareOperation( "Relabel", [ IsObject, IsString ] );


#############################################################################
##
#O  LabelPosition( <object>, ... )  . . . . . . . . .  calculate a label pos.
##
DeclareOperation( "LabelPosition", [ IsGraphicObject ] );


#############################################################################
##
#O  SetWidth( <object>, w )  . . . . . . . . . . . . . . .  change line width
##
DeclareOperation( "SetWidth", [ IsGraphicObject, IsObject ] );


#############################################################################
##
#O  Box( <sheet>, <x>, <y>, <w>, <h> )  . . . . . . . . draw a box in a sheet
#O  Box( <sheet>, <x>, <y>, <w>, <h>, <defaults> )  . . draw a box in a sheet
##
##
##  creates a new graphic object,  namely a filled black  box, on the graphic
##  sheet <sheet> and  returns a {\GAP} record describing  this  object.  The
##  four   corners     of  the    box    are   $(<x>,<y>)$,  $(<x>+<w>,<y>)$,
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
DeclareOperation( "Box",
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  Circle( <sheet>, <x>, <y>, <r> )  . . . . . . .  draw a circle in a sheet
#O  Circle( <sheet>, <x>, <y>, <r>, <defaults> )  .  draw a circle in a sheet
##
##  ...
##
DeclareOperation( "Circle",
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  Disc( <sheet>, <x>, <y>, <r> )  . . . . . . . . .  draw a disc in a sheet
#O  Disc( <sheet>, <x>, <y>, <r>, <defaults> )  . . .  draw a disc in a sheet
##
DeclareOperation( "Disc",
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  Diamond( <sheet>, <x>, <y>, <w>, <h> )  . . . . draw a diamond in a sheet
#O  Diamond( <sheet>, <x>, <y>, <w>, <h>, <defaults> )
##
DeclareOperation( "Diamond",
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  Rectangle( <sheet>, <x>, <y>, <w>, <h> )  . . draw a Rectangle in a sheet
#O  Rectangle( <sheet>, <x>, <y>, <w>, <h>, <defaults> )
##
DeclareOperation( "Rectangle",
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  Line( <sheet>, <x>, <y>, <w>, <h> ) . . . . . . .  draw a line in a sheet
#O  Line( <sheet>, <x>, <y>, <w>, <h>, <defaults> ) .  draw a line in a sheet
##
DeclareOperation( "Line",
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  Text( <sheet>, <font>, <x>, <y>, <str> )  . . . . write a text in a sheet
#O  Text( <sheet>, <font>, <x>, <y>, <str>, <defaults> )
##
DeclareOperation( "Text",
    [ IsGraphicSheet, IsFont, IsInt, IsInt, IsString, IsRecord ] );


#############################################################################
##
#O  Vertex( <sheet>, <x>, <y> ) . . . . . . . . . . . . . . . . draw a vertex
#O  Vertex( <sheet>, <x>, <y>, <defaults> ) . . . . . . . . . . draw a vertex
##
DeclareOperation( "Vertex",
    [ IsGraphicSheet, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  ConnectionPosition( <vertex>, <x>, <y> ) . calculate pos. of a connection
##
DeclareOperation( "ConnectionPosition", 
        [ IsGraphicObject, IsInt, IsInt ] );


#############################################################################
##
#O  Connection( <vertex>, <vertex>) . . . . . . . . . .  connect two vertices
#O  Connection( <vertex>, <vertex>, <def>)  . . . . . .  connect two vertices
##
##  The second variation can get a default record for the actual line. The
##  same entries as in the default record for lines are allowed.
DeclareOperation( "Connection", 
        [ IsGraphicObject,
          IsGraphicObject ] );


#############################################################################
##
#O  Disconnect( <vertex>, <vertex>) .  delete connection between two vertices
##
DeclareOperation( "Disconnect", 
        [ IsGraphicObject,
          IsGraphicObject ] );


#############################################################################
##
#O  Highlight( <vertex>, ... ) . . . .  switch highlightning status of vertex
##
DeclareOperation( "Highlight", 
        [ IsGraphicObject, IsBool ] );


#############################################################################
##

#E  gobject.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

