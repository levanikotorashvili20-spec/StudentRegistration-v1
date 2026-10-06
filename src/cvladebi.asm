; ============================================================
; cvladebi.asm — ცვლადები, ჰენდლები, კონტროლების ID-ები
; ============================================================

; ---------- ფანჯრის ზომები (96 DPI-ზე, მასშტაბირდება) ----------
SAWYISI_SIGANE  equ 1180            ; საწყისი ზომა
SAWYISI_SIMAGLE equ 640
MIN_SIGANE      equ 1060            ; ამაზე პატარა ვერ გახდება
MIN_SIMAGLE     equ 620

; ---------- რესურსები (app.rc) ----------
IDI_APP         equ 1               ; პროგრამის აიქონი

; ---------- კონტროლების ID-ები ----------
IDC_LANG        equ 100             ; ენის გადამრთველი

; რეგისტრაციის ფორმა
IDC_SAXELI      equ 101
IDC_GVARI       equ 102
IDC_MAMIS       equ 103
IDC_DAB         equ 104             ; დაბადების თარიღი
IDC_ASAKI       equ 105             ; ასაკი (ავტომატურად)
IDC_MOQ         equ 106             ; მოქალაქეობა
IDC_PIRADI      equ 107
IDC_QVEYANA     equ 108
IDC_REGIONI     equ 109
IDC_QALAQI      equ 110
IDC_QUCHA       equ 111
IDC_SAXLI       equ 112
IDC_BINA        equ 113
IDC_INDEKSI     equ 114
IDC_TELKODI     equ 115             ; +995 (ქვეყნის მიხედვით)
IDC_MOB         equ 116
IDC_EMAIL       equ 117
IDC_GPA         equ 118
IDC_SLASH       equ 119
IDC_GPA_SKALA   equ 120
IDC_START       equ 121             ; სწავლის დაწყება
IDC_END         equ 122             ; სწავლის დასრულება
IDC_REGISTRACIA equ 130
IDC_GASUFTAVEBA equ 131
IDC_WASHLA      equ 132             ; წაშლა (მხოლოდ რედაქტირებისას ჩანს)

; ძებნის პანელი
IDC_DZ_JGUFI    equ 140
IDC_DZ_MOQ      equ 141
IDC_DZ_PIRADI   equ 142
IDC_DZ_GHILAKI  equ 143
IDC_DZ_WASHLA   equ 144             ; მონიშნული შედეგის წაშლა
IDC_SIA         equ 150             ; შედეგების ცხრილი

.data
ena             dd 0                ; 0 = ქართული, 1 = English
dpi             dd 96               ; ეკრანის მასშტაბი (96 = 100%)

WSTR szClass,   <StudentRegWnd>
WSTR szStatic,  <STATIC>
WSTR szEdit,    <EDIT>
WSTR szButton,  <BUTTON>
WSTR szCombo,   <COMBOBOX>
WSTR szDate,    <SysDateTimePick32>
WSTR szList,    <SysListView32>
WSTR szFont,    <Segoe UI>
WSTR szTelKodi, <+995>
WSTR szSlash,   </>
szCarieli       dw 0                ; ცარიელი UTF-16 სტრიქონი

.data?
hInstance       dd ?
hMainWnd        dd ?
hFont           dd ?
min_sigane      dd ?                ; ფანჯრის მინიმალური ზომა (პიქსელებში)
min_simagle     dd ?
wbuf            dw 512 dup(?)       ; UTF-16 ბუფერი (UTF-8 -> UTF-16 გადაყვანისთვის)
