#
# xgap
#
# This file runs tests for the package mode used by XGAP.
# It is referenced in the package metadata file PackageInfo.g
#

ReadPackage("xgap", "tst/xgap_test.g");
XGT_Test("TestDirectory( DirectoriesPackageLibrary(\"xgap\", \"tst\"), rec(testOptions := rec(compareFunction := \"uptowhitespace\") ) );");
