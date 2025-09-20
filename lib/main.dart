import 'package:ecommerce_app/common_widgets/main_screen.dart';
import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/address/bloc/address_bloc.dart';
import 'package:ecommerce_app/features/address/data/repositories/user_address_repository_impl.dart';
import 'package:ecommerce_app/features/auth/bloc/auth_bloc.dart';
import 'package:ecommerce_app/features/auth/service/session_manager.dart';
import 'package:ecommerce_app/core/theme/theme_app.dart';
import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/data/local/hive_product_setup.dart';
import 'package:ecommerce_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:ecommerce_app/features/product/domain/usecase/get_products_is_active.dart';
import 'package:ecommerce_app/features/profile/bloc/profile_bloc.dart';
import 'package:ecommerce_app/features/profile/data/local/hive_profile_setup.dart';
import 'package:ecommerce_app/features/splash/presentation/splash_screen.dart';
import 'package:ecommerce_app/service/auth_deep_link_handler.dart';
import 'package:ecommerce_app/service/deep_link_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  try {
    await dotenv.load(fileName: ".env");
    await SupabaseConfig.initialize();
    await HiveProfileSetup.initHive();
    await HiveProductSetup.initialize();
    await SessionManager.initialize();

    await DeepLinkService().initialize();
    final session = await SessionManager.restoreSession();

    // Đặt lại chế độ immersive sau khi khởi tạo xong
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    runApp(MyApp(hasSession: session != null));
  } catch (e) {
    print('Error during app initialization: $e');
    runApp(MyApp(hasSession: false));
  }
}

class MyApp extends StatefulWidget {
  final bool hasSession;
  const MyApp({Key? key, required this.hasSession}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => AuthDeepLinkHandler.initialize(context));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        Provider(
          create: (context) =>
              UserAddressRepositoryImpl(), // Hoặc tên class của bạn
        ),
        BlocProvider(
          create: (context) => AddressBloc(
            context.read<UserAddressRepositoryImpl>(),
          ),
        ),
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(),
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
        home: Builder(
          builder: (context) {
            return widget.hasSession
                ? const MainScreen()
                : const SplashScreen();
          },
        ),
      ),
    );
  }
}
