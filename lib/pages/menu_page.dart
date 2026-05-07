import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'game_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),

              // =========================
              // TITLE
              // =========================
              Center(
                child: Column(
                  children: [
                    Text(
                      "Fraction\nGame",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 0.9,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF8B5CF6),
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.deepPurple.withOpacity(0.18),
                            offset: const Offset(0, 5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: 120,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              const Text(
                "Choose Level",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF241B4B),
                ),
              ),

              const SizedBox(height: 18),

              // =========================
              // LEVEL 1
              // =========================
              _levelCard(
                title: "Level 1",
                subtitle: "Basic fraction questions",
                icon: Icons.looks_one_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  Get.to(() => const GamePage(), arguments: 1);
                },
              ),

              const SizedBox(height: 18),

              // =========================
              // LEVEL 2
              // =========================
              _levelCard(
                title: "Level 2",
                subtitle: "More challenging fractions",
                icon: Icons.looks_two_rounded,
                color: const Color(0xFF4DA6FF),
                onTap: () {
                  Get.to(() => const GamePage(), arguments: 2);
                },
              ),

              const Spacer(),

              Center(
                child: Text(
                  "Select a level to start playing",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _levelCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: color, size: 42),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF241B4B),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}
