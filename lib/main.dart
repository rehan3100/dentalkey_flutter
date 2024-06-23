// C:\Users\wkhan\dentalkey\lib\main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'unread_provider.dart';
import 'notification_provider.dart';
import 'splash_screen.dart';
import 'dart:io';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await FlutterDownloader.initialize(
      debug: false,
    );
  }
  await _checkPermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UnreadProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MyApp(),
    ),
  );
}

Future<void> _checkPermissions() async {
  if (Platform.isAndroid) {
    if (await Permission.phone.request().isGranted) {
      print('Phone permission granted');
    } else {
      print('Phone permission denied');
    }

    if (await Permission.location.request().isGranted) {
      print('Location permission granted');
    } else {
      print('Location permission denied');
    }

    if (await Permission.storage.request().isGranted) {
      print('Storage permission granted');
    } else {
      print('Storage permission denied');
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dental Key',
      debugShowCheckedModeBanner:
          false, // Add this line to remove the debug banner
      theme: ThemeData(
        primaryColor: const Color(0xFF385A92),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: const Color(0xFFFFA726)),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          color: Color(0xFF385A92),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          toolbarHeight: 50,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey;
                } else if (states.contains(MaterialState.hovered)) {
                  return Color(0xFFFFFFFF);
                }
                return const Color(0xFF385A92);
              },
            ),
            side: MaterialStateProperty.resolveWith<BorderSide>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return const BorderSide(
                    color: Color(0xFF9E9E9E),
                    width: 2.0,
                  );
                } else if (states.contains(MaterialState.hovered)) {
                  return const BorderSide(
                    color: Color.fromARGB(255, 255, 255, 255),
                    width: 2.0,
                  );
                }
                return const BorderSide(
                  color: Color(0xFF385A92),
                  width: 2.0,
                );
              },
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(
              const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
            overlayColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return Colors.transparent;
                }
                return Colors.white;
              },
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return const Color(0xFF385A92);
                } else if (states.contains(MaterialState.hovered)) {
                  return const Color(0xFF385A92);
                }
                return Colors.white;
              },
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(const Color(0xFF385A92)),
            textStyle: MaterialStateProperty.all(
              const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Color(0xFF385A92),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xFF385A92),
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: Color(0xFF385A92),
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: Color(0xFF385A92),
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: Color(0xFF385A92),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: TextStyle(
            color: Color(0xFF385A92),
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF385A92),
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
          titleSmall: TextStyle(
            color: Colors.black,
            fontSize: 14.0,
          ),
          bodyLarge: TextStyle(
            color: Colors.black,
            fontSize: 14.0,
          ),
          bodyMedium: TextStyle(
            color: Colors.black,
            fontSize: 12.0,
          ),
          labelLarge: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
          bodySmall: TextStyle(
            color: Colors.grey,
            fontSize: 12.0,
          ),
          labelSmall: TextStyle(
            color: Colors.grey,
            fontSize: 10.0,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF385A92),
          size: 24.0,
        ),
        cardTheme: CardTheme(
          color: Color.fromARGB(255, 255, 255, 255),
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: const EdgeInsets.all(8.0),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF385A92), width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF385A92), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF385A92), width: 2.0),
          ),
          labelStyle: const TextStyle(color: Color(0xFF385A92)),
          hintStyle: const TextStyle(color: Colors.grey),
          errorStyle: const TextStyle(color: Colors.red),
          prefixStyle: const TextStyle(color: Color(0xFF385A92)),
          suffixStyle: const TextStyle(color: Color(0xFF385A92)),
          counterStyle: const TextStyle(color: Color(0xFF385A92)),
          helperStyle: const TextStyle(color: Colors.grey),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // Set the desired background color
          selectedItemColor: Color(0xFF385A92),
          unselectedItemColor: Color.fromARGB(255, 115, 115, 115),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class LoadingButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onPressed;

  const LoadingButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePress,
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.0,
              ),
            )
          : Text(widget.text),
    );
  }

  Future<void> _handlePress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
