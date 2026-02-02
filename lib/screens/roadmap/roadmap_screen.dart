/// Personalized roadmap screen - Uses Flask Backend API
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class RoadmapScreen extends StatefulWidget {
  final List<dynamic>? missingSkills;
  final List<dynamic>? skillsToImprove;

  const RoadmapScreen({
    super.key,
    this.missingSkills,
    this.skillsToImprove,
  });

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  Map<String, dynamic>? _roadmapData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoadmap();
  }

  Future<void> _loadRoadmap() async {
    try {
      // Debug: Show raw widget data
      debugPrint('RoadmapScreen - Raw widget.missingSkills: ${widget.missingSkills}');
      debugPrint('RoadmapScreen - Raw widget.skillsToImprove: ${widget.skillsToImprove}');
      debugPrint('RoadmapScreen - missingSkills length: ${widget.missingSkills?.length ?? 0}');
      debugPrint('RoadmapScreen - skillsToImprove length: ${widget.skillsToImprove?.length ?? 0}');
      
      // If we have data, show first item structure
      if (widget.missingSkills != null && widget.missingSkills!.isNotEmpty) {
        debugPrint('RoadmapScreen - First missing skill: ${widget.missingSkills![0]}');
        debugPrint('RoadmapScreen - First missing skill type: ${widget.missingSkills![0].runtimeType}');
      }
      
      // Extract skill IDs from the passed data
      final missingSkillIds = widget.missingSkills
          ?.map((s) => s['skill_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList() ?? [];
      
      final skillsToImprove = widget.skillsToImprove
          ?.map((s) => <String, dynamic>{
                'skill_id': s['skill_id']?.toString() ?? '',
                'current_level': s['current_level']?.toString() ?? 'beginner',
              })
          .where((m) => (m['skill_id'] as String).isNotEmpty)
          .toList() ?? [];

      debugPrint('RoadmapScreen - Extracted missingSkillIds: $missingSkillIds');
      debugPrint('RoadmapScreen - Extracted skillsToImprove: $skillsToImprove');

      // Call Flask Backend API for roadmap generation
      final roadmap = await ApiService.generateRoadmap(
        missingSkills: missingSkillIds,
        skillsToImprove: skillsToImprove,
      );

      debugPrint('RoadmapScreen - Roadmap data: $roadmap');

      if (mounted) {
        setState(() {
          _roadmapData = roadmap;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('RoadmapScreen - Error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error generating roadmap: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildError()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unable to generate roadmap',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final roadmap = _roadmapData?['roadmap'] as List<dynamic>? ?? [];
    final totalSkills = _roadmapData?['total_skills'] ?? 0;
    final totalHours = _roadmapData?['total_estimated_hours'] ?? 0;
    final estimatedWeeks = _roadmapData?['estimated_weeks'] ?? 1;

    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSummaryCard(totalSkills, totalHours, estimatedWeeks),
                const SizedBox(height: 24),
                if (roadmap.isEmpty)
                  _buildEmptyState()
                else
                  _buildTimeline(roadmap),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Learning Roadmap',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.route,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Personalized Path',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Learning Roadmap',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int totalSkills, int totalHours, int weeks) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          _buildSummaryItem(
            '$totalSkills',
            'Skills to Learn',
            AppTheme.primaryColor,
            Icons.school,
          ),
          _buildDivider(),
          _buildSummaryItem(
            '~$totalHours',
            'Total Hours',
            AppTheme.accentColor,
            Icons.access_time,
          ),
          _buildDivider(),
          _buildSummaryItem(
            '~$weeks',
            'Weeks',
            AppTheme.warningColor,
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        children: [
          Icon(
            Icons.celebration,
            size: 64,
            color: AppTheme.accentColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Congratulations!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have all the skills needed for this role!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<dynamic> roadmap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step-by-Step Learning Path',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Follow this roadmap to achieve your career goals',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        ...roadmap.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value as Map<String, dynamic>;
          final isLast = index == roadmap.length - 1;
          return _buildTimelineItem(step, isLast);
        }),
      ],
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> step, bool isLast) {
    final stepNumber = step['step'] ?? 1;
    final skillName = step['skill_name'] ?? '';
    final category = step['category'] ?? '';
    final status = step['status'] ?? 'New Skill';
    final targetLevel = step['target_level'] ?? 'intermediate';
    final currentLevel = step['current_level'];
    final estimatedHours = step['estimated_hours'] ?? 0;
    final resources = step['resources'] as List<dynamic>? ?? [];

    final isNew = status == 'New Skill';
    final color = isNew ? AppTheme.errorColor : AppTheme.warningColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 150 + (resources.length * 50).toDouble(),
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        skillName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isNew ? 'New' : 'Upgrade',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Meta info
                Row(
                  children: [
                    Icon(Icons.category_outlined, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      category,
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.flag_outlined, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      currentLevel != null
                          ? '$currentLevel → $targetLevel'
                          : 'Target: $targetLevel',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '~$estimatedHours hours',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                // Resources
                if (resources.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    'Recommended Resources:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...resources.map((res) => _buildResourceItem(res as Map<String, dynamic>)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceItem(Map<String, dynamic> resource) {
    final name = resource['name'] ?? '';
    final type = resource['type'] ?? '';
    final url = resource['url'] ?? '';
    final hours = resource['hours'] ?? 0;

    IconData typeIcon;
    switch (type.toLowerCase()) {
      case 'video':
        typeIcon = Icons.play_circle_outline;
        break;
      case 'course':
        typeIcon = Icons.school_outlined;
        break;
      case 'documentation':
        typeIcon = Icons.description_outlined;
        break;
      case 'book':
        typeIcon = Icons.menu_book_outlined;
        break;
      case 'tutorial':
        typeIcon = Icons.article_outlined;
        break;
      default:
        typeIcon = Icons.link;
    }

    return InkWell(
      onTap: url.isNotEmpty ? () => _launchUrl(url) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(typeIcon, size: 18, color: AppTheme.primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    '$type • ~$hours hours',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, size: 16, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}
