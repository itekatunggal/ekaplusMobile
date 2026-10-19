<!DOCTYPE html><html lang="id"><head>
<meta charset="utf-8">
<meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" name="viewport">
<title>Akun Saya - Ekatunggal</title>
<!-- Tailwind CSS v3 with Plugins -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<!-- Google Fonts: Plus Jakarta Sans -->
<link href="https://fonts.googleapis.com" rel="preconnect">
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
<script>
    tailwind.config = {
      theme: {
        extend: {
          fontFamily: {
            sans: ['"Plus Jakarta Sans"', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
          },
          colors: {
            brand: {
              50: '#FDF2F2',
              100: '#FDE8E8',
              500: '#EF4444',
              600: '#DC2626',
              700: '#B91C1C',
              800: '#991B1B'
            },
            accent: {
              yellow: '#F59E0B',
              yellowHover: '#D97706',
              yellowLight: '#FEF3C7'
            }
          },
          boxShadow: {
            card: '0 2px 10px -1px rgba(0, 0, 0, 0.05), 0 1px 4px -1px rgba(0, 0, 0, 0.03)',
            elevated: '0 8px 24px -4px rgba(185, 28, 28, 0.14), 0 4px 8px -2px rgba(0, 0, 0, 0.04)'
          }
        }
      }
    };
  </script>
<!-- Phosphor Icons for Crisp Mobile UI Icons -->
<script src="https://unpkg.com/@phosphor-icons/web"></script><link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/@phosphor-icons/web@2.1.2/src/regular/style.css"><link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/@phosphor-icons/web@2.1.2/src/thin/style.css"><link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/@phosphor-icons/web@2.1.2/src/light/style.css"><link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/@phosphor-icons/web@2.1.2/src/bold/style.css"><link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/@phosphor-icons/web@2.1.2/src/fill/style.css"><link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/@phosphor-icons/web@2.1.2/src/duotone/style.css">
<style data-purpose="base-styling">
    body {
      font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      -webkit-tap-highlight-color: transparent;
      user-select: none;
    }
    .hide-scrollbar::-webkit-scrollbar {
      display: none;
    }
    .hide-scrollbar {
      -ms-overflow-style: none;
      scrollbar-width: none;
    }
  </style>
</head>
<body class="bg-[#F6F7F9] text-gray-800 antialiased min-h-screen pb-24">
<!-- BEGIN: MobileDeviceFrame -->
<div class="max-w-md mx-auto min-h-screen bg-[#F6F7F9] relative flex flex-col shadow-2xl">
<!-- BEGIN: TopHeader -->
<header class="bg-gradient-to-r from-brand-700 to-brand-600 text-white pt-10 pb-16 px-4 relative rounded-b-[2rem] shadow-md">
<!-- Status Bar Simulation & Top Bar -->
<div class="flex items-center justify-between mb-4">
<button aria-label="Kembali" class="w-9 h-9 rounded-full bg-white/10 hover:bg-white/20 active:scale-95 flex items-center justify-center transition" type="button">
<i class="ph ph-arrow-left text-xl text-white"></i>
</button>
<h1 class="text-lg font-bold tracking-tight">Akun Saya</h1>
<div class="flex items-center space-x-2">
<button aria-label="Notifikasi" class="w-9 h-9 rounded-full bg-white/10 hover:bg-white/20 active:scale-95 flex items-center justify-center transition relative" type="button">
<i class="ph ph-bell text-xl text-white"></i>
<span class="absolute top-2 right-2 w-2 h-2 bg-accent-yellow rounded-full ring-2 ring-brand-700"></span>
</button>
</div>
</div>
</header>
<!-- END: TopHeader -->
<!-- BEGIN: MainContent -->
<main class="px-4 -mt-11 space-y-4 flex-1">
<!-- BEGIN: UserProfileCard -->
<section class="bg-white rounded-2xl p-4 shadow-card border border-gray-100 flex items-center justify-between relative overflow-hidden" data-purpose="user-profile-card">
<div class="flex items-center space-x-3.5">
<!-- Profile Avatar with Badge -->
<div class="relative">
<div class="w-16 h-16 rounded-full overflow-hidden ring-2 ring-brand-100 shadow-inner bg-gray-100">
<img alt="Foto Profil Ilham Ramdhani" class="w-full h-full object-cover" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCXgoB01mrP3m8Y2e6giDhFpYX0XJErDt7lE7TXpi35rL_W2VWxf3BCG3F-vcx4bi4UyqAJcvmNBlcqp1ztti7ySuOdZFx3-zh5eq2AhqSUc6LdDJlfjaC5eDygE6Xn-BPNdBvUjEYxPyyZLogmshLDonqnylO5lC8kQ-43ypbZQGbbxdLpDlG82jM76BfBnE4VePk9ti9KOrCiz9xiu1F0CG1XN6yv9KoBokYmcnoMWQ7aeVtgOmw">
</div>
<button aria-label="Ubah foto profil" class="absolute -bottom-1 -right-1 bg-brand-600 text-white w-6 h-6 rounded-full flex items-center justify-center shadow-md active:scale-90 transition" type="button">
<i class="ph-bold ph-camera text-xs"></i>
</button>
</div>
<!-- User Details -->
<div>
<div class="flex items-center gap-1.5">
<h2 class="font-bold text-gray-900 text-base leading-tight">Ilham Ramdhani</h2>
<span class="bg-emerald-50 text-emerald-700 text-[10px] font-semibold px-1.5 py-0.5 rounded-full border border-emerald-200">Verified</span>
</div>
<p class="text-xs text-gray-500 mt-0.5">ramdhaniit@gmail.com</p>
<div class="flex items-center gap-2 mt-1.5">
<span class="inline-flex items-center text-[11px] font-medium text-gray-600 bg-gray-100 px-2 py-0.5 rounded-md">
<i class="ph ph-phone mr-1 text-gray-400"></i>+62 896-3742-8874
</span>
</div>
</div>
</div>
<!-- Edit Profile Action Button -->
<button aria-label="Ubah data profil" class="flex flex-col items-center justify-center p-2 rounded-xl text-brand-600 hover:bg-brand-50 active:scale-95 transition" type="button">
<i class="ph-bold ph-pencil-simple text-lg"></i>
<span class="text-[11px] font-semibold mt-0.5">Ubah</span>
</button>
</section>
<!-- END: UserProfileCard -->
<!-- BEGIN: PreferencesMenu -->
<section class="bg-white rounded-2xl p-2 shadow-card border border-gray-100" data-purpose="preferences-menu-group">
<div class="px-3 py-2 border-b border-gray-50">
<h4 class="text-xs font-bold text-gray-400 uppercase tracking-wider">Preferensi Akun</h4>
</div>
<nav class="divide-y divide-gray-50 text-sm">
<!-- Item: Alamat Pengiriman Tersimpan -->
<a class="flex items-center justify-between p-3 hover:bg-gray-50 rounded-xl transition group" href="#">
<div class="flex items-center space-x-3">
<span class="w-8 h-8 rounded-lg bg-red-50 text-brand-600 flex items-center justify-center group-hover:bg-brand-600 group-hover:text-white transition">
<i class="ph ph-map-pin text-lg"></i>
</span>
<div>
<p class="font-medium text-gray-900">Alamat Pengiriman</p>
<p class="text-[11px] text-gray-400">Kelola daftar alamat tersimpan</p>
</div>
</div>
<i class="ph ph-caret-right text-gray-400"></i>
</a>
<!-- Item: Notifikasi Aplikasi -->
<a class="flex items-center justify-between p-3 hover:bg-gray-50 rounded-xl transition group" href="#">
<div class="flex items-center space-x-3">
<span class="w-8 h-8 rounded-lg bg-gray-100 text-gray-700 flex items-center justify-center group-hover:bg-brand-600 group-hover:text-white transition">
<i class="ph ph-bell-simple text-lg"></i>
</span>
<div>
<p class="font-medium text-gray-900">Notifikasi Aplikasi</p>
<p class="text-[11px] text-gray-400">Promo, pesanan, dan pembaruan</p>
</div>
</div>
<i class="ph ph-caret-right text-gray-400"></i>
</a>
</nav>
</section>
<!-- END: PreferencesMenu -->
<!-- BEGIN: SettingsAndSecurityMenu -->
<section class="bg-white rounded-2xl p-2 shadow-card border border-gray-100" data-purpose="settings-menu-group">
<div class="px-3 py-2 border-b border-gray-50">
<h4 class="text-xs font-bold text-gray-400 uppercase tracking-wider">Pengaturan &amp; Keamanan Akun</h4>
</div>
<nav class="divide-y divide-gray-50 text-sm">
<!-- Item: Data Diri -->
<a class="flex items-center justify-between p-3 hover:bg-gray-50 rounded-xl transition group" href="#"><div class="flex items-center space-x-3"><span class="w-8 h-8 rounded-lg bg-gray-100 text-gray-700 flex items-center justify-center group-hover:bg-brand-600 group-hover:text-white transition"><i class="ph ph-user text-lg"></i></span><div><p class="font-medium text-gray-900">Data Diri / Ubah Profil</p><p class="text-[11px] text-gray-400">Nama, email, username &amp; keamanan</p></div></div><i class="ph ph-caret-right text-gray-400"></i></a>
<!-- Item: Ganti Username -->

<!-- Item: Ganti Password & PIN -->

<!-- Item: Keamanan Biometrik -->
<a class="flex items-center justify-between p-3 hover:bg-gray-50 rounded-xl transition group" href="#">
<div class="flex items-center space-x-3">
<span class="w-8 h-8 rounded-lg bg-gray-100 text-gray-700 flex items-center justify-center group-hover:bg-brand-600 group-hover:text-white transition">
<i class="ph ph-fingerprint text-lg"></i>
</span>
<div class="flex items-center gap-2">
<span class="font-medium text-gray-900">Keamanan Biometrik</span>
<span class="text-[10px] bg-emerald-50 text-emerald-700 font-semibold px-1.5 py-0.5 rounded border border-emerald-200">Aktif</span>
</div>
</div>
<i class="ph ph-caret-right text-gray-400"></i>
</a>
<!-- Item: Log Out -->
<a class="flex items-center justify-between p-3 hover:bg-red-50/50 rounded-xl transition group" href="#">
<div class="flex items-center space-x-3">
<span class="w-8 h-8 rounded-lg bg-red-50 text-red-600 flex items-center justify-center group-hover:bg-red-600 group-hover:text-white transition">
<i class="ph ph-sign-out text-lg"></i>
</span>
<span class="font-medium text-red-600">Keluar dari Akun</span>
</div>
<i class="ph ph-caret-right text-red-300"></i>
</a>
</nav>
</section>
<!-- END: SettingsAndSecurityMenu -->
<!-- BEGIN: SupportAndInfoMenu -->
<section class="bg-white rounded-2xl p-2 shadow-card border border-gray-100" data-purpose="support-info-group">
<div class="px-3 py-2 border-b border-gray-50">
<h4 class="text-xs font-bold text-gray-400 uppercase tracking-wider">Pusat Informasi &amp; Bantuan</h4>
</div>
<nav class="divide-y divide-gray-50 text-sm">
<!-- Item: Tentang Ekatunggal -->
<a class="flex items-center justify-between p-3 hover:bg-gray-50 rounded-xl transition group" href="#">
<div class="flex items-center space-x-3">
<div class="w-8 h-8 rounded-lg bg-brand-50 flex items-center justify-center overflow-hidden border border-brand-200">
<span class="text-[10px] font-black text-brand-700 tracking-tighter">ETM</span>
</div>
<span class="font-medium text-gray-900">Tentang Ekatunggal</span>
</div>
<i class="ph ph-caret-right text-gray-400"></i>
</a>
<!-- Item: Tanya Vika CS -->
<a class="flex items-center justify-between p-3 hover:bg-emerald-50/40 rounded-xl transition group" href="#">
<div class="flex items-center space-x-3">
<div class="w-8 h-8 rounded-lg bg-emerald-100 text-emerald-700 flex items-center justify-center">
<i class="ph-fill ph-whatsapp-logo text-xl"></i>
</div>
<div>
<p class="font-medium text-gray-900 flex items-center gap-1.5">
                  Tanya Vika
                  <span class="text-[10px] bg-emerald-100 text-emerald-800 font-semibold px-1.5 py-0.2 rounded">CS Online</span>
</p>
<p class="text-[11px] text-gray-400">Bantuan cepat via WhatsApp 24/7</p>
</div>
</div>
<i class="ph ph-caret-right text-gray-400"></i>
</a>
<!-- Item: FAQ -->
<a class="flex items-center justify-between p-3 hover:bg-gray-50 rounded-xl transition group" href="#">
<div class="flex items-center space-x-3">
<span class="w-8 h-8 rounded-lg bg-gray-100 text-gray-700 flex items-center justify-center group-hover:bg-gray-200 transition">
<i class="ph ph-question text-lg"></i>
</span>
<span class="font-medium text-gray-900">Pertanyaan Umum (FAQ)</span>
</div>
<i class="ph ph-caret-right text-gray-400"></i>
</a>
<!-- Item: Syarat Kebijakan -->
<a class="flex items-center justify-between p-3 hover:bg-gray-50 rounded-xl transition group" href="#">
<div class="flex items-center space-x-3">
<span class="w-8 h-8 rounded-lg bg-gray-100 text-gray-700 flex items-center justify-center group-hover:bg-gray-200 transition">
<i class="ph ph-shield-check text-lg"></i>
</span>
<span class="font-medium text-gray-900">Syarat &amp; Kebijakan Privasi</span>
</div>
<i class="ph ph-caret-right text-gray-400"></i>
</a>
</nav>
</section>
<!-- END: SupportAndInfoMenu -->
<!-- BEGIN: VersionFooter -->
<footer class="text-center py-3">
<p class="text-xs text-gray-400 font-medium">Ekatunggal Mobile App</p>
<p class="text-[10px] text-gray-300">Versi 2.4.1 (Build 1204)</p>
</footer>
<!-- END: VersionFooter -->
</main>
<!-- END: MainContent -->
<!-- BEGIN: FloatingMenuTrigger -->
<div class="fixed bottom-20 right-4 z-20">
<button aria-label="Buka Menu Akses Cepat" class="w-12 h-12 bg-gray-800/80 backdrop-blur-md text-white rounded-2xl shadow-elevated flex items-center justify-center hover:bg-gray-900 active:scale-95 transition border border-white/20" type="button">
<i class="ph-bold ph-squares-four text-2xl"></i>
</button>
</div>
<!-- END: FloatingMenuTrigger -->
<!-- BEGIN: BottomNavigationBar -->
<nav class="fixed bottom-0 left-0 right-0 max-w-md mx-auto bg-white border-t border-gray-200/80 px-2 py-2 flex items-center justify-around z-30 shadow-lg">
<!-- Nav Item: Beranda -->
<a class="flex flex-col items-center justify-center w-14 py-1 text-gray-400 hover:text-gray-600 transition" href="#">
<i class="ph ph-house text-xl"></i>
<span class="text-[10px] mt-1 font-medium">Beranda</span>
</a>
<!-- Nav Item: Kategori -->
<a class="flex flex-col items-center justify-center w-14 py-1 text-gray-400 hover:text-gray-600 transition" href="#">
<i class="ph ph-squares-four text-xl"></i>
<span class="text-[10px] mt-1 font-medium">Kategori</span>
</a>
<!-- Nav Item: Customer (Company / Branch hub) -->
<a class="flex flex-col items-center justify-center w-14 py-1 text-gray-400 hover:text-gray-600 transition" href="#">
<i class="ph ph-buildings text-xl"></i>
<span class="text-[10px] mt-1 font-medium">Customer</span>
</a>
<!-- Nav Item: Transaksi -->
<a class="flex flex-col items-center justify-center w-14 py-1 text-gray-400 hover:text-gray-600 transition" href="#">
<i class="ph ph-receipt text-xl"></i>
<span class="text-[10px] mt-1 font-medium">Transaksi</span>
</a>
<!-- Nav Item: Akun (Active) -->
<a class="flex flex-col items-center justify-center w-14 py-1 text-brand-600 font-bold transition" href="#">
<i class="ph-fill ph-user text-xl"></i>
<span class="text-[10px] mt-1 font-semibold">Akun</span>
</a>
</nav>
<!-- END: BottomNavigationBar -->
</div>
<!-- END: MobileDeviceFrame -->

</body></html>
