# PRD

# Sales Order & Menunggu Pengiriman

## Ekaplus Mobile – Customer Facing

---

# 1. Overview

Ekaplus Mobile membutuhkan dua fitur utama terkait transaksi customer:

1. **Sales Order**
2. **Menunggu Pengiriman**

Keduanya saling berhubungan tetapi mempunyai tujuan berbeda.

**Sales Order** berfungsi sebagai histori dan monitoring seluruh pesanan customer.

**Menunggu Pengiriman** berfungsi sebagai daftar item dari Sales Order customer yang masih memiliki sisa kuantitas yang perlu dikirim.

Fitur dibuat untuk customer, bukan untuk user internal ERP.

---

# 2. Tujuan Bisnis

Customer harus dapat mengetahui:

- pesanan apa saja yang pernah dibuat,
- status Sales Order,
- nilai Sales Order,
- progress pengiriman,
- progress penagihan,
- item apa saja yang dibeli,
- berapa qty dipesan,
- berapa qty sudah dikirim,
- berapa qty masih menunggu pengiriman,
- item mana yang terlambat,
- riwayat pengiriman suatu item,
- invoice yang terkait dengan item tersebut.

---

# 3. Scope Navigation

Pada area Pesanan Ekaplus:

```text
Pesanan

[ Sales Order ]
[ Menunggu Pengiriman ]
```

Alternatif dapat menggunakan segmented top navigation:

```text
Sales Order | Menunggu Pengiriman
```

Jangan menggunakan nama:

```text
Item To Be Delivered
```

pada UI customer.

Nama customer-facing:

```text
Menunggu Pengiriman
```

---

# 4. Design System

Semua halaman wajib mengikuti:

```text
DESIGN.md Ekaplus Mobile
```

Gunakan:

- CustomHeader existing
- primary maroon Ekaplus
- background existing
- card putih
- subtle border
- soft shadow
- typography existing
- spacing existing
- bottom navigation existing

Jangan membuat design system baru.

Hijau hanya untuk success state.

---

# 5. Security

Semua API menggunakan autentikasi Frappe.

Jangan menyimpan credential Administrator di mobile.

Gunakan user/token khusus mobile yang memiliki Role dan User Permissions sesuai customer.

Permission Frappe harus menjadi authority utama. Token yang memiliki akses luas akan tetap mendapatkan data sesuai aksesnya, sehingga akun mobile harus dikonfigurasi dengan permission yang tepat.

---

# MODULE A

# SALES ORDER

---

# 6. Sales Order List API

Gunakan:

```http
GET /api/method/ekaplus.utils.sales_order.get_sales_orders
```

Default request customer-facing:

```text
docstatus=1
page=1
page_size=20
sort=newest
```

Jangan mengambil:

```text
Draft
Cancelled
```

karena aplikasi customer hanya menampilkan Sales Order submitted.

Endpoint list menyediakan pagination, status, customer, company, date, search, delivery progress, docstatus, dan sort.

---

# 7. Status Filter

Filter berupa horizontal filter chip/bubble seperti marketplace.

Gunakan:

```text
[Semua]
[Menunggu Pengiriman]
[Menunggu Tagihan]
[Pengiriman & Tagihan]
[Selesai]
```

Mapping:

```text
Semua
→ tidak kirim parameter status

Menunggu Pengiriman
→ status=To Deliver

Menunggu Tagihan
→ status=To Bill

Pengiriman & Tagihan
→ status=To Deliver and Bill

Selesai
→ status=Completed
```

Jangan tampilkan:

```text
Draft
On Hold
Cancelled
Closed
```

di UI filter customer.

---

# 8. Sales Order List Header

Gunakan:

```text
Sales Order
Pantau pesanan Anda
```

Di bawah header:

```text
Search field

[Semua] [Menunggu Pengiriman] [Menunggu Tagihan] ...
```

Search mendukung:

- nomor SO
- ID customer
- nama customer

sesuai capability endpoint.

---

# 9. Sales Order Card

Contoh:

```text
SO-2026-10-0123

17 Okt 2026                  MENUNGGU PENGIRIMAN

Rp135.000.000

Pengiriman                         75%
████████████████░░░░

Penagihan                         100%
████████████████████
```

Card minimal menampilkan:

```text
name
transaction_date
grand_total
currency
status
per_delivered
per_billed
delivery_progress_label
```

Field list tersebut memang tersedia dari API list.

---

# 10. Status Translation

Jangan tampilkan status ERP mentah jika bisa dibuat lebih customer-friendly.

Gunakan:

```text
To Deliver
→ Menunggu Pengiriman

To Bill
→ Menunggu Tagihan

To Deliver and Bill
→ Pengiriman & Tagihan

Completed
→ Selesai
```

Tetapi value API tetap menggunakan status ERP original.

---

# 11. Pagination

Gunakan infinite scroll.

Request:

```text
page=1
page_size=20
```

Saat mendekati akhir list:

```text
page=2
```

dan seterusnya.

Jika transaksi berubah atau refresh manual dilakukan:

```text
reset ke page=1
```

Pagination API menggunakan offset dan tim ERP merekomendasikan refresh mulai halaman 1 ketika transaksi berubah.

---

# 12. Sales Order Detail API

Saat card dipilih:

```http
GET /api/method/ekaplus.utils.sales_order.get_sales_order_detail
```

Parameter:

```text
name={salesOrderName}
only_pending_items=0
```

Endpoint memberikan header, PO customer, alamat, kontak, pajak/diskon, remarks, items, dan item_summary sesuai permission user.

---

# 13. Detail Page Structure

Gunakan:

```text
Custom Header

↓

Hero Sales Order

↓

Tabs:

Ringkasan
Produk
Pengiriman
Invoice
```

---

# 14. Detail Hero

Contoh:

```text
SO-2026-09-0338LK
17 Sep 2026

SELESAI

Rp135.000.000

Pengiriman                        100%
████████████████████
Terkirim

Penagihan                         100%
████████████████████
Ditagihkan
```

Field:

```text
name
transaction_date
status
grand_total
currency
per_delivered
per_billed
```

---

# 15. Billing Rule

`per_billed` adalah progress penagihan.

Bukan progress pembayaran.

Jangan menampilkan:

```text
Lunas
```

berdasarkan:

```text
per_billed == 100
```

README ERP secara eksplisit menyatakan `per_billed` bukan persentase pembayaran.

---

# 16. Tab Ringkasan

Tampilkan customer-facing fields seperti:

```text
Nomor Sales Order
Tanggal Pesanan
Target Pengiriman
Customer PO
Alamat Pengiriman
Termin jika tersedia
Grand Total
```

Jangan tampilkan informasi internal seperti:

```text
sales internal
warehouse
purchasing
supervisor
valuation
gross profit
margin
stock internal
```

---

# 17. Remarks

Endpoint dapat mengembalikan remarks.

Remarks tidak otomatis customer-safe.

Jangan tampilkan raw remarks sebelum backend/tim ERP memastikan remarks tersebut memang dibuat untuk customer.

Jika diperlukan customer note, gunakan field customer-facing khusus.

---

# 18. HTML Content

Description, address, dan remarks dapat mengandung HTML ERPNext.

Mobile harus:

```text
sanitize HTML
<br> → newline
```

Jangan render raw HTML tanpa sanitization.

---

# 19. Tab Produk

Gunakan `items` dari endpoint detail Sales Order.

Gunakan juga:

```text
item_summary
```

---

# 20. Product Summary

Contoh:

```text
Produk Pesanan

12 Produk
3 Belum Terkirim
1 Terlambat
```

Mapping dari:

```text
total_rows
pending_rows
remaining_rows
overdue_rows
```

API menyediakan item_summary tersebut.

---

# 21. Product Filter

Gunakan filter chip:

```text
[Semua]
[Belum Terkirim]
```

Jika customer memilih:

```text
Belum Terkirim
```

boleh request ulang:

```text
only_pending_items=1
```

atau filter state sesuai implementasi yang paling efisien.

---

# 22. Product Card

Contoh:

```text
BAHAN KIMIA PPG IBC WANHUA

0030110000017#181

Dipesan
4.000 KG

Terkirim
3.000 KG

Sisa
1.000 KG

Target Kirim
22 Sep 2026
```

Minimal tampilkan:

```text
item_name
item_code
qty
uom
delivered_qty
remaining_qty
delivery_date
```

---

# 23. Delivery Item Calculation

Flutter jangan menghitung sendiri:

```text
qty - delivered_qty
```

Gunakan langsung:

```text
remaining_qty
pending_delivery_qty
over_delivered_qty
```

dari API.

Backend sudah mendefinisikan aturan resmi:

```text
remaining_qty = max(qty - delivered_qty, 0)
over_delivered_qty = max(delivered_qty - qty, 0)
```

dan pending_delivery_qty memperhitungkan status SO serta skip_delivery_note.

---

# 24. Over Delivery

Jika:

```text
over_delivered_qty > 0
```

boleh tampil:

```text
Dipesan       4.000 KG
Terkirim      4.104,5 KG
Lebih Kirim     104,5 KG
```

Gunakan label netral.

Jangan dianggap error frontend.

---

# 25. Overdue

Jika:

```text
is_overdue = true
```

tampilkan badge:

```text
Terlambat
```

Jika API menyediakan overdue_days:

```text
Terlambat 3 hari
```

Gunakan semantic danger/warning sesuai DESIGN.md.

---

# 26. Product Detail Navigation

Saat item dipilih, gunakan:

```text
sales_order
sales_order_item
```

untuk membuka:

```http
GET /api/method/ekaplus.utils.sales_order.get_sales_order_item_detail
```

`sales_order_item` adalah ID row, bukan `item_code`.

---

# 27. Item Detail Screen

Halaman:

```text
Detail Produk
```

Hero:

```text
BAHAN KIMIA PPG IBC WANHUA
0030110000017#181

SO-2026-09-0338LK
```

Qty summary:

```text
Dipesan       4.000 KG
Terkirim      3.000 KG
Sisa          1.000 KG
```

---

# 28. Item Detail Tabs

Gunakan:

```text
Ringkasan
Pengiriman
Invoice
```

---

# 29. Item Detail – Pengiriman

Gunakan response:

```text
delivery_notes[]
```

API hanya mengambil Delivery Note submitted yang benar-benar terkait ke item melalui `so_detail`.

Contoh:

```text
Riwayat Pengiriman

BBK-2026-09-00310
22 Sep 2026

2.000 KG
Completed
```

---

# 30. Item Detail – Invoice

Gunakan:

```text
sales_invoices[]
```

Invoice terkait melalui:

```text
so_detail
```

atau:

```text
dn_detail
```

dari Delivery Note yang terkait item.

Contoh:

```text
Riwayat Invoice

SJ-2026-09-00310
22 Sep 2026

1.000 KG
Rp33.750.000
```

---

# 31. History Permission

Response dapat mengandung:

```text
history_scope
history_note
```

Jika:

```text
authorized_documents_only
```

render history normal.

Jika:

```text
no_read_permission
```

jangan tampil:

```text
Belum ada riwayat.
```

Gunakan:

```text
Riwayat belum tersedia untuk akun ini.
```

Array kosong tidak selalu berarti transaksi belum ada karena permission dapat membatasi history.

---

# 32. Do Not Double Count

Jangan menjumlahkan:

```text
DN qty + SI qty
```

untuk menghitung total terkirim.

Sales Invoice dapat menagih barang yang sudah ada di Delivery Note.

Gunakan:

```text
item.delivered_qty
```

sebagai data pengiriman resmi.

API ERP secara eksplisit melarang menjumlahkan DN dan SI sebagai total delivery.

---

# 33. UOM

Jangan menjumlahkan qty dengan UOM berbeda.

Tampilkan UOM masing-masing record.

API tidak melakukan konversi otomatis antar UOM.

---

# MODULE B

# MENUNGGU PENGIRIMAN

---

# 34. Purpose

Halaman ini menampilkan semua item customer yang:

```text
masih mempunyai sisa qty
dan
masih membutuhkan pengiriman
```

dari berbagai Sales Order.

Tujuannya agar customer tidak perlu membuka Sales Order satu per satu.

---

# 35. Page Name

Gunakan nama:

```text
Menunggu Pengiriman
```

Subtitle:

```text
Produk yang masih menunggu pengiriman
```

Jangan gunakan:

```text
Dalam Perjalanan
```

karena API belum mempunyai status logistik in-transit.

---

# 36. Pending Items API

Gunakan:

```http
GET /api/method/ekaplus.utils.sales_order.get_customer_pending_items
```

Parameter customer:

```text
customer={customerId}
```

atau:

```text
bcid={bcid}
```

Endpoint hanya mengambil SO:

```text
submitted
bukan Closed
bukan Cancelled
bukan On Hold
bukan Stopped
delivery_required
remaining_qty > 0
```

---

# 37. Pending Page Header

Contoh:

```text
Menunggu Pengiriman

Produk yang masih menunggu pengiriman
```

Summary:

```text
3 Item
dari 2 Sales Order
```

API menyediakan summary seluruh hasil sebelum pagination.

---

# 38. Filter Bubble

Gunakan:

```text
[Semua]
[Terlambat]
```

Optional future:

```text
[Berdasarkan SO]
```

Jangan menggunakan status “Dalam Perjalanan” karena belum ada datanya.

---

# 39. Search

Search bisa mencari:

```text
item code
item name
```

menggunakan parameter:

```text
search
```

---

# 40. Pending Item Card

Contoh:

```text
BAHAN KIMIA PPG IBC WANHUA

SO-2026-09-0338LK
Target 22 Sep 2026

Dipesan
4.000 KG

Terkirim
3.000 KG

Sisa
1.000 KG

TERLAMBAT 3 HARI
```

---

# 41. Card Fields

Gunakan:

```text
item_code
item_name

sales_order
sales_order_item

transaction_date
status

qty
uom

delivered_qty
remaining_qty
pending_delivery_qty

delivery_date
overdue_days
is_overdue
```

Response pending items menyediakan identitas SO/item dan informasi sisa/overdue tersebut.

---

# 42. Remaining Amount

API dapat memberikan:

```text
remaining_amount
```

formula:

```text
remaining_qty × rate
```

Nilai ini:

```text
bukan outstanding invoice
```

dan sebelum pajak.

Untuk customer app, jangan tampilkan sebagai:

```text
Tagihan tersisa
```

Jika ingin ditampilkan, gunakan label:

```text
Nilai Barang Tersisa
```

Tetapi optional.

Default desain:

```text
jangan tampilkan dulu
```

agar tidak membingungkan dengan invoice outstanding.

---

# 43. Summary

API memberikan:

```text
total_sales_orders
total_item_rows
overdue_rows
remaining_amount_by_currency
amount_unavailable_rows
```

Gunakan maksimal:

```text
3 Item
2 Sales Order
1 Terlambat
```

Jangan tampilkan `remaining_amount` di summary default agar user tidak mengira itu outstanding pembayaran.

---

# 44. Sort Order

API sudah mengurutkan item dengan:

```text
tanggal kirim terlama dahulu
tanggal kosong di akhir
```

Pertahankan urutan tersebut secara default.

---

# 45. Pending Item Click

Saat item dipilih:

```text
sales_order
sales_order_item
```

lalu buka endpoint:

```http
GET /api/method/ekaplus.utils.sales_order.get_sales_order_item_detail
```

Tidak perlu membuat endpoint detail baru.

---

# 46. Pending Item Detail

Gunakan layar yang sama dengan Product Detail pada Sales Order.

Artinya:

```text
Sales Order
→ Produk
→ Detail Produk
```

dan:

```text
Menunggu Pengiriman
→ Detail Produk
```

menggunakan halaman yang sama.

Jangan duplicate implementation.

---

# 47. Navigation Example

```text
Pesanan
│
├── Sales Order
│    ├── SO List
│    └── Detail SO
│         └── Produk
│              └── Detail Produk
│
└── Menunggu Pengiriman
     └── Pending Item
          └── Detail Produk
```

---

# 48. State Label

Gunakan customer-friendly status item.

## Belum Terkirim

Jika:

```text
delivered_qty == 0
remaining_qty > 0
is_overdue == false
```

label:

```text
Menunggu Pengiriman
```

---

## Sebagian Terkirim

Jika:

```text
delivered_qty > 0
remaining_qty > 0
```

label:

```text
Sebagian Terkirim
```

---

## Terlambat

Jika:

```text
is_overdue == true
```

label utama:

```text
Terlambat
```

Optional:

```text
Terlambat 3 hari
```

---

# 49. Jangan Gunakan "Dalam Perjalanan"

Tidak boleh infer:

```text
Dalam Perjalanan
```

hanya karena Delivery Note sudah ada.

API belum memberikan:

```text
shipment dispatched
driver assigned
vehicle
tracking status
arrival status
```

Jika fitur tersebut diperlukan di masa depan, backend harus menyediakan shipment tracking khusus.

---

# 50. Loading

Gunakan skeleton card.

Infinite scroll hanya menampilkan loading di bawah list.

Jangan full-screen reload saat pagination.

---

# 51. Empty State Sales Order

```text
Belum ada Sales Order.
```

---

# 52. Empty State Menunggu Pengiriman

```text
Semua pesanan sudah terkirim.

Saat ada produk yang masih menunggu pengiriman,
produk akan muncul di sini.
```

Gunakan positive empty state.

---

# 53. Empty State Filter Terlambat

```text
Tidak ada pengiriman yang terlambat.
```

---

# 54. Error Handling

API menggunakan HTTP exception standar Frappe.

Mobile harus menangani:

```text
403 → akses tidak diizinkan
404 → dokumen tidak ditemukan
417 → parameter tidak valid
authentication failure → session/token issue
```

Jangan hanya membaca:

```text
success=false
```

karena error Frappe menggunakan HTTP status.

---

# 55. Data Security

Jangan expose:

```text
ERP secret
Administrator token
internal notes
gross profit
valuation rate
internal stock
margin
purchase information
internal employee
```

Gunakan hanya field yang diperlukan UI customer.

---

# 56. Status Color

Gunakan semantic colors.

```text
Selesai
→ success

Menunggu Pengiriman
→ warning

Menunggu Tagihan
→ warning

Sebagian Terkirim
→ warning

Terlambat
→ danger
```

Navigation/action tetap menggunakan primary maroon.

---

# 57. Sales Order List Example

```text
Detail Pesanan

[Sales Order] [Menunggu Pengiriman]

Cari Sales Order...

[Semua]
[Menunggu Pengiriman]
[Menunggu Tagihan]
[Pengiriman & Tagihan]
[Selesai]


SO-2026-10-0123
17 Okt 2026

MENUNGGU PENGIRIMAN

Rp135.000.000

Pengiriman                       75%
████████████████░░░░

Penagihan                       100%
████████████████████
```

---

# 58. Menunggu Pengiriman Example

```text
Menunggu Pengiriman
Produk yang masih menunggu pengiriman

3 Item • 2 Sales Order • 1 Terlambat

Cari produk...

[Semua] [Terlambat]


BAHAN KIMIA PPG IBC WANHUA
SO-2026-09-0338LK

Target Pengiriman
22 Sep 2026

Dipesan       4.000 KG
Terkirim      3.000 KG
Sisa          1.000 KG

TERLAMBAT 3 HARI
```

---

# 59. Item Detail Example

```text
Detail Produk

BAHAN KIMIA PPG IBC WANHUA
0030110000017#181

SO-2026-09-0338LK

Dipesan       4.000 KG
Terkirim      3.000 KG
Sisa          1.000 KG


[Ringkasan] [Pengiriman] [Invoice]


PENGIRIMAN

BBK-2026-09-0310
22 Sep 2026

2.000 KG


BBK-2026-09-0399
28 Sep 2026

1.000 KG
```

---

# 60. Acceptance Criteria – Sales Order

PASS jika:

- hanya submitted Sales Order yang ditampilkan,
- status customer filter hanya 4 status bisnis + Semua,
- draft/on hold/cancelled/closed tidak ada di filter,
- search bekerja,
- pagination bekerja,
- progress pengiriman tampil,
- progress billing tampil,
- billing tidak dianggap pembayaran,
- detail SO dapat dibuka.

---

# 61. Acceptance Criteria – Detail SO

PASS jika:

- detail menggunakan endpoint khusus mobile,
- hero menampilkan nomor SO, tanggal, nilai, status, progress,
- produk berasal dari `items`,
- summary produk berasal dari `item_summary`,
- sisa qty menggunakan `remaining_qty`,
- overdue menggunakan `is_overdue`,
- tidak menghitung ulang business logic yang sudah diberikan backend.

---

# 62. Acceptance Criteria – Menunggu Pengiriman

PASS jika:

- hanya item `remaining_qty > 0` yang tampil,
- Closed/Cancelled/On Hold/Stopped tidak tampil,
- item dari banyak SO boleh muncul,
- SO number tampil pada item,
- qty order/terkirim/sisa tampil,
- item terlambat diberi indikator,
- filter Terlambat bekerja,
- search bekerja,
- pagination bekerja.

---

# 63. Acceptance Criteria – Item Detail

PASS jika:

- menggunakan `sales_order_item` ID row,
- riwayat Delivery Note benar-benar related ke item,
- riwayat Sales Invoice benar-benar related ke item,
- DN dan SI tidak dijumlahkan menjadi total delivery,
- UOM tidak dijumlahkan lintas satuan,
- history permission ditangani dengan benar.

---

# 64. Out of Scope

Belum termasuk:

```text
Payment Entry
Status Lunas global
Payment History
Shipment Tracking
Driver Tracking
GPS Tracking
Vehicle Tracking
Estimated Arrival
Proof of Delivery
```

Karena API sekarang belum menyediakan data tersebut.

---

# 65. Future Enhancement

Jika ERP nantinya menyediakan shipment tracking:

```text
Delivery Note
↓
Shipment
↓
Driver / Vehicle
↓
In Transit
↓
Delivered
```

maka halaman Menunggu Pengiriman dapat dikembangkan menjadi:

```text
Belum Dikirim
Sedang Dikirim
Terkirim
```

Untuk versi sekarang jangan infer status tersebut.

---

# 66. Definition of Done

Fitur dianggap selesai jika customer dapat:

1. melihat semua Sales Order,
2. memfilter status Sales Order,
3. mencari Sales Order,
4. membuka detail SO,
5. melihat produk per SO,
6. mengetahui qty dipesan/terkirim/sisa,
7. melihat produk yang masih menunggu pengiriman dari seluruh SO,
8. melihat produk terlambat,
9. membuka detail produk,
10. melihat riwayat Delivery Note,
11. melihat riwayat Invoice,
12. tanpa mendapatkan informasi ERP internal yang tidak relevan.

---

# FINAL UX PRINCIPLE

## Sales Order

Menjawab:

> “Bagaimana status pesanan saya?”

## Menunggu Pengiriman

Menjawab:

> “Barang apa saja yang masih belum selesai dikirim?”

## Detail Produk

Menjawab:

> “Dari item ini, berapa yang saya pesan, berapa yang sudah dikirim, berapa sisanya, dan bagaimana riwayat pengiriman serta invoicenya?”
