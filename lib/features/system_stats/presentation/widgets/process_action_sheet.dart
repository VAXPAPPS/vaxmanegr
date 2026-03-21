import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:vaxmanegr/core/constants/app_colors.dart';

class ProcessActionSheet extends StatelessWidget {
  final VoidCallback onKill;
  final VoidCallback onShowLog;
  final VoidCallback onRestart;

  const ProcessActionSheet({
    super.key,
    required this.onKill,
    required this.onShowLog,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 240, // زيادة الارتفاع قليلاً لاستيعاب التصميم الجديد
      borderRadius: 30, // زوايا أكثر استدارة
      blur: 30,
      alignment: Alignment.center,
      border: 1.5,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1A1B26).withValues(alpha: 0.6), // لون خلفية فيتوم
          const Color(0xFF1A1B26).withValues(alpha: 0.3),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accent.withValues(alpha: 0.5),
          AppColors.accent.withValues(alpha: 0.1),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // شريط علوي صغير للدلالة على السحب
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Spacer(),
              
              // الصف الأول: العمليات المساعدة (Log + Restart)
              Row(
                children: [
                  Expanded(
                    child: _TacticalButton(
                      title: 'View Logs',
                      icon: Icons.terminal_rounded,
                      color: Colors.cyanAccent,
                      onTap: onShowLog,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TacticalButton(
                      title: 'Restart',
                      icon: Icons.refresh_rounded,
                      color: Colors.amberAccent,
                      onTap: onRestart,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // الصف الثاني: زر القتل (الخطر)
              _KillButton(onTap: onKill),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// زر العمليات العادية (بتصميم زجاجي خفيف)
class _TacticalButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TacticalButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// زر القتل المخصص (بتصميم عدواني)
class _KillButton extends StatelessWidget {
  final VoidCallback onTap;

  const _KillButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.redAccent.withValues(alpha: 0.4),
        child: Container(
          height: 65,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.withValues(alpha: 0.2),
                Colors.redAccent.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.1),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.dangerous_outlined, color: Colors.redAccent, size: 28), // جمجمة/خطر
              const SizedBox(width: 12),
              const Text(
                'TERMINATE PROCESS', // لغة عسكرية/تقنية
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
