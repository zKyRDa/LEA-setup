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

[Files]
Source: "LEA setup source\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Run]
Filename: "https://lea.code-dominators.fun"; Flags: shellexec postinstall; Description: "Посетить главный сайт скрипта"
Filename: "https://discord.com/invite/m4w2wkdb8X"; Flags: shellexec postinstall; Description: "Присоединиться к дискорд-серверу скрипта"