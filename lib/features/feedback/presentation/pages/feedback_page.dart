import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olivia/common_widgets/custom_button.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/feedback/domain/entities/feedback.dart';
import 'package:olivia/features/feedback/presentation/bloc/feedback_bloc.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  static const String routeName = '/feedback';

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  String _selectedFeedbackType = 'saran'; // Default value

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FeedbackBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Beri Masukan')),
        body: BlocConsumer<FeedbackBloc, FeedbackState>(
          listener: (context, state) {
            if (state is FeedbackSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  content: Text('Terima kasih! Masukan Anda telah terkirim.'),
                  backgroundColor: Colors.green,
                ));
              Navigator.of(context).pop();
            }
            if (state is FeedbackFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text('Gagal mengirim: ${state.message}'),
                  backgroundColor: Colors.red,
                ));
            }
          },
          builder: (context, state) {
            if (state is FeedbackSubmitting) {
              return const Center(child: LoadingIndicator(message: 'Mengirim...'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Kami menghargai masukan Anda untuk membuat aplikasi ini lebih baik.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: _selectedFeedbackType,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Masukan',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'saran', child: Text('Saran & Ide')),
                        DropdownMenuItem(value: 'bug', child: Text('Laporan Bug')),
                        DropdownMenuItem(value: 'review', child: Text('Review Aplikasi')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedFeedbackType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Detail Masukan Anda*',
                        hintText: 'Jelaskan sedetail mungkin...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 8,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Mohon isi detail masukan Anda.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Kirim Masukan',
                      onPressed: () {
                        final currentUser = context.read<AuthBloc>().state.user;
                        if (currentUser == null) {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Anda harus login untuk mengirim masukan.'),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        }

                        if (_formKey.currentState!.validate()) {
                          final feedback = FeedbackEntity(
                            userId: currentUser.id,
                            feedbackType: _selectedFeedbackType,
                            content: _contentController.text,
                          );
                          context.read<FeedbackBloc>().add(FeedbackSubmitted(feedback));
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
