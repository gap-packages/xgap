#############################################################################
##
#W  meataxe.gi                 	XGAP library                  Max Neunhoeffer
##
#H  @(#)$Id: meataxe.gi,v 1.1 1998/12/18 17:02:15 gap Exp $
##
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
##  This file contains code for meataxe posets
##
Revision.pkg_xgap_lib_meataxe_gi :=
    "@(#)$Id: meataxe.gi,v 1.1 1998/12/18 17:02:15 gap Exp $";


#############################################################################
##
#M  GraphicMeatAxeLattice(<name>, <width>, <height>)  . creates graphic poset
##
##  creates a new graphic meataxe lattice which is a specialization of a
##  graphic poset. Those posets have a new filter for method selection.
##
InstallMethod( GraphicMeatAxeLattice,
    "for a string, and two integers",
    true,
    [ IsString,
      IsInt,
      IsInt ],
    0,

function( name, width, height )
  local P;

  P := GraphicPoset(name,width,height);
  SetFilterObj(P,IsMeatAxeLattice);
  return P;
end);


#############################################################################
##
#M  CompareLevels(<poset>,<levelp1>,<levelp2>) . . . compares two levelparams
##
##  Compare two levelparams. -1 means that levelp1 is "higher", 1 means
##  that levelp2 is "higher", 0 means that they are equal. fail means that
##  they are not comparable. This method is for the case if level
##  parameters are integers and lower values mean lower levels like in the
##  case of meataxe lattices of Michael Ringe.
##
InstallMethod( CompareLevels,
    "for a graphic meataxe lattice, and two integers",
    true,
    [ IsGraphicPosetRep and IsMeatAxeLattice, IsInt, IsInt ],
    0,

function( poset, l1, l2 )
  if l1 < l2 then
    return 1;
  elif l1 > l2 then
    return -1;
  else
    return 0;
  fi;
end);

