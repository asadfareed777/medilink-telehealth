import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injector.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/appointments/presentation/cubit/appointments_cubit.dart';
import 'features/doctors/presentation/bloc/doctors_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MediLinkApp());
}

class MediLinkApp extends StatelessWidget {
  const MediLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DoctorsBloc(sl())..add(const DoctorsRequested())),
        BlocProvider(create: (_) => AppointmentsCubit(sl(), clock: sl())..start()),
      ],
      child: MaterialApp.router(
        title: 'MediLink',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
