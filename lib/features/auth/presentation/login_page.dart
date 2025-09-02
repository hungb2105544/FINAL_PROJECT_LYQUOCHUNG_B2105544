import 'package:ecommerce_app/features/auth/bloc/auth_bloc.dart';
import 'package:ecommerce_app/features/auth/bloc/auth_event.dart';
import 'package:ecommerce_app/features/auth/bloc/auth_state.dart';
import 'package:ecommerce_app/features/auth/presentation/register_page.dart';
import 'package:ecommerce_app/features/auth/presentation/waiting_verify_page.dart';
import 'package:ecommerce_app/features/home/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isVisiable = false;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: BlocListener<AuthBloc, AuthenState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
            );
          } else if (state.status == AuthStatus.emailVerificationRequired) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    WaitingVerifyPage(email: _usernameController.text),
              ),
            );
          } else if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Có lỗi xảy ra'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Nền dưới
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: constraints.maxHeight * 0.5,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),

                  // Nội dung chính
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                constraints.maxWidth > 400 ? 32.0 : 20.0,
                            vertical: 20.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 20),
                              // Logo
                              SizedBox(
                                height: constraints.maxHeight * 0.17,
                                child: Image.asset(
                                  'assets/images/splash_logo.png',
                                  fit: BoxFit.fitWidth,
                                ),
                              ),

                              // Form đăng nhập
                              Container(
                                padding: const EdgeInsets.all(24.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    // Tiêu đề
                                    Text(
                                      'Đăng nhập',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _usernameController,
                                      decoration: const InputDecoration(
                                        labelText: "Email",
                                        hintText: "Nhập email",
                                        prefixIcon: Icon(Icons.person),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        labelText: "Mật khẩu",
                                        hintText: "Nhập mật khẩu",
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: _obscurePassword,
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          print("Quên mật khẩu? clicked");
                                        },
                                        child: const Text("Quên mật khẩu?"),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final response = context
                                              .read<AuthBloc>()
                                              .add(
                                                LoginEvent(
                                                  email:
                                                      _usernameController.text,
                                                  password:
                                                      _passwordController.text,
                                                ),
                                              );
                                        },
                                        child: const Text("Đăng nhập"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Đăng ký
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Chưa có tài khoản?",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                const RegisterPage(),
                                          ));
                                    },
                                    child: Text(
                                      "Đăng ký",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Hoặc đăng nhập với
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      "Hoặc đăng nhập với",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Google button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Colors.grey),
                                  ),
                                ),
                                onPressed: () {},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/google.png",
                                      height: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Đăng nhập với Google",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),

                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                      visible: isVisiable,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          child: Lottie.asset(
                              "assets/lottie/loading_viemode.json"),
                        ),
                      ))
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
