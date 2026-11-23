/**
 * Dirección de la API. En desarrollo es la de Visual Studio; en Docker la
 * define public/config.js como "/api" y nginx la reenvía al contenedor.
 */
export const API_URL: string =
  (globalThis as { API_URL?: string }).API_URL || 'https://localhost:7244/api';
