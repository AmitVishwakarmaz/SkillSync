"""
SkillSync Backend - Skill Analysis Module
Contains core analysis algorithms for skill gap mapping
"""

import pandas as pd
import os
from typing import Dict, List, Tuple

DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')


class SkillAnalyzer:
    """Core class for skill gap analysis"""
    
    SKILL_LEVELS = {
        'beginner': 1,
        'intermediate': 2,
        'advanced': 3
    }
    
    def __init__(self):
        self.skills_df = pd.read_csv(os.path.join(DATA_DIR, 'skills.csv'))
        self.roles_df = pd.read_csv(os.path.join(DATA_DIR, 'job_roles.csv'))
        self.resources_df = pd.read_csv(os.path.join(DATA_DIR, 'resources.csv'))
    
    def analyze_gap(
        self,
        user_skills: Dict[str, str],
        target_role: str
    ) -> Dict:
        """
        Analyze skill gap between user skills and job role requirements
        
        Args:
            user_skills: Dict mapping skill_id to level (e.g., {"python": "intermediate"})
            target_role: Job role ID
            
        Returns:
            Analysis result with proficient, to_improve, and missing skills
        """
        # Get role requirements
        role = self.roles_df[self.roles_df['role_id'] == target_role]
        if role.empty:
            return {"error": "Role not found"}
        
        required_skills = role.iloc[0]['required_skills'].split(',')
        required_skills = [s.strip() for s in required_skills]
        
        proficient = []
        to_improve = []
        missing = []
        
        for skill_id in required_skills:
            skill_info = self._get_skill_info(skill_id)
            if not skill_info:
                continue
            
            if skill_id in user_skills:
                user_level = user_skills[skill_id].lower()
                if self._is_proficient(user_level):
                    proficient.append({
                        **skill_info,
                        'current_level': user_level
                    })
                else:
                    to_improve.append({
                        **skill_info,
                        'current_level': user_level,
                        'target_level': 'intermediate'
                    })
            else:
                missing.append(skill_info)
        
        # Calculate match percentage
        total = len(required_skills)
        match = (len(proficient) + len(to_improve) * 0.5) / total * 100 if total > 0 else 0
        
        return {
            'match_percentage': int(match),
            'proficient_skills': proficient,
            'skills_to_improve': to_improve,
            'missing_skills': missing
        }
    
    def generate_roadmap(
        self,
        missing_skills: List[str],
        skills_to_improve: List[Dict]
    ) -> List[Dict]:
        """
        Generate personalized learning roadmap
        
        Args:
            missing_skills: List of skill IDs to learn
            skills_to_improve: List of dicts with skill_id and current_level
            
        Returns:
            Ordered list of learning steps with resources
        """
        roadmap = []
        step = 1
        
        # Priority order for categories
        category_order = [
            'Core CS', 'Programming', 'Web Development',
            'Database', 'AI/ML', 'Data Science',
            'Tools', 'Cloud', 'Soft Skills'
        ]
        
        # Sort missing skills by category priority
        sorted_missing = self._sort_by_category(missing_skills, category_order)
        
        for skill_id in sorted_missing:
            skill_info = self._get_skill_info(skill_id)
            if not skill_info:
                continue
            
            resources = self._get_resources(skill_id, 'beginner')
            
            roadmap.append({
                'step': step,
                'type': 'new',
                **skill_info,
                'target_level': 'intermediate',
                'resources': resources
            })
            step += 1
        
        # Add skills to improve
        for skill_data in skills_to_improve:
            skill_id = skill_data.get('skill_id')
            current = skill_data.get('current_level', 'beginner')
            
            skill_info = self._get_skill_info(skill_id)
            if not skill_info:
                continue
            
            target = 'intermediate' if current == 'beginner' else 'advanced'
            resources = self._get_resources(skill_id, target)
            
            roadmap.append({
                'step': step,
                'type': 'improve',
                **skill_info,
                'current_level': current,
                'target_level': target,
                'resources': resources
            })
            step += 1
        
        return roadmap
    
    def _get_skill_info(self, skill_id: str) -> Dict:
        """Get skill information by ID"""
        skill = self.skills_df[self.skills_df['skill_id'] == skill_id]
        if skill.empty:
            return None
        
        row = skill.iloc[0]
        return {
            'skill_id': row['skill_id'],
            'skill_name': row['skill_name'],
            'category': row['category'],
            'description': row['description']
        }
    
    def _get_resources(self, skill_id: str, level: str) -> List[Dict]:
        """Get learning resources for a skill"""
        resources = self.resources_df[self.resources_df['skill_id'] == skill_id]
        
        # Filter by difficulty if possible
        level_resources = resources[resources['difficulty'] == level]
        if level_resources.empty:
            level_resources = resources
        
        result = []
        for _, row in level_resources.head(3).iterrows():
            result.append({
                'name': row['resource_name'],
                'type': row['resource_type'],
                'url': row['url'],
                'hours': int(row['estimated_hours'])
            })
        
        return result
    
    def _is_proficient(self, level: str) -> bool:
        """Check if user level meets requirement (intermediate)"""
        return self.SKILL_LEVELS.get(level, 0) >= 2
    
    def _sort_by_category(
        self,
        skill_ids: List[str],
        category_order: List[str]
    ) -> List[str]:
        """Sort skills by category priority"""
        def get_priority(skill_id):
            skill = self.skills_df[self.skills_df['skill_id'] == skill_id]
            if skill.empty:
                return 99
            category = skill.iloc[0]['category']
            try:
                return category_order.index(category)
            except ValueError:
                return 99
        
        return sorted(skill_ids, key=get_priority)


# Example usage
if __name__ == '__main__':
    analyzer = SkillAnalyzer()
    
    # Sample user skills
    user_skills = {
        'python': 'intermediate',
        'sql': 'beginner',
        'pandas': 'beginner'
    }
    
    # Analyze for Data Analyst role
    result = analyzer.analyze_gap(user_skills, 'data_analyst')
    
    print("=== Skill Gap Analysis ===")
    print(f"Match: {result['match_percentage']}%")
    print(f"Proficient: {len(result['proficient_skills'])}")
    print(f"To Improve: {len(result['skills_to_improve'])}")
    print(f"Missing: {len(result['missing_skills'])}")
    
    # Generate roadmap
    missing = [s['skill_id'] for s in result['missing_skills']]
    to_improve = [{'skill_id': s['skill_id'], 'current_level': s['current_level']} 
                  for s in result['skills_to_improve']]
    
    roadmap = analyzer.generate_roadmap(missing, to_improve)
    
    print("\n=== Learning Roadmap ===")
    for step in roadmap:
        print(f"Step {step['step']}: {step['skill_name']} ({step['type']})")
