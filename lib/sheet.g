#############################################################################
##
#A  sheet.g                   	XGAP library                     Frank Celler
##
#H  @(#)$Id: sheet.g,v 1.1 1997/11/27 12:20:07 frank Exp $
##
#Y  Copyright (C) 1993,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##
##  This file contains all functions for graphic sheets, the low level window
##  functions are in "window.g".  The menu functions are in "menu.g".
##
#H  $Log: sheet.g,v $
#H  Revision 1.1  1997/11/27 12:20:07  frank
#H  added 3.5 library (does not work with 4.0)
#H
#H  Revision 1.17  1995/08/10  18:06:27  fceller
#H  changed 'Box', 'Rectangle', 'Diamond' and 'Line'
#H  to expect the start position and a width and height
#H
#H  Revision 1.16  1995/08/09  10:52:04  fceller
#H  changed print routines,
#H  tried to fix postscript text output
#H
#H  Revision 1.15  1995/07/24  10:01:24  fceller
#H  changed select mechanism
#H
#H  Revision 1.14  1995/05/29  14:39:02  fceller
#H  selected nicer TX position for vertices
#H
#H  Revision 1.13  1995/03/06  11:39:19  fceller
#H  added 'VertexOps.\='
#H
#H  Revision 1.12  1995/02/16  20:46:41  fceller
#H  added rectangles
#H
#H  Revision 1.11  1995/02/16  15:18:54  fceller
#H  added color support
#H
#H  Revision 1.10  1994/06/06  09:21:16  fceller
#H  added missing variable
#H
#H  Revision 1.9  1994/06/06  08:39:07  fceller
#H  added 'Relabel' for lines
#H
#H  Revision 1.8  1993/10/28  15:12:12  fceller
#H  fixed a bug in 'SavePSFile'
#H
#H  Revision 1.7  1993/10/06  16:19:23  fceller
#H  fixed 'Move' of vertex
#H
#H  Revision 1.6  1993/10/05  12:33:26  fceller
#H  added '.isAlive'
#H
#H  Revision 1.5  93/09/22  10:19:51  fceller
#H  added 'VertexOps.Destroy'
#H  
#H  Revision 1.4  1993/08/18  10:59:49  fceller
#H  removed emacs variables
#H
#H  Revision 1.3  1993/08/13  13:38:39  fceller
#H  added 'VertexOps.MoveDelta'
#H
#H  Revision 1.2  1993/07/22  11:24:32  fceller
#H  split files into three: "window.g", "sheet.g", "menu.g"
#H
#H  Revision 1.1  1993/07/21  12:32:42  fceller
#H  Initial revision
##


#############################################################################
##
#F  GraphicSheet( <name>, <width>, <height> ) . . . . . . a new graphic sheet
##
GraphicSheetOps := rec( name := "GraphicSheetOps" );

GraphicSheet := function( name, width, height )
    local   w,  txt;

    # open a new graphic sheet and store the identifier
    w := WcOpenWindow( name, width, height );

    # construct a new graphic sheet record
    w.isGraphicSheet := true;
    w.name           := Copy(name);
    w.title          := w.name;
    w.width          := width;
    w.height         := height;
    w.objects        := [];
    w.free           := [];
    w.isAlive        := true;
    w.fastUpdate     := 0;
    w.operations     := GraphicSheetOps;

    # set defaults for color, line width, shape
    w.defaults       := rec();
    w.defaults.color := COLORS.black;
    w.defaults.width := 1;
    w.defaults.shape := 1;
    w.defaults.label := false;

    # add menu to close GraphicSheet
    w.operations.MakeGAPMenu(w);

    # add close function
    InstallGSMethod( w, "Close", Ignore );

    # return the graphic sheet <w>
    return w;

end;


#############################################################################
##
#F  GraphicSheetOps.Close( <sheet> )  . . . . . . . . . . close graphic sheet
##
GraphicSheetOps.Close := function( sheet )
    local   obj;

    sheet.close(sheet);
    sheet.isAlive := false;
    WcCloseWindow(sheet.id);
    for obj  in sheet.objects  do
        obj.isAlive := false;
    od;
end;


#############################################################################
##
#F  GraphicSheetOps.CreateObject( <sheet>, <ops>, <def> ) . create a template
##
GraphicSheetOps.CreateObject := function( sheet, ops, def )
    local   obj;

    # fill default record
    if not IsBound(def.color)  then def.color := sheet.defaults.color;  fi;
    if not IsBound(def.width)  then def.width := sheet.defaults.width;  fi;
    if not IsBound(def.label)  then def.label := sheet.defaults.label;  fi;

    # create a template
    obj            := rec();
    obj.sheet      := sheet;
    obj.color      := def.color;
    obj.isAlive    := true;
    obj.operations := ops;
    
    # add object to list of objects stored in <S>    
    if 0 = Length(sheet.free)  then
        Add( sheet.objects, obj );
    else
        sheet.objects[sheet.free[Length(sheet.free)]] := obj;
        Unbind(sheet.free[Length(sheet.free)]);
    fi;
    
    # and return
    return obj;

end;


#############################################################################
##
#F  GraphicSheetOps.Delete( <sheet>, <obj> )  . . . . delete <obj> in <sheet>
##
GraphicSheetOps.Delete := function( sheet, obj )
    local   pos;
    
    # find position of object
    pos := Position( sheet.objects, obj );
    
    # destroy object
    obj.operations.Destroy(obj);
    
    # and remove it from the list of objects
    Unbind(sheet.objects[pos]);
    Add( sheet.free, pos );

end;


#############################################################################
##
#F  GraphicSheetOps.FastUpdate( <sheet>, <flag> ) . . . .  fast update on/off
##
GraphicSheetOps.FastUpdate := function( sheet, flag )

    # fast update on
    if flag  then
        if 0 = sheet.fastUpdate  then
            WcFastUpdate( sheet.id, true );
        fi;
        sheet.fastUpdate := sheet.fastUpdate + 1;

    # fast update off
    else
        if 0 = sheet.fastUpdate  then
            Error( "FastUpdate(false) without FastUpdate(true)" );
        fi;
        if 1 = sheet.fastUpdate  then
            WcFastUpdate( sheet.id, false );
        fi;
        sheet.fastUpdate := sheet.fastUpdate - 1;
    fi;

end;


#############################################################################
##
#F  GraphicSheetOps.GMCloseGS( <sheet>, <menu>, <entry> ) . . . . .  close GS
##
GraphicSheetOps.GMCloseGS := function( sheet, menu, entry )
    sheet.operations.Close(sheet);
end;
        

#############################################################################
##
#F  GraphicSheetOps.GMSaveAsPS( <sheet>, <menu>, <entry> )  . . .  save as PS
##
GraphicSheetOps.GMSaveAsPS := function( sheet, menu, entry )
    local   res;
    
    if IsBound(sheet.filenamePS)  then
        res := Query( FILENAME_DIALOG, sheet.filenamePS );
    else
        res := Query( FILENAME_DIALOG, "" );
    fi;
    if res = false  then
        return;
    fi;
    sheet.filenamePS := res;
    sheet.operations.SavePSFile( sheet, res );
        
end;

#############################################################################
##
#F  GraphicSheetOps.InstallGSMethod( <sheet>, <name>, <meth> )  .  use <meth>
##
GraphicSheetOps.InstallGSMethod := function( sheet, name, meth )
    local   names,  funcs,  pos;

    names := [ "Close",
               "LeftPBDown",
               "RightPBDown",
               "ShiftLeftPBDown",
               "ShiftRightPBDown",
               "CtrlLeftPBDown",
               "CtrlRightPBDown" ];
    funcs := [ "close",
               "leftPointerButtonDown",
               "rightPointerButtonDown",
               "shiftLeftPointerButtonDown",
               "shiftRightPointerButtonDown",
               "ctrlLeftPointerButtonDown",
               "ctrlRightPointerButtonDown" ];

    # find the <name> and use the corresponding record component
    pos := Position( names, name );
    if pos = false  then
        Error( "unkown graphic sheet method ", name );
    fi;
    sheet.(funcs[pos]) := meth;

end;


#############################################################################
##
#F  GraphicSheetOps.PointerButtonDown( <sheet>, <x>, <y>, <bt>, <md> )  click
##
GraphicSheetOps.PointerButtonDown := function( sheet, x, y, bt, md )
    local   upper,  lower,  name;

    upper := "LRSC";
    lower := "lrsc";
    name := "PointerButtonDown";
    if bt = BUTTONS.left  then
        name := Concatenation( "Left", name );
    else
        name := Concatenation( "Right", name );
    fi;
    if QuoInt(md,BUTTONS.shift) mod 2 = 1  then
        name := Concatenation( "Shift", name );
    fi;
    if QuoInt(md,BUTTONS.ctrl) mod 2 = 1  then
        name := Concatenation( "Ctrl", name );
    fi;
    name[1] := lower[Position(upper,name[1])];
    if IsBound(sheet.(name))  then
        return sheet.(name)( sheet, x, y );
    fi;
end;


#############################################################################
##
#F  GraphicSheetOps.Print( <sheet> )  . . . . .  pretty print a graphic sheet
##
GraphicSheetOps.Print := function( sheet )
    if sheet.isAlive  then
        Print( "<graphic sheet \"", sheet.name, "\">" );
    else
        Print( "<dead graphic sheet>" );
    fi;
end;
    

#############################################################################
##
#F  GraphicSheetOps.Resize( <sheet>, <width>, <height> )  . . .  resize sheet
##
GraphicSheetOps.Resize := function( sheet, width, height )
    WcResizeWindow( sheet.id, width, height );
    sheet.height := height;
    sheet.width  := width;
end;

    
#############################################################################
##
#F  GraphicSheetOps.SavePSFile( <sheet>, <file> ) . . . .  save as PostScript
##
GraphicSheetOps.SavePSFile := function( sheet, file )
    local   a,  b,  obj,  str;

    # set filename and create file
    PrintTo( file, "%!PS-Adobe-2.0\n" );

    # collect string in <str>
    str := "";
    
    # landscape or portrait
    if sheet.height <= sheet.width  then
        Append( str, "90 rotate\n" );
        a := QuoInt( sheet.height*1000, 6 );
        b := QuoInt( sheet.width*1000,  8 );
        a := Maximum(a,b);
        Append( str, "100000 " );
        Append( str, String(a) );
        Append( str, " div 100000 " );
        Append( str, String(a) );
        Append( str, " div scale\n" );
        Append( str, "0 " );
        Append( str, String(-sheet.height) );
        Append( str, " translate\n" );
    else
        a := QuoInt( sheet.height*1000, 8 );
        b := QuoInt( sheet.width*1000,  6 );
        a := Maximum(a,b);
        Append( str, "100000 " );
        Append( str, String(a) );
        Append( str, " div 100000 " );
        Append( str, String(a) );
        Append( str, " div scale\n" );
    fi;
    for obj  in sheet.objects  do
        Append( str, obj.operations.PSString(obj) );
    od;
    Append( str, "showpage\n" );
    AppendTo( file, str );

end;


#############################################################################
##
#F  GraphicSheetOps.SetTitle( <sheet>, <text> ) . . . . . . .  set title text
##
GraphicSheetOps.SetTitle := function( sheet, text )
    sheet.title := text;
    WcSetTitle( sheet.id, text );
end;


#############################################################################
##
#F  GraphicSheetOps.ShowObjectId( <sheet>, <x>, <y> ) print object at <x>,<y>
##
GraphicSheetOps.ShowObjectId := function( sheet, x, y )
    local   x,  y,  pos,  elm,  one;

    # try to locate a graphic object at position <x>, <y>
    pos := [ x, y ];
    one := false;
    for elm  in sheet.objects  do
    	if pos in elm  then
            elm.operations.PrintInfo(elm);
            one := true;
    	fi;
    od;
    
    # tell the user if there are no objects at this position
    if not one  then
        Print("#I  there are no objects at position [",x,", ",y,"]\n");
    fi;

    # restore old title and button function
    sheet.operations.SetTitle( sheet, sheet.saveTitle );
    sheet.leftPointerButtonDown := sheet.saveLeftPointerButtonDown;
    Unbind( sheet.saveLeftPointerButtonDown );
    Unbind( sheet.saveTitle );
    
end;


#############################################################################
##
#F  GraphicSheetOps.ShowObjectPS( <sheet>, <x>, <y> ) . . show PostScript def
##
GraphicSheetOps.ShowObjectPS := function( sheet, x, y )
    local   x,  y,  pos,  elm,  one;

    # try to locate a graphic object at position <x>, <y>
    pos := [ x, y ];
    one := false;
    for elm  in sheet.objects  do
    	if pos in elm  then
            elm.operations.PrintInfo(elm);
            Print( elm.operations.PSString(elm) );
            one := true;
    	fi;
    od;
    
    # tell the user if there are no objects at this position
    if not one  then
        Print("#I  there are no objects at position [",x,", ",y,"]\n");
    fi;

    # restore old title and button function
    sheet.operations.SetTitle( sheet, sheet.saveTitle );
    sheet.leftPointerButtonDown := sheet.saveLeftPointerButtonDown;
    Unbind( sheet.saveLeftPointerButtonDown );
    Unbind( sheet.saveTitle );
    
end;


#############################################################################
##
#F  GraphicSheetOps.MakeGAPMenu( <sheet> )  . . . . .  create a standard menu
##
GraphicSheetOps.GAPMenu := [
    "save",                   Ignore,
    "save as",                Ignore,
    ,                         Ignore,
    "save as postscript",     GraphicSheetOps.GMSaveAsPS,
    "save as LaTeX",          Ignore,
    ,                         Ignore,
    "close graphic sheet",    GraphicSheetOps.GMCloseGS
];

GraphicSheetOps.MakeGAPMenu := function( sheet )
    sheet.gapMenu := Menu( sheet, "GAP", sheet.operations.GAPMenu );
    Enable( sheet.gapMenu, "save", false );
    Enable( sheet.gapMenu, "save as", false );
    Enable( sheet.gapMenu, "save as LaTeX", false );
end;


#############################################################################
##

#F  GraphicObjectOps  . . . . . . . . . operations record for graphic objects
##
GraphicObjectOps := OperationsRecord( "GraphicObjectOps" );

GraphicObjectOps.Delete := function( obj )
    return obj.sheet.operations.Delete( obj.sheet, obj );
end;


#############################################################################
##

#F  Box( <sheet>, <x>, <y>, <w>, <h> )  . . . . . . . . draw a box in a sheet
##
BoxOps := OperationsRecord( "BoxOps", GraphicObjectOps );

Box := function(arg)
    if Length(arg) = 5  then
        return arg[1].operations.Box( arg[1], arg[2], arg[3], arg[4],
                                      arg[5], arg[1].defaults );
    elif Length(arg) = 6  then
        return arg[1].operations.Box( arg[1], arg[2], arg[3], arg[4],
                                      arg[5], arg[6] );
    else
        Error( "usage: Box( <sheet>, <x1>, <y1>, <x2>, <y2> )" );
    fi;
end;

GraphicSheetOps.Box := function( sheet, x, y, w, h, def )
    local   box;

    # create a box object in <sheet>
    box       := sheet.operations.CreateObject( sheet, BoxOps, def );
    box.isBox := true;
    box.x     := x;
    box.y     := y;
    box.w     := w;
    box.h     := h;

    # draw the Rectangle and get the identifier
    box.operations.Draw(box);

    # and return
    return box;

end;


#############################################################################
##
#F  BoxOps.Destroy( <box> ) . . . . . . . . . . . . . . . . . .  detroy <box>
##
BoxOps.Destroy := function( box )
    WcDestroy( box.sheet.id, box.id );
    box.isAlive := false;
end;


#############################################################################
##
#F  BoxOps.Draw( <box> )  . . . . . . . . . . . . . . . . . . . .  draw a box
##
BoxOps.Draw := function( box )

    # create the other corner
    box.x1 := box.x;
    box.x2 := box.x + box.w;
    box.y1 := box.y;
    box.y2 := box.y + box.h;

    # draw the box and get the identifier
    WcSetColor( box.sheet.id, box.color );
    box.id := WcDrawBox( box.sheet.id, box.x1, box.y1, box.x2, box.y2 );

end;


#############################################################################
##
#F  BoxOps.Move( <box>, <x>, <y> )  . . . . . . . . . . . . . . absolute move
##
BoxOps.Move := function( box, x, y )
    
    # make sure that we really have to move
    if x = box.x and y = box.y  then return;  fi;

    # delete old box
    WcDestroy( box.sheet.id, box.id );

    # change the dimension
    box.x := x;
    box.y := y;

    # use 'Draw'
    box.operations.Draw(box);
    
end;


#############################################################################
##
#F  BoxOps.MoveDelta( <box>, <dx>, <dy> ) . . . . . . . . . . . .  delta move
##
BoxOps.MoveDelta := function( box, dx, dy )
    
    # make sure that we really have to move
    if dx = 0 and dy = 0  then return;  fi;

    # delete old box
    WcDestroy( box.sheet.id, box.id );

    # change the dimension
    box.x := box.x + dx;
    box.y := box.y + dy;

    # use 'Reshape'
    box.operations.Draw(box);
    
end;


#############################################################################
##
#F  BoxOps.PSString( <box> )  . . . . . . . . . . . . . . . PostScript string
##
BoxOps.PSString := function( box )
    return Concatenation(
        "newpath\n",
        String(box.x1), " ", String(box.sheet.height-box.y1), " moveto\n",
        String(box.x1), " ", String(box.sheet.height-box.y2), " lineto\n",
        String(box.x2), " ", String(box.sheet.height-box.y2), " lineto\n",
        String(box.x2), " ", String(box.sheet.height-box.y1), " lineto\n",
        String(box.x1), " ", String(box.sheet.height-box.y1), " lineto\n",
        "closepath\nfill\n" );
end;


#############################################################################
##
#F  BoxOps.Print( <box> ) . . . . . . . . . . . . . . . .  pretty print a box
##
BoxOps.Print := function( box )
    if not box.isAlive  then
        Print( "<dead box>" );
    else
        Print( "<box>" );
    fi;
end;

BoxOps.PrintInfo := function( box )
    Print( "#I Box( ", box.x, ", ", box.y, ", ", box.w, ", ",
           box.h, " ) = ", box.id, " @ ", 
           Position(box.sheet.objects,box), "\n" );
end;


#############################################################################
##
#F  BoxOps.Recolor( <box>, <col> )  . . . . . . . . . . . . . .  change color
##
BoxOps.Recolor := function( box, col )

    # remove old box
    WcDestroy( box.sheet.id, box.id );
    
    # set new color
    box.color := col;

    # and create new one
    box.operations.Draw(box);
    
end;


#############################################################################
##
#F  BoxOps.Reshape( <box>, <w>, <h> ) . . . . . . . . . . . . .  change <box>
##
BoxOps.Reshape := function( box, w, h )

    # remove old box
    WcDestroy( box.sheet.id, box.id );
    
    # update box coordinates
    box.w := w;
    box.h := h;

    # draw a new one
    box.operations.Draw(box);

end;


#############################################################################
##
#F  BoxOps.in( <pos>, <box> ) . . . . . . . . . . . . . . . .  <pos> in <box>
##
BoxOps.\in := function( pos, box )
    local   x,  y,  ax,  ay,  ix,  iy;

    x  := pos[1];
    y  := pos[2];
    ax := Maximum( box.x1, box.x2 );
    ix := Minimum( box.x1, box.x2 );
    ay := Maximum( box.y1, box.y2 );
    iy := Minimum( box.y1, box.y2 );
    return ix <= x and x <= ax and iy <= y and y <= ay;
    
end;


#############################################################################
##

#F  Circle( <sheet>, <x>, <y>, <r> )  . . . . . . .  draw a circle in a sheet
##
CircleOps := OperationsRecord( "CircleOps", GraphicObjectOps );

Circle := function(arg)
    if Length(arg) = 4  then
        return arg[1].operations.Circle( arg[1], arg[2], arg[3], arg[4],
                                         arg[1].defaults );
    elif Length(arg) = 5  then
        return arg[1].operations.Circle( arg[1], arg[2], arg[3], arg[4],
                                         arg[5] );
    else
        Error( "usage: Circle( <sheet>, <x>, <y>, <r> )" );
    fi;
end;

GraphicSheetOps.Circle := function( sheet, x, y, r, def )
    local   circle;

    # create a circle record
    circle          := sheet.operations.CreateObject(sheet, CircleOps, def);
    circle.isCircle := true;
    circle.x        := x;
    circle.y        := y;
    circle.r        := Maximum( 1, AbsInt(r) );
    circle.width    := def.width;

    # draw the circle and get the identifier
    WcSetColor( sheet.id, circle.color );
    WcSetLineWidth( sheet.id, circle.width );
    circle.id := WcDrawCircle( sheet.id, x, y, r );

    # and return
    return circle;

end;


#############################################################################
##
#F  CircleOps.Destroy( <circle> ) . . . . . . . . . . . . .  destroy <circle>
##
CircleOps.Destroy := function( circle )
    WcDestroy( circle.sheet.id, circle.id );
    circle.isAlive := false;
end;


#############################################################################
##
#F  CircleOps.Move( <circle>, <x>, <y> )  . . . . . . . . . . . absolute move
##
CircleOps.Move := function( circle, x, y )

    # make sure that we really have to move
    if x = circle.x and y = circle.y  then return;  fi;

    # remove old circle
    WcDestroy( circle.sheet.id, circle.id );

    # update coordinates
    circle.x := x;
    circle.y := y;

    # and draw a new circle
    WcSetColor( circle.sheet.id, circle.color );
    WcSetLineWidth( circle.sheet.id, circle.width );
    circle.id := WcDrawCircle(circle.sheet.id, circle.x, circle.y, circle.r);

end;


#############################################################################
##
#F  CircleOps.MoveDelta( <circle>, <dx>, <dy> ) . . . . . . . . .  delta move
##
CircleOps.MoveDelta := function( circle, dx, dy )

    # make sure that we really have to move
    if dx = 0 and dy = 0  then return;  fi;

    # remove old circle
    WcDestroy( circle.sheet.id, circle.id );

    # update coordinates
    circle.x := circle.x+dx;
    circle.y := circle.y+dy;

    # and draw a new circle
    WcSetColor( circle.sheet.id, circle.color );
    WcSetLineWidth( circle.sheet.id, circle.width );
    circle.id := WcDrawCircle(circle.sheet.id, circle.x, circle.y, circle.r);

end;


#############################################################################
##
#F  CircleOps.PSString( <circle> )  . . . . . . . . . . . . PostScript string
##
CircleOps.PSString := function( circle )
    return Concatenation(
        "newpath\n",
        String(circle.x), " ", String(circle.sheet.height-circle.y), " ",
        String(circle.r), " 0 360 arc\n",
        String(circle.width), " setlinewidth\n",
        "stroke\n" );
end;


#############################################################################
##
#F  CircleOps.Print( <circle> ) . . . . . . . . . . . . pretty print a circle
##
CircleOps.Print := function( circle )
    if not circle.isAlive  then
        Print( "<dead circle>" );
    else
        Print( "<circle>" );
    fi;
end;

CircleOps.PrintInfo := function( circle )
    Print( "#I  Circle( ", circle.x, ", ", circle.y, ", ",
           circle.r, " ) = ", circle.id, " @ ",
    	   Position(circle.sheet.objects,circle), "\n" );
end;


#############################################################################
##
#F  CircleOps.Recolor( <circle>, <col> )  . . . . . . . . . . .  change color
##
CircleOps.Recolor := function( circle, col )

    # remove old circle
    WcDestroy( circle.sheet.id, circle.id );

    # change color
    circle.color := col;

    # and draw a new circle
    WcSetColor( circle.sheet.id, circle.color );
    WcSetLineWidth( circle.sheet.id, circle.width );
    circle.id := WcDrawCircle(circle.sheet.id, circle.x, circle.y, circle.r);

end;


#############################################################################
##
#F  CircleOps.Reshape( <circle>, <r> )  . . . . . . . . . . . . change radius
##
CircleOps.Reshape := function( circle, r )
    
    # remove old circle
    WcDestroy( circle.sheet.id, circle.id );
    
    # and update radius
    circle.r := Maximum( AbsInt(r), 1 );

    # and create a new one
    WcSetColor( circle.sheet.id, circle.color );
    WcSetLineWidth( circle.sheet.id, circle.width );
    circle.id := WcDrawCircle(circle.sheet.id, circle.x, circle.y, circle.r);

end;


#############################################################################
##
#F  CircleOps.SetWidth( <circle>, <with> )  . . . . . . . . . .  change width
##
CircleOps.SetWidth := function( circle, width )
    
    # remove old circle
    WcDestroy( circle.sheet.id, circle.id );
    
    # change line width
    circle.width := width;

    # and draw a new circle
    WcSetLineWidth( circle.sheet.id, circle.width );
    circle.id := WcDrawCircle(circle.sheet.id, circle.x, circle.y, circle.r);

end;


#############################################################################
##
#F  CircleOps.in( <pos>, <circle> ) . . . . . . . . . . . . <pos> in <circle>
##
CircleOps.\in := function( pos, circle )
    return (pos[1]-circle.x)^2+(pos[2]-circle.y)^2 < (circle.r+3)^2;
end;


#############################################################################
##

#F  Disc( <sheet>, <x>, <y>, <r> )  . . . . . . . . .  draw a disc in a sheet
##
DiscOps := OperationsRecord( "DiscOps", GraphicObjectOps );

Disc := function(arg)
    if Length(arg) = 4  then
        return arg[1].operations.Disc( arg[1], arg[2], arg[3], arg[4],
                                       arg[1].defaults );
    elif Length(arg) = 5  then
        return arg[1].operations.Disc( arg[1], arg[2], arg[3], arg[4],
                                       arg[5] );
    else
        Error( "usage: Disc( <sheet>, <x>, <y>, <r> )" );
    fi;
end;

GraphicSheetOps.Disc := function( sheet, x, y, r, def )
    local   disc;

    # create a disc record
    disc        := sheet.operations.CreateObject( sheet, DiscOps, def );
    disc.isDisc := true;
    disc.x      := x;
    disc.y      := y;
    disc.r      := AbsInt(r);

    # draw the disc and get the identifier
    WcSetColor( sheet.id, disc.color );
    disc.id := WcDrawDisc( sheet.id, x, y, r );

    # and return
    return disc;

end;


#############################################################################
##
#F  DiscOps.Destroy( <disc> ) . . . . . . . . . . . . . . . .  destroy <disc>
##
DiscOps.Destroy := function( disc )
    WcDestroy( disc.sheet.id, disc.id );
    disc.isAlive := false;
end;


#############################################################################
##
#F  DiscOps.Move( <disc>, <x>, <y> )  . . . . . . . . . . . . . absolute move
##
DiscOps.Move := function( disc, x, y )

    # make sure that we really have to move
    if disc.x = x and disc.y = y  then return;  fi;

    # remove old circle
    WcDestroy( disc.sheet.id, disc.id );

    # update coordinates
    disc.x := x;
    disc.y := y;

    # and draw a new circle
    WcSetColor( disc.sheet.id, disc.color );
    disc.id := WcDrawDisc( disc.sheet.id, disc.x, disc.y, disc.r );

end;


#############################################################################
##
#F  DiscOps.MoveDelta( <disc>, <dx>, <dy> ) . . . . . . . . . . .  delta move
##
DiscOps.MoveDelta := function( disc, dx, dy )

    # make sure that we really have to move
    if dx = 0 and dy = 0  then return;  fi;

    # remove old circle
    WcDestroy( disc.sheet.id, disc.id );

    # update coordinates
    disc.x := disc.x+dx;
    disc.y := disc.y+dy;

    # and draw a new circle
    WcSetColor( disc.sheet.id, disc.color );
    disc.id := WcDrawDisc( disc.sheet.id, disc.x, disc.y, disc.r );

end;


#############################################################################
##
#F  DiscOps.PSString( <disc> )  . . . . . . . . . . . . . . PostScript string
##
DiscOps.PSString := function( disc )
    return Concatenation(
        "newpath\n",
        String(disc.x), " ", String(disc.sheet.height-disc.y), " ",
        String(disc.r), " 0 360 arc\nfill\n" );
end;


#############################################################################
##
#F  DiscOps.Print( <disc> ) . . . . . . . . . . . . . . . pretty print a disc
##
DiscOps.Print := function( disc )
    if not disc.isAlive  then
        Print( "<dead disc>" );
    else
        Print( "<disc>" );
    fi;
end;

DiscOps.PrintInfo := function( disc )
    Print( "#I  Disc( ", disc.x, ", ", disc.y, ", ",
           disc.r, " ) = ", disc.id, " @ ",
    	   Position(disc.sheet.objects,disc), "\n" );
end;


#############################################################################
##
#F  DiscOps.Recolor( <disc>, <col> )  . . . . . . . . . . . . .  change color
##
DiscOps.Recolor := function( disc, col )

    # remove old disc
    WcDestroy( disc.sheet.id, disc.id );

    # change color
    disc.color := col;

    # and draw a new disc
    WcSetColor( disc.sheet.id, disc.color );
    disc.id := WcDrawDisc( disc.sheet.id, disc.x, disc.y, disc.r );

end;


#############################################################################
##
#F  DiscOps.Reshape( <disc>, <r> )  . . . . . . . . . . . . . . change radius
##
DiscOps.Reshape := function( disc, r )
    
    # remove old disc
    WcDestroy( disc.sheet.id, disc.id );
    
    # update radius
    disc.r := AbsInt(r);

    # and create a new one
    WcSetColor( disc.sheet.id, disc.color );
    disc.id := WcDrawDisc( disc.sheet.id, disc.x, disc.y, disc.r );

end;


#############################################################################
##
#F  DiscOps.in( <pos>, <disc> ) . . . . . . . . . . . . . . . <pos> in <disc>
##
DiscOps.\in := function( pos, disc )
    return (pos[1]-disc.x)^2+(pos[2]-disc.y)^2 <= (disc.r)^2;
end;


#############################################################################
##

#F  Diamond( <sheet>, <x>, <y>, <w>, <h> )  . . . . draw a diamond in a sheet
##
DiamondOps := OperationsRecord( "DiamondOps", GraphicObjectOps );

Diamond := function(arg)
    if Length(arg) = 5  then
        return arg[1].operations.Diamond( arg[1], arg[2], arg[3], arg[4],
                                          arg[5], arg[1].defaults );
    elif Length(arg) = 6  then
        return arg[1].operations.Diamond( arg[1], arg[2], arg[3], arg[4],
                                          arg[5], arg[6] );
    else
        Error( "usage: Diamond( <sheet>, <x1>, <y1>, <x2>, <y2> )" );
    fi;
end;

GraphicSheetOps.Diamond := function( sheet, x, y, w, h, def )
    local   dia,  x3,  y3,  x4,  y4;

    # create a diamond record
    dia           := sheet.operations.CreateObject( sheet, DiamondOps, def );
    dia.isDiamond := true;
    dia.width     := def.width;
    dia.x         := x;
    dia.y         := y;
    dia.w         := w;
    dia.h         := h;

    # draw the diamond and get the identifier
    dia.operations.Draw(dia);

    # and return
    return dia;

end;


#############################################################################
##
#F  DiamondOps.Draw( <dia> )  . . . . . . . . . . . . . . . .  draw a diamond
##
DiamondOps.Draw := function( dia )
    local   x1,  y1,  x2,  y2,  x3,  y3,  x4,  y4;

    # create the four corners
    x1 := dia.x;
    y1 := dia.y;
    x2 := dia.x + dia.w;
    y2 := dia.y + dia.h;
    x3 := 2*x2-x1;
    y3 := y1;
    x4 := x2;
    y4 := 2*y1-y2;
    
    # set the coordinates
    dia.x1 := x1;
    dia.x2 := x2;
    dia.y1 := y1;
    dia.y2 := y2;
    dia.x3 := x3;
    dia.y3 := y3;
    dia.x4 := x4;
    dia.y4 := y4;

    # draw the diamond and get the identifier
    WcSetColor( dia.sheet.id, dia.color );
    WcSetLineWidth( dia.sheet.id, dia.width );
    dia.id1 := WcDrawLine( dia.sheet.id, x1, y1, x2, y2 );
    dia.id2 := WcDrawLine( dia.sheet.id, x2, y2, x3, y3 );
    dia.id3 := WcDrawLine( dia.sheet.id, x3, y3, x4, y4 );
    dia.id4 := WcDrawLine( dia.sheet.id, x4, y4, x1, y1 );
end;


#############################################################################
##
#F  DiamondOps.Destroy( <dia> ) . . . . . . . . . . . . . . . . destroy <dia>
##
DiamondOps.Destroy := function( dia )
    WindowCmd([ "XRO", dia.sheet.id, dia.id1, dia.id2, dia.id3, dia.id4 ]);
    dia.isAlive := false;
end;


#############################################################################
##
#F  DiamondOps.Move( <dia>, <x>, <y> )  . . . . . . . . . . .   absolute move
##
DiamondOps.Move := function( dia, x, y )
    local   x1,  x2,  x3,  x4,  y1,  y2,  y3,  y4;
    
    # make sure that we really have to move
    if x = dia.x and y = dia.y  then return;  fi;

    # delete old lines
    WcDestroy( dia.sheet.id, dia.id1, dia.id2, dia.id3, dia.id4 );
    
    # change coordinates
    dia.x := x;
    dia.y := y;
          
    # redraw the lines
    dia.operations.Draw(dia);
    
end;


#############################################################################
##
#F  DiamondOps.MoveDelta( <dia>, <dx>, <dy> ) . . . . . . . . . .  delta move
##
DiamondOps.MoveDelta := function( dia, dx, dy )
    local   x1,  x2,  x3,  x4,  y1,  y2,  y3,  y4;
    
    # make sure that we really have to move
    if dx = 0 and dy = 0  then return;  fi;

    # delete old lines
    WcDestroy( dia.sheet.id, dia.id1, dia.id2, dia.id3, dia.id4 );
    
    # change coordinates
    dia.x := dia.x + dx;
    dia.y := dia.y + dy;
          
    # redraw the lines
    dia.operations.Draw(dia);
    
end;


#############################################################################
##
#F  DiamondOps.PSString( <dia> )  . . . . . . . . . . . . . PostScript string
##
DiamondOps.PSString := function( dia )
    local   x1,  x2,  x3,  x4,  y1,  y2,  y3,  y4;
    
    x1 := dia.x1;  y1 := dia.sheet.height - dia.y1;
    x2 := dia.x2;  y2 := dia.sheet.height - dia.y2;
    x3 := dia.x3;  y3 := dia.sheet.height - dia.y3;
    x4 := dia.x4;  y4 := dia.sheet.height - dia.y4;
    return Concatenation(
        "newpath\n",
        String(x1), " ", String(y1), " moveto\n",
        String(x2), " ", String(y2), " lineto\n",
        String(x3), " ", String(y3), " lineto\n",
        String(x4), " ", String(y4), " lineto\n",
        String(x1), " ", String(y1), " lineto\n",
        String(dia.width), " setlinewidth\n",
        "closepath\nstroke\n" );
end;


#############################################################################
##
#F  DiamondOps.Print( <dia> ) . . . . . . . . . . . .  pretty print a diamond
##
DiamondOps.Print := function( dia )
    if not dia.isAlive  then
        Print( "<dead diamond>" );
    else
        Print( "<diamond>" );
    fi;
end;

DiamondOps.PrintInfo := function( dia )
    Print( "#I  Diamond( ", dia.x, ", ", dia.y, ", ",
           dia.w, ", ", dia.h, " ) = ", dia.id1, "+",
           dia.id2, "+", dia.id3, "+", dia.id4, " @ ",
    	   Position(dia.sheet.objects,dia), "\n" );
end;


#############################################################################
##
#F  DiamondOps.Recolor( <dia>, <col> )  . . . . . . . . . . . .  change color
##
DiamondOps.Recolor := function( dia, col )
    local   x1,  x2,  x3,  x4,  y1,  y2,  y3,  y4;
    
    # update the color
    dia.color := col;

    # delete old lines
    WcDestroy( dia.sheet.id, dia.id1, dia.id2, dia.id3, dia.id4 );
    
    # redraw the lines
    dia.operations.Draw(dia);
    
end;


#############################################################################
##
#F  DiamondOps.Reshape( <dia>, <w>, <h> ) . . . . . . . . . . .  change shape
##
DiamondOps.Reshape := function( dia, w, h )
    local   dia,  x3,  y3,  x4,  y4;

    # delete old lines
    WcDestroy( dia.sheet.id, dia.id1, dia.id2, dia.id3, dia.id4 );
    
    # change the coordinates
    dia.w := w;
    dia.h := h;

    # redraw the lines
    dia.operations.Draw(dia);
    
end;


#############################################################################
##
#F  DiamondOps.SetWidth( <dia>, <width> ) . . . . . . . . . . .  change width
##
DiamondOps.SetWidth := function( dia, width )
    local   x1,  x2,  x3,  x4,  y1,  y2,  y3,  y4;
    
    # delete old lines
    WcDestroy( dia.sheet.id, dia.id1, dia.id2, dia.id3, dia.id4 );
    
    # set new width
    dia.width := width;

    # readraw the lines
    dia.operations.Draw(dia);

end;


#############################################################################
##
#F  DiamondOps.in( <pos>, <dia> ) . . . . . . . . . . . . . .  <pos> in <dia>
##
DiamondOps.\in := function( pos, dia )
    return     Minimum( dia.x1, dia.x3 ) <= pos[1]
           and pos[1] <= Maximum( dia.x1, dia.x3 )
           and Minimum( dia.y2, dia.y4 ) <= pos[2]
           and pos[2] <= Maximum( dia.y2, dia.y4 );    
end;


#############################################################################
##

#F  Rectangle( <sheet>, <x>, <y>, <w>, <h> )  . . draw a Rectangle in a sheet
##
RectangleOps := OperationsRecord( "RectangleOps", GraphicObjectOps );

Rectangle := function(arg)
    if Length(arg) = 5  then
        return arg[1].operations.Rectangle( arg[1], arg[2], arg[3], arg[4],
                                          arg[5], arg[1].defaults );
    elif Length(arg) = 6  then
        return arg[1].operations.Rectangle( arg[1], arg[2], arg[3], arg[4],
                                          arg[5], arg[6] );
    else
        Error( "usage: Rectangle( <sheet>, <x>, <y>, <w>, <h> )" );
    fi;
end;

GraphicSheetOps.Rectangle := function( sheet, x, y, w, h, def )
    local   ret;

    # create a rectangle record
    ret             := sheet.operations.CreateObject(sheet,RectangleOps,def);
    ret.isRectangle := true;
    ret.width       := def.width;
    ret.x           := x;
    ret.y           := y;
    ret.w           := w;
    ret.h           := h;

    # draw the Rectangle and get the identifier
    ret.operations.Draw(ret);

    # and return
    return ret;

end;


#############################################################################
##
#F  RectangleOps.Destroy( <ret> ) . . . . . . . . . . . . . . . destroy <ret>
##
RectangleOps.Destroy := function( ret )
    WindowCmd([ "XRO", ret.sheet.id, ret.id1, ret.id2, ret.id3, ret.id4 ]);
    ret.isAlive := false;
end;


#############################################################################
##
#F  RectangleOps.Draw( <ret> )  . . . . . . . . . . . . . .  draw a rectangle
##
RectangleOps.Draw := function( ret )
    local   x1,  y1,  x2,  y2,  x3,  y3,  x4,  y4;

    # create the other four corner points
    x1 := ret.x;
    y1 := ret.y;
    x2 := ret.x + ret.w;
    y2 := ret.y + ret.h;
    if x2 < x1  then
        x3 := x1;  x1 := x2;  x2 := x3;
        y3 := y1;  y1 := y2;  y2 := y3;
    fi;
    x3 := x2;
    y3 := y1;
    x4 := x1;
    y4 := y2;
    
    # store the points in <ret>
    ret.x1 := x1;
    ret.x2 := x2;
    ret.y1 := y1;
    ret.y2 := y2;
    ret.x3 := x3;
    ret.y3 := y3;
    ret.x4 := x4;
    ret.y4 := y4;

    WcSetColor( ret.sheet.id, ret.color );
    WcSetLineWidth( ret.sheet.id, ret.width );
    ret.id1 := WcDrawLine( ret.sheet.id, x1, y1, x3, y3 );
    ret.id2 := WcDrawLine( ret.sheet.id, x3, y3, x2, y2 );
    ret.id3 := WcDrawLine( ret.sheet.id, x2, y2, x4, y4 );
    ret.id4 := WcDrawLine( ret.sheet.id, x4, y4, x1, y1 );

end;


#############################################################################
##
#F  RectangleOps.Move( <ret>, <x>, <y> )  . . . . . . . . . . . absolute move
##
RectangleOps.Move := function( ret, x, y )
    
    # make sure that we really have to move
    if x = ret.x and y = ret.y  then return;  fi;

    # delete old lines
    WcDestroy( ret.sheet.id, ret.id1, ret.id2, ret.id3, ret.id4 );
    
    # change coordinates
    ret.x := x;
    ret.y := y;

    # redraw the lines
    ret.operations.Draw(ret);
    
end;


#############################################################################
##
#F  RectangleOps.MoveDelta( <ret>, <dx>, <dy> ) . . . . . . . . .  delta move
##
RectangleOps.MoveDelta := function( ret, dx, dy )
    local   x1,  x2,  x3,  x4,  y1,  y2,  y3,  y4;
    
    # make sure that we really have to move
    if dx = 0 and dy = 0  then return;  fi;

    # delete old lines
    WcDestroy( ret.sheet.id, ret.id1, ret.id2, ret.id3, ret.id4 );
    
    # change coordinates
    ret.x := ret.x + dx;
    ret.y := ret.y + dy;

    # redraw the lines
    ret.operations.Draw(ret);
    
end;


#############################################################################
##
#F  RectangleOps.PSString( <ret> )  . . . . . . . . . . . . PostScript string
##
RectangleOps.PSString := function( ret )
    local   x1,  x2,  x3,  x4,  y1,  y2,  y3,  y4;
    
    x1 := ret.x1;  y1 := ret.sheet.height - ret.y1;
    x2 := ret.x2;  y2 := ret.sheet.height - ret.y2;
    x3 := ret.x3;  y3 := ret.sheet.height - ret.y3;
    x4 := ret.x4;  y4 := ret.sheet.height - ret.y4;
    return Concatenation(
        "newpath\n",
        String(x1), " ", String(y1), " moveto\n",
        String(x3), " ", String(y3), " lineto\n",
        String(x2), " ", String(y2), " lineto\n",
        String(x4), " ", String(y4), " lineto\n",
        String(x1), " ", String(y1), " lineto\n",
        String(ret.width), " setlinewidth\n",
        "closepath\nstroke\n" );
end;


#############################################################################
##
#F  RectangleOps.Print( <ret> ) . . . . . . . . . .  pretty print a Rectangle
##
RectangleOps.Print := function( ret )
    if not ret.isAlive  then
        Print( "<dead rectangle>" );
    else
        Print( "<rectangle>" );
    fi;
end;

RectangleOps.PrintInfo := function( ret )
    Print( "#I Rectangle( ", ret.x, ", ", ret.y, ", ", ret.w, ", ",
           ret.h, " ) = ", ret.id1, "+", ret.id2, "+", ret.id3, "+",
           ret.id4, " @ ", Position(ret.sheet.objects,ret), "\n" );
end;


#############################################################################
##
#F  RectangleOps.Recolor( <ret>, <col> )  . . . . . . . . . . .  change color
##
RectangleOps.Recolor := function( ret, col )
    local   x1,  x2,  x3,  x4,  y1,  y2,  y3,  y4;
    
    # update the color
    ret.color := col;

    # delete old lines
    WcDestroy( ret.sheet.id, ret.id1, ret.id2, ret.id3, ret.id4 );
    
    # redraw the lines
    ret.operations.Draw(ret);
    
end;


#############################################################################
##
#F  RectangleOps.Reshape( <ret>, <w>, <h> ) . . . . . . . . . .  change shape
##
RectangleOps.Reshape := function( ret, w, h )

    # change the width and height
    ret.w := w;
    ret.h := h;

    # delete old lines
    WcDestroy( ret.sheet.id, ret.id1, ret.id2, ret.id3, ret.id4 );
    
    # redraw the lines
    ret.operations.Draw(ret);
    
end;


#############################################################################
##
#F  RectangleOps.SetWidth( <ret>, <width> ) . . . . . . . . . .  change width
##
RectangleOps.SetWidth := function( ret, width )
    
    # delete old lines
    WcDestroy( ret.sheet.id, ret.id1, ret.id2, ret.id3, ret.id4 );
    
    # set new width
    ret.width := width;

    # readraw the lines
    ret.operations.Draw(ret);

end;


#############################################################################
##
#F  RectangleOps.in( <pos>, <ret> ) . . . . . . . . . . . . .  <pos> in <ret>
##
RectangleOps.\in := function( pos, ret )
    return ret.x1 <= pos[1]
           and pos[1] <= ret.x2
           and Minimum(ret.y1,ret.y2) <= pos[2]
           and pos[2] <= Maximum(ret.y1,ret.y2);
end;


#############################################################################
##

#F  Line( <sheet>, <x>, <y>, <w>, <h> ) . . . . . . .  draw a line in a sheet
##
LineOps := OperationsRecord( "LineOps", GraphicObjectOps );

Line := function(arg)
    if Length(arg) = 5  then
        return arg[1].operations.Line( arg[1], arg[2], arg[3], arg[4],
                                       arg[5], arg[1].defaults );
    elif Length(arg) = 6  then
        return arg[1].operations.Line( arg[1], arg[2], arg[3], arg[4],
                                       arg[5], arg[6] );
    else
        Error( "usage: Line( <sheet>, <x1>, <y1>, <x2>, <y2> )" );
    fi;
end;

GraphicSheetOps.Line := function( sheet, x, y, w, h, def )
    local   line;

    # create a line object in <sheet>
    line        := sheet.operations.CreateObject( sheet, LineOps, def );
    line.isLine := true;
    line.x      := x;
    line.y      := y;
    line.w      := w;
    line.h      := h;
    line.width  := def.width;
    line.label  := def.label;

    # draw the line
    line.operations.Draw(line);

    # and return
    return line;

end;


#############################################################################
##
#F  LineOps.Change( <line>, <x>, <y>, <w>, <h> )  . . . . . . . change <line>
##
LineOps.Change := function( line, x, y, w, h )
    local   pos;

    # remove old line
    WcDestroy( line.sheet.id, line.id );

    # update line coordinates
    line.x := x;
    line.y := y;
    line.w := w;
    line.h := h;

    # and redraw it
    line.operations.Draw(line);
    
end;


#############################################################################
##
#F  LineOps.Destroy( <line> ) . . . . . . . . . . . . . . . .  destroy <line>
##
LineOps.Destroy := function( line )
    if line.label <> false  then
        line.sheet.operations.Delete( line.sheet, line.label);
    fi;
    WcDestroy( line.sheet.id, line.id );
    line.isAlive := false;
end;


#############################################################################
##
#F  LineOps.Draw( <line> )  . . . . . . . . . . . . . . . . . . . draw a line
##
LineOps.Draw := function( line )

    # compute the coordinates
    line.x1 := line.x;
    line.x2 := line.x + line.w;
    line.y1 := line.y;
    line.y2 := line.y + line.h;

    # set a label
    if line.label <> false  then
        line.operations.Relabel( line, line.label.text );
    fi;

    # draw the line and get the identifier
    WcSetLineWidth( line.sheet.id, line.width );
    WcSetColor( line.sheet.id, line.color );
    line.id := WcDrawLine(line.sheet.id,line.x1,line.y1,line.x2,line.y2);

end;


#############################################################################
##
#F  LineOps.LabelPosition( <line> ) . . . . . . . . . . . . position of label
##
LineOps.LabelPosition := function( line )
    local   x1,  y1,  x2,  y2,  x,  y;

    if line.y1 < line.y2  then
        x1 := line.x1;  x2 := line.x2;
        y1 := line.y1;  y2 := line.y2;
    else
        x1 := line.x2;  x2 := line.x1;
        y1 := line.y2;  y2 := line.y1;
    fi;
    x := x1 + QuoInt( x2-x1, 2 );
    y := y1 + QuoInt( y2-y1, 2 );
    if x1-10*FONTS.tiny[1] < x2 and x2 < x1+10*FONTS.tiny[1]  then
        x := x + QuoInt(FONTS.tiny[1],2);
    fi;
    if y2 < y1+(FONTS.tiny[2]+FONTS.tiny[1])*3  then
        y := y - QuoInt( FONTS.tiny[2]+FONTS.tiny[3], 2 );
    fi;
    if x2 < x1 then
        x := x + FONTS.tiny[1];
    fi;
    return [ x, y ];

end;


#############################################################################
##
#F  LineOps.Move( <line>, <x>, <y> )  . . . . . . . . . . . . . absolute move
##
LineOps.Move := function( line, x, y )
    
    # make sure that we really have to move
    if x = line.x and y = line.y  then return;  fi;

    # update coordinates
    line.x := x;
    line.y := y;

    # remove old line
    WcDestroy( line.sheet.id, line.id );

    # use 'Draw'
    line.operations.Draw(line);

end;


#############################################################################
##
#F  LineOps.MoveDelta( <line>, <dx>, <dy> ) . . . . . . . . . . .  delta move
##
LineOps.MoveDelta := function( line, dx, dy )
    
    # make sure that we really have to move
    if dx = 0 and dy = 0  then return;  fi;

    # update coordinates
    line.x := line.x + dx;
    line.y := line.y + dy;

    # remove old line
    WcDestroy( line.sheet.id, line.id );

    # use 'Draw'
    line.operations.Draw(line);

end;


#############################################################################
##
#F  LineOps.PSString( <line> )	. . . . . . . . . . . . . . PostScript string
##
LineOps.PSString := function( line )
    return Concatenation(
        "newpath\n",
        String(line.x1), " ", String(line.sheet.height-line.y1), " moveto\n",
        String(line.x2), " ", String(line.sheet.height-line.y2), " lineto\n",
        String(line.width), " setlinewidth\n",
        "stroke\n" );
end;


#############################################################################
##
#F  LineOps.Print( <line> ) . . . . . . . . . . . . . . . pretty print a line
##
LineOps.Print := function( line )
    if not line.isAlive  then
        Print( "<dead line>" );
    else
        Print( "<line>" );
    fi;
end;

LineOps.PrintInfo := function( line )
    Print( "#I  Line( ", line.x, ", ", line.y, ", ",
           line.w, ", ", line.h, " ) = ", line.id, " @ ",
    	   Position(line.sheet.objects,line), "\n" );
end;


#############################################################################
##
#F  LineOps.Recolor( <line>, <col> )  . . . . . . . . . . . . .  change color
##
LineOps.Recolor := function( line, col )

    # remove old line
    WcDestroy( line.sheet.id, line.id );

    # set new color
    line.color := col;

    # and create a new one
    line.operations.Draw(line);
    
end;


#############################################################################
##
#F  LineOps.Relabel( <line>, <text> ) . . . . . . . .  change label of <line>
##
LineOps.Relabel := function( line, text )
    local   pos,  col;

    if line.label <> false  then
        line.sheet.operations.Delete( line.sheet, line.label );
    fi;
    if text = false  then
        line.label := false;
    else
        pos := line.operations.LabelPosition(line);
        col := rec( color := line.color );
        line.label := Text(line.sheet,FONTS.tiny,pos[1],pos[2],text,col);
    fi;
end;


#############################################################################
##
#F  LineOps.Reshape( <line>, <w>, <h> ) . . . . . . . . . . . . change <line>
##
LineOps.Reshape := function( line, w, h )
    local   pos;

    # remove old line
    WcDestroy( line.sheet.id, line.id );

    # update line coordinates
    line.w := w;
    line.h := h;

    # and redraw it
    line.operations.Draw(line);
    
end;


#############################################################################
##
#F  LineOps.SetWidth( <line>, <width> )	. . . . . . . . . . . .  change width
##
LineOps.SetWidth := function( line, width )
    if line.width <> width  then
        line.width := width;
        WcDestroy( line.sheet.id, line.id );
        line.operations.Draw(line);
    fi;
end;


#############################################################################
##
#F  LineOps.in( <pos>, <line> )	. . . . . . . . . . . . . . . <pos> on <line>
##
LineOps.\in := function( pos, line )
    local   x,  y,  ax,  ay,  ix,  iy;
    
    x  := pos[1];
    y  := pos[2];
    ax := Maximum( line.x1, line.x2 );
    ix := Minimum( line.x1, line.x2 );
    ay := Maximum( line.y1, line.y2 );
    iy := Minimum( line.y1, line.y2 );
    if 5 < x-ax or 5 < ix-x  then
    	return false;
    elif 5 < y-ay or 5 < iy-y  then
    	return false;
    elif ax = ix or ay = iy  then
    	return true;
    else
    	return AbsInt((x-line.x1)*(line.y2-line.y1)
               /(line.x2-line.x1)-(y-line.y1)) < 5;
    fi;
    
end;


#############################################################################
##

#F  Text( <sheet>, <font>, <x>, <y>, <str> )  . . . . write a text in a sheet
##
TextOps := OperationsRecord( "TextOps", GraphicObjectOps );

Text := function(arg)
    if Length(arg) = 5  then
        return arg[1].operations.Text( arg[1], arg[2], arg[3], arg[4],
                                       arg[5], arg[1].defaults );
    elif Length(arg) = 6  then
        return arg[1].operations.Text( arg[1], arg[2], arg[3], arg[4],
                                       arg[5], arg[6] );
    else
        Error( "usage: Text( <sheet>, <font>, <x>, <y>, <str> )" );
    fi;
end;

GraphicSheetOps.Text := function( sheet, font, x, y, str, def )
    local   text;

    # create a text object in <sheet>
    text        := sheet.operations.CreateObject( sheet, TextOps, def );
    text.isText := true;
    text.x      := x;
    text.y      := y;
    text.text   := Copy(str);

    # set font id
    if IsInt(font)  then
        text.font := font;
    else
        text.font := Position( FONTS.fonts, font );
    fi;

    # draw the text and get the identifier
    WcSetColor( text.sheet.id, text.color );
    text.id := WcDrawText( sheet.id, text.font, text.x, text.y, text.text );
    
    # and return
    return text;

end;


#############################################################################
##
#F  TextOps.Destroy( <text> ) . . . . . . . . . . . . . . . .  destroy <text>
##
TextOps.Destroy := function( text )
    WindowCmd([ "XRO", text.sheet.id, text.id ]);
    text.isAlive := false;
end;


#############################################################################
##
#F  TextOps.Move( <text>, <x>, <y> )  . . . . . . . . . . . . . absolute move
##
TextOps.Move := function( text, x, y )
    
    # make sure that we really have to move
    if x = text.x and y = text.y  then return;  fi;

    # destroy old text
    WcDestroy( text.sheet.id, text.id );
    
    # and redraw it at the new position
    WcSetColor( text.sheet.id, text.color );
    text.x := x;
    text.y := y;
    text.id := WcDrawText(text.sheet.id,text.font,text.x,text.y,text.text);

end;


#############################################################################
##
#F  TextOps.MoveDelta( <text>, <dx>, <dy> ) . . . . . . . . . . .  delta move
##
TextOps.MoveDelta := function( text, dx, dy )
    
    # make sure that we really have to move
    if dx = 0 and dy = 0  then return;  fi;

    # destroy old text
    WcDestroy( text.sheet.id, text.id );
    
    # and redraw it at the new position
    WcSetColor( text.sheet.id, text.color );
    text.x := text.x + dx;
    text.y := text.y + dy;
    text.id := WcDrawText(text.sheet.id,text.font,text.x,text.y,text.text);

end;


#############################################################################
##
#F  TextOps.PSString( <text> )  . . . . . . . . . . . . . . PostScript string
##
TextOps.PSString := function( text )
    local   save_text,  c,  a,  b;

    save_text := "";
    for c  in text.text  do
        if c = ')'  then
            Add( save_text, '\\' );
        fi;
        Add( save_text, c );
    od;
    a := QuoInt( FONTS.fonts[text.font][1] * 150, 100 );
    b := QuoInt( FONTS.fonts[text.font][3] * 168, 100 );
    return Concatenation(
        "/Courier findfont [", String(b), " 0 0 ", String(a),
        " 0 0] makefont setfont\n",
        String(text.x), " ", String(text.sheet.height-text.y), " moveto\n",
        "(", save_text, ") show\n" );
end;


#############################################################################
##
#F  TextOps.Print( <text> ) . . . . . . . . . . .  pretty print a text object
##
TextOps.Print := function( text )
    if not text.isAlive  then
        Print( "<dead text>" );
    else
        Print( "<text>" );
    fi;
end;

TextOps.PrintInfo := function( text )
    Print( "#I  Text( ", text.font, ", ", text.x, ", ",
           text.y, ", \"", text.text, "\" ) = ", text.id, " @ ",
           Position(text.sheet.objects,text), "\n" );
end;


#############################################################################
##
#F  TextOps.Recolor( <text>, <col> )  . . . . . . . . . . . . . .change color
##
TextOps.Recolor := function( text, col )

    # destroy old text
    WcDestroy( text.sheet.id, text.id );
    
    # and redraw with a new color
    text.color := col;
    WcSetColor( text.sheet.id, text.color );
    text.id := WcDrawText(text.sheet.id,text.font,text.x,text.y,text.text);

end;


#############################################################################
##
#F  TextOps.Relabel( <text>, <label> )  . . . . . . . . . . . . . change text
##
TextOps.Relabel := function( text, label )

    # destroy old text
    WcDestroy( text.sheet.id, text.id );
    
    # and redraw with a new label
    text.text := Copy(label);
    WcSetColor( text.sheet.id, text.color );
    text.id := WcDrawText(text.sheet.id,text.font,text.x,text.y,text.text);

end;


#############################################################################
##
#F  TextOps.in( <pos>, <text> ) . . . . . . . . . . . . . . . <text> in <pos>
##
TextOps.\in := function( pos, text )
    local   d,  x1,  x2,  y1,  y2;

    d  := FONTS.fonts[text.font];
    y1 := text.y - d[1];
    y2 := text.y + d[2];
    x1 := text.x;
    x2 := text.x + Length(text.text) * d[3];
    return x1 <= pos[1] and pos[1] <= x2 and y1 <= pos[2] and pos[2] <= y2;
    
end;


#############################################################################
##

#F  Vertex( <sheet>, <x>, <y> )	. . . . . . . . . . . . . . . . draw a vertex
##
VertexOps := OperationsRecord( "VertexOps", GraphicObjectOps );

Vertex := function(arg)
    if Length(arg) = 3  then
        return arg[1].operations.Vertex( arg[1], arg[2], arg[3],
                                         arg[1].defaults );
    elif Length(arg) = 4  then
        return arg[1].operations.Vertex( arg[1], arg[2], arg[3], arg[4] );
    else
        Error( "usage: Vertex( <sheet>, <x>, <y> )" );
    fi;
end;

GraphicSheetOps.Vertex := function( sheet, x, y, def )
    local   r,  ver,  label;
    
    # compute the radius
    r := QuoInt( 5*FONTS.tiny[3]+20*(FONTS.tiny[1]+FONTS.tiny[2])+16, 15 );

    # create a vertex record in <sheet>
    ver           := sheet.operations.CreateObject( sheet, VertexOps, def );
    ver.isVertex  := true;
    ver.x         := x;
    ver.y         := y;
    ver.r         := r;
    ver.ty        := QuoInt( 2*y+FONTS.tiny[1]-FONTS.tiny[2]+1, 2 );
    ver.tx        := [ x-QuoInt(10*FONTS.tiny[3],20),
                       x-QuoInt(10*FONTS.tiny[3],10),
                       x-QuoInt(28*FONTS.tiny[3],20),
                       x-QuoInt(18*FONTS.tiny[3],10) ];
    ver.outline   := [ Circle(sheet,x,y,r,rec(color:=ver.color)) ];
    ver.shape     := VERTEX.circle;
    ver.highlight := false;

    # set label
    ver.label := false;
    if def.label = false  then
        label := false;
    else
        label := def.label{[ 1 .. Minimum(4,Length(def.label)) ]};
    fi;
    ver.operations.Relabel( ver, label );
    
    # add list of connections
    ver.connections     := [];
    ver.connectingLines := [];
    
    # and return
    return ver;

end;


#############################################################################
##
#V  VERTEX  . . . . . . . . . . . . . . . . . . . . . . .  vertex information
##
VERTEX := rec();
VERTEX.circle    := 1;
VERTEX.diamond   := 2;
VERTEX.rectangle := 4;
VERTEX.radius    :=
    QuoInt(5*FONTS.tiny[3]+20*(FONTS.tiny[1]+FONTS.tiny[2])+16,15);
VERTEX.diameter  := 2*VERTEX.radius;


#############################################################################
##
#F  VertexOps.Connection( <C>, <D> )  . . . . . . . . .  connect two vertices
##
VertexOps.Connection := function( C, D )
    local   L,  pos1,  pos2;
    
    # check if <C> and <D> are already connected
    if C in D.connections  then
    	return D.connectingLines[ Position( D.connections, C ) ];
    fi;

    # compute position
    pos1 := C.operations.PositionConnection( C, D.x, D.y );
    pos2 := D.operations.PositionConnection( D, C.x, C.y );

    # create a line between <C> and <D>
    L := Line( C.sheet, pos1[1], pos1[2], pos2[1]-pos1[1], pos2[2]-pos1[2] );

    # add line to connections of <C> and <D>
    Add( C.connections, D );  Add( C.connectingLines, L );
    Add( D.connections, C );  Add( D.connectingLines, L );

    # and return the line
    return L;

end;


#############################################################################
##
#F  VertexOps.Destroy( <ver> )  . . . . . . . . . . . . . . . . destroy <ver>
##
VertexOps.Destroy := function( ver )
    local   l;

    for l  in ver.connections  do
        ver.operations.Disconnect( ver, l );
    od;
    for l  in ver.outline  do
        ver.sheet.operations.Delete( ver.sheet, l );
    od;
    if ver.label <> false  then
        ver.sheet.operations.Delete( ver.sheet, ver.label );
    fi;
    ver.isAlive := false;
end;


#############################################################################
##
#F  VertexOps.Disconnect( <C>, <D> )  . . . . . . . . disconnect two vertices
##
VertexOps.Disconnect := function( C, D )
    local   pos,  L;
    
    # <C> and <D> must be connected
    pos := Position( D.connections, C );
    if pos = false  then
        Error( "<C> and <D> must be connected" );
    fi;
    
    # remove connection from <C> and <D>
    L := D.connectingLines[pos];
    D.connections := Concatenation(
        D.connections{[1..pos-1]},
        D.connections{[pos+1..Length(D.connections)]} );
    D.connectingLines := Concatenation(
        D.connectingLines{[1..pos-1]},
        D.connectingLines{[pos+1..Length(D.connectingLines)]} );
    pos := Position( C.connections, D );
    C.connections := Concatenation(
        C.connections{[1..pos-1]},
        C.connections{[pos+1..Length(C.connections)]} );
    C.connectingLines := Concatenation(
        C.connectingLines{[1..pos-1]},
        C.connectingLines{[pos+1..Length(C.connectingLines)]} );
    
    # finally delete <L>
    C.sheet.operations.Delete( C.sheet, L );
    
end;


#############################################################################
##
#F  VertexOps.Highlight( <ver>, <flag> )  . . . . . . . . .  highlight vertex
##
VertexOps.Highlight := function( ver, flag )
    local   obj;
    
    ver.highlight := flag;
    if ver.highlight  then
        for obj  in ver.outline  do
            obj.operations.SetWidth( obj, 2 );
        od;
    else
        for obj  in ver.outline  do
            obj.operations.SetWidth( obj, 1 );
        od;
    fi;

end;


#############################################################################
##
#F  VertexOps.Move( <ver>, <x>, <y> ) . . . . . . . . . . . . . absolute move
##
VertexOps.Move := function( ver, x, y )
    local   dx,  dy,  obj,  ver2,  pos1,  pos2,  i;
    
    # compute delta move
    dx := x-ver.x;
    dy := y-ver.y;
    if dx = 0 and dy = 0  then return;  fi;
    ver.x  := x;
    ver.y  := y;
    ver.tx := ver.tx + dx;
    ver.ty := ver.ty + dy;
    
    # move all objects
    for obj  in ver.outline  do
        obj.operations.MoveDelta( obj, dx, dy );
    od;
    ver.label.operations.MoveDelta( ver.label, dx, dy );
    
    # move all connections
    for i  in [ 1 .. Length(ver.connections) ]  do
        ver2 := ver.connections[i];
        pos1 := ver.operations.PositionConnection( ver, ver2.x, ver2.y );
        pos2 := ver2.operations.PositionConnection( ver2, ver.x, ver.y );
        obj  := ver.connectingLines[i];
        obj.operations.Change( obj, pos1[1],         pos1[2],
                                    pos2[1]-pos1[1], pos2[2]-pos1[2] );
    od;

end;


#############################################################################
##
#F  VertexOps.MoveDelta( <ver>, <dx>, <dy> )  . . . . . . . . . .  delta move
##
VertexOps.MoveDelta := function( ver, dx, dy )
    if dx = 0 and dy = 0  then return;  fi;
    ver.operations.Move( ver, ver.x+dx, ver.y+dy );
end;


#############################################################################
##
#F  VertexOps.PSString( <ver> ) . . . . . . . . . . . . . . . . .  do nothing
##
VertexOps.PSString := function( ver )
    return "";
end;


#############################################################################
##
#F  VertexOps.PositionConnection( <ver>, <x>, <y> ) .  connection to <x>, <y>
##
VertexOps.PositionConnection := function( ver, x, y )
    
    # on the same line connect horizontal
    if AbsInt( ver.y - y ) < ver.r  then
        if x < ver.x  then
            return [ ver.x - ver.r, ver.y ];
        else
            return [ ver.x + ver.r, ver.y ];
        fi;
        
    # is it above
    elif y < ver.y  then
        return [ ver.x, ver.y - ver.r ];
        
    # otherwise it is below
    else
        return [ ver.x, ver.y + ver.r ];
    fi;
    
end;


#############################################################################
##
#F  VertexOps.Print( <ver> )  . . . . . . . . . . . . . pretty print a vertex
##
VertexOps.Print := function( ver )
    if not ver.isAlive  then
        Print( "<dead vertex>" );
    elif ver.label = false  then
        Print( "<vertex>" );
    else
        Print( "<vertex \"", ver.label.text, "\">" );
    fi;
end;

VertexOps.PrintInfo := function( ver )
    Print( "#I  Vertex( W, ", ver.x, ", ", ver.y,
           " ) = -.", Position(ver.sheet.objects,ver), "\n" );
end;


#############################################################################
##
#F  VertexOps.Recolor( <ver>, <color> ) . . . . . . . . . . .  recolor vertex
##
VertexOps.Recolor := function( ver, color )
    local   obj;

    ver.color := color;
    for obj  in ver.outline  do
        obj.operations.Recolor( obj, color );
    od;
    if ver.label <> false  then
        ver.label.operations.Recolor( ver.label, color );
    fi;
end;


#############################################################################
##
#F  VertexOps.Relabel( <ver>, <text> )  . . . . . . . . change label of <ver>
##
VertexOps.Relabel := function( ver, text )

    if ver.label <> false  then
        ver.sheet.operations.Delete( ver.sheet, ver.label );
    fi;
    if text = false or 0 = Length(text)  then
        ver.label := false;
    else
        if 4 < Length(text)  then text := text{[1..4]};  fi;
        ver.label := Text( ver.sheet, FONTS.tiny, ver.tx[Length(text)], 
                           ver.ty, text, rec(color:=ver.color) );
    fi;
end;


#############################################################################
##
#F  VertexOps.Reshape( <ver>, <shape> ) . . . . . . . . . . . . . . new shape
##
VertexOps.Reshape := function( ver, shape )
    local   obj,  col;
    
    if ver.shape = shape  then return;  fi;
    ver.shape := shape;

    # delete old outline
    for obj  in ver.outline  do
        ver.sheet.operations.Delete( ver.sheet, obj );
    od;
    ver.outline := [];
    
    # and create new ones
    col := rec( color := ver.color );
    if ver.highlight then col.width := 2;  else col.width := 1;  fi;
    if VERTEX.rectangle <= shape  then
        shape := shape - VERTEX.rectangle;
        Add( ver.outline, Rectangle( ver.sheet, ver.x-ver.r, ver.y-ver.r,
                                     2*ver.r, 2*ver.r, col ) );
    fi;
    if VERTEX.diamond <= shape  then
        shape := shape - VERTEX.diamond;
        Add( ver.outline, Diamond( ver.sheet, ver.x-ver.r, ver.y,
                                   ver.r, ver.r, col ) );
    fi;
    if VERTEX.circle <= shape  then
        shape := shape - VERTEX.circle;
        Add( ver.outline, Circle( ver.sheet, ver.x, ver.y, ver.r, col ) );
    fi;
    
end;


#############################################################################
##
#F  VertexOps.in( <pos>, <ver> )  . . . . . . . . . . . . . .  <pos> in <ver>
##
VertexOps.\in := function( pos, ver )
    return (pos[1]-ver.x)^2+(pos[2]-ver.y)^2 < (ver.r+3)^2;
end;


#############################################################################
##
#F  VertexOps.=( <v1>, <v2> ) . . . . . . . . . . . . .  compare two vertices
##
VertexOps.\= := function( v1, v2 )
    if IsRec(v1) and IsBound(v1.isVertex)  then
        if IsRec(v2) and IsBound(v2.isVertex)  then
            return v1.outline = v2.outline;
        else
            return false;
        fi;
    else
        if IsRec(v2) and IsBound(v2.isVertex)  then
            return false;
        else
            Error( "I am trying to compare two vertices" );
        fi;
    fi;
end;

