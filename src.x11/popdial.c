/****************************************************************************
**
*A  popdial.c			XGAP source	                 Frank Celler
**
*H  @(#)$Id: popdial.c,v 1.1 1997/11/25 15:52:43 frank Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This  file  contains functions for popping up dialogs.  Two functions are
**  exported:
**
**  CreatePopupDialog( <app>, <top>, <name>, <bt>, <def>, <pix> )
**  -------------------------------------------------------------
**
**  'CreatePopupDialog'  creates a popup dialog  structure.  A popup shell of
**  type "transientShellWidgetClass" is created together with a dialog widget
**  and  buttons according to <bt>. None  of these widgets are realised, this
**  is  done by   calling 'PopupDialog'.  The  default   button  activated by
**  pressing "return" is <def>.
**
**  Possible buttons are: PD_YES, PD_NO, PD_OK, PD_CANCEL, PD_ABORT, PD_RETRY
**                        PD_APPEND, PD_OVERWRITE
**
**  PopupDialog( <dialog>, <message>, <deflt>, <result> )
**  -----------------------------------------------------
**
**  'PopupDialog' will pop up a dialog created  with 'CreatePopupDialog'.  It
**  then grabs  the keyboard  and  returns only if a   button or  "return" is
**  pressed.  A pointer to the result is stored in <result> and the number of
**  the button  pressed  is returned.  If  "return"  was hit by  the user the
**  button number is the number given as <def> in 'CreatePopupDialog'.
**
**  The layout of the popup dialog is basically:
**
**       +-----------------------------------------+
**       |                                         |
**       |  pixmap    some text <message>          |
**       |  <pix>                                  |
**       |                                         |
**       |  [[[ INPUT FIELD (default: <deflt>) ]]] |
**       |                                         |
**       |  Btn1  Btn2 ... BtnN                    |
**       |                                         |
**       +-----------------------------------------+
**
**  PopupDialogBrokenWM()
**  ---------------------
**
**  Some window  manager  don't handle transient shell widgets correctly.  In
**  this case  calling  'PopupDialogBrokenWM' will  toggle  a flag such  that
**  a override shell widet is used instead.
**
*H  $Log: popdial.c,v $
*H  Revision 1.1  1997/11/25 15:52:43  frank
*H  first attempt at XGAP for GAP 4
*H
*H  Revision 1.4  1995/07/24  09:28:30  fceller
*H  reworked most parts to use nice typedefs
*H
*H  Revision 1.3  1995/01/24  11:14:36  fceller
*H  a dot cursor is show if the cursor is inside a button
*H
*H  Revision 1.2  1993/12/23  08:45:54  fceller
*H  used unsigned bitmaps to avoid compiler warnings
*H
*H  Revision 1.1  1993/08/12  13:50:35  fceller
*H  fixed keyboard grab on dec station
*H
*H  Revision 1.0  1993/04/05  11:42:18  fceller
*H  Initial revision
*/
#include    "utils.h"
#include    "popdial.h"			/* this package */


/****************************************************************************
**
*F  ButtonSelected( <w>, <cld>, <cd> )	. . . . . . callback for button click
*/
static struct { String name;  Int flag; } buttons[] =
{
    { "yes",	    PD_YES       },
    { "no",         PD_NO        },
    { "OK",         PD_OK        },
    { "cancel",     PD_CANCEL    },
    { "abort",      PD_ABORT     },
    { "retry",      PD_RETRY     },
    { "append",     PD_APPEND    },
    { "overwrite",  PD_OVERWRITE }
};

static void ButtonSelected ( w, cld, cd )
    Widget	    w;
    XtPointer       cld;
    XtPointer       cd;
{
    Int             i;
    Int           * res = (int*) cld;
    String          name;

    /* find name in <buttons> and set result */
    XtVaGetValues( w, XtNlabel, &name, 0, 0 );
    for ( i = 0;  i < XtNumber(buttons);  i++ )
	if ( ! strcmp( buttons[i].name, name ) )
	    (*res) |= buttons[i].flag;
}


/****************************************************************************
**
*F  CreatePopupDialog( <app>, <top>, <name>, <button>, <def>, <pix> )  create
*/
#include "bitmaps/return.bm"

static Boolean BrokenWM = False;

TypePopupDialog CreatePopupDialog ( app, top, name, bt, def, pix )
    XtAppContext        app;
    Widget	        top;
    String              name;
    Int                 bt;
    Int                 def;
    Pixmap              pix;
{
    Display           * dp;
    TypePopupDialog     dialog;
    Int                 i;
    static Pixmap       symbol = 0;              

    
    /* create pixmap for default button */
    if ( symbol == 0 )
    {
	dp = XtDisplay(top);
	symbol = XCreateBitmapFromData( dp, DefaultRootWindow(dp),
                     return_bits, return_width, return_height );
    }

    /* create a new popup variable */
    dialog = (TypePopupDialog) XtMalloc( sizeof( struct _popup_dialog ) );
    dialog->topLevel   = top;

    if ( BrokenWM )
        dialog->popupShell = XtVaCreatePopupShell(
                                 name, overrideShellWidgetClass,  top,
		                 XtNallowShellResize, True,
			         0 );
    else
        dialog->popupShell = XtVaCreatePopupShell(
	    		         name, transientShellWidgetClass, top,
			         XtNallowShellResize, True,
			         XtNtransientFor,     top,
			         0 );
    if ( pix == 0 )
        dialog->dialog = XtVaCreateManagedWidget(
                             "xgapDialog",  dialogWidgetClass,
                             dialog->popupShell,
                             0, 0 );
    else
        dialog->dialog = XtVaCreateManagedWidget(
                             "xgapDialog",  dialogWidgetClass,
                             dialog->popupShell,
                             XtNicon, pix,
                             0, 0 );
    dialog->button        = bt;
    dialog->context       = app;
    dialog->defaultButton = def;

    /* add buttons to the dialog */
    for ( i = 0;  i < XtNumber(buttons);  i++ )
	if ( bt & buttons[i].flag )
	{
	    if ( buttons[i].flag == def )
		dialog->buttons[i] = XtVaCreateManagedWidget(
			    buttons[i].name, commandWidgetClass,
			    dialog->dialog, 
			    XtNleftBitmap, symbol,
			    0, 0 );
	    else
		dialog->buttons[i] = XtVaCreateManagedWidget(
			    buttons[i].name, commandWidgetClass,
			    dialog->dialog, 
			    0, 0 );
	    XtAddCallback( dialog->buttons[i],
			   XtNcallback,
			   ButtonSelected,
			   &(dialog->result) );
	}
	else
	    dialog->buttons[i] = 0;
    return dialog;
}


/****************************************************************************
**
*F  PopupDialogBrokenWM() . . . . . . . . . . . . . .  toggle <BrokenWM> flag
*/
void PopupDialogBrokenWM ( )
{
    BrokenWM = ! BrokenWM;
}


/****************************************************************************
**
*F  PopupDialog( <dialog>, <message>, <deflt>, <result> ) . . . . . . . do it
*/
static Cursor BlobCursor = 0;

Int PopupDialog ( dialog, message, deflt, result )
    TypePopupDialog	dialog;
    String              message;
    String              deflt;
    String *            result;
{
    Display *           display;
    Position            x1,  y1,  tmp;
    Dimension           w1,  h1,  bw;
    Window              root;
    Window              child;
    Int        	        x2,  y2,  x3,  y3;
    UInt                bt;
    Int                 i;

    /* create font cursor */
    display = XtDisplay(dialog->popupShell);
    if ( BlobCursor == 0 )
	BlobCursor = XCreateFontCursor( display, XC_dot );

    /* set message and default answer in dialog */
    XtVaSetValues( dialog->dialog,
		   XtNlabel, 	"            ",
		   XtNvalue,    "                      ",
		   0,           0 );
    XtRealizeWidget( dialog->popupShell );
    XtVaSetValues( dialog->dialog,
		   XtNlabel, 	message,
		   XtNvalue,    deflt,
		   0,           0 );

    /* get size of popup dialog */
    XtVaGetValues( dialog->popupShell,
		   XtNwidth,       &w1,
		   XtNheight,      &h1,
		   XtNborderWidth, &bw,
		   0,              0 );

    /* get position of the mouse pointer */
    XQueryPointer( display, XtWindow(dialog->popupShell),
		   &root, &child, &x2, &y2, &x3, &y3, &bt );

    /* find a nice position for the dialog */
    tmp = DisplayWidth( display, DefaultScreen(display) );
    x1 = x2 - (bw+w1)/2;
    if ( tmp-w1-2*bw < x1 )  x1 = tmp-w1-2*bw;
    if ( x1 < 0 )  x1 = 0;
    tmp = DisplayHeight( display, DefaultScreen(display) );
    y1  = y2 - (bw+h1)/2;
    if ( tmp-h1-2*bw < y1 )  y1 = tmp-h1-2*bw;
    if ( y1 < 0 )  y1 = 0;

    /* move the popup dialog to this position */
    XtVaSetValues( dialog->popupShell,
		   XtNx, x1,
		   XtNy, y1,
		   0,    0 );

    /* pop up shell */
    XtPopup( dialog->popupShell, XtGrabExclusive );
    for ( i = 0;  i < XtNumber(buttons);  i++ )
	if ( dialog->buttons[i] )
	    XDefineCursor( display,
			   XtWindow(dialog->buttons[i]), BlobCursor );


    /* and grab keyboard */
    XGrabKeyboard( display, XtWindow(dialog->dialog), False,
		   GrabModeAsync, GrabModeAsync, CurrentTime );

    /* wait until at least one button is selected */
    dialog->result = 0;
    while ( ( dialog->result & dialog->button ) == 0 )
    {
	XEvent	event;
	char    str[128];
	KeySym  keysym;
	Int     len;

	/* get next application event */
	XtAppNextEvent(dialog->context, &event);

	/* is the event a key event */
	if ( event.type == KeyPress )
	{
	    if ( dialog->defaultButton != 0 )
	    {

		/* convert key event into text string and check for return */
		len = XLookupString((XKeyEvent*)&event,str,128,&keysym,0);
		if ( len != 0 && ( str[0] == '\n' || str[0] == '\r' ) )
		{
		    dialog->result |= dialog->defaultButton;
		    continue;
		}
	    }
	}

	/* dipatch event normally */
	XtDispatchEvent(&event);
    }

    /* return answer string in <result> */
    if ( result )
        *result = XawDialogGetValueString(dialog->dialog);
    
    /* remove pop up menu from screen */
    XtPopdown(dialog->popupShell);
    return dialog->result & dialog->button;
}
