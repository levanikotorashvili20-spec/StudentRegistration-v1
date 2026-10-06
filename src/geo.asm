; ============================================================
; geo.asm — ქვეყნების, რეგიონებისა და ქალაქების სიები
; ============================================================

; "GE" UTF-16-ში 4 ბაიტია: 'G' (0047h) და 'E' (0045h).
; ორივე ერთ DWORD-ში ეტევა, ამიტომ ISO კოდს ComboBox-ის
; ელემენტს პირდაპირ ვაბამთ (CB_SETITEMDATA), ცალკე ცხრილი არ გვჭირდება.
ISO_GE          equ 00450047h

.data
sqlQveynebi     db "SELECT iso2, name FROM countries ORDER BY name", 0
sqlRegionebi    db "SELECT id, name FROM states WHERE country_iso = ?1 ORDER BY name", 0
sqlTelKodi      db "SELECT phonecode FROM countries WHERE iso2 = ?1", 0
sqlQalaqebi     db "SELECT name FROM cities WHERE state_id = ?1 ORDER BY name", 0
WSTR szPlius,   <+>

.data?
telbuf          dw 32 dup(?)        ; სატელეფონო კოდი: "+" + phonecode

.code

; ------------------------------------------------------------
; qveynebis_shevseba — სამივე ქვეყნის სიის შევსება:
; მოქალაქეობა, ქვეყანა, ძებნის მოქალაქეობა.
; ნაგულისხმევად: საქართველო
; ------------------------------------------------------------
qveynebis_shevseba PROC USES esi edi ebx
    LOCAL stmt:DWORD
    LOCAL h1:DWORD, h2:DWORD, h3:DWORD
    LOCAL iso:DWORD, ge_idx:DWORD

    invoke GetDlgItem, hMainWnd, IDC_MOQ
    mov h1, eax
    invoke GetDlgItem, hMainWnd, IDC_QVEYANA
    mov h2, eax
    invoke GetDlgItem, hMainWnd, IDC_DZ_MOQ
    mov h3, eax
    mov ge_idx, 0

    invoke sqlite3_prepare_v2, hGeo, offset sqlQveynebi, -1, addr stmt, NULL
    cmp eax, SQLITE_OK
    jne qs_dasasruli

qs_cikli:
    invoke sqlite3_step, stmt
    cmp eax, SQLITE_ROW
    jne qs_finalize

    invoke sqlite3_column_text16, stmt, 0   ; iso2: "GE" -> ერთი DWORD
    mov eax, [eax]
    mov iso, eax
    invoke sqlite3_column_text16, stmt, 1   ; ქვეყნის სახელი
    mov esi, eax

    ; სამივე სიაში ერთნაირი რიგით ემატება, ამიტომ ინდექსიც ერთნაირია
    invoke SendMessageW, h1, CB_ADDSTRING, 0, esi
    mov edi, eax
    invoke SendMessageW, h1, CB_SETITEMDATA, edi, iso
    invoke SendMessageW, h2, CB_ADDSTRING, 0, esi
    invoke SendMessageW, h2, CB_SETITEMDATA, edi, iso
    invoke SendMessageW, h3, CB_ADDSTRING, 0, esi
    invoke SendMessageW, h3, CB_SETITEMDATA, edi, iso

    .if iso == ISO_GE
        mov ge_idx, edi                     ; საქართველოს ადგილი სიაში
    .endif
    jmp qs_cikli

qs_finalize:
    invoke sqlite3_finalize, stmt

    invoke SendMessageW, h1, CB_SETCURSEL, ge_idx, 0
    invoke SendMessageW, h2, CB_SETCURSEL, ge_idx, 0
    invoke SendMessageW, h3, CB_SETCURSEL, ge_idx, 0

qs_dasasruli:
    ret
qveynebis_shevseba ENDP

; ------------------------------------------------------------
; archeuli_monacemi — სიაში არჩეული ელემენტის მიბმული მნიშვნელობა
; (ქვეყნისთვის ISO კოდი, რეგიონისთვის id)
; eax = მნიშვნელობა, ან CB_ERR (-1), თუ არაფერია არჩეული
; ------------------------------------------------------------
archeuli_monacemi PROC id_:DWORD
    LOCAL hk:DWORD

    invoke GetDlgItem, hMainWnd, id_
    mov hk, eax
    invoke SendMessageW, hk, CB_GETCURSEL, 0, 0
    cmp eax, CB_ERR
    je am_dasasruli
    invoke SendMessageW, hk, CB_GETITEMDATA, eax, 0
am_dasasruli:
    ret
archeuli_monacemi ENDP

; ------------------------------------------------------------
; regionebis_shevseba — ქვეყანა შეიცვალა:
;   - რეგიონების სია ახალი ქვეყნით
;   - ქალაქების სია სუფთავდება (რეგიონი ჯერ არ არის არჩეული)
;   - სატელეფონო კოდი (+995)
; ------------------------------------------------------------
regionebis_shevseba PROC USES esi edi
    LOCAL stmt:DWORD, iso:DWORD
    LOCAL hReg:DWORD, hQal:DWORD, hTel:DWORD

    invoke GetDlgItem, hMainWnd, IDC_REGIONI
    mov hReg, eax
    invoke GetDlgItem, hMainWnd, IDC_QALAQI
    mov hQal, eax
    invoke GetDlgItem, hMainWnd, IDC_TELKODI
    mov hTel, eax

    ; ძველი მონაცემების გასუფთავება
    invoke SendMessageW, hReg, CB_RESETCONTENT, 0, 0
    invoke SendMessageW, hQal, CB_RESETCONTENT, 0, 0
    invoke SetWindowTextW, hTel, offset szCarieli

    invoke archeuli_monacemi, IDC_QVEYANA
    cmp eax, CB_ERR
    je rs_dasasruli
    mov iso, eax                            ; "GE" — 4 ბაიტი UTF-16

    ; ---- რეგიონები ----
    invoke sqlite3_prepare_v2, hGeo, offset sqlRegionebi, -1, addr stmt, NULL
    cmp eax, SQLITE_OK
    jne rs_telefoni
    ; ?1 = ISO კოდი: 4 ბაიტი პირდაპირ iso ცვლადიდან
    invoke sqlite3_bind_text16, stmt, 1, addr iso, 4, SQLITE_TRANSIENT
rs_cikli:
    invoke sqlite3_step, stmt
    cmp eax, SQLITE_ROW
    jne rs_finalize
    invoke sqlite3_column_int, stmt, 0      ; რეგიონის id
    mov edi, eax
    invoke sqlite3_column_text16, stmt, 1   ; რეგიონის სახელი
    invoke SendMessageW, hReg, CB_ADDSTRING, 0, eax
    invoke SendMessageW, hReg, CB_SETITEMDATA, eax, edi
    jmp rs_cikli
rs_finalize:
    invoke sqlite3_finalize, stmt

rs_telefoni:
    ; ---- სატელეფონო კოდი ----
    invoke sqlite3_prepare_v2, hGeo, offset sqlTelKodi, -1, addr stmt, NULL
    cmp eax, SQLITE_OK
    jne rs_dasasruli
    invoke sqlite3_bind_text16, stmt, 1, addr iso, 4, SQLITE_TRANSIENT
    invoke sqlite3_step, stmt
    cmp eax, SQLITE_ROW
    jne rs_tel_finalize
    invoke sqlite3_column_text16, stmt, 0
    test eax, eax                           ; კოდი შეიძლება არ ჰქონდეს
    jz rs_tel_finalize
    mov esi, eax
    ; ბაზაში კოდი შეიძლება "+"-ით ეწეროს ან მის გარეშე
    .if word ptr [esi] == '+'
        invoke lstrcpyW, offset telbuf, esi
    .else
        invoke lstrcpyW, offset telbuf, offset szPlius
        invoke lstrcatW, offset telbuf, esi
    .endif
    invoke SetWindowTextW, hTel, offset telbuf
rs_tel_finalize:
    invoke sqlite3_finalize, stmt

rs_dasasruli:
    ret
regionebis_shevseba ENDP

; ------------------------------------------------------------
; qalaqebis_shevseba — რეგიონი შეიცვალა: ქალაქების სია
; ------------------------------------------------------------
qalaqebis_shevseba PROC USES edi
    LOCAL stmt:DWORD, hQal:DWORD

    invoke GetDlgItem, hMainWnd, IDC_QALAQI
    mov hQal, eax
    invoke SendMessageW, hQal, CB_RESETCONTENT, 0, 0

    invoke archeuli_monacemi, IDC_REGIONI
    cmp eax, CB_ERR
    je qq_dasasruli
    mov edi, eax                            ; რეგიონის id

    invoke sqlite3_prepare_v2, hGeo, offset sqlQalaqebi, -1, addr stmt, NULL
    cmp eax, SQLITE_OK
    jne qq_dasasruli
    invoke sqlite3_bind_int, stmt, 1, edi
qq_cikli:
    invoke sqlite3_step, stmt
    cmp eax, SQLITE_ROW
    jne qq_finalize
    invoke sqlite3_column_text16, stmt, 0   ; ქალაქის სახელი
    invoke SendMessageW, hQal, CB_ADDSTRING, 0, eax
    jmp qq_cikli
qq_finalize:
    invoke sqlite3_finalize, stmt

qq_dasasruli:
    ret
qalaqebis_shevseba ENDP
