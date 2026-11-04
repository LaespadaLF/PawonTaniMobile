# AGENTS.md - Panduan Lengkap Proyek PawonTani Mobile (Flutter)

Dokumen ini adalah pedoman utama untuk **Hermes AI** saat bekerja di repositori `PawonTaniMobile`.

---

## 1. Identitas & Gambaran Proyek
- **Nama Aplikasi**: `pawon_mobile` (PawonTani Mobile)
- **Framework**: Flutter (Dart SDK `^3.13.1`)
- **Dependensi Utama**: `dio` (HTTP Client), `flutter_secure_storage` (token storage), `google_fonts`, `cupertino_icons`.
- **Tujuan**: Aplikasi mobile bagi petani dan anggota kelompok tani untuk memantau ringkasan pertanian, mencatat panen, mengelola lahan, mencatat aktivitas harian, dan mencatat transaksi penjualan.
- **Backend Pasangan**: Laravel 13 di `c:\laragon\www\PawonTani` (PostgreSQL Supabase).

---

## 2. Struktur Arsitektur Kode (`lib/`)

Proyek ini mengadopsi **Feature-First Architecture**:

### A. Root & Navigasi Utama
- `lib/main.dart`:
  - Entry point aplikasi.
  - Mengatur `MainNavigationShell` menggunakan `IndexedStack` dengan **5 Tab Navigasi**:
    1. **Tab 0: Beranda** (`HomeScreen` di `features/beranda/screens/layar_beranda.dart`)
    2. **Tab 1: Lahan** (`LahanScreen` di `features/lahan/screens/layar_lahan.dart`)
    3. **Tab 2: Aktivitas** (`AktivitasScreen` di `features/aktivitas/screens/layar_aktivitas.dart`)
    4. **Tab 3: Panen** (`PanenScreen` di `features/panen/screens/layar_panen.dart`)
    5. **Tab 4: Penjualan** (`PenjualanScreen` di `features/penjualan/screens/layar_penjualan.dart`)

### B. Core Framework (`lib/core/`)
- `lib/core/theme/warna_aplikasi.dart`:
  - Tema warna resmi PawonTani:
    - Primary: `Color(0xFF285438)`
    - Primary Dark: `Color(0xFF142419)`
    - Primary Light: `Color(0xFF3B6B4F)`
    - Primary Background: `Color(0xFFF9FAF9)`
    - Green Light: `Color(0xFFE8F4EC)`
- `lib/core/widgets/navigasi_bawah_pawon.dart`:
  - Komponen `PawonBottomNav` dengan 5 ikon navigasi.
- `lib/core/widgets/dialog_sukses_simpan.dart`: Dialog feedback simpan data.
- `lib/core/widgets/ikon_tanaman_kustom.dart`: Komponen visual aset tanaman.

### C. Fitur Beranda (`lib/features/beranda/`)
- `screens/layar_beranda.dart`:
  - `_buildTopHeader`: Sapaan ("Selamat pagi, Pak Joko 👋"), notifikasi, profil.
  - `FarmerBannerCard` (`widgets/kartu_banner_petani.dart`): Banner semangat bertani + widget cuaca ("28°C Cerah Berawan, Sukamaju").
  - `HomeFarmSummarySection` (`widgets/kartu_statistik_beranda.dart`): Grid statistik 2x2 (3 Lahan Aktif, 2 Komoditas, 4,2 Ton Panen, Rp28,5 jt Penjualan) + Status Kondisi Pertanian Aman.
  - `HomeQuickActionsSection` (`widgets/aksi_cepat_beranda.dart`): Tombol aksi instan.
  - `widgets/bagian_panen_terbaru_beranda.dart`, `widgets/bagian_artikel_beranda.dart`, `widgets/kartu_kemitraan.dart`.

### D. Fitur Panen (`lib/features/panen/`)
- **Model** (`models/item_panen.dart`):
  - Model `HarvestItem`: `id`, `harvestCode`, `title`, `cropType`, `status` (`HarvestStatus.menunggu`, `disetujui`, `ditolak`), `location`, `blockArea`, `date`, `harvestTime`, `season`, `poktan`, `weightKg`, `qualityGrade`, `moisturePercent`, `pricePerKg`, `fieldNotes`, dll.
- **Layar** (`screens/`):
  - `layar_panen.dart`: Daftar riwayat panen dan tab filter.
  - `layar_catat_panen.dart`: Formulir pencatatan panen baru.
  - `layar_detail_panen.dart`: Rincian lengkap hasil panen dan status verifikasi.
  - `layar_edit_panen.dart`: Form edit data panen.
- **Widgets** (`widgets/`):
  - `kartu_panen.dart`, `kartu_ringkasan_panen.dart`, `modal_tambah_panen.dart`, `dialog_hapus_panen.dart`.

### E. Fitur Lahan (`lib/features/lahan/`)
- `models/item_lahan.dart`: Model entitas lahan petani.
- `screens/layar_lahan.dart`: Daftar lahan.
- `screens/layar_tambah_lahan.dart`: Formulir tambah lahan baru.
- `screens/layar_detail_lahan.dart`, `screens/layar_edit_lahan.dart`.

### F. Fitur Aktivitas & Penjualan
- `lib/features/aktivitas/`: `models/item_aktivitas_tanam.dart`, `layar_aktivitas.dart`, `layar_catat_aktivitas.dart`.
- `lib/features/penjualan/`: `models/item_penjualan.dart`, `layar_penjualan.dart`, `layar_catat_penjualan.dart`.

---

## 3. Integrasi API Backend Laravel
- **Lokasi Backend**: `c:\laragon\www\PawonTani`
- **Base URL API**:
  - Android Emulator: `http://10.0.2.2:8000/api`
  - Perangkat Fisik (Wi-Fi): `http://192.168.x.x:8000/api`
  - Flutter Web: `http://localhost:8000/api`
- **Konvensi**:
  - Gunakan `dio` untuk HTTP request.
  - Simpan auth token JWT/Sanctum di `flutter_secure_storage`.
  - Format respon JSON dari Laravel dipetakan langsung ke model Dart di masing-masing folder fitur.

---

## 4. Gaya & Standar Koding
- Ikuti standar Flutter/Dart resmi (`flutter_lints`).
- Komposisi UI berbasis widget modular yang dapat digunakan kembali (*reusable*).
- Gunakan Bahasa Indonesia yang ramah, santun, dan komunikatif untuk copy UI dan pesan feedback kepada petani.

