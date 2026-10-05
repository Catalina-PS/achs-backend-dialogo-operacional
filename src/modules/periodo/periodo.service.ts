import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/prisma/prisma.service';
import { Cron } from '@nestjs/schedule';

@Injectable()
export class PeriodoService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  // Funcion que calcula el periodo semanal ISO al que pertenece una fecha
  private calcularPeriodo(fecha: Date) {
    const fechaUTC = new Date(
    Date.UTC(
      fecha.getUTCFullYear(),
      fecha.getUTCMonth(),
      fecha.getUTCDate(),
    ),
  );

    const diaSemana = fechaUTC.getUTCDay() || 7;
    const diasHastaLunes = diaSemana - 1;

    const fechaDesde = new Date(fechaUTC);
    fechaDesde.setUTCDate(
      fechaUTC.getUTCDate() - diasHastaLunes,
    );

    const fechaHasta = new Date(fechaDesde);
    fechaHasta.setUTCDate(
      fechaDesde.getUTCDate() + 6,
    );

    const jueves = new Date(fechaUTC);
    jueves.setUTCDate(
      fechaUTC.getUTCDate() + 4 - diaSemana,
    );

    const anio = jueves.getUTCFullYear();

    const cuatroEnero = new Date(
      Date.UTC(anio, 0, 4),
    );

    const diaCuatroEnero =
      cuatroEnero.getUTCDay() || 7;

    const lunesSemana1 = new Date(cuatroEnero);
    lunesSemana1.setUTCDate(
      cuatroEnero.getUTCDate() - (diaCuatroEnero - 1),
    );

    const numeroSemana =
      Math.floor((fechaDesde.getTime() - lunesSemana1.getTime()) /604800000,) + 1;

    return {
      numeroSemana,
      anio,
      fechaDesde,
      fechaHasta,
    };
  }

  // Obtiene todos los periodos ordenados desde el más antiguo al mas reciente
  async findAll() {
    return this.prisma.periodo.findMany({
      orderBy: {
        fechaDesde: 'asc',
      },
    });
  }

  // Revisa los períodos futuros y, si quedan 3 o menos, crea hasta volver a tener 6
  async asegurarPeriodosFuturos() {
    const hoy = new Date();
    const periodoActual = this.calcularPeriodo(hoy);

    const periodosFuturos =
      await this.prisma.periodo.findMany({
        where: {
          fechaDesde: {
            gt: periodoActual.fechaHasta,
          },
        },
        orderBy: {
          fechaDesde: 'asc',
        },
      });

    if (periodosFuturos.length > 3) {
      return;
    }

    const cantidadACrear =
      6 - periodosFuturos.length;

    let fechaBase: Date;

    if (periodosFuturos.length > 0) {
      fechaBase =
        periodosFuturos[
          periodosFuturos.length - 1
        ].fechaHasta;
    } else {
      fechaBase = periodoActual.fechaHasta;
    }

    for (let i = 0; i < cantidadACrear; i++) {
    const siguienteFecha = new Date(fechaBase);

    siguienteFecha.setUTCDate(
      fechaBase.getUTCDate() + 1,
    );

    const nuevoPeriodo =
      this.calcularPeriodo(siguienteFecha);

      await this.prisma.periodo.create({
        data: nuevoPeriodo,
    });
        fechaBase = nuevoPeriodo.fechaHasta;
    }
  }

  //Funcion cron para crear nuevos periodos todos los domingo 12 del medio dia
  @Cron('0 12 * * 0', {
  timeZone: 'America/Santiago',
  })
  async generarPeriodosAutomaticamente() {
    await this.asegurarPeriodosFuturos();
  }
}