// ignore_for_file: use_build_context_synchronously

import 'package:blog/Authentication/user_login_screen.dart';
import 'package:blog/Authentication/authentication.dart';
import 'package:blog/Utilities/constant.dart';
import 'package:blog/Utilities/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  bool _isObscure = true, _isObscure1 = true;
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController(),
      _emailController = TextEditingController(),
      _mobileController = TextEditingController(),
      _passwordController = TextEditingController(),
      _cPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _cPasswordController.dispose();
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
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
      child: Text(
        text,
        style: kLabelStyle,
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Full Name'),
          TextFormField(
            controller: _nameController,
            style: kBodyStyle.copyWith(color: kTextPrimary),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please enter your name';
              if (!val.isValidName) return 'Please enter a valid name';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'John Doe',
              prefixIcon: Icons.person_outline_rounded,
            ),
          ),
          _buildLabel('Email Address'),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: kBodyStyle.copyWith(color: kTextPrimary),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please enter your email';
              if (!val.isValidEmail) return 'Please enter a valid email';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'john@example.com',
              prefixIcon: Icons.email_outlined,
            ),
          ),
          _buildLabel('Mobile Number'),
          TextFormField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            style: kBodyStyle.copyWith(color: kTextPrimary),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please enter mobile number';
              if (!val.isValidPhone) return 'Please enter a valid number';
              return null;
            },
            decoration: _inputDecoration(
              hint: '+1 234 567 890',
              prefixIcon: Icons.phone_android_outlined,
            ),
          ),
          _buildLabel('Password'),
          TextFormField(
            controller: _passwordController,
            obscureText: _isObscure,
            style: kBodyStyle.copyWith(color: kTextPrimary),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please enter password';
              if (!val.isValidPassword) return 'Min. 6 characters required';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Create a password',
              prefixIcon: Icons.lock_outline_rounded,
              suffix: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: kTextLight,
                  size: 20,
                ),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              ),
            ),
          ),
          _buildLabel('Confirm Password'),
          TextFormField(
            controller: _cPasswordController,
            obscureText: _isObscure1,
            style: kBodyStyle.copyWith(color: kTextPrimary),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please confirm password';
              if (val != _passwordController.text) return 'Passwords do not match';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Repeat your password',
              prefixIcon: Icons.lock_reset_rounded,
              suffix: IconButton(
                icon: Icon(
                  _isObscure1 ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: kTextLight,
                  size: 20,
                ),
                onPressed: () => setState(() => _isObscure1 = !_isObscure1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
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

            await AuthMethods().registerUser(
              _nameController.text,
              _emailController.text,
              _mobileController.text,
              _passwordController.text,
              _cPasswordController.text,
            );

            Navigator.pop(context); // Close loading dialog

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Account created successfully!"),
                behavior: SnackBarBehavior.floating,
                backgroundColor: kSuccessColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserLoginScreen()),
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
        child: const Text('Create Account'),
      ),
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text('Create Account', style: kHeadingStyle),
                  const SizedBox(height: 12),
                  Text('Join our community of storytellers today.', style: kSubtitleStyle),
                  
                  _buildSignUpForm(),
                  
                  _buildSignUpButton(),
                  
                  const SizedBox(height: 40),
                  
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const UserLoginScreen()),
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: kBodyStyle,
                            ),
                            TextSpan(
                              text: 'Sign In',
                              style: kLabelStyle.copyWith(color: kPrimaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
