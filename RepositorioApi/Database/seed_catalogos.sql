-- Catalog data required by the project submission form.
-- Names are lowercase because the database enforces that convention.
-- Safe to run more than once; existing names are preserved.
INSERT INTO tbl_tematica (nombre, descripcion)
VALUES
    ('bases de datos', 'Bases de datos y gestión de información.'),
    ('desarrollo web', 'Aplicaciones, servicios y plataformas web.'),
    ('redes y comunicación', 'Redes, comunicaciones y telecomunicaciones.'),
    ('inteligencia artificial', 'Inteligencia artificial y aprendizaje automático.'),
    ('otros', 'Otras áreas temáticas.')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO tbl_tipo_recurso (nombre, descripcion)
VALUES
    ('pdf', 'Documento PDF adjunto a una entrega.'),
    ('zip', 'Archivo ZIP adjunto a una entrega.'),
    ('enlace', 'Enlace externo relacionado con una entrega.')
ON CONFLICT (nombre) DO NOTHING;
