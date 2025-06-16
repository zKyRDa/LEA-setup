[Setup]
AppName=Law Enforcer Assistant!
AppVersion=Actual
DefaultDirName={localappdata}\Programs\Arizona Games Launcher\bin\arizona
OutputBaseFilename=Law Enforcer Assistant Setup
Compression=lzma
SolidCompression=yes
DisableProgramGroupPage=yes 
Uninstallable=no
DirExistsWarning=no
WizardImageFile=img\banner_for_setup.bmp
WizardSmallImageFile=img\small_banner_for_setup.bmp
SetupIconFile=img\lea.ico

[Languages]
Name: "russian"; MessagesFile: "Russian.isl"

[Tasks]
Name: "VisualCppRedist"; Description: "Установить все версии C++ (рекомендуется)"; GroupDescription: "Улучшение стабильности"
Name: "DirectX"; Description: "Установить DirectX (рекомендуется)"; GroupDescription: "Улучшение стабильности"

[Files]
Source: "LEA setup source\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "dxwebsetup.exe"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "VisualCppRedist_AIO.exe"; DestDir: "{tmp}"; Flags: ignoreversion

[Run]
Filename: "https://lea.code-dominators.fun"; Flags: shellexec postinstall; Description: "Посетить главный сайт скрипта"
Filename: "https://discord.com/invite/m4w2wkdb8X"; Flags: shellexec postinstall; Description: "Присоединиться к дискорд-серверу скрипта"
Filename: "{tmp}\dxwebsetup.exe"; Flags: shellexec waituntilterminated; Tasks: DirectX; Description: "Установка DirectX"
Filename: "{tmp}\VisualCppRedist_AIO.exe"; Flags: shellexec waituntilterminated; Tasks: VisualCppRedist; Description: "Установка Visual C++"
