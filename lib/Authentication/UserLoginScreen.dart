// ignore_for_file: file_names, non_constant_identifier_names, use_build_context_synchronously, prefer_typing_uninitialized_variables, avoid_print, unnecessary_null_comparison

import 'package:blog/Authentication/UserRegisterScreen.dart';
import 'package:blog/Screens/splashScreen.dart';
import 'package:blog/Services/Auth.dart';
import 'package:blog/Utilities/constant.dart';
import 'package:blog/Utilities/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({Key? key}) : super(key: key);

  @override
  _UserLoginScreen createState() => _UserLoginScreen();
}

class _UserLoginScreen extends State<UserLoginScreen> {
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
          Text('Email',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground)),
          const SizedBox(height: defaultPadding),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
                fontFamily: 'OpenSans',
                color: Theme.of(context).colorScheme.onBackground),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter Email';
              } else if (!value.isValidEmail) {
                return 'Please Enter Valid Email Id';
              }
              return null;
            },
            controller: emailController,
            decoration: InputDecoration(
              fillColor: Theme.of(context).colorScheme.background,
              filled: true,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(Icons.email,
                  color: Theme.of(context).colorScheme.primary),
              hintText: 'Enter your Email',
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.onSurface),
              errorStyle: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Text('Password',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground)),
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
            style: TextStyle(
                fontFamily: 'OpenSans',
                color: Theme.of(context).colorScheme.onBackground),
            controller: passwordController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
              fillColor: Theme.of(context).colorScheme.background,
              filled: true,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(Icons.lock,
                  color: Theme.of(context).colorScheme.primary),
              hintText: 'Enter your Password',
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.onSurface),
              errorStyle: const TextStyle(fontSize: 15),
            ),
          ),
        ],
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
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
            await AuthMethods().userLogin(
                emailController.text, passwordController.text, context);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(defaultPadding),
          backgroundColor: Theme.of(context).colorScheme.secondary,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onBackground),
          onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
              (route) => false),
        ),
      ),
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
                      horizontal: 40.0, vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                      _buildForm(),
                      Container(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => showForgetPasswordDialog(context),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                        ),
                      ),
                      _buildLoginBtn(),
                      const Text(
                        '-------------------- OR --------------------',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        'Sign in with',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _buildSocialBtn(
                                () async => await AuthMethods()
                                    .signInWithGoogle(context),
                                const AssetImage('assets/logos/google.png')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const UserRegisterScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Don\'t have an Account? ',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
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
              color: Colors.transparent,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(image: logo),
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
                Text('Email',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground)),
                const SizedBox(height: defaultPadding),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                      fontFamily: 'OpenSans',
                      color: Theme.of(context).colorScheme.onBackground),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Email';
                    } else if (!value.isValidEmail) {
                      return 'Please Enter Valid Email Id';
                    }
                    return null;
                  },
                  controller: emailController,
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).colorScheme.background,
                    filled: true,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.only(top: 14.0),
                    prefixIcon: Icon(Icons.email,
                        color: Theme.of(context).colorScheme.primary),
                    hintText: 'Enter your Email',
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
                    errorStyle: const TextStyle(fontSize: 15),
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
}
