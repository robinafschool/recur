import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text('Recur', style: AppTheme.logo),
                  const SizedBox(height: AppTheme.spacing60),
                  AppCard(
                    padding: const EdgeInsets.all(AppTheme.spacing30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Email', style: AppTheme.bodySecondary),
                        const SizedBox(height: AppTheme.spacing8),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'your@email.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          style: AppTheme.body,
                        ),
                        const SizedBox(height: AppTheme.spacing20),
                        const Text('Password', style: AppTheme.bodySecondary),
                        const SizedBox(height: AppTheme.spacing8),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            hintText: '••••••••',
                          ),
                          obscureText: true,
                          style: AppTheme.body,
                        ),
                        const SizedBox(height: AppTheme.spacing20),
                        ElevatedButton(
                          onPressed: _handleSignIn,
                          child: const Text('Sign In'),
                        ),
                        const SizedBox(height: AppTheme.spacing20),
                        const Center(
                          child: Text('or', style: AppTheme.bodySecondary),
                        ),
                        const SizedBox(height: AppTheme.spacing20),
                        OutlinedButton(
                          onPressed: _handleSignIn,
                          child: const Text('Sign in with Google'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing20),
                  GestureDetector(
                    onTap: () {
                      // Navigate to sign up
                    },
                    child: const Text(
                      'Don\'t have an account? Sign up',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
