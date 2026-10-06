; ============================================================
; ui.asm — ფანჯრის კონტროლები: ცხრილი, შექმნა, განლაგება
;
; ყველა კონტროლი აღწერილია ერთ ცხრილში (kontrolebi).
; create_controls ერთი ციკლით ქმნის ყველას, apply_language
; (ena.asm) იმავე ცხრილით ცვლის წარწერებს.
; ახალი ველი = ცხრილში ახალი ხაზი.
;
; კოორდინატები ჩაწერილია 96 DPI-ზე (100% მასშტაბი);
; masshtabi მათ ეკრანის რეალურ მასშტაბზე ამრავლებს.
; ============================================================

; ---------- ცხრილის ერთი ხაზი ----------
CTL STRUCT
    k_klasi     DWORD ?     ; კლასის სახელი (UTF-16 სტრიქონის მისამართი)
    k_stili     DWORD ?     ; სტილი (WS_...)
    k_exstili   DWORD ?     ; გაფართოებული სტილი (WS_EX_...)
    k_x         DWORD ?
    k_y         DWORD ?
    k_w         DWORD ?
    k_h         DWORD ?
    k_id        DWORD ?     ; კონტროლის ID
    k_teqsti    DWORD ?     ; წარწერის T_ ნომერი, ან NO_TEXT
CTL ENDS

; ---------- განლაგება ----------
; ყველა კოორდინატი ამ ოთხ რიცხვზეა მიბმული: თუ წარწერა არ ეტევა,
; საკმარისია LW-ს გაზრდა და დანარჩენი თავისით გადაიწევს.
LX  = 16                    ; წარწერების x (მარცხენა სვეტი)
LW  = 180                   ; წარწერების სიგანე
IX  = LX + LW + 6           ; ველების x
IW  = 270                   ; ველების სიგანე
PX  = IX + IW + 20          ; მარჯვენა პანელის x

; ---------- სტილები ----------
ST_LABEL     = WS_CHILD or WS_VISIBLE or SS_LEFT or SS_CENTERIMAGE
ST_CENTER    = WS_CHILD or WS_VISIBLE or SS_CENTER or SS_CENTERIMAGE
ST_EDIT      = WS_CHILD or WS_VISIBLE or WS_TABSTOP or ES_AUTOHSCROLL
ST_EDITNUM   = ST_EDIT or ES_NUMBER
ST_LIST      = WS_CHILD or WS_VISIBLE or WS_TABSTOP or WS_VSCROLL or CBS_DROPDOWNLIST
ST_COMBO     = WS_CHILD or WS_VISIBLE or WS_TABSTOP or WS_VSCROLL or CBS_DROPDOWN or CBS_AUTOHSCROLL
ST_DATE      = WS_CHILD or WS_VISIBLE or WS_TABSTOP
ST_DATE_NONE = ST_DATE or DTS_SHOWNONE
ST_BTN       = WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_PUSHBUTTON
ST_BTN_DAMALULI = WS_CHILD or WS_TABSTOP or BS_PUSHBUTTON     ; თავიდან დამალული
ST_BTN_GATISHULI = ST_BTN or WS_DISABLED                     ; თავიდან გამორთული
ST_GROUP     = WS_CHILD or WS_VISIBLE or BS_GROUPBOX
ST_LV        = WS_CHILD or WS_VISIBLE or WS_TABSTOP or LVS_REPORT or LVS_SINGLESEL or LVS_SHOWSELALWAYS
EX_EDGE      = WS_EX_CLIENTEDGE
NO_TEXT      = -1

.data
;            კლასი            სტილი         ex       x    y    w    h    ID               წარწერა
kontrolebi LABEL CTL
; ---------- რეგისტრაციის ფორმა (მარცხნივ) ----------
CTL <offset szStatic, ST_LABEL,     0,       LX,      16, LW,     26,  201,             T_SAXELI>
CTL <offset szEdit,   ST_EDIT,      EX_EDGE, IX,      16, IW,     26,  IDC_SAXELI,      NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,      48, LW,     26,  202,             T_GVARI>
CTL <offset szEdit,   ST_EDIT,      EX_EDGE, IX,      48, IW,     26,  IDC_GVARI,       NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,      80, LW,     26,  203,             T_MAMIS_SAXELI>
CTL <offset szEdit,   ST_EDIT,      EX_EDGE, IX,      80, IW,     26,  IDC_MAMIS,       NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     112, LW,     26,  204,             T_DAB_TARIGHI>
CTL <offset szDate,   ST_DATE,      0,       IX,     112, 140,    26,  IDC_DAB,         NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       IX+150, 112, 56,     26,  205,             T_ASAKI>
CTL <offset szStatic, ST_LABEL,     0,       IX+208, 112, IW-208, 26,  IDC_ASAKI,       NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     144, LW,     26,  206,             T_MOQALAQEOBA>
CTL <offset szCombo,  ST_LIST,      0,       IX,     144, IW,     300, IDC_MOQ,         NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     176, LW,     26,  207,             T_PIRADI>
CTL <offset szEdit,   ST_EDIT,      EX_EDGE, IX,     176, IW,     26,  IDC_PIRADI,      NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     208, LW,     26,  208,             T_QVEYANA>
CTL <offset szCombo,  ST_LIST,      0,       IX,     208, IW,     300, IDC_QVEYANA,     NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     240, LW,     26,  209,             T_REGIONI>
CTL <offset szCombo,  ST_LIST,      0,       IX,     240, IW,     300, IDC_REGIONI,     NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     272, LW,     26,  210,             T_QALAQI>
CTL <offset szCombo,  ST_COMBO,     0,       IX,     272, IW,     300, IDC_QALAQI,      NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     304, LW,     26,  211,             T_QUCHA>
CTL <offset szEdit,   ST_EDIT,      EX_EDGE, IX,     304, IW,     26,  IDC_QUCHA,       NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     336, LW,     26,  212,             T_SAXLI_BINA>
CTL <offset szEdit,   ST_EDIT,      EX_EDGE, IX,     336, 127,    26,  IDC_SAXLI,       NO_TEXT>
CTL <offset szEdit,   ST_EDIT,      EX_EDGE, IX+143, 336, 127,    26,  IDC_BINA,        NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     368, LW,     26,  213,             T_INDEKSI>
CTL <offset szEdit,   ST_EDIT,      EX_EDGE, IX,     368, 127,    26,  IDC_INDEKSI,     NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     400, LW,     26,  214,             T_MOBILURI>
CTL <offset szStatic, ST_LABEL,     0,       IX,     400, 50,     26,  IDC_TELKODI,     NO_TEXT>
CTL <offset szEdit,   ST_EDITNUM,   EX_EDGE, IX+54,  400, IW-54,  26,  IDC_MOB,         NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     432, LW,     26,  215,             T_EMAIL>
CTL <offset szEdit,   ST_EDIT,      EX_EDGE, IX,     432, IW,     26,  IDC_EMAIL,       NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     464, LW,     26,  216,             T_GPA>
CTL <offset szEdit,   ST_EDIT,      EX_EDGE, IX,     464, 90,     26,  IDC_GPA,         NO_TEXT>
CTL <offset szStatic, ST_CENTER,    0,       IX+94,  464, 16,     26,  IDC_SLASH,       NO_TEXT>
CTL <offset szCombo,  ST_LIST,      0,       IX+114, 464, 90,     300, IDC_GPA_SKALA,   NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     496, LW,     26,  217,             T_SWAVLA_START>
CTL <offset szDate,   ST_DATE,      0,       IX,     496, 140,    26,  IDC_START,       NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       LX,     528, LW,     26,  218,             T_SWAVLA_END>
CTL <offset szDate,   ST_DATE_NONE, 0,       IX,     528, 140,    26,  IDC_END,         NO_TEXT>
CTL <offset szButton, ST_BTN,       0,       IX,     572, 130,    32,  IDC_REGISTRACIA, T_REGISTRACIA>
CTL <offset szButton, ST_BTN,       0,       IX+140, 572, 130,    32,  IDC_GASUFTAVEBA, T_GASUFTAVEBA>
CTL <offset szButton, ST_BTN_DAMALULI, 0,    LX,     572, 130,    32,  IDC_WASHLA,      T_WASHLA>
; ---------- ძებნა (მარჯვნივ) ----------
CTL <offset szButton, ST_GROUP,     0,       PX,       8, 436,    104, IDC_DZ_JGUFI,    T_DZEBNA>
CTL <offset szStatic, ST_LABEL,     0,       PX+16,   34, 150,    26,  219,             T_MOQALAQEOBA>
CTL <offset szCombo,  ST_LIST,      0,       PX+170,  34, 150,    300, IDC_DZ_MOQ,      NO_TEXT>
CTL <offset szStatic, ST_LABEL,     0,       PX+16,   68, 150,    26,  220,             T_PIRADI>
CTL <offset szEdit,   ST_EDIT,      EX_EDGE, PX+170,  68, 150,    26,  IDC_DZ_PIRADI,   NO_TEXT>
CTL <offset szButton, ST_BTN_GATISHULI, 0,   PX+330,  32, 90,     30,  IDC_DZ_WASHLA,   T_WASHLA>
CTL <offset szButton, ST_BTN,       0,       PX+330,  66, 90,     30,  IDC_DZ_GHILAKI,  T_DZEBNA>
CTL <offset szList,   ST_LV,        EX_EDGE, PX,     124, 600,    500, IDC_SIA,         NO_TEXT>
CTL <offset szButton, ST_BTN,       0,       SAWYISI_SIGANE-116, 14, 100, 30, IDC_LANG, T_ENA_GHILAKI>
kontrolebi_raod = ($ - kontrolebi) / SIZEOF CTL

; ---------- შედეგების ცხრილის სვეტები ----------
SV_RAOD = 5
sv_siganeebi    dd 160, 110, 130, 140, 70
sv_teqstebi     dd T_PIRADI, T_SAXELI, T_GVARI, T_QALAQI, T_GPA

; ---------- GPA-ს სკალები ----------
WSTR szSk4,   <4>
WSTR szSk5,   <5>
WSTR szSk10,  <10>
WSTR szSk20,  <20>
WSTR szSk100, <100>
SK_RAOD = 5
skalebi         dd szSk4, szSk5, szSk10, szSk20, szSk100

.code

; ------------------------------------------------------------
; masshtabi — 96 DPI-ის მნიშვნელობა -> ეკრანის რეალური პიქსელები
; eax = v * dpi / 96
; ------------------------------------------------------------
masshtabi PROC v:DWORD
    invoke MulDiv, v, dpi, 96
    ret
masshtabi ENDP

; ------------------------------------------------------------
; fanjris_zoma — კლიენტის ზომიდან (96 DPI) ფანჯრის სრული ზომა
; (სათაურის ზოლით და ჩარჩოთი)
; შედეგი: eax = სიგანე, edx = სიმაღლე
; ------------------------------------------------------------
fanjris_zoma PROC kw_:DWORD, kh_:DWORD
    LOCAL rc:RECT

    mov rc.left, 0
    mov rc.top, 0
    invoke masshtabi, kw_
    mov rc.right, eax
    invoke masshtabi, kh_
    mov rc.bottom, eax
    invoke AdjustWindowRectEx, addr rc, WS_OVERLAPPEDWINDOW, FALSE, 0
    mov eax, rc.right
    sub eax, rc.left
    mov edx, rc.bottom
    sub edx, rc.top
    ret
fanjris_zoma ENDP

; ------------------------------------------------------------
; create_controls — ცხრილიდან ყველა კონტროლის შექმნა
; ------------------------------------------------------------
create_controls PROC USES esi edi ebx, hWnd:DWORD
    LOCAL kx:DWORD, ky:DWORD, kw:DWORD, kh:DWORD
    LOCAL lvc:LVCOLUMNW

    ; შრიფტი: Segoe UI, ზომა ეკრანის მასშტაბის მიხედვით
    invoke masshtabi, 16
    neg eax
    invoke CreateFontW, eax, 0, 0, 0, FW_NORMAL, 0, 0, 0, \
           DEFAULT_CHARSET, 0, 0, CLEARTYPE_QUALITY, 0, offset szFont
    mov hFont, eax

    ; ---- ყველა კონტროლი ცხრილიდან ----
    mov esi, offset kontrolebi
    mov edi, kontrolebi_raod
kc_cikli:
    invoke masshtabi, [esi].CTL.k_x
    mov kx, eax
    invoke masshtabi, [esi].CTL.k_y
    mov ky, eax
    invoke masshtabi, [esi].CTL.k_w
    mov kw, eax
    invoke masshtabi, [esi].CTL.k_h
    mov kh, eax
    invoke CreateWindowExW, [esi].CTL.k_exstili, [esi].CTL.k_klasi, NULL, \
           [esi].CTL.k_stili, kx, ky, kw, kh, \
           hWnd, [esi].CTL.k_id, hInstance, NULL
    invoke SendMessageW, eax, WM_SETFONT, hFont, TRUE
    add esi, SIZEOF CTL
    dec edi
    jnz kc_cikli

    ; ---- შედეგების ცხრილი: მთლიანი სტრიქონის მონიშვნა, ბადე ----
    invoke GetDlgItem, hWnd, IDC_SIA
    mov ebx, eax
    invoke SendMessageW, ebx, LVM_SETEXTENDEDLISTVIEWSTYLE, \
           LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES or LVS_EX_DOUBLEBUFFER, \
           LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES or LVS_EX_DOUBLEBUFFER

    ; სვეტები: ფორმატით და ცარიელი ტექსტით, რომ სათაურმა ტექსტი
    ; დახატოს (თვითონ ტექსტს apply_language წერს)
    lea edi, lvc                    ; სტრუქტურის განულება
    xor eax, eax
    mov ecx, SIZEOF LVCOLUMNW / 4
    rep stosd
    xor edi, edi
sv_cikli:
    mov lvc.imask, LVCF_FMT or LVCF_WIDTH or LVCF_TEXT or LVCF_SUBITEM
    mov lvc.fmt, LVCFMT_LEFT
    mov lvc.pszText, offset szCarieli
    invoke masshtabi, sv_siganeebi[edi*4]
    mov lvc.lx, eax
    mov lvc.iSubItem, edi
    invoke SendMessageW, ebx, LVM_INSERTCOLUMNW, edi, addr lvc
    inc edi
    cmp edi, SV_RAOD
    jb sv_cikli

    ; ---- GPA-ს სკალები ----
    invoke GetDlgItem, hWnd, IDC_GPA_SKALA
    mov ebx, eax
    xor edi, edi
sk_cikli:
    invoke SendMessageW, ebx, CB_ADDSTRING, 0, skalebi[edi*4]
    inc edi
    cmp edi, SK_RAOD
    jb sk_cikli
    invoke SendMessageW, ebx, CB_SETCURSEL, 0, 0

    ; ---- ენაზე დამოუკიდებელი წარწერები ----
    invoke GetDlgItem, hWnd, IDC_TELKODI
    invoke SetWindowTextW, eax, offset szTelKodi
    invoke GetDlgItem, hWnd, IDC_SLASH
    invoke SetWindowTextW, eax, offset szSlash
    ret
create_controls ENDP

; ------------------------------------------------------------
; gadaadgile — კონტროლის გადატანა/ზომის შეცვლა ID-ით
; (კოორდინატები უკვე მასშტაბირებულია)
; ------------------------------------------------------------
gadaadgile PROC id_:DWORD, x_:DWORD, y_:DWORD, w_:DWORD, h_:DWORD
    invoke GetDlgItem, hMainWnd, id_
    invoke MoveWindow, eax, x_, y_, w_, h_, TRUE
    ret
gadaadgile ENDP

; ------------------------------------------------------------
; on_size — WM_SIZE: ფანჯრის ზომა შეიცვალა
; ფორმა ადგილზე რჩება, იცვლება მხოლოდ:
;   - ენის ღილაკი (მიჰყვება მარჯვენა კიდეს)
;   - შედეგების ცხრილი (ავსებს დარჩენილ ადგილს)
; ------------------------------------------------------------
on_size PROC USES esi edi, lParam:DWORD
    LOCAL sigane:DWORD, simagle:DWORD
    LOCAL tx:DWORD, ty:DWORD, tw:DWORD

    mov eax, lParam
    movzx ecx, ax                   ; ქვედა 16 ბიტი: სიგანე
    mov sigane, ecx
    shr eax, 16                     ; ზედა 16 ბიტი: სიმაღლე
    mov simagle, eax
    cmp sigane, 0                   ; ჩაკეცილი ფანჯარა: არაფერს ვაკეთებთ
    je os_dasasruli

    ; ---- ენის ღილაკი ----
    invoke masshtabi, 116
    mov ecx, sigane
    sub ecx, eax
    mov tx, ecx
    invoke masshtabi, 14
    mov ty, eax
    invoke masshtabi, 100
    mov tw, eax
    invoke masshtabi, 30
    invoke gadaadgile, IDC_LANG, tx, ty, tw, eax

    ; ---- შედეგების ცხრილი ----
    invoke masshtabi, PX
    mov esi, eax                    ; x
    invoke masshtabi, 124
    mov ty, eax                     ; y
    invoke masshtabi, 16
    mov edi, eax                    ; დაშორება კიდიდან
    mov ecx, sigane
    sub ecx, esi
    sub ecx, edi
    mov tw, ecx                     ; სიგანე
    mov ecx, simagle
    sub ecx, ty
    sub ecx, edi                    ; სიმაღლე
    invoke gadaadgile, IDC_SIA, esi, ty, tw, ecx

os_dasasruli:
    ret
on_size ENDP
