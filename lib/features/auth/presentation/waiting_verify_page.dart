import 'package:ecommerce_app/features/auth/bloc/auth_bloc.dart';
import 'package:ecommerce_app/features/auth/bloc/auth_event.dart';
import 'package:ecommerce_app/features/auth/bloc/auth_state.dart';
import 'package:ecommerce_app/features/auth/presentation/login_page.dart';
import 'package:ecommerce_app/features/auth/presentation/success_verified_email.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class WaitingVerifyPage extends StatefulWidget {
  final String email;

  const WaitingVerifyPage({
    super.key,
    required this.email,
  });

  @override
  State<WaitingVerifyPage> createState() => _WaitingVerifyPageState();
}

class _WaitingVerifyPageState extends State<WaitingVerifyPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  Timer? _checkTimer;
  int _countdown = 60;
  Timer? _countdownTimer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startCountdown();
    _startPeriodicCheck();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _startPeriodicCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      context.read<AuthBloc>().add(RestoreSessionEvent());
    });
  }

  void _resendVerificationEmail() {
    context.read<AuthBloc>().add(
          ResendVerificationEvent(email: widget.email),
        );
    setState(() {
      _canResend = false;
      _countdown = 60;
    });
    _startCountdown();
    _showSuccessSnackBar('Email xác thực đã được gửi lại');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) return email;

    final maskedUsername = username[0] +
        '*' * (username.length - 2) +
        username[username.length - 1];

    return '$maskedUsername@$domain';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _checkTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: BlocListener<AuthBloc, AuthenState>(
        listener: (context, state) {
          print('Auth state changed: ${state.status}');
          switch (state.status) {
            case AuthStatus.authenticated:
              print('Navigating to success page');
              _checkTimer?.cancel();
              _countdownTimer?.cancel();
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => const SuccessVerifiedEmail(),
                ),
              );
              break;
            case AuthStatus.error:
              _showErrorSnackBar(state.errorMessage ?? 'Có lỗi xảy ra');
              break;
            default:
              break;
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
                                height: constraints.maxHeight * 0.15,
                                child: Image.asset(
                                  'assets/images/splash_logo.png',
                                  fit: BoxFit.fitWidth,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Card chính
                              Container(
                                padding: const EdgeInsets.all(32.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    // Icon email với animation
                                    AnimatedBuilder(
                                      animation: _pulseAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _pulseAnimation.value,
                                          child: Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: AnimatedBuilder(
                                              animation: _rotationAnimation,
                                              builder: (context, child) {
                                                return Transform.rotate(
                                                  angle:
                                                      _rotationAnimation.value *
                                                          2 *
                                                          3.14159,
                                                  child: Icon(
                                                    Icons.mail_outline,
                                                    size: 60,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 24),

                                    // Tiêu đề
                                    Text(
                                      'Kiểm tra email của bạn',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 16),

                                    // Mô tả
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                              height: 1.5,
                                            ),
                                        children: [
                                          const TextSpan(
                                            text:
                                                'Chúng tôi đã gửi liên kết xác thực đến\n',
                                          ),
                                          TextSpan(
                                            text: _maskEmail(widget.email),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Hướng dẫn
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue[200]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.blue[700],
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Hướng dẫn:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '1. Kiểm tra hộp thư đến của bạn\n'
                                            '2. Nhấp vào liên kết xác thực\n'
                                            '3. Quay lại ứng dụng để tiếp tục',
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Trạng thái kiểm tra
                                    BlocBuilder<AuthBloc, AuthenState>(
                                      builder: (context, state) {
                                        if (state.status ==
                                            AuthStatus.loading) {
                                          return const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              ),
                                              SizedBox(width: 8),
                                              Text('Đang kiểm tra...'),
                                            ],
                                          );
                                        }
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.refresh,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Tự động kiểm tra mỗi 3 giây',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 32),

                                    // Nút gửi lại email
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _canResend
                                            ? _resendVerificationEmail
                                            : null,
                                        icon: const Icon(Icons.refresh),
                                        label: Text(
                                          _canResend
                                              ? 'Gửi lại email xác thực'
                                              : 'Gửi lại sau ${_countdown}s',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _canResend
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey[400],
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Nút kiểm tra thủ công
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          context
                                              .read<AuthBloc>()
                                              .add(RestoreSessionEvent());
                                          print("Restore session success");
                                        },
                                        icon: const Icon(
                                            Icons.check_circle_outline),
                                        label: const Text('Tôi đã xác thực'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              Theme.of(context).primaryColor,
                                          side: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Quay lại đăng nhập
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Chưa nhận được email?",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _checkTimer?.cancel();
                                      _countdownTimer?.cancel();
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage()),
                                        (route) => false,
                                      );
                                    },
                                    child: Text(
                                      "Đăng nhập lại",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
