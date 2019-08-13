; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "CSM Service"
!define PRODUCT_VERSION "1.1.12.1"
!define PRODUCT_PUBLISHER "ITOB"
!define PRODUCT_WEB_SITE "http://www.itob.ru"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\CsmSvc.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI2.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\win.bmp" ; optional
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "Russian"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "CsmSvcSetup.exe"
InstallDir "$PROGRAMFILES\CsmService"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "MainSection" SEC01
  
  SetOutPath "$INSTDIR"
  SetOverwrite try
  File "SRC\CsmSvc.exe"
  
  ; ���� ������ ����� ��� - ������
  ReadRegStr $0 HKLM SYSTEM\CurrentControlSet\Services\CsmService "DisplayName"
  StrCmp $0 "CsmService" service_installed done
  service_installed:
     ExecWait "net stop CsmService"
	 Sleep 1000
	 ExecWait "taskkill /f /im CsmSvc.exe"
	 Sleep 1000
     ExecWait "$INSTDIR\CsmSvc.exe /uninstall /silent"
     Goto done
  done:
  
  SetOutPath "$INSTDIR"
  SetOverwrite on
  File "SRC\CsmSvc.exe"
  File "SRC\libeay32.dll"
  File "SRC\libssl32.dll"
  File "SRC\ssleay32.dll"
  File "SRC\sqlite3.dll"
  File "SRC\check_csmsvc.vbs"
  File "SRC\restart.bat"
  File "SRC\start.bat"
  File "SRC\stop.bat"  
  SetOverwrite off
  File "SRC\CsmSvc.ini"
    
  SetOverwrite try
  
  SetOutPath "$INSTDIR\htdocs"
  File "SRC\htdocs\index.html"
  
  SetOutPath "$INSTDIR\htdocs\map\images"
  File "SRC\htdocs\map\images\*"

  SetOutPath "$INSTDIR\htdocs\map\img"
  File "SRC\htdocs\map\img\*"
  
  SetOutPath "$INSTDIR\htdocs\map"
  File "SRC\htdocs\map\map.html"
  File "SRC\htdocs\map\style.css"
  File "SRC\htdocs\map\OpenLayers.js"
  File "SRC\htdocs\map\Custom.js"
  File "SRC\htdocs\map\jquery.js"
  File "SRC\htdocs\map\openlayex.js"
  
  SetOutPath "$INSTDIR\htdocs\map\theme\default"
  File "SRC\htdocs\map\theme\default\*.css"
  SetOutPath "$INSTDIR\htdocs\map\theme\default\img"
  File "SRC\htdocs\map\theme\default\img\*"
  
  SetOutPath "$INSTDIR\data\Images"
  File "SRC\data\Images\*"
  SetOutPath "$INSTDIR\data\Profiles"
  SetOutPath "$INSTDIR\data\Tiles"
    
  SetOutPath "$INSTDIR"
  
  CreateDirectory "$SMPROGRAMS\CsmService"
  Delete "$SMPROGRAMS\CsmService\*"
  CreateShortCut "$SMPROGRAMS\CsmService\Edit Configuration File.lnk" "$INSTDIR\CsmSvc.ini"
  CreateShortCut "$SMPROGRAMS\CsmService\Test Configuration.lnk" "http://127.0.0.1:8091/Test"
  CreateShortCut "$SMPROGRAMS\CsmService\Start service.lnk" "$INSTDIR\start.bat"
  CreateShortCut "$SMPROGRAMS\CsmService\Stop service.lnk" "$INSTDIR\stop.bat"
  CreateShortCut "$SMPROGRAMS\CsmService\Restart service.lnk" "$INSTDIR\restart.bat"
  CreateShortCut "$SMPROGRAMS\CsmService\CsmService status.lnk" "http://127.0.0.1:8091/Status" 
  CreateShortCut "$SMPROGRAMS\CsmService\Review Log.lnk" "$INSTDIR\CsmSvc.log"
  CreateShortCut "$SMPROGRAMS\CsmService\Uninstall.lnk" "$INSTDIR\uninst.exe"
  
  ; ������ ������
  ExecWait "$INSTDIR\CsmSvc.exe /install /silent"
  ExecWait "net start CsmService"
  
  ; ������� ����������� ������� ��������  
  ExecWait "schtasks /End /tn check_csmsvc"  
  ExecWait "schtasks /DELETE /tn check_csmsvc /f"
  ; ��� ������� ������, ������� ���������, ���� ��� �� ������
  ;ExecWait "schtasks /create /tn check_csmsvc /tr $\"%SystemRoot%\system32\CScript.exe \$\"$INSTDIR\check_csmsvc.vbs\$\" //B$\" /sc MINUTE /mo 20 /st 00:00:00 /ru $\"System$\""
  
  ; ������� ����������� ������� ����������� CsmService
  ExecWait "schtasks /End /tn restart_csmservice"
  ExecWait "schtasks /DELETE /tn restart_csmservice /f"
  ExecWait "schtasks /create /tn restart_csmservice /tr $\"$INSTDIR\restart.bat$\" /sc DAILY /mo 1 /st 00:00:00 /ru $\"System$\""  
    
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\CsmSvc.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\CsmSvc.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "�������� ��������� $(^Name) ���� ������� ���������."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "�� ������� � ���, ��� ������� ������� $(^Name) � ��� ���������� ���������?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  ExecWait "net stop CsmService"
  ExecWait "taskkill /f /im CsmSvc.exe"
  ExecWait "$INSTDIR\CsmSvc.exe /uninstall /silent"
  
  ExecWait "schtasks /End /tn check_csmsvc"  
  ExecWait "schtasks /DELETE /tn check_csmsvc /f"
  
  Delete "$INSTDIR\uninst.exe"    
  Delete "$INSTDIR\CsmSvc.ini"
  Delete "$INSTDIR\CsmSvc.exe"
  Delete "$INSTDIR\libeay32.dll"
  Delete "$INSTDIR\libssl32.dll"
  Delete "$INSTDIR\ssleay32.dll"
  Delete "$INSTDIR\sqlite3.dll"
  Delete "$INSTDIR\CsmSvc.log"
  Delete "$INSTDIR\*.log"
  Delete "$INSTDIR\check_csmsvc.vbs"
  Delete "$INSTDIR\restart.bat"
  
  Delete "$INSTDIR\htdocs\map\theme\default\img\*"
  Delete "$INSTDIR\htdocs\map\theme\default\*"
  Delete "$INSTDIR\htdocs\map\img\*"
  Delete "$INSTDIR\htdocs\map\images\*"
  Delete "$INSTDIR\htdocs\map\*"
  Delete "$INSTDIR\htdocs\cache\*" 
  
  Delete "$INSTDIR\htdocs\index.html"
  
  Delete "$INSTDIR\data\Images\*"
  Delete "$INSTDIR\data\Profiles\*"
  Delete "$INSTDIR\data\Tiles\*"
  
  Delete "$SMPROGRAMS\CsmService\Edit Configuration File.lnk"
  Delete "$SMPROGRAMS\CsmService\Test Configuration.lnk"
  Delete "$SMPROGRAMS\CsmService\Start service.lnk"
  Delete "$SMPROGRAMS\CsmService\Stop service.lnk"
  Delete "$SMPROGRAMS\CsmService\Restart service.lnk"
  Delete "$SMPROGRAMS\CsmService\CsmService status.lnk"
  Delete "$SMPROGRAMS\CsmService\Review Log.lnk"
  Delete "$SMPROGRAMS\CsmService\Uninstall.lnk"
  
  RMDir "$INSTDIR\htdocs\map\theme\default\img"
  RMDir "$INSTDIR\htdocs\map\theme\default"
  RMDir "$INSTDIR\htdocs\map\theme"
  RMDir "$INSTDIR\htdocs\map\img"
  RMDir "$INSTDIR\htdocs\map\images"
  RMDir "$INSTDIR\htdocs\map"
  RMDir "$INSTDIR\htdocs\cache"  
  RMDir "$INSTDIR\htdocs"  
  RMDir "$INSTDIR\data\Images"
  RMDir "$INSTDIR\data\Profiles"
  RMDir "$INSTDIR\data\Tiles"
  RMDir "$INSTDIR\data"  
  RMDir "$INSTDIR"
  
  RMDir "$SMPROGRAMS\CsmService"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd