#############################################################################
##
#A  init.g                      XGAP library                     Frank Celler
##
#H  @(#)$Id: init.g,v 1.1 1997/11/27 12:20:01 frank Exp $
##
#Y  Copyright (C) 1993,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##
#H  $Log: init.g,v $
#H  Revision 1.1  1997/11/27 12:20:01  frank
#H  added 3.5 library (does not work with 4.0)
#H
#H  Revision 1.11  1995/09/25  08:06:54  fceller
#H  added support for module lattices
#H
#H  Revision 1.10  1995/08/16  12:46:14  fceller
#H  set version number to 1.3
#H
#H  Revision 1.9  1995/08/09  10:55:49  fceller
#H  added PSL, TrefoilKnotGroup, SeidelHex
#H
#H  Revision 1.8  1995/07/28  10:05:14  fceller
#H  added 'XGAPLIBNAME' and 'EpimorphismsFpGroup'
#H
#H  Revision 1.7  1995/07/24  10:01:24  fceller
#H  changed select mechanism
#H
#H  Revision 1.6  1995/03/06  11:41:19  fceller
#H  added interactive lattice stuff
#H
#H  Revision 1.5  1994/06/11  09:27:57  fceller
#H  updated release number
#H
#H  Revision 1.4  1993/10/18  11:06:14  fceller
#H  added fast updated
#H
#H  Revision 1.3  1993/10/06  16:19:23  fceller
#H  added 'GraphicLatticeOps'
#H
#H  Revision 1.2  1993/10/05  12:33:26  fceller
#H  added '.isAlive'
#H
#H  Revision 1.1  1993/08/18  10:59:09  fceller
#H  Initial revision
##


## set version ##############################################################
XGAPVERSION := "Version 1 Release 3";

## read in original init file ###############################################
ReadPath := function ( path, name, ext )
    local   i, k, file, found;
    i := 1;
    found := false;
    while not found  and i <= Length(path)+1 do
        k := Position( path, ';', i-1 );
        if k = false  then k := Length(path)+1;  fi;
        file := path{[i..k-1]};  Append( file, name );  Append( file, ext );
        found := READ( file );
        i := k + 1;
    od;
    return found;
end;

XGAPLIBNAME := LIBNAME{[ 1 .. Position(LIBNAME,';')-1 ]};
GAPLIBNAME  := LIBNAME{[ Position(LIBNAME,';')+1 .. Length(LIBNAME) ]};
ReadPath( GAPLIBNAME, "init", ".g" );

## print banner #############################################################
if BANNER  then
    Print( "\n     X-Window ", XGAPVERSION, " by\n",
             "     Frank Celler and Susanne Keitemeier\n\n" );
fi;

## set editor ###############################################################
if not IsBound(EDITOR)  then 
    EDITOR := "xterm -e vi";
fi;

## initialize window/selectors lists ########################################
WINDOWS   := [];
SELECTORS := [];
PERM_GROUP := 0;

## auto read library ########################################################
AUTO( ReadLib("fpextra"),
      IsSubgroupFpGroup, PseudoSubgroup, ExtraDiagonalizeMat,
      ExtraElementaryDivisorsMat, DerivedQuotInvariantsFpGroup,
      ModuloAdditionVectors,VectorToInt, NextVector,
      RegularActionAbelianGroup, CosetTableAction, WreathProductActions,
      AddSchreierGens, DerivedSubgroupFpGroup, WreathProductCosetTables,
      ExtraPresentationAugmentedCosetTable, PresentationSubgroupGivenGens,
      PresentationCosetTable, PresentationAction, CosetTableIntersection,
      IntersectionNormalSubgroups, BlocksCosetTable, TablesConjugacyClass,
      RegularCosetTable, AllBlocks, IntermediateCosetTables );

AUTO( ReadLib("glatgrp"),
      IntString, GraphicLattice, GraphicLatticeOps );

AUTO( ReadLib("glatlist"),
      GraphicLatticeRecord, GraphicLatticeRecordOps );

AUTO( ReadLib("ilatgrp"),
      InteractiveLattice, InteractiveLatticeOps );

AUTO( ReadLib("ilatfpgp"),
      InteractiveFpLattice, InteractiveFpLatticeOps );

AUTO( ReadLib("ilatmamo"),
      InteractiveModuleLattice, InteractiveModuleLatticeOps );

AUTO( ReadLib("menu"),
      FILENAME_DIALOG, Menu, TextSelector, Dialog, PopupMenu );

AUTO( ReadLib("permimag"),
      EpimorphismsFpGroup );

AUTO( ReadLib("sheet"),
      GraphicSheet, GraphicSheetOps, 
      Line, Box, Circle, Disc, Diamond, Text, Vertex, VERTEX );

AUTO( ReadLib("window"),
      FONTS, BUTTONS, COLORS, PointerButtonDown, MenuSelected, TextSelected,
      ButtonSelected, Drag, WcAddMenu, WcCheckMenu, WcCloseWindow, WcDestroy,
      WcDialog, WcDrawBox, WcDrawCircle, WcDrawDisc, WcDrawLine, WcDrawText,
      WcEnableMenu, WcOpenWindow, WcPopupMenu, WcQueryPointer, WcQueryPopup,
      WcResizeWindow, WcSetLineWidth, WcSetTitle, WcTextSelector,
      WcTsChangeText, WcTsClose, WcTsEnable, WcTsUnhighlight, WcFastUpdate,
      WcSetColor, WcDeleteMenu );

AUTO( ReadLib("xabattoi"),
      PrintGS );

AUTO( ReadLib("xdispatc"),
      Close, Delete, SetTitle, Highlight, Move, Relabel, Reshape, Recolor,
      Connection, Disconnect, Enable, Check, Query, InstallGSMethod,
      InstallPointerButtonDown, FastUpdate );

AUTO( ReadGrp("projecti"),
      ProjectiveSpecialLinearGroup, PSL );

AUTO( ReadGrp("knotgrp"),
      TrefoilKnotGroup );

AUTO( ReadGrp("seidelhx"),
      SeidelHex );


## meataxe functions ########################################################
if not IsBound(IsPartialModuleLattice)  then
    IsPartialModuleLattice := function(obj) return false; end;
fi;


## Playback ##################################################################
Playback := function( name )
    WindowCmd( [ "XPF", name ] );
end;

ResumePlayback := function()
    WindowCmd( [ "XRP" ] );
end;
