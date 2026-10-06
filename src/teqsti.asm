; ============================================================
; teqsti.asm — ინტერფეისის ტექსტები ორ ენაზე
; ფაილი UTF-8-შია (BOM-ის გარეშე). პროგრამაში ტექსტი
; MultiByteToWideChar-ით UTF-16-ში გადაიყვანება (ena.asm).
;
; ახალი ტექსტის დამატება:
;   1. დაამატე T_ კონსტანტა შემდეგი ნომრით
;   2. დაწერე ორივე ენაზე (ka_ და en_)
;   3. დაამატე მისამართები teqsti_ka-სა და teqsti_en-ში, იმავე რიგით
; ============================================================

T_SATAURI       equ 0
T_ENA_GHILAKI   equ 1
T_SAXELI        equ 2
T_GVARI         equ 3
T_MAMIS_SAXELI  equ 4
T_DAB_TARIGHI   equ 5
T_ASAKI         equ 6
T_MOQALAQEOBA   equ 7
T_PIRADI        equ 8
T_QVEYANA       equ 9
T_REGIONI       equ 10
T_QALAQI        equ 11
T_QUCHA         equ 12
T_SAXLI_BINA    equ 13
T_INDEKSI       equ 14
T_MOBILURI      equ 15
T_EMAIL         equ 16
T_GPA           equ 17
T_SWAVLA_START  equ 18
T_SWAVLA_END    equ 19
T_REGISTRACIA   equ 20
T_GASUFTAVEBA   equ 21
T_DZEBNA        equ 22
T_SHECDOMA_GEO  equ 23
T_SHECDOMA_STUD equ 24
T_DAREGISTRIRDA equ 25
T_UKVE_ARSEBOBS equ 26
T_SHEAVSE_VELEBI equ 27
T_SHEIYVANE_NOMERI equ 28
T_VER_MOIDZEBNA equ 29
T_V_SAXELI      equ 30
T_V_GVARI       equ 31
T_V_MOQ         equ 32
T_V_PIRADI      equ 33
T_V_PIRADI_GE   equ 34
T_V_QVEYANA     equ 35
T_V_QALAQI      equ 36
T_V_MOB         equ 37
T_V_EMAIL       equ 38
T_V_GPA         equ 39
T_V_DAB         equ 40
T_V_DASRULEBA   equ 41
T_SHENAXVA      equ 42
T_AXALI         equ 43
T_WASHLA        equ 44
T_SHENAXULIA    equ 45
T_DADASTURE     equ 46
T_WASHLILIA     equ 47
T_GAXSNA        equ 48

.data
; ---------- ქართული ----------
ka_satauri      db "სტუდენტების რეგისტრაცია", 0
ka_ena_ghilaki  db "English", 0         ; ღილაკზე მეორე ენის სახელი ჩანს
ka_saxeli       db "სახელი", 0
ka_gvari        db "გვარი", 0
ka_mamis_saxeli db "მამის სახელი", 0
ka_dab_tarighi  db "დაბადების თარიღი", 0
ka_asaki        db "ასაკი:", 0
ka_moqalaqeoba  db "მოქალაქეობა", 0
ka_piradi       db "პირადი ნომერი", 0
ka_qveyana      db "ქვეყანა", 0
ka_regioni      db "რეგიონი", 0
ka_qalaqi       db "ქალაქი", 0
ka_qucha        db "ქუჩა", 0
ka_saxli_bina   db "სახლი / ბინა", 0
ka_indeksi      db "საფოსტო ინდექსი", 0
ka_mobiluri     db "მობილური", 0
ka_email        db "ელ-ფოსტა", 0
ka_gpa          db "GPA", 0
ka_swavla_start db "სწავლის დაწყება", 0
ka_swavla_end   db "სწავლის დასრულება", 0
ka_registracia  db "რეგისტრაცია", 0
ka_gasuftaveba  db "გასუფთავება", 0
ka_dzebna       db "ძებნა", 0
ka_shecdoma_geo db "ვერ მოიძებნა ქვეყნების ბაზა: data\geo.db", 0
ka_shecdoma_stud db "ვერ გაიხსნა სტუდენტების ბაზა: data\students.db", 0
ka_daregistrirda db "სტუდენტი წარმატებით დარეგისტრირდა.", 0
ka_ukve_arsebobs db "ამ ქვეყნის ამ პირადი ნომრით სტუდენტი უკვე რეგისტრირებულია.", 0
ka_sheavse_velebi db "შეავსე სავალდებულო ველები: სახელი, გვარი, პირადი ნომერი, ქალაქი, მობილური.", 0
ka_sheiyvane_nomeri db "შეიყვანე საძიებო პირადი ნომერი.", 0
ka_ver_moidzebna db "ამ პირადი ნომრით სტუდენტი ვერ მოიძებნა.", 0
ka_v_saxeli db "შეიყვანე სახელი.", 0
ka_v_gvari db "შეიყვანე გვარი.", 0
ka_v_moq db "აირჩიე მოქალაქეობა.", 0
ka_v_piradi db "შეიყვანე პირადი ნომერი.", 0
ka_v_piradi_ge db "საქართველოს მოქალაქის პირადი ნომერი ზუსტად 11 ციფრისგან შედგება.", 0
ka_v_qveyana db "აირჩიე ქვეყანა.", 0
ka_v_qalaqi db "აირჩიე ან ჩაწერე ქალაქი.", 0
ka_v_mob db "შეიყვანე მობილურის ნომერი (6-დან 15 ციფრამდე).", 0
ka_v_email db "ელ-ფოსტის მისამართი არასწორია (მაგ. name@example.com).", 0
ka_v_gpa db "GPA უნდა იყოს რიცხვი 0-დან არჩეულ სკალამდე, მაგ. 3.75", 0
ka_v_dab db "დაბადების თარიღი არასწორია: ასაკი 14-დან 100 წლამდე უნდა იყოს.", 0
ka_v_dasruleba db "სწავლის დასრულება დაწყებამდე ვერ იქნება.", 0
ka_shenaxva db "შენახვა", 0
ka_axali db "ახალი", 0
ka_washla db "წაშლა", 0
ka_shenaxulia db "ცვლილებები შენახულია.", 0
ka_dadasture db "ნამდვილად გინდა ამ სტუდენტის წაშლა? ამის გაუქმება შეუძლებელი იქნება.", 0
ka_washlilia db "სტუდენტი წაიშალა.", 0
ka_gaxsna db "გახსნა", 0

; ---------- English ----------
en_satauri      db "Student Registration", 0
en_ena_ghilaki  db "ქართული", 0
en_saxeli       db "First name", 0
en_gvari        db "Last name", 0
en_mamis_saxeli db "Father's name", 0
en_dab_tarighi  db "Date of birth", 0
en_asaki        db "Age:", 0
en_moqalaqeoba  db "Citizenship", 0
en_piradi       db "Personal ID", 0
en_qveyana      db "Country", 0
en_regioni      db "Region", 0
en_qalaqi       db "City", 0
en_qucha        db "Street", 0
en_saxli_bina   db "House / Apt.", 0
en_indeksi      db "Postal code", 0
en_mobiluri     db "Mobile", 0
en_email        db "E-mail", 0
en_gpa          db "GPA", 0
en_swavla_start db "Study start", 0
en_swavla_end   db "Study end", 0
en_registracia  db "Register", 0
en_gasuftaveba  db "Clear", 0
en_dzebna       db "Search", 0
en_shecdoma_geo db "Countries database not found: data\geo.db", 0
en_shecdoma_stud db "Could not open the students database: data\students.db", 0
en_daregistrirda db "The student has been registered.", 0
en_ukve_arsebobs db "A student with this citizenship and personal ID is already registered.", 0
en_sheavse_velebi db "Please fill in the required fields: first name, last name, personal ID, city, mobile.", 0
en_sheiyvane_nomeri db "Enter a personal ID to search for.", 0
en_ver_moidzebna db "No student found with this personal ID.", 0
en_v_saxeli db "Enter the first name.", 0
en_v_gvari db "Enter the last name.", 0
en_v_moq db "Select the citizenship.", 0
en_v_piradi db "Enter the personal ID.", 0
en_v_piradi_ge db "A Georgian personal ID consists of exactly 11 digits.", 0
en_v_qveyana db "Select the country.", 0
en_v_qalaqi db "Select or type the city.", 0
en_v_mob db "Enter a mobile number (6 to 15 digits).", 0
en_v_email db "The e-mail address is not valid (e.g. name@example.com).", 0
en_v_gpa db "GPA must be a number from 0 to the selected scale, e.g. 3.75", 0
en_v_dab db "Invalid date of birth: age must be between 14 and 100.", 0
en_v_dasruleba db "The study end date cannot be before the start date.", 0
en_shenaxva db "Save", 0
en_axali db "New", 0
en_washla db "Delete", 0
en_shenaxulia db "Changes saved.", 0
en_dadasture db "Do you really want to delete this student? This cannot be undone.", 0
en_washlilia db "The student has been deleted.", 0
en_gaxsna db "Open", 0

; ---------- ცხრილები (რიგი = T_ ნომრები!) ----------
teqsti_ka   dd ka_satauri, ka_ena_ghilaki, ka_saxeli, ka_gvari
            dd ka_mamis_saxeli, ka_dab_tarighi, ka_asaki, ka_moqalaqeoba
            dd ka_piradi, ka_qveyana, ka_regioni, ka_qalaqi
            dd ka_qucha, ka_saxli_bina, ka_indeksi, ka_mobiluri
            dd ka_email, ka_gpa, ka_swavla_start, ka_swavla_end
            dd ka_registracia, ka_gasuftaveba, ka_dzebna, ka_shecdoma_geo
            dd ka_shecdoma_stud, ka_daregistrirda, ka_ukve_arsebobs, ka_sheavse_velebi
            dd ka_sheiyvane_nomeri, ka_ver_moidzebna
            dd ka_v_saxeli, ka_v_gvari, ka_v_moq, ka_v_piradi, ka_v_piradi_ge, ka_v_qveyana
            dd ka_v_qalaqi, ka_v_mob, ka_v_email, ka_v_gpa, ka_v_dab, ka_v_dasruleba
            dd ka_shenaxva, ka_axali, ka_washla, ka_shenaxulia, ka_dadasture, ka_washlilia
            dd ka_gaxsna

teqsti_en   dd en_satauri, en_ena_ghilaki, en_saxeli, en_gvari
            dd en_mamis_saxeli, en_dab_tarighi, en_asaki, en_moqalaqeoba
            dd en_piradi, en_qveyana, en_regioni, en_qalaqi
            dd en_qucha, en_saxli_bina, en_indeksi, en_mobiluri
            dd en_email, en_gpa, en_swavla_start, en_swavla_end
            dd en_registracia, en_gasuftaveba, en_dzebna, en_shecdoma_geo
            dd en_shecdoma_stud, en_daregistrirda, en_ukve_arsebobs, en_sheavse_velebi
            dd en_sheiyvane_nomeri, en_ver_moidzebna
            dd en_v_saxeli, en_v_gvari, en_v_moq, en_v_piradi, en_v_piradi_ge, en_v_qveyana
            dd en_v_qalaqi, en_v_mob, en_v_email, en_v_gpa, en_v_dab, en_v_dasruleba
            dd en_shenaxva, en_axali, en_washla, en_shenaxulia, en_dadasture, en_washlilia
            dd en_gaxsna

teqstebi    dd teqsti_ka, teqsti_en     ; ena = 0 -> ქართული, 1 -> English
