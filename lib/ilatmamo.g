#############################################################################
##
#A  glatmamo.g                 	XGAP library                Maximilian Bisani
##
#H  @(#)$Id: ilatmamo.g,v 1.1 1997/11/27 12:20:00 frank Exp $
##
#Y  Copyright (C) 1995,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##
#H  $Log: ilatmamo.g,v $
#H  Revision 1.1  1997/11/27 12:20:00  frank
#H  added 3.5 library (does not work with 4.0)
#H
#H  Revision 1.1  1995/09/25  08:15:13  fceller
#H  Initial revision
#H
##
RequirePackage("meataxe");


#############################################################################
##
#V  InteractiveModuleLatticeOps . . . .  operations record for submodule lattices
##
InteractiveModuleLatticeOps := OperationsRecord(
    "InteractiveModuleLatticeOps", GraphicSheetOps);



#############################################################################
##                                                                         ##
#F                 L a y o u t   a n d   d r a w i n g                     ##
##                                                                         ##
#############################################################################

#############################################################################
##
#F  InteractiveModuleLatticeOps.MakeLayout(<sheet>, <visible>)
##
InteractiveModuleLatticeOps.MakeLayout := function(sheet, visible)
    
    local lat, remains, below, i;

    SetTitle(sheet, "Computing Coordinates");

    # MakeLayout
    lat := sheet.lattice;
    
    # compute the layers <sheet>.layers
    sheet.layers := [];
    remains := Copy(visible);
    below   := List([1..Length(lat.sub)], x -> Set(Filtered(
                    [1..Length(lat.sub)], y ->(x <> y) and lat.operations.IsSub(lat,x,y))));

    while Length(remains) > 0 do
        Add(sheet.layers, Filtered(remains, x -> below[x] = []));
 	SubtractSet(remains, sheet.layers[Length(sheet.layers)]);
 	for i in remains do
 	    SubtractSet(below[i], sheet.layers[Length(sheet.layers)]);
 	od;
    od;

    # create initial setup
    sheet.init := rec(
        x := sheet.operations.MakeX(sheet) ,
        y := sheet.operations.MakeY(sheet) );
    SetTitle(sheet, sheet.operations.Status(sheet));
end;


#############################################################################
##
#F  InteractiveModuleLatticeOps.OptimizeX( <sheet> )  . . . . . . optimize x coordinates
##
InteractiveModuleLatticeOps.OptimizeX := function(sheet)
    
    local Algorithm4, Intersections,
          lat;
    
    # Count intersections between two layers(employed by Algorithms 3&4)
    Intersections := function(upper, lower) 
        local count, i, j, k, l, crossings;
        
        count := 0;
        crossings := List(lower, x -> 0);
        
        for i in [1..Length(upper)] do
            for j in lat.maximals[upper[i]] do
                k := Position(lower, j);
                if k <> false then
                    count := count + crossings[k];
                fi;
            od;
            for j in lat.maximals[upper[i]] do
                k := Position(lower, j);
                if k <> false then
                    for l in [1..k-1] do
                        crossings[l] := crossings[l] + 1;
                    od;
                fi;
            od;
        od;
        
        return count;
    end; # Intersections

    
    ## Algorithm 4
    Algorithm4 := function()
        local Sort,
              lay, TI, lastTI;
        
        
        Sort := function(on, lay)
            local i, l, m, r;
            
            if Length(on) <= 1 then return on; fi;
            l := []; m := on[1]; r := [];
            for i in Difference(on, [m]) do
                if Intersections(sheet.layers[lay+1], [i,m]) + 
                   Intersections([i,m], sheet.layers[lay-1]) < 
                   Intersections(sheet.layers[lay+1], [m,i]) +
                   Intersections([m,i], sheet.layers[lay-1]) then
                    Add(l, i);
                else
                    Add(r, i);
                fi;
            od;
            
            return Concatenation(Sort(l,lay), [m], Sort(r,lay));
        end; # Sort
        
        TI := Sum([2..Length(sheet.layers)], 
                  l -> Intersections(sheet.layers[l], sheet.layers[l-1]));
        repeat
            lastTI := TI;
            Print("optimizing layer ");
            for lay in [2 .. Length(sheet.layers) - 1] do
                Print(lay, " ");
                sheet.layers[lay] := Sort(sheet.layers[lay], lay);
            od;
            
            TI := Sum([2..Length(sheet.layers)], 
                      l -> Intersections(sheet.layers[l], sheet.layers[l-1]));
            Print(" - ", TI, " intersections remaining\n");
        until lastTI <= TI;
    end; # Algorithm 4
    

    # Optimize X    
    lat := sheet.lattice;
       
    # Show total number of intersections(for testing purpose only)
    Print("total intersections: ", 
          Sum([2..Length(sheet.layers)], 
              l -> Intersections(sheet.layers[l], sheet.layers[l-1])), "\n");
    
    Algorithm4(); 
end; # OptimizeX

#############################################################################
##
#F  InteractiveModuleLatticeOps.MakeX( <sheet> )  . . . . . .  make x coordinates
##
InteractiveModuleLatticeOps.MakeX := function(sheet)
    
    local x, l, i, j, xstep;
     
    # compute the x coordinates
    x := []; 
    for i in [1..Length(sheet.layers)] do
        l := sheet.layers[i];
        xstep := QuoInt(sheet.width, Length(l) + 1);
        for j in [1 .. Length(l)] do
            x[l[j]] := j * xstep;
        od;
    od;
    return x;    
end; # MakeX


#############################################################################
##
#F  InteractiveModuleLatticeOps.MakeY( <sheet> )  . . . . . .  make y-coordinates
##
InteractiveModuleLatticeOps.MakeY := function( sheet ) 
    
    local l, i, m, y;
       
    m := QuoInt(sheet.height - 2 * VERTEX.diameter, Length(sheet.layers));
    y := [];
    for l in [1 .. Length(sheet.layers)] do
        for i in sheet.layers[l] do
            y[i] := m *(Length(sheet.layers) - l + 1);
        od;
    od;
    return y;
end; # MakeY


#############################################################################
##
#F  InteractiveModuleLatticeOps.MakeVertices(<sheet>, <new>)
##
InteractiveModuleLatticeOps.MakeVertices := function(sheet, new)
    
    local   lat, i,  v;

    lat := sheet.lattice;
    
#   if not IsBound(lat.sortex) then lat.operations.Sort(lat); fi;
    
    # loop over all modules to be shown
    for i in new do
            
        # create a graphic vertex
        v := Vertex(
                 sheet,
                 sheet.init.x[i],
                 sheet.init.y[i],
                 rec(
                      label := String(lat.operations.GetIndex(lat, i))
#                     label := String(Position(lat.sortex, lat.operations.GetIndex(lat, i)))
                 )
             );

        # choose appropriate shape
        if lat.operations.IsMountain(lat,i) then
            Reshape(v, VERTEX.rectangle + VERTEX.diamond);
        else
            Reshape(v, VERTEX.rectangle);
        fi;

        # set the module it represents
        v.module := i;
            
        # put vertex into the lists of vertices
        sheet.vertices[i] := v;
    od; 

    sheet.operations.UnmakeConnections(sheet, new);
    sheet.operations.MakeConnections  (sheet, new);
end; # MakeVertices


#############################################################################
##
#F  InteractiveModuleLatticeOps.MakeConnections(<sheet>, <consider>)
##
InteractiveModuleLatticeOps.MakeConnections := function(sheet, consider)
    local lat, v, j, c, it;
    
    lat := sheet.lattice;
    # loop over all vertices...
    for v in sheet.vertices do
        # ... and their module's maximals
        for j in lat.operations.Maximals(lat, v.module) do
            if(v.module in consider and j in sheet.visible)
            or(j in consider) then 
                c := Connection(v, First(sheet.vertices, k -> k.module = j));
                it := lat.operations.IsoType(lat, v.module, j);
                if it = false then
                    Recolor(c, sheet.color.local_maximal);
                else
                    Relabel(c, String(it));
                fi;
            fi;
        od;
    od;
end; # MakeConnections


#############################################################################
##
#F  InteractiveModuleLatticeOps.UnmakeConnections(<sheet>, <consider>)
##
## Reconsider local connections
##
InteractiveModuleLatticeOps.UnmakeConnections := function(sheet, consider)
    local L, i, bi, abi;
    
    L := sheet.lattice;
    for i in consider do
        for bi in Intersection(sheet.visible, L.operations.Maximals(L, i)) do
            for abi in Filtered(
              List(sheet.vertices[bi].connections, v -> v.module), 
              j -> L.operations.IsSub(L, j, bi) and(not bi in L.operations.Maximals(L, j))) do
                Disconnect(sheet.vertices[abi],
                            sheet.vertices[ bi]);
            od;
        od;
    od;
end; # UnmakeConnections;



#############################################################################
##
#F  InteractiveModuleLatticeOps.UnmakeVertices(<sheet>, <hide>)
##
InteractiveModuleLatticeOps.UnmakeVertices := function(sheet, hide)
    local v;
    for v in sheet.vertices{hide} do
        Delete(v);
        Unbind(v);
    od;
end;


#############################################################################
##
#F  InteractiveModuleLatticeOps.Reposition(<sheet>, <init>) . . .  move vertices
##
InteractiveModuleLatticeOps.Reposition := function(sheet, init)
    local i, v;
    
    SetTitle(sheet, "Drawing");
    if not IsBound(init.x) then
        init.x := [];
        for v in sheet.vertices do
            init.x[sheet.lattice.operations.GetIndex(sheet.lattice, v.module)] := v.x;
        od;
    fi;

    if not IsBound(init.y) then
        init.y := [];
        for v in sheet.vertices do
            init.y[sheet.lattice.operations.GetIndex(sheet.lattice, v.module)] := v.y;
        od;
    fi;

    for i in sheet.visible do
        Move(sheet.vertices[i], init.x[i], init.y[i]);
    od;
    SetTitle(sheet, sheet.operations.Status(sheet));
end;


#############################################################################
##
#F  InteractiveModuleLatticeOps.SetVisible(<sheet>, <visible>) . . . . . . . . .
##
## Shows all vertices specified in visible and hides the rest
##
InteractiveModuleLatticeOps.SetVisible := function(sheet, visible)
    local show, hide;
    
    SetTitle(sheet, "Drawing");
    
    show := Difference(visible, sheet.visible);
    hide := Difference(sheet.visible, visible);
    
    sheet.operations.UnmakeVertices(sheet, hide);
    SubtractSet(sheet.visible, hide);
    
    if Size(show) > 0 then
        sheet.operations.MakeLayout  (sheet, visible);
        sheet.operations.Reposition  (sheet, sheet.init);
        sheet.operations.MakeVertices(sheet, show);
        Unbind(sheet.init);
        UniteSet(sheet.visible, show);
    else
        sheet.layers := List(sheet.layers, 
            l -> Filtered(l, l -> l in sheet.visible));
        sheet.layers := Filtered(sheet.layers, l -> Length(l) > 0);
    fi;

    SetTitle(sheet, sheet.operations.Status(sheet));
end; # SetVisible;



#############################################################################
##
#F  InteractiveModuleLatticeOps.UpdateSR(sheet, consider)
##
# Show selected and resulting modules
##
InteractiveModuleLatticeOps.UpdateSR := function(sheet, consider)

    local v;

    for v in sheet.vertices{consider} do
        if v.module in sheet.selected then
            Recolor(v, sheet.color.selected);
        elif v.module in sheet.result then
            Recolor(v, sheet.color.result);
        else
            Recolor(v, sheet.color.unselected);
        fi;
    od;
end; # UpdateSR


#############################################################################
##                                                                         ##
#F                 S t a t u s - i n f o r m a t i o n                     ##
##                                                                         ##
#############################################################################


#############################################################################
##
#F  InteractiveModuleLatticeOps.Status(<sheet>)
##
InteractiveModuleLatticeOps.Status := function(sheet)
    local lat, t;
    
    lat := sheet.lattice;
    t := "";

    if sheet.visible <> [1..Length(lat.sub)] then
        Append(t, String(Size(sheet.visible)));
        Append(t, " of ");
    fi;

    Append(t, String(Length(lat.sub)));
    Append(t, " submodules generated by ");
    Append(t, String(Size(lat.mountainMask)));
    if Size(lat.mountainMask) < lat.nMount then
        Append(t, " of ");
        Append(t, String(lat.nMount));
    fi;
    Append(t, " mountains in ");
    Append(t, String(lat.generation));
    Append(t, " generations");
    if lat.closed then
        Append(t, "(closed)");
    fi;

    if IsBound(sheet.resultDesc) then
        Append(t, " ");
	Append(t, sheet.resultDesc);
        Append(t, " : ");
        Append(t, String(sheet.result));
    fi;
    return t;
end;


#############################################################################
##
#F  InteractiveModuleLatticeOps.SetResult(<sheet>,<desc>,<res>)
##
InteractiveModuleLatticeOps.SetResult := function(sheet, desc, res)
    local consider, new;

    consider := sheet.result;
    sheet.result := Set(List(res, i -> sheet.lattice.operations.GetIndex(sheet.lattice, i)));
    UniteSet(consider, sheet.result);

    sheet.operations.SetVisible(sheet, Union(sheet.visible, sheet.result));

    if desc <> false then
        sheet.resultDesc := desc;
    else
        Unbind(sheet.resultDesc);
    fi;

    sheet.operations.UpdateSR(sheet, consider);
    SetTitle(sheet, sheet.operations.Status(sheet));
end;


#############################################################################
##
#F  InteractiveModuleLatticeOps.UpdateMenus(sheet)
##
InteractiveModuleLatticeOps.UpdateMenus := function(sheet)

    local tripel;

    for tripel in sheet.updateMenus do
        Enable(tripel[1], tripel[2], tripel[3](sheet));
    od;
end; # UpdateMenus



#############################################################################
##                                                                         ##
#F                               M e n u s                                 ##
##                                                                         ##
#############################################################################

#############################################################################
##
#F  InteractiveModuleLatticeOps.CMAverageYLevels(...) . . . . .  common y coordinates
##
InteractiveModuleLatticeOps.CMAverageYLevels := function( sheet, menu, name )
    sheet.operations.Reposition(sheet, rec(
        y := sheet.operations.MakeY(sheet)));
end;

#############################################################################
##
#F  InteractiveModuleLatticeOps.CMAverageXLevels(...) . . . . .  common x coordinates
##
InteractiveModuleLatticeOps.CMAverageXLevels := function( sheet, menu, name )
    sheet.operations.Reposition(sheet, rec(
        x := sheet.operations.MakeX(sheet)));
end;

#############################################################################
##
#F  InteractiveModuleLatticeOps.CMOptimize(...) . . . . . . optimal x coordinates
##
InteractiveModuleLatticeOps.CMOptimize := function( sheet, menu, name )
    sheet.operations.OptimizeX(sheet);
    sheet.operations.Reposition(sheet, rec(
        y := sheet.operations.MakeY(sheet),
        x := sheet.operations.MakeX(sheet)));
end;



#############################################################################
##
#F  InteractiveModuleLatticeOps.SRMDeselectAll(...) . . .  deselected all objects
##
InteractiveModuleLatticeOps.SRMDeselectAll := function(sheet, menu, name)
    local consider;
    consider       := sheet.selected;  
    sheet.selected := [];
    sheet.operations.UpdateSR(sheet, consider);
    sheet.operations.UpdateMenus(sheet);  
end;

#############################################################################
##
#F  InteractiveModuleLatticeOps.SRMInvertSelection(...) . . . . invert Selection
##
InteractiveModuleLatticeOps.SRMInvertSelection := function(sheet, menu, name)
    sheet.selected := Difference([1..Length(sheet.vertices)], sheet.selected);
    sheet.operations.UpdateSR(sheet, [1 .. Length(sheet.vertices)]);
    sheet.operations.UpdateMenus(sheet);  
end;

#############################################################################
##
#F  InteractiveModuleLatticeOps.SRMSelectResult(...) . . . . . . . . . . . . . .
##
InteractiveModuleLatticeOps.SRMSelectResult := function(sheet, menu, name)
    local consider;
    consider       := Union(sheet.selected, sheet.result);
    sheet.selected := Copy(sheet.result);
    sheet.operations.UpdateSR(sheet, consider);
    sheet.operations.UpdateMenus(sheet);  
end;

#############################################################################
##
#F  InteractiveModuleLatticeOps.SRMShowAll(...) . . . . . . . . . . . . . . . .
##
InteractiveModuleLatticeOps.SRMShowAll := function(sheet, menu, name)
    sheet.operations.SetVisible(sheet, [1 .. Length(sheet.lattice.sub)]);
    sheet.operations.UpdateSR    (sheet, []);
end;

#############################################################################
##
#F  InteractiveModuleLatticeOps.SRMHideSelected(...) . . . . . . . . . . . . .
##
InteractiveModuleLatticeOps.SRMHideSelected := function(sheet, menu, name)
    sheet.operations.SetVisible(sheet, 
            Difference(sheet.visible, sheet.selected));
    sheet.operations.UpdateSR      (sheet, []);
end;

#############################################################################
##
#F  InteractiveModuleLatticeOps.SRMShowSelected(...)  . . . . . . . . . . . . .
##
InteractiveModuleLatticeOps.SRMShowSelected := function(sheet, menu, name)
    sheet.operations.SetVisible(sheet, sheet.selected);
    sheet.operations.UpdateSR      (sheet, []);
end;



#############################################################################
##
#F  InteractiveModuleLatticeOps.GMAll(...)  . . . . . . . . . .  generate all
##
InteractiveModuleLatticeOps.GMAll := function( sheet, menu, name )
    local new;

    new := sheet.lattice.operations.Generate( sheet.lattice, -1, -1 );
    sheet.operations.SetResult( sheet, "generated", new );
end;


#############################################################################
##
#F  InteractiveModuleLatticeOps.GMUpto(...) . . . . . .  generate up to n modules
##
InteractiveModuleLatticeOps.GMUpto := function(sheet, menu, name)
    local maxSubs, new;

    maxSubs := Query(Dialog("OKcancel", "Maximum number of submodules"));
    if maxSubs = false then return; fi;
    maxSubs := IntString(maxSubs);
    new := sheet.lattice.operations.Generate(sheet.lattice, -1, maxSubs);
    sheet.operations.SetResult(sheet, "generated", new);
end;

#############################################################################
##
#F  InteractiveModuleLatticeOps.GMNextGen(...) . . . . . . . . one new generation
##
InteractiveModuleLatticeOps.GMNextGen := function(sheet, menu, name)
    local new;
    new := sheet.lattice.operations.Generate(sheet.lattice, sheet.lattice.generation + 1, -1);
    sheet.operations.SetResult(sheet, "generated", new);
end;



#############################################################################
##
#F  InteractiveModuleLatticeOps.SMMountains . . . . . . . . . . . . ShowMountains
##
InteractiveModuleLatticeOps.SMMountains := function(sheet, menu, name)
    local m;
    m := sheet.selected[1];
    sheet.operations.SetResult(sheet,
        ConcatenationString("mountains contained in ", String(m)),
        sheet.lattice.operations.Mountains(sheet.lattice, m)
    );
end; # SMMountains

#############################################################################
##
#F  InteractiveModuleLatticeOps.SMMaximals
##
InteractiveModuleLatticeOps.SMMaximals := function(sheet, menu, name)
    local m;
    m := sheet.selected[1];
    sheet.operations.SetResult(sheet,
        ConcatenationString("maximal submodules of ", String(m)),
        sheet.lattice.operations.Maximals(sheet.lattice, m)
    );
end; # SMMaximals

#############################################################################
##
#F  InteractiveModuleLatticeOps.SMSubModules
##
InteractiveModuleLatticeOps.SMSubModules := function(sheet, menu, name)
    local m;
    m := sheet.selected[1];
    sheet.operations.SetResult(sheet,
        ConcatenationString("submodules of ", String(m)),
        sheet.lattice.operations.SubModules(sheet.lattice, m)
    );
end; # SMSubModules

#############################################################################
##
#F  InteractiveModuleLatticeOps.SMSuperModules
##
InteractiveModuleLatticeOps.SMSuperModules := function(sheet, menu, name)
    local m;
    m := sheet.selected[1];
    sheet.operations.SetResult(sheet,
        ConcatenationString("supermodules of ", String(m)),
        sheet.lattice.operations.SuperModules(sheet.lattice, m)
    );
end; # SMSuperModules

#############################################################################
##
#F  InteractiveModuleLatticeOps.SMClosedUnion
##
InteractiveModuleLatticeOps.SMClosedUnion := function(sheet, menu, name)
    local m;
    m := sheet.selected;
    sheet.operations.SetResult(sheet,
        ConcatenationString("closed union of ", String(m)),
        [sheet.lattice.operations.ClosedUnion(sheet.lattice, m)]
    );
end; # SMClosedUnion

#############################################################################
##
#F  InteractiveModuleLatticeOps.SMIntersection
##
InteractiveModuleLatticeOps.SMIntersection := function(sheet, menu, name)
    local m;
    m := sheet.selected;
    sheet.operations.SetResult(sheet,
        ConcatenationString("intersection of ", String(m)),
        [sheet.lattice.operations.Intersection(sheet.lattice, m)]
    );
end; # SMIntersection

#############################################################################
##
#F  InteractiveModuleLatticeOps.SMBetween
##
InteractiveModuleLatticeOps.SMBetween := function(sheet, menu, name)
    local u,d;
    if sheet.lattice.operations.IsSub(sheet.lattice, sheet.selected[1], sheet.selected[2]) then
        u := sheet.selected[1];
        d := sheet.selected[2];
    else
        u := sheet.selected[2];
        d := sheet.selected[1];
    fi;

    sheet.operations.SetResult(sheet,
        ConcatenationString("modules between ", String(u), " and ", String(d)),
        Intersection(
            sheet.lattice.operations.SubModules (sheet.lattice, u),
            sheet.lattice.operations.SuperModules(sheet.lattice, d)
        )
    );
end; # SMBetween

#############################################################################
##
#F  InteractiveModuleLatticeOps.SMRadicalSeries
##
InteractiveModuleLatticeOps.SMRadicalSeries := function(sheet, menu, name)
    sheet.operations.SetResult(sheet,
        "radical series",
        sheet.lattice.operations.RadicalSeries(sheet.lattice)
    );
end; # SMRadicalSeries

#############################################################################
##
#F  InteractiveModuleLatticeOps.SMSocleSeries
##
InteractiveModuleLatticeOps.SMSocleSeries := function(sheet, menu, name)
    sheet.operations.SetResult(sheet,
        "socle series",
        sheet.lattice.operations.SocleSeries(sheet.lattice)
    );
end; # SMSocleSeries



#############################################################################
##
#F  InteractiveModuleLatticeOps.MakeMenus(<sheet>)  . . . . menus for a module lattice sheet
##
InteractiveModuleLatticeOps.MakeMenus := function(sheet)

    local ExactlyOne, AtLeastTwo, NotClosed,
          m, u;

    ExactlyOne := S -> Length(S.selected)  = 1;
    AtLeastTwo := S -> Length(S.selected) >= 2;
    NotClosed  := S -> not S.lattice.closed;

    sheet.updateMenus := []; u := sheet.updateMenus;
    
    # generate menu
    m := Menu(sheet, "Generate",
          ["Next Generation", sheet.operations.GMNextGen ,
           "All",             sheet.operations.GMAll     ,
           "Upto",            sheet.operations.GMUpto    ] );
    Add(u, [m, "Next Generation", NotClosed]);
    Add(u, [m, "All",             NotClosed]);
    Add(u, [m, "Upto",            NotClosed]);

    # selection menu
    Menu(sheet, "Select",
          ["Deselect All",     sheet.operations.SRMDeselectAll     ,
           "Invert Selection", sheet.operations.SRMInvertSelection ,
           "Select Result",    sheet.operations.SRMSelectResult    ,
           ,                   Ignore                              ,
           "Show All",         sheet.operations.SRMShowAll         ,
           "Hide Selected",    sheet.operations.SRMHideSelected    ,
           "Show Selected",    sheet.operations.SRMShowSelected    ] );

    # submodule menu
    m := Menu( sheet, "Submodule",
        [ "Mountains",		sheet.operations.SMMountains,
          "Maximals",		sheet.operations.SMMaximals,
          "Submodules",		sheet.operations.SMSubModules,
          "Supermodules",	sheet.operations.SMSuperModules,
          "",                   Ignore,
          "Closed Union",	sheet.operations.SMClosedUnion,
          "Intersection",	sheet.operations.SMIntersection,
          "Between",		sheet.operations.SMBetween,
          "",                   Ignore,
          "Radical Series",	sheet.operations.SMRadicalSeries,
          "Socle Series",	sheet.operations.SMSocleSeries
        ] );
    Add(u, [m, "Mountains",	ExactlyOne]);
    Add(u, [m, "Maximals",	ExactlyOne]);
    Add(u, [m, "Submodules",	ExactlyOne]);
    Add(u, [m, "Supermodules",	ExactlyOne]);
    Add(u, [m, "Closed Union",	AtLeastTwo]);
    Add(u, [m, "Intersection",	AtLeastTwo]);
    Add(u, [m, "Between",	S -> Length(S.selected) = 2]);

    # create the clean up menu
    sheet.cleanUpMenu := Menu(sheet, "CleanUp",
        [ "Average Y Levels" , sheet.operations.CMAverageYLevels ,
          "Average X Levels" , sheet.operations.CMAverageXLevels ,
          "Optimize"         , sheet.operations.CMOptimize       ] );

end; # MakeMenus



#############################################################################
##                                                                         ##
#F                            Button Functions                             ##
##                                                                         ##
#############################################################################

#############################################################################
##
#F  InteractiveModuleLatticeOps.ToggleSelection( <sheet>, <obj> ) . . . . toggle status
##
InteractiveModuleLatticeOps.ToggleSelection := function(sheet, obj)
    if obj.module in sheet.selected  then
        SubtractSet(sheet.selected, [obj.module]);
    else
        AddSet(sheet.selected, obj.module);
    fi;
    sheet.operations.UpdateSR(sheet, [obj.module]);
    sheet.operations.UpdateMenus(sheet);  
end;



#############################################################################
##
#F  InteractiveModuleLatticeOps.DragVertex( <sheet>, <obj> )  . . .  drag/select vertex
##
InteractiveModuleLatticeOps.DragVertex := function(sheet, obj)
    local    j, d1,  d2,  oldx,  oldy,  moved;

    j := PositionProperty(sheet.layers, l -> obj.module in l);

    # the upper bound the lowest vertex in the layer above
    if 0 = j - 1  then
        d1 := sheet.height;
    else
        d1 := List(sheet.layers[j-1], i -> sheet.vertices[i].y);
        d1 := Minimum(d1) - VERTEX.diameter;
    fi;

    # the lower bound is the highest vertex in the strip below
    if Length(sheet.layers) < j + 1 then
        d2 := 0;
    else
        d2 := List(sheet.layers[j+1], i -> sheet.vertices[i].y);
        d2 := Maximum(d2) + VERTEX.diameter;
    fi;
            
    # drag vertex
    oldx := obj.x;
    oldy := obj.y;
    WcFastUpdate( sheet.id, true );
    j := WindowCmd([ "XQP", sheet.id ]);
    moved := false;
    Drag(sheet, j[1], j[2], BUTTONS.left, function(x, y)
        if 5 < AbsInt(oldx-x) or 5 < AbsInt(oldy-y) then
            moved := true;
        fi;
        if y >= d1  then y := d1;  fi;
        if y <= d2  then y := d2;  fi;
        Move( obj, x, y );
    end);
            
    # select a vertex
    if not moved  then
        Move(obj, oldx, oldy);
        sheet.operations.ToggleSelection(sheet, obj);
        WcFastUpdate(sheet.id, false);
        return false;
    else
        WcFastUpdate(sheet.id, false);
        return true;
    fi;
end; # DragVertex


#############################################################################
##
#F  InteractiveModuleLatticeOps.LeftButton( <sheet>, <x>, <y> ) . drag a representative
##
InteractiveModuleLatticeOps.LeftButton := function( sheet, x, y )
    local   pos,  obj,  res;
    
    pos := [x,y];
    for obj in sheet.objects do
        if IsBound(obj.isVertex) and obj.isVertex and pos in obj  then
            sheet.operations.DragVertex( sheet, obj );
            return;
        fi;
    od;
#   return sheet.operations.PopupSheet( sheet, x, y );
end;


#############################################################################
##
#F  InteractiveModuleLatticeOps.RightButton( <sheet>, <x>, <y> ) show vertex/sheet menu
##
InteractiveModuleLatticeOps.RightButton := function( sheet, x, y )
    local   pos,  obj,  res;
  
    # check if the pointer is on a vertex
    pos := [x,y];
    for obj  in sheet.objects  do
        if IsBound(obj.isVertex) and obj.isVertex and pos in obj then 
            sheet.operations.PMInformation(sheet, obj);
            return;
        fi;
    od;
#   sheet.operations.PopupSheet(sheet, x, y);
end;



#############################################################################
##                                                                         ##
#F                                Popup Menus                              ##
##                                                                         ##
#############################################################################

#############################################################################
##
#F  InteractiveModuleLatticeOps.PMInformation( <sheet>, <obj> ) . . . . show group info
##
InteractiveModuleLatticeOps.PMInformation := function(sheet, obj)
    local FuncCompute, FuncAll, FuncClose,
          lat, m, text,  info,  str,  i;
    
    # destroy other text selectors flying around
    if IsBound(sheet.selector)  then
        Close(sheet.selector);
    fi;
    
    lat := sheet.lattice;
    m   := obj.module;
             
    # construct info texts(text, record component, function)
    info := [
             [ "Dimension"  , lat.dimensions, lat.operations.Dimension  ] ,
             [ "is mountain",               , lat.operations.IsMountain ]
            ];
   
               
    FuncCompute := function(sel, tid)
        local text, str;

        tid  := sel.selected;
        text := Copy(sheet.selector.labels);
        str  := String(info[sel.selected][1], -14);
        Append(str, String(info[sel.selected][3](lat, m)));
        text[sel.selected] := str;
        Relabel(sel, text);
    end;

    FuncAll := function(sel, bt)
        local   i;
        for i  in [ 1 .. Length(sel.labels) ]  do
            sel.textFuncs[i]( sel, i );
        od;
        Enable( sel, "all", false );
    end; 

    FuncClose := function(sel, bt)
        Close(sel);
        Unbind(sheet.selector);
    end;   
    
    # construct the string
    text := [];
    for i in info do
        str := String(i[1], -14);
        if IsBound(i[2]) then
            if IsBound(i[2][m]) then
                Append(str, String(i[2][m]));
            else
                Append(str, "unknown");
            fi;
        else
            Append(str, String(i[3](lat,m)));
        fi;       
        Add(text, str);
        Add(text, FuncCompute);
    od;
    # Print(text);

    # construct text selector
    sheet.selector := TextSelector(
        Concatenation("Information about ", String(lat.operations.GetIndex(lat, m))),
        text,
        ["all", FuncAll, "close", FuncClose]
    );
end; # PMInformation



#############################################################################
##                                                                         ##
#F                                  M A I N                                ##
##                                                                         ##
#############################################################################


#############################################################################
##
#F  MeatAxeModuleOps.InteractiveLattice( <M> )  . display a submodule lattice
##
MeatAxeModuleOps.InteractiveLattice := function( arg )
    local   module,  lat,  sheet,  def,  i,  j,  match;

    # parse arguments, at least one argument: the module
    if Length(arg) < 1  then
        Error( "usage: InteractiveLattice( <module> )" );
    fi;
    module := arg[1];
    
    # match substring
    match := function( b, a )
        local   c;
        c := Minimum(Length(a),Length(b));
        return a{[1..c]} = b{[1..c]};
    end;

    # parse the other argument: <x>, <y> or "title"
    def := rec( x := 800, y := 600, title := "Submodule Lattice" );
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
    
    # open a graphic sheet
    sheet := GraphicSheet( def.title, def.x, def.y );
    sheet.defaultTitle := def.title;
    sheet.close := function(sheet)
        if IsBound(sheet.selector)  then
            Close(sheet.selector);
        fi;
    end;

    # change ops for module lattice sheet
    sheet.operations := InteractiveModuleLatticeOps;
    
    # create the partial lattice
    if IsModule(module)  then
        SetTitle( sheet, "Computing Lattice" );
        lat := PartialModuleLattice(module);
    elif IsPartialModuleLattice(module)  then
        lat := module;
    else
        Error( "<lat> is neither a module nor a partial lattice" );
    fi;
    lat.operations.Generate( lat, 1, -1 );
    SetTitle( sheet, sheet.defaultTitle );

    # select a color model
    if COLORS.red <> false and COLORS.green <> false and COLORS.blue <> false  then
        # colour
        sheet.color := rec(unselected    := COLORS.black ,
                        selected      := COLORS.red   ,
                        result        := COLORS.green ,
                        local_maximal := COLORS.blue  );
    else
        # black & white
        sheet.color := rec(unselected    := COLORS.black ,
                        selected      := COLORS.lightGrey   ,
                        result        := COLORS.dimGrey ,
                        local_maximal := COLORS.lightGrey  );
    fi;
    
    # no objects are selected at first
    sheet.selected := [];
    sheet.result   := [];
    sheet.vertices := [];
    sheet.visible  := [];
    sheet.lattice  := lat;
    
    # Show submodules
    sheet.operations.SetVisible(sheet, [1 .. Length(lat.sub)]);
    
    ### GUI section
    # add pointer action to <sheet>
    sheet.leftPointerButtonDown  := sheet.operations.LeftButton;
    sheet.rightPointerButtonDown := sheet.operations.RightButton;
    
    # create menus
    sheet.operations.MakeMenus(sheet);

    # and enable/disable entries
    sheet.operations.UpdateMenus(sheet);

    # that's it
    return sheet;
end;
InteractiveModuleLattice := MeatAxeModuleOps.InteractiveLattice;