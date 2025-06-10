import 'package:olivia/features/auth/data/models/user_profile_model.dart';
import 'package:olivia/features/history/domain/entities/claim_history_entry.dart';
import 'package:olivia/features/item/data/models/item_model.dart';

class ClaimHistoryEntryModel extends ClaimHistoryEntry {
  const ClaimHistoryEntryModel({
    required super.item,
    required super.claimerProfile,
    required super.securityProfile,
    required super.claimedAt,
  });

  factory ClaimHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return ClaimHistoryEntryModel(
      item: ItemModel.fromJson(json['item']),
      claimerProfile: UserProfileModel.fromJson(json['claimer']),
      securityProfile: UserProfileModel.fromJson(json['security_reporter']),
      claimedAt: DateTime.parse(json['claimed_at']),
    );
  }
}
