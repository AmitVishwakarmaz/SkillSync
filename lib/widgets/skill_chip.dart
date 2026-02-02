/// Skill chip widget for displaying and selecting skills
library;

import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/skill_model.dart';

class SkillChip extends StatelessWidget {
  final Skill skill;
  final SkillLevel? level;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLevelChange;

  const SkillChip({
    super.key,
    required this.skill,
    this.level,
    this.isSelected = false,
    this.onTap,
    this.onLevelChange,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isSelected 
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.primaryColor 
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                if (isSelected) const SizedBox(width: 6),
                Text(
                  skill.name,
                  style: TextStyle(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (level != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getLevelColor(level!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      level!.displayName[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return Colors.orange;
      case SkillLevel.intermediate:
        return Colors.blue;
      case SkillLevel.advanced:
        return Colors.green;
    }
  }
}

class SkillSelectionCard extends StatelessWidget {
  final Skill skill;
  final SkillLevel? selectedLevel;
  final ValueChanged<SkillLevel?>? onLevelChanged;

  const SkillSelectionCard({
    super.key,
    required this.skill,
    this.selectedLevel,
    this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedLevel != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? AppTheme.cardShadow : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skill header
          InkWell(
            onTap: () {
              if (isSelected) {
                onLevelChanged?.call(null);
              } else {
                onLevelChanged?.call(SkillLevel.beginner);
              }
            },
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusMedium),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? AppTheme.primaryColor 
                                : AppTheme.textPrimary,
                          ),
                        ),
                        if (skill.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            skill.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
          
          // Level selection (visible when selected)
          if (isSelected)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: SkillLevel.values.map((level) {
                  final isLevelSelected = selectedLevel == level;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onLevelChanged?.call(level),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isLevelSelected 
                              ? _getLevelColor(level)
                              : _getLevelColor(level).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          level.displayName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isLevelSelected 
                                ? Colors.white 
                                : _getLevelColor(level),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Color _getLevelColor(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return Colors.orange;
      case SkillLevel.intermediate:
        return Colors.blue;
      case SkillLevel.advanced:
        return Colors.green;
    }
  }
}
