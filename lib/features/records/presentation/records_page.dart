import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../domain/health_summary.dart';
import 'records_cubit.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecordsCubit(sl())..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Health records', style: TextStyle(fontWeight: FontWeight.w700))),
        body: BlocBuilder<RecordsCubit, RecordsState>(
          builder: (context, state) => switch (state) {
            RecordsLoading() => const Center(child: CircularProgressIndicator()),
            RecordsError() => const Center(child: Text('Could not load records')),
            RecordsLoaded(:final summary) => _RecordsView(summary: summary),
          },
        ),
      ),
    );
  }
}

class _RecordsView extends StatelessWidget {
  const _RecordsView({required this.summary});
  final HealthSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.98,
          children: [for (final v in summary.vitals) VitalCard(vital: v)],
        ),
        const SizedBox(height: 20),
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Steps this week', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const Spacer(),
                  Text('avg ${NumberFormat.decimalPattern().format(summary.stepsAverage)}',
                      style: const TextStyle(color: AppColors.muted)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(height: 130, child: _StepsChart(steps: summary.weeklySteps)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader('Prescriptions'),
        const SizedBox(height: 4),
        for (final p in summary.prescriptions) ...[
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: AppColors.violet.fade(0.12), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.medication_rounded, color: AppColors.violet),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(p.dosage, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                    ],
                  ),
                ),
                Pill('${p.daysLeft} days left', color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

extension on VitalKind {
  (IconData, Color) get style => switch (this) {
        VitalKind.heartRate => (Icons.favorite_rounded, AppColors.coral),
        VitalKind.bloodPressure => (Icons.monitor_heart_rounded, AppColors.indigo),
        VitalKind.bloodSugar => (Icons.water_drop_rounded, AppColors.amber),
        VitalKind.sleep => (Icons.bedtime_rounded, AppColors.violet),
      };
}

class VitalCard extends StatelessWidget {
  const VitalCard({super.key, required this.vital});
  final Vital vital;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = vital.kind.style;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: color.fade(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(vital.status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(vital.title, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          Text.rich(TextSpan(children: [
            TextSpan(text: vital.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            if (vital.unit.isNotEmpty)
              TextSpan(text: ' ${vital.unit}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ])),
          const Spacer(),
          SizedBox(height: 34, width: double.infinity, child: CustomPaint(painter: SparklinePainter(vital.history, color))),
        ],
      ),
    );
  }
}

/// Smooth sparkline with a soft gradient fill.
class SparklinePainter extends CustomPainter {
  SparklinePainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : maxV - minV;
    final points = [
      for (var i = 0; i < values.length; i++)
        Offset(size.width * i / (values.length - 1), size.height - (values[i] - minV) / range * size.height * 0.85 - 2),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final mid = (p0.dx + p1.dx) / 2;
      path.cubicTo(mid, p0.dy, mid, p1.dy, p1.dx, p1.dy);
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          colors: [color.fade(0.25), color.fade(0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(points.last, 3.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(SparklinePainter old) => old.values != values || old.color != color;
}

class _StepsChart extends StatelessWidget {
  const _StepsChart({required this.steps});
  final List<int> steps;

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxSteps = steps.isEmpty ? 1 : steps.reduce(math.max);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < steps.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 100 * steps[i] / maxSteps * t,
                    margin: const EdgeInsets.symmetric(horizontal: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: steps[i] == maxSteps
                            ? const [AppColors.primary, AppColors.sky]
                            : [AppColors.primary.fade(0.35), AppColors.primary.fade(0.2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(labels[i % 7], style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
