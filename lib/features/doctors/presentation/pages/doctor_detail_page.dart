import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common.dart';
import '../../../appointments/domain/appointment.dart';
import '../../../appointments/presentation/cubit/booking_cubit.dart';
import '../../domain/doctor.dart';

class DoctorDetailPage extends StatelessWidget {
  const DoctorDetailPage({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingCubit(doctors: sl(), appointments: sl(), clock: sl())..load(doctorId),
      child: const _DoctorDetailView(),
    );
  }
}

class _DoctorDetailView extends StatelessWidget {
  const _DoctorDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listenWhen: (a, b) => a.status != b.status || a.error != b.error,
      listener: (context, state) {
        if (state.status == BookingStatus.success && state.booked != null) {
          _showConfirmation(context, state.booked!);
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final doctor = state.doctor;
        if (doctor == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: state.status == BookingStatus.failure
                  ? const Text('Doctor not found')
                  : const CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Doctor profile'), actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_rounded)),
          ]),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _ProfileHeader(doctor: doctor),
              const SizedBox(height: 16),
              _Stats(doctor: doctor),
              const SizedBox(height: 24),
              const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(doctor.about, style: const TextStyle(color: AppColors.muted, height: 1.5)),
              const SizedBox(height: 24),
              const Text('Consultation type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _TypeSelector(selected: state.type),
              const SizedBox(height: 24),
              Text(DateFormat('MMMM yyyy').format(state.selectedDay ?? DateTime.now()),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _DayPicker(days: state.days, selected: state.selectedDay),
              const SizedBox(height: 20),
              const Text('Available time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _SlotGrid(state: state),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: FilledButton(
                onPressed: state.canConfirm ? () => context.read<BookingCubit>().confirm() : null,
                child: state.status == BookingStatus.submitting
                    ? const SizedBox(
                        width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : Text('Book appointment · \$${doctor.fee}'),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showConfirmation(BuildContext context, Appointment a) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: AppColors.primary.fade(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 56),
            ),
            const SizedBox(height: 20),
            const Text('Appointment booked!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              '${a.doctor.name} · ${a.type.label}\n${DateFormat('EEEE, d MMM · h:mm a').format(a.start)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.go(Routes.appointments);
              },
              child: const Text('View my appointments'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          InitialsAvatar(id: doctor.id, initials: doctor.initials, size: 84),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Pill(doctor.specialty.label, color: doctor.specialty.color, icon: doctor.specialty.icon),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(doctor.hospital,
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.people_alt_rounded, '${(doctor.patients / 1000).toStringAsFixed(1)}k+', 'Patients', AppColors.sky),
      (Icons.work_outline_rounded, '${doctor.yearsExperience} yrs', 'Experience', AppColors.violet),
      (Icons.star_rounded, '${doctor.rating}', 'Rating', AppColors.amber),
      (Icons.chat_bubble_rounded, '${doctor.reviews}', 'Reviews', AppColors.coral),
    ];
    return Row(
      children: [
        for (final (icon, value, label, color) in items)
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: color.fade(0.12), shape: BoxShape.circle),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected});
  final ConsultationType selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final type in ConsultationType.values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<BookingCubit>().selectType(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: type == selected ? AppColors.primary.fade(0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: type == selected ? AppColors.primary : AppColors.border,
                    width: type == selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type == ConsultationType.video ? Icons.videocam_rounded : Icons.local_hospital_rounded,
                      color: type == selected ? AppColors.primary : AppColors.muted,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(type.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: type == selected ? AppColors.primary : AppColors.muted,
                        )),
                  ],
                ),
              ),
            ),
          ),
          if (type != ConsultationType.values.last) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.days, required this.selected});
  final List<DateTime> days;
  final DateTime? selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final day = days[i];
          final isOn = day == selected;
          return GestureDetector(
            onTap: () => context.read<BookingCubit>().selectDay(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 60,
              decoration: BoxDecoration(
                color: isOn ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isOn ? AppColors.primary : AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE').format(day),
                      style: TextStyle(fontSize: 12, color: isOn ? Colors.white70 : AppColors.muted)),
                  const SizedBox(height: 4),
                  Text('${day.day}',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700, color: isOn ? Colors.white : AppColors.text)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({required this.state});
  final BookingState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == BookingStatus.loading) {
      return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
    }
    if (state.slots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('No free slots on this day. Try another date.', style: TextStyle(color: AppColors.muted)),
      );
    }
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.9,
      children: [
        for (final slot in state.slots)
          GestureDetector(
            onTap: () => context.read<BookingCubit>().selectSlot(slot),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: slot == state.selectedSlot ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: slot == state.selectedSlot ? AppColors.primary : AppColors.border),
              ),
              child: Text(
                DateFormat('h:mm a').format(slot),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: slot == state.selectedSlot ? Colors.white : AppColors.text,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
