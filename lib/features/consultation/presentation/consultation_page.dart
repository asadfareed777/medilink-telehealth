import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../appointments/domain/appointment_repository.dart';
import 'call_cubit.dart';

class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  Widget build(BuildContext context) {
    final appointment = sl<AppointmentRepository>().byId(appointmentId);
    if (appointment == null) {
      return const Scaffold(body: Center(child: Text('Consultation not found')));
    }
    final doctor = appointment.doctor;

    return BlocProvider(
      create: (_) => CallCubit()..start(),
      child: BlocConsumer<CallCubit, CallState>(
        listenWhen: (a, b) => b.phase == CallPhase.ended && a.phase != b.phase,
        listener: (context, _) => context.pop(),
        builder: (context, call) {
          final cubit = context.read<CallCubit>();
          return Scaffold(
            backgroundColor: AppColors.callBackground,
            body: Stack(
              children: [
                // Remote video placeholder
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F3D46), Color(0xFF14284B), Color(0xFF0B1220)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InitialsAvatar(id: doctor.id, initials: doctor.initials, size: 140, radius: 70),
                          const SizedBox(height: 20),
                          if (call.phase == CallPhase.connecting) ...[
                            const Text('Connecting…', style: TextStyle(color: Colors.white70, fontSize: 16)),
                            const SizedBox(height: 12),
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Top bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        _RoundButton(icon: Icons.keyboard_arrow_down_rounded, onTap: () => context.pop()),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doctor.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: call.phase == CallPhase.live ? AppColors.green : AppColors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    call.phase == CallPhase.live ? call.timer : 'Calling',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.lock_rounded, color: Colors.white54, size: 16),
                        const SizedBox(width: 4),
                        const Text('End-to-end encrypted', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                // Self preview
                Positioned(
                  right: 16,
                  top: MediaQuery.paddingOf(context).top + 76,
                  child: Container(
                    width: 108,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 1.5),
                    ),
                    child: Center(
                      child: call.cameraOn
                          ? const InitialsAvatar(id: 'me', initials: 'AF', size: 56, radius: 28)
                          : const Icon(Icons.videocam_off_rounded, color: Colors.white54),
                    ),
                  ),
                ),
                // Controls
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.fade(0.08),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _RoundButton(
                            icon: call.micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                            active: !call.micOn,
                            onTap: cubit.toggleMic,
                          ),
                          _RoundButton(
                            icon: call.cameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                            active: !call.cameraOn,
                            onTap: cubit.toggleCamera,
                          ),
                          _RoundButton(
                            icon: Icons.call_end_rounded,
                            background: AppColors.coral,
                            size: 64,
                            onTap: cubit.hangUp,
                          ),
                          _RoundButton(icon: Icons.cameraswitch_rounded, onTap: cubit.flipCamera),
                          _RoundButton(icon: Icons.chat_bubble_rounded, onTap: () {}),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap, this.active = false, this.background, this.size = 52});

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final Color? background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background ?? (active ? Colors.white : Colors.white.fade(0.12)),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: active ? AppColors.callBackground : Colors.white),
        ),
      ),
    );
  }
}
