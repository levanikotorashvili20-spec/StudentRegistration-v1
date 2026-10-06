; ============================================================
; main.asm — StudentRegistration v1
; ბილდში მხოლოდ ეს ფაილი შედის. დანარჩენი include-ით ემატება.
; ============================================================

.386
.model flat, stdcall
option casemap:none

include win32.inc       ; Windows API: კონსტანტები, სტრუქტურები, PROTO-ები
include sqlite3.inc     ; SQLite-ის ფუნქციები
include cvladebi.asm    ; ცვლადები და კონტროლების ID-ები
include teqsti.asm      ; ინტერფეისის ტექსტები (ka / en)
include ui.asm          ; კონტროლების ცხრილი, შექმნა, განლაგება
include ena.asm         ; ენის მართვა (ui.asm-ის შემდეგ!)
include db.asm          ; ბაზების პოვნა და გახსნა
include geo.asm         ; ქვეყნები, რეგიონები, ქალაქები
include registracia.asm ; რეგისტრაცია, გასუფთავება, ასაკი
include shemowmeba.asm  ; ველების შემოწმება
include dzebna.asm      ; ძებნა პირადი ნომრით
include chatvirtva.asm  ; სტუდენტის ჩატვირთვა ფორმაში
include redaqtireba.asm ; შენახვა და წაშლა
include click.asm       ; ღილაკების დამუშავება

.code

; ------------------------------------------------------------
; WndProc — მთავარი ფანჯრის შეტყობინებები
; ------------------------------------------------------------
WndProc PROC hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    .if uMsg == WM_CREATE
        mov eax, hWnd
        mov hMainWnd, eax
        invoke create_controls, hWnd
        call apply_language
        call qveynebis_shevseba
        call regionebis_shevseba    ; საქართველოს რეგიონები და +995
        call asakis_gamotvla
        call rejimis_dayeneba       ; ახალი სტუდენტის რეჟიმი („წაშლა“ დამალულია)
        xor eax, eax
        ret

    .elseif uMsg == WM_NOTIFY
        ; დაბადების თარიღის ამრჩევიდან -> ასაკის გადათვლა
        mov eax, lParam
        .if [eax].NMHDR.idFrom == IDC_DAB
            call asakis_gamotvla
        .elseif [eax].NMHDR.idFrom == IDC_SIA
            mov ecx, [eax].NMHDR.nm_code
            .if ecx == NM_DBLCLK
                call archeulis_chatvirtva       ; ორჯერ დაწკაპუნება -> ფორმაში
            .elseif ecx == NM_RCLICK
                call konteqsturi_menu           ; მარჯვენა ღილაკი -> მენიუ
            .elseif ecx == LVN_ITEMCHANGED
                call washlis_ghilakis_ganaxleba ; მონიშვნა შეიცვალა
            .elseif ecx == LVN_KEYDOWN
                .if word ptr [eax + 12] == VK_DELETE
                    call archeulis_washla       ; Delete კლავიში -> წაშლა
                .endif
            .endif
        .endif
        xor eax, eax
        ret

    .elseif uMsg == WM_SIZE
        invoke on_size, lParam
        xor eax, eax
        ret

    .elseif uMsg == WM_GETMINMAXINFO
        ; ფანჯარა ამაზე პატარა ვერ გახდება
        mov eax, lParam
        mov ecx, min_sigane
        mov [eax].MINMAXINFO.ptMinTrackSize.x, ecx
        mov ecx, min_simagle
        mov [eax].MINMAXINFO.ptMinTrackSize.y, ecx
        xor eax, eax
        ret

    .elseif uMsg == WM_COMMAND
        invoke on_command, wParam
        xor eax, eax
        ret

    .elseif uMsg == WM_DESTROY
        invoke sqlite3_close, hGeo
        invoke sqlite3_close, hStud
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
    .endif

    invoke DefWindowProcW, hWnd, uMsg, wParam, lParam
    ret
WndProc ENDP

; ------------------------------------------------------------
; WinMain — მომზადება, ფანჯრის შექმნა, შეტყობინებების ციკლი
; ------------------------------------------------------------
WinMain PROC USES ebx
    LOCAL wc:WNDCLASSEXW
    LOCAL msg:MSG
    LOCAL icc:INITCOMMONCONTROLSEX
    LOCAL fsigane:DWORD, fsimagle:DWORD

    ; ეკრანის მასშტაბი (DPI): Windows აღარ გაწელავს ფანჯარას,
    ; კოორდინატებს თავად ვამრავლებთ (ui.asm, masshtabi)
    invoke SetProcessDPIAware
    invoke GetDC, NULL
    mov ebx, eax
    invoke GetDeviceCaps, ebx, LOGPIXELSX
    mov dpi, eax
    invoke ReleaseDC, NULL, ebx

    ; თანამედროვე კონტროლები: თარიღის ამრჩევი, ცხრილი
    mov icc.dwSize, SIZEOF INITCOMMONCONTROLSEX
    mov icc.dwICC, ICC_STANDARD_CLASSES or ICC_LISTVIEW_CLASSES or ICC_DATE_CLASSES
    invoke InitCommonControlsEx, addr icc

    ; ქვეყნების ბაზა: თუ ვერ მოიძებნა, პროგრამა ჩერდება
    call geo_gaxsna
    .if eax == 0
        invoke get_text, T_SHECDOMA_GEO
        invoke MessageBoxW, NULL, eax, NULL, MB_ICONERROR
        xor eax, eax
        ret
    .endif

    ; სტუდენტების ბაზა (თუ არ არსებობს, შეიქმნება)
    call students_gaxsna
    .if eax == 0
        invoke get_text, T_SHECDOMA_STUD
        invoke MessageBoxW, NULL, eax, NULL, MB_ICONERROR
        xor eax, eax
        ret
    .endif

    ; ფანჯრის ზომები: მინიმალური და საწყისი
    invoke fanjris_zoma, MIN_SIGANE, MIN_SIMAGLE
    mov min_sigane, eax
    mov min_simagle, edx
    invoke fanjris_zoma, SAWYISI_SIGANE, SAWYISI_SIMAGLE
    mov fsigane, eax
    mov fsimagle, edx

    ; ფანჯრის კლასი
    mov wc.cbSize, SIZEOF WNDCLASSEXW
    mov wc.style, 0
    mov wc.lpfnWndProc, offset WndProc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    mov eax, hInstance
    mov wc.hInstance, eax
    ; აიქონი რესურსებიდან (app.rc):
    ; დიდი — Alt+Tab-ისა და ამოცანების ზოლისთვის, პატარა — სათაურის ზოლისთვის
    invoke LoadIconW, hInstance, IDI_APP
    mov wc.hIcon, eax
    invoke GetSystemMetrics, SM_CYSMICON
    push eax
    invoke GetSystemMetrics, SM_CXSMICON
    pop ecx
    invoke LoadImageW, hInstance, IDI_APP, IMAGE_ICON, eax, ecx, LR_DEFAULTCOLOR
    mov wc.hIconSm, eax
    invoke LoadCursorW, NULL, IDC_ARROW
    mov wc.hCursor, eax
    mov wc.hbrBackground, COLOR_BTNFACE + 1
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, offset szClass
    invoke RegisterClassExW, addr wc

    ; ფანჯარა: ზომის შეცვლა და მაქსიმიზაცია ჩართულია
    invoke CreateWindowExW, 0, offset szClass, NULL, \
           WS_OVERLAPPEDWINDOW, \
           CW_USEDEFAULT, CW_USEDEFAULT, fsigane, fsimagle, \
           NULL, NULL, hInstance, NULL

    invoke ShowWindow, hMainWnd, SW_SHOWNORMAL
    invoke UpdateWindow, hMainWnd

msg_loop:
    invoke GetMessageW, addr msg, NULL, 0, 0
    cmp eax, 0
    jle msg_done                    ; 0 = WM_QUIT, -1 = შეცდომა
    invoke IsDialogMessageW, hMainWnd, addr msg   ; Tab: ველებს შორის გადასვლა
    test eax, eax
    jnz msg_loop
    invoke TranslateMessage, addr msg
    invoke DispatchMessageW, addr msg
    jmp msg_loop

msg_done:
    mov eax, msg.wParam
    ret
WinMain ENDP

; ------------------------------------------------------------
; პროგრამის დასაწყისი (Entry Point)
; ------------------------------------------------------------
start:
    invoke GetModuleHandleW, NULL
    mov hInstance, eax
    call WinMain
    invoke ExitProcess, eax

end start
