; ============================================================
; shemowmeba.asm — ველების შემოწმება ბაზაში ჩაწერამდე
; ყოველი შეცდომისას: შეტყობინება მიმდინარე ენაზე
; და კურსორი იმ ველზე, რომელიც უნდა გასწორდეს
; ============================================================

.data
; ტექსტური ველები, რომლებსაც თავში და ბოლოში ჰარები ეჭრება
sasuftavebeli   dd IDC_SAXELI, IDC_GVARI, IDC_MAMIS, IDC_PIRADI, IDC_QALAQI
                dd IDC_QUCHA, IDC_SAXLI, IDC_BINA, IDC_INDEKSI, IDC_EMAIL, IDC_GPA
SAS_RAOD = ($ - sasuftavebeli) / 4

.code

; ------------------------------------------------------------
; shecdoma — შეტყობინება + კურსორი ველზე. eax = 0 (შემოწმება ვერ გაიარა)
; ------------------------------------------------------------
shecdoma PROC t_id:DWORD, ctl_id:DWORD
    invoke shetyobineba, t_id, MB_ICONWARNING
    invoke GetDlgItem, hMainWnd, ctl_id
    invoke SetFocus, eax
    xor eax, eax
    ret
shecdoma ENDP

; ------------------------------------------------------------
; velis_sigrdze — ველში ჩაწერილი ტექსტის სიგრძე
; ------------------------------------------------------------
velis_sigrdze PROC id_:DWORD
    invoke GetDlgItem, hMainWnd, id_
    invoke GetWindowTextLengthW, eax
    ret
velis_sigrdze ENDP

; ------------------------------------------------------------
; teqstis_gasuftaveba — ველის ტექსტს თავში და ბოლოში ჰარებს აჭრის
; და გასუფთავებულს ველში უკან წერს. eax = ახალი სიგრძე
; ------------------------------------------------------------
teqstis_gasuftaveba PROC USES esi edi, id_:DWORD
    LOCAL hk:DWORD, sigrdze:DWORD

    invoke GetDlgItem, hMainWnd, id_
    mov hk, eax
    invoke GetWindowTextW, hk, offset vbuf, LENGTHOF vbuf
    mov sigrdze, eax

    ; ბოლოდან: სანამ ჰარია, ვამოკლებთ
    mov ecx, eax
tg_bolo:
    test ecx, ecx
    jz tg_bolo_mzad
    cmp word ptr vbuf[ecx*2 - 2], ' '
    jne tg_bolo_mzad
    dec ecx
    jmp tg_bolo
tg_bolo_mzad:
    mov word ptr vbuf[ecx*2], 0

    ; თავიდან: რამდენი ჰარია (esi)
    xor esi, esi
tg_tavi:
    cmp esi, ecx
    jae tg_tavi_mzad
    cmp word ptr vbuf[esi*2], ' '
    jne tg_tavi_mzad
    inc esi
    jmp tg_tavi
tg_tavi_mzad:
    ; vbuf[esi..ecx) -> vbuf[0..)
    sub ecx, esi                    ; ახალი სიგრძე
    mov edx, ecx
    lea esi, vbuf[esi*2]
    mov edi, offset vbuf
    rep movsw                       ; ecx სიმბოლოს გადატანა
    mov word ptr [edi], 0

    ; თუ რამე მოიჭრა — ველში ვწერთ
    .if edx != sigrdze
        push edx
        invoke SetWindowTextW, hk, offset vbuf
        pop edx
    .endif
    mov eax, edx
    ret
teqstis_gasuftaveba ENDP

; ------------------------------------------------------------
; mxolod_cifrebi — eax = 1, თუ სტრიქონში მხოლოდ ციფრებია
; ------------------------------------------------------------
mxolod_cifrebi PROC gza_:DWORD
    mov ecx, gza_
mc_cikli:
    movzx eax, word ptr [ecx]
    test eax, eax
    jz mc_ki
    sub eax, '0'
    cmp eax, 9                      ; '0'-ზე ნაკლები -> დიდი რიცხვი (unsigned)
    ja mc_ara
    add ecx, 2
    jmp mc_cikli
mc_ki:
    mov eax, 1
    ret
mc_ara:
    xor eax, eax
    ret
mxolod_cifrebi ENDP

; ------------------------------------------------------------
; emailis_shemowmeba — eax = 1 სწორია, 0 არასწორია
; წესი: ზუსტად ერთი '@', მის წინ რამე, მის შემდეგ "რამე.რამე"
; ------------------------------------------------------------
emailis_shemowmeba PROC USES esi, gza_:DWORD
    mov esi, gza_
    xor ecx, ecx                    ; '@'-ების რაოდენობა
    xor edx, edx                    ; ბოლო '@'-ის მისამართი
em_cikli:
    mov ax, [esi]
    test ax, ax
    jz em_bolo
    cmp ax, '@'
    jne em_shemdegi
    inc ecx
    mov edx, esi
em_shemdegi:
    add esi, 2
    jmp em_cikli
em_bolo:
    cmp ecx, 1                      ; ზუსტად ერთი '@'
    jne em_ara
    cmp edx, gza_                   ; '@'-ის წინ რამე უნდა იყოს
    je em_ara
    cmp word ptr [edx + 2], 0       ; '@'-ის შემდეგ რამე უნდა იყოს...
    je em_ara
    cmp word ptr [edx + 2], '.'     ; ...და არა პირდაპირ წერტილი
    je em_ara
    lea esi, [edx + 4]
em_wertili:                         ; ვეძებთ წერტილს, რომლის შემდეგაც რამე წერია
    mov ax, [esi]
    test ax, ax
    jz em_ara
    cmp ax, '.'
    jne em_wertili_shemdegi
    cmp word ptr [esi + 2], 0
    jne em_ki
em_wertili_shemdegi:
    add esi, 2
    jmp em_wertili
em_ki:
    mov eax, 1
    ret
em_ara:
    xor eax, eax
    ret
emailis_shemowmeba ENDP

; ------------------------------------------------------------
; gpas_gardaqmna — "3.75" -> 375 (მეასედებში), "4" -> 400
; დასაშვებია: 1-3 ციფრი, შემდეგ არასავალდებულო '.' და 1-2 ციფრი
; eax = მნიშვნელობა × 100, ან -1, თუ ფორმატი არასწორია
; ------------------------------------------------------------
gpas_gardaqmna PROC USES esi ebx, gza_:DWORD
    mov esi, gza_
    xor eax, eax                    ; მთელი ნაწილი
    xor ebx, ebx                    ; მისი ციფრების რაოდენობა
gp_mteli:
    movzx edx, word ptr [esi]
    sub edx, '0'
    cmp edx, 9
    ja gp_mteli_bolo                ; ციფრი არ არის
    imul eax, eax, 10
    add eax, edx
    inc ebx
    cmp ebx, 3
    ja gp_ara                       ; 3 ციფრზე მეტი
    add esi, 2
    jmp gp_mteli
gp_mteli_bolo:
    test ebx, ebx                   ; ერთი ციფრი მაინც უნდა იყოს
    jz gp_ara
    imul eax, eax, 100
    movzx edx, word ptr [esi]
    test edx, edx                   ; ბოლო -> წილადი ნაწილი არ აქვს
    jz gp_ki
    cmp edx, '.'
    jne gp_ara
    ; პირველი ციფრი წერტილის შემდეგ (მეათედები) — აუცილებელია
    movzx edx, word ptr [esi + 2]
    sub edx, '0'
    cmp edx, 9
    ja gp_ara
    imul edx, edx, 10
    add eax, edx
    ; მეორე ციფრი (მეასედები) — არასავალდებულო
    movzx edx, word ptr [esi + 4]
    test edx, edx
    jz gp_ki
    sub edx, '0'
    cmp edx, 9
    ja gp_ara
    add eax, edx
    cmp word ptr [esi + 6], 0       ; მესამე ციფრი აღარ შეიძლება
    jne gp_ara
gp_ki:
    ret
gp_ara:
    mov eax, -1
    ret
gpas_gardaqmna ENDP

; ------------------------------------------------------------
; gpas_shemowmeba — GPA: მძიმე -> წერტილი, რიცხვი 0-დან სკალამდე
; ცარიელი GPA დასაშვებია. eax = 1 სწორია, 0 არასწორია
; ------------------------------------------------------------
gpas_shemowmeba PROC USES esi
    LOCAL hk:DWORD, mnishvneloba:DWORD

    invoke GetDlgItem, hMainWnd, IDC_GPA
    mov hk, eax
    invoke GetWindowTextW, hk, offset vbuf, LENGTHOF vbuf
    .if eax == 0
        mov eax, 1                  ; ცარიელი -> კარგია
        ret
    .endif

    ; "3,75" -> "3.75" (და ველშიც ასე ჩაიწერება)
    mov esi, offset vbuf
    xor ecx, ecx                    ; შეიცვალა თუ არა რამე
gs_cikli:
    mov ax, [esi]
    test ax, ax
    jz gs_bolo
    .if ax == ','
        mov word ptr [esi], '.'
        mov ecx, 1
    .endif
    add esi, 2
    jmp gs_cikli
gs_bolo:
    .if ecx != 0
        invoke SetWindowTextW, hk, offset vbuf
    .endif

    invoke gpas_gardaqmna, offset vbuf
    cmp eax, -1
    je gs_ara
    mov mnishvneloba, eax

    ; სკალა (იგივე ფუნქციით: "4" -> 400)
    invoke GetDlgItem, hMainWnd, IDC_GPA_SKALA
    invoke GetWindowTextW, eax, offset vbuf2, LENGTHOF vbuf2
    invoke gpas_gardaqmna, offset vbuf2
    cmp eax, -1
    je gs_ara
    cmp mnishvneloba, eax           ; GPA სკალაზე მეტი ვერ იქნება
    ja gs_ara
    mov eax, 1
    ret
gs_ara:
    xor eax, eax
    ret
gpas_shemowmeba ENDP

; ------------------------------------------------------------
; tarighi_ricxvad — თარიღი -> YYYYMMDD რიცხვი (შესადარებლად)
; eax = 0, თუ თარიღი გამორთულია
; ------------------------------------------------------------
tarighi_ricxvad PROC id_:DWORD
    LOCAL dro:SYSTEMTIME
    LOCAL hk:DWORD

    invoke GetDlgItem, hMainWnd, id_
    mov hk, eax
    invoke SendMessageW, hk, DTM_GETSYSTEMTIME, 0, addr dro
    .if eax != GDT_VALID
        xor eax, eax
        ret
    .endif
    movzx eax, dro.wYear
    imul eax, eax, 10000
    movzx ecx, dro.wMonth
    imul ecx, ecx, 100
    add eax, ecx
    movzx ecx, dro.wDay
    add eax, ecx
    ret
tarighi_ricxvad ENDP

; ------------------------------------------------------------
; shemowmeba — ყველა ველის შემოწმება ფორმის რიგით (ზემოდან ქვემოთ)
; eax = 1 ყველაფერი სწორია, 0 შეცდომაა (შეტყობინება უკვე ნაჩვენებია)
; ------------------------------------------------------------
shemowmeba PROC USES esi edi
    LOCAL iso:DWORD

    ; ---- 0. ჰარების მოჭრა ყველა ტექსტურ ველში ----
    mov esi, offset sasuftavebeli
    mov edi, SAS_RAOD
sh_cikli:
    invoke teqstis_gasuftaveba, dword ptr [esi]
    add esi, 4
    dec edi
    jnz sh_cikli

    ; ---- 1. სახელი, გვარი ----
    invoke velis_sigrdze, IDC_SAXELI
    .if eax == 0
        invoke shecdoma, T_V_SAXELI, IDC_SAXELI
        ret
    .endif
    invoke velis_sigrdze, IDC_GVARI
    .if eax == 0
        invoke shecdoma, T_V_GVARI, IDC_GVARI
        ret
    .endif

    ; ---- 2. დაბადების თარიღი: ასაკი 14-დან 100-მდე ----
    call asakis_datvla
    cmp eax, 14
    jl sh_dab_shecdoma
    cmp eax, 100
    jle sh_dab_kargi
sh_dab_shecdoma:
    invoke shecdoma, T_V_DAB, IDC_DAB
    ret
sh_dab_kargi:

    ; ---- 3. მოქალაქეობა ----
    invoke archeuli_monacemi, IDC_MOQ
    .if eax == CB_ERR
        invoke shecdoma, T_V_MOQ, IDC_MOQ
        ret
    .endif
    mov iso, eax

    ; ---- 4. პირადი ნომერი (საქართველო: ზუსტად 11 ციფრი) ----
    invoke GetDlgItem, hMainWnd, IDC_PIRADI
    invoke GetWindowTextW, eax, offset vbuf, LENGTHOF vbuf
    .if eax == 0
        invoke shecdoma, T_V_PIRADI, IDC_PIRADI
        ret
    .endif
    .if iso == ISO_GE
        .if eax != 11
            invoke shecdoma, T_V_PIRADI_GE, IDC_PIRADI
            ret
        .endif
        invoke mxolod_cifrebi, offset vbuf
        .if eax == 0
            invoke shecdoma, T_V_PIRADI_GE, IDC_PIRADI
            ret
        .endif
    .endif

    ; ---- 5. ქვეყანა ----
    invoke archeuli_monacemi, IDC_QVEYANA
    .if eax == CB_ERR
        invoke shecdoma, T_V_QVEYANA, IDC_QVEYANA
        ret
    .endif

    ; ---- 6. ქალაქი ----
    invoke velis_sigrdze, IDC_QALAQI
    .if eax == 0
        invoke shecdoma, T_V_QALAQI, IDC_QALAQI
        ret
    .endif

    ; ---- 7. მობილური: 6-დან 15 ციფრამდე ----
    invoke velis_sigrdze, IDC_MOB
    .if eax < 6 || eax > 15
        invoke shecdoma, T_V_MOB, IDC_MOB
        ret
    .endif

    ; ---- 8. ელ-ფოსტა (თუ შეყვანილია) ----
    invoke GetDlgItem, hMainWnd, IDC_EMAIL
    invoke GetWindowTextW, eax, offset vbuf, LENGTHOF vbuf
    .if eax != 0
        invoke emailis_shemowmeba, offset vbuf
        .if eax == 0
            invoke shecdoma, T_V_EMAIL, IDC_EMAIL
            ret
        .endif
    .endif

    ; ---- 9. GPA (თუ შეყვანილია) ----
    call gpas_shemowmeba
    .if eax == 0
        invoke shecdoma, T_V_GPA, IDC_GPA
        ret
    .endif

    ; ---- 10. სწავლის დასრულება დაწყებამდე ვერ იქნება ----
    invoke tarighi_ricxvad, IDC_END
    .if eax != 0
        mov edi, eax
        invoke tarighi_ricxvad, IDC_START
        .if edi < eax
            invoke shecdoma, T_V_DASRULEBA, IDC_END
            ret
        .endif
    .endif

    mov eax, 1                      ; ყველაფერი რიგზეა
    ret
shemowmeba ENDP
