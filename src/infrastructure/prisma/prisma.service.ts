import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleDestroy
{
  constructor() {
    // Creamos el adaptador que conecta Prisma con PostgreSQL
    const adapter = new PrismaPg({
      connectionString: process.env.DATABASE_URL!,
    });
    super({
      adapter,
    });
  }
  async onModuleDestroy() {
    await this.$disconnect();
  }
}