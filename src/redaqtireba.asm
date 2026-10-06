; ============================================================
; redaqtireba.asm — ჩატვირთული სტუდენტის შენახვა და წაშლა
; (mimdinare_id = ფორმაში ჩატვირთული სტუდენტის id)
; ============================================================

.data
; ?1..?19 = reg_velebi-ს რიგი (იგივე, რაც INSERT-ში), ?20 = id
sqlShenaxva db "UPDATE students SET saxeli = ?1, gvari = ?2, mamis_saxeli = ?3, "
            db "dab_tarighi = ?4, moqalaqeoba = ?5, piradi_nomeri = ?6, qveyana = ?7, "
            db "regioni = ?8, qalaqi = ?9, qucha = ?10, saxlis_n = ?11, bina = ?12, "
            db "indeksi = ?13, mob_nomeri = ?14, email = ?15, gpa = ?16, gpa_skala = ?17, "
            db "swavla_start = ?18, swavla_end = ?19 WHERE id = ?20", 0
sqlWashla   db "DELETE FROM students WHERE id = ?1", 0

; შედეგების ცხრილის სვეტები -> ფორმის ველები (sv_teqstebi-ს რიგით)
sv_kontrolebi   dd IDC_PIRADI, IDC_SAXELI, IDC_GVARI, IDC_QALAQI, IDC_GPA

.code

; ------------------------------------------------------------
; rigis_povna — შედეგების ცხრილში იმ სტრიქონის პოვნა,
; რომელსაც ეს სტუდენტის id (sid) აქვს მიბმული
; eax = სტრიქონის ინდექსი, ან -1
; ------------------------------------------------------------
rigis_povna PROC sid:DWORD
    LOCAL hSia:DWORD
    LOCAL fi:LVFINDINFOW

    invoke GetDlgItem, hMainWnd, IDC_SIA
    mov hSia, eax
    mov fi.lf_flags, LVFI_PARAM
    mov fi.lf_psz, 0
    mov eax, sid
    mov fi.lf_lParam, eax
    mov fi.lf_pt.x, 0
    mov fi.lf_pt.y, 0
    mov fi.lf_vkDirection, 0
    invoke SendMessageW, hSia, LVM_FINDITEMW, -1, addr fi
    ret
rigis_povna ENDP

; ------------------------------------------------------------
; siis_ganaxleba — შენახვის შემდეგ შედეგების ცხრილში
; ამ სტუდენტის სტრიქონი ფორმის ახალი მნიშვნელობებით
; ------------------------------------------------------------
siis_ganaxleba PROC USES esi edi ebx
    LOCAL hSia:DWORD
    LOCAL item:LVITEMW

    invoke rigis_povna, mimdinare_id
    cmp eax, -1                         ; ცხრილში არ არის
    je sl_dasasruli
    mov ebx, eax                        ; სტრიქონის ინდექსი

    invoke GetDlgItem, hMainWnd, IDC_SIA
    mov hSia, eax
    lea edi, item                       ; LVITEMW-ს განულება
    xor eax, eax
    mov ecx, SIZEOF LVITEMW / 4
    rep stosd

    xor esi, esi                        ; სვეტი 0..4
sl_cikli:
    invoke GetDlgItem, hMainWnd, sv_kontrolebi[esi*4]
    invoke GetWindowTextW, eax, offset vbuf, LENGTHOF vbuf
    mov item.iSubItem, esi
    mov item.pszText, offset vbuf
    invoke SendMessageW, hSia, LVM_SETITEMTEXTW, ebx, addr item
    inc esi
    cmp esi, SV_RAOD
    jb sl_cikli
sl_dasasruli:
    ret
siis_ganaxleba ENDP

; ------------------------------------------------------------
; shenaxva — „შენახვა“: შემოწმება -> UPDATE
; ------------------------------------------------------------
shenaxva PROC
    LOCAL stmt:DWORD

    call shemowmeba
    test eax, eax
    jz sn_dasasruli

    invoke sqlite3_prepare_v2, hStud, offset sqlShenaxva, -1, addr stmt, NULL
    cmp eax, SQLITE_OK
    jne sn_sqlite_shecdoma
    invoke velebis_mibma, stmt              ; ?1..?19 ფორმიდან
    invoke sqlite3_bind_int, stmt, 20, mimdinare_id
    invoke shesruleba, stmt
    .if eax == 1
        call siis_ganaxleba
        invoke shetyobineba, T_SHENAXULIA, MB_ICONINFORMATION
    .endif
sn_dasasruli:
    ret

sn_sqlite_shecdoma:
    invoke sqlite3_errmsg16, hStud
    invoke MessageBoxW, hMainWnd, eax, NULL, MB_ICONERROR
    ret
shenaxva ENDP

; ------------------------------------------------------------
; studentis_washla — სტუდენტის (sid) წაშლა დადასტურებით:
; ბაზიდან, შედეგების ცხრილიდან, და თუ ფორმაში იყო — ფორმიდანაც
; ------------------------------------------------------------
studentis_washla PROC sid:DWORD
    LOCAL stmt:DWORD

    invoke shetyobineba, T_DADASTURE, MB_YESNO or MB_ICONQUESTION
    .if eax != IDYES
        ret
    .endif

    invoke sqlite3_prepare_v2, hStud, offset sqlWashla, -1, addr stmt, NULL
    cmp eax, SQLITE_OK
    jne ws_sqlite_shecdoma
    invoke sqlite3_bind_int, stmt, 1, sid
    invoke shesruleba, stmt
    .if eax == 1
        ; შედეგების ცხრილიდან
        invoke rigis_povna, sid
        .if eax != -1
            push eax
            invoke GetDlgItem, hMainWnd, IDC_SIA
            pop ecx
            invoke SendMessageW, eax, LVM_DELETEITEM, ecx, 0
        .endif
        call washlis_ghilakis_ganaxleba
        ; თუ ეს სტუდენტი ფორმაში იყო ჩატვირთული
        mov eax, sid
        .if eax == mimdinare_id
            call formis_gasuftaveba         ; ისევ ახალი სტუდენტის რეჟიმი
        .endif
        invoke shetyobineba, T_WASHLILIA, MB_ICONINFORMATION
    .endif
    ret

ws_sqlite_shecdoma:
    invoke sqlite3_errmsg16, hStud
    invoke MessageBoxW, hMainWnd, eax, NULL, MB_ICONERROR
    ret
studentis_washla ENDP

; ------------------------------------------------------------
; washla — ფორმის „წაშლა“ ღილაკი: ჩატვირთული სტუდენტი
; ------------------------------------------------------------
washla PROC
    .if mimdinare_id != 0
        invoke studentis_washla, mimdinare_id
    .endif
    ret
washla ENDP

; ------------------------------------------------------------
; archeulis_washla — შედეგების ცხრილში მონიშნული სტუდენტი
; (Delete კლავიში ან მენიუს „წაშლა“)
; ------------------------------------------------------------
archeulis_washla PROC
    call archeulis_id
    cmp eax, -1
    je aw_dasasruli
    invoke studentis_washla, eax
aw_dasasruli:
    ret
archeulis_washla ENDP

; ------------------------------------------------------------
; konteqsturi_menu — მარჯვენა ღილაკი შედეგზე: „გახსნა“ / „წაშლა“
; ------------------------------------------------------------
MENU_GAXSNA     equ 1001
MENU_WASHLA     equ 1002

konteqsturi_menu PROC
    LOCAL kursori:POINT, hMenu:DWORD

    call archeulis_id                   ; ცარიელ ადგილზე დაწკაპუნება -> მენიუ არ გვჭირდება
    cmp eax, -1
    je km_dasasruli

    invoke CreatePopupMenu
    mov hMenu, eax
    invoke get_text, T_GAXSNA           ; მენიუ ტექსტს თავისთვის იმახსოვრებს,
    invoke AppendMenuW, hMenu, MF_STRING, MENU_GAXSNA, eax
    invoke get_text, T_WASHLA           ; ამიტომ wbuf-ის ხელახლა გამოყენება შეიძლება
    invoke AppendMenuW, hMenu, MF_STRING, MENU_WASHLA, eax

    ; მენიუ კურსორის ადგილას; TPM_RETURNCMD: არჩეული პუნქტი eax-ში ბრუნდება
    invoke GetCursorPos, addr kursori
    invoke TrackPopupMenu, hMenu, TPM_RETURNCMD or TPM_RIGHTBUTTON, \
           kursori.x, kursori.y, 0, hMainWnd, NULL
    push eax
    invoke DestroyMenu, hMenu
    pop eax

    .if eax == MENU_GAXSNA
        call archeulis_chatvirtva
    .elseif eax == MENU_WASHLA
        call archeulis_washla
    .endif
km_dasasruli:
    ret
konteqsturi_menu ENDP
