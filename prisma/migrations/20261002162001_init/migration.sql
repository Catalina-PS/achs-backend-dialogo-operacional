-- CreateEnum
CREATE TYPE "Rol" AS ENUM ('ADC', 'EQUIPO_CENTRAL');

-- CreateEnum
CREATE TYPE "TipoContenido" AS ENUM ('NOTICIA', 'ENTRENAMIENTO');

-- CreateEnum
CREATE TYPE "TipoPregunta" AS ENUM ('ANIMO', 'PERSONA', 'PRINCIPIO');

-- CreateEnum
CREATE TYPE "EstadoUsuario" AS ENUM ('ACTIVO', 'INACTIVO');

-- CreateEnum
CREATE TYPE "EstadoCentro" AS ENUM ('ACTIVO', 'INACTIVO');

-- CreateEnum
CREATE TYPE "EstadoPregunta" AS ENUM ('ACTIVA', 'INACTIVA');

-- CreateTable
CREATE TABLE "Usuario" (
    "id" TEXT NOT NULL,
    "codigo" TEXT,
    "nombre" TEXT NOT NULL,
    "correo" TEXT NOT NULL,
    "rol" "Rol" NOT NULL DEFAULT 'ADC',
    "estado" "EstadoUsuario" NOT NULL DEFAULT 'ACTIVO',

    CONSTRAINT "Usuario_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Centro" (
    "id" TEXT NOT NULL,
    "usuarioId" TEXT,
    "codigo" TEXT,
    "nombre" TEXT NOT NULL,
    "tipoCentro" TEXT,
    "estado" "EstadoCentro" NOT NULL DEFAULT 'ACTIVO',

    CONSTRAINT "Centro_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Periodo" (
    "id" TEXT NOT NULL,
    "numeroSemana" INTEGER NOT NULL,
    "anio" INTEGER NOT NULL,
    "fechaDesde" TIMESTAMP(3) NOT NULL,
    "fechaHasta" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Periodo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Dotacion" (
    "id" TEXT NOT NULL,
    "centroId" TEXT NOT NULL,
    "periodoId" TEXT NOT NULL,
    "dotacion" INTEGER NOT NULL,
    "fechaCreacion" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fechaModificacion" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Dotacion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Proposito" (
    "id" TEXT NOT NULL,
    "contenido" TEXT NOT NULL,
    "fechaDesde" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fechaHasta" TIMESTAMP(3),

    CONSTRAINT "Proposito_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Principio" (
    "id" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "descripcion" TEXT,
    "orden" INTEGER NOT NULL,
    "color" TEXT NOT NULL,
    "fechaDesde" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fechaHasta" TIMESTAMP(3),

    CONSTRAINT "Principio_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "NuestraOperacion" (
    "id" TEXT NOT NULL,
    "usuarioId" TEXT NOT NULL,
    "contenido" TEXT NOT NULL,
    "orden" INTEGER NOT NULL,
    "fechaDesde" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fechaHasta" TIMESTAMP(3),

    CONSTRAINT "NuestraOperacion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Contenido" (
    "id" TEXT NOT NULL,
    "periodoId" TEXT NOT NULL,
    "tipo" "TipoContenido" NOT NULL,
    "orden" INTEGER NOT NULL,
    "area" TEXT,
    "titulo" TEXT NOT NULL,
    "mensaje" TEXT,
    "fechaCreacion" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fechaModificacion" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Contenido_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Documento" (
    "id" TEXT NOT NULL,
    "periodoId" TEXT NOT NULL,
    "tipo" TEXT NOT NULL,
    "nombreArchivo" TEXT NOT NULL,
    "rutaArchivo" TEXT NOT NULL,
    "fechaCreacion" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fechaModificacion" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Documento_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RespuestaFormulario" (
    "id" TEXT NOT NULL,
    "formsRespuestaId" TEXT NOT NULL,
    "centroId" TEXT NOT NULL,
    "periodoId" TEXT NOT NULL,
    "fechaRespuesta" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RespuestaFormulario_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Pregunta" (
    "id" TEXT NOT NULL,
    "tipoPregunta" "TipoPregunta" NOT NULL,
    "textoPregunta" TEXT NOT NULL,
    "estado" "EstadoPregunta" NOT NULL DEFAULT 'ACTIVA',

    CONSTRAINT "Pregunta_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RespuestaPregunta" (
    "id" TEXT NOT NULL,
    "respuestaId" TEXT NOT NULL,
    "preguntaId" TEXT NOT NULL,
    "valorRespuesta" TEXT,
    "principioId" TEXT,

    CONSTRAINT "RespuestaPregunta_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Usuario_codigo_key" ON "Usuario"("codigo");

-- CreateIndex
CREATE UNIQUE INDEX "Usuario_correo_key" ON "Usuario"("correo");

-- CreateIndex
CREATE UNIQUE INDEX "Centro_codigo_key" ON "Centro"("codigo");

-- CreateIndex
CREATE UNIQUE INDEX "Periodo_anio_numeroSemana_key" ON "Periodo"("anio", "numeroSemana");

-- CreateIndex
CREATE UNIQUE INDEX "Dotacion_centroId_periodoId_key" ON "Dotacion"("centroId", "periodoId");

-- CreateIndex
CREATE UNIQUE INDEX "RespuestaFormulario_formsRespuestaId_key" ON "RespuestaFormulario"("formsRespuestaId");

-- CreateIndex
CREATE INDEX "RespuestaFormulario_centroId_periodoId_idx" ON "RespuestaFormulario"("centroId", "periodoId");

-- CreateIndex
CREATE UNIQUE INDEX "RespuestaPregunta_respuestaId_preguntaId_key" ON "RespuestaPregunta"("respuestaId", "preguntaId");

-- AddForeignKey
ALTER TABLE "Centro" ADD CONSTRAINT "Centro_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "Usuario"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Dotacion" ADD CONSTRAINT "Dotacion_centroId_fkey" FOREIGN KEY ("centroId") REFERENCES "Centro"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Dotacion" ADD CONSTRAINT "Dotacion_periodoId_fkey" FOREIGN KEY ("periodoId") REFERENCES "Periodo"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "NuestraOperacion" ADD CONSTRAINT "NuestraOperacion_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contenido" ADD CONSTRAINT "Contenido_periodoId_fkey" FOREIGN KEY ("periodoId") REFERENCES "Periodo"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Documento" ADD CONSTRAINT "Documento_periodoId_fkey" FOREIGN KEY ("periodoId") REFERENCES "Periodo"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RespuestaFormulario" ADD CONSTRAINT "RespuestaFormulario_centroId_fkey" FOREIGN KEY ("centroId") REFERENCES "Centro"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RespuestaFormulario" ADD CONSTRAINT "RespuestaFormulario_periodoId_fkey" FOREIGN KEY ("periodoId") REFERENCES "Periodo"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RespuestaPregunta" ADD CONSTRAINT "RespuestaPregunta_respuestaId_fkey" FOREIGN KEY ("respuestaId") REFERENCES "RespuestaFormulario"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RespuestaPregunta" ADD CONSTRAINT "RespuestaPregunta_preguntaId_fkey" FOREIGN KEY ("preguntaId") REFERENCES "Pregunta"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RespuestaPregunta" ADD CONSTRAINT "RespuestaPregunta_principioId_fkey" FOREIGN KEY ("principioId") REFERENCES "Principio"("id") ON DELETE SET NULL ON UPDATE CASCADE;
