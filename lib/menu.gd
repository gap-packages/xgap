#############################################################################
##
#W  menu.gd                     XGAP library                     Frank Celler
##
#H  @(#)$Id: menu.gd,v 1.4 1999/01/17 23:45:50 gap Exp $
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
    "@(#)$Id: menu.gd,v 1.4 1999/01/17 23:45:50 gap Exp $";


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
#O  Menu( <sheet>, <title>, <zipped> ) . . . .  add a menu to a graphic sheet
##
##  `Menu' returns a pulldown menu. It is as attached to the sheet <sheet>
##  under the title <title>. In the first form <ents> is a list of strings
##  consisting of the names of the menu entries. <fncs> is a list of
##  functions. They are called when the corresponding menu entry is selected
##  by the user. The parameters they get are the graphic sheet as first
##  parameter, the menu object as second, and the name of the selected entry
##  as third parameter. In the second form the entry names and functions are
##  all in one list <zipped> in alternating order, meaning first a menu entry,
##  then the corresponding function and so on.
##  Note that you can delete Menus but it is not possible to modify them,
##  once they are attached to the sheet.
##  If a name of a menu entry begins with a minus sign or the list entry
##  in <ents> is not bound, a dummy menu entry is generated, which can sort
##  the menu entries within a menu in blocks. The corresponding function
##  does not matter.
##
DeclareOperation( "Menu", [ IsGraphicSheet, IsString, IsList, IsList ] );


#############################################################################
##
#O  Check( <menu>, <entry>, <flag> )  . . . . . . . . . . .  check menu entry
## 
##  Modifies the ``checked'' state of a menu entry. This is visualized by a 
##  small checked mark behind the menu entry. <menu> must be a menu object,
##  <entry> the string exactly as in the definition of the menu, and <flag>
##  a boolean value.
##
DeclareOperation( "Check", [ IsMenu, IsObject, IsBool ] );


#############################################################################
##
#O  Enable( <menu>, <entry>, <flag> ) . . . .  enable an object for selection
##
##  Modifies the ``enabled'' state of a menu entry. Only enabled menu entries
##  can be selected by the user. Deselected menu entries are visualized
##  by grey or shaded letters in the menu. <menu> must be a menu object,
##  <entry> the string exactly as in the definition of the menu, and <flag>
##  a boolean value.
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
##  creates a new popup menu and returns a {\GAP} object describing it.
##  <name> is the title of the menu and <labels> is a list of strings for
##  the entries. Use `Query' to actually put the popup on the screen.
##
DeclareOperation( "PopupMenu", [IsString, IsList] );


#############################################################################
##
#O  Query( <pop> ) . . . . . . . . . . . . . . actually put a popup on screen
##
##  actually puts a popup on screen. Returns the string of the selected entry
##  or false if the user clicks outside the popup.
##
DeclareOperation( "Query", [ IsObject ] );


#############################################################################
##
#O  TextSelector( <name>, <list>, <buttons> ) . . . .  create a text selector
##
##  creates a new text selector and returns a {\GAP} object describing it.
##  <name> is a title. <list> is an alternating list of strings and
##  functions. The strings are displayed and can be selected by the user. 
##  If this happens the corresponding function is called with two parameters.
##  The first is the text selector object itself, the second the that is
##  selected. <buttons> is an analogous list for the buttons that are 
##  displayed at the bottom of the text selector. The text selector is 
##  displayed immediately and stays on screen until it is closed (use the
##  `Close' operation). Buttons can be enabled and disabled by the `Enable'
##  operation and the string of a text can be changed via `Relabel'.
##
##  A selected string is highlighted and all other strings are reset at the
##  same time. Use `Reset' to reset all entries.
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
#O  Dialog( <type>, <text> ) . . . . . . . . . . . . .  create a popup dialog
##
##  creates a dialog box and returns a {\GAP} object describing it. There are
##  currently two types of dialogs: A file selector dialog (called
##  `Filename') and a dialog type called `OKcancel'. <text> is a text that
##  appears as a title in the dialog box.
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

