; ============================================================
; sqlite3.inc — SQLite-ის ფუნქციების აღწერები
; SQLite C-ის გამოძახების წესს იყენებს (cdecl), ამიტომ PROTO C:
; invoke თავად გაასუფთავებს სტეკს გამოძახების შემდეგ.
; ============================================================

; ბიბლიოთეკა პროექტის lib საქაღალდიდან
; (ლინკერი პროექტის საქაღალდიდან ეშვება, ამიტომ გზა მისგან ითვლება)
includelib lib\sqlite3.lib

; ---------- შედეგის კოდები ----------
SQLITE_OK           equ 0
SQLITE_ROW          equ 100         ; sqlite3_step: კიდევ არის სტრიქონი
SQLITE_DONE         equ 101         ; sqlite3_step: სტრიქონები დამთავრდა
SQLITE_TRANSIENT    equ -1          ; bind: SQLite ტექსტს თავისთვის დაიკოპირებს
SQLITE_CONSTRAINT_NOTNULL equ 1299  ; NOT NULL სვეტი ცარიელია
SQLITE_CONSTRAINT_UNIQUE  equ 2067  ; UNIQUE: ასეთი ჩანაწერი უკვე არის

; ---------- ფუნქციები ----------
sqlite3_open16          PROTO C :DWORD, :DWORD
sqlite3_close           PROTO C :DWORD
sqlite3_exec            PROTO C :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
sqlite3_errmsg16        PROTO C :DWORD
sqlite3_extended_errcode PROTO C :DWORD
sqlite3_prepare_v2      PROTO C :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
sqlite3_step            PROTO C :DWORD
sqlite3_finalize        PROTO C :DWORD
sqlite3_reset           PROTO C :DWORD
sqlite3_bind_text16     PROTO C :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
sqlite3_bind_int        PROTO C :DWORD, :DWORD, :DWORD
sqlite3_bind_null       PROTO C :DWORD, :DWORD
sqlite3_column_text16   PROTO C :DWORD, :DWORD
sqlite3_column_int      PROTO C :DWORD, :DWORD
