import 'package:flutter/material.dart';
import '../../../shared/services/auth_service.dart';
import '../../tasks/view/task_home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 40.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/todo_logo.png',
                          height: 100,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Katomaran Todo',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Sign in to manage your tasks efficiently.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () async {
                            print('[DEBUG] Login button pressed');

                            final user =
                                await AuthService().signInWithGoogle();

                            print(
                                '[DEBUG] Google Sign-in returned: $user');

                            if (user != null && context.mounted) {
                              print('[DEBUG] Navigating to TaskHomeScreen...');
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TaskHomeScreen(),
                                ),
                              );
                            } else {
                              print('[DEBUG] Sign-in failed or user cancelled');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Sign-in failed. Please try again.'),
                                ),
                              );
                            }
                          },
                          icon: Image.asset(
                            'assets/images/google_icon.png',
                            height: 24,
                          ),
                          label: const Text('Continue with Google'),
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            minimumSize: const Size(double.infinity, 50),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Made with ❤ for Katomaran Hackathon',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}