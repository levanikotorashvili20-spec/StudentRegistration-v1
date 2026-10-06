; ============================================================
; click.asm — WM_COMMAND: ღილაკებზე დაჭერის დამუშავება
; ============================================================

.code

on_command PROC wParam:DWORD
    mov eax, wParam
    movzx ecx, ax                   ; ქვედა 16 ბიტი: კონტროლის ID
    shr eax, 16                     ; ზედა 16 ბიტი: შეტყობინების კოდი

    .if ecx == IDC_LANG && eax == BN_CLICKED
        call toggle_language
        call rejimis_dayeneba       ; რეჟიმის ღილაკები ახალ ენაზე

    .elseif ecx == IDC_QVEYANA && eax == CBN_SELCHANGE
        call regionebis_shevseba    ; ქვეყანა შეიცვალა

    .elseif ecx == IDC_REGIONI && eax == CBN_SELCHANGE
        call qalaqebis_shevseba     ; რეგიონი შეიცვალა

    .elseif ecx == IDC_REGISTRACIA && eax == BN_CLICKED
        .if mimdinare_id == 0
            call registracia        ; „რეგისტრაცია“: ახალი სტუდენტი
        .else
            call shenaxva           ; „შენახვა“: ჩატვირთულის ცვლილებები
        .endif

    .elseif ecx == IDC_GASUFTAVEBA && eax == BN_CLICKED
        call formis_gasuftaveba     ; „გასუფთავება“ / „ახალი“

    .elseif ecx == IDC_WASHLA && eax == BN_CLICKED
        call washla                 ; ფორმის „წაშლა“: ჩატვირთული სტუდენტი

    .elseif ecx == IDC_DZ_WASHLA && eax == BN_CLICKED
        call archeulis_washla       ; ძებნის „წაშლა“: მონიშნული სტრიქონი

    .elseif ecx == IDC_DZ_GHILAKI && eax == BN_CLICKED
        call dzebna

    .elseif ecx == IDOK
        ; Enter: თუ კურსორი ძებნის ველშია — ვეძებთ
        invoke GetFocus
        mov ecx, eax
        push ecx
        invoke GetDlgItem, hMainWnd, IDC_DZ_PIRADI
        pop ecx
        .if eax == ecx
            call dzebna
        .endif
    .endif
    ret
on_command ENDP
