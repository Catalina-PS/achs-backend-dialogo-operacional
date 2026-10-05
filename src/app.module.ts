import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { FormularioModule } from './modules/formulario/formulario.module';
import { PeriodoModule } from './modules/periodo/periodo.module';
import { PrismaModule } from './infrastructure/prisma/prisma.module';
import { ScheduleModule } from '@nestjs/schedule';

@Module({
  imports: [ScheduleModule.forRoot(),FormularioModule, PeriodoModule, PrismaModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
