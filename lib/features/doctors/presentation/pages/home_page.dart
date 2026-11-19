import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common.dart';
import '../../../appointments/domain/appointment.dart';
import '../../../appointments/presentation/cubit/appointments_cubit.dart';
import '../../domain/doctor.dart';
import '../bloc/doctors_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverList.list(
                children: [
                  const _Header(),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (q) => context.read<DoctorsBloc>().add(SearchChanged(q)),
                    decoration: const InputDecoration(
                      hintText: 'Search doctors, specialties, hospitals',
                      prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AppointmentsCubit, AppointmentsState>(
                    builder: (context, state) {
                      final next = state.next;
                      return next == null ? const SizedBox.shrink() : _UpcomingCard(appointment: next);
                    },
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader('Specialties'),
                  const SizedBox(height: 8),
                  const _SpecialtyStrip(),
                  const SizedBox(height: 20),
                  const SectionHeader('Top doctors'),
                ],
              ),
            ),
            BlocBuilder<DoctorsBloc, DoctorsState>(
              builder: (context, state) {
                if (state.status == DoctorsStatus.loading || state.status == DoctorsStatus.initial) {
                  return const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
                  );
                }
                if (state.status == DoctorsStatus.failure) {
                  return const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Could not load doctors'))),
                  );
                }
                final doctors = state.visible;
                if (doctors.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No doctors match your search', style: TextStyle(color: AppColors.muted))),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  sliver: SliverList.separated(
                    itemCount: doctors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => DoctorCard(doctor: doctors[i]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
    return Row(
      children: [
        const InitialsAvatar(id: 'me', initials: 'AF', size: 48, radius: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting 👋', style: const TextStyle(color: AppColors.muted, fontSize: 14)),
              const Text('Asad Fareed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final d = appointment.doctor;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.fade(0.3), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upcoming consultation',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: Colors.white.fade(0.3), borderRadius: BorderRadius.circular(18)),
                child: InitialsAvatar(id: d.id, initials: d.initials, size: 52),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                    Text(d.specialty.label, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Icon(
                appointment.type == ConsultationType.video ? Icons.videocam_rounded : Icons.local_hospital_rounded,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.fade(0.16), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DateFormat('EEE, d MMM').format(appointment.start),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.access_time_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(DateFormat('h:mm a').format(appointment.start),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (appointment.type == ConsultationType.video) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => context.push(Routes.call(appointment.id)),
                icon: const Icon(Icons.videocam_rounded),
                label: const Text('Join video call'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecialtyStrip extends StatelessWidget {
  const _SpecialtyStrip();

  @override
  Widget build(BuildContext context) {
    final selected = context.select((DoctorsBloc b) => b.state.specialty);
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: Specialty.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final s = Specialty.values[i];
          final isOn = s == selected;
          return GestureDetector(
            onTap: () => context.read<DoctorsBloc>().add(SpecialtyToggled(s)),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isOn ? s.color : s.color.fade(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(s.icon, color: isOn ? Colors.white : s.color, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOn ? AppColors.text : AppColors.muted,
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

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(Routes.doctor(doctor.id)),
      child: Row(
        children: [
          InitialsAvatar(id: doctor.id, initials: doctor.initials, size: 64),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(doctor.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, size: 16, color: AppColors.sky),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${doctor.specialty.label} · ${doctor.hospital}',
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.amber, size: 18),
                    Text(' ${doctor.rating}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Expanded(
                      child: Text(' (${doctor.reviews})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    ),
                    if (doctor.availableToday) const Pill('Today', color: AppColors.green),
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
