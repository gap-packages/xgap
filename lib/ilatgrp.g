#############################################################################
##
#A  ilatgrp.g                 	XGAP library               Susanne Keitemeier
##
#H  @(#)$Id: ilatgrp.g,v 1.1 1997/11/27 12:19:58 frank Exp $
##
#Y  Copyright (C) 1995,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##
##  This   file contains the  interactive   lattice  program.  The  following
##  functions are implemented:
##
##  'InteractiveLattice( <group>[, <x>, <y>] )
##  -----------------------------------------------------------------------
##
##  'InteractiveLattice'  displays  a partial lattice  in  a graphic sheet of
##  dimension width <x> and height <y>.
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
##  all components mentioned in "glatgrp.g"
##
##  'super':
##    the  group  which is  the   first  argument for 'Centralizer',  'Core',
##    'Normalizer', 'NormalClosure'
##
##  'limits':
##    a record containing the following limits:
##
##      'conjugates':
##        If a new subgroup is  inserted for all  vertex of the same size, it
##        is checked  if they are conjugated to  the  new subgroup.  However,
##        this check  is not done if   there are more then  'conjugates' many
##        conjugates.
##
##  A vertex from 'vertices' is a record with the following components:
##  -------------------------------------------------------------------
##
##  'class':
##    if  'isClassRep'  is 'true' then  'class' contains  a list  of vertices
##    describing the class seen so far.
##
##  'classRep':
##    if 'isClassRep' is 'false' this the vertex of the representative
##
##  'conjugates':
##    for  a  representative  'conjugates' holds  a list  of   all conjugated
##    subgroups (that is the conjugacy classes in the group <sheet.group>)
##
##  'group':
##    the subgroup of this vertex
##
##  'ident':
##    a  pair  '[<c>,<i>]', where <c> is   number of the  class (according to
##    <sheet>.classes) in which  the subgroup of  this vertex lies and <i> is
##    the    position of    the  subgroup   in   this   classes.   See   also
##    'SubgroupVertex' and 'VertexSubgroup'.
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
#H  $Log: ilatgrp.g,v $
#H  Revision 1.1  1997/11/27 12:19:58  frank
#H  added 3.5 library (does not work with 4.0)
#H
#H  Revision 1.9  1996/06/07  16:01:30  fceller
#H  added 'Overgroups' (ahulpke)
#H
#H  Revision 1.8  1995/09/25  08:12:23  fceller
#H  remove read statment, this is now done by calling 'InteractiveFpLattice'
#H
#H  Revision 1.7  1995/09/24  14:35:17  fceller
#H  fixed a problem with 'match'
#H
#H  Revision 1.6  1995/08/09  10:54:36  fceller
#H  fixed various things (too much too mention but all were minor)
#H
#H  Revision 1.5  1995/07/28  10:02:23  fceller
#H  changed "black&white" to "monochrome"
#H  changed some of the names of the menu entries
#H  some speedup in 'MakeConnections'
#H
#H  Revision 1.4  1995/07/24  10:01:24  fceller
#H  changed select mechanism
#H
#H  Revision 1.3  1995/05/29  14:37:13  fceller
#H  added nicer X position for 'Select'
#H
#H  Revision 1.2  1995/02/16  20:46:15  fceller
#H  changed diamond to rectangle
#H
#H  Revision 1.1  1995/02/10  14:52:14  fceller
#H  Initial revision
##


#F  # # # # # # # # # # #  Internal Functions   # # # # # # # # # # # # # # #


#############################################################################
##

#V  InteractiveLatticeOps. . . . . . . . . . . . . . . . .  operations record
##
InteractiveLatticeOps := OperationsRecord(
    "InteractiveLatticeOps", GraphicLatticeOps );


#############################################################################
##
#F  InteractiveLatticeOps.InsertConjugate( <sheet>, <rep>, <grp> )   new conj
##
InteractiveLatticeOps.InsertConjugate := function( sheet, rep, grp )
    local    v,                   # the new vertex
             x,                   # x coordinate of the new vertex
             i;                   # loop variable

    # compute the <x> position of the new class element
    x := Maximum( List( rep.classRep.class, v -> v.x ) ) + VERTEX.diameter;

    # create a new vertex
    v := Vertex( sheet, x, rep.y );
    Relabel( v, String(Length(sheet.vertices)+1) ); 

    # set the (class) information
    v.isClassRep := false;
    v.classRep   := rep.classRep;
    v.group      := grp;
    v.ident      := [ rep.ident[1], Length(rep.classRep.class)+1 ];
    v.info       := rec(size := Size(grp), index := Index(sheet.group,grp));

    # compute the strip number
    i := PositionProperty( sheet.yCoors, x -> x[1] = Size(grp) );
    Add( sheet.strips[i], v );
    v.strip := i;

    # add vertex to our list of vertices
    Add( sheet.vertices, v );

    # update the class stored in the representative
    Add( rep.classRep.class, v );

    # update maximals subgroups and connections
    v.maximals := [];

    return v;

end;


#############################################################################
##
#F  InteractiveLatticeOps.InsertRep( <sheet> , <grp>, <x> ) . .  insert a rep
##
InteractiveLatticeOps.InsertRep := function( sheet, grp, x )

    local i, j,                   # loop variables
          max,
          size,                   # the size of <grp>
          y0, y1,                 # upper/lower bound of strips above/below
          v;                      # new vertex

    # find new <y> position
    size := Size(grp);
    i := PositionProperty( sheet.yCoors, x -> x[1] = size );
    j := i;
    while 1 < j and 0 = Length(sheet.strips[j])  do
        j := j-1;
    od;
    y0 := Maximum( List( sheet.strips[j], t -> t.y ) );
    j := i;
    while j < Length(sheet.strips) and 0 = Length(sheet.strips[j])  do
        j := j+1;
    od;
    y1 := Minimum( List( sheet.strips[j], t -> t.y ) );

    # create a new vertex
    v := Vertex( sheet, x, QuoInt(y0+y1,2) );
    Relabel( v, String(Length(sheet.vertices)+1) ); 

    # set the (class) information
    v.isClassRep := true;
    v.classRep   := v;
    v.group      := grp; 
    v.class      := [v];
    v.info       := rec(size := Size(grp), index := Index(sheet.group,grp));

    # find the next class number
    max     := Maximum( List( sheet.vertices, x -> x.ident[1] ) ) + 1;
    v.ident := [ max, 1 ];

    # compute the strip number
    Add( sheet.strips[i], v );
    v.strip := PositionProperty( sheet.yCoors, x -> x[1] = size );

    # add vertex to our list of vertices
    Add( sheet.vertices, v ); 

    # update maximals subgroups and connections
    v.maximals := [];
    sheet.operations.MakeMaximalSubgroups(sheet);
    sheet.operations.MakeConnections( sheet, v );

    return v;

end;


#############################################################################
##
#F  InteractiveLatticeOps.InsertVertex( <sheet>, <grp>, <x> ) . .  insert new
##
##  check, if the  new  subgroup is a   new  representative or a   conjugated
##  subgroup, this function   is  used in the  functions   which compute  new
##  subgroups.
##
InteractiveLatticeOps.InsertVertex := function( sheet, grp, x )
    local   size,  vers,  sgin,  lim,  cc,  k,  s;

    # check if we already know the group
    if ForAny( sheet.vertices, x -> x.group = grp )  then
        return;
    fi;

    # find class representatives of the same size
    size := Size(grp);
    vers := Filtered(sheet.vertices,x->x.isClassRep and Size(x.group)=size);

    # do we want to check conjugates
    if 0 = Length(vers)  then
        sgin := true;
    else
        lim := sheet.limits.conjugates;
        s   := sheet.group;

        # <grp> has few enough conjugates (XXX do it better/faster)
        sgin := false;
        if 0 < lim and Index( sheet.group, grp ) < lim  then
            sgin := true;
        elif 0 < lim and Index( s, Normalizer( s, grp ) ) < lim  then
            sgin := true;
        elif lim < 0 and Index( sheet.group, grp ) < -lim  then
            sgin := true;
        fi;
        if sgin = true  then
            cc := ConjugateSubgroups( sheet.group, grp );
            for k  in vers  do
                if sgin = true and k.group in cc  then
                    sgin := k;
                fi;
            od;
        fi;
    fi;

    # insert a new representative at position <x>
    if sgin = true then
        return sheet.operations.InsertRep( sheet, grp, x );

    # insert a (possible) new representative at position <x>
    elif sgin = false  then
        k := sheet.operations.InsertRep( sheet, grp, x );
        Reshape( k, VERTEX.rectangle );
        return k;

    # insert a new conjugate at position <x>
    else
        k := sheet.operations.InsertConjugate( sheet, sgin, grp );
        sheet.operations.MakeMaximalSubgroups( sheet );
        sheet.operations.MakeConnections( sheet, k );
        return k;
    fi;
end;


#############################################################################
##
#F  InteractiveLatticeOps.NewXPosition( <sheet>, <strip> )  . x-pos in <strip>
##
InteractiveLatticeOps.NewXPosition := function( sheet, strip )
    local   l,  r,  v,  p;

    # create a list of possible position
    l := [ 1 .. QuoInt(sheet.width,VERTEX.diameter) ];
    r := [ 1 .. QuoInt(sheet.width,VERTEX.diameter) ];
    for v  in sheet.strips[strip]  do
        p := QuoInt(v.y,VERTEX.diameter);
        if v.isClassRep  then
            RemoveSet( r, p );
        fi;
        RemoveSet( l, p );
    od;
    if 0 < Length(l)  then
        return VERTEX.diameter*Random(l);
    elif 0 < Length(r)  then
        return VERTEX.diameter*Random(r);
    else
        return Random( [ 1 .. sheet.width ] );
    fi;
        
end;


#############################################################################
##
#F  InteractiveLatticeOps.Print( <sheet> ) . . . . . . . . .  pretty printing
##
InteractiveLatticeOps.Print := function( sheet )
    Print( "<interactive graphic lattice>" );
end;
  
  
#############################################################################
##
#F  InteractiveLatticeOps.Select( <sheet>, <list> )  . .  select given groups
##
InteractiveLatticeOps.Select := function( sheet, l )

    local   size,         # size of the group to be inserted
            i,            # strip of the group
            x,            # and the x position itself
            u,            # loop variables
            c,            # the found group
            nos;          # list with the found numbers

    # deselect all groups
    sheet.operations.DeselectAll(sheet);

    # find subgroups
    nos := [];
    for u  in l  do
        c := PositionProperty( sheet.vertices, x -> x.group = u );
        if c = false  then
            size := Size(u);
            i := PositionProperty( sheet.yCoors, x -> x[1] = size );
            x := sheet.operations.NewXPosition( sheet, i );
            c := sheet.operations.InsertVertex( sheet, u, x );
        else
            c := sheet.vertices[c];
        fi;
        Add( nos, c );
    od;

    # and highlight these groups
    for i  in  nos  do
        sheet.operations.ToggleSelection( sheet, i );
    od;

    # and return a list of numbers
    return nos;

end;

  
#############################################################################
##
#F  InteractiveLatticeOps.ShowResult( <sheet>, <old>, <new>, <x> )  .  result
##
InteractiveLatticeOps.ShowResult := function( sheet, old, new, x )
    local   i,  ver;

    # deselect all vertices
    sheet.operations.DeselectAll(sheet);

    # insert the new subgroup
    for i  in [ 1 .. Length(new) ]  do
        sheet.operations.InsertVertex( sheet, new[i], x[i] );
    od;

    # find the vertices corresponding to <old> and <new>
    old := List( old, x -> First( sheet.vertices, y -> y.group = x ) );
    new := List( new, x -> First( sheet.vertices, y -> y.group = x ) );

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

    # and return the new vertices
    return new;

end;


#############################################################################
##
#F  InteractiveLatticeOps.SubgroupVertex( <sheet>, <ver> )  . . . .  subgroup
##
InteractiveLatticeOps.SubgroupVertex := function( sheet, ver )
    return ver.group;
end;


#############################################################################
##
#F  InteractiveLatticeOps.MergeClasses( <sheet>, <v1>, <v2> ) merge <v1>/<v2>
##
InteractiveLatticeOps.MergeClasses := function( sheet, v1, v2 )
    local   tmp,  x1,  x2,  dx,  dy,  v;

    # find representatives
    if not v1.isClassRep  then v1 := v1.classRep;  fi;
    if not v2.isClassRep  then v2 := v2.classRep;  fi;
    if v1 = v2  then return v1;  fi;

    # the longer class will survive
    if Length(v1.class) < Length(v2.class)  then
        tmp := v1;  v1 := v2;  v2 := tmp;
    fi;

    # find new position
    x1 := Maximum( List( v1.class, t -> t.x ) ) + VERTEX.diameter;
    x2 := Minimum( List( v2.class, t -> t.x ) );
    dx := x1-x2;
    dy := v1.y-v2.y;

    # move class of <v2>
    for v  in v2.class  do
        v.operations.MoveDelta( v, dx, dy );
    od;

    # update classes
    v2.isClassRep := false;
    for v  in v2.class  do
        Add( v1.class, v );
        v.ident    := [ v1.ident[1], Length(v1.class) ];
        v.classRep := v1;
    od;
    Unbind(v2.class);

    # reshape the old representative
    Reshape( v2, VERTEX.circle );

    # check if there is only one class left
    tmp := Size(v1.group);
    tmp := Filtered(sheet.vertices,x->x.isClassRep and Size(x.group)=tmp);
    if 1 = Length(tmp)  then
        Reshape( v1, VERTEX.circle );
    fi;

    return v1;

end;


#F  # # # # # # # # # # # # # # #  Menus  # # # # # # # # # # # # # # # # # #


#############################################################################
##

#F  InteractiveLatticeOps.SMConjugateSubgroups( ... ) . conj subgrp of groups
##
InteractiveLatticeOps.SMConjugateSubgroups := function( sheet, menu, name )
    local   selected,  new,  ver,  cc,  grp,  pos,  lst,  seen;

    # it might take a while
    SetTitle( sheet, "Computing Conjugates" );

    # compute all conjugate subgroups
    selected := ShallowCopy(sheet.selected);
    sheet.operations.DeselectAll(sheet);
    lst  := [];
    seen := [];
    for ver  in  selected  do
        if not ver.classRep in seen  then
            ver := ver.classRep;
            Add( seen, ver );
            InfoGraphicLattice1( "#I  ConjugateSubgroups(",
                                 ver.label.text, ") = " );

            # compute the conjugate subgroups under the op of super
            if sheet.super = sheet.group  then
                if not IsBound(ver.conjugates)  then
                    cc := ConjugateSubgroups( sheet.group, ver.group );
                    ver.conjugates := cc;
                fi;
                cc := ver.conjugates;
            else
                cc:=ConjugateSubgroups( sheet.super, ver.group );
            fi;

            # insert conjugates step by step
            FastUpdate( sheet, true );
            for grp  in Filtered( cc, x -> x <> ver.group )  do
                pos := PositionProperty( sheet.vertices, x -> x.group=grp );

                # insert new found representatives
                if pos = false  then
                    new := sheet.operations.InsertConjugate(sheet,ver,grp);

                # merge classes
                else
                    new := sheet.vertices[pos];
                    new := sheet.operations.MergeClasses( sheet, ver, new );
                fi;
                Add( lst, new );
                InfoGraphicLattice1( new.label.text, " " );
            od;
            InfoGraphicLattice1( "\n" );

            # select the new conjugate subgroups
            for grp   in ver.classRep.class  do
                if not grp in sheet.selected  then
                    sheet.operations.ToggleSelection( sheet, grp );
                    if sheet.color.result <> false  then
                        Recolor( grp, sheet.color.result );
                    fi;
                fi;
            od;

            FastUpdate( sheet, false );
        fi;
    od;
    sheet.operations.MakeMaximalSubgroups( sheet );
    for ver  in lst  do
        sheet.operations.MakeConnections( sheet, ver );
    od;

    # restore the default title
    SetTitle( sheet, sheet.defaultTitle );

end;


#############################################################################
##
#F  InteractiveLatticeOps.SMRandomConjugates( ... ) .  random conjs of groups
##
InteractiveLatticeOps.SMRandomConjugates := function( sheet, menu, name )
    local   selected,  ver,  grp,  pos,  new,  lst,  seen;

    # it might take a while
    SetTitle( sheet, "Computing Conjugates" );

    # compute all conjugate subgroups
    selected := sheet.selected;
    sheet.operations.DeselectAll(sheet);
    lst  := [];
    seen := [];
    for ver  in  selected  do
        if not ver.classRep in seen  then
            Add( seen, ver.classRep );
            grp := ver.group^Random(sheet.group);
            pos := PositionProperty( sheet.vertices, x -> x.group = grp );
            InfoGraphicLattice1( "#I  RandomConjugate(",
                                 ver.label.text, ") = " );

            # insert new found representatives
            if pos = false  then
                new := sheet.operations.InsertConjugate( sheet, ver, grp );
                if not ver in sheet.selected  then
                    sheet.operations.ToggleSelection( sheet, ver );
                fi;
                if not new in sheet.selected  then
                    sheet.operations.ToggleSelection( sheet, new );
                fi;
                if sheet.color.result <> false  then
                    Recolor( new, sheet.color.result );
                fi;

            # merge classes
            else
                new := sheet.vertices[pos];
                new := sheet.operations.MergeClasses( sheet, ver, new );
                if not ver in sheet.selected  then
                    sheet.operations.ToggleSelection( sheet, ver );
                fi;
                if not new in sheet.selected  then
                    sheet.operations.ToggleSelection( sheet, new );
                fi;
                if sheet.color.result <> false  then
                    Recolor( new, sheet.color.result );
                fi;
            fi;
            Add( lst, new );
            InfoGraphicLattice1( new.label.text, "\n" );
        else
            sheet.operations.ToggleSelection( sheet, ver );
        fi;
    od;
    sheet.operations.MakeMaximalSubgroups( sheet );
    for ver  in lst  do
        sheet.operations.MakeConnections( sheet, ver );
    od;

    # restore default title
    SetTitle( sheet, sheet.defaultTitle );

end;


#############################################################################
##

#F  InteractiveLatticeOps.CMMergeClasses( ... ) . . . . . . . . merge classes
##
InteractiveLatticeOps.CMMergeClasses := function( sheet, menu, name )
    local   size,  v,  i;

    # check that all selected groups have the same size
    size := List( sheet.selected, x -> Size(x.group) );
    if 1 < Length(Set(size))  then
        Print( "#W  subgroups must have the same size\n" );
        return;
    fi;

    # merge the classes
    v := sheet.selected[1];
    for i  in [ 2 .. Length(sheet.selected) ]  do
        sheet.operations.MergeClasses( sheet, v, sheet.selected[i] );
    od;

end;


#############################################################################
##

#F  # # # # # # # #  Functions used for the Initial Setup   # # # # # # # # #


#############################################################################
##

#F  InteractiveLatticeOps.MakeMenus( <sheet> ) 	. . menus for a lattice sheet
##
InteractiveLatticeOps.MakeMenus := function( sheet )
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
          ,                       Ignore,
          "Conjugate Subgroups",  sheet.operations.SMConjugateSubgroups,
          "Random Conjugates",    sheet.operations.SMRandomConjugates,
          "Overgroups",           sheet.operations.SMAllOverGroups
        ] );
    Add( sheet.updateMenus0, [ menu, [
          "Centres", "Derived Series", "Normalizers", "Normal Subgroups",
          "Derived Subgroups", "Centralizers", "Normal Closures",
          "Sylow Subgroup", "Fitting Subgroups", "Cores",
          "Conjugate Subgroups", "Random Conjugates" ] ] );
    Add( sheet.updateMenus1, [ menu, [
         "Closure", "Intersection", "Commutator Subgroups" ] ] );
    Add( sheet.updateMenus2, [ menu, [
         "Closures", "Intersections" ] ] );

    # create clean up menu
    tmp := [ "Average Y Levels",        sheet.operations.CMAverageYLevels,
             "Average X Levels",        sheet.operations.CMAverageXLevels,
             "Rotate Conjugates",       sheet.operations.CMRotateConjugates,
             ,                          Ignore,
             "Deselect All",            sheet.operations.CMDeselectAll,
             "Relabel Vertices",        sheet.operations.CMRelabelVertices,
             "Select Representatives",  sheet.operations.CMSelectReps,
             ,                          Ignore,
             "Merge Classes",           sheet.operations.CMMergeClasses
    ];
    if sheet.color.model = "color"  then
        Append( tmp, [ , Ignore,
             "Use Black&White",         sheet.operations.CMUseBlackWhite ] );
    fi;
    sheet.cleanUpMenu := Menu( sheet, "CleanUp", tmp );
    Add( sheet.updateMenus0, [ sheet.cleanUpMenu, [
            "Deselect All", "Relabel Vertices" ] ] );
    Add( sheet.updateMenus1, [ sheet.cleanUpMenu, [
            "Average X Levels", "Rotate Conjugates", "Merge Classes" ] ] );

end;


#############################################################################
##
#F  InteractiveLatticeOps.MakeConnections( <sheet>, <ver> ) . new Connections
##
InteractiveLatticeOps.MakeConnections := function( sheet, ver )
    local    list,            # all objects connected with obj
             i, j,            # loop variables 
             size,
             vertex;          # the new vertex 

    # new object and its label
    list := Filtered( sheet.vertices, x -> ver in x.maximals );

    # disconnect all existing connections with elements of list
    for vertex  in list  do
        size := Size(vertex.group);
        for j  in ShallowCopy(vertex.connections)  do
            if Size(j.group) < size  then
                if not j in vertex.maximals  then
                    Disconnect( vertex, j );
                fi;
            fi;
        od;
    od;

    # make new connections from the new vertex <ver>
    for i  in ver.maximals  do
        Connection( ver, i );
    od;

    # remake the connections of vertices containing <ver> as maximal
    for i  in list  do
        for j  in i.maximals  do
            Connection( i, j );
        od;
    od;

end;


#############################################################################
## 
#F  InteractiveLatticeOps.MakeMaximalSubgroups( <sheet> ) . . . . . . . local
##
InteractiveLatticeOps.MakeMaximalSubgroups := function ( sheet )
    local   ord,                # list of orders/indices of sheet.maximals
            vi, vj,
            incl, max,          # inclusions, maximals
            i, j,               # loop variables
            vertices,
            grp;

    # sort vertices according to the order
    vertices := ShallowCopy(sheet.vertices);
    SortParallel( List(vertices, x -> Size(x.group)), vertices );

    # make maximals new
    max  := List( vertices, x -> [] );
    incl := List( vertices, x -> [] );
    grp  := sheet.group;
    for i  in [ 1 .. Length(vertices) ]  do
        for j  in [ i-1, i-2 .. 1 ]  do
            vi := vertices[i];
            vj := vertices[j];
            if not j in incl[i]  then
                if Index(grp,vj.group) <> Index(grp,vi.group)
                   and Index(grp,vj.group) mod Index(grp,vi.group) = 0
                   and IsSubgroup( vi.group, vj.group )
                then
                    if not vj in max[i]  then Add( max[i], vj );  fi;
                    AddSet( incl[i], j );
                    UniteSet( incl[i], incl[j] );
                fi;
            fi;
        od;
    od;

    # and enter the result
    for i  in [ 1 .. Length(max) ]  do
        vertices[i].maximals := max[i];
    od;

end;


#############################################################################
##
#F  InteractiveLatticeOps.MakeY( <sheet> )  . . . . . . .  make y-coordinates
##
InteractiveLatticeOps.MakeY := function(sheet)
    local   L, M, i, D;

    D := DivisorsInt(Size(sheet.group));
    L := Length(D);
    M := (sheet.height-2*VERTEX.diameter)/L;
    sheet.yCoors := [];
    for i  in [1..L]  do
        sheet.yCoors[i] := [ D[i] , sheet.height - Int(M*i) ];
    od;
end;


#F  # # # # # # # # # # # # #  the main functions   # # # # # # # # # # # # #


#############################################################################
##

#F  InteractiveLattice( <G>, <x>, <y> ) . . . . . . . . .  display a lattice
##
InteractiveLattice := function( arg )
    if IsModule(arg[1]) or IsPartialModuleLattice(arg[1])  then
        return ApplyFunc( InteractiveModuleLattice, arg );
    elif IsFpGroup(arg[1])  then
        return ApplyFunc( InteractiveFpLattice, arg );
    else
        return ApplyFunc( GroupOps.InteractiveLattice, arg );
    fi;
end;  



#############################################################################
##  
#F  GroupOps.InteractiveLattice( <G>, <x>, <y> ) . . . . . display a lattice
##
GroupOps.InteractiveLattice := function( arg )

    local   sheet,       #  the sheet
            G,           #  the group
            x,  y,       #  width, height of the sheet
            v,           #  vertices
            tmp,         #  temporary variable
            def,         #  default
            match,       #  the matching string
            i,  j;       #  loop variables 

    # we need at least one argument: the group
    if Length(arg) < 1  then
        Error( "usage: InteractiveLattice( <G>[, <x>, <y>] )" );
    fi;
    G := arg[1];
    if Size(G) = 1  then
        return Error( "<G> must be non-trivial" );
    fi;
    
    # match a substring
    match := function( b, a )
        local   c;
        c := Minimum(Length(a),Length(b));
        return a{[1..c]} = b{[1..c]};
    end;

    # parse the other argument: <x>, <y> or "title"
    def := rec( x := 800, y := 600 );
    i := 2;
    while i <= Length(arg)  do
        if IsInt(arg[i])  then
            def.x := arg[i];
            def.y := arg[i+1];
            i := i+2;
        elif IsString(arg[i])  then
            if match( arg[i], "title" )  then
                def.title := arg[i];
            elif match( arg[i], "Title" )  then
                def.title := arg[i];
            else
                Error( "unkown option \"", arg[i], "\",\n",
                       "options are: \"title\"" );
            fi;
            i := i+1;
        else
            Error( "unkown option ", arg[i] );
        fi;
    od;

    # construct a nice title
    if not IsBound(def.title)  then
        if IsBound(G.name)  then
            def.title := Concatenation( "Interactive Lattice of ", G.name );
        else
            def.title := "Interactive Lattice";
        fi;
    fi;

    # open a graphic sheet
    sheet := GraphicSheet( def.title, def.x, def.y );
    sheet.defaultTitle := def.title;
     sheet.close := function(sheet)
        if IsBound(sheet.selector)  then
            Close(sheet.selector);
        fi;
    end;
    sheet.operations := InteractiveLatticeOps;

    # store group in <sheet>
    sheet.group := G;
    sheet.super := G;

    # select a color model
    sheet.color := rec();
    if COLORS.red <> false or COLORS.lightGray <> false  then
        sheet.color.model := "color";
    else
        sheet.color.model := "monochrome";
    fi;
    sheet.operations.MakeColors(sheet);

    # set the limits
    sheet.limits := rec();
    sheet.limits.conjugates := 100;

    # create all possible strips
    sheet.strips := List( DivisorsInt(Size(G)), x -> [] );

    # create two initial vertices
    sheet.vertices := []; 
    x := QuoInt( sheet.width, 2 );

    # trivial subgroup
    v := Vertex( sheet, x, sheet.height-VERTEX.diameter );
    v.class      := [v];
    v.group      := TrivialSubgroup(G);
    v.ident      := [ 1, 1 ];
    v.isClassRep := true;
    v.classRep   := v;
    v.strip      := 1;
    v.maximals   := [];
    v.info       := rec( size := 1, index := Size(G) );
    Relabel( v, "1" );
    Add( sheet.vertices, v );
    Add( sheet.strips[v.strip], v );
    sheet.operations.SelectObject( sheet, v, false );
    
    # <G> itself
    v := Vertex( sheet, x, VERTEX.diameter );
    v.class      := [v];
    v.group      := G;
    v.ident      := [ 2, 1 ];
    v.isClassRep := true;
    v.classRep   := v;
    v.strip      := Length(sheet.strips);
    v.maximals   := sheet.vertices[1];
    v.info       := rec( size := Size(G), index := 1 );
    Relabel( v, "2" );
    Add( sheet.vertices, v );
    Add( sheet.strips[v.strip], v );

    # create menus
    sheet.operations.MakeMenus(sheet);

    # connect the two vertices
    Connection( sheet.vertices[1], sheet.vertices[2] );

    # compute possible y coordinates
    sheet.operations.MakeY(sheet);
    
    # <G> is selected at first
    sheet.selected := []; 
    sheet.operations.ToggleSelection( sheet, sheet.vertices[2] );
    
    # add pointer action to <sheet>
    InstallGSMethod(sheet,"LeftPBDown",     sheet.operations.LeftButton     );
    InstallGSMethod(sheet,"RightPBDown",    sheet.operations.RightButton    );
    InstallGSMethod(sheet,"ShiftLeftPBDown",sheet.operations.ShiftLeftButton);
    InstallGSMethod(sheet,"CtrlLeftPBDown", sheet.operations.ShiftLeftButton);

    # and enable/disable entries
    sheet.operations.UpdateMenus(sheet);

    return sheet;

end;


#############################################################################
##
#F  InteractiveLatticeOps.FindAllOverGroups( <sheet>, <ver> ) .  overgroups
##
InteractiveLatticeOps.FindAllOverGroups := function( sheet, ver )
    local op,t,p,p2,j,
          Klist,              # list of all over-groups
          i, vec,             # loop variables
          K,                  # the new group
          new,
          vertex;             # new vertex

    if IsBound(ver.group.forcelattice) 
       or (Size(ver.group)^2<=10*Size(sheet.group) 
	   and (not IsSolvable(sheet.group) or Size(sheet.group)<50000)) then
      # NOCH: convert probably in AgGroup
      Klist:=List(ConjugacyClassesSubgroups(sheet.group),Representative);
      Klist:=Filtered(Klist,i->IsInt(Size(i)/Size(ver.group)));

      new:=[];
      for t in Klist do
	# Enumerate class
	op:=[t];
	for i in op do
	  for j in sheet.group.generators do
	    K:=ConjugateSubgroup(i,j);
	    if not K in op then
	      Add(op,K);
	    fi;
	  od;
	od;

        for K in op do
	  if IsSubgroup(K,ver.group) then
	    K.index := Index(sheet.group,K);
	    K.isNormal:=IsNormal(sheet.group,K);
	    Add(new,K);
	  fi;
        od;

      od;
      
    else
      t:=CanonicalRightTransversal(sheet.group,ver.group);
      Unbind(ver.group.rightTransversal);
      op :=Operation(sheet.group,t,
		     OnCanonicalCosetElements(sheet.group,ver.group));
      
      Klist:=AllBlocks(op);

      # insert the new subgroups in the lattice
      new := [ver.group];
      for i in [ 1 .. Length(Klist) ]  do

	K:=Subgroup(sheet.group,Concatenation(ver.group.generators,
		    t{Klist[i]}));
	K.size:=Size(ver.group)*Length(Klist[i]);

	# build the  new group as a pseudo-subgroup  of <sheet.group> and add
	# all entries
	K.index      := Index(sheet.group,K);
	
	Add( new, K );
	  
	K.isNormal:=IsNormal(sheet.group,K);
      od;
      Add(new,sheet.group);
    fi;

    return new;
end;

#############################################################################
##
#F  InteractiveLatticeOps.SMAllOverGroups( ... ) . all over groups of group
##
InteractiveLatticeOps.SMAllOverGroups := function( sheet, menu, name )
    local   ver,  new;

    # check if the selected group is the whole group
    ver := sheet.selected[1];
    if Size(ver.group)=Size(sheet.group) then
        new:=[ver.group];

    # otherwise find all over groups
    else
        new := sheet.operations.FindAllOverGroups( sheet, ver );
        if new = false  then return;  fi;
    fi;
    sheet.operations.ShowResult( sheet, List(sheet.selected,i->i.group), new ,
                                List([1..Length(new)],i->i*20));
end;

