import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
              (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "About Us",
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 40),
                const CircleAvatar(
                  radius: 80,
                  backgroundImage:
                  AssetImage('assets/logos/blog_sample.png'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Arpit Vekariya',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Pacifico',
                  ),
                ),
                const Text(
                  'Flutter Developer',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 40),
                _buildButton(
                  icon: Icons.link,
                  text: 'http://arpit-blog.epizy.com',
                  onPressed: () {},
                ),
                _buildButton(
                  icon: Icons.phone,
                  text: '+91 92650 32740',
                  onPressed: () {},
                ),
                _buildButton(
                  icon: Icons.email,
                  text: 'aj.vekariya123@gmail.com',
                  onPressed: () {},
                ),
                _buildButton(
                  icon: Icons.code,
                  text: 'https://github.com/Arpitpatel259',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        width: 350,
        child: GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied to clipboard: $text')),
            );
          },
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 10),
                Text(text),
              ],
            ),
          ),
        ),
      ),
    );
  }

}