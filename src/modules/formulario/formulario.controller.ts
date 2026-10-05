import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { FormularioService } from './formulario.service';
import { CreateFormularioDto } from './dto/create-formulario.dto';
import { UpdateFormularioDto } from './dto/update-formulario.dto';

@Controller('formulario')
export class FormularioController {
  constructor(private readonly formularioService: FormularioService) {}

  // Recibe una respuesta del formulario
  @Post('respuestas')
  create(@Body() dto: CreateFormularioDto) {
    return this.formularioService.create(dto);
  }

  @Get()
  findAll() {
    return this.formularioService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.formularioService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateFormularioDto: UpdateFormularioDto) {
    return this.formularioService.update(+id, updateFormularioDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.formularioService.remove(+id);
  }
}
