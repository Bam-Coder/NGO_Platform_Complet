import { Test, TestingModule } from '@nestjs/testing';
import { ImpactReportsService } from './impact-reports.service';

describe('ImpactReportsService', () => {
  let service: ImpactReportsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ImpactReportsService],
    }).compile();

    service = module.get<ImpactReportsService>(ImpactReportsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
