#############################################################################
##
#W  xgap_test.g               XGAP testing framework          Russ Woodroofe
##

## All globals are prefixed with XGT_

##
##  TL;DR:  Load this file, then perform XGT_Test(<cmd>) for a command <cmd> 
##  to be tested in an XGAP or Gap.app style environment.  
##
##  E.g.:
##    XGT_Test("Print(\"Hello world\");");
##

##
##  Global variables
## 
XGT_buf:="";
XGT_inputmode:=false;

##
## Constant storing the @w code queries sent by the XGAP library on startup,
## together with appropriate responses.  (The responses match those sent by
## Gap.app 0.61, but for most purposes, the specifics shouldn't matter.)
##
## Structure: list of pairs.  
##   1st entry: query sent by XGAP library
##   2nd entry: response to send back
##
## Queries:
##   3+XCN is asking for the number of colors supported.  (Generally, 2 or 5.)
##   6+XFI lines are asking for metrics of a fixed-spacing font in five sizes
##
XGT_wcode_responses:=[
  ["3+XCN","@a6+I0+I4+"],
  ["6+XFII1+","@a21+I0+I7+I3+I6+"],
  ["6+XFII2+","@a21+I0+I9+I3+I7+"],
  ["6+XFII3+","@a31+I0+I11+I4+I9+"],
  ["6+XFII4+","@a41+I0+I21+I4+I01+"],
  ["6+XFII5+","@a41+I0+I51+I5+I31+"]];;

##
#F  XGT_ParseChunk( <stream> )
##  
##  Parse input from "GAP -p" instance up to next @ special code, if any
##

XGT_ParseChunk:=function(stream)
  local atpos, retstr, codechar, pluspos, i;

  atpos:=Position(XGT_buf, '@');
  if atpos = fail then
    retstr:=ShallowCopy(XGT_buf);
    XGT_buf:="";
    return retstr;
  elif atpos > 1 then
    retstr:=XGT_buf{[1..atpos-1]};
    XGT_buf:=XGT_buf{[atpos..Length(XGT_buf)]};
    return retstr;
  fi;
  # So, atpos=1
  if Length(XGT_buf) < 2 then
    Info(InfoWarning, 1, "Unexpected @ code end");
    return fail;
  fi;
  codechar:=XGT_buf[2];
  XGT_buf:=XGT_buf{[3..Length(XGT_buf)]};
  if codechar = '@' then
    return "@";
  elif codechar = 'J' then
    return "\n";
  elif codechar = 'n' then
    #normal output, no action needed
    return "";
  elif codechar = 'r' then
    #input line, no action needed
    return "";
  elif (codechar >= '!' and codechar <= '&') or
       (codechar >= '1' and codechar <= '6') then
    # if we have a woefully underful buffer, try to get more
    if Length(XGT_buf) <= 3 then
      Append(XGT_buf, ReadLine(stream));
    fi;
    pluspos:=Position(XGT_buf, '+');
    if pluspos = fail then
      Info(InfoWarning, 1, "Badly formed garbage collection command");
      return fail;
    fi;
    XGT_buf:=XGT_buf{[pluspos+1..Length(XGT_buf)]};
    return "";
  elif codechar = 'i' then
    XGT_inputmode:=true;
    return "";
  elif codechar = 'e' then
    XGT_inputmode:=fail;
    return "";
  elif codechar = 'w' then
    # if we have a woefully underful buffer, try to get more
    if Length(XGT_buf) <= 3 then
      Append(XGT_buf, ReadLine(stream));
    fi;
    for i in [1..Length(XGT_wcode_responses)] do
      if StartsWith(XGT_buf, XGT_wcode_responses[i][1]) then
        WriteAll(stream, XGT_wcode_responses[i][2]);
        XGT_buf:=XGT_buf{[Length(XGT_wcode_responses[i][1])+1..Length(XGT_buf)]};
        return "";
      fi;
    od;
    Info(InfoWarning, 1, "Unimplemented @w code query @w", XGT_buf);
    return "@w";
  else
    return Flat(["[@", [codechar], "]"]);
  fi;
end;

##
#F  XGT_ParseUntilInput( <stream> )
##  
##  Parse input from "GAP -p" instance until the instance enters either
##  input mode, or error mode
##
XGT_ParseUntilInput:=function(stream)
  while XGT_inputmode = false do
    Append(XGT_buf, ReadLine(stream));
    while not IsEmpty(XGT_buf) do
      Print(XGT_ParseChunk(stream),"\c");
    od;
  od;
end;

##
#F  XGT_Test( <cmd> )
##  
##  Start up "GAP -p" instance, running GAP in the package mode ("XGAP mode").
##  Parse XGAP commands, and give canned responses to some basic queries.
##  Once "GAP -p" instance is ready for input, issue a single command, then
##  wait for the instance to be ready for input (or error input again).
##  Close stream (which should close the child "GAP -p" instance) at that
##  point.
##
XGT_Test:=function(cmd)
  local GAP_cmd, GAP_dir, stream, mycmd;

  GAP_cmd := Filename(DirectoriesLibrary(""), "gap");
  GAP_dir := DirectoryCurrent();

  XGT_buf:="";
  XGT_inputmode:=false;

  Print("Running GAP in package mode for command:  ", cmd, "\n\n");

  stream := InputOutputLocalProcess(GAP_dir,GAP_cmd,["-p"]);

  if ReadLine(stream) <> "@p1." then
    Info(InfoWarning, 1, "Failed acknowledgement from GAP package mode");
    CloseStream(stream);
    return fail;
  fi;

  XGT_ParseUntilInput(stream);

  WriteAll(stream, cmd);
  WriteAll(stream, "\n");
  XGT_inputmode:=false;

  XGT_ParseUntilInput(stream);

  CloseStream(stream);
end;

