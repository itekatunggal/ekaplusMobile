# EKAPLUS Mobile Design System & UI Engineering Standard

> **Status:** Canonical design reference untuk pengembangan halaman baru EKAPLUS Mobile.
> **Tanggal baseline:** 22 Oktober 2026.
> **Tujuan utama:** semua halaman baru harus terasa sebagai bagian dari aplikasi yang sama—warna, tipografi, spacing, card, header, state, loading, list, pagination, form, dialog, dan interaction tidak boleh dibuat dengan style sendiri-sendiri.

---

## 0. Aturan Wajib untuk Developer / Codex

Sebelum membuat atau mengubah halaman EKAPLUS Mobile:

1. **Baca file ini terlebih dahulu.**
2. Gunakan komponen shared yang sudah ada sebelum membuat widget baru.
3. Gunakan `AppColors`, `AppFonts`, `CustomHeaderScaffold`, `CustomHeaderAppBar`, `CustomHeaderActionButton`, dan komponen existing lain yang relevan.
4. Jangan membuat warna, radius, shadow, ukuran font, atau spacing baru secara acak jika sudah ada token/pola di dokumen ini.
5. Halaman baru harus mengikuti pola visual **Account + Ubah Profil + Wishlist**.
6. Card utama harus terlihat terpisah dari background. Jangan membuat surface putih tanpa border/shadow yang membuat card menyatu dengan halaman.
7. Untuk halaman list/data besar, wajib menangani minimal: **initial loading, loading more, empty, search empty, error, retry, dan end-of-list**.
8. Untuk pagination, jangan replace list saat load halaman berikutnya. Data lama tetap tampil dan spinner kecil hanya muncul di bawah list.
9. Untuk action yang menghapus/mengubah data penting, gunakan confirmation dialog dan feedback snackbar.
10. Jangan mengunci layout ke satu ukuran layar. Wajib aman pada lebar `< 360dp`.
11. Jangan menggandakan widget yang secara fungsi dan visual sama. Jika pola muncul di ≥2 halaman, refactor menjadi shared widget/token.
12. Prioritas konsistensi: **reuse > extension > komponen baru**.

---

# 1. Referensi yang Diaudit

Design system ini diturunkan dari implementasi aktif berikut:

- `lib/constant.dart`
- `lib/main.dart`
- `lib/core/shared_widgets/custom_header.dart`
- `lib/features/account/presentation/pages/account_page.dart`
- `lib/features/account/presentation/widgets/account_logged_in_view.dart`
- `lib/features/account/presentation/pages/edit_profile_page.dart`
- `lib/features/wishlist/presentation/pages/wishlist_page.dart`
- `lib/features/wishlist/presentation/widgets/wishlist_content.dart`
- `lib/features/wishlist/presentation/widgets/wishlist_list_view.dart`
- `lib/features/wishlist/presentation/widgets/wishlist_item_card.dart`
- `lib/features/wishlist/presentation/widgets/wishlist_empty_state.dart`
- `lib/features/wishlist/presentation/widgets/wishlist_locked_state.dart`
- `lib/features/wishlist/presentation/bloc/wishlist_bloc.dart`

Dokumen ini **bukan hanya dokumentasi kondisi saat ini**. Beberapa nilai dinormalisasi menjadi standar final supaya halaman baru tidak mewarisi inkonsistensi kecil yang sudah ada.

---

# 2. Prinsip Visual EKAPLUS

Karakter visual aplikasi:

- Bersih dan ringan.
- Dominan background abu sangat muda.
- Surface/card putih.
- Merah EKAPLUS sebagai warna brand dan primary action.
- Kuning sebagai secondary/accent CTA tertentu.
- Banyak menggunakan slate/neutral untuk hierarchy teks.
- Card menggunakan radius cukup besar (`16dp`) dengan border tipis dan shadow halus.
- Header kuat secara brand tetapi body tetap tenang.
- Spacing rapat namun tidak sesak.
- Ukuran font mobile relatif compact.
- Ikon menggunakan gaya outline/rounded secara dominan.
- Elevation tidak boleh berat.

---

# 3. Font Family

## 3.1 Primary Font

**Poppins**

Dipakai untuk:

- heading
- title
- body utama
- label
- button
- badge
- navigation
- menu
- search

Existing constant:

```dart
class AppFonts {
  static const primaryFont = "poppins";
  static const secondaryFont = "lato";
}
```

Di `pubspec.yaml`, family terdaftar sebagai:

```yaml
- family: Poppins
- family: Lato
```

### Standard final

Nama design-nya tetap:

- Primary: `Poppins`
- Secondary: `Lato`

> Catatan engineering: sebaiknya nama family pada constant disamakan persis dengan deklarasi `pubspec.yaml` agar tidak bergantung pada fallback/case handling.

## 3.2 Secondary Font

**Lato**

Gunakan terbatas untuk:

- kode/SKU
- teks supporting tertentu
- konten sekunder yang membutuhkan perbedaan karakter visual

Jangan memakai Lato untuk heading utama halaman.

---

# 4. Typography Scale

Semua ukuran di bawah menggunakan logical pixel Flutter (`sp` secara konsep).

## 4.1 Heading H1–H6

| Token | Penggunaan | Size | Weight | Color default | Line height | Letter spacing |
|---|---|---:|---|---|---:|---:|
| H1 | Page title / top-level heading | 18 Android / 19 iOS | 700 | `#0F172A`; pada header `#FFFFFF` | 1.20 | `-0.3` |
| H2 | Dialog title / profile name besar / major section | 15–17 | 700 | `#1E293B` | 1.25 | `-0.2` s/d `0` |
| H3 | Empty/error title / card title penting | 13–14 | 700 | `#1E293B` | 1.30 | `0` |
| H4 | Row title / product title | 12 | 600–700 | `#1E293B` atau `#0F172A` | 1.32 | `-0.15` s/d `0` |
| H5 | Secondary row title / compact heading | 11–11.5 | 600 | `#334155` | 1.35 | `0` |
| H6 | Section eyebrow uppercase | 9.5 | 700 | `#94A3B8` | 1.30 | `0.45` |

### H6 / Section Eyebrow wajib

Untuk judul section seperti:

- `PREFERENSI AKUN`
- `PENGATURAN & KEAMANAN AKUN`
- `INFORMASI AKUN PERSONAL`

Gunakan:

```dart
const TextStyle(
  color: Color(0xFF94A3B8),
  fontSize: 9.5,
  fontWeight: FontWeight.w700,
  letterSpacing: .45,
)
```

Teks ditampilkan uppercase.

## 4.2 Body & Caption

| Token | Size | Weight | Color | Penggunaan |
|---|---:|---|---|---|
| Body L | 12 | 500–600 | `#334155` / `#1E293B` | row title, compact button |
| Body M | 11.5 | 400–600 | `#475569` / `#64748B` | value, description |
| Body S | 11 | 400–500 | `#64748B` / `#94A3B8` | helper, subtitle |
| Caption | 10 | 400–600 | `#64748B` / `#94A3B8` | labels, info |
| Micro | 9–9.5 | 600–700 | semantic | badge, count, small action |
| Nano | 8–8.5 | 600–700 | semantic | tiny metadata badge |

## 4.3 Font Weight Standard

Gunakan hanya weight utama berikut sebisa mungkin:

- `400` Regular
- `500` Medium
- `600` SemiBold
- `700` Bold

Hindari `800/900` kecuali benar-benar ada kebutuhan brand/display.

---

# 5. Color System

## 5.1 Brand Colors

| Token | Hex | Penggunaan |
|---|---|---|
| Primary | `#B11F23` | brand utama, CTA, active, destructive brand |
| Primary Gradient Top | `#D52A2F` | bagian atas header gradient |
| Secondary | `#FDD100` | accent, notification dot, selected CTA tertentu |
| White | `#FFFFFF` | surface/card |
| Black | `#1A1A1A` | legacy black / button text tertentu |

Existing:

```dart
AppColors.primaryColor   // #B11F23
AppColors.secondaryColor // #FDD100
AppColors.background     // #F8FAFC
```

## 5.2 Neutral / Slate

| Token | Hex | Fungsi |
|---|---|---|
| Text Strong | `#0F172A` | product title / strongest content |
| Text Primary | `#1E293B` | heading, row title |
| Text Secondary | `#475569` | secondary content |
| Text Muted | `#64748B` | subtitle / value secondary |
| Text Disabled | `#94A3B8` | hint, section title, inactive |
| Icon/Border Mid | `#CBD5E1` | chevron, input/icon inactive |
| Border | `#E2E8F0` | input, metadata, outlined button |
| Divider / Card Border | `#F1F5F9` | divider dan canonical card border |
| Surface Alt | `#F8FAFC` | input fill, image container, page background |
| Page Alt | `#F6F7F9` | beberapa screen Account/Profile |

## 5.3 Semantic Colors

### Success

- Strong: `#16A34A`
- Text/badge: `#059669`
- Background: `#ECFDF5`
- Border: `#A7F3D0`

### Danger / Destructive

- Default EKAPLUS: `#B11F23`
- Soft background: `#FFF1F2`
- Soft border: `#FECACA`

### Info / Blue

- Strong: `#2563EB`
- Background: `#EFF6FF`

### Warning / Amber

- Strong: `#D97706`
- Background: `#FFFBEB`

### Purple / Security

- Strong: `#7C3AED`
- Background: `#F5F3FF`

### WhatsApp Context

- Dark green: `#128C7E`
- Bright green: `#25D366`
- Light background: `#DCFCE7`

Warna WhatsApp hanya untuk action yang benar-benar membuka WhatsApp.

---

# 6. Page Background

Canonical background halaman:

```dart
const Color(0xFFF8FAFC)
```

Untuk halaman Account/Profile yang sudah memakai `#F6F7F9`, masih diterima.

### Aturan baru

Untuk screen baru, default gunakan:

```dart
AppColors.background // #F8FAFC
```

Jangan menggunakan pure white sebagai seluruh page background jika halaman berisi card putih, karena hierarchy surface akan hilang.

---

# 7. Spacing System

Gunakan scale berikut:

```text
2, 4, 6, 8, 10, 12, 14, 16, 20, 24, 28, 32
```

Jangan membuat nilai seperti `17`, `19`, `23` tanpa alasan layout khusus.

## 7.1 Horizontal Page Padding

- Standard content/list: `12dp`
- Form/profile detail: `16dp`
- Modal/bottom sheet: `20dp`
- Empty/error state: `24–32dp`

## 7.2 Vertical Section Gap

Canonical antar-card/section:

```dart
const SizedBox(height: 14)
```

Gunakan `16dp` jika section perlu napas lebih besar.

## 7.3 Max Content Width

Untuk Account/Profile dan screen form/detail:

```dart
const BoxConstraints(maxWidth: 680)
```

Konten harus di-center pada tablet/lebar besar.

---

# 8. Radius System

| Token | Radius | Penggunaan |
|---|---:|---|
| R4 | 4 | shimmer bar kecil |
| R5 | 5 | micro badge / checkbox |
| R6 | 6 | SKU badge |
| R7 | 7 | compact button |
| R8 | 8 | small controls |
| R9 | 9 | icon container / retry button |
| R10 | 10 | field value box / medium button |
| R11 | 11 | image shell / search |
| R12 | 12 | form input / primary button |
| R16 | 16 | canonical card |
| R18 | 18 | pill action tertentu |
| R20 | 20 | filter chip/pill |
| R24 | 24 | bottom sheet top radius |
| R28 | 28 | branded header bottom radius |

Jangan mencampur radius random pada komponen sejenis.

---

# 9. Elevation, Border & Surface

## 9.1 Canonical Card Decoration — WAJIB untuk halaman baru

Standar final menggabungkan strength Account dan Wishlist:

```dart
const BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  border: Border.fromBorderSide(
    BorderSide(color: Color(0xFFF1F5F9), width: 1),
  ),
  boxShadow: [
    BoxShadow(
      color: Color(0x0D0F172A),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ],
)
```

### Kenapa border ditambahkan?

Account existing memakai shadow halus tetapi tanpa border. Pada background sangat terang card bisa terasa menyatu. Wishlist sudah memakai border `#F1F5F9` dan hasil separation lebih jelas.

**Mulai halaman baru:** gunakan **border + shadow**.

## 9.2 List/Product Card

Wishlist-style card:

```text
background        #FFFFFF
radius            16
border            1px #F1F5F9
shadow color      rgba(15,23,42,0.05) / #0D0F172A
shadow blur       14
shadow offset     (0,4)
padding           12
vertical margin   5
```

Selected state:

```text
background  primary @ 5%
border      primary 1.5px
```

## 9.3 Divider

Default divider:

```text
height: 1
color: #F1F5F9
```

Gunakan indent jika divider hanya memisahkan content setelah icon.

---

# 10. Custom Header Standard

## 10.1 Default Page Header

Untuk halaman tanpa search di dalam header gunakan:

```dart
CustomHeaderScaffold(...)
```

Bukan AppBar custom baru.

Untuk halaman dengan search utama di dalam header, gunakan pola canonical
Wishlist pada bagian **11. Header + Search Pattern**. Jangan meletakkan search
sebagai child pertama `CustomHeaderScaffold.body`, karena posisi judul dan
search akan berbeda dari header Wishlist.

### Default geometry

```text
headerHeight  = 154
contentTop    = 116
bottomRadius  = 28
bodyPadding   = horizontal 12
```

Body overlap ke header sekitar `38dp`.

## 10.2 Brand Header Gradient

```dart
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFD52A2F),
    AppColors.primaryColor,
  ],
)
```

Shadow:

```text
color       #1F0F172A
blur        12
offset      (0,4)
```

## 10.3 Header Title

Android:

```text
18sp / 700 / white / letterSpacing -0.3
```

iOS:

```text
19sp / 700 / white / letterSpacing -0.3
```

Subtitle:

```text
10sp / 400 / white @ 72%
```

Brand eyebrow `EKAPLUS`:

```text
9sp / 500 / #FECACA / letterSpacing 0.35
```

## 10.4 Header Icon Button

```text
width/height      40
shape             circle
background        white @ 16%
icon              white
icon size         17–21
```

Gunakan `CustomHeaderActionButton`.

## 10.5 Header Tanpa Back Button

Root tabs seperti Account/Wishlist:

```dart
showBackButton: false
```

Subpage seperti Ubah Profil:

```dart
showBackButton: true
// atau onLeadingPressed: () => context.pop()
```

---

# 11. Header + Search Pattern

Wishlist memiliki header tinggi `178dp` dengan search overlay di bawah header.
Pola ini menjadi implementasi canonical untuk semua halaman baru yang memiliki
search utama, termasuk halaman list dengan tombol back atau header action.

Untuk halaman yang membutuhkan search utama di header:

```text
header height       178
search left/right   16
search bottom       18
search height       42
search bg           #FFFFFF
search radius       11
search shadow       #100F172A blur 8 offset (0,2)
```

Search text:

```text
11.5sp / 500 / #1E293B
```

Hint:

```text
11sp / 400 / #94A3B8
```

Search icon:

```text
18px / #94A3B8
```

Close icon ketika query tidak kosong:

```text
17px / #94A3B8
```

Font seluruh field wajib memakai `AppFonts.primaryFont` (`Poppins`).

## 11.1 Canonical Widget Structure

Gunakan struktur yang sama dengan halaman Wishlist:

```dart
Widget _buildHeader(BuildContext context) {
  return SizedBox(
    height: 178,
    child: Stack(
      children: [
        Positioned.fill(
          child: CustomHeaderAppBar(
            title: 'Judul Halaman',
            brandStyle: true,
            showBackButton: false, // true untuk subpage
            height: 178,
            actions: [
              CustomHeaderActionButton(
                tooltip: 'Nama action',
                onPressed: _onAction,
                icon: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 18,
          child: CustomHeaderSearchField(
            controller: _searchController,
            hintText: 'Cari...',
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
          ),
        ),
      ],
    ),
  );
}
```

Page shell:

```dart
Scaffold(
  backgroundColor: AppColors.background,
  body: Column(
    children: [
      _buildHeader(context),
      Expanded(child: pageContent),
    ],
  ),
)
```

### Aturan posisi

- `CustomHeaderAppBar` harus berada di dalam `Positioned.fill`.
- Search harus berada di dalam `Positioned(left: 16, right: 16, bottom: 18)`.
- Jangan menambahkan padding horizontal lagi di dalam posisi search.
- Jangan menggunakan `CustomHeaderScaffold` lalu menaruh search sebagai child
  pertama body untuk pattern ini.
- Root page memakai `showBackButton: false`; subpage memakai
  `showBackButton: true` dan callback navigasi existing.
- Header action wajib memakai `CustomHeaderActionButton`, berukuran visual
  `19px`, dengan tooltip.
- Subtitle hanya ditambahkan bila requirement halaman memang membutuhkannya;
  default pola Wishlist tidak menggunakan subtitle.

## 11.2 Canonical Search Field

Selalu gunakan `CustomHeaderSearchField` dari
`lib/core/shared_widgets/custom_header.dart`. Jangan membuat `TextField` search
baru di masing-masing halaman.

Contract visual `CustomHeaderSearchField`:

```text
height              42
background          #FFFFFF
radius              11
shadow              #100F172A / blur 8 / offset (0,2)
font family         Poppins
input text          11.5 / 500 / #1E293B
hint text           11 / 400 / #94A3B8
search icon         18 / #94A3B8
close icon          17 / #94A3B8
content padding     vertical 12
text input action   search
```

### Canonical rule

Jika dibutuhkan variasi behavior, perluas parameter
`CustomHeaderSearchField`; jangan copy-paste dekorasi atau `TextField` baru.

---

# 12. Account/Profile Card Pattern

## 12.1 Profile Summary / Identity Card

```text
card radius       16
card bg           white
canonical border  #F1F5F9
shadow            subtle
padding           14–16
avatar            62 Account / 84 Profile
```

Name:

```text
14–15sp / 700 / #1E293B
```

Email/username:

```text
10.5–11sp / 400 / #64748B atau #94A3B8
```

Compact edit action:

```text
icon primary 19
label 10sp / 600 / primary
radius touch area 12
```

## 12.2 Avatar

Avatar standard:

```text
shape         circle
border        2px #FECACA
fallback bg   primary
initial       white / 700
```

Camera badge:

```text
size          34% dari avatar
bg            primary
border        2px white
shape         circle
```

---

# 13. Section Card Pattern

Untuk grup menu atau data:

```text
surface            white
radius             16
border             #F1F5F9
shadow             subtle
clipBehavior       antiAlias
```

Header section:

```text
padding left/right 14
padding top        13–14
padding bottom     8–10
font               H6
```

Divider setelah header atau row:

```text
#F1F5F9 / 1dp
```

---

# 14. Menu Row Pattern

Account row:

```text
horizontal padding 12
vertical padding   10
icon box            32x32
icon box radius     9
icon size           18
icon/text gap       11
chevron size        18
chevron color       #CBD5E1
```

Title:

```text
12sp / 600 / #1E293B
```

Subtitle:

```text
9.5sp / 400 / #94A3B8
```

### Default icon style

```text
icon bg       #F1F5F9
icon color    #475569
```

### Destructive row

```text
icon bg       #FFF1F2
icon/title    primary
```

---

# 15. Security / Setting Row Pattern

Profile security row:

```text
horizontal padding   13
vertical padding     11
icon box             34x34
radius               10
icon                 18
text gap             11
```

Title:

```text
11.5sp / 600 / #1E293B
```

Subtitle:

```text
9.5sp / 400 / #94A3B8
```

Action chip `Ubah`:

```text
padding H8 V4
border #FECACA
radius 7
text primary 9sp / 600
```

---

# 16. Form Field Standard

Gunakan style dari Edit Profile bottom sheet.

```text
filled              true
fillColor           #F8FAFC
content padding     H14 V13
radius              12
default border      #E2E8F0
focused border      primary
label size          12
input text          12–13
```

Dart baseline:

```dart
InputDecoration(
  filled: true,
  fillColor: const Color(0xFFF8FAFC),
  contentPadding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 13,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primaryColor),
  ),
)
```

## 16.1 Readonly / Data Value Box

Untuk row data profil:

```text
bg          #F8FAFC
border      #E2E8F0
radius      10
padding     H12 V11
value       11.5sp / 600 / #1E293B
action      10sp / 600 / primary
```

---

# 17. Button System

## 17.1 Primary Button

```text
height          48
background      primary #B11F23
foreground      white
radius          12
text            12–14sp / 600–700
elevation       0 atau sangat minimal
```

Contoh: `Selesai`, `Simpan Perubahan`.

## 17.2 Secondary Yellow CTA

Gunakan untuk CTA eksplorasi/entry tertentu, bukan action destructive.

```text
background    #FDD100
text          #1A1A1A / #0F172A
weight        700
radius        8–10
```

Contoh: `Jelajahi Produk`, `Masuk` pada locked state.

## 17.3 Neutral Outlined

```text
border        #E2E8F0
text          #475569
radius        9–10
```

## 17.4 Soft Primary Outlined

```text
border        #FECACA
text/icon     primary
radius        10
```

Contoh: `Ubah Foto Profil`, action edit kecil.

## 17.5 Compact Action Button

```text
height       30–31
radius       7
text         9.5–10.5 / 600–700
icon         14–15
```

Gunakan untuk action di dalam card list.

---

# 18. Badge / Status / Chip

## 18.1 Success Badge

```text
bg          #ECFDF5
border      #A7F3D0
text        #059669
radius      20
padding     H6 V2
font        8sp / 700
```

Contoh: `Terverifikasi`.

## 18.2 Filter Chip

Unselected:

```text
bg          white
border      #E2E8F0
radius      20
shadow      sangat tipis
label       #334155 / 10.5 / 700
count bg    #F1F5F9
count text  #64748B / 9 / 700
```

Selected:

```text
bg          primary
border      primary
label       white
count bg    white @ 22%
count text  white
```

Padding:

```text
H11 V6
```

Chip gap:

```text
8dp
```

---

# 19. Product / List Card Pattern

Untuk halaman list produk/item:

## 19.1 Card

```text
margin vertical      5
padding               12
radius                16
background            white
border                #F1F5F9
shadow blur           14
shadow offset         (0,4)
```

## 19.2 Product Image

Normal:

```text
92x92
```

Small screen `< 360dp`:

```text
82x82
```

Image shell:

```text
padding        4
bg             #F8FAFC
border         #F1F5F9
radius         11
inner radius   8
fit            BoxFit.contain
```

## 19.3 SKU Badge

```text
bg          #F1F5F9
radius      6
padding     H8 V4
font        Lato
size        11–11.5
weight      600
color       #64748B
```

## 19.4 Product Name

```text
maxLines      2
overflow      ellipsis
font          Poppins
size          11.5 small / 12 normal
weight        700
color         #0F172A
line height   1.32
letterSpace   -0.15
```

## 19.5 Metadata Badge

```text
bg          #F8FAFC
border      #E2E8F0
radius      5
padding     H6 V3
icon        10 / #64748B
font        8.5 / 600 / #64748B
max width   150
```

---

# 20. Search, Filter, Sort

## 20.1 Search Interaction

- Search field harus memberikan feedback langsung.
- Clear button hanya muncul jika query tidak kosong.
- Query di-trim.
- Pencarian text harus case-insensitive kecuali domain membutuhkan case-sensitive.

Wishlist saat ini melakukan local filter terhadap `_cachedItems` berdasarkan:

```text
itemName
itemCode
```

### Untuk data server besar

Jika jumlah data melebihi data yang sudah ter-load:

- gunakan server-side search;
- debounce ideal `300–500ms`;
- reset `page = 1` saat query berubah;
- clear list lama hanya setelah state baru siap atau tampilkan loading state yang tidak membuat layar berkedip;
- jangan mengklaim hasil search global jika hanya memfilter page yang sudah dimuat.

## 20.2 Filter Chip

- filter aktif harus jelas secara warna;
- count boleh tampil di dalam chip;
- horizontal list memakai `BouncingScrollPhysics`;
- category list disort alphabetically bila tidak ada business priority.

---

# 21. Infinite Scroll / Pagination Standard

Ini adalah contract utama untuk halaman list baru.

## 21.1 Page Size

Default:

```dart
static const int defaultLimit = 20;
```

## 21.2 Initialization

Load pertama hanya satu kali saat widget siap:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!_hasInitialized && mounted) {
    loadFirstPage();
    _hasInitialized = true;
  }
});
```

Gunakan `AutomaticKeepAliveClientMixin` untuk root tab/list yang perlu mempertahankan state/scroll.

## 21.3 Scroll Controller

Gunakan satu `ScrollController` yang dimiliki parent list/page.

Listener harus dilepas di `dispose()`.

## 21.4 Trigger Threshold

Load halaman berikutnya saat posisi mencapai minimal:

```text
90% dari maxScrollExtent
```

Baseline:

```dart
if (currentOffset >= maxScrollExtent * 0.90) {
  loadNextPage();
}
```

## 21.5 Guard Sebelum Request

Wajib cek:

```dart
if (!scrollController.hasClients) return;
if (isLoadingMore) return;
if (!hasMore) return;
if (!mounted) return;
if (maxScrollExtent <= 0) return;
```

Di BLoC/repository layer juga wajib ada guard kedua:

```dart
if (state is! LoadedState) return;
if (!state.hasMore || state.isLoadingMore) return;
```

UI guard **tidak cukup**. Domain/state guard mencegah duplicate API request saat rebuild cepat.

## 21.6 Next Page

```dart
nextPage = current.page + 1;
```

Parameter berikut harus tetap diwariskan:

- `limit`
- `search`
- `filters`
- `orderBy`
- `fields`

## 21.7 Append Behavior

Jangan replace list lama.

```dart
items: [...current.items, ...newItems]
```

## 21.8 hasMore

Baseline:

```dart
hasMore = newItems.length == current.limit;
```

Jika API menyediakan total/count/next cursor, prioritaskan metadata resmi API dibanding heuristic ini.

## 21.9 Loading More UI

Saat load page > 1:

- list lama tetap tampil;
- jangan tampilkan full page shimmer lagi;
- spinner kecil di bawah;
- ukuran sekitar `21–22dp`;
- `strokeWidth 2.2–2.3`;
- color primary;
- vertical padding `14–16`.

## 21.10 Error Saat Load More

Jika network error terjadi saat page berikutnya:

- data existing jangan hilang;
- `isLoadingMore = false`;
- pertahankan current state;
- global connectivity dialog/snackbar dapat memberi feedback.

Untuk non-network/domain error, tampilkan feedback tanpa mengosongkan list jika memungkinkan.

## 21.11 Refresh

Refresh harus kembali ke first page:

```text
page = 1
clear pagination cursor
request ulang data
```

Jika halaman memiliki pull-to-refresh, gunakan `RefreshIndicator` dan jangan membuat mekanisme refresh kedua yang bertabrakan.

---

# 22. Loading State Standard

## 22.1 Initial Loading

Untuk halaman list/card gunakan **shimmer skeleton**, bukan spinner besar jika struktur UI sudah diketahui.

Wishlist baseline:

```text
placeholder count      5
card height            sekitar 118
card radius            12–16
card border            #E2E8F0 / #F1F5F9
base shimmer           grey[300]
highlight shimmer      grey[100]
```

Skeleton harus menyerupai final layout:

- image box
- short label
- title bar
- secondary bar
- action placeholders

## 22.2 Simple Loading

Untuk screen kecil atau auth/session loading:

```dart
CircularProgressIndicator(
  color: AppColors.primaryColor,
)
```

---

# 23. Empty State Standard

## 23.1 Empty Data

Struktur:

1. visual/icon
2. title
3. short description
4. CTA jika user dapat menyelesaikan keadaan kosong

Canonical text hierarchy:

```text
title        13–18 / 700 / #1E293B atau black
description  11–13 / 400 / #64748B / lineHeight 1.4
```

## 23.2 Search Empty

Gunakan icon circle:

```text
58x58
bg       #F1F5F9
icon     28 / #94A3B8
```

Title:

```text
13 / 700 / #1E293B
```

Description:

```text
11 / 400 / #94A3B8 / lineHeight 1.4
```

Search empty **berbeda** dari dataset empty.

---

# 24. Error State Standard

Error page/list:

Icon shell:

```text
58x58
circle
bg       #FFF1F2
icon     primary
size     28
```

Title:

```text
13 / 700 / #1E293B
```

Description:

```text
11 / 400 / #64748B / lineHeight 1.4
```

Retry:

```text
OutlinedButton + refresh icon
foreground primary
border primary
radius 9
```

Pesan error user-facing harus singkat dan actionable.

Jangan tampilkan stack trace/raw exception di UI produksi.

---

# 25. Locked / Authentication Required State

Jika fitur hanya untuk user login:

- jangan menampilkan error teknis;
- tampilkan locked state yang menjelaskan alasan;
- sediakan CTA `Masuk` dan `Daftar` bila relevan;
- gunakan visual yang sesuai fitur.

CTA utama boleh menggunakan secondary yellow pada entry/auth prompt agar tidak terlihat destructive.

---

# 26. Selection Mode & Bulk Action

Pattern dari Wishlist.

## 26.1 Selection Mode

Saat mode selection aktif:

- top action berubah `Pilih` → `Batal`;
- setiap card menampilkan checkbox custom;
- tap card memilih/unselect, bukan membuka detail;
- selected card berubah tint + border;
- selected IDs harus dibersihkan saat keluar selection mode.

## 26.2 Checkbox

```text
20x20
radius 5
border 1.5
unselected bg white / border #CBD5E1
selected bg primary / border primary
check icon white 14
animation 150ms
```

## 26.3 Bulk Bar

```text
margin H16 top2 bottom8
padding H10 V7
bg primary @ 7%
border primary @ 12%
radius 9
```

Delete button disabled jika tidak ada selection.

## 26.4 Data Integrity

Saat list berubah:

- hapus selected IDs yang tidak lagi tersedia;
- jangan menyimpan selection yang orphaned.

---

# 27. Optimistic Update Standard

Untuk action ringan seperti remove wishlist:

1. simpan previous state;
2. update UI segera;
3. call API;
4. jika success, pertahankan;
5. jika network failure, rollback previous state;
6. jika domain/server error yang jelas, feedback user dan reload bila perlu.

Jangan gunakan optimistic update untuk action finansial/security tanpa desain transaction/rollback yang jelas.

---

# 28. Dialog Standard

## 28.1 Confirmation Dialog

```text
inset horizontal   28
radius             16
bg                 white
padding            20–24
```

Icon shell:

```text
52–64
circle
semantic soft background
```

Title:

```text
15–17 / 700
```

Description:

```text
11.5–13.5 / 400 / #64748B
lineHeight 1.4
```

Buttons:

- kiri: cancel/outlined neutral
- kanan: confirm/primary atau danger
- gap: `10dp`

Button radius `9–10`.

---

# 29. Bottom Sheet Standard

Untuk edit/select action:

```text
background      white
top radius      24
isScrollControlled true
```

Content padding:

```text
left/right  20
top         14
bottom      20 + keyboard inset
```

Handle:

```text
40x4
#CBD5E1
radius 10
```

Sheet title:

```text
17 / 700
```

Subtitle:

```text
11 / 400 / #64748B
```

Gap title→subtitle: `4dp`.

Gap sebelum form: `18dp`.

---

# 30. Sticky Bottom Action

Untuk screen edit/form panjang:

Container:

```text
bg            white
top border    #F1F5F9
padding       H16 V12
SafeArea      top false
```

Content tetap mengikuti `maxWidth: 680`.

Primary CTA:

```text
width      full
height     48
radius     12
primary bg
white text
```

Jangan membungkus bottom bar dengan card besar atau menyisakan tepi putih aneh.

---

# 31. Snackbar / Feedback

Gunakan shared `AppSnackbar` jika tersedia.

Gunakan semantic feedback:

- success → green
- error → red
- info → neutral/info style

Floating snackbar custom:

```text
behavior      floating
radius        10
margin        12
```

Pesan action harus pendek, misalnya:

```text
"3 item dihapus dari wishlist"
```

Bukan log teknis API.

---

# 32. Motion & Interaction

## 32.1 Page Transition

Global app menggunakan fade-through + slight scale:

```text
scale 0.94 → 1.0
curve easeOutCubic
```

Jangan menambahkan transition page custom lain kecuali ada kebutuhan khusus.

## 32.2 Card Press

Wishlist menggunakan scale:

```text
1.0 → 0.98
150ms
Curves.easeInOut
```

Cocok untuk interactive card.

Jangan memberi scale animation pada seluruh menu sederhana jika terasa berlebihan.

## 32.3 Animated Selection

Selection container sekitar `150–180ms`.

Semua micro animation sebaiknya berada di rentang `120–220ms`.

---

# 33. Responsive Rules

## 33.1 Primary Small-Screen Breakpoint

```dart
final isSmallScreen = screenWidth < 360;
```

## 33.2 Compact Breakpoint

Action button Wishlist memakai compact mode di sekitar:

```text
< 370dp
```

Gunakan breakpoint ini hanya untuk mengurangi ukuran internal, bukan membuat layout yang benar-benar berbeda tanpa kebutuhan.

## 33.3 Tablet / Wide Screen

Content form/account:

```text
maxWidth 680
center aligned
```

List/grid dapat memiliki aturan sendiri, tetapi harus memakai token warna/typography/card yang sama.

---

# 34. Text Scaling / Accessibility

Existing Wishlist membatasi `textScaler` maksimum `1.0` untuk menjaga layout compact.

### Standard baru

Untuk screen baru:

1. **Jangan langsung mematikan text scaling secara global.**
2. Prioritaskan `Flexible`, `Expanded`, `Wrap`, `maxLines`, dan responsive layout.
3. Jika ada komponen sangat padat yang benar-benar rusak pada scale besar, clamp hanya pada komponen tersebut dan dokumentasikan alasannya.
4. Touch target interactive utama idealnya mendekati `40–48dp` walau visual icon lebih kecil.
5. Semua IconButton penting wajib memiliki `tooltip`.

---

# 35. Iconography

Preferensi:

- Material Rounded / Outlined
- FontAwesome hanya jika sudah menjadi bagian shared component atau ikon spesifik tidak tersedia di Material

Default:

```text
small icon       14–15
row icon         18
header icon      17–21
empty icon       28+
```

Jangan campur filled, outlined, dan sharp icon secara acak dalam satu group.

---

# 36. Page Blueprint — Standard Non-List Page

Gunakan struktur:

```text
CustomHeaderScaffold
└─ body
   └─ Center
      └─ ConstrainedBox(maxWidth: 680)
         └─ ScrollView
            ├─ Primary card
            ├─ gap 14
            ├─ Section card
            ├─ gap 14
            ├─ Section card
            └─ bottom spacing 24–28
```

Jika ada sticky CTA:

```text
Column
├─ Expanded(scroll content)
└─ sticky bottom action
```

---

# 37. Page Blueprint — Standard Data List

```text
Scaffold / CustomHeader layout
├─ Branded header
├─ optional search
├─ optional filters
└─ Expanded
   └─ state switch
      ├─ loading shimmer
      ├─ empty state
      ├─ error + retry
      └─ list
         ├─ card 1
         ├─ card 2
         ├─ ...
         └─ loading-more spinner
```

List horizontal padding default:

```text
12dp
```

Card gap visual sekitar `8–10dp`; jika card sudah memiliki vertical margin 5, separator tambahan harus minimal.

---

# 38. State Rendering Priority

Untuk halaman data, gunakan priority yang jelas:

```text
1. valid cached/existing data
2. empty data
3. explicit error
4. initial loading
```

Kenapa existing data didahulukan?

Agar refresh/load more tidak membuat seluruh layar berkedip menjadi loading.

Jika data lama masih valid, pertahankan data dan tampilkan loading kecil/non-blocking.

---

# 39. Network Error Behavior

Aplikasi sudah memiliki connection handling global.

Halaman fitur tidak perlu selalu menghapus state hanya karena network sementara gagal.

Untuk pagination/load-more:

- retain data existing;
- stop spinner;
- jangan replace dengan error full screen.

Untuk first load tanpa cache:

- tampilkan error state + retry.

---

# 40. Image Loading

Gunakan `CachedNetworkImage` untuk remote image jika sesuai.

Pattern:

- shimmer placeholder;
- `BoxFit.contain` untuk product image;
- fallback icon jika gagal;
- jangan render broken URL icon default.

Thumbnail product disarankan memakai server image transformation jika API mendukung untuk menghemat bandwidth.

---

# 41. Content Overflow Rules

### Nama/user/item

```text
maxLines 1–2
overflow ellipsis
```

### Subtitle

```text
maxLines 1
```

### Metadata badge

```text
max width
maxLines 1
ellipsis
```

Gunakan `Flexible` atau `Expanded` di Row sebelum menambahkan hard-coded width.

---

# 42. Naming & Shared Component Rules

Untuk komponen reusable baru gunakan nama berdasarkan fungsi, bukan halaman.

Bagus:

```text
AppSurfaceCard
AppSectionCard
AppStatusBadge
AppPrimaryButton
AppEmptyState
AppErrorState
AppSearchField
AppLoadingMoreIndicator
```

Kurang baik:

```text
CustomerRedCard2
NewWishlistBox
PageXButtonStyle
```

Jika design token baru dibutuhkan, tambahkan ke shared theme/constants, bukan ulang raw value di banyak file.

---

# 43. Recommended Design Tokens Refactor

Untuk menjaga konsistensi jangka panjang, Codex sebaiknya secara bertahap memindahkan raw value berulang ke token seperti:

```dart
class AppDesign {
  static const pagePadding = 12.0;
  static const formPagePadding = 16.0;
  static const sectionGap = 14.0;
  static const maxContentWidth = 680.0;

  static const cardRadius = 16.0;
  static const inputRadius = 12.0;
  static const compactButtonRadius = 7.0;

  static const textStrong = Color(0xFF0F172A);
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF475569);
  static const textMuted = Color(0xFF64748B);
  static const textDisabled = Color(0xFF94A3B8);

  static const border = Color(0xFFE2E8F0);
  static const divider = Color(0xFFF1F5F9);
  static const surfaceAlt = Color(0xFFF8FAFC);
}
```

Ini rekomendasi refactor; jangan melakukan refactor besar tanpa kebutuhan task jika berisiko mengubah banyak halaman sekaligus.

---

# 44. Design QA Checklist untuk Halaman Baru

Sebelum dianggap selesai, cek semua poin berikut.

## Header

- [ ] Memakai `CustomHeaderScaffold` / `CustomHeaderAppBar` bila sesuai.
- [ ] Gradient, radius, title, action icon sesuai standard.
- [ ] Back button benar untuk root/subpage.
- [ ] Header dengan search memakai struktur Wishlist: tinggi `178`, search
      `left/right 16`, `bottom 18`.
- [ ] Search header memakai `CustomHeaderSearchField`, bukan style lokal.
- [ ] Search memakai Poppins `11.5/500`; hint memakai Poppins `11/400`.
- [ ] Tidak membuat AppBar style baru tanpa alasan.

## Layout

- [ ] Background `#F8FAFC` atau approved alt `#F6F7F9`.
- [ ] Horizontal padding konsisten `12/16`.
- [ ] Section gap `14/16`.
- [ ] Wide screen menggunakan max width jika halaman form/detail.

## Typography

- [ ] Poppins primary.
- [ ] Heading mengikuti scale dokumen ini.
- [ ] Warna teks memakai hierarchy slate yang ditentukan.
- [ ] Tidak ada font size random.

## Card

- [ ] White surface.
- [ ] Radius `16` untuk major card.
- [ ] Border `#F1F5F9`.
- [ ] Shadow halus.
- [ ] Card tidak menyatu dengan background.

## Form

- [ ] Fill `#F8FAFC`.
- [ ] Border `#E2E8F0`.
- [ ] Focus border primary.
- [ ] Radius `12`.
- [ ] Error/validation user-friendly.

## List/Data

- [ ] Initial loading.
- [ ] Empty state.
- [ ] Search empty state jika ada search.
- [ ] Error state + retry.
- [ ] Infinite scroll guard jika paginated.
- [ ] Existing list tidak hilang saat load more.
- [ ] Spinner load more hanya di bawah.

## Interaction

- [ ] Destructive action confirmation.
- [ ] Success/error feedback.
- [ ] Disabled state jelas.
- [ ] Tooltip pada icon-only action.
- [ ] Tidak ada double submit/double pagination request.

## Responsive

- [ ] Aman pada `<360dp`.
- [ ] Tidak overflow.
- [ ] Text panjang ellipsis/wrap dengan benar.
- [ ] Button tidak terpotong.

---

# 45. Do / Don't

## DO

- Reuse shared widgets.
- Gunakan border + shadow tipis untuk card.
- Gunakan neutral slate sebagai supporting colors.
- Gunakan primary red dengan disiplin.
- Pertahankan existing content saat refreshing/loading more.
- Buat skeleton menyerupai final layout.
- Buat error message yang actionable.
- Buat empty state berbeda dari error state.
- Gunakan optimistic update hanya jika aman.

## DON'T

- Jangan membuat background card `#FFFFFF` di atas page `#FFFFFF` tanpa separation.
- Jangan memakai shadow gelap/tebal seperti web dashboard desktop.
- Jangan memberi semua button warna merah.
- Jangan membuat font 14–16 untuk semua text di mobile compact UI.
- Jangan memunculkan spinner full screen saat load page berikutnya.
- Jangan memanggil API pagination berkali-kali karena listener scroll tanpa guard.
- Jangan reset scroll state setiap tab rebuild.
- Jangan copy-paste design constants ke puluhan file.
- Jangan membuat warna semantic baru jika warna existing sudah cukup.
- Jangan menampilkan raw exception/API stack trace ke user.

---

# 46. Instruksi Singkat untuk Codex

Jika user mengatakan:

> "Buat halaman X, ikuti design.md"

maka Codex harus melakukan urutan berikut:

1. Baca `design.md`.
2. Cari shared widget yang sudah tersedia.
3. Cari halaman existing yang paling mirip.
4. Tentukan page blueprint: detail/form/list.
5. Implementasikan dengan token di dokumen ini.
6. Untuk card gunakan canonical card border + shadow.
7. Untuk header gunakan shared custom header; jika memiliki search, ikuti
   struktur canonical Wishlist pada bagian 11 dan gunakan
   `CustomHeaderSearchField`.
8. Untuk list besar gunakan pagination contract di dokumen ini.
9. Tambahkan loading/empty/error/retry state.
10. Pastikan responsive `<360dp`.
11. Hindari membuat style lokal baru jika bisa direuse.
12. Jalankan analyzer/test yang relevan.
13. Sebelum selesai, bandingkan implementasi terhadap checklist Design QA.

---

# 47. Canonical Quick Reference

```text
PRIMARY            #B11F23
PRIMARY TOP        #D52A2F
SECONDARY          #FDD100
PAGE BG            #F8FAFC
SURFACE            #FFFFFF
TEXT STRONG        #0F172A
TEXT PRIMARY       #1E293B
TEXT SECONDARY     #475569
TEXT MUTED         #64748B
TEXT DISABLED      #94A3B8
BORDER             #E2E8F0
DIVIDER/CARD       #F1F5F9
SOFT RED           #FFF1F2
SOFT RED BORDER    #FECACA

PRIMARY FONT       Poppins
SECONDARY FONT     Lato

CARD RADIUS        16
INPUT RADIUS       12
HEADER RADIUS      28
BOTTOM SHEET       24

PAGE PADDING       12
FORM PADDING       16
SECTION GAP        14
MAX CONTENT WIDTH  680

PRIMARY BTN H      48
SEARCH H           42
HEADER ICON        40x40

PAGINATION LIMIT   20
LOAD MORE TRIGGER  90%
```

---

# 48. Final Design Contract

Untuk halaman baru EKAPLUS Mobile, tujuan akhirnya bukan sekadar “mirip warna merahnya”, tetapi memenuhi empat konsistensi sekaligus:

1. **Visual consistency** — warna, type, radius, border, shadow, spacing.
2. **Component consistency** — header, card, row, input, button, badge, dialog.
3. **State consistency** — loading, empty, error, retry, locked, selected.
4. **Behavior consistency** — scroll, pagination, optimistic update, responsive, feedback.

Jika ada keputusan desain baru yang akan dipakai lebih dari satu halaman, update `design.md` terlebih dahulu atau pada task yang sama agar dokumen ini tetap menjadi **single source of truth UI EKAPLUS Mobile**.
