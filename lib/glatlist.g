#############################################################################
##
#A  glatlist.g                 	XGAP library                     Frank Celler
##
#H  @(#)$Id: glatlist.g,v 1.1 1997/11/27 12:19:53 frank Exp $
##
#Y  Copyright (C) 1995,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##
##  This  file contains the non-interactive  lattice  program.  The following
##  functions are implemented:
##
##  'GraphicLattice( <rec>[, <x>, <y>][, "prime"] )
##  ------------------------------------------------
##
##  'GraphicLattice' draws the lattice described by a record containing:
##
##  'vertices':
##    a list of objects
##
##  'classPositions':
##    A pair '[<c>,<p>]', where <c> is a class number and <p> is the position
##    in this  class    meaning  that  vertex number    <i>   lies in   class
##    'classes[<i>][1]' at position 'classes[<i>][2]'.
##
##  'sizes':
##    a list of sizes
##
##  'maximals':
##    a list of maximals
##
##  an example
##  ----------
##
##  MyLattice := rec(
##    vertices := [ 1 .. 7 ],
##    maximals := [ [3], [3], [4,6,7], [], [], [5], [] ],
##    classPositions := [ [1,1], [2,1], [3,1], [4,1], [5,1], [6,1], [4,2] ]
##  );
##
#H  $Log: glatlist.g,v $
#H  Revision 1.1  1997/11/27 12:19:53  frank
#H  added 3.5 library (does not work with 4.0)
#H
#H  Revision 1.7  1995/09/24  14:36:29  fceller
#H  changed resize menu entries
#H
#H  Revision 1.6  1995/07/28  09:59:33  fceller
#H  changed "black&white" to "monochrome"
#H
#H  Revision 1.5  1995/04/10  11:33:57  skeiteme
#H  changed labelling of vertices
#H
#H  Revision 1.4  1995/02/16  20:47:22  fceller
#H  used nicer positioning
#H
#H  Revision 1.3  1995/02/10  16:31:04  fceller
#H  improved 'MakeSizes'
#H
#H  Revision 1.2  1995/02/10  15:06:16  fceller
#H  added 'Close' for selector (is actually never used at the moment)
#H
#H  Revision 1.1  1995/02/07  09:42:45  fceller
#H  Initial revision
##


#############################################################################
##
#V  GraphicLatticeRecordOps . . . . .  operations record for general lattices
##
GraphicLatticeRecordOps := Copy(GraphicLatticeOps);


#############################################################################
##
#F  GraphicLatticeRecordOps.MakeLattice( <sheet> )  .  set up data structures
##
GraphicLatticeRecordOps.MakeLattice := function( sheet )
    local   lat,  ini,  i,  p;

    # create sizes
    sheet.operations.MakeSizes(sheet);

    # create the classes
    lat := sheet.lattice;
    if not IsBound(lat.classPositions)  then
        lat.classPositions := List( [1..Length(lat.vertices)], x -> [x,1] );
    fi;
    sheet.classes := Set( List( lat.classPositions, x -> x[1] ) );

    # create initial setup
    ini := sheet.init;

    # first the 'vertices' list
    ini.vertices := [];
    for i  in [ 1 .. Length(lat.vertices) ]  do
        ini.vertices[i] := [ i, lat.sizes[i], lat.maximals[i],
               lat.classPositions[i][1], lat.classPositions[i][2] ];
    od;

    # now the class lengths
    ini.classLengths := List( sheet.classes, x -> 
                         Number( lat.classPositions, t -> t[1] = x ) );

    # and the orders
    ini.orderReps := [];
    for i  in [ 1 .. Length(sheet.classes) ]  do
        p := Filtered( [ 1 .. Length(lat.classPositions) ], x ->
                       lat.classPositions[x][1] = sheet.classes[i] );
        p := List( p, x -> lat.sizes[x] );
        if 1 < Length(Set(p))  then
            Error( "vertices of class ", i, " have different sizes" );
        fi;
        Add( ini.orderReps, p[1] );
    od;
    ini.orders := Set(ini.orderReps);

    # and the reps
    ini.reps := [];
    for i  in sheet.classes  do
        Add( ini.reps, PositionProperty( [ 1 .. Length(lat.classPositions) ],
                        x -> lat.classPositions[x][1] = i
                         and lat.classPositions[x][2] = 1 ) );
    od;

    # and the class lengths
    ini.classLengths := List( sheet.classes, x ->
                              Number( lat.classPositions, t -> t[1] = x ) );

end;


#############################################################################
##
#F  GraphicLatticeRecordOps.MakeMenus( <sheet> )  . menus for a lattice sheet
##
GraphicLatticeRecordOps.MakeMenus := function( sheet )
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
    Menu( sheet, "Resize",
        [ "Double Lattice",       sheet.operations.RMDoubleLattice,
          "Halve Lattice",        sheet.operations.RMHalveLattice,
          "Resize Lattice",       sheet.operations.RMResizeLattice,
          ,                       Ignore,
          "Resize Graphic Sheet", sheet.operations.RMResizeGraphicSheet
        ] );

    # create the clean up menu
    if sheet.color.model = "color"  then
        tmp := [
            "Average Y Levels",       	sheet.operations.CMAverageYLevels,
            "Average X Levels",         sheet.operations.CMAverageXLevels,
            "Rotate Conjugates",        sheet.operations.CMRotateConjugates,
            ,			        Ignore,
            "Deselect All",             sheet.operations.CMDeselectAll,
            "Select Representatives",   sheet.operations.CMSelectReps,
            ,                           Ignore,
            "Use Black&White",          sheet.operations.CMUseBlackWhite ];
    else
        tmp := [
            "Average Y Levels",         sheet.operations.CMAverageYLevels,
            "Average X Levels",         sheet.operations.CMAverageXLevels,
            "Rotate Conjugates",        sheet.operations.CMRotateConjugates,
            ,			        Ignore,
            "Deselect All",             sheet.operations.CMDeselectAll,
            "Select Representatives",   sheet.operations.CMSelectReps ];

    fi;
    sheet.cleanUpMenu := Menu( sheet, "CleanUp", tmp );
    Add( sheet.updateMenus0, [ sheet.cleanUpMenu, [
         "Deselect All" ] ] );
    Add( sheet.updateMenus1, [ sheet.cleanUpMenu, [
         "Average X Levels", "Rotate Conjugates" ] ] );

end;


#############################################################################
##
#F  GraphicLatticeRecordOps.MakeSizes( <sheet> )  . . . . . . . . guess sizes
##
GraphicLatticeRecordOps.MakeSizes := function( sheet )
    local   max,  m,  sort,  lst,  front,  new,  i,  ver;

    # return, if sizes are known
    if IsBound(sheet.lattice.sizes)  then
        return;
    fi;

    # compute the maximal vertices
    max := [ 1 .. Length(sheet.lattice.vertices) ];
    for m  in sheet.lattice.maximals  do
        SubtractSet( max, m );
    od;

    # there should be at least one maximal object
    if Length(max) = 0  then
        Error( "lattice contains no maximal objects" );
    fi;

    # start with the maximals
    sort := [ max ];
    for lst  in sort  do
        front := [];
        for new  in lst  do
            UniteSet( front, sheet.lattice.maximals[new] );
        od;
        if 0 < Length(front)  then
            Add( sort, front );
        fi;
    od;

    # set sizes according to <sort>
    max := Length(sort);
    sheet.lattice.sizes := [];
    for i  in [ 1 .. Length(sort) ]  do
        for ver  in sort[i]  do
            sheet.lattice.sizes[ver] := 2^(max-i);
        od;
    od;

end;


#############################################################################
##
#F  GraphicLatticeRecordOps.MakeX( <sheet> )  . . . . . .  make x coordinates
##
GraphicLatticeRecordOps.MakeX := function( sheet )
    
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
    for i  in [ 1 .. Length(FactorsInt(Maximum(sheet.init.orders))) ]  do
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
               and 2*sheet.circle*pos1 < sheet.width
          then
              coor[ Position(ri,[sheet.init.b[i][j]]) ] :=
                QuoInt(sheet.width,2) - QuoInt(pos1+pos2-1,2)*sheet.circle;
          elif   1 = Length(coors)
             and 1 < pos1
             and pos1 > sheet.width/(2*sheet.circle) 
          then
              coor[ Position(ri,[sheet.init.b[i][j]]) ] :=
                QuoInt(sheet.width,2) - QuoInt(pos1,2) * sheet.circle;
#          elif 1 = pos1
#             and j in [ 2..Length(sheet.init.b[i])-1 ]
#             and noElements[Position(sheet.init.orders,sheet.init.b[i][j+1])]
#                 =  1 
#          then
#              tmp := QuoInt(Maximum(noElements) + 1, 2);
#              coor[ Position(ri,[sheet.init.b[i][j]]) ] := 
#                coors[i] + (-1)^(j+1) * tmp * sheet.circle;
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
                if 2 * noElements[j] * sheet.circle > sheet.width  then
                    sheet.init.x[i] := sheet.init.x[i-1] + sheet.circle;  
                else
                    sheet.init.x[i] := sheet.init.x[i-1] + 2*sheet.circle;
                fi;
                if     sheet.init.x[i] > sheet.width
                   and sheet.init.vertices[i][1] in sheet.init.reps
                then
                    sheet.init.x[i] := sheet.circle;
                fi;
                cl := sheet.init.classLengths[sheet.init.vertices[i][4]];
                i  := i + 1;
                j  := 1;
                x  := sheet.init.x[i-1]; 
                while j < cl  do
                    sheet.init.x[i] := x + sheet.circle * j;
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
#F  GraphicLatticeRecord( <R>, <x>, <y> ) . . . . . . . . . display a lattice
##
GraphicLatticeRecord := function( arg )
    local   R,  S,  i,  j,  tmp,  def,  match,  permlist;
    
    # we need at least one argument: the group
    if Length(arg) < 1  then
        Error("usage: GraphicLatticeRecord( <R>[, <x>, <y>][, \"prime\"] )");
    fi;
    R := arg[1];
    
    # match a substring
    match := function( b, a )
        return a{[1..Length(b)]} = b;
    end;

    # parse the other argument: <x>, <y> or "prime"
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
            elif match( arg[i], "title" )  then
                def.title := arg[i];
            elif match( arg[i], "Title" )  then
                def.title := arg[i];
            else
                Error( "unkown option \"", arg[i], "\",\n",
                       "options are: \"prime\" or \"title\"" );
            fi;
            i := i+1;
        else
            Error( "unkown option ", arg[i] );
        fi;
    od;

    # construct a nice title
    if not IsBound(def.title)  then
        def.title := "Lattice";
    fi;

    # open a graphic sheet
    S := GraphicSheet( def.title, def.x, def.y );
    S.defaultTitle := def.title;
    S.close := function(S)
        if IsBound(S.selector)  then
            Close(S.selector);
        fi;
    end;

    # store lattice in <S>
    S.lattice := Copy(R);
      
    # <S>.circle is the diameter of a vertex
    S.circle := 2*QuoInt(FONTS.tiny[3]+4*(FONTS.tiny[1]+FONTS.tiny[2])+5,3);

    # <S>.init holds valueable information for the initial setup
    S.init := rec();
    S.init.primeOrdering  := def.prime;

    # change ops for lattice sheet
    S.operations := GraphicLatticeRecordOps;

    # select a color model
    S.color := rec();
    if COLORS.red <> false or COLORS.lightGray <> false  then
        S.color.model := "color";
    else
        S.color.model := "monochrome";
    fi;
    S.operations.MakeColors(S);
    
    # no objects are selected at first
    S.selected := [];
        
    # compute the lattice of <G>
    SetTitle( S, "Computing Lattice" );
    S.operations.MakeLattice(S);
    
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

    # sort the maximal subgroups
    SetTitle( S, "Computing Maximal Subgroups" );
    S.operations.SortMaximals(S);

    # compute the x-coordinates
    SetTitle( S, "Computing Coordinates" );
    S.operations.MakeX(S);
      
    # compute the y-coordinates
    S.operations.MakeY(S);
    
    # draw lattice
    SetTitle( S, "Drawing" );
    S.operations.MakeVertices(S);
    permlist := List(S.init.vertices, x -> x[1]);
    permlist := Permuted(S.lattice.vertices, Sortex(permlist));
    for i in [ 1..Length(permlist) ] do
        Relabel( S.vertices[i], String(permlist[i]));
    od;
    
    S.operations.MakeConnections(S);

    # and unbind unused information
    # Unbind(S.init);
    
    # add pointer action to <S>
    S.leftPointerButtonDown  := S.operations.LeftButton;
    
    # create menus
    S.operations.MakeMenus(S);

    # and enable/disable entries
    S.operations.UpdateMenus(S);

    # reset the title
    SetTitle( S, S.defaultTitle );

    # that's it
    return S;

end;
