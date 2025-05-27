import 'package:flutter/material.dart';
import 'package:olivia/core/utils/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color color;
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color = AppColors.primaryColor,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: strokeWidth,
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
