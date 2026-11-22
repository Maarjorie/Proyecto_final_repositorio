import { HttpErrorResponse } from '@angular/common/http';
import { TimeoutError } from 'rxjs';

/** Mismas reglas que valida la API (Services/Validacion.cs). */
export const REGLAS = {
  anioMinimo: 1969,
  tituloMinimo: 10,
  tituloMaximo: 300,
  resumenMinimo: 100,
  resumenMaximo: 5000,
  maximoPalabrasClave: 10,
  maximoEnlaces: 10,
  palabraMaxima: 40,
  maximoArchivos: 10,
  maximoArchivoBytes: 25 * 1024 * 1024,
  maximoSolicitudBytes: 80 * 1024 * 1024
} as const;

const NOMBRE = /^\p{L}[\p{L}\s'’.\-]*$/u;
const CARNET = /^[A-Za-z]{2}\d{5}$/;
const CORREO = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

/** Devuelve el mensaje del error, o '' si el valor es válido. */
export function validarNombre(valor: string, campo: string): string {
  const texto = valor.trim();
  if (!texto) return `Escribe ${campo}.`;
  if (texto.length < 2 || texto.length > 100) return `${mayuscula(campo)} deben tener entre 2 y 100 caracteres.`;
  if (!NOMBRE.test(texto)) return `${mayuscula(campo)} solo llevan letras.`;
  return '';
}

export function validarCorreo(valor: string): string {
  const texto = valor.trim();
  if (!texto) return 'Escribe tu correo electrónico.';
  if (texto.length > 254 || !CORREO.test(texto)) return 'Escribe un correo electrónico válido.';
  return '';
}

export function validarContrasenaNueva(valor: string): string {
  if (!valor) return 'Escribe una contraseña.';
  if (valor.length < 8) return 'La contraseña debe tener al menos 8 caracteres.';
  if (valor.length > 128) return 'La contraseña admite hasta 128 caracteres.';
  if (!/\p{L}/u.test(valor) || !/\d/.test(valor)) return 'La contraseña debe tener al menos una letra y un número.';
  return '';
}

export function esCarnet(valor: string): boolean {
  return CARNET.test(valor.trim());
}

/** Detecta palabras demasiado largas, como "sssss…". */
export function tienePalabraDemasiadoLarga(texto: string): boolean {
  return texto
    .split(/\s+/)
    .filter(palabra => !/^http/i.test(palabra))
    .some(palabra => palabra.length > REGLAS.palabraMaxima);
}

function mayuscula(texto: string): string {
  // "tus nombres" -> "Los nombres"; "los apellidos" -> "Los apellidos".
  const sinPosesivo = texto.replace(/^tus\s+/i, 'los ');
  return sinPosesivo.charAt(0).toUpperCase() + sinPosesivo.slice(1);
}

/** Mensaje para el error de una llamada a la API. */
export function mensajeDeError(error: unknown, porDefecto: string): string {
  if (error instanceof TimeoutError) {
    return 'El servidor tardó demasiado en responder. Inténtalo de nuevo.';
  }
  if (error instanceof HttpErrorResponse) {
    const cuerpo = error.error;
    if (cuerpo && typeof cuerpo.mensaje === 'string' && cuerpo.mensaje) return cuerpo.mensaje;
    if (error.status === 0) return 'No se pudo conectar con el servidor. Verifica que RepositorioApi esté iniciado.';
    if (error.status === 401) return 'Tu sesión venció. Inicia sesión de nuevo.';
    if (error.status === 413) return 'Los archivos superan el tamaño permitido (25 MB cada uno, 80 MB en total).';
    if (error.status === 400) return 'Revisa los datos del formulario.';
    if (error.status >= 500) return 'El servidor tuvo un problema. Inténtalo de nuevo en un momento.';
  }
  return porDefecto;
}
