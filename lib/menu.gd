#############################################################################
##
#W  menu.gd                     XGAP library                     Frank Celler
##
#H  @(#)$Id: menu.gd,v 1.2 1998/03/06 13:14:58 gap Exp $
##
#Y  Copyright 1993-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
##
##  This files contains the menu and text selector  functions.  The low level
##  window functions are  in "window.g", the high  level window  functions in
##  "sheet.g".
##
Revision.pkg_xgap_lib_menu_gd :=
    "@(#)$Id: menu.gd,v 1.2 1998/03/06 13:14:58 gap Exp $";


#############################################################################
##

#C  IsMenu( <obj> )
##
DeclareCategory( "IsMenu", IsObject );


#############################################################################
##
#A  MenuId( <menu> )  . . . . . . . . . . . . . . . . . . . . . . . . menu id
##
DeclareAttribute( "MenuId", IsMenu );


#############################################################################
##
#V  MenuFamily  . . . . . . . . . . . . . . . . . . . . . . . family of menus
##
##  The family of menus contains all menus, such as pulldown menus,
##  popup menus, information menus, text selectors, and dialog boxes.
##  The different kinds of menus are distinguished via representations.
##
BindGlobal( "MenuFamily", NewFamily( "MenuFamily", IsMenu ) );


#############################################################################
##
#O  Menu( <window>, <title>, <ents>, <fncs> )  add a menu to a graphic window
##
##  `Menu' returns a pulldown menu.
##
DeclareOperation( "Menu", [ IsGraphicWindow, IsString, IsList, IsList ] );


#############################################################################
##
#O  Check( <menu>, <entry>, <flag> )  . . . . . . . . . . .  check menu entry
##
DeclareOperation( "Check", [ IsMenu, IsObject, IsBool ] );


#############################################################################
##
#O  Enable( <menu>, <entry>, <flag> ) . . . .  enable an object for selection
##
DeclareOperation( "Enable", [ IsMenu, IsObject, IsBool ] );


#############################################################################
##
#F  MenuSelected( <wid>, <mid>, <eid> ) . . . . . . . menu selector, internal
##
##  For the menu with menu id <mid> in the window with window id <wid>,
##  the <eid>-th entry is selected.
##
DeclareGlobalFunction( "MenuSelected" );


#############################################################################
##

#E  menu.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

