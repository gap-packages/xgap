#############################################################################
##
#W  sheet.gd                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: sheet.gd,v 1.7 1998/12/06 22:16:14 gap Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
##  This file contains all operations for graphic sheets.
##
Revision.pkg_xgap_lib_sheet_gd :=
    "@(#)$Id: sheet.gd,v 1.7 1998/12/06 22:16:14 gap Exp $";


#############################################################################
##
#F  IsAlive . . . . . . . . . . . . . . . filter for living displayed objects
##
DeclareFilter( "IsAlive" );


#############################################################################
##
#V  GraphicSheetFamily  . . . . . . . . . . . . . . . .  family of all sheets
##
BindGlobal( "GraphicSheetFamily", NewFamily( "GraphicSheetFamily" ) );


#############################################################################
##
#C  IsGraphicSheet  . . . . . . . . . . . . . . .  category of graphic sheets
##
DeclareCategory( "IsGraphicSheet", IsObject );


#############################################################################
##
#O  GraphicSheet( <name>, <width>, <height> ) . . . . . . . new graphic sheet
##
##  creates  a  graphic  sheet with  title  <name>  and dimension <width>  by
##  <height>.  A graphic sheet  is the basic  tool  to draw something,  it is
##  like a piece of  paper on which you can  put your graphic objects, and to
##  which you  can attach your  menus.   The coordinate $(0,0)$ is  the upper
##  left corner, $(<width>-1,<height>-1)$ the lower right.
##
##  It is  possible to  change the  default behaviour of   a graphic sheet by
##  installing methods (or   sometimes  called callbacks) for   the following
##  events.  In order to  avoid  confusion with  the GAP term  \"method\" the
##  term \"callback\" will be used in the following.  For example, to install
##  the function `MyLeftPBDownCallback' as callback for the left mouse button
##  down  event of a graphic <sheet>,  you have  to call `InstallCallback' as
##  follows.
##
##  \begintt
##      gap> InstallCallback( sheet, LeftPBDown, MyLeftPBDownCallback );
##  \endtt
##
##  \> Close( <sheet> )
##
##    the function will be called as soon as the user selects \"close graphic
##    sheet\",  the installed  function gets  the graphic <sheet> to close as
##    argument.
##
##  \> LeftPBDown( <sheet>, <x>, <y> )
##
##    the function will be called as soon as  the user presses the left mouse
##    button inside  the   graphic sheet, the  installed   function  gets the
##    graphic <sheet>,  the <x> coordinate and  <y> coordinate of the pointer
##    as arguments.
##
##  \> RightPBDown( <sheet>, <x>, <y> )
##
##    same  as `LeftPBDown' except that the  user has pressed the right mouse
##    button.
##
##  \> ShiftLeftPBDown( <sheet>, <x>, <y> )
##
##    same  as `LeftPBDown' except that the  user has  pressed the left mouse
##    button together with the $SHIFT$ key on the keyboard.
##
##  \> ShiftRightPBDown( <sheet>, <x>, <y> )
##
##    same as  `LeftPBDown' except that the  user has pressed the right mouse
##    button together with the $SHIFT$ key on the keyboard.
##
##  \> CtrlLeftPBDown( <sheet>, <x>, <y> )
##
##    same  as `LeftPBDown' except that the  user has pressed  the left mouse
##    button together with the $CTR$ key on the keyboard.
##
##  \> CtrlRightPBDown( <sheet>, <x>, <y> )
##
##    same as `LeftPBDown'  except that the  user has pressed the right mouse
##    button together with the $CTR$ key on the keyboard.
##
DeclareOperation( "GraphicSheet", [ IsString, IsInt, IsInt ] );


#############################################################################
##
#V  DefaultGAPMenu  . . . . . . . . . . . . . . . . . . . .  default GAP menu
##
DeclareGlobalVariable( "DefaultGAPMenu",
    "default menu for graphic sheets" );


#############################################################################
##
#A  WindowId( <sheet> ) . . . . . . . . . . . . . . . .  window id of <sheet>
##
DeclareAttribute( "WindowId", IsGraphicSheet );


#############################################################################
##
#O  Callback( <sheet>, <func>, <args> )  . . . .  execute a callback function
##
DeclareOperation( "Callback", [ IsGraphicSheet, IsObject, IsList ] );


#############################################################################
##
#O  Close( <sheet> )  . . . . . . . . . . . . . . . . . close a graphic sheet
##
DeclareOperation( "Close", [ IsGraphicSheet ] );


#############################################################################
##
#O  InstallCallback( <sheet>, <func>, <call> ) . . . . . install new callback
##
DeclareOperation( "InstallCallback",
    [ IsGraphicSheet, IsObject, IsFunction ] );


#############################################################################
##
#O  RemoveCallback( <sheet>, <func>, <call> ) . . . . . . remove old callback
##
DeclareOperation( "RemoveCallback",
    [ IsGraphicSheet, IsObject, IsFunction ] );


#############################################################################
##
#O  MakeGAPMenu( <sheet> ) . . . . . . . . . . . . . . create a standard menu
##
DeclareOperation( "MakeGAPMenu", [ IsGraphicSheet ] );


#############################################################################
##
#O  Resize( <sheet>, <width>, <height> ) . . . . . . . . . . . . resize sheet
##
DeclareOperation( "Resize", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#A  DefaultsForGraphicObject( <sheet> ) . . . . . . . . .  default color, etc
##
DeclareAttribute( "DefaultsForGraphicObject", IsGraphicSheet );


#############################################################################
##
#O  CtrlLeftPBDown( <sheet>, <x>, <y> ) . .  left pointer button down w. CTRL
##
DeclareOperation( "CtrlLeftPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#O  CtrlRightPBDown( <sheet>, <x>, <y> ) .  right pointer button down w. CTRL
##
DeclareOperation( "CtrlRightPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#O  LeftPBDown( <sheet>, <x>, <y> ) . . . . . . . .  left pointer button down
##
DeclareOperation( "LeftPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#O  RightPBDown( <sheet>, <x>, <y> )  . . . . . . . right pointer button down
##
DeclareOperation( "RightPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#O  ShiftLeftPBDown( <sheet>, <x>, <y> )  . left pointer button down w. SHIFT
##
DeclareOperation( "ShiftLeftPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#O  ShiftRightPBDown( <sheet>, <x>, <y> ) .right pointer button down w. SHIFT
##
DeclareOperation( "ShiftRightPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#F  UseFastUpdate . . . . . . . . . . . . . . . . . .  filter for fast update
##
DeclareFilter( "UseFastUpdate" );


#############################################################################
##
#O  SetTitle( <sheet>, <title> )  . . . . . . . . . . . . . . . . add a title
##
DeclareOperation( "SetTitle", [ IsGraphicSheet, IsString ] );


#############################################################################
##
#O  FastUpdate( <sheet>, <flag> ) . . . . . . . . . . . . . switch fastupdate
##
DeclareOperation( "FastUpdate", [ IsGraphicSheet, IsBool ] );


#############################################################################
##
#V  BUTTONS . . . . . . . . . . . . . . . . . . . . left/right pointer button
##
DeclareGlobalVariable( "BUTTONS" );


#############################################################################
##
#O  PointerButtonDown( <sheet>, <x>, <y>, <btn>, <state> . . reaction on user
##
DeclareOperation( "PointerButtonDown", 
        [ IsGraphicSheet, IsInt, IsInt, IsInt, IsInt ] );


#############################################################################
##
#O  Drag( <sheet>, <x>, <y>, <bt>, <func> ) . . . . . . . . .  drag something
##
DeclareOperation( "Drag",
        [ IsGraphicSheet, IsInt, IsInt, IsInt, IsFunction ] );


#############################################################################
##
#O  GMSaveAsPS( <sheet>, <menu>, <entry> )  . . . .  save sheet as postscript
##
##  This operation is called from the menu, if the user clicks on ``save as
##  postscript''. It asks for a filename (defaultname stored in the sheet)
##  and calls the operation <SaveAsPS>.
##
DeclareOperation( "GMSaveAsPS", [ IsGraphicSheet, IsObject, IsString ] );


#############################################################################
##
#O  SaveAsPS( <sheet>, <filename> ) . . . . . . . .  save sheet as postscript
##
##  Saves the graphics in the sheet <sheet> as postscript into the file
##  <filename>, which is overwritten, if it exists.
##
DeclareOperation( "SaveAsPS", [ IsGraphicSheet, IsString ] );


#############################################################################
##

#E  sheet.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

