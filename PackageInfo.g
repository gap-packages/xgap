#############################################################################
##  
##  PackageInfo.g for the GAP package xgap
##  

SetPackageInfo( rec(

PackageName := "XGAP",
Subtitle := "a graphical user interface for GAP",
Version := "4.23",
Date := "30/04/2012",

Persons := [
  rec( 
    LastName      := "Celler",
    FirstNames    := "Frank",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "Frank@Celler.DE",
    WWWHome       := "http://celler.de/"
  ),
  rec( 
    LastName      := "Neunhoeffer",
    FirstNames    := "Max",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "neunhoef@mcs.st-and.ac.uk",
    WWWHome       := "http://www-groups.mcs.st-and.ac.uk/~neunhoef/",
    PostalAddress := Concatenation( [
                       "School of Mathematics and Statistics\n",
                       "Mathematical Institute\n",
                       "North Haugh\n",
                       "St Andrews, Fife KY16 9SS\n",
                       "Scotland, UK" ] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  )
],

Status := "accepted",
CommunicatedBy := "Gerhard Hiß (Aachen)",
AcceptDate := "07/1999",

SourceRepository := rec(
    Type := "git",
    URL := Concatenation( "https://github.com/gap-packages/", ~.PackageName ),
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := Concatenation( "https://gap-packages.github.io/", ~.PackageName ),
README_URL      := Concatenation( ~.PackageWWWHome, "/README" ),
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", ~.PackageName ,"-", ~.Version ),
ArchiveFormats := ".tar.gz",

AbstractHTML := 
  "The <span class=\"pkgname\">XGAP</span> package allows to use graphics in GAP.",

PackageDoc := rec(
  BookName  := "XGap",
  ArchiveURLSubset := ["htm","doc"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "XGAP - a graphical user interface for GAP",
  Autoload  := true
),


Dependencies := rec(
  GAP := ">=4.7",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [],
  ExternalConditions := []
),

AvailabilityTest := function() return GAPInfo.CommandLineOptions.p; end,

#TestFile := "tst/testall.g",

#Keywords := []

));
