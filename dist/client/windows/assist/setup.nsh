;=========================================================
;	teleport-assist Run-time Package Installer Script.
;=========================================================

;--------------------------------------
; 命令行参数检查
;--------------------------------------

;!ifndef OEM_NAME
;	!error "You must define OEM_NAME."
;!endif

;--------------------------------------
; 包含安装对话框所要用到的头文件
;--------------------------------------
!include "MUI.nsh"
!include "x64.nsh"
!include "WinVer.nsh"
!include "WordFunc.nsh"
!include "FileFunc.nsh"

;--------------------------------------
; 定义编译nsi脚本的输出文件名称
;--------------------------------------

OutFile "..\..\..\..\out\installer\${FILE_NAME_RUNTIMEPAGE}"

Name "$(STR_PRODUCT_NAME_DISPLAY)"


;--------------------------------------
; 定义安装程序的版本信息[可选]
;--------------------------------------
VIProductVersion ${FILE_VER}
VIAddVersionKey "CompanyName"		"${COMPANY_NAME}"
VIAddVersionKey "ProductName"		"${PRODUCT_NAME_DISPLAY}"
VIAddVersionKey "FileDescription"	"${PRODUCT_DESC}"
VIAddVersionKey "LegalCopyright"	"${COPYRIGHT}"
VIAddVersionKey "FileVersion"		"${FILE_VER}"
VIAddVersionKey "ProductVersion"	"${FILE_VER}"


;--------------------------------------
; 定义默认安装路径
;--------------------------------------

;InstallDir "$PROGRAMFILES\${TARGET_DIR_BASE}"
InstallDir "$APPDATA\${TARGET_DIR_BASE}"

;--------------------------------------
; 定义默认注册表键值
;--------------------------------------
InstallDirRegKey HKLM "${TARGET_REG_BASE}" ""

;--------------------------------------
; 设置安装和卸载对话框的资源
;--------------------------------------

!define MUI_UNICON		"${SRC_RC_PATH}\uninstall.ico"
!define MUI_ICON		"${SRC_RC_PATH}\install.ico"

!define MUI_WELCOMEFINISHPAGE_BITMAP	"${SRC_RC_PATH}\win_inst.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP	"${SRC_RC_PATH}\win_uninst.bmp"

!define MUI_HEADERIMAGE				; Use the header image
!define MUI_HEADERIMAGE_RIGHT		; Put the header image to right.

!define MUI_HEADERIMAGE_BITMAP		"${SRC_RC_PATH}\header_inst.bmp"
!define MUI_HEADERIMAGE_UNBITMAP	"${SRC_RC_PATH}\header_uninst.bmp"

;--------------------------------------
; 安装和卸载的过程详细信息显示开关
;--------------------------------------
ShowInstDetails "nevershow"
ShowUninstDetails "nevershow"

;--------------------------------------
;要求安装安装时候使用管理员权限
;--------------------------------------
RequestExecutionLevel admin

;--------------------------------------
;安装和卸载退出前警告
;--------------------------------------
!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING

;记住安装程序选用的语言，将来在卸载程序中可能用到
!define MUI_LANGDLL_REGISTRY_ROOT			"HKLM"
!define MUI_LANGDLL_REGISTRY_KEY			"${TARGET_REG_BASE}"
!define MUI_LANGDLL_REGISTRY_VALUENAME		"InstallLanguageId"
!define MUI_COMPONENTSPAGE_SMALLDESC

;--------------------------------
;声明一些变量
;--------------------------------
;Var VAR_TEMP_PATH		;;资源释放的临时目录
Var VAR_TEMP_SYSWOW64		;; 64位系统 的syswow64, 32位系统的system32
Var VAR_TEMP_0
Var VAR_TEMP_1
Var VAR_TEMP_2
;--------------------------------------
; 定义安装对话框
;--------------------------------------
; Installer Pages.
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
;--------------------------------------
; 定义卸载对话框
;--------------------------------------
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------------
; 多语言支持
;--------------------------------------
!ifdef _SUPPORT_LANG_SIMPCHINESE
	!include "LangSimpChinese.nsh"
	!ifndef _SUPPORT_MUTI_LANGS_
		!define _LANG				2052
		!define _LANG_NAME			"SimpChinese"
	!endif ;;
!endif

!ifdef _SUPPORT_LANG_ENGLISH
	!include "LangEnglish.nsh"
	!ifndef _SUPPORT_MUTI_LANGS_
		!define _LANG				1033
		!define _LANG_NAME			"English"
	!endif ;;
!endif

!ifdef _SUPPORT_LANG_TRADCHINESE
	!include "LangTradChinese.nsh"
	!ifndef _SUPPORT_MUTI_LANGS_
		!define _LANG				1028
		!define _LANG_NAME			"TradChinese"
	!endif ;;
!endif

!ifdef _SUPPORT_LANG_JAPANESE
	!include "LangJapanese.nsh"
	!ifndef _SUPPORT_MUTI_LANGS_
		!define _LANG				1041
		!define _LANG_NAME			"Japanese"
	!endif ;;
!endif
;--------------------------------
;Reserve Files

;These files should be inserted before other files in the data block
;Keep these lines before any File command
;Only for BZIP2 (solid) compression
ReserveFile "${SRC_RC_PATH}\header_inst.bmp"
!ifdef _SUPPORT_MUTI_LANGS_
	!insertmacro MUI_RESERVEFILE_LANGDLL ;LangDLL (language selection dialog)
!endif

;-------------------------------------------------
; 拷贝并安装文件，如果存在则重命名
; $R0 -- 源目录
; $R1 -- 源文件名
; $R2 -- 目标目录
;-------------------------------------------------
;Function CopyAndReplaceFile
;	;MessageBox MB_OK "1:$R0\$R1, 2:$R2"
;	SetOverwrite try
;	ClearErrors
;	CopyFiles /SILENT "$R0\$R1" "$R2"
;	IfErrors 0 NO_ERROR
;		IfFileExists "$R2\$R1" 0 NO_ERROR
;			GetTempFileName $VAR_TEMP_1
;			;MessageBox MB_OK "R0\R1:$R0\$R1 R2:$R2"
;			Delete "$VAR_TEMP_1"
;			Rename "$R2\$R1" "$VAR_TEMP_1"
;			CopyFiles /SILENT "$R0\$R1" "$R2"
;			;
;			IfErrors 0 NO_ERROR
;				;MessageBox MB_OK "CopyFiles err"
;				Rename "$R0\$R1" "$R2\$R1"
;NO_ERROR:
;	Return
;FunctionEnd

Function un.CheckAndRenameFile
	IfFileExists "$R2\$R1" 0 NO_ERROR
		GetTempFileName $VAR_TEMP_2
		Delete $VAR_TEMP_2
		Rename "$R2\$R1" "$VAR_TEMP_2"
NO_ERROR:
	Return
FunctionEnd

;--------------------------------
; 安装初始化
;--------------------------------
Function .onInit
	SetOverwrite try

;----------------------------------------------------------------
	; 只有一个运行实例
	;----------------------------------------------------------------
 	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "${PRODUCT_GUID}_InstallMutex") i .r1 ?e'
 	Pop $R0

	StrCmp $R0 0 +3
  	MessageBox MB_OK|MB_ICONEXCLAMATION $(STR_CHECK_MUTEX) /SD IDOK
   		Abort

	StrCpy $0 "$SYSDIR"
	${If} ${RunningX64}
		System::Call "kernel32::GetSystemWow64Directory(t .r0, i ${NSIS_MAX_STRLEN})"
	${EndIf}
	StrCpy $VAR_TEMP_SYSWOW64 $0
	;----------------------------------------------------------------
	; 检查是否需要重新启动计算机
	;----------------------------------------------------------------

	;----------------------------------------------------------------
	; 检查是否是管理员操作的
	; 安装时要检查是否为管理员权限
	;----------------------------------------------------------------
	ClearErrors
	UserInfo::GetName
	IfErrors OnWin9X
	goto OnInitOk
;	Pop $0
;	UserInfo::GetAccountType
;	Pop $1
;	StrCmp $1 "Admin" OnInitOk OnInitErr

	;----------------------------------------------------------------
	;;调试日志
	;;MessageBox MB_OK "test onInit11"
	;----------------------------------------------------------------

OnInitErr:
	MessageBox MB_OK $(STR_CHECK_ADMIN) /SD IDOK
	Abort

OnWin9X:
	Abort

    ; We create shortcuts to All users not Current User
OnInitOk:
	;SetShellVarContext all
	;Abort

	;------------------------------------
	; 检查操作系统版本
	; 支持的最低操作系统是win2000
	;------------------------------------
	${If} ${AtLeastWin2000}
	${Else}
		MessageBox MB_OK $(STR_CHECK_OSVER) /SD IDOK
		Abort
	${EndIf}

	;------------------------------------
	; 检测旧版本
	; 调用旧版本的卸载程序卸载旧版本，并且提示用户安装新版本
	;------------------------------------
	;读取版本号,失败-没有安装过。 成功比较版本
	ClearErrors

	ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_GUID}" "Version"

	StrCmp $R0 "" Label_NotInstalled +1
	StrCpy $R1 "${FILE_VER}"

	;读取卸载字符串，如果不存在，说明安装的不全
	ReadRegStr $VAR_TEMP_0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_GUID}" "UninstallString"
	StrCmp $VAR_TEMP_0 "" +1 Label_Isinstalled
	goto Label_NotInstalled

Label_Isinstalled:
	;比较版本，如果判断需要升级，提示用户卸载旧版本
	;相等则提示是否卸载，已经安装更新的产品提示“已经安装”

	;VersionCompareUage:0(=),1(>),2(<)
	;;${VersionCompare} "[Version1]" "[Version2]" $var
	;;"[Version1]"        ; First version
	;;"[Version2]"        ; Second version
	;;$var                ; Result:
	;;                    ;    $var=0  Versions are equal
	;;                    ;    $var=1  Version1(installed) is newer
	;;                    ;    $var=2  Version2(current setup) is newer
	${VersionCompare} $R0 $R1 $R2

	;;;IntCmp val1 val2 jump_if_equal [jump_if_val1_less] [jump_if_val1_more]:( =, < , >)
	IntCmp $R2 1 Label_NewVerInstalled Label_EquVerInstalled Label_OldVerInstalled

Label_OldVerInstalled:
	MessageBox MB_YESNO|MB_ICONQUESTION $(STR_CHECK_OLDVER) /SD IDOK IDNO label_AbortInstall
		Exec $VAR_TEMP_0
	goto label_AbortInstall

Label_EquVerInstalled:
	MessageBox MB_YESNO|MB_ICONQUESTION $(STR_CHECK_EQUVER) /SD IDNO IDNO label_AbortInstall
		Exec $VAR_TEMP_0
	goto label_AbortInstall

Label_NewVerInstalled:
	goto label_AbortInstall

Label_AbortInstall:
	abort
Label_NotInstalled:

FunctionEnd

;=================================================================
; 安装:
;=================================================================
Section

	ClearErrors

	CreateDirectory "$INSTDIR"

	WriteUninstaller "$INSTDIR\uninst.exe"

	WriteRegStr HKLM "${TARGET_REG_BASE}" "Path" $INSTDIR
	WriteRegStr HKLM "${TARGET_REG_BASE}" "Version" ${FILE_VER}

	WriteRegStr HKLM "${TARGET_REG_BASE}" "${MUI_LANGDLL_REGISTRY_VALUENAME}" $LANGUAGE

	Call InstSoft

	; uninstall strings
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_GUID}" "DisplayName" $(STR_UNINSTALL_DISPLAY_NAME)
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_GUID}" "UninstallString" '"$INSTDIR\uninst.exe"'
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_GUID}" "Publisher" ${COMPANY_NAME}
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_GUID}" "URLInfoAbout" ${PRODUCT_WEBSITE}
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_GUID}" "DisplayIcon" '"$INSTDIR\${PFNAME_ASSIST}.exe"'
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_GUID}" "DisplayVersion" ${FILE_VER}
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_GUID}" "Version" ${FILE_VER}
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_GUID}" "NoModify" 0x00000001

SectionEnd

;--------------------------------
; 卸载初始化
;--------------------------------
Function un.onInit
	ReadRegStr $LANGUAGE HKLM "${TARGET_REG_BASE}" "InstallLanguageId"

	;----------------------------------------------------------------
	; 只有一个运行实例
	;----------------------------------------------------------------

!ifdef UNINSTALL_COMPONENTS
	MessageBox MB_YESNO|MB_ICONQUESTION $(un.STR_UNINSTALL_COMPONENTS) IDYES true IDNO false
	false:
   		Abort
	true:
!endif

 	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "${PRODUCT_GUID}_UninstallMutex") i .r1 ?e'
 	Pop $R0

	StrCmp $R0 0 +3
  	MessageBox MB_OK|MB_ICONEXCLAMATION $(un.STR_CHECK_MUTEX)
   	Abort

	StrCpy $0 "$SYSDIR"
	${If} ${RunningX64}
		System::Call "kernel32::GetSystemWow64Directory(t .r0, i ${NSIS_MAX_STRLEN})"
	${EndIf}
	StrCpy $VAR_TEMP_SYSWOW64 $0

	Push $R0
	Push $R1

	ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
	;----------------------------------------------------------------
	; 检查是否是管理员操作的
	;----------------------------------------------------------------
	ClearErrors
	UserInfo::GetName
	IfErrors OnWin9X
	Pop $0
	UserInfo::GetAccountType
	Pop $1
	StrCmp $1 "Admin" OnInitOk OnInitErr

	OnInitErr:
	MessageBox MB_OK $(un.STR_CHECK_ADMIN)
	Abort

	OnWin9X:
	;Abort

    ; We create shortcuts to All users not Current User
	OnInitOk:
	;SetShellVarContext all
	;Abort
FunctionEnd

;=================================================================
; 卸载:
;=================================================================
Section "Uninstall"
	;------------------------------------
	; 1: 卸载
	;------------------------------------
	SetOutPath $TEMP
	Call un.InstSoft

	;------------------------------------
	; 2: 删除注册表及目录
	;删除注册表先删除本产品的子节点TARGET_REG_BASE，然后尝试删除空的根节点TARGET_REG_ROOT
	;------------------------------------
	DeleteRegKey HKLM "${TARGET_REG_BASE}"
	DeleteRegKey /ifempty HKLM "${TARGET_REG_ROOT}"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_GUID}"

	Delete "$INSTDIR\uninst.exe"
	Sleep 1000
	; Loop to remove the $INSTDIR.
	RMDir /r $INSTDIR

	Sleep 1000
	GetFullPathName $VAR_TEMP_0 "$INSTDIR\.."
	RMDir $VAR_TEMP_0

	;Sleep 1000
	;RMDir /r "$APPDATA\eomsoft\teleport\assist"
	;Sleep 1000
	;RMDir "$APPDATA\eomsoft\teleport"
	;Sleep 1000
	;RMDir "$APPDATA\eomsoft"
SectionEnd

;-------------------------------------------------
; 安装
;-------------------------------------------------
Function InstSoft
	;SetOutPath "$APPDATA\eomsoft\teleport\assist\cfg"
	;File /r ${SRC_CFG_PATH}\*

	SetOutPath "$INSTDIR"
	File /r ${SRC_APPS_PATH}\*

	;Create shortcuts
	CreateShortCut "$DESKTOP\$(STR_DESKTOP_LINK_ASSIST).lnk" "$INSTDIR\${PFNAME_ASSIST}.exe"

	CreateDirectory "${START_MENU_ROOT}"
	Sleep 1000

	CreateDirectory "${START_MENU_BASE}"
	CreateShortCut "${START_MENU_BASE}\$(STR_STARTMENU_LINK_ASSIST).lnk" "$INSTDIR\${PFNAME_ASSIST}.exe"
	CreateShortCut "${START_MENU_BASE}\$(STR_LINK_UNINSTALLER).lnk" "$INSTDIR\uninst.exe"

	${If} ${RunningX64}
	SetRegView 64
	${EndIf}

	; 不要判断此处的返回值，可能无写入权限（即使是管理员身份运行）。
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "${PRODUCT_NAME_DESC}" "$\"$INSTDIR\${PFNAME_ASSIST}.exe$\""

	${If} ${RunningX64}
	SetRegView 32
	${EndIf}

	; start the assist.
	Exec "$INSTDIR\${PFNAME_ASSIST}.exe"
FunctionEnd

;-------------------------------------------------
; 卸载
;-------------------------------------------------
Function un.InstSoft

	ExecWait "$INSTDIR\${PFNAME_ASSIST}.exe --stop"

	;;尝试删除，失败则修改名称删除
	Sleep 2000
	ClearErrors
	Delete "$INSTDIR\${PFNAME_ASSIST}.exe"
	Sleep 100
	IfErrors 0 ON_ERROR_DEL_ASSIST
	StrCpy $R2 $INSTDIR
	StrCpy $R1 "${PFNAME_ASSIST}.exe"
	Call un.CheckAndRenameFile

ON_ERROR_DEL_ASSIST:
	ClearErrors

	DeleteRegValue HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Run\" "${PRODUCT_NAME_DESC}"

	Delete "${START_MENU_BASE}\$(STR_LINK_UNINSTALLER).lnk"
	Delete "${START_MENU_BASE}\$(STR_STARTMENU_LINK_ASSIST).lnk"

	Delete "$DESKTOP\$(STR_DESKTOP_LINK_ASSIST).lnk"

	Sleep 1000
	RMDir /r "${START_MENU_BASE}"

	Sleep 1000
	RMDir "${START_MENU_ROOT}"

FunctionEnd


;EOF
