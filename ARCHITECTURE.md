# Architecture

## Build model

Only `src\main.asm` is assembled. All other source files are pulled in with `include`, in dependency order:

| File | Purpose |
|---|---|
| `win32.inc` | Windows API: constants, structures, prototypes (no MASM32 SDK needed) |
| `sqlite3.inc` | SQLite prototypes (`PROTO C`, because SQLite uses the cdecl calling convention) |
| `cvladebi.asm` | Global variables, control IDs, window sizes |
| `teqsti.asm` | All interface texts in Georgian and English |
| `ui.asm` | Control table, control creation, layout, DPI scaling, resizing |
| `ena.asm` | Language switching |
| `db.asm` | Locating and opening the databases |
| `geo.asm` | Country / region / city lists |
| `registracia.asm` | Reading the form, registration (INSERT), clearing, age calculation, form modes |
| `shemowmeba.asm` | Input validation |
| `dzebna.asm` | Search |
| `chatvirtva.asm` | Loading a student into the form |
| `redaqtireba.asm` | Saving changes (UPDATE), deleting, right-click menu |
| `click.asm` | `WM_COMMAND`: button and list events |

## Key ideas

### 1. Table-driven user interface

All controls are described in one table (`kontrolebi` in `ui.asm`): class, style, position, size, ID and text number. A single loop in `create_controls` creates all of them. Adding a field means adding one line to the table.

Coordinates are written for 96 DPI (100% scaling). `masshtabi` multiplies them by the real screen DPI (`MulDiv`), so the window stays sharp on high-resolution displays.

### 2. Bilingual texts

Texts are stored as UTF-8 in `teqsti.asm` in two pointer tables (Georgian and English) indexed by `T_` constants. `get_text` picks the current language and converts the text to UTF-16 with `MultiByteToWideChar`, because all Windows calls use the `W` (Unicode) functions. `apply_language` walks the control table and updates every label.

### 3. One field table, two directions

`reg_velebi` (in `registracia.asm`) has 19 rows, one per database column: where the value comes from and how to read it (`V_TEXT`, `V_LIST`, `V_ISO`, `V_DATE`, `V_TEL`).

- **Form → database:** `velebis_mibma` binds the 19 values to `?1`…`?19`. Both INSERT (register) and UPDATE (save) use it.
- **Database → form:** `studentis_chatvirtva` reads a record and fills the form using the same table in reverse. The order matters: the country is set before the region and the region before the city, so each list is already filled when it is needed.

### 4. ISO country code inside a list item

The ISO code "GE" in UTF-16 is exactly 4 bytes, which is one DWORD. It is attached directly to each combo box item (`CB_SETITEMDATA`), so no extra lookup table is needed. It is passed to SQLite straight from that DWORD: `sqlite3_bind_text16(stmt, n, addr iso, 4, SQLITE_TRANSIENT)`.

### 5. SQLite from Assembly

- SQLite uses the cdecl calling convention, so its functions are declared with `PROTO C` and `invoke` cleans the stack automatically.
- The import library `sqlite3.lib` is created from `sqlite3.def` with `lib /def:sqlite3.def /machine:x86`.
- Values are always passed as bound parameters (`?1`, `?2`, …), never by concatenating strings into SQL.
- Duplicate personal IDs and empty required fields are recognized by SQLite's extended error codes (`SQLITE_CONSTRAINT_UNIQUE`, `SQLITE_CONSTRAINT_NOTNULL`).

### 6. Form modes

`mimdinare_id` holds the ID of the student loaded into the form: `0` means a new student. `rejimis_dayeneba` switches the buttons between *Register / Clear* and *Save / New / Delete*.

### 7. Finding the data folder

The program looks for `data\geo.db` next to the exe, and then one level up (`..\data\`). The second location is where it is when running from Visual Studio, because the exe is built into `Debug\`. `students.db` is opened from the same folder.

## Databases

**`students.db`**, table `students`:

- `UNIQUE (moqalaqeoba, piradi_nomeri)`: a personal ID is unique within a citizenship. This index also makes the search instant.
- `INDEX (gvari, saxeli)`: for searching by name.
- Dates are stored as `YYYY-MM-DD`, phone numbers in international format (`+995555123456`).

**`geo.db`**, built by `tools\make_geo.sql`:

- `countries (iso2, name, name_ka, phonecode, postal_regex)`
- `states (id, country_iso, name, name_ka)`
- `cities (id, state_id, country_iso, name, name_ka)`

## Glossary

Identifiers are Georgian words written in Latin letters.

| Identifier | Meaning | Identifier | Meaning |
|---|---|---|---|
| `saxeli` | first name | `dzebna` | search |
| `gvari` | last name | `washla` | delete |
| `mamis_saxeli` | father's name | `shenaxva` | save |
| `dab_tarighi` | date of birth | `chatvirtva` | loading |
| `asaki` | age | `shemowmeba` | validation |
| `moqalaqeoba` | citizenship | `registracia` | registration |
| `piradi_nomeri` | personal ID | `gasuftaveba` | clearing |
| `qveyana` | country | `teqsti` | text |
| `regioni` | region | `ena` | language |
| `qalaqi` | city | `cvladebi` | variables |
| `qucha` | street | `sia` | list |
| `saxlis_n` / `bina` | house / apartment | `ghilaki` | button |
| `indeksi` | postal code | `shecdoma` | error |
| `mob_nomeri` | mobile number | `masshtabi` | scale (DPI) |
| `swavla_start` / `swavla_end` | study start / end | `mimdinare` | current |
