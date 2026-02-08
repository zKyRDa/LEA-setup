[Setup]
AppName=Law Enforcer Assistant!
AppVersion=Actual
DefaultDirName={localappdata}\Programs\Arizona Games Launcher\bin\arizona
AppendDefaultDirName=no
OutputBaseFilename=Law Enforcer Assistant Setup
Compression=lzma
SolidCompression=yes
DisableProgramGroupPage=yes 
DirExistsWarning=no
WizardImageFile=img\banner_for_setup.bmp
WizardSmallImageFile=img\small_banner_for_setup.bmp
SetupIconFile=img\lea.ico
RestartIfNeededByRun=no
Uninstallable=no
CreateUninstallRegKey=no
UpdateUninstallLogAppName=no

[Languages]
Name: "russian"; MessagesFile: "Russian.isl"

[Tasks]
Name: "VisualCppRedist"; Description: "Установить все версии C++ (может занять много времени)"; GroupDescription: "Дополнительное ПО, которое может улучшить работу LEA:"; Flags: unchecked
Name: "DirectX"; Description: "Установить DirectX"; GroupDescription: "Дополнительное ПО, которое может улучшить работу LEA:"; Flags: unchecked

[Files]
Source: "LEA setup source\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "dxwebsetup.exe"; DestDir: "{tmp}"; Flags: ignoreversion
; Source: "VisualCppRedist_AIO_x86_x64.exe"; DestDir: "{tmp}"; Flags: ignoreversion

[Run]
Filename: "https://lea-script.tech"; Flags: shellexec postinstall; Description: "Посетить главный сайт скрипта"
Filename: "https://discord.gg/ynuGF4XX6Q"; Flags: shellexec postinstall; Description: "Присоединиться к дискорд-серверу скрипта"

Filename: "{tmp}\dxwebsetup.exe"; Flags: shellexec waituntilterminated; Tasks: DirectX; Description: "Установка DirectX"
Filename: "{tmp}\VisualCppRedist_AIO_x86_x64.exe"; Flags: shellexec waituntilterminated; Tasks: VisualCppRedist; Description: "Установка Visual C++"

[Code]
var
  DownloadPage: TDownloadWizardPage;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;

procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpSelectDir then begin
    if not DirExists(WizardForm.DirEdit.Text) then begin
      MsgBox('Ошибка: Указанной папки не существует!' + #13#10 + 
             'Пожалуйста, укажите правильный путь до папки с игрой.', mbError, MB_OK);
      Result := False;
    end;
  end
  else
  if CurPageID = wpReady then begin
    DownloadPage.Clear;
    
    if WizardIsTaskSelected('VisualCppRedist') then begin
      DownloadPage.Add('https://lea-script.tech/system/scripts/lib/VisualCppRedist_AIO_x86_x64.exe', 'VisualCppRedist_AIO_x86_x64.exe', 'ebdb3072ffb0d651b8fbd4e9ff8d8eca9930cb53231cdaced775a4fd8df4f273');
    end;
    
    DownloadPage.Add('https://lea-script.tech/system/scripts/Law%20Enforcer%20Assistant%20Manager.luac', 'Law Enforcer Assistant Manager.luac', '');
    DownloadPage.Add('https://lea-script.tech/system/scripts/Law%20Enforcer%20Assistant.luac', 'Law Enforcer Assistant.luac', '');
    
    DownloadPage.Show;
    
    try
      try
        DownloadPage.Download;
        Result := True;
      except
        SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
        Result := False;
      end;
    finally
      DownloadPage.Hide;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then 
  begin
    FileCopy(ExpandConstant('{tmp}\Law Enforcer Assistant Manager.luac'), ExpandConstant('{app}\moonloader\Law Enforcer Assistant Manager.luac'), false);
    FileCopy(ExpandConstant('{tmp}\Law Enforcer Assistant.luac'), ExpandConstant('{app}\moonloader\Law Enforcer Assistant\Law Enforcer Assistant.luac'), false);
    
    if FileExists(ExpandConstant('{tmp}\VisualCppRedist_AIO_x86_x64.exe')) then
      DeleteFile(ExpandConstant('{tmp}\VisualCppRedist_AIO_x86_x64.exe'));
  end;
end;