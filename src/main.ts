import 'newrelic';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { ResponseInterceptor } from './common/response.interceptor';
import { AllExceptionsFilter } from './common/all-exceptions.filter';
import { DataSource } from 'typeorm';
import { IpFilter } from 'express-ipfilter';
import { ModeEnum } from './enums/mode';
import { AppLogger } from './utils/logger';

async function bootstrap() {
  const port: string | number = process.env.PORT || 7001;
  const environment: string = process.env.MODE || ModeEnum.DEV;
  const allowedIps: string[] = process.env.IP_ADDRESS
    ? process.env.IP_ADDRESS.split(',').map((ip) => ip.trim())
    : [];

  const app = await NestFactory.create(
    AppModule,
    environment === ModeEnum.PROD ? { logger: false } : undefined,
  );

  if (environment === ModeEnum.PROD && allowedIps.length > 0) {
    app.use(IpFilter(allowedIps, { mode: 'allow' }));
  }

  app.useGlobalFilters(new AllExceptionsFilter());
  app.useGlobalInterceptors(new ResponseInterceptor());
  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
    }),
  );
  app.setGlobalPrefix('api/v1');
  app.enableCors({
    origin: true,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });

  await app.listen(port);
  const appUrl: string = await app.getUrl();

  AppLogger.info(`
    🚀 Application is running!
    ----------------------------------
    🌍 Environment  : ${environment}
    🚪 Port         : ${port}
    📡 Base URL     : ${appUrl}
    🔹 API Version  : /api/v1
    🕒 Started at   : ${new Date().toLocaleString()}
    ----------------------------------
  `);

  const dataSource = app.get(DataSource);

  if (dataSource.isInitialized) {
    AppLogger.info(`
      ✅ Database connected successfully!
      ----------------------------------
      🕒 Started at   : ${new Date().toLocaleString()}
      👤 Username     : ${process.env.DB_USERNAME}
      🏢 DB Host      : ${process.env.DB_HOST}
      📊 DB Name      : ${process.env.DB_NAME}
      ----------------------------------
    `);
  } else {
    AppLogger.error(`
      ❌ Database connection failed!
      ----------------------------------
      🕒 Started at   : ${new Date().toLocaleString()}
      👤 Username     : ${process.env.DB_USERNAME}
      🏢 DB Host      : ${process.env.DB_HOST}
      📊 DB Name      : ${process.env.DB_NAME}
      ----------------------------------
    `);
  }
}

bootstrap();
