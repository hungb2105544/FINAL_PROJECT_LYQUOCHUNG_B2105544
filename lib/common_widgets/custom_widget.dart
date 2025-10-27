import 'package:flutter/material.dart';

// Widget đánh giá sao
class RatingStars extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color filledColor;
  final Color unfilledColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 24,
    this.filledColor = Colors.amber,
    this.unfilledColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        if (index < rating.floor()) {
          // Sao đầy
          return Icon(Icons.star, color: filledColor, size: size);
        } else if (index < rating) {
          // Sao nửa
          return Icon(Icons.star_half, color: filledColor, size: size);
        } else {
          // Sao rỗng
          return Icon(Icons.star_border, color: unfilledColor, size: size);
        }
      }),
    );
  }
}

class ChatBubbleFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final bool hasNewMessage; // Thêm indicator cho tin nhắn mới

  const ChatBubbleFAB({
    super.key,
    required this.onPressed,
    this.hasNewMessage = false,
  });

  @override
  State<ChatBubbleFAB> createState() => _ChatBubbleFABState();
}

class _ChatBubbleFABState extends State<ChatBubbleFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value),
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main chat bubble với gradient và shadow đẹp hơn
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                        Theme.of(context).primaryColor.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 25,
                        offset: const Offset(0, 15),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onPressed,
                      borderRadius: BorderRadius.circular(25),
                      splashColor: Colors.white.withOpacity(0.3),
                      highlightColor: Colors.white.withOpacity(0.2),
                      child: Stack(
                        children: [
                          // Icon chính
                          const Center(
                            child: Icon(
                              Icons
                                  .smart_toy_rounded, // Icon robot thay vì chat bubble
                              color: Colors.white,
                              size: 32,
                            ),
                          ),

                          // Hiệu ứng sóng khi có tin nhắn mới
                          if (widget.hasNewMessage)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 1000),
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      center: Alignment.center,
                                      radius: 1.5,
                                      colors: [
                                        Colors.white.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tail của chat bubble được cải thiện
                Positioned(
                  bottom: -10,
                  right: 20,
                  child: CustomPaint(
                    size: const Size(20, 15),
                    painter: ChatBubbleTailPainter(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),

                // Active indicator với animation
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildActiveIndicator(),
                ),

                // Notification badge cho tin nhắn mới
                if (widget.hasNewMessage)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveIndicator() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.check,
          size: 8,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ChatBubbleTailPainter extends CustomPainter {
  final Color color;

  ChatBubbleTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          color,
          color.withOpacity(0.8),
        ],
      ).createShader(Rect.fromPoints(
        Offset(0, 0),
        Offset(size.width, size.height),
      ));

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.6,
        size.height * 0.1,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.05,
        size.width,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.8,
        size.width * 0.2,
        size.height,
      )
      ..close();

    canvas.drawPath(path, paint);

    // Thêm highlight cho tail
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final highlightPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.4,
        size.width * 0.7,
        size.height * 0.6,
      )
      ..lineTo(size.width * 0.5, size.height * 0.7)
      ..close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
