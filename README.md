# RuangPulih - Platform Kesehatan Mental & Jurnal Harian AI

RuangPulih adalah platform kesehatan mental modern yang dirancang untuk membantu pengguna mengelola kesejahteraan emosional mereka. Aplikasi ini mengintegrasikan kecerdasan buatan (AI) untuk memberikan layanan konseling interaktif, pelacakan suasana hati (mood tracker), pencatatan jurnal harian, pemantauan kebiasaan (habit tracker), serta forum komunitas dan konsultasi dengan dokter.

Aplikasi ini dibagi menjadi dua bagian utama:
1. **Backend**: Web API service berbasis **NestJS** (TypeScript) dengan integrasi basis data **PostgreSQL** dan **Google Gemini AI API**.
2. **Frontend**: Aplikasi mobile & multiplatform berbasis **Flutter** (Dart).

---

## 🏗️ Arsitektur & Teknologi Utama

- **Frontend**: Flutter SDK (Dart)
  - State Management & HTTP Requests
  - SharedPreferences untuk sesi login (Token-based Auth)
  - Desain UI responsif untuk Android, iOS, Web, dan Desktop
- **Backend**: NestJS (TypeScript, Node.js)
  - TypeORM dengan database driver PostgreSQL (`pg`)
  - Passport JWT untuk keamanan endpoints
  - Integrasi dengan Google Gemini AI API (`@google/generative-ai`)
- **Database**: PostgreSQL (dapat menggunakan VPS, lokal PostgreSQL, atau Cloud Database seperti Neon DB)

---

## ⚙️ Prasyarat (Prerequisites)

Sebelum menjalankan aplikasi, pastikan Anda telah memasang perangkat lunak berikut pada komputer Anda:

1. **Node.js** (versi 18.x atau yang lebih baru) & **npm**.
2. **Flutter SDK** (versi 3.x atau yang lebih baru) & **Dart SDK**.
3. **Android Studio** / **VS Code** beserta emulator/perangkat fisik yang terhubung untuk menjalankan Flutter.
4. **PostgreSQL Database** (atau akses ke server database cloud).

---

## 🚀 1. Proses Menjalankan Backend (NestJS)

Backend bertindak sebagai penyedia API utama untuk aplikasi RuangPulih.

### Langkah-langkah Memulai:

1. **Masuk ke direktori backend**:
   ```bash
   cd backend
   ```

2. **Instal dependensi project**:
   ```bash
   npm install
   ```

3. **Konfigurasi Environment Variable (`.env`)**:
   Buat file `.env` di dalam direktori `backend/` (atau ubah file `.env` yang sudah ada) dan isi parameter koneksi database serta API key Anda:
   ```env
   DATABASE_HOST=host_database_anda
   DATABASE_PORT=5432
   DATABASE_USER=username_database
   DATABASE_PASSWORD=password_database
   DATABASE_NAME=nama_database
   JWT_SECRET=kunci_rahasia_jwt_anda
   GEMINI_API_KEY=kunci_api_google_gemini_anda
   ```

4. **Menjalankan Backend (Development Mode)**:
   Gunakan perintah berikut untuk menjalankan backend dengan fitur *auto-reload* saat ada perubahan kode:
   ```bash
   npm run start:dev
   ```
   Secara default, server backend akan berjalan pada port **3000** (`http://localhost:3000`).

5. **Perintah Backend Lainnya**:
   - Menjalankan tes: `npm run test`
   - Membangun aplikasi ke mode produksi: `npm run build`
   - Menjalankan mode produksi: `npm run start:prod`

---

## 📱 2. Proses Menjalankan Frontend (Flutter)

Frontend adalah aplikasi klien RuangPulih yang dibangun menggunakan Flutter.

### Langkah-langkah Memulai:

1. **Masuk ke direktori frontend**:
   ```bash
   cd frontend
   ```

2. **Unduh paket-paket dependensi Flutter**:
   ```bash
   flutter pub get
   ```

3. **Verifikasi Perangkat/Emulator**:
   Pastikan emulator Android/iOS Anda sudah berjalan atau perangkat fisik Anda terhubung dengan fitur USB debugging aktif. Jalankan perintah berikut untuk melihat daftar perangkat yang aktif:
   ```bash
   flutter devices
   ```

4. **Konfigurasi Alamat API**:
   Flutter menggunakan `ApiService` pada berkas `frontend/lib/api_service.dart` untuk menghubungkan aplikasi ke backend. Konfigurasi alamat backend telah disesuaikan secara otomatis berdasarkan platform:
   - **Android Emulator**: Menggunakan alamat IP khusus `http://10.0.2.2:3000` agar bisa mengakses localhost komputer Anda.
   - **Windows Desktop / Web**: Menggunakan `http://localhost:3000`.

   > [!IMPORTANT]
   > Jika Anda menjalankan aplikasi pada **perangkat fisik Android/iOS** langsung (bukan emulator), pastikan perangkat Anda berada dalam satu jaringan Wi-Fi yang sama dengan komputer Anda, lalu ubah konfigurasi alamat IP di `frontend/lib/api_service.dart` ke alamat IP lokal komputer Anda (contoh: `http://192.168.1.xxx:3000`).

5. **Menjalankan Aplikasi**:
   Jalankan perintah berikut untuk menjalankan aplikasi:
   ```bash
   flutter run
   ```
   Jika terdapat beberapa perangkat aktif, pilih perangkat target menggunakan flag `-d` (misalnya: `flutter run -d chrome` or `flutter run -d <DEVICE_ID>`).

---

## 🛠️ Fitur Utama Aplikasi

Aplikasi RuangPulih mencakup fitur-fitur kesehatan mental terintegrasi berikut:

- **🔐 Autentikasi Pengguna**: Login, Signup, dan Edit Profile dengan otentikasi JWT yang aman.
- **📔 Jurnal Harian**: Catatan harian emosional yang disimpan dengan aman di database.
- **📊 Mood Tracker**: Grafik/laporan suasana hati berkala pada Dashboard utama.
- **🤖 Curhat Bebas (AI Chat)**: Konseling interaktif berbasis AI ditenagai oleh Google Gemini API untuk membantu meredakan kecemasan pengguna kapan saja.
- **📅 Habit Tracker**: Membantu pengguna membangun dan memantau kebiasaan positif sehari-hari.
- **💬 Forum Diskusi**: Komunitas tempat sesama pengguna dapat berbagi cerita dan saling mendukung secara anonim maupun publik.
- **🩺 Sesi Konsultasi Dokter**: Memilih dokter spesialis kesehatan mental, melakukan pembayaran simulasi, dan melakukan sesi konsultasi privat.
- **📚 Artikel Untukmu**: Artikel edukasi kesehatan mental terkurasi untuk memberikan wawasan tambahan kepada pengguna.

---

## 🤝 Lisensi
Proyek ini dilisensikan di bawah ketentuan lisensi internal/pribadi.
