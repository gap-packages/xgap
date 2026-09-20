#
# Run the tests which need a window. Read this file with the real XGAP,
# from the package directory:
#
#   bin/<arch>/xgap -G <gap> -- --quitonbreak tst-gui/run.g
#
# XGAP shows GAP's output in its window and does not pass on its exit
# status, so the results go to the files `tst-gui.log' and `tst-gui.status'.
#
LoadPackage( "xgap" );
LogTo( "tst-gui.log" );
dirs := [ DirectoriesPackageLibrary( "xgap", "tst-gui" )[1],
          DirectoriesPackageLibrary( "xgap", "tst" )[1] ];
res := TestDirectory( dirs,
           rec( testOptions := rec( compareFunction := "uptowhitespace" ) ) );
LogTo();
PrintTo( "tst-gui.status", res, "\n" );
QUIT_GAP( 0 );
