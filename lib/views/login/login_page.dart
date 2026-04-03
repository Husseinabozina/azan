import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/components/custom_button.dart';
import 'package:quran_app/core/components/custom_text_form_field.dart';
import 'package:quran_app/core/helpers/mqscale.dart';
import 'package:quran_app/core/router/app_navigation.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement actual login logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Data')),
      );
      // Example: Navigate to home page after successful login
      // AppNavigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo or Illustration
                SvgPicture.asset(
                  'assets/svg/quran_logo.svg', // Replace with your actual logo path
                  height: 120.h,
                  colorFilter: ColorFilter.mode(AppTheme.primaryColor, BlendMode.srcIn),
                ),
                SizedBox(height: 40.h),

                // Welcome Text
                Text(
                  LocaleKeys.welcomeBack.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  LocaleKeys.loginToContinue.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                SizedBox(height: 40.h),

                // Email Field
                CustomTextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  labelText: LocaleKeys.email.tr(),
                  hintText: LocaleKeys.enterYourEmail.tr(),
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return LocaleKeys.pleaseEnterEmail.tr();
                    }
                    // Add email format validation if needed
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Password Field
                CustomTextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  labelText: LocaleKeys.password.tr(),
                  hintText: LocaleKeys.enterYourPassword.tr(),
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.secondaryTextColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return LocaleKeys.pleaseEnterPassword.tr();
                    }
                    // Add password strength validation if needed
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to Forgot Password page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Forgot Password clicked')),
                      );
                    },
                    child: Text(
                      LocaleKeys.forgotPassword.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // Login Button
                CustomButton(
                  text: LocaleKeys.login.tr(),
                  onPressed: _login,
                  backgroundColor: AppTheme.primaryColor,
                  textColor: Colors.white,
                ),
                SizedBox(height: 24.h),

                // Or Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppTheme.borderColor,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        LocaleKeys.or.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppTheme.borderColor,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Social Login Buttons (Example: Google)
                CustomButton(
                  text: LocaleKeys.loginWithGoogle.tr(),
                  onPressed: () {
                    // TODO: Implement Google Sign-In
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login with Google clicked')),
                    );
                  },
                  backgroundColor: Colors.white,
                  textColor: AppTheme.primaryTextColor,
                  prefixIcon: 'assets/svg/google_icon.svg', // Replace with your actual icon path
                ),
                SizedBox(height: 16.h),
                CustomButton(
                  text: LocaleKeys.loginWithFacebook.tr(),
                  onPressed: () {
                    // TODO: Implement Facebook Sign-In
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login with Facebook clicked')),
                    );
                  },
                  backgroundColor: const Color(0xFF1877F2), // Facebook blue
                  textColor: Colors.white,
                  prefixIcon: 'assets/svg/facebook_icon.svg', // Replace with your actual icon path
                ),
                SizedBox(height: 32.h),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.dontHaveAnAccount.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to Sign Up page
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sign Up clicked')),
                        );
                      },
                      child: Text(
                        LocaleKeys.signUp.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h), // For bottom padding when keyboard is up
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy implementations for missing keys and components for now
// You should replace these with your actual implementations.

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final String? prefixIcon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        foregroundColor: textColor ?? Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            SvgPicture.asset(
              prefixIcon!,
              height: 24.h,
              width: 24.w,
            ),
            SizedBox(width: 12.w),
          ],
          Text(
            text,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.keyboardType = TextInputType.text,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(fontSize: 16.sp, color: AppTheme.primaryTextColor),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppTheme.secondaryTextColor, size: 20.r)
            : null,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        fillColor: AppTheme.inputFieldFillColor,
        filled: true,
        labelStyle: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14.sp),
        hintStyle: TextStyle(color: AppTheme.secondaryTextColor.withOpacity(0.7), fontSize: 14.sp),
      ),
    );
  }
}

// Dummy LocaleKeys for demonstration purposes.
// In a real app, these would be in your generated locale file.
abstract class LocaleKeys {
  static const welcomeBack = 'welcomeBack';
  static const loginToContinue = 'loginToContinue';
  static const email = 'email';
  static const enterYourEmail = 'enterYourEmail';
  static const pleaseEnterEmail = 'pleaseEnterEmail';
  static const password = 'password';
  static const enterYourPassword = 'enterYourPassword';
  static const pleaseEnterPassword = 'pleaseEnterPassword';
  static const forgotPassword = 'forgotPassword';
  static const login = 'login';
  static const or = 'or';
  static const loginWithGoogle = 'loginWithGoogle';
  static const loginWithFacebook = 'loginWithFacebook';
  static const dontHaveAnAccount = 'dontHaveAnAccount';
  static const signUp = 'signUp';
}

// Dummy AppTheme for demonstration purposes.
// In a real app, this would be properly defined.
class AppTheme {
  static Color get primaryColor => const Color(0xFF4CAF50); // Green
  static Color get secondaryTextColor => const Color(0xFF757575); // Grey
  static Color get primaryTextColor => const Color(0xFF212121); // Dark Grey
  static Color get borderColor => const Color(0xFFE0E0E0); // Light Grey
  static Color get inputFieldFillColor => const Color(0xFFF5F5F5); // Very Light Grey
}
