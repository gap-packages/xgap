#############################################################################
##
#W  sheet.gd                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: sheet.gd,v 1.4 1998/03/05 16:49:29 gap Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
##
##  This file contains all operations for graphic sheets.
##
Revision.pkg_xgap_lib_sheet_gd :=
    "@(#)$Id: sheet.gd,v 1.4 1998/03/05 16:49:29 gap Exp $";


#############################################################################
##

#C  IsGraphicWindow . . . . . . . . . . . . . . . . . .   category of windows
##
DeclareCategory( "IsGraphicWindow", IsObject );


#############################################################################
##
#V  GraphicWindowsFamily  . . . . . . . . . . . . . . . family of all windows
##
BindGlobal( "GraphicWindowsFamily", NewFamily( "GraphicWindowsFamily" ) );


#############################################################################
##
#V  DefaultGAPMenu  . . . . . . . . . . . . . . . . . . . .  default GAP menu
##
DeclareGlobalVariable( "DefaultGAPMenu",
    "default menu for graphic windows" );


#############################################################################
##
#O  GraphicWindow( <catrep>, <name>, <width>, <height> ) a new graphic window
##
DeclareOperation( "GraphicWindow", [ IsObject, IsString, IsInt, IsInt ] );


#############################################################################
##
#A  WindowId( <window> )  . . . . . . . . . . . . . . .  window id of <sheet>
##
DeclareAttribute( "WindowId", IsGraphicWindow );


#############################################################################
##
#O  Callback( <window>, <func>, <args> )  . . . . execute a callback function
##
DeclareOperation( "Callback", [ IsGraphicWindow, IsObject, IsList ] );


#############################################################################
##
#O  Close( <window> ) . . . . . . . . . . . . . . . .  close a graphic window
##
DeclareOperation( "Close", [ IsGraphicWindow ] );


#############################################################################
##
#O  InstallCallback( <window>, <func>, <call> ) . . . .  install new callback
##
DeclareOperation( "InstallCallback",
    [ IsGraphicWindow, IsObject, IsFunction ] );


#############################################################################
##
#O  MakeGAPMenu( <window> ) . . . . . . . . . . . . .  create a standard menu
##
DeclareOperation( "MakeGAPMenu", [ IsGraphicWindow ] );


#############################################################################
##
#O  Resize( <window>, <width>, <height> ) . . . . . . . . . . .  resize sheet
##
DeclareOperation( "Resize", [ IsGraphicWindow, IsInt, IsInt ] );

    
#############################################################################
##

#C  IsGraphicSheet  . . . . . . . . . . . . . . .  category of graphic sheets
##
DeclareCategory( "IsGraphicSheet", IsGraphicWindow );


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
#A  DefaultsForGraphicObject( <sheet> ) . . . . . . . . .  default color, etc
##
DeclareAttribute( "DefaultsForGraphicObject", IsGraphicSheet );


#############################################################################
##
#O  CtrlLeftPBDown( <sheet>, <x>, <y> ) . . . . . .  left pointer button down
##
DeclareOperation( "CtrlLeftPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#O  CtrlRightPBDown( <sheet>, <x>, <y> )  . . . . . right pointer button down
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
#O  ShiftLeftPBDown( <sheet>, <x>, <y> )  . . . . .  left pointer button down
##
DeclareOperation( "ShiftLeftPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#O  ShiftRightPBDown( <sheet>, <x>, <y> ) . . . . . right pointer button down
##
DeclareOperation( "ShiftRightPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##

#F  UseFastUpdate . . . . . . . . . . . . . . . . . .  filter for fast update
##
DeclareFilter( "UseFastUpdate" );


#############################################################################
##

#E  sheet.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
