#############################################################################
##
#A  ilatfpgp.g                 	XGAP library               Susanne Keitemeier
##
#H  @(#)$Id: ilatfpgp.g,v 1.1 1997/11/27 12:19:56 frank Exp $
##
#Y  Copyright (C) 1993,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##
##  This file contains  the interactive lattice program for  fp groups.   The
##  following functions are implemented:
##
##  'InteractiveLattice( <group>[, <x>, <y>] )
##  -----------------------------------------------------------------------
##
##  'InteractiveLattice'  displays  a partial lattice  in  a graphic sheet of
##  dimension width <x> and height <y>.
##
##  A graphic lattice record contains the following components:
##  -----------------------------------------------------------
##
##  'group':
##    the group of the graphic lattice
##
##  'strips':
##    a list of vertex numbers belonging to subgroups of the same order. 
##
##  'vertices':
##    a  list of   vertices, a  vertex  is   again a record  with  components
##    described below.  This first vertex always belongs to <sheet.group>.
##  
##  'maximals':
##    a list : [ [ number of vertex, index of group, 
##                       [ list of numbers of maximal subgroups ] ] . . . . ]
##  
##  'init': 
##    a record with entries 'x' and 'y'
##  
##  'selected': 
##    a list of selected vertices
##  
##  'newselected': 
##    a list of the new calculated vertices
##  
##
##  A vertex from 'vertices' is a record with the following components:
##  -------------------------------------------------------------------
##
##  'action':
##    This string  contains the action  of the group.   The following actions
##    are supported:
##
##      "cosetTable":
##        a coset table is   stored in <ver.group.cosetTable>, this table  is
##        always standardized and relative to <sheet.group>
##
##      "cosetTableSubgroup":
##        a coset  table is stored  in <ver.group.cosetTable>,  this table is
##        always standardized and relative to <ver.group.parent>
##
##  'isClassRep':
##    'true' if <vertex> is class representative
##
##  'class':
##    a list of vertices  of the class  of <vertex>, bound if 'isClassRep' is
##    'true', all  vertices of a class are  of type  "cosetTable".  This list
##    either contains only <ver> or the complete class.
##
##  'classRep':
##    the vertex of the class representative
##
##  'group':
##    the  subgroup of  this vertex,  this  can be   real  gap subgroup  with
##    generators or some  sort of pseudo  group.  We prefer groups with coset
##    table relative to <sheet.group>, so  this entry might be changed during
##    the computation.
##
##  'factorFpGroup':
##    a fp group isomorphic to the quotient of <sheet.group> and 'group'.
##
##  'fpGroup':
##    a fp  group  isomorph to 'group',  once  computed  this entry  is never
##    changed.
##
##  'pqstart':
##    If   <vertex>    was   constructed using    a   $p$-quotient algorithm,
##    <vertex.pqstart>[p] the starting point.
##
##  'pqs':
##    If  a  $p$ quotient  algorithm    was  started at this  <vertex>   then
##    'pqs[p][<c>]' contains  a pair [ <ver>, <pq>  ].  <pq> is the resulting
##    quotients of class <c> and <ver> is the  vertex. WARNING: these entries
##    are *not* independent from 'fpGroup' of the starting point of the PQ.
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
##  'isNormal':
##    if this entry is true, the group is normal and the vertex gets a 
##    different form
##
##  'abelianInvariants':
##    list of the abelian Invariants of 'group'
## 
##  'index':
##    the index of the group in <s>.group
##
##  
##  A group is a record with the following components:
##  -------------------------------------------------------------------
##  
##  'vno':
##    the number of the corresponding vertex, one has to use to compare 
##    groups
##  
##  'nvno':
##    the number of the normalizer of the group, if the group is 
##    self normalizing, 'nvno' = 'vno' 
##  
##  'parent':
##    the parent group of the group
##
##  'index':
##    the index in <sheet.group>
##  
##  'cosetTable':
##    if the coset table is calculated, it is hold here
##  
#H  $Log: ilatfpgp.g,v $
#H  Revision 1.1  1997/11/27 12:19:56  frank
#H  added 3.5 library (does not work with 4.0)
#H
#H  Revision 1.10  1995/09/25  08:11:27  fceller
#H  fixed a problem with 'match'
#H
#H  Revision 1.9  1995/09/12  08:27:31  fceller
#H  added a crude 'Select' method
#H
#H  Revision 1.8  1995/08/16  12:46:47  fceller
#H  changed to slightly different text selector syntax
#H
#H  Revision 1.7  1995/08/10  18:06:27  fceller
#H  changed 'Box', 'Rectangle', 'Diamond' and 'Line'
#H  to expect the start position and a width and height
#H
#H  Revision 1.6  1995/08/09  10:54:36  fceller
#H  fixed various things (too much too mention but all were minor)
#H
#H  Revision 1.5  1995/07/28  10:04:16  fceller
#H  changed "black&white" to "monochrome"
#H  changed some of the names of the menu entries
#H  added entry 'EpimorphismsFpGroup'
#H
#H  Revision 1.4  1995/07/24  10:01:24  fceller
#H  changed select mechanism
#H
#H  Revision 1.3  1995/03/06  11:44:09  fceller
#H  removed strip bug for groups with many primes
#H
#H  Revision 1.1  1995/02/16  20:49:13  fceller
#H  Initial revision
##  

#F  # # # # # # # # # # #  Internal Functions   # # # # # # # # # # # # # # #


#############################################################################
##

#V  InteractiveFpLatticeOps . . . . . . . . . . . . . . . . operations record
##
InteractiveFpLatticeOps := OperationsRecord(
                           "InteractiveFpLatticeOps", GraphicLatticeOps );
  

#############################################################################
##

#F  InteractiveFpLatticeOps.ComputeCosetTable( <sheet>, <vg>, <vh> )   cosets
##
##  computes the   coset table  for  the  fp.group  <vg.group> on <vh.group>.
##  There must  exists  a "chain"  of parents  from <vh.group> to <vg.group>,
##  that is  to say, a parent  of a parent  .. of a   parent of <vh.group> is
##  <vg.group>.
## 
InteractiveFpLatticeOps.ComputeCosetTable  := function( sheet, vg, vh )
    local   W,  L;

    if IsBound(vh.group.parent) then
        W := vh.group.parent;
    else
        return false;
    fi;

    # climb up the chain of parents to reach <vg>
    while W.vno <> vg.group.vno  do
        L  := sheet.vertices[W.vno];
        vh := WreathProductActions( L, vh );
        W  := L.group.parent;
    od;

    # now convert the action into a coset table
    return CosetTableAction(vh);
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.DeleteVertex( <sheet>, <ver> )  . .  delete <ver>
##
InteractiveFpLatticeOps.DeleteVertex := function( sheet, ver )
    local   v,  p,  x,  j;
    
    # always delete the whole class
    if not ver.isClassRep  then
        ver := ver.classRep;
    fi;
    
    for v  in ver.class  do

        # if <v> is a starting point for a pq, delete chain
        if IsBound(v.pqs)  then
            for p  in Filtered([1..Length(v.pqs)],x->IsBound(v.pqs[x]))  do
                for x  in v.pqs[p]  do
                    if x[1].action = "pq" and x[1].pqstart[p] = v  then
                        sheet.operations.DeleteVertex( sheet, x[1] );
                    fi;
                od;
            od;
        fi;

        # if <v> is a parent of something delete it
        for x  in ShallowCopy(sheet.vertices)  do
            if IsBound(x.group.parent)
               and x.group.parent.vno = v.group.vno
               and x <> v
            then
                    sheet.operations.DeleteVertex( sheet, x );
            fi;
        od;

        # update maximals
        for j   in v.connections  do
            if j.index < v.index then
                j.maximals := Filtered( j.maximals, x -> x <> v );
            fi;
        od;

        # update vertices
        sheet.vertices := Filtered( sheet.vertices, x -> x <> v );

        # update strips
        sheet.strips[v.strip] := Filtered(sheet.strips[v.strip], x -> x<>v);

        # update selected
        sheet.selected := Filtered( sheet.selected, x -> x <> v );

        # update normalizers
        for x  in sheet.vertices  do
            if IsBound(x.normalizer) and x.normalizer = v  then
                Unbind(x.normalizer);
            fi;
        od;

        # remove the vertex
        sheet.operations.RenameVertices( sheet, v );
        Delete(v);
    od;
end;

  
#############################################################################
##
#F  InteractiveFpLatticeOps.FindImplicitConnections( <sheet> )	. . . . check
##
InteractiveFpLatticeOps.BadSubgroupsBelow := function( sheet, lst )
    local   orb,  bad,  p,  x;

    # loop over the maximals
    orb := ShallowCopy(lst);
    bad := [];
    for p  in orb  do
        for x  in p.maximals  do
            if x in lst  then
                if not x in bad  then
                    Add( bad, x );
                fi;
            fi;
            if not x in orb  then
                Add( orb, x );
            fi;
        od;
    od;
    return bad;

end;


InteractiveFpLatticeOps.FindImplicitConnections := function( sheet )
    local   ver,  bad,  x;

    # loop over all vertices upto <pos>
    for ver  in sheet.vertices  do
        bad := sheet.operations.BadSubgroupsBelow( sheet, ver.maximals );
        for x  in bad  do
            Disconnect( ver, x );
            ver.maximals := Filtered( ver.maximals, t -> t <> x );
        od;
    od;

end;
  

#############################################################################
##
#F  InteractiveFpLatticeOps.InsertSubgroup( <sheet>,<new>,<idx>,<act>,<x> )
##
##  <new>: new subgroup
##  <idx>: index of <new> in <sheet.group>
##  <act>: "cosetTable", "cosetTableSubgroup"
##  <x>  : x coordinate of the new vertex (the y coordinate is calculated
##         below)
##
##  "cosetTable":
##    In this case the  parent of  <new> is <sheet.group>  and <new>  knows a
##    standardized coset  table relative  to <sheet.group>.  'InsertSubgroup'
##    will test for equality and inclusions in this case.
##
##  "cosetTableSubgroup":
##    In this case the parent  of <new>  is a  subgroup of <sheet.group>  and
##    <new>  only  knows a standardized  coset table  relative to this parent
##    (ie, <new.parent>).  'InsertSubgroup'  will not  test for equality  and
##    inclusions.
##
##  "abelianQuotient":
##    In this case the <new>  was constructed using an IMD.  'InsertSubgroup'
##    will not test for equality and inclusions.
##         
##  "pq":
##    In this case the <new>  was constructed  using  a PQ.  'InsertSubgroup'
##    will not test for equality and inclusions.
##         
##
InteractiveFpLatticeOps.InsertSubgroup := function(sheet, new, idx, act, x)

    local  group, fpgroup,     # two possibilities of group
           no,                 # new number of the vertex
           i,                  # loop variable
           i1, i2,
           v,                  # new vertex
           y,                  # y position of <v>
           s;                  # strip of <v>

    # if <act> is "cosetTable", check if know <new>
    if act = "cosetTable"  then
        for v  in sheet.vertices  do
            if     v.action = "cosetTable"
               and new.cosetTable = v.group.cosetTable
            then
                return v;
            fi;
        od;
    fi;
    if idx = 1  then
        return sheet.vertices[1];
    fi;

    # find the correct strip
    i1 := sheet.operations.NewYPosition( sheet, idx );
    y  := i1[2];
    s  := i1[1];

    # check if there is anything at position <x>, <y>
    i1 := [x,y];
    if ForAny( sheet.strips[s], t -> i1 in t )  then
        i1 := [ x-1, y ];
        i2 := [ x+1, y ];
        v  := false;
        while 0 <= i1[1] and i2[1] < sheet.width and v = false  do
            if 0 <= i1[1]   then
                if ForAll( sheet.strips[s], t -> not i1 in t )  then
                    v := i1[1];
                fi;
                i1[1] := i1[1] - QuoInt(3*VERTEX.diameter,2);
            fi;
            if  i2[1] <= sheet.width  then
                if ForAll( sheet.strips[s], t -> not i2 in t )  then
                    v := i2[1];
                fi;
                i2[1] := i2[1] + QuoInt(3*VERTEX.diameter,2);
            fi;
        od;
        if v <> false  then
            x := v;
        fi;
    fi;

    # create a new vertex
    no := Length(sheet.vertices)+1;
    v  := Vertex( sheet, x, y );
    v.strip      := s;
    v.isClassRep := true;
    v.classRep   := v;
    v.class      := [v];
    v.maximals   := [];
    Add( sheet.strips[v.strip], v );
    Relabel( v, String(no) ); 
    
    # "cosetTable": set group, index
    if act = "cosetTable"  then
        v.action      := act;
        v.group       := new;
        v.group.vno   := no;
        v.index       := idx;
        v.group.index := idx;
        for i  in sheet.vertices  do
            if i.action = "cosetTable"  then
                if IsSubgroupFpGroup( i.group, new )  then
                    Add( i.maximals, v );
                    Connection( i, v );
                elif IsSubgroupFpGroup( new, i.group )  then
                    Add( v.maximals, i );
                    Connection( i, v );
                fi;
            fi;
        od;
        Add( sheet.vertices, v ); 
        sheet.operations.FindImplicitConnections(sheet);

    # "cosetTableSubgroup": group, index
    elif    act = "cosetTableSubgroup"
         or act = "abelianQuotient"
         or act = "pq"
         or act = "intransitive"
    then
        v.action    := act;
        v.group     := new;
        v.group.vno := no;
        v.index     := idx;
        Add( sheet.vertices, v ); 
    fi;

    return v;
end;
  

#############################################################################
##
#F  InteractiveFpLatticeOps.IsNormal( <sheet>, <ver> )  . . . . . . is normal
##
InteractiveFpLatticeOps.IsNormal := function( sheet, ver )
    local   table,  perms,  vec;

    # don't compute it twice
    if IsBound(ver.isNormal)  then
        return ver.isNormal;
    fi;

    # compute a coset table
    table := sheet.operations.MakeCosetTable( sheet, ver );
    if table = false  then
        return "not computable";
    fi;

    # compute the permutation factor group
    perms := [];    
    for vec in table  do
        Add( perms, PermList(vec) );
    od;
    if IsRegular(Group(perms,()),[1..Length(table[1])]) = true  then
        ver.isNormal := true;
        sheet.operations.Reshape( sheet, ver );
    else
        ver.isNormal := false;
    fi;
    return ver.isNormal;

end;


#############################################################################
## 
#F  InteractiveFpLatticeOps.IsTrivial( <sheet>, <ver> ) .  check if <ver> = 1
##
##  'IsTrivial' check if *already* know that  <ver> is trivial, it will *not*
##  try to compute it.
##
InteractiveFpLatticeOps.IsTrivial := function( sheet, ver )
    local   grp;

    grp := ver.group;
    if ver.action = "pq" and  0 = Length(grp.pq.generators)  then
        return true;
    elif IsBound(grp.generators) and 0 = Length(grp.generators)  then
        return true;
    elif IsBound(ver.fpGroup) and 0 = Length(ver.fpGroup.generators)  then
        return true;
    else
        return false;
    fi;
end;



#############################################################################
##
#F  InteractiveFpLatticeOps.MakeCosetTable( <sheet>, <ver> ) make coset table
##
InteractiveFpLatticeOps.MakeCosetTable := function( sheet, ver )
    local   tab,  vno,  v;

    # check if know a table
    if ver.action = "cosetTable"  then
        return ver.group.cosetTable;
    fi;

    # otherwise compute the table
    tab := sheet.operations.ComputeCosetTable(sheet, sheet.vertices[1], ver);
    if tab = false  then return false;  fi;

    # change the group/action of <ver>
    vno                  := ver.group.vno;
    ver.action           := "cosetTable";
    ver.group            := PseudoSubgroup(sheet.group);
    ver.group.index      := ver.index;
    ver.group.cosetTable := tab;
    ver.group.vno        := vno;

    # check if know this group
    for v  in ShallowCopy(sheet.vertices)  do
        if v.isAlive and v <> ver  then
            if v.action = "cosetTable" and v.group.cosetTable = tab  then
                sheet.operations.MergeVertices( sheet, ver, v );
                return tab;
            fi;
        fi;
    od;

    # fix the maximal subgroups
    for v  in sheet.vertices  do
        if v <> ver  then
            if v.action = "cosetTable"
               and IsSubgroupFpGroup(v.group,ver.group)
            then
                if not ver in v.maximals  then
                    Add( v.maximals, ver );
                    Connection( v, ver );
                fi;
            fi;
        fi;
    od;
    sheet.operations.FindImplicitConnections(sheet);
    sheet.operations.Reshape( sheet, ver );

    # and return
    return tab;

end;


#############################################################################
##
#F  InteractiveFpLatticeOps.MakeFpGroup( <sheet>, <ver> ) . make presentation
##
InteractiveFpLatticeOps.MakeFpGroup := function( sheet, ver )
    local   U,  P;
                   
    # try to compute a presentation
    if not IsBound(ver.fpGroup)  then
        P := PresentationAction(ver);
        U := FpGroupPresentation(P);
        ver.fpGroup     := U; 
        ver.fpGroup.vno := ver.group.vno;
    fi;
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.MergeVertices( <sheet>, <v1>, <v2> )   merge them
##
##  It should never happen that <v1> and <v2> both have a class attached.
##
InteractiveFpLatticeOps.MergeVertices := function( sheet, v1, v2 )
    local   keep,  tmp,  v;

    # decide which vertex to keep
    if v1.action = "cosetTable" and v2.action <> "cosetTable"  then
        keep := 1;
    elif v2.action = "cosetTable" and v1.action <> "cosetTable"  then
        keep := 2;
    elif v1.action <> "cosetTable" and v2.action <> "cosetTable"  then
        if Length(v1.maximals) < Length(v2.maximals)  then
            keep := 2;
        else
            keep := 1;
        fi;
    else
        if v1.isClassRep and 1 < Length(v1.class)  then
            keep := 1;
        elif v2.isClassRep and 1 < Length(v2.class)  then
            keep := 2;
        elif not v1.isClassRep  then
            keep := 1;
        elif not v2.isClassRep  then
            keep := 2;
        elif Length(v1.maximals) < Length(v2.maximals)  then
            keep := 2;
        else
            keep := 1;
        fi;
    fi;

    # if <keep> = 2  then switch <v1> and <v2>
    if keep = 2  then
        tmp := v2;  v2 := v1;  v1 := tmp;
    fi;

    # merge maximals of <v2> into <v1>
    for v  in v2.maximals  do
        if not v in v1.maximals  then
            Add( v1.maximals, v );
            Connection( v1, v );
        fi;
    od;

    # if a vertex contains <v2> it must contain <v1>
    for v  in sheet.vertices  do
        if v2 in v.maximals  then
            if not v1 in v.maximals  then
                Add( v.maximals, v1 );
                Connection( v1, v );
            fi;
            v.maximals := Filtered( v.maximals, x -> x <> v2 );
        fi;
    od;

    # update normalizer entries
    for v  in sheet.vertices  do
        if IsBound(v.normalizer) and v2 = v.normalizer  then
            v.normalizer := v1;
        fi;
    od;

    # update vertices
    sheet.vertices := Filtered( sheet.vertices, x -> x <> v2 );

    # update strips
    sheet.strips[v2.strip] := Filtered( sheet.strips[v2.strip], x -> x<>v2 );

    # update selected
    sheet.selected := Filtered( sheet.selected, x -> x <> v2 );

    # update possible parents
    if not IsBound(v1.fpGroup) and IsBound(v2.fpGroup)  then
        v1.fpGroup := v2.fpGroup;
        v1.fpGroup.vno := v1.group.vno;
    fi;
    for v  in sheet.vertices  do
        if v <> v2 and v <> v1  then
            if IsBound(v.group.parent) and
               v.group.parent.vno = v2.group.vno
            then
                if v.action = "cosetTableSubgroup"  then
                    v.group.parent := v1.fpGroup;
                    Unbind(v.group.generators);
                elif v.action = "abelianQuotient"  then
                    v.group.parent := v1.fpGroup;
                    Unbind(v.group.generators);
                elif v.action = "pq"  then
                    v.group.parent := v1.fpGroup;
                    Unbind(v.group.generators);
                elif v.action = "intransitive"  then
                    v.group.parent := v1.group;
                    Unbind(v.group.generators);
                fi;
            fi;
        fi;
    od;

    # remove vertex
    Delete(v2);
    sheet.operations.RenameVertices( sheet, v2 );
    sheet.operations.Reshape( sheet, v1 );
    sheet.operations.FindImplicitConnections(sheet);

    return v1;

end;


#############################################################################
##
#F  InteractiveFpLatticeOps.NewYPosition( <sheet>, <idx> )  .  find new y pos
##
InteractiveFpLatticeOps.NewYPosition := function( sheet, idx )
    local   p,  y1,  y2,  i,  v;

    # check if already know this index
    p := PositionProperty( sheet.strips, x -> x[1].index = idx );

    # return the y position of this strip
    if p <> false  then
        return [ p, sheet.strips[p][1].y ];
    fi;

    # find the position to insert the new strip
    p := PositionProperty( sheet.strips, x -> x[1].index < idx );

    # if all are smaller we have to insert a new strip at the end
    if p = 1  then

        # now comes the hard bit, find a nice y position
        y1 := sheet.strips[p][1].y;
        y2 := sheet.height - VERTEX.radius;
        y1 := y1+QuoInt(y2-y1,10);
        
    # create a new strip between <p>-1 and <p>
    else

        # get the upper and lower bound
        y1 := sheet.strips[p-1][1].y;
        y2 := sheet.strips[p][1].y;

        # and average
        y1 := QuoInt( y1+y2, 2 );
    fi;

    # make room for a new strip
    for i  in [ Length(sheet.strips), Length(sheet.strips)-1 .. p ]  do
        sheet.strips[i+1] := sheet.strips[i];
        for v  in sheet.strips[i+1]  do
            v.strip := i+1;
        od;
    od;
    sheet.strips[p] := [];

    # and return the new strip and y position
    return [ p, y1 ];

end;


#############################################################################
##
#F  InteractiveFpLatticeOps.Print( <sheet> )  . . . . . . . . pretty printing
##
InteractiveFpLatticeOps.Print := function( sheet )
    Print( "<interactive graphic lattice>" );
end;
  

#############################################################################
##
#F  InteractiveFpLatticeOps.RenameVertices( <sheet>, <ver> ) rename everthing
##
InteractiveFpLatticeOps.RenameVertices := function( sheet, ver )
    local   map,  i;
    
    # construct an array containing the new numbers
    map := [];
    for i  in [ 1 .. ver.group.vno-1 ]  do
        map[i] := i;
    od;
    for i  in [ ver.group.vno+1 .. Length(sheet.vertices)+1 ]  do
        map[i] := i-1;
    od;

    # renumber the group numbers
    for i  in sheet.vertices   do
        if IsBound(i.group) and IsBound(i.group.vno)  then
            i.group.vno := map[i.group.vno];
        fi;
        if IsBound(i.fpGroup) and IsBound(i.fpGroup.vno)  then
            i.fpGroup.vno := map[i.fpGroup.vno];
        fi;
    od;
     
    # relabel the vertices
    for i in [ ver.group.vno .. Length(sheet.vertices) ]  do
        Relabel( sheet.vertices[i], String(i) );
    od;

end;


#############################################################################
##
#F  InteractiveFpLatticeOps.Select( <sheet>, <list> ) . . .  select subgroups
##
InteractiveFpLatticeOps.Select := function( sheet, l )
    local   new,  i,  vertex,  perms,  vec;

    new := [];
    for i  in [ 1 .. Length(l) ]  do
        if sheet.group <> Parent(l[i])  then
            Error( "parent groups differ for l[", i, "]" );
        fi;
        l[i].index := Length( CosetTableFpGroup( sheet.group, l[i] )[1] );
        
        # insert vertex
        vertex := sheet.operations.InsertSubgroup( sheet, l[i],
                          l[i].index, "cosetTable",
                          i*QuoInt(sheet.width,Length(l)+1) );
        Add( new, vertex );

        # compute permutation group
        perms := [];
        for vec in l[i].cosetTable  do
            Add(perms,PermList(vec));
        od;

        # for subgroups of <sheet.group> check if they are normal
        if not IsRegular( Group(perms,()), [1..Length(vec)] )  then 
            vertex.isNormal := false;
        else
            vertex.isNormal := true;
            sheet.operations.Reshape( sheet, vertex );
        fi;
    od;
    sheet.operations.ShowResult( sheet, [], new );
    
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.Selected( <sheet> ) . . .  return selected groups
##
InteractiveFpLatticeOps.Selected := function( sheet )
    local   groups,  x;

    groups := [];
    for x  in sheet.selected  do

        # get the group of <x>
        if IsBound(x.group)  then
            Add( groups, x.group );
        elif IsBound(x.fpGroup) then
            Add( groups, x.fpGroup );
        fi;
    od;

    # and return
    return groups;

end;


#############################################################################
##
#F  InteractiveFpLatticeOps.ShowResult( <sheet>, <old>, <new> )  color result
##
InteractiveFpLatticeOps.ShowResult := function( sheet, old, new )
    local  i;
    
    sheet.operations.DeselectAll(sheet);
    for i  in old  do
        if i.isAlive  then
            sheet.operations.ToggleSelection( sheet, i );
        fi;
    od;
    for i  in new  do
        if i.isAlive  then
            if not i  in sheet.selected  then
                sheet.operations.ToggleSelection( sheet, i );
            fi;
            sheet.operations.Reshape( sheet, i );
            if sheet.color.result <> false  then
                Recolor( i, sheet.color.result );
            fi;
        fi;
    od;
end;   


#############################################################################
##
#F  InteractiveFpLatticeOps.Reshape( <sheet>, <ver> ) . . . . . reshape <ver>
##
InteractiveFpLatticeOps.Reshape := function( sheet, ver )
    if IsBound(ver.isNormal) and ver.isNormal  then
        if ver.action = "cosetTable"  then
            Reshape( ver, VERTEX.diamond );
        else
            Reshape( ver, VERTEX.diamond + VERTEX.rectangle );
        fi;
    else
        if ver.action = "cosetTable"  then
            Reshape( ver, VERTEX.circle );
        else
            Reshape( ver, VERTEX.rectangle );
        fi;
    fi;
end;


#############################################################################
##

#F  InteractiveFpLatticeOps.FindAllOverGroups( <sheet>, <ver> ) .  overgroups
##
InteractiveFpLatticeOps.FindAllOverGroups := function( sheet, ver )
    local table,              # the coset table of H in G
          Klist,              # list of all over-groups
          i, vec,             # loop variables
          K,                  # the new group
          new,
          perms,              # permutation
          vertex;             # new vertex

    # compute the coset table of <sheet.group> / <ver.group>
    table := sheet.operations.MakeCosetTable( sheet, ver );
    
    # check if table is really a coset table
    if table = false  then 
        return false; 
    fi;
    
    # now find all coset tables of groups between <H> and <sheet.group>
    Klist := IntermediateCosetTables( table ); 
    
    if Length( Klist ) = 0  then
        Print( "#I  No over-groups found! \n" );
        return [ver];
    fi;
    
    # insert the new subgroups in the lattice
    new := [];
    for i in [ 1 .. Length(Klist) ]  do

        # build the  new group as a pseudo-subgroup  of <sheet.group> and add
        # all entries
        K            := PseudoSubgroup(sheet.group);
        K.cosetTable := Klist[i];
        K.index      := Length(K.cosetTable[1]);
        
        # insert the new vertex
        vertex := sheet.operations.InsertSubgroup(
                      sheet, K, K.index, "cosetTable",
                      (i-1) * QuoInt(sheet.width, Length(Klist)) );
        Add( new, vertex );
        
        # check if the new group is normal
        perms := [];
        for vec  in K.cosetTable  do
            Add( perms, PermList(vec) );
        od;
        if IsRegular(Group(perms, ()),[ 1..Length(vec) ]) = true  then 
            vertex.isNormal := true;
            sheet.operations.Reshape( sheet, vertex );
        else
            vertex.isNormal := false;
        fi;
    od;
    return new;
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.FindConjugacyClass( <sheet>, <ver> )   conj class
##
InteractiveFpLatticeOps.FindConjugacyClass := function( sheet, ver )
    local   table1,  table2,  tables,  i,  K,  vertex;

    # return if <ver> is not a class representative
    if not ver.isClassRep  then
        return false;
    fi;
    
    # check if <ver> is normal
    if IsBound(ver.isNormal) and ver.isNormal  then
        return [ver];
    fi;

    # check if already know a class
    if 1 < Length(ver.class)  then
        return ver.class;
    fi;

    # compute the normalizer first
    if not IsBound(ver.normalizer)  then
        sheet.operations.FindNormalizer( sheet, ver );
    fi;
    if ver.isNormal  then
        return [ver];
    fi;
    
    # compute the coset table of <sheet.group> / <ver.group>
    table1 := sheet.operations.MakeCosetTable( sheet, ver );
    
    # compute the coset table of <sheet.group> / <ver.normalizer.group>
    table2 := sheet.operations.MakeCosetTable( sheet, ver.normalizer ); 
    
    # check if these tables are real coset tables
    if table1 = false or table2 = false  then 
        return false;
    fi;
    
    # now find all coset tables of groups in the conjugacy class of <H>    
    tables := TablesConjugacyClass( table1, table2 );
      
    # insert the new vertices
    for i in [ 2 .. Length(tables) ]  do
        
        # create the new group with coset table table[i]  
        K            := PseudoSubgroup(sheet.group);
        K.cosetTable := tables[i];
        
        # insert the new vertex
        vertex := sheet.operations.InsertSubgroup(
            sheet,  K,  Length(table1[1]), "cosetTable",
            ver.x+(i-1)*VERTEX.diameter );

        # set class info
        vertex.isClassRep := false;
        vertex.classRep   := ver;
        Unbind(vertex.class);

        # move it to the correct position
        vertex.operations.Move( vertex, ver.x+(i-1)*VERTEX.diameter, ver.y );

        # this vertex is not normal
        vertex.isNormal := false;

        # add it the class of <ver>
        Add( ver.class, vertex );
        
    od;
    return ver.class;
    
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.FindCore( <sheet>, <ver> )	. . . . . . . .  core
##
InteractiveFpLatticeOps.FindCore := function( sheet, ver )
    local table,           # the coset table
          K,               # new subgroup
          Kindex,          # the index of K in sheet.group
          vertex;          # new vertex

    # if <ver> is normal, return <ver>
    if IsBound(ver.isNormal) and ver.isNormal  then
        return ver;
    fi;

    # compute the coset table of <sheet.group> / <H>
    table := sheet.operations.MakeCosetTable( sheet, ver );
    if table = false  then
        return false;
    fi;
    
    # now table is the coset table of H in <sheet>.group
    table := RegularCosetTable(table);
      
    # so now we have the coset table for the core of H in <sheet>.group
    Kindex := Length(table[1]);
    
    # if <Kindex> = <ver>.index then <ver> is normal
    if ver.index = Kindex  then
        ver.isNormal := true;
        vertex := ver;
        sheet.operations.Reshape( sheet, vertex );

    # a new group is found
    else

        # create a new pseudo subgroup
        K                 := PseudoSubgroup(sheet.group);
        K.index           := Kindex;
        K.cosetTable      := table;
        
        # insert the new vertex below the selected one
        vertex := sheet.operations.InsertSubgroup(
                          sheet, K, Kindex, "cosetTable", ver.x );
        
        # connect the selected and the new vertex
        if not vertex in ver.maximals  then
            Connection( vertex, ver );
            Add( ver.maximals, vertex );
        fi;
        sheet.operations.FindImplicitConnections(sheet);
        
        # update the record components 
        vertex.isNormal := true;
        sheet.operations.Reshape( sheet, vertex );
    fi;
    return vertex;
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.FindDerivedSubgroup( <sheet>, <ver> ) . deri subg
##  
InteractiveFpLatticeOps.FindDerivedSubgroup := function( sheet, ver )
    local   K,               #  the new subgroup
            Kindex,          #  the index of  K
            vertex;          #  the new vertex
    
    # first check, if <ver.group> is the trivial subgroup 
    if sheet.operations.IsTrivial( sheet, ver )  then
        return ver;
    fi;

    # if there are no ab. invariants, calculate them together with new group
    sheet.operations.MakeFpGroup( sheet, ver );
    if not IsBound(ver.abelianInvariants)  then
        K := DerivedSubgroupFpGroup(ver.fpGroup);
        if 1 <> K.index  then
            ver.abelianInvariants := K.invariantsQuotient;
        else
            ver.abelianInvariants := [];
        fi;
    fi;
    
    # <ver> is perfect
    if 0 = Length(ver.abelianInvariants)  then
        return ver;
        
    # quotient is infinite
    elif 0 in ver.abelianInvariants  then
        Print("#W  abelian quotient of ",ver.label.text," is infinite.\n");
        return false;
        
    # compute the subgroup
    else

        # could be, if we already knew the abelian invariants
        if not IsBound(K)  then  
            K := DerivedSubgroupFpGroup(ver.fpGroup);
        fi;

        # compute the index of <K>
        Kindex := ver.index * K.index;
        
        # insert the new vertex below the selected one 
        vertex := sheet.operations.InsertSubgroup(
                          sheet, K, Kindex, "abelianQuotient", ver.x );
        
        # and connect the two vertices
        if not vertex in ver.maximals  then
            Connection( vertex, ver );
            Add( ver.maximals, vertex );
        fi;
        
        # if the selected group was normal, the new one is also normal
        if IsBound(ver.isNormal) and ver.isNormal = true  then
            vertex.isNormal := true;
            sheet.operations.Reshape( sheet, vertex );
        fi;
        return vertex;
    fi;
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.FindEpimorphisms( <sheet>, <ver>, <g>, <u>, <f> )
##
InteractiveFpLatticeOps.FindEpimorphisms := function( sheet, ver, g, u, f )
    local   fpg,  dgr,  map,  table,  i,  gen,  involutions,  rel,  
            length,  base,  word,  vec,  j,  epi,  new;

    # compute a presentation for <ver>
    if not IsBound(ver.fpGroup)  then
        sheet.operations.MakeFpGroup( sheet, ver );
    fi;
    fpg := ver.fpGroup;
    dgr := Maximum( List( g.generators, LargestMovedPointPerm ) );

    # construct all epimorphisms (upto inner automorphisms)
    epi := EpimorphismsFpGroup( fpg, g, u );

    # construct coset tables from the maps returned by 'EpimorphismsFpGroup'
    new := [];
    for map  in epi  do

        # create the coset table
        table := [];
        for i  in [ 1 .. Length(fpg.generators) ]  do
            gen := Image(map,fpg.generators[i]);
            table[2*i-1] := List( [1..dgr], y -> y^gen );
        od;


        # It's necessary to identity  the involutions of G, otherwise the
        # coset table won't be legal, since the  rows corresponding to an
        # involutory generator and its inverse must be identical, and not
        # merely equal.  The code to  identify involutions is copied from
        # "fpgrp.g".
        involutions := [];

        # now loop over all parent group relators.
        for rel in RelatorRepresentatives( fpg.relators ) do

            # get the length and the basic length of relator rel.
            length := LengthWord( rel );
            base := 1;
            word := rel ^ Subword( rel, 1, 1 );
            while word <> rel do
                base := base + 1;
                word := word ^ Subword( word, 1, 1 );
            od;

            if length = 2 and base = 1 then
                gen := Subword( rel, 1, 1 );
                Add(involutions,gen);
            fi;
        od;

        # build a correct coset table
        for i  in [ 1 .. Length(fpg.generators) ]  do
            if fpg.generators[i] in involutions  then
                table[2*i] := table[2*i-1];
            else 
                table[2*i] := [];
                vec := table[2*i-1];
                for j  in [ 1 .. Length(vec) ]  do
                    table[2*i][vec[j]] := j;
                od;
            fi;
        od;

        # always compute a standardized table
        StandardizeTable(table);

        # and store it in <new>
        AddSet( new, table );

    od;

    # return the coset tables
    return new;

end;


#############################################################################
##
#F  InteractiveFpLatticeOps.FindIntersection( <sheet>, <v1>, <v2>, <v> )
##
InteractiveFpLatticeOps.FindIntersection := function( sheet, v1, v2, v )
    local   vv1,  vv2,  K,  Kindex,  action,  table1,  table2,  table,  
            new,  tmp;

    # if both are normal use intransitive perm representation
    if IsBound(v1.isNormal) and v1.isNormal and
       IsBound(v2.isNormal) and v2.isNormal 
    then
        if v1.group.parent.vno  = v.group.vno  then 
            vv1 := v1;
        else 
            vv1 := rec();
            vv1.action := "cosetTableSubgroup";
            vv1.group  := PseudoSubgroup(v.fpGroup);
            vv1.group.cosetTable :=
              sheet.operations.ComputeCosetTable( sheet, v, v1 );
        fi;
        if v2.group.parent.vno  = v.group.vno  then 
            vv2 := v2;
        else 
            vv2 := rec();
            vv2.action := "cosetTableSubgroup";
            vv2.group  := PseudoSubgroup(v.fpGroup);
            vv2.group.cosetTable :=
              sheet.operations.ComputeCosetTable( sheet, v, v2 );
        fi;
      
        # compute the intersection
        K := IntersectionNormalSubgroups( vv1, vv2 );
        
        # get the right index and action
        Kindex := K.index * v.index;
        action := "intransitive";

    # at least one subgroup is not normal get both coset tables
    else
        table1 := sheet.operations.ComputeCosetTable( sheet, v, v1 );
        table2 := sheet.operations.ComputeCosetTable( sheet, v, v2 );
        
        # compute the table of the intersection
        table := CosetTableIntersection(table1,table2); 
        
        # add all record components
        K            := PseudoSubgroup(v.fpGroup);
        K.cosetTable := table;
        K.index      := Length(table[1]);

        # get the right index and action
        Kindex := K.index * v.index;
        if v.index = 1  then
            action := "cosetTable"; 
        else
            action := "cosetTableSubgroup";
        fi;
    fi;
    
    # check, if the subgroups  are identical, one  subgroup a subgroup  other
    # sugroup is, or if you computed a new one
    
    # the subgroups are identical
    if Kindex = v1.index and Kindex = v2.index  then
        new := sheet.operations.MergeVertices( sheet, v1, v2 );

    # <v1> is a subgroup of <v2> or vice versa
    elif Kindex = v1.index or Kindex = v2.index  then
        if Kindex = v2.index  then
            tmp := v1;
            v1  := v2;
            v2 := tmp;
        fi;

        # connect both vertices and make maximals new
        Connection( v1, v2 );
        Add( v2.maximals, v1 );
            
        # look for implicit connections
        sheet.operations.FindImplicitConnections(sheet);
        new := v1;
            
    # we found a new group
    else 
        new := sheet.operations.InsertSubgroup( sheet, K, Kindex,
                          action, QuoInt(v1.x + v2.x, 2) );

        # check if the new group is normal
        if IsBound(v1.isNormal) and v1.isNormal
            and IsBound(v2.isNormal) and v2.isNormal
        then
            new.isNormal := true;
            sheet.operations.Reshape( sheet, new );
        fi; 
        
        # make connections and  maximals new
        if action <> "cosetTable"  then
            Connection( v1, new );
            Add( v1.maximals, new );
            Connection( v2, new );
            Add( v2.maximals, new );
            sheet.operations.FindImplicitConnections(sheet);
        fi;
    fi;
    return new;
     
end;


#############################################################################
##  
#F  InteractiveFpLatticeOps.FindLowIndexSubgroups( <sheet>, <ver> ) . . . lis
##
InteractiveFpLatticeOps.FindLowIndexSubgroups := function( sheet, ver )

    local lim,     	# index limit
          lis,          # list of new subgroups computed by LowIndex   
          i, vec,       # loop variables
          j, no,
          vertex,       # the new vertex
          new,          # list of all new vertices
          H,
          Kindex,
          vi,  vj,
          perms;        # the permutation group
    
    # create an fp group
    sheet.operations.MakeFpGroup( sheet, ver );
    
    # check if <ver.group> is the trivial subgroup
    if sheet.operations.IsTrivial( sheet, ver )  then
        Print( "#I  Subgroup is the trivial subgroup\n" );
        return [];
    fi;
    H := ver.fpGroup;
    
    # dialog-menu : get limit and check if it is correct
    lim := Query(sheet.operations.PDLimit);
    if lim = false or lim = ""  then
        return [];
    fi;
    lim := IntString(lim);

    # compute the new subgroups
    lis := LowIndexSubgroupsFpGroup( H, TrivialSubgroup(H), lim ); 

    # the selected group is found
    if Length(lis) = 1  then
        Print("#I  No subgroups found of index at most ",lim,"\n");
    fi;
    Sort( lis, function(a,b) return Length(a.cosetTable[1])
                                  < Length(b.cosetTable[1]); end );

    # insert the new groups
    # lis[i] is actually a subgroup of H, and not of G, if H <> G 
    new := [];
    for i in [2..Length(lis)]  do
        lis[i].index := Length( lis[i].cosetTable[1] );
        Kindex       := ver.index * lis[i].index;
        
        # insert vertex
        if ver.index = 1  then
            vertex := sheet.operations.InsertSubgroup( sheet, lis[i],
                          Kindex, "cosetTable",
                          (i-1)*QuoInt(sheet.width,Length(lis)) );
        else
            vertex := sheet.operations.InsertSubgroup( sheet, lis[i],
                          Kindex, "cosetTableSubgroup",
                          (i-1)*QuoInt(sheet.width,Length(lis)) );
        fi;
        
        Add( new, vertex );

        # compute permutation group
        perms := [];
        for vec in lis[i].cosetTable  do
            Add(perms,PermList(vec));
        od;

        # for subgroups of <sheet.group> check if they are normal
        if 1 = ver.index  then
            if not IsRegular( Group(perms,()), [1..Length(vec)] )  then 
                vertex.isNormal := false;
            else
                vertex.isNormal := true;
                sheet.operations.Reshape( sheet, vertex );
            fi;
        fi;
    od;
    
    # check, if one group is subgroup of other
    if 1 < ver.index  then
        no := H.vno;
        for i  in [ 1 .. Length(lis) ]  do
            vi := sheet.vertices[lis[i].vno];
            for j  in [ i+1 .. Length(lis) ]  do
                vj := sheet.vertices[lis[j].vno];
                if IsSubgroupFpGroup( lis[i], lis[j] )  then
                    Connection( vi, vj );
                    if not vj in vi.maximals  then
                        Add( vi.maximals, vj );
                    fi;
                fi;
            od;
        od;
        sheet.operations.FindImplicitConnections(sheet);
    fi;

    # return the vertices
    return new;
    
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.FindNormalizer( <sheet>, <ver> )  . .  normalizer
##
InteractiveFpLatticeOps.FindNormalizer := function( sheet, ver )
    local table,             # the coset table
          gens,              # generators of H
          K,                 # new Subgroups
          newgens,           # generators of K
          Kindex,            # the index of K in sheet.group
          i,
          no, no1, pos,
          vertex;            # new vertex        

    # if vertex is normal return
    if IsBound(ver.isNormal) and ver.isNormal  then
        return sheet.vertices[1];
    fi;

    # if we know the normalizer return
    if IsBound(ver.normalizer)  then
        return ver.normalizer;
    fi;

    # construct the coset table
    table := sheet.operations.MakeCosetTable( sheet, ver );
    if table = false  then 
        return false; 
    fi;

    # now table is the coset table of <ver.group> in <sheet.group>
    if ver.group.parent.vno = 1  then 
        if not IsBound(ver.group.generators)  then
            AddSchreierGens(ver.group); 
        fi;
        gens := ver.group.generators;
        K := Normalizer( sheet.group, ver.group );
    else 
        gens := GeneratorsCosetTable(sheet.group,table);
        K := Normalizer(sheet.group,Subgroup(sheet.group,gens));
    fi;

    # extract the new generators
    newgens := Filtered( K.generators, x -> not x in gens );

    # if <newgens> is empty then <K> = <ver.group>
    if 0 = Length(newgens)  then
        ver.isNormal := false;
        ver.normalizer := ver;
        return ver;
    else
        K.cosetTable := BlocksCosetTable( sheet.group, newgens, table );
        Kindex := Length(K.cosetTable[1]);
        if Kindex = 1  then
            ver.isNormal := true;
            ver.normalizer := ver;
            sheet.operations.Reshape( sheet, ver );
            Print( "#I  ", ver, " is normal.\n" );
            return ver;
        else
            ver.isNormal := false;
        fi;
        vertex := sheet.operations.InsertSubgroup(
                          sheet, K, Kindex, "cosetTable", ver.x );
        ver.normalizer := vertex;
        return vertex;
    fi;
end;
  
  
#############################################################################
##
#F  InteractiveFpLatticeOps.FindPrimeQuotient(<sheet>,<ver>,<prime>,<class>)
##
InteractiveFpLatticeOps.FindPrimeQuotient := function(sheet,ver,prime,class)
    local   class,  H,  c,  next,  pq,  new,  Kindex,  K,  i,  vertex,  
            L;
          
    # if this a pq result change the starting point
    if IsBound(ver.pqstart) and IsBound(ver.pqstart[prime])  then
        c := PositionProperty( ver.pqstart[prime].pqs[prime], x->x[1]=ver );
        class := class + c;
        ver := ver.pqstart[prime];
    else
        c := 0;
    fi;
    sheet.operations.MakeFpGroup( sheet, ver );

    # check if the groups have been calculated already 
    if not IsBound(ver.pqs)  then
        ver.pqs := [];
    fi;
    if IsBound(ver.pqs[prime]) and 0 < Length(ver.pqs[prime]) then
        if class <= Length(ver.pqs[prime])  then
            return List( ver.pqs[prime]{[c+1..class]}, x -> x[1] );
        fi;
        new := List(ver.pqs[prime]{[c+1..Length(ver.pqs[prime])]}, x->x[1]);
        c := Length(ver.pqs[prime]);
        next := ver.pqs[prime][c][1];
        pq := ver.pqs[prime][c][2];
    else
        new := [];
        ver.pqs[prime] := [];
        next := ver;
        c := 0;
    fi;
    
    repeat
        if c = 0  then
            pq := FirstClassPQp( ver.fpGroup, prime );
        else
            pq := NextClassPQp( ver.fpGroup, pq );
        fi;

        # initialize Kindex
        Kindex := ver.index;
        
        if Length(pq.dimensions) <= c  then
            Print("#I  Exponent-",prime,"-nilpotent quotient stopped ");
            Print("before class ",c+1,".\n");
            return new;
        else

            # the record pq has changed, so copy it to L
            K               := PseudoSubgroup(ver.fpGroup);
            K.pq            := pq;
            K.ag            := AgGroupPcp(pq.pcp);
            K.pqEpimorphism := Copy(pq.epimorphism);
            K.pqGenerators  := Copy(pq.generators);
            K.pqDefinedBy   := Copy(pq.definedby);
        fi;
        
        # calculate the correct index
        for i in pq.dimensions  do
            Kindex := Kindex * prime^i; 
   
        od;
        Print( "#I  found quotient of size ", prime, "^",
               Sum(pq.dimensions), "\n" );
        
        # insert the new vertices 
        vertex := sheet.operations.InsertSubgroup(
                      sheet, K, Kindex, "pq",
                      sheet.selected[1].x+VERTEX.diameter );
        Add( new, vertex );
        vertex.pqstart := [];
        vertex.pqstart[prime] := ver;
        ver.pqs[prime][c+1] := [ vertex, pq ];
       
        # connect the two vertices
        if not vertex in next.maximals  then
            Add( next.maximals, vertex );
            Connection( vertex, next );
        fi;
        next := vertex;
        
        # check if the new vertex is normal
        if IsBound(ver.isNormal) and ver.isNormal  then
            vertex.isNormal := true;
            sheet.operations.Reshape( sheet, vertex );
        fi;
        
        c := c+1;
        L := K;
    until c = class;

    return new;
        
end;


#F  # # # # # # # # # # # # # #  Dialogs  # # # # # # # # # # # # # # # # # #


#############################################################################
##

#V  InteractiveFpLatticeOps.PDClass . . . . . . . . . .  "enter class" dialog
##
InteractiveFpLatticeOps.PDClass := Dialog( "OKcancel", "Class" );


#############################################################################
##
#V  InteractiveFpLatticeOps.PDDimension . . . . . .  "enter dimension" dialog
##
InteractiveFpLatticeOps.PDDimension := Dialog( "OKcancel", "Dimension" );


#############################################################################
##
#V  InteractiveFpLatticeOps.PDDegree  . . . . . . . . . "enter degree" dialog
##
InteractiveFpLatticeOps.PDDegree := Dialog( "OKcancel", "Degree" );


#############################################################################
##
#V  InteractiveFpLatticeOps.PDLimit . . . . . . . . . .  "enter limit" dialog
##
InteractiveFpLatticeOps.PDLimit := Dialog( "OKcancel", "Limit" );


#############################################################################
##
#V  InteractiveFpLatticeOps.PDFieldSize	. . . . . . "enter field size" dialog
##
InteractiveFpLatticeOps.PDFieldSize := Dialog( "OKcancel", "FieldSize" );


#F  # # # # # # # # # # # # # # Epimorphims # # # # # # # # # # # # # # # # #


#############################################################################
##

#F  InteractiveFpLatticeOps.EMShowResult( <sel>, <bt> )  . . . show subgroups
##
InteractiveFpLatticeOps.EMShowResult := function( sel, bt )
    local   act,  sheet,  new,  i,  v;

    # action is either "cosetTable" or "cosetTableSubgroup"
    if sel.info.vertex.index = 1  then
        act := "cosetTable";
    else
        act := "cosetTableSubgroup";
    fi;

    # create the vertices
    sheet := sel.info.sheet;
    new   := ShallowCopy(sel.info.result);
    for i  in [ 1 .. Length(new) ]  do
        v := PseudoSubgroup(sel.info.vertex.fpGroup);
        v.cosetTable := new[i];
        v := sheet.operations.InsertSubgroup( sheet, v,
                     Length(new[i][1])*sel.info.vertex.index, act, 
                     i*QuoInt(sheet.width,Length(new)+1) );
        new[i] := v;
    od;

    # check, if one group is subgroup of other
    if 1 < sel.info.vertex.index  then
        for i  in new  do
            Connection( sel.info.vertex, i );
        od;
        sel.info.sheet.operations.FindImplicitConnections(sel.info.sheet);
    fi;

    # close the selector and show the result
    Close(sel);
    Unbind(sheet.selector);
    sheet.operations.ShowResult( sheet, sheet.selected, new );
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.EMFindEpimorphisms( <sel>, <g>, <u>, <r> )
##
InteractiveFpLatticeOps.EMFindEpimorphisms := function( sel, g, u, r )
    local   res,  txt,  tbl,  tid;

    # adjust the text width of <r>
    res := String( r, sel.info.width );

    # compute the epimorphisms to <g> containing <u>
    txt := ShallowCopy(sel.info.text);
    tid := sel.selected;
    txt[tid] := Concatenation( res, "computing" );
    Relabel( sel, txt );
    tbl := sel.info.sheet.operations.FindEpimorphisms(
               sel.info.sheet, sel.info.vertex, g, u, true );

    # show the number of epimorphisms found
    txt := ShallowCopy(sel.info.text);
    txt[tid] := Concatenation( res, String(Length(tbl),3), " found" );
    Relabel( sel, txt );

    # if we found any epimorphism, enable "display"
    if 0 < Length(tbl)  then
        Enable( sel, "display" );
        sel.info.result := tbl;
    else
        Enable( sel, "display", false );
    fi;

end;


#############################################################################
##
#F  InteractiveFpLatticeOps.EMAlternatingGroup( <sel>, <tid> )  . . .  alt(n)
##
InteractiveFpLatticeOps.EMAlternatingGroup := function( sel, tid )
    local   res,  grp;
    
    res := Query( InteractiveFpLatticeOps.PDDegree );
    if res = false  then
        return;
    fi;
    res := IntString(res);
    if res < 3  then
        return;
    fi;
    grp := AlternatingGroup(res);
    res := Concatenation( "Alt(", String(res), ")" );
    return sel.info.sheet.operations.EMFindEpimorphisms(
               sel, grp, grp, res );
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.EMLibrary( <sel>, <tid> ) . . load a library file
##
InteractiveFpLatticeOps.EMLibrary := function( sel, tid )
    local   res,  grp;
    
    res := ReplacedString( XGAPLIBNAME, "lib", "pmg" );
    res := Query( FILENAME_DIALOG, res );
    if res = false  then
        return;
    fi;
    PERM_GROUP := 0;
    if not READ(res)  then
        return Concatenation( "cannot read file ", res );
    elif IsInt(PERM_GROUP)  then
        return Concatenation( res, " does not define PERM_GROUP" );
    fi;
    grp := PERM_GROUP;
    Unbind(PERM_GROUP);
    res  := Concatenation( "Library (", ReplacedString(
                grp.filename, ".grp", "" ), ")" );
    return sel.info.sheet.operations.EMFindEpimorphisms(
               sel, grp, grp, res );
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.EMPSL( <sel>, <tid> ) . . . . . . . . .  PSL(d,q)
##
InteractiveFpLatticeOps.EMPSL := function( sel, tid )
    local   res,  grp,  d,  q;
    
    # get dimension
    res := Query( InteractiveFpLatticeOps.PDDimension );
    if res = false  then
        return;
    fi;
    d := IntString(res);
    if not IsInt(d) or d < 1  then
        return;
    fi;

    # get field size
    res := Query( InteractiveFpLatticeOps.PDFieldSize );
    if res = false  then
        return;
    fi;
    q := IntString(res);
    if not IsInt(d) or not IsPrimePowerInt(q)  then
        return;
    fi;
    
    # construct the group and find the epimorphisms
    grp := PSL(d,q);
    res := Concatenation( "PSL(", String(d), ",", String(q), ")" );
    return sel.info.sheet.operations.EMFindEpimorphisms(
               sel, grp, grp, res );
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.EMSymAltGroup( <sel>, <tid> ) . . sym(n) > alt(n)
##
InteractiveFpLatticeOps.EMSymAltGroup := function( sel, tid )
    local   res,  grp1,  grp2;
    
    res := Query( InteractiveFpLatticeOps.PDDegree );
    if res = false  then
        return;
    fi;
    res  := IntString(res);
    grp1 := SymmetricGroup(res);
    grp2 := DerivedSubgroup(grp1);
    res  := Concatenation("Sym(",String(res),") > Alt(",String(res),")" );
    return sel.info.sheet.operations.EMFindEpimorphisms(
               sel, grp1, grp2, res );
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.EMSymmetricGroup( <sel>, <tid> )  . . . .  sym(n)
##
InteractiveFpLatticeOps.EMSymmetricGroup := function( sel, tid )
    local   res,  grp;
    
    res := Query( InteractiveFpLatticeOps.PDDegree );
    if res = false  then
        return;
    fi;
    res := IntString(res);
    if res < 3  then
        return;
    fi;
    grp := SymmetricGroup(res);
    res := Concatenation( "Sym(", String(res), ")" );
    return sel.info.sheet.operations.EMFindEpimorphisms(
               sel, grp, grp, res );
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.EMUserDefined( <sel>, <tid> ) . . .  user defined
##
InteractiveFpLatticeOps.EMUserDefined := function( sel, tid )
    local   txt,  grp,  res;
    
    if not IsBound(PERM_GROUP) or IsInt(PERM_GROUP)  then
        txt := ShallowCopy(sel.info.text);
        tid := sel.selected;
        txt[tid] := "Define variable PERM_GROUP & click here!";
        Relabel( sel, txt );
    else
        grp := PERM_GROUP;
        res := sel.info.text[sel.selected];
        return sel.info.sheet.operations.EMFindEpimorphisms(
                   sel, grp, grp, res );
    fi;
end;


#F  # # # # # # # # # # # # # Information Functions # # # # # # # # # # # # #


#############################################################################
##

#F  InteractiveFpLatticeOps.SIAbelianInvariants( sheet, obj, flag ) . . . inv
##
InteractiveFpLatticeOps.SIAbelianInvariants := function( sheet, obj, flag )
    local   v,  p,  i,  num,  str1;

    # if don't know the invariants and <flag> is false return
    if not IsBound(obj.abelianInvariants) and not flag  then
        return "unknown";
    fi;

    # if we don't know compute the presentation
    if not IsBound(obj.abelianInvariants)  then
        sheet.operations.MakeFpGroup( sheet, obj );
        if sheet.operations.IsTrivial( sheet, obj )  then
            obj.abelianInvariants := [];
        else
            obj.abelianInvariants :=
              AbelianInvariantsSubgroupFpGroup( obj.fpGroup, obj.fpGroup );
        fi;
    fi;
    sheet.result := obj.abelianInvariants;

    # construct a nice string
    if 0 = Length(obj.abelianInvariants)  then
        p := "perfect";
    else
        v := Reversed(Set(obj.abelianInvariants));
        p := [];
        for i  in v  do
            num := Number( obj.abelianInvariants, x -> x =  i );
            if num > 1 then
                str1 := ConcatenationString(String(i),"^",String(num));
            else
                str1 :=  String(i);
            fi;
            Add( p, str1 );
            Add( p, " " );
        od;
        p := Concatenation(p);
    fi;
    return p;

end;


#############################################################################
##
#F  InteractiveFpLatticeOps.SICosetTable( sheet, obj, flag )  . . coset table
##
InteractiveFpLatticeOps.SICosetTable := function( sheet, obj, flag )
    local   table;

    if obj.action <> "cosetTable" and not flag  then
        return "unknown";
    fi;
    table := sheet.operations.MakeCosetTable( sheet, obj );
    if table <> false  then
        sheet.result := table;
        return "known";
    else
        return "not computable";
    fi;

end;    


#############################################################################
##
#F  InteractiveFpLatticeOps.SIFactorFpGroup( sheet, obj, flag )  factor group
##
InteractiveFpLatticeOps.SIFactorFpGroup := function( sheet, obj, flag )
    local   normal,  i,  j,  table,  Q,  R,  abInv,  L;

    if IsBound(obj.isNormal) and not obj.isNormal  then
        return "not normal";
    fi;
    if not IsBound(obj.factorFpGroup) and not flag  then
        return "unknown";
    fi;
    if not IsBound(obj.factorFpGroup)  then
        normal := sheet.operations.IsNormal( sheet, obj );
        if IsString(normal)  then
            return normal;
        elif not normal  then
            return "not normal";
        fi;
        if obj.index = 1  then
            Q            := rec();
            Q.generators := [];
            Q.relators   := [];
        elif obj.action = "abelianQuotient" and obj.group.parent.vno = 1 then
            abInv := obj.group.invariantsQuotient;
            Q := FreeGroup( Length(abInv) );
            R := [];
            for i  in [1 .. Length(abInv)]  do
                if abInv[i] <> 0  then
                    Add( R, Q.generators[i]^abInv[i] );
                fi;
                for j  in [ 1 .. i-1 ]  do
                    Add( R,Comm(Q.generators[i], Q.generators[j]) );
                od;
            od;
            Q := Q / R;
        elif obj.action = "pq" and obj.group.parent.vno = 1  then
            Q := FpGroup(obj.group.ag);
        else
            table := sheet.operations.MakeCosetTable( sheet, obj );
            if table = false  then
                return "not computable";
            fi;
            L := PseudoSubgroup(sheet.group);
            L.action := "cosetTable";
            L.cosetTable := table;
            AddSchreierGens(L);
            R := Concatenation( sheet.group.relators, L.generators );
            Q := sheet.group / R;
        fi;
        obj.factorFpGroup := Q;
    fi;
    sheet.result := obj.factorFpGroup;
    return Concatenation(
       String( Length(obj.factorFpGroup.generators) ),
       " gens, ", String( Length(obj.factorFpGroup.relators) ),
       " rels" );

end;


#############################################################################
##
#F  InteractiveFpLatticeOps.SIIndex( sheet, obj, flag ) . . . . . . . . index
##
InteractiveFpLatticeOps.SIIndex := function( sheet, obj, flag )
    sheet.result := obj.index;
    return String(obj.index);
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.SIIsNormal( sheet, obj, flag )  . . . . is normal
##
InteractiveFpLatticeOps.SIIsNormal := function( sheet, obj, flag )
    local   normal;

    # check if already know if <obj> is normal
    if IsBound(obj.isNormal)  then 
        sheet.result := obj.isNormal;
        if obj.isNormal  then
            return "true";
        else
            return "false";
        fi;
    fi;

    # if <flag> is false don't compute if it is normal
    if not flag  then
        return "unknown";
    fi;
    normal := sheet.operations.IsNormal( sheet, obj );
    if IsString(normal)  then
        return normal;
    elif normal  then
        sheet.result := obj.isNormal;
        return "true";
    else
        sheet.result := obj.isNormal;
        return "false";
    fi;

end;


#############################################################################
##
#F  InteractiveFpLatticeOps.SIPresentation( sheet, obj, flag )	 presentation
##
InteractiveFpLatticeOps.SIPresentation := function( sheet, obj, flag )

    # check if know a presentation
    if not IsBound(obj.fpGroup) and not flag  then
        return "unknown";
    fi;

    # compute the presentation
    if not IsBound(obj.fpGroup)  then
        sheet.operations.MakeFpGroup( sheet, obj );
    fi;
    sheet.result := obj.fpGroup;
    return Concatenation(
       String( Length(obj.fpGroup.generators) ),
       " gens, ", String( Length(obj.fpGroup.relators) ),
       " rels" );

end;


#############################################################################
##

#F  InteractiveFpLatticeOps.PMInformation( <sheet>, <obj> ) . . . information
##
InteractiveFpLatticeOps.PMInformation := function( sheet, obj )
    local   info,  text,  str,  i,  func,  width;
    
    # destroy other text selectors flying around
    if IsBound(sheet.selector)  then
        Close(sheet.selector);
    fi;
   
    # construct info texts (text, record component, function)
    info := [
      [ "Index",               sheet.operations.SIIndex             ],
      [ "IsNormal",            sheet.operations.SIIsNormal          ],
      [ "Abelian Invariants",  sheet.operations.SIAbelianInvariants ],
      [ "Presentation",        sheet.operations.SIPresentation      ],
      [ "Coset Table",         sheet.operations.SICosetTable        ],
      [ "Factor Fp Group",     sheet.operations.SIFactorFpGroup     ]
    ];
    width := Maximum( List( info, x -> Length(x[1]) ) ) + 2;
   

    # text select function
    func := function( sel, tid )
        local    res;

        tid := sel.selected;
        text := ShallowCopy(sel.labels);
        sheet.result := "failed";
        str := String( info[tid][1], -width );
        Append( str, info[tid][2]( sheet, obj, true ) );
        text[tid] := str;
        res := sheet.result;
        for i  in [ 1 .. Length(info) ]  do
            if i <> tid  then
                str := String( info[i][1], -width );
                Append( str, info[i][2]( sheet, obj, false ) );
                text[i] := str;
            fi;
        od;
        sheet.result := res;
        Relabel( sel, text );
    end;
   
    # construct the string
    text := [];
    for i  in info  do
        str := String( i[1], -width );
        Append( str, i[2]( sheet, obj, false ) );
        Add( text, str );
        Add( text, func );
    od;

    # button select function
    func := function( sel, bt )
        Close(sel);
        Unbind(sheet.selector);
    end;

    # construct text selector
    sheet.selector := TextSelector( Concatenation(
        "          Information about ", obj.label.text, "          " ),
        text,
        [ "close", func ] );
               
end;


#F  # # # # # # # # # # # # # # #  Menus  # # # # # # # # # # # # # # # # # #


#############################################################################
##  

#F  InteractiveFpLatticeOps.SMAbelianPQuotient( ... ) . .  abelian p quotient
##
InteractiveFpLatticeOps.SMAbelianPQuotient := function( sheet, menu, name )
    local   ver,  prime,  class,  new;

    # get the vertex
    ver := sheet.selected[1];

    # first check, if <ver.group> is the trivial subgroup 
    if sheet.operations.IsTrivial( sheet, ver )  then
        Print( "#I  Subgroup is the trivial subgroup\n" );
    fi;

    # dialog-menu: get the prime and check whether it is a prime
    prime := Query(sheet.operations.PDPrime);
    if prime = false  or prime = ""  then
        return;
    fi;
    prime := IntString(prime);
    if not IsPrime(prime) then
        Print( "#I  ", prime, " is not a prime!\n" );
        return;
    fi;

    # compute the new subgroups
    new := sheet.operations.FindPrimeQuotient( sheet, ver, prime, 1 );
    if 0 < Length(new)  then
        InfoGraphicLattice1( "#I  Abelian-", prime, "-Quotients(",
                             ver.label.text, ") = ", new[1].label.text,
                             "\n" );
    else
        InfoGraphicLattice1( "#I  Abelian-", prime, "-Quotients(",
                             ver.label.text, ") = trivial\n" );
    fi;

    sheet.operations.ShowResult( sheet, sheet.selected, new );
end;
  

#############################################################################
##
#F  InteractiveFpLatticeOps.SMAllOverGroups( ... ) . all over groups of group
##
InteractiveFpLatticeOps.SMAllOverGroups := function( sheet, menu, name )
    local   ver,  new;

    # check if the selected group is the whole group
    ver := sheet.selected[1];
    if ver.index = 1  then
        new := [ver];

    # otherwise find all over groups
    else
        new := sheet.operations.FindAllOverGroups( sheet, ver );
        if new = false  then return;  fi;
    fi;
    sheet.operations.ShowResult( sheet, sheet.selected, new );
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.SMConjugacyClass( ... )  conjugacy class of group
##
InteractiveFpLatticeOps.SMConjugacyClass := function( sheet, menu, name )
    local   ver,  new;

    # get the selected one
    ver := sheet.selected[1];

    # selected group is sheet.group
    if ver.index = 1  then
        ver.normalizer := ver;
        new := [ver];

    # compute the conjugacy class
    else
        new := sheet.operations.FindConjugacyClass( sheet, ver );
        if new = false  then return;  fi;
    fi;

    sheet.operations.ShowResult( sheet, sheet.selected, new );
end;
    
    
#############################################################################
##
#F  InteractiveFpLatticeOps.SMCores( ... )  . . . . . . . . .  core of groups
##
InteractiveFpLatticeOps.SMCores := function( sheet, menu, name )
    local   old,  new,  sel,  table,  res;
  
    new := [];
    old := ShallowCopy(sheet.selected);

    # keep in mind that vertices *might* get deleted during the computation
    for sel  in old  do
        if sel.isAlive  then
            res := sheet.operations.FindCore( sheet, sel );
            if res <> false  then
                Add( new, res );
                InfoGraphicLattice1( "#I  Core(",
                    sel.label.text, ") = ", res.label.text, "\n" );
            fi;
        fi;
    od;
    old := Filtered( old, x -> x.isAlive );

    # mark the result
    sheet.operations.ShowResult( sheet, old, new );

end;
  

#############################################################################
##
#F  InteractiveFpLatticeOps.SMDerivedSubgroups( ... ) . . . derived subgroups
##
InteractiveFpLatticeOps.SMDerivedSubgroups := function( sheet, menu, name )
    local   new,  old,  sel,  res;

    new := [];
    old := ShallowCopy(sheet.selected);

    # keep in mind that vertices *might* get deleted during the computation
    for sel  in old  do
        if sel.isAlive  then
            res := sheet.operations.FindDerivedSubgroup( sheet, sel );
            if res <> false  then
                Add( new, res );
                InfoGraphicLattice1( "#I  DerivedSubgroup(",
                    sel.label.text, ") = ", res.label.text, "\n" );
            fi;
        fi;
    od;
    old := Filtered( old, x -> x.isAlive );

    # mark the result
    sheet.operations.ShowResult( sheet, old, new );
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.SMEpimorphisms( ... ) . . . . . . .  epimorphisms
##
InteractiveFpLatticeOps.SMEpimorphisms := function( sheet, menu, name )
    local   obj,  info,  width,  text,  i,  func;

    # get the selected vertex
    obj := sheet.selected[1];

    # destroy other text selectors flying around
    if IsBound(sheet.selector)  then
        Close(sheet.selector);
    fi;
   
    # construct text describing the groups
    info := [
      "Sym(n)",	              sheet.operations.EMSymmetricGroup,
      "Alt(n)",               sheet.operations.EMAlternatingGroup,
      "Sym(n) > Alt(n)",      sheet.operations.EMSymAltGroup,
      "PSL(d,q)",             sheet.operations.EMPSL,
      "Library",              sheet.operations.EMLibrary,
      "User Defined",         sheet.operations.EMUserDefined,
    ];
    width := Maximum(List(info{[1,3..Length(info)-1]},Length))+8;
    text  := [];
    for i  in [ 1, 3 .. Length(info)-1 ]  do
        info[i] := String( info[i], -width );
        Add( text, info[i] );
    od;

    # close function
    func := function( sel, bt )
        Close(sel);
        Unbind(sheet.selector);
    end;

    # construct a text selector
    sheet.selector := TextSelector(
        Concatenation(
        "          Epimorphisms from ", obj.label.text, "           " ),
        info, [ "display", sheet.operations.EMShowResult, "close", func ]
    );
    Enable( sheet.selector, "display", false );

    # store some info inside the selector
    sheet.selector.info := rec();
    sheet.selector.info.width  := -width;
    sheet.selector.info.text   := text;
    sheet.selector.info.vertex := obj;
    sheet.selector.info.sheet  := sheet;

end;


#############################################################################
##
#F  InteractiveFpLatticeOps.SMIntersections( ... )  .  interscetion of groups
##
InteractiveFpLatticeOps.SMIntersections := function( sheet, menu, name )
    local   lst,  i,  j,  sel1,  sel2,  sel,  H1,  H2,  U,  H,  new;
    
    lst := ShallowCopy(sheet.selected);
    i   := 1;
    j   := 1;
    new := [];
    while i < Length(lst)   do
        j := i + 1;
        while j <= Length(lst)   do
            sel1 := lst[i];
            sel2 := lst[j];
            
            if sel1.isAlive and sel2.isAlive  then
                if sel2.index < sel1.index  then
                    sel := sel2; sel2 := sel1; sel1 := sel;
                fi;
            
                # now index of  H1 in G is no no bigger than index of H2,
                # if those indices are known.
                H1 := sel1.group;
                H1.index := sel1.index;
                H2 := sel2.group; 
                H2.index := sel2.index;

                # We're trying to find the least common parent of H1 and H2.
                if IsBound(sel1.fpGroup)  then
                    U := sel1.fpGroup;
                else 
                    U := H1.parent;
                fi;
            
                # If there isn't a f.p. group corresponding to H1, 
                # H1 itself cannot possible be the parent of H2, so we can go
                # straightaway to the parent of H1.
            
                if U.vno = 1  then
                    H := sheet.group;
                else 
                    H := H2;
                fi;
            
                while  U.vno <> 1 and  U.vno <> H.vno  do
                    while H.vno <> 1 and  U.vno <> H.vno  do
                        H := sheet.vertices[H.parent.vno].group;
                    od;
                    if U.vno <> 1 and  U.vno <> H.vno  then
                        U := sheet.vertices[U.vno].group.parent;
                    fi;
                od;
            
                # Now  the pair of groups H,U correspond to the vertex
                # which is the least common parent of H1 and H2.
            
                if H.vno = H2.vno  then
                    sheet.operations.MergeVertices( sheet, sel1, sel2 );
                elif H.vno = H1.vno  then
                    Print( "#I  ", sel2, " is a subgroup of ", sel1, "\n" );
                    if not sel2 in sel1.connections  then
                        Connection( sel1, sel2 );
                        Add( sel1.maximals, sel2 );
                        sheet.operations.FindImplicitConnections(sheet);
                    fi;
                else

                    # So H1  and H2 are both   proper subgroups of H,  and we
                    # need to build the relevant coset tables.
                    Add( new, sheet.operations.FindIntersection(
                            sheet, sel1, sel2, sheet.vertices[H.vno] ) );
                fi;
            fi;
            j := j + 1;
        od;
        i := i + 1;
    od;
    sheet.operations.ShowResult( sheet, sheet.selected, new );
end;    


#############################################################################
##
#F  InteractiveFpLatticeOps.SMLowIndexSubgroups( ... ) subgroups of low index
##
InteractiveFpLatticeOps.SMLowIndexSubgroups := function( sheet, menu, name )
    local   old,  new,  res;

    # compute the new subgroups
    old := sheet.selected[1];
    new := sheet.operations.FindLowIndexSubgroups( sheet, old );

    # give some information
    for res  in new  do
    	InfoGraphicLattice1( "#I  Index-", res.index/old.index,
                             "-Subgroup(", old.label.text, ") = ", 
                             res.label.text, "\n" );
    od;
    sheet.operations.ShowResult( sheet, [old], new );
         
end;
  

#############################################################################
##
#F  InteractiveFpLatticeOps.SMNormalizers( ... ) . . . . normalizer of groups
##
InteractiveFpLatticeOps.SMNormalizers := function( sheet, menu, name )
    local   old,  new,  sel,  res;
  
    new := [];
    old := ShallowCopy(sheet.selected);

    # keep in mind that vertices *might* get deleted during the computation
    for sel  in old  do
        if sel.isAlive  then
            res := sheet.operations.FindNormalizer( sheet, sel );
            if res <> false  then
                Add( new, res );
                InfoGraphicLattice1( "#I  Normailzer(", sel.label.text,
                                     ") = ", res.label.text, "\n" );
            fi;
        fi;
    od;
    sheet.operations.ShowResult( sheet, sheet.selected, new );
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.SMPrimeQuotient( ... ) . . . . . . prime quotient
##
InteractiveFpLatticeOps.SMPrimeQuotient := function( sheet, menu, name )
    local   ver,  prime,  class,  new,  res;

    # get the vertex
    ver := sheet.selected[1];

    # first check, if <ver.group> is the trivial subgroup 
    if sheet.operations.IsTrivial( sheet, ver )  then
        Print( "#W  Subgroup is the trivial subgroup\n" );
        return;
    fi;

    # dialog-menu: get the prime and check whether it is a prime
    prime := Query(sheet.operations.PDPrime);
    if prime = false  or prime = ""  then
        return;
    fi;
    prime := IntString(prime);
    if not IsPrime(prime) then
        Print( "#W  ", prime, " is not a prime!\n" );
        return;
    fi;

    # dialog-menu: get the class and check if the entry was right
    class := Query(sheet.operations.PDClass);
    if class = false  or class = "" then
        return;
    fi;
    class := IntString(class);
    
    # compute the new subgroups
    new := sheet.operations.FindPrimeQuotient( sheet, ver, prime, class );
    InfoGraphicLattice1("#I  ",prime,"-Quotients(",ver.label.text,") = ");
    for res  in new  do
        InfoGraphicLattice1( res.label.text, " " );
    od;
    if 0 = Length(new)  then
        InfoGraphicLattice1( "trivial" );
    fi;
    InfoGraphicLattice1( "\n" );

    # mark the result
    sheet.operations.ShowResult( sheet, sheet.selected, new );
end;


#############################################################################
##

#F  InteractiveFpLatticeOps.CMDeleteVertex( ... )  delete one selected vertex
##
InteractiveFpLatticeOps.CMDeleteVertex := function( sheet, menu, name )
    local   ver;

    ver := sheet.selected[1];
    sheet.operations.DeselectAll(sheet);
    sheet.operations.DeleteVertex( sheet, ver );
end;


#############################################################################
##
#F  InteractiveFpLatticeOps.CMCheckVertices( ... )  . . . . check coset table
##
InteractiveFpLatticeOps.CMCheckVertices := function( sheet, menu, name )
    local   ver;

    for ver in  sheet.selected  do
        if ver.action <> "cosetTable"  then
            sheet.operations.MakeCosetTable( sheet, ver );
        fi;
    od;
end;
 

#F  # # # # # # # # # # # # # #  Button Functions   # # # # # # # # # # # # #


#############################################################################
##

#F  InteractiveFpLatticeOps.DragVertex( <sheet>, <obj>, <sft> )   drag vertex
##
InteractiveFpLatticeOps.DragVertex := function( sheet, obj, sft )
    local   oldy,  drag,  dy,  ver,  pos,  i;

    # use the method of our parent
    oldy := obj.y;
    drag := GraphicLatticeOps.DragVertex( sheet, obj, sft );

    # if the obj has moved update the strip
    if drag  then
        if not sft  then
            dy := obj.y - oldy;
            for ver  in sheet.strips[obj.strip]  do
                if ver.classRep <> obj  then
                    if ver.index = obj.index  then
                        obj.operations.MoveDelta( ver, 0, dy );
                    fi;
                fi;
            od;
        else
            pos := [];
            pos[obj.strip] := obj.y;
            for ver  in sheet.selected  do
                pos[ver.strip] := ver.y;
            od;
            for i  in [ 1 .. Length(pos) ]  do
                if IsBound(pos[i])  then
                    for ver  in sheet.strips[i]  do
                        Move( ver, ver.x, pos[i] );
                    od;
                fi;
            od;
        fi;
    fi;

end;


#F  # # # # # # # #  Functions used for the Initial Setup   # # # # # # # # #


#############################################################################
##

#F  InteractiveFpLatticeOps.MakeMenus( <sheet> )  . menus for a lattice sheet
##
InteractiveFpLatticeOps.MakeMenus := function( sheet )
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
        [
          "Abelian Prime Quotient",  sheet.operations.SMAbelianPQuotient,
          "All Overgroups",          sheet.operations.SMAllOverGroups,
          "Conjugacy Class",         sheet.operations.SMConjugacyClass,
          "Cores",                   sheet.operations.SMCores,
          "Derived Subgroups",       sheet.operations.SMDerivedSubgroups,
          "Epimorphisms",            sheet.operations.SMEpimorphisms,
          "Intersections",           sheet.operations.SMIntersections,
          "Low Index Subgroups",     sheet.operations.SMLowIndexSubgroups,
         #"Nilpotent Series",        sheet.operations.SMNilpSeries,
          "Normalizers",             sheet.operations.SMNormalizers,
          "Prime Quotient",          sheet.operations.SMPrimeQuotient
        ] );
    Add( sheet.updateMenus0, [ menu, [
           "Cores", "Derived Subgroups", "Normalizers" ] ] );
    Add( sheet.updateMenus1, [ menu, [
           "Intersections" ] ] );
    Add( sheet.updateMenusEq1, [ menu, [
           "Low Index Subgroups", "Prime Quotient", "All Overgroups",
           "Abelian Prime Quotient", "Conjugacy Class",
           "Epimorphisms" ] ] );
    
    # create clean up menu
    tmp := [ "Check Coset Tables",  sheet.operations.CMCheckVertices,
             ,		            Ignore,
             "Deselect All",        sheet.operations.CMDeselectAll,
             "Delete Vertex",       sheet.operations.CMDeleteVertex
    ];
    if sheet.color.model = "color"  then
        Append( tmp, [ , Ignore,
             "Use Black&White", sheet.operations.CMUseBlackWhite ] );
    fi;
    sheet.cleanUpMenu := Menu( sheet, "CleanUp", tmp );
    Add( sheet.updateMenus0, [ sheet.cleanUpMenu, [
           "Deselect All", "Check Coset Tables" ] ] );
    Add( sheet.updateMenusEq1, [ sheet.cleanUpMenu, [
           "Delete Vertex" ] ] );

end;


#############################################################################
##
#F  FpGroupOps.InteractiveLattice( <G>, <x>, <y> ) . . . .  display a lattice
##
FpGroupOps.InteractiveLattice := function( arg )
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
    if 0 = Length(G.generators)  then
        return Error( "<G> must be non-trivial" );
    fi;
    if not IsBound(G.relators)  then
        G := ShallowCopy(G);
        G.relators := [];
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
    sheet.operations := InteractiveFpLatticeOps;

    # select a color model
    sheet.color := rec();
    if COLORS.red <> false or COLORS.lightGray <> false  then
        sheet.color.model := "color";
    else
        sheet.color.model := "monochrome";
    fi;
    sheet.operations.MakeColors(sheet);
    sheet.vertices := []; 

    # store information in <sheet>
    sheet.group := G;

    # create a coset table in <G>
    G.cosetTable := CosetTableFpGroup( G, G );
    sheet.strips := [ [] ];

    # create one initial vertex
    v := Vertex( sheet, QuoInt(sheet.width,2), VERTEX.radius );
    v.action      := "cosetTable";
    v.fpGroup     := G;
    v.group       := G;
    v.isNormal    := true; 
    v.index       := 1;
    v.strip       := 1;
    v.maximals    := [];
    v.isClassRep  := true;
    v.classRep    := v;
    v.class       := [v];
    Relabel( v, "1" );
    Add( sheet.vertices, v );
    Add( sheet.strips[v.strip], v );

    # create menus
    sheet.operations.MakeMenus(sheet);

    # <G> is selected at first and is vertex number "1"
    sheet.selected := []; 
    sheet.operations.ToggleSelection( sheet, sheet.vertices[1] );
    sheet.operations.Reshape( sheet, sheet.vertices[1] );
    G.vno := 1;
    
    # add pointer action to <sheet>
    InstallGSMethod(sheet,"LeftPBDown",     sheet.operations.LeftButton     );
    InstallGSMethod(sheet,"RightPBDown",    sheet.operations.RightButton    );
    InstallGSMethod(sheet,"ShiftLeftPBDown",sheet.operations.ShiftLeftButton);
    InstallGSMethod(sheet,"CtrlLeftPBDown", sheet.operations.ShiftLeftButton);

    # and enable/disable entries
    sheet.operations.UpdateMenus(sheet);

    return sheet;

end;
InteractiveFpLattice := FpGroupOps.InteractiveLattice;
