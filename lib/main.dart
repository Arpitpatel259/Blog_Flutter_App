// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:blog/Screens/PostEditor.dart';
import 'package:blog/Screens/splashScreen.dart';
import 'package:blog/Utilities/cardwidgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Authentication/userLogin.dart';
import 'Screens/NavigationDrawers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.black),
          bodyText2: TextStyle(color: Colors.black),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white),
          prefixIconColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey,
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white),
          prefixIconColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      check_if_already_login(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> check_if_already_login(BuildContext context) async {
    try {
      // Initialize Firebase
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.web,
        );
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isLoggedIn = prefs.getBool('isLoggedIn');

      if (isLoggedIn == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
              (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking login status: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'An error occurred while checking login status. Please try again.'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            disabledTextColor: Colors.white,
            textColor: Colors.yellow,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.blueGrey),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 50.0,
                      child: Icon(
                        Icons.work,
                        color: Colors.black,
                        size: 50.0,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 10.0)),
                    Text(
                      "Find Your Own Blogs",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getConnectivity();
    });
  }

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            setState(() => isAlertSet = true);
          }
        },
      );

  @override
  void dispose() {
    subscription.cancel();
    // Ensure you call super.dispose() to clean up resources
    super.dispose();
  }

  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('No Connection'),
          content: const Text('Please check your internet connectivity'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawers(),
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Blogs',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: const BlogList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostEditor()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
