import 'package:flutter/material.dart';

import '../../features/doctors/domain/doctor.dart';
import '../theme/app_theme.dart';

const _avatarPalettes = [
  [Color(0xFF0FA3A3), Color(0xFF14B8A6)],
  [Color(0xFF4F46E5), Color(0xFF818CF8)],
  [Color(0xFFF43F5E), Color(0xFFFB7185)],
  [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
  [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
];

/// Gradient initials avatar. Deterministic colour per id so a doctor keeps the same look.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.id, required this.initials, this.size = 56, this.radius});

  final String id;
  final String initials;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final seed = id.codeUnits.fold<int>(0, (a, b) => a + b);
    final palette = _avatarPalettes[seed % _avatarPalettes.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? size * 0.32),
        gradient: LinearGradient(colors: palette, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Text(
        initials,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.34),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(action!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.fade(0.12), borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

extension SpecialtyUi on Specialty {
  IconData get icon => switch (this) {
        Specialty.general => Icons.medical_services_rounded,
        Specialty.cardiology => Icons.favorite_rounded,
        Specialty.dermatology => Icons.face_rounded,
        Specialty.pediatrics => Icons.child_care_rounded,
        Specialty.neurology => Icons.psychology_rounded,
        Specialty.orthopedics => Icons.accessibility_new_rounded,
      };

  Color get color => switch (this) {
        Specialty.general => AppColors.primary,
        Specialty.cardiology => AppColors.coral,
        Specialty.dermatology => AppColors.amber,
        Specialty.pediatrics => AppColors.sky,
        Specialty.neurology => AppColors.violet,
        Specialty.orthopedics => AppColors.indigo,
      };
}
