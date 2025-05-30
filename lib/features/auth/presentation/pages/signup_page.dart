import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/utils/app_colors.dart'; // Sesuaikan path
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/auth/presentation/pages/login_page.dart'; // Untuk navigasi kembali ke login
import 'package:olivia/navigation/main_navigation_scaffold.dart'; // Untuk navigasi ke home setelah sukses
import 'package:olivia/common_widgets/custom_button.dart'; // Sesuaikan path
import 'package:olivia/common_widgets/loading_indicator.dart'; // Sesuaikan path

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  static const String routeName = '/signup'; // Definisikan rute

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final fullName = _fullNameController.text.trim();
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      print('Signing up with Email: $email, FullName: $fullName');

      context.read<AuthBloc>().add(AuthSignUpRequested(
          email: email,
          password: password,
          confirmPassword: confirmPassword,
          fullName: fullName,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        leading: IconButton( // Tombol kembali jika diperlukan
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // Jika tidak bisa pop (mungkin rute awal), pergi ke login
              context.go(LoginPage.routeName);
            }
          },
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        // Dengarkan AuthBloc yang di-provide di level yang lebih tinggi
        // (misal di MaterialApp atau AppRouter)
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            // Navigasi ke halaman utama setelah signup berhasil
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                  content: Text('Pendaftaran berhasil! Selamat datang.'),
                  backgroundColor: Colors.green));
            context.go(MainNavigationScaffold.routeName);
          }
          if (state.status == AuthStatus.unauthenticated && state.failure != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                  content: Text('Pendaftaran Gagal: ${state.failure!.message}'),
                  backgroundColor: Colors.red));
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Placeholder untuk logo atau gambar
                  FlutterLogo(size: 80, style: FlutterLogoStyle.stacked, textColor: AppColors.primaryColor),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap*',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama lengkap tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Kampus*',
                      hintText: 'nim@student.universitaspertamina.ac.id',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      // Validasi domain bisa lebih ketat di usecase/BLoC
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Format email tidak valid';
                      }
                      if (!value.toLowerCase().endsWith('universitaspertamina.ac.id')){
                         return 'Gunakan email domain universitaspertamina.ac.id';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password*',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Password*',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_person_outlined),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password tidak boleh kosong';
                      }
                      if (value != _passwordController.text) {
                        return 'Password tidak cocok';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  BlocBuilder<AuthBloc, AuthState>(
                    // Build berdasarkan AuthBloc yang di-provide di atas
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Daftar',
                        isLoading: state.status == AuthStatus.loading,
                        onPressed: _signUp,
                        backgroundColor: AppColors.primaryColor,
                        textColor: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah punya akun? "),
                      TextButton(
                        onPressed: () {
                          context.go(LoginPage.routeName); // Kembali ke halaman login
                        },
                        child: const Text('Login di sini'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}