#############################################################################
##
#A  permimag.g                 	XGAP library                     Frank Celler
##                                                               & Sarah Rees
##
#H  @(#)$Id: permimag.g,v 1.1 1997/11/27 12:20:05 frank Exp $
##
#Y  Copyright (C) 1995,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##
##  $Log: permimag.g,v $
##  Revision 1.1  1997/11/27 12:20:05  frank
##  added 3.5 library (does not work with 4.0)
##
#H  Revision 1.1  1995/07/28  09:59:12  fceller
#H  Initial revision
#H
##


#############################################################################
##
#F  CheckRelators( <sort>, <img>, <level> ) . . . . . . check sorted relators
##
CheckRelators := function( sort, imgs, level )
    local   gens,  id,  r;

    # truncate the number of gens and imgs to <level>
    gens := sort.generators{[ 1 .. level ]};
    imgs := imgs{[ 1 .. level ]};
    id   := imgs[1]^0;

    # check the new level
    for r  in sort.relators[level]  do
        if MappedWord( r, gens, imgs ) <> id  then
            return false;
        fi;
    od;
    return true;

end;


#############################################################################
##
#F  SortedRelators( <f> ) . . . sort relators of <f> according to occurrences
##
SortedRelators := function( f )
    local   relators,  finish,  new,  j,  i,  flt,  rels,  glist,  
            min,  fst,  gns;

    # check for the trivial case (Sarah says!)
    if 0 = Length(f.relators)  then
        return rec( generators := f.generators,
                    relators   := List([1..Length(f.generators)],x->[]),
                    finish     := Length(f.generators) );
    fi;
                    
    # explode the relators
    new := [];
    for j  in [ 1 .. Length(f.relators) ]  do
        new[j] := [];
        for i  in [ 1 .. LengthWord(f.relators[j]) ]  do
            fst := Subword( f.relators[j], i, i );
            if not fst in f.generators  then
                fst := fst^-1;
            fi;
            AddSet( new[j], fst );
        od;
    od;

    # <rels> will collect all the relator lists
    rels := [];

    # <glist> will conatin the generators in the new order
    glist := [];

    # select one which contains least number of generators
    flt := Filtered( new, x -> 0 < Length(x) );

    # if <flt> is non-empty,  we have found a new relators
    repeat

        min := Minimum( List( flt, Length ) );

        # find the first relator with the minimal number of generators
        fst := PositionProperty( new, x -> Length(x) = min );

        # copy these generators and append them to the generator list
        gns := ShallowCopy(new[fst]);
        Append( glist, gns );
        for i  in [ 1 .. Length(gns) ]  do
            Add( rels, [] );
        od;

        # store all relators involving these generators
        for i  in [ 1 .. Length(new) ]  do
            if 0 < Length(new[i]) and new[i] = gns  then
                Add( rels[Length(rels)], f.relators[i] );
            fi;
            SubtractSet( new[i], gns );
        od;
        flt := Filtered( new, x -> 0 < Length(x) );
    until 0 = Length(flt);

    # check if any generators is free
    new := Difference( Set(f.generators), glist );
    for i  in [ 1 .. Length(new) ]  do
        Add( rels, [] );
    od;
    Append( glist, new );

    return rec( generators := glist,
                relators   := rels,
                finish     := Length(glist) );
end;


#############################################################################
##
#F  EpimorphismsFpGroup( <f>, <p> ) .  check for epimorphisms from <f> to <u>
##
EpimorphismsFpGroup := function( arg )

    local	f,	    # finitely presented group
                p,          # the range
                u,          # a subgroup to be contained in the image
                sort,       # sort relators of <f>
                rc,         # representatives for the conj classes of <p>
                r,          # one representative of <rc>
                cr,         # the centralizer of <r>
                all,        # all maps from <f> to <p> containing <u>
                new,        # all maps starting with <r>
                base,       # base for <p>
                trv,        # left trans for p_i+1 in p_i
                stab,       # p_i
                id,         # the list [1,...,1] describing the identity
                ino,        # list of images as vector
                img,        # list of images as elements of <p>
                lev,        # current level in the search tree
                checkImage,
                tmp,        # temporary
                j,  k;      # loop variables


    # first argument is a finitely presented group (the domain)
    f := arg[1];

    # second argument is a group (the range)
    p := arg[2];

    # third argument is a subgroup to be contained in the images of the maps
    if 3 = Length(arg)  then
        u := arg[3];
    else
        u := p;
    fi;

    # sort the relators of <f>
    sort := SortedRelators(f);

    # first of all compute the reps for the cojugacy classes of <p>
    rc := List( ConjugacyClasses(p), Representative );

    # check that the relators hold for <r>
    rc := Reversed( Filtered( rc, x -> CheckRelators(sort,[x],1) ) );

    # store all maps in <all>
    all := [];

    # compute a base for <p>
    base := Base(p);

    # <trv> will be a list of left transversals for p_i+1 in p_i
    trv := [];

    # compute all left transversals
    stab := p;
    for j  in [ 1 .. Length(base) ]  do
        tmp := Stabilizer( stab, base[j] );
        Add( trv, LeftTransversal( stab, tmp ) );
        stab := tmp;
    od;

    # <checkImgage> checks that the image conatins <u> and is "new"
    checkImage := function( cr, new, img )
        local   ngrp;

        # construct a group
        ngrp := Subgroup( Parent(p), img );

        # check that <u> is contained in <ngrp>
        if IsGroup(u) and not IsSubgroup( ngrp, u )  then
            return false;
        elif not IsGroup(u) and not IsTransitive( ngrp, u )  then
            return false;
        fi;

        # check that <img> is not conjugate to something in <new>
        if ForAny( new, 
            x -> RepresentativeOperation(cr,img,x,OnTuples) <> false )
        then
            return false;
        fi;

        # ok, this is new
        return true;
            
    end;

    # <id> corresponds to the identity
    id := List( [ 1 .. Length(base) ], x -> 1 );

    # loop over <rc> which are the possible images for the first generator
    for r  in rc  do

        # collect maps starting with <r> in <new>
        new := [];

        # compute the centralizer of <r> in <p>
        cr := Centralizer( p , r );

        # construct a new tuple of possible images
        ino := List( sort.generators, x -> Copy(id) );
        img := List( sort.generators, x -> () );
        img[1] := r;

        # start with the second generator and do a breadth first search
        lev := 2;
        while 1 < lev  do

            # the generators upto <lev> hold, go to the next level
            if lev < sort.finish and CheckRelators(sort,img,lev)  then
                lev := lev + 1;

            # either at the last level or the check failed
            else

                # at the last level,  check the relators
                if  CheckRelators(sort,img,lev)  then

                    # if <img> is not conjugate to an old one, use it
                    if checkImage( cr, new, img )  then
                        Add( new, ShallowCopy(img) );
                    fi;
                fi;

                # move to the next tuple
                j := Length(ino[lev]);
                while 1 < lev and 0 < j  do
                    if ino[lev][j] < Length(trv[j])  then
                        ino[lev][j] := ino[lev][j] + 1;
                        img[lev] := p.identity;
                        for k  in [ 1 .. Length(ino[lev]) ]  do
                            img[lev] := img[lev]*trv[k][ino[lev][k]];
                        od;
                        j := 0;
                    else
                        ino[lev][j] := 1;
                        j := j - 1;
                        if 0 = j  then
                            img[lev] := p.identity;
                            lev := lev - 1;
                            j := Length(ino[lev]);
                        fi;
                    fi;
                od;
            fi;
        od;

        # collect all maps in <all>
        Append( all, new );

    od;

    # convert image list into mapping
    for j  in [ 1 .. Length(all) ]  do
        all[j] := GroupHomomorphismByImages( f, p,
                      sort.generators, all[j] );
    od;
    return all;

end;
