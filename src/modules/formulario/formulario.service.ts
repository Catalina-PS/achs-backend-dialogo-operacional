import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { CreateFormularioDto } from './dto/create-formulario.dto';
import { UpdateFormularioDto } from './dto/update-formulario.dto';
import { PrismaService } from '../../infrastructure/prisma/prisma.service';

@Injectable()
export class FormularioService {
  constructor(
      private readonly prisma: PrismaService,
    ) {}

  // Funcion que procesa una respuesta recibida desde Microsoft Forms
  async create(dto: CreateFormularioDto) {
    // Valida que la respuesta no exista
    const respuestaExistente =
      await this.prisma.respuestaFormulario.findUnique({
        where: {
          formsRespuestaId: dto.formsRespuestaId,
        },
      });

    if (respuestaExistente) {
      throw new ConflictException(
        `La respuesta ${dto.formsRespuestaId} ya fue registrada`,
      );
    }
    // Busca el centro
    const centro = await this.prisma.centro.findFirst({
      where: {
        nombre: {
          equals: dto.centro,
          mode: 'insensitive',
        },
      },
    });

    if (!centro) {
      throw new NotFoundException(
        `No existe el centro ${dto.centro}`,
      );
    }

    const fechaRespuesta = new Date(dto.fechaRespuesta);

    // Busca el perioo
    const periodo = await this.prisma.periodo.findFirst({
      where: {
        fechaDesde: {
          lte: fechaRespuesta,
        },
        fechaHasta: {
          gte: fechaRespuesta,
        },
      },
    });

    if (!periodo) {
      throw new NotFoundException(
        'No existe un período para la fecha de respuesta',
      );
    }

    // Guarda la respuesta principal
    const respuestaFormulario =
      await this.prisma.respuestaFormulario.create({
        data: {
          formsRespuestaId: dto.formsRespuestaId,
          centroId: centro.id,
          periodoId: periodo.id,
          fechaRespuesta: fechaRespuesta,
        },
      });

    // Busca las preguntas activas
    const preguntas = await this.prisma.pregunta.findMany({
      where: {
        estado: 'ACTIVA',
      },
    });

    const preguntaAnimo = preguntas.find(
      (pregunta) => pregunta.tipoPregunta === 'ANIMO',
    );

    const preguntaPersona = preguntas.find(
      (pregunta) => pregunta.tipoPregunta === 'PERSONA',
    );

    const preguntaPrincipio = preguntas.find(
      (pregunta) => pregunta.tipoPregunta === 'PRINCIPIO',
    );

    if (
      !preguntaAnimo ||
      !preguntaPersona ||
      !preguntaPrincipio
    ) {
      throw new NotFoundException(
        'No se encontraron todas las preguntas activas',
      );
    }

    // Busca el principio seleccionado
    let principio = null;

    if (dto.principio) {
      principio = await this.prisma.principio.findFirst({
        where: {
          nombre: {
            equals: dto.principio,
            mode: 'insensitive',
          },
        },
      });

      if (!principio) {
        throw new NotFoundException(
          `No existe el principio ${dto.principio}`,
        );
      }
    }

    // Guarda las respuestas
    await this.prisma.respuestaPregunta.createMany({
      data: [
        {
          respuestaId: respuestaFormulario.id,
          preguntaId: preguntaAnimo.id,
          valorRespuesta: dto.animo,
        },
        {
          respuestaId: respuestaFormulario.id,
          preguntaId: preguntaPersona.id,
          valorRespuesta: dto.personaReconocida ?? null,
        },
        {
          respuestaId: respuestaFormulario.id,
          preguntaId: preguntaPrincipio.id,
          valorRespuesta: dto.principio ?? null,
          principioId: principio?.id ?? null,
        },
      ],
    });

    // Devuelve la respuesta con su detalle
    return this.prisma.respuestaFormulario.findUnique({
      where: {
        id: respuestaFormulario.id,
      },
      include: {
        detalle: true,
      },
    });
  }


  findAll() {
    return `This action returns all formulario`;
  }

  findOne(id: number) {
    return `This action returns a #${id} formulario`;
  }

  update(id: number, updateFormularioDto: UpdateFormularioDto) {
    return `This action updates a #${id} formulario`;
  }

  remove(id: number) {
    return `This action removes a #${id} formulario`;
  }
}
