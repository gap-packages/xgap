#############################################################################
##
#W  gobject.gi                 	XGAP library                     Frank Celler
##
#H  @(#)$Id: gobject.gi,v 1.3 1998/03/05 16:49:26 gap Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
Revision.pkg_xgap_lib_gobject_gi :=
    "@(#)$Id: gobject.gi,v 1.3 1998/03/05 16:49:26 gap Exp $";


#############################################################################
##

#R  IsGraphicObjectRep  . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsGraphicObjectRep",
    IsComponentObjectRep,
    [],
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
#M  WindowId( <object> )  . . . . . . . . . . . pretty print a graphic window
##
##  return the window id of the sheet
##
InstallOtherMethod( WindowId,
    "for graphic object",
    true,
    [ IsGraphicObjectRep ],
    0,
    obj -> WindowId( obj!.sheet ) );


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
    if not IsBound(def.color)  then def.color := sheet!.defaults.color;  fi;
    if not IsBound(def.width)  then def.width := sheet!.defaults.width;  fi;
    if not IsBound(def.label)  then def.label := sheet!.defaults.label;  fi;
    
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
#F  Box( <sheet>, <x>, <y>, <w>, <h> )  . . . . . . . . draw a box in a sheet
##
InstallMethod( Box,
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
#F  Destroy( <box> )  . . . . . . . . . . . . . . . . . . . . .  detroy <box>
##
InstallMethod( Destroy,
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive],
    0,

function( box )
    WcDestroy( WindowId(box), box!.id );
    ResetFilterObj( box, IsAlive );
end );


#############################################################################
##
#F  Draw( <box> ) . . . . . . . . . . . . . . . . . . . . . . . .  draw a box
##
InstallMethod( Draw,
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
#F  Move( <box>, <x>, <y> ) . . . . . . . . . . . . . . . . . . absolute move
##
InstallMethod( Move,
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
#F  MoveDelta( <box>, <dx>, <dy> )  . . . . . . . . . . . . . . .  delta move
##
InstallMethod( MoveDelta,
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
#F  PrintInfo( <box> )  . . . . . . . . . . . . . . . . . print debug message
##
InstallMethod( PrintInfo,
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
#F  Recolor( <box>, <col> ) . . . . . . . . . . . . . . . . . .  change color
##
InstallMethod( Recolor,
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
#F  ViewObj( <box> )  . . . . . . . . . . . . . . . . . .  pretty print a box
##
InstallMethod( ViewObj,
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive ],
    0,

function( box )
    Print( "<box>" );
end );


#############################################################################
##

#E  gobject.gi	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
