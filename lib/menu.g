#############################################################################
##
#A  menu.g                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: menu.g,v 1.2 1997/12/09 12:37:03 frank Exp $
##
#Y  Copyright (C) 1993,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##
##  This files contains the menu and text selector  functions.  The low level
##  window functions are  in "window.g", the high  level window  functions in
##  "sheet.g".
##
#H  $Log: menu.g,v $
#H  Revision 1.2  1997/12/09 12:37:03  frank
#H  added first tries for documentation, menus
#H
#H  Revision 1.1  1997/11/27 12:20:03  frank
#H  added 3.5 library (does not work with 4.0)
#H
#H  Revision 1.9  1995/08/09  10:52:38  fceller
#H  changed call convention of the text select callback
#H
#H  Revision 1.8  1995/07/24  10:01:24  fceller
#H  changed select mechanism
#H
#H  Revision 1.7  1995/02/16  20:48:22  fceller
#H  changed menu parameters
#H
#H  Revision 1.6  1994/09/22  09:29:00  fceller
#H  added filename dialog
#H
#H  Revision 1.5  1993/10/06  16:19:23  fceller
#H  added 'isAlive'
#H
#H  Revision 1.4  1993/10/05  12:33:26  fceller
#H  added '.isAlive'
#H
#H  Revision 1.3  1993/08/18  11:27:04  fceller
#H  fixed missing 'FILENAME_DIALOG'
#H
#H  Revision 1.2  1993/08/18  10:59:49  fceller
#H  removed emacs variables
#H
#H  Revision 1.1  1993/07/22  11:24:12  fceller
#H  Initial revision
##


#############################################################################
##

#F  PopupMenu( <name>, <labels> ) . . . . . . . . . . . . create a popup menu
##
PopupMenuOps := rec( name := "PopupMenuOps" );

PopupMenu := function( title, lbs )
    local   pop,  str,  i,  id;

    # create window command
    str := Copy(lbs[1]);
    for i  in [ 2 .. Length(lbs) ]  do
        Append( str, "|" );
        Append( str, lbs[i] );
    od;

    # construct a popup menu record
    pop            := WcPopupMenu( title, str );
    pop.title      := title;
    pop.entries    := Copy(lbs);
    pop.operations := PopupMenuOps;

    # and return
    return pop;

end;


#############################################################################
##
#F  PopupMenuOps.Print( <pop> ) . . . . . . . . . . . .  pretty print a popup
##
PopupMenuOps.Print := function( pop )
    Print( "<popup menu \"", pop.title, "\">" );
end;


#############################################################################
##
#F  PopupMenuOps.Query( <pop> ) . . . . . . . . . . . . . .  query popup menu
##
PopupMenuOps.Query := function( args )
    local   res;

    # show popup shell and query user
    res := WcQueryPopup(args[1].id);
    
    # return 'false' or name of entry
    if res = 0  then
    	return false;
    else
    	return args[1].entries[res];
    fi;

end;


#############################################################################
##

#F  TextSelector( <name>, <list>, <buttons> ) . . . .  create a text selector
##
TextSelectorOps := rec( name := "TextSelectorOps" );

TextSelector := function( name, lbs, bts )
    local   str1,  str2,  sel,  i,  lfs,  bfs;
    
    # create label string
    str1 := Copy(lbs[1]);
    for i  in [ 3, 5 .. Length(lbs)-1 ]  do
        Append( str1, "|" );
        Append( str1, lbs[i] );
    od;
    lfs := lbs{[ 2, 4 .. Length(lbs) ]};
    
    # create button string
    str2 := Copy(bts[1]);
    for i  in [ 3, 5 .. Length(bts)-1 ]  do
        Append( str2, "|" );
        Append( str2, bts[i] );
    od;
    bfs := bts{[ 2, 4 .. Length(bts) ]};
    
    # create text selector record
    sel             := WcTextSelector( name, str1, str2 );
    sel.title       := Copy(name);
    sel.labels      := Copy(lbs{[1, 3 .. Length(lbs)-1]});
    sel.buttons     := Copy(bts{[1, 3 .. Length(bts)-1]});
    sel.isAlive     := true;
    sel.selected    := 0;
    sel.buttonFuncs := bfs;
    sel.textFuncs   := lfs;
    sel.operations  := TextSelectorOps;

    # force lables to be real strings
    List( sel.labels, IsString );
    
    # and return
    return sel;
    
end;


#############################################################################
##
#F  TextSelectorOps.ButtonPressed( <sel>, <bid> ) . . . . button <bt> pressed
##
TextSelectorOps.ButtonPressed := function( sel, bid )
    return sel.buttonFuncs[bid]( sel, sel.buttons[bid] );
end;


#############################################################################
##
#F  TextSelectorOps.Close( <sel> )  . . . . . . . . . . . . .  close selector
##
TextSelectorOps.Close := function( sel )
    WcTsClose(sel.id);
    sel.isAlive := false;
end;

TextSelectorOps.Destroy := TextSelectorOps.Close;


#############################################################################
##
#F  TextSelectorOps.Enable( <sel>, <bt>, <flag> ) . . . . . . . enable button
##
TextSelectorOps.Enable := function( sel, bt, flag )
    local   pos;

    pos := Position( sel.buttons, bt );
    if pos = false  then
        Error( "unknown button \"", bt, "\"" );
    fi;
    if flag  then
        WcTsEnable( sel.id, pos, 1 );
    else
        WcTsEnable( sel.id, pos, 0 );
    fi;
    
end;


#############################################################################
##
#F  TextSelectorOps.Print( <sel> )  . . . . . .  pretty print a file selector
##
TextSelectorOps.Print := function( sel )
    Print( "<text selector \"", sel.title, "\">" );
end;


#############################################################################
##
#F  TextSelectorOps.Relabel( <sel>, <text> )  . . . . . . . . .  set new text
##
TextSelectorOps.Relabel := function( sel, text )
    local   str,  i;
    
    if Length(text) <> Length(sel.labels)  then
        Error( "the text selector has ", Length(sel.labels), " labels" );
    fi;
    str := Copy(text[1]);
    for i  in [ 2 .. Length(text) ]  do
        Append( str, "|" );
        Append( str, text[i] );
    od;
    WcTsChangeText( sel.id, str );
    sel.labels := Copy(text);
    List( sel.labels, IsString );
end;


#############################################################################
##
#F  TextSelectorOps.Reset( <sel> )  . . . . . . . . . . . . . remove highligh
##
TextSelectorOps.Reset := function( sel )
    WcTsUnhighlight(sel.id);
end;


#############################################################################
##
#F  TextSelectorOps.TextSelected( <sel>, <tid> )  . . . . . . . text selected
##
TextSelectorOps.TextSelected := function( sel, tid )
    if 0 < tid  then
        sel.selected := tid;
        return sel.textFuncs[tid]( sel, sel.labels[tid] );
    fi;
end;


#############################################################################
##

#F  Dialog( <type>, <text> )  . . . . . . . . . . . . . create a popup dialog
##
DialogOps := rec( name := "DialogOps" );

Dialog := function( type, text )
    local   dial;

    # create a dialog record
    dial            := rec( isDialog := true );
    dial.text       := Copy(text);
    dial.operations := DialogOps;

    # check type
    if type = "OKcancel"  then
    	dial.type   := 1;
        dial.cancel := 1;
    elif type = "Filename"  then
    	dial.type   := 2;
        dial.cancel := 1;
    else
    	Error( "unknown type \"", type, "\"" );
    fi;
    dial.typeName := Copy(type);

    # return
    return dial;

end;


#############################################################################
##
#F  DialogOps.Print( <dial> ) . . . . . . . . . . . . . pretty print a dialog
##
DialogOps.Print := function( dial )
    Print( "<dialog \"", dial.typeName, "\">" );
end;

    
#############################################################################
##
#F  DialogOps.Query( <dial>, <def> )  . . . . . . query dialog (with default)
##
DialogOps.Query := function( args )
    local   res,  dial;

    # get dialog
    dial := args[1];
    
    # if we have a default use this
    if 1 < Length(args)  then
        res := WcDialog( dial.type, dial.text, String(args[2]) );
    else
        res := WcDialog( dial.type, dial.text, "" );
    fi;
    
    # return the result
    if res[1] = dial.cancel  then
    	return false;
    else
    	return res[2];
    fi;

end;
    

#############################################################################
##

#V  FILENAME_DIALOG . . . . . . . . . . . . . . a dialog asking for filenames
##
FILENAME_DIALOG := Dialog( "Filename", "Enter a filename" );
