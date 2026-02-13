import { Test, TestingModule } from '@nestjs/testing';
import { ImpactReportsController } from './impact-reports.controller';

describe('ImpactReportsController', () => {
  let controller: ImpactReportsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ImpactReportsController],
    }).compile();

    controller = module.get<ImpactReportsController>(ImpactReportsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
