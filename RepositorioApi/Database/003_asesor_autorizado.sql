-- RF-16: "La ficha podrá mostrar los nombres de los docentes asesores
-- registrados cuya difusión se haya autorizado. Si hay dato y permiso,
-- aparece el asesor. Si falta alguno, la ficha puede publicarse sin
-- mostrar su nombre."
-- El supervisor registra, por cada asesor del proyecto, si se autoriza
-- mostrar su nombre en el catálogo público.
-- Es seguro ejecutarlo más de una vez.
ALTER TABLE tbl_proyecto_docente
    ADD COLUMN IF NOT EXISTS nombre_autorizado boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN tbl_proyecto_docente.nombre_autorizado IS
    'Se autorizó mostrar el nombre de este docente asesor en la ficha pública (RF-16).';
