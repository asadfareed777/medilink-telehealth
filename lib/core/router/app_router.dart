import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/consultation/presentation/consultation_page.dart';
import '../../features/doctors/presentation/pages/doctor_detail_page.dart';
import '../../features/doctors/presentation/pages/home_page.dart';
import '../../features/records/presentation/records_page.dart';

abstract final class Routes {
  static const home = '/home';
  static const appointments = '/appointments';
  static const records = '/records';
  static String doctor(String id) => '/doctor/$id';
  static String call(String appointmentId) => '/call/$appointmentId';
}

final appRouter = GoRouter(
  initialLocation: Routes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: Routes.home, builder: (_, __) => const HomePage())]),
        StatefulShellBranch(
          routes: [GoRoute(path: Routes.appointments, builder: (_, __) => const AppointmentsPage())],
        ),
        StatefulShellBranch(routes: [GoRoute(path: Routes.records, builder: (_, __) => const RecordsPage())]),
      ],
    ),
    GoRoute(
      path: '/doctor/:id',
      builder: (_, state) => DoctorDetailPage(doctorId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/call/:id',
      pageBuilder: (_, state) => MaterialPage(
        fullscreenDialog: true,
        child: ConsultationPage(appointmentId: state.pathParameters['id']!),
      ),
    ),
  ],
);

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart_rounded),
            label: 'Records',
          ),
        ],
      ),
    );
  }
}
