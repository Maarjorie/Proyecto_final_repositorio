using System.Text.RegularExpressions;

namespace RepositorioApi.Services;

/// <summary>Reglas de validación; el formulario de Angular usa las mismas.</summary>
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

    /// <summary>Largo máximo de una palabra; más que eso es texto sin sentido.</summary>
    public const int PalabraMaxima = 40;

    [GeneratedRegex(@"^\p{L}[\p{L}\s'’.\-]*$")]
    private static partial Regex RegexNombre();

    public const int ObservacionMinima = 10;
    public const int DescripcionMaxima = 500;

    // Códigos de carrera, materia o docente: letras, números y guiones (FMO-IA-006, ISS115, DOC-001).
    [GeneratedRegex(@"^[A-Z0-9][A-Z0-9-]{1,19}$")]
    private static partial Regex RegexCodigo();

    // Carnet UES: dos letras y cinco dígitos.
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

    /// <summary>Código ya en mayúsculas: 2 a 20 caracteres, letras, números y guiones.</summary>
    public static bool EsCodigo(string codigo) => RegexCodigo().IsMatch(codigo);

    /// <summary>Nombre de catálogo con sentido: al menos 3 letras y sin palabras imposibles.</summary>
    public static bool EsNombreCatalogo(string nombre, int maximo) =>
        nombre.Length >= 3 && nombre.Length <= maximo && RegexLetra().IsMatch(nombre) && !TienePalabraDemasiadoLarga(nombre);

    /// <summary>Al menos una letra y un número.</summary>
    public static bool EsContrasenaSegura(string? valor) =>
        valor is { Length: >= 8 and <= 128 } && RegexLetra().IsMatch(valor) && RegexDigito().IsMatch(valor);

    /// <summary>Detecta palabras demasiado largas, como "ssssss…" (ignora enlaces).</summary>
    public static bool TienePalabraDemasiadoLarga(string texto) =>
        texto.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries)
            .Where(palabra => !palabra.StartsWith("http", StringComparison.OrdinalIgnoreCase))
            .Any(palabra => palabra.Length > PalabraMaxima);

    /// <summary>Revisa la firma del archivo para confirmar que es PDF o ZIP.</summary>
    public static async Task<bool> ContenidoCoincideAsync(IFormFile archivo, string extension, CancellationToken ct)
    {
        var firma = extension == ".pdf" ? "%PDF-"u8.ToArray() : new byte[] { 0x50, 0x4B, 0x03, 0x04 };
        var inicio = new byte[firma.Length];
        await using var stream = archivo.OpenReadStream();
        var leidos = await stream.ReadAtLeastAsync(inicio, inicio.Length, throwOnEndOfStream: false, ct);
        return leidos == firma.Length && inicio.AsSpan().SequenceEqual(firma);
    }
}
