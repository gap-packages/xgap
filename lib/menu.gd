#############################################################################
##
#O  Menu( <window>, <title>, <ents>, <fncs> )  add a menu to a graphic window
##
Menu := NewOperation( Menu,
    [ IsGraphicWindow, IsString, IsList, IsList ] );


#############################################################################
##
#F  MenuOps.Print( <menu> ) . . . . . . . . . . . . . . . pretty print a menu
##
MenuOps.Print := function( menu )
    if menu.isAlive  then
        Print( "<menu \"", menu.title, "\">" );
    else
        Print( "<dead menu>" );
    fi;
end;


