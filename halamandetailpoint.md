# PRD Revisi — Ekapoint & Detail Poin Customer

## 1. Tujuan

Perbaiki section **Poin & Hadiah / Ekapoint** pada halaman Customer dan implementasikan flow detail perolehan poin berdasarkan API loyalty yang sudah tersedia.

Flow utama:

```text
Customer
→ Ekapoint
→ Rincian Poin
→ Rincian Kategori
→ Sumber Pembelian
```

Fitur merupakan customer-facing feature.

Jangan menampilkan data accounting/internal perusahaan seperti:

- gross profit,
- gross profit percentage,
- formula internal,
- rule detail ID,
- calculation internal metadata,
- owner,
- created_by,
- updated_by.

---

# 2. Hierarki Data

Gunakan tiga level data berikut.

## Level 1 — Saldo Poin

Resource:

```text
loyalty_point_ledger
```

Filter:

```text
gpid = GP customer aktif
```

Field utama:

```text
earned_point
```

`earned_point` adalah saldo poin customer yang sudah siap digunakan sebagai nilai saldo.

JANGAN hitung ulang:

```text
earned_point - used_point
```

atau membuat formula saldo sendiri di Flutter.

Backend sudah menentukan nilai `earned_point`.

Field penting lain:

```text
calculation_id
period_name
ready
expired
valid_from
valid_to
```

Contoh:

```text
earned_point = 237
calculation_id = 36
period_name = LOYALTY-2026
ready = 1
expired = 0
valid_to = null
```

Tampilan:

```text
237 Poin
```

---

# 3. Jangan Gunakan fields ["*"]

Customer mobile jangan request semua field.

Untuk ledger gunakan field whitelist sesuai kebutuhan.

Contoh konsep:

```text
fields:
- calculation_id
- calculation_name
- earned_point
- period_name
- ready
- expired
- valid_from
- valid_to
```

Jangan mengambil field yang tidak dibutuhkan UI.

---

# 4. Perbaikan Section Poin di Customer Page

Pertahankan posisi:

```text
ENTITAS & CABANG PERUSAHAAN

POIN & HADIAH

TRANSAKSI
```

Jangan redesign bagian Customer lainnya.

---

# 5. Perbaikan Visual Card Ekapoint

Card sekarang memiliki ruang kanan yang terlalu kosong.

Perbaiki information hierarchy.

Gunakan layout:

```text
┌──────────────────────────────────────────┐
│ [icon] Ekapoint             Periode 2026 │
│                                          │
│ Saldo Poin Anda        ✓ Siap digunakan │
│ 237 Poin                                  │
│                                          │
│ Gunakan poin untuk berbagai reward       │
│ eksklusif Ekaplus                         │
│                                          │
│ [ Tukar Poin ]     [ Rincian Poin ]      │
└──────────────────────────────────────────┘
```

## Left area

Tampilkan:

```text
Saldo Poin Anda
237 Poin
```

Saldo merupakan elemen visual paling dominan.

## Right area

Gunakan untuk informasi ringkas:

```text
Periode 2026
```

dan jika relevan:

```text
Siap digunakan
```

Jika `valid_to != null`, boleh tampil:

```text
Berlaku sampai
30 Nov 2026
```

Jika `valid_to == null`, tidak wajib menampilkan teks expiry.

---

# 6. Warna

Jangan menjadikan kuning/gold sebagai primary application color.

Gunakan:

**Ekaplus Primary**

untuk:

- CTA utama,
- active state,
- navigation emphasis.

Gunakan **gold/yellow loyalty accent** hanya untuk:

- icon point,
- badge,
- aksen kecil,
- highlight angka point bila sesuai design.md.

Card tetap menggunakan:

- background putih,
- border/shadow sesuai `design.md`,
- warna teks existing Ekaplus.

Tujuannya agar Ekapoint masih terasa bagian dari aplikasi Ekaplus.

---

# 7. Hapus Katalog Lengkap di Header Section

Saat ini terdapat:

```text
POIN & HADIAH           Katalog Lengkap >
```

Hapus `Katalog Lengkap`.

Alasannya:

CTA tersebut memiliki tujuan yang sama dengan:

```text
Tukar Poin
```

Hindari dua entry point yang melakukan hal sama.

Section cukup:

```text
POIN & HADIAH

[Ekapoint Card]
```

---

# 8. Button Card

Gunakan dua CTA:

## Primary

```text
Tukar Poin
```

Action:

```text
→ Reward Catalog
```

## Secondary

Ubah:

```text
Riwayat & Detail
```

menjadi:

```text
Rincian Poin
```

Action:

```text
→ LoyaltyPointCalculationDetailPage
```

Jangan gunakan label `Riwayat & Detail` karena dua konsep berbeda.

---

# 9. Riwayat Penukaran

Riwayat redemption merupakan fitur berbeda dengan rincian calculation.

Jangan gabungkan dengan tombol `Rincian Poin`.

Jika dibutuhkan, sediakan entry:

```text
Riwayat Penukaran
```

di halaman Reward/Point Detail.

Riwayat ini menggunakan data redemption, bukan:

```text
loyalty_calculation_detail
```

dan bukan:

```text
loyalty_calculation_source
```

---

# 10. Page — Rincian Poin

Ketika user menekan:

```text
Rincian Poin
```

ambil:

```text
calculation_id
```

dari ledger aktif.

Contoh:

```text
calculation_id = 36
```

Kemudian load:

```text
loyalty_calculation_detail
```

dengan filter:

```text
calculation_id = 36
```

---

# 11. Safe Fields Calculation Detail

Jangan gunakan:

```text
fields: ["*"]
```

Request hanya:

```text
account
omzet_snapshot
standard_divider_snapshot
awarded_point
calculation_id
```

JANGAN REQUEST:

```text
gross_profit_snapshot
gp_percent_snapshot
formula_snapshot
raw_point
rule_detail_id
owner
created_by
updated_by
```

Data Gross Profit tidak boleh berada di customer-facing model.

---

# 12. Filtering Calculation Detail

Jangan tampilkan account yang benar-benar tidak mempunyai aktivitas:

```text
omzet_snapshot = 0
```

Tetapi:

**account dengan omzet > 0 dan awarded_point = 0 tetap ditampilkan.**

Contoh:

```text
Accessories

Total Pembelian
Rp2.850.000

Ketentuan
Rp20.000.000 = 1 poin

Poin Diperoleh
0 Poin
```

Ini penting karena customer memang melakukan pembelian, tetapi belum mencapai nilai yang menghasilkan satu poin.

Jangan menyembunyikan transaksi tersebut.

Filter utama:

```text
omzet_snapshot > 0
```

bukan:

```text
awarded_point > 0
```

---

# 13. Rincian Poin UI

Header:

```text
← Rincian Poin
```

Summary card:

```text
Periode 2026

Saldo Poin Saat Ini
237 Poin
```

Kemudian:

```text
PEROLEHAN BERDASARKAN KATEGORI
```

List seluruh kategori dengan omzet > 0.

---

# 14. Category Item

Gunakan compact card/list.

Contoh:

```text
Plastic

Total Pembelian
Rp2.234.875.000

Ketentuan Poin
Rp20.000.000 = 1 poin

Poin Diperoleh
+111 Poin

                                      >
```

Contoh:

```text
Kimia

Total Pembelian
Rp852.864.375

Ketentuan Poin
Rp20.000.000 = 1 poin

Poin Diperoleh
+42 Poin

                                      >
```

Jangan tampilkan formula:

```text
FLOOR(...)
```

Customer hanya perlu memahami:

```text
Total Pembelian
÷
Ketentuan Point
=
Poin
```

---

# 15. Sorting

Default sorting:

```text
awarded_point DESC
```

Kategori yang memberikan poin terbesar berada di atas.

Jika awarded point sama, urutkan berdasarkan:

```text
omzet_snapshot DESC
```

---

# 16. Category Dengan 0 Point

Jika omzet ada tetapi poin 0:

gunakan neutral state.

Contoh:

```text
Accessories

Rp2.850.000

Rp20.000.000 = 1 poin

Belum menghasilkan 1 poin
```

Jangan gunakan warna error.

Ini bukan kegagalan.

---

# 17. Tap Category

Setiap category item tappable.

Contoh user tap:

```text
Kimia
```

Navigate:

```text
Rincian Poin
→ Detail Kimia
```

Kemudian gunakan:

```text
loyalty_calculation_source
```

---

# 18. Source Filter

Filter wajib:

```text
calculation_id = selected calculation
AND
account = selected account
```

Contoh:

```text
calculation_id = 36
account = Penjualan Kimia
```

Jangan mengambil seluruh source calculation jika hanya satu kategori yang sedang dibuka.

---

# 19. Safe Fields Calculation Source

Jangan request:

```text
fields: ["*"]
```

Gunakan whitelist:

```text
account
omzet
branch_id
bc_refs
customer_count
calculation_id
```

JANGAN REQUEST:

```text
gross_profit
gp_percent
gcid
owner
created_by
updated_by
```

---

# 20. Source Filtering

Untuk halaman customer, hanya tampilkan source:

```text
omzet > 0
```

Jangan tampilkan source dengan omzet Rp0.

---

# 21. Page — Detail Kategori

Contoh:

```text
← Detail Poin

Kimia

Total Pembelian
Rp852.864.375

Ketentuan Poin
Rp20.000.000 = 1 poin

Poin Diperoleh
42 Poin
```

Di bawah:

```text
SUMBER PEMBELIAN
```

---

# 22. Source List

Tampilkan sumber pembelian per customer/cabang.

Ideal UI:

```text
Bogor
BGR00039

Rp852.864.375
```

Jika nama customer tersedia:

```text
Bogor

ANUGERAH KARYA ASINDO PT
BGR00039

Rp852.864.375
```

Jangan tampilkan:

```text
branch_id: 56
```

secara mentah.

Resolve `branch_id` menjadi nama cabang menggunakan master branch existing.

---

# 23. bc_refs

API source saat ini membawa:

```text
bc_refs
```

Contoh:

```text
BGR00039
```

Gunakan sebagai identifier BC.

Jika ingin menampilkan nama customer, lakukan mapping dari customer/master data existing.

Jangan menebak nama customer hanya dari `bc_refs`.

Jika mapping nama belum tersedia:

cukup tampilkan:

```text
Bogor
BGR00039
Rp852.864.375
```

---

# 24. Source Pagination

Perhatikan generic resource API menggunakan pagination.

Jangan berasumsi semua source selalu kembali dalam satu response.

Gunakan filter:

```text
calculation_id
+
account
```

agar dataset jauh lebih kecil.

Jika jumlah source masih banyak:

gunakan infinite scroll sesuai `design.md`.

---

# 25. Relasi Data

Flow relasi:

```text
loyalty_point_ledger
│
│ calculation_id
▼
loyalty_calculation_detail
│
│ calculation_id + account
▼
loyalty_calculation_source
```

Interpretasi:

```text
Ledger
= saldo customer saat ini

Calculation Detail
= poin berdasarkan kategori penjualan

Calculation Source
= sumber omzet kategori berdasarkan BC/cabang
```

---

# 26. Perbedaan Saldo dan Awarded Point

Jangan menyamakan:

```text
ledger.earned_point
```

dengan:

```text
SUM(detail.awarded_point)
```

sebagai konsep permanen.

`ledger.earned_point`:

```text
saldo poin saat ini
```

`detail.awarded_point`:

```text
hasil point calculation untuk kategori pada calculation tersebut
```

Saat customer sudah melakukan redemption, keduanya dapat berbeda.

---

# 27. Current Example

Current ledger:

```text
Saldo
237 Poin

Calculation
36

Period
LOYALTY-2026
```

Rincian calculation dapat menghasilkan kategori seperti:

```text
Plastic                 +111
Kimia                    +42
HDP                      +38
Kawat                    +29
Percoil                   +9
Kain Polos Springbed      +5
Accessories Kaki          +1
Non Woven                 +1
Stapless                  +1
```

UI jangan hardcode nilai tersebut.

Semua berasal dari API.

---

# 28. Loading State

Customer page:

hanya card Ekapoint yang loading.

Jangan membuat seluruh Customer page loading.

Rincian Poin:

gunakan skeleton list.

Detail Category:

gunakan skeleton summary + source rows.

---

# 29. Error Handling

Jika ledger gagal:

```text
Ekapoint

Data poin belum dapat dimuat

[Coba Lagi]
```

Jika calculation detail gagal:

```text
Rincian poin belum dapat dimuat.

[Coba Lagi]
```

Jika source gagal:

```text
Sumber pembelian belum dapat dimuat.

[Coba Lagi]
```

Jangan tampilkan raw API/backend error.

---

# 30. Empty State

Calculation detail kosong:

```text
Belum Ada Perolehan Poin

Rincian pembelian yang masuk dalam
perhitungan poin akan tampil di sini.
```

Source kosong:

```text
Belum Ada Rincian Sumber

Detail sumber pembelian belum tersedia.
```

---

# 31. Refresh

Saat Customer page refresh:

refresh ledger.

Saat membuka Rincian Poin:

gunakan `calculation_id` terbaru dari ledger.

Jangan menyimpan `calculation_id` secara hardcoded.

Saat ledger berubah karena calculation baru:

detail harus menggunakan calculation terbaru yang direferensikan ledger.

---

# 32. Security

Customer app tidak boleh menerima:

```text
gross_profit
gross_profit_snapshot
gp_percent
gp_percent_snapshot
```

Jangan hanya menyembunyikannya di widget.

Minimal:

- jangan request field tersebut,
- jangan masukkan ke Flutter model,
- jangan log response yang mengandungnya.

Idealnya backend juga menerapkan customer-safe access/field whitelist agar customer tidak dapat meminta field tersebut secara manual.

---

# 33. Final Navigation

```text
CUSTOMER
│
└── POIN & HADIAH
       │
       └── Ekapoint
              │
              ├── Tukar Poin
              │      │
              │      └── Reward Catalog
              │
              └── Rincian Poin
                     │
                     ▼
             CALCULATION DETAIL
                     │
                     ├── Plastic
                     ├── Kimia
                     ├── HDP
                     ├── Kawat
                     └── ...
                            │
                            │ tap category
                            ▼
                   CALCULATION SOURCE
                            │
                            ├── Cabang A / BC A
                            ├── Cabang B / BC B
                            └── ...
```

`Riwayat Penukaran` adalah flow terpisah dan jangan dicampur dengan calculation detail.
