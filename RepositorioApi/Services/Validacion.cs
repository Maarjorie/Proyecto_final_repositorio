using System.Text.RegularExpressions;

namespace RepositorioApi.Services;

/// <summary>
/// Reglas de validación compartidas. El formulario de Angular aplica las
/// mismas reglas para avisar antes de enviar.
/// </summary>
public static partial class Validacion
{
    /// <summary>Año desde el que se registran trabajos (fundación de la FMO).</summary>
    public const int AnioMinimo = 1969;

    public const int TituloMinimo = 10;
    public const int TituloMaximo = 300;
    public const int ResumenMinimo = 100;
    public const int ResumenMaximo = 5000;
    public const int MaximoPalabrasClave = 10;
    public const int MaximoEnlaces = 10;

    /// <summary>Ninguna palabra real en español pasa de 40 letras.</summary>
    public const int PalabraMaxima = 40;

    [GeneratedRegex(@"^\p{L}[\p{L}\s'’.\-]*$")]
    private static partial Regex RegexNombre();

    // Carnet de la UES: dos letras y cinco dígitos (p. ej. AB12345).
    [GeneratedRegex(@"^[A-Za-z]{2}\d{5}$")]
    private static partial Regex RegexCarnet();

    [GeneratedRegex(@"\p{L}")]
    private static partial Regex RegexLetra();

    [GeneratedRegex(@"\d")]
    private static partial Regex RegexDigito();

    public static bool EsNombrePersona(string? valor)
    {
        var texto = valor?.Trim() ?? string.Empty;
        return texto.Length is >= 2 and <= 100 && RegexNombre().IsMatch(texto);
    }

    public static bool EsCarnet(string? valor) => RegexCarnet().IsMatch(valor?.Trim() ?? string.Empty);

    /// <summary>Al menos una letra y un número.</summary>
    public static bool EsContrasenaSegura(string? valor) =>
        valor is { Length: >= 8 and <= 128 } && RegexLetra().IsMatch(valor) && RegexDigito().IsMatch(valor);

    /// <summary>
    /// Detecta texto sin sentido como "sssssss…": una palabra más larga que
    /// cualquier palabra real. Los enlaces no cuentan.
    /// </summary>
    public static bool TienePalabraDemasiadoLarga(string texto) =>
        texto.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries)
            .Where(palabra => !palabra.StartsWith("http", StringComparison.OrdinalIgnoreCase))
            .Any(palabra => palabra.Length > PalabraMaxima);

    /// <summary>Comprueba por el contenido que el archivo sea de verdad un PDF o un ZIP.</summary>
    public static async Task<bool> ContenidoCoincideAsync(IFormFile archivo, string extension, CancellationToken ct)
    {
        var firma = extension == ".pdf" ? "%PDF-"u8.ToArray() : new byte[] { 0x50, 0x4B, 0x03, 0x04 };
        var inicio = new byte[firma.Length];
        await using var stream = archivo.OpenReadStream();
        var leidos = await stream.ReadAtLeastAsync(inicio, inicio.Length, throwOnEndOfStream: false, ct);
        return leidos == firma.Length && inicio.AsSpan().SequenceEqual(firma);
    }
}
