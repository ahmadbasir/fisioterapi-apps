# 🧘 FisioActive - Self-Recovery Assistant

[![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.9.2-blue?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-%5E3.0-blue?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey)](#)

**FisioActive** adalah aplikasi asisten pemulihan mandiri (Self-Recovery Assistant) berbasis Flutter yang dirancang untuk membantu pengguna melakukan terapi fisik dan melacak kemajuan pemulihan otot/sendi mereka secara mandiri, aman, dan terstruktur.

Aplikasi ini dilengkapi dengan sistem triase medis mandiri, pemetaan keluhan tubuh (*body mapping*), serta modul latihan pemulihan yang disesuaikan secara dinamis.

---

## ✨ Fitur Utama (Key Features)

1. **🔐 Onboarding & Profile Setup**
   * Alur onboarding interaktif untuk mengenalkan fitur utama.
   * Peringatan Disclaimer Medis demi keamanan pengguna sebelum memulai terapi.
   * Pengisian data profil awal untuk mempersonalisasi rekomendasi program pemulihan.

2. **📊 Dashboard & Progress Reports (`fl_chart`)**
   * Tampilan kemajuan pemulihan dengan grafik visual interaktif.
   * Laporan riwayat latihan pemulihan harian.
   * Akses cepat ke menu utama dan pengaturan aplikasi.

3. **🩺 Med-Triage & Body Mapping**
   * **Interactive Body Map**: Menunjuk area tubuh yang mengalami keluhan secara spesifik.
   * **Red Flags Screening**: Deteksi dini gejala kritis untuk memastikan keamanan sebelum berlatih.
   * **Doctor Referral System**: Rekomendasi otomatis untuk berkonsultasi dengan dokter spesialis jika terdeteksi indikasi medis berbahaya (*red flags*).

4. **🏋️ Dynamic Recovery Workout System**
   * Ringkasan program latihan pemulihan (*Workout Overview*).
   * Antarmuka latihan aktif (*Active Workout Screen*) dengan visualisasi langkah demi langkah dan pengatur waktu.
   * Ringkasan sesi latihan (*Workout Summary*) untuk mencatat pencapaian dan durasi latihan.

---

## 🛠️ Arsitektur & Teknologi (Tech Stack)

Aplikasi ini dibangun menggunakan arsitektur modern Flutter yang terstruktur rapi:
* **Framework**: [Flutter SDK ^3.9.2](https://flutter.dev)
* **State Management**: [Riverpod (`flutter_riverpod ^2.6.1`)](https://riverpod.dev) — Untuk manajemen state yang reaktif, bersih, dan mudah diuji.
* **Routing**: [GoRouter (`go_router ^14.6.2`)](https://pub.dev/packages/go_router) — Untuk navigasi berbasis rute yang deklaratif dan aman.
* **Visualisasi Data**: [FL Chart (`fl_chart ^0.70.0`)](https://pub.dev/packages/fl_chart) — Untuk menyajikan grafik pemulihan yang interaktif dan modern.
* **Penyimpanan Lokal**: [Shared Preferences (`shared_preferences ^2.3.2`)](https://pub.dev/packages/shared_preferences) — Menyimpan profil pengguna dan progres latihan secara offline.
* **Tipografi**: [Google Fonts (`google_fonts ^6.2.1`)](https://pub.dev/packages/google_fonts) — Menggunakan font premium modern untuk estetika terbaik.

---

## 🚀 Panduan Memulai di Perangkat Lokal (Getting Started)

Ikuti langkah-langkah di bawah ini untuk mengklon dan menjalankan proyek **FisioActive** di komputer lokal Anda.

### 📋 Prasyarat (Prerequisites)

Pastikan Anda telah menginstal peralatan berikut:
* **Flutter SDK** (versi >= 3.9.2) - [Panduan Instalasi Flutter](https://docs.flutter.dev/get-started/install)
* **Dart SDK** (versi >= 3.0)
* **IDE/Editor**: [Visual Studio Code](https://code.visualstudio.com/) atau [Android Studio](https://developer.android.com/studio) beserta ekstensi Flutter & Dart.
* **Git** - [Download Git](https://git-scm.com/)

---

### 💻 Langkah demi Langkah (Step-by-Step)

#### 1. Klon Repositori (Clone the Repository)
Buka terminal/command prompt di komputer Anda, lalu jalankan perintah berikut:
```bash
git clone https://github.com/ahmadbasir/fisioterapi-apps.git
```

#### 2. Masuk ke Direktori Proyek (Navigate to Project Directory)
```bash
cd fisioterapi-apps
```

#### 3. Unduh Dependensi (Fetch Dependencies)
Unduh seluruh package/library Flutter yang dibutuhkan untuk menjalankan proyek ini:
```bash
flutter pub get
```

#### 4. Jalankan Aplikasi (Run the Application)
Pastikan emulator (Android/iOS) sedang aktif atau perangkat fisik Anda terhubung via USB debugging, kemudian jalankan:

* **Mode Debug Utama**:
  ```bash
  flutter run
  ```

* **Menjalankan pada platform spesifik**:
  * **Android**:
    ```bash
    flutter run -d android
    ```
  * **iOS**:
    ```bash
    flutter run -d ios
    ```
  * **Web**:
    ```bash
    flutter run -d chrome
    ```

---

## 📁 Struktur Folder Proyek (Folder Structure)

```text
lib/
├── app/                  # Konfigurasi Global & Tema
│   ├── router.dart       # Pengaturan Rute Navigasi (GoRouter)
│   └── theme.dart        # Palet Warna Premium & Desain Visual Gelap (AppTheme)
├── core/                 # Komponen Inti & Data
│   ├── data/             # Repositori Data & Logika Bisnis
│   ├── models/           # Struktur Data & Model Objek
│   └── providers/        # Riverpod Global Providers & Shared Preferences
├── features/             # Fitur Fungsional Modular
│   ├── auth/             # Autentikasi, Onboarding, Profile Setup, Disclaimer, Splash
│   ├── dashboard/        # Dashboard Utama, Visualisasi Grafik (Report), Pengaturan
│   ├── triage/           # Body Mapping, Deteksi Red Flags, Rujukan Dokter
│   └── workout/          # Halaman Latihan Aktif, Ringkasan, & Ikhtisar Latihan
└── main.dart             # Titik Masuk Utama Aplikasi (App Entry Point)
```

---

## 🤝 Kontribusi (Contributing)

Jika Anda ingin ikut berkontribusi dalam pengembangan aplikasi **FisioActive**:
1. Lakukan **Fork** pada repositori ini.
2. Buat branch fitur baru Anda (`git checkout -b fitur/FiturKerenAnda`).
3. Commit perubahan Anda (`git commit -m 'Menambahkan fitur keren'`).
4. Push ke branch Anda (`git push origin fitur/FiturKerenAnda`).
5. Buat **Pull Request** baru di GitHub.

---

## 📄 Lisensi (License)

Proyek ini dilisensikan di bawah Lisensi **MIT**. Silakan gunakan secara bebas untuk keperluan belajar maupun komersial dengan tetap menyertakan atribusi yang sesuai.

---
*Dibuat dengan ❤️ oleh kelompok pengembang **FisioActive***
