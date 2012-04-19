#############################################################################
##
#W  init.g                      XGAP library                     Frank Celler
##
#H  @(#)$Id: init.g,v 1.14 2012/04/19 14:12:17 neunhoef Exp $
##
#Y  Copyright (C) 1993,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##

last := 0;    # to make GAP happy when this package is autoloaded

#############################################################################
##
#X  declaration part
##
ReadPackage( "xgap", "lib/color.gd"   );
ReadPackage( "xgap", "lib/font.gd"    );
ReadPackage( "xgap", "lib/sheet.gd"   );
ReadPackage( "xgap", "lib/gobject.gd" );
ReadPackage( "xgap", "lib/menu.gd"    );
ReadPackage( "xgap", "lib/poset.gd"   );
ReadPackage( "xgap", "lib/ilatgrp.gd" );
ReadPackage( "xgap", "lib/meataxe.gd" );

#############################################################################
##
#X  interface to `WindowCmd'
##
ReadPackage( "xgap", "lib/window.g"   );

#############################################################################
##
#X  implementation part
##
ReadPackage( "xgap", "lib/color.gi"   );
ReadPackage( "xgap", "lib/font.gi"    );
ReadPackage( "xgap", "lib/sheet.gi"   );
ReadPackage( "xgap", "lib/gobject.gi" );
ReadPackage( "xgap", "lib/menu.gi"    );
ReadPackage( "xgap", "lib/poset.gi"   );
ReadPackage( "xgap", "lib/ilatgrp.gi" );
ReadPackage( "xgap", "lib/meataxe.gi" );

#############################################################################
##

#E  init.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

