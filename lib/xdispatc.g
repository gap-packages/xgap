#############################################################################
##
#A  dispatch.g                 	XGAP library                     Frank Celler
##
#H  @(#)$Id: xdispatc.g,v 1.1 1997/11/27 12:20:11 frank Exp $
##
#Y  Copyright (C) 1995,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##
#H  $Log: xdispatc.g,v $
#H  Revision 1.1  1997/11/27 12:20:11  frank
#H  added 3.5 library (does not work with 4.0)
#H
#H  Revision 1.2  1995/08/09  10:50:22  fceller
#H  added dispatcher 'Select' and 'Selected'
#H
#H  Revision 1.1  1995/07/24  09:59:41  fceller
#H  Initial revision
##


#############################################################################
##
#F  Check( <menu>, <entry>, <flag> )  . . . . . . . . . . .  check menu entry
##
Check := function( arg )
    if 2 = Length(arg)  then
        return arg[1].operations.Check( arg[1], arg[2], true );
    elif 3 = Length(arg)  then
        return arg[1].operations.Check( arg[1], arg[2], arg[3] );
    else
        Error( "usage: Check( <menu>, <entry>, <flag> )" );
    fi;
end;


#############################################################################
##
#F  Close( <sheet> )  . . . . . . . . . . . . . . . . . . . . .  close window
##
Close := function( obj )
    return obj.operations.Close(obj);
end;


#############################################################################
##
#F  Connection( <o1>, <o2> )  . . . . . . . . . . . . . . connect two objects
##
Connection := function( o1, o2 )
    if not o1.isAlive  then Error( "<o1> must be alive" );  fi;
    if not o2.isAlive  then Error( "<o2> must be alive" );  fi;
    return o1.operations.Connection( o1, o2 );
end;


#############################################################################
##
#F  Delete( <obj> ) . . . . . . . . . . . . . . . . . . . . . .  delete <obj>
##
Delete := function( obj )
    obj.operations.Delete(obj);
end;


#############################################################################
##
#F  Disconnect( <o1>, <o2> )  . . . . . . . . . . . .  disconnect two objects
##
Disconnect := function( o1, o2 )
    if not o1.isAlive  then Error( "<o1> must be alive" );  fi;
    if not o2.isAlive  then Error( "<o2> must be alive" );  fi;
    o1.operations.Disconnect( o1, o2 );
end;


#############################################################################
##
#F  Enable( <menu>, <entry>, <flag> ) . . . .  enable an object for selection
##
Enable := function( arg )
    if 2 = Length(arg)  then
        return arg[1].operations.Enable( arg[1], arg[2], true );
    elif 3 = Length(arg)  then
        return arg[1].operations.Enable( arg[1], arg[2], arg[3] );
    else
        Error( "usage: Enable( <menu>, <entry>, <flag> )" );
    fi;
end;


#############################################################################
##
#F  FastUpdate( <sheet, <flag> )  . . . . . . . . . . . .  fast update on/off
##
FastUpdate := function( arg )
    if Length(arg) = 1  then
        return arg[1].operations.FastUpdate( arg[1], true );
    elif Length(arg) = 2  then
        return arg[1].operations.FastUpdate( arg[1], arg[2] );
    else
        Error( "usage: FastUpdate( <sheet>, <flag> )" );
    fi;
end;


#############################################################################
##
#F  Highlight( <obj>, <flag> )  . . . . . . . . . . . . . highlight an object
##
Highlight := function( arg )
    local   obj, flag;

    if Length(arg) = 1  then
        obj  := arg[1];
        flag := true;
    elif Length(arg) = 2  then
        obj  := arg[1];
        flag := arg[2];
    else
        Error( "usage: Highlight( <obj>, <flag> )" );
    fi;
    if not obj.isAlive  then Error( "<obj> must be alive" );  fi;
    return obj.operations.Highlight( obj, flag );
end;


#############################################################################
##
#F  InstallGSMethod( <sheet>, <name>, <meth> )  . . . . . . . . .  use <meth>
##
InstallGSMethod := function( sheet, name, meth )
    sheet.operations.InstallGSMethod( sheet, name, meth );
end;


#############################################################################
##
#F  Move( <obj>, <x>, <y> ) . . . . . . . . . . .  move <obj> to new position
##
Move := function( obj, x, y )
    if not obj.isAlive  then Error( "<obj> must be alive" );  fi;
    return obj.operations.Move( obj, x, y );
end;


#############################################################################
##
#F  MoveDelta( <obj>, <dx>, <dy> )  . . . . . . . . . . . . .  move an object
##
MoveDelta := function( obj, dx, dy )
    if not obj.isAlive  then Error( "<obj> must be alive" );  fi;
    return obj.operations.MoveDelta( obj, dx, dy );
end;


#############################################################################
##
#F  Query( <obj>, ... ) . . . . . . query a dialog/menu and return the result
##
Query := function( arg )
    return arg[1].operations.Query(arg);
end;


#############################################################################
##
#F  Recolor( <obj>, <color> ) . . . . . . . . . change the color of an object
##
Recolor := function( obj, color )
    if not obj.isAlive  then Error( "<obj> must be alive" );  fi;
    return obj.operations.Recolor( obj, color );
end;


#############################################################################
##
#F  Relabel( <obj>, <text> )  . . . . . . . . . . . . . . . relabel an object
##
Relabel := function( obj, text )
    if not obj.isAlive  then Error( "<obj> must be alive" );  fi;
    return obj.operations.Relabel( obj, text );
end;


#############################################################################
##
#F  Reset( <obj> )  . . . . . . . . . . . . . . . . . . . . . reset an object
##
Reset := function( obj )
    return obj.operations.Reset(obj);
end;


#############################################################################
##
#F  Reshape( <obj>, ... ) . . . . . . . . . . . . . . . . . reshape an object
##
Reshape := function( arg )
    if not arg[1].isAlive  then Error( "<obj> must be alive" );  fi;
    return ApplyFunc( arg[1].operations.Reshape, arg );
end;


#############################################################################
##
#F  Select( <S>, <list> ) . . . . . . . . . . . . . . . . select given groups
##
Select := function( S, l )
    if not IsList(l)  then
        l := [l];
    fi;
    return S.operations.Select( S, l );
end;


#############################################################################
##
#F  Selected( <S> ) . . . . . . . . . . . . . . . . .  return selected groups
##
Selected := function( S )
    return S.operations.Selected(S);
end;


#############################################################################
##
#F  SetTitle( <sheet>, <title> )  . . . . . . . . . . . . . . . . add a title
##
SetTitle := function( sheet, text )
    return sheet.operations.SetTitle( sheet, text );
end;


#############################################################################
##
#F  SetWidth( <obj>, <width> )  . . . . . . . . change the width of an object
##
SetWidth := function( obj, width )
    if not obj.isAlive  then Error( "<obj> must be alive" );  fi;
    return obj.operations.SetWidth( obj, width );
end;


#############################################################################
##
