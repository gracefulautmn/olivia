import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initialName; // Untuk fallback jika imageUrl null
  final double radius;
  final double? fontSize; // Untuk ukuran font inisial
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.initialName,
    this.radius = 24.0,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
  });

  String get _getInitials {
    if (initialName == null || initialName!.isEmpty) return '?';
    List<String> nameParts = initialName!.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts.last[0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: hasImage ? Colors.transparent : (backgroundColor ?? Theme.of(context).colorScheme.primaryContainer),
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: !hasImage
          ? Text(
              _getInitials,
              style: TextStyle(
                fontSize: fontSize ?? radius * 0.8, // Sesuaikan ukuran font
                fontWeight: FontWeight.bold,
                color: textColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );
  }
}