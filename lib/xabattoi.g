# print a longer text in a graphic sheet
PrintGS := function( sheet, x, y, text )
    local   h,  w,  s,  n,  sub,  p,  l;

    # we use the normal font, compute its height and width
    h := FONTS.normal[1]+FONTS.normal[2]+2;
    w := FONTS.normal[3];

    # how large is the graphic sheet
    s := sheet.width;

    # how many characters will fit in one line
    n := QuoInt( (s-2*y), w );

    # print the text
    text := Copy(text);
    l := 0;
    while 0 < Length(text)  do
        if Length(text) < n  then
            sub  := text;
            text := "";
        else
            p := n;
            while not text[p] in ".,!? " and n/2 < p  do
                p := p - 1;
            od;
            if not text[p] in ".,!? "  then
                p := n;
            fi;
            sub := text{[1..p]};
            p   := p+1;
            while p <= Length(text) and text[p] = ' '  do
                p := p + 1;
            od;
            text := text{[p..Length(text)]};
        fi;
        Text( sheet, FONTS.normal, x, y, sub );
        l := l + 1;
        y := y + h;
    od;
    return l;
end;


# create a button in a graphic sheet
Button := function( sheet, x, y, text, func )
    local   h,  w,  ret,  txt,  but;

    # compute the dimension of the text
    h := FONTS.small[1]+FONTS.small[2];
    w := FONTS.small[3] * Length(text);

    # create a rectangle
    ret := Rectangle( sheet, x, y, w+4, h+4 );

    # create a text
    txt := Text( sheet, FONTS.small, x+3, y+2+FONTS.small[1], text );

    # store the button in a record
    but := rec( rectangle := ret, text := txt, func := func );

    # store the button in <sheet>.buttons
    if not IsBound(sheet.buttons)  then
        sheet.buttons := [];
    fi;
    Add( sheet.buttons, but );
    
    # and return
    return but;

end;
