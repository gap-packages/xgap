#############################################################################
##
#A  fpextra.g                 	XGAP library                     Frank Celler
#A                                                       & Susanne Keitemeier
#A                                                               & Sarah Rees
##
#H  @(#)$Id: fpextra.g,v 1.1 1997/11/27 12:19:47 frank Exp $
##
#Y  Copyright (C) 1993,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##
#H  $Log: fpextra.g,v $
#H  Revision 1.1  1997/11/27 12:19:47  frank
#H  added 3.5 library (does not work with 4.0)
#H
#H  Revision 1.1  1995/07/24  09:59:15  fceller
#H  Initial revision
#H
##
if not IsBound(InfoMatrix1)  then InfoMatrix1 := Ignore; fi;
if not IsBound(InfoMatrix2)  then InfoMatrix2 := Ignore; fi;
if not IsBound(InfoFpGroup1) then InfoFpGroup1 := Ignore; fi;
if not IsBound(InfoFpGroup2) then InfoFpGroup2 := Ignore; fi;  


#############################################################################
##
#F  IsSubgroupFpGroup( <H>, <I> ) . . . . . . . . . . . . . . . subgroup test
##
IsSubgroupFpGroup := function ( H, I )
    local   G,          # parent of <H> and <I>
            g,          # one generator of <G> (actually its index)
            nrgens,     # number of generators of <G>
            tableI,     # coset table of <I>
            tableH,     # coset table of <H>
            cosetH,     # 'cosetH[<cosI>]' is the coset of <H>
                        # which supposedly contains the coset <i> of <I>
            cosI,       # one coset of <I>
            cosH,       # the coset of <H> which supposedly contains <cosI>
            imgI,       # image of <cosI> under <g>
            imgH;       # image of <cosH> under <g>

    # easy tests first
    if not IsBound(H.parent)  then
        return true;
    fi;
    if not IsBound(I.parent) or H.parent = I.parent  then
        G := H.parent;
    fi;
    nrgens := Length( G.generators );
    if  1 = H.index  then
        return true;
    fi;
    if I.index mod H.index <> 0  then
        return false;
    fi;

    # get the coset tables
    if not IsBound( H.cosetTable )  then
        H.cosetTable := CosetTableFpGroup( G, H );
    fi;
    tableH := H.cosetTable;
    if not IsBound( I.cosetTable )  then
        I.cosetTable := CosetTableFpGroup( G, I );
    fi;
    tableI := I.cosetTable;
 
    
    # suppose that the coset 1 of <H> contains the coset 1 of <I>
    cosetH := [];
    cosetH[1] := 1;

    # loop over the cosets of <I>
    for cosI  in [1..Length(tableI[1])]  do
        cosH := cosetH[cosI];   # if this fails, <tableI> is not standardized

        # loop over the generators of <G>
        for g  in [1..nrgens]  do

            # compute the images of the cosets
            imgI := tableI[2*g-1][cosI];
            imgH := tableH[2*g-1][cosH];
      
            # if we haven't seen this coset yet,
            # then suppose that <imgI> is contained in <imgH>
            if not IsBound( cosetH[imgI] )  then
                cosetH[imgI] := imgH;

            # if <imgI> is contained in two different cosets of <H>,
            # then <I> is not a subgroup of <H>
            elif cosetH[imgI] <> imgH  then
                return false;
            fi;

        od;
    od;

    # everything tested ok
    return true;
end;



#############################################################################
##
#F  PseudoSubgroup ( <G> )  . . . . . . . . . . . . make a subgroup without a 
##  generating set, which isn't officially a group, but has all
## the right components, so it can easily become a subgroup later.
##
PseudoSubgroup := function ( G )
    local H;

    H := Subgroup(G,[]);
    Unbind(H.generators);
    Unbind(H.isGroup);
    Unbind(H.isFpGroup);
    Unbind(H.operations);
    return H;
end;


#############################################################################
##
#F  ExtraDiagonalizeMat( <mat> [, <M>] )  . . . . . diagonalize an integer m 
##
##  The function returns a list of two matrices [Rops,Cops] such that
##  Rops*mat*Cops is diagonal. Rops and Cops transform with row and
##  column operations respectively.
##
##  If a non-zero integers M is given as a second argument, the whole 
##  calculation is done mod M.  Thus Rops, and Cops have entries less than
##  M in absolute value, and the matrix Rops*mat*Cops is diagonal mod M.
##  In this case the size of entries is kept down, so there seems no
##  need to use row and column norms.
##
ExtraDiagonalizeMat := function ( arg )
    local   mat, M,     # the arguments
            i,          # current position
            k, l,       # row and column loop variables
            r, c,       # row and column index of minimal element
            e, f,       # entries of the matrix
            g,          # (extended) gcd of <e> and <f>
            v, w,       # rows of the matrix or row and column norms
            m,          # maximal entry, only for information
            isClearCol, #
            Cops, # the matrix of column ops.
            Rops; # the matrix of row ops.

    mat := arg[1];
    if Length(arg) = 2 then
        M := arg[2];
    else 
        M := 0;
    fi;

    InfoMatrix1("#I  ExtraDiagonalizeMat called\n");
    InfoMatrix1("#I ",mat,"\n");
    Cops := [];
    Rops := [];

    if mat <> [] then

        InfoMatrix2("#I    divisors: \c");
        m := 0;

        # initialise the matrix of column operations.
        for i in [1..Length(mat[1])] do
            Cops[i] := 0 * [1..Length(mat[1])];
            Cops[i][i] := 1;
        od;
        # initialise the matrix of row operations.
        for i in [1..Length(mat)] do
            Rops[i] := 0 * [1..Length(mat)];
            Rops[i][i] := 1;
        od;

        # loop over all rows respectively columns of the matrix
        for i  in [1..Minimum( Length(mat), Length(mat[1]) )]  do

            if M = 0 then
                # compute the row and column norms
                v := 0 * [1..Length(mat)];
                w := 0 * [1..Length(mat[1])];
                for k  in [i..Length(mat)]  do
                    for l  in [i..Length(mat[1])]  do
                        e := mat[k][l];
                        if   0 < e  then
                            v[k] := v[k] + e;
                            w[l] := w[l] + e;
                        else
                            v[k] := v[k] - e;
                            w[l] := w[l] - e;
                        fi;
                    od;
                od;

                # find the element with the smallest absolute value 
                # and best norm in the matrix
                f := 0;
                for k  in [i..Length(mat)]  do
                    for l  in [i..Length(mat[1])]  do
                        e := mat[k][l];
                        if 0 < e and 
                           (f=0 or  e<f or  e=f and v[k]*w[l]<g) 
                           then
                            f :=  e; 
                            r := k; 
                            c := l; 
                            g := v[k]*w[l];
                        elif e < 0 
                          and (f=0 or -e<f or -e=f and v[k]*w[l]<g) 
                          then
                            f := -e;  r := k;  c := l;  g := v[k]*w[l];
                        fi;
                        if   0 < e and m <  e  then
                            m :=  e;
                        elif e < 0 and m < -e  then
                            m := -e;
                        fi;
                    od;
                od;

            else
                # if the calculation is done mod M we don't bother with norms
                # but just find the element with the smallest absolute value 
                f := 0;
                for k  in [i..Length(mat)]  do
                    for l  in [i..Length(mat[1])]  do
                        e := mat[k][l];
                        if   0 < e and (f=0 or  e<f or  e=f ) then
                            f :=  e;  r := k;  c := l; 
                        elif e < 0 and (f=0 or -e<f or -e=f ) then
                            f := -e;  r := k;  c := l; 
                        fi;
                        if   0 < e and m <  e  then
                            m :=  e;
                        elif e < 0 and m < -e  then
                            m := -e;
                        fi;
                    od;
                od;
            fi;

            # if there is no nonzero entry we are done
            if f = 0  then
                InfoMatrix2("\n");
                InfoMatrix1("#I  ExtraDiagonalizeMat returns\n");
                return [Rops,Cops];
            fi;

            # move the minimal element to position 'mat[i][i]' make it positive
            if i <> r  then
                v := mat[i];  mat[i] := mat[r];  mat[r] := v;
                v := Rops[i];  Rops[i] := Rops[r];  Rops[r] := v;
            fi;
            if i <> c  then
                for k  in [i..Length(mat)]  do
                    e := mat[k][i];  
                    mat[k][i] := mat[k][c];  
                    mat[k][c] := e;
                od;
                for k  in [1..Length(mat[1])]  do
                    e := Cops[k][i];  
                    Cops[k][i] := Cops[k][c];  
                    Cops[k][c] := e;
                od;
            fi;
            if mat[i][i] < 0  then
                mat[i] := - mat[i];
                Rops[i] := - Rops[i];
            fi;

            # now clear the column i and the row i
            isClearCol := false;
            while not isClearCol  do

                # clear the column i using unimodular row operations such that
                # mat[i][i] becomes gcd(mat[i][i],mat[r][i]) and mat[r][i] = 0
                k := i + 1;
                while k <= Length(mat)  do
                    e := mat[i][i];  f := mat[k][i];
                    if f mod e = 0  then
                        mat[k] := mat[k] - f/e * mat[i];
                        Rops[k] := Rops[k] - f/e * Rops[i];
                    elif f <> 0  then
                        g := Gcdex( e, f );
                        v := mat[i];  w := mat[k];
                        mat[i] := g.coeff1 * v + g.coeff2 * w;
                        mat[k] := g.coeff3 * v + g.coeff4 * w;
                        v := Rops[i];  w := Rops[k];
                        Rops[i] := g.coeff1 * v + g.coeff2 * w;
                        Rops[k] := g.coeff3 * v + g.coeff4 * w;
                    fi;
                    k := k + 1;
                od;

                isClearCol := true;

                if M<>0 then # then reduce relevant rows of mat and Rops mod M
                    for k in [i..Length(mat)] do
                        Rops[k] := List(Rops[k],x -> x mod M); 
                        mat[k] := List(mat[k],x -> x mod M); 
                    od;
                fi;

                # clear the row i using unimodular column operations such that
                # mat[i][i] becomes gcd(mat[i][i],mat[i][c]) and mat[i][c] = 0
                # after such an operation we may have to clear column i  again
                l := i + 1;
                while l <= Length(mat[1])  and isClearCol  do
                    e := mat[i][i];  f := mat[i][l];
                    if f mod e = 0  then
                        g := f/e;
                        mat[i][l] := 0;
                        for k  in [1..Length(mat[1])]  do
                            Cops[k][l] := Cops[k][l] - g*Cops[k][i];
                        od;
                    elif f <> 0  then
                        g := Gcdex( e, f );
                        for k  in [i..Length(mat)]  do
                            v := mat[k][i];  w := mat[k][l];
                            mat[k][i] := g.coeff1 * v + g.coeff2 * w;
                            mat[k][l] := g.coeff3 * v + g.coeff4 * w;
                        od;
                        for k  in [1..Length(mat[1])]  do
                            v := Cops[k][i];  w := Cops[k][l];
                            Cops[k][i] := g.coeff1 * v + g.coeff2 * w;
                            Cops[k][l] := g.coeff3 * v + g.coeff4 * w;
                        od;
                        isClearCol := false;
                    fi;
                    l := l + 1;
                od;
                if M<>0 then # then reduce relevant rows of mat and Cops mod M
                    for k in [i..Length(mat)] do
                        mat[k] := List(mat[k],x -> x mod M); 
                    od;
                    for k in [1..Length(mat[1])] do
                        Cops[k] := List(Cops[k],x -> x mod M); 
                    od;
                fi;

            od;

            InfoMatrix2(mat[i][i]," \c");
        od;

        InfoMatrix2("\n");
        InfoMatrix2("#I  maximal entry ",m,"\n");
    fi;

    InfoMatrix1("#I  ExtraDiagonalizeMat returns\n");
    return [Rops,Cops];
end;


#############################################################################
##
#F  ExtraElementaryDivisorsMat( <mat> [,<M> ])  . .elementary divisors of an 
##  integer matrix
##
##  ExtraElementaryDivisorsMat returns a list of 3 elements. The first is the  
##  list of the elementary divisors, i.e., the
##  unique <d> with '<d>[<i>]' divides '<d>[<i>+1]' and <mat>  is  equivalent
##  to a diagonal matrix with the elements '<d>[<i>]' on the diagonal.
##  The second and third elements of the list are the 2 matrices Rops,Cops
##  which transform mat into the diagonal matrix of elementary divisors, 
##  using row and column operations respectively.  
##  Thus Rops*mat*Cops is diagonal.
##
##  If a second non-zero argument M is given, the whole calculation is
##  done mod M, i.e. the final matrix is only diagonal mod M. 
##
ExtraElementaryDivisorsMat := function ( arg )
    local  mat,                 # the matrix
           M,                   # matrix with row/columns operations
           m, n,                # number of rows / columns  
           RCops, Rops, Cops,   # row / column operations
           divs,                # diagonal elements
           g,                   # Gcdex of two diagonal elements
           i, j, k,             # loop variables 
           temp;                # 

    mat := arg[1];
    if Length(arg) = 2 then
        M := arg[2];
    else
        M := 0;
    fi;
    # make a copy to avoid changing the original argument
    if mat=[] then return [[],[],[]]; fi;
    mat := Copy( mat );
    m := Length(mat);  
    n := Length(mat[1]);

    # diagonalize the matrix
    if M <> 0 then
        RCops := ExtraDiagonalizeMat( mat,M );
    else
        RCops := ExtraDiagonalizeMat( mat );
    fi;
    Rops := RCops[1]; 
    Cops := RCops[2];

    # get the diagonal elements
    divs := [];
    for i  in [1..Minimum(m,n)]  do
        divs[i] := mat[i][i];
    od;

    # transform the divisors so that every divisor divides the next
    for i  in [1..Length(divs)-1]  do
        for k  in [i+1..Length(divs)]  do
            if divs[i] <> 0  and divs[k] mod divs[i] <> 0  then
                g := Gcdex(divs[i],divs[k]);
                Rops[k] := Rops[k] + g.coeff1 * Rops[i];
                for j in [1..n] do
                    Cops[j][i] := Cops[j][i] + g.coeff2 * Cops[j][k];
                od;
                temp := Rops[i]; Rops[i] := Rops[k]; Rops[k] := temp;
                Rops[k] := Rops[k] - divs[i] / g.gcd * Rops[i];
                for j in [1..n] do
                    Cops[j][k] := Cops[j][k] - divs[k] / g.gcd * Cops[j][i];
                od;
                Rops[k] := - Rops[k];
                divs[k] := divs[k] / g.gcd * divs[i];
                divs[i] := g.gcd;
            fi;
        od;
    od;

    if M <> 0 then
        for k in [1..Length(mat[1])] do
            Cops[k] := List(Cops[k],x -> x mod M); 
        od;
        for k in [1..Length(mat)] do
            Rops[k] := List(Rops[k],x -> x mod M); 
        od;
    fi;
    return [divs,Rops,Cops];
end;


#############################################################################
##
#F  DerivedQuotInvariantsFpGroup(<G>[,<exp>]). compute the abelian invariant 
##  the derived quotient of a  fin. pres. group, together with the
##  list of images of the generators of G.
##
##  The output consists of a pair of lists. The first list is the sequence
##  [d_1,d_2,...d_r] of elementary divisors <> 1, so that d_1 | d_ 2 etc.
##  The second list consists of the images of each of the generators of
##  G in the abelian group, expressed as a vector 
##  of length r, containing
##  the coordinates of the image in the abelian group represented as
##  a direct product of cyclic groups of orders d_1,d_2,...d_r.
##
DerivedQuotInvariantsFpGroup := function ( arg )
    local   G, exp,     # group, exponent
            abl,        # abelian invariants of <G>, result
            images,     # images of generators of <G> in ab. group, result
            mat,        # relation matrix of <G>
            row,        # one row of <mat>
            rel,        # one relation of <G>
            g,          # one letter of <rel>
            p,          # position of <g> or its inverse in '<G>.generators'
            i,j,        # loop variable
            eed,        # result of call to ExtraElementaryDivisorsMat
            divs,       # elementary divisors
            tail,       
            Cops,       # matrix of column operations
            triv,       # the number of trivial cyclic components
            # of the ab. gp.
            n, k, row;

    G := arg[1];
    if Length(arg) = 2 then
        exp := arg[2];
    else 
        exp := 0;
    fi;

    # we can handle only groups with relators
    if not IsParent( G )  then
        G := FpGroup( G );
    fi;

    # make the relation matrix
    mat := [];
    n := Length(G.generators);
    for rel  in G.relators  do
        row := [];
        for i  in [ 1 .. n ]  do
            row[i] := 0;
        od;
        for i  in [ 1 .. LengthWord( rel ) ]  do
            g := Subword( rel, i, i );
            p := Position( G.generators, g );
            if p <> false  then
                row[ p ] := row[ p ] + 1;
            else
                p := Position( G.generators, g^-1 );
                row[ p ] := row[ p ] - 1;
            fi;
        od;
        if exp<>0  then
            row := List(row,x->x mod exp); 
        fi;
        Add( mat, row );
    od;


    # diagonalize the matrix
    if mat<> [] then
        if exp<>0 then
            eed := ExtraElementaryDivisorsMat( mat,exp );
        else
            eed := ExtraElementaryDivisorsMat( mat );
        fi;
        divs := eed[1];
        Cops := eed[3];
    else
        divs := [];
        Cops := [];

        for i in [1..n] do
            Cops[i] := 0*[1..n];
            Cops[i][i] := 1;
        od;
    fi; 

    if exp <> 0 then
        divs := List(divs,x->Gcd(x,exp));
    fi;

    # now add 0's onto the list of divisors until it has length n.
    tail := 0*[Length(divs)+1..n];
    if exp<>0 then  tail := List(tail,x->exp); fi;
    divs := Concatenation(divs,tail);

    # and return the abelian invariants
    abl := [];
    for i  in divs  do
        if i <> 1  then
            Add( abl, i );
        fi;
    od;

    triv := Length(divs) -  Length(abl);
    images := [];
    for i in [1..n] do
        row := Sublist(Cops[i],[triv+1..n]);
        for j in [1..Length(abl)] do
            if abl[j]<>0 then row[j] :=  row[j] mod abl[j]; fi;
        od;
        images[i] := row;
    od;
    return [abl,images];
end;


#############################################################################
##
#F  ModuloAdditionVectors( <vec1> , <vec2> , <orders> )  . . . . . . . . . . 
##
##  Form the sum of the vectors vec1 and vec2, and reduce each component
## of the sum by the integer in the corresponding position of the list orders,
## that is, add the two vectors as elements of the direct product of the
## finite abelian group which is a direct product of cyclic groups of
## orders as in the list.
##
ModuloAdditionVectors := function ( vec1, vec2, orders )
    local vec, i, n;

    n := Length(orders);

    vec := [];
    for i in [1..n] do
        vec[i] := (vec1[i] + vec2[i] ) mod orders[i] ;
    od;

    return vec;
end;


#############################################################################
##
#F  VectorToInt( <vec> , <orders> )  . . . . . . . . . . . . . . . . . . . . 
##
## Given a vector (v_1,v_2,...v_n) of non-negative integers,
## and a list (d_1,d_2,...,d_n) of integers, 
## compute and return the integer
## 1 + v_1 + d_1 * v_2 + d_1 * d_2 *v_3 + ....
##
VectorToInt := function ( vec, orders )
    local i,n, x;

    n := Length(vec);
    x := 0;
    i := n;
    while i > 1 do
        x := orders[i-1] * (x + vec[i]);
        i := i-1;
    od;
    x := x + vec[1] + 1;
    return x;
end;


#############################################################################
##
#F  NextVector( <vec> , <orders> )  . . . . . . . . . . . . . . . . . . . .  
##
## Given a vector (v_1,v_2,...v_n) of non-negative integers,
## and a list (d_1,d_2,...,d_n) of positive integers,
## where v_i < d_i, for all i,
## replace vec by the "next" vector in the list, i.e. increment the
## first entry v_i less than d_i-1 by 1, and set all previous v_i to
## zero. Set vec to the zero vector if there is no next one.
##
##
NextVector := function ( vec, orders )

    local posn,n;

    n := Length(vec);

    posn := 1;
    while posn <=n and vec[posn] = orders[posn] - 1 do
        vec[posn] := 0;
        posn := posn + 1;
    od;
    if posn > n then 
        return;
    fi;
    vec[posn] := vec[posn] + 1;
    return;
end;


#############################################################################
##
#F  RegularActionAbelianGroup( <orders> , <list> )  . . . . . . . .  compute 
## list of permutations corresponding to the regular action of elements 
## of a list of elements of an abelian group on the group.
## Ths list is output as a set of vectors, since this seems more convenient
## for application.
## The group is written as a direct product of (finite)
## cyclic groups of orders d_1,d_2,..d_r, d_1<>1,
## and the list of these d_i is given as the first argument.
## The elements which act are given by their coordinates with respect
## to this direct product, in the list which is the second argument.
##
##
RegularActionAbelianGroup := function ( orders, list)

    local r,n,  
          gaction, vec, imvec,
          g,i,j,k,degree, 
          action;

    r := Length(orders);
    n := Length(list);
    degree := 1;

    for i in [1..r] do
        degree := degree * orders[i];
    od;

    action := [];

    vec := 0*[1..r];
    for i in [1..n] do
        g := list[i];
        gaction := [];
        k:= 1;
        repeat
            imvec :=  ModuloAdditionVectors(vec,g,orders);
            gaction[k] := VectorToInt(imvec,orders);
            k := k+1;
            NextVector(vec,orders);
        until k > degree;
        Add(action,gaction);
    od;

    return action;
end;


#############################################################################
##
#F  CosetTableAction( <H> ) . . . . . . . . . . . . . compute the coset table
##
##  'CosetTableAction' converts   the action given  for the  vertex <H>  to a
##  coset table action relatively to <H.parent>, and returns the coset table.
##  In fact <H.group> doesn't have to  be formally a group  in the gap sense,
##  since it  might  have  no generators.  But   it  has to  have fields  for
##  <H.group.parent>,  <H.action>,   and  whatever  components  go with   the
##  particular action specified by the <H.action> flag.
##
CosetTableAction := function( H )
    local   table,  G,  m,  act,  i,  Q,  epi,  elts,  n,  vec,  
            genim,  j,  elt,  P,  PG,  Preg,  gen,  involutions,  rel,  
            length,  base,  word;


    # if know a coset table, return
    if H.action = "cosetTable" or H.action = "cosetTableSubgroup"  then 
        return H.group.cosetTable;

    # we have to work harder
    else

        # <table> will hold the coset table relative to <G>
        table := [];
        G := H.group.parent;
        m := Length(G.generators);

        # action from 'DerivedSubgroup'
        if H.action = "abelianQuotient"  then
            act := RegularActionAbelianGroup( H.group.invariantsQuotient,
                                              H.group.imGensParent );
            for i  in [ 1 .. m ]  do
                table[2*i-1] := act[i];
            od;

        # action from 'PrimeQuotient'
        elif H.action = "pq"  then
            Q   := H.group.ag;

            # replace definition by generators in epimorphism
            epi := H.group.pqEpimorphism;
            for i in [1..m] do
                if IsInt(epi[i]) then
                    epi[i] := H.group.pqGenerators[epi[i]];
                fi;
            od;

            # compute the regular action of <Q> in words of <H>
            elts := Elements(Q);
            n    := Length(elts);
            for i  in [ 1 .. m ]  do
                vec := [];
                genim:=MappedWord(epi[i],H.group.pqGenerators,Q.generators);
                for j  in [ 1 .. n ]  do
                    elt := elts[j];
                    vec[j] := Position(elts,elt*genim);
                od;
                table[2*i-1] := vec;
            od;

        # action from a intersection of normal subgroups
        elif H.action = "intransitive" then
            P  := H.group.perms;
            PG := Group(P,());

            # compute the regular action of <PG>
            Preg := [];
            for gen in P  do
                Add( Preg, Permutation( gen, Elements(PG), OnRight ) ); 
            od;
            n := Size(PG);
            for i  in [ 1 .. m ]  do
                gen := Preg[i];
                table[2*i-1] := List( [ 1 .. n ], x -> x^gen );  
            od;

        # oops, I don't know this action
        else
            Error( "Sorry cannot deal with ",H.action," actions." );
        fi;

        # It's  necessary to  identity  the involutions of   G, otherwise the
        # coset  table  won't be legal,   since the rows corresponding  to an
        # involutory  generator  and its inverse  must  be identical, and not
        # merely equal.  The   code  to identify involutions is   copied from
        # "fpgrp.g".
        involutions := [];

        # now loop over all parent group relators.
        for rel in RelatorRepresentatives( G.relators ) do

            # get the length and the basic length of relator rel.
            length := LengthWord( rel );
            base := 1;
            word := rel ^ Subword( rel, 1, 1 );
            while word <> rel do
                base := base + 1;
                word := word ^ Subword( word, 1, 1 );
            od;

            if length = 2 and base = 1 then
                gen := Subword( rel, 1, 1 );
                Add(involutions,gen);
            fi;
        od;

        # build a correct coset table
        for i  in [ 1 .. m ]  do
            if G.generators[i] in involutions  then
                table[2*i] := table[2*i-1];
            else 
                table[2*i] := [];
                vec := table[2*i-1];
                for j  in [ 1 .. Length(vec) ]  do
                    table[2*i][vec[j]] := j;
                od;
            fi;
        od;

        # always compute a standardized table
        StandardizeTable(table);
        return table;
    fi;

end; 


#############################################################################
##
#F  WreathProductActions( <H>, <K> )  . . . . . . . . . . . . combine actions
##
##  'WreathProductActions'  combines the  actions of <H.group.parent>  on the
##  cosets of <H.group> and  <H.group> on the cosets of  <K.group> to  give a
##  single action for <H.group.parent> on the cosets on <K.group>.
##
##  The two actions which are  combined might not actually  be given as coset
##  tables, and I  foresee that this combined  action might not in general be
##  either, although at  the moment it is.   <H.group> represents a  subgroup
##  and  <K.group.parent> must be <H.group>,  but  they might not be strictly
##  groups   in  the gap   sense.    Each is  a   record   with   fields  for
##  '.group.parent",  '.action'  and whatever  should   be defined  for  that
##  particular value of action.
##
WreathProductActions := function( H, K )
    local   HH,  L;

    # if <H.group> is the whole group, construct the table for <K>
    if  H.index = 1 then

        # if it is a coset table action return <K>
        if K.action = "cosetTable"  then
            return K;

        # if it is a coset table subgroup action, check preliminaries
        elif K.action = "cosetTableSubgroup"  then
            Error( "this must a coset table action" );

        # compute the table using 'CosetTableAction'
        else
            HH := rec();
            HH.action := "cosetTable";
            HH.group  := PseudoSubgroup(K.group.parent);
            HH.group.cosetTable := CosetTableAction(K);
            return HH;
        fi;
    fi;

    # we know a coset table of <H.group> in <H.group.parent>
    if H.action = "cosetTable" or H.action = "cosetTableSubgroup"  then
        HH := H.group;

    # compute such a table
    else
        HH := PseudoSubgroup(H.group.parent);
        HH.cosetTable := CosetTableAction(H);
    fi;

    # construct a new action
    L := rec();
    L.action := "cosetTable";
    L.group  := PseudoSubgroup(H.group.parent);
    L.group.cosetTable := WreathProductCosetTables(HH,CosetTableAction(K));

    # and return
    return L;

end;


#############################################################################
##
#F  AddSchreierGens( <G> ) . . . . . . . . . . . . . . . . . . . . . . . . . 
##
AddSchreierGens := function ( G )
    local   aug,  i;

    aug := AugmentedCosetTableRrs(G.parent,G.cosetTable,2,"_x");
    if IsBound(G.generators) then
        for i in [1..Length(G.generators)] do
            Unbind(G.(i));
        od;
        Unbind(G.generators);
    fi;
    G.generators := aug.primaryGeneratorWords;
    for i in [1..Length(G.generators)] do
        G.(i) := G.generators[i];
    od;
    G.cosetFactorTable := aug.cosetFactorTable;
    G.tree := aug.tree;
    if not IsBound(G.isGroup) then
        G.isGroup := true; 
    fi;
    if not IsBound(G.isFpGroup) then 
        G.isFpGroup := true; 
    fi;
    if not IsBound(G.operations) then 
        G.operations := G.parent.operations;
    fi;
end;


#############################################################################
##
#F  DerivedSubgroupFpGroup( <G> [,<exp>] )  .  . . . . . . . . . . . . . . . 
##
##  First the abelian invariants of the derived quotient mod exp are computed.
## If they are all non-zero, the derived subgroup is also computed
## as a record with the following fields:
## .parent, set to G,
## .invariantsQuotient which contains the abelian invariants of the
## quotient
## .imGensParent which contains a list of vectors which
## define the images of the generators of the
## G, .index set to the index of H in G,
## and .action set to "abelianQuotient"
## The function returns either the above record, or the
## list of abelian invariants (which then contains a zero entry).
##
DerivedSubgroupFpGroup := function ( arg )

    local G, exp,
          dqi, abinv,  involutions,
          length, rel, base, word, gen,
          degree, 
          table, action,
          m,n,
          i,j,
          schreier,
          H;

    G := arg[1];

    if Length(arg)=2 then
        exp := arg[2];
    else
        exp := 0;
    fi;

    if (exp<>0) then
        dqi := DerivedQuotInvariantsFpGroup(G,exp); 
    else
        dqi := DerivedQuotInvariantsFpGroup(G); 
    fi;
    abinv := dqi[1];
    degree := 1;
    for i in [1..Length(abinv)] do
        degree := degree * abinv[i];
    od;
    if degree = 1 then
        G.index := 1;
        return G;
    fi; 
    H := PseudoSubgroup(G);
    H.imGensParent := dqi[2];
    H.invariantsQuotient := abinv;
    H.index := degree; 
    return H;
end;


#############################################################################
##
#F  WreathProductCosetTables( H,HKtable )  . . . . . makes a coset table for 
##
##  action of G on cosets of K. H is a subgroup of G, and has as fields
## the coset table for the action of G on the its cosets, Schreier generators
## in its list of generators, and an array schreierTable which identifies
## the positions of the Schreier generators in that list.
## K is a subgroup of H, (or maybe of a group HH isomorphic to H, with a 
## generating set which corresponds to the generating set for H,
## and has a coset table for the action of H  (or HH) on its
## cosets. The function returns the coset table.
## Because of the fact that K may not actually be a subgroup of H in
## the sense of gap, this function cannot check that the input is sensible.
## So it doesn't.
##
WreathProductCosetTables := function ( H,HKtable )
    local GHtable, GKtable, # the coset tables
          cosetFactorTable, tree, # the info about Schreier generators for H
          GKindex, GHindex, HKindex, # the indices
          Ggens, # number of generators for G, the parent of H.
          Hgens, # number of generators for H.
          i,j,k, r,s,
          w, jw, g, cos, ImageUnderSchreierGen;

    GHtable := H.cosetTable;
    GHindex := Length(GHtable[1]);
    HKindex := Length(HKtable[1]);
    GKindex := GHindex * HKindex;

    Ggens := QuoInt(Length(GHtable),2);
    if not IsBound(H.cosetFactorTable) then
        AddSchreierGens(H);
    fi;
    cosetFactorTable := H.cosetFactorTable;
    tree := H.tree;
    Hgens := Length(H.generators);
    ImageUnderSchreierGen := function(jj,ww)
        local w1, w2, neg;
        if ww = 0 then 
            return jj;
        elif ww < 0 then
            neg := true; ww := -ww;
        else
            neg := false;
        fi;
        if ww <= Hgens then 
            if neg then
                return HKtable[2*ww][jj]; 
            else 
                if not IsBound(HKtable[2*ww - 1][jj]) then
                    return false;
                else
                    return HKtable[2*ww - 1][jj];
                fi;
            fi;
        else 
            if neg then
                w1 := -tree[2][ww]; w2 := -tree[1][ww];
            else
                w1 := tree[1][ww]; w2 := tree[2][ww];
            fi;
            return ImageUnderSchreierGen(ImageUnderSchreierGen(jj,w1),w2);
        fi;
    end; 

    GKtable := [];
    for i in [1..Ggens] do
        r := 2*i - 1; s := 2*i;
        GKtable[r] := [];
        for j in [1..HKindex] do
            for k in [1..GHindex] do
                cos := j + HKindex *(k-1);
                w := cosetFactorTable[r][k];
                jw := ImageUnderSchreierGen(j,w);
                GKtable[r][cos] := jw + HKindex * (GHtable[r][k] -1);
            od;
        od; 
        if IsIdentical(GHtable[r],GHtable[s]) then 
            GKtable[s] := GKtable[r];
        else 
            GKtable[s] := [];
            for j in [1..GKindex] do
                GKtable[s][GKtable[r][j]] := j;
            od;
        fi;
    od;

    StandardizeTable(GKtable);

    return GKtable;
end;



#############################################################################
##
#F  ExtraPresentationAugmentedCosetTable( <aug>  [,<print level>] ) . . . .  
## . create a 
##                                                              Tietze record 
## 
##  'ExtraPresentationAugmentedCosetTable'  creates a presentation, 
##  i.e. a Tietze
##  record, from the given augmented coset table.
##
##  This differs from PresentationAugmentedCosetTable in that it 
##  doesn't call TzHandleLength1Or2Relations or TzSort,
##  i.e. it doesn't do any Tietze transformations on the presentation. 
##
ExtraPresentationAugmentedCosetTable := function ( arg )

    local aug, coFacTable, comps, convert, gens, i, invs, lengths, numgens,
          numrels, pointers, printlevel, rel, rels, T, tietze, total, tree,
          treelength, treeNums;

    # check the first argument to be an augmented coset table.
    aug := arg[1];
    if not ( IsRec( aug ) and IsBound( aug.isAugmentedCosetTable ) and
             aug.isAugmentedCosetTable ) then
        Error( "first argument must be an augmented coset table" );
    fi;

    # check the second argument to be an integer.
    printlevel := 1;
    if Length( arg ) = 2 then  printlevel := arg[2];  fi;
    if not IsInt( printlevel ) then
        Error (" second argument must be an integer" );
    fi;

    # initialize some local variables.
    rels := Copy( aug.subgroupRelators );
    gens := Copy( aug.subgroupGenerators );
    coFacTable := aug.cosetFactorTable;
    tree := ShallowCopy( aug.tree );
    treeNums := Copy( aug.treeNumbers );
    treelength := Length( tree[1] );

    # create the Tietze record.
    T := rec( );
    T.isTietze := true;
    T.operations := PresentationOps;

    # construct the relator lengths list.
    numrels := Length( rels );
    lengths := 0 * [ 1 .. numrels ];
    total := 0;
    for i in [ 1 .. numrels ] do
        lengths[i] := Length( rels[i] );
        total := total + lengths[i];
    od;

    # initialize the Tietze stack.
    tietze := 0 * [ 1 .. TZ_LENGTHTIETZE ];
    tietze[TZ_NUMRELS] := numrels;
    tietze[TZ_RELATORS] := rels;
    tietze[TZ_LENGTHS] := lengths;
    tietze[TZ_FLAGS] := 1 + 0 * [ 1 .. numrels ];
    tietze[TZ_TOTAL] := total;

    # renumber the generators in the relators, if necessary.
    numgens := Length( gens );
    if numgens < treelength then
        convert := 0 * [ 1 .. treelength ];
        for i in [ 1 .. numgens ] do
            convert[treeNums[i]] := i;
        od;
        for rel in rels do
            for i in [ 1 .. Length( rel ) ] do
                if rel[i] > 0 then
                    rel[i] := convert[rel[i]];
                else
                    rel[i] := - convert[-rel[i]];
                fi;
            od;
        od;
    fi;

    # construct the generators and the inverses list, and save the generators
    # as components of the Tietze record.
    invs := 0 * [ 1 .. 2 * numgens + 1 ];
    comps := 0 * [ 1 .. numgens ];
    pointers := [ 1 .. treelength ];
    for i in [ 1 .. numgens ] do
        invs[numgens+1-i] := i;
        invs[numgens+1+i] := - i;
        T.(String( i )) := gens[i];
        comps[i] := i;
        pointers[treeNums[i]] := treelength + i;
    od;

    # define the remaining Tietze stack entries.
    tietze[TZ_NUMGENS] := numgens;
    tietze[TZ_GENERATORS] := gens;
    tietze[TZ_INVERSES] := invs;
    tietze[TZ_NUMREDUNDS] := 0;
    tietze[TZ_STATUS] := [ 0, 0, -1 ];
    tietze[TZ_MODIFIED] := false;

    # define some Tietze record components.
    T.generators := tietze[TZ_GENERATORS];
    T.tietze := tietze;
    T.components := comps;
    T.nextFree := numgens + 1;
    T.identity := IdWord;

    # initialize the Tietze options by their default values.
    T.eliminationsLimit := 100;
    T.expandLimit := 150;
    T.generatorsLimit := 0;
    T.lengthLimit := "infinity";
    T.loopLimit := "infinity";
    T.printLevel := 0;
    T.saveLimit := 10;
    T.searchSimultaneous := 20;

    # save the tree as component of the Tietze record.
    tree[TR_TREENUMS] := treeNums;
    tree[TR_TREEPOINTERS] := pointers;
    tree[TR_TREELAST] := treelength;
    T.tree := tree;

    T.printLevel := printlevel;

    # return the Tietze record.
    return T;
end;


#############################################################################
##
#F  PresentationSubgroupGivenGens(<G>, <H> [,<string>] [,<print level>] ) .  
##
##  'PresentationSubgroupGivenGens' uses the Modified Todd-Coxeter 
##  coset representative enumeration method  to compute a presentation 
##  (i.e. a presentation record) for a subgroup H of a finitely presented 
##  group G, where the generators of H have been calculated from its coset
##  table using the ReducedReidemeisterSchreier method 
##  (as in GeneratorsCosetTable() )
##  The generators
##  in the resulting presentation will be named   <string>1, <string>2, ... ,
##  the default string is "_x".  The default print level is  1. 
##  The presentation is computed using code copied from 
##  PresentationSubgroupMtc, where the set of generators is extended to
##  a larger set.
##  The only Tietze transformation applied in this function is the
##  function TzEliminateGen, which is used simply to eliminate the
##  introduced generators from the presentation.
##  If the print
##  level is set to 0,  then the printout of the 'DecodeTree' command will be
##  suppressed.
##
## 
PresentationSubgroupGivenGens := function ( arg )

    local aug, G, H, i, printlevel, string, T, type, index;

    # check the first two arguments to be a finitely presented group and a
    # subgroup of that group.
    G := arg[1];
    if not ( IsRec( G ) and IsBound( G.isFpGroup ) and G.isFpGroup ) then
        Error( "<group> must be a finitely presented group" );
    fi;
    H := arg[2];
    if not ( IsRec( H ) and IsBound( H.isFpGroup ) and H.isFpGroup ) then
        Error( "<subgroup> must be a finitely presented group" );
    fi;
    if IsBound( H.parent ) and H.parent <> G or ( not IsBound( H.parent ) )
       and H <> G 
       then
        Error( "<group> must be the parent of <subgroup>" );
    fi;

    # initialize generator name string and the print level.
    string := "_x";
    printlevel := 1;

    # get the optional parameters.
    for i in [ 3 .. 4 ] do
        if Length( arg ) >= i then 
            if IsInt( arg[i] ) then 
                printlevel := arg[i];
            elif IsString( arg[i] ) then 
                string := arg[i];
            else
                Error( "optional parameter must be a string or an integer" );
            fi;
        fi;
    od;

    # do a Modified Todd-Coxeter coset representative enumeration to
    # construct an augmented coset table of H.

    type := 2;
 
    index := 0;
    if IsBound(H.index) then
        index := H.index;
        Unbind(H.index);
    fi;
    
    aug := AugmentedCosetTableMtc( G, H, type, string );
    
    if index <> 0 then
        H.index := index;
    fi;
    
    RewriteSubgroupRelators( aug );

    # create a Tietze record for the resulting presentation.
    T := ExtraPresentationAugmentedCosetTable( aug );
    if printlevel >= 1 then  
        TzPrintStatus( T, true ); 
    fi;

    for i in [Length(H.generators) + 1..Length(T.generators)] do
        TzEliminateGen(T,i);
    od;
    T.printLevel := 1;

    if type = 1 then
        if aug.exponent > 0 then
            Print( "size = ", aug.exponent * H.index, "\n" );
        else 
            Print( "size = infinite\n" ); 
        fi;
    fi;

    return T;
end;


#############################################################################
##
#F  PresentationCosetTable( <G> ). . . . . . . . . . . . . . . . . . . . . . 
##
PresentationCosetTable := function ( G )

    if not IsBound(G.cosetFactorTable) then
        AddSchreierGens(G);
    fi;
    return PresentationSubgroupGivenGens(G.parent,G);

end;


#############################################################################
##
#F  PresentationAction( <ver> )  . . .  compute a presentation for the vertex
##
PresentationAction := function ( ver )
    local   GG;

    # if we know a presentation, do nothing
    if not IsBound(ver.fpgroup)  then

        # if we know a coset table, compute the presentation
        if ver.action="cosetTable" or ver.action="cosetTableSubgroup"  then
            ver.fpgroup := PresentationCosetTable(ver.group);

        # otherwise compute the table first
        else
            GG            := PseudoSubgroup(ver.group.parent);
            GG.cosetTable := CosetTableAction(ver);
            ver.fpgroup   := PresentationCosetTable(GG);
        fi;
    fi;
    return ver.fpgroup;

end;


#############################################################################
##
#F  CosetTableIntersection(<tableG>,<tableH>)  . . . . . coset table for the 
## 
## intersection of two fin. pres. groups. Two tables tableG and tableH are 
## given as input, which are the coset tables for the action of a finitely
## presented group X on two subgroups G and H. The table for the action
## of X on the intersection of G and H is output.
##
##  
CosetTableIntersection := function ( tableG, tableH )
    local   table,      # coset table for intersection of G and H in X.
            nrcos,      # number of cosets of intersection in X.
            nrcosG,     # number of cosets of <G>
            nrcosH,     # number of cosets of <H>
            nrgens,     # number of generators of <X>
            ren,        # if 'ren[<i>]' is 'nrcosH * <iG> + <iH>' then the
            # coset <i> of <I> corresponds to the intersection
            # of the pair of cosets <iG> of <G> and <iH> of <H>
            ner,        # the inverse mapping of 'ren'
            cos,        # coset loop variable
            gen,        # generator loop variable
            img;        # image of <cos> under <gen>

    nrcosG := Length( tableG[1] ) + 1;
    nrcosH := Length( tableH[1] ) + 1;

    # initialize the table for the intersection
    nrgens := QuoInt(Length(tableG),2);
    table := [];
    for gen  in [ 1 .. nrgens ]  do
        table[ 2*gen-1 ] := [];
        if IsIdentical(tableG[2*gen-1],tableG[2*gen]) then
            table[ 2*gen ] := table[ 2*gen-1 ];
        else
            table[ 2*gen ] := [];
        fi;
    od;
    # set up the renumbering
    ren := 0 * [ 1 .. nrcosG * nrcosH ];
    ner := 0 * [ 1 .. nrcosG * nrcosH ];
    ren[ 1*nrcosH + 1 ] := 1;
    ner[ 1 ] := 1*nrcosH + 1;
    nrcos := 1;

    # the coset table for the intersection is the transitive component of 1
    # in the *tensored* permutation representation
    cos := 1;
    while cos <= nrcos  do

        # loop over all entries in this row
        for gen  in [ 1 .. nrgens ]  do

            # get the coset pair
            img := nrcosH * tableG[ 2*gen-1 ][ QuoInt( ner[ cos ], nrcosH ) ]
                   + tableH[ 2*gen-1 ][ ner[ cos ] mod nrcosH ];

            # if this pair is new give it the next available coset number
            if ren[ img ] = 0  then
                nrcos := nrcos + 1;
                ren[ img ] := nrcos;
                ner[ nrcos ] := img;
            fi;

            # and enter it into the coset table
            table[ 2*gen-1 ][ cos ] := ren[ img ];
            table[ 2*gen   ][ ren[ img ] ] := cos;
        od;

        cos := cos + 1;
    od;

    # and return it
    return table;
end;


#############################################################################
##
#F  IntersectionNormalSubgroups( H,K)  . . . . . . . . . . . . . . . . . . . 
##
##  H,K are normal subgroups of a group G.
##  This function returns the normal subgroup action which
##  is the intersection of H and K, equipped with a map onto
##  an intransitive permutation group.
##  
##
IntersectionNormalSubgroups := function ( vh, vk )
    local P1, P2, L, table, perms, translate, m, n1, n2, i ;

    if vh.action = "intransitive" then
        P1 := vh.group.perms;
        m  := Length(P1);
        n1 := Maximum(List(P1,function(i)
            if i=() then
                return 0;
            else
                return LargestMovedPointPerm(i);
            fi;
        end));
    else 
        table := CosetTableAction(vh);
        m := QuoInt(Length(table),2);
        n1 := Length(table[1]);
        P1 := [];
        for i in [1..m] do
            Add(P1,PermList(table[2*i-1]));
        od;
    fi;

    if vk.action = "intransitive" then
        P2 := vk.group.perms;
        n2 := Maximum(List(P2,function(i)
            if i=() then
                return 0;
            else
                return LargestMovedPointPerm(i);
            fi;
        end));
    else 
        table := CosetTableAction(vk);
        n2 := Length(table[1]);
        P2 := [];
        for i in [1..m] do
            Add(P2,PermList(table[2*i-1]));
        od;
    fi;

    translate:=PermList(Concatenation([n1+1..n1+n2],[1..n1]));
    perms := [];
    for i in [1..m] do
        perms[i]:=P1[i]*P2[i]^translate;
    od;

    L := PseudoSubgroup(vh.group.parent);
    L.perms := perms;
    L.index := Size(Group(perms,()));
    return L;
end;


#############################################################################
##
#F  BlocksCosetTable( G, list, Htable )  . . . . . . . . . . . . . . . . . . 
##
##  H  is a subgroup of a group G, which has a coset table, list is
##  a list of elements of G, and then N is the smallest
##  subgroup of G which contains H and the elements of list. 
##  This function returns the coset table for the action of G on the
##  cosets of G on N, whose columns are found as blocks 
##  of columns of the table for H
##
BlocksCosetTable := function ( G, list, Htable )

    local Ntable,
          P, 
          perms, perm,
          block, blocks, reps,
          Ggens, Pgens, x,g, i,j,r,s;

    Ggens := G.generators;
    Pgens := [];
    for i in [1..Length(Ggens)] do
        Add(Pgens,PermList(Htable[2*i-1]));
    od;
    P := Group(Pgens,());

    perms := [];
    for x in list do
        perm := ();
        for i in [1..LengthWord(x)] do
            j := Position(Ggens,Subword(x,i,i));
            if j=false then
                perm := perm * (Pgens[Position(Ggens,Subword(x,i,i)^-1)])^-1;
            else
                perm := perm * Pgens[j];
            fi;
        od;
        Add(perms,perm);
    od;

    block := Set(Orbit(Group(perms,()),1));
    blocks := Orbit(P,block,OnSets);
    reps := List(blocks,x->x[1]);

    Ntable:= [];

    for i in [1..Length(Ggens)] do
        g := Pgens[i];
        Ntable[2*i-1] := [];
        r := 2*i-1; s := 2*i;
        for j in [1..Length(blocks)] do
            Ntable[r][j] := PositionProperty(blocks,x->reps[j]^g in x);
        od;
        if IsIdentical(Htable[r],Htable[s]) then
            Ntable[s] := Ntable[r];
        else
            Ntable[s] := [];
            for j in [1..Length(blocks)] do
                Ntable[s][Ntable[r][j]] := j;
            od;
        fi;
    od;

    StandardizeTable(Ntable);

    return Ntable;

end;


#############################################################################
##
#F  TablesConjugacyClass( Htable,Ntable )   . . . . . . . . .  . . . . . . . 
##
## Htable is the coset table for the action of G, N is the normalizer of H,
## Ntable is the coset table for
## the action of G on the cosets of N.
## This function returns a list of coset tables for the set
## of all conjugates of H in G (including H itself).
TablesConjugacyClass := function(Htable,Ntable)

    local tables, rep, invrep, next, Nindex, Hindex, Ggens,
          i,j,k,l,m, iconj, g, vec, table;

    tables := [Htable];
    rep := [[]];
    invrep := [[]];
    next := [1];
    Nindex := Length(Ntable[1]);
    Hindex := Length(Htable[1]);
    l := 1;
    Ggens := QuoInt(Length(Htable),2);

    while Length(next) < Nindex  do
        j := next[l];
        for i in [1..Length(Htable)] do
            k := Ntable[i][j];
            if not IsBound(rep[k]) then 
                rep[k] := Concatenation(rep[j],[i]);
                invrep[k] := Reversed(rep[k]);
                for m in [1..Length(rep[k])] do
                    g := invrep[k][m];
                    if g mod 2 = 0 then
                        invrep[k][m] := g-1;
                    else
                        invrep[k][m] := g+1;
                    fi;
                od;
                Add(next,k);
            fi;
        od;
        l := l+1;
    od;

    for l in [2..Nindex] do
        # now we build the coset table for the conjugate of H by the word of
        # G corresponding to rep[l].
        # If this element of G is x then if t_1,t_2,..are coset reps for H
        # in G, then t_1^x, t_2^x ... are coset reps for H^x in G,
        # and g_i takes (Ht_j)^x to (Ht_j(xg_ix^-1))^x
        table := [];
        for i in [1..Ggens] do
            vec := [];
            iconj := Concatenation(rep[l],[2*i-1],invrep[l]);
            for j in [1..Hindex] do
                k := j;
                for g in iconj do 
                    k := Htable[g][k]; 
                od;
                vec[j] := k;
            od;
            table[2*i-1] := vec;
            if IsIdentical(Htable[2*i],Htable[2*i-1]) then
                table[2*i] := table[2*i-1];
            else
                table[2*i] := [];
                for j in [1..Hindex] do
                    table[2*i][table[2*i-1][j]] := j;
                od;
            fi;
        od;
        StandardizeTable(table);
        Add(tables,table);
    od; 

    return tables;
end;


#############################################################################
##
#F  RegularCosetTable( table )  . . . . . . . . . . . . . . .  . . . . . . . 
##
##  table is a coset table for the action of a group G on a subgroup H.
##  The function returns the coset table for the action of G on the core
##  of H, that is the coset table which represents the right regular
##  action of the permutation group associated with the coset table.
RegularCosetTable := function(table)
    local   newtable, perms, P,PG, Preg, Ggens, n, r,s,i,j,g;

    P := [];
    Ggens := QuoInt(Length(table),2);
    for i in [1..Ggens] do
        Add(P,PermList(table[2*i-1]));
    od;
    PG := Group(P,());
    Preg := [];
    for g in P do
        Add(Preg,Permutation(g,Elements(PG), OnRight)); 
    od;
    n := Size(PG);
    # Now the regular perm group corresponding to right regular action
    # of previous perm group.
    newtable := [];
    for i in [1..Ggens] do
        g := Preg[i];
        r := 2*i-1;
        s := 2*i; 
        newtable[r] := List([1..n],x->x^g);  
        if IsIdentical(table[r],table[s]) then
            newtable[s] := newtable[r];
        else
            newtable[s] := [];
            for j in [1..n] do
                newtable[s][newtable[r][j]] := j; 
            od;
        fi;
    od;
    StandardizeTable(newtable);
    return newtable;
end;


#############################################################################
##
#F  AllBlocks(<g>)  . . . . . . . . . . . . . . . . . . . . . . .  returns a 
##
##  representation of each non-trivial block system for the
##  permutation group g - from Alexander Hulpke.
##
AllBlocks := function(g)
    local dom, DoBlocks;

    DoBlocks := function(b)
        local bl, bld, i, t, n;

        bld := Difference(dom,b); 
        bl := [];
        for i in bld do
            t := Union(b,[i]);
            n := Blocks(g,dom,t);
            if Length(n)>1 then
                t := n[1];
                bl := Union(bl,[t],DoBlocks(t));
            fi;
        od;
        return bl;
    end;

    dom := PermGroupOps.MovedPoints(g);
    return DoBlocks(dom{[1]});
end;


#############################################################################
##
#F  IntermediateCosetTables(<table>)  . . . . . . . . . . . . . .  finds all 
##  the coset tables corresponding to non-trivial block systems of table.
##  From A. Hulpke.
##
##
IntermediateCosetTables := function(table)
    local o,b,bl,ex,i,j,r,s,etable,ngens,pgens,g,blocks,reps;

    ngens := QuoInt(Length(table),2);
    pgens := [];
    for i in [1..ngens] do
        Add(pgens,PermList(table[2*i-1]));
    od;
    o:=Group(pgens,());
    b:=AllBlocks(o);
    if Length(b)=0 then
        return [];
    else
        ex:=[];
        for bl in b do

            blocks := Orbit(o,bl,OnSets);
            reps := List(blocks,x->x[1]);

            etable:= [];

            for i in [1..ngens] do
                g := pgens[i];
                etable[2*i-1] := [];
                r := 2*i-1; 
                s := 2*i;
                for j in [1..Length(blocks)] do
                    etable[r][j] := PositionProperty(blocks,x->reps[j]^g in x);
                od;
                if IsIdentical(table[r],table[s]) then
                    etable[s] := etable[r];
                else
                    etable[s] := [];
                    for j in [1..Length(blocks)] do
                        etable[s][etable[r][j]] := j;
                    od;
                fi;
            od;

            StandardizeTable(etable);

            Add(ex,etable);
        od;
        return ex;
    fi;
end;
