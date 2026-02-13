# 🌍 NGO Project & Donor Management API

Production-grade backend for NGO operations management, combining project tracking, budget control, expense approval workflows, and impact verification.

**Built with**: NestJS + TypeScript + TypeORM + PostgreSQL + JWT + Swagger

## ✨ Features

- 🔐 **Role-Based Access Control**: ADMIN, AGENT, FINANCE, DONOR roles with JWT authentication
- 💰 **Financial Controls**: Expense approval workflow (PENDING → APPROVED/REJECTED)
- 📊 **Budget Tracking**: Real-time spending monitoring with multi-currency support (ISO 4217)
- 🎯 **Impact Verification**: Finance team verifies beneficiary claims and impact data
- 📋 **Project Management**: Complete project lifecycle (PLANNED → ACTIVE → COMPLETED)
- 👥 **Donor Management**: Track donor contributions and project relationships
- 📝 **Audit Trail**: Automatic timestamps (createdAt, updatedAt) and user attribution
- 🔄 **Agent Assignment**: Assign field workers to projects with role tracking
- 📚 **API Documentation**: Auto-generated Swagger/OpenAPI documentation
- 🔒 **Security**: JWT authentication, role-based guards, input validation

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL 13+
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Start PostgreSQL (Docker)
docker-compose up -d

# Create .env file
cp .env.example .env
```

### Development

```bash
# Start dev server with auto-reload
npm run start:dev

# Build for production
npm run build

# Start production server
npm run start:prod
```

### Testing

```bash
# Run unit tests
npm run test

# Run E2E tests
npm run test:e2e

# Watch mode
npm run test:watch
```

## 📖 API Documentation

Once the server is running, visit:
- **Swagger UI**: http://localhost:3000/api/docs
- **OpenAPI JSON**: http://localhost:3000/api-json

## 🏗️ Architecture & Documentation

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Complete project structure, design decisions, and code standards
- **[CLEANUP_REPORT.md](./CLEANUP_REPORT.md)** - Code quality audit and cleanup changes
- **[IMPORT_AND_USAGE_GUIDE.md](./IMPORT_AND_USAGE_GUIDE.md)** - Entity and DTO usage patterns

## 📚 Key Entities & DTOs

### Authentication
- **LoginDto** - Email + password login
- **RegisterDto** - Register new user (defaults to AGENT role)

### Projects
- **CreateProjectDto** - Create project with budget, currency, dates
- **UpdateProjectDto** - Update project details
- **ProjectStatus** - PLANNED, ACTIVE, PAUSED, COMPLETED, CANCELLED

### Budgets
- **CreateBudgetDto** - Create budget with category allocation
- **BudgetCategory** - Transport, Food, Logistics, Training, Health, Education, Equipment, Staff, Utilities, Other

### Expenses
- **CreateExpenseDto** - Create expense with GPS and receipt URL
- **ApproveExpenseDto** - Approve/reject expense (FINANCE role only)
- **ExpenseStatus** - PENDING, APPROVED, REJECTED

### Impact Reports
- **CreateImpactReportDto** - Report with beneficiary count and photos
- **VerifyImpactReportDto** - Verify impact claim (FINANCE role only)

## 🔐 Role-Based Access Control

| Role | Permissions |
|------|-------------|
| **ADMIN** | Full system access, user management, role assignment |
| **AGENT** | Create expenses, submit impact reports, view projects |
| **FINANCE** | Approve expenses, verify impact reports, audit trail access |
| **DONOR** | View own donations and funded projects |

## 📊 Workflow Examples

### Expense Approval Workflow
1. **Agent** creates expense (PENDING status)
2. **Finance** reviews receipt and details
3. **Finance** approves (APPROVED) or rejects (REJECTED)
4. **System** records approvedBy user and approvedAt timestamp

### Impact Verification Workflow
1. **Agent** submits impact report
2. **System** marks verified = false initially
3. **Finance** verifies beneficiary data
4. **Finance** marks verified = true (or false if invalid)
5. **System** records verifiedBy user and timestamp

## 🛠️ Development Workflow

```bash
# 1. Create new feature branch
git checkout -b feature/your-feature

# 2. Make changes and test
npm run test
npm run test:e2e

# 3. Build and verify
npm run build

# 4. Check code quality
npm run lint

# 5. Commit and push
git add .
git commit -m "feat: description of changes"
git push origin feature/your-feature
```

## 📋 Project Structure

```
src/
├── auth/              # JWT, roles, authentication
├── users/             # User management
├── projects/          # Projects & agents
├── budgets/           # Budget allocation & tracking
├── expenses/          # Expense submission & approval
├── donors/            # Donor management
├── impact-reports/    # Impact reporting & verification
└── app.module.ts      # Root module
```

## 🌍 Multi-Language Support

- **Database**: PostgreSQL 13+
- **Currency**: ISO 4217 codes (USD, EUR, XOF, etc.)
- **Dates**: ISO 8601 format (YYYY-MM-DD)
- **Documentation**: English (international teams)

## 📝 Environment Variables

Create `.env` file:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=ngo_db

# JWT
JWT_SECRET=your-secret-key-here
JWT_EXPIRATION=7d

# Server
PORT=3000
NODE_ENV=development
```

## 🚀 Deployment

### Docker Deployment

```bash
# Build Docker image
docker build -t ngo-backend .

# Run container
docker run -p 3000:3000 --env-file .env ngo-backend
```

### Production Checklist

- ✅ Set `NODE_ENV=production`
- ✅ Enable HTTPS/SSL
- ✅ Set strong JWT_SECRET
- ✅ Configure database backups
- ✅ Set up monitoring/logging
- ✅ Enable rate limiting
- ✅ Configure CORS properly
- ✅ Use environment-specific .env files

## 📞 Support & Issues

For issues, feature requests, or documentation improvements:
1. Check [ARCHITECTURE.md](./ARCHITECTURE.md) for design details
2. Check [CLEANUP_REPORT.md](./CLEANUP_REPORT.md) for recent changes
3. Create an issue on GitHub with clear description

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👨‍💻 Contributors

Built for NGO operations management with focus on:
- Financial transparency & accountability
- Donor confidence & reporting
- Field team efficiency
- Impact measurement & verification

