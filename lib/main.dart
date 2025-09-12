import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/auth/bloc/auth_bloc.dart';
import 'package:ecommerce_app/features/auth/service/session_manager.dart';
import 'package:ecommerce_app/core/theme/theme_app.dart';
import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/data/local/hive_product_setup.dart';
import 'package:ecommerce_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:ecommerce_app/features/product/domain/usecase/get_products_is_active.dart';
import 'package:ecommerce_app/features/product/presentation/home_page.dart';
import 'package:ecommerce_app/features/profile/data/local/hive_profile_setup.dart';
import 'package:ecommerce_app/features/splash/presentation/splash_screen.dart';
import 'package:ecommerce_app/service/auth_deep_link_handler.dart';
import 'package:ecommerce_app/service/deep_link_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    await SupabaseConfig.initialize();
    await HiveProfileSetup.initHive();
    await HiveProductSetup.initialize();
    await SessionManager.initialize();

    await DeepLinkService().initialize();
    final session = await SessionManager.restoreSession();
    runApp(MyApp(hasSession: session != null));
  } catch (e) {
    print('Error during app initialization: $e');
    runApp(MyApp(hasSession: false));
  }
}

class MyApp extends StatelessWidget {
  final bool hasSession;
  const MyApp({Key? key, required this.hasSession}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        Provider(
          create: (context) => ProductRemoteDataSourceImpl(),
        ),
        Provider(
          create: (context) => GetProductsIsActive(
            context.read<ProductRemoteDataSourceImpl>(),
          ),
        ),
        BlocProvider(
            create: (context) => ProductBloc(
                  getProductsIsActiveUseCase:
                      context.read<GetProductsIsActive>(),
                )..add(GetProductIsActive()))
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: appTheme,
          home: Builder(builder: (context) {
            AuthDeepLinkHandler.initialize(context);
            return hasSession ? const HomePage() : const SplashScreen();
          })),
    );
  }
}
