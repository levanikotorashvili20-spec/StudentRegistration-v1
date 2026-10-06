; ============================================================
; db.asm — ბაზების პოვნა და გახსნა
;
; data საქაღალდეს ორ ადგილას ვეძებთ (იქ, სადაც geo.db დევს):
;   1. exe-ს გვერდით:        <exe>\data\        (მზა პროგრამა, Release)
;   2. ერთი დონით ზემოთ:      <exe>\..\data\     (Visual Studio-დან: exe Debug-შია)
; students.db იმავე data საქაღალდეშია.
; ============================================================

.data
WSTR szData1,     <data\>
WSTR szData2,     <..\data\>
WSTR szGeoFile,   <geo.db>
WSTR szStudFile,  <students.db>

; სტუდენტების ცხრილი — იგივე, რაც tools\gen_students.sql-ში
sqlSqema    db "CREATE TABLE IF NOT EXISTS students ("
            db "id INTEGER PRIMARY KEY, saxeli TEXT NOT NULL, gvari TEXT NOT NULL, "
            db "mamis_saxeli TEXT, dab_tarighi TEXT NOT NULL, moqalaqeoba TEXT NOT NULL, "
            db "piradi_nomeri TEXT NOT NULL, qveyana TEXT NOT NULL, regioni TEXT, "
            db "qalaqi TEXT NOT NULL, qucha TEXT, saxlis_n TEXT, bina TEXT, indeksi TEXT, "
            db "mob_nomeri TEXT NOT NULL, email TEXT, gpa REAL, gpa_skala REAL, "
            db "registr_tarighi TEXT NOT NULL DEFAULT (datetime('now', 'localtime')), "
            db "swavla_start TEXT NOT NULL, swavla_end TEXT, "
            db "UNIQUE (moqalaqeoba, piradi_nomeri)); "
            db "CREATE INDEX IF NOT EXISTS idx_students_saxeli ON students (gvari, saxeli)", 0

.data?
exe_dir         dw MAX_PATH dup(?)      ; exe-ს საქაღალდე, ბოლოში "\"-ით
data_dir        dw MAX_PATH dup(?)      ; data საქაღალდე, ბოლოში "\"-ით
db_path         dw MAX_PATH dup(?)      ; ბაზის სრული გზა
hGeo            dd ?                    ; geo.db
hStud           dd ?                    ; students.db

.code

; ------------------------------------------------------------
; exe_dir_povna — exe_dir = exe ფაილის საქაღალდე
; ------------------------------------------------------------
exe_dir_povna PROC
    invoke GetModuleFileNameW, NULL, offset exe_dir, MAX_PATH

    ; ბოლო "\"-ის პოვნა: ecx ათვალიერებს, edx იმახსოვრებს
    mov ecx, offset exe_dir
    mov edx, ecx
ed_cikli:
    mov ax, [ecx]
    test ax, ax                     ; სტრიქონის ბოლო?
    jz ed_bolo
    cmp ax, '\'
    jne ed_shemdegi
    mov edx, ecx
ed_shemdegi:
    add ecx, 2                      ; UTF-16: თითო სიმბოლო 2 ბაიტია
    jmp ed_cikli
ed_bolo:
    mov word ptr [edx + 2], 0       ; "\"-ის შემდეგ ვჭრით (ფაილის სახელი ქრება)
    ret
exe_dir_povna ENDP

; ------------------------------------------------------------
; arsebobs — არსებობს თუ არა ფაილი
; eax = 1 არსებობს, 0 არ არსებობს
; ------------------------------------------------------------
arsebobs PROC gza:DWORD
    invoke GetFileAttributesW, gza
    cmp eax, INVALID_FILE_ATTRIBUTES
    je ar_ara
    mov eax, 1
    ret
ar_ara:
    xor eax, eax
    ret
arsebobs ENDP

; ------------------------------------------------------------
; data_dir_povna — data საქაღალდე იქ, სადაც geo.db დევს
; შედეგი: data_dir, db_path = geo.db-ის გზა; eax = 1 ნაპოვნია, 0 არა
; ------------------------------------------------------------
data_dir_povna PROC
    call exe_dir_povna

    ; 1. exe-ს გვერდით
    invoke lstrcpyW, offset data_dir, offset exe_dir
    invoke lstrcatW, offset data_dir, offset szData1
    invoke lstrcpyW, offset db_path, offset data_dir
    invoke lstrcatW, offset db_path, offset szGeoFile
    invoke arsebobs, offset db_path
    test eax, eax
    jnz dp_dasasruli

    ; 2. ერთი დონით ზემოთ
    invoke lstrcpyW, offset data_dir, offset exe_dir
    invoke lstrcatW, offset data_dir, offset szData2
    invoke lstrcpyW, offset db_path, offset data_dir
    invoke lstrcatW, offset db_path, offset szGeoFile
    invoke arsebobs, offset db_path
dp_dasasruli:
    ret
data_dir_povna ENDP

; ------------------------------------------------------------
; geo_gaxsna — geo.db-ის პოვნა და გახსნა
; eax = 1 წარმატება, 0 ვერ მოიძებნა ან ვერ გაიხსნა
; ------------------------------------------------------------
geo_gaxsna PROC
    call data_dir_povna
    test eax, eax
    jz gg_ver
    invoke sqlite3_open16, offset db_path, offset hGeo
    cmp eax, SQLITE_OK
    jne gg_ver
    mov eax, 1
    ret
gg_ver:
    xor eax, eax
    ret
geo_gaxsna ENDP

; ------------------------------------------------------------
; students_gaxsna — students.db-ის გახსნა (თუ არ არსებობს, შეიქმნება)
; და ცხრილის შექმნა, თუ ჯერ არ არის.
; geo_gaxsna-ს შემდეგ უნდა გამოიძახო (data_dir უკვე ცნობილია)
; eax = 1 წარმატება, 0 შეცდომა
; ------------------------------------------------------------
students_gaxsna PROC
    invoke lstrcpyW, offset db_path, offset data_dir
    invoke lstrcatW, offset db_path, offset szStudFile
    invoke sqlite3_open16, offset db_path, offset hStud
    cmp eax, SQLITE_OK
    jne sg_ver
    invoke sqlite3_exec, hStud, offset sqlSqema, NULL, NULL, NULL
    cmp eax, SQLITE_OK
    jne sg_ver
    mov eax, 1
    ret
sg_ver:
    xor eax, eax
    ret
students_gaxsna ENDP
