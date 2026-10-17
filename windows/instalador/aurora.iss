; Instalador do Aurora para Windows (Inno Setup 6).
; Compilado por tool/release/windows.ps1, que passa /DAppVersion=x.y.z.
; Instala por usuário (sem pedir administrador) e, rodando em silêncio pela
; atualização automática, fecha o app, troca os arquivos e o abre de novo.
; Os dados do app ficam em %APPDATA%\br.app.aurora e não são tocados.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

[Setup]
; Nunca mudar o AppId: é ele que faz a versão nova substituir a antiga.
AppId={{8C4F2A61-5B7E-4D3A-9E12-6A0F3B8D7C55}
AppName=Aurora
AppVersion={#AppVersion}
AppVerName=Aurora {#AppVersion}
AppPublisher=Maraath
DefaultDirName={localappdata}\Programs\Aurora
DefaultGroupName=Aurora
DisableProgramGroupPage=yes
DisableDirPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=..\..\build\instalador
OutputBaseFilename=Aurora-{#AppVersion}-setup
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\aurora.exe
UninstallDisplayName=Aurora
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
CloseApplications=force
RestartApplications=no

[Languages]
Name: "ptbr"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na área de trabalho"; GroupDescription: "Atalhos:"

[InstallDelete]
; Tira arquivos de versões antigas que a nova não usa mais.
Type: filesandordirs; Name: "{app}\data"

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; O AppUserModelID igual ao do app faz as notificações saírem com o nome e o ícone do Aurora.
Name: "{autoprograms}\Aurora"; Filename: "{app}\aurora.exe"; AppUserModelID: "BrAppAurora.Aurora"
Name: "{autodesktop}\Aurora"; Filename: "{app}\aurora.exe"; Tasks: desktopicon

[Run]
; Sem "skipifsilent": depois da atualização silenciosa o app volta sozinho.
Filename: "{app}\aurora.exe"; Description: "Abrir o Aurora"; Flags: nowait postinstall
