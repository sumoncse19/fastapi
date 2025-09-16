# DailyBite - Docker Deployment Guide

This guide explains how to run the complete DailyBite application (FastAPI backend + Flutter web frontend) using Docker.

## 🏗️ Architecture

The Docker setup includes:

- **Backend**: FastAPI application with JWT authentication and meal tracking
- **Frontend**: Flutter web application served by nginx
- **Database**: PostgreSQL database for data persistence
- **Networking**: All services communicate through a Docker network

## 📋 Prerequisites

- Docker and Docker Compose installed
- At least 4GB of available RAM
- Ports 3000, 8000, and 5432 available

## 🚀 Quick Start

### 1. Clone and Navigate

```bash
cd /home/sumon7866/Projects/learn-fastapi/fastapi-blog
```

### 2. Build and Start All Services

```bash
# Using Docker Compose directly
docker-compose up --build

# Or using the Docker Makefile
make -f Makefile.docker dev-setup
```

### 3. Access the Application

- **Frontend (Flutter Web)**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Database**: localhost:5432

## 🛠️ Docker Commands

### Using Makefile (Recommended)

```bash
# Show all available commands
make -f Makefile.docker help

# Start all services in background
make -f Makefile.docker up

# View logs
make -f Makefile.docker logs

# Stop all services
make -f Makefile.docker down

# Rebuild everything
make -f Makefile.docker rebuild
```

### Using Docker Compose Directly

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Remove everything including volumes
docker-compose down -v
```

## 📊 Service Details

### Backend Service

- **Container**: `dailybite_backend`
- **Port**: 8000
- **Features**: FastAPI, JWT auth, file uploads, AI meal analysis
- **Health Check**: http://localhost:8000/docs

### Frontend Service

- **Container**: `dailybite_frontend`
- **Port**: 3000 (maps to nginx port 80)
- **Features**: Flutter web app, responsive design, PWA support
- **Built with**: Flutter web + nginx

### Database Service

- **Container**: `dailybite_postgres`
- **Port**: 5432
- **Database**: `dailybite_db`
- **User**: `dailybite_user`
- **Password**: `dailybite_pass`

## 🔧 Configuration

### Environment Variables

Update `.env` file for backend configuration:

```env
# Database
DATABASE_URL=postgresql://dailybite_user:dailybite_pass@db:5432/dailybite_db

# JWT
JWT_SECRET_KEY=your-super-secret-jwt-key-here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# File Upload
MAX_FILE_SIZE=10485760
UPLOAD_DIR=uploads

# AI Service
AI_PROVIDER=mock
MOCK_ANALYSIS_ENABLED=true
```

### API Base URL

The Flutter frontend automatically connects to the backend through Docker networking. No manual configuration needed.

## 🗃️ Data Persistence

### Volumes

- `postgres_data`: Database files persist across container restarts
- `uploads`: User-uploaded meal photos persist across container restarts

### Backup Database

```bash
make -f Makefile.docker db-backup
```

### Restore Database

```bash
make -f Makefile.docker db-restore FILE=backup_20240917_123456.sql
```

## 🐛 Troubleshooting

### Container Issues

```bash
# Check container status
make -f Makefile.docker status

# View specific service logs
make -f Makefile.docker logs-backend
make -f Makefile.docker logs-frontend
make -f Makefile.docker logs-db

# Restart specific service
make -f Makefile.docker restart-backend
```

### Network Issues

```bash
# Check if containers can communicate
docker-compose exec frontend ping backend
docker-compose exec backend ping db
```

### Database Issues

```bash
# Connect to database
make -f Makefile.docker db-shell

# Check database tables
docker-compose exec db psql -U dailybite_user -d dailybite_db -c "\dt"
```

### Frontend Issues

```bash
# Check nginx configuration
docker-compose exec frontend cat /etc/nginx/conf.d/default.conf

# Check Flutter build files
docker-compose exec frontend ls -la /usr/share/nginx/html
```

## 🔒 Security Notes

### Development vs Production

- Current setup is for **development**
- CORS allows all origins (`allow_origins=["*"]`)
- Debug mode enabled
- Default passwords used

### Production Deployment

For production, update:

1. Change all default passwords
2. Configure specific CORS origins
3. Use environment-specific secrets
4. Enable HTTPS with SSL certificates
5. Use production-grade database settings

## 📱 Testing the Application

### 1. Register a User

- Open http://localhost:3000
- Click "Register" and create an account
- Verify you can log in

### 2. Test Meal Tracking

- Click "Add Meal" to open camera interface
- Upload a food photo (use gallery option in web)
- Verify AI analysis creates a meal entry
- Check daily progress updates

### 3. API Testing

- Visit http://localhost:8000/docs
- Test API endpoints directly
- Verify JWT authentication works

## 🔄 Development Workflow

### Making Changes

#### Backend Changes

```bash
# Backend auto-reloads with volume mounting
# Just edit files in src/ and changes apply immediately
```

#### Frontend Changes

```bash
# Rebuild frontend container
make -f Makefile.docker restart-frontend

# Or rebuild everything
make -f Makefile.docker rebuild
```

### Logs and Debugging

```bash
# Follow all logs
make -f Makefile.docker logs

# Follow specific service
make -f Makefile.docker logs-backend

# Enter container for debugging
make -f Makefile.docker shell-backend
```

## 🎯 Next Steps

1. **Test the complete workflow**: Register → Login → Add Meal → View Progress
2. **Customize the AI service**: Replace mock with real AI provider
3. **Add more features**: Meal history, analytics, user preferences
4. **Deploy to production**: Use container orchestration (Kubernetes, Docker Swarm)

Your DailyBite application is now running in Docker! 🎉
