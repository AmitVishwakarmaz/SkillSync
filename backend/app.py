"""
SkillSync Backend - Flask API Server
Skill Gap Mapper for Students vs Job Markets

This backend provides APIs for:
- Skill gap analysis with ML-based readiness prediction
- Personalized learning roadmap
- Progress tracking
- User management
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import os
import json
from datetime import datetime

# Import ML predictor for job readiness
from ml_predictor import predict_readiness, get_skill_recommendations

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Data directory
DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')
USERS_FILE = os.path.join(DATA_DIR, 'users.csv')

# Load CSV data
def load_skills():
    """Load skills database"""
    return pd.read_csv(os.path.join(DATA_DIR, 'skills.csv'))

def load_job_roles():
    """Load job roles database"""
    return pd.read_csv(os.path.join(DATA_DIR, 'job_roles.csv'))

def load_resources():
    """Load learning resources database"""
    return pd.read_csv(os.path.join(DATA_DIR, 'resources.csv'))

def load_users():
    """Load users database, create if not exists"""
    if not os.path.exists(USERS_FILE):
        df = pd.DataFrame(columns=[
            'user_id', 'name', 'email', 'degree', 'branch', 'semester',
            'interests', 'skills', 'selected_role', 'progress', 'created_at'
        ])
        df.to_csv(USERS_FILE, index=False)
    return pd.read_csv(USERS_FILE)

def save_users(df):
    """Save users database"""
    df.to_csv(USERS_FILE, index=False)


# ==================== API ENDPOINTS ====================

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'message': 'SkillSync API is running (with ML Model)',
        'timestamp': datetime.now().isoformat()
    })


# ==================== SKILLS ENDPOINTS ====================

@app.route('/api/skills', methods=['GET'])
def get_all_skills():
    """Get all available skills"""
    skills_df = load_skills()
    
    # Group by category
    skills_by_category = {}
    for _, row in skills_df.iterrows():
        category = row['category']
        if category not in skills_by_category:
            skills_by_category[category] = []
        skills_by_category[category].append({
            'id': row['skill_id'],
            'name': row['skill_name'],
            'description': row['description']
        })
    
    return jsonify({
        'success': True,
        'data': skills_by_category,
        'total_skills': len(skills_df)
    })


@app.route('/api/skills/<skill_id>', methods=['GET'])
def get_skill(skill_id):
    """Get a specific skill by ID"""
    skills_df = load_skills()
    skill = skills_df[skills_df['skill_id'] == skill_id]
    
    if skill.empty:
        return jsonify({'success': False, 'error': 'Skill not found'}), 404
    
    skill_data = skill.iloc[0].to_dict()
    
    # Get resources for this skill
    resources_df = load_resources()
    skill_resources = resources_df[resources_df['skill_id'] == skill_id]
    skill_data['resources'] = skill_resources.to_dict('records')
    
    return jsonify({'success': True, 'data': skill_data})


# ==================== JOB ROLES ENDPOINTS ====================

@app.route('/api/job-roles', methods=['GET'])
def get_all_job_roles():
    """Get all available job roles"""
    roles_df = load_job_roles()
    
    roles = []
    for _, row in roles_df.iterrows():
        required_skills = row['required_skills'].split(',')
        roles.append({
            'id': row['role_id'],
            'name': row['role_name'],
            'description': row['description'],
            'icon': row['icon'],
            'required_skills': required_skills,
            'skill_count': len(required_skills)
        })
    
    return jsonify({'success': True, 'data': roles})


@app.route('/api/job-roles/<role_id>', methods=['GET'])
def get_job_role(role_id):
    """Get a specific job role with detailed skill requirements"""
    roles_df = load_job_roles()
    role = roles_df[roles_df['role_id'] == role_id]
    
    if role.empty:
        return jsonify({'success': False, 'error': 'Role not found'}), 404
    
    role_data = role.iloc[0]
    required_skill_ids = role_data['required_skills'].split(',')
    
    # Get detailed skill info
    skills_df = load_skills()
    required_skills = []
    for skill_id in required_skill_ids:
        skill = skills_df[skills_df['skill_id'] == skill_id.strip()]
        if not skill.empty:
            required_skills.append({
                'id': skill.iloc[0]['skill_id'],
                'name': skill.iloc[0]['skill_name'],
                'category': skill.iloc[0]['category']
            })
    
    return jsonify({
        'success': True,
        'data': {
            'id': role_data['role_id'],
            'name': role_data['role_name'],
            'description': role_data['description'],
            'icon': role_data['icon'],
            'required_skills': required_skills
        }
    })


# ==================== SKILL GAP ANALYSIS (ML-POWERED) ====================

@app.route('/api/analyze-gap', methods=['POST'])
def analyze_skill_gap():
    """
    Analyze skill gap between user skills and job role requirements.
    Uses ML model for job readiness prediction.
    
    Request body:
    {
        "user_skills": {
            "python": "intermediate",
            "sql": "beginner"
        },
        "target_role": "data_analyst"
    }
    """
    data = request.get_json()
    
    if not data:
        return jsonify({'success': False, 'error': 'No data provided'}), 400
    
    user_skills = data.get('user_skills', {})
    target_role = data.get('target_role')
    
    if not target_role:
        return jsonify({'success': False, 'error': 'target_role is required'}), 400
    
    # Get role requirements
    roles_df = load_job_roles()
    role = roles_df[roles_df['role_id'] == target_role]
    
    if role.empty:
        return jsonify({'success': False, 'error': 'Role not found'}), 404
    
    role_data = role.iloc[0]
    required_skill_ids = [s.strip() for s in role_data['required_skills'].split(',')]
    
    # Get skill details
    skills_df = load_skills()
    
    # Analyze gaps
    proficient_skills = []
    skills_to_improve = []
    missing_skills = []
    
    skill_level_values = {'beginner': 1, 'intermediate': 2, 'advanced': 3}
    required_level = 'intermediate'  # Default required level
    
    for skill_id in required_skill_ids:
        skill_info = skills_df[skills_df['skill_id'] == skill_id]
        if skill_info.empty:
            continue
            
        skill_name = skill_info.iloc[0]['skill_name']
        skill_category = skill_info.iloc[0]['category']
        
        if skill_id in user_skills:
            user_level = user_skills[skill_id].lower()
            user_level_value = skill_level_values.get(user_level, 0)
            required_level_value = skill_level_values.get(required_level, 2)
            
            if user_level_value >= required_level_value:
                proficient_skills.append({
                    'skill_id': skill_id,
                    'skill_name': skill_name,
                    'category': skill_category,
                    'current_level': user_level,
                    'required_level': required_level
                })
            else:
                skills_to_improve.append({
                    'skill_id': skill_id,
                    'skill_name': skill_name,
                    'category': skill_category,
                    'current_level': user_level,
                    'required_level': required_level,
                    'gap': required_level_value - user_level_value
                })
        else:
            missing_skills.append({
                'skill_id': skill_id,
                'skill_name': skill_name,
                'category': skill_category,
                'required_level': required_level
            })
    
    # ===== USE ML MODEL FOR JOB READINESS PREDICTION =====
    ml_readiness_score = predict_readiness(user_skills, target_role)
    
    # Get skill recommendations from ML module
    recommendations = get_skill_recommendations(user_skills, target_role)
    
    # Combine ML score with gap analysis
    total_required = len(required_skill_ids)
    
    return jsonify({
        'success': True,
        'data': {
            'target_role': {
                'id': role_data['role_id'],
                'name': role_data['role_name'],
                'icon': role_data['icon']
            },
            'match_percentage': ml_readiness_score,  # ML-predicted score
            'proficient_skills': proficient_skills,
            'skills_to_improve': skills_to_improve,
            'missing_skills': missing_skills,
            'recommendations': recommendations,
            'summary': {
                'total_required': total_required,
                'proficient': len(proficient_skills),
                'to_improve': len(skills_to_improve),
                'missing': len(missing_skills),
                'ml_readiness_score': ml_readiness_score
            }
        }
    })


# ==================== LEARNING ROADMAP ====================

@app.route('/api/roadmap', methods=['POST'])
def generate_roadmap():
    """
    Generate personalized learning roadmap based on skill gaps
    
    Request body:
    {
        "missing_skills": ["javascript", "react"],
        "skills_to_improve": [{"skill_id": "git", "current_level": "beginner"}]
    }
    """
    data = request.get_json()
    
    if not data:
        return jsonify({'success': False, 'error': 'No data provided'}), 400
    
    missing_skills = data.get('missing_skills', [])
    skills_to_improve = data.get('skills_to_improve', [])
    
    resources_df = load_resources()
    skills_df = load_skills()
    
    roadmap = []
    step = 1
    
    # Priority 1: Missing skills (sorted by category - Core CS first, then Programming, etc.)
    category_priority = {
        'Core CS': 1, 'Programming': 2, 'Web Development': 3,
        'Database': 4, 'AI/ML': 5, 'Data Science': 6,
        'Tools': 7, 'Cloud': 8, 'Soft Skills': 9, 'Methodology': 10
    }
    
    # Sort missing skills by category priority
    missing_with_priority = []
    for skill_id in missing_skills:
        skill_info = skills_df[skills_df['skill_id'] == skill_id]
        if not skill_info.empty:
            category = skill_info.iloc[0]['category']
            priority = category_priority.get(category, 99)
            missing_with_priority.append((skill_id, priority, skill_info.iloc[0]))
    
    missing_with_priority.sort(key=lambda x: x[1])
    
    for skill_id, _, skill_info in missing_with_priority:
        skill_resources = resources_df[resources_df['skill_id'] == skill_id]
        
        resources = []
        total_hours = 0
        for _, res in skill_resources.iterrows():
            resources.append({
                'name': res['resource_name'],
                'type': res['resource_type'],
                'url': res['url'],
                'difficulty': res['difficulty'],
                'hours': int(res['estimated_hours'])
            })
            total_hours += int(res['estimated_hours'])
        
        roadmap.append({
            'step': step,
            'skill_id': skill_id,
            'skill_name': skill_info['skill_name'],
            'category': skill_info['category'],
            'status': 'New Skill',
            'target_level': 'intermediate',
            'estimated_hours': total_hours,
            'resources': resources[:3]  # Top 3 resources
        })
        step += 1
    
    # Priority 2: Skills to improve
    for skill_data in skills_to_improve:
        skill_id = skill_data.get('skill_id')
        current_level = skill_data.get('current_level', 'beginner')
        
        skill_info = skills_df[skills_df['skill_id'] == skill_id]
        if skill_info.empty:
            continue
        
        skill_resources = resources_df[resources_df['skill_id'] == skill_id]
        
        # Filter resources for next level
        next_level = 'intermediate' if current_level == 'beginner' else 'advanced'
        level_resources = skill_resources[skill_resources['difficulty'] == next_level]
        if level_resources.empty:
            level_resources = skill_resources
        
        resources = []
        total_hours = 0
        for _, res in level_resources.iterrows():
            resources.append({
                'name': res['resource_name'],
                'type': res['resource_type'],
                'url': res['url'],
                'difficulty': res['difficulty'],
                'hours': int(res['estimated_hours'])
            })
            total_hours += int(res['estimated_hours'])
        
        roadmap.append({
            'step': step,
            'skill_id': skill_id,
            'skill_name': skill_info.iloc[0]['skill_name'],
            'category': skill_info.iloc[0]['category'],
            'status': 'Upgrade',
            'current_level': current_level,
            'target_level': next_level,
            'estimated_hours': total_hours,
            'resources': resources[:2]  # Top 2 resources
        })
        step += 1
    
    # Calculate totals
    total_estimated_hours = sum(item['estimated_hours'] for item in roadmap)
    
    return jsonify({
        'success': True,
        'data': {
            'roadmap': roadmap,
            'total_skills': len(roadmap),
            'total_estimated_hours': total_estimated_hours,
            'estimated_weeks': max(1, total_estimated_hours // 10)  # Assuming 10 hrs/week
        }
    })


# ==================== USER PROGRESS ====================

@app.route('/api/users/<user_id>/progress', methods=['GET'])
def get_user_progress(user_id):
    """Get user's learning progress"""
    users_df = load_users()
    user = users_df[users_df['user_id'] == user_id]
    
    if user.empty:
        return jsonify({'success': False, 'error': 'User not found'}), 404
    
    user_data = user.iloc[0]
    progress = json.loads(user_data['progress']) if pd.notna(user_data['progress']) else {}
    
    return jsonify({
        'success': True,
        'data': {
            'user_id': user_id,
            'progress': progress
        }
    })


@app.route('/api/users/<user_id>/progress', methods=['POST'])
def update_user_progress(user_id):
    """
    Update user's learning progress
    
    Request body:
    {
        "skill_id": "python",
        "status": "completed"  // not_started, in_progress, completed
    }
    """
    data = request.get_json()
    
    if not data:
        return jsonify({'success': False, 'error': 'No data provided'}), 400
    
    skill_id = data.get('skill_id')
    status = data.get('status')
    
    if not skill_id or not status:
        return jsonify({'success': False, 'error': 'skill_id and status are required'}), 400
    
    if status not in ['not_started', 'in_progress', 'completed']:
        return jsonify({'success': False, 'error': 'Invalid status'}), 400
    
    users_df = load_users()
    user_idx = users_df[users_df['user_id'] == user_id].index
    
    if len(user_idx) == 0:
        # Create new user entry
        new_user = {
            'user_id': user_id,
            'name': '',
            'email': '',
            'degree': '',
            'branch': '',
            'semester': '',
            'interests': '[]',
            'skills': '{}',
            'selected_role': '',
            'progress': json.dumps({skill_id: status}),
            'created_at': datetime.now().isoformat()
        }
        users_df = pd.concat([users_df, pd.DataFrame([new_user])], ignore_index=True)
    else:
        idx = user_idx[0]
        progress = json.loads(users_df.at[idx, 'progress']) if pd.notna(users_df.at[idx, 'progress']) else {}
        progress[skill_id] = status
        users_df.at[idx, 'progress'] = json.dumps(progress)
    
    save_users(users_df)
    
    return jsonify({
        'success': True,
        'message': 'Progress updated successfully'
    })


@app.route('/api/users/<user_id>/save', methods=['POST'])
def save_user_data(user_id):
    """
    Save/update user profile and skills
    
    Request body:
    {
        "name": "John Doe",
        "email": "john@example.com",
        "degree": "B.Tech",
        "branch": "Computer Science",
        "semester": "5th Semester",
        "interests": ["Web Development", "AI"],
        "skills": {"python": "intermediate", "sql": "beginner"},
        "selected_role": "data_analyst"
    }
    """
    data = request.get_json()
    
    if not data:
        return jsonify({'success': False, 'error': 'No data provided'}), 400
    
    users_df = load_users()
    user_idx = users_df[users_df['user_id'] == user_id].index
    
    user_data = {
        'user_id': user_id,
        'name': data.get('name', ''),
        'email': data.get('email', ''),
        'degree': data.get('degree', ''),
        'branch': data.get('branch', ''),
        'semester': data.get('semester', ''),
        'interests': json.dumps(data.get('interests', [])),
        'skills': json.dumps(data.get('skills', {})),
        'selected_role': data.get('selected_role', ''),
        'progress': '{}',
        'created_at': datetime.now().isoformat()
    }
    
    if len(user_idx) == 0:
        users_df = pd.concat([users_df, pd.DataFrame([user_data])], ignore_index=True)
    else:
        idx = user_idx[0]
        for key, value in user_data.items():
            if key != 'progress':  # Don't overwrite progress
                users_df.at[idx, key] = value
    
    save_users(users_df)
    
    return jsonify({
        'success': True,
        'message': 'User data saved successfully'
    })


# ==================== RESOURCES ENDPOINTS ====================

@app.route('/api/resources/<skill_id>', methods=['GET'])
def get_skill_resources(skill_id):
    """Get learning resources for a specific skill"""
    resources_df = load_resources()
    skill_resources = resources_df[resources_df['skill_id'] == skill_id]
    
    if skill_resources.empty:
        return jsonify({
            'success': True,
            'data': [],
            'message': 'No resources found for this skill'
        })
    
    resources = []
    for _, res in skill_resources.iterrows():
        resources.append({
            'name': res['resource_name'],
            'type': res['resource_type'],
            'url': res['url'],
            'difficulty': res['difficulty'],
            'estimated_hours': int(res['estimated_hours'])
        })
    
    return jsonify({
        'success': True,
        'data': resources
    })


# ==================== MAIN ====================

if __name__ == '__main__':
    print("=" * 50)
    print("  SkillSync API Server")
    print("  Skill Gap Mapper for Students")
    print("=" * 50)
    print("\nAvailable endpoints:")
    print("  GET  /api/health          - Health check")
    print("  GET  /api/skills          - Get all skills")
    print("  GET  /api/job-roles       - Get all job roles")
    print("  POST /api/analyze-gap     - Analyze skill gap")
    print("  POST /api/roadmap         - Generate learning roadmap")
    print("  POST /api/users/<id>/save - Save user data")
    print("  GET  /api/users/<id>/progress - Get progress")
    print("  POST /api/users/<id>/progress - Update progress")
    print("\n" + "=" * 50)
    
    app.run(debug=True, host='0.0.0.0', port=5000)
