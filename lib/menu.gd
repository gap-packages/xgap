#############################################################################
##
#W  menu.gd                     XGAP library                     Frank Celler
##
#H  @(#)$Id: menu.gd,v 1.3 1998/11/27 14:50:54 ahulpke Exp $
##
#Y  Copyright 1993-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Cyopright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
##
##  This files contains the menu and text selector  functions.  The low level
##  window functions are  in "window.g", the high  level window  functions in
##  "sheet.g".
##
Revision.pkg_xgap_lib_menu_gd :=
    "@(#)$Id: menu.gd,v 1.3 1998/11/27 14:50:54 ahulpke Exp $";


#############################################################################
##
#C  IsMenu( <obj> )  . . . . . . . . . . . . . . . . . . . . .  menu category
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
#O  Menu( <sheet>, <title>, <ents>, <fncs> ) .  add a menu to a graphic sheet
##
##  `Menu' returns a pulldown menu.
##
DeclareOperation( "Menu", [ IsGraphicSheet, IsString, IsList, IsList ] );


#############################################################################
##
##  Other installed method:
##
#O  Menu( <sheet>, <title>, <zipped> ) . . . .  add a menu to a graphic sheet
##


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
#O  PopupMenu( <name>, <labels> ) . . . . . . . . . . . . create a popup menu
##
DeclareOperation( "PopupMenu", [IsString, IsList] );


#############################################################################
##
#O  Query( <pop> ) . . . . . . . . . . . . . . actually put a popup on screen
##
DeclareOperation( "Query", [ IsObject ] );


#############################################################################
##
#O  TextSelector( <name>, <list>, <buttons> ) . . . .  create a text selector
##
DeclareOperation( "TextSelector", [ IsString, IsList, IsList ] );


#############################################################################
##
#O  ButtonSelected( <sel>, <bid> )  . . . . . .  called if button is selected
##
DeclareOperation( "ButtonSelected", [IsObject, IsInt] );


#############################################################################
##
#O  Reset( <sel> ) . . . . . . . . . . . . . . . .  unhighlight text selector
##
DeclareOperation( "Reset", [IsObject] );


#############################################################################
##
#O  TextSelected( <sel>, <tid> ) . . . . . . . . . . . . . . .  text selected
##
DeclareOperation( "TextSelected", [ IsMenu, IsInt] );


#############################################################################
##
#O  Dialog( <name>, <text> ) . . . . . . . . . . . . .  create a popup dialog
##
DeclareOperation( "Dialog", [ IsString, IsString ] );


#############################################################################
##
#V  FILENAME_DIALOG . . . . . . . . . . . . . . a dialog asking for filenames
##
DeclareGlobalVariable( "FILENAME_DIALOG", "dialog for querying filenames" );


#############################################################################
##

#E  menu.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

