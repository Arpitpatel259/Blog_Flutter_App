// ignore_for_file: file_names, non_constant_identifier_names, use_build_context_synchronously, prefer_typing_uninitialized_variables, avoid_print, unnecessary_null_comparison

import 'package:blog/Authentication/user_register_screen.dart';
import 'package:blog/Screens/splash_screen.dart';
import 'package:blog/Authentication/authentication.dart';
import 'package:blog/Utilities/constant.dart';
import 'package:blog/Utilities/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: kBodyStyle.copyWith(color: kTextLight),
      prefixIcon: Icon(prefixIcon, color: kTextLight, size: 22),
      suffixIcon: suffix,
      filled: true,
      fillColor: kInputFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: kErrorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: kErrorColor, width: 1.5),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: kLabelStyle,
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Email Address'),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            style: kBodyStyle.copyWith(color: kTextPrimary),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email';
              if (!value.isValidEmail) return 'Please enter a valid email';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'you@example.com',
              prefixIcon: Icons.alternate_email_rounded,
            ),
          ),
          const SizedBox(height: 24),
          _buildLabel('Password'),
          TextFormField(
            keyboardType: TextInputType.visiblePassword,
            obscureText: _isObscure,
            controller: passwordController,
            style: kBodyStyle.copyWith(color: kTextPrimary),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your password';
              if (!value.isValidPassword) return 'Min. 6 characters required';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Enter your password',
              prefixIcon: Icons.lock_outline_rounded,
              suffix: IconButton(
                icon: Icon(
                  _isObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: kTextLight,
                  size: 20,
                ),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
            );
            await AuthMethods().userLogin(
              emailController.text,
              passwordController.text,
              context,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: kButtonStyle,
        ),
        child: const Text('Sign In'),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: kInputBorder, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              fontSize: 10,
              color: kTextLight,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(child: Divider(color: kInputBorder, thickness: 1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextPrimary, size: 20),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false,
          ),
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text('Welcome back!', style: kHeadingStyle),
                  const SizedBox(height: 12),
                  Text('Fill your details or continue with social media', style: kSubtitleStyle),

                  const SizedBox(height: 48),

                  _buildForm(),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => showForgetPasswordDialog(context),
                      child: Text(
                        'Forgot Password?',
                        style: kLabelStyle.copyWith(color: kPrimaryColor, fontSize: 13),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildLoginBtn(),
                  const SizedBox(height: 40),
                  _buildDivider(),
                  const SizedBox(height: 32),

                  Center(
                    child: InkWell(
                      onTap: () async => await AuthMethods().signInWithGoogle(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: kSurfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kInputBorder),
                          boxShadow: kSoftShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Image(image: AssetImage('assets/logos/google.png'), height: 24),
                            const SizedBox(width: 12),
                            Text('Google', style: kLabelStyle),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserRegisterScreen()),
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: kBodyStyle,
                            ),
                            TextSpan(
                              text: 'Create account',
                              style: kLabelStyle.copyWith(color: kPrimaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showForgetPasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final forgotEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: kSurfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reset Password', style: kTitleStyle),
                const SizedBox(height: 12),
                Text("We'll send a recovery link to your email.", style: kBodyStyle),
                const SizedBox(height: 32),

                Form(
                  key: formKey,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: forgotEmailController,
                    decoration: _inputDecoration(
                      hint: 'Email Address',
                      prefixIcon: Icons.mail_outline_rounded,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: kLabelStyle.copyWith(color: kTextLight)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            await AuthMethods().resetPasswordAndNotify(
                              forgotEmailController.text,
                              context,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Send Link'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
