import 'package:blog/Screens/showMyBlogs.dart';
import 'package:blog/Screens/splashScreen.dart';
import 'package:blog/Services/Auth.dart';
import 'package:blog/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'UserAppSetting.dart';

class NavigationDrawers extends StatefulWidget {
  const NavigationDrawers({Key? key}) : super(key: key);

  @override
  _NavigationDrawer createState() => _NavigationDrawer();
}

class _NavigationDrawer extends State<NavigationDrawers> {
  final padding = const EdgeInsets.symmetric(horizontal: 20);

  late SharedPreferences logindata;
  late bool newuser;
  AuthMethods authMethods = AuthMethods();

  var email = "";
  var name = "";
  var pImage = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      newuser = (logindata.getBool('isLoggedIn') ?? false);
      email = logindata.getString("email") ?? "";
      name = logindata.getString("name") ?? "";
      pImage = logindata.getString("imgUrl") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey, Colors.blueGrey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 10),
            Padding(
              padding: padding,
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blueGrey,
                ),
                accountName: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'SF Pro',
                    ),
                    children: [
                      const TextSpan(
                        text: 'Welcome, ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: name,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ],
                  ),
                ),
                accountEmail: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'CustomFont',
                    ),
                    children: [
                      TextSpan(
                        text: email,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ],
                  ),
                ),
                currentAccountPicture: ClipOval(
                  clipBehavior:Clip.hardEdge,
                  child: authMethods.buildProfileImage(pImage),
                ),
              ),
            ),
            Container(
              padding: padding,
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  buildMenuItem(
                    text: 'DashBoard',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'SF Pro',
                    ),
                    icon: Icons.home,
                    onClicked: () => selectedItems(context, 0),
                  ),
                  const SizedBox(height: 24),
                  buildMenuItem(
                    text: 'My Blogs',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'SF Pro',
                    ),
                    icon: Icons.info_outlined,
                    onClicked: () => selectedItems(context, 1),
                  ),
                  const SizedBox(height: 24),
                  buildMenuItem(
                    text: 'Settings',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'SF Pro',
                    ),
                    icon: Icons.settings,
                    onClicked: () => selectedItems(context, 2),
                  ),
                  const SizedBox(height: 24),
                  buildMenuItem(
                    text: 'Logout',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'SF Pro',
                    ),
                    icon: Icons.logout_sharp,
                    onClicked: () => selectedItems(context, 3),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
    required TextStyle style,
  }) {
    const color = Colors.white;
    const hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  selectedItems(BuildContext context, int index) {
    Navigator.of(context).pop();

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
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const showMyBlogPost()),
          );
          break;
        }
      case 2:
        {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingPage()),
          );
          break;
        }
      case 3:
        {
          showPlatformDialog<String>(
            context: context,
            builder: (BuildContext context) => PlatformAlertDialog(
              title: const Text('Alert'),
              content:
                  const Text('Are you sure you want to logout from this app?'),
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
                    logindata.setBool('login', true);
                    await logindata.clear();
                    AuthMethods().logout(context);
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
          break;
        }
    }
  }
}
