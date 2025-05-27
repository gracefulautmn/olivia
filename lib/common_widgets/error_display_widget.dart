import 'package:flutter/material.dart';
import 'package:olivia/common_widgets/custom_button.dart'; // Menggunakan CustomButton

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry; // Callback untuk tombol coba lagi (opsional)
  final String retryButtonText;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryButtonText = 'Coba Lagi',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 60),
            const SizedBox(height: 16),
            Text(
              'Oops! Terjadi Kesalahan',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: retryButtonText,
                onPressed: onRetry!,
                backgroundColor: Colors.red.shade400,
                icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
