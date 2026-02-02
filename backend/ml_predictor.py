"""
SkillSync ML Predictor Module
Uses trained ML model (PKL) for job readiness prediction
"""

import joblib
import pandas as pd
import os

# Model file paths (place your PKL files in backend/models/ folder)
MODEL_DIR = os.path.join(os.path.dirname(__file__), 'models')
MODEL_PATH = os.path.join(MODEL_DIR, 'job_readiness_model.pkl')
FEATURES_PATH = os.path.join(MODEL_DIR, 'model_features.pkl')

# Global model and features (loaded once)
_model = None
_features = None


def load_model():
    """Load the ML model and features from PKL files"""
    global _model, _features
    
    if _model is None:
        if os.path.exists(MODEL_PATH) and os.path.exists(FEATURES_PATH):
            _model = joblib.load(MODEL_PATH)
            _features = joblib.load(FEATURES_PATH)
            print(f"✓ ML Model loaded successfully from {MODEL_PATH}")
        else:
            print(f"⚠ ML Model files not found at {MODEL_DIR}")
            print("  Please place job_readiness_model.pkl and model_features.pkl in backend/models/")
            return False
    return True


def predict_readiness(user_skills: dict, target_role: str) -> int:
    """
    Predict job readiness score using ML model
    
    Args:
        user_skills: Dict mapping skill_id to level (0-3)
                    e.g., {"python": 2, "sql": 1, "java": 0}
        target_role: Target job role (e.g., "data_analyst", "ml_engineer", "backend_dev")
    
    Returns:
        Job readiness score (0-100)
    """
    if not load_model():
        # Fallback to simple calculation if model not available
        return _calculate_fallback_readiness(user_skills, target_role)
    
    # Convert skill levels to numeric values
    skill_levels = {
        'beginner': 1,
        'intermediate': 2,
        'advanced': 3
    }
    
    # Map skill IDs to model feature names
    skill_mapping = {
        'python': 'python',
        'sql': 'sql',
        'java': 'java',
        'machine_learning': 'ml',
        'deep_learning': 'ml',
        'tensorflow': 'ml',
        'pandas': 'stats',
        'numpy': 'stats',
        'data_viz': 'stats',
        'git': 'git',
    }
    
    # Role mapping to model format
    role_mapping = {
        'data_analyst': 'data_analyst',
        'data_scientist': 'data_analyst',
        'ai_engineer': 'ml_engineer',
        'backend_developer': 'backend_dev',
        'software_developer': 'backend_dev',
        'web_developer': 'backend_dev',
        'fullstack_developer': 'backend_dev',
        'devops_engineer': 'backend_dev',
    }
    
    # Prepare input data
    user_data = {
        "python": 0,
        "sql": 0,
        "java": 0,
        "ml": 0,
        "stats": 0,
        "git": 0,
        "projects_completed": 2,  # Default assumption
        "internships": 1,        # Default assumption
        "target_role_data_analyst": 0,
        "target_role_ml_engineer": 0,
        "target_role_backend_dev": 0
    }
    
    # Map user skills to model features
    for skill_id, level in user_skills.items():
        # Convert string level to numeric
        if isinstance(level, str):
            level = skill_levels.get(level.lower(), 1)
        
        # Map to model feature
        model_feature = skill_mapping.get(skill_id)
        if model_feature and model_feature in user_data:
            # Use max in case multiple skills map to same feature
            user_data[model_feature] = max(user_data[model_feature], level)
    
    # Set target role
    mapped_role = role_mapping.get(target_role, 'backend_dev')
    role_key = f"target_role_{mapped_role}"
    if role_key in user_data:
        user_data[role_key] = 1
    
    # Create DataFrame
    df = pd.DataFrame([user_data])
    
    # Ensure all features exist
    for col in _features:
        if col not in df:
            df[col] = 0
    
    df = df[_features]
    
    # Predict
    prediction = _model.predict(df)[0]
    
    return max(0, min(100, int(prediction)))


def _calculate_fallback_readiness(user_skills: dict, target_role: str) -> int:
    """Fallback calculation when ML model is not available"""
    # Simple weighted calculation
    ROLES = {
        "data_analyst": ["python", "sql", "pandas", "data_viz"],
        "data_scientist": ["python", "machine_learning", "pandas", "numpy"],
        "ai_engineer": ["python", "machine_learning", "deep_learning", "tensorflow"],
        "ml_engineer": ["python", "machine_learning", "deep_learning", "tensorflow"],
        "backend_developer": ["python", "java", "sql", "git", "rest_api"],
        "software_developer": ["python", "java", "dsa", "oop", "git"],
        "web_developer": ["html", "css", "javascript", "react", "git"],
        "fullstack_developer": ["html", "css", "javascript", "react", "nodejs", "git"],
    }
    
    skill_levels = {'beginner': 1, 'intermediate': 2, 'advanced': 3}
    
    required_skills = ROLES.get(target_role, ["python", "git"])
    score = 0
    max_score = len(required_skills) * 3 * 10
    
    for skill in required_skills:
        if skill in user_skills:
            level = user_skills[skill]
            if isinstance(level, str):
                level = skill_levels.get(level.lower(), 1)
            score += level * 10
    
    return int((score / max_score) * 100) if max_score > 0 else 0


def get_skill_recommendations(user_skills: dict, target_role: str) -> dict:
    """
    Get skill recommendations based on gap analysis
    
    Returns:
        Dict with 'priority_skills' and 'additional_skills' lists
    """
    ROLE_SKILLS = {
        "data_analyst": {
            "core": ["python", "sql", "pandas", "data_viz"],
            "additional": ["numpy", "communication", "problem_solving"]
        },
        "data_scientist": {
            "core": ["python", "machine_learning", "pandas", "numpy", "sql"],
            "additional": ["deep_learning", "tensorflow", "data_viz"]
        },
        "ai_engineer": {
            "core": ["python", "machine_learning", "deep_learning", "tensorflow"],
            "additional": ["numpy", "pandas", "system_design"]
        },
        "backend_developer": {
            "core": ["python", "sql", "rest_api", "git", "docker"],
            "additional": ["mongodb", "aws", "system_design"]
        },
        "software_developer": {
            "core": ["python", "dsa", "oop", "git", "sql"],
            "additional": ["system_design", "java", "problem_solving"]
        },
        "web_developer": {
            "core": ["html", "css", "javascript", "react", "git"],
            "additional": ["nodejs", "rest_api", "mongodb"]
        },
    }
    
    role_skills = ROLE_SKILLS.get(target_role, ROLE_SKILLS["software_developer"])
    
    user_skill_ids = set(user_skills.keys())
    
    # Find missing core skills
    priority_skills = [s for s in role_skills["core"] if s not in user_skill_ids]
    
    # Find missing additional skills
    additional_skills = [s for s in role_skills["additional"] if s not in user_skill_ids]
    
    return {
        "priority_skills": priority_skills[:5],  # Top 5 priority
        "additional_skills": additional_skills[:3]  # Top 3 additional
    }


# Test the module
if __name__ == '__main__':
    # Sample test
    user_skills = {
        'python': 'intermediate',
        'sql': 'beginner',
        'pandas': 'beginner'
    }
    
    score = predict_readiness(user_skills, 'data_analyst')
    print(f"Predicted Job Readiness: {score}%")
    
    recommendations = get_skill_recommendations(user_skills, 'data_analyst')
    print(f"Priority Skills: {recommendations['priority_skills']}")
    print(f"Additional Skills: {recommendations['additional_skills']}")
