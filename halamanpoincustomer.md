Sebelum mulai coding, baca dan pahami terlebih dahulu:

1. `design.md`
2. halaman Customer existing
3. komponen reusable yang sudah dipakai pada halaman Customer, Account, Wishlist, dan halaman lain yang relevan
4. PRD Loyalty Point di bawah ini

Tugas bukan hanya mengimplementasikan logic/API.

Codex juga bertanggung jawab mendesain UI/UX fitur Loyalty Point agar menyatu dengan aplikasi Ekaplus existing.

## Aturan desain

Jangan membuat style baru yang berbeda sendiri.

Ambil pola visual dari aplikasi existing, terutama:

- CustomHeader
- section title
- card
- border
- shadow
- radius
- icon container
- typography
- spacing
- list item
- chevron
- button
- bottom sheet
- shimmer
- empty state
- error state
- infinite scroll

Prioritas desain:

1. konsisten dengan `design.md`
2. konsisten dengan halaman Customer existing
3. reuse component existing jika memungkinkan
4. baru membuat component baru jika memang belum ada

## Halaman Customer

Jangan redesign seluruh halaman Customer.

Pertahankan tampilan existing.

Tambahkan section:

`POIN & REWARD`

di antara:

`ENTITAS & CABANG PERUSAHAAN`

dan:

`TRANSAKSI`

Card `Poin Ekaplus` harus mengikuti pola visual card existing seperti `Daftar Perusahaan & Cabang`.

Contoh hierarchy:

```text
POIN & REWARD

[icon]  Poin Ekaplus                    >
        17.892 Poin
        Poin tersedia
```

Jangan membuat card ini terlalu besar.

Halaman Customer hanya berfungsi sebagai entry point dan summary.

## Halaman Poin Ekaplus

Untuk halaman detail Poin Ekaplus, Codex boleh merancang layout terbaik sendiri selama:

- mengikuti design system Ekaplus,
- mobile-first,
- hierarchy informasi jelas,
- Poin Tersedia menjadi informasi paling dominan,
- tidak terlalu padat,
- tidak terlihat seperti dashboard admin,
- mudah dipahami customer umum.

Susunan informasi minimal:

```text
CustomHeader

Saldo Poin
↓
Informasi poin akan berakhir / belum aktif

Perolehan Poin
↓
Preview 3 item
↓
Lihat Semua

Reward
↓
Preview beberapa reward
↓
Lihat Semua

Aktivitas Terbaru
↓
Preview history
↓
Lihat Semua
```

Codex boleh menentukan apakah masing-masing menggunakan:

- card,
- grouped card,
- horizontal list,
- vertical list,

berdasarkan pola yang paling konsisten dengan Ekaplus.

## Rincian Perolehan Poin

Prioritaskan keterbacaan.

Customer harus langsung memahami:

```text
Accessories

Total Pembelian
Rp1.280.000

Ketentuan Poin
Rp10.000 = 1 poin

Poin Diperoleh
+128 Poin
```

Jangan tampilkan:

- formula teknis,
- raw calculation,
- Gross Profit,
- GP Percentage,
- calculation ID,
- rule ID,
- internal error.

## Reward

Reward harus terasa seperti customer benefit, bukan admin master data.

Tampilkan:

- image jika tersedia,
- nama reward,
- point required,
- eligibility,
- CTA.

Jika poin kurang:

`Kurang 2.108 poin`

Jika cukup:

`Bisa ditukar`

## Quality Requirement

Jangan hanya membuat UI yang “berfungsi”.

Hasil harus:

- rapi,
- polished,
- konsisten,
- reusable,
- production-ready,
- responsive terhadap ukuran device,
- tidak overflow,
- mendukung text scaling secara wajar.

Setelah implementasi:

1. review hasil desain terhadap `design.md`,
2. cari inkonsistensi spacing/font/card,
3. rapikan,
4. jalankan analyzer,
5. pastikan tidak ada error,
6. pastikan tidak ada regression pada halaman Customer existing.

Jangan mengubah fitur lain yang tidak berkaitan.

# PRD Development — Loyalty Point Customer Ekaplus Mobile

## 1. Objective

Implementasikan fitur **Poin Ekaplus** pada halaman Customer existing aplikasi Flutter Ekaplus.

Entry point bukan menu bottom navigation baru.

Entry point berada pada:

```text
Bottom Navigation
→ Customer
→ Section POIN & REWARD
→ Poin Ekaplus
```

Section Point berada di halaman Customer existing, di antara:

```text
ENTITAS & CABANG PERUSAHAAN

dan

TRANSAKSI
```

---

# 2. Existing Customer Page

Struktur existing:

```text
CustomerPage
│
├── CustomHeader
├── Customer Summary
├── ENTITAS & CABANG PERUSAHAAN
├── TRANSAKSI
└── Bottom Navigation
```

Ubah menjadi:

```text
CustomerPage
│
├── CustomHeader
├── Customer Summary
├── ENTITAS & CABANG PERUSAHAAN
├── POIN & REWARD
│      └── Poin Ekaplus
├── TRANSAKSI
└── Bottom Navigation
```

Jangan merombak layout existing selain menyisipkan section baru.

---

# 3. Customer Context

Halaman Customer mempunyai customer/BC aktif.

Poin mengikuti customer aktif tersebut.

Gunakan `bcid` customer aktif sebagai context API loyalty.

Jangan resolve:

```text
BC → GC → GP
```

di Flutter.

Backend yang menentukan GP terkait.

---

# 4. Customer Switch Behavior

Saat user menekan:

```text
Ganti
```

dan customer aktif berubah:

refresh:

```text
customer summary
point balance
point preview
```

Point dari customer sebelumnya tidak boleh tertinggal di UI.

Sequence:

```text
Customer A
↓
load point A

Ganti Customer

Customer B
↓
clear/stale point A
↓
load point B
```

Gunakan loading state sementara untuk card Point.

---

# 5. GP Wallet Behavior

Saldo loyalty berada pada Group Parent.

Karena itu dua BC yang berbeda tetapi berada pada GP sama dapat menghasilkan saldo poin yang sama.

Ini valid.

Jangan membuat wallet per BC di Flutter.

---

# 6. Section Component

Tambahkan section heading:

```text
POIN & REWARD
```

Tambahkan component misalnya:

```dart
CustomerLoyaltyPointCard
```

Follow widget style existing Customer page.

Card:

```text
[icon] Poin Ekaplus            >
       17.892 Poin
       Poin tersedia
```

---

# 7. Customer Page Data

Customer page hanya perlu:

```text
availablePoint
```

Tidak perlu mengambil semua calculation detail hanya untuk membuat card.

Card harus ringan.

---

# 8. Balance API

Gunakan existing endpoint:

```http
POST /api/resource/loyalty_redemption/method/get_balance
```

Payload:

```json
{
  "bcid": "<ACTIVE_BCID>"
}
```

Relevant response:

```json
{
  "status": "success",
  "data": {
    "total_point": 8000,
    "redeemed_point": 2000,
    "reserved_point": 1000,
    "available_point": 5000,
    "buckets": []
  }
}
```

---

# 9. Customer Card Mapping

```text
available_point
→ 5.000 Poin
```

Subtitle:

```text
Poin tersedia
```

Do not show:

```text
total_point
reserved_point
redeemed_point
```

on CustomerPage.

Those values belong to PointPage.

---

# 10. Customer Card Loading

Only point card should load.

Do not block entire CustomerPage.

Suggested states:

```text
initial
loading
success
empty
failure
```

---

# 11. Customer Card Error

If point endpoint fails:

do not break CustomerPage.

Display:

```text
Poin Ekaplus

Data poin belum dapat dimuat

Coba Lagi
```

Other Customer features remain functional.

---

# 12. Customer Card Empty

If available point is zero:

```text
Poin Ekaplus

0 Poin

Mulai kumpulkan poin dari pembelian Anda
```

Card remains tappable.

---

# 13. Navigation

Tap card:

```text
CustomerPage
↓
LoyaltyPointPage
```

Suggested routes:

```text
/customer/points
/customer/points/earnings
/customer/points/rewards
/customer/points/rewards/:rewardId
/customer/points/history
/customer/points/history/:redemptionId
```

Carry active BC context via current customer state or route parameter according to existing architecture.

Do not duplicate customer object unnecessarily.

---

# 14. Main Loyalty Point Page

Suggested:

```dart
LoyaltyPointPage
```

Sections:

```text
CustomHeader
BalanceCard
ExpiryInformation
EarningPreview
RewardPreview
RecentRedemption
```

Do not build entire page as one massive widget.

---

# 15. Point Balance Mapping

Mapping:

```text
available_point
→ Poin Tersedia

total_point
→ Total Poin

reserved_point
→ Dalam Proses

redeemed_point
→ Sudah Digunakan
```

Primary number:

```text
available_point
```

---

# 16. Balance Domain Entity

Suggested:

```dart
class LoyaltyBalance {
  final int totalPoint;
  final int redeemedPoint;
  final int reservedPoint;
  final int availablePoint;
  final List<LoyaltyPointBucket> buckets;
}
```

Bucket:

```dart
class LoyaltyPointBucket {
  final int earnedPoint;
  final int usedPoint;
  final int reservedPoint;
  final int availablePoint;

  final DateTime? validFrom;
  final DateTime? validTo;

  final bool expired;
  final bool ready;
}
```

Internal IDs do not need presentation exposure.

---

# 17. Expiry

Find usable non-expired bucket:

```text
availablePoint > 0
AND
expired == false
AND
validTo != null
```

Nearest expiry should get priority.

Display:

```text
3.000 poin akan berakhir
30 November 2026
```

---

# 18. Not Ready Point

For:

```text
ready == false
```

display customer wording:

```text
2.500 poin belum dapat digunakan
```

Never show:

```text
ready
AFTER_PERIOD_END
expiry_mode
```

---

# 19. Point Earning Detail

Source data concept:

```text
loyalty_calculation_detail
```

Customer only needs:

```text
account
omzet_snapshot
standard_divider_snapshot
awarded_point
```

Mapping:

```text
account
→ category

omzet_snapshot
→ purchaseAmount

standard_divider_snapshot
→ pointDivider

awarded_point
→ awardedPoint
```

---

# 20. Security Requirement

CRITICAL.

Do not call unrestricted:

```text
/api/resource/loyalty_calculation_detail
```

from customer mobile if the response contains confidential columns.

Especially:

```text
gross_profit_snapshot
gp_percent_snapshot
```

must never be delivered to customer app.

Hiding them from Flutter widgets is not sufficient.

---

# 21. Customer Safe Point Detail API

If no safe endpoint currently exists, backend should provide dedicated method.

Recommended:

```http
POST /api/resource/loyalty_calculation/method/get_customer_point_detail
```

Payload:

```json
{
  "bcid": "BGR00001"
}
```

Optional period:

```json
{
  "bcid": "BGR00001",
  "period": "LOYALTY-2026"
}
```

Backend responsibilities:

1. authorize logged-in customer,
2. validate BC is accessible,
3. resolve BC → GC → GP,
4. find customer-visible finalized calculation,
5. filter relevant detail,
6. return whitelist fields only.

---

# 22. Safe Response

Recommended:

```json
{
  "status": "success",
  "data": {
    "period_name": "LOYALTY-2026",
    "total_point": 586,
    "rows": [
      {
        "category": "Penjualan Accessories",
        "purchase_amount": 1280000,
        "point_divider": 10000,
        "awarded_point": 128
      },
      {
        "category": "Penjualan Accessories Kaki",
        "purchase_amount": 2000000,
        "point_divider": 10000,
        "awarded_point": 200
      },
      {
        "category": "Penjualan Kain Polos Sofa",
        "purchase_amount": 2584000,
        "point_divider": 10000,
        "awarded_point": 258
      }
    ]
  }
}
```

---

# 23. Backend Whitelist

Customer-safe endpoint may expose:

```text
period_name
total_point
category
purchase_amount
point_divider
awarded_point
```

Never expose:

```text
gross_profit_snapshot
gp_percent_snapshot
calculation_id
calculation_name
rule_detail_id
formula_snapshot
raw_point
created_by
updated_by
owner
docstatus
internal error
batch
```

---

# 24. Filtering

Customer-visible detail should only contain meaningful rows.

Recommended:

```text
purchase_amount > 0
AND
awarded_point > 0
```

Do not show:

```text
Penjualan Busa
Rp0
0 poin
```

---

# 25. Internal Rule Errors

If backend has:

```text
NO_RULE_DETAIL
NEED_REVIEW
FAILED
```

do not send technical error to mobile.

Customer only sees finalized point earning.

---

# 26. Earning Entity

Suggested:

```dart
class LoyaltyEarningDetail {
  final String category;
  final num purchaseAmount;
  final num pointDivider;
  final int awardedPoint;
}
```

Do not add:

```dart
grossProfit
gpPercent
calculationId
ruleId
formula
```

even as hidden presentation fields.

---

# 27. Point Formatting

Use Indonesian formatting:

```text
1280000
→ Rp1.280.000

17892
→ 17.892 Poin
```

Divider:

```text
10000
→ Rp10.000 = 1 poin
```

Do not display raw formula.

---

# 28. Earning Preview

On main LoyaltyPointPage show max 3 rows.

Example:

```text
Accessories
Rp1.280.000
Rp10.000 = 1 poin           +128

Accessories Kaki
Rp2.000.000
Rp10.000 = 1 poin           +200
```

CTA:

```text
Lihat Semua
```

---

# 29. Full Earning Page

Suggested:

```dart
LoyaltyEarningDetailPage
```

Features:

- summary period,
- total earned,
- list,
- pull to refresh,
- pagination if required,
- loading,
- empty,
- error.

---

# 30. Rewards

Reward preview appears on LoyaltyPointPage.

Maximum:

```text
3–5 items
```

CTA:

```text
Lihat Semua
```

Navigate to:

```dart
LoyaltyRewardListPage
```

---

# 31. Reward Card

Customer-visible fields:

```text
reward name
image
point required
availability
```

Example:

```text
Voucher Rp100.000
2.000 Poin
Bisa ditukar
```

---

# 32. Reward Eligibility

UI:

```dart
canRedeem = availablePoint >= pointRequired;
```

If insufficient:

```text
Kurang 2.108 poin
```

Backend remains authority.

Client-side eligibility is informational only.

---

# 33. Reward Detail

Suggested:

```dart
LoyaltyRewardDetailPage
```

Display:

```text
image
reward name
description
point required
current available point
quantity
total point
approval information
```

CTA:

```text
Tukar Poin
```

---

# 34. Redemption API

Use:

```http
POST /api/resource/loyalty_redemption/method/redeem
```

Payload:

```json
{
  "reward": "<REWARD>",
  "bcid": "<ACTIVE_BCID>",
  "quantity": 1,
  "idempotency_key": "<UNIQUE_KEY>"
}
```

---

# 35. Idempotency

Generate one key per confirmed redemption attempt.

Disable submit button while request is active.

If network result is uncertain and the exact request is retried:

reuse the same idempotency key.

Do not accidentally create a second redemption.

---

# 36. Redemption Result

Map:

```text
APPROVED
→ Berhasil

PENDING
→ Dalam Proses
```

After result:

do not manually calculate final wallet state.

Refresh:

```text
balance
reward eligibility
history
```

from backend.

---

# 37. Error Mapping

Example:

```text
INSUFFICIENT_POINT
```

UI:

```text
Poin Anda tidak mencukupi untuk menukar hadiah ini.
```

Example:

```text
QUOTA_EXHAUSTED
```

UI:

```text
Hadiah ini sudah tidak tersedia.
```

Example:

```text
REWARD_INACTIVE
REWARD_EXPIRED
```

UI:

```text
Hadiah ini sudah tidak dapat ditukar.
```

Never show raw backend messages.

---

# 38. Redemption History

Use:

```http
POST /api/resource/loyalty_redemption/method/get_history
```

Payload:

```json
{
  "bcid": "<ACTIVE_BCID>",
  "limit": 20
}
```

Relevant response:

```text
redemption_id
redemption_name
status
point_used
reward_name
reward_type
created_at
completed_at
```

---

# 39. History Mapping

```text
PENDING
→ Dalam Proses

APPROVED
→ Berhasil

REJECTED
→ Ditolak
```

---

# 40. Main Page History Preview

Show maximum:

```text
3 latest transactions
```

Example:

```text
Voucher Rp100.000
-2.000 Poin
Berhasil
21 Oktober 2026
```

CTA:

```text
Lihat Semua
```

---

# 41. History Screen

Suggested:

```dart
LoyaltyHistoryPage
```

Filter:

```text
Semua
Dalam Proses
Berhasil
Ditolak
```

Support:

- pagination,
- infinite scroll,
- pull to refresh,
- loading,
- empty,
- error.

---

# 42. Redemption Detail

Suggested:

```dart
LoyaltyRedemptionDetailPage
```

Show:

```text
reward
status
pointUsed
createdAt
completedAt
redemptionName
```

Map:

```text
redemptionName
→ No. Transaksi
```

---

# 43. State Management

Use existing Flutter Bloc/Cubit architecture.

Do not introduce new state management.

Suggested:

```text
CustomerPointSummaryCubit
LoyaltyBalanceCubit
LoyaltyEarningCubit
LoyaltyRewardBloc/Cubit
LoyaltyRedeemCubit
LoyaltyHistoryBloc/Cubit
```

Can be consolidated if existing project architecture prefers feature-level Bloc.

Follow project convention.

---

# 44. Customer Change Handling

Customer switch is critical.

When active `bcid` changes:

```text
cancel/ignore previous customer response
clear point summary
load new point summary
```

Prevent race condition:

```text
Customer A request running
↓
switch Customer B
↓
A response arrives late
```

Response A must not overwrite Customer B point state.

State should retain the BCID/request context.

---

# 45. Pull to Refresh

Customer page refresh:

```text
customer information
point summary
```

PointPage refresh:

```text
balance
earning
reward preview
recent history
```

After redeem:

```text
balance
rewards
history
```

---

# 46. Cache

Do not treat local cached balance as final truth.

On entering LoyaltyPointPage:

refresh backend.

If stale cache is displayed for UX:

mark/replace it after API response.

Redemption must always use backend.

---

# 47. Independent Loading

PointPage sections should fail independently where possible.

Example:

balance success,
reward endpoint failure.

Result:

balance remains displayed.

Reward section displays retry state.

Do not replace entire screen with one global error unless core balance itself cannot load.

---

# 48. Design Requirement

Read `design.md` before implementation.

Reuse existing components:

```text
CustomHeader
Cards
Section heading
Typography
Spacing
Border
Shadow
Radius
Icons
Bottom Sheet
Button
Shimmer
Empty State
Error State
Infinite Scroll
```

Do not create arbitrary new styling.

---

# 49. Customer Page Layout Requirement

Final layout:

```text
Customer Summary

ENTITAS & CABANG PERUSAHAAN
[Daftar Perusahaan & Cabang]

POIN & REWARD
[Poin Ekaplus]

TRANSAKSI
[Sales Order]
[Sales Invoice]
```

Point card should visually match existing list/card components.

---

# 50. Security

Customer application must never receive confidential calculation data.

Especially:

```text
gross_profit_snapshot
gp_percent_snapshot
```

Security rules:

1. server-side field whitelist,
2. authorization of active BC,
3. verify BC belongs to logged-in customer's accessible hierarchy,
4. never trust arbitrary BCID,
5. do not depend on Flutter hiding fields,
6. do not log confidential calculation response.

---

# 51. Acceptance Criteria

Implementation is complete when:

1. Customer page contains `POIN & REWARD`.
2. Section appears between Entity and Transaction sections.
3. Point card follows existing Customer UI.
4. Card displays available point.
5. Card updates when customer is changed.
6. Previous customer point cannot remain after switch.
7. Card can navigate to Poin Ekaplus.
8. PointPage shows available point.
9. Total point and in-process point display correctly.
10. Expiry warning works.
11. Not-ready point information works.
12. Earning preview displays.
13. Customer can open all earning details.
14. Purchase amount displays in Rupiah.
15. Divider displays as customer-friendly point rule.
16. Gross Profit is never sent/displayed.
17. GP Percentage is never sent/displayed.
18. Internal calculation information is hidden.
19. Customer can view rewards.
20. Customer can open reward detail.
21. Customer can redeem reward.
22. Double submit is protected.
23. Pending maps to Dalam Proses.
24. Approved maps to Berhasil.
25. Rejected maps to Ditolak.
26. Customer can view history.
27. Balance refreshes after redeem.
28. Customer switch correctly refreshes loyalty state.
29. Loading state exists.
30. Empty state exists.
31. Error state exists.
32. Point endpoint error does not break CustomerPage.
33. UI complies with `design.md`.
34. Unauthorized customer cannot access another group's points.

---

# 52. Final Flow

```text
BOTTOM NAVIGATION
      │
      ▼
   CUSTOMER
      │
      ├── Customer Summary
      │
      ├── Entity & Branch
      │
      ├── POIN & REWARD
      │       │
      │       └── Poin Ekaplus
      │              │
      │              ▼
      │          POINT PAGE
      │          │
      │          ├── Saldo
      │          ├── Expiry
      │          │
      │          ├── Perolehan
      │          │      │
      │          │      └── Semua Perolehan
      │          │
      │          ├── Reward
      │          │      │
      │          │      ├── Semua Reward
      │          │      └── Detail Reward
      │          │              │
      │          │              └── Redeem
      │          │
      │          └── History
      │                 │
      │                 └── Detail Redemption
      │
      └── Transaction
             ├── Sales Order
             └── Sales Invoice
```

Customer experience:

```text
Customer Aktif
↓
Lihat Poin
↓
Lihat asal poin
↓
Lihat reward
↓
Tukar poin
↓
Lihat status penukaran
```

Keep the experience simple and do not expose loyalty engine complexity.
