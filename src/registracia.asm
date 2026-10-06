; ============================================================
; registracia.asm — სტუდენტის რეგისტრაცია:
;   ველების წაკითხვა და ბაზაში ჩაწერა, ფორმის გასუფთავება,
;   ასაკის გამოთვლა
; ============================================================

; ---------- ველის წყაროს ტიპები ----------
V_TEXT  = 1                 ; ტექსტი კონტროლიდან (ცარიელი -> NULL)
V_ISO   = 2                 ; ქვეყნის ISO კოდი სიიდან
V_DATE  = 3                 ; თარიღი (გამორთული -> NULL)
V_TEL   = 4                 ; სატელეფონო კოდი + ნომერი
V_LIST  = 5                 ; ჩამოსაშლელი სია: ინახება ტექსტი, იტვირთება ტექსტით არჩევა

.data
; INSERT: პარამეტრების რიგი (?1..?19) = reg_velebi ცხრილის რიგი
sqlChawera  db "INSERT INTO students (saxeli, gvari, mamis_saxeli, dab_tarighi, "
            db "moqalaqeoba, piradi_nomeri, qveyana, regioni, qalaqi, qucha, "
            db "saxlis_n, bina, indeksi, mob_nomeri, email, gpa, gpa_skala, "
            db "swavla_start, swavla_end) VALUES "
            db "(?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, "
            db "?11, ?12, ?13, ?14, ?15, ?16, ?17, ?18, ?19)", 0

;               ტიპი    კონტროლი            სვეტი
reg_velebi  dd V_TEXT, IDC_SAXELI       ; ?1  saxeli
            dd V_TEXT, IDC_GVARI        ; ?2  gvari
            dd V_TEXT, IDC_MAMIS        ; ?3  mamis_saxeli
            dd V_DATE, IDC_DAB          ; ?4  dab_tarighi
            dd V_ISO,  IDC_MOQ          ; ?5  moqalaqeoba
            dd V_TEXT, IDC_PIRADI       ; ?6  piradi_nomeri
            dd V_ISO,  IDC_QVEYANA      ; ?7  qveyana
            dd V_LIST, IDC_REGIONI      ; ?8  regioni
            dd V_TEXT, IDC_QALAQI       ; ?9  qalaqi
            dd V_TEXT, IDC_QUCHA        ; ?10 qucha
            dd V_TEXT, IDC_SAXLI        ; ?11 saxlis_n
            dd V_TEXT, IDC_BINA         ; ?12 bina
            dd V_TEXT, IDC_INDEKSI      ; ?13 indeksi
            dd V_TEL,  IDC_MOB          ; ?14 mob_nomeri
            dd V_TEXT, IDC_EMAIL        ; ?15 email
            dd V_TEXT, IDC_GPA          ; ?16 gpa
            dd V_LIST, IDC_GPA_SKALA    ; ?17 gpa_skala
            dd V_DATE, IDC_START        ; ?18 swavla_start
            dd V_DATE, IDC_END          ; ?19 swavla_end
REG_RAOD = ($ - reg_velebi) / 8

; ფორმის გასუფთავებისას ეს ველები ცარიელდება
gasasuftavebeli dd IDC_SAXELI, IDC_GVARI, IDC_MAMIS, IDC_PIRADI, IDC_QUCHA
                dd IDC_SAXLI, IDC_BINA, IDC_INDEKSI, IDC_MOB, IDC_EMAIL, IDC_GPA
                dd IDC_QALAQI
GAS_RAOD = ($ - gasasuftavebeli) / 4

mimdinare_id    dd 0            ; ფორმაში ჩატვირთული სტუდენტის id (0 = ახალი სტუდენტი)

.data?
vbuf        dw 256 dup(?)       ; ველის ტექსტი (UTF-16)
vbuf2       dw 64 dup(?)        ; მობილურის ნომერი
capbuf      dw 128 dup(?)       ; შეტყობინების ფანჯრის სათაური

.code

; ------------------------------------------------------------
; cifrebi — რიცხვი -> ზუსტად raod ციფრი (UTF-16, წინ ნულებით)
; მაგ: (7, 2) -> "07", (2026, 4) -> "2026"
; ------------------------------------------------------------
cifrebi PROC USES ebx edi, mn:DWORD, raod:DWORD, mizani:DWORD
    mov eax, mn
    mov edi, mizani
    mov ecx, raod
    mov ebx, 10
cf_cikli:
    xor edx, edx
    div ebx                         ; eax = eax / 10, edx = ნაშთი (ბოლო ციფრი)
    add edx, '0'
    mov [edi + ecx*2 - 2], dx       ; მარჯვნიდან მარცხნივ ვწერთ
    dec ecx
    jnz cf_cikli
    ret
cifrebi ENDP

; ------------------------------------------------------------
; tarighi_teqstad — თარიღის ამრჩევიდან "YYYY-MM-DD" -> vbuf
; eax = 1 თარიღი არის, 0 თუ გამორთულია (სწავლის დასრულება)
; ------------------------------------------------------------
tarighi_teqstad PROC id_:DWORD
    LOCAL dro:SYSTEMTIME
    LOCAL hk:DWORD

    invoke GetDlgItem, hMainWnd, id_
    mov hk, eax
    invoke SendMessageW, hk, DTM_GETSYSTEMTIME, 0, addr dro
    cmp eax, GDT_VALID
    jne tt_ara

    movzx eax, dro.wYear
    invoke cifrebi, eax, 4, offset vbuf             ; YYYY
    mov word ptr vbuf[8], '-'
    movzx eax, dro.wMonth
    invoke cifrebi, eax, 2, offset vbuf + 10        ; MM
    mov word ptr vbuf[14], '-'
    movzx eax, dro.wDay
    invoke cifrebi, eax, 2, offset vbuf + 16        ; DD
    mov word ptr vbuf[20], 0
    mov eax, 1
    ret
tt_ara:
    xor eax, eax
    ret
tarighi_teqstad ENDP

; ------------------------------------------------------------
; shetyobineba — შეტყობინება მიმდინარე ენაზე
; ------------------------------------------------------------
shetyobineba PROC t_id:DWORD, ikona:DWORD
    invoke get_text, T_SATAURI              ; სათაური ცალკე ბუფერში,
    invoke lstrcpyW, offset capbuf, eax     ; რადგან get_text wbuf-ს ხელახლა წერს
    invoke get_text, t_id
    invoke MessageBoxW, hMainWnd, eax, offset capbuf, ikona
    ret
shetyobineba ENDP

; ------------------------------------------------------------
; asakis_datvla — დაბადების თარიღიდან ასაკი
; eax = ასაკი (უარყოფითი, თუ თარიღი მომავალშია)
; ------------------------------------------------------------
asakis_datvla PROC
    LOCAL dab:SYSTEMTIME, dghes:SYSTEMTIME
    LOCAL hk:DWORD

    invoke GetDlgItem, hMainWnd, IDC_DAB
    mov hk, eax
    invoke SendMessageW, hk, DTM_GETSYSTEMTIME, 0, addr dab
    invoke GetLocalTime, addr dghes

    movzx eax, dghes.wYear
    movzx ecx, dab.wYear
    sub eax, ecx                    ; წლების სხვაობა
    ; დაბადების დღე წელს ჯერ არ დამდგარა -> ერთით ნაკლები
    mov cx, dghes.wMonth
    cmp cx, dab.wMonth
    jb ad_akleba
    ja ad_mzad
    mov cx, dghes.wDay
    cmp cx, dab.wDay
    jae ad_mzad
ad_akleba:
    dec eax
ad_mzad:
    ret
asakis_datvla ENDP

; ------------------------------------------------------------
; asakis_gamotvla — ასაკი -> IDC_ASAKI ("ასაკი: 22")
; ------------------------------------------------------------
asakis_gamotvla PROC USES ebx
    LOCAL hk:DWORD, raod:DWORD

    call asakis_datvla
    mov ebx, eax                    ; ebx = ასაკი

    invoke GetDlgItem, hMainWnd, IDC_ASAKI
    mov hk, eax
    test ebx, ebx                   ; მომავლის თარიღი -> ცარიელი
    js ag_carieli

    ; რამდენი ციფრია: 1, 2 თუ 3
    mov ecx, 1
    cmp ebx, 10
    jb ag_cifrebi
    inc ecx
    cmp ebx, 100
    jb ag_cifrebi
    inc ecx
ag_cifrebi:
    mov raod, ecx
    invoke cifrebi, ebx, raod, offset vbuf
    mov ecx, raod
    mov word ptr vbuf[ecx*2], 0
    invoke SetWindowTextW, hk, offset vbuf
    ret
ag_carieli:
    invoke SetWindowTextW, hk, offset szCarieli
    ret
asakis_gamotvla ENDP

; ------------------------------------------------------------
; ghilakis_teqsti — ღილაკზე წარწერა მიმდინარე ენაზე
; ------------------------------------------------------------
ghilakis_teqsti PROC id_:DWORD, t_id:DWORD
    LOCAL hk:DWORD

    invoke GetDlgItem, hMainWnd, id_
    mov hk, eax
    invoke get_text, t_id
    invoke SetWindowTextW, hk, eax
    ret
ghilakis_teqsti ENDP

; ------------------------------------------------------------
; rejimis_dayeneba — ღილაკები ფორმის რეჟიმის მიხედვით:
;   mimdinare_id = 0 -> ახალი სტუდენტი: „რეგისტრაცია“, „გასუფთავება“
;   mimdinare_id > 0 -> რედაქტირება:     „შენახვა“, „ახალი“, „წაშლა“
; ------------------------------------------------------------
rejimis_dayeneba PROC
    .if mimdinare_id == 0
        invoke ghilakis_teqsti, IDC_REGISTRACIA, T_REGISTRACIA
        invoke ghilakis_teqsti, IDC_GASUFTAVEBA, T_GASUFTAVEBA
        invoke GetDlgItem, hMainWnd, IDC_WASHLA
        invoke ShowWindow, eax, SW_HIDE
    .else
        invoke ghilakis_teqsti, IDC_REGISTRACIA, T_SHENAXVA
        invoke ghilakis_teqsti, IDC_GASUFTAVEBA, T_AXALI
        invoke GetDlgItem, hMainWnd, IDC_WASHLA
        invoke ShowWindow, eax, SW_SHOW
    .endif
    ret
rejimis_dayeneba ENDP

; ------------------------------------------------------------
; formis_gasuftaveba — ფორმა საწყის მდგომარეობაში
; (ქვეყანა და მოქალაქეობა რჩება: ხშირად ერთი ქვეყნის სტუდენტებს ვარეგისტრირებთ)
; ------------------------------------------------------------
formis_gasuftaveba PROC USES esi edi
    LOCAL dro:SYSTEMTIME
    LOCAL hk:DWORD

    ; ტექსტური ველები
    mov esi, offset gasasuftavebeli
    mov edi, GAS_RAOD
fg_cikli:
    invoke GetDlgItem, hMainWnd, dword ptr [esi]
    invoke SetWindowTextW, eax, offset szCarieli
    add esi, 4
    dec edi
    jnz fg_cikli

    ; რეგიონის არჩევანი ეხსნება, ქალაქების სია ცარიელდება
    invoke GetDlgItem, hMainWnd, IDC_REGIONI
    invoke SendMessageW, eax, CB_SETCURSEL, -1, 0
    invoke GetDlgItem, hMainWnd, IDC_QALAQI
    invoke SendMessageW, eax, CB_RESETCONTENT, 0, 0

    ; თარიღები: დღევანდელი
    invoke GetLocalTime, addr dro
    invoke GetDlgItem, hMainWnd, IDC_DAB
    mov hk, eax
    invoke SendMessageW, hk, DTM_SETSYSTEMTIME, GDT_VALID, addr dro
    invoke GetDlgItem, hMainWnd, IDC_START
    mov hk, eax
    invoke SendMessageW, hk, DTM_SETSYSTEMTIME, GDT_VALID, addr dro
    invoke GetDlgItem, hMainWnd, IDC_END
    mov hk, eax
    invoke SendMessageW, hk, DTM_SETSYSTEMTIME, GDT_VALID, addr dro
    call asakis_gamotvla

    mov mimdinare_id, 0             ; ფორმა ისევ ახალი სტუდენტისთვისაა
    call rejimis_dayeneba

    ; კურსორი პირველ ველზე
    invoke GetDlgItem, hMainWnd, IDC_SAXELI
    invoke SetFocus, eax
    ret
formis_gasuftaveba ENDP

; ------------------------------------------------------------
; velebis_mibma — ფორმის ყველა ველი -> ?1..?19
; (იყენებს რეგისტრაციაც და შენახვაც)
; ------------------------------------------------------------
velebis_mibma PROC USES esi ebx, stmt_:DWORD
    LOCAL iso:DWORD, param:DWORD

    mov esi, offset reg_velebi
    mov param, 1
vm_cikli:
    mov eax, [esi]                  ; წყაროს ტიპი
    mov ebx, [esi + 4]              ; კონტროლის ID

    .if eax == V_TEXT || eax == V_LIST
        invoke GetDlgItem, hMainWnd, ebx
        invoke GetWindowTextW, eax, offset vbuf, LENGTHOF vbuf
        .if eax == 0
            invoke sqlite3_bind_null, stmt_, param
        .else
            invoke sqlite3_bind_text16, stmt_, param, offset vbuf, -1, SQLITE_TRANSIENT
        .endif

    .elseif eax == V_ISO
        invoke archeuli_monacemi, ebx
        .if eax == CB_ERR
            invoke sqlite3_bind_null, stmt_, param
        .else
            mov iso, eax
            invoke sqlite3_bind_text16, stmt_, param, addr iso, 4, SQLITE_TRANSIENT
        .endif

    .elseif eax == V_DATE
        invoke tarighi_teqstad, ebx
        .if eax == 0
            invoke sqlite3_bind_null, stmt_, param
        .else
            invoke sqlite3_bind_text16, stmt_, param, offset vbuf, -1, SQLITE_TRANSIENT
        .endif

    .elseif eax == V_TEL
        invoke GetDlgItem, hMainWnd, ebx
        invoke GetWindowTextW, eax, offset vbuf2, LENGTHOF vbuf2
        .if eax == 0
            invoke sqlite3_bind_null, stmt_, param
        .else
            invoke GetDlgItem, hMainWnd, IDC_TELKODI      ; "+995"
            invoke GetWindowTextW, eax, offset vbuf, LENGTHOF vbuf
            invoke lstrcatW, offset vbuf, offset vbuf2    ; "+995" + "555123456"
            invoke sqlite3_bind_text16, stmt_, param, offset vbuf, -1, SQLITE_TRANSIENT
        .endif
    .endif

    add esi, 8
    inc param
    cmp param, REG_RAOD
    jbe vm_cikli
    ret
velebis_mibma ENDP

; ------------------------------------------------------------
; shesruleba — ბრძანების შესრულება (INSERT/UPDATE/DELETE) და finalize
; eax = 1 წარმატება, 0 შეცდომა (შეტყობინება უკვე ნაჩვენებია)
; ------------------------------------------------------------
shesruleba PROC stmt_:DWORD
    invoke sqlite3_step, stmt_
    .if eax == SQLITE_DONE
        invoke sqlite3_finalize, stmt_
        mov eax, 1
        ret
    .endif

    ; შეცდომა: რა სახის?
    invoke sqlite3_extended_errcode, hStud
    .if eax == SQLITE_CONSTRAINT_UNIQUE
        invoke shetyobineba, T_UKVE_ARSEBOBS, MB_ICONWARNING      ; ასეთი პირადი ნომერი უკვე არის
    .elseif eax == SQLITE_CONSTRAINT_NOTNULL
        invoke shetyobineba, T_SHEAVSE_VELEBI, MB_ICONWARNING     ; სავალდებულო ველი ცარიელია
    .else
        invoke sqlite3_errmsg16, hStud
        invoke MessageBoxW, hMainWnd, eax, NULL, MB_ICONERROR
    .endif
    invoke sqlite3_finalize, stmt_
    xor eax, eax
    ret
shesruleba ENDP

; ------------------------------------------------------------
; registracia — ახალი სტუდენტი: შემოწმება -> INSERT
; ------------------------------------------------------------
registracia PROC
    LOCAL stmt:DWORD

    call shemowmeba                 ; ველების შემოწმება (shemowmeba.asm)
    test eax, eax
    jz rg_dasasruli

    invoke sqlite3_prepare_v2, hStud, offset sqlChawera, -1, addr stmt, NULL
    cmp eax, SQLITE_OK
    jne rg_sqlite_shecdoma
    invoke velebis_mibma, stmt
    invoke shesruleba, stmt
    .if eax == 1
        invoke shetyobineba, T_DAREGISTRIRDA, MB_ICONINFORMATION
        call formis_gasuftaveba
    .endif
rg_dasasruli:
    ret

rg_sqlite_shecdoma:
    invoke sqlite3_errmsg16, hStud
    invoke MessageBoxW, hMainWnd, eax, NULL, MB_ICONERROR
    ret
registracia ENDP
