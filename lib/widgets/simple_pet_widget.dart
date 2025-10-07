import 'package:flutter/material.dart';
import '../models/pet.dart';

class SimplePetWidget extends StatefulWidget {
  final Pet pet;
  final VoidCallback? onTap;
  final double size;

  const SimplePetWidget({
    super.key,
    required this.pet,
    this.onTap,
    this.size = 200.0,
  });

  @override
  State<SimplePetWidget> createState() => _SimplePetWidgetState();
}

class _SimplePetWidgetState extends State<SimplePetWidget>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _blinkController;
  late AnimationController _bounceController;
  
  @override
  void initState() {
    super.initState();
    
    // Breathing animation (continuous)
    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Blinking animation (periodic)
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Bounce animation (on tap)
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Start periodic blinking
    _startBlinking();
  }

  void _startBlinking() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: 2 + (3 * (1 - widget.pet.healthPercentage)).round()));
      if (mounted) {
        _blinkController.forward().then((_) {
          if (mounted) _blinkController.reverse();
        });
      }
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _blinkController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onTap() {
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _breathingController,
          _blinkController,
          _bounceController,
        ]),
        builder: (context, child) {
          final breathingScale = 1.0 + (_breathingController.value * 0.05);
          final bounceScale = 1.0 + (_bounceController.value * 0.1);
          final totalScale = breathingScale * bounceScale;
          
          return Transform.scale(
            scale: totalScale,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: PetPainter(
                pet: widget.pet,
                blinkAmount: _blinkController.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class PetPainter extends CustomPainter {
  final Pet pet;
  final double blinkAmount;

  PetPainter({
    required this.pet,
    required this.blinkAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bodyRadius = size.width * 0.35;
    
    // Get colors based on pet state
    final colors = _getPetColors();
    
    // Draw shadow
    _drawShadow(canvas, center, bodyRadius);
    
    // Draw body
    _drawBody(canvas, center, bodyRadius, colors);
    
    // Draw belly
    _drawBelly(canvas, center, bodyRadius, colors);
    
    // Draw arms
    _drawArms(canvas, center, bodyRadius, colors);
    
    // Draw legs
    _drawLegs(canvas, center, bodyRadius, colors);
    
    // Draw face
    _drawFace(canvas, center, bodyRadius, colors);
    
    // Draw ears based on evolution stage
    _drawEars(canvas, center, bodyRadius, colors);
    
    // Draw accessories based on level
    if (pet.level >= 5) {
      _drawAccessory(canvas, center, bodyRadius);
    }
  }

  PetColors _getPetColors() {
    switch (pet.evolutionStage) {
      case PetEvolutionStage.baby:
        return PetColors(
          primary: Colors.lightGreen.shade300,
          secondary: Colors.lightGreen.shade100,
          accent: Colors.green.shade400,
        );
      case PetEvolutionStage.child:
        return PetColors(
          primary: Colors.green.shade400,
          secondary: Colors.green.shade200,
          accent: Colors.green.shade600,
        );
      case PetEvolutionStage.adult:
        return PetColors(
          primary: Colors.green.shade600,
          secondary: Colors.green.shade300,
          accent: Colors.green.shade800,
        );
    }
  }

  void _drawShadow(Canvas canvas, Offset center, double bodyRadius) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + 5, center.dy + bodyRadius + 10),
        width: bodyRadius * 1.5,
        height: bodyRadius * 0.3,
      ),
      shadowPaint,
    );
  }

  void _drawBody(Canvas canvas, Offset center, double bodyRadius, PetColors colors) {
    final bodyPaint = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.fill;
    
    // Main body (circular)
    canvas.drawCircle(center, bodyRadius, bodyPaint);
    
    // Body outline
    final outlinePaint = Paint()
      ..color = colors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(center, bodyRadius, outlinePaint);
  }

  void _drawBelly(Canvas canvas, Offset center, double bodyRadius, PetColors colors) {
    final bellyPaint = Paint()
      ..color = colors.secondary
      ..style = PaintingStyle.fill;
    
    final bellyRadius = bodyRadius * 0.6;
    canvas.drawCircle(
      Offset(center.dx, center.dy + bodyRadius * 0.2),
      bellyRadius,
      bellyPaint,
    );
  }

  void _drawArms(Canvas canvas, Offset center, double bodyRadius, PetColors colors) {
    final armPaint = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.fill;
    
    final armRadius = bodyRadius * 0.25;
    
    // Left arm
    canvas.drawCircle(
      Offset(center.dx - bodyRadius * 0.8, center.dy),
      armRadius,
      armPaint,
    );
    
    // Right arm
    canvas.drawCircle(
      Offset(center.dx + bodyRadius * 0.8, center.dy),
      armRadius,
      armPaint,
    );
  }

  void _drawLegs(Canvas canvas, Offset center, double bodyRadius, PetColors colors) {
    final legPaint = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.fill;
    
    final legRadius = bodyRadius * 0.3;
    
    // Left leg
    canvas.drawCircle(
      Offset(center.dx - bodyRadius * 0.4, center.dy + bodyRadius * 0.8),
      legRadius,
      legPaint,
    );
    
    // Right leg
    canvas.drawCircle(
      Offset(center.dx + bodyRadius * 0.4, center.dy + bodyRadius * 0.8),
      legRadius,
      legPaint,
    );
  }

  void _drawFace(Canvas canvas, Offset center, double bodyRadius, PetColors colors) {
    // Eyes
    _drawEyes(canvas, center, bodyRadius);
    
    // Mouth
    _drawMouth(canvas, center, bodyRadius);
    
    // Cheeks (if happy)
    if (pet.emotionalState == PetEmotionalState.happy || 
        pet.emotionalState == PetEmotionalState.excited) {
      _drawCheeks(canvas, center, bodyRadius);
    }
  }

  void _drawEyes(Canvas canvas, Offset center, double bodyRadius) {
    final eyeWhitePaint = Paint()..color = Colors.white;
    final eyeBlackPaint = Paint()..color = Colors.black;
    
    final eyeRadius = bodyRadius * 0.15;
    final eyeY = center.dy - bodyRadius * 0.2;
    
    // Eye positions
    final leftEyeCenter = Offset(center.dx - bodyRadius * 0.25, eyeY);
    final rightEyeCenter = Offset(center.dx + bodyRadius * 0.25, eyeY);
    
    // Draw eye whites
    canvas.drawCircle(leftEyeCenter, eyeRadius, eyeWhitePaint);
    canvas.drawCircle(rightEyeCenter, eyeRadius, eyeWhitePaint);
    
    // Calculate eye height based on blink and emotional state
    double eyeHeight = eyeRadius * 2;
    if (blinkAmount > 0) {
      eyeHeight *= (1 - blinkAmount);
    }
    
    // Adjust eye shape based on emotion
    switch (pet.emotionalState) {
      case PetEmotionalState.happy:
      case PetEmotionalState.excited:
        eyeHeight *= 0.7; // Squinty happy eyes
        break;
      case PetEmotionalState.sad:
        eyeHeight *= 1.2; // Wider sad eyes
        break;
      default:
        break;
    }
    
    // Draw pupils
    final pupilRadius = eyeRadius * 0.6;
    canvas.drawOval(
      Rect.fromCenter(center: leftEyeCenter, width: pupilRadius * 2, height: eyeHeight * 0.6),
      eyeBlackPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: rightEyeCenter, width: pupilRadius * 2, height: eyeHeight * 0.6),
      eyeBlackPaint,
    );
    
    // Draw eye highlights
    final highlightPaint = Paint()..color = Colors.white;
    final highlightRadius = pupilRadius * 0.3;
    canvas.drawCircle(
      Offset(leftEyeCenter.dx - pupilRadius * 0.3, leftEyeCenter.dy - pupilRadius * 0.3),
      highlightRadius,
      highlightPaint,
    );
    canvas.drawCircle(
      Offset(rightEyeCenter.dx - pupilRadius * 0.3, rightEyeCenter.dy - pupilRadius * 0.3),
      highlightRadius,
      highlightPaint,
    );
  }

  void _drawMouth(Canvas canvas, Offset center, double bodyRadius) {
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    final mouthY = center.dy + bodyRadius * 0.1;
    
    Path mouthPath = Path();
    
    switch (pet.emotionalState) {
      case PetEmotionalState.happy:
      case PetEmotionalState.excited:
        // Happy smile
        mouthPath.addArc(
          Rect.fromCenter(
            center: Offset(center.dx, mouthY - bodyRadius * 0.1),
            width: bodyRadius * 0.4,
            height: bodyRadius * 0.3,
          ),
          0,
          3.14159,
        );
        break;
      case PetEmotionalState.sad:
        // Sad frown
        mouthPath.addArc(
          Rect.fromCenter(
            center: Offset(center.dx, mouthY + bodyRadius * 0.1),
            width: bodyRadius * 0.3,
            height: bodyRadius * 0.2,
          ),
          3.14159,
          3.14159,
        );
        break;
      default:
        // Neutral mouth
        mouthPath.moveTo(center.dx - bodyRadius * 0.1, mouthY);
        mouthPath.lineTo(center.dx + bodyRadius * 0.1, mouthY);
        break;
    }
    
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawCheeks(Canvas canvas, Offset center, double bodyRadius) {
    final cheekPaint = Paint()
      ..color = Colors.pink.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    
    final cheekRadius = bodyRadius * 0.1;
    final cheekY = center.dy + bodyRadius * 0.05;
    
    // Left cheek
    canvas.drawCircle(
      Offset(center.dx - bodyRadius * 0.5, cheekY),
      cheekRadius,
      cheekPaint,
    );
    
    // Right cheek
    canvas.drawCircle(
      Offset(center.dx + bodyRadius * 0.5, cheekY),
      cheekRadius,
      cheekPaint,
    );
  }

  void _drawEars(Canvas canvas, Offset center, double bodyRadius, PetColors colors) {
    final earPaint = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.fill;
    
    final innerEarPaint = Paint()
      ..color = colors.secondary
      ..style = PaintingStyle.fill;
    
    double earSize = bodyRadius * 0.3;
    
    // Ears get bigger as pet evolves
    switch (pet.evolutionStage) {
      case PetEvolutionStage.baby:
        earSize *= 0.8;
        break;
      case PetEvolutionStage.child:
        earSize *= 1.0;
        break;
      case PetEvolutionStage.adult:
        earSize *= 1.2;
        break;
    }
    
    final earY = center.dy - bodyRadius * 0.7;
    
    // Left ear
    canvas.drawCircle(
      Offset(center.dx - bodyRadius * 0.5, earY),
      earSize,
      earPaint,
    );
    canvas.drawCircle(
      Offset(center.dx - bodyRadius * 0.5, earY),
      earSize * 0.6,
      innerEarPaint,
    );
    
    // Right ear
    canvas.drawCircle(
      Offset(center.dx + bodyRadius * 0.5, earY),
      earSize,
      earPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + bodyRadius * 0.5, earY),
      earSize * 0.6,
      innerEarPaint,
    );
  }

  void _drawAccessory(Canvas canvas, Offset center, double bodyRadius) {
    // Simple hat or bow tie for higher level pets
    final accessoryPaint = Paint()
      ..color = Colors.blue.shade400
      ..style = PaintingStyle.fill;
    
    if (pet.level >= 10) {
      // Draw a simple hat
      final hatRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy - bodyRadius * 0.9),
        width: bodyRadius * 0.8,
        height: bodyRadius * 0.3,
      );
      canvas.drawOval(hatRect, accessoryPaint);
    } else {
      // Draw a bow tie
      final bowTieRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + bodyRadius * 0.6),
        width: bodyRadius * 0.3,
        height: bodyRadius * 0.15,
      );
      canvas.drawOval(bowTieRect, accessoryPaint);
    }
  }

  @override
  bool shouldRepaint(PetPainter oldDelegate) {
    return oldDelegate.pet != pet || oldDelegate.blinkAmount != blinkAmount;
  }
}

class PetColors {
  final Color primary;
  final Color secondary;
  final Color accent;

  PetColors({
    required this.primary,
    required this.secondary,
    required this.accent,
  });
}