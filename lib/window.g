#############################################################################
##
#W  window.g                    XGAP library                     Frank Celler
##
#H  @(#)$Id: window.g,v 1.6 1998/03/06 13:15:03 gap Exp $
##
#Y  Copyright 1993-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
Revision.pkg_xgap_lib_window_g :=
    "@(#)$Id: window.g,v 1.6 1998/03/06 13:15:03 gap Exp $";


#############################################################################
##

#V  WINDOWS . . . . . . . . . . . . . . . . . . . . . . . . . list of windows
##
BindGlobal( "WINDOWS", [] );


#############################################################################
##
#F  WcStoreWindow( <id>, <w> )  . . . . . . . . . . . . . store window object
##
BindGlobal( "WcStoreWindow", function( id, w )
    WINDOWS[id+1] := w;
end );

#############################################################################
##

#F  WcCloseWindow( <id> ) . . . . . . . . . . . . . . . . . . .  close window
##
BindGlobal( "WcCloseWindow", function( id )
    Unbind(WINDOWS[id+1]);
    WindowCmd([ "XCW", id  ]);
end );


#############################################################################
##
#F  WcOpenWindow( <name>, <width>, <height> ) . . . . . . . . . . open window
##
BindGlobal( "WcOpenWindow", function( name, width, height )
    return WindowCmd([ "XOW", name, width, height ])[1];
end );


#############################################################################
##
#F  WcResizeWindow( <id>, <width>, <height> ) . . . . . . . . . resize window
##
BindGlobal( "WcResizeWindow", function( id, width, height )
    WindowCmd([ "XRE", id, width, height ]);
end );


#############################################################################
##
#F  WcSetColor( <id>, <col> ) . . . . . . . . . . . . . . . . . .   set color
##
BindGlobal( "WcSetColor", function( id, col )
    WindowCmd([ "XCO", id, col ]);
end );


#############################################################################
##
#F  WcDrawBox( <id>, <x1>, <y1>, <x2>, <y2> ) . . . . . . . . . .  draw a box
##
BindGlobal( "WcDrawBox", function( id, x1, y1, x2, y2 )
    return WindowCmd([ "XDB", id, x1, y1, x2, y2 ])[1];
end );


#############################################################################
##
#F  WcDrawCircle( <id>, <x>, <y>, <r> ) . . . . . . . . . . . . draw a circle
##
BindGlobal( "WcDrawCircle", function( id, x, y, r )
    return WindowCmd([ "XDC", id, x, y, r ])[1];
end );


#############################################################################
##
#F  WcDrawDisc( <id>, <x>, <y>, <r> ) . . . . . . . . . . . . . . draw a disc
##
BindGlobal( "WcDrawDisc", function( id, x, y, r )
    return WindowCmd([ "XDD", id, x, y, r ])[1];
end );


#############################################################################
##
#F  WcDrawLine( <id>, <x1>, <y1>, <x2>, <y2> )  . . . . . . . . . draw a line
##
BindGlobal( "WcDrawLine", function( id, x1, y1, x2, y2 )
    return WindowCmd([ "XDL", id, x1, y1, x2, y2 ])[1];
end );


#############################################################################
##
#F  WcDrawText( <id>, <fid>, <x>, <y>, <str> )  . . . . . . . . . draw a text
##
BindGlobal( "WcDrawText", function( id, fid, x, y, str )
    return WindowCmd([ "XDT", id, fid, x, y, str ])[1];
end );


#############################################################################
##
#F  WcDestroyMenu( <wid>, <mid> ) . . . . . . . . . . . . . .  destroy a menu
##
BindGlobal( "WcDestroyMenu", function( wid, mid )
    WindowCmd([ "XDM", wid, mid ]);
end );


#############################################################################
##
#F  WcDestroy( <id>, <obj> )  . . . . . . . . . . destroy <obj> on sheet <id>
##
BindGlobal( "WcDestroy", function( arg )
    local   cmd;

    cmd := Concatenation( ["XRO"], arg );
    WindowCmd(cmd);

end );


#############################################################################
##
#F  WcEnableMenu( <wid>, <mid>, <pos>, <flag> ) . . . . en/disable menu entry
##
BindGlobal( "WcEnableMenu", function( wid, mid, pos, flag )
    WindowCmd([ "XEM", wid, mid, pos, flag ]);
end );


#############################################################################
##
#F  WcFastUpdate( <wid>, <flag> ) . . . . . . . . . .  en/disable fast update
##
BindGlobal( "WcFastUpdate", function( wid, flag )
    if flag  then
        WindowCmd([ "XFU", wid, 1 ]);
    else
        WindowCmd([ "XFU", wid, 0 ]);
    fi;
end );


#############################################################################
##
#F  WcQueryPointer( <id> )  . . . . . . . . . . . . . . . . . . query pointer
##
BindGlobal( "WcQueryPointer", function( id )
    return WindowCmd([ "XQP", id ]);
end );


#############################################################################
##
#F  WcQueryPopup( <id> )  . . . . . . . . . . . . . . . . .  query popup menu
##
BindGlobal( "WcQueryPopup", function( id )
    return WindowCmd([ "XSP", id ])[1];
end );


#############################################################################
##
#F  WcSetLineWidth( <id>, <w> ) . . . . . . . . . . . . . . .  set line width
##
BindGlobal( "WcSetLineWidth", function( id, w )
    WindowCmd([ "XLW", id, w ]);
end );


#############################################################################
##
#F  WcSetTitle( <id>, <text> )  . . . . . . . . . . . . . .  set window title
##
BindGlobal( "WcSetTitle", function( id, text )
    WindowCmd([ "XAT", id, text ]);
end );


#############################################################################
##
#F  WcTsChangeText( <id>, <str> ) . . . . . . .  change text of text selector
##
BindGlobal( "WcTsChangeText", function( id, str )
    WindowCmd([ "XCL", id, str ]);
end );


#############################################################################
##

#V  SELECTORS . . . . . . . . . . . . . . . . . . . . . . . list of selectors
##
BindGlobal( "SELECTORS", [] );


#############################################################################
##
#F  WcTsClose( <id> ) . . . . . . . . . . . . . . . . . . close text selector
##
BindGlobal( "WcTsClose", function( id )
    WindowCmd([ "XCS", id ]);
    Unbind(SELECTORS[id+1]);
end );


#############################################################################
##
#F  WcTsEnable( <id>, <pos>, <flag> ) . . . .  enable button in text selector
##
BindGlobal( "WcTsEnable", function( id, pos, flag )
    WindowCmd([ "XEB", id, pos, flag ]);
end );


#############################################################################
##
#F  WcTsUnhighlight( <id> ) . . . . . . . . remove highlight in text selector
##
BindGlobal( "WcTsUnhighlight", function(id)
   WindowCmd([ "XUS", id ]);
end );


#############################################################################
##

#F  WcMenu( <wid>, <title>, <str> ) . . . . . .  create new menu for a window
##
BindGlobal( "WcMenu", function( id, title, str )
    return WindowCmd([ "XME", id, title, str ])[1];
end );


#############################################################################
##
#F  WcCheckMenu( <wid>, <mid>, <pos>, <flag> )  . .  check/uncheck menu entry
##
BindGlobal( "WcCheckMenu", function( wid, mid, pos, flag )
    WindowCmd([ "XCM", wid, mid, pos, flag ]);
end );


#############################################################################
##

#F  window.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
