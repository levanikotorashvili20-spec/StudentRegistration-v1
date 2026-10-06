; ============================================================
; chatvirtva.asm — სტუდენტის სრული მონაცემები -> ფორმა
; (შედეგების ცხრილში ორჯერ დაწკაპუნებით)
;
; იყენებს reg_velebi ცხრილს (registracia.asm) საპირისპირო მიმართულებით:
;   რეგისტრაცია: ფორმა -> ბაზა
;   ჩატვირთვა:   ბაზა  -> ფორმა
; ============================================================

.data
; სვეტების რიგი = reg_velebi-ს რიგი!
; gpa_skala მთელ რიცხვად: REAL 4.0 ტექსტად "4.0" იქნებოდა, სიაში კი "4" წერია
sqlChatvirtva   db "SELECT saxeli, gvari, mamis_saxeli, dab_tarighi, moqalaqeoba, "
                db "piradi_nomeri, qveyana, regioni, qalaqi, qucha, saxlis_n, bina, "
                db "indeksi, mob_nomeri, email, gpa, CAST(gpa_skala AS INTEGER), "
                db "swavla_start, swavla_end FROM students WHERE id = ?1", 0

.code

; ------------------------------------------------------------
; ricxvi_teqstidan — UTF-16 ციფრები -> რიცხვი
; მაგ: ("2004", 4) -> 2004
; ------------------------------------------------------------
ricxvi_teqstidan PROC USES esi, gza_:DWORD, raod:DWORD
    mov esi, gza_
    mov ecx, raod
    xor eax, eax
rt_cikli:
    imul eax, eax, 10
    movzx edx, word ptr [esi]
    sub edx, '0'
    add eax, edx
    add esi, 2
    dec ecx
    jnz rt_cikli
    ret
ricxvi_teqstidan ENDP

; ------------------------------------------------------------
; tarighis_dayeneba — "YYYY-MM-DD" -> თარიღის ამრჩევი
; teqsti = 0 (NULL) -> თარიღი გამორთულია (სწავლის დასრულება)
; ------------------------------------------------------------
tarighis_dayeneba PROC USES esi edi, id_:DWORD, teqsti:DWORD
    LOCAL dro:SYSTEMTIME
    LOCAL hk:DWORD

    invoke GetDlgItem, hMainWnd, id_
    mov hk, eax
    mov esi, teqsti
    .if esi == 0
        invoke SendMessageW, hk, DTM_SETSYSTEMTIME, GDT_NONE, 0
        ret
    .endif

    lea edi, dro                    ; SYSTEMTIME-ის განულება
    xor eax, eax
    mov ecx, SIZEOF SYSTEMTIME / 4
    rep stosd

    invoke ricxvi_teqstidan, esi, 4     ; YYYY  (სიმბოლოები 0-3)
    mov dro.wYear, ax
    lea eax, [esi + 10]                 ; MM    (სიმბოლოები 5-6)
    invoke ricxvi_teqstidan, eax, 2
    mov dro.wMonth, ax
    lea eax, [esi + 16]                 ; DD    (სიმბოლოები 8-9)
    invoke ricxvi_teqstidan, eax, 2
    mov dro.wDay, ax
    invoke SendMessageW, hk, DTM_SETSYSTEMTIME, GDT_VALID, addr dro
    ret
tarighis_dayeneba ENDP

; ------------------------------------------------------------
; iso_archeva — ქვეყნის სიაში იმ ქვეყნის არჩევა, რომლის ISO კოდიც iso-ა
; ------------------------------------------------------------
iso_archeva PROC USES esi edi, id_:DWORD, iso:DWORD
    LOCAL hk:DWORD

    invoke GetDlgItem, hMainWnd, id_
    mov hk, eax
    invoke SendMessageW, hk, CB_GETCOUNT, 0, 0
    mov edi, eax                        ; ელემენტების რაოდენობა
    xor esi, esi
ia_cikli:
    cmp esi, edi
    jae ia_ver
    invoke SendMessageW, hk, CB_GETITEMDATA, esi, 0
    cmp eax, iso
    je ia_napovnia
    inc esi
    jmp ia_cikli
ia_napovnia:
    invoke SendMessageW, hk, CB_SETCURSEL, esi, 0
    ret
ia_ver:
    invoke SendMessageW, hk, CB_SETCURSEL, -1, 0
    ret
iso_archeva ENDP

; ------------------------------------------------------------
; teqstit_archeva — სიაში ზუსტად ამ ტექსტის მქონე ელემენტის არჩევა
; (რეგიონი, GPA-ს სკალა). ვერ იპოვა ან NULL -> არაფერი არჩეული
; ------------------------------------------------------------
teqstit_archeva PROC id_:DWORD, teqsti:DWORD
    LOCAL hk:DWORD

    invoke GetDlgItem, hMainWnd, id_
    mov hk, eax
    mov eax, CB_ERR
    .if teqsti != 0
        invoke SendMessageW, hk, CB_FINDSTRINGEXACT, -1, teqsti
    .endif
    invoke SendMessageW, hk, CB_SETCURSEL, eax, 0
    ret
teqstit_archeva ENDP

; ------------------------------------------------------------
; telefonis_dayeneba — "+995555123456" -> მობილურის ველი
; თუ ნომერი მიმდინარე კოდით ("+995") იწყება, ველში მხოლოდ დარჩენილი ნაწილი ჩაიწერება
; ------------------------------------------------------------
telefonis_dayeneba PROC USES esi edi, teqsti:DWORD
    LOCAL hk:DWORD

    invoke GetDlgItem, hMainWnd, IDC_MOB
    mov hk, eax
    mov esi, teqsti
    .if esi == 0
        invoke SetWindowTextW, hk, offset szCarieli
        ret
    .endif

    invoke GetDlgItem, hMainWnd, IDC_TELKODI
    invoke GetWindowTextW, eax, offset vbuf2, LENGTHOF vbuf2

    ; ნომრის დასაწყისი კოდს ემთხვევა?
    mov edi, offset vbuf2
    mov ecx, esi
td_cikli:
    mov ax, [edi]
    test ax, ax                         ; კოდი დამთავრდა -> ემთხვევა
    jz td_emtxveva
    cmp ax, [ecx]
    jne td_sruli
    add edi, 2
    add ecx, 2
    jmp td_cikli
td_emtxveva:
    invoke SetWindowTextW, hk, ecx      ; კოდის შემდეგ დარჩენილი ნაწილი
    ret
td_sruli:
    invoke SetWindowTextW, hk, esi      ; სხვა კოდია -> სრულად
    ret
telefonis_dayeneba ENDP

; ------------------------------------------------------------
; studentis_chatvirtva — სტუდენტის (id) ყველა ველი ფორმაში
; ------------------------------------------------------------
studentis_chatvirtva PROC USES esi edi ebx, sid:DWORD
    LOCAL stmt:DWORD, sveti:DWORD

    invoke sqlite3_prepare_v2, hStud, offset sqlChatvirtva, -1, addr stmt, NULL
    cmp eax, SQLITE_OK
    jne sc_dasasruli
    invoke sqlite3_bind_int, stmt, 1, sid
    invoke sqlite3_step, stmt
    cmp eax, SQLITE_ROW
    jne sc_finalize

    mov esi, offset reg_velebi
    mov sveti, 0
sc_cikli:
    invoke sqlite3_column_text16, stmt, sveti
    mov edi, eax                        ; ტექსტი (0, თუ NULL)
    mov ebx, [esi + 4]                  ; კონტროლის ID
    mov eax, [esi]                      ; წყაროს ტიპი

    .if eax == V_TEXT
        .if edi == 0
            mov edi, offset szCarieli
        .endif
        invoke GetDlgItem, hMainWnd, ebx
        invoke SetWindowTextW, eax, edi

    .elseif eax == V_LIST
        invoke teqstit_archeva, ebx, edi
        .if ebx == IDC_REGIONI
            call qalaqebis_shevseba     ; ამ რეგიონის ქალაქები
        .endif

    .elseif eax == V_ISO
        .if edi != 0
            invoke iso_archeva, ebx, dword ptr [edi]
        .endif
        .if ebx == IDC_QVEYANA
            call regionebis_shevseba    ; ამ ქვეყნის რეგიონები და კოდი
        .endif

    .elseif eax == V_DATE
        invoke tarighis_dayeneba, ebx, edi

    .elseif eax == V_TEL
        invoke telefonis_dayeneba, edi
    .endif

    add esi, 8
    inc sveti
    cmp sveti, REG_RAOD
    jb sc_cikli

    mov eax, sid
    mov mimdinare_id, eax               ; ფორმაში ახლა ეს სტუდენტია
    call rejimis_dayeneba               ; ღილაკები: შენახვა / ახალი / წაშლა
    call asakis_gamotvla

sc_finalize:
    invoke sqlite3_finalize, stmt
sc_dasasruli:
    ret
studentis_chatvirtva ENDP

; ------------------------------------------------------------
; archeulis_id — შედეგების ცხრილში მონიშნული სტრიქონის სტუდენტის id
; eax = id, ან -1, თუ არაფერია მონიშნული
; ------------------------------------------------------------
archeulis_id PROC USES edi
    LOCAL hSia:DWORD
    LOCAL item:LVITEMW

    invoke GetDlgItem, hMainWnd, IDC_SIA
    mov hSia, eax
    invoke SendMessageW, hSia, LVM_GETNEXTITEM, -1, LVNI_SELECTED
    cmp eax, -1                         ; არაფერია მონიშნული
    je ai_dasasruli

    push eax
    lea edi, item                       ; LVITEMW-ს განულება
    xor eax, eax
    mov ecx, SIZEOF LVITEMW / 4
    rep stosd
    pop eax

    mov item.iItem, eax
    mov item.imask, LVIF_PARAM          ; გვჭირდება მხოლოდ მიბმული id
    invoke SendMessageW, hSia, LVM_GETITEMW, 0, addr item
    mov eax, item.lv_lParam
ai_dasasruli:
    ret
archeulis_id ENDP

; ------------------------------------------------------------
; archeulis_chatvirtva — მონიშნული სტუდენტი -> ფორმა
; ------------------------------------------------------------
archeulis_chatvirtva PROC
    call archeulis_id
    cmp eax, -1
    je ac_dasasruli
    invoke studentis_chatvirtva, eax
ac_dasasruli:
    ret
archeulis_chatvirtva ENDP
