import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class WorkPage extends StatelessWidget {
  const WorkPage({super.key});

  static const List<_WorkItem> _projects = [
    _WorkItem(
      category: 'RESIDENTIAL',
      title: 'The Verdant Residence',
      location: 'Bengaluru, Karnataka',
      year: '2025',
      asset: 'assets/images/1.jpg',
      tags: ['Interior', 'Furniture', 'Lighting'],
    ),
    _WorkItem(
      category: 'COMMERCIAL',
      title: 'Aura Wellness Studio',
      location: 'Mumbai, Maharashtra',
      year: '2024',
      asset: 'assets/images/nivara.png',
      tags: ['Spatial', 'Branding', 'Custom Fit-Out'],
    ),
    _WorkItem(
      category: 'PRODUCT',
      title: 'Qubo Task Lamp',
      location: 'Pan India',
      year: '2024',
      asset: 'assets/images/qubo.png',
      tags: ['Product Design', 'Lighting'],
    ),
    _WorkItem(
      category: 'ASSISTIVE',
      title: 'Neuro Bite Device',
      location: 'Research & Development',
      year: '2023',
      asset: 'assets/images/neuro bit.png',
      tags: ['Assistive Tech', 'Healthcare'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OUR WORK',
                      style: navStyle(size: 11.5, color: AppColors.green)),
                  const SizedBox(height: 6),
                  Text('Featured Projects', style: headingStyle(size: 26)),
                  const SizedBox(height: 8),
                  Text(
                    'A selection of residential, commercial, and product '
                    'design projects that define the Indris ethos.',
                    style: bodyStyle(size: 13.5),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border),
                ],
              ),
            ),
          ),

          // ── Project list ─────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _ProjectCard(project: _projects[index]),
                childCount: _projects.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _WorkItem {
  final String category;
  final String title;
  final String location;
  final String year;
  final String asset;
  final List<String> tags;

  const _WorkItem({
    required this.category,
    required this.title,
    required this.location,
    required this.year,
    required this.asset,
    required this.tags,
  });
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final _WorkItem project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          AspectRatio(
            aspectRatio: 16 / 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  project.asset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.cream,
                    child: const Icon(Icons.image_outlined,
                        size: 40, color: AppColors.border),
                  ),
                ),
                // Category badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(project.category,
                        style: navStyle(
                            size: 9.5,
                            color: Colors.white,
                            weight: FontWeight.w700)),
                  ),
                ),
                // Year badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(project.year,
                        style: navStyle(
                            size: 9.5,
                            color: Colors.white,
                            weight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.title, style: headingStyle(size: 17)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Text(project.location,
                        style: bodyStyle(size: 12.5)),
                  ],
                ),
                const SizedBox(height: 10),
                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: project.tags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(tag,
                                style: navStyle(
                                    size: 10.5,
                                    color: AppColors.textGrey)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
