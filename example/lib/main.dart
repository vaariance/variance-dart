import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:variancedemo/providers/account_providers.dart';
import 'package:variancedemo/providers/module_provider.dart';
import 'package:variancedemo/providers/wallet_provider.dart';
import 'package:variancedemo/screens/create_account.dart';
import 'package:variancedemo/screens/home/home_screen.dart';
import 'package:variancedemo/screens/initial_page.dart';

final globalScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => WalletProvider()),
    ChangeNotifierProvider(create: (_) => AccountProvider()),
    ProxyProvider<WalletProvider, ModuleProvider?>(
      update: (context, walletProvider, previous) {
        if (walletProvider.wallet == null) {
          return previous;
        }
        return ModuleProvider(walletProvider.wallet!);
      },
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: MaterialApp(
        title: 'Variance Dart',
        routes: {
          '/': (context) => const InitialPage(),
          '/create-account': (context) => const CreateAccountScreen(),
          '/home': (context) => const HomeScreen(),
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffE1FF01)),
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
