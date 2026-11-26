# PawonTani Mobile — Dokumentasi Pengembangan

Aplikasi mobile Flutter untuk ekosistem pertanian **PawonTani**. Digunakan oleh anggota kelompok tani untuk mengelola petak lahan garapan, siklus tanam, pencatatan aktivitas budidaya, verifikasi panen, dan transaksi hasil tani.

---

## Dokumentasi Akumulasi Update: Fitur Siklus Tanam (November 2026)

Dokumentasi ini merangkum seluruh akumulasi pengembangan dan penyempurnaan fitur **Siklus Tanam PawonTani Mobile** sejak implementasi awal hingga update validasi terakhir (F-01, F-02, F-04).

### 1. Tujuan Perubahan
Mewujudkan alur siklus tanam yang terstruktur, transparan, dan terintegrasi antara anggota petani dan pengurus kelompok tani:
1. **Single Source of Truth:** Seluruh status masa tanam petak lahan mengacu langsung pada siklus tanam berjalan (`ItemSiklusTanam`), menggantikan data operasional legacy yang terfragmentasi.
2. **Keterikatan Data Budidaya:** Pencatatan aktivitas tanam dan hasil panen wajib terikat secara sah pada siklus tanam aktif (`id_siklus`), mencegah pencatatan liar pada lahan yang sedang beristirahat.
3. **Pengakhiran dan Pertanggungjawaban:** Mendukung alur pengakhiran siklus berhasil (*Selesai*), pelaporan puso (*Gagal*), maupun pembatalan siklus awal (*Dibatalkan*), lengkap dengan validasi persyaratan dan audit trail persetujuan pengurus.

---

### 2. Rincian Pembaruan Fitur

#### A. Integrasi Siklus Tanam & Detail Lahan
- **Status Operasional Lahan:** Pemisahan status lahan menjadi `aktif` (sedang ada siklus berjalan), `persiapan` (olah tanah/pembibitan), dan `istirahat` (pasca panen / jeda tanam).
- **Filter Petak Lahan (F-06):** Pada daftar lahan garapan, pengguna dapat memfilter petak berdasarkan status: *Semua*, *Aktif Ditanami*, *Dalam Persiapan*, dan *Masa Istirahat*.
- **Informasi Siklus Aktif:** Detail lahan menampilkan komoditas, varietas, musim tanam, estimasi panen, target panen, dan realisasi hasil panen yang telah disetujui.
- **Riwayat Siklus Tanam (P0 & F-03):** Riwayat siklus masa lalu kini tersimpan dan dapat dilihat langsung pada tab Riwayat di halaman Detail Lahan.

#### B. Mulai Siklus Tanam & Standarisasi Komoditas (F-04)
- **Validasi Lahan Terverifikasi:** Tombol *Mulai Siklus* hanya dapat dijalankan pada lahan yang telah disetujui oleh Pengurus.
- **Pilihan Komoditas Terstandarisasi:** Dropdown komoditas terintegrasi dengan endpoint resmi master data `GET /api/v1/komoditas`, selaras dengan Form Artikel Web PPL:
  - 🌾 **Tanaman Pangan** (Padi Sawah, Padi Gogo, Jagung, Kedelai, Kacang Tanah, Kacang Hijau, Singkong, Ubi Jalar)
  - 🌶️ **Hortikultura & Sayuran** (Cabai Rawit, Cabai Merah, Bawang Merah, Bawang Putih, Tomat, Terong, Bayam, Kangkung, dll.)
  - 🍉 **Buah-buahan** (Melon, Semangka, Pisang, Pepaya, Jeruk, Mangga, Alpukat, Durian, Nanas, Jambu Kristal)
  - ☕ **Perkebunan & Rempah** (Kopi, Kakao, Kelapa, Cengkeh, Lada, Jahe, Kunyit, Lengkuas, Serai)
- **Tampilan Kategori:** Pilihan komoditas dikelompokkan dengan ikon kategori dan badge yang jelas serta responsif di layar mobile.

#### C. Pengelolaan & Pengakhiran Siklus Tanam (F-01 & F-02)
- **Opsi Pengakhiran Siklus (F-02):** Modal bottom sheet didesain ulang dengan `isScrollControlled: true` dan `SingleChildScrollView` di dalam `SafeArea`, melenyapkan error *RenderFlex overflow 18 pixels*.
- **Tiga Jalur Pengakhiran:**
  1. **Akhiri Siklus Panen (Selesai):** Untuk siklus yang telah berhasil dipanen.
  2. **Laporkan Kegagalan Panen (Gagal):** Untuk tanaman puso/rusak (wajib unggah foto bukti kegagalan).
  3. **Batalkan Siklus Tanam:** Jika terjadi salah input dan belum ada aktivitas atau panen yang dicatat.
- **Feedback Jelas Tanpa Panen (F-01):**
  - Dilengkapi *pre-check validation*: jika siklus belum memiliki panen, sistem langsung menampilkan dialog penjelasan ramah petani:
    > **Siklus Belum Dapat Diakhiri**  
    > *Siklus tanam belum memiliki data panen. Tambahkan data panen terlebih dahulu sebelum mengajukan pengakhiran siklus selesai.*
  - Jika terdapat panen yang masih berstatus menunggu verifikasi pengurus:
    > **Siklus Belum Dapat Diakhiri**  
    > *Pengakhiran siklus belum dapat diajukan karena masih terdapat hasil panen yang menunggu verifikasi atau belum disetujui Pengurus.*
  - Ditambahkan banner error merah lokal di dalam modal sheet jika backend mengembalikan penolakan.

#### D. Keterikatan Modul Aktivitas & Panen
- **Pencatatan Aktivitas:** Otomatis membawa `id_siklus` dari siklus aktif. Petani dicegah mencatat aktivitas jika lahan tidak memiliki siklus aktif.
- **Pencatatan Panen:** Otomatis terikat dengan siklus aktif. Menampilkan informasi komoditas, varietas, dan musim tanam siklus berjalan.
- **Dukungan Data Legacy:** Aktivitas dan panen lama tanpa `id_siklus` tetap tampil aman tanpa menyebabkan crash aplikasi (`isLegacy = true`).

#### E. Modul Notifikasi Siklus Tanam
- **Pusat Notifikasi Anggota:** Menerima pemberitahuan persetujuan atau penolakan pengakhiran siklus dari Pengurus Kelompok Tani.
- **Badge Dinamis Beranda:** Ikon lonceng di beranda menampilkan badge jumlah notifikasi yang belum dibaca secara reaktif (`NotifikasiRepository`).
- **Format Waktu Relatif:** Menggunakan `WaktuRelatifUtil` ("Baru saja", "15 mnt lalu", "Kemarin").

---

### 3. Pengujian & Verifikasi

- **Flutter Analyze:** `flutter analyze` pada target file `layar_detail_lahan.dart` dan paket `lib/` bebas dari error kompilasi (**0 errors**).
- **Rangkaian Test Otomatis (44 Tests PASS):**
  - `test/features/aktivitas/aktivitas_siklus_test.dart` (4 tests)
  - `test/features/lahan/siklus_pengakhiran_test.dart` (2 tests)
  - `test/features/lahan/siklus_tanam_model_test.dart` (2 tests)
  - `test/features/panen/panen_siklus_test.dart` (7 tests)
  - `test/features/notifikasi/notifikasi_test.dart` (19 tests)
  - `test/lahan_api_service_test.dart` (10 tests)
- **Pengujian Manual:** Seluruh skenario alur mulai siklus, pencatatan budidaya, opsi pengakhiran selesai/gagal/batal, dan validasi feedback telah dikonfirmasi berfungsi normal.

---

### 4. Batasan Scope
- Pembaruan ini **100% berada pada sisi Flutter Mobile** (`PawonTaniMobile`).
- Tidak mengubah Web Backend Laravel, skema database PostgreSQL/Supabase, maupun endpoint backend yang telah berjalan.
