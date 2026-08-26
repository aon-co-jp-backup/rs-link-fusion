; rs-link-fusion Windowsインストーラー(Inno Setup)。
;
; ユーザー指示「パワーシェル版とリポジトリ名-installer.exeの二種類を
; ご用意して」への対応。既存の`install.ps1`(管理者権限のPowerShell、
; 電源プロファイルの対話選択+マシン環境変数設定)はそのまま維持し、
; これは第二の選択肢——ダブルクリックで進むGUIインストーラー(内部で
; 既存install.ps1をそのまま呼ぶ、電源プロファイルの対話選択もそのまま
; コンソール上で行われる)。
;
; 正直な開示: install.ps1が`[Environment]::SetEnvironmentVariable(...,
; 'Machine')`でマシン全体の環境変数を設定するため、管理者権限が必須
; ——`PrivilegesRequired=admin`とし、Inno Setup標準のUAC昇格プロンプト
; を1回表示する(手動での管理者権限PowerShell起動が不要になる)。
; wintun.dll・shaders\は任意ファイルで、このインストーラーには同梱
; しない(既存install.ps1と同じくファイルが存在すれば使う設計、
; 別途 https://wintun.net/ から取得しinstall先へ配置可能)。
;
; ビルド方法: リポジトリルートで`cargo build --release --bin
; rs-linkfusion`を実行した後、このディレクトリで`ISCC.exe
; rs-link-fusion.iss`を実行する。

#define MyAppName "rs-link-fusion"
#ifndef MyAppVersion
  #define MyAppVersion "0.0.0-local-build"
#endif
#define MyAppPublisher "aon-co-jp"
#define MyAppURL "https://github.com/aon-co-jp/rs-link-fusion"
#define MyAppExeName "rs-linkfusion.exe"

[Setup]
PrivilegesRequired=admin
AppId={{D4E5F6A7-9999-4A5B-8C6D-2E7F9A0B1C2D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2
SolidCompression=yes
OutputDir=dist
OutputBaseFilename=rs-link-fusion-installer
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes

[Languages]
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\..\target\release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\install.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Run]
; 既存install.ps1の電源プロファイル選択・環境変数設定ロジックをそのまま
; 再利用する(重複実装を避ける)。対話プロンプト(Read-Host)が表示される
; ためwaituntilterminatedのみ(runhiddenは付けない)。
Filename: "powershell.exe"; \
    Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\install.ps1"""; \
    StatusMsg: "Choosing power profile and finishing setup... / 電源プロファイルの選択とセットアップを完了中..."; \
    Flags: waituntilterminated

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
