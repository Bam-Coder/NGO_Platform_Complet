import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { ProjectsModule } from './projects/projects.module';
import { BudgetsModule } from './budgets/budgets.module';
import { UploadsModule } from './uploads/uploads.module';
import { DonorsModule } from './donors/donors.module';
import { ExpensesModule } from './expenses/expenses.module';
import { ImpactReportsModule } from './impact-reports/impact-reports.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),

    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST,
      port: parseInt(process.env.DB_PORT ?? '5432', 10),
      username: process.env.DB_USERNAME,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      autoLoadEntities: true,
      synchronize: true, // DEV uniquement
    }),

    UsersModule,
    AuthModule,
    ProjectsModule,
    BudgetsModule,
    UploadsModule,
    DonorsModule,
    ExpensesModule,
    ImpactReportsModule,
  ],
})
export class AppModule {}
