# 📋 Architecture & Code Standards

## Project Structure

```
src/
├── auth/                      # Authentication & Authorization
│   ├── dto/                   # DTOs: LoginDto, RegisterDto
│   ├── auth.service.ts        # JWT and user registration logic
│   ├── jwt.strategy.ts        # JWT passport strategy
│   ├── jwt-auth.guard.ts      # Protect routes with JWT
│   ├── roles.guard.ts         # Role-based access control
│   ├── roles.decorator.ts     # @Roles() decorator
│   ├── roles.enum.ts          # Role enumeration
│   └── auth.module.ts
│
├── users/                     # User Management
│   ├── user.entity.ts         # User database model
│   ├── users.service.ts       # User CRUD operations
│   ├── users.controller.ts    # User routes
│   └── users.module.ts
│
├── projects/                  # Project Management
│   ├── dto/
│   │   ├── create-project.dto.ts
│   │   ├── update-project.dto.ts
│   │   └── assign-agent-to-project.dto.ts
│   ├── project.entity.ts      # Project model
│   ├── project-agent.entity.ts # Project-Agent many-to-many relationship
│   ├── project-status.enum.ts # Project status enumeration
│   ├── projects.service.ts
│   ├── projects.controller.ts
│   └── projects.module.ts
│
├── budgets/                   # Budget Management
│   ├── dto/
│   │   └── create-budget.dto.ts
│   ├── budget.entity.ts       # Budget model with category
│   ├── budgets.service.ts
│   ├── budgets.controller.ts
│   └── budgets.module.ts
│
├── expenses/                  # Expense Tracking & Approval
│   ├── dto/
│   │   ├── create-expense.dto.ts
│   │   └── approve-expense.dto.ts # Finance approval workflow
│   ├── expense.entity.ts      # Expense with workflow state
│   ├── expense-status.enum.ts # PENDING, APPROVED, REJECTED
│   ├── expenses.service.ts
│   ├── expenses.controller.ts
│   └── expenses.module.ts
│
├── donors/                    # Donor Management
│   ├── dto/
│   │   └── create-donor.dto.ts
│   ├── donor.entity.ts        # Donor model
│   ├── donors.service.ts
│   ├── donors.controller.ts
│   └── donors.module.ts
│
├── impact-reports/            # Impact Reporting & Verification
│   ├── dto/
│   │   ├── create-impact-reports.dto.ts
│   │   └── verify-impact-report.dto.ts # Finance verification
│   ├── impact-report.entity.ts # Impact model with verification
│   ├── impact-reports.service.ts
│   ├── impact-reports.controller.ts
│   └── impact-reports.module.ts
│
├── app.module.ts              # Root module (imports all)
├── app.controller.ts          # Health check
├── app.service.ts
└── main.ts                    # Application bootstrap with Swagger

test/                          # E2E tests
package.json                   # Dependencies & scripts
tsconfig.json                  # TypeScript configuration
docker-compose.yml             # PostgreSQL for local dev
```

## Key Design Decisions

### 1. **ID Strategy**
- All entities use `@PrimaryGeneratedColumn()` → auto-incremented number
- Consistent with SQL databases (PostgreSQL, MySQL)
- Avoids UUID string overhead for NGO use cases

### 2. **Role-Based Access Control**
```typescript
enum Role {
  ADMIN = 'ADMIN',         // System administrator
  AGENT = 'AGENT',         // Field worker (default)
  FINANCE = 'FINANCE',     // Finance controller/approver
  DONOR = 'DONOR'          // Donor (can view own donations)
}
```

### 3. **Financial Control Workflow**
- **Expenses**: PENDING → APPROVED/REJECTED (Finance approval required)
- **Impact Reports**: unverified → verified (Finance verification required)
- All approval actions include `approvedBy`, `approvedAt`, and optional comments
- Audit trail: `createdBy`, `createdAt`, `updatedAt` on all entities

### 4. **Currency & Localization**
- `currency: string` (ISO 4217 codes) on Project
- `currency: string` on Donor
- Prevents ambiguity: 50M XOF ≠ 50M USD

### 5. **Data Validation**
- All DTOs use `class-validator` decorators
- Type checking: `@IsInt()`, `@IsEnum()`, `@IsDateString()`
- Range validation: `@Min()`, `@Max()`
- String validation: `@IsEmail()`, `@MinLength()`, `@IsString()`

### 6. **Timestamps Strategy**
- `@CreateDateColumn()` - auto-set on create
- `@UpdateDateColumn()` - auto-update on modify
- Applied to ALL entities for audit trail
- Enables: historical queries, export for compliance, legal proof

## Security Best Practices

1. **Registration Security**
   - No role input from self-registration (defaults to AGENT)
   - Only ADMIN can promote users to FINANCE/ADMIN roles
   - Optional `role` parameter for bulk admin user creation

2. **Guards & Decorators**
   - `@UseGuards(JwtAuthGuard)` - Verify JWT token
   - `@UseGuards(RolesGuard)` - Verify user role
   - `@Roles(Role.ADMIN, Role.FINANCE)` - Restrict by role

3. **DTO Input Validation**
   - Finance workflows don't accept `approvedBy` from user (system-assigned)
   - Verification workflows don't accept `verifiedBy` from user (system-assigned)
   - Prevents privilege escalation

## API Endpoint Structure

### Authentication
```
POST   /auth/register          - Register new user (defaults to AGENT)
POST   /auth/login             - Login & get JWT token
```

### Projects
```
POST   /projects               - Create project
GET    /projects               - List all projects
GET    /projects/:id           - Get project detail
PATCH  /projects/:id           - Update project
```

### Budgets
```
POST   /budgets                - Create budget
GET    /budgets                - List budgets
PATCH  /budgets/:id            - Update budget
```

### Expenses
```
POST   /expenses/:projectId/:budgetId    - Create expense
GET    /expenses                         - List expenses
PATCH  /expenses/:id/approve             - Approve/reject (FINANCE only)
```

### Impact Reports
```
POST   /impact-reports/:projectId        - Create report
GET    /impact-reports                   - List reports
PATCH  /impact-reports/:id/verify        - Verify (FINANCE only)
```

## Naming Conventions

- **Entities**: PascalCase, singular (`User`, `Project`, `Expense`)
- **DTOs**: PascalCase, ends with `Dto` (`CreateProjectDto`, `ApproveExpenseDto`)
- **Enums**: PascalCase, singular (`Role`, `ProjectStatus`, `ExpenseStatus`)
- **Services**: PascalCase, plural (`UsersService`, `ProjectsService`)
- **Controllers**: PascalCase, plural (`UsersController`, `ProjectsController`)
- **Routes**: kebab-case (`/impact-reports`, `/project-agents`)

## Code Quality Standards

- ✅ Zero unused imports
- ✅ TypeScript strict mode enabled
- ✅ All DTOs have validation decorators
- ✅ All entities have timestamps
- ✅ Proper error handling (NotFoundException, BadRequestException)
- ✅ API documentation via Swagger decorators
- ✅ Bearer token authentication on protected routes
- ✅ Role-based access control enforced
