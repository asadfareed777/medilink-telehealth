import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common.dart';
import '../../domain/appointment.dart';
import '../cubit/appointments_cubit.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My appointments', style: TextStyle(fontWeight: FontWeight.w700)),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(64),
            child: Padding(padding: EdgeInsets.fromLTRB(20, 4, 20, 12), child: _Tabs()),
          ),
        ),
        body: BlocBuilder<AppointmentsCubit, AppointmentsState>(
          builder: (context, state) => TabBarView(
            children: [
              _AppointmentList(items: state.upcoming, upcoming: true, cancellingId: state.cancellingId),
              _AppointmentList(items: state.past, upcoming: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.muted,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({required this.items, required this.upcoming, this.cancellingId});

  final List<Appointment> items;
  final bool upcoming;
  final String? cancellingId;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_available_rounded, size: 64, color: AppColors.border),
            const SizedBox(height: 12),
            Text(upcoming ? 'No upcoming appointments' : 'No past appointments',
                style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _AppointmentCard(appointment: items[i], cancelling: items[i].id == cancellingId),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, this.cancelling = false});

  final Appointment appointment;
  final bool cancelling;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final isUpcoming = a.status == AppointmentStatus.upcoming;
    final (statusLabel, statusColor) = switch (a.status) {
      AppointmentStatus.upcoming => ('Confirmed', AppColors.green),
      AppointmentStatus.completed => ('Completed', AppColors.sky),
      AppointmentStatus.cancelled => ('Cancelled', AppColors.coral),
    };
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(id: a.doctor.id, initials: a.doctor.initials, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.doctor.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text(a.doctor.specialty.label, style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
              Pill(statusLabel, color: statusColor),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1, color: AppColors.border)),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.muted),
              const SizedBox(width: 6),
              Text(DateFormat('EEE, d MMM').format(a.start), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded, size: 16, color: AppColors.muted),
              const SizedBox(width: 6),
              Text(DateFormat('h:mm a').format(a.start), style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Icon(a.type == ConsultationType.video ? Icons.videocam_rounded : Icons.local_hospital_rounded,
                  size: 18, color: AppColors.primary),
            ],
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: cancelling ? null : () => context.read<AppointmentsCubit>().cancel(a.id),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      side: const BorderSide(color: AppColors.border),
                      foregroundColor: AppColors.text,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(cancelling ? 'Cancelling…' : 'Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                    onPressed: a.type == ConsultationType.video ? () => context.push(Routes.call(a.id)) : () {},
                    child: Text(a.type == ConsultationType.video ? 'Join call' : 'Directions'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
