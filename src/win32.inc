; ============================================================
; win32.inc — Windows API-ს აღწერები
; მხოლოდ ის, რაც ამ პროექტს სჭირდება. MASM32 SDK არ გვჭირდება:
; პროექტი აიწყობა ნებისმიერ კომპიუტერზე, სადაც Visual Studio-ა.
; ============================================================

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib comctl32.lib

; ---------- ზოგადი ----------
NULL                equ 0
TRUE                equ 1
FALSE               equ 0
CP_UTF8             equ 65001

; ---------- ფანჯრის სტილები ----------
WS_OVERLAPPED       equ 00000000h
WS_CAPTION          equ 00C00000h
WS_SYSMENU          equ 00080000h
WS_THICKFRAME       equ 00040000h
WS_MINIMIZEBOX      equ 00020000h
WS_MAXIMIZEBOX      equ 00010000h
WS_OVERLAPPEDWINDOW equ WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX
WS_CHILD            equ 40000000h
WS_VISIBLE          equ 10000000h
WS_VSCROLL          equ 00200000h
WS_TABSTOP          equ 00010000h
WS_DISABLED         equ 08000000h
WS_EX_CLIENTEDGE    equ 00000200h

; ---------- კონტროლების სტილები ----------
BS_PUSHBUTTON       equ 00000000h
BS_GROUPBOX         equ 00000007h
SS_LEFT             equ 00000000h
SS_CENTER           equ 00000001h
SS_CENTERIMAGE      equ 00000200h
ES_AUTOHSCROLL      equ 00000080h
ES_NUMBER           equ 00002000h
CBS_DROPDOWN        equ 00000002h
CBS_DROPDOWNLIST    equ 00000003h
CBS_AUTOHSCROLL     equ 00000040h
DTS_SHOWNONE        equ 00000002h
LVS_REPORT          equ 00000001h
LVS_SINGLESEL       equ 00000004h
LVS_SHOWSELALWAYS   equ 00000008h

; ---------- ComboBox / ListView შეტყობინებები ----------
CB_ADDSTRING                    equ 0143h
CB_GETCURSEL                    equ 0147h
CB_RESETCONTENT                 equ 014Bh
CB_SETCURSEL                    equ 014Eh
CB_GETCOUNT                     equ 0146h
CB_FINDSTRINGEXACT              equ 0158h
CB_GETITEMDATA                  equ 0150h
CB_SETITEMDATA                  equ 0151h
CBN_SELCHANGE                   equ 1
CB_ERR                          equ -1
LVM_SETEXTENDEDLISTVIEWSTYLE    equ 1036h
LVM_SETCOLUMNW                  equ 1060h
LVM_INSERTCOLUMNW               equ 1061h
LVS_EX_GRIDLINES                equ 00000001h
LVS_EX_FULLROWSELECT            equ 00000020h
LVS_EX_DOUBLEBUFFER             equ 00010000h
LVCF_FMT                        equ 0001h
LVCF_WIDTH                      equ 0002h
LVCF_TEXT                       equ 0004h
LVCF_SUBITEM                    equ 0008h
LVM_DELETEALLITEMS              equ 1009h
LVM_INSERTITEMW                 equ 104Dh
LVM_SETITEMTEXTW                equ 1074h
LVIF_TEXT                       equ 0001h
LVIF_PARAM                      equ 0004h
LVM_GETNEXTITEM                 equ 100Ch
LVM_GETITEMW                    equ 104Bh
LVM_DELETEITEM                  equ 1008h
LVM_FINDITEMW                   equ 1053h
LVFI_PARAM                      equ 0001h
LVNI_SELECTED                   equ 0002h
NM_DBLCLK                       equ -3
NM_RCLICK                       equ -5              ; მარჯვენა ღილაკი
LVN_KEYDOWN                     equ -155            ; კლავიში ცხრილში
LVN_ITEMCHANGED                 equ -101            ; მონიშვნა შეიცვალა
LVM_GETSELECTEDCOUNT            equ 1032h
VK_DELETE                       equ 2Eh
MF_STRING                       equ 0
TPM_RIGHTBUTTON                 equ 0002h
TPM_RETURNCMD                   equ 0100h
LVCFMT_LEFT                     equ 0000h

; ---------- Common Controls ----------
ICC_LISTVIEW_CLASSES    equ 00000001h
ICC_DATE_CLASSES        equ 00000100h
ICC_STANDARD_CLASSES    equ 00004000h

; ---------- სხვადასხვა ----------
CW_USEDEFAULT       equ 80000000h
SW_SHOWNORMAL       equ 1
SW_HIDE             equ 0
SW_SHOW             equ 5
COLOR_BTNFACE       equ 15
IDC_ARROW           equ 32512
IDI_APPLICATION     equ 32512
LOGPIXELSX          equ 88
IMAGE_ICON          equ 1
LR_DEFAULTCOLOR     equ 0
SM_CXSMICON         equ 49
SM_CYSMICON         equ 50
MAX_PATH            equ 260
INVALID_FILE_ATTRIBUTES equ -1
MB_ICONERROR        equ 00000010h
MB_ICONWARNING      equ 00000030h
MB_ICONINFORMATION  equ 00000040h
MB_ICONQUESTION     equ 00000020h
MB_YESNO            equ 00000004h
IDYES               equ 6
DTM_GETSYSTEMTIME   equ 1001h
DTM_SETSYSTEMTIME   equ 1002h
GDT_VALID           equ 0
GDT_NONE            equ 1

; ---------- შეტყობინებები ----------
WM_CREATE           equ 0001h
WM_DESTROY          equ 0002h
WM_SIZE             equ 0005h
WM_GETMINMAXINFO    equ 0024h
WM_SETFONT          equ 0030h
WM_COMMAND          equ 0111h
WM_NOTIFY           equ 004Eh
BN_CLICKED          equ 0
IDOK                equ 1               ; Enter (IsDialogMessage)

; ---------- შრიფტი ----------
FW_NORMAL           equ 400
DEFAULT_CHARSET     equ 1
CLEARTYPE_QUALITY   equ 5

; ---------- სტრუქტურები ----------
POINT STRUCT
    x               DWORD ?
    y               DWORD ?
POINT ENDS

RECT STRUCT
    left            DWORD ?
    top             DWORD ?
    right           DWORD ?
    bottom          DWORD ?
RECT ENDS

MSG STRUCT
    hwnd            DWORD ?
    message         DWORD ?
    wParam          DWORD ?
    lParam          DWORD ?
    time            DWORD ?
    pt              POINT <>
MSG ENDS

WNDCLASSEXW STRUCT
    cbSize          DWORD ?
    style           DWORD ?
    lpfnWndProc     DWORD ?
    cbClsExtra      DWORD ?
    cbWndExtra      DWORD ?
    hInstance       DWORD ?
    hIcon           DWORD ?
    hCursor         DWORD ?
    hbrBackground   DWORD ?
    lpszMenuName    DWORD ?
    lpszClassName   DWORD ?
    hIconSm         DWORD ?
WNDCLASSEXW ENDS

SYSTEMTIME STRUCT
    wYear           WORD ?
    wMonth          WORD ?
    wDayOfWeek      WORD ?
    wDay            WORD ?
    wHour           WORD ?
    wMinute         WORD ?
    wSecond         WORD ?
    wMilliseconds   WORD ?
SYSTEMTIME ENDS

NMHDR STRUCT
    hwndFrom        DWORD ?
    idFrom          DWORD ?
    nm_code         DWORD ?
NMHDR ENDS

MINMAXINFO STRUCT
    ptReserved      POINT <>
    ptMaxSize       POINT <>
    ptMaxPosition   POINT <>
    ptMinTrackSize  POINT <>
    ptMaxTrackSize  POINT <>
MINMAXINFO ENDS

LVITEMW STRUCT
    imask           DWORD ?     ; "mask" MASM-ში დაკავებული სიტყვაა
    iItem           DWORD ?
    iSubItem        DWORD ?
    state           DWORD ?
    stateMask       DWORD ?
    pszText         DWORD ?
    cchTextMax      DWORD ?
    iImage          DWORD ?
    lv_lParam       DWORD ?
    iIndent         DWORD ?
    iGroupId        DWORD ?
    cColumns        DWORD ?
    puColumns       DWORD ?
    piColFmt        DWORD ?
    iGroup          DWORD ?
LVITEMW ENDS

LVFINDINFOW STRUCT
    lf_flags        DWORD ?
    lf_psz          DWORD ?
    lf_lParam       DWORD ?
    lf_pt           POINT <>
    lf_vkDirection  DWORD ?
LVFINDINFOW ENDS

INITCOMMONCONTROLSEX STRUCT
    dwSize          DWORD ?
    dwICC           DWORD ?
INITCOMMONCONTROLSEX ENDS

LVCOLUMNW STRUCT
    imask           DWORD ?     ; "mask" MASM-ში დაკავებული სიტყვაა
    fmt             DWORD ?
    lx              DWORD ?     ; "cx" რეგისტრის სახელია
    pszText         DWORD ?
    cchTextMax      DWORD ?
    iSubItem        DWORD ?
    iImage          DWORD ?
    iOrder          DWORD ?
LVCOLUMNW ENDS

; ---------- kernel32 ----------
GetModuleHandleW    PROTO :DWORD
ExitProcess         PROTO :DWORD
MultiByteToWideChar PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
MulDiv              PROTO :DWORD, :DWORD, :DWORD
GetModuleFileNameW  PROTO :DWORD, :DWORD, :DWORD
GetFileAttributesW  PROTO :DWORD
lstrcpyW            PROTO :DWORD, :DWORD
lstrcatW            PROTO :DWORD, :DWORD
GetLocalTime        PROTO :DWORD

; ---------- user32 ----------
RegisterClassExW    PROTO :DWORD
CreateWindowExW     PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, \
                          :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ShowWindow          PROTO :DWORD, :DWORD
EnableWindow        PROTO :DWORD, :DWORD
UpdateWindow        PROTO :DWORD
GetMessageW         PROTO :DWORD, :DWORD, :DWORD, :DWORD
TranslateMessage    PROTO :DWORD
DispatchMessageW    PROTO :DWORD
IsDialogMessageW    PROTO :DWORD, :DWORD
DefWindowProcW      PROTO :DWORD, :DWORD, :DWORD, :DWORD
PostQuitMessage     PROTO :DWORD
LoadCursorW         PROTO :DWORD, :DWORD
LoadIconW           PROTO :DWORD, :DWORD
LoadImageW          PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
GetSystemMetrics    PROTO :DWORD
SetWindowTextW      PROTO :DWORD, :DWORD
GetWindowTextW      PROTO :DWORD, :DWORD, :DWORD
GetWindowTextLengthW PROTO :DWORD
SetFocus            PROTO :DWORD
GetFocus            PROTO
CreatePopupMenu     PROTO
AppendMenuW         PROTO :DWORD, :DWORD, :DWORD, :DWORD
TrackPopupMenu      PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
DestroyMenu         PROTO :DWORD
GetCursorPos        PROTO :DWORD
SendMessageW        PROTO :DWORD, :DWORD, :DWORD, :DWORD
GetDlgItem          PROTO :DWORD, :DWORD
MoveWindow          PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
AdjustWindowRectEx  PROTO :DWORD, :DWORD, :DWORD, :DWORD
SetProcessDPIAware  PROTO
GetDC               PROTO :DWORD
ReleaseDC           PROTO :DWORD, :DWORD
MessageBoxW         PROTO :DWORD, :DWORD, :DWORD, :DWORD

; ---------- gdi32 ----------
CreateFontW         PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, \
                          :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
GetDeviceCaps       PROTO :DWORD, :DWORD

; ---------- comctl32 ----------
InitCommonControlsEx PROTO :DWORD

; ---------- მაკრო: ASCII ტექსტი -> UTF-16 ----------
; კლასებისა და შრიფტის სახელებისთვის (მხოლოდ ლათინური ასოები!)
; გამოყენება:  WSTR szButton, <BUTTON>
WSTR MACRO lbl:REQ, txt:REQ
    lbl LABEL WORD
    FORC simb, <txt>
        dw '&simb'
    ENDM
    dw 0
ENDM
