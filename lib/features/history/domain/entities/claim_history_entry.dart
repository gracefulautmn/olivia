import 'package:equatable/equatable.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/item/domain/entities/item.dart';

class ClaimHistoryEntry extends Equatable {
  final ItemEntity item;
  final UserProfile claimerProfile; // Profil yang mengklaim
  final UserProfile securityProfile; // Profil keamanan yang menemukan/menyerahkan
  final DateTime claimedAt;

  const ClaimHistoryEntry({
    required this.item,
    required this.claimerProfile,
    required this.securityProfile,
    required this.claimedAt,
  });

  @override
  List<Object?> get props => [item, claimerProfile, securityProfile, claimedAt];
}
