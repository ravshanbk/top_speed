import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:top_speed/l10n/app_localizations.dart';

import 'app/router.dart';
import 'core/services/speed_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/settings/cubit/settings_state.dart';
import 'features/tracking/bloc/tracking_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
    ),
  );

  final storage = StorageService();
  await storage.init();

  runApp(TopSpeedApp(storage: storage));
}

class TopSpeedApp extends StatelessWidget {
  final StorageService storage;
  const TopSpeedApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StorageService>.value(value: storage),
      ],
      child: BlocProvider(
        create: (_) => SettingsCubit(storage),
        child: BlocProvider(
          create: (context) => TrackingBloc(
            speedService: SpeedService(),
            storage: storage,
            settings: context.read<SettingsCubit>(),
          ),
          child: BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (prev, curr) => prev.locale != curr.locale,
            builder: (context, settings) {
              return MaterialApp.router(
                title: 'Top Speed',
                theme: buildAppTheme(),
                debugShowCheckedModeBanner: false,
                routerConfig: appRouter,
                locale: settings.locale,
                supportedLocales: const [
                  Locale('en'),
                  Locale('ru'),
                  Locale('uz'),
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
