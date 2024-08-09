import 'package:blog/Authentication/UserLoginScreen.dart';
import 'package:blog/Services/Auth.dart';
import 'package:blog/Utilities/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Utilities/constant.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  _UserRegisterScreen createState() => _UserRegisterScreen();
}

class _UserRegisterScreen extends State<UserRegisterScreen> {
  var email = "", password = "", confirmPassword = "";
  bool _isObscure = true, _isObscure1 = true;
  final formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(),
      _emailController = TextEditingController(),
      _mobileController = TextEditingController(),
      _passwordController = TextEditingController(),
      _cPasswordController = TextEditingController();

  Widget _buildTextFormField(
      {required String label,
        required TextInputType keyboardType,
        required IconData icon,
        required String hint,
        required TextEditingController controller,
        bool obscureText = false,
        String? Function(String?)? validator,
        IconButton? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: defaultPadding),
        TextFormField(
          keyboardType: keyboardType,
          obscureText: obscureText,
          controller: controller,
          validator: validator,
          style: const TextStyle(color: Colors.black, fontFamily: 'OpenSans'),
          decoration: InputDecoration(
            fillColor: Colors.white24,
            filled: true,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.only(top: 14.0),
            prefixIcon: Icon(icon, color: Colors.blue),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            suffixIcon: suffixIcon,
          ),
        ),
        const SizedBox(height: defaultPadding),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _buildTextFormField(
            label: 'Name',
            keyboardType: TextInputType.text,
            icon: Icons.person,
            hint: 'Enter Your Name',
            controller: _nameController,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please Enter Your Name';
              if (!val.isValidName) return 'Please Enter Valid Name';
              return null;
            },
          ),
          _buildTextFormField(
            label: 'Email Id',
            keyboardType: TextInputType.emailAddress,
            icon: Icons.email_outlined,
            hint: 'Enter Your Email Id',
            controller: _emailController,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please Enter Email';
              if (!val.isValidEmail) return 'Please Enter Valid Email Id';
              return null;
            },
          ),
          _buildTextFormField(
            label: 'Mobile No',
            keyboardType: TextInputType.phone,
            icon: Icons.mobile_friendly_sharp,
            hint: 'Enter Your Mobile No',
            controller: _mobileController,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please Enter Mobile No';
              if (!val.isValidPhone) return 'Please Enter Valid Mobile No';
              return null;
            },
          ),
          _buildTextFormField(
            label: 'Password',
            keyboardType: TextInputType.visiblePassword,
            icon: Icons.password_sharp,
            hint: 'Enter Your Password',
            controller: _passwordController,
            obscureText: _isObscure,
            suffixIcon: IconButton(
              icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _isObscure = !_isObscure),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please Enter Password';
              if (!val.isValidPassword) return 'Please Enter Valid Password';
              return null;
            },
          ),
          _buildTextFormField(
            label: 'Confirm Password',
            keyboardType: TextInputType.visiblePassword,
            icon: Icons.password_sharp,
            hint: 'Enter Confirm Password',
            controller: _cPasswordController,
            obscureText: _isObscure1,
            suffixIcon: IconButton(
              icon: Icon(_isObscure1 ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _isObscure1 = !_isObscure1),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please Enter Confirm Password';
              if (!val.isValidPassword) return 'Please Enter Valid Confirm Password';
              if (val != _passwordController.text) return 'Password Do Not Match!';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            setState(() {
              email = _emailController.text;
              password = _passwordController.text;
              confirmPassword = _cPasswordController.text;
            });
            if (_nameController.text.isNotEmpty &&
                _emailController.text.isNotEmpty &&
                _mobileController.text.isNotEmpty &&
                _passwordController.text.isNotEmpty &&
                _cPasswordController.text.isNotEmpty) {
              if (_passwordController.text == _cPasswordController.text) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                await AuthMethods().registerUser(
                    _nameController.text, email, _mobileController.text, password, confirmPassword);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Registration Successful"),
                    backgroundColor: Colors.teal,
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'Dismiss',
                      onPressed: () {},
                    ),
                  ),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const UserLoginScreen()),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Registration Unsuccessful. Please Check Your Details!"),
                  backgroundColor: Colors.teal,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Dismiss',
                    onPressed: () {},
                  ),
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15.0),
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white, Colors.white, Colors.white],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
                height: double.infinity,
                width: double.infinity,
              ),
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 100.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'OpenSans',
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildSignUpForm(),
                    _buildSignUpButton(),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const UserLoginScreen()),
                              (Route<dynamic> route) => false,
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an Account? ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
