// Angular imports
import {
  ApplicationConfig,
  LOCALE_ID,
  provideBrowserGlobalErrorListeners,
} from '@angular/core';
import { provideRouter } from '@angular/router';

// Utils imports
import { ptBR } from '../l18n/pt-br';
import { SITE_URL } from '@shared/utils/tokens/site-url';
import { environment } from '../environments/environment';
import { appRoutes } from './app.routes';

// PrimeNG imports
import { providePrimeNG } from 'primeng/config';
import ThemePreset from '../../theme';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(appRoutes),
    { provide: LOCALE_ID, useValue: 'pt-BR' },
    providePrimeNG({
      theme: ThemePreset,
      ripple: true,
      translation: ptBR,
    }),
    // Providers injection tokens
    { provide: SITE_URL, useValue: environment.siteUrl },
  ],
};
