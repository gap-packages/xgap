/****************************************************************************
**
*A  utils.c                     XGAP Source                      Frank Celler
**
*H  @(#)$Id: utils.c,v 1.1 1997/11/25 15:52:50 frank Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This  file contains the  utility  functions  and  macros  used in   XGAP,
**  basically  the list functions  ('ELM', 'LEN',  'AddList', and 'List') and
**  the  debug  macro ('DEBUG').  This  file also  includes all the necessary
**  system and X11 include files and defines the following data types:
**
**      Boolean         "True" or "False" (defined by X11)
**      Char            a "Char" will be able to hold one character
**      Int             a 32-bit signed integer
**      Long            an integer able to hold a pointer
**      Pointer         a generic pointer
**      Short           a 16-bit signed integer
**      String          an array of chars
**      UChar           unsigned version of "Char"
**      UInt            a 32-bit unsigned integer
**      ULong           unsigned version of "Long"
**      UShort          a 16-bit unsigned integer
**
**  List( <len> )
**  -------------
**  'List' creates a new list able to hold <len> pointers of type 'Pointer'.
**
**  AddList( <lst>, <elm> )
**  -----------------------
**  'AddList' appends  the  new  element  <elm> of type  'Pointer'  to <lst>,
**  enlarging the list if necessary.
**
**  ELM( <lst>, <i> )
**  -----------------
**  'ELM' returns the <i>.th element of <lst>.
**
**  LEN( <lst> )
**  ------------
**  'LEN' returns the length of <lst>.
**
**  DEBUG( <type>, ( <debug-text>, ... ) )
**  --------------------------------------
**  'DEBUG' uses 'printf' to print the  <debug-text> in case that  'Debug' &&
**  <type> is true.  The text  is preceded by the line number  and the source
**  file name.  The following types are available:  D_LIST, D_XCMD, D_COMM.
**
*H  $Log: utils.c,v $
*H  Revision 1.1  1997/11/25 15:52:50  frank
*H  first attempt at XGAP for GAP 4
*H
*H  Revision 1.5  1995/07/24  09:28:30  fceller
*H  reworked most parts to use nice typedefs
*H
*H  Revision 1.4  1994/06/06  08:57:24  fceller
*H  added database
*H
*H  Revision 1.3  1993/12/23  08:47:41  fceller
*H  removed malloc debug functions
*H
*H  Revision 1.2  1993/10/18  11:04:47  fceller
*H  added fast updated,  fixed timing problem
*H
*H  Revision 1.1  1993/04/13  07:16:39  fceller
*H  added 'SYS_HAS_STDARG
*H
*H  Revision 1.0  1993/04/05  11:42:18  fceller
*H  Initial revision
*/
#include    "utils.h"


/****************************************************************************
**
*V  Debug . . . . . . . . . . . . . . . . . . . . . . . . . . .  debug on/off
*/
Int Debug = 0;


/****************************************************************************
**
*F  List( <len> )   . . . . . . . . . . . . . . . . . . .   create a new list
*/
#ifdef DEBUG_ON
TypeList LIST ( file, line, len )
    String	file;
    Int         line;
    UInt        len;
#else
TypeList List ( len )
    UInt        len;
#endif
{
    TypeList    list;

    /* get memory for new list */
    list       = (TypeList) XtMalloc( sizeof( struct _list ) );
    list->len  = len;
    list->size = len+10;
    list->ptr  = (Pointer) XtMalloc( list->size * sizeof(Pointer) );

    /* give some debug information */
#ifdef DEBUG_ON
    if ( Debug & D_LIST )
	printf( "%04d:%s: List(%d)=%p\n", line, file, len, (void*)list );
#endif

    /* return the new list */
    return list;
}


/****************************************************************************
**
*F  AddList( <lst>, <elm> ) . . . . . . . .  add list element <elm> to <list>
*/
#ifdef DEBUG_ON
void ADD_LIST ( file, line, lst, elm )
    String	file;
    Int         line;
    TypeList    lst;
    Pointer     elm;
#else
void AddList ( lst, elm )
    TypeList    lst;
    Pointer     elm;
#endif
{
    /* give some debug information */
#ifdef DEBUG_ON
    if ( Debug & D_LIST )
	printf( "%04d:%s: AddList( %p, %p )\n", line, file, (void*)lst,
	        (void*)elm );
#endif

    /* resize <lst> if necessary */
    if ( lst->len == lst->size )
    {
        lst->size = lst->size*4/3 + 5;
        lst->ptr  = (Pointer) XtRealloc( (char*) lst->ptr,
                                         lst->size * sizeof(Pointer) );
    }

    /* and add list element */
    lst->ptr[lst->len++] = elm;
}
