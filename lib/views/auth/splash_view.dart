import 'package:flutter/material.dart';
import '../../app_theme.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              // Hero image — place heroImage.png in assets/images/
              Image.asset(
                'assets/images/heroImage.png',
                height: 300,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 32),

              // App tagline
              const Text(
                'Student Assistant\nApplication System',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  height: 1.3,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Apply for Student Assistant positions,\ntrack your application status and more.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),

              const Spacer(),

              // Login button
              ElevatedButton(
                 style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                  ),

                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Login'),
              ),
              const SizedBox(height: 14),

              // Register outlined button
              OutlinedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/register'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Register'),
              ),

              const SizedBox(height: 16),

              // About link
              TextButton(
                onPressed: () => _showAboutDialog(context),
                child: const Text(
                  'About this app',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.school, color: AppTheme.primary),
            SizedBox(width: 10),
            Text(
              'About',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Assistant Application System',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This app allows students at the Central University of Technology to apply for Student Assistant positions. Students can apply to assist with up to two modules, track their application status, and manage their profile.\n\nAdministrative staff can review, approve, or reject applications and manage student accounts.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Version',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                Text('1.0.0',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Module',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                Text('TPG316C',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Institution',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                Text('CUT',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary)),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}