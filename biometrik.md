# PRD Final — Login Biometrik Ekaplus Flutter

## 1. Latar Belakang

Aplikasi Ekaplus saat ini menggunakan login username/password ke backend.

Tujuan fitur baru adalah mempermudah proses login dengan memanfaatkan kemampuan password manager dan biometric authentication dari perangkat.

Contoh pengalaman yang diinginkan:

- Samsung Pass
- Google Password Manager
- iCloud Passwords
- iOS Password AutoFill
- Password manager lain yang terdaftar sebagai Autofill Service

User tidak perlu mengetik username dan password secara manual setiap kali login.

Sebagai gantinya:

```text
User membuka Login Screen
        ↓
Memilih credential tersimpan
        ↓
Fingerprint / Face ID / biometrik perangkat
        ↓
Username + password tersedia
        ↓
Form login terisi
        ↓
Login dikirim ke backend Ekaplus
        ↓
Backend melakukan login username/password seperti existing
```

Fitur ini bukan biometric authentication terhadap backend.

Backend tetap menggunakan mekanisme username/password existing.

---

# 2. Tujuan

Implementasi harus:

1. mendukung autofill username/password pada Login Screen;
2. kompatibel dengan password manager perangkat;
3. memungkinkan user memakai fingerprint/Face ID apabila password manager perangkat meminta biometric verification;
4. tetap menggunakan API login Ekaplus yang sekarang;
5. tidak mengubah backend;
6. tidak membuat endpoint biometric login;
7. tidak menyimpan password user sendiri menggunakan Flutter;
8. tidak membaca atau menyimpan data fingerprint/Face ID;
9. tetap mendukung login manual username/password.

---

# 3. Konsep Utama

Biometrik bukan pengganti username/password pada backend.

Biometrik digunakan oleh sistem operasi/password manager untuk memberikan akses terhadap credential yang telah tersimpan.

Flow:

```text
Biometric
   ↓
Password Manager
   ↓
Username + Password
   ↓
Ekaplus Login Form
   ↓
Existing Login API
   ↓
Backend
```

Backend Ekaplus tetap menerima:

```json
{
  "username": "...",
  "password": "..."
}
```

sesuai mekanisme existing.

---

# 4. Hal yang Tidak Boleh Dilakukan

JANGAN membuat flow:

```text
Fingerprint
→ backend biometric login
```

JANGAN membuat endpoint seperti:

```text
POST /biometric/login
POST /biometric/register
POST /biometric/verify
```

JANGAN membuat field backend seperti:

```text
fingerprint_id
face_id
biometric_token
```

JANGAN mengirim:

```json
{
  "biometric_verified": true
}
```

sebagai dasar login.

JANGAN menyimpan:

- password plaintext;
- password terenkripsi buatan sendiri;
- fingerprint data;
- Face ID data;
- biometric template;
- biometric image.

---

# 5. Backend

Tidak ada perubahan backend dalam task ini.

Existing login endpoint tetap digunakan.

Contoh flow:

```text
Flutter
   ↓
username/password
   ↓
Existing Ekaplus Login API
   ↓
Access Token / Refresh Token
```

Semua validation dan authentication backend tetap existing.

---

# 6. Existing Session Storage

Project sudah menggunakan:

```text
flutter_secure_storage ^10.0.0
```

melalui existing SessionManager untuk:

- access token;
- refresh token.

Pertahankan mekanisme ini.

Tidak perlu menambahkan secure storage baru.

Tidak perlu memindahkan token dari SharedPreferences.

JANGAN menyimpan password user di `flutter_secure_storage` untuk fitur ini.

Password harus dikelola oleh password manager sistem.

---

# 7. Dependency

Tidak wajib menggunakan:

```text
local_auth
```

untuk Login Autofill.

Alasannya:

biometric verification dilakukan oleh password manager atau OS ketika user memilih credential tersimpan.

Untuk fitur ini fokus pada:

```text
Flutter Autofill API
```

Gunakan widget dan hint native Flutter.

Contoh:

```dart
AutofillGroup(
  child: Column(
    children: [
      TextFormField(
        autofillHints: const [
          AutofillHints.username,
        ],
      ),
      TextFormField(
        obscureText: true,
        autofillHints: const [
          AutofillHints.password,
        ],
      ),
    ],
  ),
)
```

Jika project menggunakan custom input widget, tambahkan dukungan `autofillHints` pada widget tersebut.

---

# 8. Login Screen

Login Screen tetap mempunyai:

```text
Username
Password

[ Login ]
```

Tidak perlu menambahkan tombol custom:

```text
Login dengan Fingerprint
Login dengan Face ID
Login Biometrik
```

Password manager native akan muncul melalui mekanisme Autofill.

Contoh UX:

```text
Username
[ __________________ ]

Password
[ __________________ ]

Samsung Pass / Passwords suggestion
```

Ketika user memilih credential:

```text
Fingerprint / Face ID
        ↓
credential terbuka
        ↓
field terisi
```

---

# 9. Autofill Username

Field username harus menggunakan:

```dart
autofillHints: const [
  AutofillHints.username,
]
```

Jika backend Ekaplus sebenarnya menggunakan email sebagai login, boleh gunakan:

```dart
AutofillHints.username
```

dan bila sesuai struktur project bisa juga mempertimbangkan:

```dart
AutofillHints.email
```

Tetapi jangan membuat hint yang bertentangan dengan tipe credential existing.

---

# 10. Autofill Password

Field password harus menggunakan:

```dart
autofillHints: const [
  AutofillHints.password,
]
```

Password field tetap:

```dart
obscureText: true
```

Existing show/hide password tetap dipertahankan.

---

# 11. AutofillGroup

Username dan password harus berada dalam satu:

```dart
AutofillGroup
```

agar OS memahami bahwa kedua field merupakan satu credential set.

Contoh:

```dart
AutofillGroup(
  child: Column(
    children: [
      usernameField,
      passwordField,
    ],
  ),
)
```

Jangan memisahkan field login ke AutofillGroup yang berbeda.

---

# 12. Login Submit

Setelah credential terisi melalui Autofill:

existing login flow tetap digunakan.

Contoh:

```text
Autofill
   ↓
usernameController.text
passwordController.text
   ↓
existing LoginCubit
   ↓
existing login repository
   ↓
existing API
```

Jangan membuat login path khusus biometric.

---

# 13. Autofill Tidak Boleh Bypass Validation

Jika Login Screen memiliki validation:

```text
username required
password required
```

tetap gunakan validation existing.

Credential yang berasal dari password manager diperlakukan sama seperti input manual.

---

# 14. Login Manual Tetap Wajib Berfungsi

Jika user:

- tidak punya password manager;
- tidak menyimpan credential;
- tidak mengaktifkan biometric;
- tidak ingin menggunakan autofill;

maka user tetap dapat mengetik:

```text
username
password
```

secara manual.

Autofill adalah convenience feature, bukan requirement login.

---

# 15. Password Manager Android

Android dapat menggunakan password manager/autofill service seperti:

- Google Password Manager
- Samsung Pass
- password manager lain yang user pilih

Aplikasi tidak boleh melakukan hardcode untuk:

```text
Samsung Pass
```

karena tidak semua Android memakai Samsung.

Gunakan Android Autofill framework melalui Flutter.

---

# 16. Password Manager iOS

iOS dapat menggunakan:

- iCloud Passwords
- Password AutoFill
- password manager lain yang terintegrasi dengan iOS

Aplikasi tidak perlu membuat Face ID implementation sendiri.

Ketika password manager membutuhkan autentikasi:

```text
Face ID
Touch ID
device authentication
```

dikelola oleh iOS.

---

# 17. Biometric Responsibility

Biometric authentication dalam flow ini merupakan tanggung jawab:

```text
Operating System / Password Manager
```

bukan aplikasi Ekaplus.

Ekaplus hanya menerima hasil autofill berupa:

```text
username
password
```

di field login.

Aplikasi tidak mengetahui:

```text
fingerprint mana
face mana
biometric type mana
```

yang digunakan user.

---

# 18. Credential Saving

Setelah login berhasil, OS/password manager boleh menawarkan:

```text
Save Password?
```

atau:

```text
Update Password?
```

jika memang didukung oleh platform/password manager.

Ekaplus tidak perlu membuat dialog sendiri:

```text
Simpan password di Ekaplus?
```

Jangan menyimpan password di storage aplikasi.

---

# 19. Autofill Finish

Setelah login berhasil, gunakan:

```dart
TextInput.finishAutofillContext();
```

jika sesuai dengan lifecycle form dan implementasi Flutter version project.

Tujuannya memberi sinyal bahwa proses login/autofill telah selesai sehingga OS dapat menangani save/update credential.

Codex harus memeriksa implementasi Flutter yang kompatibel dengan project sebelum memanggil API ini.

---

# 20. Autofill Cancel / Failure

Jika Autofill tidak muncul atau user cancel:

tidak ada error.

User tetap bisa login manual.

Tidak perlu menampilkan:

```text
Biometric gagal
```

karena Ekaplus tidak mengontrol proses biometric password manager.

---

# 21. Jangan Memanggil local_auth

Untuk flow Login Autofill ini:

JANGAN memanggil:

```dart
LocalAuthentication.authenticate()
```

sebelum Autofill.

Contoh yang salah:

```text
User klik login
→ Ekaplus minta fingerprint
→ setelah sukses isi username/password sendiri
```

Itu berarti aplikasi harus menyimpan credential sendiri, dan bukan flow yang diinginkan.

Biometric challenge harus berasal dari password manager/OS.

---

# 22. Tidak Menyimpan Credential Sendiri

Jangan membuat:

```dart
secureStorage.write(
  key: 'saved_username',
  value: username,
);

secureStorage.write(
  key: 'saved_password',
  value: password,
);
```

terutama untuk password.

Jika username existing memang sudah disimpan untuk UX seperti remember username, boleh dipertahankan sesuai existing behavior.

Tetapi password login tidak boleh disimpan oleh aplikasi untuk kemudian dipakai ulang.

---

# 23. Existing Session

Setelah login berhasil:

```text
username/password
   ↓
backend login
   ↓
access token
refresh token
```

Existing SessionManager tetap menangani token.

Jika session masih valid, existing aplikasi boleh tetap masuk sesuai current behavior.

Fitur ini tidak mengubah session lifetime.

---

# 24. App Lock Bukan Bagian Task Ini

PRD sebelumnya membahas:

```text
Face ID / fingerprint
→ membuka existing session
→ App Lock
```

Konsep tersebut adalah fitur berbeda.

Untuk PRD ini:

```text
App Lock tidak termasuk scope.
```

Jangan implementasikan:

- global biometric gate;
- biometric lock setelah background;
- biometric timeout;
- AppLockCubit;
- lock overlay;
- biometric unlock token.

Jika suatu saat dibutuhkan, buat PRD terpisah.

---

# 25. UX Final

Login Screen:

```text
┌───────────────────────────────┐
│            EKAPLUS            │
│                               │
│ Username                      │
│ [_________________________]   │
│                               │
│ Password                      │
│ [_________________________] 👁 │
│                               │
│          [ LOGIN ]            │
│                               │
└───────────────────────────────┘
```

Jika password manager mendeteksi form:

```text
┌───────────────────────────────┐
│ yuda@example.com              │
│ Google Password Manager       │
└───────────────────────────────┘
```

atau:

```text
Samsung Pass
```

atau:

```text
Passwords
```

User memilih credential.

Kemudian OS/password manager dapat meminta:

```text
Fingerprint
Face ID
Touch ID
```

Setelah sukses:

```text
Username terisi
Password terisi
```

Kemudian login menggunakan existing API.

---

# 26. Flow Lengkap

## Scenario A — Login Manual

```text
Login Screen
    ↓
User ketik username/password
    ↓
Login
    ↓
Existing API
    ↓
Success
    ↓
Home
```

---

## Scenario B — Google Password Manager

```text
Login Screen
    ↓
User memilih credential
    ↓
Google Password Manager
    ↓
Fingerprint / biometric jika diminta
    ↓
Username/password autofill
    ↓
Login
    ↓
Existing API
    ↓
Success
```

---

## Scenario C — Samsung Pass

```text
Login Screen
    ↓
Samsung Pass suggestion
    ↓
User pilih credential
    ↓
Fingerprint / biometric
    ↓
Username/password autofill
    ↓
Existing Login
```

---

## Scenario D — iPhone

```text
Login Screen
    ↓
Passwords / Password AutoFill
    ↓
Face ID / Touch ID jika diminta
    ↓
Username/password autofill
    ↓
Existing Login
```

---

# 27. Tidak Ada Perbedaan Backend

Semua scenario akhirnya menjadi:

```text
POST existing login endpoint

username = ...
password = ...
```

Backend tidak perlu tahu apakah credential berasal dari:

```text
manual typing
Samsung Pass
Google Password Manager
iCloud Passwords
```

Semua dianggap sama.

---

# 28. Custom Login Widget

Project Ekaplus mungkin menggunakan custom widget untuk TextField.

Codex harus memeriksa apakah custom widget menerima:

```dart
autofillHints
textInputAction
keyboardType
obscureText
controller
```

Jika belum, extend widget existing.

Jangan mengganti semua input widget project hanya untuk fitur ini.

---

# 29. Keyboard Configuration

Username field sebaiknya:

```dart
textInputAction: TextInputAction.next
```

Password:

```dart
textInputAction: TextInputAction.done
```

Jika user menekan Done pada password:

jalankan existing submit/login jika validation valid.

---

# 30. Credential Association

Agar password manager mengenali aplikasi/site dengan baik, Codex harus memeriksa apakah project memerlukan konfigurasi tambahan untuk credential association.

Android dapat memerlukan konfigurasi terkait domain/app association tergantung password manager dan target implementation.

iOS dapat memerlukan Associated Domains jika ingin association yang lebih kuat antara aplikasi dan credential website.

Namun:

jangan menambahkan konfigurasi tersebut secara sembarangan.

Pertama analisis:

- existing package/application ID;
- domain login Ekaplus;
- apakah credential website juga digunakan;
- apakah association diperlukan oleh target behavior.

Jika autofill native sudah bekerja tanpa association tambahan, jangan menambah complexity.

Jika association diperlukan, laporkan terlebih dahulu konfigurasi yang ditambahkan.

---

# 31. Android Configuration

Periksa:

```text
AndroidManifest.xml
MainActivity
minSdk
targetSdk
Flutter version
```

Untuk Autofill standard Flutter biasanya tidak perlu permission biometric.

JANGAN menambahkan:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

hanya untuk fitur Password Autofill jika aplikasi sendiri tidak memanggil biometric API.

Biometric prompt milik password manager tidak membutuhkan permission biometric aplikasi Ekaplus.

---

# 32. iOS Configuration

Untuk Password AutoFill standard:

jangan menambahkan:

```text
NSFaceIDUsageDescription
```

hanya karena password manager dapat memakai Face ID.

Ekaplus tidak memanggil Face ID secara langsung.

`NSFaceIDUsageDescription` hanya diperlukan jika aplikasi sendiri menggunakan Face ID/local authentication.

Jika tidak menggunakan `local_auth`, jangan menambahkan konfigurasi Face ID yang tidak diperlukan.

---

# 33. Dependency local_auth

Keputusan final untuk task ini:

```text
local_auth tidak perlu ditambahkan
```

kecuali setelah analisis Codex ternyata ada requirement lain yang benar-benar membutuhkan biometric authentication langsung dari Ekaplus.

Jangan menambahkan dependency yang tidak digunakan.

---

# 34. Security

Credential handling harus mengikuti:

```text
password manager → TextField → existing login request
```

Jangan log isi password.

Jangan log:

```text
username/password payload lengkap
```

jika existing project saat ini melakukannya, minimal pastikan password di-redact.

Contoh aman:

```text
login request for user: yuda
```

bukan:

```text
username=yuda
password=123456
```

---

# 35. Error Login

Jika Autofill berhasil tetapi password sudah tidak valid:

backend dapat mengembalikan login error seperti biasa.

Contoh:

```text
Username atau password salah.
```

Jangan menyimpulkan:

```text
Biometric gagal.
```

Biometric sudah berhasil membuka credential; masalahnya adalah credential password sudah invalid.

User dapat memperbarui password di password manager setelah login dengan credential baru.

---

# 36. Password Berubah

Scenario:

```text
Password Ekaplus berubah
        ↓
Password manager masih menyimpan password lama
        ↓
Autofill
        ↓
Login gagal
```

Expected:

existing login error.

User:

```text
ketik password baru
→ login
```

OS/password manager kemudian dapat menawarkan update password.

Ekaplus tidak perlu membuat sinkronisasi password manager sendiri.

---

# 37. Multiple Accounts

Jika satu device memiliki beberapa akun Ekaplus tersimpan:

password manager dapat menawarkan beberapa credential.

Contoh:

```text
user.a@company.com
user.b@company.com
```

User memilih salah satu.

Ekaplus tidak perlu membuat account picker sendiri untuk credential password manager.

---

# 38. User Tidak Mengaktifkan Biometric

Jika password manager tidak menggunakan biometric:

credential tetap dapat digunakan sesuai policy perangkat/password manager.

Ekaplus tidak boleh memaksa:

```text
harus fingerprint
```

karena authentication method credential storage merupakan tanggung jawab OS/password manager.

Jika organisasi nantinya membutuhkan biometric mandatory, itu merupakan requirement keamanan berbeda dan perlu desain tersendiri.

---

# 39. Acceptance Criteria

## AC-01

Login Screen tetap memiliki username/password existing.

---

## AC-02

Username field memiliki autofill hint yang sesuai.

---

## AC-03

Password field memiliki:

```text
AutofillHints.password
```

---

## AC-04

Username dan password berada dalam satu AutofillGroup.

---

## AC-05

Android password manager dapat mendeteksi form login.

---

## AC-06

iOS Password AutoFill dapat mendeteksi form login.

---

## AC-07

Credential hasil Autofill masuk ke controller existing.

---

## AC-08

Login menggunakan credential Autofill tetap memanggil existing login API.

---

## AC-09

Backend tetap menerima username/password.

Tidak ada perubahan request contract login.

---

## AC-10

Login manual tetap berfungsi.

---

## AC-11

Jika password manager tidak tersedia, Login Screen tetap normal.

---

## AC-12

Jika user cancel Password Autofill, Login Screen tetap dapat digunakan.

---

## AC-13

Jika password Autofill salah/expired, backend error login tampil seperti existing.

---

## AC-14

Tidak ada password yang disimpan sendiri oleh aplikasi Ekaplus untuk fitur ini.

---

## AC-15

Tidak ada `local_auth` call untuk login.

---

## AC-16

Tidak ada biometric data yang dikirim ke backend.

---

## AC-17

Tidak ada perubahan backend.

---

## AC-18

Existing access token/refresh token flow tetap berfungsi.

---

## AC-19

Existing logout tetap berfungsi.

---

## AC-20

Password tidak muncul di application log.

---

# 40. Manual Test Matrix

## Android Samsung

Test:

```text
Samsung Pass enabled
credential tersedia
```

Expected:

- Login Screen dikenali;
- Samsung Pass/autofill suggestion muncul sesuai konfigurasi device;
- credential dapat dipilih;
- biometric verification berjalan dari Samsung Pass;
- username/password terisi;
- login berhasil.

---

## Android Google Password Manager

Expected:

- suggestion credential muncul;
- biometric/device verification mengikuti Google Password Manager;
- Autofill berhasil;
- login backend berhasil.

---

## iPhone Face ID

Expected:

- Password AutoFill tersedia;
- user memilih credential;
- Face ID muncul jika diminta iOS;
- username/password terisi;
- login berhasil.

---

## iPhone Touch ID

Expected:

- Password AutoFill;
- Touch ID jika diminta OS;
- login berhasil.

---

## Device Tanpa Password Tersimpan

Expected:

```text
Login Screen normal
```

User login manual.

---

# 41. Existing Project Analysis

Sebelum coding, Codex wajib memeriksa:

```text
Login Page
Login Form
custom TextField
LoginCubit
LoginRepository
SessionManager
GoRouter flow setelah login
flutter_secure_storage
Android package ID
iOS bundle ID
domain/backend login
```

Perhatikan khusus custom TextField.

Jika existing reusable field belum mendukung:

```dart
autofillHints
```

tambahkan parameter optional tanpa merusak pemakaian lain.

---

# 42. Implementation Approach

Prioritaskan perubahan minimal.

Kemungkinan perubahan utama:

```text
login_page.dart
custom_text_field.dart
```

atau file ekuivalen.

Contoh target:

```dart
AutofillGroup(
  child: Form(
    child: Column(
      children: [
        AppTextField(
          controller: usernameController,
          autofillHints: const [
            AutofillHints.username,
          ],
          textInputAction: TextInputAction.next,
        ),

        AppTextField(
          controller: passwordController,
          autofillHints: const [
            AutofillHints.password,
          ],
          obscureText: true,
          textInputAction: TextInputAction.done,
        ),
      ],
    ),
  ),
)
```

Jangan copy-paste widget baru jika existing component dapat diperluas.

---

# 43. Finish Autofill Context

Setelah login success:

pertimbangkan:

```dart
TextInput.finishAutofillContext(
  shouldSave: true,
);
```

jika sesuai Flutter version dan behavior project.

Tujuannya agar OS/password manager dapat menawarkan save/update credential.

Jangan panggil sebelum login benar-benar berhasil.

Jika login gagal:

jangan menandai Autofill context sebagai successful credential save.

---

# 44. Login Error

Existing API error handling harus dipertahankan.

Contoh:

```text
Invalid username or password
Network error
Server error
```

Jangan mengganti error menjadi biometric-specific.

---

# 45. Scope Out

Tidak termasuk task ini:

- App Lock;
- biometric lock setelah background;
- biometric approval transaksi;
- fingerprint storage;
- face recognition custom;
- biometric login backend;
- PIN login;
- Passkey;
- WebAuthn;
- FIDO2;
- MFA biometric;
- root/jailbreak detection.

---

# 46. Future Enhancement — Passkey

Jika di masa depan Ekaplus ingin benar-benar mempunyai login passwordless:

```text
Face ID / Fingerprint
→ cryptographic credential
→ backend verifies public-key credential
```

maka gunakan konsep:

```text
Passkey / WebAuthn / FIDO2
```

Itu berbeda dari PRD ini dan membutuhkan perubahan backend.

Jangan implementasikan sekarang.

---

# 47. Definition of Done

Task selesai jika:

- Login Screen mendukung Autofill;
- username memiliki AutofillHint;
- password memiliki AutofillHint;
- login fields berada dalam satu AutofillGroup;
- custom input existing tetap reusable;
- login manual tetap berfungsi;
- Password Autofill Android dapat digunakan;
- Password AutoFill iOS dapat digunakan;
- existing login API tidak berubah;
- backend tidak berubah;
- aplikasi tidak menyimpan password sendiri;
- `local_auth` tidak ditambahkan tanpa kebutuhan;
- tidak ada biometric permission yang tidak diperlukan;
- existing SessionManager tetap digunakan;
- existing access/refresh token tidak rusak;
- existing logout tidak rusak;
- password tidak dicetak ke log;
- `flutter analyze` tidak menghasilkan error baru;
- existing tests tetap lulus;
- Android build berhasil;
- iOS configuration tidak rusak.

---

# 48. Instruksi Final Untuk Codex

PRD sebelumnya mengenai:

```text
biometric sebagai local App Lock
```

tidak berlaku untuk task ini.

Gunakan PRD ini sebagai source of truth.

Tujuan implementasi adalah:

```text
Password Manager / Autofill
        ↓
Biometric verification oleh OS jika diperlukan
        ↓
Username + Password
        ↓
Existing Login Ekaplus
```

Bukan:

```text
Biometric
→ unlock token/session
```

dan bukan:

```text
Biometric
→ login backend secara langsung
```

Setelah implementasi selesai, laporkan:

1. file yang diubah;
2. widget login yang diperbarui;
3. AutofillHint yang digunakan;
4. apakah custom input widget perlu diubah;
5. apakah ada Android config tambahan;
6. apakah ada iOS config tambahan;
7. apakah `TextInput.finishAutofillContext()` digunakan;
8. hasil `flutter analyze`;
9. hasil test;
10. hasil build;
11. kemungkinan keterbatasan Samsung Pass/Google Password Manager/iOS Password AutoFill yang ditemukan.
