import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessVerifiedEmail extends StatefulWidget {
  const SuccessVerifiedEmail({super.key});

  @override
  State<SuccessVerifiedEmail> createState() => _SuccessVerifiedEmailState();
}

class _SuccessVerifiedEmailState extends State<SuccessVerifiedEmail> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF182145),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 32.0, horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/lottie/success_confetti.json',
                      width: screenWidth * 0.6,
                      height: screenWidth * 0.6,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Xác nhận thành công! 🎉🎉🎉",
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Hãy đăng nhập để tiến hành mua sắm.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: screenWidth * 0.6,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to home page or login page
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFeb7816),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Đăng nhập ngay"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
