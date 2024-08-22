import 'package:blog/Screens/showMyBlogs.dart';
import 'package:blog/Screens/splashScreen.dart';
import 'package:blog/Services/Auth.dart';
import 'package:blog/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationDrawers extends StatefulWidget {
  const NavigationDrawers({Key? key}) : super(key: key);

  @override
  _NavigationDrawersState createState() => _NavigationDrawersState();
}

class _NavigationDrawersState extends State<NavigationDrawers> {
  late SharedPreferences logindata;
  AuthMethods authMethods = AuthMethods();

  var email = "";
  var name = "";
  var pImage = "";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      email = logindata.getString("email") ?? "";
      name = logindata.getString("name") ?? "";
      pImage = logindata.getString("imgUrl") ?? "";
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
          break;
        }
      case 1:
        {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const showMyBlogPost()),
          );
          break;
        }
      case 2:
        {
          _showLogoutDialog(context);
          break;
        }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showPlatformDialog<String>(
      context: context,
      builder: (BuildContext context) => PlatformAlertDialog(
        title: const Text('Alert'),
        content: const Text('Are you sure you want to logout from this app?'),
        actions: <Widget>[
          PlatformDialogAction(
            child: PlatformText('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          PlatformDialogAction(
            child: PlatformText('Ok'),
            onPressed: () async {
              await logindata.clear();
              authMethods.logout(context);
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                platformPageRoute(
                  context: context,
                  builder: (context) => const SplashScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _selectedIndex == 0
            ? const MainPage()
            : _selectedIndex == 1
                ? const showMyBlogPost()
                : const SizedBox.shrink(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_sharp),
            label: 'Logout',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueGrey,
        onTap: _onItemTapped,
      ),
    );
  }
}
