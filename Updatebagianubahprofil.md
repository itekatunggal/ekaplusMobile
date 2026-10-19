<!DOCTYPE html>

<html lang="id"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" name="viewport"/>
<title>Ubah Profil - Ekatunggal Mobile</title>
<!-- Tailwind CSS CDN -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            brand: {
              red: '#D92525',
              darkRed: '#B81E1E',
              yellow: '#F59E0B',
              bg: '#F8FAFC',
              card: '#FFFFFF',
              textPrimary: '#1E293B',
              textSecondary: '#64748B',
              border: '#E2E8F0',
            }
          },
          fontFamily: {
            sans: ['Inter', 'system-ui', '-apple-system', 'Segoe UI', 'Roboto', 'sans-serif'],
          }
        }
      }
    }
  </script>
<style data-purpose="custom-styling">
    /* Custom shadow and smooth input transitions */
    .card-shadow {
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.04), 0 1px 3px rgba(0, 0, 0, 0.02);
    }
    input:focus {
      outline: none;
      border-color: #D92525;
      box-shadow: 0 0 0 3px rgba(217, 37, 37, 0.1);
    }
  </style>
</head>
<body class="bg-[#F6F7F9] text-brand-textPrimary font-sans antialiased min-h-screen flex justify-center selection:bg-red-100 selection:text-brand-red">
<!-- Mobile Viewport Container -->
<div class="w-full max-w-md bg-[#F6F7F9] min-h-screen flex flex-col relative pb-28 shadow-xl">
<!-- BEGIN: Header -->
<header class="bg-brand-red text-white sticky top-0 z-30 px-4 pt-10 pb-5 rounded-b-[28px] shadow-md flex items-center justify-between" data-purpose="app-header">
<!-- Tombol Kembali -->
<button aria-label="Kembali" class="w-10 h-10 rounded-full bg-white/15 active:bg-white/30 flex items-center justify-center transition-colors" type="button">
<svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" stroke-width="2.5" viewbox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<path d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>
</button>
<!-- Judul Halaman -->
<h1 class="text-lg font-bold tracking-tight text-white">Ubah Profil</h1>
<!-- Aksi Bantuan / Info -->
<button aria-label="Pusat Bantuan" class="w-10 h-10 rounded-full bg-white/15 active:bg-white/30 flex items-center justify-center transition-colors" type="button">
<svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" stroke-width="2" viewbox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<path d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9 5.25h.008v.008H12v-.008z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>
</button>
</header>
<!-- END: Header -->
<!-- BEGIN: MainContent -->
<main class="flex-1 px-4 pt-5 space-y-5" data-purpose="main-profile-form">
<!-- BEGIN: AvatarSection -->
<section class="flex flex-col items-center justify-center pt-2 pb-1" data-purpose="user-avatar-upload">
<div class="relative group">
<!-- Foto Profil (Memakai placeholder avatar resmi sesuai UI referensi) -->
<div class="w-24 h-24 rounded-full overflow-hidden border-4 border-white shadow-md bg-gray-200">
<img alt="Foto Profil Ilham Ramdhani" class="w-full h-full object-cover" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBDPYFsWc4ttPVj8Mfo1RHbuddtUf0L0G0EK7OGIMI0UcAPFmfyLiVEzUjI-MZPrf0qOVkppk2A6zJBh07tdEa6GkgfydJJ0c-lxGaLymzs2AKZ1HAn5GVqFMHc3uWYrq4KpxEu6hfjDXGJXl73joKkhZn9zhZHx-h4n3i-1vHw3Jzg6Ejv5Gw8Kzkigw_vmICWiLhftHDgJVT41WXS2HFC2Ez-dquI3X13GcdoDHHbU3cVnEYoHr8"/>
</div>
<!-- Tombol Kamera (Badge Ubah Foto) -->
<button aria-label="Ubah Foto Profil" class="absolute bottom-0 right-0 w-8 h-8 rounded-full bg-brand-red text-white flex items-center justify-center border-2 border-white shadow hover:bg-brand-darkRed active:scale-95 transition-all" type="button">
<svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewbox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<path d="M6.827 6.175A2.31 2.31 0 015.186 7.23c-.38.054-.757.112-1.134.175C2.999 7.58 2.25 8.507 2.25 9.574V18a2.25 2.25 0 002.25 2.25h15A2.25 2.25 0 0021.75 18V9.574c0-1.067-.75-1.994-1.802-2.169a47.865 47.865 0 00-1.134-.175 2.31 2.31 0 01-1.64-1.055l-.822-1.316a2.192 2.192 0 00-1.736-1.039 48.774 48.774 0 00-5.232 0 2.192 2.192 0 00-1.736 1.039l-.821 1.316z" stroke-linecap="round" stroke-linejoin="round"></path>
<path d="M16.5 12.75a4.5 4.5 0 11-9 0 4.5 4.5 0 019 0zM18.75 10.5h.008v.008h-.008V10.5z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>
</button>
</div>
<p class="text-xs font-semibold text-brand-red mt-2.5 cursor-pointer hover:underline">Ubah Foto Profil</p>
</section>
<!-- END: AvatarSection -->
<!-- BEGIN: PersonalInformationSection -->
<section class="bg-white rounded-2xl p-4 card-shadow border border-slate-100" data-purpose="personal-details-form">
<h2 class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-4">Informasi Akun Personal</h2>
<div class="space-y-4">
<!-- Input: Nama Lengkap -->
<div>
<label class="block text-xs font-medium text-slate-500 mb-1.5" for="full-name">Nama Lengkap</label>
<div class="relative">
<input class="w-full text-sm font-semibold text-brand-textPrimary bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 focus:bg-white transition-colors" id="full-name" name="fullName" placeholder="Masukkan nama lengkap" type="text" value="Ilham Ramdhani"/>
</div>
</div>
<!-- Input: Nomor Handphone -->
<div>
<div class="flex items-center justify-between mb-1.5">
<label class="text-xs font-medium text-slate-500" for="phone-number">Nomor Handphone</label>
<span class="inline-flex items-center gap-1 text-[11px] font-semibold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
<svg class="w-3 h-3" fill="currentColor" viewbox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
<path clip-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" fill-rule="evenodd"></path>
</svg>
                Terverifikasi
              </span>
</div>
<div class="relative flex items-center">
<input class="w-full text-sm font-semibold text-brand-textPrimary bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 pr-16 focus:bg-white transition-colors" id="phone-number" name="phoneNumber" type="tel" value="+62 896-3742-8874"/>
<button class="absolute right-3 text-xs font-semibold text-brand-red hover:underline" type="button">
                Ubah
              </button>
</div>
</div>
<!-- Input: Alamat Email -->
<div>
<div class="flex items-center justify-between mb-1.5">
<label class="text-xs font-medium text-slate-500" for="email-address">Email</label>
<span class="inline-flex items-center gap-1 text-[11px] font-semibold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
<svg class="w-3 h-3" fill="currentColor" viewbox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
<path clip-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" fill-rule="evenodd"></path>
</svg>
                Terverifikasi
              </span>
</div>
<div class="relative flex items-center">
<input class="w-full text-sm font-semibold text-brand-textPrimary bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 pr-16 focus:bg-white transition-colors" id="email-address" name="emailAddress" type="email" value="ramdhaniit@gmail.com"/>
<button class="absolute right-3 text-xs font-semibold text-brand-red hover:underline" type="button">
                Ubah
              </button>
</div>
</div>
</div>
</section>
<!-- END: PersonalInformationSection -->
<!-- BEGIN: SecuritySettingsSection -->
<section class="bg-white rounded-2xl p-4 card-shadow border border-slate-100" data-purpose="security-settings">
<h2 class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-3">Pengaturan Akun &amp; Keamanan</h2>
<div class="divide-y divide-slate-100">
<!-- Username Option -->
<div class="py-3 flex items-center justify-between">
<div class="flex items-center gap-3">
<div class="w-9 h-9 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
<svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewbox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<path d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>
</div>
<div>
<p class="text-xs text-slate-500">Username</p>
<p class="text-sm font-semibold text-slate-800">@ilhamramdhani</p>
</div>
</div>
<button class="text-xs font-semibold text-brand-red px-2.5 py-1 rounded-lg border border-red-200 hover:bg-red-50 transition-colors" type="button">
              Ubah
            </button>
</div>
<!-- Ganti Kata Sandi -->
<a class="py-3 flex items-center justify-between group active:bg-slate-50 transition-colors rounded-lg px-1" href="#ganti-sandi">
<div class="flex items-center gap-3">
<div class="w-9 h-9 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
<svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewbox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<path d="M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H6.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>
</div>
<div>
<p class="text-sm font-medium text-slate-800">Ganti Kata Sandi</p>
<p class="text-xs text-slate-400">Terakhir diubah 3 bulan lalu</p>
</div>
</div>
<svg class="w-4 h-4 text-slate-400 group-hover:translate-x-0.5 transition-transform" fill="none" stroke="currentColor" stroke-width="2" viewbox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<path d="M8.25 4.5l7.5 7.5-7.5 7.5" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>
</a>
<!-- Ganti PIN Transaksi -->
<a class="py-3 flex items-center justify-between group active:bg-slate-50 transition-colors rounded-lg px-1" href="#ganti-pin">
<div class="flex items-center gap-3">
<div class="w-9 h-9 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center">
<svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewbox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<path d="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>
</div>
<div>
<p class="text-sm font-medium text-slate-800">PIN Transaksi</p>
<p class="text-xs text-slate-400">Keamanan pembayaran &amp; persetujuan</p>
</div>
</div>
<div class="flex items-center gap-1.5">
<span class="text-[11px] font-semibold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">Aktif</span>
<svg class="w-4 h-4 text-slate-400 group-hover:translate-x-0.5 transition-transform" fill="none" stroke="currentColor" stroke-width="2" viewbox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<path d="M8.25 4.5l7.5 7.5-7.5 7.5" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>
</div>
</a>
</div>
</section>
<!-- END: SecuritySettingsSection -->
<!-- Informasi Tambahan Keamanan -->
<div class="flex items-start gap-2.5 px-2 text-slate-400">
<svg class="w-4 h-4 mt-0.5 text-slate-400 flex-shrink-0" fill="none" stroke="currentColor" stroke-width="2" viewbox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<path d="M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>
<p class="text-xs leading-relaxed">
          Pastikan data profil Anda selalu valid untuk mempermudah proses verifikasi pengiriman pesanan dan transaksi Ekatunggal.
        </p>
</div>
</main>
<!-- END: MainContent -->
<!-- BEGIN: BottomStickyAction -->
<footer class="fixed bottom-0 left-0 right-0 max-w-md mx-auto bg-white/95 backdrop-blur-sm border-t border-slate-200 px-4 py-3.5 z-40" data-purpose="submit-profile-changes">
<button class="w-full bg-brand-red active:bg-brand-darkRed text-white font-semibold py-3.5 px-4 rounded-xl shadow-lg shadow-red-500/25 transition-all text-sm flex items-center justify-center gap-2 hover:opacity-95" type="button">
<svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2.5" viewbox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<path d="M4.5 12.75l6 6 9-13.5" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>
        Simpan Perubahan
      </button>
</footer>
<!-- END: BottomStickyAction -->
</div>
</body></html>
