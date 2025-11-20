import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';
import 'features/system_stats/data/repositories/system_stats_repository.dart';
import 'features/system_stats/presentation/cubit/system_stats_cubit.dart';
import 'features/system_stats/presentation/screens/task_manager_screen.dart';

Future<void> main() async {
  // Initialize Flutter bindings first to ensure the binary messenger is ready
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop controls
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Vaxmanager');
    const fixedSize = Size(655, 920);
    setWindowMinSize(fixedSize);
    setWindowMaxSize(fixedSize);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        brightness: Brightness.dark,
      ),
      home: BlocProvider(
        create: (context) => SystemStatsCubit(SystemStatsRepository()),
        child: const vaxmanegrScreen(),
      ),
    );
  }
}
