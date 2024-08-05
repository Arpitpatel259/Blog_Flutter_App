import 'package:blog/Authentication/userLogin.dart';
import 'package:blog/Services/Auth.dart';
import 'package:blog/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationDrawers extends StatefulWidget {
  const NavigationDrawers({Key? key}) : super(key: key);

  @override
  _NavigationDrawer createState() => _NavigationDrawer();
}

class _NavigationDrawer extends State<NavigationDrawers> {
  final padding = const EdgeInsets.symmetric(horizontal: 20);

  late SharedPreferences logindata;
  late bool newuser;

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
      newuser = (logindata.getBool('login') ?? false);
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
            colors: [Colors.blueAccent, Colors.blueGrey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: <Widget>[
            Container(
              padding: padding,
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
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
                            text: name ?? 'John Due',
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
                            text: email ?? 'example@gmail.com',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ],
                      ),
                    ),
                    currentAccountPicture: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => _buildProfileModal(context),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                        );
                      },
                      child: Hero(
                        tag: 'profile-picture',
                        child: CircleAvatar(
                          radius: 50,
                          child: ClipOval(
                            child: pImage.isNotEmpty
                                ? Image.network(
                                    pImage,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  )
                                : Container(
                                    width: 100,
                                    height: 100,
                                    child: const Center(
                                      child: Icon(
                                        Icons.account_circle,
                                        size: 72, // adjust size as needed
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                    text: 'Setting',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'SF Pro',
                    ),
                    icon: Icons.settings,
                    onClicked: () => selectedItems(context, 3),
                  ),
                  const SizedBox(height: 24),
                  buildMenuItem(
                    text: 'About Us',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'SF Pro',
                    ),
                    icon: Icons.info_outline,
                    onClicked: () => selectedItems(context, 4),
                  ),
                  const SizedBox(height: 24),
                  buildMenuItem(
                    text: 'Logout',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'SF Pro',
                    ),
                    icon: Icons.logout_sharp,
                    onClicked: () => selectedItems(context, 5),
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
            MaterialPageRoute(builder: (context) => const userLoginScreen()),
          );
          break;
        }
      case 2:
        {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const userLoginScreen()),
          );
          break;
        }
      case 3:
        {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const userLoginScreen()),
          );
          break;
        }
      case 4:
        {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const userLoginScreen()),
          );
          break;
        }
      case 5:
        {
          showPlatformDialog<String>(
            context: context,
            builder: (BuildContext context) => PlatformAlertDialog(
              title: Text('Alert'),
              content: Text('Are you sure you want to logout from this app?'),
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
                        builder: (context) => const userLoginScreen(),
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

  Widget _buildProfileModal(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Hero(
            tag: 'profile-picture',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
              child: ClipOval(
                child: pImage.isNotEmpty
                    ? Image.network(
                        pImage,
                        fit: BoxFit.cover,
                        width: 300,
                        height: 300,
                      )
                    : const Icon(
                        Icons.account_circle,
                        size: 250,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
