# PRD — Implementasi Keamanan Biometrik Ekaplus Flutter

## 1. Latar Belakang

Aplikasi Ekaplus saat ini menggunakan autentikasi utama melalui login aplikasi/backend.

Tambahkan lapisan keamanan lokal menggunakan biometrik perangkat sehingga user dapat mengunci dan membuka kembali aplikasi menggunakan mekanisme biometrik yang tersedia pada perangkat.

Biometrik yang digunakan mengikuti kemampuan sistem operasi, misalnya:

- Fingerprint
- Face ID
- Face Recognition
- Biometrik lain yang didukung Android/iOS

Aplikasi tidak boleh membuat implementasi fingerprint dan face recognition secara terpisah.

Gunakan API biometrik native melalui Flutter package `local_auth`.

Untuk penyimpanan session/token sensitif, gunakan secure storage berbasis:

- Android Keystore
- iOS Keychain

Implementasi tahap pertama hanya berada di aplikasi Flutter.

**Tidak ada perubahan backend/API Ekaplus pada scope ini.**

---

# 2. Tujuan

Implementasi harus menghasilkan mekanisme keamanan berikut:

1. User tetap login pertama kali menggunakan username/password seperti sekarang.
2. Setelah login, user dapat mengaktifkan keamanan biometrik.
3. Jika biometrik aktif, aplikasi akan terkunci ketika dibuka kembali sesuai aturan App Lock.
4. User membuka aplikasi menggunakan fingerprint/Face ID/biometrik perangkat.
5. Jika biometrik tidak dapat digunakan, user harus tetap bisa kembali ke mekanisme login normal.
6. Token/session tidak boleh disimpan secara insecure.
7. Biometric data tidak pernah disimpan atau dikirim ke server Ekaplus.

---

# 3. Non-Goal

Pada tahap ini JANGAN:

- mengubah backend
- membuat endpoint biometric login
- mengirim informasi fingerprint/Face ID ke server
- mengirim `biometric_verified=true` ke backend
- membuat biometric sebagai identitas user di server
- menggantikan login username/password sepenuhnya
- membuat custom face recognition
- menyimpan fingerprint
- menyimpan face template
- menyimpan PIN perangkat
- membuat approval biometrik untuk transaksi bisnis

Biometrik pada tahap ini hanya digunakan sebagai:

> Local App Lock / Local Session Unlock

---

# 4. Library

Gunakan:

```yaml
local_auth:
flutter_secure_storage:
```

Gunakan versi terbaru yang kompatibel dengan Flutter/project saat implementasi.

Jangan melakukan downgrade dependency lain tanpa alasan yang diperlukan.

---

# 5. Konsep Arsitektur

Flow utama:

```text
User Login
    ↓
Username + Password
    ↓
Backend Ekaplus
    ↓
Login berhasil
    ↓
Access Token / Session
    ↓
Flutter Secure Storage
    ↓
User menggunakan aplikasi
```

Jika biometric lock aktif:

```text
App Dibuka
    ↓
Cek session tersedia
    ↓
Cek biometric_enabled
    ↓
YES
    ↓
Tampilkan App Lock
    ↓
local_auth
    ↓
Fingerprint / Face ID / Biometric OS
    ↓
Berhasil
    ↓
Unlock aplikasi
```

Biometrik bukan pengganti backend authentication.

Biometrik hanya memberikan izin lokal kepada aplikasi untuk menggunakan session yang sebelumnya sudah diperoleh secara sah.

---

# 6. Secure Storage

Data sensitif tidak boleh disimpan di SharedPreferences.

Token/session authentication harus menggunakan:

```text
flutter_secure_storage
```

Contoh data:

```text
access_token
refresh_token
session_token
```

Jika aplikasi saat ini menyimpan token menggunakan SharedPreferences, lakukan migrasi token authentication ke secure storage.

Preference non-sensitif masih boleh menggunakan SharedPreferences, misalnya:

```text
biometric_enabled
language
theme
first_launch
```

Namun untuk konsistensi, `biometric_enabled` juga boleh dimasukkan ke secure storage.

---

# 7. Biometric Service

Buat service terpisah.

Contoh struktur:

```text
lib/
  core/
    security/
      biometric_service.dart
      secure_storage_service.dart
      app_lock_service.dart
```

Nama folder boleh mengikuti arsitektur existing project.

Jangan memaksakan struktur baru jika project sudah mempunyai pattern service/repository sendiri.

---

# 8. BiometricService

Service minimal menyediakan:

```dart
Future<bool> isDeviceSupported();

Future<bool> canCheckBiometrics();

Future<List<BiometricType>> getAvailableBiometrics();

Future<bool> authenticate();
```

Authentication menggunakan:

```dart
LocalAuthentication.authenticate()
```

Reason:

```text
Verifikasi identitas untuk membuka Ekaplus
```

Gunakan biometric authentication native dari OS.

Jangan membuat UI fingerprint/face custom yang meniru biometric prompt.

---

# 9. Jangan Bedakan Fingerprint dan Face ID Dalam Logic Login

Hindari implementasi seperti:

```dart
if (fingerprintAvailable) {
   fingerprintLogin();
} else if (faceAvailable) {
   faceLogin();
}
```

Gunakan satu mekanisme:

```dart
authenticate()
```

OS menentukan biometrik yang tersedia.

`getAvailableBiometrics()` hanya boleh digunakan jika dibutuhkan untuk UI/informasi.

Contoh:

```text
Biometrik tersedia
Face ID tersedia
Fingerprint tersedia
```

Bukan untuk menentukan flow authentication utama.

---

# 10. Setting Security

Tambahkan menu:

```text
Settings
  → Security
```

atau mengikuti lokasi menu pengaturan yang sudah ada.

UI:

```text
Keamanan

Login Biometrik

[ Toggle ON/OFF ]

Gunakan fingerprint, Face ID, atau biometrik
perangkat untuk membuka aplikasi Ekaplus.
```

Gunakan i18n jika project sudah menggunakan localization.

Bahasa Indonesia:

```text
Keamanan
Login Biometrik
Gunakan biometrik perangkat untuk membuka Ekaplus.
```

Bahasa Inggris:

```text
Security
Biometric Login
Use device biometrics to unlock Ekaplus.
```

---

# 11. Mengaktifkan Biometrik

Ketika user mengubah:

```text
Biometric OFF → ON
```

Jangan langsung menyimpan:

```text
biometric_enabled = true
```

Flow wajib:

```text
Toggle ON
   ↓
Check device support
   ↓
Check biometric enrollment
   ↓
Authenticate biometric
   ↓
Success
   ↓
Save biometric_enabled=true
```

Jika authenticate gagal:

```text
biometric_enabled tetap false
```

---

# 12. Dialog Aktivasi

Saat user mengaktifkan:

```text
Aktifkan Login Biometrik?

Setelah diaktifkan, Anda dapat membuka Ekaplus
menggunakan biometrik perangkat ini.

[Batal] [Aktifkan]
```

Setelah menekan Aktifkan:

```text
OS biometric prompt
```

Jika berhasil:

```text
Login biometrik berhasil diaktifkan.
```

---

# 13. Device Tidak Mendukung Biometrik

Jika device tidak memiliki biometric hardware:

Toggle sebaiknya disabled.

Tampilkan:

```text
Biometrik tidak didukung pada perangkat ini.
```

Jangan menghasilkan exception/crash.

---

# 14. Device Mendukung Tetapi Belum Enroll

Contoh:

- fingerprint belum didaftarkan
- Face ID belum dikonfigurasi

Tampilkan informasi:

```text
Biometrik belum diatur pada perangkat.

Silakan aktifkan fingerprint, Face ID, atau biometrik
lainnya melalui pengaturan perangkat.
```

Jangan mengaktifkan biometric setting.

---

# 15. Menonaktifkan Biometrik

Ketika:

```text
ON → OFF
```

Untuk keamanan, minta autentikasi biometric terlebih dahulu jika biometric masih tersedia.

Flow:

```text
Toggle OFF
   ↓
Authenticate
   ↓
Success
   ↓
biometric_enabled=false
```

Jika biometric sudah tidak tersedia karena user menghapus biometric dari device, aplikasi boleh meminta user login ulang menggunakan password.

Setelah login sukses:

```text
biometric_enabled=false
```

---

# 16. App Lock Screen

Ketika biometric aktif dan aplikasi membutuhkan unlock, tampilkan screen khusus.

Contoh:

```text
--------------------------------

             EKAPLUS

        Aplikasi Terkunci

Gunakan biometrik untuk membuka Ekaplus.

       [ Buka dengan Biometrik ]

          Login Ulang

--------------------------------
```

Jangan menampilkan data aplikasi sensitif di belakang App Lock.

---

# 17. App Startup Flow

Pada cold start:

```text
App Start
   ↓
Initialize
   ↓
Check session/token
   ↓
Token tidak ada
   → Login Screen

Token ada
   ↓
Check biometric_enabled
   ↓
false
   → masuk aplikasi seperti sekarang

true
   ↓
App Lock
   ↓
Authenticate
   ↓
Success
   → Home

Failure
   → tetap App Lock
```

---

# 18. Jangan Auto Logout Saat Biometrik Gagal

Jika biometric authentication gagal:

JANGAN:

```text
hapus token
logout backend
hapus session
```

Biometric failure berbeda dengan invalid authentication session.

Biometric failure hanya berarti aplikasi belum boleh dibuka.

---

# 19. Login Ulang Sebagai Fallback

Pada App Lock screen sediakan:

```text
Login Ulang
```

Jika ditekan:

1. hapus token/session lokal
2. reset biometric unlock state
3. arahkan ke login screen
4. user login username/password

Jangan menonaktifkan preference biometric secara otomatis kecuali memang diperlukan.

Setelah user login kembali, biometric tetap boleh aktif jika perangkat masih mendukung.

---

# 20. Background / Foreground Security

Tambahkan lifecycle handling.

Monitor:

```dart
AppLifecycleState
```

Khusus:

```text
inactive
paused
resumed
detached
hidden
```

Jangan langsung lock setiap aplikasi kehilangan focus beberapa milidetik karena OS biometric prompt sendiri dapat mengubah lifecycle state.

Harus mencegah infinite loop seperti:

```text
authenticate
↓
OS prompt muncul
↓
app paused
↓
lock lagi
↓
authenticate lagi
```

Gunakan state seperti:

```dart
bool _isAuthenticating = false;
bool _isUnlocked = false;
DateTime? _backgroundAt;
```

---

# 21. Background Lock Timeout

Gunakan aturan:

```text
Cold Start
→ selalu biometric lock jika biometric_enabled=true
```

Untuk background → foreground:

Gunakan default timeout:

```text
1 menit
```

Contoh:

```text
User pindah aplikasi 10 detik
→ tidak perlu biometric lagi

User pindah aplikasi >1 menit
→ biometric lock
```

Buat konstanta:

```dart
const biometricLockTimeout = Duration(minutes: 1);
```

Jangan hardcode angka di banyak file.

Ke depan timeout dapat dibuat configurable.

---

# 22. Kondisi Logout

Saat user menekan Logout:

Wajib:

```text
delete access token
delete refresh token
delete session
reset unlocked state
```

Biometric preference boleh tetap tersimpan.

Artinya:

```text
biometric_enabled=true
```

tetapi biometric tidak boleh dapat login tanpa session.

User tetap harus melakukan username/password login terlebih dahulu.

---

# 23. Kondisi Token Expired

Flow:

```text
Biometric success
   ↓
App unlocked
   ↓
API dipanggil
   ↓
Backend mengatakan token expired
   ↓
refresh token
```

Jika refresh gagal:

```text
clear authentication token
→ Login Screen
```

Jangan berasumsi biometric success berarti session backend valid.

---

# 24. Security Rule

Biometric success tidak boleh membuat token baru.

Dilarang:

```dart
if (biometricSuccess) {
   token = "something";
}
```

Token hanya boleh berasal dari backend authentication.

---

# 25. Data Biometrik

Aplikasi tidak boleh:

- membaca fingerprint image
- membaca face image
- menyimpan biometric template
- mengirim biometric template
- mengirim fingerprint data
- mengirim Face ID data

Yang diterima aplikasi hanya:

```text
authentication success / failure
```

Native OS menangani semua biometric verification.

---

# 26. Android Configuration

Tambahkan permission:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

Pastikan activity compatible dengan kebutuhan `local_auth`.

Jika package membutuhkan:

```kotlin
FlutterFragmentActivity
```

ubah MainActivity sesuai kebutuhan plugin.

Pastikan tidak merusak plugin Flutter existing.

---

# 27. iOS Configuration

Tambahkan:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Face ID digunakan untuk mengamankan akses ke aplikasi Ekaplus.</string>
```

Gunakan localization bila Info.plist localization sudah digunakan project.

---

# 28. Error Handling

Semua biometric exception harus ditangani.

Contoh kondisi:

```text
NotAvailable
NotEnrolled
LockedOut
PermanentlyLockedOut
UserCanceled
SystemCanceled
PasscodeNotSet
```

Jangan tampilkan raw exception ke user.

Contoh buruk:

```text
PlatformException(NotAvailable, ...)
```

Tampilkan pesan manusiawi.

---

# 29. Failed Authentication

Jika user gagal fingerprint/Face ID:

Tetap tampilkan App Lock.

Contoh:

```text
Biometrik tidak berhasil diverifikasi.
Silakan coba kembali.
```

Jangan logout.

---

# 30. User Cancel

Jika user menutup biometric prompt:

Tetap di App Lock.

Tidak perlu dianggap error fatal.

User bisa tekan:

```text
Buka dengan Biometrik
```

lagi.

---

# 31. Biometric Locked Out

Jika terlalu banyak percobaan gagal:

Tampilkan:

```text
Biometrik sementara terkunci.

Silakan coba kembali nanti atau gunakan Login Ulang.
```

Jika permanently locked:

```text
Biometrik tidak dapat digunakan.

Silakan login ulang atau periksa pengaturan keamanan perangkat.
```

---

# 32. Perubahan Biometric Device

Perhatikan kondisi user:

1. mengaktifkan biometrik di Ekaplus
2. kemudian menambahkan/menghapus fingerprint di Settings HP

Jika biometric tidak lagi dapat dipakai:

```text
App Lock
→ biometric unavailable
→ tampilkan Login Ulang
```

Jangan menyebabkan user permanently terkunci dari aplikasi.

---

# 33. Reinstall Application

Setelah uninstall/reinstall:

Jangan mengandalkan biometric preference lama.

Secure storage/keychain behavior dapat berbeda antar platform.

Aplikasi harus tetap mampu menentukan:

```text
session tersedia?
biometric setting valid?
```

Jika state tidak konsisten:

```text
clear authentication state
→ login normal
```

Fail securely.

---

# 34. Root/Jailbreak

Root/jailbreak detection bukan bagian scope PRD ini.

Jangan menambahkan library root detection tanpa requirement terpisah.

---

# 35. Sensitive Screenshot

Saat App Lock aktif, jangan membiarkan isi aplikasi terlihat jelas melalui App Switcher jika project sudah memiliki mekanisme privacy screen.

Jika belum ada, buat implementasi dengan risiko rendah jika memungkinkan tanpa merusak UX.

Prioritas:

```text
App Lock muncul secepat mungkin ketika resume.
```

Privacy screen penuh dapat dibuat PRD terpisah jika kompleks.

---

# 36. State Management

Ikuti state management project existing.

Jika project menggunakan Bloc/Cubit:

Buat misalnya:

```text
SecurityCubit
AppLockCubit
```

State contoh:

```text
SecurityInitial
SecurityChecking
SecurityAvailable
SecurityUnavailable
SecurityAuthenticating
SecurityEnabled
SecurityDisabled
SecurityError
```

Jangan memperkenalkan Provider/Riverpod baru jika project sudah menggunakan Bloc.

---

# 37. Suggested Domain Model

Contoh:

```dart
enum AppLockStatus {
  disabled,
  locked,
  authenticating,
  unlocked,
}
```

AppLock controller/service bertanggung jawab menentukan:

```text
needLock
isUnlocked
shouldLockOnResume
```

---

# 38. Single Authentication Request

Jangan jalankan beberapa biometric prompt bersamaan.

Gunakan guard:

```dart
if (_isAuthenticating) return;
```

Contoh bug yang harus dicegah:

```text
build()
→ authenticate()

rebuild()
→ authenticate()

resume()
→ authenticate()
```

Biometric call jangan diletakkan langsung di `build()`.

Gunakan lifecycle/event/controller yang jelas.

---

# 39. Navigasi

User tidak boleh bisa bypass App Lock menggunakan:

- Android back button
- deep link
- notification navigation
- route restoration
- tab navigation

Jika app dalam kondisi:

```text
locked
```

seluruh protected route harus tetap berada di belakang App Lock.

---

# 40. Deep Link / Notification

Jika notification membuka route:

```text
/customer/123
```

dan aplikasi locked:

```text
notification tap
↓
App Lock
↓
Biometric success
↓
baru buka /customer/123
```

Jangan langsung membuka screen tujuan sebelum unlock.

Jika project belum memiliki deep link/notification routing, jangan membangun fitur baru hanya untuk PRD ini.

Tetapi arsitektur lock tidak boleh menghalangi implementasi tersebut di kemudian hari.

---

# 41. Multi Account

Jika Ekaplus mendukung logout → login akun berbeda:

Biometric unlock hanya membuka session akun yang sedang tersimpan.

Jangan menyimpan mapping:

```text
fingerprint → user A
face ID → user B
```

OS biometric tidak memberikan identitas biometric tersebut.

---

# 42. UI Behaviour

Saat authentication sedang berjalan:

Disable button:

```text
Buka dengan Biometrik
```

untuk mencegah double tap.

Boleh tampilkan:

```text
Memverifikasi...
```

Setelah selesai:

```text
button aktif kembali
```

jika authentication gagal/cancel.

---

# 43. Localization

Semua string baru masukkan ke localization existing.

Minimal:

```text
security
biometricLogin
biometricDescription
enableBiometric
disableBiometric
unlockApp
appLocked
authenticateToContinue
biometricNotAvailable
biometricNotEnrolled
biometricFailed
biometricLocked
loginAgain
cancel
enable
```

Bahasa minimal:

```text
id
en
```

jika project Ekaplus memang sudah mempunyai kedua bahasa tersebut.

---

# 44. Logging

Jangan log:

```text
access token
refresh token
password
secure storage content
```

Boleh log secara development:

```text
biometric auth requested
biometric auth success
biometric auth cancelled
biometric unavailable
```

Tetapi hindari log sensitif.

---

# 45. Backend

Tidak ada perubahan backend.

Tidak perlu membuat:

```text
POST /biometric/login
POST /biometric/verify
POST /biometric/register
```

Tidak perlu mengubah schema user.

Tidak perlu membuat field:

```text
fingerprint_id
face_id
biometric_token
```

Biometric authentication adalah local device security.

---

# 46. Future Scope

Desain jangan menghalangi implementasi tahap berikutnya:

## Phase 2 — Biometric Re-Authentication

Digunakan sebelum action sensitif seperti:

```text
Approve Credit Limit
Approve Overdue
Perubahan Credit Policy
Perubahan Rekening
Approval penting
```

Tetapi JANGAN implementasikan Phase 2 sekarang.

Phase 2 perlu security design sendiri karena action sensitif tidak boleh hanya bergantung pada:

```json
{
  "biometric_verified": true
}
```

yang bisa dimanipulasi oleh client.

---

# 47. Acceptance Criteria

## AC-01

Device mempunyai fingerprint/Face ID.

User dapat mengaktifkan:

```text
Login Biometrik
```

dan harus melakukan biometric verification sebelum setting tersimpan.

---

## AC-02

Setelah biometric aktif, cold start aplikasi menampilkan App Lock sebelum user melihat konten utama.

---

## AC-03

Fingerprint berhasil:

```text
App Lock → Home
```

---

## AC-04

Face ID berhasil:

```text
App Lock → Home
```

tanpa logic khusus Face ID di aplikasi.

---

## AC-05

User cancel biometric prompt.

Expected:

```text
tetap di App Lock
```

Tidak logout.

---

## AC-06

Fingerprint salah.

Expected:

```text
tetap locked
```

Tidak menghapus session.

---

## AC-07

Device tidak mendukung biometric.

Expected:

```text
setting biometric unavailable/disabled
```

Aplikasi tidak crash.

---

## AC-08

Device mendukung biometric tetapi user belum enroll.

Expected:

```text
biometric tidak dapat diaktifkan
```

Tampilkan instruksi untuk mengatur biometric pada device.

---

## AC-09

App masuk background kurang dari 1 menit.

Expected:

```text
resume tanpa biometric prompt
```

---

## AC-10

App masuk background lebih dari 1 menit.

Expected:

```text
App Lock
→ biometric authentication
```

---

## AC-11

User logout.

Expected:

```text
token/session dihapus
```

Biometric tidak boleh membuka aplikasi tanpa login backend.

---

## AC-12

Token expired.

Biometric berhasil tetapi refresh token gagal.

Expected:

```text
Login Screen
```

---

## AC-13

Biometric permanently unavailable.

Expected:

```text
user tetap memiliki opsi Login Ulang
```

Tidak boleh terjadi permanent lock-out.

---

## AC-14

User menekan tombol biometric berkali-kali.

Expected:

```text
hanya satu biometric prompt aktif
```

---

## AC-15

Biometric prompt menyebabkan lifecycle paused/resumed.

Expected:

```text
tidak terjadi authentication loop
```

---

# 48. Testing

Tambahkan unit test sebanyak memungkinkan untuk:

```text
AppLockService
Security state
timeout calculation
needLock()
logout state
```

Logic native biometric dapat dimock.

Test minimal:

```text
biometric disabled → no lock

biometric enabled + cold start → locked

biometric enabled + auth success → unlocked

biometric enabled + auth fail → locked

background 30 sec → unlocked

background 61 sec → locked

logout → session unavailable

no biometric → setting cannot be enabled
```

---

# 49. Manual Testing Matrix

Minimal test:

| Device                               | Biometric     | Result |
| ------------------------------------ | ------------- | ------ |
| Android fingerprint                  | fingerprint   | PASS   |
| Android face biometric jika tersedia | face          | PASS   |
| Android tanpa biometric              | none          | PASS   |
| iPhone Touch ID jika tersedia        | fingerprint   | PASS   |
| iPhone Face ID                       | face          | PASS   |
| biometric belum enroll               | none enrolled | PASS   |
| biometric lockout                    | locked        | PASS   |

Tidak wajib memiliki semua device fisik.

Gunakan emulator/simulator untuk scenario yang bisa diemulasikan.

Tetapi minimal lakukan test pada satu Android device fisik sebelum release production.

---

# 50. Definition of Done

Task dianggap selesai jika:

- `local_auth` terintegrasi
- secure storage digunakan untuk authentication token
- biometric setting tersedia
- biometric activation diverifikasi
- App Lock tersedia
- cold start locking berjalan
- background timeout locking berjalan
- fallback login tersedia
- lifecycle tidak menyebabkan loop
- Android configuration selesai
- iOS configuration selesai
- localization tersedia
- error handling tersedia
- tidak ada perubahan backend
- existing login tetap berfungsi
- existing logout tetap berfungsi
- build Android berhasil
- build iOS tidak rusak
- lint/analyzer tidak menghasilkan error baru
- tidak ada token/password yang dicetak ke log

---

# 51. Instruksi Implementasi untuk Codex

Sebelum coding:

1. Analisis struktur project Flutter Ekaplus.
2. Temukan mekanisme login saat ini.
3. Temukan lokasi penyimpanan token/session.
4. Temukan state management yang digunakan.
5. Temukan lifecycle handling existing.
6. Temukan routing/navigation existing.
7. Temukan localization existing.
8. Temukan Settings/Profile screen existing.

Jangan mengubah arsitektur project secara besar-besaran.

Integrasikan fitur mengikuti pattern existing.

Jika token masih disimpan menggunakan SharedPreferences:

```text
migrasikan hanya authentication secret ke flutter_secure_storage
```

Jangan memindahkan seluruh preference aplikasi tanpa alasan.

Sebelum melakukan perubahan besar, identifikasi seluruh call-site yang membaca token supaya tidak menyebabkan regression.

Implementasi harus production-oriented, bukan hanya proof of concept.

Setelah implementasi:

1. jalankan `flutter analyze`
2. jalankan test existing
3. tambahkan test feature baru
4. verifikasi Android build
5. laporkan file yang diubah
6. laporkan perubahan dependency
7. laporkan perubahan Android/iOS configuration
8. jelaskan flow final App Lock
9. laporkan potential issue yang masih tersisa

Jangan mengubah backend Ekaplus dalam task ini.
