# SkillSync Backend

Flask API server for Skill Gap Analysis

## Setup

1. Install Python 3.8+

2. Create virtual environment (optional but recommended):
```bash
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Run the server:
```bash
python app.py
```

Server will start at `http://localhost:5000`

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/skills` | Get all skills by category |
| GET | `/api/job-roles` | Get all job roles |
| GET | `/api/job-roles/{id}` | Get job role details |
| POST | `/api/analyze-gap` | Analyze skill gap |
| POST | `/api/roadmap` | Generate learning roadmap |
| POST | `/api/users/{id}/save` | Save user data |
| GET | `/api/users/{id}/progress` | Get user progress |
| POST | `/api/users/{id}/progress` | Update progress |
| GET | `/api/resources/{skill_id}` | Get learning resources |

## Example API Calls

### Analyze Skill Gap
```bash
curl -X POST http://localhost:5000/api/analyze-gap \
  -H "Content-Type: application/json" \
  -d '{
    "user_skills": {"python": "intermediate", "sql": "beginner"},
    "target_role": "data_analyst"
  }'
```

### Generate Roadmap
```bash
curl -X POST http://localhost:5000/api/roadmap \
  -H "Content-Type: application/json" \
  -d '{
    "missing_skills": ["pandas", "data_viz"],
    "skills_to_improve": [{"skill_id": "sql", "current_level": "beginner"}]
  }'
```

## Data Files

- `data/skills.csv` - Skills database (30+ skills)
- `data/job_roles.csv` - Job roles with required skills (10 roles)
- `data/resources.csv` - Learning resources with URLs (37 resources)
- `data/users.csv` - User data (auto-created)

## For Flutter App

Update the `baseUrl` in `lib/services/api_service.dart`:
- Android Emulator: `http://10.0.2.2:5000/api`
- Physical Device: `http://<your-computer-ip>:5000/api`
- iOS Simulator: `http://localhost:5000/api`
