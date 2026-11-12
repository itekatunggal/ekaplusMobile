# README — EKAPLUS Mobile Home Redesign (Product Hide + Branch + Loyalty + Sales + Promo + Artikel)

**Status:** Implementation brief / instruksi pengembangan untuk Codex  
**Baseline source:** `ekaplusMobile-development (1).zip`, 10 November 2026  
**Platform:** Flutter / Dart, `flutter_bloc` (Bloc/Cubit), `go_router`, GetIt  
**Referensi UI:** screenshots aplikasi FIT HUB yang disertakan dalam percakapan; **adaptasi pola UX, jangan menyalin identitas/visual FIT HUB**.  
**Sumber desain wajib:** `design.md` pada root project EKAPLUS Mobile.

> **INSTRUKSI UTAMA UNTUK CODEX:** Implementasikan perubahan frontend Flutter berikut pada codebase saat ini. **Jangan menghapus fitur produk**. Hide sementara dari navigasi, Home, entry point UI, dan pemanggilan awal yang tidak dibutuhkan. Gunakan API existing untuk banner, cabang, dan loyalty; gunakan data dummy terisolasi untuk sales, promo, dan artikel sampai API tersedia. Jangan membuat API backend baru atau mengubah backend. Pertahankan fungsi login, customer, invoice, sales order, loyalty, dan akun yang sudah ada.

---

## 1. Tujuan bisnis

Katalog produk belum memiliki data dan foto yang lengkap. Karena itu versi sementara EKAPLUS berfokus pada:

1. Informasi cabang Ekatunggal Group, dengan pilihan **cabang informasi aktif**.
2. Daftar **sales Ekatunggal** yang difilter berdasarkan cabang yang dipilih.
3. **EkaPoint / Loyalty** di Home untuk customer login dengan perusahaan/GPID valid.
4. Akses cepat ke layanan yang benar-benar ada.
5. Promo dan artikel/berita perusahaan dengan UI dummy yang mudah dihubungkan ke API di kemudian hari.
6. Tetap mempertahankan fitur customer & transaksi.

**Tidak termasuk scope:** redesign backend, sistem chat internal, pembuatan API sales/promo/artikel, proses transaksi/redeem baru, dan data manajemen promo CMS.

## 2. Audit file existing sebelum coding

Baca dan identifikasi pola existing terlebih dahulu. Path di bawah ditemukan pada ZIP baseline:

| Area | File / referensi |
| --- | --- |
| Design system | `design.md`, `lib/constant.dart` |
| Entry/provider | `lib/main.dart`, `lib/injection.dart` |
| Home | `lib/features/home/presentation/pages/home_page.dart` |
| Banner | `lib/features/banner/presentation/cubit/banner_cubit.dart`, `lib/features/home/presentation/widgets/home_slider_widget.dart` |
| Bottom nav | `lib/core/shared_widgets/bottom_nav.dart` |
| Routing + Shell | `lib/core/routes/my_router.dart` (`AppShell`) |
| Cabang | `lib/features/branch/` (entity, datasource, repository, usecase, Cubit) |
| Active customer | `lib/features/member/presentation/cubit/active_company_cubit.dart` |
| Loyalty summary existing | `lib/features/loyalty/presentation/cubit/customer_point_summary_cubit.dart` |
| Loyalty service | `lib/features/loyalty/data/services/loyalty_service.dart` |
| Customer + loyalty card | `lib/features/customer/presentation/pages/customer_page.dart`, `lib/features/loyalty/presentation/widgets/customer_loyalty_point_card.dart` |
| Shared widgets | `lib/core/shared_widgets/` |
| Persistence existing | `shared_preferences`/Hive sudah ada di `pubspec.yaml` |

**Fakta codebase yang perlu dipertimbangkan:**

- `MyRouter` saat ini `initialLocation: '/customer'`.
- `AppShell` dan `BottomNavBar` saat ini memakai tab Beranda, Kategori, Wishlist, Customer (login), Akun.
- `HomePage` masih menampilkan `HomeSearchBar`, `TypeCategoryList`, dan dua `ProductsSection`.
- `HomePage` saat ini memanggil `fetchBanners()` pada `bloc:` di dalam `BlocBuilder`, sehingga rawan refetch saat rebuild.
- `main.dart` langsung memicu `ProductEventLoadFirstPage` ketika inisialisasi; perlu dihentikan selama fitur produk disembunyikan.
- `Branch` existing memiliki `id`, `branchName`, `address`, `city`, `area`, `island`, `status`, `disabled`, `url`, `lat`, `lng`. **Tidak ada field foto, telepon, jam operasional di entity saat ini.**
- `BranchRemoteDatasource` masih meminta `fields: ['*']`; ubah ke **field publik yang dibutuhkan**, jangan mengambil credential/token branch ke layar customer.
- `ActiveCompanyCubit` mengelola perusahaan/BCID customer, **bukan** pilihan cabang direktori.
- CustomerPage memakai `CustomerPointSummaryCubit` dengan `gpidId` dari `ActiveMemberCompany`.
- Pada implementasi `CustomerPointSummaryCubit`, nilai `availablePoint` saat ini berasal dari `ledger.earnedPoint`. Periksa kembali semantik saldo agar yang tampil benar-benar **poin tersedia**, bukan total perolehan sebelum digunakan. `LoyaltyService.getBalance(bcid)` sudah ada dengan model `availablePoint`.

Jangan menganggap field/endpoint yang belum ada sebagai API yang sudah tersedia. Jika ada konflik dengan source terbaru di branch kerja, prioritaskan pemeriksaan kode aktual dan jelaskan penyesuaiannya.

---

## 3. Feature flags — hide, tidak delete

Buat satu konfigurasi pusat (nama file disesuaikan arsitektur), misalnya `lib/core/config/feature_flags.dart`:

```dart
abstract final class FeatureFlags {
  static const bool showProductCatalog = false;
  static const bool showProductCategories = false;
  static const bool showWishlist = false;
  static const bool showProductSearch = false;
  static const bool showHomeLoyalty = true;
  static const bool showBranchDirectory = true;
  static const bool showSalesDirectory = true;
  static const bool showPromotions = true;
  static const bool showArticles = true;
  static const bool useDummySales = true;
  static const bool useDummyPromotions = true;
  static const bool useDummyArticles = true;
}
```

Flag di atas contoh kontrak; implementasi boleh menggunakan enum/config typed yang lebih aman. Hindari flag tersebar di banyak file. **Satu konfigurasi dapat mengaktifkan kembali katalog ketika siap**, tanpa membongkar kode.

Saat flags produk OFF:

- Hide tab **Kategori** dan **Wishlist**.
- Hide pencarian produk, kategori, produk terbaru, produk terlaris di Home.
- Hide tautan/item produk dari layar lain yang menjadi entry point user-facing, termasuk akses katalog dari banner yang mengarah ke fitur nonaktif.
- **Jangan hapus file, widget, Bloc, repository, routes, atau tests fitur produk.**
- Jangan membuat request produk/kategori/wishlist dari bootstrap/entry Home jika tak diperlukan. Periksa `ProductEventLoadFirstPage` pada `main.dart` dan `TypeEventGetAllTypes` pada `HomePage.initState`.
- **Routes tersembunyi harus memiliki guard/fallback** untuk deep link/history: arahkan ke Home atau tampilkan halaman unavailable yang rapi. Jangan hanya menghilangkan tab namun route produk tetap bebas dibuka.
- Pastikan halaman detail produk dari link banner tidak membuat crash saat produk OFF. Validasi target route dan berikan fallback aman.
- Hindari menghapus data/cache user hanya karena flag dimatikan.

## 4. Navigation baru

**Saat login:** Beranda | Cabang | Sales | Customer | Akun.  
**Saat guest:** Beranda | Cabang | Sales | Akun.

Implementasikan mapping tab lewat **route name/id yang sama dengan item**, jangan lagi mengasumsikan posisi index lama pada `_locationToIndex`/`_routeNames`. Route baru yang disarankan:

| Route name (saran) | Path | Konten |
| --- | --- | --- |
| `home` | `/` | Home redesign |
| `branches` | `/branches` | Daftar/pilih cabang |
| `sales` | `/sales` | Direktori sales sesuai cabang |
| `customer` | `/customer` | Fitur existing, login only |
| `account` | `/account` | Fitur existing |
| `branch-detail` | `/branches/:branchId` | Detail informasi cabang |
| `sales-detail` | `/sales/:salesId` | Detail sales |
| `promotions` / `promotion-detail` | `/promotions`, `/promotions/:id` | Daftar/detail promo |
| `articles` / `article-detail` | `/articles`, `/articles/:id` | Daftar/detail artikel |

Gunakan `GoRouter` existing, `ShellRoute` untuk tab utama, route detail boleh di luar Shell mengikuti pola project. Sesuaikan penamaan jika bertabrakan dengan named routes yang ada.

- Set entry awal **Home** (`/`) setelah mempertimbangkan alur splash/auth existing. Jangan merusak redirect login, OTP, registrasi, atau session restore.
- Customer tidak tampil di nav bagi guest. Akses langsung `/customer` oleh guest wajib dialihkan ke login atau protected state existing.
- Jangan menampilkan 5 tab dengan slot kosong untuk guest; 4 tab harus tersebar seimbang.
- Gunakan `SafeArea(bottom: true)` adaptif seperti `BottomNavBar` existing; pastikan tidak tertutup gesture bar Android/iOS.
- Pertahankan state pilihan cabang ketika ganti tab dan kembali dari detail.

---

## 5. Struktur Home final

Gunakan **satu scroll vertikal utama** dengan refresh-to-reload terkontrol dan whitespace yang proporsional. Urutan final:

1. **Header** — sapaan singkat, profil/akun dari existing; action notifikasi hanya aktif jika fitur benar-benar tersedia.
2. **Banner carousel** — memakai API & widget banner existing; tampil juga untuk guest sesuai kebijakan tap existing.
3. **Card cabang aktif** — nama cabang, kota, ringkasan lokasi, chevron ke pemilihan cabang.
4. **EkaPoint / Loyalty** — untuk login dengan GPID/BCID yang valid; guest melihat teaser ringkas login/daftar (tanpa angka palsu).
5. **Layanan cepat** — Hubungi Sales, Lokasi Cabang, Transaksi, Bantuan.
6. **Sales Ekatunggal** — carousel horizontal 2–3 kartu tampak sebagian, sesuai cabang aktif; CTA `Lihat Semua`.
7. **Promo Spesial** — carousel horizontal; CTA `Lihat Semua`.
8. **Artikel & Berita Terbaru** — carousel horizontal; CTA `Lihat Semua`.

**Opsional hanya jika ada data nyata:** pengumuman operasional cabang (jangan memasukkan fake announcement publik). Tidak wajib sebagai bagian MVP.

Pedoman visual:

- Warna primary `AppColors.primaryColor` `#B11F23`, font utama Poppins, background sesuai `design.md` (`#F6F7F9` untuk baseline standar), surface putih.
- Gunakan radius, border, dan shadow dari `design.md`. Jangan beri card besar seragam untuk seluruh section; variasikan card cabang, reward menonjol, icon shortcut, dan carousel.
- Card loyalty boleh menggunakan maroon yang lebih gelap sebagai surface khusus, selama warna brand konsisten dan kontras terbaca.
- Horizontal margin default berdasarkan standar `design.md`, pastikan layar 320–360dp tidak overflow.
- Hindari header tinggi berlebih/ruang kosong tidak perlu. Pertahankan banner image aspect ratio, jangan gunakan `BoxFit.fill` yang membuat foto/banner terdistorsi; pilih rasio dan fit berdasarkan konten.
- Sticky bottom nav tidak boleh menghalangi card paling bawah; gunakan padding akhir scroll.
- Setiap section wajib punya loading, error/retry, empty state yang tidak merusak section lain.
- Tidak perlu meniru icon, warna turquoise, karakter, label, maupun artwork FIT HUB.

### 5.1 Header & banner

- Reuse `ProfileHeader` bila sesuai setelah hide search produk.
- `BannerCubit.fetchBanners()` dipanggil satu kali di `initState` / lifecycle fetch yang tepat, **bukan di dalam `build` / parameter `bloc:` BlocBuilder**.
- Saat pull-to-refresh, panggil reload secara eksplisit, bukan memicu refetch setiap rebuild.
- Bila banner API kosong/error: tampilkan fallback proporsional dan tombol retry jika sesuai; jangan shimmer tanpa batas.
- Jika banner menautkan ke route produk tersembunyi, jangan buka route tersebut saat feature flag OFF. Link eksternal tetap mengikuti validasi `Uri` dan kebijakan yang ada.

### 5.2 Loyalty Home (REAL DATA, BUKAN DUMMY)

Ketentuan tampilan:

- Hanya tampil saldo untuk user **login** dan **perusahaan customer aktif** yang punya `gpidId` serta BCID valid.
- Header card: `EkaPoint` atau `EKAPLUS Rewards` (ikuti branding existing); label **Total Poin Tersedia**; angka format Indonesia; nama Group Parent (uppercase sesuai kebijakan UI yang ada).
- **Jangan tampilkan periode/tahun** pada ringkasan Home.
- Jangan menampilkan `gross_profit`, margin, omzet internal, atau field sensitif lain.
- Tombol `Tukar Poin` dan `Rincian Poin` harus memakai route **existing** beserta extra `bcid`, `gpid`, `groupParentName`, `groupParentCode` yang benar.
- Saldo **harus benar-benar available point**, bukan earned point saja. Prioritaskan model/endpoint balance existing `LoyaltyService.getBalance(bcid)` (memiliki `availablePoint`), verifikasi semantik dengan implementasi Loyalty/Customer; jangan diam-diam menampilkan `ledger.earnedPoint` sebagai saldo tersedia.
- Jangan menghitung ulang atau melakukan pengurangan dua kali jika API sudah memberikan `available_point` final.
- Data Home dan Customer harus konsisten. Usahakan reuse repository/state dan hindari request ganda berlebihan; jika refactor shared state, lakukan tanpa regresi di CustomerPage.
- Saat BCID aktif diganti di halaman Customer, Home wajib memuat ulang poin dan nama GP yang terkait. Request lama tidak boleh menimpa result perusahaan baru.
- Saat guest/akun belum memiliki perusahaan aktif, tampilkan CTA login/daftarkan perusahaan yang relevan, **bukan nilai `0` yang menyesatkan**.
- Loading skeleton, error + retry, zero balance dan empty company harus berbeda.

### 5.3 Layanan Cepat

- `Hubungi Sales` -> direktori sales (pilihan cabang tetap).
- `Lokasi Cabang` -> detail cabang aktif / daftar cabang jika belum memilih.
- `Transaksi` -> `/customer` bila sudah login; guest -> flow login.
- `Bantuan` -> buka fitur existing jika benar-benar ada; jika tidak, tampilkan informasi kontak umum yang terverifikasi atau **nonaktifkan shortcut sampai siap**. Jangan membuat tombol palsu yang hanya dekoratif.

---

## 6. Cabang informasi aktif (API existing)

### 6.1 Sumber data

Gunakan `BranchCubit` / repository / datasource existing. `Branch` saat ini memiliki:

```text
id, branchName, address, city, area, island, status,
disabled, url, lat, lng
```

- Fetch dari API existing (`/api/resource/branch` lewat repository existing), **tanpa hardcode daftar cabang**.
- Tampilkan hanya branch enabled/visible, pertimbangkan `disabled == false` dan status existing sesuai kebijakan backend.
- Batasi `fields` request ke data publik yang benar-benar dibutuhkan. Tidak boleh meminta `*` jika API juga menyimpan `token`, password, internal URL, atau kredensial ERP.
- Jangan menampilkan `url` internal/server sebagai website publik kecuali sudah jelas diverifikasi sebagai URL publik.
- Apabila backend belum mendukung fields tertentu, tampilkan hanya yang nyata; jangan mengarang jam operasional, telepon, foto, rating, crowd, atau jarak.

### 6.2 State yang terpisah dari customer

Buat `SelectedBranchCubit` (atau nama setara) **khusus UI direktori**, dengan state:

```text
initial/loading/ready/error
selectedBranchId: int?
selectedBranch: Branch?
branches: List<Branch>
```

- Gunakan `SharedPreferences` atau Hive existing untuk menyimpan `selectedBranchId` lintas restart.
- Urutan resolve saat startup: (1) restore id tersimpan jika masih valid/aktif; (2) pilih cabang aktif customer **hanya sebagai default opsional satu kali** jika cocok; (3) fallback ke cabang pertama yang aktif; (4) bila list kosong tampilkan empty state.
- **Memilih cabang di Home TIDAK BOLEH memanggil `ActiveCompanyCubit.setActiveCompany()` atau mengubah BCID.**
- `selectedBranchId` hanya memengaruhi **daftar sales, informasi cabang, dan konten publik yang kelak terscope cabang**.
- Jika branch terpilih dihapus/dinonaktifkan, otomatis resolve fallback aman; jangan crash atau tampilkan data sales dari branch yang tidak valid.
- Semua widget Home, halaman cabang, dan halaman sales membaca sumber state terpilih yang sama.

### 6.3 Halaman daftar cabang

Referensi FIT HUB gambar 2, adaptasi B2B:

- Header `Daftar Cabang Ekatunggal`.
- Pencarian nama cabang/kota (case-insensitive).
- Filter kota (opsi dari data API yang dimuat); jangan implementasi filter kompleks tanpa manfaat.
- Card: nama cabang, kota/area, alamat singkat, visual fallback/icon cabang, indikator yang dipilih.
- Action: `Lihat Detail`, `Pilih Cabang`; bila ada koordinat valid, tampilkan `Lihat di Maps`.
- Bottom CTA `Pilih Cabang` boleh sticky **hanya aktif setelah pilihan baru dipilih**, dan harus commit pilihan + kembali ke caller. Jika desain memakai pemilihan langsung, jangan tambah CTA sticky yang redundant.
- Tidak perlu label crowd, rating bintang, jarak terdekat, atau video karena datanya belum tersedia.
- Halaman detail: informasi cabang, alamat, kota, peta melalui URL eksternal dengan `lat/lng` valid (jangan hardcode lokasi), dan tombol `Lihat Sales Cabang`.
- Foto/galeri cabang hanya jika data/asset yang sah tersedia; jika belum, tampilkan placeholder profesional.

---

## 7. Direktori Sales (dummy dahulu)

### 7.1 Data model dan repository

Buat feature terpisah, misalnya:

```text
lib/features/sales_directory/
  domain/entities/sales_profile.dart
  domain/repositories/sales_directory_repository.dart
  data/models/sales_profile_model.dart
  data/repositories/mock_sales_directory_repository.dart
  data/repositories/remote_sales_directory_repository.dart  # kerangka opsional, jangan request ke endpoint yang belum ada
  data/dummy/mock_sales_profiles.dart
  presentation/cubit/sales_directory_cubit.dart
  presentation/pages/sales_directory_page.dart
  presentation/pages/sales_detail_page.dart
  presentation/widgets/sales_profile_card.dart
```

Contoh skema **fixture, bukan kontrak API final**:

```json
{
  "id": 101,
  "name": "Contoh Sales A",
  "position": "Sales Executive",
  "division": "Sales",
  "branch_id": 56,
  "photo_url": null,
  "work_whatsapp": null,
  "work_phone": null,
  "description": "Tim sales Ekatunggal"
}
```

- Isi fixture minimal beberapa sales **per branch valid yang dipakai di development**. Contoh `branch_id: 56` hanya berlaku jika API cabang saat dijalankan memang memuat ID 56.
- Pastikan mock tidak menampilkan nama/foto staf sungguhan tanpa data resmi. Gunakan label `Contoh Sales A`, `Contoh Sales B`, foto placeholder/avatar lokal dan atribut tidak sensitif.
- Repository method dianjurkan: `getSales({required int branchId, String? query, String? position})` dan `getSalesById(id)`; filter dapat client-side untuk dummy. Hindari mengunci UI pada struktur response yang belum final.
- Simulasikan latency singkat hanya di mock repository jika membantu uji skeleton; jangan pakai timer/perulangan network di widget.

### 7.2 Home section

- Judul `Sales Ekatunggal`, subtitle `Tim sales cabang [nama cabang]`.
- Horizontal carousel dengan partial peek, kira-kira 2–3 card tergantung lebar.
- Kartu: foto/avatar placeholder, nama, jabatan singkat. Jangan tampilkan jumlah pelanggan aktif (internal).
- `Lihat Semua` -> tab Sales, otomatis terfilter ke `selectedBranchId`.
- Bila cabang berganti, section reload dan **tidak boleh menampilkan sales cabang lama**.

### 7.3 Halaman daftar & detail sales

- Header `Sales Ekatunggal`, dropdown cabang aktif, search nama, filter jabatan/divisi yang tersedia pada dataset.
- Grid **2 kolom** untuk mobile (bukan harus 3 seperti FIT HUB), ukuran adaptif untuk tablet.
- Lazy loading gambar; fallback avatar tanpa network.
- Empty `Belum ada data sales untuk cabang ini`, tidak diam-diam menampilkan sales semua cabang.
- Detail: foto, nama, jabatan/divisi, cabang, deskripsi, CTA kontak kerja.
- **CTA WhatsApp/Telepon hanya muncul jika nomor kerja terverifikasi tersedia**. Dummy dengan nomor null -> sembunyikan atau disable CTA disertai keterangan, **jangan membuat nomor atau membuka chat dummy**.

---

## 8. Promo Spesial (dummy dahulu)

Buat feature/repository yang sama polanya dengan Sales (data mock terpisah dari widget). Minimal field:

```text
id, title, summary, coverImage, content,
startAt?, endAt?, status, branchId? (opsional), targetAudience? (opsional)
```

- Home: horizontal carousel image 16:9 atau rasio yang disepakati, title ringkas, `Lihat Semua`.
- Halaman daftar promo dan detail promo internal; jangan langsung melempar user ke situs lain tanpa kebutuhan.
- Promo expired atau `status != active` tidak tampil di Home jika date/status memang diisi.
- Saat mock dipakai, buat konten **jelas sebagai demo** dan hindari klaim diskon, harga, periode berlaku, atau reward yang belum disetujui. Jangan sampai pelanggan mengira promo dummy resmi.
- Siapkan extension untuk `all branches` vs `specific branch` dan `guest` vs `logged-in`; **jangan aktifkan segmentasi palsu** sebelum API menyediakan data.
- Banner existing tetap independen: banner = hero campaign, promo = daftar program.

## 9. Artikel & Berita Terbaru (dummy dahulu)

Minimal field:

```text
id, title, excerpt, coverImage, category, publishedAt?, content, status
```

- Home: carousel 1–2 card yang sebagian terlihat, judul maksimal 2 baris, excerpt dan tanggal hanya bila tersedia.
- Halaman daftar artikel dan detail artikel dengan konten dapat di-scroll, gambar hero, judul, kategori, tanggal publikasi jika valid.
- Kategori potensial: `Berita Perusahaan`, `Wawasan Industri`, `Kegiatan Ekatunggal`.
- Dummy sebaiknya berisi artikel generik berlabel contoh, **bukan pengumuman resmi atau berita palsu**.
- Detail artikel harus benar-benar membuka konten; jangan CTA yang hanya snackbar `Coming Soon` jika halaman sudah dinyatakan selesai.

---

## 10. Arsitektur, dependency, dan keterhubungan API

### 10.1 Aturan desain implementasi

- Pertahankan `flutter_bloc`, `go_router`, GetIt dan pola feature-based existing.
- UI bergantung pada Cubit/state/repository, **bukan membaca data dummy langsung dalam widget**.
- Untuk Sales/Promo/Artikel, gunakan repository contract yang sama bagi `mock` dan `remote` sehingga nanti berpindah ke API cukup ganti implementasi di DI/config.
- Daftarkan provider di scope yang tepat; `SelectedBranchCubit` harus tersedia di Home, Cabang, Sales tanpa kehilangan state saat navigasi.
- Tidak perlu menginstal state management baru atau membuat backend palsu.
- Controller dan stream perlu di-dispose, debounce search bila dibutuhkan.
- Jika ingin cache, gunakan pola existing; jangan memperkenalkan cache rumit untuk dataset kecil.

### 10.2 Rencana integrasi bertahap

| Modul | Mode sekarang | Mode saat API siap |
| --- | --- | --- |
| Banner | API existing | Tetap API existing |
| Branch | API existing | Tetap API existing (tambahan field publik jika tersedia) |
| Loyalty | API existing | Tetap API existing |
| Sales | Mock repository | Remote repository |
| Promo | Mock repository | Remote repository |
| Artikel | Mock repository | Remote repository |

### 10.3 Error / offline

- Kegagalan satu section tidak boleh membuat seluruh Home blank.
- Branch gagal: tampilkan retry; jika ada cached selected branch valid, boleh ditampilkan dengan keterangan belum diperbarui, jangan mengarang lokasi.
- Sales/Promo/Artikel mode dummy bekerja tanpa network; jelas di source/config bahwa data contoh.
- Loyalty gagal/unauthorized: tampilkan error/CTA sesuai state, **bukan angka palsu**.
- Tidak ada silent failure yang menyamarkan error ke saldo 0.

---

## 11. Performa & UX

- `RefreshIndicator` pada Home melakukan reload banner, branch, loyalty sesuai kebutuhan; dummy sections boleh reload lokal.
- Hindari nested vertical scroll, unbounded height, dan request berulang dari `build`.
- Lazy render section konten panjang jika diperlukan; media menggunakan placeholder dan cache gambar existing.
- Semua item interaktif memiliki target tap yang nyaman dan accessibility label/semantic yang relevan.
- Text scaling tidak boleh menyebabkan overflow/clip; jangan mengunci semua font pada scale maksimal 1.0 tanpa mempertimbangkan aksesibilitas.
- Responsive di 320dp/360dp/390dp/large screen serta aman untuk gesture navigation dan keyboard.
- Scroll/selection state sebisa mungkin bertahan saat switch tab dan back dari detail.
- Jangan menampilkan badges `NEW`, unread notification, jumlah sales, jumlah customer, rating, atau angka lain bila data aktual belum ada.

---

## 12. Urutan pengerjaan untuk Codex

Implementasikan dalam urutan berikut **pada satu branch pengembangan**:

### Fase A — Hide produk & navigasi

1. Tambahkan `FeatureFlags` pusat.
2. Refactor `BottomNavBar` + `AppShell` mapping route agar tab dinamis/benar login vs guest.
3. Tambahkan route placeholder/halaman baru yang memang akan diimplementasikan dalam fase berikut.
4. Matikan fetch initial produk yang tidak dipakai selama flag OFF.
5. Hide entry point produk; pastikan guard route/deep link.
6. Ubah initial flow masuk ke Home tanpa merusak auth.

### Fase B — Cabang & Home dasar

1. Reuse/fix API branch existing, whitelist field publik.
2. Tambahkan `SelectedBranchCubit` + persistence dan validasi id branch.
3. Buat halaman daftar/detail cabang.
4. Refactor Home: banner existing, card cabang, quick action; hilangkan product overlays.
5. Perbaiki pemanggilan banner agar tidak di dalam build.

### Fase C — Loyalty Home

1. Reuse data `ActiveCompanyCubit` dan `LoyaltyService` existing.
2. Perbaiki/menghindari kekeliruan `earnedPoint` vs `availablePoint`.
3. Tampilkan reward card untuk user dan GP/BCID valid, guest teaser bila perlu.
4. Navigasikan ke route reward/detail existing dengan extras yang benar.
5. Uji perubahan BCID dan session/logout agar cache point tidak bocor antarakun.

### Fase D — Sales dummy

1. Buat entity + repository interface + mock + Cubit + DI.
2. Home section carousel sales dengan filter cabang.
3. List sales + search/filter + detail.
4. Uji perubahan branch dan empty state.

### Fase E — Promo & artikel dummy

1. Buat repository mock terpisah dan data contoh yang jelas.
2. Tambahkan carousel dan halaman daftar/detail.
3. Pastikan konten dummy tidak mengiklankan promo sungguhan.
4. Optimasi UI, loading, empty, error, responsive.

### Fase F — QA dan handover

1. `dart format` seluruh file yang berubah.
2. Jalankan `flutter analyze` dan `flutter test` bila toolchain tersedia.
3. Tambah/perbarui widget/unit test untuk state cabang, route flags, filter sales, loyalty, dan perbedaan guest/login.
4. Perbaiki issue yang muncul dari perubahan ini; laporkan issue lama yang tidak terkait secara terpisah.
5. Berikan ringkasan file yang dibuat/diubah dan hasil pengujian, termasuk bila testing tidak dapat dijalankan.

---

## 13. Acceptance criteria / definition of done

Checklist berikut wajib terpenuhi:

- [ ] Banner API existing tampil di Home; tidak refetch pada setiap rebuild.
- [ ] Search produk, Kategori, Wishlist, Produk Baru, Produk Terlaris tersembunyi; **source tetap ada**.
- [ ] Tidak ada request produk/kategori otomatis dari inisialisasi yang sebenarnya tidak dibutuhkan selama fitur OFF.
- [ ] Route produk tersembunyi aman terhadap akses langsung dan tautan banner.
- [ ] Tab guest: Beranda, Cabang, Sales, Akun.
- [ ] Tab login: Beranda, Cabang, Sales, Customer, Akun.
- [ ] Cabang diambil dari API existing, tidak dari daftar hardcoded; field data publik only.
- [ ] Pilihan cabang tersimpan setelah restart, dipulihkan hanya jika masih valid.
- [ ] Pilihan cabang informasi **tidak mengubah** BCID/perusahaan aktif.
- [ ] Cabang aktif di Home, cabang, dan Sales selalu konsisten.
- [ ] Sales dummy ditampilkan hanya untuk cabang terpilih; search/filter/detail berjalan.
- [ ] Tidak ada nomor WhatsApp fiktif, data pegawai asli tanpa izin, atau klaim customer count.
- [ ] Loyalty menggunakan data asli, saldo `availablePoint` benar; tidak menampilkan periode di card Home.
- [ ] Guest tanpa perusahaan valid tidak melihat poin palsu atau data perusahaan lain.
- [ ] Tombol Tukar Poin & Rincian Poin bekerja dengan route + parameter existing.
- [ ] Promo & artikel dummy memiliki list/detail yang dapat dibuka dan jelas merupakan konten contoh.
- [ ] Semua section menangani loading/error/retry/empty secara layak.
- [ ] Tidak ada overflow/tertutup gesture bar Android/iOS.
- [ ] Tampilan mengikuti `design.md`, identitas brand EKAPLUS, bukan menyalin FIT HUB.
- [ ] Login, register/OTP, customer, loyalty existing, invoice, sales order, account tidak regresi.
- [ ] `flutter analyze` dan `flutter test` lulus atau keterbatasannya dilaporkan jelas.

## 14. Skenario uji prioritas

| Kasus | Hasil yang diharapkan |
| --- | --- |
| Guest masuk aplikasi | Home, banner, cabang, sales, promo/artikel; tidak ada saldo poin user lain |
| Login + perusahaan/GPID valid | Card poin tersedia dari API asli + detail/redeem bisa diakses |
| Login tanpa perusahaan | Tidak tampil 0 poin menyesatkan; CTA sesuai |
| Ganti customer aktif BCID A -> B | Poin dan nama GP ikut update; pilihan cabang informasi tetap |
| Pilih cabang Bogor -> Sidoarjo | Direktori Sales ikut berpindah; tidak ada sales Bogor tersisa |
| Restart aplikasi | Cabang pilihan tersimpan jika masih valid |
| Cabang nonaktif/hilang | Fallback state tidak crash |
| Search sales tidak ditemukan | Empty search state, bukan list dari cabang lain |
| Promo/artikel dummy diklik | Halaman detail terbuka, bukan dead CTA |
| Klik deep link produk saat flag OFF | Redirect/unavailable state, tanpa crash |
| Pull refresh Home | Request yang perlu saja, tidak berulang tanpa kendali |
| Android gesture navigation / iOS | Bottom nav dan konten aman dari system inset |

---

## 15. Output yang wajib diberikan Codex

Setelah coding selesai, sertakan:

1. Ringkasan perubahan nyata yang dilakukan.
2. Daftar **file added/modified**, dengan alasan singkat.
3. Struktur folder baru untuk fitur Cabang pilihan, Sales, Promo, Artikel.
4. Penjelasan flag untuk mengaktifkan kembali fitur produk.
5. Penjelasan sumber data per section: API vs dummy.
6. Hasil perintah `flutter analyze` dan `flutter test` (jangan mengaku sudah dijalankan jika tidak).
7. Catatan keterbatasan yang memerlukan API/data dari tim lain.
8. Instruksi singkat penggantian `MockRepository` ke API ketika backend siap.

**Non-negotiable:** Jangan menghapus kode katalog, jangan mengubah backend, jangan membuat data loyalty palsu, jangan mengubah BCID saat memilih cabang informasi, dan jangan mengklaim dummy sebagai data resmi Ekatunggal.
