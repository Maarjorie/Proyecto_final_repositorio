-- RF-10: el supervisor registra qué materiales autorizaron difundir los autores.
-- "Si de dos PDF solo se autorizó uno, queda identificado cuál es."
-- El permiso general del proyecto sigue en tbl_proyecto.estado_autorizacion
-- (pendiente / autorizado / no_autorizado); esta columna indica, dentro de una
-- entrega autorizada, qué archivos o enlaces pueden mostrarse en el catálogo.
-- Es seguro ejecutarlo más de una vez.
ALTER TABLE tbl_recurso
    ADD COLUMN IF NOT EXISTS difusion_autorizada boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN tbl_recurso.difusion_autorizada IS
    'Material autorizado por los autores para mostrarse en el catálogo público (RF-10, RF-11).';
