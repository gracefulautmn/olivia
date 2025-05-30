class AppConstants {
  // GANTI DENGAN URL DAN ANON KEY SUPABASE ANDA
  static const String supabaseUrl = 'https://rrbmuxaeyignlezgggkv.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJyYm11eGFleWlnbmxlemdnZ2t2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNjgwMTgsImV4cCI6MjA2Mzg0NDAxOH0.OUdGSx4L9M9x6RLM7oXo3BNFKsz6MqHwN2dHfoYDB8I';

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