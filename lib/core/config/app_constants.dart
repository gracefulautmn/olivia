// lib/core/config/app_constants.dart

class AppConstants {
  // Supabase Credentials
  // TODO: Ganti dengan URL Supabase Anda yang sebenarnya
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  // TODO: Ganti dengan Anon Key Supabase Anda yang sebenarnya
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // App Name (jika diperlukan di beberapa tempat)
  static const String appName = 'Lost & Found UP';

  // Default values or common strings
  static const String defaultErrorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
  static const String networkErrorMessage = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
  static const String defaultProfileImageUrl = 'https://placehold.co/150x150/E0E0E0/BDBDBD?text=User'; // Placeholder avatar

  // Durations (misalnya untuk snackbar atau animasi)
  static const Duration shortDuration = Duration(milliseconds: 500);
  static const Duration mediumDuration = Duration(seconds: 1);
  static const Duration longDuration = Duration(seconds: 3);

  // Batasan (Limits)
  static const int maxRecentItemsToShow = 6; // Jumlah item terbaru yang ditampilkan di beranda
  static const int itemsPerPage = 10; // Jumlah item per halaman untuk paginasi

  // Kunci untuk Shared Preferences (jika digunakan)
  // static const String themePreferenceKey = 'app_theme_preference';

  // Format Tanggal
  static const String defaultDateFormat = 'dd MMM yyyy, HH:mm'; // Contoh: 26 Mei 2025, 14:30

  // Regex untuk validasi email Universitas Pertamina
  // Format: nim@student.universitaspertamina.ac.id ATAU identifier@universitaspertamina.ac.id
  static const String emailRegexPattern = r'^[a-zA-Z0-9._%+-]+@(student\.)?universitaspertamina\.ac\.id$';

}
