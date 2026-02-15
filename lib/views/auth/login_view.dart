import 'package:chatify/controller/auth/auth_controller.dart';
import 'package:chatify/routes/app_routes.dart';
import 'package:chatify/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:get_x/get_core/src/get_main.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _fromKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  bool _obsecurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _fromKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Center(
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.chat_bubble_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Welcome Back!',
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Sign in to continue chatting with friends & family",
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'Enter your email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!GetUtils.isEmail(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      }

                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.emailAddress,
                    obscureText: _obsecurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      hintText: 'Enter your password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obsecurePassword = !_obsecurePassword;
                          });
                        },
                        icon: Icon(
                          _obsecurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your password';
                      }
                      if (value!.length < 6) {
                        return "Password must be at latest 6 characters";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  Obx(
                          () =>
                          SizedBox(
                            height: 50, width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _authController.isLoading ? null : () {
                                if (_fromKey.currentState?.validate() ??
                                    false) {
                                  _authController.signInWithEmailAndPassword(
                                      _emailController.text.trim(), _passwordController.text.trim());
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)
                                  )
                              ),
                              child: _authController.isLoading
                                  ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text('Sign In'),
                            ),
                          )
                  ),
                  SizedBox(height: 16,),
                  Center(child: TextButton(onPressed: () {
                    Get.toNamed(AppRoutes.forgetPassword);
                  }, child: Text('Forget Password?', style: TextStyle(
                      color: AppTheme.primaryColor
                  ),)),),
                  SizedBox(height: 32,),
                  Row(children: [
                    Expanded(child: Divider(
                      color: AppTheme.borderColor,
                    )),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodySmall,
                      ),),
                    Expanded(child: Divider(
                      color: AppTheme.borderColor,
                    )),
                  ],),
                  SizedBox(height: 32,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.register),
                        child: Text("Sign Up", style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor
                        ),),
                      )
                    ],)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
