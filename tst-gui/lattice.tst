# an interactive lattice starts with the whole group and the trivial subgroup
gap> sheet := GraphicSubgroupLattice( SymmetricGroup( 4 ) );;
gap> nrVertices := s -> Sum( Levels( s ),
>        l -> Sum( Classes( s, l ), c -> Length( Vertices( s, l, c ) ) ) );;
gap> nrVertices( sheet );
2

# the entries of the "Subgroups" menu act on the selected vertices
gap> menu := sheet!.menus[3];;
gap> SetInfoLevel( GraphicLattice, 0 );
gap> Select( sheet, sheet!.WholeGroupVert, true );
gap> GGLMenuOperation( sheet, menu, "DerivedSubgroups" );
gap> nrVertices( sheet );
3
gap> GGLMenuOperation( sheet, menu, "All Subgroups" );
gap> nrVertices( sheet );
30

# "SelectedGroups to GAP" hands the selection to the user in `last'
gap> DeselectAll( sheet );
gap> Select( sheet, sheet!.WholeGroupVert, true );
gap> GGLMenuOperation( sheet, menu, "SelectedGroups to GAP" );
gap> last = [ SymmetricGroup( 4 ) ];
true
gap> SetInfoLevel( GraphicLattice, 1 );
gap> Close( sheet );
