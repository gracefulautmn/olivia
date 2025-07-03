import 'package:equatable/equatable.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/item/domain/entities/item.dart';

class ClaimHistoryEntry extends Equatable {
  final ItemEntity item;
  // --- PERBAIKAN 1: Jadikan profil pengklaim bisa null ---
  final UserProfile? claimerProfile; 
  final UserProfile securityProfile;
  final DateTime claimedAt;
  // --- PERBAIKAN 2: Tambahkan field untuk menyimpan detail tamu ---
  final String? guestClaimerDetails;

  const ClaimHistoryEntry({
    required this.item,
    this.claimerProfile, // Sekarang opsional
    required this.securityProfile,
    required this.claimedAt,
    this.guestClaimerDetails, // Opsional
  });

  @override
  List<Object?> get props => [item, claimerProfile, securityProfile, claimedAt, guestClaimerDetails];
}
