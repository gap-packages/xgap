#
# xgap
#
# This file runs tests for the package mode used by XGAP, and if possible
# also tests inside the real XGAP.
# It is referenced in the package metadata file PackageInfo.g
#

ReadPackage("xgap", "tst/xgap_test.g");
output := XGT_Test("TestDirectory( DirectoriesPackageLibrary(\"xgap\", \"tst\"), rec(testOptions := rec(compareFunction := \"uptowhitespace\") ) );");

# the child's exit status is not available, so go by what TestDirectory printed
if output = fail or
   PositionSublist(output, "#I  No errors detected while testing") = fail then
  FORCE_QUIT_GAP(1);
fi;

if XGT_TestGui() = false then
  FORCE_QUIT_GAP(1);
fi;
FORCE_QUIT_GAP(0);
