[Setup]
AppName=Law Enforcer Assistant!
AppVersion=Actual
DefaultDirName=C:\Users\KyRDa\AppData\Local\Programs\Arizona Games Launcher\bin\arizona
OutputBaseFilename=Law Enforcer Assistant Setup
Compression=lzma
SolidCompression=yes
DisableProgramGroupPage=yes 
Uninstallable=no
DirExistsWarning=no

[Languages]
Name: "russian"; MessagesFile: "Russian.isl"

[Tasks]
Name: "VisualCppRedist"; Description: "Установить все версии C++ (рекомендуется)"; GroupDescription: "Улучшение стабильности"
Name: "DirectX"; Description: "Установить DirectX (рекомендуется)"; GroupDescription: "Улучшение стабильности"

[Files]
Source: "LEA setup source\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Run]
Filename: "https://lea.code-dominators.fun"; Flags: shellexec postinstall; Description: "Посетить главный сайт скрипта"
Filename: "https://discord.com/invite/m4w2wkdb8X"; Flags: shellexec postinstall; Description: "Присоединиться к дискорд-серверу скрипта"
Filename: "C:\Users\KyRDa\Documents\VSC WORKSPACES\LEA-setup\dxwebsetup.exe"; Flags: shellexec; Tasks: DirectX
Filename: "C:\Users\KyRDa\Documents\VSC WORKSPACES\LEA-setup\VisualCppRedist_AIO.exe"; Flags: shellexec; Tasks: VisualCppRedist

