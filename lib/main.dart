import 'dart:async';

import 'package:blog/Utilities/constant.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/edit_update_screen.dart';
import 'Screens/saved_post_screen.dart';
import 'Screens/show_my_blogs.dart';
import 'Authentication/authentication.dart';
import 'Utilities/card_widgets.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar overlay
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  final AuthMethods authMethods = AuthMethods();
  Widget homeWidget = await authMethods.checkIfAlreadyLogin();
  runApp(MyApp(homeWidget: homeWidget));
}

class MyApp extends StatelessWidget {
  final Widget homeWidget;

  const MyApp({super.key, required this.homeWidget});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlogScape',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          primary: kPrimaryColor,
          secondary: kAccentColor,
          surface: kSurfaceColor,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: kBackgroundColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: kTitleStyle,
          iconTheme: const IconThemeData(color: kTextPrimary),
        ),
        cardTheme: CardThemeData(
          color: kSurfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kCardRadius),
            side: const BorderSide(color: kInputBorder, width: 1),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: homeWidget,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  int _selectedIndex = 0;
  late SharedPreferences logindata;
  AuthMethods authMethods = AuthMethods();

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    logindata = await SharedPreferences.getInstance();
    if (mounted) setState(() {});
  }

  void _initConnectivity() {
    // Initial check
    InternetConnectionChecker().hasConnection.then((connected) {
      if (!connected && mounted) {
        _showNoConnectionDialog();
        setState(() => isAlertSet = true);
      }
    });

    // Listener
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      isDeviceConnected = status == InternetConnectionStatus.connected;
      if (!isDeviceConnected && !isAlertSet && mounted) {
        _showNoConnectionDialog();
        setState(() => isAlertSet = true);
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showNoConnectionDialog() {
    showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('No Connection'),
        content: const Text('Please check your internet connectivity'),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.pop(context, 'OK');
              setState(() => isAlertSet = false);
              bool connected = await InternetConnectionChecker().hasConnection;
              if (!connected && mounted) {
                _showNoConnectionDialog();
                setState(() => isAlertSet = true);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildPageContent(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PostEditor(isEdit: false),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 24),
              label: const Text('Write', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kSurfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: kTextPrimary,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.auto_stories_outlined, Icons.auto_stories, 'Feed'),
                  _buildNavItem(1, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
                  _buildNavItem(2, Icons.bookmark_outline_rounded, Icons.bookmark_rounded, 'Saved'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : kTextLight,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return const BlogList();
      case 1:
        return const ShowMyBlogPost();
      case 2:
        return SavedPostsScreen(
          userId: logindata.getString('userId') ?? "",
        );
      default:
        return const SizedBox();
    }
  }
}
