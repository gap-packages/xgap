#############################################################################
##
#W  gobject.gi                 	XGAP library                     Frank Celler
##
#H  @(#)$Id: gobject.gi,v 1.4 1998/03/06 13:14:55 gap Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
Revision.pkg_xgap_lib_gobject_gi :=
    "@(#)$Id: gobject.gi,v 1.4 1998/03/06 13:14:55 gap Exp $";


#############################################################################
##

#R  IsGraphicObjectRep  . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsGraphicObjectRep",
    IsComponentObjectRep,
    [ "sheet", "color" ],
    IsGraphicObject );


#############################################################################
##
#M  ViewObj( <object> ) . . . . . . . . . . . . pretty print a graphic window
##
InstallMethod( ViewObj,
    "for graphic object",
    true,
    [ IsGraphicObject ],
    0,

function( obj )
    if IsAlive(obj)  then
        Print( "<graphic object>" );
    else
        Print( "<dead graphic object>" );
    fi;
end );


#############################################################################
##
#M  WindowId( <gobject> ) . for graphic object, return window id of the sheet
##
InstallOtherMethod( WindowId,
    "for graphic object",
    true,
    [ IsGraphicObject and IsGraphicObjectRep ],
    0,
    obj -> WindowId( obj!.sheet ) );


#############################################################################
##
#M  Delete( <object> )  . . . .  . . . delete a graphic object from its sheet
##
InstallOtherMethod( Delete,
    "for a graphic object",
    true,
    [ IsGraphicObject and IsGraphicObjectRep ],
    0,
function( obj )
    Delete( obj!.sheet, obj );
end );


#############################################################################
##
#M  GraphicObject( <sheet>, <ops>, <def> )  . . . . . . . . create a template
##
InstallMethod( GraphicObject,
    "for a representation, a graphic sheet, and defaults",
    true,
    [ IsFunction, IsGraphicSheet, IsRecord ], 0,
    function( repres, sheet, def )
    local   obj;

    # fill default record
    if not IsBound( def.color ) then
      if not IsMutable( def ) then def:= ShallowCopy( def ); fi;
      def.color := DefaultsForGraphicObject( sheet ).color;
    fi;
    if not IsBound( def.width ) then
      if not IsMutable( def ) then def:= ShallowCopy( def ); fi;
      def.width := DefaultsForGraphicObject( sheet ).width;
    fi;
    if not IsBound( def.label ) then
      if not IsMutable( def ) then def:= ShallowCopy( def ); fi;
      def.label := DefaultsForGraphicObject( sheet ).label;
    fi;

    # create a template
    obj            := Objectify( NewType( GraphicObjectFamily,
                                          repres and IsAlive ),
                                 rec() );
    obj!.sheet     := sheet;
    obj!.color     := def.color;

    # add object to list of objects stored in <S>
    if IsEmpty( sheet!.free ) then
        Add( sheet!.objects, obj );
    else
        sheet!.objects[sheet!.free[Length(sheet!.free)]] := obj;
        Unbind(sheet!.free[Length(sheet!.free)]);
    fi;

    # and return
    return obj;

end );


#############################################################################
##

#R  IsBoxObjectRep  . . . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsBoxObjectRep",
    IsGraphicObjectRep,
    [ "id", "x", "y", "w", "h", "x1", "x2", "y1", "y2" ],
    IsGraphicObject );


#############################################################################
##
#M  Box( <sheet>, <x>, <y>, <w>, <h> )  . . . . . . . . draw a box in a sheet
#M  Box( <sheet>, <x>, <y>, <w>, <h>, <defaults> )  . . draw a box in a sheet
##
InstallMethod( Box,
    "for sheet, four integers, and record of defaults",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt,
      IsInt,
      IsRecord ],
    0,

function( sheet, x, y, w, h, def )
    local   box;

    # create a box object in <sheet>
    box := GraphicObject( IsBoxObjectRep, sheet, def );
    box!.x := x;
    box!.y := y;
    box!.w := w;
    box!.h := h;

    # draw the Rectangle and get the identifier
    Draw(box);

    # and return
    return box;

end );


InstallOtherMethod( Box,
    "using default from sheet",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt,
      IsInt ],
    0,

function( sheet, x, y, w, h )
    return Box( sheet, x, y, w, h, DefaultsForGraphicObject(sheet) );
end );


#############################################################################
##
#M  Destroy( <box> )  . . . . . . . . . . . . . . . . . . . . . destroy <box>
##
InstallMethod( Destroy,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive],
    0,

function( box )
    WcDestroy( WindowId(box), box!.id );
    ResetFilterObj( box, IsAlive );
end );


#############################################################################
##
#M  Draw( <box> ) . . . . . . . . . . . . . . . . . . . . . . . .  draw a box
##
InstallMethod( Draw,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive ],
    0,

function( box )

    # create the other corner
    box!.x1 := box!.x;
    box!.x2 := box!.x + box!.w;
    box!.y1 := box!.y;
    box!.y2 := box!.y + box!.h;

    # draw the box and get the identifier
    WcSetColor( WindowId(box), ColorId(box!.color) );
    box!.id := WcDrawBox(WindowId(box), box!.x1, box!.y1, box!.x2, box!.y2);

end );


#############################################################################
##
#M  Move( <box>, <x>, <y> ) . . . . . . . . . . . . . . . . . . absolute move
##
InstallMethod( Move,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( box, x, y )

    # make sure that we really have to move
    if x = box!.x and y = box!.y  then return;  fi;

    # delete old box
    WcDestroy( WindowId(box), box!.id );

    # change the dimension
    box!.x := x;
    box!.y := y;

    # use 'Draw'
    Draw(box);

end );


#############################################################################
##
#M  MoveDelta( <box>, <dx>, <dy> )  . . . . . . . . . . . . . . .  delta move
##
InstallMethod( MoveDelta,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( box, dx, dy )

    # make sure that we really have to move
    if dx = 0 and dy = 0  then return;  fi;

    # delete old box
    WcDestroy( WindowId(box), box!.id );

    # change the dimension
    box!.x := box!.x + dx;
    box!.y := box!.y + dy;

    # use 'Draw'
    Draw(box);

end );


#############################################################################
##
#M  PostScriptString( <box> )
##
InstallMethod( PostScriptString,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep ],
    0,
    box -> Concatenation(
        "newpath\n",
        String(box!.x1), " ", String(box!.sheet!.height-box!.y1)," moveto\n",
        String(box!.x1), " ", String(box!.sheet!.height-box!.y2)," lineto\n",
        String(box!.x2), " ", String(box!.sheet!.height-box!.y2)," lineto\n",
        String(box!.x2), " ", String(box!.sheet!.height-box!.y1)," lineto\n",
        String(box!.x1), " ", String(box!.sheet!.height-box!.y1)," lineto\n",
        "closepath\nfill\n" ) );


#############################################################################
##
#M  PrintInfo( <box> )  . . . . . . . . . . . . . . . . . print debug message
##
InstallMethod( PrintInfo,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep ],
    0,

function( box )
    Print( "#I Box( ", box!.x, ", ", box!.y, ", ", box!.w, ", ",
           box!.h, " ) = ", box!.id, " @ ",
           Position(box!.sheet!.objects,box), "\n" );
end );


#############################################################################
##
#M  Recolor( <box>, <col> ) . . . . . . . . . . . . . . . . . .  change color
##
InstallMethod( Recolor,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive,
      IsColor ],
    0,

function( box, col )

    # remove old box
    WcDestroy( WindowId(box), box!.id );

    # set new color
    box!.color := col;

    # and create new one
    Draw(box);

end );


#############################################################################
##
#M  Reshape( <box>, <w>, <h> )  . . . . . . . . . . . . . . . .  change <box>
##
InstallOtherMethod( Reshape,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive, IsInt, IsInt ],
    0,

function( box, w, h )

    # remove old box
    WcDestroy( WindowId(box), box!.id );

    # update box coordinates
    box!.w := w;
    box!.h := h;

    # draw a new one
    Draw(box);

end );


#############################################################################
##
#M  ViewObj( <box> )  . . . . . . . . . . . . . . . . . .  pretty print a box
##
InstallMethod( ViewObj,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive ],
    0,

function( box )
    Print( "<box>" );
end );


#############################################################################
##
#M  \in( <pos>, <box> ) . . . . . . . . . . . . . . . . . . .  <pos> in <box>
##
InstallMethod( \in,
    "for a pair of integers, and a box",
    true,
    [ IsList and IsCyclotomicCollection,
      IsGraphicObject and IsBoxObjectRep and IsAlive ],
    0,

function( pos, box )
    local   x,  y,  ax,  ay,  ix,  iy;

    x  := pos[1];
    y  := pos[2];
    ax := Maximum( box!.x1, box!.x2 );
    ix := Minimum( box!.x1, box!.x2 );
    ay := Maximum( box!.y1, box!.y2 );
    iy := Minimum( box!.y1, box!.y2 );
    return ix <= x and x <= ax and iy <= y and y <= ay;

end );


#############################################################################
##

#E  gobject.gi	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here

