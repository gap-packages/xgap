#############################################################################
##
#W  font.gd                 	XGAP library                  Max Neunhoeffer
##
#H  @(#)$Id: font.gd,v 1.1 1998/11/27 14:50:48 ahulpke Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
Revision.pkg_xgap_lib_font_gd :=
    "@(#)$Id: font.gd,v 1.1 1998/11/27 14:50:48 ahulpke Exp $";


#############################################################################
##
#C  IsFont . . . . . . . . . . . . . . . . . . . . . . . .  category of fonts
##
DeclareCategory( "IsFont", IsObject );


#############################################################################
##
#O  FontInfo( <font> )  . . . . . . . . . . . . . . . . . font info of a font
##
DeclareOperation( "FontInfo", [ IsFont ] );


#############################################################################
##
#O  FontName( <font> )  . . . . . . . . . . . . . . . . . . .  name of a font
##
DeclareOperation( "FontName", [ IsFont ] );


#############################################################################
##
#V  FontFamily  . . . . . . . . . . . . . . . . . . . . . . . family of fonts
##
BindGlobal( "FontFamily", NewFamily( "FontFamily" ) );


#############################################################################
##
#V  FONTS  . . . . . . . . . . . . . . . . . . . . .  list of available fonts
##
##  The variable  `FONTS' contains a list  of  available fonts.  If  an entry
##  is `false' this  fonts is not available  on your screen.
DeclareGlobalFunction( "CreateFonts" );
DeclareGlobalVariable( "FONTS" );


#############################################################################
##

#E  font.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

