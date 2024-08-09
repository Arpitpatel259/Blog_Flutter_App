import 'package:blog/Authentication/UserLoginScreen.dart';
import 'package:blog/Services/Auth.dart';
import 'package:blog/Utilities/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Utilities/constant.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserRegisterScreen createState() => _UserRegisterScreen();
}

class _UserRegisterScreen extends State<UserRegisterScreen> {
  var email = "";
  var password = "";
  var confirmPassword = "";

  bool _isObscure = true;
  bool _isObscure1 = true;

  final formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cPasswordController = TextEditingController();

  Widget _buildSignUpForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* FIRST NAME FIELD*/
          const Text(
            'Name',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(
            height: defaultPadding,
          ),
          TextFormField(
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please Enter Your Name';
              } else if (!val.isValidName) {
                return 'Please Enter Valid Name';
              }
              return null;
            },
            controller: _nameController,
            decoration: const InputDecoration(
              fillColor: Colors.white24,
              filled: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.blue,
              ),
              hintText: 'Enter Your Name',
              hintStyle: TextStyle(color: Colors.black38),
            ),
          ),
          const SizedBox(
            height: defaultPadding,
          ),

          /* EMAIL ID FIELD*/
          const Text(
            'Email Id',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(
            height: defaultPadding,
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            obscureText: false,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please Enter Email';
              } else if (!val.isValidEmail) {
                return 'Please Enter Valid Email Id';
              }
              return null;
            },
            controller: _emailController,
            decoration: const InputDecoration(
              fillColor: Colors.white24,
              filled: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: Colors.blue,
              ),
              hintText: 'Enter your Email Id',
              hintStyle: TextStyle(color: Colors.black38),
            ),
          ),
          const SizedBox(
            height: defaultPadding,
          ),

          /* MOBILE NUMBER FIELD*/
          const Text(
            'Mobile No',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(
            height: defaultPadding,
          ),
          TextFormField(
            keyboardType: TextInputType.phone,
            obscureText: false,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please Enter Mobile No';
              } else if (!val.isValidPhone) {
                return 'Please Enter Valid Mobile No';
              }
              return null;
            },
            controller: _mobileController,
            decoration: const InputDecoration(
              fillColor: Colors.white24,
              filled: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.mobile_friendly_sharp,
                color: Colors.blue,
              ),
              hintText: 'Enter your Mobile No',
              hintStyle: TextStyle(color: Colors.black38),
            ),
          ),
          const SizedBox(
            height: defaultPadding,
          ),

          /* PASSWORD FILED*/
          const Text(
            'Password',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(
            height: defaultPadding,
          ),
          TextFormField(
            obscureText: _isObscure,
            keyboardType: TextInputType.visiblePassword,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please Enter Password';
              } else if (!val.isValidPassword) {
                return 'Please Enter Valid Password';
              }
              return null;
            },
            controller: _passwordController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  }),
              fillColor: Colors.white24,
              filled: true,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.password_sharp,
                color: Colors.blue,
              ),
              hintText: 'Enter your Password',
              hintStyle: const TextStyle(color: Colors.black38),
            ),
          ),
          const SizedBox(
            height: defaultPadding,
          ),

          /* CONFIRM PASSWORD FILED*/
          const Text(
            'Confirm Password',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(
            height: defaultPadding,
          ),
          TextFormField(
            obscureText: _isObscure1,
            keyboardType: TextInputType.visiblePassword,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please Enter Confirm Password';
              } else if (!val.isValidPassword) {
                return 'Please Enter Valid Confirm Password';
              } else if (val != _passwordController.text) {
                return 'Password Do Not Match!';
              }
              return null;
            },
            controller: _cPasswordController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure1 ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isObscure1 = !_isObscure1;
                    });
                  }),
              fillColor: Colors.white24,
              filled: true,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.password_sharp,
                color: Colors.blue,
              ),
              hintText: 'Enter Confirm Password',
              hintStyle: const TextStyle(color: Colors.black38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      // ignore: deprecated_member_use
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
                  // Prevents dismissal when tapping outside
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                await AuthMethods().registerUser(_nameController.text, email,
                    _mobileController.text, password, confirmPassword);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Registration Successfull",
                    ),
                    backgroundColor: Colors.teal,
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'Dismiss',
                      disabledTextColor: Colors.white,
                      textColor: Colors.yellow,
                      onPressed: () {
                        //Do whatever you want
                      },
                    ),
                  ),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserLoginScreen(),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "Registered Unsuccessfull. Please Check Your Details!",
                  ),
                  backgroundColor: Colors.teal,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Dismiss',
                    disabledTextColor: Colors.white,
                    textColor: Colors.yellow,
                    onPressed: () {
                      //Do whatever you want
                    },
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
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white,
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              // ignore: sized_box_for_whitespace
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 100.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
