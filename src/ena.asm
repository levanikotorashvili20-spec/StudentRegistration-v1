; ============================================================
; ena.asm — ენის მართვა: ტექსტის აღება და გადართვა
; (ui.asm-ის შემდეგ უნდა იყოს ჩართული: იყენებს kontrolebi ცხრილს)
; ============================================================

.code

; ------------------------------------------------------------
; get_text — აბრუნებს id ნომრის ტექსტს მიმდინარე ენაზე
; შედეგი: eax = UTF-16 სტრიქონის მისამართი (wbuf)
; ყურადღება: wbuf საერთოა — შედეგი მაშინვე გამოიყენე
; ------------------------------------------------------------
get_text PROC id:DWORD
    mov eax, ena
    mov eax, teqstebi[eax*4]        ; მიმდინარე ენის ცხრილი
    mov ecx, id
    mov eax, [eax + ecx*4]          ; UTF-8 ტექსტის მისამართი
    invoke MultiByteToWideChar, CP_UTF8, 0, eax, -1, offset wbuf, LENGTHOF wbuf
    mov eax, offset wbuf
    ret
get_text ENDP

; ------------------------------------------------------------
; apply_language — ყველა წარწერას მიმდინარე ენაზე ცვლის
; ------------------------------------------------------------
apply_language PROC USES esi edi ebx
    LOCAL lvc:LVCOLUMNW

    ; ფანჯრის სათაური
    invoke get_text, T_SATAURI
    invoke SetWindowTextW, hMainWnd, eax

    ; ცხრილის ყველა კონტროლი, რომელსაც წარწერა აქვს
    mov esi, offset kontrolebi
    mov edi, kontrolebi_raod
en_cikli:
    mov eax, [esi].CTL.k_teqsti
    cmp eax, NO_TEXT
    je en_shemdegi
    invoke get_text, eax
    mov ebx, eax                    ; ტექსტის მისამართი
    invoke GetDlgItem, hMainWnd, [esi].CTL.k_id
    invoke SetWindowTextW, eax, ebx
en_shemdegi:
    add esi, SIZEOF CTL
    dec edi
    jnz en_cikli

    ; შედეგების ცხრილის სვეტების სათაურები
    lea edi, lvc                    ; სტრუქტურის განულება
    xor eax, eax
    mov ecx, SIZEOF LVCOLUMNW / 4
    rep stosd
    invoke GetDlgItem, hMainWnd, IDC_SIA
    mov ebx, eax
    xor edi, edi
sv_cikli:
    invoke get_text, sv_teqstebi[edi*4]
    mov lvc.imask, LVCF_FMT or LVCF_TEXT
    mov lvc.fmt, LVCFMT_LEFT
    mov lvc.pszText, eax
    invoke SendMessageW, ebx, LVM_SETCOLUMNW, edi, addr lvc
    inc edi
    cmp edi, SV_RAOD
    jb sv_cikli
    ret
apply_language ENDP

; ------------------------------------------------------------
; toggle_language — ქართული <-> English
; ------------------------------------------------------------
toggle_language PROC
    xor ena, 1
    call apply_language
    ret
toggle_language ENDP
