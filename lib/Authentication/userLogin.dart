// ignore_for_file: file_names, non_constant_identifier_names, use_build_context_synchronously, prefer_typing_uninitialized_variables, avoid_print, unnecessary_null_comparison

import 'package:blog/Authentication/userRegister.dart';
import 'package:blog/Services/Auth.dart';
import 'package:blog/Utilities/constant.dart';
import 'package:blog/Utilities/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class userLoginScreen extends StatefulWidget {
  const userLoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _userLoginScreen createState() => _userLoginScreen();
}

class _userLoginScreen extends State<userLoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  var email = "";
  var password = "";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontFamily: 'OpenSans'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter Email';
              } else if (!value.isValidEmail) {
                return 'Please Enter Valid Email Id';
              }
              return null;
            },
            controller: emailController,
            decoration: const InputDecoration(
              fillColor: Colors.white24,
              filled: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(Icons.email),
              hintText: 'Enter Your Email',
              errorStyle: TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: defaultPadding),
          const Text(
            'Password',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            keyboardType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter Password';
              } else if (!value.isValidPassword) {
                return 'Please Enter Valid Password.';
              }
              return null;
            },
            obscureText: _isObscure,
            style: const TextStyle(fontFamily: 'OpenSans'),
            controller: passwordController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon:
                    Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
              fillColor: Colors.white24,
              filled: true,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(Icons.lock),
              hintText: 'Enter Your Password',
              errorStyle: const TextStyle(fontSize: 15) ,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          showForgetPasswordDialog(context);
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            setState(() {
              email = emailController.text;
              password = passwordController.text;
            });

            showDialog(
              context: context,
              barrierDismissible: false,
              // Prevents dismissal when tapping outside
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );

            await AuthMethods().userLogin(email, password, context);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(defaultPadding),
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: const Text(
          'Sign In',
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

  Widget _buildSignInWithText() {
    return const Column(
      children: <Widget>[
        Text(
          '-------------------- OR --------------------',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20.0),
        Text(
          'Sign in with',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
      ],
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
            () async {
              await AuthMethods().signInWithGoogle(context);
            },
            const AssetImage(
              'assets/logos/google.png',
            ),
          ),
          _buildSocialBtn(
            () => print('Login with Facebook'),
            const AssetImage(
              'assets/logos/facebook.png',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const userRegisterScreen()),
        );
      },
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void showForgetPasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Email',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: defaultPadding),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontFamily: 'OpenSans'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Email';
                    } else if (!value.isValidEmail) {
                      return 'Please Enter Valid Email Id';
                    }
                    return null;
                  },
                  controller: emailController,
                  decoration: const InputDecoration(
                    fillColor: Colors.white24,
                    filled: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.only(top: 14.0),
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Enter Your Email',
                    errorStyle: TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(height: defaultPadding),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {}
                    },
                    child: const Text('Reset Password'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 120.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Sign In',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          _buildForm(),
                          _buildForgotPasswordBtn(),
                          _buildLoginBtn(),
                          _buildSignInWithText(),
                          _buildSocialBtnRow(), // Add this line
                          const SizedBox(height: 10.0),
                          _buildSignupBtn(),
                        ],
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
