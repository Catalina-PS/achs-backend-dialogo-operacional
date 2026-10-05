import { Controller, Get } from '@nestjs/common';
import { PeriodoService } from './periodo.service';

@Controller('periodo')
export class PeriodoController {
  constructor(
    private readonly periodoService: PeriodoService,
  ) {}

  @Get()
  findAll() {
    return this.periodoService.findAll();
  }

  @Get('generar-periodos')
  generarPeriodos() {
    return this.periodoService.asegurarPeriodosFuturos();
  }
}