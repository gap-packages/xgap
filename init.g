#############################################################################
##
#W  init.g                      XGAP library                     Frank Celler
##
#H  @(#)$Id: init.g,v 1.10 2003/05/17 13:24:38 gap Exp $
##
#Y  Copyright (C) 1993,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##

last := 0;    # to make GAP happy when this package is autoloaded

# We leave the following until everybody has GAP >=4.4
DeclarePackage("xgap","4.17",ReturnTrue);
DeclarePackageAutoDocumentation( "xgap", "doc" );


#############################################################################
##
#X  declaration part
##
ReadPkg( "xgap", "lib/color.gd"   );
ReadPkg( "xgap", "lib/font.gd"    );
ReadPkg( "xgap", "lib/sheet.gd"   );
ReadPkg( "xgap", "lib/gobject.gd" );
ReadPkg( "xgap", "lib/menu.gd"    );
ReadPkg( "xgap", "lib/poset.gd"   );
ReadPkg( "xgap", "lib/ilatgrp.gd" );
ReadPkg( "xgap", "lib/meataxe.gd" );

#############################################################################
##
#X  interface to `WindowCmd'
##
ReadPkg( "xgap", "lib/window.g"   );

#############################################################################
##
#X  implementation part
##
ReadPkg( "xgap", "lib/color.gi"   );
ReadPkg( "xgap", "lib/font.gi"    );
ReadPkg( "xgap", "lib/sheet.gi"   );
ReadPkg( "xgap", "lib/gobject.gi" );
ReadPkg( "xgap", "lib/menu.gi"    );
ReadPkg( "xgap", "lib/poset.gi"   );
ReadPkg( "xgap", "lib/ilatgrp.gi" );
ReadPkg( "xgap", "lib/meataxe.gi" );

#############################################################################
##

#E  init.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

