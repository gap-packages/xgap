#############################################################################
##
#W  ilatgrp.gi                 	XGAP library                  Max Neunhoeffer
##
#H  @(#)$Id: ilatgrp.gi,v 1.1 1998/11/27 14:50:53 ahulpke Exp $
##
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
##  This file contains the implementations for graphs and posets
##
Revision.pkg_xgap_lib_ilatgrp_gi :=
    "@(#)$Id: ilatgrp.gi,v 1.1 1998/11/27 14:50:53 ahulpke Exp $";


#############################################################################
##
##  Representations:  
##
#############################################################################
  
  
#############################################################################
##
#R  IsGraphicSubgroupLattice . . . . . .  repr. for graphic subgroup lattices
##
if not IsBound(IsGraphicSubgroupLattice) then
  DeclareRepresentation( "IsGraphicSubgroupLattice",
    IsComponentObjectRep and IsAttributeStoringRep and IsGraphicSheet and
    IsGraphicSheetRep and IsGraphicGraphRep and IsGraphicPosetRep,
# we inherit those components from the sheet:        
    [ "name", "width", "height", "gapMenu", "callbackName", "callbackFunc",
      "menus", "objects", "free",
# and the following from being a poset:
      "levels",           # list of levels, stores current total ordering
      "levelparams",      # list of level parameters
      "selectedvertices", # list of selected vertices
      "menutypes",        # one entry per menu which contains list of types
      "menuenabled",      # one entry per menu which contains list of flags
      "rightclickfunction",    # the current function which is called when
                               # user clicks right button
      "color",            # some color infos for the case of different models
      "levelboxes",       # little graphic boxes for the user to handle levels
      "showlevels",       # flag, if levelboxes are shown
# now follow our own components:
      "group",            # the group
      "limits",           # a record with some limits, e.g. "conjugates"
      "menuoperations",   # configuration of menu operations
      "infodisplays",     # list of records for info displays, see below
      "largestlabel",     # largest used number for label
      "lastresult",       # list of vertices which are "green"
      "selector"],        # the current text selector or "false"
    IsGraphicSheet );
fi;


#############################################################################
##
##  Configuration section for menu operations and info displays:
##
#############################################################################

#############################################################################
##
##  Some global constants for configuration purposes (see "ilatgrp.gi"):
##
#############################################################################

BindGlobal( "GGLfrom1", 1 );
BindGlobal( "GGLfrom2", 2 );
BindGlobal( "GGLfromSet", 3 );
BindGlobal( "GGLto0", 0 );
BindGlobal( "GGLto1", 1 );
BindGlobal( "GGLtoSet", 2 );
BindGlobal( "GGLwhereUp", 1 );
BindGlobal( "GGLwhereDown", 2 );
BindGlobal( "GGLwhereAny", 0 );
BindGlobal( "GGLwhereBetween", 3 );
BindGlobal( "GGLrelsMax", 1 );
BindGlobal( "GGLrelsTotal", 2 );
BindGlobal( "GGLrelsNo", 0 );
BindGlobal( "GGLrelsDown", 3 );
BindGlobal( "GGLrelsUp", 4 );


##
##  The configuration of the menu operations works as follows:
##  Every menu operation gets a record with the following entries, which
##  can take on the values described after the colon respectively:
##
##   name     : a string
##   op       : a GAP-Operation for group(s)
##   sheet    : true, false
##   parent   : true, false
##   from     : GGLfrom1, GGLfrom2, GGLfromSet
##   to       : GGLto0, GGLto1, GGLtoSet
##   where    : GGLwhereUp, GGLwhereDown, GGLwhereAny, GGLWhereBetween
##   plural   : true, false
##   rels     : GGLrelsMax, GGLrelsTotal, GGLrelsNo, GGLrelsDown, GGLrelsup
##
##  Please use always these names instead of actual values because the values
##  of these variables can be subject to changes, especially because they
##  actually should be integers rather than strings.
##
##  <name> is the name appearing in the menu and info messages.
##  <op> is called to do the real work. The usage of <op> is however configured
##  by the other entries. <from> says, how many groups <op> gets as parameters.
##  It can be one group, exactly two or a list (GGLfromSet) of groups.
##  <sheet> says, if the graphic sheet is supplied as first parameter.
##  <parent> says, if the parent group is supplied as first/second parameter of
##  the call of the operation or not.
##  <to> says, how many groups <op> produces, it can be zero, one or a list
##  of groups (GGLtoSet). <where> determines what is known about the relative
##  position of the new groups with respect to the input groups of <op>.
##  GGLwhereUp means, that the new group(s) all contain all groups <op> was
##  called with. GGLwhereDown means, that the new group(s) are all contained
##  in all groups <op> was called with. GGLwhereAny means that nothing is
##  known about the result(s) with respect to this question. GGLwhereBetween
##  applies only for the case <from>=GGLfrom2 and means, that all produced
##  groups are contained in the first group and contain the second group
##  delivered to <op>. That means that in case such an operation exists
##  it will be checked before the call to the operation, which group is
##  contained in the other! It is an error if that is not the case!
##  <plural> is a flag which determines, if more than the
##  appropriate number of vertices can be selected. In this case <op> is called
##  for all subsets of the set of selected subgroups with the right number of
##  groups. This does not happen if <plural> is false. <rels> gives <op> the
##  possibility to return inclusion information about the newly calculated
##  subgroups. If <rels> is GGLrelsMax or GGLrelsTotal then <op> must return
##  a record with components `subgroups' which is a list of subgroups 
##  generated as well as a component `inclusions' which lists all maximality
##  inclusions among these subgroups.
##  A maximality inclusion is given as a list `[<i>,<j>]' indicating that
##  subgroup number <i> is a maximal subgroup of subgroup number <j>, the
##  numbers 0 and 1+length(`subgroups') are used to denote <U> and <G>
##  respectively, this applies to the case <rels>=GGLrelsMax.
##  In the case <rels>=GGLrelsTotal each pair says that the first group is
##  contained in the second. 
##  Again: The complete poset information must be returned!
##  In the case <rels>=GGLrelsNo nothing is known about the relative inclusions
##  of the results. <op> just returns a list of groups. If <rels>=GGLrelsDown
##  then the returned list is a descending chain and if <rels>=GGLrelsUp then
##  the returned list is an ascending chain.

##  we have two cases up to now:
BindGlobal( "GGLMenuOpsForFiniteGroups",
        [ rec( name := "All Subgroups", 
               op := function(G) 
                 local result,cl;
                 result := [];
                 for cl in LatticeSubgroups(G)!.conjugacyClassesSubgroups do
                   Append(result,AsList(cl));
                 od;
                 return result;
               end,
               parent := false, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereDown, plural := false, rels := GGLrelsNo ),
          rec( name := "Centralizers", op := Centralizer, 
               parent := true, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereAny, plural := true, rels := GGLrelsNo ),
          rec( name := "Centres", op := Centre, 
               parent := false, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "Closure", op := ClosureGroup, 
               parent := false, from := GGLfromSet, to := GGLto1, 
               where := GGLwhereUp, plural := false, rels := GGLrelsNo ),
          rec( name := "Closures", op := ClosureGroup, 
               parent := false, from := GGLfrom2, to := GGLto1, 
               where := GGLwhereUp, plural := true, rels := GGLrelsNo ),
          rec( name := "Commutator Subgroups", op := CommutatorSubgroup,
               parent := false, from := GGLfrom2, to := GGLto1, 
               where := GGLwhereAny, plural := true, rels := GGLrelsNo ),
          rec( name := "Conjugate Subgroups", 
#FIXME: again use ConjugateSubgroups???
               op := function(G,H) 
                       return AsList(ConjugacyClassSubgroups(G,H)); 
                     end,
               parent := true, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereAny, plural := true, rels := GGLrelsNo ),
          rec( name := "Cores", op := Core,
               parent := true, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "DerivedSeries", op := DerivedSeries,
               parent := false, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereDown, plural := true, rels := GGLrelsDown ),
          rec( name := "DerivedSubgroups", op := DerivedSubgroup,
               parent := false, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "Fitting Subgroups", op := FittingSubgroup,
               parent := false, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "Intermediate Subgroups", op := IntermediateSubgroups,
               parent := false, from := GGLfrom2, to := GGLtoSet, 
               where := GGLwhereBetween, plural := false, rels := GGLrelsMax),
          rec( name := "Intersection", op := Intersection,
               parent := false, from := GGLfromSet, to := GGLto1, 
               where := GGLwhereDown, plural := false, rels := GGLrelsNo ),
          rec( name := "Intersections", op := Intersection,
               parent := false, from := GGLfrom2, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "Normalizers", op := Normalizer,
               parent := true, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereUp, plural := true, rels := GGLrelsNo ),
          rec( name := "Normal Closures", op := NormalClosure,
               parent := true, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereUp, plural := true, rels := GGLrelsNo ),
          rec( name := "Normal Subgroups", op := NormalSubgroups,
               parent := false, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "Sylow Subgroups", op := GGLSylowSubgroup,
               parent := false, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo )
] );
                                             
BindGlobal( "GGLMenuOpsForFpGroups",
        [ rec( name := "Abelian Prime Quotient", op := GGLAbelianPQuotient,
               parent := false, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := false, rels := GGLrelsNo ),
          rec( name := "All Overgroups", op := IntermediateSubgroups,
               parent := true, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereUp, plural := false, rels := GGLrelsMax ),
          rec( name := "Conjugacy Class", 
#FIXME: again use ConjugateSubgroups???
               op := function(G,H) 
                       return AsList(ConjugacyClassSubgroups(G,H)); 
                     end,
               parent := true, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereAny, plural := false, rels := GGLrelsNo ),
          rec( name := "Cores", op := Core,
               parent := true, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "DerivedSubgroups", op := DerivedSubgroup,
               parent := false, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "Epimorphisms", op := GGLEpimorphisms,
               parent := false, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereDown, plural := false, rels := GGLrelsNo ),
          rec( name := "Intersections", op := Intersection,
               parent := false, from := GGLfrom2, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ) 
        ] );
# FIXME: ... to be continued


##
##  The configuration of the info displays works as follows:
##  Info displays come in two flavours:
##   (1) info about an attribute
##   (2) info from a function
##  The reason for (2) is that it could be interesting to see "relative"
##  information about a subgroup with respect to the parent group. This
##  cannot be an attribute because it does not belong to the group itself.
##  Every info display gets a record with the following components:
##   name      : a string
##   tostr     : a function (can be "String") which converts the value to 
##               display into a string, if not bound "String" is taken
##  For case (1) we only have one more component:
##   attrib    : an attribute or property (the gap operation)
##  For case (2) we have:
##   func      : a function which returns the value that should be displayed
##   sheet     : true iff first parameter for <func> should be the sheet
##   parent    : true iff first/second parameter should be the parent group
##  if one of the last two is not bound it counts like "false".
##  The information produced by the functions "func" is cached in the record
##  "info" of the "data" part of the vertex under the component "name".
##
BindGlobal( "GGLInfoDisplaysForFiniteGroups",
        [ rec( name := "Size", attrib := Size ),
          rec( name := "Index", func := Index, parent := true ),
          rec( name := "IsAbelian", attrib := IsCommutative ),
          rec( name := "IsCentral", func := IsCentral, parent := true ),
          rec( name := "IsCyclic", attrib := IsCyclic ),
          rec( name := "IsNilpotent", attrib := IsNilpotentGroup ),
          rec( name := "IsNormal", func := IsNormal, parent := true ),
          rec( name := "IsPerfect", attrib := IsPerfectGroup ),
          rec( name := "IsSimple", attrib := IsSimpleGroup ),
          rec( name := "IsSolvable", attrib := IsSolvableGroup ),
          rec( name := "Isomorphism", attrib := IdGroup ) 
        ] );
                 
BindGlobal( "GGLInfoDisplaysForFpGroups",
        [ rec( name := "Index", func := Index, parent := true ),
          rec( name := "IsNormal", func := IsNormal, parent := true ),
          rec( name := "AbelianInvariants", attrib := AbelianInvariants ),
          rec( name := "Presentation", func := GGLPresentation ) 
        ] );
# FIXME: ... to be continued


#############################################################################
##
##  Global data, menus etc.:  
##
#############################################################################
  

GGLCleanupMenu :=
  [ "Not yet implemented", "forany", Ignore ];
#  [ "Average Y Levels",        "forany",     CMAverageYLevels,
#    "Average X Levels",        "formin2",    CMAverageXLevels,
#    "Rotate Conjugates",       "formin2",    CMRotateConjugates,
#    "-",                       "-",          "-",
#    "Relabel Vertices",        "forsubset",  CMRelabelVertices,
#    "Select Representatives",  "forany",     CMSelectReps,
#    "-",                       "-",          "-",
#    "Merge Classes",           "formin2",    CMMergeClasses ];
  
  
#############################################################################
##
##  Menu entries and Popups:
##
#############################################################################


############################################################################
##
#M  GGLRightClickPopup . . . . . . . . . . called if user does a right click
##
##  This is called if the user does a right click on a vertex or somewhere
##  else on the sheet. This operation is highly configurable with respect
##  to the Attributes of groups it can display/calculate. See the 
##  configuration section in "ilatgrp.gi" for an explanation.
##
InstallMethod( GGLRightClickPopup,
    "for a graphic subgroup lattice, a vertex, and two integers",
    true,
    [ IsGraphicSheet and IsGraphicSubgroupLattice, IsGPVertex, IsInt, IsInt ],
    0,

function(sheet,v,x,y)
  local   grp,  textselectfunc,  text,  i,  str,  funcclose,  funcall;
  
  # did we get a vertex?
  if v = fail then
    return;
  fi;
  
    # destroy other text selectors flying around
  if sheet!.selector <> false then
    Close(sheet!.selector);
    sheet!.selector := false;
  fi;
  
  # get the group of <obj>
  grp := v!.data.group;

  # text select function
  textselectfunc := function( sel, name )
    local   tid,  current,  text,  str,  value,  parameters;
    
    tid  := sel!.selected;
    current := sheet!.infodisplays[tid];
    text := ShallowCopy(sel!.labels);
    str  := String( current.name, -14 );
    if IsBound(current.attrib) then
      value := current.attrib( grp );
    else
      if not(IsBound(v!.data.info.(current.name))) then
        # we have to calculate:
        parameters := [];
        if IsBound(current.sheet) and current.sheet then 
          Add(parameters,sheet);
        fi;
        if IsBound(current.parent) and current.parent then 
          Add(parameters,sheet!.group);
        fi;
        Add(parameters,grp);
        value := CallFuncList(current.func,parameters);
        v!.data.info.(current.name) := value;
      else
        # we know "by heart"
        value := v!.data.info.(current.name);
      fi;
    fi;
    if IsBound(current.tostr) then
      Append(str,current.tostr(value));
    else
      Append(str,String(value));
    fi;
    text[tid] := str;
    Relabel( sel, text );
    return true;
  end;

  # construct the string in the first place:
  text := [];
  for i in sheet!.infodisplays  do
    str := String( i.name, -14 );
    # do we know the value?
    if IsBound(i.attrib) then
      if Tester(i.attrib)(grp) then
        if IsBound(i.tostr) then
          Append(str,i.tostr(i.attrib(grp)));
        else
          Append(str,String(i.attrib(grp)));
        fi;
      else
        Append(str,"Unknown");
      fi;
    else   #  its determined by a function and perhaps cached:
      if IsBound(v!.data.info.(i.name)) then
        if IsBound(i.tostr) then
          Append( str, i.tostrv(v!.data.info.(i.name)));
        else
          Append( str, String(v!.data.info.(i.name)));
        fi;
      else
        Append( str, "Unknown" );
      fi;
    fi;
    Add( text, str );
    Add( text, textselectfunc );
  od;

  # button select functions:
  funcclose := function( sel, bt )
    Close(sel);
    sheet!.selector := false;
    return true;  
  end;
  funcall := function( sel, bt )
    local i;
    for i  in [ 1 .. Length(sel!.labels) ]  do
      sel!.selected := i;
      sel!.textFuncs[i]( sel, sel!.labels[i] );
    od;
    Enable( sel, "all", false );
    return true;  
  end;
  
  # construct text selector
  sheet!.selector := TextSelector(
        Concatenation( " Information about ", v!.label ),
        text,
        [ "all", funcall, "close", funcclose ] );

end);


#############################################################################
##
##  Methods for menu actions:
##
#############################################################################


#############################################################################
##
#M  GGLMenuOperation . . . . . . . . . . . . . . . .  is called from the menu
##
##  This operation is called for all so called "menu operations" the user
##  wants to perform on lattices. It is highly configurable with respect
##  to the input and output and the GAP-Operation which is actually performed
##  on the selected subgroups. See the configuration section in "ilatgrp.gi"
##  for an explanation.
##
InstallMethod( GGLMenuOperation,
    "for a graphic subgroup lattice, a menu, and a string",
    true,
    [ IsGraphicSheet and IsGraphicSubgroupLattice, IsMenu, IsString ],
    0,

function(sheet, menu, entry)
  local   menuop,  parameters,  selected,  v,  todolist,  i,  j,  todo,  
          currentparameters,  result,  infostr,  vertices,  newflag,  len,  
          hints,  grp,  res,  ver,  T,  inc,  T2;
  
  # first we determine the menu entry which was selected:
  menuop := Position(menu!.entries,entry);
  # fail is not an option here!
  menuop := sheet!.menuoperations[menuop];
  
  # note that we are guaranteed to have enough vertices selected!
  
  # let's prepare the parameters:
  parameters := [];
  if IsBound(menuop.sheet) and menuop.sheet then 
    Add(parameters,sheet); 
  fi;
  if IsBound(menuop.parent) and menuop.parent then 
    Add(parameters,sheet!.group); 
  fi;
  
  # the selected vertices:
  selected := Selected(sheet);
  
  # we clear old "results":
  for v in sheet!.lastresult do
    if PositionSet(selected,v) = fail then
      Recolor(sheet,v,sheet!.color.unselected);
    else
      Recolor(sheet,v,sheet!.color.selected);
    fi;
  od;
  sheet!.lastresult := [];
    
  if menuop.from = GGLfrom1 then
    # we do *not* have to look for menuop.plural because if it is false
    # then there can only be one vertex selected!
    todolist := List(selected,v->[v]);
    
  elif menuop.from = GGLfrom2 then
    # we do *not* have to look for menuop.plural because if it is false
    # then there can only be selected exactly two vertices.
    todolist := [];
    for i in [1..Length(selected)-1] do
      for j in [i+1..Length(selected)] do
        Add(todolist,[selected[i],selected[j]]);
      od;
    od;
    
  else  # menuop.from = GGLfromSet then
    # we do *not* have to look for menuop.plural because it is forbidden
    # for this case!
    todolist := [selected];
  fi;
  
  for todo in [1..Length(todolist)] do
    currentparameters := ShallowCopy(parameters);
    
    # there is one special case where we have to compare the two groups
    # in question:
    if menuop.from = GGLfrom2 and menuop.where = GGLwhereBetween then
      if not IsSubgroup( todolist[todo][1]!.data.group, 
                         todolist[todo][2]!.data.group ) then
        todolist[todo]{[1,2]} := todolist[todo]{[2,1]};
      fi;
    fi;
    
    Append(currentparameters,List(todolist[todo],v->v!.data.group));
    result := CallFuncList(menuop.op,currentparameters);
    
    # we give some information:
    infostr := Concatenation(menuop.name," (",todolist[todo][1]!.label);
    for i in [2..Length(todolist[todo])] do
      Append(infostr,",");
      Append(infostr,todolist[todo][i]!.label);
    od;
    Append(infostr,")");
    
    # now we have either nothing or a group or a list of groups or a record 
    # with components "subgroups" and "inclusions".
    if result = fail then
      Append(infostr,"fail");
    fi;
    if menuop.to = GGLto0 or result = fail then
      Info(GraphicLattice,1,infostr);
      infostr := "";
    else
      
      Append(infostr," --> (");
      
      if menuop.to = GGLto1 then
        result := [result];
      fi;
      
      if IsList(result) then
        result := rec(subgroups := result, inclusions := []);
      fi;
      
      # first we only insert the "new" vertices:
      vertices := [];
      newflag := [];
      len := Length(result.subgroups);
      hints := List(todolist[todo],v->v!.x);
      for grp in [1..len] do
        # we want no lines to vanish:
        FastUpdate(sheet,false);
        res := InsertVertex( sheet, result.subgroups[grp], hints );
        FastUpdate(sheet,true);
        
        vertices[grp] := res[1];
        newflag[grp] := res[2];
        
        # we mark the vertex:
        Select(sheet,res[1],true);
        if sheet!.color.result <> false  then
          Recolor( sheet, res[1], sheet!.color.result );
        fi;

        if grp <> 1 then
          Append(infostr,",");
        fi;
        Append(infostr,vertices[grp]!.label);
      od;
      Append(infostr,")");
      Info(GraphicLattice,1,infostr);
      infostr := "";
      
      # if the sheet has the HasseProperty, we are done, because the 
      # connections are calculated. Otherwise we have to see what we can do.
      if not HasseProperty(sheet) then
        # do we have additional information?
        if menuop.rels = GGLrelsTotal then
          # we calculate the info which vertex is maximal in which:
          T := List([1..len],x->List([1..len],y->0));
          for inc in result.inclusions do
            T[inc[1]][inc[2]] := 1;
          od;
          T2 := T * T;
          # if there is a value <> 0 at the position (i,j) then there is a
          # possibility to walk in two steps from vertex i to vertex j
          for i in [1..len] do
            for j in [1..len] do
              if T[i][j] <> 0 and T2[i][j] = 0 then
                NewInclusionInfo( sheet, vertices[i], vertices[j] );
              fi;
            od;
          od;
        elif menuop.rels = GGLrelsMax then
          for inc in result.inclusions do
            if inc[1] >= 1 and inc[1] <= len and 
               inc[2] >= 1 and inc[2] <= len then
                # this is no inclusion with lower or higher groups!
              NewInclusionInfo( sheet, vertices[inc[1]], vertices[inc[2]] );
            fi;
          od;
        elif menuop.rels = GGLrelsDown then
          for i in [1..len-1] do
            NewInclusionInfo( sheet, vertices[i+1], vertices[i] );
          od;
        elif menuop.rels = GGLrelsUp then
          for i in [1..len-1] do
            NewInclusionInfo( sheet, vertices[i], vertices[i+1] );
          od;
        fi;
        # we cannot say anything if menuop.rels = GGLrelsNo
        
        # perhaps we have information about the selected groups:
        if menuop.where = GGLwhereUp then
          for i in [1..len] do
            for j in [1..Length(todolist[todo])] do
              NewInclusionInfo( sheet, todolist[todo][j], vertices[i] );
            od;
          od;
        elif menuop.where = GGLwhereDown then
          for i in [1..len] do
            for j in [1..Length(todolist[todo])] do
              NewInclusionInfo( sheet, vertices[i], todolist[todo][j] );
            od;
          od;
        elif menuop.where = GGLwhereBetween then
          for i in [1..len] do
            NewInclusionInfo( sheet, vertices[i], todolist[todo][1] );
            NewInclusionInfo( sheet, todolist[todo][2], vertices[i] );
          od;
        fi;
        # we cannot say anything if menuop.where = GGLwhereAny
      fi;     # not HasseProperty
    fi;  # operation produced something
  od;  # all done
end);

##
## we need a dialog:
##
BindGlobal( "GGLPrimeDialog", Dialog( "OKcancel", "Prime" ) );

#############################################################################
##
#M  GGLSylowSubgroup(<grp>)  . . . . . .  asks for prime, calls SylowSubgroup
##
##  This operation just asks for a prime by a little dialog and calls then
##  SylowSubgroup. Returns its result.
##
InstallMethod( GGLSylowSubgroup,
    "for a group",
    true,
    [ IsGroup ],
    0,

function(grp)
  local   res,  p;
  res := Query( GGLPrimeDialog );
  if res = false then
    return fail;
  fi;
  p := Int(res);
  if not IsInt(p) or not IsPrime(p) then
    return fail;
  fi;
  return SylowSubgroup( grp, p );
end);


#############################################################################
##
##  Methods for inserting new vertices:
##
#############################################################################


#############################################################################
##
#M  InsertVertex( <sheet>, <grp>, <hints> ) . . . . . . . . insert new vertex
##
##  Insert the group <grp> as a new vertex into the sheet. If 
##  CanCompareSubgroups is set for the lattice, we check, if the group is
##  already in the lattice or if we already have a conjugate subgroup.
##  If the lattice has the HasseProperty, then this new vertex is sorted 
##  into the poset. So we check for all vertices on higher levels, if
##  the new vertex is contained and for all vertices on lower levels,
##  if they are contained in the new vertex. We try then to add edges to
##  the appropriate vertices. If the lattice does not have the HasseProperty,
##  nothing is done with respect to the connections of any vertex.
##  Returns list with vertex as first entry and a flag as second, which 
##  says, if this vertex was inserted right now or has already been there.
##  <hint> is a list of x coordinates which should give some hint for the
##  choice of the new x coordinate. It can for example be the x coordinates
##  of those groups which were parameter for the operation which calculated
##  the group. <hints> can be empty but must always be a list!
##
InstallMethod( InsertVertex,
    "for a graphic subgroup lattice, a group, and an list",
    true,
    [ IsGraphicSubgroupLattice and HasseProperty, IsGroup, IsList ],
    0,
        
function( sheet, grp, hints )
  local   index,  data,  isClassRep,  info,  vertex,  v,  vers,  lev,  
          cl,  conj,  classparam,  label,  Walkup,  Walkdown,  
          containerlist,  containedlist;
  
  ## FIXME: what if this index calculation crashes?
  ## so we never get infinite indices!
  
  index := Index(sheet!.group,grp);
  data := rec(group := grp,
              isClassRep := false,
              info := rec(Index := index));
  # missing: class and classrep, isClassRep could be changed!
  
  vertex := false;   # will become the new vertex
  if CanCompareSubgroups(sheet) then
    # we search for this group:
    v := WhichVertex(sheet,grp,function(data,vdata) 
                                 return data=vdata.group; 
                               end);
    if v <> fail then      
      return( [v,false] );
    fi;
    
    # perhaps we have a conjugate group?
    vers := [];
    # the index is the level parameter:
    lev := Position( Levels(sheet), index );
    lev := sheet!.levels[lev];
    # we walk through all classes and search the class representative:
    for cl in lev!.classes do
      Add(vers,First(cl,x->x!.data.isClassRep));
    od;
    
    if Length(vers) = 0 then 
      conj := fail;
    else
      conj := First([1..Length(vers)],
                    v->IsConjugate(sheet!.group,grp,vers[v]!.data.group));
    fi;
    
    if conj <> fail then
      # we insert into that class
      
      sheet!.largestlabel := sheet!.largestlabel+1;
      data.classRep := vers[conj]!.data;
      data.class := vers[conj]!.data.class;
      vertex := Vertex(sheet,data,rec(levelparam := index,
                                      classparam := lev!.classparams[conj],
                                      label := String(sheet!.largestlabel)));
    fi;
  fi;
  
  # if not yet done we create a new vertex in a new class:
  if vertex = false then
    data.isClassRep := true;
    data.classRep := data;
    data.class := [data];
    sheet!.largestlabel := sheet!.largestlabel + 1;
    vertex := Vertex(sheet,data,rec(levelparam := index,
                                    label := String(sheet!.largestlabel)));
  fi;
  
  if not HasseProperty(sheet) then
    return [v,true];
  fi;
  
  # now coming to the connections, we first search all higher levels
  # for vertices which contain our group. All those and those which are
  # even higher in the hierarchy meaning they contain vertices which contain
  # the new vertex, are stored in a list by their serial numbers to shorten
  # the search:
  
  Walkup := function(v)
    local   w;
    for w in v!.maximalin do
      if PositionSet(containerlist,w!.serial) <> fail then
        AddSet(containerlist,w!.serial);
        Walkup(w);
      fi;
    od;
  end;
  
  Walkdown := function(v)
    local   w;
    # first check if there are superfluos connections:
    for w in v!.maximalin do
      if PositionSet(containerlist,w!.serial) <> fail then
        # gotcha! Attention: new Edge not yet created, so no danger!
        Delete(sheet,w,v);
      fi;
    od;
    
    # now go down:
    for w in v!.maximals do
      if PositionSet(containedlist,w!.serial) <> fail then
        AddSet(containedlist,w!.serial);
        Walkdown(w);
      fi;
    od;
  end;
      
  containerlist := [];
  # all higher levels:
  lev := Position(Levels(sheet),index)-1;
  while lev > 0 do
    # all classes:
    for cl in sheet!.levels[lev]!.classes do
      for v in cl do
        if PositionSet(containerlist,v!.serial) = fail then
          if IsSubgroup(v!.data.group,grp) then
            Edge(sheet,vertex,v);
            AddSet(containerlist,v!.serial);
            Walkup(v);
          fi;
        fi;
      od;
    od;
    lev := lev - 1;
  od;
  
  # we have now connected to all subgroups which contain our new one as
  # a maximal element and have stored the serial numbers of all vertices
  # that contain our new vertex.
  # we now do the same downwards but we cancel additionally all connections
  # between contained subgroups and overgroups.
  containedlist := [];
  # all lower levels:
  lev := Position(Levels(sheet),index)+1;
  while lev <= Length(Levels(sheet)) do
    # all classes:
    for cl in sheet!.levels[lev]!.classes do
      for v in cl do
        if PositionSet(containedlist,v!.serial) = fail then
          if IsSubgroup(grp,v!.data.group) then
            AddSet(containedlist,v!.serial);
            Walkdown(v);
            Edge(sheet,vertex,v);
          fi;
        fi;
      od;
    od;
    lev := lev + 1;
  od;
  
  # now at last we are done.
  return [vertex,true];
  
end);


#############################################################################
##
##  Constructors:  
##
#############################################################################
  
#############################################################################
##
#F  GGLMakeSubgroupsMenu( <sheet>, <config> ) . . . . .  makes subgroups menu
##
##  This function is used to generate a menu out of the configuration data.
##
InstallGlobalFunction( GGLMakeSubgroupsMenu,
  function( sheet, config )
  
  local   entries,  types,  functions,  i,  c;
  
  entries := [];
  types := [];
  functions := [];
  
  for i in [1..Length(config)] do
    if IsBound(config) then
      c := config[i];
      entries[i] := c.name;
      functions[i] := GGLMenuOperation;
      if c.from = GGLfrom1 then
        if c.plural then
          types[i] := "forsubset";
        else
          types[i] := "forone";
        fi;
      elif c.from = GGLfrom2 then
        if c.plural then
          types[i] := "formin2";
        else
          types[i] := "fortwo";
        fi;
      elif c.from = GGLfromSet then
        types[i] := "forsubset";
      else
        types[i] := "forany";
      fi;
    fi;
  od;
  
  Menu( sheet, "Subgroups", entries, types, functions );
end);


#############################################################################
##
#M  GraphicSubgroupLattice(<G>) . . . . displays subgroup lattice graphically
#M  GraphicSubgroupLattice(<G>,<def>)  . . . . . . . . . . same with defaults
##
##  Displays a graphic poset which shows (parts of) the subgroup lattice of
##  the group <group>. Normally only the whole group and the trivial group are
##  shown (behaviour of "InteractiveLattice" in xgap3). Returns a
##  IsGraphicSubgroupLattice object. Calls DecideSubgroupLatticeType. See
##  there for details.
##
InstallMethod( GraphicSubgroupLattice,
    "for a group, and a record",
    true,
    [ IsGroup, IsRecord ],
    0,
        
function(G,def)
  local   latticetype,  defaults,  height,  title,  poset,  indices,  
          levelheight,  l,  vmath,  isClassRep,  info,  v2,  v1,  tmp;
  
  latticetype := DecideSubgroupLatticeType(G);
  # we do some heuristics to avoid the trivial group:
  # if we know all levels, we probably can calc. Size, if we shall generate
  # a vertex for the trivial subgroup, we should also know Size!
  if latticetype[1] or latticetype[4] then   
    # no trivial case:
    if Size(G) = 1 then
      return Error( "<G> must be non-trivial" );
    fi;
  fi;
  
  # we need a defaults record for the poset:
  defaults := rec(width := 800,
                  height := 600,
                  title := "GraphicSubgroupLattice");
  if HasName(G) then
    defaults.title := Concatenation(defaults.title," of ",Name(G));
  elif HasIdGroup(G) then
    defaults.title := Concatenation(defaults.title," of ",String(IdGroup(G)));
  fi;
  
  if IsBound(def.width) then defaults.width := def.width; fi;
  if IsBound(def.height) then defaults.height := def.height; fi;
  if IsBound(def.title) then defaults.title := def.title; fi;
  
  # we open a graphic poset:
  poset := GraphicPoset(defaults.title,defaults.width,defaults.height);
  # and make it a GraphicSubgroupLattice:
  SetFilterObj( poset, IsGraphicSubgroupLattice );
  
  poset!.group := G;
  
  # now the other filters, depending on type:
  if latticetype[1] then
    SetFilterObj(poset,KnowsAllLevels);
  fi;
  if latticetype[2] then
    SetFilterObj(poset,HasseProperty);
  fi;
  if latticetype[3] then
    SetFilterObj(poset,CanCompareSubgroups);
  fi;
  
  # initialize some components:
  poset!.selector := false;
  InstallCallback(poset,"Close",
          function(poset)
            if poset!.selector <> false then
              Close(poset!.selector);
              poset!.selector := false;
            fi;
          end);
          
  # set the limits:
  poset!.limits := rec(conjugates := 100);
  
  if KnowsAllLevels(poset) then
    # create all possible level parameters and levels:
    indices := Reversed(DivisorsInt(Size(G)));
    levelheight := QuoInt(poset!.height,Length(indices));
    for l in indices do
      CreateLevel(poset,l);
      ResizeLevel(poset,l,levelheight);
    od;
  else
    # we just create one or two levels:
    CreateLevel(poset,1);  # for the whole group
    if latticetype[4] then
      CreateLevel(poset,Size(G));
    fi;
  fi;
  
  # create one or two initial vertices (G itself and trivial subgroup):
  # we seperate the mathematical data and the graphical data:
  vmath := rec(group := G,
               isClassRep := true,
               info := rec(Index := 1));
  vmath.class := [vmath];
  vmath.classrep := vmath;
  v2 := Vertex(poset,vmath,rec(levelparam := vmath.info.Index, label := "G"));
  
  # we keep track of largest label:
  poset!.largestlabel := 1;
  
  if latticetype[4] then
    vmath := rec(group := TrivialSubgroup(G),
                 isClassRep := true,
                 info := rec(Index := Size(G)));
    vmath.class := [vmath];
    vmath.classrep := vmath;
    v1 := Vertex(poset,vmath,rec(levelparam := vmath.info.Index,label := "1"));
    
    # connect the two vertices
    Edge(poset,v1,v2);
  fi;
  
  # <G> is selected at first
  Select(poset,v2,true);
  
  # create menus:
  GGLMakeSubgroupsMenu(poset,latticetype[5]);
  poset!.menuoperations := latticetype[5];
  
  tmp := ShallowCopy(GGLCleanupMenu);
  if poset!.color.model = "color" then
    Append(tmp,[ "-","-","-","Use Black&White", "forany", GGLUseBlackWhite ]);
  fi;
  Menu(poset,"Cleanup",
       tmp{[1,4..Length(tmp)-2]},
       tmp{[2,5..Length(tmp)-1]},
       tmp{[3,6..Length(tmp)]});
  
  # Install the info method:
  poset!.infodisplays := latticetype[6];
  InstallPopup(poset,GGLRightClickPopup);
  
  # no vertex is green right now:
  poset!.lastresult := [];
  
  return poset;
end);

##
## without defaults record:
##
InstallOtherMethod(GraphicSubgroupLattice,
    "for a group",
    true,
    [ IsGroup ],
    0,
function(G)
  return GraphicSubgroupLattice(G,rec());
end);


#############################################################################
##
##  Decision function for subgroup lattice type:
##
#############################################################################


#############################################################################
##
#M  DecideSubgroupLatticeType(<grp>)  . . decides about the type of a lattice
##
##  This operation is called while creation of a new graphic subgroup lattice.
##  It has to decide about the type of the lattice. That means it has to
##  decide 5 questions:
##   1) Are all levels known right from the beginning?
##   2) Has the lattice the HasseProperty?
##   3) Can we test two subgroups for equality reasonably cheaply?
##   4) Shall we create a vertex for the trivial subgroup at the beginning?
##   5) What menu operations are possible?
##   6) What information is displayed on RightClick?
##  Returns a list. The first four entries are boolean values for  questions
##  1-4. Note that if the answer to 2 is true, then the answer to 3 must also
##  be true. The fifth and sixth entry are configuration lists as explained 
##  in the configuration section of "ilatgrp.gi" for menu operations and
##  info displays respectively.
##
##  The following is the default "fallback" method suitable for reasonably
##  small finite groups.
##
InstallMethod( DecideSubgroupLatticeType,
    "for a group",
    true,
    [ IsGroup ],
    0,
        
function( G )
  local   knowslevels;
  if Size(G) > 10^17 then    # that is just heuristic!
    knowslevels := false;
  else
    knowslevels := Length(DivisorsInt(Size(G))) < 50;
  fi;
  return [knowslevels,
          true,         # we assume HasseProperty
          true,         # we assume we can compare groups
          true,         # we want the trivial subgroup
          GGLMenuOpsForFiniteGroups,
          GGLInfoDisplaysForFiniteGroups];
end);

## for finitely presented groups:
InstallMethod( DecideSubgroupLatticeType,
    "for a group",
    true,
    [ IsGroup and IsFpGroup ],
    0,
        
function( G )
  return [false,        # we create levels dynamically
          false,        # we do not assume HasseProperty
          false,        # we assume we cannot compare groups efficiently
          false,        # we don't want the trivial subgroup
          GGLMenuOpsForFpGroups,
          GGLInfoDisplaysForFpGroups];
end);

