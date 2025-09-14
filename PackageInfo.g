#############################################################################
##  
##  PackageInfo.g for the GAP package xgap
##  

SetPackageInfo( rec(

PackageName := "XGAP",
Subtitle := "a graphical user interface for GAP",
Version := "4.33",
Date := "14/09/2025", # dd/mm/yyyy format
License := "GPL-2.0-or-later",

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
    LastName      := "Horn",
    FirstNames    := "Max",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "mhorn@rptu.de",
    WWWHome       := "https://www.quendi.de/math",
    GitHubUsername := "fingolfin",
    Place         := "Kaiserslautern, Germany",
    Institution   := "RPTU Kaiserslautern-Landau",
  ),

  rec( 
    LastName      := "Neunhöffer",
    FirstNames    := "Max",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "max@9hoeffer.de",
    WWWHome       := "http://www-groups.mcs.st-and.ac.uk/~neunhoef",
  ),
],

Status := "accepted",
CommunicatedBy := "Gerhard Hiß (Aachen)",
AcceptDate := "07/1999",

SourceRepository := rec(
    Type := "git",
    URL := "https://github.com/gap-packages/xgap",
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := "https://gap-packages.github.io/xgap",
README_URL      := Concatenation( ~.PackageWWWHome, "/README" ),
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/xgap-", ~.Version ),
ArchiveFormats := ".tar.gz",

AbstractHTML := 
  "The <span class=\"pkgname\">XGAP</span> package allows to use graphics in GAP.",

PackageDoc := rec(
  BookName  := "XGAP",
  ArchiveURLSubset := ["htm","doc"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "XGAP - a graphical user interface for GAP",
),


Dependencies := rec(
  GAP := ">=4.7",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [],
  ExternalConditions := []
),

AvailabilityTest := function() return GAPInfo.CommandLineOptions.p; end,

TestFile := "tst/testall.g",

#Keywords := []

));
