// Enum dari skema SQL Anda (digunakan di entity dan model)
enum UserRole { mahasiswa, staff_dosen }
enum ItemStatus { hilang, ditemukan_tersedia, ditemukan_diklaim }
enum ReportType { kehilangan, penemuan }

// Helper untuk konversi string ke enum dan sebaliknya
// Contoh untuk UserRole:
UserRole userRoleFromString(String value) {
  switch (value) {
    case 'mahasiswa':
      return UserRole.mahasiswa;
    case 'staff_dosen':
      return UserRole.staff_dosen;
    default:
      throw ArgumentError('Unknown UserRole string: $value');
  }
}

String userRoleToString(UserRole role) {
  switch (role) {
    case UserRole.mahasiswa:
      return 'mahasiswa';
    case UserRole.staff_dosen:
      return 'staff_dosen';
  }
}

// Buat fungsi serupa untuk ItemStatus dan ReportType
ItemStatus itemStatusFromString(String value) {
  // ... implementasi
  if (value == 'hilang') return ItemStatus.hilang;
  if (value == 'ditemukan_tersedia') return ItemStatus.ditemukan_tersedia;
  if (value == 'ditemukan_diklaim') return ItemStatus.ditemukan_diklaim;
  throw ArgumentError('Unknown ItemStatus string: $value');
}

String itemStatusToString(ItemStatus status) {
  // ... implementasi
  if (status == ItemStatus.hilang) return 'hilang';
  if (status == ItemStatus.ditemukan_tersedia) return 'ditemukan_tersedia';
  if (status == ItemStatus.ditemukan_diklaim) return 'ditemukan_diklaim';
  throw ArgumentError('Unknown ItemStatus value');
}

ReportType reportTypeFromString(String value) {
  // ... implementasi
  if (value == 'kehilangan') return ReportType.kehilangan;
  if (value == 'penemuan') return ReportType.penemuan;
  throw ArgumentError('Unknown ReportType string: $value');
}

String reportTypeToString(ReportType type) {
  // ... implementasi
  if (type == ReportType.kehilangan) return 'kehilangan';
  if (type == ReportType.penemuan) return 'penemuan';
  throw ArgumentError('Unknown ReportType value');
}