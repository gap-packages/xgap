#############################################################################
##
#W  poset.gd                  	XGAP library                  Max Neunhoeffer
##
#H  @(#)$Id: poset.gd,v 1.5 1998/12/06 22:16:14 gap Exp $
##
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
##  This file contains declarations for graphs and posets
##
Revision.pkg_xgap_lib_poset_gd :=
    "@(#)$Id: poset.gd,v 1.5 1998/12/06 22:16:14 gap Exp $";


#############################################################################
##
##  Constructors:
##
#############################################################################

#############################################################################
##
#O  GraphicGraph( <name>, <width>, <height> ) . . . . . . . new graphic graph
##
##  creates a new graphic graph which is a graphic sheet representation
##  with knowledge about vertices and edges and infrastructure for user
##  interfaces.
##
if IsBound(GraphicGraph) then if not IsOperation(GraphicGraph) then
  Error("Identifier GraphicGraph already in use!"); fi;
else
  DeclareOperation("GraphicGraph",[IsString, IsInt, IsInt]);
fi;


#############################################################################
##
#O  GraphicPoset(<name>, <width>, <height>) . . . . . . creates graphic poset
##
##  creates a new graphic poset which is a specialization of a graphic graph
##  mainly because per definition a poset comes in "layers" or "levels". This
##  leads to some algorithms that are more efficient than the general ones
##  for graphs.
##
if IsBound(GraphicPoset) then if not IsOperation(GraphicPoset) then
  Error("Identifier GraphicPoset already in use!"); fi;
else
  DeclareOperation("GraphicPoset",[IsString, IsInt, IsInt]);
fi;


#############################################################################
##
#O  CreateLevel(<poset>, <levelparam>) . . . . . . creates new level in poset
#O  CreateLevel(<poset>, <levelparam>, <lptext>) . creates new level in poset
##
##  A level in a graphic poset can be thought of as a horizontal slice of
##  the poset. It has a y coordinate of the top of the level relatively to
##  the graphic sheet and a height. Every class of vertices in a graphic
##  poset is in a level. The levels are totally ordered by their y
##  coordinate. No two vertices which are included in each other are in the
##  same level. A vertex containing another one is always "higher" on the
##  screen, meaning in a "higher" level.  Every level has a unique
##  levelparam, which can be any gap object. The user is responsible for
##  all methods where a levelparam occurs as parameter and is not just an
##  integer. There is NO gap object representing a level which is visible
##  for the user of posets. All communication about levels goes via the
##  levelparam.  Returns fail if there is already a level with a level
##  parameter which is considered "equal" by CompareLevels or levelparam if
##  everything went well.
##  The second method allows to specify which text appears for the level at
##  the right edge of the sheet.
##
if IsBound(CreateLevel) then if not IsOperation(CreateLevel) then
  Error("Identifier CreateLevel already in use!"); fi;
else
  DeclareOperation("CreateLevel",[IsGraphicSheet,IsObject]);
  DeclareOperation("CreateLevel",[IsGraphicSheet,IsObject,IsString]);
fi;


#############################################################################
##
#O  CreateClass(<poset>,<levelparam>,<classparam>) . . . .  creates new class
##
##  A class in a graphic poset is a collection of vertices within a level
##  which belong together in some sense.  Every vertex in a graphic poset
##  is in a class, which in turn belongs to a level. Every class in a level
##  has a unique classparam, which can be any gap object. The user is
##  responsible for all methods where a classparam occurs as parameter and
##  is not just an integer. There is NO gap object representing a class
##  which is visible to the user of posets. All communication about classes
##  goes via the classparam.  Returns fail if there is no level with
##  parameter levelparam or there is already a class in this level with
##  parameter classparam. Returns classparam otherwise.
##
if IsBound(CreateClass) then if not IsOperation(CreateClass) then
  Error("Identifier CreateClass already in use!"); fi;
else
  DeclareOperation("CreateClass",[IsGraphicSheet, IsObject, IsObject]);
fi;


#############################################################################
##
#O  Vertex(<graph>,<data>[,<inf>]) . . . . . . . . . . . . creates new vertex
##
##  Creates a new vertex. <inf> is a record in which additional info can be
##  supplied for the new vertex. For general graphic graphs only the
##  "label", "color", "shape", "x" and "y" components are applicable, they
##  contain a short label which will be attached to the vertex, the color,
##  the shape ("circle", "diamond", or "rectangle") and the coordinates
##  relative to the graphic sheet respectively. For graphic posets also the 
##  components "levelparam" and "classparam" are evaluated. If the component
##  "hints" is bound it must be a list of x coordinates which will be
##  delivered to ChoosePosition to help placement. Those x coordinates will
##  be the coordinates of other vertices related to the new one. All values of
##  record components which are not specified will be determined by calling 
##  some methods for graphic graphs or posets. Those are:
##    ChooseLabel for the label,
##    ChooseColor for the color,
##    ChooseShape for the shape,
##    ChoosePosition for the position,
##    ChooseLevel for the levelparam, and
##    ChooseClass for the classparam.
##    ChooseWidth for the line width of the vertex
##  Returns fail no vertex was created. This happens only, if one of the
##  choose functions return fail or no possible value, for example a
##  non-existing level or class parameter.
##  Returns vertex object if everything went well. 
##
if IsBound(Vertex) then if not IsOperation(Vertex) then
  Error("Identifier Vertex already in use!"); fi;
else
  DeclareOperation("Vertex",[IsGraphicSheet, IsObject, IsRecord]);
fi;


#############################################################################
##
#O  Edge(<graph>,<vertex1>,<vertex2>) . . . . . . . . . . . . adds a new edge
#O  Edge(<graph>,<vertex1>,<vertex2>,<def>) . . .  adds a new edge, with defs
##
##  Adds a new edge from <vertex1> to <vertex2>. For posets this puts one
##  of the vertices into the other as a maximal subvertex. So either
##  <vertex1> must lie in a "higher" level than <vertex2> or the other way
##  round. There must be no vertex "between" <vertex1> and <vertex2>. If
##  the two vertices are in the same level or one is already indirectly
##  included in the other fail is returned, otherwise true. That means,
##  that in the case where one of the two vertices is already a maximal
##  subobject of the other, then the method does nothing and returns true.
##  The variation with a defaults record just hands this over to the lower
##  levels, meaning that the line width and color are modified.
##
if IsBound(Edge) then if not IsOperation(Edge) then
  Error("Identifier Edge already in use!"); fi;
else
  DeclareOperation("Edge",[IsGraphicSheet,IsGraphicObject,IsGraphicObject]);
fi;


#############################################################################
##
##  Destructors:
##
#############################################################################


#############################################################################
##
#O  Delete(<graph>,<obj>) . . . . . . . . . . . . . remove something in graph
##
##  This operation already exists in xgap for the graphic objects!
##  Applicable for edges, vertices, classes.
##
if IsBound(Delete) then if not IsOperation(Delete) then
  Error("Identifier Delete already in use!"); fi;
else
  DeclareOperation("Delete",[IsGraphicSheet,IsObject]);
fi;


#############################################################################
##
#O  DeleteLevel(<poset>,<obj>)  . . . . . . . . . . . . remove level in poset
##
##  The following method applies to a level. It returns fail if the level
##  is not in the poset. The level is deleted and all classes within it
##  are also deleted! Returns true if the level is successfully deleted.
##  The parameter is a level parameter.
if IsBound(DeleteLevel) then if not IsOperation(DeleteLevel) then
  Error("Identifier DeleteLevel already in use!"); fi;
else
  DeclareOperation("DeleteLevel",[IsGraphicSheet,IsObject]);
fi;

#############################################################################
##
##  Operations for modifications:
##
#############################################################################


#############################################################################
##
#O  ResizeLevel(<poset>,<levelparam>,<height>)  . . .  change height of level
##
##  Changes the height of a level. The y coordinate can only be changed by
##  permuting levels, see below.
##  Attention: can increase the size of the sheet!
##  Returns fail if no level with parameter levelparam exists and true
##  otherwise. 
##
if IsBound(ResizeLevel) then if not IsOperation(ResizeLevel) then
  Error("Identifier ResizeLevel already in use!"); fi;
else
  DeclareOperation("ResizeLevel",[IsGraphicSheet,IsObject,IsInt]);
fi;


#############################################################################
##
#O  MoveLevel(<poset>,<levelparam>,<position>) move level to another position
##
##  Moves a level to another position. <position> is an absolute index in
##  the list of levels. The level with parameter <levelparam> will be at the
##  position <position> after the operation. This is only allowed if the
##  new ordering is compatible with the partial order given by CompareLevels
##  and if there is no connection of a vertex in the moving level with 
##  another level with which it is interchanged.
##  So <levelparam> is compared with all levelparams between the old and
##  the new position. If there is a contradiction nothing happens and the
##  method returns fail. If everything works the operation returns true.
##  This operation already exists in xgap for graphic objects.
if IsBound(MoveLevel) then if not IsOperation(MoveLevel) then
  Error("Identifier MoveLevel already in use!"); fi;
else
  DeclareOperation("MoveLevel",[IsGraphicSheet,IsObject,IsInt]);
fi;

#############################################################################
##
#O  Relabel(<graph>,<vertex>,<label>)  . . . . . . . . change label of vertex
#O  Relabel(<graph>,<vertex>)  . . . . . . . . . . . . change label of vertex
#O  Relabel(<poset>,<vertex>,<vertex>,<label>) . . . . . change label of edge
#O  Relabel(<poset>,<vertex>,<vertex>) . . . . . . . . . change label of edge
##
##  Changes the label of a vertex or edge. This must be a short string. In the
##  method where no label is specified the new label is chosen
##  functionally: the method ChooseLabel is called. Returns fail if an
##  error occurs and true otherwise.  This operations already exists in
##  xgap for graphic objects.
##
if IsBound(Relabel) then if not IsOperation(Relabel) then
  Error("Identifier Relabel already in use!"); fi;
else
  DeclareOperation("Relabel",[IsGraphicSheet,IsGraphicObject,IsString]);
fi;


#############################################################################
##
#O  Move(<graph>,<vertex>,<x>,<y>) . . . . . . . . . . . . . . .  move vertex
#O  Move(<graph>,<vertex>) . . . . . . . . . . . . . . . . . . .  move vertex
##
##  Moves <vertex>. For posets coordinates are relative to the level of the
##  vertex. <vertex> must be a vertex object in <graph>. If no coordinates
##  are specified the method ChoosePosition is called. Returns fail if an
##  error occurs and true otherwise.  This operations already exists in
##  xgap for graphic objects.
##
if IsBound(Move) then if not IsOperation(Move) then
  Error("Identifier Move already in use!"); fi;
else
  DeclareOperation("Move",[IsGraphicSheet,IsGraphicObject,IsInt,IsInt]);
fi;


#############################################################################
##
#O  Reshape(<graph>,<vertex>)  . . . . . . . . . . . . change shape of vertex
#O  Reshape(<graph>,<vertex>,<shape>)  . . . . . . . . change shape of vertex
##
##  Changes the shape of a vertex. <vertex> must be a vertex object in
##  graph. For the method where no shape is specified the new shape is
##  chosen functionally: ChooseShape is called for the corresponding data.
##  Returns fail if an error occurs and true otherwise.  This operations
##  already exists in xgap for graphic objects.
##
if IsBound(Reshape) then if not IsOperation(Reshape) then
  Error("Identifier Reshape already in use!"); fi;
else
  DeclareOperation("Reshape",[IsGraphicSheet,IsGraphicObject,IsString]);
fi;


#############################################################################
##
#O  Recolor(<graph>,<vertex>)  . . . . . . . . . . . . change color of vertex
#O  Recolor(<graph>,<vertex>,<color>)  . . . . . . . . change color of vertex
#O  Recolor(<poset>,<vertex1>,<vertex2>,<color>) . .  change color of an edge
#O  Recolor(<poset>,<vertex1>,<vertex2>) . . . . . .  change color of an edge
##
##  Changes the color of a vertex or an edge. <vertex> must be a vertex 
##  object in <graph>. For the method where no color is specified the new 
##  color is chosen functionally: ChooseColor is called for the corresponding 
##  data. Returns fail if an error occurs and true otherwise. This operation
##  already exists in xgap for graphic objects.
##
if IsBound(Recolor) then if not IsOperation(Recolor) then
  Error("Identifier Recolor already in use!"); fi;
else
  DeclareOperation("Recolor",[IsGraphicSheet,IsGraphicObject,IsColor]);
fi;


#############################################################################
##
#O  SetWidth(<graph>,<vertex1>,<vertex2>,<width>) . change line width of edge
#O  SetWidth(<graph>,<vertex1>,<vertex2>) . . . . . change line width of edge
##
##  Changes the line width of an edge. <vertex1> and <vertex2> must be
##  vertices in the graph <graph>. For the method where no line width is
##  specified the width is chosen functionally: ChooseWidth is called for
##  the corresponding data pair. Returns fail if an error occurs and true
##  otherwise. This operation already exists in xgap for graphic objects.
##
if IsBound(SetWidth) then if not IsOperation(SetWidth) then
  Error("Identifier SetWidth already in use!"); fi;
else
  DeclareOperation("SetWidth",[IsGraphicSheet,IsGraphicObject,
          IsGraphicObject,IsInt]);
  DeclareOperation("SetWidth",[IsGraphicSheet,IsGraphicObject,
          IsGraphicObject]);
fi;


#############################################################################
##
#O  Highlight(<graph>,<vertex>)  . . . . . . . change highlightning of vertex
#O  Highlight(<graph>,<vertex>,<flag>) . . . . change highlightning of vertex
##
##  Changes the highlightning status of a vertex. <vertex> must be a vertex
##  object in <graph>. For the method where no flag is specified the new status
##  is chosen functionally: ChooseHighlight is called for the corresponding 
##  data. Returns fail if an error occurs and true otherwise. This operation
##  already exists in xgap for graphic objects.
##
if IsBound(Highlight) then if not IsOperation(Highlight) then
  Error("Identifier Highlight already in use!"); fi;
else
  DeclareOperation("Highlight",[IsGraphicSheet,IsGraphicObject,IsBool]);
  DeclareOperation("Highlight",[IsGraphicSheet,IsGraphicObject]);
fi;


#############################################################################
##
#O  Select(<graph>,<vertex>,<flag>) . . . . . . . . . . (de-)selects a vertex
#O  Select(<graph>,<vertex>)  . . . . . . . . . . . . . . .  selects a vertex
##
##  Changes the selection state of a vertex. <vertex> must be a vertex object
##  in <graph>. The flags determines whether the vertex should be selected or
##  deselected. This operation already exists in xgap for graphic objects.
##  The method without flags assumes "true".
##
if IsBound(Select) then if not IsOperation(Select) then
  Error("Identifier Select already in use!"); fi;
else
  DeclareOperation( "Select",[IsGraphicSheet,IsGraphicObject,IsBool]);
fi;


#############################################################################
##
#O  DeselectAll(<graph>) . . . . . . . . . . . . . . . deselects all vertices
##
##  Deselects all vertices in graph.
##
if IsBound(DeselectAll) then if not IsOperation(DeselectAll) then
  Error("Identifier DeselectAll already in use!"); fi;
else
  DeclareOperation( "DeselectAll",[IsGraphicSheet] );
fi;


#############################################################################
##
#O  Selected(<graph>) . . . . . . . . .  returns set of all selected vertices
##
##  Returns a (shallow-)copy of the set of all selected vertices.
##
if IsBound(Selected) then if not IsOperation(Selected) then
  Error("Identifier Selected already in use!"); fi;
else
  DeclareOperation( "Selected",[IsGraphicSheet] );
fi;


#############################################################################
##
##  Operations for decisions with respect to data:
##
##  Those are normally supplied by the user via installing new methods.
##
#############################################################################


#############################################################################
##
#O  ChooseLabel(<graph>,<data>) . . . . . . . is called while vertex creation
#O  ChooseLabel(<graph>,<data>,<data>)  . . . . is called while edge creation
##
##  This operation is called while vertex or edge creation, if the caller 
##  didn't specify a label for the vertex or edge. It has to return a short 
##  string which will be attached to the vertex. If it returns fail the new 
##  vertex is not generated! This method just returns the empty string, so 
##  no label is generated.
##  This method is also called in the Relabel method without label parameter.
##
if IsBound(ChooseLabel) then if not IsOperation(ChooseLabel) then
  Error("Identifier ChooseLabel already in use!"); fi;
else
  DeclareOperation("ChooseLabel",[IsGraphicSheet,IsObject]);
fi;


#############################################################################
##
#O  ChooseLevel(<poset>,<data>) . . . . . . . is called while vertex creation
##
##  This operation is called while vertex creation, if the caller didn't
##  specify a level where the vertex belongs to. It has to return a
##  levelparam which exists in the poset. If it returns fail the new vertex
##  is not generated!
##
if IsBound(ChooseLevel) then if not IsOperation(ChooseLevel) then
  Error("Identifier ChooseLevel already in use!"); fi;
else
  DeclareOperation("ChooseLevel",[IsGraphicSheet,IsObject]);
fi;


#############################################################################
##
#O  ChooseClass(<poset>,<data>,<levelp>) . .  is called while vertex creation
##
##  This operation is called while vertex creation, if the caller didn't
##  specify a class where the vertex belongs to. It has to return a
##  classparam which exists in the poset in levelp. If it returns fail the
##  new vertex is not generated!
##
if IsBound(ChooseClass) then if not IsOperation(ChooseClass) then
  Error("Identifier ChooseClass already in use!"); fi;
else
  DeclareOperation("ChooseClass",[IsGraphicSheet,IsObject,IsObject]);
fi;


#############################################################################
##
#O  ChooseColor(<graph>,<data>) . . . . . . . is called while vertex creation
#O  ChooseColor(<graph>,<data1>,<data2>). . . . is called while edge creation
##
##  This operation is called while vertex or edge creation. It has to return a
##  color. If it returns fail the new vertex is not generated!
##  It is also called in the Recolor method without color parameter.
##
if IsBound(ChooseColor) then if not IsOperation(ChooseColor) then
  Error("Identifier ChooseColor already in use!"); fi;
else
  DeclareOperation("ChooseColor",[IsGraphicSheet,IsObject]);
fi;


#############################################################################
##
#O  ChooseHighlight(<graph>,<data>) . . . . . is called while vertex creation
##
##  This operation is called while vertex creation. It has to return a
##  flag which indicates, whether the vertex is highlighted or not. If it 
##  returns fail the new vertex is not generated!
##  It is also called in the Highlight method without flag parameter.
##
if IsBound(ChooseHighlight) then if not IsOperation(ChooseHighlight) then
  Error("Identifier ChooseHighlight already in use!"); fi;
else
  DeclareOperation("ChooseHighlight",[IsGraphicSheet,IsObject]);
fi;


#############################################################################
##
#O  ChoosePosition(<poset>,<data>,<level>,<class>,<hints>)  . . . . . . . . . 
#O  ChoosePosition(<graph>,<data>)  . . . . . is called while vertex creation
##                                            
##
##  This operation is called while vertex creation.  It has to return a
##  list with two integers: the coordinates. For posets those are relative
##  to the level the vertex resides in.  If it returns fail the new vertex
##  is not generated!
##
if IsBound(ChoosePosition) then if not IsOperation(ChoosePosition) then
  Error("Identifier ChoosePosition already in use!"); fi;
else
  DeclareOperation("ChoosePosition",[IsGraphicSheet,IsObject]);
  DeclareOperation("ChoosePosition",[IsGraphicSheet,IsObject,
                                     IsObject,IsObject,IsList]);
fi;


#############################################################################
##
#O  ChooseShape(<graph>,<data>) . . . . . . . is called while vertex creation
##
##  This operation is called while vertex creation.
##  It has to return a string out of the following list:
##  "circle", "diamond", "rectangle"
##  If it returns fail the new vertex is not generated!
##
if IsBound(ChooseShape) then if not IsOperation(ChooseShape) then
  Error("Identifier ChooseShape already in use!"); fi;
else
  DeclareOperation("ChooseShape",[IsGraphicSheet,IsObject]);
fi;


#############################################################################
##
#O  ChooseWidth(<graph>,<data>) . . . . . . . is called while vertex creation
#O  ChooseWidth(<graph>,<data1>,<data2>)  . . . is called while edge creation
##
##  This operation is called while vertex or edge creation.
##  It has to return a line width.
##  If it returns fail the new vertex or edge is not generated!
##  This is also called by the SetWidth operation without width parameter.
##
if IsBound(ChooseWidth) then if not IsOperation(ChooseWidth) then
  Error("Identifier ChooseWidth already in use!"); fi;
else
  DeclareOperation("ChooseWidth",[IsGraphicSheet,IsObject]);
fi;


#############################################################################
##
#O  CompareLevels(<poset>,<levelp1>,<levelp2>) . . . compares two levelparams
##
##  Compare two levelparams. -1 means that levelp1 is "higher", 1 means that
##  levelp2 is "higher", 0 means that they are equal. fail means that they
##  are not comparable.
##
if IsBound(CompareLevels) then if not IsOperation(CompareLevels) then
  Error("Identifier CompareLevels already in use!"); fi;
else
  DeclareOperation("CompareLevels",[IsGraphicSheet,IsObject,IsObject]);
fi;


#############################################################################
##
##  Operations for aquiring information about the poset:
##
#############################################################################


#############################################################################
##
#O  WhichLevel(<poset>,<y>) . . . . . .  determine level in which position is
##
##  Determines level in which position is. Returns levelparam or fail.
##
if IsBound(WhichLevel) then if not IsOperation(WhichLevel) then
  Error("Identifier WhichLevel already in use!"); fi;
else
  DeclareOperation("WhichLevel",[IsGraphicSheet,IsInt]);
fi;


#############################################################################
##
#O  WhichClass(<poset>,<x>,<y>) . . . .  determine class in which position is
##
##  Determines a class with a vertex which contains the position. The first
##  class found is taken.  Returns list with levelparam as first and
##  classparam as second element.  Returns fail if no such class is found.
##
if IsBound(WhichClass) then if not IsOperation(WhichClass) then
  Error("Identifier WhichClass already in use!"); fi;
else
  DeclareOperation("WhichClass",[IsGraphicSheet,IsInt,IsInt]);
fi;


#############################################################################
##
#O  WhichVertex(<graph>,<x>,<y>) . . .  determine vertex in which position is
#O  WhichVertex(<graph>,<data>)  . . . . .  determine vertex with data <data>
#O  WhichVertex(<graph>,<data>,<func>)   . . .  determine vertex functionally
##
##  Determines a vertex which contains the position.  Returns vertex.
##  In the third form the function func must take two parameters "data" and
##  the data entry of a vertex in question. It must return true or false, 
##  according to the right vertex being found or not.
##  The function can for example consider just one record component of
##  data records.
##  Returns fail in case no vertex is found.
##
if IsBound(WhichVertex) then if not IsOperation(WhichVertex) then
  Error("Identifier WhichVertex already in use!"); fi;
else
  DeclareOperation("WhichVertex",[IsGraphicSheet,IsInt,IsInt]);
  DeclareOperation("WhichVertex",[IsGraphicSheet,IsObject]);
  DeclareOperation("WhichVertex",[IsGraphicSheet,IsObject,IsFunction]);
fi;


#############################################################################
##
#O  WhichVertices(<graph>,<x>,<y>) .  determine vertices in which position is
#O  WhichVertices(<graph>,<data>)  . . .  determine vertices with data <data>
#O  WhichVertices(<graph>,<data>,<func>) . .  determine vertices functionally
##
##  Determines the list of vertices which contain the position. Returns list.
##  In the third form the function func must take two parameters "data" and
##  the data entry of a vertex in question. It must return true or false, 
##  according to the vertex belonging into the result or not.
##  The function can for example consider just one record component of
##  data records.
##  Returns the empty list in case no vertex is found.
##
if IsBound(WhichVertices) then if not IsOperation(WhichVertices) then
  Error("Identifier WhichVertices already in use!"); fi;
else
  DeclareOperation("WhichVertices",[IsGraphicSheet,IsInt,IsInt]);
  DeclareOperation("WhichVertices",[IsGraphicSheet,IsObject]);
  DeclareOperation("WhichVertices",[IsGraphicSheet,IsObject,IsFunction]);
fi;


#############################################################################
##
#O  Levels(<poset>) . . . . . . . . . . . . . returns the list of levelparams
##
##  Returns the list of levelparams in descending order meaning highest to
##  lowest. 
##
if IsBound(Levels) then if not IsOperation(Levels) then
  Error("Identifier Levels already in use!"); fi;
else
  DeclareOperation("Levels",[IsGraphicSheet]);
fi;


#############################################################################
##
#O  Classes(<poset>,<levelparam>) . . . . . . returns the list of classparams
##
##  Returns the list of classparams in level levelparam. Returns fail if no
##  level with parameter <levelparam> occurs.
##
if IsBound(Classes) then if not IsOperation(Classes) then
  Error("Identifier Classes already in use!"); fi;
else
  DeclareOperation("Classes",[IsGraphicSheet,IsObject]);
fi;


#############################################################################
##
#O  Vertices(<poset>,<levelparam>,<classparam>)  . . . . . . returns vertices
##
##  Returns the list of vertices in class classparams in level
##  levelparam. Returns fail no level with paramter <levelparam> or no
##  class with parameter <classparam> in the level.
##
if IsBound(Vertices) then if not IsOperation(Vertices) then
  Error("Identifier Vertices already in use!"); fi;
else
  DeclareOperation("Vertices",[IsGraphicSheet,IsObject,IsObject]);
fi;


#############################################################################
##
#O  Maximals(<poset>,<vertex>) . . . . . . . . .  returns maximal subvertices
##
##  Returns the list of maximal subvertices in <vertex>. Returns fail if an
##  error occurs.
##
if IsBound(Maximals) then if not IsOperation(Maximals) then
  Error("Identifier Maximals already in use!"); fi;
else
  DeclareOperation("Maximals",[IsGraphicSheet,IsObject]);
fi;


#############################################################################
##
#O  MaximalIn(<poset>,<vertex>) . .  returns vertices, in which v. is maximal
##
##  Returns the list of vertices, in which <vertex> is maximal.  Returns
##  fail if an error occurs.
##
if IsBound(MaximalIn) then if not IsOperation(MaximalIn) then
  Error("Identifier MaximalIn already in use!"); fi;
else
  DeclareOperation("MaximalIn",[IsGraphicSheet,IsObject]);
fi;


#############################################################################
##
#O  PositionLevel(<poset>,<levelparam>) . . . . . returns y position of level 
##
##  Returns the y position of the level relative to the graphic
##  sheet and the height. Returns fail if no level with parameter 
##  <levelparam> exists.
##
if IsBound(PositionLevel) then if not IsOperation(PositionLevel) then
  Error("Identifier PositionLevel already in use!"); fi;
else
  DeclareOperation("PositionLevel",[IsGraphicSheet,IsObject]);
fi;


#############################################################################
##
##  Operations for Menus and Mouse:
##
#############################################################################


#############################################################################
##
#O  Menu(<graph>,<title>,<entrylist>,<typelist>,<functionslist>) . . new menu
##
##  This operation already exists in xgap for GraphicSheets.
##  Builts a new Menu but with information about the type of the menu entry.
##  This information describes the relation between the selection state of
##  the vertices and the parameters supplied to the functions. The following 
##  types are supported:
##    "forany"    : always enabled, generic routines don't change anything
##    "forone"    : enabled iff exactly one vertex is selected
##    "fortwo"    : enabled iff exactly two vertices are selected
##    "forthree"  : enabled iff exactly three vertices are selected
##    "forsubset" : enabled iff at least one vertex is selected
##    "foredge"   : enabled iff a connected pair of two vertices is selected
##    "formin2"   : enabled iff at least two vertices are selected
##    "formin3"   : enabled iff at least three vertices are selected
##  The IsMenu object is returned. It is also stored in the sheet.
##
if IsBound(Menu) then if not IsOperation(Menu) then
  Error("Identifier Menu already in use!"); fi;
else
  DeclareOperation("Menu",[IsGraphicSheet,IsString,IsList,IsList,IsList]);
fi;


#############################################################################
##
#O  ModifyEnabled(<graph>,<from>,<to>) , . .  modifies enablednes of entries
##
##  Modifies the "Enabledness" of menu entries according to their type and
##  number of selected vertices. <from> is the first menu to work on and
##  <to> the last one (indices). Only IsAlive menus are considered. Returns 
##  nothing.
##  There are two different methods for graphs and posets:  
##
if IsBound(ModifyEnabled) then if not IsOperation(ModifyEnabled) then
  Error("Identifier ModifyEnabled already in use!"); fi;
else
  DeclareOperation("ModifyEnabled",[IsGraphicSheet,IsInt,IsInt]);
fi;

#############################################################################
##
#O  InstallPopup(<graph>,<func>) . install function for right click on vertex
##
##  Installs a function that is called if the user clicks with the right
##  button on a vertex. The function gets as parameters:
##   poset,vertex,x,y        (click position)
##
if IsBound(InstallPopup) then if not IsOperation(InstallPopup) then
  Error("Identifier InstallPopup already in use!"); fi;
else
  DeclareOperation("InstallPopup",[IsGraphicSheet,IsFunction]);
fi;

  
#############################################################################
##
##  Methods for user interaction:
##
#############################################################################


#############################################################################
##
#O  PosetLeftClick(poset,x,y) . . . . method which is called after left click
##
##  This operation is called when the user does a left click in a poset. It 
##  lets the user move, select and deselect vertices or edges.
##  Edges are selected as pair of vertices.
##
if IsBound(PosetLeftClick) then if not IsOperation(PosetLeftClick) then
  Error("Identifier PosetLeftClick already in use!"); fi;
else
  DeclareOperation( "PosetLeftClick", [IsGraphicSheet, IsInt, IsInt] );
fi;

#############################################################################
##
#O  PosetCtrlLeftClick(poset,x,y) . . method which is called after left click
##
##  This operation is called when the user does a left click in a poset while
##  holding down the control key. It lets the user move, select and deselect
##  vertices or edges. The difference to the operation without the control
##  key is, that while selecting the old vertices are NOT deselected.
##  Moving does not move the whole class but only one vertex. This allows
##  for permuting the vertices within a class.
##  Edges are selected as pair of vertices.
##
if IsBound(PosetCtrlLeftClick) then if not IsOperation(PosetCtrlLeftClick) then
  Error("Identifier PosetCtrlLeftClick already in use!"); fi;
else
  DeclareOperation( "PosetCtrlLeftClick", [IsGraphicSheet, IsInt, IsInt] );
fi;


#############################################################################
##
#O  PosetRightClick(poset,x,y) . . . method which is called after right click
##
##  This operation is called when the user does a right click in a poset. It 
##  finds out on which vertex the user clicked and calls the supplied
##  which the "user" supplied.
##
if IsBound(PosetRightClick) then if not IsOperation(PosetRightClick) then
  Error("Identifier PosetRightClick already in use!"); fi;
else
  DeclareOperation( "PosetRightClick", [IsGraphicSheet, IsInt, IsInt] );
fi;


#############################################################################
##
#O  UserDeleteVerticesOp . . . is called if the user wants to delete vertices
##
##  This operation is called when the user selects "Delete vertices". 
##  The generic method actually deletes the selected vertices including all
##  their edges.
##
if IsBound(UserDeleteVerticesOp) then if not IsOperation(UserDeleteVerticesOp) then
  Error("Identifier UserDeleteVerticesOp already in use!"); fi;
else
  DeclareOperation( "UserDeleteVerticesOp", [IsGraphicSheet, IsMenu, IsString] );
fi;

#############################################################################
##
#O  UserDeleteEdgeOp  . . . . . is called if the user wants to delete an edge
##
##  This operation is called when the user selects "Delete edge". 
##  The generic method deletes the edge with no further warning!
##
if IsBound(UserDeleteEdgeOp) then if not IsOperation(UserDeleteEdgeOp) then
  Error("Identifier UserDeleteEdgeOp already in use!"); fi;
else
  DeclareOperation( "UserDeleteEdgeOp", [IsGraphicSheet, IsMenu, IsString] );
fi;


#############################################################################
##
#O  UserMagnifyLattice . . . . . .  lets the user magnify the graphic lattice
##
##  This operation is called when the user selects "Magnify Lattice". 
##  The generic method scales everything by 144/100 including the sheet,
##  all heights of levels and positions of vertices.
##
if IsBound(UserMagnifyLattice) then if not IsOperation(UserMagnifyLattice) then
  Error("Identifier UserMagnifyLattice already in use!"); fi;
else
  DeclareOperation( "UserMagnifyLattice", [IsGraphicSheet, IsMenu, IsString] );
fi;


#############################################################################
##
#O  UserShrinkLattice . . . . . . .  lets the user shrink the graphic lattice
##
##  This operation is called when the user selects "Shrink Lattice". 
##  The generic method scales everything by 100/144 including the sheet,
##  all heights of levels and positions of vertices.
##
if IsBound(UserShrinkLattice) then if not IsOperation(UserShrinkLattice) then
  Error("Identifier UserShrinkLattice already in use!"); fi;
else
  DeclareOperation( "UserShrinkLattice", [IsGraphicSheet, IsMenu, IsString] );
fi;


#############################################################################
##
#O  UserResizeLattice . . . . . . .  lets the user resize the graphic lattice
##
##  This operation is called when the user selects "Resize Lattice". 
##  The generic method asks the user for a x and a y factor and scales
##  everything including the sheet, all heights of levels and positions of 
##  vertices.
##
if IsBound(UserResizeLattice) then if not IsOperation(UserResizeLattice) then
  Error("Identifier UserResizeLattice already in use!"); fi;
else
  DeclareOperation( "UserResizeLattice", [IsGraphicSheet, IsMenu, IsString] );
fi;


#############################################################################
##
#O  UserResizeSheet . . . . . . . . .  lets the user resize the graphic sheet
##
##  This operation is called when the user selects "Resize Sheet". 
##  The generic method asks the user for a x and a y pixel number and
##  changes the width and height of the sheet. No positions of levels and
##  vertices are changed. If the user asks for trouble he gets it!
##
if IsBound(UserResizeSheet) then if not IsOperation(UserResizeSheet) then
  Error("Identifier UserResizeSheet already in use!"); fi;
else
  DeclareOperation( "UserResizeSheet", [IsGraphicSheet, IsMenu, IsString] );
fi;


#############################################################################
##
#O  UserMoveLattice . . . . . . . . . . . . . lets the user move all vertices
##
##  This operation is called when the user selects "Move Lattice". 
##  The generic method asks the user for a pixel number and
##  changes the position of all vertices horizontally. No positions of 
##  levels are changed. 
##
if IsBound(UserMoveLattice) then if not IsOperation(UserMoveLattice) then
  Error("Identifier UserMoveLattice already in use!"); fi;
else
  DeclareOperation( "UserMoveLattice", [IsGraphicSheet, IsMenu, IsString] );
fi;


#############################################################################
##
#O  UserChangeLabels . . . . . . . .  lets the user change labels of vertices
##
##  This operation is called when the user selects "Change Labels". 
##  The user is prompted for every selected vertex, which label it should
##  have.
##
if IsBound(UserChangeLabels) then if not IsOperation(UserChangeLabels) then
  Error("Identifier UserChangeLabels already in use!"); fi;
else
  DeclareOperation( "UserChangeLabels", [IsGraphicSheet, IsMenu, IsString] );
fi;


#############################################################################
##
#O  UserAverageY . . . . . . . . .  average all y positions within all levels
##
##  This operation is called when the user selects ``Average Y Positions''.
##  In all level the average y coordinate is calculated and all vertices are
##  moved to this y position.
##
if IsBound(UserAverageY) then if not IsOperation(UserAverageY) then
  Error("Identifier UserAverageY already in use!"); fi;
else
  DeclareOperation( "UserAverageY", [IsGraphicSheet, IsMenu, IsString] );
fi;


#############################################################################
##
#O  UserAverageX . . . . . . . . . . average all x positions of sel. vertices
##
##  This operation is called when the user selects ``Average X Positions''.
##  The average of all x coordinates of the selected vertices is calculated.
##  Then all classes with a selected vertex are moved such that the first
##  selected vertex in this class has the calculated position as x position.
##
if IsBound(UserAverageX) then if not IsOperation(UserAverageX) then
  Error("Identifier UserAverageX already in use!"); fi;
else
  DeclareOperation( "UserAverageX", [IsGraphicSheet, IsMenu, IsString] );
fi;


#############################################################################
##
#O  UserRearrangesClasses . . . . . . . . . . rearrange vertices within class
##
##  This operation is called when the user selects ``Rearrange Classes''.
##  All classes with a selected vertex are rearranged: The vertices are
##  lined up neatly one after the other, sorted according to their current
##  x position.
##
if IsBound(UserRearrangeClasses) then 
  if not IsOperation(UserRearrangeClasses) then
    Error("Identifier UserRearrangeClasses already in use!"); fi;
else
  DeclareOperation( "UserRearrangeClasses", 
          [IsGraphicSheet, IsMenu, IsString] );
fi;


############################################################################
##
#O  UserUseBlackWhite . . . . . . . . . .  called if user selects bw in menu
##
##  This is called if the user selects ``Use Black and White'' in the menu.
##
DeclareOperation( "UserUseBlackWhite", [ IsGraphicSheet, IsMenu, IsString ] );


#############################################################################
##
#O  PosetShowLevels  . . . . . . . . . . . . . . . . switch display of levels
##
##  This operation is called when the user selects "Show Levels" in the menu.
##  Switches the display of the little boxes for level handling on and off.
##
if IsBound(PosetShowLevels) then if not IsOperation(PosetShowLevels) then
  Error("Identifier PosetShowLevels already in use!"); fi;
else
  DeclareOperation( "PosetShowLevels", [IsGraphicSheet, IsMenu, IsString] );
fi;


#############################################################################
##
#O  PosetShowLevelparams . . . . . . . . .  switch display of levelparameters
##
##  This operation is called when the user selects "Show Levelparameters" in 
##  the menu. Switches the display of the level parameters at the right of
##  the screen on and off.
##
if IsBound(PosetShowLevelparams) then 
  if not IsOperation(PosetShowLevelparams) then
  Error("Identifier PosetShowLevelparams already in use!"); fi;
else
  DeclareOperation( "PosetShowLevelparams", 
          [IsGraphicSheet, IsMenu, IsString] );
fi;


#############################################################################
##
#O  DoRedraw(<graph>). . . . . . . . . . redraws all vertices and connections
##
##  Redraws all vertices and connections.
##
if IsBound(DoRedraw) then if not IsOperation(DoRedraw) then
  Error("Identifier DoRedraw already in use!"); fi;
else
  DeclareOperation( "DoRedraw", [IsGraphicSheet] );
fi;



