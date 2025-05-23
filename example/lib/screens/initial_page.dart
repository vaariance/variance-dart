import 'package:flutter/material.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              // Logo container with wallet icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E6FA),
                    borderRadius: BorderRadius.circular(100),
                    border:
                        Border.all(color: const Color(0xFF9370DB), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Color(0xFF663399),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // Title text
              Text(
                "Account Kits for You",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE6E6FA),
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Subtitle text
              const Text(
                "Choose your preferred account abstraction solution",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFE6E6FA),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              // First navigation button
              _buildNavigationButton(
                context,
                "Create Account",
                Icons.smart_toy_outlined,
                () => Navigator.pushNamed(context, '/create-account'),
                const Color(0xFF9370DB),
              ),
              const Spacer(),
              // Footer text
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Text(
                  "© 2025 variance inc",
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFE6E6FA).withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color, width: 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
