import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardItem {
  final int id;
  final String label;
  final IconData icon;
  final Color color;
  final String actionKey;

  const DashboardItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.actionKey,
  });
}

class DashboardCard extends StatelessWidget {
  final DashboardItem item;
  final VoidCallback onTap;
  final int animationIndex;

  const DashboardCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.animationIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: item.color.withOpacity(0.1),
            highlightColor: item.color.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon container
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          item.color,
                          item.color.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: item.color.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      item.icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          .animate(delay: Duration(milliseconds: 80 * animationIndex))
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut),
    );
  }
}
