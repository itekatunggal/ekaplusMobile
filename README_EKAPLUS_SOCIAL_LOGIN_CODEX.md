# README — Implementasi Social Login Google & Apple (EKAPLUS Mobile)

**Target:** Flutter EKAPLUS Mobile (Android & iOS)  
**Acuan backend:** `README_SOCIAL_LOGIN.md` (branch `feature/apple-signin`, 5 November 2026)  
**Acuan UI:** `LoginPage` saat ini dan `DESIGN.md` proyek  
**Pelaksana:** Codex di repository Flutter  
**Cakupan:** frontend Flutter + integrasi API yang sudah disediakan. **Jangan mengubah backend Go.**

## 1. Tujuan

Implementasikan autentikasi sosial **dua fase** di aplikasi EKAPLUS Mobile, dengan ketentuan:

1. Android: tampilkan **Google Sign-In** saja.
2. iOS: tampilkan **Google Sign-In** dan **Sign in with Apple**.
3. Login manual (nomor HP/email/username + password), lupa password, dan registrasi biasa tetap berfungsi.
4. User yang belum login tetap dapat melihat Home/katalog (Guest Mode).
5. User dengan akun sosial **sudah lengkap** langsung login, menyimpan sesi secara aman, dan menuju Home.
6. User dengan akun sosial **belum lengkap** masuk ke halaman **Lengkapi Akun** untuk mengisi `username` dan `password`, kemudian langsung login **hanya setelah completion berhasil**.
7. Jangan menganggap HTTP 200 atau `status: success` sebagai bukti login berhasil jika backend mengirim `registration_required: true`.

## 2. Inspeksi kode sebelum mengubah

Codex wajib membaca dan mengikuti implementasi nyata di repository:

- `DESIGN.md`, `constant.dart`, `CustomHeaderScaffold`, route `go_router`.
- `LoginPage` saat ini.
- `AuthBloc`, `auth_event.dart`, `auth_state.dart`, repository/use case/datasource auth, HTTP client, error mapper.
- `AuthSessionCubit`, penyimpanan token (mis. `flutter_secure_storage`) dan pola logout/refresh token.
- Integrasi Google Sign-In yang telah berfungsi dan konfigurasi Android/iOS.
- `pubspec.yaml`, `Info.plist`, entitlements iOS, dan berkas konfigurasi autentikasi terkait.

**Jangan membuat ulang arsitektur auth, memperkenalkan state management lain, mengubah nama route tanpa alasan, atau menambah dependency yang sudah tersedia.** Lakukan perubahan minimal yang terintegrasi dengan pola proyek. Jangan menebak struktur response wrapper: gunakan dokumentasi backend dan parser existing.

## 3. Aturan tampilan per platform

| Fitur | Android | iOS |
|---|---|---|
| Login manual | Tampil | Tampil |
| Google Sign-In | Tampil | Tampil |
| Apple Sign-In | **Sembunyikan** | **Tampil** |
| Lupa password | Tampil | Tampil |
| Daftar sekarang | Tampil | Tampil |
| Close (`×`) kembali ke Guest/halaman asal | Tampil | Tampil |

Gunakan `Platform.isIOS` dari `dart:io` untuk aplikasi Flutter mobile native (atau abstraksi platform yang sudah dipakai repo). Jangan munculkan tombol Apple di Android dan jangan membuat fallback Apple via web untuk Android dalam scope ini.

**UI login:** pertahankan header maroon sesuai `AppColors.primaryColor`, logo EKAPLUS, teks `Halo!`, `Selamat datang di EKAPLUS`, rounded sheet, background, spacing, typography, input, border/shadow, dan desain dari `DESIGN.md`. Tombol sosial bersebelahan pada iOS; jika Android, Google tetap berada di tengah. Ikon Apple harus terlihat jelas, menggunakan gaya ikon resmi yang tepat; jangan mengganti ikon Google yang sudah ada. Semua tombol mempunyai ukuran area sentuh minimal 44 × 44 logical pixels. UI harus responsif di layar kecil, keyboard terbuka, dan memakai SafeArea.

**Close Login:** pertahankan tombol `×` pada header. Saat ditekan, keluar dari login tanpa membuat sesi: `context.pop()` jika tersedia, atau `context.go('/')` sebagai fallback sesuai route yang benar. Jangan menonaktifkan Guest Mode. Tombol Back sistem harus mengikuti strategi navigasi yang masuk akal; jangan mengubah seluruh stack aplikasi.

## 4. Kontrak API mobile

Base URL: **gunakan konfigurasi environment/API client aplikasi yang sudah ada**; jangan hardcode domain dev/production.

### 4.1 Google

`POST /api/user/google/mobile`

Payload memakai ID token dari Google provider dan atribut yang diminta backend, misalnya:

```json
{
  "id_token": "<google_id_token>",
  "device_id": "<device-id>",
  "platform": "android"
}
```

Pada iOS, `platform` harus `ios`. Pertahankan mekanisme pembuatan `device_id` yang sudah digunakan proyek; jangan membuat identifier yang tidak stabil jika sudah tersedia.

### 4.2 Apple

`POST /api/user/apple/mobile`

Ambil **identity token / ID token** dari Apple native sign-in, lalu kirim sesuai kontrak aktual endpoint backend (cek request DTO yang sudah tersedia/README konfigurasi Apple; jangan menebak nama key payload apabila belum didokumentasikan). Jangan mengirim authorization code sebagai pengganti identity token tanpa kepastian kontrak. `platform` = `ios`; gunakan `device_id` sesuai pola auth lain.

**Persiapan native iOS:** cek capability Sign in with Apple, entitlements, Apple Developer identifier/provisioning dan konfigurasi plugin yang dipilih. Jangan membuat/mengarang Team ID, Bundle ID, client ID, private key, atau rahasia provider. Catat jika konfigurasi yang memerlukan Apple Developer masih belum tersedia.

### 4.3 Respons login sosial: dua kemungkinan

**A. Akun sudah lengkap:** response berisi `user`, `access_token`, `refresh_token` (ikuti wrapper aktual API). Hanya pada kondisi ini lakukan persist token dan `AuthSessionCubit.login(user)`, lalu navigasi Home.

**B. Akun belum lengkap:** response `HTTP 200`, code `REGISTRATION_REQUIRED`, dan data:

```json
{
  "status": "success",
  "code": "REGISTRATION_REQUIRED",
  "message": "Lengkapi username dan password",
  "data": {
    "registration_required": true,
    "registration_token": "<ticket>",
    "expires_in": 600,
    "prefill": {
      "email": "budi@example.com",
      "first_name": "Budi",
      "last_name": "Santoso",
      "full_name": "Budi Santoso",
      "profile_pic": "https://..."
    }
  }
}
```

Ketika menerima respons B:
- **Jangan** memanggil `AuthSessionCubit.login`.
- **Jangan** menyimpan access/refresh token (memang belum diterbitkan).
- Simpan `registration_token` **sementara di memory** dalam state/argumen route yang tidak muncul dalam URL, log, analytics, maupun snackbar.
- Navigasi ke `SocialAccountCompletionPage` membawa token dan prefill secara aman.
- Jangan tampilkan halaman Home seolah user sudah login.

### 4.4 Completion

`POST /api/user/auth/social/complete` dengan JSON:

```json
{
  "ticket": "<registration_token>",
  "username": "budi_123",
  "password": "rahasia",
  "device_id": "<device-id>",
  "platform": "ios"
}
```

Backend juga menerima `registration_token` sebagai pengganti `ticket`, tetapi pilih **satu bentuk konsisten** (disarankan `ticket`). Untuk Android gunakan `platform: android`.

Respons completion sukses mengandung:

```json
{
  "status": "success",
  "code": "REGISTRATION_COMPLETED",
  "message": "Registrasi berhasil",
  "data": {
    "user": {"id": 123, "username": "budi_123", "email": "budi@example.com"},
    "access_token": "...",
    "refresh_token": "..."
  }
}
```

Hanya setelah respons completion valid dan token berhasil diproses mengikuti mekanisme sesi existing, user dapat dinyatakan login dan dialihkan ke `/`.

**Jangan gunakan endpoint `/api/user/auth/social/exchange` untuk alur native mobile**; endpoint itu khusus penukaran login ticket pada redirect **web**.

## 5. Halaman baru: SocialAccountCompletionPage

Buat halaman baru memakai `DESIGN.md`, `CustomHeaderScaffold`, warna primary maroon, komponen input/card existing, dan spacing konsisten.

**Isi layar:**

- Judul `Lengkapi Akun`.
- Keterangan singkat: `Satu langkah lagi untuk menggunakan EKAPLUS.`
- Email hasil prefill sebagai informasi **read-only**, jika tersedia; jangan izinkan pengguna mengganti identitas provider dari halaman ini.
- Field **Username** (wajib).
- Field **Password** (wajib) dengan show/hide.
- Field **Konfirmasi Password** (validasi lokal; **jangan dikirim** ke API completion).
- Tombol utama `Selesaikan Pendaftaran` dengan loading state dan proteksi double submit.
- Tombol Close/Back: batal completion dan kembali ke Guest Mode atau konteks sebelum login; hapus ticket dari state UI.

**Validasi username:** trim; panjang 3–30 karakter; hanya `A-Z`, `a-z`, `0-9`, `_`, `.`; tanpa spasi; larang nama reserved (case-insensitive): `admin`, `administrator`, `root`, `system`, `support`, `api`, `www`, `mail`, `help`, `official`, `user`, `guest`, `null`, `undefined`, `ekaplus`, `ekatunggal`. Keunikan case-insensitive harus tetap diputuskan **backend**, bukan hanya validator lokal.

**Validasi password:** wajib, minimal 6 karakter, maksimal **72 byte UTF-8** (bukan 72 karakter). Konfirmasi harus sama. Jangan menambahkan persyaratan uppercase/simbol/angka yang tidak ada pada kontrak backend. Jangan trim atau mengubah isi password secara diam-diam.

**Ticket:** masa berlaku 600 detik (10 menit), single-use, maksimal 5 percobaan completion dari sisi backend. Bila ticket kadaluarsa atau tidak valid, tampilkan pesan jelas seperti `Sesi pendaftaran berakhir. Silakan masuk dengan Google/Apple kembali.` dan beri aksi kembali ke login. Jangan otomatis mengulang completion dengan ticket lama.

## 6. Desain AuthBloc dan sesi

Tambahkan event/state sesuai konvensi repo (nama berikut **contoh**, bukan kewajiban):

- Event `LoginWithAppleEvent`, `CompleteSocialRegistrationEvent`.
- State `SocialRegistrationRequired(registrationToken, expiresIn, prefill, provider)`.
- State completion loading/success/error, atau gunakan state auth existing yang dipisahkan jelas per operasi.

Perbarui Google flow yang sekarang agar mengenali `REGISTRATION_REQUIRED` dan tidak memaksanya menjadi `LoginWithGoogleSuccess`. Apple flow harus memakai parser dan strategi error yang sama.

**Perhatikan implementasi saat ini:** `_completeLogin(AuthState state)` melakukan cast selain `LoginSuccess` ke `LoginWithGoogleSuccess`. Ubah agar Apple success dan completion success ditangani **type-safe**, tidak memicu cast error. Jika completion sukses, hanya lakukan satu kali transisi ke sesi login dan satu kali navigasi. Pastikan flag loading Google/Apple/manual tidak saling menimpa; normalisasi state ketika operasi dibatalkan atau gagal.

Simpan token aplikasi dengan mekanisme aman existing (mis. secure storage). Jangan menyimpan access/refresh token atau registration ticket ke `Hive` biasa, log, maupun URL. Jangan log password, ID token provider, maupun respons mentah yang mengandung rahasia.

## 7. Error handling

Tangani `code` backend, bukan sekadar pencocokan string pesan:

| Kode | Perlakuan UI |
|---|---|
| `REGISTRATION_REQUIRED` | Navigasi ke completion, **bukan login sukses** |
| `INVALID_REGISTRATION_TOKEN` (401) | Ticket tidak valid/expired, minta login social lagi |
| `ACCOUNT_ALREADY_EXISTS` (409) | Tampilkan error dari backend pada username / pesan relevan |
| `INVALID_INPUT` (400) | Tampilkan validasi input dari backend |
| `SOCIAL_CONFLICT` (409) | Tampilkan konflik akun, jangan otomatis menggabungkan akun |
| `SOCIAL_PROVIDER_CONFLICT` (409) | Informasikan akun social sudah terhubung ke identitas lain |
| `EMAIL_NOT_VERIFIED` (401) | Informasikan email provider belum terverifikasi |
| `GOOGLE_LOGIN_FAILED` (401) | Gagal autentikasi Google; aman untuk retry |
| `APPLE_LOGIN_FAILED` (401) | Gagal autentikasi Apple; aman untuk retry |
| `SOCIAL_COMPLETION_FAILED` (500) | Tampilkan error umum, izinkan retry bila ticket masih berlaku |

Bila user membatalkan dialog Google/Apple secara sengaja, jangan tampilkan snackbar error yang mengganggu. Tangani loading, timeout, offline/network error, dan double tap secara konsisten.

## 8. Kriteria penerimaan (wajib diuji)

- [ ] Android hanya menampilkan tombol Google; iOS menampilkan Google dan Apple.
- [ ] Login manual, lupa password, dan registrasi biasa tidak rusak.
- [ ] Tutup Login (`×`) kembali ke konteks asal / Home Guest jika tidak bisa pop.
- [ ] Google/Apple akun lengkap: login sukses, token tersimpan aman, Home Customer terbuka.
- [ ] Google/Apple akun baru/belum lengkap: muncul completion, tidak membuat session prematur.
- [ ] Completion sukses: user + token diproses, login sekali, navigasi sekali.
- [ ] Completion error: user tetap belum login, pesan sesuai `code`.
- [ ] Username duplikat berbeda kapital ditolak backend; format/reserved divalidasi di UI.
- [ ] Password divalidasi min 6 karakter dan max 72 byte; konfirmasi lokal tidak dikirim.
- [ ] Ticket expired/terpakai tidak diulang; tersedia jalan kembali untuk autentikasi ulang.
- [ ] Jika completion ditutup, tidak ada sesi dan Guest Mode tetap berjalan.
- [ ] Loading/double tap, cancel provider, offline, keyboard, layar kecil, dan system Back diuji.
- [ ] Tidak ada token/password/ID token tercetak di log atau bocor ke route URL.
- [ ] `flutter analyze` dan tes auth yang relevan lulus.

## 9. Deliverables Codex

1. Kode Flutter terintegrasi: UI login, tombol Apple native iOS, state/event/repository/API, halaman completion, router.
2. Test unit/widget untuk respons login lengkap vs `REGISTRATION_REQUIRED`, completion, validasi, navigasi, dan platform visibility.
3. Ringkasan file yang dimodifikasi, dependency baru (jika diperlukan), konfigurasi iOS manual yang harus dilakukan, dan cara menguji pada perangkat nyata.
4. Jelaskan risiko/gap dokumentasi API yang membutuhkan klarifikasi **tanpa mengarang kontrak**.

## 10. Batasan tegas

- **Frontend Flutter saja; jangan edit backend.**
- **Jangan hapus fitur atau mengganti desain utama** yang sudah ada.
- **Jangan auto-register user aktif dari aplikasi** sebelum completion.
- **Jangan menyimpan session pada `REGISTRATION_REQUIRED`.**
- **Jangan tampilkan Apple di Android.**
- **Jangan mengubah alur register/login manual yang sudah berjalan.**
- **Jangan hardcode environment URL, credential, atau secret.**
- Jika ada detail payload Apple tidak dijelaskan README, baca API client/kontrak backend yang tersedia dan laporkan gap; jangan menebak field.

---

**Instruksi langsung untuk Codex:**

> Baca README ini, `DESIGN.md`, implementasi `LoginPage`, AuthBloc, repository/datasource auth, konfigurasi router, serta README backend social login. Implementasikan seluruh perubahan frontend secara menyeluruh sesuai arsitektur proyek, pertahankan Guest Mode dan seluruh fungsi login existing, lalu jalankan analyzer/test yang relevan. Jangan edit backend. Setelah selesai, laporkan perubahan file dan konfigurasi iOS Apple Sign-In yang masih perlu dilakukan secara manual.
