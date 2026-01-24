import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme.dart';
import '../../../widgets/glass_card.dart';

class JournalSkeleton extends StatelessWidget {
  const JournalSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerPadding,
        AppSpacing.md,
        AppSpacing.containerPadding,
        140,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildSkeletonCard(index);
      },
    );
  }

  Widget _buildSkeletonCard(int index) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      color: AppColors.bgSecondary.withOpacity(0.2),
      border: Border.all(
        color: Colors.white.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .shimmer(
       duration: 1500.ms,
       color: Colors.white.withOpacity(0.05),
       delay: (index * 150).ms,
     );
  }

  static Widget statsSkeleton() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: List.generate(4, (index) => _buildStatSkeleton(index)),
    );
  }

  static Widget _buildStatSkeleton(int index) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      color: AppColors.bgSecondary.withOpacity(0.2),
      border: Border.all(
        color: Colors.white.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .shimmer(
       duration: 1500.ms,
       color: Colors.white.withOpacity(0.05),
       delay: (index * 100).ms,
     );
  }
}
