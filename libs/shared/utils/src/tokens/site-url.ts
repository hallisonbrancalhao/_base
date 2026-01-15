import { InjectionToken } from '@angular/core';

/**
 * InjectionToken for the site URL (public-facing website)
 * Used for generating QR codes and external links
 *
 * Values by environment:
 * - development: http://localhost:4200
 * - homolog: https://hml.domain.com.br
 * - production: https://domain.com.br
 */
export const SITE_URL = new InjectionToken<string>('SITE_URL');
