; ============================================================
; dzebna.asm — სტუდენტის ძებნა მოქალაქეობით და პირადი ნომრით
; შედეგები -> შედეგების ცხრილი (ListView)
; ყოველ სტრიქონს სტუდენტის id ებმის (ეკრანზე არ ჩანს),
; ორჯერ დაწკაპუნებისას ამ id-ით იტვირთება სრული მონაცემები
; ============================================================

.data
; 0 = id, 1..5 = ცხრილის სვეტები (sv_teqstebi-ს რიგით, ui.asm)
sqlDzebna   db "SELECT id, piradi_nomeri, saxeli, gvari, qalaqi, gpa FROM students "
            db "WHERE moqalaqeoba = ?1 AND piradi_nomeri = ?2", 0

.code

; ------------------------------------------------------------
; washlis_ghilakis_ganaxleba — ძებნის პანელის „წაშლა“ აქტიურია
; მხოლოდ მაშინ, როცა შედეგების ცხრილში სტრიქონია მონიშნული
; ------------------------------------------------------------
washlis_ghilakis_ganaxleba PROC
    LOCAL raod:DWORD

    invoke GetDlgItem, hMainWnd, IDC_SIA
    invoke SendMessageW, eax, LVM_GETSELECTEDCOUNT, 0, 0
    mov raod, eax                       ; მონიშნული სტრიქონების რაოდენობა
    invoke GetDlgItem, hMainWnd, IDC_DZ_WASHLA
    invoke EnableWindow, eax, raod      ; 0 -> გამორთული, 1 -> ჩართული
    ret
washlis_ghilakis_ganaxleba ENDP

; ------------------------------------------------------------
; dzebna — „ძებნა“ ღილაკი (ან Enter პირადი ნომრის ველში)
; ------------------------------------------------------------
dzebna PROC USES esi edi ebx
    LOCAL stmt:DWORD, iso:DWORD, hSia:DWORD, napovni:DWORD
    LOCAL item:LVITEMW

    ; წინა შედეგების წაშლა
    invoke GetDlgItem, hMainWnd, IDC_SIA
    mov hSia, eax
    invoke SendMessageW, hSia, LVM_DELETEALLITEMS, 0, 0
    mov napovni, 0

    ; პირადი ნომერი
    invoke GetDlgItem, hMainWnd, IDC_DZ_PIRADI
    invoke GetWindowTextW, eax, offset vbuf, LENGTHOF vbuf
    .if eax == 0
        invoke shetyobineba, T_SHEIYVANE_NOMERI, MB_ICONWARNING
        ret
    .endif
    ; მოქალაქეობა (ISO კოდი)
    invoke archeuli_monacemi, IDC_DZ_MOQ
    mov iso, eax

    invoke sqlite3_prepare_v2, hStud, offset sqlDzebna, -1, addr stmt, NULL
    cmp eax, SQLITE_OK
    jne dz_dasasruli
    invoke sqlite3_bind_text16, stmt, 1, addr iso, 4, SQLITE_TRANSIENT
    invoke sqlite3_bind_text16, stmt, 2, offset vbuf, -1, SQLITE_TRANSIENT

    ; LVITEMW-ს განულება
    lea edi, item
    xor eax, eax
    mov ecx, SIZEOF LVITEMW / 4
    rep stosd

dz_cikli:
    invoke sqlite3_step, stmt
    cmp eax, SQLITE_ROW
    jne dz_finalize

    ; ---- ახალი სტრიქონი: პირველი სვეტის ტექსტი + სტუდენტის id ----
    mov item.imask, LVIF_TEXT or LVIF_PARAM
    mov eax, napovni
    mov item.iItem, eax
    mov item.iSubItem, 0
    invoke sqlite3_column_int, stmt, 0          ; id
    mov item.lv_lParam, eax
    invoke sqlite3_column_text16, stmt, 1       ; პირადი ნომერი
    .if eax == 0                                ; NULL -> ცარიელი
        mov eax, offset szCarieli
    .endif
    mov item.pszText, eax
    invoke SendMessageW, hSia, LVM_INSERTITEMW, 0, addr item
    mov ebx, eax                                ; სტრიქონის ინდექსი

    ; ---- დანარჩენი სვეტები ამავე სტრიქონში ----
    mov item.imask, LVIF_TEXT
    mov esi, 1                                  ; ცხრილის სვეტი 1..4
dz_svetebi:
    lea eax, [esi + 1]                          ; ბაზის სვეტი 2..5
    invoke sqlite3_column_text16, stmt, eax
    .if eax == 0
        mov eax, offset szCarieli
    .endif
    mov item.pszText, eax
    mov item.iSubItem, esi
    invoke SendMessageW, hSia, LVM_SETITEMTEXTW, ebx, addr item
    inc esi
    cmp esi, SV_RAOD
    jb dz_svetebi

    inc napovni
    jmp dz_cikli

dz_finalize:
    invoke sqlite3_finalize, stmt
    .if napovni == 0
        invoke shetyobineba, T_VER_MOIDZEBNA, MB_ICONINFORMATION
    .endif
dz_dasasruli:
    call washlis_ghilakis_ganaxleba     ; ახალი შედეგები: ჯერ არაფერია მონიშნული
    ret
dzebna ENDP
