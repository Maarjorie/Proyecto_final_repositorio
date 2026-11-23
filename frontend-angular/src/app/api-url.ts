/** URL de la API. En Docker viene de config.js como "/api". */
export const API_URL: string =
  (globalThis as { API_URL?: string }).API_URL || 'https://localhost:7244/api';
