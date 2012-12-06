program project1;

{$mode objfpc}{$H+}

uses
  Windows, iniFiles, SysUtils;

{$R *.res}

function RunApp(my_app : string; my_wait : bool) : bool;
  var
    si : TStartupInfo;
    pi : TProcessInformation;
  begin
    Result := false;
    try
      ZeroMemory(@si,SizeOf(si));
      si.cb := SizeOf(si);
      //si.dwFlags := STARTF_USESHOWWINDOW;
      //si.wShowWindow := SW_HORMAL;
      if CreateProcess(nil,PChar(my_app),nil,nil,False,0,nil,nil,si,pi{%H-})=true then Result := true;
      try CloseHandle(pi.hThread); except ; end;
      if my_wait = true then WaitForSingleObject(pi.hProcess, INFINITE);
      try CloseHandle(pi.hProcess); except ; end;
    except
      Result := false;
    end;
  end;

function IsWindows64: boolean;
{$ifdef WIN32} //Modified KpjComp for 64bit compile mode
type
  TIsWow64Process = function( // Type of IsWow64Process API fn
      Handle: Windows.THandle; var Res: Windows.BOOL): Windows.BOOL; stdcall;
var
  IsWow64Result: Windows.BOOL; // Result from IsWow64Process
  IsWow64Process: TIsWow64Process; // IsWow64Process fn reference
begin
  // Try to load required function from kernel32
  IsWow64Process := TIsWow64Process(Windows.GetProcAddress(
    Windows.GetModuleHandle('kernel32'), 'IsWow64Process'));
  if Assigned(IsWow64Process) then
  begin
    // Function is implemented: call it
    if not IsWow64Process(Windows.GetCurrentProcess, IsWow64Result) then
      raise SysUtils.Exception.Create('IsWindows64: bad process handle');
    // Return result of function
    Result := IsWow64Result;
  end
  else
    // Function not implemented: can't be running on Wow64
    Result := False;
{$else} //if were running 64bit code, OS must be 64bit :)
begin
 Result := True;
{$endif}
end;

function RunProgram(ininame: string; section: string): boolean;
var
  ini: TIniFile;
  cmdline: string;
begin
  Result:=False;
  ini:=TIniFile.Create(ininame);
  try
    if ini.ValueExists(section,'CmdLine') then begin
      Result:=True;
      cmdline:=ini.ReadString(section,'CmdLine','');
      if trim(cmdline)='' then exit;
      RunApp(cmdline,false);
    end;
  finally
    ini.Free;
  end;
end;

var
  ininame, info: string;
begin
  info:=#10#10+'Structure of ini:'+
        #10+'[Launch]'+
        #10+'CmdLine=calc.exe'+
        #10+'or'+
        #10+'[Launch32]'+
        #10+'CmdLine=calc32.exe'+
        #10+'[Launch64]'+
        #10+'CmdLine=calc64.exe'+
        #10+''+
        #10+'Created by Str@y (2012)';

  ininame:=ExtractFileName(paramstr(0));    //get current exe-name
  SetLength(ininame, Length(ininame)-4);   // cut '.exe'
  ininame:=ininame+'.ini';

  if not FileExists(ininame) then begin
    MessageBox(0, PChar(ininame+' not found.'+info), 'ProgStarter', MB_OK);
    exit;
  end;

  if not RunProgram(ininame,'Launch') then begin
    if IsWindows64() then
      RunProgram(ininame,'Launch64')
    else
      RunProgram(ininame,'Launch32');
  end;
end.

