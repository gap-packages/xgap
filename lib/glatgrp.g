#############################################################################
##
#A  glatgrp.g                 	XGAP library               Susanne Keitemeier
##
#H  @(#)$Id: glatgrp.g,v 1.1 1997/11/27 12:19:50 frank Exp $
##
#Y  Copyright (C) 1993,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##
##  This  file contains the non-interactive  lattice  program.  The following
##  functions are implemented:
##
##  'GraphicLattice( <group>[, <x>, <y>][, "prime"][, "normal subgroups"] )
##  -----------------------------------------------------------------------
##
##  'GraphicLattice' computes  the lattice of <group>  and then  displays the
##  whole lattice in a graphic  sheet of dimension  width <x> and height <y>.
##
##  If you  specify "prime"  then the y   coordinate of a classes  is choosen
##  according to the  numbers of prime  factors of  the subgroups instead  of
##  their sizes.
##
##  If you specify "normal subgroups" only the lattice of normal subgroups is
##  drawn.
##
##  'Select( <lat>, <list-of-subgroups> )'
##  --------------------------------------
##
##  'Select' selects the subgroups given in <list-of-subgroups>
##
##  'Selected( <lat> )'
##  -------------------
##
##  'Selected'  returns a list of selected subgroup
##
##  A graphic lattice record contains the following components:
##  -----------------------------------------------------------
##
##  'classes':
##    a list of conjugacy classes of 'group'
##
##  'cleanUpMenu':
##    This menu contains "Use Black&White" which will be checked if selected.
##
##  'color.model':
##    If equals "color" then the  color 'color.unselected' is used for normal
##    vertices and 'color.selected' is used for selected ones.
##
##  'color.selected':
##    If the display supports color, the color "red"  is used, if the display
##    supports grayscale,  "light gray" is  used.  If  neither red  nor light
##    gray are available then a circle/diamond combination is used.
##
##  'color.unselected':
##    a black circle is used for unselected vertices
##
##  'color.result':
##    the  color used to mark  a result from  the subgroup menu, this is only
##    used on a color screen in which case 'color.result' is "green".
##
##  'group':
##    the group of the graphic lattice
##
##  'init':
##    a record used to describe the initial setup of the graphic lattice. The
##    components are  described   below, they  are *only*  used  to draw  the
##    lattice before the  user can interact.  After the  lattice is drawn all
##    information is stored in 'vertices', 'strips'.
##
##  'lattice':
##    the subgroup lattice of 'group' (see 'Lattice' for details)
##
##  'representatives':
##    a representative for each class
##
##  'strips':
##    a list of  vertices  belonging  to subgroups  of  the same  order.  For
##    instance  'strips' is used in  "Average   Y Levels"  to find out  which
##    vertices should be on the same Y line  or the drag  routine to find out
##    between which bounds a vertex can be dragged.
##
##  'updateMenus0':
##    a list of pairs (menu,entries) for menus which are not available  if no
##    selection is made
##
##  'updateMenus1':
##    a list  of pairs (menu,entries) for  menus  which are  not available if
##    less than 2 selections are made
##
##  'updateMenusEq1':
##    a list of  pairs (menu,entries)  for  menus which are available  if one
##    selection is made
##
##  'updateMenus2':
##    a list  of pairs (menu,entries) for  menus  which are  not available if
##    less than 3 selections are made
##
##  'vertices':
##    a  list of   vertices, a  vertex  is   again a record  with  components
##    described below.
##
##
##  A vertex from 'vertices' is a record with the following components:
##  -------------------------------------------------------------------
##
##  'class':
##    if  'isClassRep'  is 'true' then  'class' contains  a list  of vertices
##    describing the whole class (including the representative).
##
##  'classRep':
##    the vertex of the class representative
##
##  'group':
##    the subgroup of this vertex (optional)
##
##  'ident':
##    a  pair  '[<c>,<i>]', where <c> is   number of the  class (according to
##    <sheet>.classes) in which  the subgroup of  this vertex lies and <i> is
##    the    position of    the  subgroup   in   this   classes.   See   also
##    'SubgroupVertex' and 'VertexSubgroup'.
##
##  'info':
##    contains    information about  the  group belong    to the vertex, this
##    information is used in 'PMShowInfo'
##
##  'isClassRep':
##    true, if vertex is a class representative
##
##  'strip':
##    this vertex lies in the strip <s>.strips[<ver>.strip]
##
##  'x':
##    the x coordinate, one has to use 'Move' in order to change it
##
##  'y':
##    the y coordinate, one has to use 'Move' in order to change it
##
##
##  The inital setup 'init' contains the following record components:
##  -----------------------------------------------------------------
##
##  'b':
##    branches
##
##  'classLengths':
##    length of each class
##
##  'primeOrdering':
##    if 'false'  the y  coordinates are  ordered according  to the number of
##    size of the subgroups, if 'true' the y  coordinates are order according
##    to the number of prime factors of the size.
##
##  'orderReps':
##    the order of representative of a class
##
##  'orders':
##    different orders occuring, sorted according to 'primeOrdering'
##
##  'r':
##    rows
##
##  'reps':
##    'vertices' numbers (number <n>, see below) of the representatives
##
##  'vertices':
##    a     list   of  vertices,    each  vertex   in   this    list  a tuple
##    [<n>,<s>,<m>,<c>,<p>] where <n> is a unique  number, <s> is the size of
##    the representative, <m> is a list of  maximals (as list of those unique
##    numbers), <c> is the class, and <p> is the position in this class.
##
##  'x':
##    the inital x coordinates of each vertex
##
##  'y':
##    the inital y coordinates of each strip
##
##
#H  $Log: glatgrp.g,v $
#H  Revision 1.1  1997/11/27 12:19:50  frank
#H  added 3.5 library (does not work with 4.0)
#H
#H  Revision 1.19  1995/09/24  14:38:54  fceller
#H  fixed a problem with "colors" on a grey scale display
#H
#H  Revision 1.18  1995/08/10  18:06:27  fceller
#H  changed 'Box', 'Rectangle', 'Diamond' and 'Line'
#H  to expect the start position and a width and height
#H
#H  Revision 1.17  1995/08/09  10:54:36  fceller
#H  fixed various things (too much too mention but all were minor)
#H
#H  Revision 1.16  1995/07/28  10:00:20  fceller
#H  changed some of the names of the menu entries
#H
#H  Revision 1.15  1995/07/24  10:01:24  fceller
#H  changed select mechanism
#H
#H  Revision 1.14  1995/05/29  12:51:51  fceller
#H  added 'Relabel' in the CleanUp Menu,
#H  removed Popup Menu for Vertex, click with the right mouse pointer
#H  on vertex will now give the information text selector
#H
#H  Revision 1.13  1995/02/16  20:47:00  fceller
#H  added 'updateMenusEq1'
#H
#H  Revision 1.12  1995/02/10  16:30:45  fceller
#H  added local missing variable
#H
#H  Revision 1.11  1995/02/10  14:50:23  fceller
#H  clean up information menu
#H
#H  Revision 1.10  1995/02/07  09:39:02  fceller
#H  changed 'SortMaximals' slightly to allow all kinds of lattices
#H
#H  Revision 1.9  1995/02/06  09:56:27  fceller
#H  the representatives are now also stored in a graphic lattice
#H
#H  Revision 1.8  1995/02/03  10:46:00  fceller
#H  added a description at the beginnig, removed a lot of unnecessary
#H  record components
#H
#H  Revision 1.7  1994/09/22  09:28:10  fceller
#H  added Susanne's resize functions,  added color support
#H
#H  Revision 1.6  1994/06/06  08:39:49  fceller
#H  fast update is now done for the entire movement of classes
#H
#H  Revision 1.5  1993/10/18  11:06:14  fceller
#H  added fast updated
#H
#H  Revision 1.4  1993/10/05  12:33:26  fceller
#H  added '.isAlive'
#H
#H  Revision 1.3  1993/08/13  13:37:04  fceller
#H  added resize
#H
#H  Revision 1.2  93/07/30  14:23:59  fceller
#H  added graphic lattice given by maximals
#H  
#H  Revision 1.1  1993/07/22  11:23:53  fceller
#H  Initial revision
##


#############################################################################
##
#F  InfoGraphicLattice1(...)  . . . . print information about subgroups found
##
InfoGraphicLattice1 := Print;


#############################################################################
##
#F  IntString( <string> ) . . . . . . . . . . . . . . . . . String -> Integer
##
IntString := function( a )
    local   z,  m,  i,  s,  n,  p,  d;

    z := 0;
    m := 1;
    p := 1;
    d := false;
    for i  in [ 1 .. Length(a) ]  do
        if i = p and a[i] = '-'  then
            m := -1;
        elif a[i] = '/' and not IsBound(n)  then
            if IsRat(d)  then
                z := d * z;
            fi;
            d := false;
            n := m * z;
            m := 1;
            p := i+1;
            z := 0;
        elif a[i] = '.' and not IsRat(d)  then
            d := 1;
        else
            s := Position( "0123456789", a[i] );
            if s <> false  then
                z := 10 * z + (s-1);
            else
                return false;
            fi;
            if IsRat(d)  then
                d := d / 10;
            fi;
        fi;
    od;
    if IsRat(d)  then
        z := d * z;
    fi;
    if IsBound(n)  then
        return m * n / z;
    else
        return m * z;
    fi;
end;


#F  # # # # # # # # # # #  Internal Functions   # # # # # # # # # # # # # # #


#############################################################################
##

#V  GraphicLatticeOps . . . . . . . . . . . . . . . . . . . operations record
##
GraphicLatticeOps := OperationsRecord(
    "GraphicLatticeOps", GraphicSheetOps );

#F  GraphicLatticeOps.DeselectAll( <sheet> )  . . . . . . deselect all groups
##
GraphicLatticeOps.DeselectAll := function( sheet )
    local   obj;
    
    for obj  in sheet.selected  do
        sheet.operations.SelectObject( sheet, obj, false );
    od;
    sheet.selected := [];
    sheet.operations.UpdateMenus(sheet);
end;


#############################################################################
##
#F  GraphicLatticeOps.Enlarge( <sheet>, <xfac>, <yfac> )  . .  resize lattice
##
GraphicLatticeOps.Enlarge := function( sheet, xfac, yfac )
    local   obj,  x,  y,  ver,  newx,  newy;
    
    # is this really a resize?
    if xfac = 1 and yfac = 1  then return;  fi;

    # resize window
    sheet.operations.Resize( sheet, Int(xfac*sheet.width),
                                    Int(yfac*sheet.height) );

    # and move objects to new position
    FastUpdate( sheet, true );
    for obj  in sheet.vertices  do
        if obj.isClassRep  then
            x := obj.x;  newx := Int(xfac*(x+1)-1);
            y := obj.y;  newy := Int(yfac*(y+1)-1);
            for ver  in obj.class  do
                Move( ver, (ver.x-x)+newx, newy );
            od;
        fi;
    od;
    FastUpdate( sheet, false );
    
end;


#############################################################################
##
#F  GraphicLatticeOps.Print( <sheet> )  . . . . . . . . . . . pretty printing
##
GraphicLatticeOps.Print := function( sheet )
    Print( "<graphic lattice>" );
end;


#############################################################################
##
#F  GraphicLatticeOps.Select( <sheet>, <list> ) . . . . . select given groups
##
GraphicLatticeOps.Select := function( sheet, l )
    local   u,  v,  ver;
    
    # deselect all groups
    sheet.operations.DeselectAll(sheet);

    # find subgroups
    v := [];
    for u  in l  do
        ver := sheet.operations.VertexSubgroup( sheet, u );
        if not ver in sheet.selected  then
            sheet.operations.ToggleSelection( sheet, ver );
        fi;
        Add( v, ver );
    od;

    # and return a list of vertices
    return v;

end;


#############################################################################
##
#F  GraphicLatticeOps.SelectObject( <sheet>, <obj>, <flag> )  . .  (de)select
##
GraphicLatticeOps.SelectObject := function( sheet, obj, flag )

    Highlight( obj, flag );
    if flag  then
        Recolor( obj, sheet.color.selected );
    else
        Recolor( obj, sheet.color.unselected );
    fi;

end;


#############################################################################
##
#F  GraphicLatticeOps.Selected( <sheet> ) . . . . . .  return selected groups
##
GraphicLatticeOps.Selected := function( sheet )
    local   groups,  obj,  rep,  trn;

    groups := [];
    for obj  in sheet.selected  do
        Add( groups, sheet.operations.SubgroupVertex( sheet, obj ) );
    od;

    # and return
    return groups;

end;


#############################################################################
##
#F  GraphicLatticeOps.ShowResult( <sheet>, <old>, <new>, <x> )  show a result
##
##  <x> is ignored because all subgroups are already on screen.
##
GraphicLatticeOps.ShowResult := function( sheet, old, new, x )
    local   ver;

    # deselect all vertices
    sheet.operations.DeselectAll(sheet);

    # find the vertices corresponding to <old> and <new>
    old := List( old, x -> sheet.operations.VertexSubgroup(sheet,x) );
    new := List( new, x -> sheet.operations.VertexSubgroup(sheet,x) );

    # if 'sheet.color.result' is false use dump selection
    for ver  in Concatenation( old, new )  do
        if not ver in sheet.selected  then
            sheet.operations.ToggleSelection( sheet, ver );
        fi;
    od;

    # otherwise use nice selection coloring
    if sheet.color.result <> false  then
        for ver  in new  do
            Recolor( ver, sheet.color.result );
        od;
    fi;

    # and return the "new" vertices
    return new;

end;


#############################################################################
##
#F  GraphicLatticeOps.SubgroupVertex( <sheet>, <ver> )   subgroup of a vertex
##
GraphicLatticeOps.SubgroupVertex := function( sheet, ver )
    local   rep,  trn;

    if not IsBound(ver.group)  then
        rep := sheet.representatives[ver.ident[1]];
        trn := RightTransversal(sheet.group,Normalizer(sheet.group,rep));
        ver.group := rep^trn[ver.ident[2]];
    fi;
    return ver.group;
end;


#############################################################################
##
#F  GraphicLatticeOps.ToggleSelection( <sheet>, <obj> ) . . . . toggle status
##
GraphicLatticeOps.ToggleSelection := function( sheet, obj )
    
    if obj in sheet.selected  then
        sheet.operations.SelectObject( sheet, obj, false );
        sheet.selected := Filtered( sheet.selected, x -> x <> obj );
    else
        sheet.operations.SelectObject( sheet, obj, true );
        Add( sheet.selected, obj );
    fi;
    sheet.operations.UpdateMenus(sheet);
    
end;

                          
#############################################################################
##
#F  GraphicLatticeOps.UpdateMenus( <sheet> )  . . . . .  enable/disable menus
##
GraphicLatticeOps.UpdateMenus := function( sheet )
    local   pair, name;

    # entries which need at least one selection
    if 0 < Length(sheet.selected)  then
        for pair  in sheet.updateMenus0  do
            for name  in pair[2]  do
                Enable( pair[1], name );
            od;
        od;
    else
        for pair  in sheet.updateMenus0  do
            for name  in pair[2]  do
                Enable( pair[1], name, false );
            od;
        od;
    fi;

    # entries which need at least two selections
    if 1 < Length(sheet.selected)  then
        for pair  in sheet.updateMenus1  do
            for name  in pair[2]  do
                Enable( pair[1], name );
            od;
        od;
    else
        for pair  in sheet.updateMenus1  do
            for name  in pair[2]  do
                Enable( pair[1], name, false );
            od;
        od;
    fi;

    # entries which need at least three selections
    if 2 < Length(sheet.selected)  then
        for pair  in sheet.updateMenus2  do
            for name  in pair[2]  do
                Enable( pair[1], name );
            od;
        od;
    else
        for pair  in sheet.updateMenus2  do
            for name  in pair[2]  do
                Enable( pair[1], name, false );
            od;
        od;
    fi;

    # entries which need exactly one selection
    if 1 = Length(sheet.selected)  then
        for pair  in sheet.updateMenusEq1  do
            for name  in pair[2]  do
                Enable( pair[1], name );
            od;
        od;
    else
        for pair  in sheet.updateMenusEq1  do
            for name  in pair[2]  do
                Enable( pair[1], name, false );
            od;
        od;
    fi;
end;


#############################################################################
## 
#F  GraphicLatticeOps.VertexSubgroup( <sheet>, <grp> )   vertex of a subgroup
##
GraphicLatticeOps.VertexSubgroup := function( sheet, grp )
    local   s,  c,  r,  i,  rep,  trn,  U;

    # first do a trvial search
    s := Size(grp);
    c := Filtered( [1..Length(sheet.classes)],
                   x -> Size(sheet.representatives[x]) = s );
    r := Filtered(sheet.vertices, x -> IsBound(x.group) and x.ident[1] in c);
    for i  in r  do
        if i.group = grp  then
            return i;
        fi;
    od;

    # ok, we have to search harder
    c   := First( [1..Length(sheet.classes)], x -> grp in sheet.classes[x] );
    rep := sheet.representatives[c];
    trn := RightTransversal( sheet.group, Normalizer( sheet.group, rep ) );
    i   := 1;
    U   := rep^trn[i];
    while grp <> U do
        i := i + 1;
        U := rep^trn[i];
    od;
    rep := [ c, i ];
    rep := First( sheet.vertices, x -> x.ident = rep );
    if not IsBound(rep.group)  then
        rep.group := U;
    fi;
    return rep;
end;


#F  # # # # # # # # # # # # # #  Dialogs  # # # # # # # # # # # # # # # # # #


#############################################################################
##

#V  GraphicLatticeOps.PDLabel . . . . . . . . . . . . .  "enter label" dialog
##
GraphicLatticeOps.PDLabel := Dialog( "OKcancel", "Label" );


#############################################################################
##
#V  GraphicLatticeOps.PDPrime . . . . . . . . . . . . .  "enter prime" dialog
##
GraphicLatticeOps.PDPrime := Dialog( "OKcancel", "Prime" );


#F  # # # # # # # # # # # # # # #  Menus  # # # # # # # # # # # # # # # # # #


#############################################################################
##

#F  GraphicLatticeOps.RMDoubleLattice( ... )  . . . . . .  double the lattice
##
GraphicLatticeOps.RMDoubleLattice := function( sheet, menu, name )
    return sheet.operations.Enlarge( sheet, 2, 2 );
end;


#############################################################################
##
#F  GraphicLatticeOps.RMHalveLattice( ... ) . . . . . . .  double the lattice
##
GraphicLatticeOps.RMHalveLattice := function( sheet, menu, name )
    return sheet.operations.Enlarge( sheet, 1/2, 1/2 );
end;


#############################################################################
##
#F  GraphicLatticeOps.RMResizeLattice( ... )  . . . . . . . . . . resize menu
##
GraphicLatticeOps.FactorsString := function( factor )
    local   p,  x,  y;

    # find ","
    p := Position( factor, ',' );
    if p = false  then
        x := IntString(factor);
        y := x;
    elif p = 1  then
        x := 1;
        y := IntString(factor{[2..Length(factor)]});
    elif p = Length(factor)  then
        x := IntString(factor{[1..p-1]});
        y := 1;
    else
        x := IntString(factor{[1..p-1]});
        y := IntString(factor{[p+1..Length(factor)]});
    fi;
    if x = 0  then x := 1;  fi;
    if y = 0  then y := 1;  fi;
    return [ x, y ];

end;

GraphicLatticeOps.RMResizeLattice := function( sheet, menu, entry )
    local   res,  fac;

    # popup a dialog box and query resize factors
    res := Query( Dialog( "OKcancel", "X,Y factors" ) );
    if res = false or 0 = Length(res)  then
        return;
    fi;
    fac := sheet.operations.FactorsString(res);

    # enlarge the sheet and resize the lattice
    sheet.operations.Enlarge( sheet, fac[1], fac[2] );

end;


#############################################################################
##
#F  GraphicLatticeOps.RMResizeGraphicSheet( ... ) .  resize the graphic sheet
##
GraphicLatticeOps.RMResizeGraphicSheet := function( sheet, menu, entry )
    local   res,  fac;

    # popup a dialog box and query resize factors
    res := Query( Dialog( "OKcancel", "X,Y factors" ) );
    if res = false or 0 = Length(res)  then
        return;
    fi;
    fac := sheet.operations.FactorsString(res);

    # enlarge the sheet and resize the lattice
    fac[1] := Int(fac[1]*sheet.width);
    fac[2] := Int(fac[2]*sheet.height);
    sheet.operations.Resize( sheet, fac[1], fac[2] );
end;


#############################################################################
##

#F  GraphicLatticeOps.SMCentralizers( ... ) . centralizers of selected groups
##
GraphicLatticeOps.SMCentralizers := function( sheet, menu, name )
    local   sel,  old,  new,  i,  pos;

    # compute the centralizers and show them
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    new := List( old, x -> Centralizer( sheet.super, x ) );
    pos := List( sel, x -> x.x );
    new := sheet.operations.ShowResult( sheet, old, new, pos );

    # give some information
    for  i  in [ 1 .. Length(sel) ]  do
        InfoGraphicLattice1( "#I  Centralizer(", sel[i].label.text, ") = ",
                             new[i].label.text, "\n" );
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.SMCentres( ... )  . . . . .  centres of selected groups
##
GraphicLatticeOps.SMCentres := function( sheet, menu, name )
    local   sel,  old,  new,  i,  pos;

    # compute the centres and show them
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    new := List( old, Centre );
    pos := List( sel, x -> x.x );
    new := sheet.operations.ShowResult( sheet, old, new, pos );

    # give some information
    for  i  in [ 1 .. Length(sel) ]  do
        InfoGraphicLattice1( "#I  Centre(", sel[i].label.text, ") = ",
                             new[i].label.text, "\n" );
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.SMClosure( ... )  . . . . .  closure of selected groups
##
GraphicLatticeOps.SMClosure := function( sheet, menu, name )
    local   sel,  clo,  new,  old,  i,  pos;

    # compute the closure and show it
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    clo := old[1];
    pos := sel[1].x;
    for i  in [ 2 .. Length(old) ]  do
        clo := Closure( clo, old[i] );
        pos := pos + sel[i].x;
    od;
    pos := QuoInt( pos, Length(sel) );
    new := sheet.operations.ShowResult( sheet, old, [clo], [pos] );

    # give some information
    InfoGraphicLattice1( "#I  Closure(", sel[1].label.text );
    for  i  in [ 2 .. Length(sel) ]  do
        InfoGraphicLattice1( ",", sel[i].label.text );
    od;
    InfoGraphicLattice1( ") = ", new[1].label.text, "\n" );

end;


#############################################################################
##
#F  GraphicLatticeOps.SMClosures( ... ) . . . . . closures of selected groups
##
GraphicLatticeOps.SMClosures := function( sheet, menu, name )
    local   sel,  old,  new,  x,  y,  i,  pos;

    # compute the centres and show them
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    new := [];
    pos := [];
    for x  in [ 1 .. Length(old) ]  do
        for y  in [ x+1 .. Length(old) ]  do
            Add( new, Closure( old[x], old[y] ) );
            Add( pos, QuoInt( sel[x].x+sel[y].x, 2 ) );
        od;
    od;
    new := sheet.operations.ShowResult( sheet, old, new, pos );

    # give some information
    i := 1;
    for x  in [ 1 .. Length(old) ]  do
        for y  in [ x+1 .. Length(old) ]  do
            InfoGraphicLattice1( "#I  Closure(", sel[x].label.text, ",",
                                 sel[y].label.text, ") = ",
                                 new[i].label.text, "\n" );
            i := i + 1;
        od;
    od;
    
end;


#############################################################################
##
#F  GraphicLatticeOps.SMCommutatorSubgroups( ... )  . comm of selected groups
##
GraphicLatticeOps.SMCommutatorSubgroups := function( sheet, menu, name )
    local   sel,  old,  new,  x,  y,  i,  pos;

    # compute the commutators and show them
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    new := [];
    pos := [];
    for x  in [ 1 .. Length(old) ]  do
        for y  in [ x+1 .. Length(old) ]  do
            Add( new, CommutatorSubgroup( old[x], old[y] ) );
            Add( pos, QuoInt( sel[x].x+sel[y].x, 2 ) );
        od;
    od;
    new := sheet.operations.ShowResult( sheet, old, new, pos );

    # give some information
    i := 1;
    for x  in [ 1 .. Length(old) ]  do
        for y  in [ x+1 .. Length(old) ]  do
            InfoGraphicLattice1( "#I  CommutatorSubgroup(", 
                                 sel[x].label.text, ",",
                                 sel[y].label.text, ") = ",
                                 new[i].label.text, "\n" );
            i := i + 1;
        od;
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.SMCores( ... )  . . . . . . .  cores of selected groups
##
GraphicLatticeOps.SMCores := function( sheet, menu, name )
    local   sel,  old,  new,  i,  pos;

    # compute the centres and show them
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    new := List( old, x -> Core( sheet.super, x ) );
    pos := List( sel, x -> x.x );
    new := sheet.operations.ShowResult( sheet, old, new, pos );

    # give some information
    for  i  in [ 1 .. Length(sel) ]  do
        InfoGraphicLattice1( "#I  Core(", sel[i].label.text, ") = ",
                             new[i].label.text, "\n" );
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.SMDerivedSeries( ... )   der. series of selected groups
##
GraphicLatticeOps.SMDerivedSeries := function( sheet, menu, name )
    local   sel,  old,  new,  src,  pos,  i,  tmp,  j,  k;

    # compute the closure and show it
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    new := [];
    src := [];
    pos := [];
    for i  in [ 1 .. Length(old) ]  do
        tmp := DerivedSeries(old[i]);
        Append( new, tmp );
        Append( pos, List( tmp, x -> sel[i].x ) );
        Add( src, [i,tmp] );
    od;
    new := sheet.operations.ShowResult( sheet, old, new, pos );

    # give some information
    j := 0;
    for i  in [ 1 .. Length(src) ]  do
        InfoGraphicLattice1( "#I  DerivedSeries(", sel[src[i][1]].label.text,
                             ") = " );
        for k  in [ 1 .. Length(src[i][2]) ]  do
            InfoGraphicLattice1( new[j+k].label.text, " " );
        od;
        j := j + Length(src[i][2]);
        InfoGraphicLattice1( "\n" );
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.SMDerivedSubgroups( ... ) .  der.sub of selected groups
##
GraphicLatticeOps.SMDerivedSubgroups := function( sheet, menu, name )
    local   sel,  old,  new,  i,  pos;

    # compute the centres and show them
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    new := List( old, DerivedSubgroup );
    pos := List( sel, x -> x.x );
    new := sheet.operations.ShowResult( sheet, old, new, pos );

    # give some information
    for  i  in [ 1 .. Length(sel) ]  do
        InfoGraphicLattice1( "#I  DerivedSubgroup(", sel[i].label.text,
                             ") = ", new[i].label.text, "\n" );
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.SMFittingSubgroups( ... ) .  fitting of selected groups
##
GraphicLatticeOps.SMFittingSubgroups := function( sheet, menu, name )
    local   sel,  old,  new,  i,  pos;

    # compute the centres and show them
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    new := List( old, FittingSubgroup );
    pos := List( sel, x -> x.x );
    new := sheet.operations.ShowResult( sheet, old, new, pos );

    # give some information
    for  i  in [ 1 .. Length(sel) ]  do
        InfoGraphicLattice1( "#I  FittingSubgroup(", sel[i].label.text,
                             ") = ", new[i].label.text, "\n" );
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.SMIntersection( ... ) . intersection of selected groups
##
GraphicLatticeOps.SMIntersection := function( sheet, menu, name )
    local   sel,  clo,  new,  old,  i,  pos;

    # compute the closure and show it
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    clo := old[1];
    pos := sel[1].x;
    for i  in [ 2 .. Length(old) ]  do
        clo := Intersection( clo, old[i] );
        pos := pos + sel[i].x;
    od;
    pos := QuoInt( pos, Length(sel) );
    new := sheet.operations.ShowResult( sheet, old, [clo], [pos] );

    # give some information
    InfoGraphicLattice1( "#I  Intersection(", sel[1].label.text );
    for  i  in [ 2 .. Length(sel) ]  do
        InfoGraphicLattice1( ",", sel[i].label.text );
    od;
    InfoGraphicLattice1( ") = ", new[1].label.text, "\n" );

end;


#############################################################################
##
#F  GraphicLatticeOps.SMIntersections( ... ) intersections of selected groups
##
GraphicLatticeOps.SMIntersections := function( sheet, menu, name )
    local   sel,  old,  new,  x,  y,  i,  pos;

    # compute the centres and show them
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    new := [];
    pos := [];
    for x  in [ 1 .. Length(old) ]  do
        for y  in [ x+1 .. Length(old) ]  do
            Add( new, Intersection( old[x], old[y] ) );
            Add( pos, QuoInt( sel[x].x+sel[y].x, 2 ) );
        od;
    od;
    new := sheet.operations.ShowResult( sheet, old, new, pos );

    # give some information
    i := 1;
    for x  in [ 1 .. Length(old) ]  do
        for y  in [ x+1 .. Length(old) ]  do
            InfoGraphicLattice1( "#I  Intersection(", sel[x].label.text,
                                 ",", sel[y].label.text, ") = ",
                                 new[i].label.text, "\n" );
            i := i + 1;
        od;
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.SMNormalClosures( ... )  normal clos of selected groups
##
GraphicLatticeOps.SMNormalClosures := function( sheet, menu, name )
    local   sel,  old,  new,  i,  pos;

    # compute the centres and show them
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    new := List( old, x -> NormalClosure( sheet.super, x ) );
    pos := List( sel, x -> x.x );
    new := sheet.operations.ShowResult( sheet, old, new, pos );

    # give some information
    for  i  in [ 1 .. Length(sel) ]  do
        InfoGraphicLattice1( "#I  NormalClosure(", sel[i].label.text,
                             ") = ", new[i].label.text, "\n" );
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.SMNormalSubgroups( ... )  normal sub of selected groups
##
GraphicLatticeOps.SMNormalSubgroups := function( sheet, menu, name )
    local   sel,  old,  new,  src,  pos,  i,  tmp,  k,  m,  j,  p;

    # compute the closure and show it
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    new := [];
    src := [];
    pos := [];
    for i  in [ 1 .. Length(old) ]  do

        # compute the normal subgroups and sort them
        tmp := NormalSubgroups(old[i]);
        Sort( tmp, function(a,b) return Size(a) < Size(b); end );
        Append( new, tmp );
        Add( src, [i,tmp] );

        # compute nice positions
        k := 0;
        m := 1;
        for j  in [ 1 .. Length(tmp) ]  do
            if 1 < j and Size(tmp[j]) = Size(tmp[j-1])  then
                k := k+1;
            else
                k := 0;
                m := 1;
            fi;
            if m = 1  then
                p := sel[i].x+QuoInt(3*VERTEX.diameter*k,2);
                if sheet.width < pos+2*VERTEX.diameter  then
                    m := -1;
                    k := 1;
                fi;
            fi;
            if m = -1  then
                p := sel[i].x-QuoInt(3*VERTEX.diameter*k,2);
                if p < 2*VERTEX.diameter  then
                    p := sel[i].x;
                fi;
            fi;
            Add( pos, p );
        od;

    od;
    new := sheet.operations.ShowResult( sheet, old, new, pos );

    # give some information
    j := 0;
    for i  in [ 1 .. Length(src) ]  do
        InfoGraphicLattice1( "#I  NormalSubgroups(", 
                             sel[src[i][1]].label.text, ") = " );
        for k  in [ 1 .. Length(src[i][2]) ]  do
            InfoGraphicLattice1( new[j+k].label.text, " " );
        od;
        j := j + Length(src[i][2]);
        InfoGraphicLattice1( "\n" );
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.SMNormalizers( ... )  .  normalizers of selected groups
##
GraphicLatticeOps.SMNormalizers := function( sheet, menu, name )
    local   sel,  old,  new,  i,  pos;

    # compute the centres and show them
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    new := List( old, x -> Normalizer( sheet.super, x ) );
    pos := List( sel, x -> x.x );
    new := sheet.operations.ShowResult( sheet, old, new, pos );

    # give some information
    for  i  in [ 1 .. Length(sel) ]  do
        InfoGraphicLattice1( "#I  Normalizer(", sel[i].label.text, ") = ",
                             new[i].label.text, "\n" );
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.SMSylowSubgroups( ... )    sylow sub of selected groups
##
GraphicLatticeOps.SMSylowSubgroups := function( sheet, menu, name )
    local   res,  p,  sel,  old,  new,  i,  pos;

    # request a prime from the user
    res := Query( sheet.operations.PDPrime );
    if res = false  then
        return;
    fi;
    p := IntString(res);
    if p = false or not IsInt(p) then
        Print( "#W  '", res, "' is not an integer\n" );
        return;
    fi;
    if p < 1 or not IsPrime(p)  then
        Print( "#W  '", res, "' is not a positive prime\n" );
        return;
    fi;

    # compute the sylow subgroups and show them
    sel := ShallowCopy(sheet.selected);
    old := List( sel, x -> sheet.operations.SubgroupVertex(sheet,x) );
    new := List( old, x -> SylowSubgroup( x, p ) );
    pos := List( sel, x -> x.x );
    new := sheet.operations.ShowResult( sheet, old, new, pos );

    # give some information
    for  i  in [ 1 .. Length(sel) ]  do
        InfoGraphicLattice1( "#I  Sylow-", p, "-Subgroup(",
                             sel[i].label.text, ") = ", 
                             new[i].label.text, "\n" );
    od;

end;


#############################################################################
##

#F  GraphicLatticeOps.CMAverageXLevels( ... ) . . . . .  common x coordinates
##
GraphicLatticeOps.CMAverageXLevels := function( sheet, menu, name )
    local   x,  strips,  selected,  obj,  diff,  ver;
    
    x := 0;
    strips   := [];
    selected := [];
    for obj  in sheet.selected  do
        if not obj.strip in strips  then
            x := x + obj.x;
            Add( strips, obj.strip );
            Add( selected, obj );
        fi;
    od;
    x := QuoInt( x, Length(selected) );
    for obj  in selected  do
        diff := x - obj.x;
        for ver  in obj.classRep.class do
            Move( ver, ver.x+diff, ver.y );
        od;
        sheet.operations.ToggleSelection( sheet, obj );
    od;
    
end;


#############################################################################
##
#F  GraphicLatticeOps.CMAverageYLevels( ... ) . . . . .  common y coordinates
##
GraphicLatticeOps.CMAverageYLevels := function( sheet, menu, name )
    local   i,  a,  n,  ver;
    
    for i  in [ 1 .. Length(sheet.strips) ]  do
        if 0 < Length(sheet.strips[i])  then

            # compute the average Y coordinate
            a := 0;
            n := 0;
            for ver  in  sheet.strips[i]  do
                if ver.isClassRep  then
                    a := a + ver.y;
                    n := n + 1;
                fi;
            od;
            a := QuoInt( a, n );

            # and move the vertices to this new coordinate
            for ver  in sheet.strips[i]  do
                Move( ver, ver.x, a );
            od;
        fi;
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.CMDeselectAll( ... )  . . . . .  deselected all objects
##
GraphicLatticeOps.CMDeselectAll := function( sheet, menu, name )
    sheet.operations.DeselectAll(sheet);
end;

                          
#############################################################################
##
#F  GraphicLatticeOps.CMRelabelVertices( ... )	. . . .  relabel the vertices
##
GraphicLatticeOps.CMRelabelVertices := function( sheet, menu, name )
    local   ver,  res;

    for ver in sheet.selected  do
        res := Query( sheet.operations.PDLabel, ver.label.text );
        if res = false  then
            return;
        fi;
        if 0 < Length(res)  then
            Relabel( ver, res );
        fi;
    od;    
end;


#############################################################################
##
#F  GraphicLatticeOps.CMRotateConjugates( ... ) . . . . . . . .  swap objects
##
GraphicLatticeOps.CMRotateConjugates := function( sheet, menu, name )
    local   classes,  class,  obj,  k,  oldx,  i;
    
    classes := [];
    for obj  in sheet.selected  do
        k := obj.ident[1];
        if not IsBound(classes[k])  then
            classes[k] := [];
        fi;
        Add( classes[k], obj );
    od;
    for class  in classes do
        if 1 < Length(class)  then
            oldx := class[1].x;
            for i  in [ 2 .. Length(class) ]  do
                Move( class[i-1], class[i].x, class[i].y );
            od;
            Move( class[Length(class)], oldx, class[1].y );
        fi;
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.CMSelectReps( ... ) . . . .  select all representatives
##
GraphicLatticeOps.CMSelectReps := function( sheet, menu, name )
    local   obj;

    # first deselect everything
    sheet.operations.DeselectAll(sheet);

    # now select all representatives
    for obj  in sheet.vertices  do
        if obj.isClassRep  then
            Add( sheet.selected, obj );
            sheet.operations.SelectObject( sheet, obj, true );
        fi;
    od;
    sheet.operations.UpdateMenus(sheet);

end;


#############################################################################
##
#F  GraphicLatticeOps.CMUseBlackWhite( ... )  use black&white instead of color
##
GraphicLatticeOps.CMUseBlackWhite := function( sheet, menu, name )
    local   obj;

    if sheet.color.model = "color"  then
        sheet.color.model := "monochrome";
        Check( sheet.cleanUpMenu, "Use Black&White" );
    else
        sheet.color.model := "color";
        Check( sheet.cleanUpMenu, "Use Black&White", false );
    fi;
    sheet.operations.MakeColors(sheet);
    for obj  in sheet.vertices  do
        sheet.operations.SelectObject( sheet, obj, false );
    od;
    for obj  in sheet.selected  do
        sheet.operations.SelectObject( sheet, obj, true );
    od;
    
end;


#F  # # # # # # # # # # # # # Information Functions # # # # # # # # # # # # #


#############################################################################
##

#F  GraphicLatticeOps.SIIndex( <sheet>, <ver>, <grp> )  . . . . . . . . index
##
GraphicLatticeOps.SIIndex := function( sheet, ver, grp )
    if not IsBound(ver.info.index)  then
        ver.info.index := Index( sheet.group, grp );
    fi;
    if ver.info.index < 20  then
        return String(ver.info.index);
    else
        return StringPP(ver.info.index);
    fi;
end;


#############################################################################
##
#F  GraphicLatticeOps.SIIsAbelian( <sheet>, <ver>, <grp> )  . . .  is abelian
##
GraphicLatticeOps.SIIsAbelian := function( sheet, ver, grp )
    if not IsBound(ver.info.isAbelian)  then
        ver.info.isAbelian := IsAbelian(grp);
    fi;
    if ver.info.isAbelian  then
        return "true";
    else
        return "false";
    fi;
end;


#############################################################################
##
#F  GraphicLatticeOps.SIIsCentral( <sheet>, <ver>, <grp> )  . . . .  isCentral
##
GraphicLatticeOps.SIIsCentral := function( sheet, ver, grp )
    if not IsBound(ver.info.isCentral)  then
        ver.info.isCentral := IsCentral( sheet.group, grp );
    fi;
    if ver.info.isCentral  then
        return "true";
    else
        return "false";
    fi;
end;


#############################################################################
##
#F  GraphicLatticeOps.SIIsCyclic( <sheet>, <ver>, <grp> ) . . . . .  is cyclic
##
GraphicLatticeOps.SIIsCyclic := function( sheet, ver, grp )
    if not IsBound(ver.info.isCyclic)  then
        ver.info.isCyclic := IsCyclic(grp);
    fi;
    if ver.info.isCyclic  then
        return "true";
    else
        return "false";
    fi;
end;


#############################################################################
##
#F  GraphicLatticeOps.SIIsNilpotent( <sheet>, <ver>, <grp> )  . . is nilpotent
##
GraphicLatticeOps.SIIsNilpotent := function( sheet, ver, grp )
    if not IsBound(ver.info.isNilpotent)  then
        ver.info.isNilpotent := IsNilpotent(grp);
    fi;
    if ver.info.isNilpotent  then
        return "true";
    else
        return "false";
    fi;
end;


#############################################################################
##
#F  GraphicLatticeOps.SIIsNormal( <sheet>, <ver>, <grp> )  . . . . . is normal
##
GraphicLatticeOps.SIIsNormal := function( sheet, ver, grp )
    if not IsBound(ver.info.isNormal)  then
        ver.info.isNormal := IsNormal(sheet.group, grp );
    fi;
    if ver.info.isNormal  then
        return "true";
    else
        return "false";
    fi;
end;


#############################################################################
##
#F  GraphicLatticeOps.SIIsPerfect( <sheet>, <ver>, <grp> ) . . . .  is perfect
##
GraphicLatticeOps.SIIsPerfect := function( sheet, ver, grp )
    if not IsBound(ver.info.isPerfect)  then
        ver.info.isPerfect := IsPerfect(grp);
    fi;
    if ver.info.isPerfect  then
        return "true";
    else
        return "false";
    fi;
end;


#############################################################################
##
#F  GraphicLatticeOps.SIIsSimple( <sheet>, <ver>, <grp> )  . . . . . is simple
##
GraphicLatticeOps.SIIsSimple := function( sheet, ver, grp )
    if not IsBound(ver.info.isSimple)  then
        ver.info.isSimple := IsSimple(grp);
    fi;
    if ver.info.isSimple  then
        return "true";
    else
        return "false";
    fi;
end;


#############################################################################
##
#F  GraphicLatticeOps.SIIsSolvable( <sheet>, <ver>, <grp> )  . . . is solvable
##
GraphicLatticeOps.SIIsSolvable := function( sheet, ver, grp )
    if not IsBound(ver.info.isSolvable)  then
        ver.info.isSolvable := IsSolvable(grp);
    fi;
    if ver.info.isSolvable  then
        return "true";
    else
        return "false";
    fi;
end;


#############################################################################
##
#F  GraphicLatticeOps.SIIsomorphism( <sheet>, <ver>, <grp> ) . . . . group id
##
GraphicLatticeOps.SIIsomorphism := function( sheet, ver, grp )
    if 100 < Size(grp)  then
        return "not computable";
    fi;
    if not IsBound(ver.info.groupId)  then
        ver.info.groupId := GroupId(grp);
    fi;
    if 0 = Length(ver.info.groupId.names)  then
        return Concatenation( String(ver.info.groupId.catalogue[1]), ".",
                              String(ver.info.groupId.catalogue[2]) );
    else
        return ver.info.groupId.names[1];
    fi;
end;


#############################################################################
##
#F  GraphicLatticeOps.SISize( <sheet>, <ver>, <grp> ) . . . . . . . . .  size
##
GraphicLatticeOps.SISize := function( sheet, ver, grp )
    if not IsBound(ver.info.size)  then
        ver.info.size := Size(grp);
    fi;
    if ver.info.size < 20  then
        return String(ver.info.size);
    else
        return StringPP(ver.info.size);
    fi;
end;

#F  GraphicLatticeOps.PMInformation( <sheet>, <obj> ) . . . . show group info
##
GraphicLatticeOps.PMInformation := function( sheet, obj )
    local   grp,  text,  info,  str,  i,  func1,  func2;
    
    # destroy other text selectors flying around
    if IsBound(sheet.selector)  then
        Close(sheet.selector);
    fi;
   
    # get the group of <obj>
    if not IsBound(obj.group)  then
        sheet.operations.SubgroupVertex( sheet, obj );
    fi;
    grp := obj.group;

    # construct info texts (text, record component, function)
    info := [
      [ "Size",        "size",        sheet.operations.SISize        ],
      [ "Index",       "index",       sheet.operations.SIIndex       ],
      [ "IsAbelian",   "isAbelian",   sheet.operations.SIIsAbelian   ],
      [ "IsCentral",   "isCentral",   sheet.operations.SIIsCentral   ],
      [ "IsCyclic",    "isCyclic",    sheet.operations.SIIsCyclic    ],
      [ "IsNilpotent", "isNilpotent", sheet.operations.SIIsNilpotent ],
      [ "IsNormal",    "isNormal",    sheet.operations.SIIsNormal    ],
      [ "IsPerfect",   "isPerfect",   sheet.operations.SIIsPerfect   ],
      [ "IsSimple",    "isSimple",    sheet.operations.SIIsSimple    ],
      [ "IsSolvable",  "isSolvable",  sheet.operations.SIIsSolvable  ],
      [ "Isomorphism", "groupId",     sheet.operations.SIIsomorphism ]
    ];
   
    # text select function
    func1 := function( sel, tid )
        tid  := sel.selected;
        text := Copy(sel.labels);
        str  := String( info[tid][1], -14 );
        Append( str, info[tid][3]( sheet, obj, grp ) );
        text[tid] := str;
        Relabel( sel, text );
    end;

    # construct the string
    text := [];
    if not IsBound(obj.info)  then
        obj.info := rec();
    fi;
    for i  in info  do
        str := String( i[1], -14 );
        if IsBound(obj.info.(i[2]))  then
            Append( str, i[3]( sheet, obj, grp ) );
        else
            Append( str, "unknown" );
        fi;
        Add( text, str );
        Add( text, func1 );
    od;

    # button select functions
    func1 := function( sel, bt )
        Close(sel);
        Unbind(sheet.selector);
    end;
    func2 := function( sel, bt )
        local   i;
        for i  in [ 1 .. Length(sel.labels) ]  do
            sel.selected := i;
            sel.textFuncs[i]( sel, sel.labels[i] );
        od;
        Enable( sel, "all", false );
    end;

    # construct text selector
    sheet.selector := TextSelector(
        Concatenation( " Information about ", obj.label.text ),
        text,
        [ "all", func2, "close", func1 ] );
               
end;


#############################################################################
##

#F  # # # # # # # # # # # # # # #  Popup Menus  # # # # # # # # # # # # # # #


#############################################################################
##

#F  GraphicLatticeOps.PMBottomMargin( <sheet>, <x>, <y> ) . set botton margin
##
GraphicLatticeOps.PMBottomMargin := function( sheet, x, y )
    local   z;
   
    # make sure that the window is not getting to small
    if y < 100  then
        return;
    fi;
    z := Maximum( List( sheet.vertices, x -> x.y ) );
    if y < z  then
        y := z;
    fi;

    # resize window
    sheet.operations.Resize( sheet, sheet.width, y );
    
end;


#############################################################################
##
#F  GraphicLatticeOps.PMLeftMargin( <sheet>, <x>, <y> ) . . . set left margin
##
GraphicLatticeOps.PMLeftMargin := function( sheet, x, y )
    local   obj,  d,  ver;
    
    # make sure that the window is not getting to small
    if x > sheet.width + 100  then
        return;
    fi;
    d := Minimum( List( sheet.vertices, x -> x.x ) );
    if d < x  then
        x := d;
    fi;

    # move all vertices to the left
    FastUpdate( sheet, true );
    for obj  in sheet.vertices  do
        if obj.isClassRep  then
            if obj.x - x < 0  then
                d := -obj.x;
            else
                d := -x;
            fi;
            for ver  in obj.class  do
                ver.operations.MoveDelta( ver, d, 0 );
            od;
        fi;
    od;
    FastUpdate( sheet, false );

    # resize window
    sheet.operations.Resize( sheet, sheet.width-x, sheet.height );
    
end;


#############################################################################
##
#F  GraphicLatticeOps.PMRightMargin( <sheet>, <x>, <y> )  .  set right margin
##
GraphicLatticeOps.PMRightMargin := function( sheet, x, y )
    local   z;
    
    # make sure that the window is not getting to small
    if x < 100  then
        return;
    fi;
    z := Maximum( List( sheet.vertices, x -> x.x ) );
    if x < z  then
        x := z;
    fi;

    # resize window
    sheet.operations.Resize( sheet, x, sheet.height );
    
end;


#############################################################################
##
#F  GraphicLatticeOps.PMTopMargin( <sheet>, <x>, <y> )  . . .  set top margin
##
GraphicLatticeOps.PMTopMargin := function( sheet, x, y )
    local   obj,  d,  ver;
    
    # make sure that the window is not getting to small
    if y > sheet.height + 100  then
        return;
    fi;
    d := Minimum( List( sheet.vertices, x -> x.y ) );
    if d < y  then
        y := d;
    fi;

    # move all vertices to the left
    FastUpdate( sheet, true );
    for obj  in sheet.vertices  do
        if obj.isClassRep  then
            if obj.y - y < 0  then
                d := -obj.y;
            else
                d := -y;
            fi;
            for ver  in obj.class  do
                ver.operations.MoveDelta( ver, 0, d );
            od;
        fi;
    od;
    FastUpdate( sheet, false );

    # resize window
    sheet.operations.Resize( sheet, sheet.width, sheet.height-y );
    
end;


#############################################################################
##

#V  GraphicLatticeOps.popupSheet  . . . . . . . . . .  popup menu for a sheet
##
GraphicLatticeOps.popupSheet := PopupMenu( "SHEET MENU", [
    "Left Margin", "Right Margin", "Top Margin", "Bottom Margin"
] );


#############################################################################
##
#F  GraphicLatticeOps.PopupSheet( <sheet>, <x>, <y> ) .  popup the sheet menu
##
GraphicLatticeOps.PopupSheet := function( sheet, x, y )
    local   res;

    res := Query( sheet.operations.popupSheet, sheet );
    if res <> false  then
        res := Concatenation( "PM", Filtered( res, x -> x <> ' ' ) );
        sheet.operations.(res)( sheet, x, y );
    fi;
end;


#############################################################################
##

#F  # # # # # # # # # # # # # #  Button Functions   # # # # # # # # # # # # #


#############################################################################
##

#F  GraphicLatticeOps.DragVertex( <sheet>, <obj>, <sft> )  drag/select vertex
##
GraphicLatticeOps.DragVertex := function( sheet, obj, sft )
    local    d1,  d2,  dx,  dy,  j,  oldx,  oldy,  moved,  c,  v,  seen;

    # the lower bound is the highest vertex in the strip below
    j := obj.strip-1;
    while 0 < j and 0 = Length(sheet.strips[j])  do
        j := j-1;
    od;
    if 0 = j  then
        d1 := sheet.height;
    else
        d1 := List(sheet.strips[j], v -> v.y);
        d1 := Minimum(d1) - VERTEX.diameter;
    fi;

    # the upper bound the lowest vertex in the strip above
    j := obj.strip+1;
    while j <= Length(sheet.strips) and 0 = Length(sheet.strips[j])  do
        j := j+1;
    od;
    if Length(sheet.strips) < j  then
        d2 := 0;
    else
        d2 := List(sheet.strips[j], v -> v.y);
        d2 := Maximum(d2) + VERTEX.diameter;
    fi;
            
    # drag representative
    oldx := obj.x;
    oldy := obj.y;
    FastUpdate( sheet, true );
    j := WcQueryPointer(sheet.id);
    c := 1;
    moved := false;
    Drag( sheet, j[1], j[2], BUTTONS.left, function( x, y )
        if 5 < AbsInt(oldx-x) or 5 < AbsInt(oldy-y)  then
            moved := true;
        fi;
        if y >= d1  then y := d1;  fi;
        if y <= d2  then y := d2;  fi;
        Move( obj, x, y );
        c := c mod 30 + 1;
        if c = 1  then
            FastUpdate( sheet, false );
            FastUpdate( sheet, true );
        fi;
    end );
            
    # select a vertex
    if not moved  then
        Move( obj, oldx, oldy );
        if sft  then
            sheet.operations.ToggleSelection( sheet, obj );
        else
            if 0 = Length(sheet.selected)  then
                sheet.operations.ToggleSelection( sheet, obj );
            elif 1=Length(sheet.selected) and obj=sheet.selected[1]  then
                sheet.operations.ToggleSelection( sheet, obj );
            else
                sheet.operations.DeselectAll(sheet);
                sheet.operations.ToggleSelection( sheet, obj );
            fi;
        fi;
        FastUpdate( sheet, false );
        return false;

    # move a class to a new position
    elif not sft  then
        dx := oldx - obj.x;
        for v  in obj.classRep.class  do
            if v <> obj  then
                Move( v, v.x - dx, obj.y );
            fi;
        od;
        FastUpdate( sheet, false );
        return true;

    # move selected subgroups to a new position
    else
        dx := oldx - obj.x;
        dy := oldy - obj.y;
        if oldy < obj.y  then
            Sort(sheet.selected, function(a,b) return a.strip<b.strip; end);
        else
            Sort(sheet.selected, function(a,b) return a.strip>b.strip; end);
        fi;

        # move a class to a new position
        for v  in obj.classRep.class  do
            if v <> obj  then
                Move( v, v.x - dx, obj.y );
            fi;
        od;
        seen := [ obj.classRep ];
        for v  in sheet.selected  do
            if not v.classRep in seen  then

                # the lower bound is the highest vertex in the strip below
                j := v.strip-1;
                while 0 < j and 0 = Length(sheet.strips[j])  do
                    j := j-1;
                od;
                if 0 = j  then
                    d1 := sheet.height;
                else
                    d1 := List(sheet.strips[j], v -> v.y);
                    d1 := Minimum(d1) - VERTEX.diameter;
                fi;

                # the upper bound the lowest vertex in the strip above
                j := v.strip+1;
                while j <= Length(sheet.strips) 
                      and 0 = Length(sheet.strips[j])
                do
                    j := j+1;
                od;
                if Length(sheet.strips) < j  then
                    d2 := 0;
                else
                    d2 := List( sheet.strips[j], v -> v.y );
                    d2 := Maximum(d2) + VERTEX.diameter;
                fi;

                # check the new position
                if v.y-dy < d2  then
                    c := d2;
                elif d1 < v.y-dy  then
                    c := d1;
                else
                    c := v.y-dy;
                fi;

                # moce class to a new position
                for j  in v.classRep.class  do
                    Move( j, j.x - dx, c );
                od;
                Add( seen, v.classRep );
            fi;
        od;
        FastUpdate( sheet, false );
        return true;
    fi;
end;


#############################################################################
##
#F  GraphicLatticeOps.DragBox( <sheet>, <x>, <y>, <sft> ) . . drag select box
##
GraphicLatticeOps.DragBox := function( sheet, x, y, sft )
    local   j,  b,  c,  x2,  y2,  obj;
            
    # drag an rectangle
    FastUpdate( sheet, true );
    b  := Rectangle( sheet, x, y, 1, 1 );
    c  := 1;
    Drag( sheet, x, y, BUTTONS.left, function( x0, y0 )
        x2 := x0;
        y2 := y0;
        Reshape( b, x0-x, y0-y );
        c := c mod 30 + 1;
        if c = 1  then
            FastUpdate( sheet, false );
            FastUpdate( sheet, true );
        fi;
    end );
    FastUpdate( sheet, false );
    Delete(b);

    # check impossible small rectangle
    if not IsBound(x2) or x = x2 or y = y2  then
        return;
    fi;

    # minimize <x> and <y>
    if x2 < x  then
        c := x;  x := x2;  x2 := c;
    fi;
    if y2 < y  then
        c := y;  y := y2;  y2 := c;
    fi;

    # deselect old vertices
    if not sft  then
        sheet.operations.DeselectAll(sheet);
    fi;

    # run through all vertices and select them if they lie inbetween
    for obj  in sheet.vertices  do
        if x <= obj.x and obj.x <= x2 and y <= obj.y and obj.y <= y2  then
            if not obj in sheet.selected  then
                sheet.operations.ToggleSelection( sheet, obj );
            fi;
        fi;
    od;

end;


#############################################################################
##
#F  GraphicLatticeOps.LeftButton( <sheet>, <x>, <y> ) . drag a representative
##
GraphicLatticeOps.LeftButton := function( sheet, x, y )
    local   pos,  obj,  res;
    
    pos := [x,y];
    for obj in sheet.objects do
        if IsBound(obj.isVertex) and obj.isVertex and pos in obj  then
            sheet.operations.DragVertex( sheet, obj, false );
            return;
        fi;
    od;
    return sheet.operations.DragBox( sheet, x, y, false );
end;


#############################################################################
##
#F  GraphicLatticeOps.ShiftLeftButton( <sheet>, <x>, <y> )  . . .  drag a rep
##
GraphicLatticeOps.ShiftLeftButton := function( sheet, x, y )
    local   pos,  obj,  res;
    
    pos := [x,y];
    for obj in sheet.objects do
        if IsBound(obj.isVertex) and obj.isVertex and pos in obj  then
            sheet.operations.DragVertex( sheet, obj, true );
            return;
        fi;
    od;
    return sheet.operations.DragBox( sheet, x, y, true );
end;


#############################################################################
##
#F  GraphicLatticeOps.RightButton( <sheet>, <x>, <y> ) show vertex/sheet menu
##
GraphicLatticeOps.RightButton := function( sheet, x, y )
    local   pos,  obj,  res;
  
    # check if the pointer is above a vertex
    pos := [x,y];
    for obj  in sheet.objects  do
        if IsBound(obj.isVertex) and obj.isVertex and pos in obj then 
            sheet.operations.PMInformation( sheet, obj );
            return;
        fi;
    od;
    sheet.operations.PopupSheet( sheet, x, y );
end;


#F  # # # # # # # #  Functions used for the Initial Setup   # # # # # # # # #


#############################################################################
##

#F  GraphicLatticeOps.MakeColors( <sheet> ) . .  colors for selected vertices
##
GraphicLatticeOps.MakeColors := function( sheet )

    if not IsBound(sheet.color)  then
        sheet.color := rec();
        if COLORS.red <> false or COLORS.lightGray <> false  then
            sheet.color.model := "color";
        else
            sheet.color.model := "monochrome";
        fi;
    fi;
    if sheet.color.model = "color"  then
        if COLORS.red <> false  then
            sheet.color.unselected := COLORS.black;
            sheet.color.selected   := COLORS.red;
        else
            sheet.color.unselected := COLORS.dimGray;
            sheet.color.selected   := COLORS.black;
        fi;
        if COLORS.green <> false  then
            sheet.color.result := COLORS.green;
        else
            sheet.color.result := COLORS.black; # COLORS.lightGray;
        fi;
    else
        sheet.color.selected   := COLORS.black;
        sheet.color.unselected := COLORS.black;
        sheet.color.result     := false;
    fi;

end;


#############################################################################
##
#F  GraphicLatticeOps.MakeConnections( <sheet> )  . . . .  create connections
##
GraphicLatticeOps.MakeConnections := function( sheet )
    local   i,  j,  k;
    
    for i  in [ 1 .. Length(sheet.init.vertices) ]  do
        for j  in sheet.init.vertices[i][3]  do
            k := PositionProperty( sheet.init.vertices, x -> x[1] = j );
            Connection( sheet.vertices[i], sheet.vertices[k] );
        od;
    od;
end;


###############################################################################
## 
#F  GraphicLatticeOps.MakeLattice( <sheet>, <grp> ) . .  compute full lattice
##
GraphicLatticeOps.MakeLattice := function( sheet, grp )
    sheet.lattice := Lattice(grp);
    sheet.classes := sheet.lattice.classes;
    sheet.representatives := List(sheet.lattice.classes,x->x.representative);
    sheet.init.classLengths := List( sheet.classes, Size );
    sheet.init.orderReps := List(sheet.representatives, Size );
    sheet.init.orders := Set(sheet.init.orderReps);
end;


#############################################################################
##
#F  GraphicLatticeOps.MakeMaximalSubgroups( <sheet> ) . . . . . . . . . local
##
GraphicLatticeOps.MakeMaximalSubgroups := function ( sheet )
    local   maxs,               # maximals (result)
            lat,                # lattice
            rel,                # maximal subgroup relation (for reps)
            sums,               # accumulated class lengths
            rep,                # representative of a class
            trn,                # transversal of normalizer of <rep>
            rep2,               # other representative
            nrm2,               # its normalizer
            trn2,               # its transversal
            max,                # maximal subgroups of <rep>
            reps,               # representatives of classes
            i, k, l;            # loop variables

    # get the maximals relation
    lat := sheet.lattice;
    rel := lat.operations.MaximalSubgroups( lat );

    # mapping from pairs to numbers    
    sums := [ 0 ];
    for i  in [2..Length(lat.classes)]  do
        sums[i] := sums[i-1] + Size( lat.classes[i-1] );
    od;

    # loop over the conjugacy classes
    maxs := [];
    reps := [];
    for i  in [ 1 .. Length(lat.classes) ]  do

        #N how do I do it without using 'Representative'?
        rep := lat.classes[i].representative;

        # enter the representative itself
        maxs[sums[i]+1] := [
            sums[i]+1,					    # unique number
            Size(rep),                                      # size
            Set(List(rel[i],pair->sums[pair[1]]+pair[2])),  # maximals
            i,                                              # class
            1                                               # pos in class
        ];
        Add( reps, maxs[sums[i]+1][1] );

        # loop over the conjugates
        trn := RightTransversal( lat.group, Normalizer( lat.group, rep ) );
        for k  in [ 2 .. Length(trn) ]  do

            # enter the conjugate
            maxs[sums[i]+k] := [
                sums[i]+k,
                Size(rep),
                [],
                i,
                k
            ];

            # find the conjugated maximals
            for max  in rel[i]  do

                #N how do I do it without using 'Representative'?
                rep2 := lat.classes[max[1]].representative;
                nrm2 := Normalizer( lat.group, rep2 );
                trn2 := RightTransversal( lat.group, nrm2 );
                l := 1;
                while not trn2[max[2]] * trn[k] / trn2[l] in nrm2  do
                    l := l + 1;
                od;
                AddSet( maxs[sums[i]+k][3], sums[max[1]]+l );
            od;

        od;

    od;

    # assign the result
    sheet.init.vertices := maxs;
    sheet.init.reps     := reps;
end;
 
 
#############################################################################
##
#F  GraphicLatticeOps.MakeMenus( <sheet> )  . . . . menus for a lattice sheet
##
GraphicLatticeOps.ResizeMenu := [
    "Double Lattice",       GraphicLatticeOps.RMDoubleLattice,
    "Halve Lattice",        GraphicLatticeOps.RMHalveLattice,
    "Resize Lattice",       GraphicLatticeOps.RMResizeLattice,
    ,                       Ignore,
    "Resize Graphic Sheet", GraphicLatticeOps.RMResizeGraphicSheet
];

GraphicLatticeOps.MakeMenus := function( sheet )
    local   tmp,  menu;

    # <updateMenus0> menus not available if no selection is made
    sheet.updateMenus0 := [];

    # <updateMenus1> menus not available if less than 2 selections are made
    sheet.updateMenus1 := [];

    # <updateMenus2> menus not available if less than 3 selections are made
    sheet.updateMenus2 := [];

    # <updateMenusEq1> menus available if 1 selection is made
    sheet.updateMenusEq1 := [];

    # create the resize menu
    Menu( sheet, "Resize", sheet.operations.ResizeMenu );

    # create the subgroup menu
    menu := Menu( sheet, "Subgroups",
        [ "Centralizers",         sheet.operations.SMCentralizers,
          "Centres",              sheet.operations.SMCentres,
          "Closure",              sheet.operations.SMClosure,
          "Closures",             sheet.operations.SMClosures,
          "Commutator Subgroups", sheet.operations.SMCommutatorSubgroups,
          "Cores",                sheet.operations.SMCores,
          "Derived Series",       sheet.operations.SMDerivedSeries,
          "Derived Subgroups",    sheet.operations.SMDerivedSubgroups,
          "Fitting Subgroups",    sheet.operations.SMFittingSubgroups,
          "Intersection",         sheet.operations.SMIntersection,
          "Intersections",        sheet.operations.SMIntersections,
          "Normalizers",          sheet.operations.SMNormalizers,
          "Normal Closures",      sheet.operations.SMNormalClosures,
          "Normal Subgroups",     sheet.operations.SMNormalSubgroups,
          "Sylow Subgroup",       sheet.operations.SMSylowSubgroups,
        ] );
    Add( sheet.updateMenus0, [ menu, [
         "Centres", "Derived Series", "Normalizers", "Normal Subgroups",
         "Derived Subgroups", "Centralizers", "Normal Closures",
         "Sylow Subgroup", "Fitting Subgroups", "Cores" ] ] );
    Add( sheet.updateMenus1, [ menu, [
         "Closure", "Intersection", "Commutator Subgroups" ] ] );
    Add( sheet.updateMenus2, [ menu, [
         "Closures", "Intersections" ] ] );

    # create the clean up menu
    tmp := [ "Average Y Levels",       	sheet.operations.CMAverageYLevels,
             "Average X Levels",        sheet.operations.CMAverageXLevels,
             "Rotate Conjugates",       sheet.operations.CMRotateConjugates,
             ,			        Ignore,
             "Deselect All",            sheet.operations.CMDeselectAll,
             "Relabel Vertices",        sheet.operations.CMRelabelVertices,
             "Select Representatives",  sheet.operations.CMSelectReps
    ];
    if sheet.color.model = "color"  then
        Append( tmp, [ , Ignore,
             "Use Black&White",         sheet.operations.CMUseBlackWhite ] );
    fi;
    sheet.cleanUpMenu := Menu( sheet, "CleanUp", tmp );
    Add( sheet.updateMenus0, [ sheet.cleanUpMenu, [
         "Deselect All", "Relabel Vertices" ] ] );
    Add( sheet.updateMenus1, [ sheet.cleanUpMenu, [
         "Average X Levels", "Rotate Conjugates" ] ] );

end;


#############################################################################
##
#F  GraphicLatticeOps.MakeVertices( <sheet> ) . . . . create list of vertices
##
GraphicLatticeOps.MakeVertices := function( sheet )
    local   i,  max,  v,  j;

    # collect vertices in <sheet.vertices>
    sheet.vertices := [];

    # collect vertices which lie in the same strip in <sheet.strips>
    sheet.strips := List( sheet.init.y, x -> [] );

    # loop over all vertices
    for i in [ 1 .. Length(sheet.init.vertices) ]  do
        max := sheet.init.vertices[i];
        j   := Position( sheet.init.orders, max[2] );

        # create a graphic vertex
        v := Vertex( sheet, sheet.init.x[i], sheet.init.y[j],
                     rec( label := String(max[1]),
                          color := sheet.color.unselected ) );

        # set its ident
        v.ident := sheet.init.vertices[i]{[4,5]};
        v.isClassRep := v.ident[2] = 1;

        # put vertex into the corresponding strip list
        v.strip := j;
        Add( sheet.strips[v.strip], v );

        # put vertex into the list of vertices
        sheet.vertices[i] := v;
    od;

    # for each representative construct its class
    for i  in sheet.vertices  do
        if i.isClassRep  then
            j := [i];
            i.class := j;
            i.classRep := i;
        else
            i.classRep := j[1];
            Add( j, i );
        fi;
    od;
            

end;


#############################################################################
##
#F  GraphicLatticeOps.MakeX( <sheet> )  . . . . . . . . .  make x coordinates
##
GraphicLatticeOps.MakeX := function( sheet )
    
    local   i,  j,  k,  l,	# loop variable
            ri,                 # local rows
            cl,                 # class length
            coor, coors,        # local x coordinate list
            x,                  # x coordinate
            n,                  # number of branches
            pos1,  pos2,        # positions
            noClasses,          # number of classes of a given order
            noElements,         # number of vertices of a given order
            tmp;
    
    # if the lattice is trivial (one or two vertices) return
    if Length(sheet.classes) <= 2 then
        sheet.init.x := [ QuoInt(sheet.width, 2), QuoInt(sheet.width, 2) ];
        return;
    fi;

    # count the number of classes of a given order
    noClasses := List( sheet.init.orders, x -> 
                       [ Number( sheet.init.orderReps, y->y=x ), x ] );

    # count the number of vertices of a given order
    noElements := List( sheet.init.orders, x ->
                        Number( sheet.init.vertices, y -> y[2] = x ) );

    # compute the layers <sheet>.l
    sheet.init.l := [];
    for i  in [ 1 .. Length(FactorsInt(Size(sheet.group))) ]  do
        sheet.init.l[i] := [];
    od;
    for i  in [ 2 .. Length(sheet.init.orderReps)-1 ]  do
        AddSet( sheet.init.l[Length(FactorsInt(sheet.init.orderReps[i])) ],
                sheet.init.orderReps[i] );
    od;
    sheet.init.l := Filtered( sheet.init.l, i -> 0 < Length(i) ); 
    
    # compute the branches <sheet>.b
    sheet.init.b := [];
    tmp := Maximum(List(sheet.init.l, x->Length(x)));
    for i in [ 1..tmp]  do
        sheet.init.b[i] := [];
        for j in [1..Length(sheet.init.l)] do
             if IsBound(sheet.init.l[j][i]) then
                 Add(sheet.init.b[i], sheet.init.l[j][i]);
             fi;
        od;
    od;
    sheet.init.b := Filtered( sheet.init.b, i -> 0 < Length(i) );
    
    # compute the row <sheet>.r of <sheet>.b and <sheet>.l
    sheet.init.r := [];
    ri  := [];
    for i  in [ 1 .. Length(sheet.init.l) ]  do
        for j  in [ 1 .. Length(sheet.init.b) ]  do
            tmp := Intersection( sheet.init.l[i], sheet.init.b[j] );
            if 0 < Length(tmp) then
                if Length(tmp) = 1 then
                    Add( ri, tmp );
                    Add( sheet.init.r, [ [i,j], tmp ] );
                else
                    for k  in [ 1 .. Length(tmp) ]  do
                        Add( ri, [tmp[k]] );
                        Add( sheet.init.r, [ [i,j], [tmp[k]] ] );
                    od;
                fi;
            fi;
        od;
    od;   
  
    # compute the x coordinates
    sheet.init.x := List( sheet.init.vertices, x -> 0 );
    sheet.init.x[1] := QuoInt( sheet.width, 2 );
    sheet.init.x[Length(sheet.init.vertices)] := QuoInt( sheet.width, 2 );
   
    # divide x axis
    n := Length(sheet.init.b);
    if n = 2  then
        coors := [ QuoInt(sheet.width,3), 2*QuoInt(sheet.width,3) ];
    else
        coors := [ QuoInt(sheet.width,2) ];
        for j  in [ 1 .. QuoInt(n+1,2)-1 ]  do
            Add( coors, QuoInt( (2*j-1)*sheet.width, 2*n ) );
        od;
        for j  in [ QuoInt(n+1,2)+1 .. n ]  do
            Add( coors, QuoInt( (2*j-1)*sheet.width, 2*n ) );
        od;
    fi;
    coor := [];
    for i  in [ 1 .. Length(sheet.init.b) ]  do
        for j in [ 1 .. Length(sheet.init.b[i]) ]  do
          pos1:=noElements[Position(sheet.init.orders,sheet.init.b[i][j])];
          pos2:=noClasses[Position(sheet.init.orders,sheet.init.b[i][j])][1];
          if 1 = Length(coors)
               and 1 < pos1
               and 2*VERTEX.diameter*pos1 < sheet.width
          then
              coor[ Position(ri,[sheet.init.b[i][j]]) ] :=
                QuoInt(sheet.width,2) - QuoInt(pos1+pos2-1,2)*VERTEX.diameter;
          elif   1 = Length(coors)
             and 1 < pos1
             and pos1 > sheet.width/(2*VERTEX.diameter) 
          then
              coor[ Position(ri,[sheet.init.b[i][j]]) ] :=
                QuoInt(sheet.width,2) - QuoInt(pos1,2) * VERTEX.diameter;
          elif 1 = pos1
             and j in [ 2..Length(sheet.init.b[i])-1 ]
             and noElements[Position(sheet.init.orders,sheet.init.b[i][j+1])]
                 =  1 
          then
              tmp := QuoInt(Maximum(noElements) + 1, 2);
              coor[ Position(ri,[sheet.init.b[i][j]]) ] := 
                coors[i] + (-1)^(j+1) * tmp * VERTEX.diameter;
          else
              coor[ Position(ri,[sheet.init.b[i][j]]) ] := coors[i];
          fi;
        od;
    od;
    for i  in [ 1.. Length(sheet.init.r) ]  do
        sheet.operations.MakeXFirstClass( sheet, coor, i );
    od;
    
    
    # set x coordinates of all other elements
    i := 1;
    while i < Length(sheet.init.vertices)  do
        if sheet.init.x[i] = 0  then
            if sheet.init.vertices[i-1][2] <= sheet.init.vertices[i][2]  then
                j := 1;
                while noClasses[j][2] <> sheet.init.vertices[i][2]  do
                    j := j + 1;
                od;
                if 2 * noElements[j] * VERTEX.diameter > sheet.width  then
                    sheet.init.x[i] := sheet.init.x[i-1] + VERTEX.diameter;  
                else
                    sheet.init.x[i] := sheet.init.x[i-1] + 2*VERTEX.diameter;
                fi;
                if     sheet.init.x[i] > sheet.width
                   and sheet.init.vertices[i][1] in sheet.init.reps
                then
                    sheet.init.x[i] := VERTEX.diameter;
                fi;
                cl := sheet.init.classLengths[sheet.init.vertices[i][4]];
                i  := i + 1;
                j  := 1;
                x  := sheet.init.x[i-1]; 
                while j < cl  do
                    sheet.init.x[i] := x + VERTEX.diameter * j;
                    j := j + 1;
                    i := i + 1;
                od;
            else
                Error();
            fi;
        else
            i := i + 1;
        fi;
    od;
end;    
    

#############################################################################
##
#F  GraphicLatticeOps.MakeXFirstClass( <sheet>, <xs>, <n> ) coors of 1. class
##
GraphicLatticeOps.MakeXFirstClass := function( sheet, xs, n )
    local  i,  j,  max,  x;
    
    i := PositionProperty( [ 1 .. Length(sheet.init.vertices) ], 
                 x -> sheet.init.vertices[x][2] = sheet.init.r[n][2][1] );
    max := sheet.init.classLengths[sheet.init.vertices[i][4]];
    if 1 < Length(sheet.init.b)  then
        x := xs[n] - Int(max/2) * VERTEX.diameter; 
        if x < 0 then
            x := 0;
        fi;
    else
        x := xs[n];
    fi;
    j := 0;
    while j < max do
        if sheet.init.x[i+j] = 0  then
            sheet.init.x[i+j] := x + VERTEX.diameter*j;
        fi;
        j := j+1;
    od;
end;
    

#############################################################################
##
#F  GraphicLatticeOps.MakeY( <sheet> )  . . . . . . . . .  make y-coordinates
##
GraphicLatticeOps.MakeY := function( sheet ) 
    local    L,  M;
       
    L := Length(sheet.init.orders);
    M := QuoInt(sheet.height-2*VERTEX.diameter,L);
    sheet.init.y := Reversed( Set( List( [1..L], i -> M*i ) ) );
end;

    
#############################################################################
##
#F  GraphicLatticeOps.SortMaximals( <sheet> ) . . . . . . . sort the maximals
##
GraphicLatticeOps.SortMaximals := function( sheet )
    local   max,  i,  j,  min,  classes,  class,  L,  S1,  k,  l;
    
    # <classes> contains the triple size, class number, no of minimals
    classes := [];
    for i  in [ 1 .. Length(sheet.init.reps) ]  do
        min := 0;
        for j  in [ 1 .. Length(sheet.init.vertices) ]  do
            if sheet.init.reps[i] in sheet.init.vertices[j][3]  then
                min := min+1;
            fi;
        od;
        class:=First(sheet.init.vertices,y->y[1]=sheet.init.reps[i]){[2,4]};
        Add( class, min );
        Add( classes, class );
    od;
 
    # group <classes> together according to their sizes
    L := [];
    for i  in Set( List( classes, x -> x[1] ) )  do
        class := Filtered( classes, x -> x[1] = i );
        Sort( class, function(a,b) return a[3] < b[3]; end );
        Add( L, class );
    od;
    Sort( L, function(a,b) return a[1] < b[1]; end );

    # put the vertices with many connections nearer to the middle
    S1 := List( L, x -> [] );
    for i  in [ 1 .. Length(L) ]  do
        k := 0;
        l := 0;
        for j in  [ 1 .. Length(L[i]) ]  do
            if j mod 2 = 1  then
                S1[i][Length(L[i])-k] := L[i][j];
                k := k + 1;
            else
                S1[i][l+1] := L[i][j];
                l := l + 1;
            fi;
        od;      
    od;
    
    # sort <sheet>.init.vertices according to <S1>
    max := [];
    for i  in S1  do
        for j  in i  do
            L := Filtered( sheet.init.vertices, x -> x[4] = j[2] );
            Sort( L, function(a,b) return a[5] < b[5]; end );
            if not IsRange(List(L,x->x[5])) or L[1][5] <> 1  then
                Error( "class ", L[1][4], " corrupted" );
            fi;
            Append( max, L );
        od;
    od;
    sheet.init.vertices := max;

end;


#F  # # # # Functions used for the Initial Setup (NormalSubgroups)  # # # # #


#############################################################################
##

#V  NormalGraphicLatticeOps . . . . . . . . . operations for normal subgroups
##
NormalGraphicLatticeOps := OperationsRecord(
    "NormalGraphicLatticeOps", GraphicLatticeOps );


#############################################################################
##
#F  NormalGraphicLatticeOps.MakeMenus( <sheet> )  . menus for a lattice sheet
##
NormalGraphicLatticeOps.MakeMenus := function( sheet )
    local   tmp,  menu;

    # <updateMenus0> menus not available if no selection is made
    sheet.updateMenus0 := [];

    # <updateMenus1> menus not available if less than 2 selections are made
    sheet.updateMenus1 := [];

    # <updateMenus2> menus not available if less than 3 selections are made
    sheet.updateMenus2 := [];
 
    # <updateMenusEq1> menus available if 1 selection is made
    sheet.updateMenusEq1 := [];

    # create the resize menu
    Menu( sheet, "Resize", sheet.operations.ResizeMenu );

    # create the subgroup menu
    menu := Menu( sheet, "Subgroups",
        [ "Centralizers",         sheet.operations.SMCentralizers,
          "Centres", 	          sheet.operations.SMCentres,
          "Closure",              sheet.operations.SMClosure,
          "Closures",             sheet.operations.SMClosures,
          "Commutator Subgroups", sheet.operations.SMCommutatorSubgroups,
          "Derived Series",       sheet.operations.SMDerivedSeries,
          "Derived Subgroups",    sheet.operations.SMDerivedSubgroups,
          "Fitting Subgroups",    sheet.operations.SMFittingSubgroups,
          "Intersection",         sheet.operations.SMIntersection,
          "Intersections",        sheet.operations.SMIntersections,
          "Sylow Subgroup",       sheet.operations.SMSylowSubgroups,
        ] );
    Add( sheet.updateMenus0, [ menu, [
         "Centres", "Derived Series", "Derived Subgroups",
         "Centralizers", "Sylow Subgroup", "Fitting Subgroups" ] ] );
    Add( sheet.updateMenus1, [ menu, [
         "Closure", "Intersection", "Commutator Subgroups" ] ] );
    Add( sheet.updateMenus2, [ menu, [
         "Closures", "Intersections" ] ] );

    # create the clean up menu
    tmp := [ "Average Y Levels",       	sheet.operations.CMAverageYLevels,
             "Average X Levels",        sheet.operations.CMAverageXLevels,
             ,			        Ignore,
             "Deselect All",            sheet.operations.CMDeselectAll,
             "Relabel Vertices",        sheet.operations.CMRelabelVertices,
             "Select Representatives",  sheet.operations.CMSelectReps,
    ];
    if sheet.color.model = "color"  then
        Append( tmp, [ , Ignore,
             "Use Black&White",         sheet.operations.CMUseBlackWhite ] );
    fi;
    sheet.cleanUpMenu := Menu( sheet, "CleanUp", tmp );
    Add( sheet.updateMenus0, [ sheet.cleanUpMenu, [
         "Deselect All", "Relabel Vertices" ] ] );
    Add( sheet.updateMenus1, [ sheet.cleanUpMenu, [
         "Average X Levels" ] ] );

end;


#############################################################################
##
#F  NormalGraphicLatticeOps.MakeLattice( <sheet>, <grp> ) .  normal subgroups
##
NormalGraphicLatticeOps.MakeLattice := function( sheet, grp )
    sheet.representatives := NormalSubgroups(grp);
    sheet.classes := List( sheet.representatives,
                           x -> ConjugacyClassSubgroups( grp, x ) );
    sheet.init.classLengths := List( sheet.classes, x -> 1 );
    sheet.init.orderReps := List( sheet.representatives, Size );
    sheet.init.orders := Set(sheet.init.orderReps);
    sheet.init.reps := [ 1 .. Length(sheet.classes) ];
end;


#############################################################################
##
#F  NormalGraphicLatticeOps.MakeMaximalSubgroups( <sheet> ) . . . . . . local
##
NormalGraphicLatticeOps.MakeMaximalSubgroups := function( sheet )
    local   maximals,  inclusions,  i,  j;
    
    # compute the maximal subgroups
    maximals   := List( sheet.classes, x -> [] );
    inclusions := List( sheet.classes, x -> [] );
    for i  in [ 1 .. Length(sheet.classes) ]  do
        for j  in [ i, i-1 .. 1 ]  do
            if not j in inclusions[i]  then
                if IsSubgroup( sheet.representatives[i],
                               sheet.representatives[j] )
                then
                    AddSet( maximals[i], j );
                    AddSet( inclusions[i], j );
                    UniteSet( inclusions[i], inclusions[j] );
                fi;
            fi;
        od;
    od;
    sheet.init.vertices := List( [ 1 .. Length(maximals) ],
            x -> [ x, Size(sheet.representatives[x]), maximals[x], x, 1 ] );
end;


#F  # # # # # # # # # # # # #  the main functions   # # # # # # # # # # # # #


#############################################################################
##

#F  GraphicLattice( <G>, <x>, <y> )  . . . . . . . . . . .  display a lattice
##
GraphicLattice := function( arg )

    if IsGroup(arg[1])  then
        return ApplyFunc( GroupOps.GraphicLattice, arg );
    else
        return ApplyFunc( GraphicLatticeRecord, arg );
    fi;

end;


#############################################################################
##
#F  GroupOps.GraphicLattice( <G>, <x>, <y> ) . . . display a subgroup lattice
##
GroupOps.GraphicLattice := function( arg )
    local   G,  S,  i,  j,  tmp,  def,  match;
    
    # we need at least one argument: the group
    if Length(arg) < 1  then
        Error( "usage: GraphicLattice( <G>[, <x>, <y>][, \"prime\"] )" );
    fi;
    G := arg[1];
    
    # match a substring
    match := function( b, a )
        local   c;
        c := Minimum(Length(a),Length(b));
        return a{[1..c]} = b{[1..c]};
    end;

    # parse the other argument: <x>, <y> or "prime" or "normal subgroups"
    def := rec( prime := false, normal := false, x := 800, y := 600 );
    i := 2;
    while i <= Length(arg)  do
        if IsInt(arg[i])  then
            def.x := arg[i];
            def.y := arg[i+1];
            i := i+2;
        elif IsString(arg[i])  then
            if match( arg[i], "prime" )  then
                def.prime := true;
            elif match( arg[i], "Prime" )  then
                def.prime := true;
            elif match( arg[i], "normal subgroups" )  then
                def.normal := true;
            elif match( arg[i], "normalsubgroups" )  then
                def.normal := true;
            elif match( arg[i], "Normal Subgroups" )  then
                def.normal := true;
            elif match( arg[i], "title" )  then
                def.title := arg[i];
            elif match( arg[i], "Title" )  then
                def.title := arg[i];
            else
                Error( "unkown option \"", arg[i], "\",\n",
                       "options are: \"normal subgroups\", \"prime\", ",
                       "\"title\"" );
            fi;
            i := i+1;
        else
            Error( "unkown option ", arg[i] );
        fi;
    od;

    # construct a nice title
    if not IsBound(def.title)  then
        if def.normal  then
            if IsBound(G.name)  then
                def.title := Concatenation( "Normal Subgroups of ", G.name );
            else
                def.title := "Normal Subgroups Lattice";
            fi;
        else
            if IsBound(G.name)  then
                def.title := Concatenation( "Subgroup Lattice of ", G.name );
            else
                def.title := "Subgroup Lattice";
            fi;
        fi;
    fi;

    # open a graphic sheet
    S := GraphicSheet( def.title, def.x, def.y );
    S.defaultTitle := def.title;
    S.close := function(S)
        if IsBound(S.selector)  then
            Close(S.selector);
        fi;
    end;

    # store group in <S>
    S.group := G;
    S.super := G;
      
    # <S>.init holds valueable information for the initial setup
    S.init := rec();
    S.init.primeOrdering  := def.prime;

    # change ops for normal subgroup lattice
    if def.normal  then
        S.operations := NormalGraphicLatticeOps;
    else
        S.operations := GraphicLatticeOps;
    fi;

    # select a color model
    S.operations.MakeColors(S);
    
    # no objects are selected at first
    S.selected := [];
        
    # compute the lattice of <G>
    SetTitle( S, "Computing Lattice" );
    S.operations.MakeLattice( S, G );
    
    # sort orders according to the number of factors
    if S.init.primeOrdering  then
        Sort( S.init.orders, function(a,b)
              local la, lb;
              la := Length(Factors(a));
              lb := Length(Factors(b));
              if la = lb  then
                  return a < b;
              else
                  return la < lb;
              fi;
        end );
    fi;

    # construct the maximal subgroups
    SetTitle( S, "Computing Maximal Subgroups" );
    S.operations.MakeMaximalSubgroups(S);
    S.operations.SortMaximals(S);

    # compute the x-coordinates
    SetTitle( S, "Computing Coordinates" );
    S.operations.MakeX(S);
      
    # compute the y-coordinates
    S.operations.MakeY(S);
    
    # draw lattice
    SetTitle( S, "Drawing" );
    S.operations.MakeVertices(S);
    S.operations.MakeConnections(S);

    # and unbind unused information
    Unbind(S.init);
    
    # add pointer actions to <S>
    InstallGSMethod( S, "LeftPBDown",      S.operations.LeftButton      );
    InstallGSMethod( S, "RightPBDown",     S.operations.RightButton     );
    InstallGSMethod( S, "ShiftLeftPBDown", S.operations.ShiftLeftButton );
    InstallGSMethod( S, "CtrlLeftPBDown",  S.operations.ShiftLeftButton );
    
    # create menus
    S.operations.MakeMenus(S);

    # and enable/disable entries
    S.operations.UpdateMenus(S);

    # reset the title
    SetTitle( S, S.defaultTitle );

    # that's it
    return S;

end;
