import {
  Controller,
  Post,
  UploadedFile,
  Req,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { ApiBearerAuth, ApiConsumes, ApiOperation, ApiTags } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { normalizeMediaUrl } from '../common/media-url.util';

@ApiTags('Uploads')
@ApiBearerAuth('JWT-auth')
@Controller('uploads')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UploadsController {
  @Post()
  @ApiOperation({ summary: 'Upload image file' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: join(process.cwd(), 'uploads'),
        filename: (_req, file, cb) => {
          const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
          cb(null, `${unique}${extname(file.originalname)}`);
        },
      }),
      limits: { fileSize: 5 * 1024 * 1024 },
    }),
  )
  upload(@UploadedFile() file: any, @Req() req: any) {
    const baseUrl =
      process.env.PUBLIC_BASE_URL?.trim() ||
      `${req.protocol}://${req.get('host')}`;
    const relativeUrl = `/uploads/${file.filename}`;
    const absoluteUrl = normalizeMediaUrl(`${baseUrl}${relativeUrl}`);

    return {
      url: absoluteUrl,
      relativeUrl,
      absoluteUrl,
    };
  }
}
