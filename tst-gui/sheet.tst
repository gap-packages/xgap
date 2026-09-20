# graphic objects on a plain sheet
gap> sheet := GraphicSheet( "test", 300, 200 );;
gap> IsAlive( sheet );
true
gap> box := Box( sheet, 10, 10, 50, 30 );;
gap> rect := Rectangle( sheet, 70, 10, 50, 30 );;
gap> circle := Circle( sheet, 150, 25, 15 );;
gap> disc := Disc( sheet, 200, 25, 15 );;
gap> line := Line( sheet, 10, 60, 100, 20 );;
gap> text := Text( sheet, FONTS.normal, 10, 120, "hello" );;
gap> Length( sheet!.objects );
6
gap> Move( box, 20, 20 );
gap> [ box!.x, box!.y ];
[ 20, 20 ]
gap> Reshape( circle, 20 );
gap> circle!.r;
20
gap> Recolor( disc, COLORS.red );
gap> Delete( line );
gap> IsAlive( line );
false
gap> Resize( sheet, 400, 300 );
gap> [ sheet!.width, sheet!.height ];
[ 400, 300 ]
gap> Close( sheet );
gap> IsAlive( sheet );
false
