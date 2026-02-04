import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();
  
  final authProvider = AuthProvider();
  await authProvider.loadCurrentUser();
  
  runApp(MyApp(
    authProvider: authProvider,
    themeProvider: themeProvider,
  ));
}

class MyApp extends StatefulWidget {
  final AuthProvider authProvider;
  final ThemeProvider themeProvider;

  const MyApp({
    required this.authProvider,
    required this.themeProvider,
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authProvider),
        ChangeNotifierProvider.value(value: widget.themeProvider),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, auth, theme, _) {
          final currentTheme = theme.isDarkMode ? theme.getDarkTheme() : theme.getLightTheme();
          return AnimatedTheme(
            data: currentTheme,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: MaterialApp(
              title: 'CA Client Manager',
              debugShowCheckedModeBanner: false,
              theme: theme.getLightTheme(),
              darkTheme: theme.getDarkTheme(),
              themeMode: theme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: auth.isAuthenticated ? const HomePage() : const LoginPage(),
            ),
          );
        },
      ),
    );
  }
}
