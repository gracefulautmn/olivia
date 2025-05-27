class AppConstants {
  // GANTI DENGAN URL DAN ANON KEY SUPABASE ANDA
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static const String studentEmailDomain = '@student.universitaspertamina.ac.id';
  static const String staffEmailDomain = '@universitaspertamina.ac.id'; // Lebih umum, akan dicek setelah student

  // Item status (sesuai enum di DB)
  static const String itemStatusLost = 'hilang';
  static const String itemStatusFoundAvailable = 'ditemukan_tersedia';
  static const String itemStatusFoundClaimed = 'ditemukan_diklaim';

  // Report type (sesuai enum di DB)
  static const String reportTypeLoss = 'kehilangan';
  static const String reportTypeFound = 'penemuan';
}