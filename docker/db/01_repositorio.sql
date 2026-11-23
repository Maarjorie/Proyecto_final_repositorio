-- Base de prueba para Docker. Se carga sola al crear el contenedor db.
-- Cuentas @example.com, contraseña Repositorio2026.

--
-- PostgreSQL database dump
--

\restrict b8HIBz6Wpw5Um5QvdyvgcUrxb9yfrOxuxBAwMnqLwjJX9bbtWnheamEdFiI2qsQ

-- Dumped from database version 17.11 (Debian 17.11-1.pgdg13+2)
-- Dumped by pg_dump version 17.11 (Debian 17.11-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tbl_autor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_autor (
    id_autor integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    carnet character varying(20),
    id_usuario integer,
    CONSTRAINT ck_autor_apellidos CHECK ((TRIM(BOTH FROM apellidos) <> ''::text)),
    CONSTRAINT ck_autor_carnet CHECK (((carnet IS NULL) OR (((carnet)::text <> ''::text) AND ((carnet)::text = upper(TRIM(BOTH FROM carnet)))))),
    CONSTRAINT ck_autor_nombres CHECK ((TRIM(BOTH FROM nombres) <> ''::text))
);


--
-- Name: tbl_autor_id_autor_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_autor_id_autor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_autor_id_autor_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_autor_id_autor_seq OWNED BY public.tbl_autor.id_autor;


--
-- Name: tbl_carrera; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_carrera (
    id_carrera integer NOT NULL,
    codigo character varying(20) NOT NULL,
    nombre character varying(150) NOT NULL,
    id_departamento integer NOT NULL,
    CONSTRAINT ck_carrera_codigo CHECK ((((codigo)::text <> ''::text) AND ((codigo)::text = upper(TRIM(BOTH FROM codigo))))),
    CONSTRAINT ck_carrera_nombre CHECK ((TRIM(BOTH FROM nombre) <> ''::text))
);


--
-- Name: tbl_carrera_id_carrera_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_carrera_id_carrera_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_carrera_id_carrera_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_carrera_id_carrera_seq OWNED BY public.tbl_carrera.id_carrera;


--
-- Name: tbl_carrera_materia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_carrera_materia (
    id_carrera integer NOT NULL,
    id_materia integer NOT NULL,
    ciclo smallint NOT NULL,
    CONSTRAINT ck_carrera_materia_ciclo CHECK (((ciclo >= 1) AND (ciclo <= 14)))
);


--
-- Name: TABLE tbl_carrera_materia; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tbl_carrera_materia IS 'Materias del plan de estudios de cada carrera.';


--
-- Name: COLUMN tbl_carrera_materia.ciclo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tbl_carrera_materia.ciclo IS 'Ciclo en que se cursa la materia (1 a 14).';


--
-- Name: tbl_departamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_departamento (
    id_departamento integer NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion text,
    CONSTRAINT ck_departamento_nombre CHECK ((TRIM(BOTH FROM nombre) <> ''::text))
);


--
-- Name: tbl_departamento_id_departamento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_departamento_id_departamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_departamento_id_departamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_departamento_id_departamento_seq OWNED BY public.tbl_departamento.id_departamento;


--
-- Name: tbl_docente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_docente (
    id_docente integer NOT NULL,
    id_usuario integer NOT NULL,
    codigo_docente character varying(20) NOT NULL,
    id_departamento integer NOT NULL,
    CONSTRAINT ck_docente_codigo CHECK ((((codigo_docente)::text <> ''::text) AND ((codigo_docente)::text = upper(TRIM(BOTH FROM codigo_docente)))))
);


--
-- Name: COLUMN tbl_docente.id_departamento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tbl_docente.id_departamento IS 'Departamento del docente.';


--
-- Name: tbl_docente_id_docente_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_docente_id_docente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_docente_id_docente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_docente_id_docente_seq OWNED BY public.tbl_docente.id_docente;


--
-- Name: tbl_entrega; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_entrega (
    id_entrega integer NOT NULL,
    id_proyecto integer NOT NULL,
    id_usuario_envia integer NOT NULL,
    id_usuario_revisa integer,
    fecha_envio timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    estado_entrega character varying(20) DEFAULT 'pendiente'::character varying NOT NULL,
    fecha_revision timestamp without time zone,
    datos_propuestos jsonb,
    CONSTRAINT ck_entrega_estado CHECK (((estado_entrega)::text = ANY (ARRAY[('pendiente'::character varying)::text, ('aprobada'::character varying)::text, ('con_correcciones'::character varying)::text, ('rechazada'::character varying)::text]))),
    CONSTRAINT ck_entrega_fechas CHECK (((fecha_revision IS NULL) OR (fecha_revision >= fecha_envio))),
    CONSTRAINT ck_entrega_revision CHECK (((((estado_entrega)::text = 'pendiente'::text) AND (fecha_revision IS NULL)) OR (((estado_entrega)::text = ANY (ARRAY[('aprobada'::character varying)::text, ('con_correcciones'::character varying)::text, ('rechazada'::character varying)::text])) AND (id_usuario_revisa IS NOT NULL) AND (fecha_revision IS NOT NULL))))
);


--
-- Name: COLUMN tbl_entrega.datos_propuestos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tbl_entrega.datos_propuestos IS 'Cambios pedidos para un trabajo publicado; se aplican al aprobar.';


--
-- Name: tbl_entrega_id_entrega_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_entrega_id_entrega_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_entrega_id_entrega_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_entrega_id_entrega_seq OWNED BY public.tbl_entrega.id_entrega;


--
-- Name: tbl_etiquetas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_etiquetas (
    id_etiqueta integer NOT NULL,
    nombre character varying(60) NOT NULL,
    CONSTRAINT ck_etiqueta_nombre CHECK ((((nombre)::text <> ''::text) AND ((nombre)::text = lower(TRIM(BOTH FROM nombre)))))
);


--
-- Name: tbl_etiquetas_id_etiqueta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_etiquetas_id_etiqueta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_etiquetas_id_etiqueta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_etiquetas_id_etiqueta_seq OWNED BY public.tbl_etiquetas.id_etiqueta;


--
-- Name: tbl_favorito; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_favorito (
    id_usuario integer NOT NULL,
    id_proyecto integer NOT NULL,
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: tbl_historial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_historial (
    id_historial integer NOT NULL,
    id_usuario integer NOT NULL,
    id_proyecto integer NOT NULL,
    accion character varying(20) NOT NULL,
    fecha_accion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    detalle text,
    CONSTRAINT ck_historial_accion CHECK ((((accion)::text <> ''::text) AND ((accion)::text = lower(TRIM(BOTH FROM accion)))))
);


--
-- Name: tbl_historial_id_historial_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_historial_id_historial_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_historial_id_historial_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_historial_id_historial_seq OWNED BY public.tbl_historial.id_historial;


--
-- Name: tbl_materia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_materia (
    id_materia integer NOT NULL,
    codigo character varying(20) NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion text,
    CONSTRAINT ck_materia_codigo CHECK ((((codigo)::text <> ''::text) AND ((codigo)::text = upper(TRIM(BOTH FROM codigo))))),
    CONSTRAINT ck_materia_nombre CHECK ((TRIM(BOTH FROM nombre) <> ''::text))
);


--
-- Name: tbl_materia_docente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_materia_docente (
    id_materia integer NOT NULL,
    id_docente integer NOT NULL
);


--
-- Name: TABLE tbl_materia_docente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tbl_materia_docente IS 'Docentes que imparten cada materia.';


--
-- Name: tbl_materia_id_materia_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_materia_id_materia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_materia_id_materia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_materia_id_materia_seq OWNED BY public.tbl_materia.id_materia;


--
-- Name: tbl_notificacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_notificacion (
    id_notificacion integer NOT NULL,
    id_entrega integer NOT NULL,
    id_usuario_destino integer NOT NULL,
    mensaje text NOT NULL,
    fecha_envio timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_lectura timestamp without time zone,
    CONSTRAINT ck_notificacion_fechas CHECK (((fecha_lectura IS NULL) OR (fecha_lectura >= fecha_envio))),
    CONSTRAINT ck_notificacion_mensaje CHECK ((TRIM(BOTH FROM mensaje) <> ''::text))
);


--
-- Name: tbl_notificacion_id_notificacion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_notificacion_id_notificacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_notificacion_id_notificacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_notificacion_id_notificacion_seq OWNED BY public.tbl_notificacion.id_notificacion;


--
-- Name: tbl_proyecto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_proyecto (
    id_proyecto integer NOT NULL,
    titulo character varying(300) NOT NULL,
    resumen text NOT NULL,
    anio integer NOT NULL,
    id_tipo_proyecto integer NOT NULL,
    id_carrera integer NOT NULL,
    id_tematica integer NOT NULL,
    id_materia integer,
    estado_publicacion character varying(15) DEFAULT 'no_publicado'::character varying NOT NULL,
    estado_autorizacion character varying(20) DEFAULT 'pendiente'::character varying NOT NULL,
    es_destacado boolean DEFAULT false NOT NULL,
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_proyecto_anio CHECK (((anio >= 1) AND (anio <= 9999))),
    CONSTRAINT ck_proyecto_autorizacion CHECK (((estado_autorizacion)::text = ANY (ARRAY[('pendiente'::character varying)::text, ('autorizado'::character varying)::text, ('no_autorizado'::character varying)::text]))),
    CONSTRAINT ck_proyecto_fechas CHECK ((fecha_actualizacion >= fecha_registro)),
    CONSTRAINT ck_proyecto_publicacion CHECK (((estado_publicacion)::text = ANY (ARRAY[('no_publicado'::character varying)::text, ('publicado'::character varying)::text, ('retirado'::character varying)::text]))),
    CONSTRAINT ck_proyecto_publicacion_autorizada CHECK ((((estado_publicacion)::text <> 'publicado'::text) OR ((estado_autorizacion)::text = 'autorizado'::text))),
    CONSTRAINT ck_proyecto_resumen CHECK ((TRIM(BOTH FROM resumen) <> ''::text)),
    CONSTRAINT ck_proyecto_titulo CHECK ((TRIM(BOTH FROM titulo) <> ''::text))
);


--
-- Name: tbl_proyecto_autor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_proyecto_autor (
    id_proyecto integer NOT NULL,
    id_autor integer NOT NULL,
    orden_autoria integer NOT NULL,
    CONSTRAINT ck_proyecto_orden_autoria CHECK ((orden_autoria > 0))
);


--
-- Name: tbl_proyecto_docente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_proyecto_docente (
    id_proyecto integer NOT NULL,
    id_docente integer NOT NULL,
    nombre_autorizado boolean DEFAULT false NOT NULL
);


--
-- Name: COLUMN tbl_proyecto_docente.nombre_autorizado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tbl_proyecto_docente.nombre_autorizado IS 'Si se puede mostrar el nombre del asesor en la ficha.';


--
-- Name: tbl_proyecto_etiqueta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_proyecto_etiqueta (
    id_proyecto integer NOT NULL,
    id_etiqueta integer NOT NULL
);


--
-- Name: tbl_proyecto_id_proyecto_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_proyecto_id_proyecto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_proyecto_id_proyecto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_proyecto_id_proyecto_seq OWNED BY public.tbl_proyecto.id_proyecto;


--
-- Name: tbl_recurso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_recurso (
    id_recurso integer NOT NULL,
    id_entrega integer NOT NULL,
    id_tipo_recurso integer NOT NULL,
    nombre character varying(200) NOT NULL,
    ubicacion text NOT NULL,
    difusion_autorizada boolean DEFAULT false NOT NULL,
    CONSTRAINT ck_recurso_nombre CHECK ((TRIM(BOTH FROM nombre) <> ''::text)),
    CONSTRAINT ck_recurso_ubicacion CHECK (((TRIM(BOTH FROM ubicacion) <> ''::text) AND (ubicacion = TRIM(BOTH FROM ubicacion))))
);


--
-- Name: COLUMN tbl_recurso.difusion_autorizada; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tbl_recurso.difusion_autorizada IS 'Si el material se puede descargar desde el catálogo.';


--
-- Name: tbl_recurso_id_recurso_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_recurso_id_recurso_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_recurso_id_recurso_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_recurso_id_recurso_seq OWNED BY public.tbl_recurso.id_recurso;


--
-- Name: tbl_rol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_rol (
    id_rol integer NOT NULL,
    nombre_rol character varying(50) NOT NULL,
    descripcion text,
    CONSTRAINT ck_rol_nombre CHECK ((((nombre_rol)::text <> ''::text) AND ((nombre_rol)::text = lower(TRIM(BOTH FROM nombre_rol)))))
);


--
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_rol_id_rol_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_rol_id_rol_seq OWNED BY public.tbl_rol.id_rol;


--
-- Name: tbl_tematica; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_tematica (
    id_tematica integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    CONSTRAINT ck_tematica_nombre CHECK ((((nombre)::text <> ''::text) AND ((nombre)::text = lower(TRIM(BOTH FROM nombre)))))
);


--
-- Name: tbl_tematica_id_tematica_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_tematica_id_tematica_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_tematica_id_tematica_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_tematica_id_tematica_seq OWNED BY public.tbl_tematica.id_tematica;


--
-- Name: tbl_tipo_proyecto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_tipo_proyecto (
    id_tipo_proyecto integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion text,
    CONSTRAINT ck_tipo_proyecto_nombre CHECK ((((nombre)::text <> ''::text) AND ((nombre)::text = lower(TRIM(BOTH FROM nombre)))))
);


--
-- Name: tbl_tipo_proyecto_id_tipo_proyecto_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_tipo_proyecto_id_tipo_proyecto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_tipo_proyecto_id_tipo_proyecto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_tipo_proyecto_id_tipo_proyecto_seq OWNED BY public.tbl_tipo_proyecto.id_tipo_proyecto;


--
-- Name: tbl_tipo_recurso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_tipo_recurso (
    id_tipo_recurso integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion text,
    CONSTRAINT ck_tipo_recurso_nombre CHECK ((((nombre)::text <> ''::text) AND ((nombre)::text = lower(TRIM(BOTH FROM nombre)))))
);


--
-- Name: tbl_tipo_recurso_id_tipo_recurso_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_tipo_recurso_id_tipo_recurso_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_tipo_recurso_id_tipo_recurso_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_tipo_recurso_id_tipo_recurso_seq OWNED BY public.tbl_tipo_recurso.id_tipo_recurso;


--
-- Name: tbl_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_usuario (
    id_usuario integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    correo character varying(254) NOT NULL,
    contrasena_hash text NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_usuario_apellidos CHECK ((TRIM(BOTH FROM apellidos) <> ''::text)),
    CONSTRAINT ck_usuario_contrasena_hash CHECK ((TRIM(BOTH FROM contrasena_hash) <> ''::text)),
    CONSTRAINT ck_usuario_correo CHECK ((((correo)::text <> ''::text) AND ((correo)::text = lower(TRIM(BOTH FROM correo))))),
    CONSTRAINT ck_usuario_nombres CHECK ((TRIM(BOTH FROM nombres) <> ''::text))
);


--
-- Name: tbl_usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tbl_usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tbl_usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tbl_usuario_id_usuario_seq OWNED BY public.tbl_usuario.id_usuario;


--
-- Name: tbl_usuario_rol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_usuario_rol (
    id_usuario integer NOT NULL,
    id_rol integer NOT NULL
);


--
-- Name: tbl_autor id_autor; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_autor ALTER COLUMN id_autor SET DEFAULT nextval('public.tbl_autor_id_autor_seq'::regclass);


--
-- Name: tbl_carrera id_carrera; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_carrera ALTER COLUMN id_carrera SET DEFAULT nextval('public.tbl_carrera_id_carrera_seq'::regclass);


--
-- Name: tbl_departamento id_departamento; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_departamento ALTER COLUMN id_departamento SET DEFAULT nextval('public.tbl_departamento_id_departamento_seq'::regclass);


--
-- Name: tbl_docente id_docente; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_docente ALTER COLUMN id_docente SET DEFAULT nextval('public.tbl_docente_id_docente_seq'::regclass);


--
-- Name: tbl_entrega id_entrega; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_entrega ALTER COLUMN id_entrega SET DEFAULT nextval('public.tbl_entrega_id_entrega_seq'::regclass);


--
-- Name: tbl_etiquetas id_etiqueta; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_etiquetas ALTER COLUMN id_etiqueta SET DEFAULT nextval('public.tbl_etiquetas_id_etiqueta_seq'::regclass);


--
-- Name: tbl_historial id_historial; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_historial ALTER COLUMN id_historial SET DEFAULT nextval('public.tbl_historial_id_historial_seq'::regclass);


--
-- Name: tbl_materia id_materia; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_materia ALTER COLUMN id_materia SET DEFAULT nextval('public.tbl_materia_id_materia_seq'::regclass);


--
-- Name: tbl_notificacion id_notificacion; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_notificacion ALTER COLUMN id_notificacion SET DEFAULT nextval('public.tbl_notificacion_id_notificacion_seq'::regclass);


--
-- Name: tbl_proyecto id_proyecto; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto ALTER COLUMN id_proyecto SET DEFAULT nextval('public.tbl_proyecto_id_proyecto_seq'::regclass);


--
-- Name: tbl_recurso id_recurso; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_recurso ALTER COLUMN id_recurso SET DEFAULT nextval('public.tbl_recurso_id_recurso_seq'::regclass);


--
-- Name: tbl_rol id_rol; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_rol ALTER COLUMN id_rol SET DEFAULT nextval('public.tbl_rol_id_rol_seq'::regclass);


--
-- Name: tbl_tematica id_tematica; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_tematica ALTER COLUMN id_tematica SET DEFAULT nextval('public.tbl_tematica_id_tematica_seq'::regclass);


--
-- Name: tbl_tipo_proyecto id_tipo_proyecto; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_tipo_proyecto ALTER COLUMN id_tipo_proyecto SET DEFAULT nextval('public.tbl_tipo_proyecto_id_tipo_proyecto_seq'::regclass);


--
-- Name: tbl_tipo_recurso id_tipo_recurso; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_tipo_recurso ALTER COLUMN id_tipo_recurso SET DEFAULT nextval('public.tbl_tipo_recurso_id_tipo_recurso_seq'::regclass);


--
-- Name: tbl_usuario id_usuario; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.tbl_usuario_id_usuario_seq'::regclass);


--
-- Data for Name: tbl_autor; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_autor (id_autor, nombres, apellidos, carnet, id_usuario) FROM stdin;
3	Andrea Rebeca	Villalobos González	VG14648	\N
4	Gabriela Carolina	Sánchez Ramírez	SR14985	\N
5	Mónica Alejandra	Quintanilla Romero	QR14905	\N
6	Fátima Valeria	Sánchez Orellana	SO14466	\N
7	Josué Ricardo	Lazo López	LL14425	\N
8	Carolina Valeria	Bonilla González	BG14729	\N
9	Edwin Miguel	Chávez López	CL14785	\N
10	Yesenia Gloria	Portillo Umaña	PU14508	\N
11	Fátima Lucía	Gómez Flores	GF14065	\N
12	Gabriela Patricia	Reyes Guevara	RG14954	\N
13	Fátima Mónica	Ventura García	VG14148	\N
14	Rebeca Jennifer	Amaya Rodríguez	AR14796	\N
15	Katherine Fátima	Bonilla Cruz	BC14627	\N
16	Emerson Gerson	Benítez Reyes	BR14797	\N
17	Rodrigo Henry	Hernández Villalobos	HV14195	\N
18	Mónica Alejandra	Villalobos Chávez	VC14251	\N
19	Walter Bryan	Martínez López	ML14618	\N
20	Andrea Rocío	Romero Sorto	RS14167	\N
21	Katherine Marisol	Orellana Villalobos	OV14912	\N
22	Rocío Gloria	Lazo Rodríguez	LR14137	\N
23	Silvia Lucía	Flores Benítez	FB14568	\N
24	Óscar Edwin	Argueta Fuentes	AF15749	\N
25	Fernando Rafael	Sánchez Reyes	SR15449	\N
26	Mónica Patricia	Pérez Chávez	PC15855	\N
27	Elena Mónica	Quintanilla Granados	QG15526	\N
28	Emerson José	Lazo Portillo	LP15643	\N
29	Fátima Yesenia	Rivera Benítez	RB15893	\N
30	Josué Miguel	Guevara Rodríguez	GR15432	\N
31	Tatiana Jennifer	Rodríguez López	RL15827	\N
32	Andrés Edwin	González Ramírez	GR15599	\N
33	Wilfredo David	Argueta Canales	AC15928	\N
34	Karla Fátima	Reyes Argueta	RA15776	\N
35	Fátima Jennifer	Quintanilla Lazo	QL15387	\N
36	Ricardo Walter	Saravia Ramírez	SR15032	\N
37	Carlos Mario	Sánchez Alvarenga	SA15720	\N
38	Fátima Valeria	Alvarenga Mejía	AM15042	\N
39	Miguel Fernando	Díaz García	DG15995	\N
40	Alejandra Rocío	Rivera Rodríguez	RR15084	\N
41	Rodrigo Henry	Orellana Alvarenga	OA15765	\N
42	Óscar Mario	Mejía Umaña	MU15467	\N
43	Valeria Patricia	Ventura Hernández	VH15365	\N
44	Fernando Daniel	Sánchez Argueta	SA15154	\N
45	Josué Francisco	Díaz Saravia	DS15224	\N
46	Francisco Mario	Chávez González	CG15005	\N
47	Kevin Ricardo	Majano Torres	MT15166	\N
48	Fernando Mario	Sorto Villalobos	SV15526	\N
49	Carlos Diego	Díaz González	DG15162	\N
50	José Emerson	Mejía Sorto	MS15875	\N
51	Ana Yesenia	Zelaya Umaña	ZU15194	\N
52	Alexander Emerson	Ayala Majano	AM15190	\N
53	Lucía Carolina	Bonilla Guevara	BG15759	\N
54	Edwin Walter	Canales Sánchez	CS15292	\N
55	Andrea Gloria	Majano Lazo	ML15681	\N
56	David Gerson	Ventura Cruz	VC15973	\N
57	Sofía Mónica	Sánchez Saravia	SS15189	\N
58	Miguel Rafael	Martínez Quintanilla	MQ15973	\N
59	Mónica Claudia	Martínez Saravia	MS15334	\N
60	María Ana	López Zelaya	LZ15827	\N
61	Mario Miguel	Umaña Ventura	UV15213	\N
62	Rodrigo David	Lazo Chávez	LC15963	\N
63	Edwin David	González García	GG15934	\N
64	Silvia Mónica	Chávez Amaya	CA15555	\N
65	Wendy Beatriz	Hernández Quintanilla	HQ15390	\N
66	Sofía Ana	Romero Hernández	RH15919	\N
67	Tatiana Silvia	Alvarenga Argueta	AA15422	\N
68	Carlos Gerson	Majano Gómez	MG15721	\N
69	Andrea Elena	Ventura García	VG15895	\N
70	José Rodrigo	Umaña Canales	UC15482	\N
71	Patricia Yesenia	Granados Mejía	GM15452	\N
72	José Bryan	Díaz Pérez	DP15127	\N
73	Elena Rebeca	Granados Sánchez	GS16828	\N
74	Claudia Carolina	Romero López	RL16500	\N
75	Marisol Patricia	Majano Zelaya	MZ16997	\N
76	Luis Josué	Argueta Zelaya	AZ16572	\N
77	Andrea Daniela	Cruz Pérez	CP16419	\N
78	Karla Silvia	Sorto Rodríguez	SR16092	\N
79	Yesenia Jennifer	Portillo Flores	PF16792	\N
80	Miguel Juan	Martínez Díaz	MD16247	\N
81	Edwin Andrés	Quintanilla Díaz	QD16897	\N
82	Mario Bryan	Villalobos Cruz	VC16407	\N
83	Mario Josué	Orellana López	OL16862	\N
84	José Gerson	Argueta López	AL16034	\N
85	Gerson José	Reyes Ramírez	RR16491	\N
86	Karla Sofía	Rodríguez García	RG16627	\N
87	Karla Patricia	Bonilla Reyes	BR16672	\N
88	Edwin Diego	Majano Umaña	MU16586	\N
89	Ricardo Kevin	Rodríguez Chávez	RC16344	\N
90	Alexander Ricardo	Portillo Canales	PC16048	\N
91	Francisco Carlos	Martínez García	MG16360	\N
92	Jorge Emerson	Benítez Rivera	BR16083	\N
93	Marisol Gloria	Romero Díaz	RD16901	\N
94	Silvia Mónica	Cruz Díaz	CD16356	\N
95	Andrés Daniel	Chávez Orellana	CO16404	\N
96	María Jennifer	Pérez Argueta	PA16067	\N
97	Jorge Daniel	Saravia Sorto	SS16162	\N
98	Katherine Sofía	Romero Rivera	RR16866	\N
99	Rodrigo José	Flores Sánchez	FS16769	\N
100	Karla Sofía	Romero Díaz	RD16164	\N
101	Julio Fernando	Benítez Gómez	BG16956	\N
102	Gabriela Fátima	Fuentes Torres	FT16989	\N
103	Beatriz Lucía	Torres Ayala	TA16659	\N
104	Diego Kevin	Alvarenga Sorto	AS16528	\N
105	Óscar Luis	Ventura Quintanilla	VQ16600	\N
106	Silvia Beatriz	Zelaya Argueta	ZA16931	\N
107	Rodrigo Walter	Canales Ayala	CA16447	\N
108	Bryan Miguel	Quintanilla Orellana	QO16358	\N
109	Patricia Ana	Chávez Romero	CR16758	\N
110	Ana Mónica	Torres Lazo	TL16814	\N
111	Yesenia Mónica	Ayala Chávez	AC16463	\N
112	Silvia Daniela	Ayala Díaz	AD16123	\N
113	Jennifer Katherine	Reyes Portillo	RP16338	\N
114	Fernando Gerson	Pérez Sánchez	PS16642	\N
120	Juan David	Fuentes Rivera	FR16748	\N
125	Rocío Marisol	García Pérez	GP16931	\N
126	Jorge Julio	Portillo Saravia	PS16666	\N
127	Katherine Beatriz	Sorto Díaz	SD16204	\N
130	José Julio	Orellana Zelaya	OZ16096	\N
131	Fernando Julio	Sorto Rodríguez	SR16351	\N
132	Wendy Alejandra	Fuentes López	FL16172	\N
133	Claudia Tatiana	Hernández Amaya	HA16378	\N
134	Alejandra Wendy	García Hernández	GH17318	\N
135	Valeria Silvia	Umaña Torres	UT17946	\N
136	María Alejandra	Alvarenga Ramírez	AR17067	\N
138	Claudia Paola	Villalobos Umaña	VU17101	\N
139	Fátima Claudia	Zelaya Umaña	ZU17999	\N
147	Wilfredo Edwin	Portillo Umaña	PU17845	\N
148	Patricia Beatriz	Cruz Guevara	CG17763	\N
149	Luis Kevin	Lazo Ramírez	LR17979	\N
150	Bryan Carlos	Alvarenga López	AL17673	\N
151	Emerson Carlos	Sorto Rodríguez	SR17065	\N
152	Juan José	Umaña Pérez	UP17402	\N
153	Elena Fátima	López Sánchez	LS17739	\N
115	Gloria Andrea	Flores Ventura	FV16161	\N
116	Wilfredo Jorge	Rodríguez Canales	RC16558	\N
117	Edwin David	González Chávez	GC16049	\N
118	Luis Daniel	Canales Reyes	CR16709	\N
119	Gloria Karla	Chávez Argueta	CA16145	\N
121	Wilfredo Jorge	Cruz Fuentes	CF16336	\N
122	Elena Sofía	Flores Sorto	FS16984	\N
123	Emerson Carlos	Argueta Díaz	AD16774	\N
124	Juan Daniel	Fuentes Rivera	FR16004	\N
128	Claudia Lucía	Benítez Sánchez	BS16135	\N
129	Josué Emerson	Flores Majano	FM16346	\N
137	Alexander David	Benítez Saravia	BS17161	\N
140	Fernando Daniel	Sánchez Argueta	SA17154	\N
141	Mónica Rocío	Flores Pérez	FP17863	\N
142	Walter Kevin	Villalobos Rivera	VR17855	\N
143	Katherine Beatriz	González Torres	GT17966	\N
144	Juan José	Benítez Orellana	BO17306	\N
145	Emerson Jorge	García Argueta	GA17801	\N
146	Wilfredo Rafael	Hernández Chávez	HC17901	\N
154	Wilfredo Gerson	González Pérez	GP17780	\N
155	Beatriz Patricia	Sorto Orellana	SO17308	\N
156	Bryan José	Sánchez Romero	SR17739	\N
157	Elena Yesenia	Gómez Díaz	GD17813	\N
158	Alexander José	Ventura Umaña	VU17378	\N
159	Miguel Wilfredo	López Sorto	LS17386	\N
160	Kevin Henry	Quintanilla Fuentes	QF17731	\N
161	José Jorge	Argueta Rivera	AR17194	\N
162	Jorge Juan	Canales López	CL17204	\N
163	Alexander Josué	Canales Ramírez	CR17001	\N
164	Óscar Gerson	Ventura Chávez	VC17430	\N
165	Valeria Lucía	Amaya García	AG17875	\N
166	Óscar Gerson	Gómez Alvarenga	GA17150	\N
167	Fernando Luis	Hernández González	HG17155	\N
168	Óscar Emerson	Ayala López	AL17770	\N
169	Bryan Mario	Torres Ramírez	TR17211	\N
170	Karla Tatiana	Rivera Gómez	RG17644	\N
171	Wendy Katherine	Portillo Quintanilla	PQ17091	\N
172	Gerson Walter	Rodríguez Chávez	RC17455	\N
173	Andrea Sofía	García Majano	GM18377	\N
174	Gerson Julio	Canales Martínez	CM18868	\N
175	Fátima Yesenia	Zelaya Reyes	ZR18213	\N
176	David Wilfredo	García Villalobos	GV18668	\N
177	Kevin Juan	Mejía López	ML18083	\N
178	Rodrigo Emerson	Martínez García	MG18950	\N
179	Rocío Claudia	Reyes Zelaya	RZ18859	\N
180	Rocío Alejandra	Martínez Rodríguez	MR18888	\N
181	Miguel Gerson	Saravia Guevara	SG18648	\N
182	Edwin Mario	Benítez Bonilla	BB18660	\N
183	Gloria Ana	Canales Ventura	CV18580	\N
184	Mónica Marisol	Quintanilla Romero	QR18663	\N
185	Carolina Paola	Ventura Chávez	VC18563	\N
186	Alexander Gerson	Argueta Canales	AC18021	\N
187	Ana Silvia	Flores Ayala	FA18911	\N
188	Bryan Wilfredo	Rodríguez Pérez	RP18170	\N
189	Elena Silvia	Martínez Benítez	MB18222	\N
190	Wendy Katherine	Argueta Ayala	AA18755	\N
191	Rafael Francisco	Majano Bonilla	MB18974	\N
192	Rafael Alexander	Díaz Ayala	DA18379	\N
193	Gerson José	Rivera Alvarenga	RA18563	\N
194	Elena Daniela	Flores Amaya	FA18537	\N
195	Beatriz Tatiana	Granados Benítez	GB18646	\N
196	Gloria Rebeca	Villalobos Portillo	VP18653	\N
197	Valeria Rocío	Lazo Bonilla	LB18981	\N
198	Diego Luis	Fuentes Ventura	FV18065	\N
199	Andrés Fernando	Torres Canales	TC18093	\N
200	Gerson Luis	Reyes Saravia	RS18997	\N
201	Beatriz Paola	Villalobos Majano	VM18449	\N
202	Tatiana Rocío	Mejía Ventura	MV18124	\N
203	Rafael Ricardo	Alvarenga Orellana	AO18350	\N
204	Jorge Fernando	Rivera Ayala	RA18949	\N
205	Henry Francisco	Rodríguez López	RL18443	\N
206	Gabriela Paola	Saravia Díaz	SD18216	\N
207	José Óscar	Torres Ventura	TV18644	\N
208	Rodrigo Diego	Pérez Rodríguez	PR18638	\N
209	Juan David	Argueta Sánchez	AS18697	\N
210	Jennifer Valeria	Gómez Lazo	GL18026	\N
211	Tatiana Katherine	Ramírez Benítez	RB19468	\N
212	Wilfredo Francisco	Villalobos Quintanilla	VQ19415	\N
213	Rodrigo Gerson	Portillo Villalobos	PV19272	\N
214	Patricia Jennifer	Gómez López	GL19333	\N
215	Sofía Patricia	Sorto Martínez	SM19718	\N
216	Henry José	Reyes Ventura	RV19117	\N
217	Fátima Katherine	Reyes Torres	RT19010	\N
218	Rafael Walter	Villalobos Cruz	VC19790	\N
219	Gabriela Patricia	Sorto Amaya	SA19366	\N
220	Emerson Walter	Lazo Chávez	LC19883	\N
221	Emerson Fernando	Rodríguez Reyes	RR19645	\N
222	José Henry	Fuentes Pérez	FP19683	\N
223	Rodrigo Ricardo	Granados Umaña	GU19782	\N
224	Mario Julio	Orellana Sorto	OS19502	\N
225	Gerson Rodrigo	Benítez Rivera	BR19183	\N
226	Andrea Katherine	Martínez Fuentes	MF19695	\N
227	Andrés Alexander	Zelaya Sorto	ZS19030	\N
228	Mario Francisco	Díaz Sorto	DS19278	\N
229	Diego Fernando	Torres Benítez	TB19914	\N
230	Valeria Claudia	Sánchez Portillo	SP19986	\N
231	Julio Diego	García Martínez	GM19207	\N
232	Silvia Paola	Romero Guevara	RG19952	\N
233	Gerson Josué	Gómez Amaya	GA19682	\N
234	Kevin Wilfredo	Hernández Orellana	HO19815	\N
235	Walter Andrés	Díaz Umaña	DU19672	\N
236	María Fátima	Sánchez Fuentes	SF19047	\N
237	Fátima Tatiana	Ayala Argueta	AA19661	\N
238	Francisco José	Martínez Díaz	MD19490	\N
239	Daniel Francisco	Gómez Mejía	GM19456	\N
240	Walter Julio	Pérez Reyes	PR19010	\N
241	Wendy Valeria	Ayala Romero	AR19370	\N
242	Claudia Gloria	Romero Orellana	RO19173	\N
243	Luis Carlos	Sorto Reyes	SR19212	\N
244	Fernando Daniel	Lazo Granados	LG19384	\N
245	Patricia Rocío	Martínez Benítez	MB19242	\N
246	Carlos Josué	Ramírez Quintanilla	RQ19907	\N
247	Rebeca Ana	Martínez Reyes	MR19943	\N
248	Óscar Alexander	Fuentes López	FL19790	\N
251	Ricardo Josué	López Sorto	LS19015	\N
252	José Fernando	Alvarenga Pérez	AP19319	\N
253	Alexander Bryan	Quintanilla López	QL19500	\N
257	Óscar David	Benítez Majano	BM19927	\N
258	María Marisol	Guevara Quintanilla	GQ19809	\N
259	Sofía Karla	Umaña Orellana	UO19754	\N
260	Patricia Mónica	Chávez Canales	CC19224	\N
261	Carolina Karla	Zelaya Chávez	ZC19658	\N
262	Beatriz Wendy	Martínez Argueta	MA19004	\N
263	Paola Alejandra	Rodríguez Portillo	RP19267	\N
264	Lucía Jennifer	González Mejía	GM19165	\N
265	Yesenia Silvia	Benítez Chávez	BC19730	\N
266	Kevin Josué	Flores Hernández	FH19857	\N
267	Ricardo Josué	Guevara Chávez	GC19988	\N
249	Katherine Wendy	Guevara Sánchez	GS19978	\N
250	Wendy Valeria	Pérez Bonilla	PB19242	\N
254	Tatiana Lucía	Umaña Chávez	UC19741	\N
255	Carlos Bryan	Rodríguez Cruz	RC19979	\N
256	Lucía Fátima	Sorto Ramírez	SR19502	\N
268	Rafael Andrés	López Alvarenga	LA19738	\N
269	Emerson Luis	Zelaya Umaña	ZU19351	\N
270	Claudia Beatriz	Hernández Sánchez	HS19084	\N
271	María Rocío	Chávez Flores	CF19160	\N
272	Daniel Edwin	Hernández Pérez	HP19829	\N
273	José Jorge	Reyes Ayala	RA19927	\N
274	Gloria Gabriela	Hernández Rodríguez	HR19482	\N
275	Wilfredo Andrés	García Zelaya	GZ19144	\N
276	Mónica Gabriela	Alvarenga García	AG19151	\N
277	Julio Gerson	González Cruz	GC19833	\N
278	Rodrigo José	Saravia Umaña	SU19882	\N
279	Daniela Marisol	Amaya Argueta	AA19627	\N
280	Miguel Henry	Cruz Argueta	CA19019	\N
281	Gerson Ricardo	Mejía Chávez	MC19551	\N
282	Yesenia Alejandra	López Sorto	LS19377	\N
283	Mario David	López González	LG19275	\N
284	Wendy Karla	Cruz Bonilla	CB19964	\N
285	Rodrigo Andrés	Díaz Ayala	DA19978	\N
286	Jorge Diego	Saravia Flores	SF19021	\N
287	Alexander Josué	Villalobos Argueta	VA19730	\N
288	Luis Julio	Bonilla Pérez	BP19767	\N
289	Juan Rodrigo	Alvarenga Pérez	AP20722	\N
290	Andrés Jorge	Díaz Torres	DT20926	\N
291	Francisco Diego	Saravia Sorto	SS20737	\N
292	Carlos José	Sorto Martínez	SM20742	\N
293	Claudia Silvia	García Torres	GT20939	\N
294	Gerson Henry	Portillo Alvarenga	PA20724	\N
295	Carolina Daniela	García Orellana	GO20575	\N
296	Claudia Andrea	Guevara Alvarenga	GA20125	\N
297	Beatriz Tatiana	Ramírez González	RG20960	\N
298	José Fernando	Portillo Quintanilla	PQ20737	\N
299	Bryan Miguel	Reyes Ventura	RV20068	\N
300	María Sofía	García González	GG20568	\N
301	Emerson Francisco	Ventura Argueta	VA20359	\N
302	Yesenia Rebeca	Granados Saravia	GS20355	\N
303	Wendy Patricia	Orellana Sánchez	OS20316	\N
304	Katherine María	Pérez Amaya	PA20755	\N
305	Daniel Edwin	Sánchez García	SG20047	\N
306	David Jorge	Villalobos García	VG20701	\N
307	Fátima Rebeca	Amaya Cruz	AC20835	\N
308	Mario Ricardo	Rivera Amaya	RA20592	\N
309	Rocío Elena	Zelaya Ventura	ZV20432	\N
310	Gerson Daniel	Guevara Flores	GF20436	\N
311	Fernando Bryan	Amaya Torres	AT20837	\N
312	Edwin Alexander	Portillo Reyes	PR20700	\N
313	Miguel Julio	Saravia Rivera	SR20390	\N
314	Claudia María	González Villalobos	GV20295	\N
315	Marisol Tatiana	Gómez Guevara	GG20331	\N
316	Elena Daniela	Flores Amaya	FA20537	\N
317	Gloria Rebeca	Villalobos Portillo	VP20653	\N
318	Daniel Henry	Guevara Fuentes	GF20343	\N
319	Sofía Gabriela	Alvarenga Rodríguez	AR20123	\N
320	Francisco Miguel	Chávez Quintanilla	CQ20148	\N
321	Beatriz María	Martínez Ventura	MV20386	\N
322	Julio David	Sorto García	SG20974	\N
323	Beatriz Daniela	Cruz Pérez	CP20283	\N
324	Andrea Elena	Ventura García	VG20895	\N
325	Rebeca Daniela	Majano Fuentes	MF20016	\N
326	Patricia Andrea	López Díaz	LD20680	\N
327	Yesenia Sofía	Torres Chávez	TC20917	\N
328	Edwin Bryan	Lazo Portillo	LP20983	\N
329	Miguel Kevin	Sorto Pérez	SP20889	\N
330	Alejandra Jennifer	Benítez Ramírez	BR20705	\N
331	Andrea Jennifer	Portillo Rivera	PR20699	\N
332	Beatriz Ana	Rivera Guevara	RG20900	\N
333	Gabriela Daniela	Pérez Bonilla	PB20456	\N
334	Wendy Silvia	Benítez Sorto	BS20587	\N
335	Rodrigo David	Lazo Chávez	LC20963	\N
336	Carlos Rafael	Ventura Alvarenga	VA20837	\N
337	Silvia Mónica	Chávez Amaya	CA20555	\N
338	Katherine Elena	Guevara Hernández	GH20987	\N
339	Gloria Yesenia	Zelaya Gómez	ZG20776	\N
340	Rocío Claudia	Ventura Pérez	VP20991	\N
341	Jennifer Rebeca	Mejía González	MG20598	\N
342	Daniela Jennifer	López Majano	LM20508	\N
343	Henry Ricardo	López Rodríguez	LR20306	\N
344	Diego José	Torres Ventura	TV20160	\N
345	Julio Ricardo	Granados Umaña	GU20998	\N
346	Diego Carlos	Portillo Rivera	PR20916	\N
347	Mónica Elena	Díaz Ventura	DV20510	\N
348	Karla Rocío	Amaya Lazo	AL20515	\N
349	Emerson Walter	Sorto Majano	SM20303	\N
350	Óscar Juan	Orellana García	OG20153	\N
351	Francisco Gerson	Canales Pérez	CP20656	\N
352	Karla Patricia	Amaya Benítez	AB20235	\N
353	Daniela Mónica	Mejía Ramírez	MR20498	\N
354	Katherine Carolina	Guevara Orellana	GO20908	\N
355	Jorge Walter	Canales Reyes	CR20594	\N
356	Fátima Mónica	Flores Hernández	FH20876	\N
357	Fernando Andrés	Bonilla Rodríguez	BR20924	\N
358	Andrea Katherine	Alvarenga González	AG20452	\N
359	Gerson Carlos	Gómez Sorto	GS20727	\N
360	Gloria Valeria	Villalobos Zelaya	VZ20872	\N
361	Katherine Yesenia	Canales Zelaya	CZ20318	\N
362	Carlos Rafael	Reyes Hernández	RH20059	\N
363	Valeria Alejandra	Ramírez Sorto	RS20102	\N
364	Wilfredo Julio	García Hernández	GH20745	\N
365	Gerson Diego	Saravia Cruz	SC20205	\N
366	Gabriela Ana	Benítez Bonilla	BB20860	\N
367	Daniela Wendy	Quintanilla Zelaya	QZ20320	\N
368	Walter Francisco	Martínez Orellana	MO20438	\N
369	Mario Rodrigo	Ayala Cruz	AC20143	\N
370	Sofía Lucía	Umaña Hernández	UH20032	\N
371	Paola Wendy	Ramírez López	RL20260	\N
372	Ana Wendy	Martínez Umaña	MU20085	\N
373	Daniel Wilfredo	Díaz Chávez	DC21780	\N
374	Carlos Edwin	Sorto Gómez	SG21699	\N
375	Beatriz Rocío	Rivera Díaz	RD21368	\N
376	Josué Rafael	Pérez Mejía	PM21840	\N
377	Gerson Emerson	Alvarenga González	AG21547	\N
378	Valeria Paola	Pérez Guevara	PG21035	\N
379	Rafael Jorge	Argueta García	AG21908	\N
380	Julio Walter	Martínez Saravia	MS21365	\N
381	Ricardo José	Argueta Díaz	AD21705	\N
382	Mario Daniel	Bonilla Portillo	BP21674	\N
385	David Henry	Portillo Sorto	PS21573	\N
386	Andrés Henry	Villalobos Amaya	VA21254	\N
393	Andrea Alejandra	Quintanilla Orellana	QO21991	\N
394	David Julio	Umaña Benítez	UB21789	\N
395	Gloria Katherine	Amaya López	AL21414	\N
396	Wendy Patricia	Flores Villalobos	FV21332	\N
397	Fernando Diego	Torres Chávez	TC21109	\N
398	Ana María	Pérez Chávez	PC21760	\N
399	Katherine Patricia	Martínez Díaz	MD21528	\N
400	Kevin Rodrigo	Saravia Flores	SF21013	\N
401	Juan Miguel	García Lazo	GL21498	\N
402	María Ana	Pérez Sánchez	PS21634	\N
403	Luis Edwin	Majano Alvarenga	MA21049	\N
383	Yesenia Fátima	Sorto Guevara	SG21396	\N
384	Francisco Óscar	Quintanilla Rivera	QR21183	\N
387	Carlos Edwin	Saravia Mejía	SM21684	\N
388	Karla María	González Ayala	GA21807	\N
389	Lucía Gabriela	Reyes Hernández	RH21767	\N
390	Fátima Paola	Pérez Portillo	PP21466	\N
391	Miguel Mario	Lazo Saravia	LS21377	\N
392	Daniela Katherine	Argueta Torres	AT21659	\N
404	Gerson Luis	López Torres	LT21160	\N
405	Miguel Bryan	Granados Cruz	GC21311	\N
406	Elena Rebeca	Rivera Reyes	RR21457	\N
407	Lucía Daniela	López Rodríguez	LR21575	\N
408	Jennifer Carolina	Lazo Chávez	LC21327	\N
409	Gerson Rodrigo	Villalobos Ayala	VA21539	\N
410	Mónica Karla	Ventura Rivera	VR21891	\N
411	Sofía Gloria	Cruz Hernández	CH21721	\N
412	Francisco Mario	Zelaya González	ZG21149	\N
413	Carlos Juan	Zelaya Guevara	ZG21995	\N
414	Wilfredo Carlos	Sorto Cruz	SC21871	\N
415	Julio José	López Romero	LR21793	\N
416	Sofía Carolina	Ramírez Romero	RR21894	\N
417	Óscar Ricardo	Ayala Ventura	AV21936	\N
418	Ana Fátima	Gómez Umaña	GU21501	\N
419	Walter Alexander	Orellana Cruz	OC21356	\N
420	Katherine María	Argueta Hernández	AH21356	\N
421	Fernando Walter	Sánchez Martínez	SM21524	\N
422	María Tatiana	Rivera Bonilla	RB21196	\N
423	David Jorge	Martínez Bonilla	MB21649	\N
424	José Jorge	Flores Romero	FR21789	\N
425	Katherine Rocío	Gómez Quintanilla	GQ21047	\N
426	Juan Mario	Díaz Portillo	DP21411	\N
427	Mónica Beatriz	Villalobos Canales	VC21735	\N
428	Yesenia Marisol	Portillo González	PG21928	\N
429	Ricardo José	Pérez Saravia	PS21763	\N
430	Lucía Rebeca	Bonilla Cruz	BC21511	\N
431	Gabriela Elena	Díaz Mejía	DM21763	\N
432	Rodrigo Fernando	Amaya Martínez	AM21112	\N
433	Valeria Ana	Zelaya Sánchez	ZS21144	\N
434	Ana Rocío	Amaya Ayala	AA21974	\N
435	Daniel José	Orellana Ayala	OA21134	\N
436	Alejandra Paola	Canales Quintanilla	CQ21109	\N
437	Silvia Mónica	Flores Lazo	FL21520	\N
438	Jorge Daniel	Amaya Rodríguez	AR14778	\N
439	Katherine Ana	García Fuentes	GF14287	\N
440	Silvia Lucía	Argueta Rodríguez	AR14094	\N
441	María Ana	Zelaya Portillo	ZP14381	\N
442	Paola Jennifer	Villalobos Cruz	VC14883	\N
443	Sofía Valeria	Ramírez Reyes	RR14341	\N
444	Yesenia Fátima	Sánchez Zelaya	SZ14977	\N
445	Wendy Karla	Cruz Bonilla	CB15964	\N
446	Wendy Valeria	Pérez Bonilla	PB15242	\N
447	Rodrigo Edwin	Ramírez Quintanilla	RQ15149	\N
448	Rodrigo Andrés	Díaz Ayala	DA15978	\N
449	Karla Elena	Bonilla Chávez	BC15198	\N
450	Elena Valeria	Hernández Majano	HM15254	\N
451	Carlos Miguel	Martínez Ayala	MA15028	\N
452	Jorge Diego	Saravia Flores	SF15021	\N
453	Mónica María	González Romero	GR15526	\N
454	Mónica Lucía	Lazo Canales	LC15095	\N
455	Rafael José	López Alvarenga	LA15340	\N
456	Kevin José	Zelaya Ventura	ZV15015	\N
457	Marisol María	Saravia Umaña	SU15147	\N
458	Elena Gloria	Lazo Sánchez	LS15743	\N
459	José Bryan	Martínez Ramírez	MR15365	\N
460	Rafael Juan	Benítez Hernández	BH15056	\N
461	Francisco Daniel	Argueta Ramírez	AR15958	\N
462	David Óscar	Guevara Torres	GT15528	\N
463	Sofía Marisol	Sánchez Quintanilla	SQ15781	\N
464	Kevin Bryan	Alvarenga Orellana	AO15215	\N
465	Bryan Miguel	Portillo Amaya	PA15682	\N
466	Wendy Paola	Torres Martínez	TM15753	\N
467	María Elena	Fuentes Bonilla	FB15962	\N
468	Henry Bryan	García López	GL16676	\N
469	Emerson Juan	Canales Argueta	CA16879	\N
470	Marisol Sofía	Amaya Mejía	AM16790	\N
471	Wendy Paola	Ventura Bonilla	VB16263	\N
472	Óscar Emerson	Mejía Villalobos	MV16486	\N
473	Carolina Silvia	Ayala Hernández	AH16435	\N
474	Marisol Tatiana	Ayala Orellana	AO16639	\N
475	Alexander Rodrigo	González Umaña	GU16816	\N
476	Emerson Jorge	Umaña García	UG16966	\N
477	Patricia Sofía	López Villalobos	LV16350	\N
478	David Francisco	Rivera Martínez	RM16126	\N
479	Daniel José	Bonilla Martínez	BM16329	\N
480	Jorge Kevin	Portillo Amaya	PA16024	\N
481	Edwin Alexander	Benítez Bonilla	BB16438	\N
482	Bryan Henry	Zelaya Fuentes	ZF16218	\N
483	Yesenia Katherine	Orellana Zelaya	OZ16273	\N
484	Jorge Daniel	Argueta Ayala	AA16824	\N
485	Paola Alejandra	Zelaya Benítez	ZB16608	\N
486	David Rodrigo	Ramírez Argueta	RA16498	\N
487	Rodrigo José	Zelaya Granados	ZG16281	\N
488	Lucía Fátima	Portillo Umaña	PU16535	\N
489	Paola Sofía	Argueta Reyes	AR16329	\N
490	Luis Diego	Benítez Umaña	BU16486	\N
491	Francisco Julio	Villalobos Flores	VF16085	\N
492	Beatriz Patricia	Zelaya Flores	ZF16627	\N
493	Jennifer Ana	Ayala Mejía	AM17518	\N
494	Diego Gerson	Mejía Romero	MR17673	\N
495	David Daniel	Gómez González	GG17933	\N
496	Alejandra Rebeca	Hernández Canales	HC17402	\N
497	Miguel Daniel	Alvarenga Majano	AM17450	\N
498	Ana Gabriela	Amaya Fuentes	AF17481	\N
499	Marisol Yesenia	González Ventura	GV17200	\N
500	Óscar Fernando	Pérez Gómez	PG17907	\N
501	Walter Miguel	Rivera Bonilla	RB17402	\N
502	Daniel Wilfredo	Guevara Quintanilla	GQ17054	\N
503	Carlos Óscar	Ayala Amaya	AA17826	\N
504	Elena Beatriz	Romero Bonilla	RB17238	\N
505	Daniela Mónica	Pérez Sánchez	PS17358	\N
506	María Silvia	Sánchez Pérez	SP17689	\N
507	Wendy Beatriz	Cruz Amaya	CA17993	\N
508	Diego Julio	Bonilla López	BL17976	\N
509	Juan Fernando	Ramírez González	RG17682	\N
510	Luis Kevin	Chávez Mejía	CM17962	\N
511	Francisco Rodrigo	Sánchez Majano	SM18081	\N
512	Josué Daniel	Guevara Rodríguez	GR18624	\N
513	Valeria Lucía	González García	GG18857	\N
514	Juan Wilfredo	Alvarenga Hernández	AH18033	\N
515	Carlos Walter	Díaz Sánchez	DS18161	\N
516	Edwin Julio	Sánchez Rodríguez	SR18121	\N
517	Kevin Rafael	Rodríguez García	RG18192	\N
518	Valeria Alejandra	Majano Bonilla	MB18262	\N
519	Valeria Rebeca	Saravia González	SG18509	\N
520	Fernando Rafael	Romero Hernández	RH18684	\N
521	Miguel Óscar	Cruz Alvarenga	CA18805	\N
522	Mónica Rocío	Mejía Guevara	MG18843	\N
523	Patricia Sofía	Orellana Ventura	OV18192	\N
524	Kevin Josué	Portillo Chávez	PC18450	\N
525	Bryan Alexander	Benítez Ayala	BA18438	\N
526	Carlos Henry	Martínez Guevara	MG18207	\N
527	Fátima Alejandra	Chávez Canales	CC18464	\N
528	Rocío Patricia	Canales Reyes	CR18862	\N
529	Carlos Henry	Martínez Guevara	MG18024	\N
530	Óscar Alexander	Ventura Pérez	VP18654	\N
531	Karla Fátima	Reyes Argueta	RA18776	\N
532	Marisol Rocío	Mejía Chávez	MC18719	\N
533	Diego Ricardo	Díaz Hernández	DH18710	\N
534	Kevin Diego	Gómez Pérez	GP18639	\N
535	Carolina Fátima	Zelaya González	ZG18800	\N
536	Fátima Jennifer	Guevara Amaya	GA18166	\N
537	Mónica Lucía	Sánchez Lazo	SL18620	\N
538	Josué Rafael	Gómez Flores	GF18609	\N
539	Mónica Gabriela	Gómez Chávez	GC19916	\N
540	Juan Mario	Hernández Granados	HG19530	\N
541	Wilfredo Josué	Benítez Orellana	BO19708	\N
542	Alexander José	Argueta Ramírez	AR19458	\N
543	Andrea Patricia	Cruz Ventura	CV19430	\N
544	Daniela Lucía	Gómez López	GL19540	\N
545	Patricia Silvia	Sánchez Pérez	SP19944	\N
546	Rocío Silvia	Flores Majano	FM19807	\N
547	Luis Emerson	Pérez Sánchez	PS19574	\N
548	Wendy Mónica	Bonilla Martínez	BM19058	\N
549	Fernando Josué	Guevara Canales	GC19492	\N
550	Kevin Óscar	Ramírez Martínez	RM19514	\N
551	Patricia Lucía	Pérez Villalobos	PV19474	\N
552	Daniela Carolina	Villalobos Zelaya	VZ19380	\N
553	Wendy Patricia	Ayala Díaz	AD19839	\N
554	Daniel Henry	Amaya Díaz	AD19191	\N
555	Fátima Yesenia	Orellana Sánchez	OS19312	\N
556	Claudia Beatriz	Portillo Ramírez	PR19818	\N
557	Karla Yesenia	Majano Cruz	MC19220	\N
558	Claudia Mónica	Mejía Lazo	ML19145	\N
559	Andrea Gloria	Majano Lazo	ML19681	\N
560	David Gerson	Ventura Cruz	VC19973	\N
561	Sofía Mónica	Sánchez Saravia	SS19189	\N
562	Lucía Yesenia	Ventura Chávez	VC19734	\N
563	Gloria Elena	Sorto Sánchez	SS19375	\N
564	Rafael Rodrigo	Díaz Martínez	DM19862	\N
565	José Rafael	Sánchez Majano	SM19163	\N
566	Francisco David	Rivera Alvarenga	RA19055	\N
567	José Ricardo	Martínez Pérez	MP19924	\N
568	Elena Marisol	Mejía Ramírez	MR19436	\N
569	Gabriela Daniela	Bonilla Guevara	BG19797	\N
570	Daniela Paola	Granados Canales	GC19907	\N
571	Juan Fernando	Rodríguez Flores	RF19932	\N
572	Alejandra Fátima	Díaz Orellana	DO19460	\N
573	Silvia Ana	Sánchez Ayala	SA19830	\N
574	Francisco Henry	Canales Villalobos	CV19397	\N
575	Henry Walter	Majano Fuentes	MF19979	\N
576	Fátima Tatiana	Cruz Díaz	CD19828	\N
577	David Walter	Sánchez Granados	SG19609	\N
578	Lucía Gloria	Flores Alvarenga	FA19718	\N
579	Rodrigo Wilfredo	Rodríguez Ramírez	RR19576	\N
580	Josué Carlos	Torres Amaya	TA19500	\N
581	Sofía Lucía	Sorto Ayala	SA19161	\N
582	Fernando Henry	García Martínez	GM19633	\N
583	Elena Gabriela	Ventura Flores	VF19895	\N
584	Walter Francisco	Ramírez Portillo	RP19052	\N
585	Jorge Bryan	Sánchez Ventura	SV19630	\N
586	Kevin Mario	Benítez Saravia	BS19990	\N
587	Ana Alejandra	Lazo Canales	LC20647	\N
588	Andrés Bryan	Ayala Romero	AR20296	\N
589	Wilfredo David	Fuentes González	FG20381	\N
590	Carlos Wilfredo	Ayala Lazo	AL20193	\N
591	Alejandra Silvia	Pérez Umaña	PU20026	\N
592	José Carlos	Chávez Sánchez	CS20635	\N
593	Edwin Andrés	Rivera Villalobos	RV20588	\N
594	Claudia Ana	Reyes Sorto	RS20700	\N
595	Marisol Sofía	Amaya Mejía	AM20790	\N
596	Walter Mario	Díaz Sánchez	DS20929	\N
597	Óscar Emerson	Mejía Villalobos	MV20486	\N
598	Carolina Silvia	Ayala Hernández	AH20435	\N
599	Fernando Rafael	Martínez Orellana	MO20747	\N
600	Alejandra Ana	Alvarenga Díaz	AD20289	\N
601	Elena Sofía	Lazo Alvarenga	LA20935	\N
602	Alexander Gerson	Orellana Majano	OM20286	\N
603	Yesenia Fátima	Benítez Pérez	BP20373	\N
604	Jorge Luis	Zelaya Rivera	ZR20210	\N
605	Edwin José	Quintanilla Flores	QF20885	\N
606	Julio José	López Romero	LR20793	\N
607	Miguel Luis	Flores Pérez	FP20339	\N
608	Diego Miguel	Hernández Ventura	HV20990	\N
609	Lucía Marisol	Ayala Sorto	AS20549	\N
610	David Rodrigo	Ramírez Argueta	RA20498	\N
611	Carlos Kevin	Bonilla Canales	BC20486	\N
612	Rocío Tatiana	Portillo Umaña	PU20638	\N
613	Elena Rocío	Torres Bonilla	TB20219	\N
614	Carlos Mario	Torres Sorto	TS20601	\N
615	Patricia Beatriz	Rivera Canales	RC20995	\N
616	Daniela Gabriela	Chávez Zelaya	CZ20259	\N
617	Katherine María	Romero Quintanilla	RQ20700	\N
618	Carlos Miguel	Sorto Ayala	SA20994	\N
619	Wilfredo Alexander	Fuentes Umaña	FU20985	\N
620	Ricardo Gerson	Umaña González	UG20392	\N
621	Kevin José	Alvarenga Portillo	AP20786	\N
622	Marisol Gabriela	López Lazo	LL20451	\N
623	Julio Emerson	Cruz Ventura	CV20439	\N
624	Daniela Patricia	González Cruz	GC20236	\N
625	Henry Emerson	Lazo Sorto	LS20195	\N
626	Patricia Mónica	Umaña Portillo	UP20145	\N
627	Elena Jennifer	Amaya Flores	AF20592	\N
628	Daniela Valeria	Reyes Amaya	RA20746	\N
629	David Luis	Rodríguez Ventura	RV20452	\N
630	Lucía Silvia	Díaz Guevara	DG20946	\N
631	Josué Diego	Cruz Quintanilla	CQ20564	\N
632	Beatriz Gabriela	Amaya Chávez	AC20929	\N
633	Juan Óscar	Umaña Torres	UT20650	\N
634	Jennifer Lucía	Portillo Alvarenga	PA20315	\N
635	Emerson Juan	Díaz Portillo	DP21394	\N
636	Yesenia Rocío	Sánchez Benítez	SB21088	\N
637	Walter Rafael	Canales Cruz	CC21484	\N
638	Rocío Marisol	Quintanilla Flores	QF21465	\N
639	Yesenia Sofía	Majano Benítez	MB21227	\N
640	Diego Josué	Benítez Portillo	BP21589	\N
641	Emerson Alexander	Fuentes Benítez	FB21043	\N
642	Gerson Josué	López Portillo	LP21985	\N
643	Fernando Óscar	Amaya Bonilla	AB21012	\N
644	Alexander Gerson	Quintanilla Martínez	QM21747	\N
645	Andrea Karla	Sorto Lazo	SL21487	\N
646	Sofía Gabriela	Benítez Canales	BC21808	\N
647	Edwin Andrés	Rivera López	RL21968	\N
648	Wendy María	Granados Argueta	GA21086	\N
649	Valeria Gloria	Sorto Canales	SC21290	\N
650	Wilfredo Rafael	Saravia Rivera	SR21583	\N
651	Carlos Daniel	Chávez Ayala	CA21676	\N
652	Wilfredo Fernando	Bonilla Lazo	BL21122	\N
653	Carolina Jennifer	Martínez Ayala	MA21968	\N
654	Henry Diego	Guevara Cruz	GC21669	\N
655	Henry Bryan	Rivera Benítez	RB21949	\N
656	Rebeca Ana	Benítez Chávez	BC21267	\N
657	Óscar Mario	Fuentes Torres	FT21401	\N
658	José Carlos	Flores Cruz	FC21579	\N
659	Bryan Alexander	Fuentes Bonilla	FB21858	\N
660	Andrés Kevin	Benítez Reyes	BR21103	\N
661	Daniela Sofía	Reyes Rivera	RR21642	\N
662	Fernando José	Díaz Sánchez	DS21394	\N
\.


--
-- Data for Name: tbl_carrera; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_carrera (id_carrera, codigo, nombre, id_departamento) FROM stdin;
1	FMO-IA-006	Ingeniería Mecánica	7
2	FMO-CNM-007	Profesorado en Biología para Tercer Ciclo de Educación Básica y Educación Media	4
3	FMO-IA-005	Ingeniería Eléctrica	7
4	FMO-CNM-002	Licenciatura en Biología	4
5	FMO-JC-001	Licenciatura en Ciencias Jurídicas	3
6	FMO-MED-004	Licenciatura en Anestesiología e Inhaloterapia	1
7	FMO-CH-007	Profesorado en Idioma Inglés para Tercer Ciclo de Educación Básica y Educación Media	6
8	FMO-MED-003	Licenciatura en Laboratorio Clínico	1
9	FMO-MED-002	Licenciatura en Fisioterapia y Terapia Ocupacional	1
10	FMO-CNM-004	Licenciatura en Ciencias Químicas	4
11	FMO-QF-001	Licenciatura en Química y Farmacia	2
12	FMO-CE-001	Licenciatura en Economía	5
13	FMO-IA-003	Ingeniería de Sistemas Informáticos	7
14	FMO-CH-003	Licenciatura en Letras	6
15	FMO-CH-002	Licenciatura en Lenguas Modernas: Especialidad en Francés e Inglés	6
16	FMO-CH-006	Profesorado en Ciencias Sociales para Tercer Ciclo de Educación Básica y Educación Media	6
17	FMO-CH-004	Licenciatura en Psicología	6
18	FMO-MED-001	Doctorado en Medicina	1
19	FMO-CNM-006	Profesorado en Física para Tercer Ciclo de Educación Básica y Educación Media	4
20	FMO-CNM-008	Profesorado en Química para Tercer Ciclo de Educación Básica y Educación Media	4
21	FMO-IA-001	Ingeniería Industrial	7
22	FMO-CE-003	Licenciatura en Mercadeo Internacional	5
23	FMO-CE-002	Licenciatura en Administración de Empresas	5
24	FMO-CNM-001	Licenciatura en Matemática	4
25	FMO-IA-004	Arquitectura	7
26	FMO-CE-004	Licenciatura en Contaduría Pública	5
27	FMO-CH-001	Licenciatura en Sociología	6
28	FMO-CNM-005	Profesorado en Matemática para Tercer Ciclo de Educación Básica y Educación Media	4
29	FMO-IA-002	Ingeniería Civil	7
30	FMO-CE-005	Licenciatura en Logística Comercial Internacional	5
31	FMO-CH-005	Licenciatura en Educación Inicial y Parvularia	6
32	FMO-AG-001	Ingeniería Agronómica	8
33	FMO-CNM-003	Licenciatura en Física	4
\.


--
-- Data for Name: tbl_carrera_materia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_carrera_materia (id_carrera, id_materia, ciclo) FROM stdin;
32	760	2
29	760	3
1	4	1
1	2	1
1	348	1
1	999	1
1	388	1
1	10	2
1	1124	2
1	331	2
1	397	2
1	9	2
1	11	2
1	304	3
1	561	3
1	501	3
1	16	3
1	962	3
1	21	4
1	558	4
1	890	4
1	1114	4
1	836	4
1	22	4
1	23	4
1	737	5
1	1240	5
1	614	5
1	1135	5
1	1086	5
1	495	6
1	167	6
1	243	6
1	840	6
1	268	6
1	32	6
1	868	7
1	461	7
1	1021	7
1	303	7
1	347	7
1	238	8
1	708	8
1	221	8
1	749	8
1	1152	8
1	41	8
1	1221	9
1	499	9
1	409	9
1	374	9
1	1229	10
1	400	10
1	630	10
2	637	1
2	976	1
2	595	1
2	738	1
2	517	1
2	549	2
2	854	2
2	527	2
2	1266	2
2	1062	2
2	205	3
2	389	3
2	1045	3
2	572	3
2	417	3
2	263	4
2	995	4
2	1258	4
2	1291	4
2	627	4
2	1150	5
2	850	5
2	458	5
2	993	5
2	1034	6
2	464	6
2	642	6
2	1160	6
3	532	1
3	4	1
3	214	1
3	540	1
3	2	1
3	9	2
3	413	2
3	1053	2
3	348	2
3	10	2
3	11	2
3	16	3
3	818	3
3	561	3
3	1285	3
3	542	3
3	626	4
3	515	4
3	1009	4
3	836	4
3	450	4
3	22	4
3	23	4
3	970	5
3	1170	5
3	788	5
3	260	5
3	247	5
3	425	6
3	1082	6
3	978	6
3	392	6
3	684	6
3	32	6
3	415	7
3	1176	7
3	703	7
3	220	7
3	202	7
3	1130	8
3	190	8
3	863	8
3	543	8
3	613	8
3	41	8
3	462	9
3	547	9
3	1265	10
3	878	10
4	1039	1
4	1097	1
4	363	1
4	302	1
4	913	2
4	322	2
4	858	2
4	526	2
4	414	3
4	1263	3
4	513	3
4	701	3
4	1192	4
4	300	4
4	1065	4
4	1139	4
4	512	5
4	1186	5
4	925	5
4	565	5
4	311	6
4	596	6
4	904	6
4	1091	7
4	1216	7
4	1235	7
4	1090	8
4	826	8
4	632	8
4	326	9
4	1146	9
4	159	9
4	656	10
5	1226	1
5	694	1
5	1233	1
5	259	1
5	759	1
5	714	2
5	943	2
5	1182	2
5	895	2
5	382	2
5	845	3
5	885	3
5	395	3
5	1209	3
5	907	3
5	924	4
5	812	4
5	954	4
5	1040	4
5	659	4
5	539	5
5	989	5
5	621	5
5	1134	5
5	249	5
5	747	6
5	328	6
5	1261	6
5	329	6
5	619	6
5	1286	7
5	1227	7
5	1112	7
5	937	7
5	1006	7
5	1098	8
5	1247	8
5	335	8
5	914	8
5	443	8
5	964	9
5	823	9
5	909	9
5	887	9
5	1018	9
5	154	10
6	1020	1
6	302	1
6	1217	1
6	423	1
6	1049	1
6	875	2
6	921	2
6	1057	2
6	618	2
6	414	2
6	617	3
6	518	3
6	1108	3
6	1121	3
6	281	3
6	798	4
6	673	4
6	676	4
6	455	4
6	1122	4
6	255	5
6	170	5
6	438	5
6	313	5
6	245	5
6	585	6
6	969	6
6	478	6
6	879	6
6	1050	6
6	244	7
6	765	7
6	295	7
6	242	7
6	894	7
6	364	8
6	506	8
6	467	8
6	372	8
6	391	8
6	1079	9
6	901	9
6	325	9
6	427	9
6	1024	9
6	163	10
6	1153	10
6	861	10
6	223	10
6	682	10
7	633	1
7	229	1
7	933	1
7	494	1
7	1246	2
7	1288	2
7	665	2
7	681	2
7	1148	3
7	375	3
7	1129	3
7	758	3
7	522	3
7	917	4
7	1297	4
7	294	4
7	936	4
7	893	4
7	835	5
7	886	5
7	1194	5
7	1241	6
7	476	6
7	1048	6
7	940	6
8	460	1
8	563	1
8	1139	1
8	227	1
8	1299	1
8	332	2
8	1116	2
8	253	2
8	309	2
8	773	3
8	602	3
8	839	3
8	798	3
8	641	4
8	318	4
8	276	4
8	715	4
8	486	5
8	246	5
8	1256	5
8	196	5
8	411	6
8	1268	6
8	271	6
8	1105	6
8	699	7
8	1022	7
8	831	7
8	1044	8
8	928	8
8	314	8
8	712	8
8	849	9
8	1193	9
8	1273	9
8	250	10
8	373	10
8	381	10
9	1075	1
9	884	1
9	809	1
9	457	1
9	533	1
9	371	1
9	213	1
9	776	2
9	1178	2
9	1215	2
9	1202	2
9	612	2
9	405	2
9	288	2
9	321	3
9	856	3
9	168	3
9	279	3
9	1200	3
9	754	3
9	727	3
9	707	4
9	1231	4
9	1060	4
9	496	4
9	1095	4
9	1156	5
9	781	5
9	805	5
9	599	5
9	489	5
9	1296	5
9	553	5
9	702	6
9	662	6
9	1083	6
9	916	6
9	570	6
9	744	6
9	298	6
9	531	7
9	1284	7
9	251	7
9	977	7
9	503	7
9	906	7
9	1143	8
9	330	8
9	362	8
9	1037	8
9	1070	8
9	883	8
9	491	8
9	1081	9
9	706	9
9	611	9
9	195	9
9	529	10
9	287	10
9	1109	10
9	824	10
10	661	1
10	1243	1
10	1097	1
10	394	1
10	784	2
10	266	2
10	1115	2
10	616	2
10	1169	3
10	1220	3
10	257	3
10	1013	3
10	677	4
10	771	4
10	596	4
10	794	4
10	441	5
10	158	5
10	434	5
10	151	5
10	778	6
10	334	6
10	1030	6
10	1023	6
10	1120	7
10	790	7
10	1137	7
10	218	7
10	693	8
10	414	8
10	248	8
10	555	9
10	408	9
10	635	9
10	445	10
10	584	10
11	1056	1
11	401	1
11	653	1
11	1147	1
11	1005	2
11	908	2
11	484	2
11	1280	2
11	604	2
11	1004	3
11	152	3
11	787	3
11	837	3
11	174	4
11	366	4
11	679	4
11	1127	4
11	900	4
11	509	5
11	646	5
11	877	5
11	929	5
11	935	5
11	346	6
11	1208	6
11	1047	6
11	449	6
11	233	6
11	1275	7
11	232	7
11	469	7
11	1089	7
11	1157	8
11	983	8
11	802	8
11	853	9
11	1140	9
11	1283	9
11	857	9
11	763	10
11	589	10
11	510	10
11	1179	10
12	546	1
12	882	1
12	674	1
12	919	1
12	692	1
12	881	2
12	955	2
12	275	2
12	827	2
12	891	2
12	750	3
12	716	3
12	291	3
12	436	3
12	1073	3
12	1173	4
12	1138	4
12	615	4
12	736	4
12	709	4
12	1183	5
12	1032	5
12	187	5
12	1159	5
12	557	6
12	1080	6
12	225	6
12	668	6
12	286	7
12	210	7
12	982	7
12	524	7
12	525	8
12	454	8
12	212	8
13	5	1
13	4	1
13	1	1
13	2	1
13	3	1
13	6	2
13	10	2
13	7	2
13	8	2
13	9	2
13	11	2
13	12	3
13	14	3
13	15	3
13	16	3
13	13	3
13	19	4
13	21	4
13	18	4
13	17	4
13	20	4
13	22	4
13	23	4
13	27	5
13	26	5
13	24	5
13	25	5
13	31	6
13	30	6
13	28	6
13	29	6
13	32	6
13	34	7
13	35	7
13	33	7
13	36	7
13	39	8
13	37	8
13	38	8
13	40	8
13	41	8
13	43	9
13	44	9
13	45	9
13	42	9
13	49	10
13	50	10
13	46	10
13	47	10
13	48	10
14	466	1
14	339	1
14	864	1
14	1141	1
14	959	2
14	801	2
14	475	2
14	1242	2
14	396	3
14	442	3
14	473	3
14	1164	3
14	711	4
14	160	4
14	855	4
14	1038	4
14	437	5
14	829	5
14	234	5
14	289	5
14	206	6
14	209	6
14	1128	6
14	420	6
14	1158	7
14	199	7
14	870	7
14	843	7
14	1189	8
14	534	8
14	889	8
14	1099	8
14	497	9
14	671	9
14	939	9
14	186	9
14	191	10
14	732	10
14	770	10
14	761	10
15	587	1
15	274	1
15	581	1
15	1014	2
15	700	2
15	1175	2
15	607	3
15	1293	3
15	1008	3
15	762	4
15	994	4
15	472	4
15	888	5
15	1027	5
15	1185	5
15	267	6
15	688	6
15	317	6
15	1181	7
15	1031	7
15	774	7
15	432	8
29	11	2
15	718	8
15	965	8
15	429	9
15	1304	9
15	740	9
15	1094	10
15	713	10
15	814	10
16	1288	1
16	494	1
16	285	1
16	1016	1
16	933	1
16	665	2
16	1219	2
16	681	2
16	758	2
16	658	2
16	1267	3
16	376	3
16	1129	3
16	936	3
16	793	3
16	698	4
16	522	4
16	1191	4
16	660	4
16	256	4
16	886	5
16	216	5
16	670	5
16	1041	5
16	819	6
16	940	6
16	1092	6
16	562	6
17	262	1
17	160	1
17	545	1
17	500	1
17	1144	1
17	153	2
17	239	2
17	746	2
17	647	2
17	211	2
17	726	3
17	667	3
17	807	3
17	689	3
17	345	3
17	406	4
17	804	4
17	986	4
17	241	4
17	444	4
17	1271	5
17	1132	5
17	678	5
17	992	5
17	1059	5
17	1190	6
17	1117	6
17	594	6
17	817	6
17	403	6
17	1068	7
17	1278	7
17	733	7
17	324	7
17	280	8
17	640	8
17	410	8
17	675	9
17	1002	10
17	859	10
18	748	1
18	1279	1
18	569	1
18	384	1
18	1015	2
18	1204	2
18	235	2
18	739	2
18	721	3
18	1224	3
18	208	3
18	1069	3
18	480	4
18	768	4
18	520	4
18	428	4
18	301	5
18	841	5
18	421	5
18	590	5
18	838	6
18	511	6
18	1188	6
18	431	6
18	504	7
18	628	7
18	228	7
18	481	7
18	756	8
18	606	8
18	162	8
18	897	8
18	1072	9
18	871	9
18	966	9
18	860	9
18	342	9
18	579	10
18	624	10
18	912	10
18	1197	10
18	1167	11
18	559	11
18	942	11
18	350	11
18	1064	12
18	1087	12
18	185	12
18	1145	12
18	588	13
18	156	13
18	580	13
18	1262	13
18	385	13
18	980	13
19	595	1
19	637	1
19	1180	1
19	631	1
19	976	1
19	282	2
19	738	2
19	204	2
19	629	2
19	741	2
19	389	3
19	816	3
19	811	3
19	404	3
19	205	3
19	995	4
19	731	4
19	1258	4
19	263	4
19	527	4
19	1269	5
19	850	5
19	207	5
19	634	5
19	663	6
19	390	6
19	464	6
20	637	1
20	738	1
20	517	1
20	976	1
20	786	1
20	282	2
20	973	2
20	1187	2
20	741	2
20	789	2
20	389	3
20	998	3
20	705	3
20	471	3
20	205	3
20	1258	4
20	173	4
20	527	4
20	1084	4
20	995	4
20	850	5
20	1126	5
20	821	5
20	974	5
20	369	6
20	464	6
20	575	6
21	1000	1
21	950	1
21	182	1
21	201	1
21	591	1
21	402	2
21	1212	2
21	164	2
21	797	2
21	310	2
21	717	3
21	1055	3
21	777	3
21	825	3
21	990	3
21	299	4
21	1067	4
21	477	4
21	725	4
21	751	4
21	852	5
21	846	5
21	447	5
21	772	5
21	426	5
21	292	6
21	1093	6
21	775	6
21	724	6
21	1118	6
21	552	7
21	666	7
21	418	7
21	452	7
21	710	7
21	808	8
21	922	8
21	1218	8
21	548	8
21	230	8
21	356	9
21	769	9
21	697	9
21	687	10
21	465	10
21	911	10
22	919	1
22	692	1
22	1159	1
22	436	1
22	546	1
22	876	2
22	955	2
22	881	2
22	827	2
22	1026	2
22	941	3
22	716	3
22	882	3
22	419	3
22	783	3
22	275	4
22	891	4
22	297	4
22	505	4
22	291	4
22	1125	5
22	672	5
22	753	5
22	377	5
22	265	5
22	240	6
22	1251	6
22	338	6
22	1245	6
22	960	7
22	343	7
22	734	7
22	680	7
22	686	8
22	284	8
22	166	8
22	231	8
22	979	9
22	574	9
22	806	9
22	171	9
22	379	10
22	1276	10
23	692	1
23	436	1
23	919	1
23	674	1
23	546	1
23	955	2
23	827	2
23	275	2
23	876	2
23	881	2
23	750	3
23	716	3
23	1073	3
23	1173	3
23	1159	3
23	1026	4
23	988	4
23	1138	4
23	291	4
23	1149	4
23	896	5
23	882	5
23	419	5
23	1052	5
23	639	6
23	891	6
23	951	6
23	378	6
23	722	7
23	1163	7
23	1205	7
23	593	7
23	946	8
23	554	8
23	1184	8
23	931	8
23	1255	9
23	454	9
23	1244	9
23	1282	10
23	1074	10
23	297	10
24	1097	1
24	1131	1
24	1232	1
24	1222	2
24	723	2
24	848	2
24	319	2
24	273	3
24	254	3
24	847	3
24	1010	3
24	365	4
24	380	4
24	368	4
24	264	4
24	1007	5
24	1225	5
24	1290	5
24	953	5
24	813	6
24	903	6
24	487	6
24	188	6
24	1234	7
24	498	7
24	568	7
24	757	7
24	341	8
24	1107	8
24	194	8
24	1196	9
24	1207	9
24	176	10
25	1248	1
25	474	1
25	407	1
25	4	1
25	359	2
25	9	2
25	180	2
25	652	2
25	198	2
25	11	2
25	1302	3
25	340	3
25	192	3
25	355	3
25	1036	3
25	1301	3
25	620	4
25	578	4
25	938	4
25	796	4
25	766	4
25	650	4
25	22	4
25	23	4
25	869	5
25	1260	5
25	446	5
25	463	5
25	947	5
25	1161	5
25	493	6
25	1035	6
25	1043	6
25	956	6
25	283	6
25	1100	6
25	32	6
25	1103	7
25	1210	7
25	508	7
25	1203	7
25	767	8
25	1166	8
25	272	8
25	41	8
25	399	9
25	514	9
25	792	9
25	1113	10
25	1162	10
25	764	10
26	692	1
26	919	1
26	674	1
26	546	1
26	436	1
26	881	2
26	275	2
26	955	2
26	876	2
26	827	2
26	1073	3
26	716	3
26	1159	3
26	1173	3
26	750	3
26	1138	4
26	291	4
26	1026	4
26	1149	4
26	988	4
26	882	5
26	419	5
26	657	5
26	896	5
26	891	6
26	378	6
26	169	6
26	1106	6
26	454	7
26	752	7
26	1298	7
26	927	7
26	832	8
26	544	8
26	1282	8
26	1012	8
26	704	9
26	200	9
26	435	9
26	923	10
26	573	10
26	323	10
27	1066	1
27	610	1
27	237	1
27	1051	1
27	538	2
27	643	2
27	308	2
27	932	2
27	915	3
27	1033	3
27	780	3
27	307	3
27	370	4
27	184	4
27	320	4
27	934	4
27	601	5
27	867	5
27	1253	5
27	453	5
27	755	6
27	1111	6
27	1259	6
27	799	6
27	327	7
27	958	7
27	608	7
27	598	7
27	583	8
27	535	8
27	828	8
27	1165	8
27	1174	9
27	603	9
27	730	9
27	1236	9
27	971	10
27	566	10
27	226	10
27	349	10
28	215	1
28	696	1
28	976	1
28	685	1
28	637	1
28	952	2
28	1201	2
28	1266	2
28	282	2
28	1017	2
28	389	3
28	205	3
28	844	3
28	1019	3
28	1102	3
28	948	4
28	527	4
28	995	4
28	177	4
28	263	4
28	850	5
28	873	5
28	1258	5
28	523	5
28	464	6
28	564	6
28	197	6
28	290	6
29	4	1
29	2	1
29	1206	1
29	945	1
29	217	1
29	9	2
29	1104	2
29	1133	2
29	348	2
29	10	2
29	561	3
29	818	3
29	638	3
29	962	3
29	16	3
29	1071	4
29	277	4
29	836	4
29	450	4
29	22	4
29	23	4
29	622	5
29	649	5
29	260	5
29	179	5
29	862	5
29	605	6
29	981	6
29	810	6
29	820	6
29	1142	6
29	32	6
29	1237	7
29	996	7
29	892	7
29	834	7
29	358	8
29	719	8
29	866	8
29	1172	8
29	41	8
29	1277	9
29	360	9
29	357	10
29	393	10
29	1223	10
30	352	1
30	1292	1
30	1063	1
30	172	1
30	842	2
30	987	2
30	865	2
30	1096	2
30	315	3
30	874	3
30	830	3
30	550	3
30	782	4
30	571	4
30	516	4
30	944	4
30	488	5
30	337	5
30	1076	5
30	957	5
30	597	6
30	1077	6
30	1250	6
30	485	7
30	470	7
30	1046	7
30	293	8
30	1061	8
30	918	8
30	963	9
30	1287	9
30	155	9
30	1230	9
30	742	10
30	930	10
30	592	10
30	551	10
31	189	1
31	354	1
31	351	1
31	440	1
31	483	1
31	175	2
31	803	2
31	779	2
31	609	2
31	636	2
31	577	3
31	412	3
31	157	3
31	537	3
31	236	3
31	416	4
31	1054	4
31	1249	4
31	822	4
31	1003	4
31	1025	5
31	1264	5
31	1101	5
31	507	5
31	655	5
31	336	6
31	448	6
31	795	6
31	728	6
31	519	6
31	1085	7
31	745	7
31	224	7
31	530	7
31	398	8
31	586	8
31	669	8
31	1168	8
31	720	9
31	691	9
31	1177	9
31	690	9
31	305	10
31	1058	10
31	576	10
31	451	10
32	972	1
32	1119	1
32	479	1
32	899	1
32	644	1
32	361	2
32	367	2
32	270	2
32	556	2
32	815	2
32	1195	3
32	905	3
32	664	3
32	920	3
32	902	3
32	1123	4
32	1281	4
32	1254	4
32	482	4
32	833	4
32	1011	5
32	785	5
32	743	5
32	985	5
32	695	5
32	791	6
32	219	6
32	541	6
32	625	6
32	926	7
32	1198	7
32	1171	7
32	1028	7
32	386	8
32	536	8
32	1155	8
32	654	8
32	1001	9
32	1136	9
32	1289	9
32	1300	9
32	459	10
32	1257	10
32	258	10
32	800	10
32	193	10
33	302	1
33	1097	1
33	278	1
33	784	1
33	188	2
33	949	2
33	257	2
33	648	2
33	1238	3
33	316	3
33	757	3
33	1294	3
33	735	4
33	341	4
33	910	4
33	439	4
33	1272	4
33	1274	5
33	872	5
33	312	5
33	178	5
33	975	5
33	968	6
33	252	6
33	1211	6
33	645	6
33	492	7
33	851	7
33	1154	7
33	433	7
33	222	8
33	961	8
33	984	8
33	333	8
33	1146	9
33	656	10
\.


--
-- Data for Name: tbl_departamento; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_departamento (id_departamento, nombre, descripcion) FROM stdin;
1	Departamento de Medicina	Facultad Multidisciplinaria Oriental - Universidad de El Salvador
2	Departamento de Química y Farmacia	Facultad Multidisciplinaria Oriental - Universidad de El Salvador
3	Departamento de Jurisprudencia y Ciencias Sociales	Facultad Multidisciplinaria Oriental - Universidad de El Salvador
4	Departamento de Ciencias Naturales y Matemática	Facultad Multidisciplinaria Oriental - Universidad de El Salvador
5	Departamento de Ciencias Económicas	Facultad Multidisciplinaria Oriental - Universidad de El Salvador
6	Departamento de Ciencias y Humanidades	Facultad Multidisciplinaria Oriental - Universidad de El Salvador
7	Departamento de Ingeniería y Arquitectura	Facultad Multidisciplinaria Oriental - Universidad de El Salvador
8	Departamento de Ciencias Agronómicas	Facultad Multidisciplinaria Oriental - Universidad de El Salvador
\.


--
-- Data for Name: tbl_docente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_docente (id_docente, id_usuario, codigo_docente, id_departamento) FROM stdin;
1	4	DOC-001	1
2	5	DOC-002	1
3	6	DOC-003	2
4	7	DOC-004	2
5	8	DOC-005	3
6	9	DOC-006	3
7	10	DOC-007	4
8	11	DOC-008	4
9	12	DOC-009	5
10	13	DOC-010	5
11	14	DOC-011	6
12	15	DOC-012	6
13	16	DOC-013	7
14	17	DOC-014	7
15	18	DOC-015	8
16	19	DOC-016	8
17	24	DOC-017	1
18	25	DOC-018	1
19	26	DOC-019	1
20	27	DOC-020	2
21	28	DOC-021	2
22	29	DOC-022	2
23	30	DOC-023	3
24	31	DOC-024	3
25	32	DOC-025	3
26	33	DOC-026	4
27	34	DOC-027	4
28	35	DOC-028	4
29	36	DOC-029	5
30	37	DOC-030	5
31	38	DOC-031	5
32	39	DOC-032	6
33	40	DOC-033	6
34	41	DOC-034	6
35	42	DOC-035	7
36	43	DOC-036	7
37	44	DOC-037	7
38	45	DOC-038	8
39	46	DOC-039	8
40	47	DOC-040	8
\.


--
-- Data for Name: tbl_entrega; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_entrega (id_entrega, id_proyecto, id_usuario_envia, id_usuario_revisa, fecha_envio, estado_entrega, fecha_revision, datos_propuestos) FROM stdin;
5	4	48	21	2019-11-23 06:12:27.49384	aprobada	2019-12-07 06:40:58.126001	\N
21	17	61	21	2020-08-09 00:41:07.976645	aprobada	2020-08-16 02:34:46.323324	\N
46	37	80	21	2021-04-22 20:58:42.622983	rechazada	2021-05-03 02:33:18.957483	\N
22	18	62	23	2020-06-25 14:51:27.624935	aprobada	2020-07-04 23:54:38.958888	\N
6	5	49	22	2019-05-26 06:15:16.446794	con_correcciones	2019-05-28 22:20:14.748788	\N
7	5	49	21	2019-06-04 09:54:57.263884	aprobada	2019-06-07 03:54:50.636777	\N
69	54	58	23	2021-09-06 13:28:28.983904	aprobada	2021-09-17 06:27:50.364798	\N
8	6	50	22	2019-08-22 13:30:05.28599	aprobada	2019-08-25 07:57:46.625682	\N
65	52	93	22	2021-07-20 06:27:01.281505	con_correcciones	2021-07-30 04:05:51.634928	\N
23	19	63	21	2020-03-29 09:27:20.582369	aprobada	2020-04-03 23:39:29.920147	\N
9	7	51	23	2019-08-10 20:03:08.938318	aprobada	2019-08-16 03:17:28.27708	\N
35	29	73	23	2020-07-17 06:24:07.591005	con_correcciones	2020-07-29 15:51:12.942546	\N
36	29	73	23	2020-08-09 02:23:59.307777	aprobada	2020-08-19 08:17:57.688359	\N
24	20	64	22	2020-10-25 22:53:32.524231	aprobada	2020-11-06 15:12:38.851819	\N
10	8	52	21	2019-05-01 05:29:38.590797	aprobada	2019-05-06 09:09:28.923692	\N
11	9	53	22	2019-05-17 17:40:26.860285	aprobada	2019-06-01 17:29:57.173297	\N
47	38	81	21	2021-07-09 05:54:11.257637	aprobada	2021-07-22 12:09:02.627355	\N
12	10	54	21	2019-12-08 08:35:42.464199	aprobada	2019-12-10 17:37:46.803312	\N
25	21	65	21	2020-11-24 12:08:24.146858	aprobada	2020-11-26 14:56:24.46931	\N
13	11	55	22	2019-04-16 09:56:40.10946	aprobada	2019-04-20 16:05:25.436972	\N
37	30	59	23	2020-04-14 01:51:33.363523	aprobada	2020-04-18 11:02:39.730017	\N
26	22	66	23	2020-04-03 07:19:55.059736	aprobada	2020-04-14 09:09:40.396765	\N
55	45	87	21	2021-11-03 18:49:18.663465	con_correcciones	2021-11-10 08:22:16.998078	\N
56	45	87	23	2021-11-20 03:33:03.361813	aprobada	2021-11-26 17:45:35.709212	\N
14	12	56	23	2019-03-05 08:31:28.112614	con_correcciones	2019-03-14 01:33:39.464355	\N
15	12	56	22	2019-03-17 05:01:04.845457	aprobada	2019-04-01 02:10:25.190582	\N
27	23	67	21	2020-08-23 16:34:41.037665	aprobada	2020-09-03 02:35:08.371803	\N
48	39	82	22	2021-03-21 15:15:48.374278	aprobada	2021-03-27 22:36:42.729687	\N
16	13	57	22	2019-05-14 07:45:18.514068	aprobada	2019-05-18 11:21:39.852891	\N
28	24	68	22	2020-05-06 15:41:11.674071	rechazada	2020-05-17 13:58:23.011585	\N
17	14	58	22	2019-11-30 00:48:42.780161	aprobada	2019-12-02 07:01:37.090162	\N
66	52	93	21	2021-08-10 06:45:29.089453	aprobada	2021-08-19 09:35:21.469704	\N
29	25	69	22	2020-10-02 21:23:36.313528	aprobada	2020-10-17 06:42:03.649504	\N
38	31	74	23	2020-11-02 12:48:17.389775	con_correcciones	2020-11-11 00:40:38.734732	\N
39	31	74	23	2020-11-16 03:52:24.116077	aprobada	2020-11-21 13:02:47.460311	\N
18	15	59	23	2019-09-04 19:52:04.392613	con_correcciones	2019-09-09 04:10:23.71064	\N
19	15	59	23	2019-09-12 22:52:41.075224	aprobada	2019-09-21 11:01:54.40471	\N
49	40	83	21	2021-04-28 23:00:36.341193	aprobada	2021-05-07 01:59:49.709648	\N
20	16	60	21	2020-10-13 05:16:27.004032	aprobada	2020-10-19 08:48:44.347491	\N
40	32	75	23	2020-08-05 05:54:49.754748	aprobada	2020-08-08 23:04:34.080082	\N
30	26	70	23	2020-06-15 22:07:17.27547	con_correcciones	2020-06-24 09:03:10.607753	\N
31	26	70	23	2020-07-07 00:25:26.013808	aprobada	2020-07-17 15:11:37.388574	\N
75	59	99	21	2021-10-15 14:18:18.204223	aprobada	2021-10-22 19:35:34.586691	\N
57	46	88	22	2021-02-20 09:30:33.333592	aprobada	2021-03-05 08:12:25.664535	\N
50	41	84	23	2021-10-12 20:37:30.412356	aprobada	2021-10-18 19:23:30.762739	\N
32	27	71	21	2020-08-31 02:15:16.041305	aprobada	2020-09-13 17:46:02.403906	\N
41	33	76	23	2020-10-21 14:46:24.659428	con_correcciones	2020-11-05 04:48:32.977093	\N
42	33	76	23	2020-11-14 07:42:08.311423	rechazada	2020-11-17 11:08:33.644049	\N
33	28	72	21	2020-08-24 03:25:42.021823	con_correcciones	2020-08-31 04:11:17.34728	\N
34	28	72	23	2020-09-14 07:58:22.683674	aprobada	2020-09-19 05:42:12.010221	\N
62	50	91	21	2021-08-03 08:01:12.950139	con_correcciones	2021-08-14 05:28:12.299076	\N
58	47	89	22	2021-05-26 15:29:24.329904	aprobada	2021-06-09 15:35:37.68947	\N
43	34	77	23	2020-04-01 02:44:54.993699	aprobada	2020-04-15 12:06:02.344847	\N
51	42	85	22	2021-08-20 09:58:24.059398	con_correcciones	2021-09-03 08:49:22.380601	\N
52	42	85	23	2021-09-16 04:56:26.747997	rechazada	2021-09-23 19:42:24.080699	\N
44	35	78	23	2021-07-16 02:22:49.999608	aprobada	2021-07-28 03:27:19.337362	\N
63	50	91	23	2021-08-28 03:04:26.717088	aprobada	2021-09-07 22:36:56.100146	\N
45	36	79	21	2021-04-27 05:30:44.973427	rechazada	2021-05-02 12:06:24.29515	\N
53	43	86	22	2021-08-27 07:54:00.379051	aprobada	2021-08-31 05:05:55.713632	\N
59	48	90	22	2021-07-02 01:20:51.381296	rechazada	2021-07-15 22:34:33.733071	\N
54	44	65	22	2021-12-07 03:31:15.034979	aprobada	2021-12-10 16:51:16.361236	\N
70	55	95	21	2021-08-28 21:15:15.038777	aprobada	2021-09-09 00:25:05.439165	\N
78	62	61	21	2022-03-27 13:57:47.773411	con_correcciones	2022-04-07 18:13:21.138813	\N
64	51	92	21	2021-08-19 03:43:45.810107	aprobada	2021-08-25 05:18:03.221511	\N
79	62	61	21	2022-04-13 09:08:19.521473	aprobada	2022-04-23 02:39:55.900763	\N
76	60	100	22	2021-10-09 10:50:28.96663	rechazada	2021-10-21 07:16:42.344029	\N
67	53	94	21	2021-05-19 09:19:27.156896	con_correcciones	2021-05-25 09:34:53.521303	\N
60	49	71	23	2021-06-15 05:11:34.080312	con_correcciones	2021-06-18 20:46:28.448821	\N
61	49	71	22	2021-07-02 07:38:42.855781	aprobada	2021-07-05 08:56:29.264041	\N
71	56	96	21	2021-08-26 07:39:03.13098	aprobada	2021-08-31 13:16:03.519281	\N
68	53	94	21	2021-06-03 00:34:01.923617	aprobada	2021-06-14 05:32:20.295154	\N
73	58	98	21	2021-06-04 16:20:32.306807	con_correcciones	2021-06-08 15:56:42.672152	\N
74	58	98	21	2021-06-16 05:55:48.062506	aprobada	2021-06-30 22:59:10.482122	\N
72	57	97	23	2021-05-28 15:17:30.181522	aprobada	2021-06-04 06:02:05.562588	\N
82	64	103	23	2022-04-04 11:47:40.4974	aprobada	2022-04-17 08:27:09.858741	\N
77	61	101	22	2022-06-03 06:31:28.675793	aprobada	2022-06-11 15:24:42.044065	\N
80	63	102	22	2022-04-02 19:42:56.605094	aprobada	2022-04-10 17:25:05.031221	\N
81	64	103	23	2022-03-16 22:56:04.746277	con_correcciones	2022-03-21 04:42:52.099402	\N
84	65	81	23	2022-07-15 05:14:43.276322	aprobada	2022-07-25 00:58:03.654438	\N
83	65	81	21	2022-07-05 17:46:50.546879	con_correcciones	2022-07-11 15:12:26.898593	\N
85	66	104	21	2022-05-11 22:31:26.324044	aprobada	2022-05-17 02:43:42.689721	\N
86	67	105	22	2022-03-27 03:21:48.365765	aprobada	2022-04-03 17:20:43.762174	\N
87	68	106	21	2022-11-27 18:59:17.424206	aprobada	2022-12-10 23:31:28.798674	\N
88	69	107	22	2022-07-24 14:04:28.10801	aprobada	2022-08-08 01:36:18.461146	\N
89	70	51	23	2022-08-19 10:20:07.116826	aprobada	2022-08-22 16:12:26.467087	\N
93	72	109	23	2022-10-28 07:21:34.868345	aprobada	2022-11-02 10:32:19.168717	\N
91	71	108	22	2022-10-16 20:34:38.704726	aprobada	2022-10-30 02:29:52.98596	\N
90	71	108	23	2022-09-30 11:19:09.081503	con_correcciones	2022-10-07 03:48:45.38884	\N
94	73	110	23	2022-05-27 18:08:34.739319	aprobada	2022-05-30 08:47:03.03974	\N
233	189	129	\N	2026-11-21 02:50:27.333942	pendiente	\N	\N
92	72	109	21	2022-10-05 11:15:40.25802	con_correcciones	2022-10-19 15:51:16.55025	\N
95	74	110	23	2022-04-05 23:41:35.310522	aprobada	2022-04-19 14:02:40.597537	\N
269	218	233	23	2021-05-21 21:02:43.548142	aprobada	2021-05-28 03:50:56.927844	\N
236	192	156	21	2026-07-01 06:27:50.63215	con_correcciones	2026-07-05 09:08:36.940513	\N
159	128	158	22	2024-03-20 11:51:24.20424	con_correcciones	2024-03-26 04:52:18.572599	\N
200	162	184	23	2025-08-24 14:41:07.731759	con_correcciones	2025-09-06 11:20:52.052302	\N
201	162	184	23	2025-09-21 04:23:22.38772	aprobada	2025-09-29 10:11:49.733459	\N
164	132	161	21	2024-04-11 05:00:49.209083	con_correcciones	2024-04-21 05:31:40.55426	\N
338	273	277	23	2024-07-04 08:45:17.801208	aprobada	2024-07-18 04:22:54.167504	\N
271	220	234	21	2021-08-24 11:08:11.898629	aprobada	2021-09-02 07:53:56.249633	\N
166	133	162	21	2024-09-24 14:04:37.982672	aprobada	2024-10-01 12:12:47.375034	\N
244	198	214	22	2026-09-22 16:47:01.541647	con_correcciones	2026-10-01 14:30:06.85912	\N
202	163	185	21	2025-07-18 03:28:03.378001	aprobada	2025-07-30 10:56:02.73905	\N
168	135	164	23	2024-05-07 20:19:08.182154	aprobada	2024-05-21 20:19:20.594799	\N
205	166	188	23	2025-07-19 21:12:16.208369	aprobada	2025-07-30 23:35:05.639773	\N
169	136	165	22	2024-07-04 21:42:10.257551	aprobada	2024-07-15 15:49:24.635645	\N
170	137	166	22	2024-06-04 09:09:41.596409	aprobada	2024-06-16 05:45:42.935731	\N
246	199	136	23	2026-08-14 11:33:36.831918	aprobada	2026-08-25 02:41:50.17126	\N
273	221	235	21	2021-08-15 13:26:16.545862	aprobada	2021-08-28 20:02:18.883689	\N
171	138	167	21	2025-05-30 22:16:18.266998	aprobada	2025-06-13 13:18:47.613999	\N
206	167	189	21	2025-04-01 03:10:30.323196	con_correcciones	2025-04-03 13:56:15.659045	\N
247	200	215	23	2026-11-21 04:31:55.760165	con_correcciones	2026-11-22 10:02:38.059004	\N
172	139	168	23	2025-05-06 18:43:27.250555	con_correcciones	2025-05-21 13:33:57.587357	\N
208	168	190	21	2025-03-22 03:42:44.641749	aprobada	2025-03-29 22:38:45.008753	\N
175	140	139	21	2025-07-29 13:52:25.31125	aprobada	2025-08-07 12:42:27.643379	\N
248	201	216	\N	2026-11-22 02:47:28.346744	pendiente	\N	\N
209	169	191	21	2025-06-18 03:31:49.649231	rechazada	2025-06-27 12:07:18.984195	\N
180	144	171	21	2025-02-20 03:31:26.940954	aprobada	2025-02-25 12:35:11.306156	\N
275	223	236	22	2021-06-26 11:33:13.488322	aprobada	2021-07-06 12:57:02.794844	\N
210	170	192	23	2025-04-25 16:03:27.280352	aprobada	2025-05-03 01:11:27.627575	\N
182	146	173	23	2025-07-19 11:33:45.876298	aprobada	2025-07-27 04:54:35.215558	\N
339	274	278	21	2025-05-23 18:53:25.810479	aprobada	2025-05-28 16:29:56.181684	\N
183	147	174	22	2025-07-02 20:18:34.828552	aprobada	2025-07-05 09:04:40.190411	\N
215	174	196	23	2025-10-26 02:31:51.789741	aprobada	2025-10-28 18:29:17.128587	\N
249	202	217	22	2026-06-26 16:43:15.669105	con_correcciones	2026-07-07 17:23:42.014308	\N
186	150	128	21	2025-10-05 14:18:18.773214	con_correcciones	2025-10-16 22:02:10.127	\N
331	267	272	23	2024-04-23 20:01:25.236263	aprobada	2024-05-05 18:49:59.606345	\N
350	283	285	21	2025-07-10 13:04:10.863118	aprobada	2025-07-12 21:16:09.221273	\N
188	151	68	23	2025-10-05 06:01:08.509174	con_correcciones	2025-10-12 09:49:41.821489	\N
251	203	218	21	2026-10-11 19:10:02.334941	aprobada	2026-10-14 04:56:45.701047	\N
345	278	281	23	2025-05-18 20:21:25.731853	aprobada	2025-05-30 03:51:05.105252	\N
191	153	178	23	2025-05-25 21:09:25.869552	aprobada	2025-06-08 12:56:16.223162	\N
220	179	201	21	2026-06-05 00:40:47.60319	con_correcciones	2026-06-10 20:37:27.908545	\N
221	179	201	23	2026-06-17 22:51:59.246045	aprobada	2026-06-30 04:18:02.580108	\N
192	154	179	21	2025-04-02 21:30:55.918236	aprobada	2025-04-16 18:56:16.256506	\N
332	268	273	23	2024-09-11 07:56:52.254624	aprobada	2024-09-25 11:04:19.624328	\N
223	180	83	21	2026-11-19 13:11:52.889939	con_correcciones	2026-11-20 19:54:31.237743	\N
197	159	130	23	2025-04-14 01:53:55.163071	aprobada	2025-04-18 11:05:01.558601	\N
252	204	219	21	2026-04-28 11:40:15.334293	aprobada	2026-05-03 07:45:33.668809	\N
224	181	122	23	2026-09-06 17:00:14.551198	aprobada	2026-09-15 10:32:01.902932	\N
333	269	274	23	2024-09-07 15:14:59.290209	aprobada	2024-09-20 19:35:52.672317	\N
225	182	202	22	2026-11-20 23:00:38.235065	con_correcciones	2026-11-21 08:28:03.585564	\N
340	275	224	22	2025-09-08 11:00:24.514811	aprobada	2025-09-21 02:08:07.896909	\N
253	205	220	22	2026-10-25 01:37:06.289426	aprobada	2026-10-27 03:49:05.619738	\N
226	183	203	21	2026-11-20 20:16:02.918121	con_correcciones	2026-11-21 05:46:09.260348	\N
231	188	151	21	2026-07-07 18:00:34.953754	aprobada	2026-07-16 01:58:01.302617	\N
261	212	227	21	2020-07-02 16:47:36.343915	aprobada	2020-07-13 17:47:54.696992	\N
263	213	228	23	2020-11-01 16:24:33.189016	con_correcciones	2020-11-04 21:38:24.591882	\N
362	292	294	21	2025-05-08 14:55:45.197425	con_correcciones	2025-05-19 02:25:49.506362	\N
265	215	230	23	2020-06-04 09:22:08.990435	aprobada	2020-06-11 08:50:38.345833	\N
334	270	275	21	2024-02-16 03:46:42.993669	con_correcciones	2024-03-01 15:24:08.336887	\N
335	270	275	23	2024-03-03 22:50:00.683726	aprobada	2024-03-13 20:33:33.05422	\N
267	217	232	22	2021-07-11 04:39:48.926934	aprobada	2021-07-20 22:00:21.261743	\N
346	279	282	22	2025-06-14 19:36:15.772093	aprobada	2025-06-17 01:12:28.131824	\N
363	292	294	21	2025-05-29 05:50:35.836683	aprobada	2025-06-10 13:08:45.174143	\N
336	271	257	23	2024-11-08 15:30:16.713484	aprobada	2024-11-14 12:07:10.083526	\N
351	284	286	21	2025-05-03 13:26:17.907199	aprobada	2025-05-14 04:00:14.276679	\N
337	272	276	22	2024-07-07 19:13:54.759753	aprobada	2024-07-13 21:20:48.125558	\N
347	280	283	21	2025-04-17 11:34:32.780517	aprobada	2025-04-20 07:18:18.162203	\N
341	276	279	21	2025-09-29 14:47:45.540503	con_correcciones	2025-10-08 13:18:58.872487	\N
342	276	279	23	2025-10-13 00:06:45.242253	aprobada	2025-10-25 13:04:15.624174	\N
352	285	287	21	2025-03-30 19:06:41.935529	aprobada	2025-04-13 01:47:51.281127	\N
348	281	240	21	2025-11-10 00:40:09.824017	aprobada	2025-11-21 18:58:26.185757	\N
343	277	280	21	2025-04-22 06:07:44.285104	con_correcciones	2025-05-06 23:27:37.651713	\N
344	277	280	23	2025-05-21 21:03:51.017623	aprobada	2025-05-28 03:52:04.39852	\N
354	287	289	22	2025-09-24 20:44:09.650857	con_correcciones	2025-10-05 03:09:19.999913	\N
355	287	289	23	2025-10-08 19:04:48.364922	aprobada	2025-10-21 01:10:15.732181	\N
349	282	284	23	2025-10-21 10:13:29.844519	aprobada	2025-11-05 04:01:44.220581	\N
361	291	293	22	2025-04-19 11:36:19.607911	con_correcciones	2025-05-02 18:21:41.91308	\N
353	286	288	22	2025-11-24 12:51:56.601117	aprobada	2025-11-28 21:53:51.990108	\N
357	289	291	21	2025-05-30 05:34:59.506826	con_correcciones	2025-06-13 20:27:52.814413	\N
356	288	290	22	2025-05-24 05:35:09.451774	aprobada	2025-05-30 03:12:07.820313	\N
358	289	291	21	2025-06-22 03:08:03.144684	aprobada	2025-06-25 21:03:05.468077	\N
359	290	292	23	2025-08-05 21:39:03.033292	con_correcciones	2025-08-10 15:54:16.342037	\N
360	290	292	23	2025-08-16 14:23:13.667719	aprobada	2025-08-24 16:49:05.013065	\N
367	294	296	\N	2026-11-22 15:03:08.290534	pendiente	\N	\N
365	293	295	23	2026-04-05 06:21:21.407237	aprobada	2026-04-20 00:15:20.747651	\N
364	293	295	23	2026-03-21 22:48:51.768738	con_correcciones	2026-04-01 16:41:53.079675	\N
366	294	296	21	2026-11-17 05:57:24.651361	con_correcciones	2026-11-20 01:54:49.956124	\N
368	295	297	23	2026-11-20 15:59:09.600281	con_correcciones	2026-11-21 09:32:54.923288	\N
369	296	298	22	2026-09-01 04:16:30.221532	aprobada	2026-09-04 19:01:47.554335	\N
370	297	255	\N	2026-11-22 08:08:45.180104	pendiente	\N	\N
371	298	299	21	2026-11-20 08:28:22.495697	con_correcciones	2026-11-21 20:21:35.800741	\N
372	299	300	21	2026-11-20 04:23:26.086515	con_correcciones	2026-11-21 09:07:41.407163	\N
373	300	301	21	2026-11-18 07:58:49.69521	con_correcciones	2026-11-20 20:58:28.013329	\N
374	300	301	\N	2026-11-21 23:11:39.348305	pendiente	\N	\N
375	301	302	23	2026-11-18 11:49:03.647498	con_correcciones	2026-11-19 13:01:49.960769	\N
377	302	303	23	2026-09-01 07:01:10.601473	aprobada	2026-09-14 21:04:43.938018	\N
96	75	111	23	2022-03-15 00:47:40.145248	aprobada	2022-03-21 10:55:14.446516	\N
97	76	112	21	2022-07-09 11:00:38.011701	aprobada	2022-07-11 14:19:04.346691	\N
118	94	129	23	2023-06-19 22:20:05.257719	aprobada	2023-07-01 21:34:51.636461	\N
98	77	113	21	2022-08-20 21:35:52.941613	aprobada	2022-08-29 12:21:13.278764	\N
99	78	114	22	2022-03-29 02:37:30.887451	aprobada	2022-04-09 05:30:29.220824	\N
176	141	169	22	2025-09-12 20:12:30.273366	aprobada	2025-09-22 07:14:17.638637	\N
100	79	115	22	2022-03-17 15:24:06.844222	aprobada	2022-03-23 08:25:35.193613	\N
119	95	130	21	2023-09-26 14:21:51.962013	con_correcciones	2023-10-03 00:54:05.319373	\N
120	95	130	22	2023-10-10 07:08:27.696448	aprobada	2023-10-13 21:16:21.063649	\N
101	80	100	23	2022-09-01 21:58:46.802575	aprobada	2022-09-07 10:07:14.124673	\N
156	126	156	23	2024-08-04 10:32:59.365624	con_correcciones	2024-08-08 01:49:14.708519	\N
136	109	143	23	2024-09-04 15:18:58.946538	con_correcciones	2024-09-12 17:44:22.25048	\N
121	96	131	23	2023-05-30 18:00:32.390653	aprobada	2023-06-14 01:31:20.745534	\N
137	109	143	21	2024-09-25 20:15:09.604322	aprobada	2024-10-02 19:06:27.956325	\N
102	81	116	22	2023-08-24 14:18:30.729963	con_correcciones	2023-09-03 07:39:07.052252	\N
103	81	116	22	2023-09-09 12:16:41.411611	aprobada	2023-09-24 02:55:49.758738	\N
160	128	158	21	2024-04-07 18:28:22.955909	aprobada	2024-04-17 05:04:48.315829	\N
104	82	117	21	2023-03-28 14:35:45.350772	aprobada	2023-04-05 06:32:38.6881	\N
140	111	145	21	2024-10-13 00:30:46.024339	aprobada	2024-10-25 19:27:22.342195	\N
105	83	118	21	2023-11-15 22:35:46.32854	aprobada	2023-11-18 18:50:58.6808	\N
122	97	132	23	2023-05-29 02:02:39.053929	con_correcciones	2023-06-10 19:54:17.383613	\N
123	97	132	23	2023-06-22 06:19:26.748078	aprobada	2023-06-27 04:13:57.128489	\N
106	84	119	22	2023-10-19 11:21:08.348793	aprobada	2023-10-30 06:18:12.700487	\N
199	161	155	21	2025-10-17 22:21:43.831697	aprobada	2025-10-30 05:07:06.153069	\N
158	127	157	21	2024-04-21 06:05:20.151789	aprobada	2024-04-28 01:11:22.519085	\N
194	156	181	21	2025-06-02 06:15:12.965051	aprobada	2025-06-11 04:22:22.34146	\N
107	85	120	21	2023-04-01 09:32:08.323151	aprobada	2023-04-05 06:49:23.65035	\N
161	129	133	21	2024-08-24 09:41:44.048595	aprobada	2024-09-02 08:57:28.417863	\N
108	86	121	21	2023-12-01 09:11:02.264778	aprobada	2023-12-03 17:26:41.585449	\N
141	112	123	21	2024-07-03 13:32:34.981855	con_correcciones	2024-07-17 19:44:51.353573	\N
109	87	122	22	2023-07-29 09:56:34.169288	aprobada	2023-08-11 21:09:09.490168	\N
124	98	133	22	2023-07-09 00:58:30.832042	con_correcciones	2023-07-20 01:15:13.233064	\N
125	98	133	21	2023-07-29 15:37:27.666543	aprobada	2023-07-31 18:39:59.06118	\N
110	88	123	23	2023-09-29 22:08:49.790761	aprobada	2023-10-05 10:39:30.097898	\N
111	89	124	21	2023-08-03 01:36:01.399225	aprobada	2023-08-05 22:09:28.732759	\N
185	149	176	21	2025-11-04 06:05:56.803444	aprobada	2025-11-08 03:06:19.135203	\N
177	142	143	21	2025-03-05 22:54:10.282683	aprobada	2025-03-13 10:38:45.661942	\N
126	99	134	23	2023-03-08 10:19:13.410007	aprobada	2023-03-19 09:50:49.825189	\N
162	130	159	21	2024-08-07 10:18:09.771789	rechazada	2024-08-17 22:54:32.134087	\N
112	90	125	23	2023-05-13 07:12:39.34142	con_correcciones	2023-05-16 09:01:44.662062	\N
113	90	125	22	2023-05-22 17:47:09.994881	rechazada	2023-05-29 10:52:15.288865	\N
127	100	135	23	2023-06-30 05:49:13.535732	aprobada	2023-07-06 21:55:47.934227	\N
114	91	126	22	2023-06-07 22:53:00.596872	aprobada	2023-06-17 05:28:17.93582	\N
146	116	124	23	2024-05-13 08:22:39.76164	aprobada	2024-05-21 22:12:05.102307	\N
115	92	127	21	2023-06-30 13:43:49.281541	aprobada	2023-07-04 18:21:19.664098	\N
128	101	136	23	2023-04-01 20:38:46.262713	aprobada	2023-04-03 22:54:14.651589	\N
129	102	137	22	2024-05-13 10:54:58.29451	aprobada	2024-05-15 20:00:53.641707	\N
147	117	53	21	2024-03-25 14:36:26.754713	aprobada	2024-04-07 19:40:49.120138	\N
116	93	128	22	2023-09-19 03:27:19.377397	con_correcciones	2023-09-30 01:55:02.753144	\N
117	93	128	23	2023-10-12 18:43:53.153139	aprobada	2023-10-26 18:44:05.541131	\N
130	103	138	22	2024-08-12 04:08:21.240532	aprobada	2024-08-18 15:13:01.592754	\N
131	104	139	23	2024-08-19 04:41:40.19961	aprobada	2024-08-27 10:27:11.505163	\N
163	131	160	22	2024-04-02 07:05:50.467214	aprobada	2024-04-05 16:24:53.861827	\N
132	105	140	23	2024-07-17 22:22:29.799454	aprobada	2024-07-26 15:58:34.136658	\N
148	118	149	22	2024-09-24 02:59:37.80986	aprobada	2024-09-29 06:56:56.175583	\N
133	106	141	22	2024-11-16 04:25:28.736063	aprobada	2024-11-20 11:36:11.071446	\N
134	107	142	22	2024-03-29 01:01:34.71129	aprobada	2024-04-04 12:04:56.048418	\N
178	143	170	23	2025-10-22 22:08:10.26789	aprobada	2025-11-05 02:05:56.631318	\N
135	108	104	22	2024-06-05 23:11:44.348237	rechazada	2024-06-19 13:26:44.65212	\N
150	120	151	21	2024-10-28 06:04:14.960206	aprobada	2024-11-10 21:32:58.348279	\N
165	132	161	23	2024-04-24 20:11:02.967843	aprobada	2024-04-27 19:45:29.318413	\N
152	122	153	22	2024-09-20 11:37:41.500765	aprobada	2024-10-05 08:31:08.870472	\N
207	167	189	23	2025-04-05 19:15:35.007497	aprobada	2025-04-15 14:11:07.340605	\N
187	150	128	21	2025-10-22 20:08:42.507032	aprobada	2025-11-03 16:54:19.865937	\N
167	134	163	22	2024-11-12 21:40:41.057974	aprobada	2024-11-18 08:41:30.461353	\N
153	123	154	23	2024-04-19 18:47:49.640075	aprobada	2024-04-26 18:16:19.005209	\N
155	125	155	23	2024-06-13 16:37:11.644369	con_correcciones	2024-06-16 22:22:08.00907	\N
173	139	168	23	2025-05-24 20:26:53.934263	con_correcciones	2025-06-01 04:26:11.265774	\N
195	157	112	22	2025-07-25 12:02:47.030581	aprobada	2025-08-05 01:35:18.409168	\N
189	151	68	22	2025-10-15 00:13:10.19818	con_correcciones	2025-10-26 21:32:14.532607	\N
179	144	171	23	2025-02-05 09:59:10.24998	con_correcciones	2025-02-12 08:42:16.580911	\N
174	140	139	21	2025-07-18 21:48:10.593485	con_correcciones	2025-07-25 20:22:51.935708	\N
213	172	194	22	2025-03-21 00:03:50.255117	rechazada	2025-04-03 23:46:47.563602	\N
203	164	186	23	2025-09-10 09:24:52.354145	aprobada	2025-09-15 18:46:59.684474	\N
181	145	172	23	2025-10-23 21:45:48.233041	aprobada	2025-10-30 21:23:33.578573	\N
190	152	177	23	2025-11-14 18:29:33.860697	aprobada	2025-11-17 08:45:54.233062	\N
184	148	175	21	2025-04-13 00:31:59.864704	aprobada	2025-04-26 23:57:06.200813	\N
196	158	182	22	2025-08-29 11:33:05.093157	aprobada	2025-09-09 08:24:25.477837	\N
193	155	180	21	2025-06-15 06:35:37.880731	aprobada	2025-06-20 19:28:11.231078	\N
212	172	194	23	2025-03-04 12:02:37.59221	con_correcciones	2025-03-08 02:41:59.910617	\N
211	171	193	21	2025-08-03 05:05:21.942469	aprobada	2025-08-09 03:16:37.289272	\N
198	160	183	22	2025-06-08 15:31:29.209648	aprobada	2025-06-18 08:52:01.52988	\N
216	175	197	\N	2026-11-22 03:43:56.724639	pendiente	\N	\N
204	165	187	22	2025-04-05 19:52:49.26146	aprobada	2025-04-09 13:20:49.587427	\N
219	178	200	\N	2026-11-21 19:00:41.281019	pendiente	\N	\N
217	176	198	23	2026-11-20 13:02:08.036359	con_correcciones	2026-11-22 10:36:39.347041	\N
214	173	195	23	2025-09-14 12:08:13.864117	aprobada	2025-09-27 01:06:36.186321	\N
218	177	199	22	2026-11-19 23:01:37.645657	con_correcciones	2026-11-21 11:12:55.981928	\N
222	180	83	21	2026-11-16 00:59:59.218826	con_correcciones	2026-11-18 19:22:01.539988	\N
227	184	204	23	2026-05-28 11:07:11.578109	aprobada	2026-05-30 15:01:31.919169	\N
228	185	205	\N	2026-11-22 07:32:56.249189	pendiente	\N	\N
229	186	206	23	2026-04-07 00:07:26.605777	aprobada	2026-04-13 06:17:55.956571	\N
230	187	207	22	2026-07-17 04:48:04.255202	aprobada	2026-07-26 23:55:04.626428	\N
237	192	156	21	2026-07-08 07:32:43.286208	aprobada	2026-07-14 07:36:32.670107	\N
255	206	221	22	2019-03-12 19:00:23.327902	aprobada	2019-03-20 16:54:00.332224	\N
256	207	222	23	2019-09-19 15:36:24.387132	aprobada	2019-09-29 06:54:54.779934	\N
257	208	223	23	2020-06-24 18:29:11.509955	aprobada	2020-06-27 18:11:49.889542	\N
258	209	224	21	2020-06-08 15:37:26.234581	aprobada	2020-06-20 15:05:53.630626	\N
259	210	225	22	2020-08-17 10:13:53.297914	aprobada	2020-08-19 19:19:09.680051	\N
260	211	226	23	2020-06-02 13:29:51.349377	aprobada	2020-06-11 01:34:24.7174	\N
138	110	144	21	2024-03-07 04:40:23.261771	aprobada	2024-03-16 14:19:54.622688	\N
232	189	129	21	2026-11-17 02:31:20.615673	con_correcciones	2026-11-18 07:23:48.939397	\N
234	190	90	\N	2026-11-20 17:22:30.673394	pendiente	\N	\N
139	111	145	21	2024-09-26 04:27:47.308895	con_correcciones	2024-09-30 20:14:36.657677	\N
309	249	257	22	2023-06-05 13:07:19.725842	aprobada	2023-06-17 13:38:05.079112	\N
290	235	246	22	2022-04-29 23:18:30.364049	aprobada	2022-05-07 08:40:55.752355	\N
235	191	208	22	2026-11-19 03:05:07.010721	con_correcciones	2026-11-21 04:57:49.334564	\N
142	112	123	21	2024-07-30 21:26:02.72772	aprobada	2024-08-12 00:26:10.078751	\N
238	193	209	\N	2026-11-21 09:16:34.998017	pendiente	\N	\N
143	113	146	23	2024-07-30 03:01:58.7298	aprobada	2024-08-02 06:27:46.159905	\N
262	213	228	22	2020-10-12 04:20:52.288574	con_correcciones	2020-10-21 09:49:35.608793	\N
239	194	210	23	2026-11-20 00:46:50.316049	con_correcciones	2026-11-21 07:57:46.63877	\N
144	114	147	23	2024-09-29 08:18:37.815957	aprobada	2024-10-04 13:18:35.164585	\N
240	195	211	\N	2026-11-20 20:54:15.936625	pendiente	\N	\N
145	115	148	21	2024-08-20 16:46:43.801735	aprobada	2024-09-02 14:44:48.126203	\N
241	196	212	\N	2026-11-21 15:50:37.273565	pendiente	\N	\N
281	227	240	23	2021-05-28 06:57:46.565213	aprobada	2021-06-01 08:51:34.914568	\N
149	119	150	23	2024-08-17 20:33:17.848493	aprobada	2024-08-25 16:06:17.247232	\N
280	227	240	22	2021-05-18 08:45:11.911962	con_correcciones	2021-05-25 10:24:19.227215	\N
264	214	229	23	2020-04-10 18:55:03.901396	aprobada	2020-04-14 12:50:43.36596	\N
151	121	152	21	2024-05-14 06:53:08.717728	aprobada	2024-05-25 09:59:24.139512	\N
243	197	213	\N	2026-11-21 20:42:53.223486	pendiente	\N	\N
242	197	213	22	2026-11-18 07:55:16.581762	con_correcciones	2026-11-20 01:33:27.888472	\N
154	124	92	23	2024-04-07 09:56:44.6477	aprobada	2024-04-15 22:41:45.981728	\N
245	198	214	23	2026-10-10 20:15:48.204653	aprobada	2026-10-18 04:22:06.534744	\N
157	126	156	22	2024-08-19 09:16:46.11849	aprobada	2024-08-28 16:14:07.4667	\N
266	216	231	21	2020-10-25 02:41:49.936219	aprobada	2020-10-30 01:05:53.296294	\N
250	202	217	22	2026-07-15 06:31:09.371065	aprobada	2026-07-21 17:57:40.717648	\N
306	246	255	22	2023-04-06 23:23:19.000766	aprobada	2023-04-19 21:39:59.339618	\N
254	205	220	\N	2026-10-29 13:42:37.939713	pendiente	\N	{"anio": 2026, "titulo": "Movimiento amortiguado de un sistema masa-resorte", "autores": [{"carnet": "OA21134", "nombres": "Daniel José", "apellidos": "Orellana Ayala"}, {"carnet": "CQ21109", "nombres": "Alejandra Paola", "apellidos": "Canales Quintanilla"}, {"carnet": "FL21520", "nombres": "Silvia Mónica", "apellidos": "Flores Lazo"}], "resumen": "Proyecto desarrollado en la asignatura Mecánica Clásica, con el tema «Movimiento amortiguado de un sistema masa-resorte». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de oscilaciones, amortiguamiento y mecánica. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores. Esta versión incorpora las observaciones del jurado y amplía la sección de resultados.", "idCarrera": 33, "idMateria": 178, "idTematica": 36, "palabrasClave": ["oscilaciones", "amortiguamiento", "mecánica", "versión revisada"], "idTipoProyecto": 4, "idDocentesAsesores": []}
305	246	255	22	2023-03-23 08:07:54.28206	con_correcciones	2023-03-25 14:52:18.635866	\N
282	228	241	21	2021-10-15 07:39:20.592027	aprobada	2021-10-30 01:37:12.023471	\N
268	218	233	21	2021-04-22 06:06:36.871404	con_correcciones	2021-05-06 23:26:30.180811	\N
296	239	250	21	2022-06-30 14:05:34.470767	con_correcciones	2022-07-13 10:05:05.810544	\N
270	219	234	21	2021-05-07 10:09:15.275388	rechazada	2021-05-17 02:57:41.595607	\N
297	239	250	23	2022-07-22 12:33:44.181578	aprobada	2022-08-03 23:01:15.516113	\N
272	221	235	23	2021-08-04 16:33:41.914404	con_correcciones	2021-08-09 10:28:08.214158	\N
302	243	253	21	2023-06-01 06:29:55.508294	aprobada	2023-06-09 05:23:15.862688	\N
291	236	247	23	2022-10-20 05:10:29.097327	con_correcciones	2022-10-25 22:44:18.482654	\N
274	222	236	22	2021-11-23 22:35:44.516119	aprobada	2021-12-05 10:33:28.847595	\N
283	229	242	23	2021-03-07 15:35:21.772573	con_correcciones	2021-03-18 09:18:26.125287	\N
284	229	242	23	2021-03-30 09:38:18.507555	aprobada	2021-04-05 10:14:20.880215	\N
276	224	237	23	2021-05-20 16:24:24.08331	aprobada	2021-05-27 16:24:20.43135	\N
292	236	247	21	2022-11-05 17:39:17.881228	aprobada	2022-11-19 19:59:08.295941	\N
301	243	253	23	2023-05-18 00:46:48.817903	con_correcciones	2023-05-25 15:45:20.14979	\N
285	230	231	23	2021-04-04 21:36:10.213395	aprobada	2021-04-11 16:15:44.605196	\N
298	240	251	23	2023-05-02 16:57:50.800545	aprobada	2023-05-13 10:32:59.139458	\N
277	225	238	22	2021-08-22 18:46:15.722735	con_correcciones	2021-09-02 02:51:34.037312	\N
278	225	238	22	2021-09-14 23:28:44.366628	aprobada	2021-09-19 19:16:42.717793	\N
286	231	243	23	2022-08-30 20:28:35.318943	aprobada	2022-09-11 09:54:20.707738	\N
279	226	239	22	2021-06-21 15:27:23.298391	aprobada	2021-06-30 06:49:07.606325	\N
299	241	252	21	2023-06-23 09:39:53.743487	aprobada	2023-06-27 17:40:00.079447	\N
287	232	244	21	2022-03-08 09:42:31.377769	aprobada	2022-03-18 19:39:37.781365	\N
293	237	248	23	2022-06-16 21:34:43.665465	con_correcciones	2022-06-24 09:25:02.042661	\N
294	237	248	21	2022-06-29 23:49:05.422615	aprobada	2022-07-07 03:41:52.804301	\N
288	233	245	22	2022-05-24 01:14:17.507287	aprobada	2022-06-07 16:10:11.913195	\N
303	244	254	21	2023-07-16 01:33:16.504915	aprobada	2023-07-18 11:47:57.887895	\N
289	234	242	23	2022-10-09 06:06:34.633495	aprobada	2022-10-19 13:05:33.00932	\N
295	238	249	23	2022-02-26 05:32:53.452918	aprobada	2022-02-28 10:50:35.818512	\N
300	242	226	22	2023-11-03 17:27:34.752845	aprobada	2023-11-09 15:13:09.138108	\N
307	247	222	22	2023-08-10 07:50:35.667569	aprobada	2023-08-16 10:20:50.042104	\N
304	245	238	23	2023-08-10 13:34:19.574491	aprobada	2023-08-12 23:41:39.947283	\N
310	250	258	22	2023-04-30 06:53:42.736278	aprobada	2023-05-05 21:05:52.087566	\N
308	248	256	22	2023-08-12 18:14:29.679107	aprobada	2023-08-17 11:51:56.049973	\N
311	251	259	21	2023-11-28 15:38:39.416847	aprobada	2023-12-11 22:33:55.804817	\N
313	253	261	23	2024-03-08 06:50:39.151392	aprobada	2024-03-11 17:15:30.534537	\N
312	252	260	23	2023-10-25 10:56:51.136828	aprobada	2023-11-05 12:10:19.496715	\N
317	256	225	21	2024-05-04 18:50:33.840772	aprobada	2024-05-06 22:36:53.252599	\N
314	254	262	22	2024-10-13 12:06:25.19386	aprobada	2024-10-24 06:00:26.576878	\N
318	257	264	22	2024-03-11 09:19:47.019601	aprobada	2024-03-23 15:24:17.433855	\N
315	255	263	23	2024-03-12 13:16:23.610962	con_correcciones	2024-03-19 17:04:56.992752	\N
316	255	263	23	2024-03-22 07:28:25.409395	aprobada	2024-04-03 04:47:29.804344	\N
321	259	266	21	2024-06-24 07:41:17.293843	aprobada	2024-07-04 06:10:40.655913	\N
320	258	265	22	2024-05-05 14:37:41.909715	aprobada	2024-05-14 01:33:35.279308	\N
319	258	265	21	2024-04-28 03:00:32.144799	con_correcciones	2024-05-01 14:48:46.512777	\N
322	260	267	22	2024-07-23 16:49:43.631526	rechazada	2024-08-04 16:58:31.972566	\N
323	261	268	21	2024-09-09 01:43:00.300296	aprobada	2024-09-13 17:46:42.675333	\N
325	262	253	23	2024-09-16 16:29:21.047655	aprobada	2024-09-21 14:13:10.412699	\N
324	262	253	21	2024-08-26 11:56:40.332388	con_correcciones	2024-09-02 12:42:15.683365	\N
326	263	227	21	2024-11-12 05:42:12.04642	aprobada	2024-11-18 02:04:15.416888	\N
327	264	269	22	2024-06-22 05:26:37.741439	aprobada	2024-06-27 22:14:44.096364	\N
329	265	270	21	2024-07-31 13:16:11.473158	aprobada	2024-08-13 22:06:00.841133	\N
328	265	270	23	2024-07-21 20:23:38.770128	con_correcciones	2024-07-28 04:27:23.110738	\N
330	266	271	22	2024-09-21 08:14:45.154224	aprobada	2024-09-23 20:53:04.542014	\N
376	301	302	\N	2026-11-21 13:03:59.296276	pendiente	\N	\N
378	303	304	21	2026-05-28 04:12:34.606846	aprobada	2026-06-11 12:39:18.989963	\N
379	304	305	22	2026-07-15 01:46:54.313046	aprobada	2026-07-22 15:58:36.692972	\N
\.


--
-- Data for Name: tbl_etiquetas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_etiquetas (id_etiqueta, nombre) FROM stdin;
4	huerto escolar
5	didáctica
6	biología
7	genética
8	juegos didácticos
9	educación media
10	estimulación temprana
11	síndrome de down
12	terapia ocupacional
13	fotocatálisis
14	colorantes
15	cinética química
16	chatbot
17	procesamiento de lenguaje natural
18	atención estudiantil
19	roque dalton
20	poesía
21	crítica social
22	traducción
23	turismo
24	francés
25	historia local
26	enseñanza
27	centros escolares
28	manual de puestos
29	organización
30	empresa familiar
31	parque lineal
32	paisajismo
33	espacio público
34	control interno
35	coso
36	cooperativa
37	fracciones
38	resolución de problemas
39	tercer ciclo
40	hidráulica
41	diseño
42	taller
43	variador de frecuencia
44	motor trifásico
45	control
46	sedación
47	dexmedetomidina
48	cuidados intensivos
49	accidente cerebrovascular
50	rehabilitación
51	neurología
52	inflación
53	canasta básica
54	precios
55	aplicación móvil
56	geolocalización
57	participación ciudadana
58	base de datos
59	inventario
60	modelo relacional
61	ciberseguridad
62	vulnerabilidades
63	owasp
64	educación cívica
65	participación juvenil
66	ciudadanía
67	experimentos
68	cinemática
69	bajo costo
70	tabla periódica
71	juegos
72	aprendizaje
73	actitudes
74	química
75	talento humano
76	diagnóstico
77	sector público
78	métodos numéricos
79	método de newton
80	sistemas no lineales
81	material manipulativo
82	geometría
83	mecánica de suelos
84	capacidad de carga
85	puente
86	aduanas
87	exportación
88	trámites
89	indicadores
90	kpi
91	cadena de suministro
92	control biológico
93	mosca blanca
94	tomate
95	material didáctico
96	célula
97	cultivo in vitro
98	orquídeas
99	conservación
100	aedes aegypti
101	temperatura
102	entomología
103	derecho laboral
104	maternidad
105	despido
106	anestesia raquídea
107	cesárea
108	complicaciones
109	vía aérea
110	obesidad
111	intubación
112	control de calidad
113	química clínica
114	reglas de westgard
115	interacciones
116	polifarmacia
117	farmacia clínica
118	café
119	regresión
120	precios internacionales
121	programación orientada a objetos
122	biblioteca
123	escritorio
124	ortografía
125	redacción
126	bachillerato
127	secuencia didáctica
128	independencia
129	historia
130	diabetes
131	factores de riesgo
132	atención primaria
133	péndulo
134	sensores
135	laboratorio
136	seguridad
137	laboratorio escolar
138	manual
139	ácido-base
140	experimento
141	enlace químico
142	planificación
143	ecuaciones diferenciales
144	epidemiología
145	modelación
146	levantamiento
147	patrimonio
148	dibujo arquitectónico
149	auditoría
150	inventarios
151	ferretería
152	violencia de género
153	universidad
154	percepciones
155	ansiedad matemática
156	pavimento
157	evaluación
158	carreteras
159	rincones de aprendizaje
160	materiales
161	aula
162	deshidratado
163	mango
164	agroindustria
165	constante de planck
166	led
167	física moderna
168	educación ambiental
169	encuesta
170	calidad de energía
171	armónicos
172	distribución
176	cuota alimenticia
177	derecho de familia
178	juzgados
187	biodiésel
188	transesterificación
189	reciclaje
190	pectina
191	extracción
192	residuos agrícolas
173	prueba pericial
174	proceso penal
175	peritaje
179	derecho mercantil
180	sociedades
181	emprendimiento
182	enseñanza basada en tareas
183	unidad didáctica
184	inglés
185	postura
186	escolares
193	cafeína
194	cromatografía
195	bebidas
196	sábila
197	gel
198	formulación
199	redes
200	cableado estructurado
201	vlan
202	fonética
203	interferencia lingüística
204	interpretación
205	inglés y francés
206	ansiedad
207	depresión
208	adulto mayor
209	seguridad ocupacional
210	riesgos
211	gestión
212	agua potable
213	diseño hidráulico
214	comunidad rural
215	incoterms
216	importación
217	contratos internacionales
218	frijol
219	variedades
220	rendimiento
221	caos
222	péndulo doble
223	simulación
224	energía solar
225	secado de granos
226	diseño mecánico
227	energía fotovoltaica
228	factibilidad
229	protecciones
230	subestación
231	cortocircuito
232	bioindicadores
233	calidad del agua
234	macroinvertebrados
235	datos personales
236	privacidad
237	derechos humanos
238	pronunciación
239	canciones
240	inclusión
241	baja visión
242	guayaba
243	extracto vegetal
244	actividad antibacteriana
245	gestión de citas
246	aplicación web
247	clínica
248	internet de las cosas
249	riego
250	claudia lars
251	narrativa
252	literatura salvadoreña
253	aprendizaje en línea
254	plataformas
255	pragmática
256	cortesía
257	escala de glasgow
258	trauma craneoencefálico
259	emergencia
260	estudio de tiempos
261	estandarización
262	lácteos
263	comercio electrónico
264	consumidor
265	cadenas de markov
266	probabilidad
267	rendimiento estudiantil
268	centro histórico
269	revitalización
270	contabilidad de costos
271	órdenes de producción
272	carpintería
273	asociatividad
274	mujeres
275	artesanía
276	diseño estructural
277	concreto reforzado
278	vivienda
279	transferencia de calor
280	intercambiador
281	prácticas de laboratorio
282	guía
283	energía eólica
284	recurso eólico
285	la unión
286	murciélagos
287	manglar
288	biodiversidad
289	flora
290	morazán
291	anestesia pediátrica
292	monitoreo
293	protocolo
294	expresión oral
295	grupos sanguíneos
296	banco de sangre
297	inmunohematología
298	lumbalgia
299	ejercicio terapéutico
300	ergonomía
301	metales pesados
302	absorción atómica
303	agua
304	uso racional
305	antibióticos
306	farmacia comunitaria
307	disolución
308	paracetamol
309	empleo informal
310	mercado laboral
311	econometría
312	redes neuronales
313	visión por computadora
314	roya del café
315	ciencia de datos
316	rendimiento académico
317	visualización
318	sociolingüística
319	habla popular
320	dialectología
321	hábitos de lectura
322	universitarios
323	duelo
324	migración
325	intervención
326	evaluación psicológica
327	inteligencia
328	niños
329	apendicitis
330	embarazo
331	cirugía
332	óptica
333	guía didáctica
334	energía
335	transformaciones
336	prácticas
337	cocina
338	química cotidiana
339	tratado de libre comercio
340	corea
341	agroexportación
342	planeación estratégica
343	foda
344	plan de negocios
345	alimentos saludables
346	demostraciones
347	álgebra
348	mercado municipal
349	diseño arquitectónico
350	accesibilidad
351	discapacidad
352	edificios
353	juventud
354	estados unidos
355	geogebra
356	funciones
357	tecnología educativa
358	ecuaciones
359	concreto
360	agregado reciclado
361	resistencia
362	juego libre
363	desarrollo social
364	primera infancia
365	lenguaje oral
366	cuentos
367	parvularia
368	psicomotricidad fina
369	vibraciones
370	mantenimiento predictivo
371	motores
372	mantenimiento preventivo
373	flota vehicular
374	consumo eléctrico
375	parasitosis
376	coproparasitología
377	urocultivo
378	infección urinaria
379	resistencia antimicrobiana
380	e. coli
381	antibiograma
382	lesiones deportivas
383	fútbol
384	prevención
385	remesas
386	consumo
387	hogares
388	bitcoin
389	comercio
390	política monetaria
391	balanza comercial
392	comercio exterior
393	centroamérica
394	salarrué
395	cuento
396	antología
397	glosario
398	terminología
399	memoria histórica
400	conflicto armado
401	mapas digitales
402	geografía
403	estrés académico
404	salud mental
405	dengue
406	pediatría
407	enfermedad renal crónica
408	adherencia
409	bajo lempa
410	concepciones alternativas
411	gravedad
412	manufactura esbelta
413	desperdicios
414	panadería
415	pronósticos
416	demanda
417	control estadístico
418	calidad
419	gráficos de control
420	café de especialidad
421	canadá
422	marca
423	artesanías
424	guatajiagua
425	investigación de mercado
426	segmentación
427	cafetería
428	mercadeo digital
429	redes sociales
430	series de tiempo
431	precipitación
432	estadística
433	tributación
434	iva
435	pequeños contribuyentes
436	vida rural
437	cambio social
438	actores sociales
439	municipio
440	desarrollo local
441	cálculo mental
442	aritmética
443	familia
444	educación parvularia
445	participación
446	riego por goteo
447	chile dulce
448	eficiencia hídrica
449	abono orgánico
450	compost
451	fertilidad
452	análisis de suelos
453	estación experimental
454	radiación solar
455	instrumentación
456	arduino
457	sismología
458	volcanes
459	datos sísmicos
460	calderas
461	eficiencia energética
462	aves
463	campus
464	hongos
465	micología
466	taxonomía
467	inconstitucionalidad
468	amnistía
469	sala de lo constitucional
470	náuseas
471	vómitos
472	postoperatorio
473	valoración preanestésica
474	hipertensión
475	riesgo anestésico
476	vocabulario
477	aplicaciones móviles
478	escritura
479	errores
480	retroalimentación
481	hemograma
482	valores de referencia
483	hematología
484	titulación
485	acidez
486	potenciometría
487	estabilidad
488	amoxicilina
489	suspensión
490	línea de tiempo
491	historia política
492	recurso digital
493	autoestima
494	adolescentes
495	clima laboral
496	psicología organizacional
497	prevalencia
498	tamizaje
499	simuladores
500	electricidad
501	phet
502	distribución en planta
503	productividad
504	muebles
505	microempresa
506	satisfacción del cliente
507	servicio
508	teoría de grafos
509	rutas
510	optimización
511	vivienda social
512	arquitectura bioclimática
513	confort térmico
514	niif para pymes
515	estados financieros
516	factura electrónica
517	ministerio de hacienda
518	negocios
519	organización comunitaria
520	asentamientos
521	vulnerabilidad sísmica
522	adobe
523	escuelas
524	rutas de distribución
525	transporte
526	almacenes
527	centro de distribución
528	puerto de la unión
529	logística portuaria
530	hábitos de higiene
531	películas delgadas
532	espectroscopía
533	oscilaciones
534	amortiguamiento
535	mecánica
536	índice de precios
537	mercados municipales
538	5s
539	orden y limpieza
540	bomba de ariete
541	iluminación pública
542	violencia intrafamiliar
543	muestras clínicas
544	bioseguridad
545	antioxidantes
546	flor de jamaica
547	extracto
548	juego de roles
549	plan de mercadeo
550	patologías
551	edificaciones
552	manejo integrado de plagas
553	maíz
554	aerogenerador
555	anfibios
556	bosque
557	hipotermia
558	cirugía mayor
559	seguridad del paciente
560	lista de verificación
561	equipo de anestesia
562	nitratos
563	agua de pozo
564	espectrofotometría
565	prácticas profesionales
566	consultorio
567	modelo entidad-relación
568	tradición oral
569	leyendas
570	literatura popular
571	traducción técnica
572	motivación
573	tercera lengua
574	control prenatal
575	laboratorio virtual
576	ondas
577	liderazgo
578	desempeño laboral
579	biochar
580	suelo
581	desarrollo económico
582	resiliencia
583	violencia
584	circuito eléctrico
585	gestión financiera
586	pyme
587	programación lineal
588	agricultura
589	logística inversa
590	envases
591	paneles solares
592	eficiencia
593	radiación
594	velocidad del sonido
595	resonancia
596	germinación
597	árboles nativos
598	reforestación
599	aprendizaje cooperativo
600	anemia
601	hemoglobina
602	hidroterapia
603	parálisis cerebral
604	crédito
605	mype
606	financiamiento
607	interpretación simultánea
608	congreso
609	práctica
610	democracia
611	teoría de colas
612	reforma fiscal
613	impuestos
614	pymes
615	juventud rural
616	empleo
617	desarrollo
618	datos reales
619	cadena de frío
620	medio natural
621	salidas de campo
622	ecosistemas
623	herbario
624	botánica
625	polinizadores
626	abejas
627	teletrabajo
628	legislación
629	debido proceso
630	procedimiento administrativo
631	garantías
632	dolor postoperatorio
633	bloqueo de plexo
634	anestesia regional
635	comprensión auditiva
636	pódcast
637	lectura
638	perfil lipídico
639	colesterol
640	pausas activas
641	salud laboral
642	automedicación
643	farmacia
644	reconocimiento facial
645	asistencia
646	neumonía
647	tratamiento
648	posicionamiento
649	diseño organizacional
650	organigrama
651	albergue
652	emergencias
653	contabilidad
654	tienda
655	redes de apoyo
656	madres solteras
657	diagnóstico participativo
658	comunidad
659	origami
660	ceniza volcánica
661	microscopio
662	instalaciones eléctricas
663	normativa
664	centro de salud
665	ligamento cruzado
666	rodilla
667	saponificación
668	jabón
669	aceites vegetales
670	crema
671	aceite de coco
672	lenguaje juvenil
673	habilidades sociales
674	infecciones nosocomiales
675	vigilancia
676	hospital
677	física
678	balanceo de línea
679	maquila
680	marañón
681	unión europea
682	aulas
683	mobiliario urbano
684	drenaje pluvial
685	hidrología
686	colonia
687	aduana
688	tiempos de despacho
689	comercio regional
690	hongos comestibles
691	análisis de fallas
692	ejes
693	fatiga
694	pérdidas técnicas
695	carbón activado
696	adsorción
697	coco
698	escritura creativa
699	patrimonio cultural
700	burnout
701	enfermería
702	modelos moleculares
703	química orgánica
704	feria científica
705	reacciones químicas
706	teoría de números
707	criptografía
708	aritmética modular
709	control de inventarios
710	farmacias
711	costos
712	arte infantil
713	emociones
714	conducción de calor
715	simulación numérica
\.


--
-- Data for Name: tbl_favorito; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_favorito (id_usuario, id_proyecto, fecha_registro) FROM stdin;
194	5	2019-06-23 14:46:50.976065
77	5	2019-06-23 14:46:50.99538
170	8	2019-05-21 16:06:38.544093
80	8	2019-05-21 16:06:38.55838
143	11	2019-04-27 14:37:06.751846
194	11	2019-04-27 14:37:06.768122
156	11	2019-04-27 14:37:06.775934
88	13	2019-06-02 09:24:06.473905
143	13	2019-06-02 09:24:06.48177
211	13	2019-06-02 09:24:06.488827
75	15	2019-09-27 23:49:39.701899
76	15	2019-09-27 23:49:39.716889
180	16	2020-11-19 22:51:12.65895
107	16	2020-11-19 22:51:12.675165
166	18	2020-08-11 10:26:03.244199
204	18	2020-08-11 10:26:03.251763
105	18	2020-08-11 10:26:03.267971
84	21	2020-12-09 03:02:18.761524
63	22	2020-05-15 13:48:29.691792
215	22	2020-05-15 13:48:29.708277
116	22	2020-05-15 13:48:29.724891
115	25	2020-11-09 16:11:55.95994
56	25	2020-11-09 16:11:55.974528
190	27	2020-09-22 09:39:14.712558
111	27	2020-09-22 09:39:14.729349
152	28	2020-10-03 18:55:18.296154
110	29	2020-09-24 10:17:37.014076
94	29	2020-09-24 10:17:37.033384
181	29	2020-09-24 10:17:37.046704
177	30	2020-05-11 04:21:13.056682
173	30	2020-05-11 04:21:13.074206
213	32	2020-08-25 05:04:12.361621
183	34	2020-05-11 13:27:32.661144
58	34	2020-05-11 13:27:32.671021
163	34	2020-05-11 13:27:32.688203
127	35	2021-08-18 11:47:08.647946
112	35	2021-08-18 11:47:08.663165
177	35	2021-08-18 11:47:08.668907
56	38	2021-07-26 06:39:51.989241
200	38	2021-07-26 06:39:52.00371
174	38	2021-07-26 06:39:52.022065
178	39	2021-04-02 13:34:12.026551
156	39	2021-04-02 13:34:12.032804
100	40	2021-05-11 14:42:46.042844
173	40	2021-05-11 14:42:46.064718
94	40	2021-05-11 14:42:46.079828
77	45	2021-12-10 00:13:28.034627
139	47	2021-06-17 16:25:53.025976
64	47	2021-06-17 16:25:53.049364
146	49	2021-07-07 10:34:19.620214
76	50	2021-09-13 08:49:15.430413
49	50	2021-09-13 08:49:15.445997
84	50	2021-09-13 08:49:15.462607
169	51	2021-10-28 12:26:14.910402
139	51	2021-10-28 12:26:14.925693
136	53	2021-07-03 12:27:53.62423
113	54	2021-10-13 13:22:19.695913
56	55	2021-09-20 06:51:02.777395
112	55	2021-09-20 06:51:02.786972
62	56	2021-10-05 16:48:28.840907
119	57	2021-06-12 21:31:36.947688
199	57	2021-06-12 21:31:36.956552
100	58	2021-07-17 18:38:36.841603
137	61	2022-07-13 04:42:37.38618
48	61	2022-07-13 04:42:37.40066
67	61	2022-07-13 04:42:37.416983
147	62	2022-05-25 19:58:23.229458
90	62	2022-05-25 19:58:23.244621
76	62	2022-05-25 19:58:23.261843
112	63	2022-05-08 03:47:21.361782
137	63	2022-05-08 03:47:21.386322
63	64	2022-05-18 13:05:59.200081
215	64	2022-05-18 13:05:59.215638
116	64	2022-05-18 13:05:59.231306
98	65	2022-08-13 06:12:20.982265
191	65	2022-08-13 06:12:20.997738
154	67	2022-05-01 06:00:05.084799
177	67	2022-05-01 06:00:05.093005
122	69	2022-08-20 19:05:12.774342
77	69	2022-08-20 19:05:12.790126
106	70	2022-09-23 05:51:03.798623
178	70	2022-09-23 05:51:03.812391
125	72	2022-12-12 09:27:46.432197
121	72	2022-12-12 09:27:46.44989
172	72	2022-12-12 09:27:46.466587
74	74	2022-05-16 11:12:55.873061
49	74	2022-05-16 11:12:55.888773
220	75	2022-04-30 07:03:45.709183
217	77	2022-09-02 18:30:35.573245
202	77	2022-09-02 18:30:35.588102
198	78	2022-04-11 12:33:11.530921
102	78	2022-04-11 12:33:11.545888
154	79	2022-04-16 11:14:37.488673
66	79	2022-04-16 11:14:37.506152
142	80	2022-09-24 11:35:34.42093
162	81	2023-10-22 21:55:07.056125
54	82	2023-05-15 06:18:37.999581
116	82	2023-05-15 06:18:38.014292
126	83	2023-11-26 00:33:32.023527
127	84	2023-11-09 02:57:12.014047
68	85	2023-05-13 04:13:52.932848
177	85	2023-05-13 04:13:52.949647
219	85	2023-05-13 04:13:52.965934
211	86	2023-12-08 05:52:59.870164
105	86	2023-12-08 05:52:59.877854
95	89	2023-08-24 23:55:11.02659
181	92	2023-07-24 23:44:40.008653
106	92	2023-07-24 23:44:40.024102
213	92	2023-07-24 23:44:40.039473
65	93	2023-11-29 19:37:48.896578
87	93	2023-11-29 19:37:48.911462
120	97	2023-07-07 02:54:57.457768
172	97	2023-07-07 02:54:57.472362
59	99	2023-04-16 02:42:08.166888
127	99	2023-04-16 02:42:08.181908
102	99	2023-04-16 02:42:08.197392
116	101	2023-04-06 13:47:24.975901
85	101	2023-04-06 13:47:24.990584
213	101	2023-04-06 13:47:25.007169
206	102	2024-06-16 16:05:23.940371
109	103	2024-08-26 20:00:14.881656
148	103	2024-08-26 20:00:14.889029
48	103	2024-08-26 20:00:14.900197
146	106	2024-11-30 12:43:42.38325
88	106	2024-11-30 12:43:42.398108
74	106	2024-11-30 12:43:42.415122
108	110	2024-04-16 14:23:46.93145
50	110	2024-04-16 14:23:46.947078
67	110	2024-04-16 14:23:46.962029
208	112	2024-09-07 19:33:05.390295
117	112	2024-09-07 19:33:05.405723
178	112	2024-09-07 19:33:05.420329
138	113	2024-08-16 08:51:41.470169
94	113	2024-08-16 08:51:41.495975
90	113	2024-08-16 08:51:41.515677
193	114	2024-10-10 12:33:40.493313
175	115	2024-09-15 18:53:24.436027
68	115	2024-09-15 18:53:24.450026
132	117	2024-05-06 06:12:51.446898
215	117	2024-05-06 06:12:51.463313
203	117	2024-05-06 06:12:51.480601
217	118	2024-10-27 02:14:27.495684
192	118	2024-10-27 02:14:27.519868
184	119	2024-09-09 13:51:06.619825
201	122	2024-11-06 10:50:05.216531
169	122	2024-11-06 10:50:05.263805
138	122	2024-11-06 10:50:05.279849
139	123	2024-05-16 07:51:38.31604
90	124	2024-05-13 18:15:17.310497
94	127	2024-06-02 21:00:22.845927
54	123	2024-05-16 07:51:38.346464
199	124	2024-05-13 18:15:17.294559
101	126	2024-09-12 19:41:11.824414
164	128	2024-05-22 19:34:39.676105
57	128	2024-05-22 19:34:39.690713
151	128	2024-05-22 19:34:39.70758
49	132	2024-05-14 17:44:26.655132
146	132	2024-05-14 17:44:26.684982
218	133	2024-10-29 16:51:01.718017
106	134	2024-12-08 09:34:52.822513
170	134	2024-12-08 09:34:52.851538
64	135	2024-06-28 11:52:43.922962
86	135	2024-06-28 11:52:43.938484
77	135	2024-06-28 11:52:43.954694
59	136	2024-08-03 15:26:31.267355
136	140	2025-09-08 15:35:31.941168
188	140	2025-09-08 15:35:31.954928
149	141	2025-10-24 04:00:14.953079
58	141	2025-10-24 04:00:14.96249
145	141	2025-10-24 04:00:14.982798
194	143	2025-11-16 17:42:14.945535
149	144	2025-04-01 18:53:14.899472
114	144	2025-04-01 18:53:14.9219
183	146	2025-08-20 11:35:58.512959
185	146	2025-08-20 11:35:58.521702
111	146	2025-08-20 11:35:58.543673
188	147	2025-07-25 09:29:18.50329
53	147	2025-07-25 09:29:18.518885
207	147	2025-07-25 09:29:18.534442
154	149	2025-11-19 01:24:44.428354
180	149	2025-11-19 01:24:44.448153
189	150	2025-11-17 02:14:11.18266
89	150	2025-11-17 02:14:11.197966
48	152	2025-12-01 04:19:34.541974
141	152	2025-12-01 04:19:34.558177
156	153	2025-07-03 08:32:46.56407
98	153	2025-07-03 08:32:46.581391
134	154	2025-04-22 01:49:51.568733
157	154	2025-04-22 01:49:51.583204
150	155	2025-07-28 01:24:35.591914
99	155	2025-07-28 01:24:35.607124
70	156	2025-06-18 08:01:38.66597
136	156	2025-06-18 08:01:38.675168
168	156	2025-06-18 08:01:38.69711
84	157	2025-09-01 20:06:34.734447
157	157	2025-09-01 20:06:34.750074
88	157	2025-09-01 20:06:34.757487
110	158	2025-09-23 07:29:05.801995
164	158	2025-09-23 07:29:05.817648
162	158	2025-09-23 07:29:05.834771
177	159	2025-05-11 04:23:34.880914
173	159	2025-05-11 04:23:34.896096
217	161	2025-11-13 08:12:58.432531
107	162	2025-10-31 14:34:58.045456
93	162	2025-10-31 14:34:58.059753
148	162	2025-10-31 14:34:58.076475
63	164	2025-10-09 00:07:51.975275
194	165	2025-04-16 05:44:13.868178
106	165	2025-04-16 05:44:13.873556
74	165	2025-04-16 05:44:13.896053
156	166	2025-09-01 06:22:54.979354
48	166	2025-09-01 06:22:54.987374
161	166	2025-09-01 06:22:54.993436
104	168	2025-04-27 02:50:24.305309
52	168	2025-04-27 02:50:24.321205
68	168	2025-04-27 02:50:24.336845
60	174	2025-11-04 07:42:56.42088
108	174	2025-11-04 07:42:56.43621
153	179	2026-07-05 12:45:27.892728
77	179	2026-07-05 12:45:27.902302
138	199	2026-10-02 00:43:36.464859
141	203	2026-11-16 14:56:47.010679
193	203	2026-11-16 14:56:47.026062
136	203	2026-11-16 14:56:47.032218
99	204	2026-06-11 11:16:55.959027
183	204	2026-06-11 11:16:55.975763
50	204	2026-06-11 11:16:55.990178
119	205	2026-11-22 05:01:14.238702
249	206	2019-04-25 12:41:04.049066
302	207	2019-10-27 02:12:26.121614
277	207	2019-10-27 02:12:26.137102
260	209	2020-07-21 14:14:44.948388
298	210	2020-08-25 03:31:47.010351
221	210	2020-08-25 03:31:47.036048
296	211	2020-07-05 23:12:32.027267
276	211	2020-07-05 23:12:32.042348
251	212	2020-08-04 13:20:54.988585
221	214	2020-05-05 16:08:20.675588
298	214	2020-05-05 16:08:20.692453
225	215	2020-07-08 07:22:52.642169
255	216	2020-11-11 12:06:46.591493
260	216	2020-11-11 12:06:46.608217
245	216	2020-11-11 12:06:46.623844
283	217	2021-07-26 04:46:38.570934
277	220	2021-09-06 10:28:45.566109
284	220	2021-09-06 10:28:45.59235
305	220	2021-09-06 10:28:45.608079
301	222	2021-12-08 05:52:46.159035
281	222	2021-12-08 05:52:46.172916
297	222	2021-12-08 05:52:46.188607
268	227	2021-06-08 04:47:35.235037
278	227	2021-06-08 04:47:35.259973
286	228	2021-11-26 23:23:52.395825
290	232	2022-04-13 11:20:20.121841
273	232	2022-04-13 11:20:20.13665
303	232	2022-04-13 11:20:20.151837
257	233	2022-06-22 04:31:22.272906
270	237	2022-08-15 11:44:58.118672
283	237	2022-08-15 11:44:58.12685
302	240	2023-05-17 04:21:12.436055
292	240	2023-05-17 04:21:12.451722
269	240	2023-05-17 04:21:12.468431
266	241	2023-07-22 04:06:11.405859
285	241	2023-07-22 04:06:11.421868
268	241	2023-07-22 04:06:11.439158
231	242	2023-12-08 21:56:30.465138
302	242	2023-12-08 21:56:30.475005
271	242	2023-12-08 21:56:30.494858
271	244	2023-07-29 16:55:02.217756
280	244	2023-07-29 16:55:02.233823
291	247	2023-09-21 14:57:50.366385
259	248	2023-08-26 18:47:53.377144
258	248	2023-08-26 18:47:53.39211
255	248	2023-08-26 18:47:53.408452
260	249	2023-06-23 09:02:00.401938
299	252	2023-11-27 21:12:00.820749
299	253	2024-04-10 13:25:38.846069
294	253	2024-04-10 13:25:38.860859
287	253	2024-04-10 13:25:38.87549
274	254	2024-11-17 02:12:25.237403
224	254	2024-11-17 02:12:25.246821
248	255	2024-04-30 08:27:48.47775
224	255	2024-04-30 08:27:48.513565
267	256	2024-06-06 05:11:51.625526
247	256	2024-06-06 05:11:51.64049
280	258	2024-05-26 08:28:17.920661
236	258	2024-05-26 08:28:17.943488
299	258	2024-05-26 08:28:17.959979
280	259	2024-08-27 14:30:22.286163
294	259	2024-08-27 14:30:22.302743
275	261	2024-09-22 09:39:54.998774
271	261	2024-09-22 09:39:55.014235
274	262	2024-10-31 07:22:50.730876
260	264	2024-06-30 04:34:06.422681
244	264	2024-06-30 04:34:06.439168
242	264	2024-06-30 04:34:06.45478
245	266	2024-10-08 05:03:46.868121
241	266	2024-10-08 05:03:46.884364
293	266	2024-10-08 05:03:46.900259
221	267	2024-06-13 04:13:21.927132
247	267	2024-06-13 04:13:21.943071
257	268	2024-10-07 17:25:33.938928
232	268	2024-10-07 17:25:33.955302
290	268	2024-10-07 17:25:33.970857
247	271	2024-12-13 23:24:03.412599
233	271	2024-12-13 23:24:03.428608
305	272	2024-08-18 00:14:20.454431
290	272	2024-08-18 00:14:20.469604
283	275	2025-09-30 07:58:42.223097
290	276	2025-11-07 06:07:42.948447
295	276	2025-11-07 06:07:42.957075
265	278	2025-07-08 21:55:03.435257
229	278	2025-07-08 21:55:03.450213
259	279	2025-07-16 18:49:14.450022
244	280	2025-05-12 15:32:29.491773
251	281	2025-12-09 18:37:30.522442
246	283	2025-08-07 20:56:04.544656
224	283	2025-08-07 20:56:04.553705
281	283	2025-08-07 20:56:04.575863
269	284	2025-05-27 12:29:01.605668
235	286	2025-12-08 10:23:15.316482
226	286	2025-12-08 10:23:15.330797
294	287	2025-11-06 13:41:26.066925
227	288	2025-06-23 20:09:49.145741
287	288	2025-06-23 20:09:49.160547
259	288	2025-06-23 20:09:49.176241
296	289	2025-07-10 02:15:27.75018
297	290	2025-09-12 04:13:20.308381
281	290	2025-09-12 04:13:20.323933
241	293	2026-05-07 13:25:47.339557
237	293	2026-05-07 13:25:47.354273
223	296	2026-10-02 04:06:09.85398
234	296	2026-10-02 04:06:09.868872
249	296	2026-10-02 04:06:09.884639
279	302	2026-10-03 13:45:02.260644
304	302	2026-10-03 13:45:02.277244
257	304	2026-08-13 03:16:03.03544
\.


--
-- Data for Name: tbl_historial; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_historial (id_historial, id_usuario, id_proyecto, accion, fecha_accion, detalle) FROM stdin;
52	65	21	envío	2020-11-24 12:08:24.146858	Solicitud registrada y pendiente de revisión del supervisor.
9	48	4	envío	2019-11-23 06:12:27.49384	Solicitud registrada y pendiente de revisión del supervisor.
10	21	4	revisión	2019-12-07 06:40:58.140112	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
24	54	10	envío	2019-12-08 08:35:42.464199	Solicitud registrada y pendiente de revisión del supervisor.
25	21	10	revisión	2019-12-10 17:37:46.806479	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
43	61	17	envío	2020-08-09 00:41:07.976645	Solicitud registrada y pendiente de revisión del supervisor.
32	57	13	envío	2019-05-14 07:45:18.514068	Solicitud registrada y pendiente de revisión del supervisor.
26	55	11	envío	2019-04-16 09:56:40.10946	Solicitud registrada y pendiente de revisión del supervisor.
27	22	11	revisión	2019-04-20 16:05:25.440077	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
11	49	5	envío	2019-05-26 06:15:16.446794	Solicitud registrada y pendiente de revisión del supervisor.
12	22	5	revisión	2019-05-28 22:20:14.750247	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
13	49	5	reenvío	2019-06-04 09:54:57.263884	Versión corregida registrada y pendiente de revisión del supervisor.
14	21	5	revisión	2019-06-07 03:54:50.639039	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
15	50	6	envío	2019-08-22 13:30:05.28599	Solicitud registrada y pendiente de revisión del supervisor.
16	22	6	revisión	2019-08-25 07:57:46.628416	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
33	22	13	revisión	2019-05-18 11:21:39.856308	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
17	51	7	envío	2019-08-10 20:03:08.938318	Solicitud registrada y pendiente de revisión del supervisor.
18	23	7	revisión	2019-08-16 03:17:28.280337	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
34	21	13	destacado	2019-05-30 21:50:49.163889	Se marcó como trabajo destacado.
44	21	17	revisión	2020-08-16 02:34:46.326827	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
19	52	8	envío	2019-05-01 05:29:38.590797	Solicitud registrada y pendiente de revisión del supervisor.
20	21	8	revisión	2019-05-06 09:09:28.927027	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
21	21	8	destacado	2019-05-14 18:10:33.249892	Se marcó como trabajo destacado.
35	58	14	envío	2019-11-30 00:48:42.780161	Solicitud registrada y pendiente de revisión del supervisor.
22	53	9	envío	2019-05-17 17:40:26.860285	Solicitud registrada y pendiente de revisión del supervisor.
23	22	9	revisión	2019-06-01 17:29:57.176478	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.
28	56	12	envío	2019-03-05 08:31:28.112614	Solicitud registrada y pendiente de revisión del supervisor.
29	23	12	revisión	2019-03-14 01:33:39.466562	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
30	56	12	reenvío	2019-03-17 05:01:04.845457	Versión corregida registrada y pendiente de revisión del supervisor.
31	22	12	revisión	2019-04-01 02:10:25.193721	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
36	22	14	revisión	2019-12-02 07:01:37.093603	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.
37	59	15	envío	2019-09-04 19:52:04.392613	Solicitud registrada y pendiente de revisión del supervisor.
38	23	15	revisión	2019-09-09 04:10:23.712754	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
39	59	15	reenvío	2019-09-12 22:52:41.075224	Versión corregida registrada y pendiente de revisión del supervisor.
40	23	15	revisión	2019-09-21 11:01:54.407849	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
47	63	19	envío	2020-03-29 09:27:20.582369	Solicitud registrada y pendiente de revisión del supervisor.
45	62	18	envío	2020-06-25 14:51:27.624935	Solicitud registrada y pendiente de revisión del supervisor.
41	60	16	envío	2020-10-13 05:16:27.004032	Solicitud registrada y pendiente de revisión del supervisor.
42	21	16	revisión	2020-10-19 08:48:44.351604	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
46	23	18	revisión	2020-07-04 23:54:38.962448	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
50	64	20	envío	2020-10-25 22:53:32.524231	Solicitud registrada y pendiente de revisión del supervisor.
48	21	19	revisión	2020-04-03 23:39:29.921599	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
49	22	19	retiro	2020-06-15 20:14:12.234859	La institución colaboradora solicitó no divulgar los resultados.
51	22	20	revisión	2020-11-06 15:12:38.853575	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
54	66	22	envío	2020-04-03 07:19:55.059736	Solicitud registrada y pendiente de revisión del supervisor.
53	21	21	revisión	2020-11-26 14:56:24.470772	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
55	23	22	revisión	2020-04-14 09:09:40.397873	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
56	67	23	envío	2020-08-23 16:34:41.037665	Solicitud registrada y pendiente de revisión del supervisor.
57	21	23	revisión	2020-09-03 02:35:08.37339	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
58	68	24	envío	2020-05-06 15:41:11.674071	Solicitud registrada y pendiente de revisión del supervisor.
61	22	25	revisión	2020-10-17 06:42:03.651752	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
59	22	24	revisión	2020-05-17 13:58:23.012067	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.
110	22	43	revisión	2021-08-31 05:05:55.716945	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.
60	69	25	envío	2020-10-02 21:23:36.313528	Solicitud registrada y pendiente de revisión del supervisor.
89	77	34	envío	2020-04-01 02:44:54.993699	Solicitud registrada y pendiente de revisión del supervisor.
64	70	26	reenvío	2020-07-07 00:25:26.013808	Versión corregida registrada y pendiente de revisión del supervisor.
68	21	27	revisión	2020-09-13 17:46:02.406405	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
135	93	52	envío	2021-07-20 06:27:01.281505	Solicitud registrada y pendiente de revisión del supervisor.
91	78	35	envío	2021-07-16 02:22:49.999608	Solicitud registrada y pendiente de revisión del supervisor.
111	65	44	envío	2021-12-07 03:31:15.034979	Solicitud registrada y pendiente de revisión del supervisor.
93	79	36	envío	2021-04-27 05:30:44.973427	Solicitud registrada y pendiente de revisión del supervisor.
94	21	36	revisión	2021-05-02 12:06:24.2964	Decisión del supervisor: Rechazada. Este trabajo ya fue registrado en el repositorio por otro integrante del grupo.
69	72	28	envío	2020-08-24 03:25:42.021823	Solicitud registrada y pendiente de revisión del supervisor.
70	21	28	revisión	2020-08-31 04:11:17.348046	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
72	23	28	revisión	2020-09-19 05:42:12.011878	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
75	73	29	reenvío	2020-08-09 02:23:59.307777	Versión corregida registrada y pendiente de revisión del supervisor.
95	80	37	envío	2021-04-22 20:58:42.622983	Solicitud registrada y pendiente de revisión del supervisor.
96	21	37	revisión	2021-05-03 02:33:18.958741	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.
77	59	30	envío	2020-04-14 01:51:33.363523	Solicitud registrada y pendiente de revisión del supervisor.
81	74	31	reenvío	2020-11-16 03:52:24.116077	Versión corregida registrada y pendiente de revisión del supervisor.
84	23	32	revisión	2020-08-08 23:04:34.082492	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
136	22	52	revisión	2021-07-30 04:05:51.635299	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
97	81	38	envío	2021-07-09 05:54:11.257637	Solicitud registrada y pendiente de revisión del supervisor.
115	87	45	reenvío	2021-11-20 03:33:03.361813	Versión corregida registrada y pendiente de revisión del supervisor.
99	82	39	envío	2021-03-21 15:15:48.374278	Solicitud registrada y pendiente de revisión del supervisor.
85	76	33	envío	2020-10-21 14:46:24.659428	Solicitud registrada y pendiente de revisión del supervisor.
86	23	33	revisión	2020-11-05 04:48:32.978196	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
87	76	33	reenvío	2020-11-14 07:42:08.311423	Versión corregida registrada y pendiente de revisión del supervisor.
88	23	33	revisión	2020-11-17 11:08:33.645491	Decisión del supervisor: Rechazada. Este trabajo ya fue registrado en el repositorio por otro integrante del grupo.
132	92	51	envío	2021-08-19 03:43:45.810107	Solicitud registrada y pendiente de revisión del supervisor.
102	21	40	revisión	2021-05-07 01:59:49.712938	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
104	23	41	revisión	2021-10-18 19:23:30.765341	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
117	88	46	envío	2021-02-20 09:30:33.333592	Solicitud registrada y pendiente de revisión del supervisor.
119	21	46	retiro	2021-05-16 00:01:50.997087	Se detectaron datos personales de participantes en el documento.
105	85	42	envío	2021-08-20 09:58:24.059398	Solicitud registrada y pendiente de revisión del supervisor.
106	22	42	revisión	2021-09-03 08:49:22.382253	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.
137	93	52	reenvío	2021-08-10 06:45:29.089453	Versión corregida registrada y pendiente de revisión del supervisor.
120	89	47	envío	2021-05-26 15:29:24.329904	Solicitud registrada y pendiente de revisión del supervisor.
122	90	48	envío	2021-07-02 01:20:51.381296	Solicitud registrada y pendiente de revisión del supervisor.
123	22	48	revisión	2021-07-15 22:34:33.735424	Decisión del supervisor: Rechazada. Este trabajo ya fue registrado en el repositorio por otro integrante del grupo.
139	22	52	retiro	2021-09-30 10:01:52.82362	Se detectaron datos personales de participantes en el documento.
127	22	49	revisión	2021-07-05 08:56:29.264667	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
128	91	50	envío	2021-08-03 08:01:12.950139	Solicitud registrada y pendiente de revisión del supervisor.
129	21	50	revisión	2021-08-14 05:28:12.298679	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
130	91	50	reenvío	2021-08-28 03:04:26.717088	Versión corregida registrada y pendiente de revisión del supervisor.
145	23	54	revisión	2021-09-17 06:27:50.366463	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
143	21	53	revisión	2021-06-14 05:32:20.297828	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
151	23	57	revisión	2021-06-04 06:02:05.565149	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
146	95	55	envío	2021-08-28 21:15:15.038777	Solicitud registrada y pendiente de revisión del supervisor.
149	21	56	revisión	2021-08-31 13:16:03.520699	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
152	98	58	envío	2021-06-04 16:20:32.306807	Solicitud registrada y pendiente de revisión del supervisor.
157	21	59	revisión	2021-10-22 19:35:34.588333	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
153	21	58	revisión	2021-06-08 15:56:42.672706	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
155	21	58	revisión	2021-06-30 22:59:10.484463	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
160	101	61	envío	2022-06-03 06:31:28.675793	Solicitud registrada y pendiente de revisión del supervisor.
158	100	60	envío	2021-10-09 10:50:28.96663	Solicitud registrada y pendiente de revisión del supervisor.
159	22	60	revisión	2021-10-21 07:16:42.345109	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.
162	61	62	envío	2022-03-27 13:57:47.773411	Solicitud registrada y pendiente de revisión del supervisor.
113	87	45	envío	2021-11-03 18:49:18.663465	Solicitud registrada y pendiente de revisión del supervisor.
83	75	32	envío	2020-08-05 05:54:49.754748	Solicitud registrada y pendiente de revisión del supervisor.
114	21	45	revisión	2021-11-10 08:22:16.99989	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
90	23	34	revisión	2020-04-15 12:06:02.347061	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
116	23	45	revisión	2021-11-26 17:45:35.712128	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
92	23	35	revisión	2021-07-28 03:27:19.339929	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
62	70	26	envío	2020-06-15 22:07:17.27547	Solicitud registrada y pendiente de revisión del supervisor.
63	23	26	revisión	2020-06-24 09:03:10.608179	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.
65	23	26	revisión	2020-07-17 15:11:37.390562	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
66	21	26	destacado	2020-08-10 18:31:19.712717	Se marcó como trabajo destacado.
67	71	27	envío	2020-08-31 02:15:16.041305	Solicitud registrada y pendiente de revisión del supervisor.
98	21	38	revisión	2021-07-22 12:09:02.630498	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
71	72	28	reenvío	2020-09-14 07:58:22.683674	Versión corregida registrada y pendiente de revisión del supervisor.
131	23	50	revisión	2021-09-07 22:36:56.101488	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
100	22	39	revisión	2021-03-27 22:36:42.732681	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
118	22	46	revisión	2021-03-05 08:12:25.66837	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
101	83	40	envío	2021-04-28 23:00:36.341193	Solicitud registrada y pendiente de revisión del supervisor.
73	73	29	envío	2020-07-17 06:24:07.591005	Solicitud registrada y pendiente de revisión del supervisor.
74	23	29	revisión	2020-07-29 15:51:12.943748	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
76	23	29	revisión	2020-08-19 08:17:57.691402	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
103	84	41	envío	2021-10-12 20:37:30.412356	Solicitud registrada y pendiente de revisión del supervisor.
78	23	30	revisión	2020-04-18 11:02:39.732499	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
121	22	47	revisión	2021-06-09 15:35:37.692648	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
107	85	42	reenvío	2021-09-16 04:56:26.747997	Versión corregida registrada y pendiente de revisión del supervisor.
108	23	42	revisión	2021-09-23 19:42:24.082462	Decisión del supervisor: Rechazada. El documento adjunto no corresponde al trabajo descrito en la ficha.
79	74	31	envío	2020-11-02 12:48:17.389775	Solicitud registrada y pendiente de revisión del supervisor.
80	23	31	revisión	2020-11-11 00:40:38.735958	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
82	23	31	revisión	2020-11-21 13:02:47.462165	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
140	94	53	envío	2021-05-19 09:19:27.156896	Solicitud registrada y pendiente de revisión del supervisor.
109	86	43	envío	2021-08-27 07:54:00.379051	Solicitud registrada y pendiente de revisión del supervisor.
112	22	44	revisión	2021-12-10 16:51:16.364144	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
141	21	53	revisión	2021-05-25 09:34:53.521556	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
142	94	53	reenvío	2021-06-03 00:34:01.923617	Versión corregida registrada y pendiente de revisión del supervisor.
133	21	51	revisión	2021-08-25 05:18:03.222559	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
134	21	51	destacado	2021-09-22 10:55:26.566667	Se marcó como trabajo destacado.
138	21	52	revisión	2021-08-19 09:35:21.471539	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
161	22	61	revisión	2022-06-11 15:24:42.046429	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
124	71	49	envío	2021-06-15 05:11:34.080312	Solicitud registrada y pendiente de revisión del supervisor.
125	23	49	revisión	2021-06-18 20:46:28.448669	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.
126	71	49	reenvío	2021-07-02 07:38:42.855781	Versión corregida registrada y pendiente de revisión del supervisor.
144	58	54	envío	2021-09-06 13:28:28.983904	Solicitud registrada y pendiente de revisión del supervisor.
150	97	57	envío	2021-05-28 15:17:30.181522	Solicitud registrada y pendiente de revisión del supervisor.
147	21	55	revisión	2021-09-09 00:25:05.441061	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
166	102	63	envío	2022-04-02 19:42:56.605094	Solicitud registrada y pendiente de revisión del supervisor.
154	98	58	reenvío	2021-06-16 05:55:48.062506	Versión corregida registrada y pendiente de revisión del supervisor.
148	96	56	envío	2021-08-26 07:39:03.13098	Solicitud registrada y pendiente de revisión del supervisor.
164	61	62	reenvío	2022-04-13 09:08:19.521473	Versión corregida registrada y pendiente de revisión del supervisor.
156	99	59	envío	2021-10-15 14:18:18.204223	Solicitud registrada y pendiente de revisión del supervisor.
172	81	65	envío	2022-07-05 17:46:50.546879	Solicitud registrada y pendiente de revisión del supervisor.
176	104	66	envío	2022-05-11 22:31:26.324044	Solicitud registrada y pendiente de revisión del supervisor.
170	103	64	reenvío	2022-04-04 11:47:40.4974	Versión corregida registrada y pendiente de revisión del supervisor.
179	105	67	envío	2022-03-27 03:21:48.365765	Solicitud registrada y pendiente de revisión del supervisor.
173	21	65	revisión	2022-07-11 15:12:26.899645	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
175	23	65	revisión	2022-07-25 00:58:03.656835	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
178	22	66	retiro	2022-09-12 13:18:48.019455	Se detectaron datos personales de participantes en el documento.
182	21	68	revisión	2022-12-10 23:31:28.801334	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
184	22	69	revisión	2022-08-08 01:36:18.463179	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
216	117	82	envío	2023-03-28 14:35:45.350772	Solicitud registrada y pendiente de revisión del supervisor.
163	21	62	revisión	2022-04-07 18:13:21.139507	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
165	21	62	revisión	2022-04-23 02:39:55.902585	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
187	108	71	envío	2022-09-30 11:19:09.081503	Solicitud registrada y pendiente de revisión del supervisor.
167	22	63	revisión	2022-04-10 17:25:05.033516	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
188	23	71	revisión	2022-10-07 03:48:45.390152	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
189	108	71	reenvío	2022-10-16 20:34:38.704726	Versión corregida registrada y pendiente de revisión del supervisor.
190	22	71	revisión	2022-10-30 02:29:52.986973	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
217	21	82	revisión	2023-04-05 06:32:38.689991	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
199	111	75	envío	2022-03-15 00:47:40.145248	Solicitud registrada y pendiente de revisión del supervisor.
200	23	75	revisión	2022-03-21 10:55:14.447785	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
168	103	64	envío	2022-03-16 22:56:04.746277	Solicitud registrada y pendiente de revisión del supervisor.
169	23	64	revisión	2022-03-21 04:42:52.100381	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
171	23	64	revisión	2022-04-17 08:27:09.860831	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
174	81	65	reenvío	2022-07-15 05:14:43.276322	Versión corregida registrada y pendiente de revisión del supervisor.
177	21	66	revisión	2022-05-17 02:43:42.69196	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
180	22	67	revisión	2022-04-03 17:20:43.764764	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
181	106	68	envío	2022-11-27 18:59:17.424206	Solicitud registrada y pendiente de revisión del supervisor.
208	115	79	envío	2022-03-17 15:24:06.844222	Solicitud registrada y pendiente de revisión del supervisor.
209	22	79	revisión	2022-03-23 08:25:35.195645	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
183	107	69	envío	2022-07-24 14:04:28.10801	Solicitud registrada y pendiente de revisión del supervisor.
201	112	76	envío	2022-07-09 11:00:38.011701	Solicitud registrada y pendiente de revisión del supervisor.
191	109	72	envío	2022-10-05 11:15:40.25802	Solicitud registrada y pendiente de revisión del supervisor.
185	51	70	envío	2022-08-19 10:20:07.116826	Solicitud registrada y pendiente de revisión del supervisor.
186	23	70	revisión	2022-08-22 16:12:26.470596	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
192	21	72	revisión	2022-10-19 15:51:16.550374	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
202	21	76	revisión	2022-07-11 14:19:04.348534	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
203	21	76	destacado	2022-07-17 20:47:26.641251	Se marcó como trabajo destacado.
193	109	72	reenvío	2022-10-28 07:21:34.868345	Versión corregida registrada y pendiente de revisión del supervisor.
194	23	72	revisión	2022-11-02 10:32:19.169788	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
195	110	73	envío	2022-05-27 18:08:34.739319	Solicitud registrada y pendiente de revisión del supervisor.
196	23	73	revisión	2022-05-30 08:47:03.040728	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.
224	121	86	envío	2023-12-01 09:11:02.264778	Solicitud registrada y pendiente de revisión del supervisor.
197	110	74	envío	2022-04-05 23:41:35.310522	Solicitud registrada y pendiente de revisión del supervisor.
198	23	74	revisión	2022-04-19 14:02:40.598946	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
204	113	77	envío	2022-08-20 21:35:52.941613	Solicitud registrada y pendiente de revisión del supervisor.
205	21	77	revisión	2022-08-29 12:21:13.280911	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
212	116	81	envío	2023-08-24 14:18:30.729963	Solicitud registrada y pendiente de revisión del supervisor.
213	22	81	revisión	2023-09-03 07:39:07.052994	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
210	100	80	envío	2022-09-01 21:58:46.802575	Solicitud registrada y pendiente de revisión del supervisor.
206	114	78	envío	2022-03-29 02:37:30.887451	Solicitud registrada y pendiente de revisión del supervisor.
207	22	78	revisión	2022-04-09 05:30:29.222506	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
211	23	80	revisión	2022-09-07 10:07:14.126229	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
214	116	81	reenvío	2023-09-09 12:16:41.411611	Versión corregida registrada y pendiente de revisión del supervisor.
215	22	81	revisión	2023-09-24 02:55:49.760605	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
220	119	84	envío	2023-10-19 11:21:08.348793	Solicitud registrada y pendiente de revisión del supervisor.
218	118	83	envío	2023-11-15 22:35:46.32854	Solicitud registrada y pendiente de revisión del supervisor.
221	22	84	revisión	2023-10-30 06:18:12.702196	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
219	21	83	revisión	2023-11-18 18:50:58.683386	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
222	120	85	envío	2023-04-01 09:32:08.323151	Solicitud registrada y pendiente de revisión del supervisor.
230	124	89	envío	2023-08-03 01:36:01.399225	Solicitud registrada y pendiente de revisión del supervisor.
223	21	85	revisión	2023-04-05 06:49:23.652206	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
225	21	86	revisión	2023-12-03 17:26:41.587384	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
226	122	87	envío	2023-07-29 09:56:34.169288	Solicitud registrada y pendiente de revisión del supervisor.
227	22	87	revisión	2023-08-11 21:09:09.492383	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.
228	123	88	envío	2023-09-29 22:08:49.790761	Solicitud registrada y pendiente de revisión del supervisor.
229	23	88	revisión	2023-10-05 10:39:30.099858	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
232	125	90	envío	2023-05-13 07:12:39.34142	Solicitud registrada y pendiente de revisión del supervisor.
231	21	89	revisión	2023-08-05 22:09:28.735368	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
270	139	104	envío	2024-08-19 04:41:40.19961	Solicitud registrada y pendiente de revisión del supervisor.
233	23	90	revisión	2023-05-16 09:01:44.663548	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
237	22	91	revisión	2023-06-17 05:28:17.939204	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.
303	23	116	revisión	2024-05-21 22:12:05.104723	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
238	127	92	envío	2023-06-30 13:43:49.281541	Solicitud registrada y pendiente de revisión del supervisor.
243	23	93	revisión	2023-10-26 18:44:05.544396	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
244	129	94	envío	2023-06-19 22:20:05.257719	Solicitud registrada y pendiente de revisión del supervisor.
272	140	105	envío	2024-07-17 22:22:29.799454	Solicitud registrada y pendiente de revisión del supervisor.
248	130	95	reenvío	2023-10-10 07:08:27.696448	Versión corregida registrada y pendiente de revisión del supervisor.
251	23	96	revisión	2023-06-14 01:31:20.748969	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
274	21	105	retiro	2024-10-04 01:59:38.435681	Los autores pidieron retirar la publicación para enviarla a una revista científica.
275	141	106	envío	2024-11-16 04:25:28.736063	Solicitud registrada y pendiente de revisión del supervisor.
278	22	107	revisión	2024-04-04 12:04:56.050339	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
252	132	97	envío	2023-05-29 02:02:39.053929	Solicitud registrada y pendiente de revisión del supervisor.
253	23	97	revisión	2023-06-10 19:54:17.386389	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
255	23	97	revisión	2023-06-27 04:13:57.132192	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
259	21	98	revisión	2023-07-31 18:39:59.064379	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
306	21	117	revisión	2024-04-07 19:40:49.12221	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
261	23	99	revisión	2023-03-19 09:50:49.829701	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
262	135	100	envío	2023-06-30 05:49:13.535732	Solicitud registrada y pendiente de revisión del supervisor.
279	104	108	envío	2024-06-05 23:11:44.348237	Solicitud registrada y pendiente de revisión del supervisor.
280	22	108	revisión	2024-06-19 13:26:44.652742	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.
264	136	101	envío	2023-04-01 20:38:46.262713	Solicitud registrada y pendiente de revisión del supervisor.
287	145	111	envío	2024-09-26 04:27:47.308895	Solicitud registrada y pendiente de revisión del supervisor.
266	137	102	envío	2024-05-13 10:54:58.29451	Solicitud registrada y pendiente de revisión del supervisor.
288	21	111	revisión	2024-09-30 20:14:36.658237	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.
268	138	103	envío	2024-08-12 04:08:21.240532	Solicitud registrada y pendiente de revisión del supervisor.
290	21	111	revisión	2024-10-25 19:27:22.343679	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
281	143	109	envío	2024-09-04 15:18:58.946538	Solicitud registrada y pendiente de revisión del supervisor.
282	23	109	revisión	2024-09-12 17:44:22.250724	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
284	21	109	revisión	2024-10-02 19:06:27.958034	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
318	23	123	revisión	2024-04-26 18:16:19.007543	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
294	123	112	reenvío	2024-07-30 21:26:02.72772	Versión corregida registrada y pendiente de revisión del supervisor.
285	144	110	envío	2024-03-07 04:40:23.261771	Solicitud registrada y pendiente de revisión del supervisor.
308	22	118	revisión	2024-09-29 06:56:56.177987	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
296	146	113	envío	2024-07-30 03:01:58.7298	Solicitud registrada y pendiente de revisión del supervisor.
309	150	119	envío	2024-08-17 20:33:17.848493	Solicitud registrada y pendiente de revisión del supervisor.
298	147	114	envío	2024-09-29 08:18:37.815957	Solicitud registrada y pendiente de revisión del supervisor.
312	21	120	revisión	2024-11-10 21:32:58.351401	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
300	148	115	envío	2024-08-20 16:46:43.801735	Solicitud registrada y pendiente de revisión del supervisor.
313	152	121	envío	2024-05-14 06:53:08.717728	Solicitud registrada y pendiente de revisión del supervisor.
319	92	124	envío	2024-04-07 09:56:44.6477	Solicitud registrada y pendiente de revisión del supervisor.
316	22	122	revisión	2024-10-05 08:31:08.872718	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
325	156	126	reenvío	2024-08-19 09:16:46.11849	Versión corregida registrada y pendiente de revisión del supervisor.
328	21	127	revisión	2024-04-28 01:11:22.522284	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
256	133	98	envío	2023-07-09 00:58:30.832042	Solicitud registrada y pendiente de revisión del supervisor.
234	125	90	reenvío	2023-05-22 17:47:09.994881	Versión corregida registrada y pendiente de revisión del supervisor.
235	22	90	revisión	2023-05-29 10:52:15.290176	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.
257	22	98	revisión	2023-07-20 01:15:13.235389	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
236	126	91	envío	2023-06-07 22:53:00.596872	Solicitud registrada y pendiente de revisión del supervisor.
258	133	98	reenvío	2023-07-29 15:37:27.666543	Versión corregida registrada y pendiente de revisión del supervisor.
239	21	92	revisión	2023-07-04 18:21:19.666724	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
289	145	111	reenvío	2024-10-13 00:30:46.024339	Versión corregida registrada y pendiente de revisión del supervisor.
291	22	111	retiro	2024-12-02 00:09:13.667534	Se detectaron datos personales de participantes en el documento.
260	134	99	envío	2023-03-08 10:19:13.410007	Solicitud registrada y pendiente de revisión del supervisor.
263	23	100	revisión	2023-07-06 21:55:47.935613	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
265	23	101	revisión	2023-04-03 22:54:14.653284	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
240	128	93	envío	2023-09-19 03:27:19.377397	Solicitud registrada y pendiente de revisión del supervisor.
241	22	93	revisión	2023-09-30 01:55:02.754982	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
242	128	93	reenvío	2023-10-12 18:43:53.153139	Versión corregida registrada y pendiente de revisión del supervisor.
245	23	94	revisión	2023-07-01 21:34:51.639472	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
301	21	115	revisión	2024-09-02 14:44:48.128883	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
267	22	102	revisión	2024-05-15 20:00:53.642747	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
246	130	95	envío	2023-09-26 14:21:51.962013	Solicitud registrada y pendiente de revisión del supervisor.
247	21	95	revisión	2023-10-03 00:54:05.321107	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
249	22	95	revisión	2023-10-13 21:16:21.066898	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
269	22	103	revisión	2024-08-18 15:13:01.593856	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
250	131	96	envío	2023-05-30 18:00:32.390653	Solicitud registrada y pendiente de revisión del supervisor.
271	23	104	revisión	2024-08-27 10:27:11.506444	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.
254	132	97	reenvío	2023-06-22 06:19:26.748078	Versión corregida registrada y pendiente de revisión del supervisor.
273	23	105	revisión	2024-07-26 15:58:34.138518	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
311	151	120	envío	2024-10-28 06:04:14.960206	Solicitud registrada y pendiente de revisión del supervisor.
276	22	106	revisión	2024-11-20 11:36:11.073016	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
302	124	116	envío	2024-05-13 08:22:39.76164	Solicitud registrada y pendiente de revisión del supervisor.
277	142	107	envío	2024-03-29 01:01:34.71129	Solicitud registrada y pendiente de revisión del supervisor.
304	22	116	retiro	2024-09-01 23:29:53.40412	La institución colaboradora solicitó no divulgar los resultados.
283	143	109	reenvío	2024-09-25 20:15:09.604322	Versión corregida registrada y pendiente de revisión del supervisor.
286	21	110	revisión	2024-03-16 14:19:54.624551	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
292	123	112	envío	2024-07-03 13:32:34.981855	Solicitud registrada y pendiente de revisión del supervisor.
314	21	121	revisión	2024-05-25 09:59:24.141896	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
293	21	112	revisión	2024-07-17 19:44:51.354658	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
295	21	112	revisión	2024-08-12 00:26:10.081494	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
297	23	113	revisión	2024-08-02 06:27:46.161873	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
305	53	117	envío	2024-03-25 14:36:26.754713	Solicitud registrada y pendiente de revisión del supervisor.
299	23	114	revisión	2024-10-04 13:18:35.167055	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
323	156	126	envío	2024-08-04 10:32:59.365624	Solicitud registrada y pendiente de revisión del supervisor.
315	153	122	envío	2024-09-20 11:37:41.500765	Solicitud registrada y pendiente de revisión del supervisor.
307	149	118	envío	2024-09-24 02:59:37.80986	Solicitud registrada y pendiente de revisión del supervisor.
310	23	119	revisión	2024-08-25 16:06:17.249839	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
321	155	125	envío	2024-06-13 16:37:11.644369	Solicitud registrada y pendiente de revisión del supervisor.
322	23	125	revisión	2024-06-16 22:22:08.011096	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
317	154	123	envío	2024-04-19 18:47:49.640075	Solicitud registrada y pendiente de revisión del supervisor.
324	23	126	revisión	2024-08-08 01:49:14.71028	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
320	23	124	revisión	2024-04-15 22:41:45.984538	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
326	22	126	revisión	2024-08-28 16:14:07.469226	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
329	158	128	envío	2024-03-20 11:51:24.20424	Solicitud registrada y pendiente de revisión del supervisor.
327	157	127	envío	2024-04-21 06:05:20.151789	Solicitud registrada y pendiente de revisión del supervisor.
330	22	128	revisión	2024-03-26 04:52:18.574677	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
331	158	128	reenvío	2024-04-07 18:28:22.955909	Versión corregida registrada y pendiente de revisión del supervisor.
333	133	129	envío	2024-08-24 09:41:44.048595	Solicitud registrada y pendiente de revisión del supervisor.
334	21	129	revisión	2024-09-02 08:57:28.419779	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.
338	22	131	revisión	2024-04-05 16:24:53.863486	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
332	21	128	revisión	2024-04-17 05:04:48.319022	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
365	169	141	envío	2025-09-12 20:12:30.273366	Solicitud registrada y pendiente de revisión del supervisor.
335	159	130	envío	2024-08-07 10:18:09.771789	Solicitud registrada y pendiente de revisión del supervisor.
336	21	130	revisión	2024-08-17 22:54:32.135373	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.
337	160	131	envío	2024-04-02 07:05:50.467214	Solicitud registrada y pendiente de revisión del supervisor.
382	22	147	revisión	2025-07-05 09:04:40.192888	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
341	161	132	reenvío	2024-04-24 20:11:02.967843	Versión corregida registrada y pendiente de revisión del supervisor.
344	21	133	revisión	2024-10-01 12:12:47.377196	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
367	143	142	envío	2025-03-05 22:54:10.282683	Solicitud registrada y pendiente de revisión del supervisor.
369	23	142	retiro	2025-06-02 18:41:09.962154	La institución colaboradora solicitó no divulgar los resultados.
345	163	134	envío	2024-11-12 21:40:41.057974	Solicitud registrada y pendiente de revisión del supervisor.
348	23	135	revisión	2024-05-21 20:19:20.596779	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
411	23	159	revisión	2025-04-18 11:05:01.55985	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
370	170	143	envío	2025-10-22 22:08:10.26789	Solicitud registrada y pendiente de revisión del supervisor.
350	22	136	revisión	2024-07-15 15:49:24.63808	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
351	21	136	destacado	2024-07-22 15:47:48.942795	Se marcó como trabajo destacado.
353	22	137	revisión	2024-06-16 05:45:42.937538	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
355	21	138	revisión	2025-06-13 13:18:47.616038	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
401	21	154	revisión	2025-04-16 18:56:16.259908	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
359	168	139	reenvío	2025-05-24 20:26:53.934263	Versión corregida registrada y pendiente de revisión del supervisor.
360	23	139	revisión	2025-06-01 04:26:11.266673	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
383	175	148	envío	2025-04-13 00:31:59.864704	Solicitud registrada y pendiente de revisión del supervisor.
385	23	148	retiro	2025-07-12 03:41:52.514358	Los autores pidieron retirar la publicación para enviarla a una revista científica.
361	139	140	envío	2025-07-18 21:48:10.593485	Solicitud registrada y pendiente de revisión del supervisor.
362	21	140	revisión	2025-07-25 20:22:51.937078	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
364	21	140	revisión	2025-08-07 12:42:27.645314	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
386	176	149	envío	2025-11-04 06:05:56.803444	Solicitud registrada y pendiente de revisión del supervisor.
428	23	166	revisión	2025-07-30 23:35:05.641679	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
402	180	155	envío	2025-06-15 06:35:37.880731	Solicitud registrada y pendiente de revisión del supervisor.
390	128	150	reenvío	2025-10-22 20:08:42.507032	Versión corregida registrada y pendiente de revisión del supervisor.
372	171	144	envío	2025-02-05 09:59:10.24998	Solicitud registrada y pendiente de revisión del supervisor.
373	23	144	revisión	2025-02-12 08:42:16.582257	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
375	21	144	revisión	2025-02-25 12:35:11.308815	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
376	21	144	destacado	2025-03-11 12:06:42.615623	Se marcó como trabajo destacado.
377	172	145	envío	2025-10-23 21:45:48.233041	Solicitud registrada y pendiente de revisión del supervisor.
380	23	146	revisión	2025-07-27 04:54:35.218917	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
394	68	151	reenvío	2025-10-15 00:13:10.19818	Versión corregida registrada y pendiente de revisión del supervisor.
395	22	151	revisión	2025-10-26 21:32:14.534444	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
412	183	160	envío	2025-06-08 15:31:29.209648	Solicitud registrada y pendiente de revisión del supervisor.
396	177	152	envío	2025-11-14 18:29:33.860697	Solicitud registrada y pendiente de revisión del supervisor.
404	181	156	envío	2025-06-02 06:15:12.965051	Solicitud registrada y pendiente de revisión del supervisor.
399	23	153	revisión	2025-06-08 12:56:16.22716	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
423	186	164	envío	2025-09-10 09:24:52.354145	Solicitud registrada y pendiente de revisión del supervisor.
406	112	157	envío	2025-07-25 12:02:47.030581	Solicitud registrada y pendiente de revisión del supervisor.
414	155	161	envío	2025-10-17 22:21:43.831697	Solicitud registrada y pendiente de revisión del supervisor.
408	182	158	envío	2025-08-29 11:33:05.093157	Solicitud registrada y pendiente de revisión del supervisor.
419	23	162	revisión	2025-09-29 10:11:49.735625	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
431	189	167	reenvío	2025-04-05 19:15:35.007497	Versión corregida registrada y pendiente de revisión del supervisor.
421	21	163	revisión	2025-07-30 10:56:02.740964	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
425	187	165	envío	2025-04-05 19:52:49.26146	Solicitud registrada y pendiente de revisión del supervisor.
438	23	170	revisión	2025-05-03 01:11:27.629305	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
434	21	168	revisión	2025-03-29 22:38:45.010316	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
439	193	171	envío	2025-08-03 05:05:21.942469	Solicitud registrada y pendiente de revisión del supervisor.
441	194	172	envío	2025-03-04 12:02:37.59221	Solicitud registrada y pendiente de revisión del supervisor.
442	23	172	revisión	2025-03-08 02:41:59.911335	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
443	194	172	reenvío	2025-03-21 00:03:50.255117	Versión corregida registrada y pendiente de revisión del supervisor.
424	23	164	revisión	2025-09-15 18:46:59.687337	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
368	21	142	revisión	2025-03-13 10:38:45.664276	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
371	23	143	revisión	2025-11-05 02:05:56.633442	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
409	22	158	revisión	2025-09-09 08:24:25.479386	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
339	161	132	envío	2024-04-11 05:00:49.209083	Solicitud registrada y pendiente de revisión del supervisor.
340	21	132	revisión	2024-04-21 05:31:40.554699	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
342	23	132	revisión	2024-04-27 19:45:29.319763	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
343	162	133	envío	2024-09-24 14:04:37.982672	Solicitud registrada y pendiente de revisión del supervisor.
374	171	144	reenvío	2025-02-20 03:31:26.940954	Versión corregida registrada y pendiente de revisión del supervisor.
346	22	134	revisión	2024-11-18 08:41:30.463443	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
378	23	145	revisión	2025-10-30 21:23:33.58109	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
347	164	135	envío	2024-05-07 20:19:08.182154	Solicitud registrada y pendiente de revisión del supervisor.
435	191	169	envío	2025-06-18 03:31:49.649231	Solicitud registrada y pendiente de revisión del supervisor.
392	68	151	envío	2025-10-05 06:01:08.509174	Solicitud registrada y pendiente de revisión del supervisor.
349	165	136	envío	2024-07-04 21:42:10.257551	Solicitud registrada y pendiente de revisión del supervisor.
379	173	146	envío	2025-07-19 11:33:45.876298	Solicitud registrada y pendiente de revisión del supervisor.
352	166	137	envío	2024-06-04 09:09:41.596409	Solicitud registrada y pendiente de revisión del supervisor.
393	23	151	revisión	2025-10-12 09:49:41.823156	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
354	167	138	envío	2025-05-30 22:16:18.266998	Solicitud registrada y pendiente de revisión del supervisor.
356	21	138	retiro	2025-07-10 02:16:17.911813	Se detectaron datos personales de participantes en el documento.
381	174	147	envío	2025-07-02 20:18:34.828552	Solicitud registrada y pendiente de revisión del supervisor.
410	130	159	envío	2025-04-14 01:53:55.163071	Solicitud registrada y pendiente de revisión del supervisor.
384	21	148	revisión	2025-04-26 23:57:06.203104	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
357	168	139	envío	2025-05-06 18:43:27.250555	Solicitud registrada y pendiente de revisión del supervisor.
358	23	139	revisión	2025-05-21 13:33:57.588359	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
397	23	152	revisión	2025-11-17 08:45:54.236502	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
363	139	140	reenvío	2025-07-29 13:52:25.31125	Versión corregida registrada y pendiente de revisión del supervisor.
387	21	149	revisión	2025-11-08 03:06:19.137716	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
366	22	141	revisión	2025-09-22 07:14:17.641072	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
413	22	160	revisión	2025-06-18 08:52:01.530866	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
398	178	153	envío	2025-05-25 21:09:25.869552	Solicitud registrada y pendiente de revisión del supervisor.
416	184	162	envío	2025-08-24 14:41:07.731759	Solicitud registrada y pendiente de revisión del supervisor.
400	179	154	envío	2025-04-02 21:30:55.918236	Solicitud registrada y pendiente de revisión del supervisor.
388	128	150	envío	2025-10-05 14:18:18.773214	Solicitud registrada y pendiente de revisión del supervisor.
389	21	150	revisión	2025-10-16 22:02:10.1288	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.
391	21	150	revisión	2025-11-03 16:54:19.868822	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
415	21	161	revisión	2025-10-30 05:07:06.153858	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
403	21	155	revisión	2025-06-20 19:28:11.234439	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
405	21	156	revisión	2025-06-11 04:22:22.34237	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
417	23	162	revisión	2025-09-06 11:20:52.053295	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
407	22	157	revisión	2025-08-05 01:35:18.410546	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
418	184	162	reenvío	2025-09-21 04:23:22.38772	Versión corregida registrada y pendiente de revisión del supervisor.
426	22	165	revisión	2025-04-09 13:20:49.5887	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
436	21	169	revisión	2025-06-27 12:07:18.984903	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.
433	190	168	envío	2025-03-22 03:42:44.641749	Solicitud registrada y pendiente de revisión del supervisor.
427	188	166	envío	2025-07-19 21:12:16.208369	Solicitud registrada y pendiente de revisión del supervisor.
420	185	163	envío	2025-07-18 03:28:03.378001	Solicitud registrada y pendiente de revisión del supervisor.
422	22	163	retiro	2025-09-03 15:05:12.067652	Los autores pidieron retirar la publicación para enviarla a una revista científica.
429	189	167	envío	2025-04-01 03:10:30.323196	Solicitud registrada y pendiente de revisión del supervisor.
430	21	167	revisión	2025-04-03 13:56:15.659404	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
432	23	167	revisión	2025-04-15 14:11:07.342423	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
437	192	170	envío	2025-04-25 16:03:27.280352	Solicitud registrada y pendiente de revisión del supervisor.
440	21	171	revisión	2025-08-09 03:16:37.290912	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
444	22	172	revisión	2025-04-03 23:46:47.564293	Decisión del supervisor: Rechazada. Este trabajo ya fue registrado en el repositorio por otro integrante del grupo.
448	196	174	envío	2025-10-26 02:31:51.789741	Solicitud registrada y pendiente de revisión del supervisor.
446	23	173	revisión	2025-09-27 01:06:36.188436	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
456	201	179	envío	2026-06-05 00:40:47.60319	Solicitud registrada y pendiente de revisión del supervisor.
445	195	173	envío	2025-09-14 12:08:13.864117	Solicitud registrada y pendiente de revisión del supervisor.
447	23	173	retiro	2025-11-02 07:28:18.475182	La institución colaboradora solicitó no divulgar los resultados.
449	23	174	revisión	2025-10-28 18:29:17.130203	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
450	197	175	envío	2026-11-22 03:43:56.724639	Solicitud registrada y pendiente de revisión del supervisor.
451	198	176	envío	2026-11-20 13:02:08.036359	Solicitud registrada y pendiente de revisión del supervisor.
452	23	176	revisión	2026-11-22 10:36:39.348093	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.
453	199	177	envío	2026-11-19 23:01:37.645657	Solicitud registrada y pendiente de revisión del supervisor.
454	22	177	revisión	2026-11-21 11:12:55.98288	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
455	200	178	envío	2026-11-21 19:00:41.281019	Solicitud registrada y pendiente de revisión del supervisor.
457	21	179	revisión	2026-06-10 20:37:27.909515	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
459	23	179	revisión	2026-06-30 04:18:02.582634	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
460	83	180	envío	2026-11-16 00:59:59.218826	Solicitud registrada y pendiente de revisión del supervisor.
461	21	180	revisión	2026-11-18 19:22:01.541351	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
465	23	181	revisión	2026-09-15 10:32:01.905558	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.
470	204	184	envío	2026-05-28 11:07:11.578109	Solicitud registrada y pendiente de revisión del supervisor.
472	205	185	envío	2026-11-22 07:32:56.249189	Solicitud registrada y pendiente de revisión del supervisor.
473	206	186	envío	2026-04-07 00:07:26.605777	Solicitud registrada y pendiente de revisión del supervisor.
475	207	187	envío	2026-07-17 04:48:04.255202	Solicitud registrada y pendiente de revisión del supervisor.
513	219	204	envío	2026-04-28 11:40:15.334293	Solicitud registrada y pendiente de revisión del supervisor.
458	201	179	reenvío	2026-06-17 22:51:59.246045	Versión corregida registrada y pendiente de revisión del supervisor.
462	83	180	reenvío	2026-11-19 13:11:52.889939	Versión corregida registrada y pendiente de revisión del supervisor.
463	21	180	revisión	2026-11-20 19:54:31.238825	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
464	122	181	envío	2026-09-06 17:00:14.551198	Solicitud registrada y pendiente de revisión del supervisor.
485	156	192	envío	2026-07-01 06:27:50.63215	Solicitud registrada y pendiente de revisión del supervisor.
466	202	182	envío	2026-11-20 23:00:38.235065	Solicitud registrada y pendiente de revisión del supervisor.
467	22	182	revisión	2026-11-21 08:28:03.587391	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
486	21	192	revisión	2026-07-05 09:08:36.940353	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
468	203	183	envío	2026-11-20 20:16:02.918121	Solicitud registrada y pendiente de revisión del supervisor.
469	21	183	revisión	2026-11-21 05:46:09.261983	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
471	23	184	revisión	2026-05-30 15:01:31.921746	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.
474	23	186	revisión	2026-04-13 06:17:55.960051	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.
476	22	187	revisión	2026-07-26 23:55:04.629861	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
487	156	192	reenvío	2026-07-08 07:32:43.286208	Versión corregida registrada y pendiente de revisión del supervisor.
477	151	188	envío	2026-07-07 18:00:34.953754	Solicitud registrada y pendiente de revisión del supervisor.
478	21	188	revisión	2026-07-16 01:58:01.306206	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
488	21	192	revisión	2026-07-14 07:36:32.671263	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
489	209	193	envío	2026-11-21 09:16:34.998017	Solicitud registrada y pendiente de revisión del supervisor.
479	129	189	envío	2026-11-17 02:31:20.615673	Solicitud registrada y pendiente de revisión del supervisor.
480	21	189	revisión	2026-11-18 07:23:48.941216	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.
481	129	189	reenvío	2026-11-21 02:50:27.333942	Versión corregida registrada y pendiente de revisión del supervisor.
482	90	190	envío	2026-11-20 17:22:30.673394	Solicitud registrada y pendiente de revisión del supervisor.
483	208	191	envío	2026-11-19 03:05:07.010721	Solicitud registrada y pendiente de revisión del supervisor.
484	22	191	revisión	2026-11-21 04:57:49.334346	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
503	215	200	envío	2026-11-21 04:31:55.760165	Solicitud registrada y pendiente de revisión del supervisor.
504	23	200	revisión	2026-11-22 10:02:38.059182	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.
490	210	194	envío	2026-11-20 00:46:50.316049	Solicitud registrada y pendiente de revisión del supervisor.
491	23	194	revisión	2026-11-21 07:57:46.638691	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.
492	211	195	envío	2026-11-20 20:54:15.936625	Solicitud registrada y pendiente de revisión del supervisor.
493	212	196	envío	2026-11-21 15:50:37.273565	Solicitud registrada y pendiente de revisión del supervisor.
497	214	198	envío	2026-09-22 16:47:01.541647	Solicitud registrada y pendiente de revisión del supervisor.
498	22	198	revisión	2026-10-01 14:30:06.859247	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
494	213	197	envío	2026-11-18 07:55:16.581762	Solicitud registrada y pendiente de revisión del supervisor.
495	22	197	revisión	2026-11-20 01:33:27.888545	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
496	213	197	reenvío	2026-11-21 20:42:53.223486	Versión corregida registrada y pendiente de revisión del supervisor.
505	216	201	envío	2026-11-22 02:47:28.346744	Solicitud registrada y pendiente de revisión del supervisor.
499	214	198	reenvío	2026-10-10 20:15:48.204653	Versión corregida registrada y pendiente de revisión del supervisor.
500	23	198	revisión	2026-10-18 04:22:06.536142	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
501	136	199	envío	2026-08-14 11:33:36.831918	Solicitud registrada y pendiente de revisión del supervisor.
502	23	199	revisión	2026-08-25 02:41:50.172626	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
511	218	203	envío	2026-10-11 19:10:02.334941	Solicitud registrada y pendiente de revisión del supervisor.
512	21	203	revisión	2026-10-14 04:56:45.702337	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
506	217	202	envío	2026-06-26 16:43:15.669105	Solicitud registrada y pendiente de revisión del supervisor.
507	22	202	revisión	2026-07-07 17:23:42.014723	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
508	217	202	reenvío	2026-07-15 06:31:09.371065	Versión corregida registrada y pendiente de revisión del supervisor.
509	22	202	revisión	2026-07-21 17:57:40.719118	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
510	22	202	retiro	2026-10-27 07:47:11.024382	Se detectaron datos personales de participantes en el documento.
514	21	204	revisión	2026-05-03 07:45:33.670456	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
515	220	205	envío	2026-10-25 01:37:06.289426	Solicitud registrada y pendiente de revisión del supervisor.
516	22	205	revisión	2026-10-27 03:49:05.621251	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
517	220	205	actualización	2026-10-29 13:42:37.939713	Actualización del trabajo publicado pendiente de revisión del supervisor.
518	221	206	envío	2019-03-12 19:00:23.327902	Solicitud registrada y pendiente de revisión del supervisor.
519	22	206	revisión	2019-03-20 16:54:00.347827	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
520	21	206	destacado	2019-04-01 17:12:46.699899	Se marcó como trabajo destacado.
553	235	221	envío	2021-08-04 16:33:41.914404	Solicitud registrada y pendiente de revisión del supervisor.
521	222	207	envío	2019-09-19 15:36:24.387132	Solicitud registrada y pendiente de revisión del supervisor.
522	23	207	revisión	2019-09-29 06:54:54.781912	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
549	234	219	envío	2021-05-07 10:09:15.275388	Solicitud registrada y pendiente de revisión del supervisor.
523	223	208	envío	2020-06-24 18:29:11.509955	Solicitud registrada y pendiente de revisión del supervisor.
524	23	208	revisión	2020-06-27 18:11:49.892203	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.
537	229	214	envío	2020-04-10 18:55:03.901396	Solicitud registrada y pendiente de revisión del supervisor.
538	23	214	revisión	2020-04-14 12:50:43.367434	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
525	224	209	envío	2020-06-08 15:37:26.234581	Solicitud registrada y pendiente de revisión del supervisor.
526	21	209	revisión	2020-06-20 15:05:53.631943	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
550	21	219	revisión	2021-05-17 02:57:41.596585	Decisión del supervisor: Rechazada. El documento adjunto no corresponde al trabajo descrito en la ficha.
527	225	210	envío	2020-08-17 10:13:53.297914	Solicitud registrada y pendiente de revisión del supervisor.
528	22	210	revisión	2020-08-19 19:19:09.681912	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
554	23	221	revisión	2021-08-09 10:28:08.215175	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
539	230	215	envío	2020-06-04 09:22:08.990435	Solicitud registrada y pendiente de revisión del supervisor.
540	23	215	revisión	2020-06-11 08:50:38.347478	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
529	226	211	envío	2020-06-02 13:29:51.349377	Solicitud registrada y pendiente de revisión del supervisor.
530	23	211	revisión	2020-06-11 01:34:24.718604	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
531	227	212	envío	2020-07-02 16:47:36.343915	Solicitud registrada y pendiente de revisión del supervisor.
532	21	212	revisión	2020-07-13 17:47:54.69853	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
555	235	221	reenvío	2021-08-15 13:26:16.545862	Versión corregida registrada y pendiente de revisión del supervisor.
556	21	221	revisión	2021-08-28 20:02:18.886736	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
541	231	216	envío	2020-10-25 02:41:49.936219	Solicitud registrada y pendiente de revisión del supervisor.
542	21	216	revisión	2020-10-30 01:05:53.298119	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
551	234	220	envío	2021-08-24 11:08:11.898629	Solicitud registrada y pendiente de revisión del supervisor.
533	228	213	envío	2020-10-12 04:20:52.288574	Solicitud registrada y pendiente de revisión del supervisor.
534	22	213	revisión	2020-10-21 09:49:35.60907	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
535	228	213	reenvío	2020-11-01 16:24:33.189016	Versión corregida registrada y pendiente de revisión del supervisor.
536	23	213	revisión	2020-11-04 21:38:24.592575	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
552	21	220	revisión	2021-09-02 07:53:56.252112	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
543	232	217	envío	2021-07-11 04:39:48.926934	Solicitud registrada y pendiente de revisión del supervisor.
544	22	217	revisión	2021-07-20 22:00:21.263515	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
557	23	221	retiro	2021-09-28 05:39:24.210168	Se detectaron datos personales de participantes en el documento.
571	240	227	envío	2021-05-18 08:45:11.911962	Solicitud registrada y pendiente de revisión del supervisor.
545	233	218	envío	2021-04-22 06:06:36.871404	Solicitud registrada y pendiente de revisión del supervisor.
546	21	218	revisión	2021-05-06 23:26:30.181786	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
547	233	218	reenvío	2021-05-21 21:02:43.548142	Versión corregida registrada y pendiente de revisión del supervisor.
548	23	218	revisión	2021-05-28 03:50:56.929977	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
562	237	224	envío	2021-05-20 16:24:24.08331	Solicitud registrada y pendiente de revisión del supervisor.
563	23	224	revisión	2021-05-27 16:24:20.43361	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
558	236	222	envío	2021-11-23 22:35:44.516119	Solicitud registrada y pendiente de revisión del supervisor.
559	22	222	revisión	2021-12-05 10:33:28.849847	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
569	239	226	envío	2021-06-21 15:27:23.298391	Solicitud registrada y pendiente de revisión del supervisor.
560	236	223	envío	2021-06-26 11:33:13.488322	Solicitud registrada y pendiente de revisión del supervisor.
561	22	223	revisión	2021-07-06 12:57:02.797262	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.
570	22	226	revisión	2021-06-30 06:49:07.609264	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.
564	238	225	envío	2021-08-22 18:46:15.722735	Solicitud registrada y pendiente de revisión del supervisor.
565	22	225	revisión	2021-09-02 02:51:34.038819	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
566	238	225	reenvío	2021-09-14 23:28:44.366628	Versión corregida registrada y pendiente de revisión del supervisor.
567	22	225	revisión	2021-09-19 19:16:42.720384	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
568	21	225	destacado	2021-10-11 21:39:28.015059	Se marcó como trabajo destacado.
572	22	227	revisión	2021-05-25 10:24:19.228744	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
573	240	227	reenvío	2021-05-28 06:57:46.565213	Versión corregida registrada y pendiente de revisión del supervisor.
574	23	227	revisión	2021-06-01 08:51:34.917327	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
610	251	240	envío	2023-05-02 16:57:50.800545	Solicitud registrada y pendiente de revisión del supervisor.
593	246	235	envío	2022-04-29 23:18:30.364049	Solicitud registrada y pendiente de revisión del supervisor.
575	241	228	envío	2021-10-15 07:39:20.592027	Solicitud registrada y pendiente de revisión del supervisor.
576	21	228	revisión	2021-10-30 01:37:12.026709	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
594	22	235	revisión	2022-05-07 08:40:55.754061	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
611	23	240	revisión	2023-05-13 10:32:59.140605	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
577	242	229	envío	2021-03-07 15:35:21.772573	Solicitud registrada y pendiente de revisión del supervisor.
578	23	229	revisión	2021-03-18 09:18:26.127258	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
579	242	229	reenvío	2021-03-30 09:38:18.507555	Versión corregida registrada y pendiente de revisión del supervisor.
580	23	229	revisión	2021-04-05 10:14:20.883494	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
603	249	238	envío	2022-02-26 05:32:53.452918	Solicitud registrada y pendiente de revisión del supervisor.
581	231	230	envío	2021-04-04 21:36:10.213395	Solicitud registrada y pendiente de revisión del supervisor.
582	23	230	revisión	2021-04-11 16:15:44.608741	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
583	22	230	retiro	2021-08-02 19:47:22.961175	La institución colaboradora solicitó no divulgar los resultados.
604	23	238	revisión	2022-02-28 10:50:35.820317	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
595	247	236	envío	2022-10-20 05:10:29.097327	Solicitud registrada y pendiente de revisión del supervisor.
584	243	231	envío	2022-08-30 20:28:35.318943	Solicitud registrada y pendiente de revisión del supervisor.
585	23	231	revisión	2022-09-11 09:54:20.710618	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
586	21	231	destacado	2022-09-25 08:15:10.050181	Se marcó como trabajo destacado.
596	23	236	revisión	2022-10-25 22:44:18.482805	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
597	247	236	reenvío	2022-11-05 17:39:17.881228	Versión corregida registrada y pendiente de revisión del supervisor.
598	21	236	revisión	2022-11-19 19:59:08.297521	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
587	244	232	envío	2022-03-08 09:42:31.377769	Solicitud registrada y pendiente de revisión del supervisor.
588	21	232	revisión	2022-03-18 19:39:37.782459	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
605	23	238	retiro	2022-05-28 13:26:51.146701	Se detectaron datos personales de participantes en el documento.
589	245	233	envío	2022-05-24 01:14:17.507287	Solicitud registrada y pendiente de revisión del supervisor.
590	22	233	revisión	2022-06-07 16:10:11.91467	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
591	242	234	envío	2022-10-09 06:06:34.633495	Solicitud registrada y pendiente de revisión del supervisor.
592	23	234	revisión	2022-10-19 13:05:33.01058	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.
616	253	243	envío	2023-05-18 00:46:48.817903	Solicitud registrada y pendiente de revisión del supervisor.
617	23	243	revisión	2023-05-25 15:45:20.150484	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
612	252	241	envío	2023-06-23 09:39:53.743487	Solicitud registrada y pendiente de revisión del supervisor.
613	21	241	revisión	2023-06-27 17:40:00.080829	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
599	248	237	envío	2022-06-16 21:34:43.665465	Solicitud registrada y pendiente de revisión del supervisor.
600	23	237	revisión	2022-06-24 09:25:02.042754	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.
601	248	237	reenvío	2022-06-29 23:49:05.422615	Versión corregida registrada y pendiente de revisión del supervisor.
602	21	237	revisión	2022-07-07 03:41:52.805826	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
606	250	239	envío	2022-06-30 14:05:34.470767	Solicitud registrada y pendiente de revisión del supervisor.
607	21	239	revisión	2022-07-13 10:05:05.811216	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
608	250	239	reenvío	2022-07-22 12:33:44.181578	Versión corregida registrada y pendiente de revisión del supervisor.
609	23	239	revisión	2022-08-03 23:01:15.517116	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
618	253	243	reenvío	2023-06-01 06:29:55.508294	Versión corregida registrada y pendiente de revisión del supervisor.
619	21	243	revisión	2023-06-09 05:23:15.86428	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
620	23	243	retiro	2023-09-19 12:03:51.175902	La institución colaboradora solicitó no divulgar los resultados.
623	238	245	envío	2023-08-10 13:34:19.574491	Solicitud registrada y pendiente de revisión del supervisor.
614	226	242	envío	2023-11-03 17:27:34.752845	Solicitud registrada y pendiente de revisión del supervisor.
615	22	242	revisión	2023-11-09 15:13:09.140005	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
624	23	245	revisión	2023-08-12 23:41:39.949628	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
621	254	244	envío	2023-07-16 01:33:16.504915	Solicitud registrada y pendiente de revisión del supervisor.
622	21	244	revisión	2023-07-18 11:47:57.88962	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
625	255	246	envío	2023-03-23 08:07:54.28206	Solicitud registrada y pendiente de revisión del supervisor.
629	222	247	envío	2023-08-10 07:50:35.667569	Solicitud registrada y pendiente de revisión del supervisor.
626	22	246	revisión	2023-03-25 14:52:18.636948	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
631	256	248	envío	2023-08-12 18:14:29.679107	Solicitud registrada y pendiente de revisión del supervisor.
627	255	246	reenvío	2023-04-06 23:23:19.000766	Versión corregida registrada y pendiente de revisión del supervisor.
628	22	246	revisión	2023-04-19 21:39:59.341956	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.
630	22	247	revisión	2023-08-16 10:20:50.04425	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
633	257	249	envío	2023-06-05 13:07:19.725842	Solicitud registrada y pendiente de revisión del supervisor.
632	22	248	revisión	2023-08-17 11:51:56.052069	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
646	263	255	envío	2024-03-12 13:16:23.610962	Solicitud registrada y pendiente de revisión del supervisor.
634	22	249	revisión	2023-06-17 13:38:05.081198	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
647	23	255	revisión	2024-03-19 17:04:56.994633	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
635	258	250	envío	2023-04-30 06:53:42.736278	Solicitud registrada y pendiente de revisión del supervisor.
636	22	250	revisión	2023-05-05 21:05:52.090033	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.
648	263	255	reenvío	2024-03-22 07:28:25.409395	Versión corregida registrada y pendiente de revisión del supervisor.
637	259	251	envío	2023-11-28 15:38:39.416847	Solicitud registrada y pendiente de revisión del supervisor.
638	21	251	revisión	2023-12-11 22:33:55.808077	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
649	23	255	revisión	2024-04-03 04:47:29.80798	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
650	21	255	destacado	2024-04-28 07:34:26.15054	Se marcó como trabajo destacado.
639	260	252	envío	2023-10-25 10:56:51.136828	Solicitud registrada y pendiente de revisión del supervisor.
640	23	252	revisión	2023-11-05 12:10:19.499536	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
656	265	258	envío	2024-04-28 03:00:32.144799	Solicitud registrada y pendiente de revisión del supervisor.
657	21	258	revisión	2024-05-01 14:48:46.512571	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
641	261	253	envío	2024-03-08 06:50:39.151392	Solicitud registrada y pendiente de revisión del supervisor.
642	23	253	revisión	2024-03-11 17:15:30.536862	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
658	265	258	reenvío	2024-05-05 14:37:41.909715	Versión corregida registrada y pendiente de revisión del supervisor.
651	225	256	envío	2024-05-04 18:50:33.840772	Solicitud registrada y pendiente de revisión del supervisor.
652	21	256	revisión	2024-05-06 22:36:53.256238	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
659	22	258	revisión	2024-05-14 01:33:35.279881	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
643	262	254	envío	2024-10-13 12:06:25.19386	Solicitud registrada y pendiente de revisión del supervisor.
644	22	254	revisión	2024-10-24 06:00:26.57973	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
645	21	254	destacado	2024-11-03 16:52:33.918507	Se marcó como trabajo destacado.
660	21	258	destacado	2024-05-22 14:01:36.603276	Se marcó como trabajo destacado.
653	264	257	envío	2024-03-11 09:19:47.019601	Solicitud registrada y pendiente de revisión del supervisor.
654	22	257	revisión	2024-03-23 15:24:17.436979	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
655	22	257	retiro	2024-04-26 09:50:04.797943	La institución colaboradora solicitó no divulgar los resultados.
672	227	263	envío	2024-11-12 05:42:12.04642	Solicitud registrada y pendiente de revisión del supervisor.
673	21	263	revisión	2024-11-18 02:04:15.418041	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
684	273	268	envío	2024-09-11 07:56:52.254624	Solicitud registrada y pendiente de revisión del supervisor.
661	266	259	envío	2024-06-24 07:41:17.293843	Solicitud registrada y pendiente de revisión del supervisor.
662	21	259	revisión	2024-07-04 06:10:40.656372	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
663	21	259	destacado	2024-07-31 15:15:40.968308	Se marcó como trabajo destacado.
664	267	260	envío	2024-07-23 16:49:43.631526	Solicitud registrada y pendiente de revisión del supervisor.
680	271	266	envío	2024-09-21 08:14:45.154224	Solicitud registrada y pendiente de revisión del supervisor.
674	269	264	envío	2024-06-22 05:26:37.741439	Solicitud registrada y pendiente de revisión del supervisor.
675	22	264	revisión	2024-06-27 22:14:44.096872	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
665	22	260	revisión	2024-08-04 16:58:31.972066	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.
668	253	262	envío	2024-08-26 11:56:40.332388	Solicitud registrada y pendiente de revisión del supervisor.
669	21	262	revisión	2024-09-02 12:42:15.683072	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
666	268	261	envío	2024-09-09 01:43:00.300296	Solicitud registrada y pendiente de revisión del supervisor.
667	21	261	revisión	2024-09-13 17:46:42.676254	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
670	253	262	reenvío	2024-09-16 16:29:21.047655	Versión corregida registrada y pendiente de revisión del supervisor.
671	23	262	revisión	2024-09-21 14:13:10.413601	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
676	270	265	envío	2024-07-21 20:23:38.770128	Solicitud registrada y pendiente de revisión del supervisor.
681	22	266	revisión	2024-09-23 20:53:04.543495	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
677	23	265	revisión	2024-07-28 04:27:23.110716	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
678	270	265	reenvío	2024-07-31 13:16:11.473158	Versión corregida registrada y pendiente de revisión del supervisor.
679	21	265	revisión	2024-08-13 22:06:00.842132	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
682	272	267	envío	2024-04-23 20:01:25.236263	Solicitud registrada y pendiente de revisión del supervisor.
688	275	270	envío	2024-02-16 03:46:42.993669	Solicitud registrada y pendiente de revisión del supervisor.
683	23	267	revisión	2024-05-05 18:49:59.607577	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
685	23	268	revisión	2024-09-25 11:04:19.625714	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
686	274	269	envío	2024-09-07 15:14:59.290209	Solicitud registrada y pendiente de revisión del supervisor.
687	23	269	revisión	2024-09-20 19:35:52.674112	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
689	21	270	revisión	2024-03-01 15:24:08.337571	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
690	275	270	reenvío	2024-03-03 22:50:00.683726	Versión corregida registrada y pendiente de revisión del supervisor.
718	240	281	envío	2025-11-10 00:40:09.824017	Solicitud registrada y pendiente de revisión del supervisor.
691	23	270	revisión	2024-03-13 20:33:33.056238	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
692	21	270	retiro	2024-04-03 22:35:57.382813	Los autores pidieron retirar la publicación para enviarla a una revista científica.
719	21	281	revisión	2025-11-21 18:58:26.188345	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
693	257	271	envío	2024-11-08 15:30:16.713484	Solicitud registrada y pendiente de revisión del supervisor.
694	23	271	revisión	2024-11-14 12:07:10.085487	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
727	287	285	envío	2025-03-30 19:06:41.935529	Solicitud registrada y pendiente de revisión del supervisor.
695	276	272	envío	2024-07-07 19:13:54.759753	Solicitud registrada y pendiente de revisión del supervisor.
696	22	272	revisión	2024-07-13 21:20:48.12783	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
728	21	285	revisión	2025-04-13 01:47:51.282042	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.
708	280	277	envío	2025-04-22 06:07:44.285104	Solicitud registrada y pendiente de revisión del supervisor.
697	277	273	envío	2024-07-04 08:45:17.801208	Solicitud registrada y pendiente de revisión del supervisor.
698	23	273	revisión	2024-07-18 04:22:54.169562	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
699	21	273	destacado	2024-08-08 04:29:30.496851	Se marcó como trabajo destacado.
709	21	277	revisión	2025-05-06 23:27:37.653135	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
700	278	274	envío	2025-05-23 18:53:25.810479	Solicitud registrada y pendiente de revisión del supervisor.
701	21	274	revisión	2025-05-28 16:29:56.184029	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
710	280	277	reenvío	2025-05-21 21:03:51.017623	Versión corregida registrada y pendiente de revisión del supervisor.
711	23	277	revisión	2025-05-28 03:52:04.400606	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
702	224	275	envío	2025-09-08 11:00:24.514811	Solicitud registrada y pendiente de revisión del supervisor.
703	22	275	revisión	2025-09-21 02:08:07.899293	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
720	284	282	envío	2025-10-21 10:13:29.844519	Solicitud registrada y pendiente de revisión del supervisor.
712	281	278	envío	2025-05-18 20:21:25.731853	Solicitud registrada y pendiente de revisión del supervisor.
713	23	278	revisión	2025-05-30 03:51:05.107889	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
721	23	282	revisión	2025-11-05 04:01:44.223271	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
722	21	282	destacado	2025-12-04 17:14:00.541371	Se marcó como trabajo destacado.
704	279	276	envío	2025-09-29 14:47:45.540503	Solicitud registrada y pendiente de revisión del supervisor.
705	21	276	revisión	2025-10-08 13:18:58.873828	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
706	279	276	reenvío	2025-10-13 00:06:45.242253	Versión corregida registrada y pendiente de revisión del supervisor.
707	23	276	revisión	2025-10-25 13:04:15.626567	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
714	282	279	envío	2025-06-14 19:36:15.772093	Solicitud registrada y pendiente de revisión del supervisor.
715	22	279	revisión	2025-06-17 01:12:28.134358	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
737	291	289	envío	2025-05-30 05:34:59.506826	Solicitud registrada y pendiente de revisión del supervisor.
716	283	280	envío	2025-04-17 11:34:32.780517	Solicitud registrada y pendiente de revisión del supervisor.
717	21	280	revisión	2025-04-20 07:18:18.165224	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
738	21	289	revisión	2025-06-13 20:27:52.814365	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
735	290	288	envío	2025-05-24 05:35:09.451774	Solicitud registrada y pendiente de revisión del supervisor.
729	288	286	envío	2025-11-24 12:51:56.601117	Solicitud registrada y pendiente de revisión del supervisor.
723	285	283	envío	2025-07-10 13:04:10.863118	Solicitud registrada y pendiente de revisión del supervisor.
724	21	283	revisión	2025-07-12 21:16:09.2242	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
730	22	286	revisión	2025-11-28 21:53:51.990875	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
736	22	288	revisión	2025-05-30 03:12:07.821241	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
725	286	284	envío	2025-05-03 13:26:17.907199	Solicitud registrada y pendiente de revisión del supervisor.
726	21	284	revisión	2025-05-14 04:00:14.279837	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
731	289	287	envío	2025-09-24 20:44:09.650857	Solicitud registrada y pendiente de revisión del supervisor.
732	22	287	revisión	2025-10-05 03:09:19.99982	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
733	289	287	reenvío	2025-10-08 19:04:48.364922	Versión corregida registrada y pendiente de revisión del supervisor.
739	291	289	reenvío	2025-06-22 03:08:03.144684	Versión corregida registrada y pendiente de revisión del supervisor.
734	23	287	revisión	2025-10-21 01:10:15.73329	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
740	21	289	revisión	2025-06-25 21:03:05.469468	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
741	292	290	envío	2025-08-05 21:39:03.033292	Solicitud registrada y pendiente de revisión del supervisor.
747	294	292	envío	2025-05-08 14:55:45.197425	Solicitud registrada y pendiente de revisión del supervisor.
742	23	290	revisión	2025-08-10 15:54:16.342347	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
743	292	290	reenvío	2025-08-16 14:23:13.667719	Versión corregida registrada y pendiente de revisión del supervisor.
745	293	291	envío	2025-04-19 11:36:19.607911	Solicitud registrada y pendiente de revisión del supervisor.
746	22	291	revisión	2025-05-02 18:21:41.913122	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
744	23	290	revisión	2025-08-24 16:49:05.014216	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
748	21	292	revisión	2025-05-19 02:25:49.506755	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.
764	255	297	envío	2026-11-22 08:08:45.180104	Solicitud registrada y pendiente de revisión del supervisor.
777	304	303	envío	2026-05-28 04:12:34.606846	Solicitud registrada y pendiente de revisión del supervisor.
749	294	292	reenvío	2025-05-29 05:50:35.836683	Versión corregida registrada y pendiente de revisión del supervisor.
750	21	292	revisión	2025-06-10 13:08:45.175557	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
751	23	292	retiro	2025-08-10 18:46:42.470739	La institución colaboradora solicitó no divulgar los resultados.
765	299	298	envío	2026-11-20 08:28:22.495697	Solicitud registrada y pendiente de revisión del supervisor.
766	21	298	revisión	2026-11-21 20:21:35.801511	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.
778	21	303	revisión	2026-06-11 12:39:18.992687	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
767	300	299	envío	2026-11-20 04:23:26.086515	Solicitud registrada y pendiente de revisión del supervisor.
768	21	299	revisión	2026-11-21 09:07:41.407993	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
769	301	300	envío	2026-11-18 07:58:49.69521	Solicitud registrada y pendiente de revisión del supervisor.
752	295	293	envío	2026-03-21 22:48:51.768738	Solicitud registrada y pendiente de revisión del supervisor.
753	23	293	revisión	2026-04-01 16:41:53.080016	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.
754	295	293	reenvío	2026-04-05 06:21:21.407237	Versión corregida registrada y pendiente de revisión del supervisor.
755	23	293	revisión	2026-04-20 00:15:20.749328	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
756	21	293	destacado	2026-04-23 23:56:51.045532	Se marcó como trabajo destacado.
770	21	300	revisión	2026-11-20 20:58:28.014438	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.
771	301	300	reenvío	2026-11-21 23:11:39.348305	Versión corregida registrada y pendiente de revisión del supervisor.
757	296	294	envío	2026-11-17 05:57:24.651361	Solicitud registrada y pendiente de revisión del supervisor.
758	21	294	revisión	2026-11-20 01:54:49.956702	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
759	296	294	reenvío	2026-11-22 15:03:08.290534	Versión corregida registrada y pendiente de revisión del supervisor.
760	297	295	envío	2026-11-20 15:59:09.600281	Solicitud registrada y pendiente de revisión del supervisor.
761	23	295	revisión	2026-11-21 09:32:54.923995	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.
779	305	304	envío	2026-07-15 01:46:54.313046	Solicitud registrada y pendiente de revisión del supervisor.
762	298	296	envío	2026-09-01 04:16:30.221532	Solicitud registrada y pendiente de revisión del supervisor.
763	22	296	revisión	2026-09-04 19:01:47.556188	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
772	302	301	envío	2026-11-18 11:49:03.647498	Solicitud registrada y pendiente de revisión del supervisor.
773	23	301	revisión	2026-11-19 13:01:49.962059	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.
774	302	301	reenvío	2026-11-21 13:03:59.296276	Versión corregida registrada y pendiente de revisión del supervisor.
780	22	304	revisión	2026-07-22 15:58:36.695541	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
775	303	302	envío	2026-09-01 07:01:10.601473	Solicitud registrada y pendiente de revisión del supervisor.
776	23	302	revisión	2026-09-14 21:04:43.939992	Decisión del supervisor: Aprobada. Se publicó en el catálogo.
\.


--
-- Data for Name: tbl_materia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_materia (id_materia, codigo, nombre, descripcion) FROM stdin;
1	FPC115	Fundamentos de Programación	\N
2	ALV115	Álgebra Lineal y Vectorial	\N
3	FEM115	Fundamentos Empresariales	\N
4	CAD115	Cálculo Diferencial	\N
5	ISS115	Ingeniería de Sistemas y Sociedad	\N
7	TSI115	Teoría de Sistemas	\N
8	POO115	Programación Orientada a Objetos	\N
9	CAI115	Cálculo Integral	\N
10	MEC115	Mecánica Clásica	\N
11	ING115	Inglés I	\N
12	ESD215	Estructuras de Datos II	\N
13	APE115	Aplicaciones de Escritorio	\N
14	BAD115	Base de Datos I	\N
15	SCO115	Sistemas Contables	\N
16	CAM115	Cálculo Multivariable	\N
17	PPI115	Programación para Internet	\N
18	INR115	Ingeniería de Requerimientos	\N
19	BAD215	Base de Datos II	\N
20	ESB115	Estadística Básica	\N
21	EMA115	Electricidad y Magnetismo	\N
22	ING215	Inglés II	\N
23	FMP115	Fundamentos de Emprendimiento	\N
24	FPI115	Formulación y Evaluación de Proyectos Informáticos I	\N
25	DSI115	Diseño de Software	\N
26	ESA115	Estadística Aplicada	\N
28	FPI215	Formulación y Evaluación de Proyectos Informáticos II	\N
29	ASC115	Aseguramiento de la Calidad de Software	\N
30	ARS115	Arquitectura de Software I	\N
31	GTH115	Gestión del Talento Humano	\N
32	ING315	Inglés III	\N
34	ARS215	Arquitectura de Software II	\N
35	SIO115	Sistemas Operativos	\N
36	FDR115	Fundamentos de Redes	\N
37	MPS115	Mercadeo de Productos y Servicios de TI	\N
38	GPS115	Gestión de Proyectos de Desarrollo de Software	\N
39	MIP115	Microprogramación	\N
40	SEI115	Seguridad Informática	\N
41	ING415	Inglés IV	\N
42	GEI115	Gerencia Informática	\N
44	IAD115	Introducción a la Analítica de Datos	\N
45	DRD115	Diseño de Redes de Datos	\N
46	PLE115	Planeación Estratégica	\N
47	COS115	Continuidad de Servicios	\N
48	GRD115	Gestión de Redes de Datos	\N
49	GEC115	Gestión del Conocimiento	\N
50	TAG115	Taller de Grado	\N
6	ESD115	Estructura de Datos I	\N
27	ARC115	Arquitectura de Computadoras	\N
33	PAE115	Programación para Arquitectura Empresariales	\N
43	MEI115	Metodología de la Investigación Cientifica	\N
151	QUD4101	Química del Estado Sólido	\N
152	QIN156	Química Inorgánica	\N
153	PIA154	Psicología de la Infancia y la Adolescencia	\N
154	FID4101	Filosofía del Derecho	\N
155	AIOA158	Ambientes Internacionales y Operaciones Aeroportuarias	\N
156	CLQ7101	Clínica Quirúrgica	\N
157	PCI154	Psicología del Desarrollo Integral Infantil I (0 a 4 años)	\N
158	QOR4101	Química Orgánica I	\N
159	FEP4101	Formulación y Evaluación de Proyectos	\N
160	FIG154	Filosofía General	\N
162	DIF7201	Diagnóstico Físico II	\N
163	CSR4101	Cuidados en Sala de Recuperación, Paliativos y Clínica del Dolor Cuidados de Pacientes en Situaciones Especiales	\N
164	DTE255	Dibujo Técnico II	\N
166	GMA158	Gerencia de Marcas	\N
167	PDF115	Procesos de Fabricación I	\N
168	LFT2420	Investigación en Fisioterapia	\N
169	COF458	Contabilidad Financiera IV	\N
170	FVA4101	Fundamentos del Manejo de la Vía Aérea	\N
171	EPR158	Ética Profesional	\N
172	INGL158	Inglés I	\N
173	SEI159	Seminario de Educación Inclusiva	\N
174	BIG156	Biología General	\N
175	DPC154	Didáctica de la Psicomotricidad y la Educación Física	\N
176	IIM4101	Introducción a la Investigación Matemática	\N
177	EDC259	Estadística II	\N
178	MCL4101	Mecánica Clásica	\N
179	TOP215	Topografía Aplicada	\N
180	GED115	Geometría Descriptiva	\N
182	DTE155	Dibujo Técnico I	\N
184	TSD114	Teorías del Desarrollo	\N
185	PSI7201	Psiquiatría II	\N
186	PML154	Pragmalingüística	\N
187	ECD158	Econometría	\N
188	FIS4101	Física I	\N
189	EOR154	Expresión Oral y Escrita I	\N
190	SIP115	Sistemas de Potencia I	\N
191	LIS154	Literatura Salvadoreña	\N
192	PCO115	Procesos Constructivos	\N
193	SPG153	Seminario de Proceso de Grado	\N
194	ANU4101	Análisis Numérico	\N
195	LFT2455	Práctica Rotatoria de Fisioterapia en Hospitales I	\N
196	DBA4101	Diagnóstico Bacteriológico	\N
197	CLC259	Cálculo II	\N
198	FUD115	Fundamentos de Diseño I	\N
199	SMA154	Semántica	\N
200	SCC158	Sistemas Contables Computarizados	\N
201	PRS155	Psicología y Relaciones Sociolaborales	\N
202	ELP115	Electrónica de Potencia	\N
204	FMC159	Física I Mecánica	\N
205	SPV159	Seminario Prevención de la Violencia Intrafamiliar y de Género	\N
206	EDA154	Evaluación del Aprendizaje	\N
207	DCF159	Desarrollo Curricular de la Física	\N
208	FIM7101	Fisiología Médica I	\N
209	FHD154	Fonética Histórica del Español	\N
210	ECI158	Economía Internacional	\N
211	PSO154	Psicología Social	\N
212	EDS158	Economía Ecológica y Desarrollo Sostenible	\N
213	LFT2404	Fundamentos de Fisioterapia	\N
214	IIE115	Introducción a la Ingeniería Eléctrica	\N
215	GMT159	Geometría I	\N
216	CFC154	Conceptos Fundamentales de Ciencia Política	\N
217	DIC115	Dibujo para Ingeniería Civil	\N
218	QOR4301	Química Orgánica III	\N
219	MIP153	Manejo Integrado de Plagas	\N
220	SGE115	Sistemas de Generación Eléctrica	\N
1175	GRF4101	Gramática Francesa I	\N
221	FAD115	Fundamentos de Administración	\N
222	FSS4101	Física del Estado Sólido	\N
223	PCL4601	Práctica Clínica VI	\N
224	PAN154	Programas y Proyectos Comunitarios de Atención a la Niñez de 0 a 7 Años	\N
225	CPO158	Ciencias Políticas	\N
226	PHE114	Promoción Humana y Métodos de Educación	\N
227	BIS4101	Bioseguridad	\N
228	MEP7101	Medicación en Atención Primaria	\N
229	BEN154	Basic English	\N
230	GCS155	Gestión de la Cadena de Suministros	\N
231	MEI258	Mercadeo Internacional II	\N
232	FMQ156	Farmacoquímica	\N
233	MBP156	Microbiología y Parasitología	\N
234	LIE154	Literatura Española I	\N
235	BIO7101	Bioquímica	\N
236	EDI154	El Juego y el Desarrollo Infantil	\N
237	EDV114	Estadística Descriptiva Aplicada a las Ciencias Sociales	\N
238	TFC115	Transferencia de Calor	\N
239	PSG254	Psicología General II	\N
240	DIN158	Derecho Internacional	\N
241	IEP154	Introducción a la Evaluación Psicológica	\N
242	FTA4101	Fisiopatología en Anestesiología	\N
243	TER115	Termodinámica I	\N
244	VEM4101	Ventilación Mecánica I	\N
245	GAM4101	Oxigenoterapia y Aerosolterapia	\N
246	DIV4101	Diagnóstico Virológico	\N
247	TER115	Termodinámica	\N
248	GCL4101	Gestión de la Calidad	\N
249	DPT4101	Derecho Individual y Procesal del Trabajo	\N
250	GIC4101	Gestión Integral de la Calidad en Servicios de Laboratorio	\N
251	LFT2446	Diseño y Formulación de Proyectos de Investigación en Fisioterapia I	\N
252	FMA4301	Física Matemática III	\N
253	AFS4101	Anatomía Fisiológica	\N
254	ALI4201	Álgebra Lineal II	\N
255	PRF4101	Principios Fundamentales del Monitoreo	\N
256	CFA154	Conceptos Fundamentales de Antropología	\N
257	CAL4201	Cálculo II	\N
258	GEA153	Gestión Ambiental	\N
259	IFJ4101	Introducción a la Filosofía Jurídica	\N
260	MFC115	Mecánica de Fluidos	\N
262	RNA154	Realidad Nacional	\N
263	SEI159	Seminario Educación Inclusiva	\N
264	PRO4201	Programación II	\N
265	DGC158	Decisiones Gerenciales Sobre Costos	\N
266	FGE4101	Física General I	\N
267	IAI4201	Inglés Avanzado Intensivo II	\N
268	MEF115	Mecánica de Fluidos	\N
270	QAG153	Química Agrícola	\N
271	DMI4101	Diagnóstico Micológico	\N
272	PRO115	Programación de Obras	\N
273	PRO4101	Programación I	\N
274	IBI4102	Inglés Básico Intensivo I	\N
275	SOG158	Sociología General	\N
276	CHI4101	Cito-Histología	\N
277	MDM115	Mecánica de Materiales	\N
278	FFI4101	Fundamentos de Física	\N
279	LFT2421	Estrategias de Información, Educación y Comunicación en Salud	\N
280	GDP254	Gestión y Desarrollo de Personal II	\N
281	IAN4101	Introducción de la Anestesiología	\N
282	SEA159	Seminario Educación Ambiental y Cambio Climático	\N
283	DEM115	Diseño Espacial Multigenérico	\N
284	PEM158	Planeación Estratégica de Mercadeo	\N
285	CFE154	Conceptos Fundamentales de Economía	\N
286	EAG158	Economía Agrícola	\N
287	LFT2460	Práctica Rotatoria de Fisioterapia en Atención Primaria	\N
288	LFT2411	Control Motor	\N
289	PCG254	Psicopedagogía II	\N
290	FSC159	Física	\N
291	MAC158	Macroeconomía I	\N
292	GDC155	Gestión de la Calidad	\N
293	INPP158	Innovación y Proyectos productivos	\N
294	END154	English Curriculum Development	\N
295	GLS4101	Gestión Hospitalaria Legislación en Salud	\N
297	TPR158	Técnicas Presupuestarias	\N
298	LFT2436	Fisioterapia en Sistema Cardiovascular	\N
299	DIN155	Dinámica	\N
300	BMA4101	Biomatemática I	\N
301	AND7101	Análisis de la Situación de Salud	\N
302	QUG4101	Química General	\N
303	PDF215	Procesos de Fabricación II	\N
304	EST115	Estática	\N
305	PRA754	Práctica VII: Proyecto Sociocomunitario-Intersectorial	\N
307	DEM114	Demografía	\N
308	EPI114	Epistemología de las Ciencias Sociales	\N
309	BQI4101	Bioquímica Clínica	\N
310	RIE155	Responsabilidad de la Ingeniería en la Economía y la Sociedad	\N
311	MIG4101	Microbiología General	\N
312	FMA4201	Física Matemática II	\N
313	PCL4101	Práctica Clínica I	\N
314	BCC4101	Bioanálisis y Correlación Clínica	\N
315	INGL358	Inglés III	\N
316	PYE4101	Probabilidad y Estadística	\N
317	TEM4102	Tecnologías Emergentes en Entornos Multilingües	\N
318	QCL4101	Química Clínica	\N
319	CDI4101	Cálculo Diferencial	\N
320	TSA214	Teoría Sociológica Contemporánea II	\N
321	LFT2418	Cinesiterapia I	\N
322	QUO4101	Química Orgánica	\N
323	ASI158	Auditoría de Sistemas	\N
324	PGP154	Psicoterapia Grupal	\N
325	ACI4101	Atención de Paciente en Cuidado Crítico e Intensivos	\N
326	EVO4101	Evolución	\N
327	GPS114	Gestión, Monitoreo y Evaluación de Proyectos Sociales	\N
328	DPP4201	Derecho Procesal Penal II	\N
329	DAD4201	Derecho Administrativo II	\N
330	LFT2451	Fisioterapia en Otras Especialidades Médicas	\N
331	DAC115	Dibujo Mecánico Asistido por Computadora	\N
332	INB4101	Inglés Básico	\N
333	FNP4101	Física Nuclear y de Partículas	\N
334	QFI4201	Química Física II	\N
335	DCM4101	Derecho de las Obligaciones y Contratos Mercantiles	\N
336	DMS254	Didáctica del Conocimiento del Medio Social y Natural en la Educación Infantil de 0 a 7 años II	\N
337	INMI158	Investigación de Mercados Internacionales	\N
338	GME158	Gerencia de Mercadeo	\N
339	IHL154	Introducción e Historia de la Lingüística	\N
340	DIA115	Dibujo Arquitectónico	\N
341	FIS4301	Física III	\N
342	ENN7101	Enfermedades No Transmisibles en Atención Primaria	\N
343	MEI158	Mercadeo Internacional I	\N
345	PAU154	Psicología de la Persona Adulta	\N
346	FSF256	Físicofarmacia II	\N
347	ELB115	Electrónica Básica	\N
348	QPI115	Química para Ingeniería	\N
349	SCV114	Sociología del Conflicto y Violencia Social	\N
350	PSI7101	Psiquiatría I	\N
351	PEN154	Pedagogía General	\N
352	FIMG158	Filosofía de los Mercados Globales	\N
354	TEG154	Teoría Educativa y Legislación	\N
355	ESA115	Estática para Arquitectura	\N
356	FEP155	Formulación y Evaluación de Proyectos	\N
357	LEA115	Legislación Aplicada a la Práctica Profesional	\N
358	PCT115	Procesos Constructivos	\N
359	FPA115	Física para Arquitectura	\N
360	CIP115	Costos y Presupuestos	\N
361	MAT253	Matemática II	\N
362	LFT2452	Fisioterapia en Atención Primaria	\N
363	IPR4101	Introducción a la Programación	\N
364	GAS4101	Gases Sanguíneos	\N
365	CAD4101	Cálculo de Varias Variables	\N
366	QOR256	Química Orgánica II	\N
367	FIG153	Física General	\N
368	PRB4101	Probabilidad I	\N
369	INB159	Introducción a la Bioquímica	\N
370	HAL114	Historia de América Latina	\N
371	LFT2403	Fisiología General	\N
372	VEM4201	Ventilación Mecánica II	\N
373	PLC4201	Prácticas de Laboratorio Clínico II	\N
374	MTE115	Máquinas Térmicas	\N
375	EGR154	English Grammar I	\N
376	DIS154	Didáctica de las Ciencias Sociales	\N
377	MIM158	Metodología de la Investigación de Mercados	\N
378	CCO258	Contabilidad de Costos II	\N
379	TNE158	Técnicas de Negociación	\N
380	TNU4101	Teoría de Números	\N
381	MIS4201	Metodología de la Investigación II	\N
382	TET4101	Teoría del Estado	\N
384	INA7101	Introducción a la Atención Primaria en Salud	\N
385	CPE7101	Clínica Pediátrica	\N
386	CUE153	Cultivos Extensivos	\N
388	INI115	Introducción a la Ingeniería	\N
389	DGE159	Didáctica General	\N
390	GFE159	Geología Física de El Salvador	\N
391	PCL4401	Práctica Clínica IV	\N
392	IEE115	Instalaciones Eléctricas I	\N
393	PDI115	Proyecto de Ingeniería	\N
394	FEC4101	Filosofía y Ética de las Ciencias	\N
395	DCB4101	Derecho Civil: Bienes	\N
396	TLI354	Teoría Literaria III	\N
397	TAM115	Taller Mecánico	\N
398	EDD154	Evaluación Institucional y de Desempeño Docente	\N
399	DCH115	Diseño de Complejos Habitacionales	\N
400	PIM115	Proyecto de Ingeniería Mecánica	\N
401	FSC156	Física I	\N
402	MAT255	Matemática II	\N
403	PID154	Psicoterapia Individual	\N
404	MAF359	Matemática III	\N
405	LFT2410	Fisiología del Ejercicio	\N
406	PEP154	Psicología Educativa y del Aprendizaje	\N
407	DIB115	Dibujo Básico	\N
408	IQU4101	Investigación Química I	\N
409	IYC115	Instrumentación y Control	\N
410	ISP154	Intervención Psicopedagógica	\N
411	DHE4101	Diagnóstico Hematológico	\N
412	DCI154	Desarrollo Curricular de la Educación Infantil de 0 a 7 Años	\N
413	DAC115	Dibujo Técnico Asistido por Computadora	\N
414	BQU4101	Bioquímica	\N
415	IEE215	Instalaciones Eléctricas II	\N
416	DPL154	Didáctica del Desarrollo del Pensamiento Lógico-Matemático en la Educación Infantil de 0 a 7 Años I	\N
417	BOG159	Botánica General	\N
418	GCH155	Gestión del Capital Humano	\N
419	CCO158	Contabilidad de Costos I	\N
420	ETC254	Estudios Culturales II	\N
421	PSD7101	Psicología de la Salud I	\N
423	SPL4101	Salud Pública	\N
425	GEP115	Gestión de Proyectos	\N
426	EEN155	Eficiencia Energética	\N
427	PCL4501	Práctica Clínica V	\N
428	INM7101	Inmunología Médica	\N
429	POI4101	Pronunciación y Expresión Oral en Inglés	\N
431	ATP7101	Atención Primaria en el Ciclo de la Vida	\N
432	CAI4102	Comprensión Lectora y Auditiva en Inglés	\N
433	FCO4101	Física Computacional	\N
434	QFI4101	Química Física I	\N
435	CGU158	Contabilidad Gubernamental	\N
436	TAD158	Teoría Administrativa I	\N
437	LTN154	Latín	\N
438	FPR4101	Fisiopatología Respiratoria I	\N
439	CAL4401	Cálculo IV	\N
440	PES154	Psicología de la Educación y del Desarrollo	\N
441	TIE4101	Técnicas Instrumentales Espectroscópicas	\N
442	MOR254	Morfosintaxis II	\N
443	DPN4101	Derecho Penitenciario	\N
444	IPR154	Introducción a la Psicología de la Personalidad	\N
445	PQI4201	Procesos Químicos Industriales II	\N
446	RPA115	Representación Arquitectónica I	\N
447	TID255	Tecnología Industrial II	\N
448	DMU154	Didáctica de la Expresión Musical y Expresión Corporal en Infantil	\N
449	BFA156	Botánica General y Farmacéutica	\N
450	DNI115	Dinámica	\N
451	TAL354	Taller III	\N
452	IDO255	Investigación de Operaciones II	\N
453	SUR114	Sociología Urbana y Rural	\N
454	ADF158	Administración Financiera I	\N
455	FRE4101	Fisiología Respiratoria	\N
457	LFT2401	Biología Celular, Molecular y Bioquímica	\N
458	FAA159	Fundamentos de Anatomía y Fisiología Animal	\N
459	AGR153	Agronegocios	\N
460	FUQ4101	Fundamentos Químicos de Laboratorio Clínico	\N
461	TER215	Termodinámica II	\N
462	SIP215	Sistemas de Potencia II	\N
463	PPA115	Presupuesto del Proyecto Arquitectónico	\N
464	PDC259	Práctica Docente II	\N
465	PTG155	Protocolo de Trabajo de Graduación	\N
466	ESO154	Educación y Sociedad	\N
467	MAP4201	Manejo Anestésico de Pacientes en Situaciones Quirúrgicas de Especialidades Médicas II	\N
469	ANI156	Análisis Instrumental	\N
470	METP158	Métodos y Técnicas de Planificación	\N
471	QCI159	Química Inorgánica	\N
472	GRF4201	Gramática Francesa II	\N
473	PCG154	Psicopedagogía I	\N
474	MEA115	Medio Ambiente	\N
475	DGL154	Didáctica General I	\N
476	RAC154	Reading and Conversation	\N
477	MAT455	Matemática IV	\N
478	PCL4201	Práctica Clínica II	\N
479	QUG153	Química General	\N
480	GEM7101	Genética Médica	\N
481	ANB7101	Anatomía Patológica Básica	\N
482	PAR153	Parasitología	\N
483	AST154	Anatomía, Salud y Estimulación Temprana	\N
484	FSC256	Física II	\N
485	OECS158	Operadores Económicos y Cadenas de Suministros	\N
486	FIP4101	Fisiopatología	\N
487	ECD4201	Ecuaciones Diferenciales II	\N
488	INGL558	Inglés V	\N
489	LFT2428	Método de Intervención de Fisioterapia	\N
491	LFT2449	Fisioterapia en Cuidados Paliativos	\N
492	MEC4101	Mecánica Cuántica I	\N
493	RPA215	Representación Arquitectónica II	\N
494	TDU154	Tecnología y Educación	\N
495	MEM215	Mecánica de Materiales II	\N
496	LFT2422	Agentes Físicos en Fisioterapia	\N
497	PPF154	Práctica Profesional	\N
498	ALA4201	Álgebra Abstracta II	\N
499	FUT115	Fundamentos de Tribología	\N
500	EAP154	Estadística Aplicada a la Psicología	\N
501	AIA115	Aplicaciones Informáticas Avanzadas	\N
503	LFT2442	Fisioterapia en Neumología y Cardiología	\N
504	DIF7101	Diagnóstico Físico I	\N
505	ING458	Inglés IV	\N
506	ASE4101	Anestesia en Situaciones de Emergencia	\N
507	DLI254	Didáctica de la Lengua en la Educación Infantil de 0 a 7 Años II	\N
508	DCC115	Diseño de Complejos Comerciales	\N
509	FSF156	Físicofarmacia I	\N
510	QAR156	Química Industrial y Aprovechamiento de los Recursos Naturales y Renovables	\N
511	PSD7201	Psicología de la Salud II	\N
512	GEN4101	Genética	\N
513	FEX4101	Física Experimental	\N
514	HAB115	Hábitat	\N
515	FDE115	Fundamentos de Ingeniería Económica	\N
516	MEIN158	Metodología de la Investigación	\N
517	MTE159	Matemática	\N
518	SEM4102	Semiología	\N
519	DCU154	Desarrollo Personal, Profesional y Cultural	\N
520	FIM7201	Fisiología Médica II	\N
522	EAP154	Evaluación de los Aprendizajes	\N
523	CLC159	Cálculo I	\N
524	EMO158	Economía Monetaria	\N
525	EDF158	Economía de los Factores	\N
526	ZOO4101	Zoología I	\N
527	TED159	Tecnología y Educación	\N
529	LFT2459	Práctica Rotatoria de Fisioterapia en Área Deportiva	\N
530	EEI154	Estrategias de Educación Inclusiva	\N
531	LFT2444	Fisioterapia en Neurología	\N
532	LOA115	Lógica y Algoritmos	\N
533	LFT2402	Anatomía Humana I	\N
534	LIC154	Literatura Centroamericana	\N
535	SSO114	Sociología de las Desigualdades Sociales	\N
536	PHO153	Producción de Hortalizas	\N
537	TCA154	Las Tecnologías de la Información y la Comunicación Aplicadas a la Educación	\N
538	EDF114	Estadística Inferencial Aplicada a las Ciencias Sociales	\N
539	DAD4101	Derecho Administrativo I	\N
540	CTS115	Ciencia, Tecnología y Sociedad	\N
541	MAG153	Maquinaria Agrícola	\N
542	SSO115	Seguridad Eléctrica y Salud Ocupacional	\N
543	ATI115	Automatismo Industrial	\N
544	CAG158	Contabilidad Agrícola y Ganadera	\N
545	PSG154	Psicología General I	\N
546	INE158	Introducción a la Economía I	\N
547	SUE115	Subestaciones Eléctricas	\N
548	MER155	Mercadeo	\N
549	FGE159	Física General	\N
550	ESIN158	Estadística Informática	\N
551	ELNI158	Empresas Logísticas Nacionales e Internacionales	\N
552	IME155	Ingeniería de Métodos	\N
553	LFT2430	Cinesiterapia III	\N
554	EDP158	Ética y Desarrollo Profesional	\N
555	PQI4101	Procesos Químicos Industriales I	\N
556	BOA153	Botánica Agrícola	\N
557	CNA158	Cuentas Nacionales	\N
558	CIM115	Ciencia de los Materiales I	\N
559	GYO7201	Ginecología y Obstetricia II	\N
561	PYE115	Probabilidad y Estadística	\N
562	TES154	Teoría Sociológica	\N
563	PSP4101	Psicología para la Práctica Técnico Asistencial	\N
564	IEM159	Informática Especial de la Matemática	\N
565	FIV4101	Fisiología Vegetal	\N
566	SPR114	Sociología Prospectiva	\N
568	ALI4301	Álgebra Lineal III	\N
569	IGM7101	Inglés Médico	\N
570	LFT2441	Nutrición en Fisioterapia	\N
571	INGL458	Inglés IV	\N
572	ZGE159	Zoología general	\N
573	SDC158	Seminario de Contabilidad	\N
574	CIN258	Comercio Internacional II	\N
575	QAT159	Química Ambiental	\N
576	TAL254	Taller II	\N
577	PRA154	Práctica I: Introducción a la Investigación Educativa	\N
578	DPA115	Desarrollo del Proyecto Arquitectónico	\N
579	PED7101	Pediatría I	\N
580	CLP7101	Clínica Psiquiátrica	\N
581	FBI4101	Francés Básico Intensivo I	\N
583	TPO114	Teoría Política	\N
584	IQU4201	Investigación Química II	\N
585	MSU4101	Medicina del Sueño	\N
586	PSC154	Pedagogía Social y Comunitaria	\N
587	GIG4101	Gramática Inglesa I	\N
588	CLM7101	Clínica Médica	\N
589	CFC156	Control de Calidad de Productos Farmacéuticos y Cosméticos	\N
590	FAM7101	Farmacología Médica I	\N
591	MAT155	Matemática I	\N
592	COEL158	Comercio Electrónico	\N
593	APE158	Administración de Personal I	\N
594	EPI154	Evaluación y Tratamiento Psicológico Infantil	\N
595	QGE159	Química General	\N
596	ETA4101	Estadística	\N
597	PLPB158	Políticas Públicas	\N
598	DTE114	Desarrollo Territorial	\N
599	LFT2434	Inglés Técnico en Fisioterapia	\N
601	PSN114	Planificación Social y Económica	\N
602	IIB4101	Introducción a la Informática Biomédica	\N
603	MSS114	Movimientos Sociales	\N
604	QGE256	Química General II	\N
605	MDS115	Mecánica de Suelos	\N
606	ANP7101	Anatomía Patológica de Sistemas	\N
607	III4101	Inglés Intermedio Intensivo I	\N
608	ICR114	Investigación Sociocrítica	\N
609	NDT154	Neurodesarrollo y Estimulación Temprana	\N
610	FFS114	Filosofía Social	\N
611	LFT2458	Diseño y Formulación de Proyectos de Investigación en Fisioterapia II	\N
612	LFT2409	Anatomía Humana II	\N
613	GEE115	Gestión de Energía	\N
614	CIM215	Ciencia de los Materiales II	\N
615	MIC258	Microeconomía II	\N
616	PRO4102	Programación	\N
617	APH4101	Práctica Clínica de Atención Prehospitalaria I	\N
618	AYF4101	Anatomía y Fisiología I	\N
619	DCS4101	Derecho Civil: Sucesiones	\N
620	PES115	Perspectiva y Sombra	\N
621	DPC4201	Derecho Procesal II	\N
622	AES115	Análisis Estructural	\N
624	DER7201	Dermatología II	\N
625	MAS153	Manejo de Suelos	\N
626	RDC115	Redes de Computadoras	\N
627	BQU159	Bioquímica	\N
628	ANT7101	Antropología	\N
629	MAF259	Matemática II	\N
630	MOE115	Montaje Electromecánico	\N
631	MAF159	Matemática I	\N
632	SIG4101	Sistema de Información Geográfica	\N
633	SDH154	Seminario Derechos Humanos	\N
634	DEF159	Didáctica para la Enseñanza de la Física	\N
635	MBI4101	Microbiología	\N
636	EFA154	Educación, Comunidad y Familia	\N
637	SDH159	Seminario Derechos Humanos	\N
638	HII115	Herramientas Informáticas para Ingeniería	\N
639	SOR158	Sistemas Organizacionales	\N
640	PFP254	Psicoterapia Familiar y de Pareja II	\N
641	MPM4101	Microbiología y Parasitología Médica	\N
642	EAC159	Educación Ambiental y Cambio Climático	\N
643	TSS114	Teoría Sociológica Clásica	\N
644	MTI153	Métodos y Técnicas de Investigación	\N
645	TEL4101	Teoría Electromagnética I	\N
646	BQG156	Bioquímica General	\N
647	IPT154	Introducción a la Psicopatología	\N
648	QUI4101	Química Inorgánica	\N
649	GEA115	Geología Aplicada	\N
650	SIT115	Sistema de Información Territorial	\N
652	FUA115	Fundamentos de Arquitectura	\N
653	MTE156	Matemática I	\N
654	MEP153	Mejoramiento de Plantas	\N
655	DMS154	Didáctica del Conocimiento del Medio Social y Natural en la Educación Infantil de 0 a 7 Años I	\N
656	SMI4201	Seminario de Investigación II	\N
657	COF358	Contabilidad Financiera III	\N
658	TMA154	Territorio Población y Medio Ambiente I	\N
659	DPE4201	Derecho Penal II	\N
660	HMD154	Historia Mundial	\N
661	QGN4101	Química General I	\N
662	LFT2438	Fisioterapia en Sistema Nervioso	\N
663	AST159	Astronomía	\N
664	BIQ153	Bioquímica	\N
665	DGE154	Didáctica General	\N
666	ADO155	Análisis y Diseño Organizacional	\N
667	MCU154	Metodología de la Investigación Cualitativa	\N
668	ECP258	Economía Política II	\N
669	GIS154	Gestión Intersectorial	\N
670	DDH154	Democracia y Derechos Humanos	\N
671	CML154	Curso Monográfico de Lingüística	\N
672	ING558	Inglés V	\N
673	BAF4101	Bases Fisiológicas en Anestesiología	\N
674	FIG158	Filosofía General	\N
675	PPF154	Prácticas Profesionales I	\N
676	FAM4201	Farmacología II	\N
677	QAN4201	Química Analítica II	\N
678	PSI154	Personalidad Social e Individual	\N
679	QCU156	Química Analítica Cuantitativa	\N
680	GVE158	Gerencia de Ventas	\N
681	PSE154	Psicología de la Educación	\N
682	MAP4301	Manejo Anestésico de Pacientes en Situaciones Quirúrgicas de Especialidades Médicas III	\N
684	ADC215	Análisis de Circuitos II	\N
685	ART159	Aritmética	\N
686	CIN158	Comercio Internacional I	\N
687	GEM155	Gestión Empresarial	\N
688	FAI4201	Francés Avanzado Intensivo II	\N
689	PSL154	Psicología de la Salud	\N
690	PFC154	Procesos de Formación Centro Educativo, Familia y Comunidad	\N
691	TAL154	Taller I	\N
692	INT158	Inglés I	\N
693	SOR4101	Síntesis Orgánica	\N
694	ICP4101	Introducción a la Ciencia Política	\N
695	FIT153	Fitopatología	\N
696	ALG159	Álgebra I	\N
697	LPR155	Legislación Profesional	\N
698	CMC154	Cultura y Medios de Comunicación	\N
699	ISS4101	Inmunohematología y Servicios de Sangre	\N
700	FBI4201	Francés Básico Intensivo II	\N
701	AVE4101	Anatomía y Morfología Vegetal	\N
702	LFT2437	Fisioterapia en Sistema Musculoesquelético	\N
703	IEM115	Instrumentación y Medición I	\N
704	AUD258	Auditoría II	\N
705	QCG159	Química Orgánica I	\N
706	LFT2457	Práctica Rotatoria de Fisioterapia en Centros de Habilitación y Rehabilitación	\N
707	LFT2424	Cinesiterapia II	\N
708	SHN115	Sistemas Hidráulicos y Neumáticos	\N
709	HEC158	Historia Económica	\N
710	CYC155	Contabilidad y Costos	\N
711	LIU154	Literatura Universal I	\N
712	ERA4101	Ética y Regulación Aplicada	\N
713	INS4101	Interpretación Simultánea	\N
714	FUC4101	Fundamentos Científicos de la Investigación Jurídica	\N
715	CUO4101	Comunicación Oral y Escrita	\N
716	MIC158	Microeconomía I	\N
717	SDF155	Sólidos Deformables	\N
718	CAF4101	Comprensión Lectora y Auditiva en Francés	\N
719	DRE115	Diseño Sismo Resistente	\N
720	GPR154	Gestión y Prevención de Riesgo	\N
721	BIM7101	Bioquímica Médica	\N
722	MER158	Mercadotecnia I	\N
723	GEO4101	Geometría I	\N
724	TID355	Tecnología Industrial III	\N
725	FIS355	Física III	\N
726	PDT154	Psicología del Trabajo	\N
727	LFT2417	Examen Integral I	\N
728	PRA454	Práctica IV: Proyecto Socio-Comunitario	\N
730	SOP114	Sociología Política	\N
731	FMC359	Física III Electricidad y Magnetismo	\N
732	SLG154	Sociolingüística	\N
733	PFP154	Psicoterapia Familiar y de Pareja I	\N
734	EIN158	Economía Internacional	\N
735	FLC4101	Filosofía de la Ciencia	\N
736	MAC258	Macroeconomía II	\N
737	CEL115	Circuitos Eléctricos	\N
738	BGN159	Biología General	\N
739	CIM7101	Ciencias Morfológicas I	\N
740	ICS4101	Interpretación Consecutiva	\N
741	PDE159	Psicología de la Educación	\N
742	LPEC158	Logística II - Procesos de Exportación	\N
743	FES153	Fertilidad de Suelos	\N
744	LFT2435	Fisioterapia en Sistema Respiratorio	\N
745	GCE154	Gestión de la Calidad Educativa	\N
746	MDI154	Metodología de la Investigación	\N
747	DPC4301	Derecho Procesal III	\N
748	QUM7101	Química Médica	\N
749	DEM215	Diseño de Elementos de Máquinas II	\N
750	COM158	Computación I	\N
751	FDA155	Fundamentos de Administración	\N
752	CDS158	Contabilidad de Seguros	\N
753	AFI158	Administración Financiera I	\N
754	LFT2416	Anatomía Funcional	\N
755	PSO114	Psicología Social	\N
756	ENT7101	Enfermedades Transmisibles en Atención Primaria	\N
757	FIS4201	Física II	\N
758	SPV154	Seminario Prevención de la Violencia Intrafamiliar y de Género	\N
759	SOE4101	Sociedad, Economía y Derecho	\N
760	AAL115	Abastecimiento de Agua y Alcantarillados	\N
761	SMN154	Seminario	\N
762	III4201	Inglés Intermedio Intensivo II	\N
763	TFC156	Tecnología Farmacéutica y Cosmética	\N
764	ASO115	Administración y Supervisión de Obras	\N
765	PCL4301	Práctica Clínica III	\N
766	MED115	Metodología del Diseño	\N
767	DCU115	Diseño de Complejos Culturales	\N
768	CIM7301	Ciencias Morfológicas III	\N
769	GDP155	Gestión de la Producción	\N
770	CMR154	Curso Monográfico de Literatura	\N
771	QIN4201	Química Inorgánica II	\N
772	MDF155	Mecánica de los Fluidos	\N
773	EMG4101	Embriología y Genética	\N
774	TLC4101	Traducción Legal y Comercial	\N
775	INE155	Ingeniería Económica	\N
776	LFT2412	Derechos Humanos, Bioética y Ética en Investigación	\N
777	MAT355	Matemática III	\N
778	QOR4201	Química Orgánica II	\N
779	EOR254	Expresión Oral y Escrita II	\N
780	HCB114	Historia de Centroamérica y el Caribe	\N
781	LFT2432	Gestión de la Literatura, Comunicación y Redacción Científica	\N
782	COCO158	Contabilidad y Costos	\N
783	MRD158	Mercadeo I	\N
784	CAL4101	Cálculo I	\N
785	HID153	Hidráulica	\N
786	QGN159	Química General I	\N
787	QAC156	Química Analítica Cualitativa	\N
788	ANN115	Análisis Numérico	\N
789	QGN259	Química General II	\N
790	VMA4101	Validación de Métodos Analíticos	\N
791	ADA153	Administración Agropecuaria	\N
792	COL115	Concursos y Licitaciones	\N
793	TMA254	Territorio Población y Medio Ambiente II	\N
794	FGE4301	Física General III	\N
795	ETM154	Ética y Moral	\N
796	AME115	Arquitectura Medieval	\N
797	QTE155	Química Técnica	\N
798	BIO4101	Bioestadística	\N
799	FPY114	Formulación de Proyectos Sociales	\N
800	CGD153	Comunicación y Gestión del Desarrollo Local	\N
801	MOR154	Morfosintaxis I	\N
802	FCT156	Farmacotécnia	\N
803	CUG154	Currículo y Gestión	\N
804	PMN154	Psicología Comunitaria	\N
805	LFT2433	Ergonomía	\N
806	PPE158	Productos y Precios en el Exterior	\N
807	PPA154	Psicopatología	\N
808	DEP155	Distribución en Planta	\N
809	LFT2407	Salud Publica, Funcionamiento y Discapacidad	\N
810	HID115	Hidráulica	\N
811	PBE159	Probabilidad y Estadística	\N
812	DOB4101	Derecho Civil: Obligaciones	\N
813	ANR4201	Análisis Real II	\N
933	PGA154	Pedagogía General	\N
814	ELI4101	Estudio Lingüístico del Idioma Inglés	\N
815	MIC153	Microbiología Agrícola	\N
816	FMC259	Física II Termodinámica, Fluidos y Ondas	\N
817	PJF154	Psicología Jurídica y Forense	\N
818	ETT115	Estática	\N
819	HCE154	Historia de Centroamérica y El Salvador	\N
820	ESC115	Estructuras de Concreto I	\N
821	DCQ159	Desarrollo Curricular de Química	\N
822	DLI154	Didáctica de la Lengua en la Educación Infantil de 0 a 7 Años I	\N
823	DER4101	Derecho Registral	\N
824	LFT2462	Ejecución de Investigación en Fisioterapia y Socialización de Resultados II	\N
825	FIS255	Física II	\N
826	EAP4101	Ecología Aplicada	\N
827	INT258	Inglés II	\N
828	SIV114	Seminario de Investigación I	\N
829	ETC154	Estudios Culturales I	\N
830	MIEC158	Microeconomía	\N
831	DMO4101	Diagnóstico Molecular	\N
832	COB158	Contabilidad Bancaria	\N
833	EDF153	Edafología	\N
834	AGE115	Análisis Geotécnico I	\N
835	AEN154	Advanced English	\N
836	ECD115	Ecuaciones Diferenciales	\N
837	QOR156	Química Orgánica I	\N
838	MIM7201	Microbiología Médica II	\N
839	ITE4101	Inglés Técnico	\N
840	MEL115	Máquinas Eléctricas	\N
841	MIM7101	Microbiología Médica I	\N
842	MELO158	Metrología Logística	\N
843	LIE254	Literatura Española II	\N
844	TCO159	Teoría Combinatoria	\N
845	DCO4101	Derecho Constitucional I	\N
846	PES155	Probabilidad y Estadística	\N
847	CAI4101	Cálculo Integral	\N
848	COY4101	Combinatoria y Grafos	\N
849	PLC4101	Prácticas de Laboratorio Clínico I	\N
850	PDC159	Práctica Docente I	\N
851	TEL4201	Teoría Electromagnética II	\N
852	FDE155	Fundamentos de Economía	\N
853	CPF156	Control de Calidad de Productos Farmacéuticos	\N
854	ETD159	Estadística	\N
855	DGL254	Didáctica General II	\N
856	LFT2419	Afecciones Médicas	\N
857	TFA156	Tecnología Farmacéutica	\N
858	FIS4101	Física	\N
859	SDI154	Seminario de Investigación	\N
860	DER7101	Dermatología I	\N
861	MCS4201	Metodología de Investigación Científica en Salud II	\N
862	MCT115	Materiales de Construcción I	\N
863	SCR115	Sistemas de Control Realimentados	\N
864	MYN154	Métodos y Técnicas de Investigación	\N
865	TEAD258	Teoría Administrativa II	\N
866	ISA115	Ingeniería Sanitaria	\N
867	TLT114	Teoría Sociológica Latinoamericana	\N
868	MHI115	Máquinas Hidráulicas	\N
869	DEI115	Diseño Espacial Inicial	\N
870	ETC354	Estudios Culturales III	\N
871	CIR7101	Cirugía I	\N
872	LBI4201	Laboratorio Intermedio II	\N
873	DMA159	Didáctica de la Matemática	\N
874	TECG158	Técnicas Gerenciales	\N
875	HDC4101	Habilidades y Destrezas Clínicas	\N
876	TAD258	Teoría Administrativa II	\N
877	ZAF156	Zoología Aplicada a la Farmacia	\N
878	CPP115	Coordinación Protecciones en Sistemas de Potencia	\N
879	SMT4101	Salud Mental	\N
881	MAT258	Matemática II	\N
882	EST158	Estadística I	\N
883	LFT2448	Fisioterapia Deportiva	\N
884	LFT2406	Habilidades de Pensamiento y de Comunicación	\N
885	DFA4101	Derecho de Familia	\N
886	PDC154	Práctica Docente I	\N
887	DCN4101	Derecho Procesal Constitucional	\N
888	IAI4101	Inglés Avanzado Intensivo I	\N
889	LNG154	Lingüística del Texto	\N
890	DIN115	Dinámica	\N
891	EST258	Estadística II	\N
892	EMA115	Estructuras de Mampostería	\N
893	IHE154	Intermediate High English	\N
894	MAP4101	Manejo Anestésico de Pacientes en Situaciones Quirúrgicas de Especialidades Médicas I	\N
895	TGD4201	Teoría General del Derecho II	\N
896	DME258	Derecho Mercantil II	\N
897	NUT7101	Nutrición	\N
899	BIG153	Biología General	\N
900	ETD156	Estadística	\N
901	REP4101	Rehabilitación Pulmonar	\N
902	EST153	Estadística	\N
903	ALA4101	Álgebra Abstracta I	\N
904	MEI4101	Métodos de Investigación	\N
905	AFA153	Anatomía y Fisiología Animal	\N
906	LFT2443	Fisioterapia en Ortopedia, Traumatología y Reumatología	\N
907	DPE4101	Derecho Penal I	\N
908	TDR156	Técnicas de Redacción e Investigación	\N
909	TLI4101	Técnicas de Litigación	\N
910	LBI4101	Laboratorio Intermedio I	\N
911	GIP155	Gestión de la Implementación de Proyectos	\N
912	SEP7101	Semiología Psiquiátrica	\N
913	BOT4101	Botánica I	\N
914	DEN4101	Derecho Notarial	\N
915	TSA114	Teoría Sociológica Contemporánea I	\N
916	LFT2440	Gestión en Fisioterapia	\N
917	EGR254	English Grammar II	\N
918	ADCA158	Administración de la Calidad I	\N
919	MAT158	Matemática I	\N
920	TOP153	Topografía	\N
921	FIC4102	Fundamentos de Investigación Científica	\N
922	ADF155	Administración Financiera	\N
923	SDA158	Seminario de Auditoría	\N
924	DCO4201	Derecho Constitucional II	\N
925	BMA4201	Biomatemática II	\N
926	GAP153	Ganado Porcino	\N
927	DTR258	Derecho Tributario II	\N
928	LAA4101	Laboratorio de Aguas y Alimentos	\N
929	PAE156	Psicología Aplicada a la Empresa	\N
930	SEIN158	Seminario de Investigación	\N
931	APR158	Administración de la Producción I	\N
932	HSL114	Historia de El Salvador	\N
934	PND114	Procesamiento y Análisis de Datos	\N
935	AOE156	Análisis Orgánico Estructural	\N
936	SEI154	Seminario Educación Inclusiva	\N
937	DSM4101	Derecho Societario y de la Empresa Mercantil	\N
938	INE115	Introducción a las Estructuras	\N
939	LLA254	Literatura Latinoamericana II	\N
940	PDC254	Práctica Docente II	\N
941	ING358	Inglés III	\N
942	PED7201	Pediatría II	\N
943	LEJ4101	Lógica y Ética Jurídica	\N
944	MELI158	Mercadeo Local e Internacional	\N
945	PYR115	Psicología y Relaciones Sociolaborales	\N
946	APE258	Administración de Personal II	\N
947	DEE115	Diseño de Elementos Estructurales	\N
948	DMT159	Desarrollo Curricular de Matemática	\N
949	LBB4101	Laboratorio Básico	\N
950	III155	Introducción a la Ingeniería Industrial	\N
951	DLA158	Derecho Laboral	\N
952	GMT259	Geometría II	\N
953	ANR4101	Análisis Real I	\N
954	DPC4101	Derecho Procesal I	\N
955	INE258	Introducción a la Economía II	\N
956	ACO115	Arquitectura Contemporánea	\N
957	TECP158	Técnicas Presupuestarias	\N
958	SCL114	Sociología Ecológica	\N
959	TLI254	Teoría Literaria II	\N
960	FIN158	Finanzas Internacionales	\N
961	LBA4201	Laboratorio Avanzado II	\N
962	OFC115	Ondas, Fluidos y Calor	\N
963	INOP158	Investigación de Operaciones	\N
964	DMF4101	Derecho de los Mercados Financieros y Tecnológicos	\N
965	TIN4101	Teoría y Práctica de la Interpretación	\N
966	EPI7101	Epidemiología	\N
968	TER4101	Termodinámica	\N
969	FPR4201	Fisiopatología Respiratoria II	\N
970	ADC115	Análisis de Circuitos I	\N
971	GPP114	Gestión de Políticas Públicas	\N
972	SOR153	Sociología Rural	\N
973	ECL159	Ecología	\N
974	DEQ159	Didáctica para la Enseñanza de la Química	\N
975	SRN4101	Seminario de Realidad Nacional	\N
976	PED159	Pedagogía General	\N
977	LFT2447	Seguridad del Fisioterapeuta	\N
978	ASS115	Análisis de Señales y Sistemas	\N
979	CDC158	Comportamiento del Consumidor	\N
980	CLG7101	Clínica Ginecológica y Obstétrica	\N
981	TEC115	Tecnología del Concreto	\N
982	EPU158	Economía Pública	\N
983	FCO156	Farmacología	\N
984	MEC4201	Mecánica Cuántica II	\N
985	NUA153	Nutrición Animal	\N
986	PTG154	Psicopatología Social	\N
987	INGL258	Inglés II	\N
988	MFI158	Matemática Financiera	\N
989	DCC4101	Derecho Civil: Contratos	\N
990	LYA155	Lógica y Algoritmos	\N
992	PGC154	Psicología Clínica	\N
993	FAV159	Fundamentos de Anatomía y Fisiología Vegetal	\N
994	FII4201	Francés Intermedio Intensivo II	\N
995	EAP159	Evaluación de los Aprendizajes	\N
996	EDA115	Estructuras de Acero I	\N
998	ETG159	Estadística General	\N
999	DIM115	Dibujo Mecánico	\N
1000	IEI155	Investigación en Ingeniería	\N
1001	SIA153	Sistemas Agrosilvopastoriles	\N
1002	PPF254	Prácticas Profesionales II	\N
1003	PCI254	Psicología del Desarrollo Integral Infantil II (4 a 7 Años)	\N
1004	MTE356	Matemática III	\N
1005	IGT256	Inglés Técnico II	\N
1006	DPI4101	Derecho de Propiedad Intelectual y Derecho Cambiario	\N
1007	ECD4101	Ecuaciones Diferenciales I	\N
1008	GIG4201	Gramática Inglesa II	\N
1009	EMA115	Electromagnetismo	\N
1010	GEO4201	Geometría II	\N
1011	GEN153	Genética	\N
1012	AUD158	Auditoría I	\N
1013	FGE4201	Física General II	\N
1014	IBI4202	Inglés Básico Intensivo II	\N
1015	ESM7101	Estadística Médica	\N
1016	ICS154	Introducción a las Ciencias Sociales	\N
1017	PCA159	Precálculo	\N
1018	DAN4101	Derecho Procesal Administrativo	\N
1019	EDC159	Estadística I	\N
1020	BCT4101	Biología Celular y Tisular	\N
1021	DEM115	Diseño de Elementos de Maquinas I	\N
1022	LDV4101	Laboratorio de Diagnóstico Veterinario	\N
1023	TEI4101	Técnicas Instrumentales Cromatográficas	\N
1024	MCS4101	Metodología de Investigación Científica en Salud I	\N
1025	DPL254	Didáctica del Desarrollo del Pensamiento Lógico-Matemático en la Educación Infantil de 0 a 7 Años II	\N
1026	COF258	Contabilidad Financiera II	\N
1027	FAI4101	Francés Avanzado Intensivo I	\N
1028	RDR153	Riegos y Drenaje	\N
1030	TEE4101	Técnicas Electroanalíticas	\N
1031	RDF4101	Redacción Académica en Francés	\N
1032	MAC358	Macroeconomía III	\N
1033	RTN114	Redacción de Textos Académicos y Científicos	\N
1034	DEB159	Didáctica para la Enseñanza de la Biología	\N
1035	DPU115	Desarrollo del Proyecto Urbanístico	\N
1036	ARA115	Arquitectura de la Antigüedad	\N
1037	LFT2453	Ejecución de Investigación en Fisioterapia y Socialización de Resultados I	\N
1038	FFE154	Fonética y Fonología del Español	\N
1039	BIG4101	Biología General	\N
1040	CRI4101	Criminología	\N
1041	HAL154	Historia de América Latina	\N
1043	PEE115	Propuesta Estructural para Edificios	\N
1044	LSG4101	Laboratorio de Serología y Genética Forense	\N
1045	GFC159	Geografía Física	\N
1046	LINR158	Liderazgo y Técnicas de Negociación	\N
1047	ANT156	Anatomía	\N
1048	ITL154	Introduction to Linguistics	\N
1049	SIA4101	Sociología	\N
1050	TAN4101	Técnicas en Anestesiología	\N
1051	IPG114	Introducción al Pensamiento Sociológico	\N
1052	PSO158	Psicología Organizacional	\N
1053	ICP115	Introducción a la Computación y Programación	\N
1054	PRA254	Práctica II: Diagnóstico Educativo y Aplicación de Currículo	\N
1055	OSI155	Ofimática y Software para Ingeniería Industrial	\N
1056	IGT156	Inglés Técnico I	\N
1057	ING4102	Inglés	\N
1058	OAC154	Organización y Administración de Centros Educativos de 0 a 7 Años	\N
1059	INC154	Intervención Comunitaria	\N
1060	LFT2427	Ingles Básico	\N
1061	FRLI158	Franquicias y Licencias	\N
1062	QOR159	Química Orgánica	\N
1063	INEC158	Introducción a la Economía I	\N
1064	MEI7201	Medicina Interna II	\N
1065	BOT4201	Botánica II	\N
1066	ISH114	Introducción a la Sociohistoria	\N
1067	TID155	Tecnología Industrial I	\N
1068	DPP154	Diagnóstico Psicopedagógico	\N
1069	EDP7101	Educación para la Salud en Atención Primaria	\N
1070	LFT2454	Fisioterapia en Actividad Física, Ejercicio y Deporte	\N
1071	TOP115	Topografía General	\N
1072	MEI7101	Medicina Interna I	\N
1073	TDI158	Técnicas de Investigación	\N
1074	FEP158	Formulación y Evaluación de Proyectos	\N
1075	LFT2405	Metodología de la Investigación en Salud	\N
1076	LEAD158	Legislación Aduanera	\N
1077	PNGF158	Planes de Negocios y Gestión Financiera	\N
1079	MFQ4101	Manejo de Pacientes en Procedimientos Fuera de Quirófano	\N
1080	MAE158	Métodos para el Análisis Económico	\N
1081	LFT2456	Práctica Rotatoria de Fisioterapia en Hospitales II	\N
1082	ELC115	Electrónica I	\N
1083	LFT2439	Fisioterapia en Otros Sistemas	\N
1084	QCG259	Química Orgánica II	\N
1085	IEC154	Investigación Educativa	\N
1086	MYN115	Metrología y Normalización	\N
1087	CIR7201	Cirugía II	\N
1089	FQN156	Farmacognosia	\N
1090	GCB4101	Gestión y Conservación de la Biodiversidad	\N
1091	PEC4101	Principios de Ecología	\N
1092	TDD154	Teorías del Desarrollo	\N
1093	SSO155	Seguridad y Salud Ocupacional	\N
1094	MEI4102	Métodos de Investigación	\N
1095	LFT2423	Examen Integral II	\N
1096	INEC258	Introducción a la Economía II	\N
1097	PRE4101	Precálculo	\N
1098	DAM4101	Derecho Ambiental	\N
1099	DLL154	Didáctica del Lenguaje y la Literatura	\N
1100	SOU115	Sociología Urbana	\N
1101	ECL154	Expresión y Creación Literaria	\N
1102	MFI159	Matemática Financiera	\N
1103	PPU115	Presupuesto del Proyecto Urbanístico	\N
1104	LYA115	Lógica y Algoritmos	\N
1105	ESP4101	Epidemiología y Salud Pública	\N
1106	DTR158	Derecho Tributario I	\N
1107	TOP4201	Topología II	\N
1108	AYF4201	Anatomía y Fisiología II	\N
1109	LFT2461	Práctica Rotatoria de Fisioterapia en Centros de Atención Crónica Avanzada	\N
1111	ICL114	Investigación Cualitativa	\N
1112	DEM4101	Derecho Municipal	\N
1113	FEP115	Formulación y Evaluación de Proyectos	\N
1114	PIN115	Proyécto Integrador	\N
1115	QGN4201	Química General II	\N
1116	ILC4101	Introducción al Laboratorio Clínico	\N
1117	FPD154	Fundamentos Psicológicos de Atención a Personas con Discapacidad	\N
1118	IDO155	Investigación de Operaciones I	\N
1119	MAT153	Matemática I	\N
1120	QUM4101	Química Macromolecular	\N
1121	FAM4101	Farmacología I	\N
1122	APH4201	Práctica Clínica de Atención Prehospitalaria II	\N
1123	FIV153	Fisiología Vegetal	\N
1124	PRB115	Programación Básica	\N
1125	DMA158	Derecho Mercantil y Aduanero	\N
1126	QCA159	Química Analítica	\N
1127	SOC156	Sociología	\N
1128	LIU254	Literatura Universal II	\N
1129	IED154	Investigación Educativa	\N
1130	MAE215	Máquinas Eléctricas II	\N
1131	ILO4101	Introducción a la Lógica Simbólica	\N
1132	EPG154	Evaluación Psicológica	\N
1133	GEO115	Geometría Descriptiva	\N
1134	DPP4101	Derecho Procesal Penal I	\N
1135	MEM115	Mecánica de Materiales I	\N
1136	FEP153	Formulación y Evaluación de Proyectos	\N
1137	QUA4101	Química Ambiental	\N
1138	COM258	Computación II	\N
1139	BCM4101	Biología Celular y Molecular	\N
1140	CSP156	Contaminación Ambiental y Salud Pública	\N
1141	TLI154	Teoría Literaria I	\N
1142	SIH115	Sistemas de Información Geográfica	\N
1143	LFT2450	Fisioterapia en Cirugía Plástica	\N
1144	FPF154	Fundamentos de Psicología Fisiológica	\N
1145	SAP7101	Salud Pública	\N
1146	SMI4101	Seminario de Investigación I	\N
1147	QGE156	Química General I	\N
1148	IME154	Intermediate Mid English	\N
1149	DME158	Derecho Mercantil I	\N
1150	DBI159	Desarrollo Curricular de la Biología	\N
1152	INE115	Ingeniería Económica	\N
1153	MEB4101	Medicina Basada en Evidencia	\N
1154	LBA4101	Laboratorio Avanzado I	\N
1155	DEX153	Diseños Experimentales	\N
1156	LFT2431	Órtesis y Prótesis	\N
1157	ANB156	Análisis Bromatológico	\N
1158	DAC154	Diseño y Aplicación del Currículo	\N
1159	COF158	Contabilidad Financiera I	\N
1160	GNT159	Genética	\N
1161	AMO115	Arquitectura Moderna	\N
1162	DUR115	Diseño de Complejos Urbanos	\N
1163	COV158	Costeo Variable	\N
1164	EXI154	Expresión Oral y Escrita	\N
1165	SFM114	Sociología de la Familia	\N
1166	DIU115	Diseño Urbano	\N
1167	MEL7101	Medicina Legal	\N
1168	PRA554	Práctica V: Proyecto Sociocomunitario Intersectorial	\N
1169	QAN4101	Química Analítica I	\N
1170	MIC115	Metodología de la Investigación Científica	\N
1171	FRU153	Fruticultura	\N
1172	IVL115	Ingeniería Vial	\N
1173	MAT358	Matemática III	\N
1174	SIV214	Seminario de Investigación II	\N
1176	MAE115	Máquinas Eléctricas I	\N
1177	PRA654	Práctica VI: Proyecto Sociocomunitario-Intersectorial	\N
1178	LFT2413	Razonamiento Clínico	\N
1179	LEF156	Legislación Farmacéutica y Deontología	\N
1180	INF159	Introducción a la Física	\N
1181	RDI4101	Redacción Académica en Inglés	\N
1182	FUS4101	Fundamentos Socioeconómicos del Derecho	\N
1183	ECP158	Economía Política I	\N
1184	MER258	Mercadotecnia II	\N
1185	GRC4101	Gramática Comparada Inglés – Español	\N
1186	FAN4101	Fisiología Animal	\N
1187	FGN159	Física General	\N
1188	FAM7201	Farmacología Médica II	\N
1189	LLA154	Literatura Latinoamericana I	\N
1190	PEM154	Psicología en Situación de Emergencia	\N
1191	GHE154	Globalización Historia Estructuras y Procesos	\N
1192	ANC4101	Anatomía Comparada de Cordados	\N
1193	MIS4101	Metodología de la Investigación I	\N
1194	DEL254	Didactics of the English Language II	\N
1195	ENT153	Entomología Agrícola	\N
1196	TEM4101	Teoría de la Medida	\N
1197	GYO7101	Ginecología y Obstetricia I	\N
1198	AVI153	Avicultura	\N
1200	LFT2415	Farmacología para Fisioterapeutas	\N
1201	ALG259	Álgebra II	\N
1202	LFT2408	Biofísica y Biomecánica	\N
1203	PLT115	Planificación Territorial	\N
1204	ESD7101	Estrategias de la Atención Primaria en Salud	\N
1205	ADS158	Administración Superior	\N
1206	ICM115	Introducción a la Ingeniería Civil y Medio Ambiente	\N
1207	ANA4101	Análisis Complejo	\N
1208	PAD156	Principios de Administración	\N
1209	TEG4101	Teoría General del Proceso	\N
1210	EBA115	Estadística Básica	\N
1211	MEA4101	Mecánica Analítica	\N
1212	FIS155	Física I	\N
1215	LFT2414	Psicología de la Salud	\N
1216	ESM4101	Estadística Multivariada	\N
1217	BME4101	Biofísica Médica	\N
1218	MDT155	Medida del Trabajo	\N
1219	MCS154	Metodología de las Ciencias Sociales	\N
1220	QIN4101	Química Inorgánica I	\N
1221	MDI115	Metodología de la Investigación	\N
1222	ALI4101	Álgebra Lineal I	\N
1223	PAB115	Planeamiento y Administración de Obras	\N
1224	CIM7201	Ciencias Morfológicas II	\N
1225	IES4101	Inferencia Estadística	\N
1226	TGD4101	Teoría General del Derecho I	\N
1227	DPU4101	Derecho Internacional Público y Comunitario	\N
1229	MPI115	Mantenimiento de Plantas Industriales	\N
1230	ADCA258	Administración de la Calidad II	\N
1231	LFT2426	Bioestadística	\N
1232	IAL4101	Introducción al Álgebra	\N
1233	IIS4101	Introducción a la Investigación Social y Redacción Académica	\N
1234	TOP4101	Topología I	\N
1235	ECC4101	Ecología Cultural	\N
1236	SGN114	Sociología de Género	\N
1237	HDI115	Hidrología	\N
1238	CAL4301	Cálculo III	\N
1240	TDM115	Teoría de Mecanísmos	\N
1241	ECO154	English Composition	\N
1242	SMG154	Semiótica General	\N
1243	FLQ4101	Fundamentos de Laboratorio Químico	\N
1244	ADP158	Administración Pública	\N
1245	AFI258	Administración Financiera II	\N
1246	ILE154	Intermediate Low English	\N
1247	DEF4101	Derecho Financiero y Tributario	\N
1248	MEI115	Métodos de Investigación	\N
1249	DEP154	Didáctica de la Expresión Plástica en Educación Infantil de 0 a 7 Años	\N
1250	OPFI158	Operaciones Financieras Internacionales	\N
1251	DNP158	Desarrollo de Nuevos Productos	\N
1253	ICN114	Investigación Cuantitativa	\N
1254	ECA153	Economía Agrícola	\N
1255	SIC158	Sistemas Computacionales	\N
1256	DII4101	Diagnóstico Inmunológico	\N
1257	INA153	Instalaciones Agropecuarias	\N
1258	IED159	Investigación Educativa	\N
1259	GEO114	Geografía Social	\N
1260	INU115	Iniciación al Urbanismo	\N
1261	DCP4101	Derecho Colectivo y Procesal del Trabajo	\N
1262	CLD7101	Clínica de Salud Pública	\N
1263	ZOO4201	Zoología II	\N
1264	PRA354	Práctica III: Proyecto Socio-Comunitario	\N
1265	PIR115	Proyecto de Ingeniería Eléctrica	\N
1266	PSE159	Psicología de la Educación	\N
1267	DCC154	Desarrollo Curricular de las Ciencias Sociales	\N
1268	DPA4101	Diagnóstico Parasitológico	\N
1269	FMC459	Física IV Física Moderna	\N
1271	IPO154	Intervención en Psicopatología Social	\N
1272	FMA4101	Física Matemática I	\N
1273	ADL4101	Administración de Laboratorio	\N
1274	FIS4401	Física IV	\N
1275	FSO156	Fisiología	\N
1276	SCI158	Seminario Integrador de Comercio Internacional	\N
1277	FDP115	Formulación y Evaluación de Proyectos	\N
1278	GDP154	Gestión y Desarrollo de Personal I	\N
1279	BIC7101	Biología Celular	\N
1280	MTE256	Matemática II	\N
1281	AGC153	Agroclimatología	\N
1282	ADF258	Administración Financiera II	\N
1283	QFT156	Química Forense y Toxicología	\N
1284	LFT2445	Fisioterapia en Salud Mental y Psiquiatría	\N
1285	SDI115	Sistemas Digitales	\N
1286	DPP4301	Derecho Procesal Penal III	\N
1287	LOTA158	Logística I - Transporte y Almacenamiento	\N
1288	SEA154	Seminario Educación Ambiental y Cambio Climático	\N
1289	MGC153	Manejo y Gestión de Cuencas Hidrográficas	\N
1290	ANV4101	Análisis Vectorial	\N
1291	ECO159	Ecología	\N
1292	TEAD158	Teoría Administrativa I	\N
1293	FII4101	Francés Intermedio Intensivo I	\N
1294	PRO4101	Programación	\N
1296	LFT2429	Examen Integral III	\N
1297	DEL154	Didactics of the English Language I	\N
1298	COF558	Contabilidad Financiera V	\N
1299	MFA4101	Matemática y Física Aplicada	\N
1300	GAV153	Ganado Vacuno	\N
1301	FUD215	Fundamentos de Diseño II	\N
1302	TOP115	Topografía	\N
1304	POF4101	Pronunciación y Expresión Oral en Francés	\N
\.


--
-- Data for Name: tbl_materia_docente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_materia_docente (id_materia, id_docente) FROM stdin;
2	8
13	13
27	14
30	13
34	14
29	13
14	14
19	13
4	8
9	7
16	8
47	13
45	14
25	13
21	8
26	7
20	8
6	13
12	14
36	13
3	14
23	13
1	14
24	13
28	14
49	13
42	14
38	13
48	14
31	13
44	14
11	13
22	14
32	13
41	14
18	13
5	14
10	7
43	14
39	13
37	14
33	13
46	14
8	13
17	14
15	13
40	14
35	13
50	14
7	13
760	37
\.


--
-- Data for Name: tbl_notificacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_notificacion (id_notificacion, id_entrega, id_usuario_destino, mensaje, fecha_envio, fecha_lectura) FROM stdin;
1525	257	21	Nueva entrega recibida para revisión: Diseño de una bomba de ariete para riego comunitario.	2020-06-24 18:29:11.509955	2020-06-25 18:29:11.509955
1526	257	3	Nueva entrega recibida para revisión: Diseño de una bomba de ariete para riego comunitario.	2020-06-24 18:29:11.509955	2020-06-25 18:29:11.509955
1527	257	23	Nueva entrega recibida para revisión: Diseño de una bomba de ariete para riego comunitario.	2020-06-24 18:29:11.509955	2020-06-25 18:29:11.509955
1528	257	22	Nueva entrega recibida para revisión: Diseño de una bomba de ariete para riego comunitario.	2020-06-24 18:29:11.509955	2020-06-25 18:29:11.509955
1529	257	2	Nueva entrega recibida para revisión: Diseño de una bomba de ariete para riego comunitario.	2020-06-24 18:29:11.509955	2020-06-25 18:29:11.509955
1530	257	223	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.	2020-06-27 18:11:49.892203	2020-06-28 18:11:49.892203
1519	256	21	Nueva entrega recibida para revisión: Implementación de las 5S en una imprenta.	2019-09-19 15:36:24.387132	2019-09-20 15:36:24.387132
1520	256	3	Nueva entrega recibida para revisión: Implementación de las 5S en una imprenta.	2019-09-19 15:36:24.387132	2019-09-20 15:36:24.387132
1521	256	23	Nueva entrega recibida para revisión: Implementación de las 5S en una imprenta.	2019-09-19 15:36:24.387132	2019-09-20 15:36:24.387132
1522	256	22	Nueva entrega recibida para revisión: Implementación de las 5S en una imprenta.	2019-09-19 15:36:24.387132	2019-09-20 15:36:24.387132
1523	256	2	Nueva entrega recibida para revisión: Implementación de las 5S en una imprenta.	2019-09-19 15:36:24.387132	2019-09-20 15:36:24.387132
1513	255	21	Nueva entrega recibida para revisión: Índice de precios de los mercados municipales de San Miguel.	2019-03-12 19:00:23.327902	2019-03-13 19:00:23.327902
17	6	2	Nueva entrega recibida para revisión: Estrategias lúdicas para la enseñanza de la genética en educación media.	2019-05-26 06:15:16.446794	2019-05-27 06:15:16.446794
18	6	3	Nueva entrega recibida para revisión: Estrategias lúdicas para la enseñanza de la genética en educación media.	2019-05-26 06:15:16.446794	2019-05-27 06:15:16.446794
16	5	48	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2019-12-07 06:40:58.140112	2019-12-08 06:40:58.140112
1542	259	225	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-08-19 19:19:09.681912	2020-08-20 19:19:09.681912
2127	356	23	Nueva entrega recibida para revisión: Propuesta de mobiliario urbano para el parque central.	2025-05-24 05:35:09.451774	2025-05-25 05:35:09.451774
2128	356	22	Nueva entrega recibida para revisión: Propuesta de mobiliario urbano para el parque central.	2025-05-24 05:35:09.451774	2025-05-25 05:35:09.451774
2129	356	2	Nueva entrega recibida para revisión: Propuesta de mobiliario urbano para el parque central.	2025-05-24 05:35:09.451774	2025-05-25 05:35:09.451774
2130	356	290	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-05-30 03:12:07.821241	2025-05-31 03:12:07.821241
2131	357	21	Nueva entrega recibida para revisión: Diseño de un sistema de drenaje pluvial para una colonia de San Miguel.	2025-05-30 05:34:59.506826	2025-05-31 05:34:59.506826
2132	357	3	Nueva entrega recibida para revisión: Diseño de un sistema de drenaje pluvial para una colonia de San Miguel.	2025-05-30 05:34:59.506826	2025-05-31 05:34:59.506826
2133	357	23	Nueva entrega recibida para revisión: Diseño de un sistema de drenaje pluvial para una colonia de San Miguel.	2025-05-30 05:34:59.506826	2025-05-31 05:34:59.506826
2134	357	22	Nueva entrega recibida para revisión: Diseño de un sistema de drenaje pluvial para una colonia de San Miguel.	2025-05-30 05:34:59.506826	2025-05-31 05:34:59.506826
2135	357	2	Nueva entrega recibida para revisión: Diseño de un sistema de drenaje pluvial para una colonia de San Miguel.	2025-05-30 05:34:59.506826	2025-05-31 05:34:59.506826
2136	357	291	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2025-06-13 20:27:52.814365	2025-06-14 20:27:52.814365
2137	358	21	Nueva entrega recibida (versión corregida) para revisión: Diseño de un sistema de drenaje pluvial para una colonia de San Miguel.	2025-06-22 03:08:03.144684	2025-06-23 03:08:03.144684
2138	358	3	Nueva entrega recibida (versión corregida) para revisión: Diseño de un sistema de drenaje pluvial para una colonia de San Miguel.	2025-06-22 03:08:03.144684	2025-06-23 03:08:03.144684
27	7	23	Nueva entrega recibida (versión corregida) para revisión: Estrategias lúdicas para la enseñanza de la genética en educación media.	2019-06-04 09:54:57.263884	2019-06-05 09:54:57.263884
561	96	21	Nueva entrega recibida para revisión: Ansiedad y depresión en adultos mayores de hogares de ancianos de San Miguel.	2022-03-15 00:47:40.145248	2022-03-16 00:47:40.145248
1555	262	21	Nueva entrega recibida para revisión: Juego de roles sobre los derechos humanos en tercer ciclo.	2020-10-12 04:20:52.288574	2020-10-13 04:20:52.288574
1556	262	3	Nueva entrega recibida para revisión: Juego de roles sobre los derechos humanos en tercer ciclo.	2020-10-12 04:20:52.288574	2020-10-13 04:20:52.288574
1557	262	23	Nueva entrega recibida para revisión: Juego de roles sobre los derechos humanos en tercer ciclo.	2020-10-12 04:20:52.288574	2020-10-13 04:20:52.288574
1558	262	22	Nueva entrega recibida para revisión: Juego de roles sobre los derechos humanos en tercer ciclo.	2020-10-12 04:20:52.288574	2020-10-13 04:20:52.288574
1559	262	2	Nueva entrega recibida para revisión: Juego de roles sobre los derechos humanos en tercer ciclo.	2020-10-12 04:20:52.288574	2020-10-13 04:20:52.288574
1560	262	228	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2020-10-21 09:49:35.60907	2020-10-22 09:49:35.60907
50	11	22	Nueva entrega recibida para revisión: La poesía de Roque Dalton desde la crítica social.	2019-05-17 17:40:26.860285	2019-05-18 17:40:26.860285
1578	265	230	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-06-11 08:50:38.347478	2020-06-12 08:50:38.347478
88	17	58	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.	2019-12-02 07:01:37.093603	2019-12-03 07:01:37.093603
1585	267	21	Nueva entrega recibida para revisión: Diseño de un aerogenerador de eje vertical para zonas rurales.	2021-07-11 04:39:48.926934	2021-07-12 04:39:48.926934
60	13	3	Nueva entrega recibida para revisión: Enseñanza de la historia local en centros escolares de San Miguel.	2019-04-16 09:56:40.10946	2019-04-17 09:56:40.10946
61	13	21	Nueva entrega recibida para revisión: Enseñanza de la historia local en centros escolares de San Miguel.	2019-04-16 09:56:40.10946	2019-04-17 09:56:40.10946
62	13	22	Nueva entrega recibida para revisión: Enseñanza de la historia local en centros escolares de San Miguel.	2019-04-16 09:56:40.10946	2019-04-17 09:56:40.10946
63	13	23	Nueva entrega recibida para revisión: Enseñanza de la historia local en centros escolares de San Miguel.	2019-04-16 09:56:40.10946	2019-04-17 09:56:40.10946
106	20	60	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-10-19 08:48:44.351604	2020-10-20 08:48:44.351604
1586	267	3	Nueva entrega recibida para revisión: Diseño de un aerogenerador de eje vertical para zonas rurales.	2021-07-11 04:39:48.926934	2021-07-12 04:39:48.926934
1587	267	23	Nueva entrega recibida para revisión: Diseño de un aerogenerador de eje vertical para zonas rurales.	2021-07-11 04:39:48.926934	2021-07-12 04:39:48.926934
1588	267	22	Nueva entrega recibida para revisión: Diseño de un aerogenerador de eje vertical para zonas rurales.	2021-07-11 04:39:48.926934	2021-07-12 04:39:48.926934
1579	266	21	Nueva entrega recibida para revisión: Manejo integrado de plagas en el cultivo de maíz.	2020-10-25 02:41:49.936219	2020-10-26 02:41:49.936219
1580	266	3	Nueva entrega recibida para revisión: Manejo integrado de plagas en el cultivo de maíz.	2020-10-25 02:41:49.936219	2020-10-26 02:41:49.936219
1581	266	23	Nueva entrega recibida para revisión: Manejo integrado de plagas en el cultivo de maíz.	2020-10-25 02:41:49.936219	2020-10-26 02:41:49.936219
524	89	51	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-08-22 16:12:26.470596	2022-08-23 16:12:26.470596
65	14	2	Nueva entrega recibida para revisión: Manual de puestos para una empresa familiar de transporte.	2019-03-05 08:31:28.112614	2019-03-06 08:31:28.112614
66	14	3	Nueva entrega recibida para revisión: Manual de puestos para una empresa familiar de transporte.	2019-03-05 08:31:28.112614	2019-03-06 08:31:28.112614
67	14	21	Nueva entrega recibida para revisión: Manual de puestos para una empresa familiar de transporte.	2019-03-05 08:31:28.112614	2019-03-06 08:31:28.112614
68	14	22	Nueva entrega recibida para revisión: Manual de puestos para una empresa familiar de transporte.	2019-03-05 08:31:28.112614	2019-03-06 08:31:28.112614
69	14	23	Nueva entrega recibida para revisión: Manual de puestos para una empresa familiar de transporte.	2019-03-05 08:31:28.112614	2019-03-06 08:31:28.112614
70	14	56	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2019-03-14 01:33:39.466562	2019-03-15 01:33:39.466562
76	15	56	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2019-04-01 02:10:25.193721	2019-04-02 02:10:25.193721
82	16	57	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2019-05-18 11:21:39.856308	2019-05-19 11:21:39.856308
89	18	2	Nueva entrega recibida para revisión: Dificultades en la resolución de problemas con fracciones.	2019-09-04 19:52:04.392613	2019-09-05 19:52:04.392613
90	18	3	Nueva entrega recibida para revisión: Dificultades en la resolución de problemas con fracciones.	2019-09-04 19:52:04.392613	2019-09-05 19:52:04.392613
91	18	21	Nueva entrega recibida para revisión: Dificultades en la resolución de problemas con fracciones.	2019-09-04 19:52:04.392613	2019-09-05 19:52:04.392613
1582	266	22	Nueva entrega recibida para revisión: Manejo integrado de plagas en el cultivo de maíz.	2020-10-25 02:41:49.936219	2020-10-26 02:41:49.936219
1583	266	2	Nueva entrega recibida para revisión: Manejo integrado de plagas en el cultivo de maíz.	2020-10-25 02:41:49.936219	2020-10-26 02:41:49.936219
1584	266	231	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-10-30 01:05:53.298119	2020-10-31 01:05:53.298119
92	18	22	Nueva entrega recibida para revisión: Dificultades en la resolución de problemas con fracciones.	2019-09-04 19:52:04.392613	2019-09-05 19:52:04.392613
93	18	23	Nueva entrega recibida para revisión: Dificultades en la resolución de problemas con fracciones.	2019-09-04 19:52:04.392613	2019-09-05 19:52:04.392613
94	18	59	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2019-09-09 04:10:23.712754	2019-09-10 04:10:23.712754
100	19	59	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2019-09-21 11:01:54.407849	2019-09-22 11:01:54.407849
525	90	21	Nueva entrega recibida para revisión: Formulación de un gel cicatrizante a base de sábila.	2022-09-30 11:19:09.081503	2022-10-01 11:19:09.081503
526	90	3	Nueva entrega recibida para revisión: Formulación de un gel cicatrizante a base de sábila.	2022-09-30 11:19:09.081503	2022-10-01 11:19:09.081503
527	90	23	Nueva entrega recibida para revisión: Formulación de un gel cicatrizante a base de sábila.	2022-09-30 11:19:09.081503	2022-10-01 11:19:09.081503
1589	267	2	Nueva entrega recibida para revisión: Diseño de un aerogenerador de eje vertical para zonas rurales.	2021-07-11 04:39:48.926934	2021-07-12 04:39:48.926934
1590	267	232	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-07-20 22:00:21.263515	2021-07-21 22:00:21.263515
2248	377	21	Nueva entrega recibida para revisión: Control de inventarios en farmacias independientes.	2026-09-01 07:01:10.601473	2026-09-02 07:01:10.601473
2249	377	3	Nueva entrega recibida para revisión: Control de inventarios en farmacias independientes.	2026-09-01 07:01:10.601473	2026-09-02 07:01:10.601473
2250	377	23	Nueva entrega recibida para revisión: Control de inventarios en farmacias independientes.	2026-09-01 07:01:10.601473	2026-09-02 07:01:10.601473
2251	377	22	Nueva entrega recibida para revisión: Control de inventarios en farmacias independientes.	2026-09-01 07:01:10.601473	2026-09-02 07:01:10.601473
2252	377	2	Nueva entrega recibida para revisión: Control de inventarios en farmacias independientes.	2026-09-01 07:01:10.601473	2026-09-02 07:01:10.601473
2253	377	303	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-09-14 21:04:43.939992	2026-09-15 21:04:43.939992
2259	378	304	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-06-11 12:39:18.992687	2026-06-12 12:39:18.992687
119	23	21	Nueva entrega recibida para revisión: Rehabilitación de pacientes con secuelas de accidente cerebrovascular.	2020-03-29 09:27:20.582369	2020-03-30 09:27:20.582369
120	23	3	Nueva entrega recibida para revisión: Rehabilitación de pacientes con secuelas de accidente cerebrovascular.	2020-03-29 09:27:20.582369	2020-03-30 09:27:20.582369
110	21	22	Nueva entrega recibida para revisión: Control de velocidad de un motor trifásico con variador de frecuencia.	2020-08-09 00:41:07.976645	2020-08-10 00:41:07.976645
111	21	23	Nueva entrega recibida para revisión: Control de velocidad de un motor trifásico con variador de frecuencia.	2020-08-09 00:41:07.976645	2020-08-10 00:41:07.976645
1596	268	233	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2021-05-06 23:26:30.181786	2021-05-07 23:26:30.181786
1597	269	21	Nueva entrega recibida (versión corregida) para revisión: Anfibios como indicadores de la salud de los bosques de Morazán.	2021-05-21 21:02:43.548142	2021-05-22 21:02:43.548142
1598	269	3	Nueva entrega recibida (versión corregida) para revisión: Anfibios como indicadores de la salud de los bosques de Morazán.	2021-05-21 21:02:43.548142	2021-05-22 21:02:43.548142
1599	269	23	Nueva entrega recibida (versión corregida) para revisión: Anfibios como indicadores de la salud de los bosques de Morazán.	2021-05-21 21:02:43.548142	2021-05-22 21:02:43.548142
1600	269	22	Nueva entrega recibida (versión corregida) para revisión: Anfibios como indicadores de la salud de los bosques de Morazán.	2021-05-21 21:02:43.548142	2021-05-22 21:02:43.548142
1601	269	2	Nueva entrega recibida (versión corregida) para revisión: Anfibios como indicadores de la salud de los bosques de Morazán.	2021-05-21 21:02:43.548142	2021-05-22 21:02:43.548142
1602	269	233	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-05-28 03:50:56.929977	2021-05-29 03:50:56.929977
1603	270	21	Nueva entrega recibida para revisión: Hipotermia postoperatoria en pacientes de cirugía mayor.	2021-05-07 10:09:15.275388	2021-05-08 10:09:15.275388
782	132	140	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-07-26 15:58:34.138518	2024-07-27 15:58:34.138518
1604	270	3	Nueva entrega recibida para revisión: Hipotermia postoperatoria en pacientes de cirugía mayor.	2021-05-07 10:09:15.275388	2021-05-08 10:09:15.275388
1605	270	23	Nueva entrega recibida para revisión: Hipotermia postoperatoria en pacientes de cirugía mayor.	2021-05-07 10:09:15.275388	2021-05-08 10:09:15.275388
1606	270	22	Nueva entrega recibida para revisión: Hipotermia postoperatoria en pacientes de cirugía mayor.	2021-05-07 10:09:15.275388	2021-05-08 10:09:15.275388
1607	270	2	Nueva entrega recibida para revisión: Hipotermia postoperatoria en pacientes de cirugía mayor.	2021-05-07 10:09:15.275388	2021-05-08 10:09:15.275388
151	28	3	Nueva entrega recibida para revisión: Educación cívica y participación de los jóvenes en su comunidad.	2020-05-06 15:41:11.674071	2020-05-07 15:41:11.674071
152	28	23	Nueva entrega recibida para revisión: Educación cívica y participación de los jóvenes en su comunidad.	2020-05-06 15:41:11.674071	2020-05-07 15:41:11.674071
1632	274	2	Nueva entrega recibida para revisión: Plataforma web para la gestión de prácticas profesionales.	2021-11-23 22:35:44.516119	2021-11-24 22:35:44.516119
1633	274	236	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-12-05 10:33:28.849847	2021-12-06 10:33:28.849847
1634	275	21	Nueva entrega recibida para revisión: Diseño de una base de datos para un consultorio odontológico.	2021-06-26 11:33:13.488322	2021-06-27 11:33:13.488322
1635	275	3	Nueva entrega recibida para revisión: Diseño de una base de datos para un consultorio odontológico.	2021-06-26 11:33:13.488322	2021-06-27 11:33:13.488322
1636	275	23	Nueva entrega recibida para revisión: Diseño de una base de datos para un consultorio odontológico.	2021-06-26 11:33:13.488322	2021-06-27 11:33:13.488322
1637	275	22	Nueva entrega recibida para revisión: Diseño de una base de datos para un consultorio odontológico.	2021-06-26 11:33:13.488322	2021-06-27 11:33:13.488322
1638	275	2	Nueva entrega recibida para revisión: Diseño de una base de datos para un consultorio odontológico.	2021-06-26 11:33:13.488322	2021-06-27 11:33:13.488322
1639	275	236	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.	2021-07-06 12:57:02.797262	2021-07-07 12:57:02.797262
1646	277	21	Nueva entrega recibida para revisión: Errores frecuentes en la traducción de textos técnicos al inglés.	2021-08-22 18:46:15.722735	2021-08-23 18:46:15.722735
1640	276	21	Nueva entrega recibida para revisión: La oralidad y las leyendas del oriente salvadoreño.	2021-05-20 16:24:24.08331	2021-05-21 16:24:24.08331
1641	276	3	Nueva entrega recibida para revisión: La oralidad y las leyendas del oriente salvadoreño.	2021-05-20 16:24:24.08331	2021-05-21 16:24:24.08331
1642	276	23	Nueva entrega recibida para revisión: La oralidad y las leyendas del oriente salvadoreño.	2021-05-20 16:24:24.08331	2021-05-21 16:24:24.08331
1643	276	22	Nueva entrega recibida para revisión: La oralidad y las leyendas del oriente salvadoreño.	2021-05-20 16:24:24.08331	2021-05-21 16:24:24.08331
1644	276	2	Nueva entrega recibida para revisión: La oralidad y las leyendas del oriente salvadoreño.	2021-05-20 16:24:24.08331	2021-05-21 16:24:24.08331
1645	276	237	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-05-27 16:24:20.43361	2021-05-28 16:24:20.43361
1647	277	3	Nueva entrega recibida para revisión: Errores frecuentes en la traducción de textos técnicos al inglés.	2021-08-22 18:46:15.722735	2021-08-23 18:46:15.722735
1648	277	23	Nueva entrega recibida para revisión: Errores frecuentes en la traducción de textos técnicos al inglés.	2021-08-22 18:46:15.722735	2021-08-23 18:46:15.722735
1649	277	22	Nueva entrega recibida para revisión: Errores frecuentes en la traducción de textos técnicos al inglés.	2021-08-22 18:46:15.722735	2021-08-23 18:46:15.722735
1650	277	2	Nueva entrega recibida para revisión: Errores frecuentes en la traducción de textos técnicos al inglés.	2021-08-22 18:46:15.722735	2021-08-23 18:46:15.722735
1651	277	238	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2021-09-02 02:51:34.038819	2021-09-03 02:51:34.038819
1652	278	21	Nueva entrega recibida (versión corregida) para revisión: Errores frecuentes en la traducción de textos técnicos al inglés.	2021-09-14 23:28:44.366628	2021-09-15 23:28:44.366628
1653	278	3	Nueva entrega recibida (versión corregida) para revisión: Errores frecuentes en la traducción de textos técnicos al inglés.	2021-09-14 23:28:44.366628	2021-09-15 23:28:44.366628
209	37	59	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-04-18 11:02:39.732499	2020-04-19 11:02:39.732499
555	95	21	Nueva entrega recibida para revisión: Interpretación consecutiva en un foro de turismo.	2022-04-05 23:41:35.310522	2022-04-06 23:41:35.310522
556	95	3	Nueva entrega recibida para revisión: Interpretación consecutiva en un foro de turismo.	2022-04-05 23:41:35.310522	2022-04-06 23:41:35.310522
222	40	21	Nueva entrega recibida para revisión: Trámites aduaneros para exportar productos agrícolas.	2020-08-05 05:54:49.754748	2020-08-06 05:54:49.754748
1656	278	2	Nueva entrega recibida (versión corregida) para revisión: Errores frecuentes en la traducción de textos técnicos al inglés.	2021-09-14 23:28:44.366628	2021-09-15 23:28:44.366628
2140	358	22	Nueva entrega recibida (versión corregida) para revisión: Diseño de un sistema de drenaje pluvial para una colonia de San Miguel.	2025-06-22 03:08:03.144684	2025-06-23 03:08:03.144684
2141	358	2	Nueva entrega recibida (versión corregida) para revisión: Diseño de un sistema de drenaje pluvial para una colonia de San Miguel.	2025-06-22 03:08:03.144684	2025-06-23 03:08:03.144684
1514	255	3	Nueva entrega recibida para revisión: Índice de precios de los mercados municipales de San Miguel.	2019-03-12 19:00:23.327902	2019-03-13 19:00:23.327902
1515	255	23	Nueva entrega recibida para revisión: Índice de precios de los mercados municipales de San Miguel.	2019-03-12 19:00:23.327902	2019-03-13 19:00:23.327902
1516	255	22	Nueva entrega recibida para revisión: Índice de precios de los mercados municipales de San Miguel.	2019-03-12 19:00:23.327902	2019-03-13 19:00:23.327902
1517	255	2	Nueva entrega recibida para revisión: Índice de precios de los mercados municipales de San Miguel.	2019-03-12 19:00:23.327902	2019-03-13 19:00:23.327902
1518	255	221	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2019-03-20 16:54:00.347827	2019-03-21 16:54:00.347827
1524	256	222	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2019-09-29 06:54:54.781912	2019-09-30 06:54:54.781912
1531	258	21	Nueva entrega recibida para revisión: Prototipo de iluminación pública con paneles solares y sensores.	2020-06-08 15:37:26.234581	2020-06-09 15:37:26.234581
1532	258	3	Nueva entrega recibida para revisión: Prototipo de iluminación pública con paneles solares y sensores.	2020-06-08 15:37:26.234581	2020-06-09 15:37:26.234581
1533	258	23	Nueva entrega recibida para revisión: Prototipo de iluminación pública con paneles solares y sensores.	2020-06-08 15:37:26.234581	2020-06-09 15:37:26.234581
1534	258	22	Nueva entrega recibida para revisión: Prototipo de iluminación pública con paneles solares y sensores.	2020-06-08 15:37:26.234581	2020-06-09 15:37:26.234581
1535	258	2	Nueva entrega recibida para revisión: Prototipo de iluminación pública con paneles solares y sensores.	2020-06-08 15:37:26.234581	2020-06-09 15:37:26.234581
1536	258	224	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-06-20 15:05:53.631943	2020-06-21 15:05:53.631943
1537	259	21	Nueva entrega recibida para revisión: La violencia intrafamiliar en los procesos de familia de San Miguel.	2020-08-17 10:13:53.297914	2020-08-18 10:13:53.297914
1538	259	3	Nueva entrega recibida para revisión: La violencia intrafamiliar en los procesos de familia de San Miguel.	2020-08-17 10:13:53.297914	2020-08-18 10:13:53.297914
1539	259	23	Nueva entrega recibida para revisión: La violencia intrafamiliar en los procesos de familia de San Miguel.	2020-08-17 10:13:53.297914	2020-08-18 10:13:53.297914
1540	259	22	Nueva entrega recibida para revisión: La violencia intrafamiliar en los procesos de familia de San Miguel.	2020-08-17 10:13:53.297914	2020-08-18 10:13:53.297914
1541	259	2	Nueva entrega recibida para revisión: La violencia intrafamiliar en los procesos de familia de San Miguel.	2020-08-17 10:13:53.297914	2020-08-18 10:13:53.297914
2139	358	23	Nueva entrega recibida (versión corregida) para revisión: Diseño de un sistema de drenaje pluvial para una colonia de San Miguel.	2025-06-22 03:08:03.144684	2025-06-23 03:08:03.144684
1561	263	21	Nueva entrega recibida (versión corregida) para revisión: Juego de roles sobre los derechos humanos en tercer ciclo.	2020-11-01 16:24:33.189016	2020-11-02 16:24:33.189016
1562	263	3	Nueva entrega recibida (versión corregida) para revisión: Juego de roles sobre los derechos humanos en tercer ciclo.	2020-11-01 16:24:33.189016	2020-11-02 16:24:33.189016
1563	263	23	Nueva entrega recibida (versión corregida) para revisión: Juego de roles sobre los derechos humanos en tercer ciclo.	2020-11-01 16:24:33.189016	2020-11-02 16:24:33.189016
1564	263	22	Nueva entrega recibida (versión corregida) para revisión: Juego de roles sobre los derechos humanos en tercer ciclo.	2020-11-01 16:24:33.189016	2020-11-02 16:24:33.189016
1543	260	21	Nueva entrega recibida para revisión: Manual de toma y transporte de muestras clínicas.	2020-06-02 13:29:51.349377	2020-06-03 13:29:51.349377
1544	260	3	Nueva entrega recibida para revisión: Manual de toma y transporte de muestras clínicas.	2020-06-02 13:29:51.349377	2020-06-03 13:29:51.349377
1545	260	23	Nueva entrega recibida para revisión: Manual de toma y transporte de muestras clínicas.	2020-06-02 13:29:51.349377	2020-06-03 13:29:51.349377
1546	260	22	Nueva entrega recibida para revisión: Manual de toma y transporte de muestras clínicas.	2020-06-02 13:29:51.349377	2020-06-03 13:29:51.349377
1547	260	2	Nueva entrega recibida para revisión: Manual de toma y transporte de muestras clínicas.	2020-06-02 13:29:51.349377	2020-06-03 13:29:51.349377
1548	260	226	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-06-11 01:34:24.718604	2020-06-12 01:34:24.718604
1565	263	2	Nueva entrega recibida (versión corregida) para revisión: Juego de roles sobre los derechos humanos en tercer ciclo.	2020-11-01 16:24:33.189016	2020-11-02 16:24:33.189016
1549	261	21	Nueva entrega recibida para revisión: Actividad antioxidante del extracto de flor de Jamaica.	2020-07-02 16:47:36.343915	2020-07-03 16:47:36.343915
1550	261	3	Nueva entrega recibida para revisión: Actividad antioxidante del extracto de flor de Jamaica.	2020-07-02 16:47:36.343915	2020-07-03 16:47:36.343915
1551	261	23	Nueva entrega recibida para revisión: Actividad antioxidante del extracto de flor de Jamaica.	2020-07-02 16:47:36.343915	2020-07-03 16:47:36.343915
1552	261	22	Nueva entrega recibida para revisión: Actividad antioxidante del extracto de flor de Jamaica.	2020-07-02 16:47:36.343915	2020-07-03 16:47:36.343915
1553	261	2	Nueva entrega recibida para revisión: Actividad antioxidante del extracto de flor de Jamaica.	2020-07-02 16:47:36.343915	2020-07-03 16:47:36.343915
1554	261	227	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-07-13 17:47:54.69853	2020-07-14 17:47:54.69853
1573	265	21	Nueva entrega recibida para revisión: Patologías en edificaciones de concreto de la zona oriental.	2020-06-04 09:22:08.990435	2020-06-05 09:22:08.990435
1567	264	21	Nueva entrega recibida para revisión: Plan de mercadeo para una tienda en línea de artesanías.	2020-04-10 18:55:03.901396	2020-04-11 18:55:03.901396
329	57	88	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-03-05 08:12:25.66837	2021-03-06 08:12:25.66837
282	50	21	Nueva entrega recibida para revisión: Control de calidad interno en el laboratorio de química clínica.	2021-10-12 20:37:30.412356	2021-10-13 20:37:30.412356
1657	278	238	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-09-19 19:16:42.720384	2021-09-20 19:16:42.720384
1658	279	21	Nueva entrega recibida para revisión: La motivación en el aprendizaje del francés como tercera lengua.	2021-06-21 15:27:23.298391	2021-06-22 15:27:23.298391
1659	279	3	Nueva entrega recibida para revisión: La motivación en el aprendizaje del francés como tercera lengua.	2021-06-21 15:27:23.298391	2021-06-22 15:27:23.298391
1660	279	23	Nueva entrega recibida para revisión: La motivación en el aprendizaje del francés como tercera lengua.	2021-06-21 15:27:23.298391	2021-06-22 15:27:23.298391
1661	279	22	Nueva entrega recibida para revisión: La motivación en el aprendizaje del francés como tercera lengua.	2021-06-21 15:27:23.298391	2021-06-22 15:27:23.298391
1662	279	2	Nueva entrega recibida para revisión: La motivación en el aprendizaje del francés como tercera lengua.	2021-06-21 15:27:23.298391	2021-06-22 15:27:23.298391
1663	279	239	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.	2021-06-30 06:49:07.609264	2021-07-01 06:49:07.609264
1664	280	21	Nueva entrega recibida para revisión: Control prenatal y complicaciones del embarazo en zonas rurales.	2021-05-18 08:45:11.911962	2021-05-19 08:45:11.911962
1665	280	3	Nueva entrega recibida para revisión: Control prenatal y complicaciones del embarazo en zonas rurales.	2021-05-18 08:45:11.911962	2021-05-19 08:45:11.911962
1666	280	23	Nueva entrega recibida para revisión: Control prenatal y complicaciones del embarazo en zonas rurales.	2021-05-18 08:45:11.911962	2021-05-19 08:45:11.911962
1667	280	22	Nueva entrega recibida para revisión: Control prenatal y complicaciones del embarazo en zonas rurales.	2021-05-18 08:45:11.911962	2021-05-19 08:45:11.911962
1668	280	2	Nueva entrega recibida para revisión: Control prenatal y complicaciones del embarazo en zonas rurales.	2021-05-18 08:45:11.911962	2021-05-19 08:45:11.911962
1669	280	240	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2021-05-25 10:24:19.228744	2021-05-26 10:24:19.228744
1675	281	240	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-06-01 08:51:34.917327	2021-06-02 08:51:34.917327
1676	282	21	Nueva entrega recibida para revisión: Laboratorio virtual de ondas para estudiantes de bachillerato.	2021-10-15 07:39:20.592027	2021-10-16 07:39:20.592027
1677	282	3	Nueva entrega recibida para revisión: Laboratorio virtual de ondas para estudiantes de bachillerato.	2021-10-15 07:39:20.592027	2021-10-16 07:39:20.592027
1678	282	23	Nueva entrega recibida para revisión: Laboratorio virtual de ondas para estudiantes de bachillerato.	2021-10-15 07:39:20.592027	2021-10-16 07:39:20.592027
1679	282	22	Nueva entrega recibida para revisión: Laboratorio virtual de ondas para estudiantes de bachillerato.	2021-10-15 07:39:20.592027	2021-10-16 07:39:20.592027
1680	282	2	Nueva entrega recibida para revisión: Laboratorio virtual de ondas para estudiantes de bachillerato.	2021-10-15 07:39:20.592027	2021-10-16 07:39:20.592027
270	48	21	Nueva entrega recibida para revisión: Bloqueo subaracnoideo frente a anestesia general en cesáreas.	2021-03-21 15:15:48.374278	2021-03-22 15:15:48.374278
271	48	3	Nueva entrega recibida para revisión: Bloqueo subaracnoideo frente a anestesia general en cesáreas.	2021-03-21 15:15:48.374278	2021-03-22 15:15:48.374278
1670	281	21	Nueva entrega recibida (versión corregida) para revisión: Control prenatal y complicaciones del embarazo en zonas rurales.	2021-05-28 06:57:46.565213	2021-05-29 06:57:46.565213
1671	281	3	Nueva entrega recibida (versión corregida) para revisión: Control prenatal y complicaciones del embarazo en zonas rurales.	2021-05-28 06:57:46.565213	2021-05-29 06:57:46.565213
1672	281	23	Nueva entrega recibida (versión corregida) para revisión: Control prenatal y complicaciones del embarazo en zonas rurales.	2021-05-28 06:57:46.565213	2021-05-29 06:57:46.565213
1673	281	22	Nueva entrega recibida (versión corregida) para revisión: Control prenatal y complicaciones del embarazo en zonas rurales.	2021-05-28 06:57:46.565213	2021-05-29 06:57:46.565213
1674	281	2	Nueva entrega recibida (versión corregida) para revisión: Control prenatal y complicaciones del embarazo en zonas rurales.	2021-05-28 06:57:46.565213	2021-05-29 06:57:46.565213
2142	358	291	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-06-25 21:03:05.469468	2025-06-26 21:03:05.469468
2143	359	21	Nueva entrega recibida para revisión: Tiempos de despacho en la aduana terrestre de El Amatillo.	2025-08-05 21:39:03.033292	2025-08-06 21:39:03.033292
2144	359	3	Nueva entrega recibida para revisión: Tiempos de despacho en la aduana terrestre de El Amatillo.	2025-08-05 21:39:03.033292	2025-08-06 21:39:03.033292
2145	359	23	Nueva entrega recibida para revisión: Tiempos de despacho en la aduana terrestre de El Amatillo.	2025-08-05 21:39:03.033292	2025-08-06 21:39:03.033292
2146	359	22	Nueva entrega recibida para revisión: Tiempos de despacho en la aduana terrestre de El Amatillo.	2025-08-05 21:39:03.033292	2025-08-06 21:39:03.033292
2147	359	2	Nueva entrega recibida para revisión: Tiempos de despacho en la aduana terrestre de El Amatillo.	2025-08-05 21:39:03.033292	2025-08-06 21:39:03.033292
2154	360	292	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-08-24 16:49:05.014216	2025-08-25 16:49:05.014216
2161	362	21	Nueva entrega recibida para revisión: Producción de hongos comestibles con residuos agrícolas.	2025-05-08 14:55:45.197425	2025-05-09 14:55:45.197425
2162	362	3	Nueva entrega recibida para revisión: Producción de hongos comestibles con residuos agrícolas.	2025-05-08 14:55:45.197425	2025-05-09 14:55:45.197425
2155	361	21	Nueva entrega recibida para revisión: Inclusión de niños con discapacidad en la educación parvularia.	2025-04-19 11:36:19.607911	2025-04-20 11:36:19.607911
2172	363	294	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-06-10 13:08:45.175557	2025-06-11 13:08:45.175557
331	58	21	Nueva entrega recibida para revisión: Factores de riesgo de diabetes tipo 2 en unidades de salud rurales.	2021-05-26 15:29:24.329904	2021-05-27 15:29:24.329904
332	58	3	Nueva entrega recibida para revisión: Factores de riesgo de diabetes tipo 2 en unidades de salud rurales.	2021-05-26 15:29:24.329904	2021-05-27 15:29:24.329904
293	51	85	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.	2021-09-03 08:49:22.382253	2021-09-04 08:49:22.382253
354	61	71	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-07-05 08:56:29.264667	2021-07-06 08:56:29.264667
1681	282	241	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-10-30 01:37:12.026709	2021-10-31 01:37:12.026709
2148	359	292	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2025-08-10 15:54:16.342347	2025-08-11 15:54:16.342347
2149	360	21	Nueva entrega recibida (versión corregida) para revisión: Tiempos de despacho en la aduana terrestre de El Amatillo.	2025-08-16 14:23:13.667719	2025-08-17 14:23:13.667719
2150	360	3	Nueva entrega recibida (versión corregida) para revisión: Tiempos de despacho en la aduana terrestre de El Amatillo.	2025-08-16 14:23:13.667719	2025-08-17 14:23:13.667719
2151	360	23	Nueva entrega recibida (versión corregida) para revisión: Tiempos de despacho en la aduana terrestre de El Amatillo.	2025-08-16 14:23:13.667719	2025-08-17 14:23:13.667719
2152	360	22	Nueva entrega recibida (versión corregida) para revisión: Tiempos de despacho en la aduana terrestre de El Amatillo.	2025-08-16 14:23:13.667719	2025-08-17 14:23:13.667719
1568	264	3	Nueva entrega recibida para revisión: Plan de mercadeo para una tienda en línea de artesanías.	2020-04-10 18:55:03.901396	2020-04-11 18:55:03.901396
1569	264	23	Nueva entrega recibida para revisión: Plan de mercadeo para una tienda en línea de artesanías.	2020-04-10 18:55:03.901396	2020-04-11 18:55:03.901396
1570	264	22	Nueva entrega recibida para revisión: Plan de mercadeo para una tienda en línea de artesanías.	2020-04-10 18:55:03.901396	2020-04-11 18:55:03.901396
1571	264	2	Nueva entrega recibida para revisión: Plan de mercadeo para una tienda en línea de artesanías.	2020-04-10 18:55:03.901396	2020-04-11 18:55:03.901396
1566	263	228	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2020-11-04 21:38:24.592575	2020-11-05 21:38:24.592575
1574	265	3	Nueva entrega recibida para revisión: Patologías en edificaciones de concreto de la zona oriental.	2020-06-04 09:22:08.990435	2020-06-05 09:22:08.990435
1575	265	23	Nueva entrega recibida para revisión: Patologías en edificaciones de concreto de la zona oriental.	2020-06-04 09:22:08.990435	2020-06-05 09:22:08.990435
1576	265	22	Nueva entrega recibida para revisión: Patologías en edificaciones de concreto de la zona oriental.	2020-06-04 09:22:08.990435	2020-06-05 09:22:08.990435
1577	265	2	Nueva entrega recibida para revisión: Patologías en edificaciones de concreto de la zona oriental.	2020-06-04 09:22:08.990435	2020-06-05 09:22:08.990435
1572	264	229	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-04-14 12:50:43.367434	2020-04-15 12:50:43.367434
1591	268	21	Nueva entrega recibida para revisión: Anfibios como indicadores de la salud de los bosques de Morazán.	2021-04-22 06:06:36.871404	2021-04-23 06:06:36.871404
1592	268	3	Nueva entrega recibida para revisión: Anfibios como indicadores de la salud de los bosques de Morazán.	2021-04-22 06:06:36.871404	2021-04-23 06:06:36.871404
1593	268	23	Nueva entrega recibida para revisión: Anfibios como indicadores de la salud de los bosques de Morazán.	2021-04-22 06:06:36.871404	2021-04-23 06:06:36.871404
1594	268	22	Nueva entrega recibida para revisión: Anfibios como indicadores de la salud de los bosques de Morazán.	2021-04-22 06:06:36.871404	2021-04-23 06:06:36.871404
2153	360	2	Nueva entrega recibida (versión corregida) para revisión: Tiempos de despacho en la aduana terrestre de El Amatillo.	2025-08-16 14:23:13.667719	2025-08-17 14:23:13.667719
609	104	21	Nueva entrega recibida para revisión: Factibilidad de un sistema fotovoltaico para la biblioteca de la facultad.	2023-03-28 14:35:45.350772	2023-03-29 14:35:45.350772
610	104	3	Nueva entrega recibida para revisión: Factibilidad de un sistema fotovoltaico para la biblioteca de la facultad.	2023-03-28 14:35:45.350772	2023-03-29 14:35:45.350772
611	104	23	Nueva entrega recibida para revisión: Factibilidad de un sistema fotovoltaico para la biblioteca de la facultad.	2023-03-28 14:35:45.350772	2023-03-29 14:35:45.350772
612	104	22	Nueva entrega recibida para revisión: Factibilidad de un sistema fotovoltaico para la biblioteca de la facultad.	2023-03-28 14:35:45.350772	2023-03-29 14:35:45.350772
613	104	2	Nueva entrega recibida para revisión: Factibilidad de un sistema fotovoltaico para la biblioteca de la facultad.	2023-03-28 14:35:45.350772	2023-03-29 14:35:45.350772
349	61	21	Nueva entrega recibida (versión corregida) para revisión: Manual de seguridad para laboratorios escolares de química.	2021-07-02 07:38:42.855781	2021-07-03 07:38:42.855781
350	61	3	Nueva entrega recibida (versión corregida) para revisión: Manual de seguridad para laboratorios escolares de química.	2021-07-02 07:38:42.855781	2021-07-03 07:38:42.855781
351	61	23	Nueva entrega recibida (versión corregida) para revisión: Manual de seguridad para laboratorios escolares de química.	2021-07-02 07:38:42.855781	2021-07-03 07:38:42.855781
352	61	22	Nueva entrega recibida (versión corregida) para revisión: Manual de seguridad para laboratorios escolares de química.	2021-07-02 07:38:42.855781	2021-07-03 07:38:42.855781
353	61	2	Nueva entrega recibida (versión corregida) para revisión: Manual de seguridad para laboratorios escolares de química.	2021-07-02 07:38:42.855781	2021-07-03 07:38:42.855781
366	63	91	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-09-07 22:36:56.101488	2021-09-08 22:36:56.101488
372	64	92	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-08-25 05:18:03.222559	2021-08-26 05:18:03.222559
601	102	2	Nueva entrega recibida para revisión: Diseño de un secador solar de granos para pequeños productores de San Miguel.	2023-08-24 14:18:30.729963	2023-08-25 14:18:30.729963
384	66	93	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-08-19 09:35:21.471539	2021-08-20 09:35:21.471539
602	102	116	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2023-09-03 07:39:07.052994	2023-09-04 07:39:07.052994
1682	283	21	Nueva entrega recibida para revisión: Liderazgo y desempeño laboral en una institución pública.	2021-03-07 15:35:21.772573	2021-03-08 15:35:21.772573
1683	283	3	Nueva entrega recibida para revisión: Liderazgo y desempeño laboral en una institución pública.	2021-03-07 15:35:21.772573	2021-03-08 15:35:21.772573
1684	283	23	Nueva entrega recibida para revisión: Liderazgo y desempeño laboral en una institución pública.	2021-03-07 15:35:21.772573	2021-03-08 15:35:21.772573
1685	283	22	Nueva entrega recibida para revisión: Liderazgo y desempeño laboral en una institución pública.	2021-03-07 15:35:21.772573	2021-03-08 15:35:21.772573
1686	283	2	Nueva entrega recibida para revisión: Liderazgo y desempeño laboral en una institución pública.	2021-03-07 15:35:21.772573	2021-03-08 15:35:21.772573
1687	283	242	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2021-03-18 09:18:26.127258	2021-03-19 09:18:26.127258
1688	284	21	Nueva entrega recibida (versión corregida) para revisión: Liderazgo y desempeño laboral en una institución pública.	2021-03-30 09:38:18.507555	2021-03-31 09:38:18.507555
1689	284	3	Nueva entrega recibida (versión corregida) para revisión: Liderazgo y desempeño laboral en una institución pública.	2021-03-30 09:38:18.507555	2021-03-31 09:38:18.507555
1690	284	23	Nueva entrega recibida (versión corregida) para revisión: Liderazgo y desempeño laboral en una institución pública.	2021-03-30 09:38:18.507555	2021-03-31 09:38:18.507555
1691	284	22	Nueva entrega recibida (versión corregida) para revisión: Liderazgo y desempeño laboral en una institución pública.	2021-03-30 09:38:18.507555	2021-03-31 09:38:18.507555
1693	284	242	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-04-05 10:14:20.883494	2021-04-06 10:14:20.883494
364	63	22	Nueva entrega recibida (versión corregida) para revisión: Indicadores ácido-base elaborados con repollo morado.	2021-08-28 03:04:26.717088	2021-08-29 03:04:26.717088
365	63	2	Nueva entrega recibida (versión corregida) para revisión: Indicadores ácido-base elaborados con repollo morado.	2021-08-28 03:04:26.717088	2021-08-29 03:04:26.717088
722	122	132	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2023-06-10 19:54:17.386389	2023-06-11 19:54:17.386389
723	123	21	Nueva entrega recibida (versión corregida) para revisión: Cadenas de Markov aplicadas al rendimiento estudiantil.	2023-06-22 06:19:26.748078	2023-06-23 06:19:26.748078
714	121	22	Nueva entrega recibida para revisión: Comportamiento del consumidor de comercio electrónico en San Miguel.	2023-05-30 18:00:32.390653	2023-05-31 18:00:32.390653
715	121	2	Nueva entrega recibida para revisión: Comportamiento del consumidor de comercio electrónico en San Miguel.	2023-05-30 18:00:32.390653	2023-05-31 18:00:32.390653
1692	284	2	Nueva entrega recibida (versión corregida) para revisión: Liderazgo y desempeño laboral en una institución pública.	2021-03-30 09:38:18.507555	2021-03-31 09:38:18.507555
2168	363	3	Nueva entrega recibida (versión corregida) para revisión: Producción de hongos comestibles con residuos agrícolas.	2025-05-29 05:50:35.836683	2025-05-30 05:50:35.836683
2169	363	23	Nueva entrega recibida (versión corregida) para revisión: Producción de hongos comestibles con residuos agrícolas.	2025-05-29 05:50:35.836683	2025-05-30 05:50:35.836683
2170	363	22	Nueva entrega recibida (versión corregida) para revisión: Producción de hongos comestibles con residuos agrícolas.	2025-05-29 05:50:35.836683	2025-05-30 05:50:35.836683
1595	268	2	Nueva entrega recibida para revisión: Anfibios como indicadores de la salud de los bosques de Morazán.	2021-04-22 06:06:36.871404	2021-04-23 06:06:36.871404
2126	356	3	Nueva entrega recibida para revisión: Propuesta de mobiliario urbano para el parque central.	2025-05-24 05:35:09.451774	2025-05-25 05:35:09.451774
2260	379	21	Nueva entrega recibida para revisión: Simulación numérica de la conducción de calor.	2026-07-15 01:46:54.313046	2026-07-16 01:46:54.313046
2261	379	3	Nueva entrega recibida para revisión: Simulación numérica de la conducción de calor.	2026-07-15 01:46:54.313046	2026-07-16 01:46:54.313046
2262	379	23	Nueva entrega recibida para revisión: Simulación numérica de la conducción de calor.	2026-07-15 01:46:54.313046	2026-07-16 01:46:54.313046
2263	379	22	Nueva entrega recibida para revisión: Simulación numérica de la conducción de calor.	2026-07-15 01:46:54.313046	2026-07-16 01:46:54.313046
2254	378	21	Nueva entrega recibida para revisión: El arte infantil como medio de expresión emocional.	2026-05-28 04:12:34.606846	2026-05-29 04:12:34.606846
2255	378	3	Nueva entrega recibida para revisión: El arte infantil como medio de expresión emocional.	2026-05-28 04:12:34.606846	2026-05-29 04:12:34.606846
2256	378	23	Nueva entrega recibida para revisión: El arte infantil como medio de expresión emocional.	2026-05-28 04:12:34.606846	2026-05-29 04:12:34.606846
2257	378	22	Nueva entrega recibida para revisión: El arte infantil como medio de expresión emocional.	2026-05-28 04:12:34.606846	2026-05-29 04:12:34.606846
2258	378	2	Nueva entrega recibida para revisión: El arte infantil como medio de expresión emocional.	2026-05-28 04:12:34.606846	2026-05-29 04:12:34.606846
2264	379	2	Nueva entrega recibida para revisión: Simulación numérica de la conducción de calor.	2026-07-15 01:46:54.313046	2026-07-16 01:46:54.313046
2265	379	305	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-07-22 15:58:36.695541	2026-07-23 15:58:36.695541
1608	270	234	Decisión del supervisor: Rechazada. El documento adjunto no corresponde al trabajo descrito en la ficha.	2021-05-17 02:57:41.596585	2021-05-18 02:57:41.596585
1609	271	21	Nueva entrega recibida para revisión: Lista de verificación de seguridad del equipo de anestesia.	2021-08-24 11:08:11.898629	2021-08-25 11:08:11.898629
1610	271	3	Nueva entrega recibida para revisión: Lista de verificación de seguridad del equipo de anestesia.	2021-08-24 11:08:11.898629	2021-08-25 11:08:11.898629
1611	271	23	Nueva entrega recibida para revisión: Lista de verificación de seguridad del equipo de anestesia.	2021-08-24 11:08:11.898629	2021-08-25 11:08:11.898629
1612	271	22	Nueva entrega recibida para revisión: Lista de verificación de seguridad del equipo de anestesia.	2021-08-24 11:08:11.898629	2021-08-25 11:08:11.898629
1613	271	2	Nueva entrega recibida para revisión: Lista de verificación de seguridad del equipo de anestesia.	2021-08-24 11:08:11.898629	2021-08-25 11:08:11.898629
1614	271	234	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-09-02 07:53:56.252112	2021-09-03 07:53:56.252112
1628	274	21	Nueva entrega recibida para revisión: Plataforma web para la gestión de prácticas profesionales.	2021-11-23 22:35:44.516119	2021-11-24 22:35:44.516119
1629	274	3	Nueva entrega recibida para revisión: Plataforma web para la gestión de prácticas profesionales.	2021-11-23 22:35:44.516119	2021-11-24 22:35:44.516119
1630	274	23	Nueva entrega recibida para revisión: Plataforma web para la gestión de prácticas profesionales.	2021-11-23 22:35:44.516119	2021-11-24 22:35:44.516119
1615	272	21	Nueva entrega recibida para revisión: Contenido de nitratos en agua de pozos de la zona oriental.	2021-08-04 16:33:41.914404	2021-08-05 16:33:41.914404
1616	272	3	Nueva entrega recibida para revisión: Contenido de nitratos en agua de pozos de la zona oriental.	2021-08-04 16:33:41.914404	2021-08-05 16:33:41.914404
1617	272	23	Nueva entrega recibida para revisión: Contenido de nitratos en agua de pozos de la zona oriental.	2021-08-04 16:33:41.914404	2021-08-05 16:33:41.914404
1618	272	22	Nueva entrega recibida para revisión: Contenido de nitratos en agua de pozos de la zona oriental.	2021-08-04 16:33:41.914404	2021-08-05 16:33:41.914404
1619	272	2	Nueva entrega recibida para revisión: Contenido de nitratos en agua de pozos de la zona oriental.	2021-08-04 16:33:41.914404	2021-08-05 16:33:41.914404
1620	272	235	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2021-08-09 10:28:08.215175	2021-08-10 10:28:08.215175
1621	273	21	Nueva entrega recibida (versión corregida) para revisión: Contenido de nitratos en agua de pozos de la zona oriental.	2021-08-15 13:26:16.545862	2021-08-16 13:26:16.545862
1622	273	3	Nueva entrega recibida (versión corregida) para revisión: Contenido de nitratos en agua de pozos de la zona oriental.	2021-08-15 13:26:16.545862	2021-08-16 13:26:16.545862
1623	273	23	Nueva entrega recibida (versión corregida) para revisión: Contenido de nitratos en agua de pozos de la zona oriental.	2021-08-15 13:26:16.545862	2021-08-16 13:26:16.545862
1624	273	22	Nueva entrega recibida (versión corregida) para revisión: Contenido de nitratos en agua de pozos de la zona oriental.	2021-08-15 13:26:16.545862	2021-08-16 13:26:16.545862
2171	363	2	Nueva entrega recibida (versión corregida) para revisión: Producción de hongos comestibles con residuos agrícolas.	2025-05-29 05:50:35.836683	2025-05-30 05:50:35.836683
439	75	99	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-10-22 19:35:34.588333	2021-10-23 19:35:34.588333
381	66	23	Nueva entrega recibida (versión corregida) para revisión: Modelos de ecuaciones diferenciales para la propagación del dengue.	2021-08-10 06:45:29.089453	2021-08-11 06:45:29.089453
382	66	22	Nueva entrega recibida (versión corregida) para revisión: Modelos de ecuaciones diferenciales para la propagación del dengue.	2021-08-10 06:45:29.089453	2021-08-11 06:45:29.089453
1719	289	21	Nueva entrega recibida para revisión: Gestión financiera de las pequeñas empresas familiares de San Miguel.	2022-10-09 06:06:34.633495	2022-10-10 06:06:34.633495
1720	289	3	Nueva entrega recibida para revisión: Gestión financiera de las pequeñas empresas familiares de San Miguel.	2022-10-09 06:06:34.633495	2022-10-10 06:06:34.633495
1701	286	21	Nueva entrega recibida para revisión: El turismo como motor del desarrollo económico de la ruta de la paz.	2022-08-30 20:28:35.318943	2022-08-31 20:28:35.318943
1702	286	3	Nueva entrega recibida para revisión: El turismo como motor del desarrollo económico de la ruta de la paz.	2022-08-30 20:28:35.318943	2022-08-31 20:28:35.318943
625	106	2	Nueva entrega recibida para revisión: Calidad del agua del río Grande de San Miguel mediante macroinvertebrados.	2023-10-19 11:21:08.348793	2023-10-20 11:21:08.348793
434	75	21	Nueva entrega recibida para revisión: Deshidratado de mango como alternativa de agroindustria rural.	2021-10-15 14:18:18.204223	2021-10-16 14:18:18.204223
416	72	21	Nueva entrega recibida para revisión: Evaluación del pavimento de la carretera Panamericana en el tramo de San Miguel.	2021-05-28 15:17:30.181522	2021-05-29 15:17:30.181522
417	72	3	Nueva entrega recibida para revisión: Evaluación del pavimento de la carretera Panamericana en el tramo de San Miguel.	2021-05-28 15:17:30.181522	2021-05-29 15:17:30.181522
418	72	23	Nueva entrega recibida para revisión: Evaluación del pavimento de la carretera Panamericana en el tramo de San Miguel.	2021-05-28 15:17:30.181522	2021-05-29 15:17:30.181522
1703	286	23	Nueva entrega recibida para revisión: El turismo como motor del desarrollo económico de la ruta de la paz.	2022-08-30 20:28:35.318943	2022-08-31 20:28:35.318943
419	72	22	Nueva entrega recibida para revisión: Evaluación del pavimento de la carretera Panamericana en el tramo de San Miguel.	2021-05-28 15:17:30.181522	2021-05-29 15:17:30.181522
420	72	2	Nueva entrega recibida para revisión: Evaluación del pavimento de la carretera Panamericana en el tramo de San Miguel.	2021-05-28 15:17:30.181522	2021-05-29 15:17:30.181522
398	69	21	Nueva entrega recibida para revisión: Auditoría de inventarios en una ferretería.	2021-09-06 13:28:28.983904	2021-09-07 13:28:28.983904
399	69	3	Nueva entrega recibida para revisión: Auditoría de inventarios en una ferretería.	2021-09-06 13:28:28.983904	2021-09-07 13:28:28.983904
400	69	23	Nueva entrega recibida para revisión: Auditoría de inventarios en una ferretería.	2021-09-06 13:28:28.983904	2021-09-07 13:28:28.983904
401	69	22	Nueva entrega recibida para revisión: Auditoría de inventarios en una ferretería.	2021-09-06 13:28:28.983904	2021-09-07 13:28:28.983904
402	69	2	Nueva entrega recibida para revisión: Auditoría de inventarios en una ferretería.	2021-09-06 13:28:28.983904	2021-09-07 13:28:28.983904
1704	286	22	Nueva entrega recibida para revisión: El turismo como motor del desarrollo económico de la ruta de la paz.	2022-08-30 20:28:35.318943	2022-08-31 20:28:35.318943
1705	286	2	Nueva entrega recibida para revisión: El turismo como motor del desarrollo económico de la ruta de la paz.	2022-08-30 20:28:35.318943	2022-08-31 20:28:35.318943
409	70	95	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-09-09 00:25:05.441061	2021-09-10 00:25:05.441061
1694	285	21	Nueva entrega recibida para revisión: Efecto del biochar en la fertilidad del suelo.	2021-04-04 21:36:10.213395	2021-04-05 21:36:10.213395
1695	285	3	Nueva entrega recibida para revisión: Efecto del biochar en la fertilidad del suelo.	2021-04-04 21:36:10.213395	2021-04-05 21:36:10.213395
1696	285	23	Nueva entrega recibida para revisión: Efecto del biochar en la fertilidad del suelo.	2021-04-04 21:36:10.213395	2021-04-05 21:36:10.213395
1723	289	2	Nueva entrega recibida para revisión: Gestión financiera de las pequeñas empresas familiares de San Miguel.	2022-10-09 06:06:34.633495	2022-10-10 06:06:34.633495
1724	289	242	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.	2022-10-19 13:05:33.01058	2022-10-20 13:05:33.01058
1725	290	21	Nueva entrega recibida para revisión: Programación lineal aplicada a la planificación de cosechas.	2022-04-29 23:18:30.364049	2022-04-30 23:18:30.364049
1726	290	3	Nueva entrega recibida para revisión: Programación lineal aplicada a la planificación de cosechas.	2022-04-29 23:18:30.364049	2022-04-30 23:18:30.364049
1727	290	23	Nueva entrega recibida para revisión: Programación lineal aplicada a la planificación de cosechas.	2022-04-29 23:18:30.364049	2022-04-30 23:18:30.364049
1728	290	22	Nueva entrega recibida para revisión: Programación lineal aplicada a la planificación de cosechas.	2022-04-29 23:18:30.364049	2022-04-30 23:18:30.364049
1729	290	2	Nueva entrega recibida para revisión: Programación lineal aplicada a la planificación de cosechas.	2022-04-29 23:18:30.364049	2022-04-30 23:18:30.364049
438	75	2	Nueva entrega recibida para revisión: Deshidratado de mango como alternativa de agroindustria rural.	2021-10-15 14:18:18.204223	2021-10-16 14:18:18.204223
1730	290	246	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-05-07 08:40:55.754061	2022-05-08 08:40:55.754061
1743	293	21	Nueva entrega recibida para revisión: Logística inversa de envases en una distribuidora de bebidas.	2022-06-16 21:34:43.665465	2022-06-17 21:34:43.665465
1744	293	3	Nueva entrega recibida para revisión: Logística inversa de envases en una distribuidora de bebidas.	2022-06-16 21:34:43.665465	2022-06-17 21:34:43.665465
1731	291	21	Nueva entrega recibida para revisión: Errores en el aprendizaje del álgebra en séptimo grado.	2022-10-20 05:10:29.097327	2022-10-21 05:10:29.097327
1732	291	3	Nueva entrega recibida para revisión: Errores en el aprendizaje del álgebra en séptimo grado.	2022-10-20 05:10:29.097327	2022-10-21 05:10:29.097327
1733	291	23	Nueva entrega recibida para revisión: Errores en el aprendizaje del álgebra en séptimo grado.	2022-10-20 05:10:29.097327	2022-10-21 05:10:29.097327
1742	292	247	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-11-19 19:59:08.297521	2022-11-20 19:59:08.297521
451	77	101	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-06-11 15:24:42.046429	2022-06-12 15:24:42.046429
633	108	21	Nueva entrega recibida para revisión: Uso de canciones para mejorar la pronunciación del inglés en séptimo grado.	2023-12-01 09:11:02.264778	2023-12-02 09:11:02.264778
634	108	3	Nueva entrega recibida para revisión: Uso de canciones para mejorar la pronunciación del inglés en séptimo grado.	2023-12-01 09:11:02.264778	2023-12-02 09:11:02.264778
635	108	23	Nueva entrega recibida para revisión: Uso de canciones para mejorar la pronunciación del inglés en séptimo grado.	2023-12-01 09:11:02.264778	2023-12-02 09:11:02.264778
1745	293	23	Nueva entrega recibida para revisión: Logística inversa de envases en una distribuidora de bebidas.	2022-06-16 21:34:43.665465	2022-06-17 21:34:43.665465
1746	293	22	Nueva entrega recibida para revisión: Logística inversa de envases en una distribuidora de bebidas.	2022-06-16 21:34:43.665465	2022-06-17 21:34:43.665465
1747	293	2	Nueva entrega recibida para revisión: Logística inversa de envases en una distribuidora de bebidas.	2022-06-16 21:34:43.665465	2022-06-17 21:34:43.665465
1748	293	248	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.	2022-06-24 09:25:02.042754	2022-06-25 09:25:02.042754
1749	294	21	Nueva entrega recibida (versión corregida) para revisión: Logística inversa de envases en una distribuidora de bebidas.	2022-06-29 23:49:05.422615	2022-06-30 23:49:05.422615
1750	294	3	Nueva entrega recibida (versión corregida) para revisión: Logística inversa de envases en una distribuidora de bebidas.	2022-06-29 23:49:05.422615	2022-06-30 23:49:05.422615
1751	294	23	Nueva entrega recibida (versión corregida) para revisión: Logística inversa de envases en una distribuidora de bebidas.	2022-06-29 23:49:05.422615	2022-06-30 23:49:05.422615
1752	294	22	Nueva entrega recibida (versión corregida) para revisión: Logística inversa de envases en una distribuidora de bebidas.	2022-06-29 23:49:05.422615	2022-06-30 23:49:05.422615
507	87	21	Nueva entrega recibida para revisión: Síntesis de biodiésel a partir de aceite de cocina usado.	2022-11-27 18:59:17.424206	2022-11-28 18:59:17.424206
508	87	3	Nueva entrega recibida para revisión: Síntesis de biodiésel a partir de aceite de cocina usado.	2022-11-27 18:59:17.424206	2022-11-28 18:59:17.424206
509	87	23	Nueva entrega recibida para revisión: Síntesis de biodiésel a partir de aceite de cocina usado.	2022-11-27 18:59:17.424206	2022-11-28 18:59:17.424206
510	87	22	Nueva entrega recibida para revisión: Síntesis de biodiésel a partir de aceite de cocina usado.	2022-11-27 18:59:17.424206	2022-11-28 18:59:17.424206
511	87	2	Nueva entrega recibida para revisión: Síntesis de biodiésel a partir de aceite de cocina usado.	2022-11-27 18:59:17.424206	2022-11-28 18:59:17.424206
2186	366	21	Nueva entrega recibida para revisión: Pérdidas técnicas en la red de distribución de un municipio.	2026-11-17 05:57:24.651361	\N
2187	366	3	Nueva entrega recibida para revisión: Pérdidas técnicas en la red de distribución de un municipio.	2026-11-17 05:57:24.651361	\N
1753	294	2	Nueva entrega recibida (versión corregida) para revisión: Logística inversa de envases en una distribuidora de bebidas.	2022-06-29 23:49:05.422615	2022-06-30 23:49:05.422615
1754	294	248	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-07-07 03:41:52.805826	2022-07-08 03:41:52.805826
2178	364	2	Nueva entrega recibida para revisión: Análisis de fallas en ejes de transmisión de maquinaria agrícola.	2026-03-21 22:48:51.768738	2026-03-22 22:48:51.768738
2179	364	295	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.	2026-04-01 16:41:53.080016	2026-04-02 16:41:53.080016
2180	365	21	Nueva entrega recibida (versión corregida) para revisión: Análisis de fallas en ejes de transmisión de maquinaria agrícola.	2026-04-05 06:21:21.407237	2026-04-06 06:21:21.407237
2181	365	3	Nueva entrega recibida (versión corregida) para revisión: Análisis de fallas en ejes de transmisión de maquinaria agrícola.	2026-04-05 06:21:21.407237	2026-04-06 06:21:21.407237
2182	365	23	Nueva entrega recibida (versión corregida) para revisión: Análisis de fallas en ejes de transmisión de maquinaria agrícola.	2026-04-05 06:21:21.407237	2026-04-06 06:21:21.407237
2183	365	22	Nueva entrega recibida (versión corregida) para revisión: Análisis de fallas en ejes de transmisión de maquinaria agrícola.	2026-04-05 06:21:21.407237	2026-04-06 06:21:21.407237
2184	365	2	Nueva entrega recibida (versión corregida) para revisión: Análisis de fallas en ejes de transmisión de maquinaria agrícola.	2026-04-05 06:21:21.407237	2026-04-06 06:21:21.407237
2185	365	295	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-04-20 00:15:20.749328	2026-04-21 00:15:20.749328
640	109	3	Nueva entrega recibida para revisión: Material didáctico de inglés para estudiantes con baja visión.	2023-07-29 09:56:34.169288	2023-07-30 09:56:34.169288
641	109	23	Nueva entrega recibida para revisión: Material didáctico de inglés para estudiantes con baja visión.	2023-07-29 09:56:34.169288	2023-07-30 09:56:34.169288
784	133	21	Nueva entrega recibida para revisión: Composición de la flora del cerro El Tigre en Morazán.	2024-11-16 04:25:28.736063	2024-11-17 04:25:28.736063
785	133	3	Nueva entrega recibida para revisión: Composición de la flora del cerro El Tigre en Morazán.	2024-11-16 04:25:28.736063	2024-11-17 04:25:28.736063
767	130	23	Nueva entrega recibida para revisión: Guía de prácticas de biología para centros escolares sin laboratorio.	2024-08-12 04:08:21.240532	2024-08-13 04:08:21.240532
768	130	22	Nueva entrega recibida para revisión: Guía de prácticas de biología para centros escolares sin laboratorio.	2024-08-12 04:08:21.240532	2024-08-13 04:08:21.240532
769	130	2	Nueva entrega recibida para revisión: Guía de prácticas de biología para centros escolares sin laboratorio.	2024-08-12 04:08:21.240532	2024-08-13 04:08:21.240532
771	131	21	Nueva entrega recibida para revisión: Potencial de generación eólica en la zona costera de La Unión.	2024-08-19 04:41:40.19961	2024-08-20 04:41:40.19961
772	131	3	Nueva entrega recibida para revisión: Potencial de generación eólica en la zona costera de La Unión.	2024-08-19 04:41:40.19961	2024-08-20 04:41:40.19961
773	131	23	Nueva entrega recibida para revisión: Potencial de generación eólica en la zona costera de La Unión.	2024-08-19 04:41:40.19961	2024-08-20 04:41:40.19961
774	131	22	Nueva entrega recibida para revisión: Potencial de generación eólica en la zona costera de La Unión.	2024-08-19 04:41:40.19961	2024-08-20 04:41:40.19961
775	131	2	Nueva entrega recibida para revisión: Potencial de generación eólica en la zona costera de La Unión.	2024-08-19 04:41:40.19961	2024-08-20 04:41:40.19961
777	132	21	Nueva entrega recibida para revisión: Diversidad de murciélagos en el manglar de la bahía de Jiquilisco.	2024-07-17 22:22:29.799454	2024-07-18 22:22:29.799454
778	132	3	Nueva entrega recibida para revisión: Diversidad de murciélagos en el manglar de la bahía de Jiquilisco.	2024-07-17 22:22:29.799454	2024-07-18 22:22:29.799454
779	132	23	Nueva entrega recibida para revisión: Diversidad de murciélagos en el manglar de la bahía de Jiquilisco.	2024-07-17 22:22:29.799454	2024-07-18 22:22:29.799454
780	132	22	Nueva entrega recibida para revisión: Diversidad de murciélagos en el manglar de la bahía de Jiquilisco.	2024-07-17 22:22:29.799454	2024-07-18 22:22:29.799454
781	132	2	Nueva entrega recibida para revisión: Diversidad de murciélagos en el manglar de la bahía de Jiquilisco.	2024-07-17 22:22:29.799454	2024-07-18 22:22:29.799454
783	132	140	Tu publicación fue retirada del catálogo. Motivo: Los autores pidieron retirar la publicación para enviarla a una revista científica.	2024-10-04 01:59:38.435681	2024-10-05 01:59:38.435681
1774	298	21	Nueva entrega recibida para revisión: Germinación de semillas de árboles nativos para reforestación.	2023-05-02 16:57:50.800545	2023-05-03 16:57:50.800545
1762	296	21	Nueva entrega recibida para revisión: Medición de la velocidad del sonido con un tubo de resonancia.	2022-06-30 14:05:34.470767	2022-07-01 14:05:34.470767
1763	296	3	Nueva entrega recibida para revisión: Medición de la velocidad del sonido con un tubo de resonancia.	2022-06-30 14:05:34.470767	2022-07-01 14:05:34.470767
1764	296	23	Nueva entrega recibida para revisión: Medición de la velocidad del sonido con un tubo de resonancia.	2022-06-30 14:05:34.470767	2022-07-01 14:05:34.470767
1765	296	22	Nueva entrega recibida para revisión: Medición de la velocidad del sonido con un tubo de resonancia.	2022-06-30 14:05:34.470767	2022-07-01 14:05:34.470767
1766	296	2	Nueva entrega recibida para revisión: Medición de la velocidad del sonido con un tubo de resonancia.	2022-06-30 14:05:34.470767	2022-07-01 14:05:34.470767
1776	298	23	Nueva entrega recibida para revisión: Germinación de semillas de árboles nativos para reforestación.	2023-05-02 16:57:50.800545	2023-05-03 16:57:50.800545
1777	298	22	Nueva entrega recibida para revisión: Germinación de semillas de árboles nativos para reforestación.	2023-05-02 16:57:50.800545	2023-05-03 16:57:50.800545
802	136	21	Nueva entrega recibida para revisión: Frecuencia de grupos sanguíneos en donantes del banco de sangre regional.	2024-09-04 15:18:58.946538	2024-09-05 15:18:58.946538
1778	298	2	Nueva entrega recibida para revisión: Germinación de semillas de árboles nativos para reforestación.	2023-05-02 16:57:50.800545	2023-05-03 16:57:50.800545
1779	298	251	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-05-13 10:32:59.140605	2023-05-14 10:32:59.140605
1780	299	21	Nueva entrega recibida para revisión: Aprendizaje cooperativo en las clases de inglés de bachillerato.	2023-06-23 09:39:53.743487	2023-06-24 09:39:53.743487
803	136	3	Nueva entrega recibida para revisión: Frecuencia de grupos sanguíneos en donantes del banco de sangre regional.	2024-09-04 15:18:58.946538	2024-09-05 15:18:58.946538
804	136	23	Nueva entrega recibida para revisión: Frecuencia de grupos sanguíneos en donantes del banco de sangre regional.	2024-09-04 15:18:58.946538	2024-09-05 15:18:58.946538
805	136	22	Nueva entrega recibida para revisión: Frecuencia de grupos sanguíneos en donantes del banco de sangre regional.	2024-09-04 15:18:58.946538	2024-09-05 15:18:58.946538
806	136	2	Nueva entrega recibida para revisión: Frecuencia de grupos sanguíneos en donantes del banco de sangre regional.	2024-09-04 15:18:58.946538	2024-09-05 15:18:58.946538
786	133	23	Nueva entrega recibida para revisión: Composición de la flora del cerro El Tigre en Morazán.	2024-11-16 04:25:28.736063	2024-11-17 04:25:28.736063
1781	299	3	Nueva entrega recibida para revisión: Aprendizaje cooperativo en las clases de inglés de bachillerato.	2023-06-23 09:39:53.743487	2023-06-24 09:39:53.743487
1782	299	23	Nueva entrega recibida para revisión: Aprendizaje cooperativo en las clases de inglés de bachillerato.	2023-06-23 09:39:53.743487	2023-06-24 09:39:53.743487
787	133	22	Nueva entrega recibida para revisión: Composición de la flora del cerro El Tigre en Morazán.	2024-11-16 04:25:28.736063	2024-11-17 04:25:28.736063
788	133	2	Nueva entrega recibida para revisión: Composición de la flora del cerro El Tigre en Morazán.	2024-11-16 04:25:28.736063	2024-11-17 04:25:28.736063
795	134	142	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-04-04 12:04:56.050339	2024-04-05 12:04:56.050339
796	135	21	Nueva entrega recibida para revisión: Ansiedad al hablar inglés en estudiantes de bachillerato.	2024-06-05 23:11:44.348237	2024-06-06 23:11:44.348237
797	135	3	Nueva entrega recibida para revisión: Ansiedad al hablar inglés en estudiantes de bachillerato.	2024-06-05 23:11:44.348237	2024-06-06 23:11:44.348237
798	135	23	Nueva entrega recibida para revisión: Ansiedad al hablar inglés en estudiantes de bachillerato.	2024-06-05 23:11:44.348237	2024-06-06 23:11:44.348237
799	135	22	Nueva entrega recibida para revisión: Ansiedad al hablar inglés en estudiantes de bachillerato.	2024-06-05 23:11:44.348237	2024-06-06 23:11:44.348237
800	135	2	Nueva entrega recibida para revisión: Ansiedad al hablar inglés en estudiantes de bachillerato.	2024-06-05 23:11:44.348237	2024-06-06 23:11:44.348237
801	135	104	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.	2024-06-19 13:26:44.652742	2024-06-20 13:26:44.652742
1783	299	22	Nueva entrega recibida para revisión: Aprendizaje cooperativo en las clases de inglés de bachillerato.	2023-06-23 09:39:53.743487	2023-06-24 09:39:53.743487
1784	299	2	Nueva entrega recibida para revisión: Aprendizaje cooperativo en las clases de inglés de bachillerato.	2023-06-23 09:39:53.743487	2023-06-24 09:39:53.743487
1785	299	252	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-06-27 17:40:00.080829	2023-06-28 17:40:00.080829
1386	232	2	Nueva entrega recibida para revisión: Prevalencia de hipertensión arterial en trabajadores de la facultad.	2026-11-17 02:31:20.615673	2026-11-22 19:17:40.075087
1786	300	21	Nueva entrega recibida para revisión: Anemia ferropénica en mujeres en edad fértil de comunidades rurales.	2023-11-03 17:27:34.752845	2023-11-04 17:27:34.752845
1787	300	3	Nueva entrega recibida para revisión: Anemia ferropénica en mujeres en edad fértil de comunidades rurales.	2023-11-03 17:27:34.752845	2023-11-04 17:27:34.752845
1788	300	23	Nueva entrega recibida para revisión: Anemia ferropénica en mujeres en edad fértil de comunidades rurales.	2023-11-03 17:27:34.752845	2023-11-04 17:27:34.752845
1789	300	22	Nueva entrega recibida para revisión: Anemia ferropénica en mujeres en edad fértil de comunidades rurales.	2023-11-03 17:27:34.752845	2023-11-04 17:27:34.752845
1790	300	2	Nueva entrega recibida para revisión: Anemia ferropénica en mujeres en edad fértil de comunidades rurales.	2023-11-03 17:27:34.752845	2023-11-04 17:27:34.752845
1791	300	226	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-11-09 15:13:09.140005	2023-11-10 15:13:09.140005
1792	301	21	Nueva entrega recibida para revisión: Hidroterapia en niños con parálisis cerebral.	2023-05-18 00:46:48.817903	2023-05-19 00:46:48.817903
1793	301	3	Nueva entrega recibida para revisión: Hidroterapia en niños con parálisis cerebral.	2023-05-18 00:46:48.817903	2023-05-19 00:46:48.817903
1794	301	23	Nueva entrega recibida para revisión: Hidroterapia en niños con parálisis cerebral.	2023-05-18 00:46:48.817903	2023-05-19 00:46:48.817903
1382	232	21	Nueva entrega recibida para revisión: Prevalencia de hipertensión arterial en trabajadores de la facultad.	2026-11-17 02:31:20.615673	\N
1383	232	3	Nueva entrega recibida para revisión: Prevalencia de hipertensión arterial en trabajadores de la facultad.	2026-11-17 02:31:20.615673	\N
1384	232	23	Nueva entrega recibida para revisión: Prevalencia de hipertensión arterial en trabajadores de la facultad.	2026-11-17 02:31:20.615673	\N
1385	232	22	Nueva entrega recibida para revisión: Prevalencia de hipertensión arterial en trabajadores de la facultad.	2026-11-17 02:31:20.615673	\N
1795	301	22	Nueva entrega recibida para revisión: Hidroterapia en niños con parálisis cerebral.	2023-05-18 00:46:48.817903	2023-05-19 00:46:48.817903
1796	301	2	Nueva entrega recibida para revisión: Hidroterapia en niños con parálisis cerebral.	2023-05-18 00:46:48.817903	2023-05-19 00:46:48.817903
1797	301	253	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2023-05-25 15:45:20.150484	2023-05-26 15:45:20.150484
1798	302	21	Nueva entrega recibida (versión corregida) para revisión: Hidroterapia en niños con parálisis cerebral.	2023-06-01 06:29:55.508294	2023-06-02 06:29:55.508294
1803	302	253	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-06-09 05:23:15.86428	2023-06-10 05:23:15.86428
1393	234	21	Nueva entrega recibida para revisión: Simuladores PhET en la enseñanza de la electricidad.	2026-11-20 17:22:30.673394	\N
1394	234	3	Nueva entrega recibida para revisión: Simuladores PhET en la enseñanza de la electricidad.	2026-11-20 17:22:30.673394	\N
826	140	21	Nueva entrega recibida (versión corregida) para revisión: Determinación de metales pesados en agua del río Lempa.	2024-10-13 00:30:46.024339	2024-10-14 00:30:46.024339
827	140	3	Nueva entrega recibida (versión corregida) para revisión: Determinación de metales pesados en agua del río Lempa.	2024-10-13 00:30:46.024339	2024-10-14 00:30:46.024339
828	140	23	Nueva entrega recibida (versión corregida) para revisión: Determinación de metales pesados en agua del río Lempa.	2024-10-13 00:30:46.024339	2024-10-14 00:30:46.024339
791	134	3	Nueva entrega recibida para revisión: Protocolo de monitoreo en anestesia pediátrica.	2024-03-29 01:01:34.71129	2024-03-30 01:01:34.71129
1387	232	129	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.	2026-11-18 07:23:48.941216	\N
792	134	23	Nueva entrega recibida para revisión: Protocolo de monitoreo en anestesia pediátrica.	2024-03-29 01:01:34.71129	2024-03-30 01:01:34.71129
793	134	22	Nueva entrega recibida para revisión: Protocolo de monitoreo en anestesia pediátrica.	2024-03-29 01:01:34.71129	2024-03-30 01:01:34.71129
2197	368	21	Nueva entrega recibida para revisión: Adsorción de colorantes con carbón activado de cáscara de coco.	2026-11-20 15:59:09.600281	\N
2198	368	3	Nueva entrega recibida para revisión: Adsorción de colorantes con carbón activado de cáscara de coco.	2026-11-20 15:59:09.600281	\N
2199	368	23	Nueva entrega recibida para revisión: Adsorción de colorantes con carbón activado de cáscara de coco.	2026-11-20 15:59:09.600281	\N
2200	368	22	Nueva entrega recibida para revisión: Adsorción de colorantes con carbón activado de cáscara de coco.	2026-11-20 15:59:09.600281	\N
2201	368	2	Nueva entrega recibida para revisión: Adsorción de colorantes con carbón activado de cáscara de coco.	2026-11-20 15:59:09.600281	\N
2202	368	297	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2026-11-21 09:32:54.923995	\N
2188	366	23	Nueva entrega recibida para revisión: Pérdidas técnicas en la red de distribución de un municipio.	2026-11-17 05:57:24.651361	\N
2189	366	22	Nueva entrega recibida para revisión: Pérdidas técnicas en la red de distribución de un municipio.	2026-11-17 05:57:24.651361	\N
2190	366	2	Nueva entrega recibida para revisión: Pérdidas técnicas en la red de distribución de un municipio.	2026-11-17 05:57:24.651361	\N
2191	366	296	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2026-11-20 01:54:49.956702	\N
2192	367	21	Nueva entrega recibida (versión corregida) para revisión: Pérdidas técnicas en la red de distribución de un municipio.	2026-11-22 15:03:08.290534	\N
2193	367	3	Nueva entrega recibida (versión corregida) para revisión: Pérdidas técnicas en la red de distribución de un municipio.	2026-11-22 15:03:08.290534	\N
2194	367	23	Nueva entrega recibida (versión corregida) para revisión: Pérdidas técnicas en la red de distribución de un municipio.	2026-11-22 15:03:08.290534	\N
2195	367	22	Nueva entrega recibida (versión corregida) para revisión: Pérdidas técnicas en la red de distribución de un municipio.	2026-11-22 15:03:08.290534	\N
2196	367	2	Nueva entrega recibida (versión corregida) para revisión: Pérdidas técnicas en la red de distribución de un municipio.	2026-11-22 15:03:08.290534	\N
1799	302	3	Nueva entrega recibida (versión corregida) para revisión: Hidroterapia en niños con parálisis cerebral.	2023-06-01 06:29:55.508294	2023-06-02 06:29:55.508294
1800	302	23	Nueva entrega recibida (versión corregida) para revisión: Hidroterapia en niños con parálisis cerebral.	2023-06-01 06:29:55.508294	2023-06-02 06:29:55.508294
1801	302	22	Nueva entrega recibida (versión corregida) para revisión: Hidroterapia en niños con parálisis cerebral.	2023-06-01 06:29:55.508294	2023-06-02 06:29:55.508294
2214	371	21	Nueva entrega recibida para revisión: Síndrome de desgaste profesional en el personal de enfermería.	2026-11-20 08:28:22.495697	\N
2215	371	3	Nueva entrega recibida para revisión: Síndrome de desgaste profesional en el personal de enfermería.	2026-11-20 08:28:22.495697	\N
2216	371	23	Nueva entrega recibida para revisión: Síndrome de desgaste profesional en el personal de enfermería.	2026-11-20 08:28:22.495697	\N
2209	370	21	Nueva entrega recibida para revisión: El patrimonio cultural de San Miguel en la enseñanza de la historia.	2026-11-22 08:08:45.180104	\N
2210	370	3	Nueva entrega recibida para revisión: El patrimonio cultural de San Miguel en la enseñanza de la historia.	2026-11-22 08:08:45.180104	\N
2211	370	23	Nueva entrega recibida para revisión: El patrimonio cultural de San Miguel en la enseñanza de la historia.	2026-11-22 08:08:45.180104	\N
2212	370	22	Nueva entrega recibida para revisión: El patrimonio cultural de San Miguel en la enseñanza de la historia.	2026-11-22 08:08:45.180104	\N
2213	370	2	Nueva entrega recibida para revisión: El patrimonio cultural de San Miguel en la enseñanza de la historia.	2026-11-22 08:08:45.180104	\N
1802	302	2	Nueva entrega recibida (versión corregida) para revisión: Hidroterapia en niños con parálisis cerebral.	2023-06-01 06:29:55.508294	2023-06-02 06:29:55.508294
1804	302	253	Tu publicación fue retirada del catálogo. Motivo: La institución colaboradora solicitó no divulgar los resultados.	2023-09-19 12:03:51.175902	2023-09-20 12:03:51.175902
2203	369	21	Nueva entrega recibida para revisión: Taller de escritura creativa para estudiantes de bachillerato.	2026-09-01 04:16:30.221532	2026-09-02 04:16:30.221532
2204	369	3	Nueva entrega recibida para revisión: Taller de escritura creativa para estudiantes de bachillerato.	2026-09-01 04:16:30.221532	2026-09-02 04:16:30.221532
2205	369	23	Nueva entrega recibida para revisión: Taller de escritura creativa para estudiantes de bachillerato.	2026-09-01 04:16:30.221532	2026-09-02 04:16:30.221532
2206	369	22	Nueva entrega recibida para revisión: Taller de escritura creativa para estudiantes de bachillerato.	2026-09-01 04:16:30.221532	2026-09-02 04:16:30.221532
2207	369	2	Nueva entrega recibida para revisión: Taller de escritura creativa para estudiantes de bachillerato.	2026-09-01 04:16:30.221532	2026-09-02 04:16:30.221532
845	143	21	Nueva entrega recibida para revisión: Control de calidad de tabletas de paracetamol de distintos fabricantes.	2024-07-30 03:01:58.7298	2024-07-31 03:01:58.7298
846	143	3	Nueva entrega recibida para revisión: Control de calidad de tabletas de paracetamol de distintos fabricantes.	2024-07-30 03:01:58.7298	2024-07-31 03:01:58.7298
815	138	3	Nueva entrega recibida para revisión: Programa de ejercicios para la lumbalgia en trabajadores de oficina.	2024-03-07 04:40:23.261771	2024-03-08 04:40:23.261771
816	138	23	Nueva entrega recibida para revisión: Programa de ejercicios para la lumbalgia en trabajadores de oficina.	2024-03-07 04:40:23.261771	2024-03-08 04:40:23.261771
868	146	124	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-05-21 22:12:05.104723	2024-05-22 22:12:05.104723
1817	305	21	Nueva entrega recibida para revisión: Percepción de los jóvenes sobre la democracia.	2023-03-23 08:07:54.28206	2023-03-24 08:07:54.28206
1818	305	3	Nueva entrega recibida para revisión: Percepción de los jóvenes sobre la democracia.	2023-03-23 08:07:54.28206	2023-03-24 08:07:54.28206
899	151	152	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-05-25 09:59:24.141896	2024-05-26 09:59:24.141896
872	147	23	Nueva entrega recibida para revisión: Rasgos del habla popular en el oriente de El Salvador.	2024-03-25 14:36:26.754713	2024-03-26 14:36:26.754713
873	147	22	Nueva entrega recibida para revisión: Rasgos del habla popular en el oriente de El Salvador.	2024-03-25 14:36:26.754713	2024-03-26 14:36:26.754713
874	147	2	Nueva entrega recibida para revisión: Rasgos del habla popular en el oriente de El Salvador.	2024-03-25 14:36:26.754713	2024-03-26 14:36:26.754713
1819	305	23	Nueva entrega recibida para revisión: Percepción de los jóvenes sobre la democracia.	2023-03-23 08:07:54.28206	2023-03-24 08:07:54.28206
1820	305	22	Nueva entrega recibida para revisión: Percepción de los jóvenes sobre la democracia.	2023-03-23 08:07:54.28206	2023-03-24 08:07:54.28206
1821	305	2	Nueva entrega recibida para revisión: Percepción de los jóvenes sobre la democracia.	2023-03-23 08:07:54.28206	2023-03-24 08:07:54.28206
906	153	21	Nueva entrega recibida para revisión: Secuencia de clases sobre la energía y sus transformaciones.	2024-04-19 18:47:49.640075	2024-04-20 18:47:49.640075
907	153	3	Nueva entrega recibida para revisión: Secuencia de clases sobre la energía y sus transformaciones.	2024-04-19 18:47:49.640075	2024-04-20 18:47:49.640075
908	153	23	Nueva entrega recibida para revisión: Secuencia de clases sobre la energía y sus transformaciones.	2024-04-19 18:47:49.640075	2024-04-20 18:47:49.640075
1822	305	255	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2023-03-25 14:52:18.636948	2023-03-26 14:52:18.636948
1845	309	2	Nueva entrega recibida para revisión: Juventud rural y oportunidades de empleo en el oriente.	2023-06-05 13:07:19.725842	2023-06-06 13:07:19.725842
1846	309	257	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-06-17 13:38:05.081198	2023-06-18 13:38:05.081198
1865	313	21	Nueva entrega recibida para revisión: Salidas de campo como estrategia para enseñar ecosistemas.	2024-03-08 06:50:39.151392	2024-03-09 06:50:39.151392
1847	310	21	Nueva entrega recibida para revisión: Estadística con datos reales en el aula de bachillerato.	2023-04-30 06:53:42.736278	2023-05-01 06:53:42.736278
930	157	21	Nueva entrega recibida (versión corregida) para revisión: Plan estratégico para una cooperativa de ahorro y crédito.	2024-08-19 09:16:46.11849	2024-08-20 09:16:46.11849
931	157	3	Nueva entrega recibida (versión corregida) para revisión: Plan estratégico para una cooperativa de ahorro y crédito.	2024-08-19 09:16:46.11849	2024-08-20 09:16:46.11849
932	157	23	Nueva entrega recibida (versión corregida) para revisión: Plan estratégico para una cooperativa de ahorro y crédito.	2024-08-19 09:16:46.11849	2024-08-20 09:16:46.11849
933	157	22	Nueva entrega recibida (versión corregida) para revisión: Plan estratégico para una cooperativa de ahorro y crédito.	2024-08-19 09:16:46.11849	2024-08-20 09:16:46.11849
934	157	2	Nueva entrega recibida (versión corregida) para revisión: Plan estratégico para una cooperativa de ahorro y crédito.	2024-08-19 09:16:46.11849	2024-08-20 09:16:46.11849
941	158	157	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-04-28 01:11:22.522284	2024-04-29 01:11:22.522284
1848	310	3	Nueva entrega recibida para revisión: Estadística con datos reales en el aula de bachillerato.	2023-04-30 06:53:42.736278	2023-05-01 06:53:42.736278
1849	310	23	Nueva entrega recibida para revisión: Estadística con datos reales en el aula de bachillerato.	2023-04-30 06:53:42.736278	2023-05-01 06:53:42.736278
1850	310	22	Nueva entrega recibida para revisión: Estadística con datos reales en el aula de bachillerato.	2023-04-30 06:53:42.736278	2023-05-01 06:53:42.736278
1851	310	2	Nueva entrega recibida para revisión: Estadística con datos reales en el aula de bachillerato.	2023-04-30 06:53:42.736278	2023-05-01 06:53:42.736278
1852	310	258	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.	2023-05-05 21:05:52.090033	2023-05-06 21:05:52.090033
1866	313	3	Nueva entrega recibida para revisión: Salidas de campo como estrategia para enseñar ecosistemas.	2024-03-08 06:50:39.151392	2024-03-09 06:50:39.151392
1867	313	23	Nueva entrega recibida para revisión: Salidas de campo como estrategia para enseñar ecosistemas.	2024-03-08 06:50:39.151392	2024-03-09 06:50:39.151392
1868	313	22	Nueva entrega recibida para revisión: Salidas de campo como estrategia para enseñar ecosistemas.	2024-03-08 06:50:39.151392	2024-03-09 06:50:39.151392
1869	313	2	Nueva entrega recibida para revisión: Salidas de campo como estrategia para enseñar ecosistemas.	2024-03-08 06:50:39.151392	2024-03-09 06:50:39.151392
1859	312	21	Nueva entrega recibida para revisión: Huerto escolar para niños de cinco años.	2023-10-25 10:56:51.136828	2023-10-26 10:56:51.136828
1853	311	21	Nueva entrega recibida para revisión: Plan de transporte para una empresa exportadora de frutas.	2023-11-28 15:38:39.416847	2023-11-29 15:38:39.416847
1854	311	3	Nueva entrega recibida para revisión: Plan de transporte para una empresa exportadora de frutas.	2023-11-28 15:38:39.416847	2023-11-29 15:38:39.416847
1895	318	21	Nueva entrega recibida para revisión: El debido proceso en el procedimiento administrativo sancionador.	2024-03-11 09:19:47.019601	2024-03-12 09:19:47.019601
1896	318	3	Nueva entrega recibida para revisión: El debido proceso en el procedimiento administrativo sancionador.	2024-03-11 09:19:47.019601	2024-03-12 09:19:47.019601
1897	318	23	Nueva entrega recibida para revisión: El debido proceso en el procedimiento administrativo sancionador.	2024-03-11 09:19:47.019601	2024-03-12 09:19:47.019601
1898	318	22	Nueva entrega recibida para revisión: El debido proceso en el procedimiento administrativo sancionador.	2024-03-11 09:19:47.019601	2024-03-12 09:19:47.019601
1899	318	2	Nueva entrega recibida para revisión: El debido proceso en el procedimiento administrativo sancionador.	2024-03-11 09:19:47.019601	2024-03-12 09:19:47.019601
1900	318	264	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-03-23 15:24:17.436979	2024-03-24 15:24:17.436979
1889	317	21	Nueva entrega recibida para revisión: El teletrabajo en la legislación laboral salvadoreña.	2024-05-04 18:50:33.840772	2024-05-05 18:50:33.840772
1890	317	3	Nueva entrega recibida para revisión: El teletrabajo en la legislación laboral salvadoreña.	2024-05-04 18:50:33.840772	2024-05-05 18:50:33.840772
1891	317	23	Nueva entrega recibida para revisión: El teletrabajo en la legislación laboral salvadoreña.	2024-05-04 18:50:33.840772	2024-05-05 18:50:33.840772
1892	317	22	Nueva entrega recibida para revisión: El teletrabajo en la legislación laboral salvadoreña.	2024-05-04 18:50:33.840772	2024-05-05 18:50:33.840772
1893	317	2	Nueva entrega recibida para revisión: El teletrabajo en la legislación laboral salvadoreña.	2024-05-04 18:50:33.840772	2024-05-05 18:50:33.840772
1894	317	225	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-05-06 22:36:53.256238	2024-05-07 22:36:53.256238
1877	315	21	Nueva entrega recibida para revisión: Polinizadores en cultivos de café de la zona oriental.	2024-03-12 13:16:23.610962	2024-03-13 13:16:23.610962
1878	315	3	Nueva entrega recibida para revisión: Polinizadores en cultivos de café de la zona oriental.	2024-03-12 13:16:23.610962	2024-03-13 13:16:23.610962
942	159	21	Nueva entrega recibida para revisión: Demostraciones visuales de identidades algebraicas.	2024-03-20 11:51:24.20424	2024-03-21 11:51:24.20424
943	159	3	Nueva entrega recibida para revisión: Demostraciones visuales de identidades algebraicas.	2024-03-20 11:51:24.20424	2024-03-21 11:51:24.20424
944	159	23	Nueva entrega recibida para revisión: Demostraciones visuales de identidades algebraicas.	2024-03-20 11:51:24.20424	2024-03-21 11:51:24.20424
1914	321	21	Nueva entrega recibida para revisión: Comprensión auditiva del inglés con pódcast en noveno grado.	2024-06-24 07:41:17.293843	2024-06-25 07:41:17.293843
1915	321	3	Nueva entrega recibida para revisión: Comprensión auditiva del inglés con pódcast en noveno grado.	2024-06-24 07:41:17.293843	2024-06-25 07:41:17.293843
1908	320	21	Nueva entrega recibida (versión corregida) para revisión: Dolor postoperatorio en pacientes con bloqueo de plexo braquial.	2024-05-05 14:37:41.909715	2024-05-06 14:37:41.909715
1909	320	3	Nueva entrega recibida (versión corregida) para revisión: Dolor postoperatorio en pacientes con bloqueo de plexo braquial.	2024-05-05 14:37:41.909715	2024-05-06 14:37:41.909715
1910	320	23	Nueva entrega recibida (versión corregida) para revisión: Dolor postoperatorio en pacientes con bloqueo de plexo braquial.	2024-05-05 14:37:41.909715	2024-05-06 14:37:41.909715
1911	320	22	Nueva entrega recibida (versión corregida) para revisión: Dolor postoperatorio en pacientes con bloqueo de plexo braquial.	2024-05-05 14:37:41.909715	2024-05-06 14:37:41.909715
1912	320	2	Nueva entrega recibida (versión corregida) para revisión: Dolor postoperatorio en pacientes con bloqueo de plexo braquial.	2024-05-05 14:37:41.909715	2024-05-06 14:37:41.909715
1913	320	265	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-05-14 01:33:35.279881	2024-05-15 01:33:35.279881
996	168	21	Nueva entrega recibida para revisión: El juego libre en el desarrollo social de niños de cuatro años.	2024-05-07 20:19:08.182154	2024-05-08 20:19:08.182154
997	168	3	Nueva entrega recibida para revisión: El juego libre en el desarrollo social de niños de cuatro años.	2024-05-07 20:19:08.182154	2024-05-08 20:19:08.182154
998	168	23	Nueva entrega recibida para revisión: El juego libre en el desarrollo social de niños de cuatro años.	2024-05-07 20:19:08.182154	2024-05-08 20:19:08.182154
999	168	22	Nueva entrega recibida para revisión: El juego libre en el desarrollo social de niños de cuatro años.	2024-05-07 20:19:08.182154	2024-05-08 20:19:08.182154
1000	168	2	Nueva entrega recibida para revisión: El juego libre en el desarrollo social de niños de cuatro años.	2024-05-07 20:19:08.182154	2024-05-08 20:19:08.182154
976	164	2	Nueva entrega recibida para revisión: GeoGebra en la enseñanza de funciones en bachillerato.	2024-04-11 05:00:49.209083	2024-04-12 05:00:49.209083
977	164	161	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2024-04-21 05:31:40.554699	2024-04-22 05:31:40.554699
983	165	161	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-04-27 19:45:29.319763	2024-04-28 19:45:29.319763
1008	170	21	Nueva entrega recibida para revisión: Actividades de psicomotricidad fina para la primera infancia.	2024-06-04 09:09:41.596409	2024-06-05 09:09:41.596409
1009	170	3	Nueva entrega recibida para revisión: Actividades de psicomotricidad fina para la primera infancia.	2024-06-04 09:09:41.596409	2024-06-05 09:09:41.596409
1010	170	23	Nueva entrega recibida para revisión: Actividades de psicomotricidad fina para la primera infancia.	2024-06-04 09:09:41.596409	2024-06-05 09:09:41.596409
1011	170	22	Nueva entrega recibida para revisión: Actividades de psicomotricidad fina para la primera infancia.	2024-06-04 09:09:41.596409	2024-06-05 09:09:41.596409
1012	170	2	Nueva entrega recibida para revisión: Actividades de psicomotricidad fina para la primera infancia.	2024-06-04 09:09:41.596409	2024-06-05 09:09:41.596409
984	166	21	Nueva entrega recibida para revisión: Secuencia didáctica de ecuaciones de primer grado.	2024-09-24 14:04:37.982672	2024-09-25 14:04:37.982672
985	166	3	Nueva entrega recibida para revisión: Secuencia didáctica de ecuaciones de primer grado.	2024-09-24 14:04:37.982672	2024-09-25 14:04:37.982672
986	166	23	Nueva entrega recibida para revisión: Secuencia didáctica de ecuaciones de primer grado.	2024-09-24 14:04:37.982672	2024-09-25 14:04:37.982672
987	166	22	Nueva entrega recibida para revisión: Secuencia didáctica de ecuaciones de primer grado.	2024-09-24 14:04:37.982672	2024-09-25 14:04:37.982672
2226	373	21	Nueva entrega recibida para revisión: Feria científica escolar sobre reacciones químicas.	2026-11-18 07:58:49.69521	\N
2227	373	3	Nueva entrega recibida para revisión: Feria científica escolar sobre reacciones químicas.	2026-11-18 07:58:49.69521	\N
2217	371	22	Nueva entrega recibida para revisión: Síndrome de desgaste profesional en el personal de enfermería.	2026-11-20 08:28:22.495697	\N
2218	371	2	Nueva entrega recibida para revisión: Síndrome de desgaste profesional en el personal de enfermería.	2026-11-20 08:28:22.495697	\N
2219	371	299	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2026-11-21 20:21:35.801511	\N
2228	373	23	Nueva entrega recibida para revisión: Feria científica escolar sobre reacciones químicas.	2026-11-18 07:58:49.69521	\N
2229	373	22	Nueva entrega recibida para revisión: Feria científica escolar sobre reacciones químicas.	2026-11-18 07:58:49.69521	\N
2230	373	2	Nueva entrega recibida para revisión: Feria científica escolar sobre reacciones químicas.	2026-11-18 07:58:49.69521	\N
2231	373	301	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2026-11-20 20:58:28.014438	\N
2232	374	21	Nueva entrega recibida (versión corregida) para revisión: Feria científica escolar sobre reacciones químicas.	2026-11-21 23:11:39.348305	\N
2220	372	21	Nueva entrega recibida para revisión: Uso de modelos moleculares en la enseñanza de la química orgánica.	2026-11-20 04:23:26.086515	\N
2221	372	3	Nueva entrega recibida para revisión: Uso de modelos moleculares en la enseñanza de la química orgánica.	2026-11-20 04:23:26.086515	\N
2222	372	23	Nueva entrega recibida para revisión: Uso de modelos moleculares en la enseñanza de la química orgánica.	2026-11-20 04:23:26.086515	\N
2223	372	22	Nueva entrega recibida para revisión: Uso de modelos moleculares en la enseñanza de la química orgánica.	2026-11-20 04:23:26.086515	\N
2224	372	2	Nueva entrega recibida para revisión: Uso de modelos moleculares en la enseñanza de la química orgánica.	2026-11-20 04:23:26.086515	\N
2225	372	300	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2026-11-21 09:07:41.407993	\N
2233	374	3	Nueva entrega recibida (versión corregida) para revisión: Feria científica escolar sobre reacciones químicas.	2026-11-21 23:11:39.348305	\N
1907	319	265	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2024-05-01 14:48:46.512571	2024-05-02 14:48:46.512571
1050	176	169	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-09-22 07:14:17.641072	2025-09-23 07:14:17.641072
1081	181	172	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-10-30 21:23:33.58109	2025-10-31 21:23:33.58109
1056	177	143	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-03-13 10:38:45.664276	2025-03-14 10:38:45.664276
1063	178	170	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-11-05 02:05:56.633442	2025-11-06 02:05:56.633442
1022	172	3	Nueva entrega recibida para revisión: Plan de mantenimiento preventivo para el parque vehicular de una alcaldía.	2025-05-06 18:43:27.250555	2025-05-07 18:43:27.250555
1926	323	21	Nueva entrega recibida para revisión: Perfil lipídico en estudiantes universitarios de la facultad.	2024-09-09 01:43:00.300296	2024-09-10 01:43:00.300296
1927	323	3	Nueva entrega recibida para revisión: Perfil lipídico en estudiantes universitarios de la facultad.	2024-09-09 01:43:00.300296	2024-09-10 01:43:00.300296
1916	321	23	Nueva entrega recibida para revisión: Comprensión auditiva del inglés con pódcast en noveno grado.	2024-06-24 07:41:17.293843	2024-06-25 07:41:17.293843
1917	321	22	Nueva entrega recibida para revisión: Comprensión auditiva del inglés con pódcast en noveno grado.	2024-06-24 07:41:17.293843	2024-06-25 07:41:17.293843
1918	321	2	Nueva entrega recibida para revisión: Comprensión auditiva del inglés con pódcast en noveno grado.	2024-06-24 07:41:17.293843	2024-06-25 07:41:17.293843
1033	174	21	Nueva entrega recibida para revisión: Monitoreo del consumo eléctrico con sensores de corriente y plataforma web.	2025-07-18 21:48:10.593485	2025-07-19 21:48:10.593485
1034	174	3	Nueva entrega recibida para revisión: Monitoreo del consumo eléctrico con sensores de corriente y plataforma web.	2025-07-18 21:48:10.593485	2025-07-19 21:48:10.593485
1035	174	23	Nueva entrega recibida para revisión: Monitoreo del consumo eléctrico con sensores de corriente y plataforma web.	2025-07-18 21:48:10.593485	2025-07-19 21:48:10.593485
1027	173	21	Nueva entrega recibida (versión corregida) para revisión: Plan de mantenimiento preventivo para el parque vehicular de una alcaldía.	2025-05-24 20:26:53.934263	2025-05-25 20:26:53.934263
1028	173	3	Nueva entrega recibida (versión corregida) para revisión: Plan de mantenimiento preventivo para el parque vehicular de una alcaldía.	2025-05-24 20:26:53.934263	2025-05-25 20:26:53.934263
1029	173	23	Nueva entrega recibida (versión corregida) para revisión: Plan de mantenimiento preventivo para el parque vehicular de una alcaldía.	2025-05-24 20:26:53.934263	2025-05-25 20:26:53.934263
1030	173	22	Nueva entrega recibida (versión corregida) para revisión: Plan de mantenimiento preventivo para el parque vehicular de una alcaldía.	2025-05-24 20:26:53.934263	2025-05-25 20:26:53.934263
1919	321	266	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-07-04 06:10:40.656372	2024-07-05 06:10:40.656372
1920	322	21	Nueva entrega recibida para revisión: Guía de actividades de lectura en inglés para tercer ciclo.	2024-07-23 16:49:43.631526	2024-07-24 16:49:43.631526
1921	322	3	Nueva entrega recibida para revisión: Guía de actividades de lectura en inglés para tercer ciclo.	2024-07-23 16:49:43.631526	2024-07-24 16:49:43.631526
1922	322	23	Nueva entrega recibida para revisión: Guía de actividades de lectura en inglés para tercer ciclo.	2024-07-23 16:49:43.631526	2024-07-24 16:49:43.631526
1923	322	22	Nueva entrega recibida para revisión: Guía de actividades de lectura en inglés para tercer ciclo.	2024-07-23 16:49:43.631526	2024-07-24 16:49:43.631526
1924	322	2	Nueva entrega recibida para revisión: Guía de actividades de lectura en inglés para tercer ciclo.	2024-07-23 16:49:43.631526	2024-07-24 16:49:43.631526
1925	322	267	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.	2024-08-04 16:58:31.972066	2024-08-05 16:58:31.972066
1031	173	2	Nueva entrega recibida (versión corregida) para revisión: Plan de mantenimiento preventivo para el parque vehicular de una alcaldía.	2025-05-24 20:26:53.934263	2025-05-25 20:26:53.934263
1032	173	168	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2025-06-01 04:26:11.266673	2025-06-02 04:26:11.266673
1036	174	22	Nueva entrega recibida para revisión: Monitoreo del consumo eléctrico con sensores de corriente y plataforma web.	2025-07-18 21:48:10.593485	2025-07-19 21:48:10.593485
1037	174	2	Nueva entrega recibida para revisión: Monitoreo del consumo eléctrico con sensores de corriente y plataforma web.	2025-07-18 21:48:10.593485	2025-07-19 21:48:10.593485
1038	174	139	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2025-07-25 20:22:51.937078	2025-07-26 20:22:51.937078
1928	323	23	Nueva entrega recibida para revisión: Perfil lipídico en estudiantes universitarios de la facultad.	2024-09-09 01:43:00.300296	2024-09-10 01:43:00.300296
1929	323	22	Nueva entrega recibida para revisión: Perfil lipídico en estudiantes universitarios de la facultad.	2024-09-09 01:43:00.300296	2024-09-10 01:43:00.300296
1930	323	2	Nueva entrega recibida para revisión: Perfil lipídico en estudiantes universitarios de la facultad.	2024-09-09 01:43:00.300296	2024-09-10 01:43:00.300296
1931	323	268	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-09-13 17:46:42.676254	2024-09-14 17:46:42.676254
1932	324	21	Nueva entrega recibida para revisión: Pausas activas para el personal administrativo de la facultad.	2024-08-26 11:56:40.332388	2024-08-27 11:56:40.332388
1933	324	3	Nueva entrega recibida para revisión: Pausas activas para el personal administrativo de la facultad.	2024-08-26 11:56:40.332388	2024-08-27 11:56:40.332388
1934	324	23	Nueva entrega recibida para revisión: Pausas activas para el personal administrativo de la facultad.	2024-08-26 11:56:40.332388	2024-08-27 11:56:40.332388
1935	324	22	Nueva entrega recibida para revisión: Pausas activas para el personal administrativo de la facultad.	2024-08-26 11:56:40.332388	2024-08-27 11:56:40.332388
1936	324	2	Nueva entrega recibida para revisión: Pausas activas para el personal administrativo de la facultad.	2024-08-26 11:56:40.332388	2024-08-27 11:56:40.332388
1938	325	21	Nueva entrega recibida (versión corregida) para revisión: Pausas activas para el personal administrativo de la facultad.	2024-09-16 16:29:21.047655	2024-09-17 16:29:21.047655
1101	185	21	Nueva entrega recibida para revisión: Antología comentada de cuentos de Salarrué.	2025-11-04 06:05:56.803444	2025-11-05 06:05:56.803444
1102	185	3	Nueva entrega recibida para revisión: Antología comentada de cuentos de Salarrué.	2025-11-04 06:05:56.803444	2025-11-05 06:05:56.803444
1943	325	253	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-09-21 14:13:10.413601	2024-09-22 14:13:10.413601
1944	326	21	Nueva entrega recibida para revisión: Automedicación en estudiantes universitarios de San Miguel.	2024-11-12 05:42:12.04642	2024-11-13 05:42:12.04642
1945	326	3	Nueva entrega recibida para revisión: Automedicación en estudiantes universitarios de San Miguel.	2024-11-12 05:42:12.04642	2024-11-13 05:42:12.04642
1946	326	23	Nueva entrega recibida para revisión: Automedicación en estudiantes universitarios de San Miguel.	2024-11-12 05:42:12.04642	2024-11-13 05:42:12.04642
1947	326	22	Nueva entrega recibida para revisión: Automedicación en estudiantes universitarios de San Miguel.	2024-11-12 05:42:12.04642	2024-11-13 05:42:12.04642
1948	326	2	Nueva entrega recibida para revisión: Automedicación en estudiantes universitarios de San Miguel.	2024-11-12 05:42:12.04642	2024-11-13 05:42:12.04642
1949	326	227	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-11-18 02:04:15.418041	2024-11-19 02:04:15.418041
1956	328	21	Nueva entrega recibida para revisión: Abordaje de la neumonía adquirida en la comunidad en niños.	2024-07-21 20:23:38.770128	2024-07-22 20:23:38.770128
1957	328	3	Nueva entrega recibida para revisión: Abordaje de la neumonía adquirida en la comunidad en niños.	2024-07-21 20:23:38.770128	2024-07-22 20:23:38.770128
1958	328	23	Nueva entrega recibida para revisión: Abordaje de la neumonía adquirida en la comunidad en niños.	2024-07-21 20:23:38.770128	2024-07-22 20:23:38.770128
1959	328	22	Nueva entrega recibida para revisión: Abordaje de la neumonía adquirida en la comunidad en niños.	2024-07-21 20:23:38.770128	2024-07-22 20:23:38.770128
1950	327	21	Nueva entrega recibida para revisión: Sistema de control de asistencia con reconocimiento facial.	2024-06-22 05:26:37.741439	2024-06-23 05:26:37.741439
1191	200	21	Nueva entrega recibida para revisión: Investigación de mercado para una cafetería universitaria.	2025-08-24 14:41:07.731759	2025-08-25 14:41:07.731759
1192	200	3	Nueva entrega recibida para revisión: Investigación de mercado para una cafetería universitaria.	2025-08-24 14:41:07.731759	2025-08-25 14:41:07.731759
1193	200	23	Nueva entrega recibida para revisión: Investigación de mercado para una cafetería universitaria.	2025-08-24 14:41:07.731759	2025-08-25 14:41:07.731759
1194	200	22	Nueva entrega recibida para revisión: Investigación de mercado para una cafetería universitaria.	2025-08-24 14:41:07.731759	2025-08-25 14:41:07.731759
1195	200	2	Nueva entrega recibida para revisión: Investigación de mercado para una cafetería universitaria.	2025-08-24 14:41:07.731759	2025-08-25 14:41:07.731759
1144	192	3	Nueva entrega recibida para revisión: Complicaciones del dengue en niños atendidos en el hospital regional.	2025-04-02 21:30:55.918236	2025-04-03 21:30:55.918236
1145	192	23	Nueva entrega recibida para revisión: Complicaciones del dengue en niños atendidos en el hospital regional.	2025-04-02 21:30:55.918236	2025-04-03 21:30:55.918236
1968	330	21	Nueva entrega recibida para revisión: Posicionamiento de la marca de un café de altura de Morazán.	2024-09-21 08:14:45.154224	2024-09-22 08:14:45.154224
1969	330	3	Nueva entrega recibida para revisión: Posicionamiento de la marca de un café de altura de Morazán.	2024-09-21 08:14:45.154224	2024-09-22 08:14:45.154224
1970	330	23	Nueva entrega recibida para revisión: Posicionamiento de la marca de un café de altura de Morazán.	2024-09-21 08:14:45.154224	2024-09-22 08:14:45.154224
1971	330	22	Nueva entrega recibida para revisión: Posicionamiento de la marca de un café de altura de Morazán.	2024-09-21 08:14:45.154224	2024-09-22 08:14:45.154224
1972	330	2	Nueva entrega recibida para revisión: Posicionamiento de la marca de un café de altura de Morazán.	2024-09-21 08:14:45.154224	2024-09-22 08:14:45.154224
1973	330	271	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-09-23 20:53:04.543495	2024-09-24 20:53:04.543495
1960	328	2	Nueva entrega recibida para revisión: Abordaje de la neumonía adquirida en la comunidad en niños.	2024-07-21 20:23:38.770128	2024-07-22 20:23:38.770128
1961	328	270	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2024-07-28 04:27:23.110716	2024-07-29 04:27:23.110716
1962	329	21	Nueva entrega recibida (versión corregida) para revisión: Abordaje de la neumonía adquirida en la comunidad en niños.	2024-07-31 13:16:11.473158	2024-08-01 13:16:11.473158
789	133	141	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-11-20 11:36:11.073016	2024-11-21 11:36:11.073016
1963	329	3	Nueva entrega recibida (versión corregida) para revisión: Abordaje de la neumonía adquirida en la comunidad en niños.	2024-07-31 13:16:11.473158	2024-08-01 13:16:11.473158
1210	203	21	Nueva entrega recibida para revisión: Análisis estadístico de la lluvia en la zona oriental de 1990 a 2024.	2025-09-10 09:24:52.354145	2025-09-11 09:24:52.354145
1202	201	184	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-09-29 10:11:49.735625	2025-09-30 10:11:49.735625
1196	200	184	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2025-09-06 11:20:52.053295	2025-09-07 11:20:52.053295
1235	207	3	Nueva entrega recibida (versión corregida) para revisión: Mapa de actores sociales de un municipio de Morazán.	2025-04-05 19:15:35.007497	2025-04-06 19:15:35.007497
1236	207	23	Nueva entrega recibida (versión corregida) para revisión: Mapa de actores sociales de un municipio de Morazán.	2025-04-05 19:15:35.007497	2025-04-06 19:15:35.007497
1237	207	22	Nueva entrega recibida (versión corregida) para revisión: Mapa de actores sociales de un municipio de Morazán.	2025-04-05 19:15:35.007497	2025-04-06 19:15:35.007497
1238	207	2	Nueva entrega recibida (versión corregida) para revisión: Mapa de actores sociales de un municipio de Morazán.	2025-04-05 19:15:35.007497	2025-04-06 19:15:35.007497
2017	338	21	Nueva entrega recibida para revisión: Diseño de una mezcla de concreto con ceniza volcánica.	2024-07-04 08:45:17.801208	2024-07-05 08:45:17.801208
2018	338	3	Nueva entrega recibida para revisión: Diseño de una mezcla de concreto con ceniza volcánica.	2024-07-04 08:45:17.801208	2024-07-05 08:45:17.801208
2019	338	23	Nueva entrega recibida para revisión: Diseño de una mezcla de concreto con ceniza volcánica.	2024-07-04 08:45:17.801208	2024-07-05 08:45:17.801208
2020	338	22	Nueva entrega recibida para revisión: Diseño de una mezcla de concreto con ceniza volcánica.	2024-07-04 08:45:17.801208	2024-07-05 08:45:17.801208
2021	338	2	Nueva entrega recibida para revisión: Diseño de una mezcla de concreto con ceniza volcánica.	2024-07-04 08:45:17.801208	2024-07-05 08:45:17.801208
2022	338	277	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-07-18 04:22:54.169562	2024-07-19 04:22:54.169562
1999	335	3	Nueva entrega recibida (versión corregida) para revisión: Las redes de apoyo de las madres solteras en San Miguel.	2024-03-03 22:50:00.683726	2024-03-04 22:50:00.683726
2000	335	23	Nueva entrega recibida (versión corregida) para revisión: Las redes de apoyo de las madres solteras en San Miguel.	2024-03-03 22:50:00.683726	2024-03-04 22:50:00.683726
2001	335	22	Nueva entrega recibida (versión corregida) para revisión: Las redes de apoyo de las madres solteras en San Miguel.	2024-03-03 22:50:00.683726	2024-03-04 22:50:00.683726
2002	335	2	Nueva entrega recibida (versión corregida) para revisión: Las redes de apoyo de las madres solteras en San Miguel.	2024-03-03 22:50:00.683726	2024-03-04 22:50:00.683726
1333	223	2	Nueva entrega recibida (versión corregida) para revisión: Valoración preanestésica en pacientes hipertensos.	2026-11-19 13:11:52.889939	2026-11-22 19:17:40.075087
2035	341	21	Nueva entrega recibida para revisión: Rehabilitación de la rodilla tras lesiones de ligamento cruzado.	2025-09-29 14:47:45.540503	2025-09-30 14:47:45.540503
2036	341	3	Nueva entrega recibida para revisión: Rehabilitación de la rodilla tras lesiones de ligamento cruzado.	2025-09-29 14:47:45.540503	2025-09-30 14:47:45.540503
2037	341	23	Nueva entrega recibida para revisión: Rehabilitación de la rodilla tras lesiones de ligamento cruzado.	2025-09-29 14:47:45.540503	2025-09-30 14:47:45.540503
1341	225	21	Nueva entrega recibida para revisión: Corrección de errores escritos frecuentes en noveno grado.	2026-11-20 23:00:38.235065	\N
1342	225	3	Nueva entrega recibida para revisión: Corrección de errores escritos frecuentes en noveno grado.	2026-11-20 23:00:38.235065	\N
1247	209	3	Nueva entrega recibida para revisión: Participación de las familias en la educación parvularia.	2025-06-18 03:31:49.649231	2025-06-19 03:31:49.649231
2038	341	22	Nueva entrega recibida para revisión: Rehabilitación de la rodilla tras lesiones de ligamento cruzado.	2025-09-29 14:47:45.540503	2025-09-30 14:47:45.540503
2039	341	2	Nueva entrega recibida para revisión: Rehabilitación de la rodilla tras lesiones de ligamento cruzado.	2025-09-29 14:47:45.540503	2025-09-30 14:47:45.540503
2040	341	279	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2025-10-08 13:18:58.873828	2025-10-09 13:18:58.873828
1329	223	21	Nueva entrega recibida (versión corregida) para revisión: Valoración preanestésica en pacientes hipertensos.	2026-11-19 13:11:52.889939	\N
1330	223	3	Nueva entrega recibida (versión corregida) para revisión: Valoración preanestésica en pacientes hipertensos.	2026-11-19 13:11:52.889939	\N
1331	223	23	Nueva entrega recibida (versión corregida) para revisión: Valoración preanestésica en pacientes hipertensos.	2026-11-19 13:11:52.889939	\N
1332	223	22	Nueva entrega recibida (versión corregida) para revisión: Valoración preanestésica en pacientes hipertensos.	2026-11-19 13:11:52.889939	\N
1334	223	83	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2026-11-20 19:54:31.238825	\N
2041	342	21	Nueva entrega recibida (versión corregida) para revisión: Rehabilitación de la rodilla tras lesiones de ligamento cruzado.	2025-10-13 00:06:45.242253	2025-10-14 00:06:45.242253
2031	340	23	Nueva entrega recibida para revisión: Diseño de la instalación eléctrica de un centro de salud rural.	2025-09-08 11:00:24.514811	2025-09-09 11:00:24.514811
2032	340	22	Nueva entrega recibida para revisión: Diseño de la instalación eléctrica de un centro de salud rural.	2025-09-08 11:00:24.514811	2025-09-09 11:00:24.514811
2033	340	2	Nueva entrega recibida para revisión: Diseño de la instalación eléctrica de un centro de salud rural.	2025-09-08 11:00:24.514811	2025-09-09 11:00:24.514811
2034	340	224	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-09-21 02:08:07.899293	2025-09-22 02:08:07.899293
2042	342	3	Nueva entrega recibida (versión corregida) para revisión: Rehabilitación de la rodilla tras lesiones de ligamento cruzado.	2025-10-13 00:06:45.242253	2025-10-14 00:06:45.242253
1248	209	23	Nueva entrega recibida para revisión: Participación de las familias en la educación parvularia.	2025-06-18 03:31:49.649231	2025-06-19 03:31:49.649231
1249	209	22	Nueva entrega recibida para revisión: Participación de las familias en la educación parvularia.	2025-06-18 03:31:49.649231	2025-06-19 03:31:49.649231
1250	209	2	Nueva entrega recibida para revisión: Participación de las familias en la educación parvularia.	2025-06-18 03:31:49.649231	2025-06-19 03:31:49.649231
1251	209	191	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.	2025-06-27 12:07:18.984903	2025-06-28 12:07:18.984903
1252	210	21	Nueva entrega recibida para revisión: Riego por goteo en el cultivo de chile dulce.	2025-04-25 16:03:27.280352	2025-04-26 16:03:27.280352
1253	210	3	Nueva entrega recibida para revisión: Riego por goteo en el cultivo de chile dulce.	2025-04-25 16:03:27.280352	2025-04-26 16:03:27.280352
1293	216	2	Nueva entrega recibida para revisión: Eficiencia energética de calderas en beneficios de café.	2026-11-22 03:43:56.724639	2026-11-22 19:17:40.075087
1298	217	2	Nueva entrega recibida para revisión: Inventario de aves del campus de la Facultad Multidisciplinaria Oriental.	2026-11-20 13:02:08.036359	2026-11-22 19:17:40.075087
2044	342	22	Nueva entrega recibida (versión corregida) para revisión: Rehabilitación de la rodilla tras lesiones de ligamento cruzado.	2025-10-13 00:06:45.242253	2025-10-14 00:06:45.242253
2045	342	2	Nueva entrega recibida (versión corregida) para revisión: Rehabilitación de la rodilla tras lesiones de ligamento cruzado.	2025-10-13 00:06:45.242253	2025-10-14 00:06:45.242253
2046	342	279	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-10-25 13:04:15.626567	2025-10-26 13:04:15.626567
2047	343	21	Nueva entrega recibida para revisión: Obtención de jabón artesanal a partir de aceites vegetales.	2025-04-22 06:07:44.285104	2025-04-23 06:07:44.285104
2048	343	3	Nueva entrega recibida para revisión: Obtención de jabón artesanal a partir de aceites vegetales.	2025-04-22 06:07:44.285104	2025-04-23 06:07:44.285104
2049	343	23	Nueva entrega recibida para revisión: Obtención de jabón artesanal a partir de aceites vegetales.	2025-04-22 06:07:44.285104	2025-04-23 06:07:44.285104
2050	343	22	Nueva entrega recibida para revisión: Obtención de jabón artesanal a partir de aceites vegetales.	2025-04-22 06:07:44.285104	2025-04-23 06:07:44.285104
1289	216	21	Nueva entrega recibida para revisión: Eficiencia energética de calderas en beneficios de café.	2026-11-22 03:43:56.724639	\N
1290	216	3	Nueva entrega recibida para revisión: Eficiencia energética de calderas en beneficios de café.	2026-11-22 03:43:56.724639	\N
1300	218	21	Nueva entrega recibida para revisión: Identificación de hongos comestibles silvestres del oriente del país.	2026-11-19 23:01:37.645657	\N
1301	218	3	Nueva entrega recibida para revisión: Identificación de hongos comestibles silvestres del oriente del país.	2026-11-19 23:01:37.645657	\N
1291	216	23	Nueva entrega recibida para revisión: Eficiencia energética de calderas en beneficios de café.	2026-11-22 03:43:56.724639	\N
1292	216	22	Nueva entrega recibida para revisión: Eficiencia energética de calderas en beneficios de café.	2026-11-22 03:43:56.724639	\N
1294	217	21	Nueva entrega recibida para revisión: Inventario de aves del campus de la Facultad Multidisciplinaria Oriental.	2026-11-20 13:02:08.036359	\N
1295	217	3	Nueva entrega recibida para revisión: Inventario de aves del campus de la Facultad Multidisciplinaria Oriental.	2026-11-20 13:02:08.036359	\N
1296	217	23	Nueva entrega recibida para revisión: Inventario de aves del campus de la Facultad Multidisciplinaria Oriental.	2026-11-20 13:02:08.036359	\N
1297	217	22	Nueva entrega recibida para revisión: Inventario de aves del campus de la Facultad Multidisciplinaria Oriental.	2026-11-20 13:02:08.036359	\N
1299	217	198	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.	2026-11-22 10:36:39.348093	\N
1302	218	23	Nueva entrega recibida para revisión: Identificación de hongos comestibles silvestres del oriente del país.	2026-11-19 23:01:37.645657	\N
1264	212	21	Nueva entrega recibida para revisión: Fertilidad de los suelos de las parcelas de la estación experimental.	2025-03-04 12:02:37.59221	2025-03-05 12:02:37.59221
1265	212	3	Nueva entrega recibida para revisión: Fertilidad de los suelos de las parcelas de la estación experimental.	2025-03-04 12:02:37.59221	2025-03-05 12:02:37.59221
1258	211	21	Nueva entrega recibida para revisión: Abono orgánico elaborado con residuos de la cosecha de café.	2025-08-03 05:05:21.942469	2025-08-04 05:05:21.942469
1259	211	3	Nueva entrega recibida para revisión: Abono orgánico elaborado con residuos de la cosecha de café.	2025-08-03 05:05:21.942469	2025-08-04 05:05:21.942469
1288	215	196	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-10-28 18:29:17.130203	2025-10-29 18:29:17.130203
1304	218	2	Nueva entrega recibida para revisión: Identificación de hongos comestibles silvestres del oriente del país.	2026-11-19 23:01:37.645657	2026-11-22 19:17:40.075087
1303	218	22	Nueva entrega recibida para revisión: Identificación de hongos comestibles silvestres del oriente del país.	2026-11-19 23:01:37.645657	\N
1305	218	199	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2026-11-21 11:12:55.98288	\N
1306	219	21	Nueva entrega recibida para revisión: Análisis de la sentencia de inconstitucionalidad de la ley de amnistía.	2026-11-21 19:00:41.281019	\N
1307	219	3	Nueva entrega recibida para revisión: Análisis de la sentencia de inconstitucionalidad de la ley de amnistía.	2026-11-21 19:00:41.281019	\N
1308	219	23	Nueva entrega recibida para revisión: Análisis de la sentencia de inconstitucionalidad de la ley de amnistía.	2026-11-21 19:00:41.281019	\N
1309	219	22	Nueva entrega recibida para revisión: Análisis de la sentencia de inconstitucionalidad de la ley de amnistía.	2026-11-21 19:00:41.281019	\N
1310	219	2	Nueva entrega recibida para revisión: Análisis de la sentencia de inconstitucionalidad de la ley de amnistía.	2026-11-21 19:00:41.281019	2026-11-22 19:17:40.075087
1327	222	2	Nueva entrega recibida para revisión: Valoración preanestésica en pacientes hipertensos.	2026-11-16 00:59:59.218826	2026-11-22 19:17:40.075087
1340	224	122	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.	2026-09-15 10:32:01.905558	2026-09-16 10:32:01.905558
1321	221	2	Nueva entrega recibida (versión corregida) para revisión: Incidencia de náuseas y vómitos postoperatorios en cirugía laparoscópica.	2026-06-17 22:51:59.246045	2026-06-18 22:51:59.246045
1322	221	201	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-06-30 04:18:02.582634	2026-07-01 04:18:02.582634
1353	227	21	Nueva entrega recibida para revisión: Titulación potenciométrica de la acidez del vinagre comercial.	2026-05-28 11:07:11.578109	2026-05-29 11:07:11.578109
1354	227	3	Nueva entrega recibida para revisión: Titulación potenciométrica de la acidez del vinagre comercial.	2026-05-28 11:07:11.578109	2026-05-29 11:07:11.578109
1363	228	2	Nueva entrega recibida para revisión: Estabilidad de una suspensión de amoxicilina reconstituida.	2026-11-22 07:32:56.249189	2026-11-22 19:17:40.075087
1323	222	21	Nueva entrega recibida para revisión: Valoración preanestésica en pacientes hipertensos.	2026-11-16 00:59:59.218826	\N
1324	222	3	Nueva entrega recibida para revisión: Valoración preanestésica en pacientes hipertensos.	2026-11-16 00:59:59.218826	\N
1325	222	23	Nueva entrega recibida para revisión: Valoración preanestésica en pacientes hipertensos.	2026-11-16 00:59:59.218826	\N
1326	222	22	Nueva entrega recibida para revisión: Valoración preanestésica en pacientes hipertensos.	2026-11-16 00:59:59.218826	\N
1328	222	83	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2026-11-18 19:22:01.541351	\N
1359	228	21	Nueva entrega recibida para revisión: Estabilidad de una suspensión de amoxicilina reconstituida.	2026-11-22 07:32:56.249189	\N
1360	228	3	Nueva entrega recibida para revisión: Estabilidad de una suspensión de amoxicilina reconstituida.	2026-11-22 07:32:56.249189	\N
1361	228	23	Nueva entrega recibida para revisión: Estabilidad de una suspensión de amoxicilina reconstituida.	2026-11-22 07:32:56.249189	\N
1362	228	22	Nueva entrega recibida para revisión: Estabilidad de una suspensión de amoxicilina reconstituida.	2026-11-22 07:32:56.249189	\N
1355	227	23	Nueva entrega recibida para revisión: Titulación potenciométrica de la acidez del vinagre comercial.	2026-05-28 11:07:11.578109	2026-05-29 11:07:11.578109
1356	227	22	Nueva entrega recibida para revisión: Titulación potenciométrica de la acidez del vinagre comercial.	2026-05-28 11:07:11.578109	2026-05-29 11:07:11.578109
1357	227	2	Nueva entrega recibida para revisión: Titulación potenciométrica de la acidez del vinagre comercial.	2026-05-28 11:07:11.578109	2026-05-29 11:07:11.578109
1364	229	21	Nueva entrega recibida para revisión: Línea de tiempo interactiva de la historia política salvadoreña.	2026-04-07 00:07:26.605777	2026-04-08 00:07:26.605777
1365	229	3	Nueva entrega recibida para revisión: Línea de tiempo interactiva de la historia política salvadoreña.	2026-04-07 00:07:26.605777	2026-04-08 00:07:26.605777
1366	229	23	Nueva entrega recibida para revisión: Línea de tiempo interactiva de la historia política salvadoreña.	2026-04-07 00:07:26.605777	2026-04-08 00:07:26.605777
1367	229	22	Nueva entrega recibida para revisión: Línea de tiempo interactiva de la historia política salvadoreña.	2026-04-07 00:07:26.605777	2026-04-08 00:07:26.605777
1368	229	2	Nueva entrega recibida para revisión: Línea de tiempo interactiva de la historia política salvadoreña.	2026-04-07 00:07:26.605777	2026-04-08 00:07:26.605777
1370	230	21	Nueva entrega recibida para revisión: Efectos del uso de redes sociales en la autoestima de adolescentes.	2026-07-17 04:48:04.255202	2026-07-18 04:48:04.255202
2054	344	3	Nueva entrega recibida (versión corregida) para revisión: Obtención de jabón artesanal a partir de aceites vegetales.	2025-05-21 21:03:51.017623	2025-05-22 21:03:51.017623
2055	344	23	Nueva entrega recibida (versión corregida) para revisión: Obtención de jabón artesanal a partir de aceites vegetales.	2025-05-21 21:03:51.017623	2025-05-22 21:03:51.017623
2056	344	22	Nueva entrega recibida (versión corregida) para revisión: Obtención de jabón artesanal a partir de aceites vegetales.	2025-05-21 21:03:51.017623	2025-05-22 21:03:51.017623
2057	344	2	Nueva entrega recibida (versión corregida) para revisión: Obtención de jabón artesanal a partir de aceites vegetales.	2025-05-21 21:03:51.017623	2025-05-22 21:03:51.017623
2059	345	21	Nueva entrega recibida para revisión: Formulación de una crema hidratante con aceite de coco.	2025-05-18 20:21:25.731853	2025-05-19 20:21:25.731853
1343	225	23	Nueva entrega recibida para revisión: Corrección de errores escritos frecuentes en noveno grado.	2026-11-20 23:00:38.235065	\N
1344	225	22	Nueva entrega recibida para revisión: Corrección de errores escritos frecuentes en noveno grado.	2026-11-20 23:00:38.235065	\N
1346	225	202	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2026-11-21 08:28:03.587391	\N
1388	233	21	Nueva entrega recibida (versión corregida) para revisión: Prevalencia de hipertensión arterial en trabajadores de la facultad.	2026-11-21 02:50:27.333942	\N
1389	233	3	Nueva entrega recibida (versión corregida) para revisión: Prevalencia de hipertensión arterial en trabajadores de la facultad.	2026-11-21 02:50:27.333942	\N
1390	233	23	Nueva entrega recibida (versión corregida) para revisión: Prevalencia de hipertensión arterial en trabajadores de la facultad.	2026-11-21 02:50:27.333942	\N
1347	226	21	Nueva entrega recibida para revisión: Valores de referencia del hemograma en adultos de San Miguel.	2026-11-20 20:16:02.918121	\N
1348	226	3	Nueva entrega recibida para revisión: Valores de referencia del hemograma en adultos de San Miguel.	2026-11-20 20:16:02.918121	\N
1349	226	23	Nueva entrega recibida para revisión: Valores de referencia del hemograma en adultos de San Miguel.	2026-11-20 20:16:02.918121	\N
1350	226	22	Nueva entrega recibida para revisión: Valores de referencia del hemograma en adultos de San Miguel.	2026-11-20 20:16:02.918121	\N
1352	226	203	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2026-11-21 05:46:09.261983	\N
1345	225	2	Nueva entrega recibida para revisión: Corrección de errores escritos frecuentes en noveno grado.	2026-11-20 23:00:38.235065	2026-11-22 19:17:40.075087
1351	226	2	Nueva entrega recibida para revisión: Valores de referencia del hemograma en adultos de San Miguel.	2026-11-20 20:16:02.918121	2026-11-22 19:17:40.075087
1392	233	2	Nueva entrega recibida (versión corregida) para revisión: Prevalencia de hipertensión arterial en trabajadores de la facultad.	2026-11-21 02:50:27.333942	2026-11-22 19:17:40.075087
1391	233	22	Nueva entrega recibida (versión corregida) para revisión: Prevalencia de hipertensión arterial en trabajadores de la facultad.	2026-11-21 02:50:27.333942	\N
1358	227	204	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.	2026-05-30 15:01:31.921746	2026-05-31 15:01:31.921746
1369	229	206	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.	2026-04-13 06:17:55.960051	2026-04-14 06:17:55.960051
1375	230	207	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-07-26 23:55:04.629861	2026-07-27 23:55:04.629861
1376	231	21	Nueva entrega recibida para revisión: Clima laboral en una empresa de servicios de la zona oriental.	2026-07-07 18:00:34.953754	2026-07-08 18:00:34.953754
1377	231	3	Nueva entrega recibida para revisión: Clima laboral en una empresa de servicios de la zona oriental.	2026-07-07 18:00:34.953754	2026-07-08 18:00:34.953754
1378	231	23	Nueva entrega recibida para revisión: Clima laboral en una empresa de servicios de la zona oriental.	2026-07-07 18:00:34.953754	2026-07-08 18:00:34.953754
1379	231	22	Nueva entrega recibida para revisión: Clima laboral en una empresa de servicios de la zona oriental.	2026-07-07 18:00:34.953754	2026-07-08 18:00:34.953754
1380	231	2	Nueva entrega recibida para revisión: Clima laboral en una empresa de servicios de la zona oriental.	2026-07-07 18:00:34.953754	2026-07-08 18:00:34.953754
1404	236	21	Nueva entrega recibida para revisión: Factores de éxito de los emprendimientos de mujeres en San Miguel.	2026-07-01 06:27:50.63215	2026-07-02 06:27:50.63215
1405	236	3	Nueva entrega recibida para revisión: Factores de éxito de los emprendimientos de mujeres en San Miguel.	2026-07-01 06:27:50.63215	2026-07-02 06:27:50.63215
1406	236	23	Nueva entrega recibida para revisión: Factores de éxito de los emprendimientos de mujeres en San Miguel.	2026-07-01 06:27:50.63215	2026-07-02 06:27:50.63215
2071	347	21	Nueva entrega recibida para revisión: Taller de habilidades sociales para niños de primaria.	2025-04-17 11:34:32.780517	2025-04-18 11:34:32.780517
1407	236	22	Nueva entrega recibida para revisión: Factores de éxito de los emprendimientos de mujeres en San Miguel.	2026-07-01 06:27:50.63215	2026-07-02 06:27:50.63215
1408	236	2	Nueva entrega recibida para revisión: Factores de éxito de los emprendimientos de mujeres en San Miguel.	2026-07-01 06:27:50.63215	2026-07-02 06:27:50.63215
1409	236	156	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2026-07-05 09:08:36.940353	2026-07-06 09:08:36.940353
2072	347	3	Nueva entrega recibida para revisión: Taller de habilidades sociales para niños de primaria.	2025-04-17 11:34:32.780517	2025-04-18 11:34:32.780517
2066	346	3	Nueva entrega recibida para revisión: El lenguaje juvenil en las redes sociales.	2025-06-14 19:36:15.772093	2025-06-15 19:36:15.772093
2067	346	23	Nueva entrega recibida para revisión: El lenguaje juvenil en las redes sociales.	2025-06-14 19:36:15.772093	2025-06-15 19:36:15.772093
2068	346	22	Nueva entrega recibida para revisión: El lenguaje juvenil en las redes sociales.	2025-06-14 19:36:15.772093	2025-06-15 19:36:15.772093
2069	346	2	Nueva entrega recibida para revisión: El lenguaje juvenil en las redes sociales.	2025-06-14 19:36:15.772093	2025-06-15 19:36:15.772093
2070	346	282	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-06-17 01:12:28.134358	2025-06-18 01:12:28.134358
1395	234	23	Nueva entrega recibida para revisión: Simuladores PhET en la enseñanza de la electricidad.	2026-11-20 17:22:30.673394	\N
1396	234	22	Nueva entrega recibida para revisión: Simuladores PhET en la enseñanza de la electricidad.	2026-11-20 17:22:30.673394	\N
1427	240	21	Nueva entrega recibida para revisión: Vivienda social bioclimática para el oriente del país.	2026-11-20 20:54:15.936625	\N
1428	240	3	Nueva entrega recibida para revisión: Vivienda social bioclimática para el oriente del país.	2026-11-20 20:54:15.936625	\N
1415	237	156	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-07-14 07:36:32.671263	2026-07-15 07:36:32.671263
1397	234	2	Nueva entrega recibida para revisión: Simuladores PhET en la enseñanza de la electricidad.	2026-11-20 17:22:30.673394	2026-11-22 19:17:40.075087
1402	235	2	Nueva entrega recibida para revisión: Distribución en planta de una fábrica de muebles.	2026-11-19 03:05:07.010721	2026-11-22 19:17:40.075087
1398	235	21	Nueva entrega recibida para revisión: Distribución en planta de una fábrica de muebles.	2026-11-19 03:05:07.010721	\N
1399	235	3	Nueva entrega recibida para revisión: Distribución en planta de una fábrica de muebles.	2026-11-19 03:05:07.010721	\N
1400	235	23	Nueva entrega recibida para revisión: Distribución en planta de una fábrica de muebles.	2026-11-19 03:05:07.010721	\N
1401	235	22	Nueva entrega recibida para revisión: Distribución en planta de una fábrica de muebles.	2026-11-19 03:05:07.010721	\N
1403	235	208	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2026-11-21 04:57:49.334346	\N
1420	238	2	Nueva entrega recibida para revisión: Satisfacción del cliente en supermercados de la ciudad de San Miguel.	2026-11-21 09:16:34.998017	2026-11-22 19:17:40.075087
1416	238	21	Nueva entrega recibida para revisión: Satisfacción del cliente en supermercados de la ciudad de San Miguel.	2026-11-21 09:16:34.998017	\N
1417	238	3	Nueva entrega recibida para revisión: Satisfacción del cliente en supermercados de la ciudad de San Miguel.	2026-11-21 09:16:34.998017	\N
1418	238	23	Nueva entrega recibida para revisión: Satisfacción del cliente en supermercados de la ciudad de San Miguel.	2026-11-21 09:16:34.998017	\N
1419	238	22	Nueva entrega recibida para revisión: Satisfacción del cliente en supermercados de la ciudad de San Miguel.	2026-11-21 09:16:34.998017	\N
1425	239	2	Nueva entrega recibida para revisión: Teoría de grafos aplicada a las rutas de transporte de San Miguel.	2026-11-20 00:46:50.316049	2026-11-22 19:17:40.075087
1421	239	21	Nueva entrega recibida para revisión: Teoría de grafos aplicada a las rutas de transporte de San Miguel.	2026-11-20 00:46:50.316049	\N
1422	239	3	Nueva entrega recibida para revisión: Teoría de grafos aplicada a las rutas de transporte de San Miguel.	2026-11-20 00:46:50.316049	\N
1423	239	23	Nueva entrega recibida para revisión: Teoría de grafos aplicada a las rutas de transporte de San Miguel.	2026-11-20 00:46:50.316049	\N
1424	239	22	Nueva entrega recibida para revisión: Teoría de grafos aplicada a las rutas de transporte de San Miguel.	2026-11-20 00:46:50.316049	\N
1426	239	210	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.	2026-11-21 07:57:46.638691	\N
2083	349	21	Nueva entrega recibida para revisión: Aprendizaje de la física a través de la resolución de problemas.	2025-10-21 10:13:29.844519	2025-10-22 10:13:29.844519
2084	349	3	Nueva entrega recibida para revisión: Aprendizaje de la física a través de la resolución de problemas.	2025-10-21 10:13:29.844519	2025-10-22 10:13:29.844519
2085	349	23	Nueva entrega recibida para revisión: Aprendizaje de la física a través de la resolución de problemas.	2025-10-21 10:13:29.844519	2025-10-22 10:13:29.844519
2086	349	22	Nueva entrega recibida para revisión: Aprendizaje de la física a través de la resolución de problemas.	2025-10-21 10:13:29.844519	2025-10-22 10:13:29.844519
2087	349	2	Nueva entrega recibida para revisión: Aprendizaje de la física a través de la resolución de problemas.	2025-10-21 10:13:29.844519	2025-10-22 10:13:29.844519
1447	243	2	Nueva entrega recibida (versión corregida) para revisión: Uso de la factura electrónica en los negocios de San Miguel.	2026-11-21 20:42:53.223486	2026-11-22 19:17:40.075087
1443	243	21	Nueva entrega recibida (versión corregida) para revisión: Uso de la factura electrónica en los negocios de San Miguel.	2026-11-21 20:42:53.223486	\N
1444	243	3	Nueva entrega recibida (versión corregida) para revisión: Uso de la factura electrónica en los negocios de San Miguel.	2026-11-21 20:42:53.223486	\N
1445	243	23	Nueva entrega recibida (versión corregida) para revisión: Uso de la factura electrónica en los negocios de San Miguel.	2026-11-21 20:42:53.223486	\N
1446	243	22	Nueva entrega recibida (versión corregida) para revisión: Uso de la factura electrónica en los negocios de San Miguel.	2026-11-21 20:42:53.223486	\N
2097	351	23	Nueva entrega recibida para revisión: Balanceo de línea en una maquila textil.	2025-05-03 13:26:17.907199	2025-05-04 13:26:17.907199
2098	351	22	Nueva entrega recibida para revisión: Balanceo de línea en una maquila textil.	2025-05-03 13:26:17.907199	2025-05-04 13:26:17.907199
2099	351	2	Nueva entrega recibida para revisión: Balanceo de línea en una maquila textil.	2025-05-03 13:26:17.907199	2025-05-04 13:26:17.907199
1410	237	21	Nueva entrega recibida (versión corregida) para revisión: Factores de éxito de los emprendimientos de mujeres en San Miguel.	2026-07-08 07:32:43.286208	2026-07-09 07:32:43.286208
1411	237	3	Nueva entrega recibida (versión corregida) para revisión: Factores de éxito de los emprendimientos de mujeres en San Miguel.	2026-07-08 07:32:43.286208	2026-07-09 07:32:43.286208
1412	237	23	Nueva entrega recibida (versión corregida) para revisión: Factores de éxito de los emprendimientos de mujeres en San Miguel.	2026-07-08 07:32:43.286208	2026-07-09 07:32:43.286208
1413	237	22	Nueva entrega recibida (versión corregida) para revisión: Factores de éxito de los emprendimientos de mujeres en San Miguel.	2026-07-08 07:32:43.286208	2026-07-09 07:32:43.286208
1414	237	2	Nueva entrega recibida (versión corregida) para revisión: Factores de éxito de los emprendimientos de mujeres en San Miguel.	2026-07-08 07:32:43.286208	2026-07-09 07:32:43.286208
1460	246	21	Nueva entrega recibida para revisión: Vulnerabilidad sísmica de escuelas construidas con adobe.	2026-08-14 11:33:36.831918	2026-08-15 11:33:36.831918
1461	246	3	Nueva entrega recibida para revisión: Vulnerabilidad sísmica de escuelas construidas con adobe.	2026-08-14 11:33:36.831918	2026-08-15 11:33:36.831918
1462	246	23	Nueva entrega recibida para revisión: Vulnerabilidad sísmica de escuelas construidas con adobe.	2026-08-14 11:33:36.831918	2026-08-15 11:33:36.831918
1448	244	21	Nueva entrega recibida para revisión: Organización comunitaria en asentamientos de San Miguel.	2026-09-22 16:47:01.541647	2026-09-23 16:47:01.541647
2234	374	23	Nueva entrega recibida (versión corregida) para revisión: Feria científica escolar sobre reacciones químicas.	2026-11-21 23:11:39.348305	\N
1449	244	3	Nueva entrega recibida para revisión: Organización comunitaria en asentamientos de San Miguel.	2026-09-22 16:47:01.541647	2026-09-23 16:47:01.541647
1450	244	23	Nueva entrega recibida para revisión: Organización comunitaria en asentamientos de San Miguel.	2026-09-22 16:47:01.541647	2026-09-23 16:47:01.541647
1451	244	22	Nueva entrega recibida para revisión: Organización comunitaria en asentamientos de San Miguel.	2026-09-22 16:47:01.541647	2026-09-23 16:47:01.541647
1452	244	2	Nueva entrega recibida para revisión: Organización comunitaria en asentamientos de San Miguel.	2026-09-22 16:47:01.541647	2026-09-23 16:47:01.541647
1453	244	214	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2026-10-01 14:30:06.859247	2026-10-02 14:30:06.859247
1459	245	214	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-10-18 04:22:06.536142	2026-10-19 04:22:06.536142
2235	374	22	Nueva entrega recibida (versión corregida) para revisión: Feria científica escolar sobre reacciones químicas.	2026-11-21 23:11:39.348305	\N
2236	374	2	Nueva entrega recibida (versión corregida) para revisión: Feria científica escolar sobre reacciones químicas.	2026-11-21 23:11:39.348305	\N
2237	375	21	Nueva entrega recibida para revisión: Aplicaciones de la teoría de números en criptografía.	2026-11-18 11:49:03.647498	\N
2238	375	3	Nueva entrega recibida para revisión: Aplicaciones de la teoría de números en criptografía.	2026-11-18 11:49:03.647498	\N
2239	375	23	Nueva entrega recibida para revisión: Aplicaciones de la teoría de números en criptografía.	2026-11-18 11:49:03.647498	\N
2240	375	22	Nueva entrega recibida para revisión: Aplicaciones de la teoría de números en criptografía.	2026-11-18 11:49:03.647498	\N
2241	375	2	Nueva entrega recibida para revisión: Aplicaciones de la teoría de números en criptografía.	2026-11-18 11:49:03.647498	\N
2242	375	302	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2026-11-19 13:01:49.962059	\N
2243	376	21	Nueva entrega recibida (versión corregida) para revisión: Aplicaciones de la teoría de números en criptografía.	2026-11-21 13:03:59.296276	\N
1429	240	23	Nueva entrega recibida para revisión: Vivienda social bioclimática para el oriente del país.	2026-11-20 20:54:15.936625	\N
1430	240	22	Nueva entrega recibida para revisión: Vivienda social bioclimática para el oriente del país.	2026-11-20 20:54:15.936625	\N
2100	351	286	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-05-14 04:00:14.279837	2025-05-15 04:00:14.279837
1432	241	21	Nueva entrega recibida para revisión: Aplicación de las NIIF para pymes en empresas comerciales.	2026-11-21 15:50:37.273565	\N
1433	241	3	Nueva entrega recibida para revisión: Aplicación de las NIIF para pymes en empresas comerciales.	2026-11-21 15:50:37.273565	\N
1434	241	23	Nueva entrega recibida para revisión: Aplicación de las NIIF para pymes en empresas comerciales.	2026-11-21 15:50:37.273565	\N
1435	241	22	Nueva entrega recibida para revisión: Aplicación de las NIIF para pymes en empresas comerciales.	2026-11-21 15:50:37.273565	\N
2101	352	21	Nueva entrega recibida para revisión: Exportación de marañón procesado a Europa.	2025-03-30 19:06:41.935529	2025-03-31 19:06:41.935529
1431	240	2	Nueva entrega recibida para revisión: Vivienda social bioclimática para el oriente del país.	2026-11-20 20:54:15.936625	2026-11-22 19:17:40.075087
1436	241	2	Nueva entrega recibida para revisión: Aplicación de las NIIF para pymes en empresas comerciales.	2026-11-21 15:50:37.273565	2026-11-22 19:17:40.075087
1441	242	2	Nueva entrega recibida para revisión: Uso de la factura electrónica en los negocios de San Miguel.	2026-11-18 07:55:16.581762	2026-11-22 19:17:40.075087
2102	352	3	Nueva entrega recibida para revisión: Exportación de marañón procesado a Europa.	2025-03-30 19:06:41.935529	2025-03-31 19:06:41.935529
1437	242	21	Nueva entrega recibida para revisión: Uso de la factura electrónica en los negocios de San Miguel.	2026-11-18 07:55:16.581762	\N
1438	242	3	Nueva entrega recibida para revisión: Uso de la factura electrónica en los negocios de San Miguel.	2026-11-18 07:55:16.581762	\N
1439	242	23	Nueva entrega recibida para revisión: Uso de la factura electrónica en los negocios de San Miguel.	2026-11-18 07:55:16.581762	\N
1440	242	22	Nueva entrega recibida para revisión: Uso de la factura electrónica en los negocios de San Miguel.	2026-11-18 07:55:16.581762	\N
2103	352	23	Nueva entrega recibida para revisión: Exportación de marañón procesado a Europa.	2025-03-30 19:06:41.935529	2025-03-31 19:06:41.935529
1442	242	213	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2026-11-20 01:33:27.888545	\N
1454	245	21	Nueva entrega recibida (versión corregida) para revisión: Organización comunitaria en asentamientos de San Miguel.	2026-10-10 20:15:48.204653	2026-10-11 20:15:48.204653
1455	245	3	Nueva entrega recibida (versión corregida) para revisión: Organización comunitaria en asentamientos de San Miguel.	2026-10-10 20:15:48.204653	2026-10-11 20:15:48.204653
1456	245	23	Nueva entrega recibida (versión corregida) para revisión: Organización comunitaria en asentamientos de San Miguel.	2026-10-10 20:15:48.204653	2026-10-11 20:15:48.204653
2104	352	22	Nueva entrega recibida para revisión: Exportación de marañón procesado a Europa.	2025-03-30 19:06:41.935529	2025-03-31 19:06:41.935529
1457	245	22	Nueva entrega recibida (versión corregida) para revisión: Organización comunitaria en asentamientos de San Miguel.	2026-10-10 20:15:48.204653	2026-10-11 20:15:48.204653
1458	245	2	Nueva entrega recibida (versión corregida) para revisión: Organización comunitaria en asentamientos de San Miguel.	2026-10-10 20:15:48.204653	2026-10-11 20:15:48.204653
1465	246	136	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-08-25 02:41:50.172626	2026-08-26 02:41:50.172626
2105	352	2	Nueva entrega recibida para revisión: Exportación de marañón procesado a Europa.	2025-03-30 19:06:41.935529	2025-03-31 19:06:41.935529
2106	352	287	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.	2025-04-13 01:47:51.282042	2025-04-14 01:47:51.282042
1495	251	218	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-10-14 04:56:45.702337	2026-10-15 04:56:45.702337
1501	252	219	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-05-03 07:45:33.670456	2026-05-04 07:45:33.670456
1483	250	21	Nueva entrega recibida (versión corregida) para revisión: El puerto de La Unión como plataforma logística regional.	2026-07-15 06:31:09.371065	2026-07-16 06:31:09.371065
1484	250	3	Nueva entrega recibida (versión corregida) para revisión: El puerto de La Unión como plataforma logística regional.	2026-07-15 06:31:09.371065	2026-07-16 06:31:09.371065
1485	250	23	Nueva entrega recibida (versión corregida) para revisión: El puerto de La Unión como plataforma logística regional.	2026-07-15 06:31:09.371065	2026-07-16 06:31:09.371065
1486	250	22	Nueva entrega recibida (versión corregida) para revisión: El puerto de La Unión como plataforma logística regional.	2026-07-15 06:31:09.371065	2026-07-16 06:31:09.371065
1487	250	2	Nueva entrega recibida (versión corregida) para revisión: El puerto de La Unión como plataforma logística regional.	2026-07-15 06:31:09.371065	2026-07-16 06:31:09.371065
1489	250	217	Tu publicación fue retirada del catálogo. Motivo: Se detectaron datos personales de participantes en el documento.	2026-10-27 07:47:11.024382	2026-10-28 07:47:11.024382
1507	253	220	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-10-27 03:49:05.621251	2026-10-28 03:49:05.621251
1508	254	21	Nueva entrega recibida (actualización de un trabajo publicado) para revisión: Movimiento amortiguado de un sistema masa-resorte.	2026-10-29 13:42:37.939713	2026-10-30 13:42:37.939713
1470	247	2	Nueva entrega recibida para revisión: Optimización de rutas de distribución para una embotelladora.	2026-11-21 04:31:55.760165	2026-11-22 19:17:40.075087
1476	248	2	Nueva entrega recibida para revisión: Gestión de almacenes en un centro de distribución de alimentos.	2026-11-22 02:47:28.346744	2026-11-22 19:17:40.075087
1502	253	21	Nueva entrega recibida para revisión: Movimiento amortiguado de un sistema masa-resorte.	2026-10-25 01:37:06.289426	2026-10-26 01:37:06.289426
1466	247	21	Nueva entrega recibida para revisión: Optimización de rutas de distribución para una embotelladora.	2026-11-21 04:31:55.760165	\N
1467	247	3	Nueva entrega recibida para revisión: Optimización de rutas de distribución para una embotelladora.	2026-11-21 04:31:55.760165	\N
1468	247	23	Nueva entrega recibida para revisión: Optimización de rutas de distribución para una embotelladora.	2026-11-21 04:31:55.760165	\N
1469	247	22	Nueva entrega recibida para revisión: Optimización de rutas de distribución para una embotelladora.	2026-11-21 04:31:55.760165	\N
1471	247	215	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.	2026-11-22 10:02:38.059182	\N
1472	248	21	Nueva entrega recibida para revisión: Gestión de almacenes en un centro de distribución de alimentos.	2026-11-22 02:47:28.346744	\N
1473	248	3	Nueva entrega recibida para revisión: Gestión de almacenes en un centro de distribución de alimentos.	2026-11-22 02:47:28.346744	\N
1474	248	23	Nueva entrega recibida para revisión: Gestión de almacenes en un centro de distribución de alimentos.	2026-11-22 02:47:28.346744	\N
1475	248	22	Nueva entrega recibida para revisión: Gestión de almacenes en un centro de distribución de alimentos.	2026-11-22 02:47:28.346744	\N
1463	246	22	Nueva entrega recibida para revisión: Vulnerabilidad sísmica de escuelas construidas con adobe.	2026-08-14 11:33:36.831918	2026-08-15 11:33:36.831918
1464	246	2	Nueva entrega recibida para revisión: Vulnerabilidad sísmica de escuelas construidas con adobe.	2026-08-14 11:33:36.831918	2026-08-15 11:33:36.831918
1490	251	21	Nueva entrega recibida para revisión: Canciones infantiles para enseñar hábitos de higiene.	2026-10-11 19:10:02.334941	2026-10-12 19:10:02.334941
1491	251	3	Nueva entrega recibida para revisión: Canciones infantiles para enseñar hábitos de higiene.	2026-10-11 19:10:02.334941	2026-10-12 19:10:02.334941
2107	353	21	Nueva entrega recibida para revisión: Modelos de regresión para el rendimiento del maíz.	2025-11-24 12:51:56.601117	2025-11-25 12:51:56.601117
2108	353	3	Nueva entrega recibida para revisión: Modelos de regresión para el rendimiento del maíz.	2025-11-24 12:51:56.601117	2025-11-25 12:51:56.601117
2109	353	23	Nueva entrega recibida para revisión: Modelos de regresión para el rendimiento del maíz.	2025-11-24 12:51:56.601117	2025-11-25 12:51:56.601117
2110	353	22	Nueva entrega recibida para revisión: Modelos de regresión para el rendimiento del maíz.	2025-11-24 12:51:56.601117	2025-11-25 12:51:56.601117
2111	353	2	Nueva entrega recibida para revisión: Modelos de regresión para el rendimiento del maíz.	2025-11-24 12:51:56.601117	2025-11-25 12:51:56.601117
2112	353	288	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-11-28 21:53:51.990875	2025-11-29 21:53:51.990875
1492	251	23	Nueva entrega recibida para revisión: Canciones infantiles para enseñar hábitos de higiene.	2026-10-11 19:10:02.334941	2026-10-12 19:10:02.334941
1493	251	22	Nueva entrega recibida para revisión: Canciones infantiles para enseñar hábitos de higiene.	2026-10-11 19:10:02.334941	2026-10-12 19:10:02.334941
1494	251	2	Nueva entrega recibida para revisión: Canciones infantiles para enseñar hábitos de higiene.	2026-10-11 19:10:02.334941	2026-10-12 19:10:02.334941
1477	249	21	Nueva entrega recibida para revisión: El puerto de La Unión como plataforma logística regional.	2026-06-26 16:43:15.669105	2026-06-27 16:43:15.669105
1478	249	3	Nueva entrega recibida para revisión: El puerto de La Unión como plataforma logística regional.	2026-06-26 16:43:15.669105	2026-06-27 16:43:15.669105
1479	249	23	Nueva entrega recibida para revisión: El puerto de La Unión como plataforma logística regional.	2026-06-26 16:43:15.669105	2026-06-27 16:43:15.669105
1480	249	22	Nueva entrega recibida para revisión: El puerto de La Unión como plataforma logística regional.	2026-06-26 16:43:15.669105	2026-06-27 16:43:15.669105
1481	249	2	Nueva entrega recibida para revisión: El puerto de La Unión como plataforma logística regional.	2026-06-26 16:43:15.669105	2026-06-27 16:43:15.669105
1482	249	217	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2026-07-07 17:23:42.014723	2026-07-08 17:23:42.014723
1488	250	217	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-07-21 17:57:40.719118	2026-07-22 17:57:40.719118
1496	252	21	Nueva entrega recibida para revisión: Propiedades ópticas de películas delgadas.	2026-04-28 11:40:15.334293	2026-04-29 11:40:15.334293
2113	354	21	Nueva entrega recibida para revisión: Confort térmico en las aulas de la facultad.	2025-09-24 20:44:09.650857	2025-09-25 20:44:09.650857
1497	252	3	Nueva entrega recibida para revisión: Propiedades ópticas de películas delgadas.	2026-04-28 11:40:15.334293	2026-04-29 11:40:15.334293
1498	252	23	Nueva entrega recibida para revisión: Propiedades ópticas de películas delgadas.	2026-04-28 11:40:15.334293	2026-04-29 11:40:15.334293
1499	252	22	Nueva entrega recibida para revisión: Propiedades ópticas de películas delgadas.	2026-04-28 11:40:15.334293	2026-04-29 11:40:15.334293
2114	354	3	Nueva entrega recibida para revisión: Confort térmico en las aulas de la facultad.	2025-09-24 20:44:09.650857	2025-09-25 20:44:09.650857
2115	354	23	Nueva entrega recibida para revisión: Confort térmico en las aulas de la facultad.	2025-09-24 20:44:09.650857	2025-09-25 20:44:09.650857
2116	354	22	Nueva entrega recibida para revisión: Confort térmico en las aulas de la facultad.	2025-09-24 20:44:09.650857	2025-09-25 20:44:09.650857
2117	354	2	Nueva entrega recibida para revisión: Confort térmico en las aulas de la facultad.	2025-09-24 20:44:09.650857	2025-09-25 20:44:09.650857
1512	254	2	Nueva entrega recibida (actualización de un trabajo publicado) para revisión: Movimiento amortiguado de un sistema masa-resorte.	2026-10-29 13:42:37.939713	2026-10-30 13:42:37.939713
1503	253	3	Nueva entrega recibida para revisión: Movimiento amortiguado de un sistema masa-resorte.	2026-10-25 01:37:06.289426	2026-10-26 01:37:06.289426
1504	253	23	Nueva entrega recibida para revisión: Movimiento amortiguado de un sistema masa-resorte.	2026-10-25 01:37:06.289426	2026-10-26 01:37:06.289426
1505	253	22	Nueva entrega recibida para revisión: Movimiento amortiguado de un sistema masa-resorte.	2026-10-25 01:37:06.289426	2026-10-26 01:37:06.289426
1506	253	2	Nueva entrega recibida para revisión: Movimiento amortiguado de un sistema masa-resorte.	2026-10-25 01:37:06.289426	2026-10-26 01:37:06.289426
2244	376	3	Nueva entrega recibida (versión corregida) para revisión: Aplicaciones de la teoría de números en criptografía.	2026-11-21 13:03:59.296276	\N
2245	376	23	Nueva entrega recibida (versión corregida) para revisión: Aplicaciones de la teoría de números en criptografía.	2026-11-21 13:03:59.296276	\N
2246	376	22	Nueva entrega recibida (versión corregida) para revisión: Aplicaciones de la teoría de números en criptografía.	2026-11-21 13:03:59.296276	\N
2247	376	2	Nueva entrega recibida (versión corregida) para revisión: Aplicaciones de la teoría de números en criptografía.	2026-11-21 13:03:59.296276	\N
1625	273	2	Nueva entrega recibida (versión corregida) para revisión: Contenido de nitratos en agua de pozos de la zona oriental.	2021-08-15 13:26:16.545862	2021-08-16 13:26:16.545862
19	6	21	Nueva entrega recibida para revisión: Estrategias lúdicas para la enseñanza de la genética en educación media.	2019-05-26 06:15:16.446794	2019-05-27 06:15:16.446794
20	6	22	Nueva entrega recibida para revisión: Estrategias lúdicas para la enseñanza de la genética en educación media.	2019-05-26 06:15:16.446794	2019-05-27 06:15:16.446794
21	6	23	Nueva entrega recibida para revisión: Estrategias lúdicas para la enseñanza de la genética en educación media.	2019-05-26 06:15:16.446794	2019-05-27 06:15:16.446794
11	5	2	Nueva entrega recibida para revisión: Huerto escolar como recurso didáctico para la enseñanza de la biología.	2019-11-23 06:12:27.49384	2019-11-24 06:12:27.49384
12	5	3	Nueva entrega recibida para revisión: Huerto escolar como recurso didáctico para la enseñanza de la biología.	2019-11-23 06:12:27.49384	2019-11-24 06:12:27.49384
13	5	21	Nueva entrega recibida para revisión: Huerto escolar como recurso didáctico para la enseñanza de la biología.	2019-11-23 06:12:27.49384	2019-11-24 06:12:27.49384
14	5	22	Nueva entrega recibida para revisión: Huerto escolar como recurso didáctico para la enseñanza de la biología.	2019-11-23 06:12:27.49384	2019-11-24 06:12:27.49384
15	5	23	Nueva entrega recibida para revisión: Huerto escolar como recurso didáctico para la enseñanza de la biología.	2019-11-23 06:12:27.49384	2019-11-24 06:12:27.49384
22	6	49	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2019-05-28 22:20:14.750247	2019-05-29 22:20:14.750247
23	7	2	Nueva entrega recibida (versión corregida) para revisión: Estrategias lúdicas para la enseñanza de la genética en educación media.	2019-06-04 09:54:57.263884	2019-06-05 09:54:57.263884
24	7	3	Nueva entrega recibida (versión corregida) para revisión: Estrategias lúdicas para la enseñanza de la genética en educación media.	2019-06-04 09:54:57.263884	2019-06-05 09:54:57.263884
25	7	21	Nueva entrega recibida (versión corregida) para revisión: Estrategias lúdicas para la enseñanza de la genética en educación media.	2019-06-04 09:54:57.263884	2019-06-05 09:54:57.263884
26	7	22	Nueva entrega recibida (versión corregida) para revisión: Estrategias lúdicas para la enseñanza de la genética en educación media.	2019-06-04 09:54:57.263884	2019-06-05 09:54:57.263884
28	7	49	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2019-06-07 03:54:50.639039	2019-06-08 03:54:50.639039
35	9	2	Nueva entrega recibida para revisión: Cinética de degradación de colorantes por fotocatálisis.	2019-08-10 20:03:08.938318	2019-08-11 20:03:08.938318
29	8	2	Nueva entrega recibida para revisión: Estimulación temprana en niños con síndrome de Down.	2019-08-22 13:30:05.28599	2019-08-23 13:30:05.28599
30	8	3	Nueva entrega recibida para revisión: Estimulación temprana en niños con síndrome de Down.	2019-08-22 13:30:05.28599	2019-08-23 13:30:05.28599
31	8	21	Nueva entrega recibida para revisión: Estimulación temprana en niños con síndrome de Down.	2019-08-22 13:30:05.28599	2019-08-23 13:30:05.28599
32	8	22	Nueva entrega recibida para revisión: Estimulación temprana en niños con síndrome de Down.	2019-08-22 13:30:05.28599	2019-08-23 13:30:05.28599
33	8	23	Nueva entrega recibida para revisión: Estimulación temprana en niños con síndrome de Down.	2019-08-22 13:30:05.28599	2019-08-23 13:30:05.28599
34	8	50	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2019-08-25 07:57:46.628416	2019-08-26 07:57:46.628416
36	9	3	Nueva entrega recibida para revisión: Cinética de degradación de colorantes por fotocatálisis.	2019-08-10 20:03:08.938318	2019-08-11 20:03:08.938318
37	9	21	Nueva entrega recibida para revisión: Cinética de degradación de colorantes por fotocatálisis.	2019-08-10 20:03:08.938318	2019-08-11 20:03:08.938318
38	9	22	Nueva entrega recibida para revisión: Cinética de degradación de colorantes por fotocatálisis.	2019-08-10 20:03:08.938318	2019-08-11 20:03:08.938318
39	9	23	Nueva entrega recibida para revisión: Cinética de degradación de colorantes por fotocatálisis.	2019-08-10 20:03:08.938318	2019-08-11 20:03:08.938318
58	12	54	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2019-12-10 17:37:46.806479	2019-12-11 17:37:46.806479
47	11	2	Nueva entrega recibida para revisión: La poesía de Roque Dalton desde la crítica social.	2019-05-17 17:40:26.860285	2019-05-18 17:40:26.860285
40	9	51	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2019-08-16 03:17:28.280337	2019-08-17 03:17:28.280337
41	10	2	Nueva entrega recibida para revisión: Chatbot de atención a estudiantes de nuevo ingreso.	2019-05-01 05:29:38.590797	2019-05-02 05:29:38.590797
42	10	3	Nueva entrega recibida para revisión: Chatbot de atención a estudiantes de nuevo ingreso.	2019-05-01 05:29:38.590797	2019-05-02 05:29:38.590797
43	10	21	Nueva entrega recibida para revisión: Chatbot de atención a estudiantes de nuevo ingreso.	2019-05-01 05:29:38.590797	2019-05-02 05:29:38.590797
44	10	22	Nueva entrega recibida para revisión: Chatbot de atención a estudiantes de nuevo ingreso.	2019-05-01 05:29:38.590797	2019-05-02 05:29:38.590797
1631	274	22	Nueva entrega recibida para revisión: Plataforma web para la gestión de prácticas profesionales.	2021-11-23 22:35:44.516119	2021-11-24 22:35:44.516119
1626	273	235	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-08-28 20:02:18.886736	2021-08-29 20:02:18.886736
1627	273	235	Tu publicación fue retirada del catálogo. Motivo: Se detectaron datos personales de participantes en el documento.	2021-09-28 05:39:24.210168	2021-09-29 05:39:24.210168
45	10	23	Nueva entrega recibida para revisión: Chatbot de atención a estudiantes de nuevo ingreso.	2019-05-01 05:29:38.590797	2019-05-02 05:29:38.590797
46	10	52	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2019-05-06 09:09:28.927027	2019-05-07 09:09:28.927027
48	11	3	Nueva entrega recibida para revisión: La poesía de Roque Dalton desde la crítica social.	2019-05-17 17:40:26.860285	2019-05-18 17:40:26.860285
49	11	21	Nueva entrega recibida para revisión: La poesía de Roque Dalton desde la crítica social.	2019-05-17 17:40:26.860285	2019-05-18 17:40:26.860285
52	11	53	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.	2019-06-01 17:29:57.176478	2019-06-02 17:29:57.176478
59	13	2	Nueva entrega recibida para revisión: Enseñanza de la historia local en centros escolares de San Miguel.	2019-04-16 09:56:40.10946	2019-04-17 09:56:40.10946
562	96	3	Nueva entrega recibida para revisión: Ansiedad y depresión en adultos mayores de hogares de ancianos de San Miguel.	2022-03-15 00:47:40.145248	2022-03-16 00:47:40.145248
563	96	23	Nueva entrega recibida para revisión: Ansiedad y depresión en adultos mayores de hogares de ancianos de San Miguel.	2022-03-15 00:47:40.145248	2022-03-16 00:47:40.145248
564	96	22	Nueva entrega recibida para revisión: Ansiedad y depresión en adultos mayores de hogares de ancianos de San Miguel.	2022-03-15 00:47:40.145248	2022-03-16 00:47:40.145248
522	89	22	Nueva entrega recibida para revisión: Contenido de cafeína en bebidas energéticas comerciales.	2022-08-19 10:20:07.116826	2022-08-20 10:20:07.116826
523	89	2	Nueva entrega recibida para revisión: Contenido de cafeína en bebidas energéticas comerciales.	2022-08-19 10:20:07.116826	2022-08-20 10:20:07.116826
565	96	2	Nueva entrega recibida para revisión: Ansiedad y depresión en adultos mayores de hogares de ancianos de San Miguel.	2022-03-15 00:47:40.145248	2022-03-16 00:47:40.145248
549	94	21	Nueva entrega recibida para revisión: Interferencia del español en la pronunciación del francés.	2022-05-27 18:08:34.739319	2022-05-28 18:08:34.739319
550	94	3	Nueva entrega recibida para revisión: Interferencia del español en la pronunciación del francés.	2022-05-27 18:08:34.739319	2022-05-28 18:08:34.739319
551	94	23	Nueva entrega recibida para revisión: Interferencia del español en la pronunciación del francés.	2022-05-27 18:08:34.739319	2022-05-28 18:08:34.739319
552	94	22	Nueva entrega recibida para revisión: Interferencia del español en la pronunciación del francés.	2022-05-27 18:08:34.739319	2022-05-28 18:08:34.739319
531	91	21	Nueva entrega recibida (versión corregida) para revisión: Formulación de un gel cicatrizante a base de sábila.	2022-10-16 20:34:38.704726	2022-10-17 20:34:38.704726
532	91	3	Nueva entrega recibida (versión corregida) para revisión: Formulación de un gel cicatrizante a base de sábila.	2022-10-16 20:34:38.704726	2022-10-17 20:34:38.704726
533	91	23	Nueva entrega recibida (versión corregida) para revisión: Formulación de un gel cicatrizante a base de sábila.	2022-10-16 20:34:38.704726	2022-10-17 20:34:38.704726
534	91	22	Nueva entrega recibida (versión corregida) para revisión: Formulación de un gel cicatrizante a base de sábila.	2022-10-16 20:34:38.704726	2022-10-17 20:34:38.704726
535	91	2	Nueva entrega recibida (versión corregida) para revisión: Formulación de un gel cicatrizante a base de sábila.	2022-10-16 20:34:38.704726	2022-10-17 20:34:38.704726
553	94	2	Nueva entrega recibida para revisión: Interferencia del español en la pronunciación del francés.	2022-05-27 18:08:34.739319	2022-05-28 18:08:34.739319
560	95	110	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-04-19 14:02:40.598946	2022-04-20 14:02:40.598946
543	93	21	Nueva entrega recibida (versión corregida) para revisión: Diseño de la red de datos de un centro escolar.	2022-10-28 07:21:34.868345	2022-10-29 07:21:34.868345
544	93	3	Nueva entrega recibida (versión corregida) para revisión: Diseño de la red de datos de un centro escolar.	2022-10-28 07:21:34.868345	2022-10-29 07:21:34.868345
545	93	23	Nueva entrega recibida (versión corregida) para revisión: Diseño de la red de datos de un centro escolar.	2022-10-28 07:21:34.868345	2022-10-29 07:21:34.868345
546	93	22	Nueva entrega recibida (versión corregida) para revisión: Diseño de la red de datos de un centro escolar.	2022-10-28 07:21:34.868345	2022-10-29 07:21:34.868345
547	93	2	Nueva entrega recibida (versión corregida) para revisión: Diseño de la red de datos de un centro escolar.	2022-10-28 07:21:34.868345	2022-10-29 07:21:34.868345
585	100	21	Nueva entrega recibida para revisión: Rendimiento de variedades de frijol rojo en el valle de San Miguel.	2022-03-17 15:24:06.844222	2022-03-18 15:24:06.844222
578	98	113	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-08-29 12:21:13.280911	2022-08-30 12:21:13.280911
586	100	3	Nueva entrega recibida para revisión: Rendimiento de variedades de frijol rojo en el valle de San Miguel.	2022-03-17 15:24:06.844222	2022-03-18 15:24:06.844222
584	99	114	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-04-09 05:30:29.222506	2022-04-10 05:30:29.222506
587	100	23	Nueva entrega recibida para revisión: Rendimiento de variedades de frijol rojo en el valle de San Miguel.	2022-03-17 15:24:06.844222	2022-03-18 15:24:06.844222
588	100	22	Nueva entrega recibida para revisión: Rendimiento de variedades de frijol rojo en el valle de San Miguel.	2022-03-17 15:24:06.844222	2022-03-18 15:24:06.844222
589	100	2	Nueva entrega recibida para revisión: Rendimiento de variedades de frijol rojo en el valle de San Miguel.	2022-03-17 15:24:06.844222	2022-03-18 15:24:06.844222
567	97	21	Nueva entrega recibida para revisión: Sistema de gestión de seguridad y salud ocupacional para un taller.	2022-07-09 11:00:38.011701	2022-07-10 11:00:38.011701
568	97	3	Nueva entrega recibida para revisión: Sistema de gestión de seguridad y salud ocupacional para un taller.	2022-07-09 11:00:38.011701	2022-07-10 11:00:38.011701
569	97	23	Nueva entrega recibida para revisión: Sistema de gestión de seguridad y salud ocupacional para un taller.	2022-07-09 11:00:38.011701	2022-07-10 11:00:38.011701
570	97	22	Nueva entrega recibida para revisión: Sistema de gestión de seguridad y salud ocupacional para un taller.	2022-07-09 11:00:38.011701	2022-07-10 11:00:38.011701
571	97	2	Nueva entrega recibida para revisión: Sistema de gestión de seguridad y salud ocupacional para un taller.	2022-07-09 11:00:38.011701	2022-07-10 11:00:38.011701
603	103	21	Nueva entrega recibida (versión corregida) para revisión: Diseño de un secador solar de granos para pequeños productores de San Miguel.	2023-09-09 12:16:41.411611	2023-09-10 12:16:41.411611
604	103	3	Nueva entrega recibida (versión corregida) para revisión: Diseño de un secador solar de granos para pequeños productores de San Miguel.	2023-09-09 12:16:41.411611	2023-09-10 12:16:41.411611
605	103	23	Nueva entrega recibida (versión corregida) para revisión: Diseño de un secador solar de granos para pequeños productores de San Miguel.	2023-09-09 12:16:41.411611	2023-09-10 12:16:41.411611
606	103	22	Nueva entrega recibida (versión corregida) para revisión: Diseño de un secador solar de granos para pequeños productores de San Miguel.	2023-09-09 12:16:41.411611	2023-09-10 12:16:41.411611
607	103	2	Nueva entrega recibida (versión corregida) para revisión: Diseño de un secador solar de granos para pequeños productores de San Miguel.	2023-09-09 12:16:41.411611	2023-09-10 12:16:41.411611
596	101	100	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-09-07 10:07:14.126229	2022-09-08 10:07:14.126229
614	104	117	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-04-05 06:32:38.689991	2023-04-06 06:32:38.689991
620	105	118	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-11-18 18:50:58.683386	2023-11-19 18:50:58.683386
626	106	119	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-10-30 06:18:12.702196	2023-10-31 06:18:12.702196
632	107	120	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-04-05 06:49:23.652206	2023-04-06 06:49:23.652206
638	108	121	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-12-03 17:26:41.587384	2023-12-04 17:26:41.587384
639	109	21	Nueva entrega recibida para revisión: Material didáctico de inglés para estudiantes con baja visión.	2023-07-29 09:56:34.169288	2023-07-30 09:56:34.169288
51	11	23	Nueva entrega recibida para revisión: La poesía de Roque Dalton desde la crítica social.	2019-05-17 17:40:26.860285	2019-05-18 17:40:26.860285
53	12	2	Nueva entrega recibida para revisión: Traducción al francés de folletos turísticos de la ruta de Morazán.	2019-12-08 08:35:42.464199	2019-12-09 08:35:42.464199
54	12	3	Nueva entrega recibida para revisión: Traducción al francés de folletos turísticos de la ruta de Morazán.	2019-12-08 08:35:42.464199	2019-12-09 08:35:42.464199
55	12	21	Nueva entrega recibida para revisión: Traducción al francés de folletos turísticos de la ruta de Morazán.	2019-12-08 08:35:42.464199	2019-12-09 08:35:42.464199
56	12	22	Nueva entrega recibida para revisión: Traducción al francés de folletos turísticos de la ruta de Morazán.	2019-12-08 08:35:42.464199	2019-12-09 08:35:42.464199
57	12	23	Nueva entrega recibida para revisión: Traducción al francés de folletos turísticos de la ruta de Morazán.	2019-12-08 08:35:42.464199	2019-12-09 08:35:42.464199
64	13	55	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2019-04-20 16:05:25.440077	2019-04-21 16:05:25.440077
107	21	2	Nueva entrega recibida para revisión: Control de velocidad de un motor trifásico con variador de frecuencia.	2020-08-09 00:41:07.976645	2020-08-10 00:41:07.976645
108	21	3	Nueva entrega recibida para revisión: Control de velocidad de un motor trifásico con variador de frecuencia.	2020-08-09 00:41:07.976645	2020-08-10 00:41:07.976645
77	16	2	Nueva entrega recibida para revisión: Anteproyecto de un parque lineal junto al río Grande de San Miguel.	2019-05-14 07:45:18.514068	2019-05-15 07:45:18.514068
78	16	3	Nueva entrega recibida para revisión: Anteproyecto de un parque lineal junto al río Grande de San Miguel.	2019-05-14 07:45:18.514068	2019-05-15 07:45:18.514068
79	16	21	Nueva entrega recibida para revisión: Anteproyecto de un parque lineal junto al río Grande de San Miguel.	2019-05-14 07:45:18.514068	2019-05-15 07:45:18.514068
71	15	2	Nueva entrega recibida (versión corregida) para revisión: Manual de puestos para una empresa familiar de transporte.	2019-03-17 05:01:04.845457	2019-03-18 05:01:04.845457
72	15	3	Nueva entrega recibida (versión corregida) para revisión: Manual de puestos para una empresa familiar de transporte.	2019-03-17 05:01:04.845457	2019-03-18 05:01:04.845457
73	15	21	Nueva entrega recibida (versión corregida) para revisión: Manual de puestos para una empresa familiar de transporte.	2019-03-17 05:01:04.845457	2019-03-18 05:01:04.845457
74	15	22	Nueva entrega recibida (versión corregida) para revisión: Manual de puestos para una empresa familiar de transporte.	2019-03-17 05:01:04.845457	2019-03-18 05:01:04.845457
75	15	23	Nueva entrega recibida (versión corregida) para revisión: Manual de puestos para una empresa familiar de transporte.	2019-03-17 05:01:04.845457	2019-03-18 05:01:04.845457
109	21	21	Nueva entrega recibida para revisión: Control de velocidad de un motor trifásico con variador de frecuencia.	2020-08-09 00:41:07.976645	2020-08-10 00:41:07.976645
666	113	22	Nueva entrega recibida (versión corregida) para revisión: Red de sensores para monitorear la humedad del suelo en cultivos.	2023-05-22 17:47:09.994881	2023-05-23 17:47:09.994881
667	113	2	Nueva entrega recibida (versión corregida) para revisión: Red de sensores para monitorear la humedad del suelo en cultivos.	2023-05-22 17:47:09.994881	2023-05-23 17:47:09.994881
704	119	130	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2023-10-03 00:54:05.321107	2023-10-04 00:54:05.321107
519	89	21	Nueva entrega recibida para revisión: Contenido de cafeína en bebidas energéticas comerciales.	2022-08-19 10:20:07.116826	2022-08-20 10:20:07.116826
80	16	22	Nueva entrega recibida para revisión: Anteproyecto de un parque lineal junto al río Grande de San Miguel.	2019-05-14 07:45:18.514068	2019-05-15 07:45:18.514068
81	16	23	Nueva entrega recibida para revisión: Anteproyecto de un parque lineal junto al río Grande de San Miguel.	2019-05-14 07:45:18.514068	2019-05-15 07:45:18.514068
95	19	2	Nueva entrega recibida (versión corregida) para revisión: Dificultades en la resolución de problemas con fracciones.	2019-09-12 22:52:41.075224	2019-09-13 22:52:41.075224
96	19	3	Nueva entrega recibida (versión corregida) para revisión: Dificultades en la resolución de problemas con fracciones.	2019-09-12 22:52:41.075224	2019-09-13 22:52:41.075224
97	19	21	Nueva entrega recibida (versión corregida) para revisión: Dificultades en la resolución de problemas con fracciones.	2019-09-12 22:52:41.075224	2019-09-13 22:52:41.075224
98	19	22	Nueva entrega recibida (versión corregida) para revisión: Dificultades en la resolución de problemas con fracciones.	2019-09-12 22:52:41.075224	2019-09-13 22:52:41.075224
99	19	23	Nueva entrega recibida (versión corregida) para revisión: Dificultades en la resolución de problemas con fracciones.	2019-09-12 22:52:41.075224	2019-09-13 22:52:41.075224
83	17	2	Nueva entrega recibida para revisión: Control interno para una cooperativa agrícola.	2019-11-30 00:48:42.780161	2019-12-01 00:48:42.780161
84	17	3	Nueva entrega recibida para revisión: Control interno para una cooperativa agrícola.	2019-11-30 00:48:42.780161	2019-12-01 00:48:42.780161
85	17	21	Nueva entrega recibida para revisión: Control interno para una cooperativa agrícola.	2019-11-30 00:48:42.780161	2019-12-01 00:48:42.780161
86	17	22	Nueva entrega recibida para revisión: Control interno para una cooperativa agrícola.	2019-11-30 00:48:42.780161	2019-12-01 00:48:42.780161
87	17	23	Nueva entrega recibida para revisión: Control interno para una cooperativa agrícola.	2019-11-30 00:48:42.780161	2019-12-01 00:48:42.780161
101	20	2	Nueva entrega recibida para revisión: Rediseño de una prensa hidráulica para el taller de la facultad.	2020-10-13 05:16:27.004032	2020-10-14 05:16:27.004032
102	20	3	Nueva entrega recibida para revisión: Rediseño de una prensa hidráulica para el taller de la facultad.	2020-10-13 05:16:27.004032	2020-10-14 05:16:27.004032
103	20	21	Nueva entrega recibida para revisión: Rediseño de una prensa hidráulica para el taller de la facultad.	2020-10-13 05:16:27.004032	2020-10-14 05:16:27.004032
104	20	22	Nueva entrega recibida para revisión: Rediseño de una prensa hidráulica para el taller de la facultad.	2020-10-13 05:16:27.004032	2020-10-14 05:16:27.004032
105	20	23	Nueva entrega recibida para revisión: Rediseño de una prensa hidráulica para el taller de la facultad.	2020-10-13 05:16:27.004032	2020-10-14 05:16:27.004032
520	89	3	Nueva entrega recibida para revisión: Contenido de cafeína en bebidas energéticas comerciales.	2022-08-19 10:20:07.116826	2022-08-20 10:20:07.116826
521	89	23	Nueva entrega recibida para revisión: Contenido de cafeína en bebidas energéticas comerciales.	2022-08-19 10:20:07.116826	2022-08-20 10:20:07.116826
739	125	2	Nueva entrega recibida (versión corregida) para revisión: Revitalización del centro histórico de San Miguel.	2023-07-29 15:37:27.666543	2023-07-30 15:37:27.666543
717	122	21	Nueva entrega recibida para revisión: Cadenas de Markov aplicadas al rendimiento estudiantil.	2023-05-29 02:02:39.053929	2023-05-30 02:02:39.053929
718	122	3	Nueva entrega recibida para revisión: Cadenas de Markov aplicadas al rendimiento estudiantil.	2023-05-29 02:02:39.053929	2023-05-30 02:02:39.053929
719	122	23	Nueva entrega recibida para revisión: Cadenas de Markov aplicadas al rendimiento estudiantil.	2023-05-29 02:02:39.053929	2023-05-30 02:02:39.053929
720	122	22	Nueva entrega recibida para revisión: Cadenas de Markov aplicadas al rendimiento estudiantil.	2023-05-29 02:02:39.053929	2023-05-30 02:02:39.053929
753	128	21	Nueva entrega recibida para revisión: Diseño estructural de una vivienda de dos niveles.	2023-04-01 20:38:46.262713	2023-04-02 20:38:46.262713
750	127	22	Nueva entrega recibida para revisión: Estudio de caso de una asociación de mujeres artesanas.	2023-06-30 05:49:13.535732	2023-07-01 05:49:13.535732
528	90	22	Nueva entrega recibida para revisión: Formulación de un gel cicatrizante a base de sábila.	2022-09-30 11:19:09.081503	2022-10-01 11:19:09.081503
529	90	2	Nueva entrega recibida para revisión: Formulación de un gel cicatrizante a base de sábila.	2022-09-30 11:19:09.081503	2022-10-01 11:19:09.081503
530	90	108	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2022-10-07 03:48:45.390152	2022-10-08 03:48:45.390152
536	91	108	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-10-30 02:29:52.986973	2022-10-31 02:29:52.986973
112	21	61	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-08-16 02:34:46.326827	2020-08-17 02:34:46.326827
121	23	23	Nueva entrega recibida para revisión: Rehabilitación de pacientes con secuelas de accidente cerebrovascular.	2020-03-29 09:27:20.582369	2020-03-30 09:27:20.582369
122	23	22	Nueva entrega recibida para revisión: Rehabilitación de pacientes con secuelas de accidente cerebrovascular.	2020-03-29 09:27:20.582369	2020-03-30 09:27:20.582369
123	23	2	Nueva entrega recibida para revisión: Rehabilitación de pacientes con secuelas de accidente cerebrovascular.	2020-03-29 09:27:20.582369	2020-03-30 09:27:20.582369
124	23	63	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-04-03 23:39:29.921599	2020-04-04 23:39:29.921599
125	23	63	Tu publicación fue retirada del catálogo. Motivo: La institución colaboradora solicitó no divulgar los resultados.	2020-06-15 20:14:12.234859	2020-06-16 20:14:12.234859
162	30	21	Nueva entrega recibida para revisión: Juegos de mesa para aprender la tabla periódica.	2020-06-15 22:07:17.27547	2020-06-16 22:07:17.27547
113	22	21	Nueva entrega recibida para revisión: Uso de dexmedetomidina como sedante en cuidados intensivos.	2020-06-25 14:51:27.624935	2020-06-26 14:51:27.624935
114	22	3	Nueva entrega recibida para revisión: Uso de dexmedetomidina como sedante en cuidados intensivos.	2020-06-25 14:51:27.624935	2020-06-26 14:51:27.624935
115	22	23	Nueva entrega recibida para revisión: Uso de dexmedetomidina como sedante en cuidados intensivos.	2020-06-25 14:51:27.624935	2020-06-26 14:51:27.624935
116	22	22	Nueva entrega recibida para revisión: Uso de dexmedetomidina como sedante en cuidados intensivos.	2020-06-25 14:51:27.624935	2020-06-26 14:51:27.624935
117	22	2	Nueva entrega recibida para revisión: Uso de dexmedetomidina como sedante en cuidados intensivos.	2020-06-25 14:51:27.624935	2020-06-26 14:51:27.624935
118	22	62	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-07-04 23:54:38.962448	2020-07-05 23:54:38.962448
150	28	21	Nueva entrega recibida para revisión: Educación cívica y participación de los jóvenes en su comunidad.	2020-05-06 15:41:11.674071	2020-05-07 15:41:11.674071
163	30	3	Nueva entrega recibida para revisión: Juegos de mesa para aprender la tabla periódica.	2020-06-15 22:07:17.27547	2020-06-16 22:07:17.27547
161	29	69	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-10-17 06:42:03.651752	2020-10-18 06:42:03.651752
132	25	21	Nueva entrega recibida para revisión: Aplicación móvil de reporte de baches para la alcaldía de San Miguel.	2020-11-24 12:08:24.146858	2020-11-25 12:08:24.146858
133	25	3	Nueva entrega recibida para revisión: Aplicación móvil de reporte de baches para la alcaldía de San Miguel.	2020-11-24 12:08:24.146858	2020-11-25 12:08:24.146858
134	25	23	Nueva entrega recibida para revisión: Aplicación móvil de reporte de baches para la alcaldía de San Miguel.	2020-11-24 12:08:24.146858	2020-11-25 12:08:24.146858
135	25	22	Nueva entrega recibida para revisión: Aplicación móvil de reporte de baches para la alcaldía de San Miguel.	2020-11-24 12:08:24.146858	2020-11-25 12:08:24.146858
136	25	2	Nueva entrega recibida para revisión: Aplicación móvil de reporte de baches para la alcaldía de San Miguel.	2020-11-24 12:08:24.146858	2020-11-25 12:08:24.146858
126	24	21	Nueva entrega recibida para revisión: Inflación de la canasta básica alimentaria entre 2020 y 2025.	2020-10-25 22:53:32.524231	2020-10-26 22:53:32.524231
127	24	3	Nueva entrega recibida para revisión: Inflación de la canasta básica alimentaria entre 2020 y 2025.	2020-10-25 22:53:32.524231	2020-10-26 22:53:32.524231
128	24	23	Nueva entrega recibida para revisión: Inflación de la canasta básica alimentaria entre 2020 y 2025.	2020-10-25 22:53:32.524231	2020-10-26 22:53:32.524231
129	24	22	Nueva entrega recibida para revisión: Inflación de la canasta básica alimentaria entre 2020 y 2025.	2020-10-25 22:53:32.524231	2020-10-26 22:53:32.524231
130	24	2	Nueva entrega recibida para revisión: Inflación de la canasta básica alimentaria entre 2020 y 2025.	2020-10-25 22:53:32.524231	2020-10-26 22:53:32.524231
131	24	64	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-11-06 15:12:38.853575	2020-11-07 15:12:38.853575
138	26	21	Nueva entrega recibida para revisión: Base de datos para el control de inventario de una farmacia.	2020-04-03 07:19:55.059736	2020-04-04 07:19:55.059736
139	26	3	Nueva entrega recibida para revisión: Base de datos para el control de inventario de una farmacia.	2020-04-03 07:19:55.059736	2020-04-04 07:19:55.059736
140	26	23	Nueva entrega recibida para revisión: Base de datos para el control de inventario de una farmacia.	2020-04-03 07:19:55.059736	2020-04-04 07:19:55.059736
141	26	22	Nueva entrega recibida para revisión: Base de datos para el control de inventario de una farmacia.	2020-04-03 07:19:55.059736	2020-04-04 07:19:55.059736
142	26	2	Nueva entrega recibida para revisión: Base de datos para el control de inventario de una farmacia.	2020-04-03 07:19:55.059736	2020-04-04 07:19:55.059736
137	25	65	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-11-26 14:56:24.470772	2020-11-27 14:56:24.470772
144	27	21	Nueva entrega recibida para revisión: Análisis de vulnerabilidades en sitios web de instituciones públicas.	2020-08-23 16:34:41.037665	2020-08-24 16:34:41.037665
145	27	3	Nueva entrega recibida para revisión: Análisis de vulnerabilidades en sitios web de instituciones públicas.	2020-08-23 16:34:41.037665	2020-08-24 16:34:41.037665
146	27	23	Nueva entrega recibida para revisión: Análisis de vulnerabilidades en sitios web de instituciones públicas.	2020-08-23 16:34:41.037665	2020-08-24 16:34:41.037665
147	27	22	Nueva entrega recibida para revisión: Análisis de vulnerabilidades en sitios web de instituciones públicas.	2020-08-23 16:34:41.037665	2020-08-24 16:34:41.037665
148	27	2	Nueva entrega recibida para revisión: Análisis de vulnerabilidades en sitios web de instituciones públicas.	2020-08-23 16:34:41.037665	2020-08-24 16:34:41.037665
143	26	66	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-04-14 09:09:40.397873	2020-04-15 09:09:40.397873
149	27	67	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-09-03 02:35:08.37339	2020-09-04 02:35:08.37339
164	30	23	Nueva entrega recibida para revisión: Juegos de mesa para aprender la tabla periódica.	2020-06-15 22:07:17.27547	2020-06-16 22:07:17.27547
165	30	22	Nueva entrega recibida para revisión: Juegos de mesa para aprender la tabla periódica.	2020-06-15 22:07:17.27547	2020-06-16 22:07:17.27547
166	30	2	Nueva entrega recibida para revisión: Juegos de mesa para aprender la tabla periódica.	2020-06-15 22:07:17.27547	2020-06-16 22:07:17.27547
537	92	21	Nueva entrega recibida para revisión: Diseño de la red de datos de un centro escolar.	2022-10-05 11:15:40.25802	2022-10-06 11:15:40.25802
173	31	70	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-07-17 15:11:37.390562	2020-07-18 15:11:37.390562
153	28	22	Nueva entrega recibida para revisión: Educación cívica y participación de los jóvenes en su comunidad.	2020-05-06 15:41:11.674071	2020-05-07 15:41:11.674071
154	28	2	Nueva entrega recibida para revisión: Educación cívica y participación de los jóvenes en su comunidad.	2020-05-06 15:41:11.674071	2020-05-07 15:41:11.674071
155	28	68	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.	2020-05-17 13:58:23.012067	2020-05-18 13:58:23.012067
167	30	70	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.	2020-06-24 09:03:10.608179	2020-06-25 09:03:10.608179
168	31	21	Nueva entrega recibida (versión corregida) para revisión: Juegos de mesa para aprender la tabla periódica.	2020-07-07 00:25:26.013808	2020-07-08 00:25:26.013808
169	31	3	Nueva entrega recibida (versión corregida) para revisión: Juegos de mesa para aprender la tabla periódica.	2020-07-07 00:25:26.013808	2020-07-08 00:25:26.013808
170	31	23	Nueva entrega recibida (versión corregida) para revisión: Juegos de mesa para aprender la tabla periódica.	2020-07-07 00:25:26.013808	2020-07-08 00:25:26.013808
171	31	22	Nueva entrega recibida (versión corregida) para revisión: Juegos de mesa para aprender la tabla periódica.	2020-07-07 00:25:26.013808	2020-07-08 00:25:26.013808
172	31	2	Nueva entrega recibida (versión corregida) para revisión: Juegos de mesa para aprender la tabla periódica.	2020-07-07 00:25:26.013808	2020-07-08 00:25:26.013808
156	29	21	Nueva entrega recibida para revisión: Experimentos de bajo costo para enseñar cinemática en noveno grado.	2020-10-02 21:23:36.313528	2020-10-03 21:23:36.313528
157	29	3	Nueva entrega recibida para revisión: Experimentos de bajo costo para enseñar cinemática en noveno grado.	2020-10-02 21:23:36.313528	2020-10-03 21:23:36.313528
158	29	23	Nueva entrega recibida para revisión: Experimentos de bajo costo para enseñar cinemática en noveno grado.	2020-10-02 21:23:36.313528	2020-10-03 21:23:36.313528
159	29	22	Nueva entrega recibida para revisión: Experimentos de bajo costo para enseñar cinemática en noveno grado.	2020-10-02 21:23:36.313528	2020-10-03 21:23:36.313528
160	29	2	Nueva entrega recibida para revisión: Experimentos de bajo costo para enseñar cinemática en noveno grado.	2020-10-02 21:23:36.313528	2020-10-03 21:23:36.313528
227	40	75	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-08-08 23:04:34.082492	2020-08-09 23:04:34.082492
198	36	21	Nueva entrega recibida (versión corregida) para revisión: Métodos numéricos para sistemas de ecuaciones no lineales.	2020-08-09 02:23:59.307777	2020-08-10 02:23:59.307777
199	36	3	Nueva entrega recibida (versión corregida) para revisión: Métodos numéricos para sistemas de ecuaciones no lineales.	2020-08-09 02:23:59.307777	2020-08-10 02:23:59.307777
179	32	71	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-09-13 17:46:02.406405	2020-09-14 17:46:02.406405
200	36	23	Nueva entrega recibida (versión corregida) para revisión: Métodos numéricos para sistemas de ecuaciones no lineales.	2020-08-09 02:23:59.307777	2020-08-10 02:23:59.307777
180	33	21	Nueva entrega recibida para revisión: Diagnóstico de la gestión del talento humano en una alcaldía.	2020-08-24 03:25:42.021823	2020-08-25 03:25:42.021823
181	33	3	Nueva entrega recibida para revisión: Diagnóstico de la gestión del talento humano en una alcaldía.	2020-08-24 03:25:42.021823	2020-08-25 03:25:42.021823
182	33	23	Nueva entrega recibida para revisión: Diagnóstico de la gestión del talento humano en una alcaldía.	2020-08-24 03:25:42.021823	2020-08-25 03:25:42.021823
183	33	22	Nueva entrega recibida para revisión: Diagnóstico de la gestión del talento humano en una alcaldía.	2020-08-24 03:25:42.021823	2020-08-25 03:25:42.021823
201	36	22	Nueva entrega recibida (versión corregida) para revisión: Métodos numéricos para sistemas de ecuaciones no lineales.	2020-08-09 02:23:59.307777	2020-08-10 02:23:59.307777
202	36	2	Nueva entrega recibida (versión corregida) para revisión: Métodos numéricos para sistemas de ecuaciones no lineales.	2020-08-09 02:23:59.307777	2020-08-10 02:23:59.307777
184	33	2	Nueva entrega recibida para revisión: Diagnóstico de la gestión del talento humano en una alcaldía.	2020-08-24 03:25:42.021823	2020-08-25 03:25:42.021823
185	33	72	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2020-08-31 04:11:17.348046	2020-09-01 04:11:17.348046
191	34	72	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-09-19 05:42:12.011878	2020-09-20 05:42:12.011878
204	37	21	Nueva entrega recibida para revisión: Material manipulativo para la enseñanza de la geometría.	2020-04-14 01:51:33.363523	2020-04-15 01:51:33.363523
205	37	3	Nueva entrega recibida para revisión: Material manipulativo para la enseñanza de la geometría.	2020-04-14 01:51:33.363523	2020-04-15 01:51:33.363523
206	37	23	Nueva entrega recibida para revisión: Material manipulativo para la enseñanza de la geometría.	2020-04-14 01:51:33.363523	2020-04-15 01:51:33.363523
207	37	22	Nueva entrega recibida para revisión: Material manipulativo para la enseñanza de la geometría.	2020-04-14 01:51:33.363523	2020-04-15 01:51:33.363523
208	37	2	Nueva entrega recibida para revisión: Material manipulativo para la enseñanza de la geometría.	2020-04-14 01:51:33.363523	2020-04-15 01:51:33.363523
216	39	21	Nueva entrega recibida (versión corregida) para revisión: Estudio de suelos para la ampliación de un puente vehicular.	2020-11-16 03:52:24.116077	2020-11-17 03:52:24.116077
217	39	3	Nueva entrega recibida (versión corregida) para revisión: Estudio de suelos para la ampliación de un puente vehicular.	2020-11-16 03:52:24.116077	2020-11-17 03:52:24.116077
218	39	23	Nueva entrega recibida (versión corregida) para revisión: Estudio de suelos para la ampliación de un puente vehicular.	2020-11-16 03:52:24.116077	2020-11-17 03:52:24.116077
219	39	22	Nueva entrega recibida (versión corregida) para revisión: Estudio de suelos para la ampliación de un puente vehicular.	2020-11-16 03:52:24.116077	2020-11-17 03:52:24.116077
220	39	2	Nueva entrega recibida (versión corregida) para revisión: Estudio de suelos para la ampliación de un puente vehicular.	2020-11-16 03:52:24.116077	2020-11-17 03:52:24.116077
668	113	125	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.	2023-05-29 10:52:15.290176	2023-05-30 10:52:15.290176
228	41	21	Nueva entrega recibida para revisión: Indicadores logísticos para una ferretería.	2020-10-21 14:46:24.659428	2020-10-22 14:46:24.659428
229	41	3	Nueva entrega recibida para revisión: Indicadores logísticos para una ferretería.	2020-10-21 14:46:24.659428	2020-10-22 14:46:24.659428
230	41	23	Nueva entrega recibida para revisión: Indicadores logísticos para una ferretería.	2020-10-21 14:46:24.659428	2020-10-22 14:46:24.659428
231	41	22	Nueva entrega recibida para revisión: Indicadores logísticos para una ferretería.	2020-10-21 14:46:24.659428	2020-10-22 14:46:24.659428
232	41	2	Nueva entrega recibida para revisión: Indicadores logísticos para una ferretería.	2020-10-21 14:46:24.659428	2020-10-22 14:46:24.659428
538	92	3	Nueva entrega recibida para revisión: Diseño de la red de datos de un centro escolar.	2022-10-05 11:15:40.25802	2022-10-06 11:15:40.25802
539	92	23	Nueva entrega recibida para revisión: Diseño de la red de datos de un centro escolar.	2022-10-05 11:15:40.25802	2022-10-06 11:15:40.25802
669	114	21	Nueva entrega recibida para revisión: La figura de la mujer en la narrativa de Claudia Lars.	2023-06-07 22:53:00.596872	2023-06-08 22:53:00.596872
174	32	21	Nueva entrega recibida para revisión: Actitudes hacia la química en estudiantes de educación media.	2020-08-31 02:15:16.041305	2020-09-01 02:15:16.041305
175	32	3	Nueva entrega recibida para revisión: Actitudes hacia la química en estudiantes de educación media.	2020-08-31 02:15:16.041305	2020-09-01 02:15:16.041305
176	32	23	Nueva entrega recibida para revisión: Actitudes hacia la química en estudiantes de educación media.	2020-08-31 02:15:16.041305	2020-09-01 02:15:16.041305
177	32	22	Nueva entrega recibida para revisión: Actitudes hacia la química en estudiantes de educación media.	2020-08-31 02:15:16.041305	2020-09-01 02:15:16.041305
178	32	2	Nueva entrega recibida para revisión: Actitudes hacia la química en estudiantes de educación media.	2020-08-31 02:15:16.041305	2020-09-01 02:15:16.041305
223	40	3	Nueva entrega recibida para revisión: Trámites aduaneros para exportar productos agrícolas.	2020-08-05 05:54:49.754748	2020-08-06 05:54:49.754748
557	95	23	Nueva entrega recibida para revisión: Interpretación consecutiva en un foro de turismo.	2022-04-05 23:41:35.310522	2022-04-06 23:41:35.310522
558	95	22	Nueva entrega recibida para revisión: Interpretación consecutiva en un foro de turismo.	2022-04-05 23:41:35.310522	2022-04-06 23:41:35.310522
542	92	109	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2022-10-19 15:51:16.550374	2022-10-20 15:51:16.550374
548	93	109	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-11-02 10:32:19.169788	2022-11-03 10:32:19.169788
186	34	21	Nueva entrega recibida (versión corregida) para revisión: Diagnóstico de la gestión del talento humano en una alcaldía.	2020-09-14 07:58:22.683674	2020-09-15 07:58:22.683674
187	34	3	Nueva entrega recibida (versión corregida) para revisión: Diagnóstico de la gestión del talento humano en una alcaldía.	2020-09-14 07:58:22.683674	2020-09-15 07:58:22.683674
188	34	23	Nueva entrega recibida (versión corregida) para revisión: Diagnóstico de la gestión del talento humano en una alcaldía.	2020-09-14 07:58:22.683674	2020-09-15 07:58:22.683674
189	34	22	Nueva entrega recibida (versión corregida) para revisión: Diagnóstico de la gestión del talento humano en una alcaldía.	2020-09-14 07:58:22.683674	2020-09-15 07:58:22.683674
190	34	2	Nueva entrega recibida (versión corregida) para revisión: Diagnóstico de la gestión del talento humano en una alcaldía.	2020-09-14 07:58:22.683674	2020-09-15 07:58:22.683674
554	94	110	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.	2022-05-30 08:47:03.040728	2022-05-31 08:47:03.040728
192	35	21	Nueva entrega recibida para revisión: Métodos numéricos para sistemas de ecuaciones no lineales.	2020-07-17 06:24:07.591005	2020-07-18 06:24:07.591005
193	35	3	Nueva entrega recibida para revisión: Métodos numéricos para sistemas de ecuaciones no lineales.	2020-07-17 06:24:07.591005	2020-07-18 06:24:07.591005
194	35	23	Nueva entrega recibida para revisión: Métodos numéricos para sistemas de ecuaciones no lineales.	2020-07-17 06:24:07.591005	2020-07-18 06:24:07.591005
195	35	22	Nueva entrega recibida para revisión: Métodos numéricos para sistemas de ecuaciones no lineales.	2020-07-17 06:24:07.591005	2020-07-18 06:24:07.591005
196	35	2	Nueva entrega recibida para revisión: Métodos numéricos para sistemas de ecuaciones no lineales.	2020-07-17 06:24:07.591005	2020-07-18 06:24:07.591005
197	35	73	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2020-07-29 15:51:12.943748	2020-07-30 15:51:12.943748
203	36	73	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-08-19 08:17:57.691402	2020-08-20 08:17:57.691402
559	95	2	Nueva entrega recibida para revisión: Interpretación consecutiva en un foro de turismo.	2022-04-05 23:41:35.310522	2022-04-06 23:41:35.310522
210	38	21	Nueva entrega recibida para revisión: Estudio de suelos para la ampliación de un puente vehicular.	2020-11-02 12:48:17.389775	2020-11-03 12:48:17.389775
211	38	3	Nueva entrega recibida para revisión: Estudio de suelos para la ampliación de un puente vehicular.	2020-11-02 12:48:17.389775	2020-11-03 12:48:17.389775
212	38	23	Nueva entrega recibida para revisión: Estudio de suelos para la ampliación de un puente vehicular.	2020-11-02 12:48:17.389775	2020-11-03 12:48:17.389775
213	38	22	Nueva entrega recibida para revisión: Estudio de suelos para la ampliación de un puente vehicular.	2020-11-02 12:48:17.389775	2020-11-03 12:48:17.389775
214	38	2	Nueva entrega recibida para revisión: Estudio de suelos para la ampliación de un puente vehicular.	2020-11-02 12:48:17.389775	2020-11-03 12:48:17.389775
215	38	74	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2020-11-11 00:40:38.735958	2020-11-12 00:40:38.735958
221	39	74	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-11-21 13:02:47.462165	2020-11-22 13:02:47.462165
573	98	21	Nueva entrega recibida para revisión: Sistema de agua potable para un caserío de Morazán.	2022-08-20 21:35:52.941613	2022-08-21 21:35:52.941613
566	96	111	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-03-21 10:55:14.447785	2022-03-22 10:55:14.447785
574	98	3	Nueva entrega recibida para revisión: Sistema de agua potable para un caserío de Morazán.	2022-08-20 21:35:52.941613	2022-08-21 21:35:52.941613
575	98	23	Nueva entrega recibida para revisión: Sistema de agua potable para un caserío de Morazán.	2022-08-20 21:35:52.941613	2022-08-21 21:35:52.941613
576	98	22	Nueva entrega recibida para revisión: Sistema de agua potable para un caserío de Morazán.	2022-08-20 21:35:52.941613	2022-08-21 21:35:52.941613
577	98	2	Nueva entrega recibida para revisión: Sistema de agua potable para un caserío de Morazán.	2022-08-20 21:35:52.941613	2022-08-21 21:35:52.941613
579	99	21	Nueva entrega recibida para revisión: Selección de incoterms en la importación de maquinaria.	2022-03-29 02:37:30.887451	2022-03-30 02:37:30.887451
580	99	3	Nueva entrega recibida para revisión: Selección de incoterms en la importación de maquinaria.	2022-03-29 02:37:30.887451	2022-03-30 02:37:30.887451
572	97	112	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-07-11 14:19:04.348534	2022-07-12 14:19:04.348534
581	99	23	Nueva entrega recibida para revisión: Selección de incoterms en la importación de maquinaria.	2022-03-29 02:37:30.887451	2022-03-30 02:37:30.887451
582	99	22	Nueva entrega recibida para revisión: Selección de incoterms en la importación de maquinaria.	2022-03-29 02:37:30.887451	2022-03-30 02:37:30.887451
583	99	2	Nueva entrega recibida para revisión: Selección de incoterms en la importación de maquinaria.	2022-03-29 02:37:30.887451	2022-03-30 02:37:30.887451
590	100	115	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-03-23 08:25:35.195645	2022-03-24 08:25:35.195645
740	125	133	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-07-31 18:39:59.064379	2023-08-01 18:39:59.064379
746	126	134	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-03-19 09:50:49.829701	2023-03-20 09:50:49.829701
224	40	23	Nueva entrega recibida para revisión: Trámites aduaneros para exportar productos agrícolas.	2020-08-05 05:54:49.754748	2020-08-06 05:54:49.754748
225	40	22	Nueva entrega recibida para revisión: Trámites aduaneros para exportar productos agrícolas.	2020-08-05 05:54:49.754748	2020-08-06 05:54:49.754748
226	40	2	Nueva entrega recibida para revisión: Trámites aduaneros para exportar productos agrícolas.	2020-08-05 05:54:49.754748	2020-08-06 05:54:49.754748
283	50	3	Nueva entrega recibida para revisión: Control de calidad interno en el laboratorio de química clínica.	2021-10-12 20:37:30.412356	2021-10-13 20:37:30.412356
233	41	76	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2020-11-05 04:48:32.978196	2020-11-06 04:48:32.978196
284	50	23	Nueva entrega recibida para revisión: Control de calidad interno en el laboratorio de química clínica.	2021-10-12 20:37:30.412356	2021-10-13 20:37:30.412356
245	43	77	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2020-04-15 12:06:02.347061	2020-04-16 12:06:02.347061
285	50	22	Nueva entrega recibida para revisión: Control de calidad interno en el laboratorio de química clínica.	2021-10-12 20:37:30.412356	2021-10-13 20:37:30.412356
251	44	78	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-07-28 03:27:19.339929	2021-07-29 03:27:19.339929
286	50	2	Nueva entrega recibida para revisión: Control de calidad interno en el laboratorio de química clínica.	2021-10-12 20:37:30.412356	2021-10-13 20:37:30.412356
269	47	81	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-07-22 12:09:02.630498	2021-07-23 12:09:02.630498
275	48	82	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-03-27 22:36:42.732681	2021-03-28 22:36:42.732681
300	53	21	Nueva entrega recibida para revisión: Modelo de regresión del precio internacional del café.	2021-08-27 07:54:00.379051	2021-08-28 07:54:00.379051
301	53	3	Nueva entrega recibida para revisión: Modelo de regresión del precio internacional del café.	2021-08-27 07:54:00.379051	2021-08-28 07:54:00.379051
302	53	23	Nueva entrega recibida para revisión: Modelo de regresión del precio internacional del café.	2021-08-27 07:54:00.379051	2021-08-28 07:54:00.379051
303	53	22	Nueva entrega recibida para revisión: Modelo de regresión del precio internacional del café.	2021-08-27 07:54:00.379051	2021-08-28 07:54:00.379051
304	53	2	Nueva entrega recibida para revisión: Modelo de regresión del precio internacional del café.	2021-08-27 07:54:00.379051	2021-08-28 07:54:00.379051
276	49	21	Nueva entrega recibida para revisión: Manejo de la vía aérea difícil en pacientes con obesidad.	2021-04-28 23:00:36.341193	2021-04-29 23:00:36.341193
277	49	3	Nueva entrega recibida para revisión: Manejo de la vía aérea difícil en pacientes con obesidad.	2021-04-28 23:00:36.341193	2021-04-29 23:00:36.341193
278	49	23	Nueva entrega recibida para revisión: Manejo de la vía aérea difícil en pacientes con obesidad.	2021-04-28 23:00:36.341193	2021-04-29 23:00:36.341193
279	49	22	Nueva entrega recibida para revisión: Manejo de la vía aérea difícil en pacientes con obesidad.	2021-04-28 23:00:36.341193	2021-04-29 23:00:36.341193
280	49	2	Nueva entrega recibida para revisión: Manejo de la vía aérea difícil en pacientes con obesidad.	2021-04-28 23:00:36.341193	2021-04-29 23:00:36.341193
294	52	21	Nueva entrega recibida (versión corregida) para revisión: Interacciones medicamentosas en pacientes polimedicados.	2021-09-16 04:56:26.747997	2021-09-17 04:56:26.747997
295	52	3	Nueva entrega recibida (versión corregida) para revisión: Interacciones medicamentosas en pacientes polimedicados.	2021-09-16 04:56:26.747997	2021-09-17 04:56:26.747997
296	52	23	Nueva entrega recibida (versión corregida) para revisión: Interacciones medicamentosas en pacientes polimedicados.	2021-09-16 04:56:26.747997	2021-09-17 04:56:26.747997
297	52	22	Nueva entrega recibida (versión corregida) para revisión: Interacciones medicamentosas en pacientes polimedicados.	2021-09-16 04:56:26.747997	2021-09-17 04:56:26.747997
298	52	2	Nueva entrega recibida (versión corregida) para revisión: Interacciones medicamentosas en pacientes polimedicados.	2021-09-16 04:56:26.747997	2021-09-17 04:56:26.747997
299	52	85	Decisión del supervisor: Rechazada. El documento adjunto no corresponde al trabajo descrito en la ficha.	2021-09-23 19:42:24.082462	2021-09-24 19:42:24.082462
311	54	65	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-12-10 16:51:16.364144	2021-12-11 16:51:16.364144
336	58	89	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-06-09 15:35:37.692648	2021-06-10 15:35:37.692648
312	55	21	Nueva entrega recibida para revisión: Errores ortográficos frecuentes en textos de estudiantes de bachillerato.	2021-11-03 18:49:18.663465	2021-11-04 18:49:18.663465
313	55	3	Nueva entrega recibida para revisión: Errores ortográficos frecuentes en textos de estudiantes de bachillerato.	2021-11-03 18:49:18.663465	2021-11-04 18:49:18.663465
314	55	23	Nueva entrega recibida para revisión: Errores ortográficos frecuentes en textos de estudiantes de bachillerato.	2021-11-03 18:49:18.663465	2021-11-04 18:49:18.663465
315	55	22	Nueva entrega recibida para revisión: Errores ortográficos frecuentes en textos de estudiantes de bachillerato.	2021-11-03 18:49:18.663465	2021-11-04 18:49:18.663465
343	60	21	Nueva entrega recibida para revisión: Manual de seguridad para laboratorios escolares de química.	2021-06-15 05:11:34.080312	2021-06-16 05:11:34.080312
344	60	3	Nueva entrega recibida para revisión: Manual de seguridad para laboratorios escolares de química.	2021-06-15 05:11:34.080312	2021-06-16 05:11:34.080312
316	55	2	Nueva entrega recibida para revisión: Errores ortográficos frecuentes en textos de estudiantes de bachillerato.	2021-11-03 18:49:18.663465	2021-11-04 18:49:18.663465
317	55	87	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2021-11-10 08:22:16.99989	2021-11-11 08:22:16.99989
323	56	87	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-11-26 17:45:35.712128	2021-11-27 17:45:35.712128
345	60	23	Nueva entrega recibida para revisión: Manual de seguridad para laboratorios escolares de química.	2021-06-15 05:11:34.080312	2021-06-16 05:11:34.080312
346	60	22	Nueva entrega recibida para revisión: Manual de seguridad para laboratorios escolares de química.	2021-06-15 05:11:34.080312	2021-06-16 05:11:34.080312
347	60	2	Nueva entrega recibida para revisión: Manual de seguridad para laboratorios escolares de química.	2021-06-15 05:11:34.080312	2021-06-16 05:11:34.080312
540	92	22	Nueva entrega recibida para revisión: Diseño de la red de datos de un centro escolar.	2022-10-05 11:15:40.25802	2022-10-06 11:15:40.25802
541	92	2	Nueva entrega recibida para revisión: Diseño de la red de datos de un centro escolar.	2022-10-05 11:15:40.25802	2022-10-06 11:15:40.25802
348	60	71	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.	2021-06-18 20:46:28.448669	2021-06-19 20:46:28.448669
680	115	127	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-07-04 18:21:19.666724	2023-07-05 18:21:19.666724
671	114	23	Nueva entrega recibida para revisión: La figura de la mujer en la narrativa de Claudia Lars.	2023-06-07 22:53:00.596872	2023-06-08 22:53:00.596872
672	114	22	Nueva entrega recibida para revisión: La figura de la mujer en la narrativa de Claudia Lars.	2023-06-07 22:53:00.596872	2023-06-08 22:53:00.596872
673	114	2	Nueva entrega recibida para revisión: La figura de la mujer en la narrativa de Claudia Lars.	2023-06-07 22:53:00.596872	2023-06-08 22:53:00.596872
272	48	23	Nueva entrega recibida para revisión: Bloqueo subaracnoideo frente a anestesia general en cesáreas.	2021-03-21 15:15:48.374278	2021-03-22 15:15:48.374278
273	48	22	Nueva entrega recibida para revisión: Bloqueo subaracnoideo frente a anestesia general en cesáreas.	2021-03-21 15:15:48.374278	2021-03-22 15:15:48.374278
274	48	2	Nueva entrega recibida para revisión: Bloqueo subaracnoideo frente a anestesia general en cesáreas.	2021-03-21 15:15:48.374278	2021-03-22 15:15:48.374278
234	42	21	Nueva entrega recibida (versión corregida) para revisión: Indicadores logísticos para una ferretería.	2020-11-14 07:42:08.311423	2020-11-15 07:42:08.311423
235	42	3	Nueva entrega recibida (versión corregida) para revisión: Indicadores logísticos para una ferretería.	2020-11-14 07:42:08.311423	2020-11-15 07:42:08.311423
236	42	23	Nueva entrega recibida (versión corregida) para revisión: Indicadores logísticos para una ferretería.	2020-11-14 07:42:08.311423	2020-11-15 07:42:08.311423
237	42	22	Nueva entrega recibida (versión corregida) para revisión: Indicadores logísticos para una ferretería.	2020-11-14 07:42:08.311423	2020-11-15 07:42:08.311423
238	42	2	Nueva entrega recibida (versión corregida) para revisión: Indicadores logísticos para una ferretería.	2020-11-14 07:42:08.311423	2020-11-15 07:42:08.311423
239	42	76	Decisión del supervisor: Rechazada. Este trabajo ya fue registrado en el repositorio por otro integrante del grupo.	2020-11-17 11:08:33.645491	2020-11-18 11:08:33.645491
246	44	21	Nueva entrega recibida para revisión: Modelos tridimensionales de la célula para estudiantes de tercer ciclo.	2021-07-16 02:22:49.999608	2021-07-17 02:22:49.999608
247	44	3	Nueva entrega recibida para revisión: Modelos tridimensionales de la célula para estudiantes de tercer ciclo.	2021-07-16 02:22:49.999608	2021-07-17 02:22:49.999608
248	44	23	Nueva entrega recibida para revisión: Modelos tridimensionales de la célula para estudiantes de tercer ciclo.	2021-07-16 02:22:49.999608	2021-07-17 02:22:49.999608
249	44	22	Nueva entrega recibida para revisión: Modelos tridimensionales de la célula para estudiantes de tercer ciclo.	2021-07-16 02:22:49.999608	2021-07-17 02:22:49.999608
250	44	2	Nueva entrega recibida para revisión: Modelos tridimensionales de la célula para estudiantes de tercer ciclo.	2021-07-16 02:22:49.999608	2021-07-17 02:22:49.999608
240	43	21	Nueva entrega recibida para revisión: Control biológico de la mosca blanca en el cultivo de tomate.	2020-04-01 02:44:54.993699	2020-04-02 02:44:54.993699
241	43	3	Nueva entrega recibida para revisión: Control biológico de la mosca blanca en el cultivo de tomate.	2020-04-01 02:44:54.993699	2020-04-02 02:44:54.993699
242	43	23	Nueva entrega recibida para revisión: Control biológico de la mosca blanca en el cultivo de tomate.	2020-04-01 02:44:54.993699	2020-04-02 02:44:54.993699
243	43	22	Nueva entrega recibida para revisión: Control biológico de la mosca blanca en el cultivo de tomate.	2020-04-01 02:44:54.993699	2020-04-02 02:44:54.993699
244	43	2	Nueva entrega recibida para revisión: Control biológico de la mosca blanca en el cultivo de tomate.	2020-04-01 02:44:54.993699	2020-04-02 02:44:54.993699
258	46	21	Nueva entrega recibida para revisión: Efecto de la temperatura en el desarrollo de larvas de Aedes aegypti.	2021-04-22 20:58:42.622983	2021-04-23 20:58:42.622983
259	46	3	Nueva entrega recibida para revisión: Efecto de la temperatura en el desarrollo de larvas de Aedes aegypti.	2021-04-22 20:58:42.622983	2021-04-23 20:58:42.622983
260	46	23	Nueva entrega recibida para revisión: Efecto de la temperatura en el desarrollo de larvas de Aedes aegypti.	2021-04-22 20:58:42.622983	2021-04-23 20:58:42.622983
261	46	22	Nueva entrega recibida para revisión: Efecto de la temperatura en el desarrollo de larvas de Aedes aegypti.	2021-04-22 20:58:42.622983	2021-04-23 20:58:42.622983
262	46	2	Nueva entrega recibida para revisión: Efecto de la temperatura en el desarrollo de larvas de Aedes aegypti.	2021-04-22 20:58:42.622983	2021-04-23 20:58:42.622983
263	46	80	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.	2021-05-03 02:33:18.958741	2021-05-04 02:33:18.958741
252	45	21	Nueva entrega recibida para revisión: Propagación in vitro de orquídeas nativas en peligro de extinción.	2021-04-27 05:30:44.973427	2021-04-28 05:30:44.973427
253	45	3	Nueva entrega recibida para revisión: Propagación in vitro de orquídeas nativas en peligro de extinción.	2021-04-27 05:30:44.973427	2021-04-28 05:30:44.973427
254	45	23	Nueva entrega recibida para revisión: Propagación in vitro de orquídeas nativas en peligro de extinción.	2021-04-27 05:30:44.973427	2021-04-28 05:30:44.973427
255	45	22	Nueva entrega recibida para revisión: Propagación in vitro de orquídeas nativas en peligro de extinción.	2021-04-27 05:30:44.973427	2021-04-28 05:30:44.973427
256	45	2	Nueva entrega recibida para revisión: Propagación in vitro de orquídeas nativas en peligro de extinción.	2021-04-27 05:30:44.973427	2021-04-28 05:30:44.973427
257	45	79	Decisión del supervisor: Rechazada. Este trabajo ya fue registrado en el repositorio por otro integrante del grupo.	2021-05-02 12:06:24.2964	2021-05-03 12:06:24.2964
287	50	84	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-10-18 19:23:30.765341	2021-10-19 19:23:30.765341
264	47	21	Nueva entrega recibida para revisión: El despido de trabajadoras embarazadas en la legislación laboral.	2021-07-09 05:54:11.257637	2021-07-10 05:54:11.257637
265	47	3	Nueva entrega recibida para revisión: El despido de trabajadoras embarazadas en la legislación laboral.	2021-07-09 05:54:11.257637	2021-07-10 05:54:11.257637
266	47	23	Nueva entrega recibida para revisión: El despido de trabajadoras embarazadas en la legislación laboral.	2021-07-09 05:54:11.257637	2021-07-10 05:54:11.257637
267	47	22	Nueva entrega recibida para revisión: El despido de trabajadoras embarazadas en la legislación laboral.	2021-07-09 05:54:11.257637	2021-07-10 05:54:11.257637
268	47	2	Nueva entrega recibida para revisión: El despido de trabajadoras embarazadas en la legislación laboral.	2021-07-09 05:54:11.257637	2021-07-10 05:54:11.257637
281	49	83	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-05-07 01:59:49.712938	2021-05-08 01:59:49.712938
288	51	21	Nueva entrega recibida para revisión: Interacciones medicamentosas en pacientes polimedicados.	2021-08-20 09:58:24.059398	2021-08-21 09:58:24.059398
289	51	3	Nueva entrega recibida para revisión: Interacciones medicamentosas en pacientes polimedicados.	2021-08-20 09:58:24.059398	2021-08-21 09:58:24.059398
290	51	23	Nueva entrega recibida para revisión: Interacciones medicamentosas en pacientes polimedicados.	2021-08-20 09:58:24.059398	2021-08-21 09:58:24.059398
291	51	22	Nueva entrega recibida para revisión: Interacciones medicamentosas en pacientes polimedicados.	2021-08-20 09:58:24.059398	2021-08-21 09:58:24.059398
292	51	2	Nueva entrega recibida para revisión: Interacciones medicamentosas en pacientes polimedicados.	2021-08-20 09:58:24.059398	2021-08-21 09:58:24.059398
591	101	21	Nueva entrega recibida para revisión: Simulación del comportamiento caótico del péndulo doble.	2022-09-01 21:58:46.802575	2022-09-02 21:58:46.802575
670	114	3	Nueva entrega recibida para revisión: La figura de la mujer en la narrativa de Claudia Lars.	2023-06-07 22:53:00.596872	2023-06-08 22:53:00.596872
813	137	143	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-10-02 19:06:27.958034	2024-10-03 19:06:27.958034
814	138	21	Nueva entrega recibida para revisión: Programa de ejercicios para la lumbalgia en trabajadores de oficina.	2024-03-07 04:40:23.261771	2024-03-08 04:40:23.261771
305	53	86	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.	2021-08-31 05:05:55.716945	2021-09-01 05:05:55.716945
333	58	23	Nueva entrega recibida para revisión: Factores de riesgo de diabetes tipo 2 en unidades de salud rurales.	2021-05-26 15:29:24.329904	2021-05-27 15:29:24.329904
334	58	22	Nueva entrega recibida para revisión: Factores de riesgo de diabetes tipo 2 en unidades de salud rurales.	2021-05-26 15:29:24.329904	2021-05-27 15:29:24.329904
335	58	2	Nueva entrega recibida para revisión: Factores de riesgo de diabetes tipo 2 en unidades de salud rurales.	2021-05-26 15:29:24.329904	2021-05-27 15:29:24.329904
306	54	21	Nueva entrega recibida para revisión: Aplicación de escritorio para la gestión de bibliotecas escolares.	2021-12-07 03:31:15.034979	2021-12-08 03:31:15.034979
307	54	3	Nueva entrega recibida para revisión: Aplicación de escritorio para la gestión de bibliotecas escolares.	2021-12-07 03:31:15.034979	2021-12-08 03:31:15.034979
308	54	23	Nueva entrega recibida para revisión: Aplicación de escritorio para la gestión de bibliotecas escolares.	2021-12-07 03:31:15.034979	2021-12-08 03:31:15.034979
309	54	22	Nueva entrega recibida para revisión: Aplicación de escritorio para la gestión de bibliotecas escolares.	2021-12-07 03:31:15.034979	2021-12-08 03:31:15.034979
310	54	2	Nueva entrega recibida para revisión: Aplicación de escritorio para la gestión de bibliotecas escolares.	2021-12-07 03:31:15.034979	2021-12-08 03:31:15.034979
324	57	21	Nueva entrega recibida para revisión: Secuencia didáctica sobre la independencia centroamericana.	2021-02-20 09:30:33.333592	2021-02-21 09:30:33.333592
325	57	3	Nueva entrega recibida para revisión: Secuencia didáctica sobre la independencia centroamericana.	2021-02-20 09:30:33.333592	2021-02-21 09:30:33.333592
326	57	23	Nueva entrega recibida para revisión: Secuencia didáctica sobre la independencia centroamericana.	2021-02-20 09:30:33.333592	2021-02-21 09:30:33.333592
327	57	22	Nueva entrega recibida para revisión: Secuencia didáctica sobre la independencia centroamericana.	2021-02-20 09:30:33.333592	2021-02-21 09:30:33.333592
328	57	2	Nueva entrega recibida para revisión: Secuencia didáctica sobre la independencia centroamericana.	2021-02-20 09:30:33.333592	2021-02-21 09:30:33.333592
330	57	88	Tu publicación fue retirada del catálogo. Motivo: Se detectaron datos personales de participantes en el documento.	2021-05-16 00:01:50.997087	2021-05-17 00:01:50.997087
318	56	21	Nueva entrega recibida (versión corregida) para revisión: Errores ortográficos frecuentes en textos de estudiantes de bachillerato.	2021-11-20 03:33:03.361813	2021-11-21 03:33:03.361813
319	56	3	Nueva entrega recibida (versión corregida) para revisión: Errores ortográficos frecuentes en textos de estudiantes de bachillerato.	2021-11-20 03:33:03.361813	2021-11-21 03:33:03.361813
320	56	23	Nueva entrega recibida (versión corregida) para revisión: Errores ortográficos frecuentes en textos de estudiantes de bachillerato.	2021-11-20 03:33:03.361813	2021-11-21 03:33:03.361813
321	56	22	Nueva entrega recibida (versión corregida) para revisión: Errores ortográficos frecuentes en textos de estudiantes de bachillerato.	2021-11-20 03:33:03.361813	2021-11-21 03:33:03.361813
322	56	2	Nueva entrega recibida (versión corregida) para revisión: Errores ortográficos frecuentes en textos de estudiantes de bachillerato.	2021-11-20 03:33:03.361813	2021-11-21 03:33:03.361813
355	62	21	Nueva entrega recibida para revisión: Indicadores ácido-base elaborados con repollo morado.	2021-08-03 08:01:12.950139	2021-08-04 08:01:12.950139
356	62	3	Nueva entrega recibida para revisión: Indicadores ácido-base elaborados con repollo morado.	2021-08-03 08:01:12.950139	2021-08-04 08:01:12.950139
357	62	23	Nueva entrega recibida para revisión: Indicadores ácido-base elaborados con repollo morado.	2021-08-03 08:01:12.950139	2021-08-04 08:01:12.950139
358	62	22	Nueva entrega recibida para revisión: Indicadores ácido-base elaborados con repollo morado.	2021-08-03 08:01:12.950139	2021-08-04 08:01:12.950139
337	59	21	Nueva entrega recibida para revisión: Péndulo con sensor para medir la aceleración de la gravedad.	2021-07-02 01:20:51.381296	2021-07-03 01:20:51.381296
338	59	3	Nueva entrega recibida para revisión: Péndulo con sensor para medir la aceleración de la gravedad.	2021-07-02 01:20:51.381296	2021-07-03 01:20:51.381296
339	59	23	Nueva entrega recibida para revisión: Péndulo con sensor para medir la aceleración de la gravedad.	2021-07-02 01:20:51.381296	2021-07-03 01:20:51.381296
340	59	22	Nueva entrega recibida para revisión: Péndulo con sensor para medir la aceleración de la gravedad.	2021-07-02 01:20:51.381296	2021-07-03 01:20:51.381296
341	59	2	Nueva entrega recibida para revisión: Péndulo con sensor para medir la aceleración de la gravedad.	2021-07-02 01:20:51.381296	2021-07-03 01:20:51.381296
342	59	90	Decisión del supervisor: Rechazada. Este trabajo ya fue registrado en el repositorio por otro integrante del grupo.	2021-07-15 22:34:33.735424	2021-07-16 22:34:33.735424
359	62	2	Nueva entrega recibida para revisión: Indicadores ácido-base elaborados con repollo morado.	2021-08-03 08:01:12.950139	2021-08-04 08:01:12.950139
360	62	91	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2021-08-14 05:28:12.298679	2021-08-15 05:28:12.298679
592	101	3	Nueva entrega recibida para revisión: Simulación del comportamiento caótico del péndulo doble.	2022-09-01 21:58:46.802575	2022-09-02 21:58:46.802575
593	101	23	Nueva entrega recibida para revisión: Simulación del comportamiento caótico del péndulo doble.	2022-09-01 21:58:46.802575	2022-09-02 21:58:46.802575
361	63	21	Nueva entrega recibida (versión corregida) para revisión: Indicadores ácido-base elaborados con repollo morado.	2021-08-28 03:04:26.717088	2021-08-29 03:04:26.717088
362	63	3	Nueva entrega recibida (versión corregida) para revisión: Indicadores ácido-base elaborados con repollo morado.	2021-08-28 03:04:26.717088	2021-08-29 03:04:26.717088
363	63	23	Nueva entrega recibida (versión corregida) para revisión: Indicadores ácido-base elaborados con repollo morado.	2021-08-28 03:04:26.717088	2021-08-29 03:04:26.717088
594	101	22	Nueva entrega recibida para revisión: Simulación del comportamiento caótico del péndulo doble.	2022-09-01 21:58:46.802575	2022-09-02 21:58:46.802575
595	101	2	Nueva entrega recibida para revisión: Simulación del comportamiento caótico del péndulo doble.	2022-09-01 21:58:46.802575	2022-09-02 21:58:46.802575
683	116	23	Nueva entrega recibida para revisión: La cortesía verbal en inglés y en francés.	2023-09-19 03:27:19.377397	2023-09-20 03:27:19.377397
684	116	22	Nueva entrega recibida para revisión: La cortesía verbal en inglés y en francés.	2023-09-19 03:27:19.377397	2023-09-20 03:27:19.377397
685	116	2	Nueva entrega recibida para revisión: La cortesía verbal en inglés y en francés.	2023-09-19 03:27:19.377397	2023-09-20 03:27:19.377397
686	116	128	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2023-09-30 01:55:02.754982	2023-10-01 01:55:02.754982
608	103	116	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-09-24 02:55:49.760605	2023-09-25 02:55:49.760605
621	106	21	Nueva entrega recibida para revisión: Calidad del agua del río Grande de San Miguel mediante macroinvertebrados.	2023-10-19 11:21:08.348793	2023-10-20 11:21:08.348793
386	67	21	Nueva entrega recibida para revisión: Levantamiento arquitectónico de la catedral de San Miguel.	2021-05-19 09:19:27.156896	2021-05-20 09:19:27.156896
387	67	3	Nueva entrega recibida para revisión: Levantamiento arquitectónico de la catedral de San Miguel.	2021-05-19 09:19:27.156896	2021-05-20 09:19:27.156896
388	67	23	Nueva entrega recibida para revisión: Levantamiento arquitectónico de la catedral de San Miguel.	2021-05-19 09:19:27.156896	2021-05-20 09:19:27.156896
389	67	22	Nueva entrega recibida para revisión: Levantamiento arquitectónico de la catedral de San Miguel.	2021-05-19 09:19:27.156896	2021-05-20 09:19:27.156896
390	67	2	Nueva entrega recibida para revisión: Levantamiento arquitectónico de la catedral de San Miguel.	2021-05-19 09:19:27.156896	2021-05-20 09:19:27.156896
391	67	94	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2021-05-25 09:34:53.521556	2021-05-26 09:34:53.521556
392	68	21	Nueva entrega recibida (versión corregida) para revisión: Levantamiento arquitectónico de la catedral de San Miguel.	2021-06-03 00:34:01.923617	2021-06-04 00:34:01.923617
393	68	3	Nueva entrega recibida (versión corregida) para revisión: Levantamiento arquitectónico de la catedral de San Miguel.	2021-06-03 00:34:01.923617	2021-06-04 00:34:01.923617
394	68	23	Nueva entrega recibida (versión corregida) para revisión: Levantamiento arquitectónico de la catedral de San Miguel.	2021-06-03 00:34:01.923617	2021-06-04 00:34:01.923617
395	68	22	Nueva entrega recibida (versión corregida) para revisión: Levantamiento arquitectónico de la catedral de San Miguel.	2021-06-03 00:34:01.923617	2021-06-04 00:34:01.923617
615	105	21	Nueva entrega recibida para revisión: Coordinación de protecciones en una subestación de 46 kV.	2023-11-15 22:35:46.32854	2023-11-16 22:35:46.32854
616	105	3	Nueva entrega recibida para revisión: Coordinación de protecciones en una subestación de 46 kV.	2023-11-15 22:35:46.32854	2023-11-16 22:35:46.32854
617	105	23	Nueva entrega recibida para revisión: Coordinación de protecciones en una subestación de 46 kV.	2023-11-15 22:35:46.32854	2023-11-16 22:35:46.32854
618	105	22	Nueva entrega recibida para revisión: Coordinación de protecciones en una subestación de 46 kV.	2023-11-15 22:35:46.32854	2023-11-16 22:35:46.32854
619	105	2	Nueva entrega recibida para revisión: Coordinación de protecciones en una subestación de 46 kV.	2023-11-15 22:35:46.32854	2023-11-16 22:35:46.32854
724	123	3	Nueva entrega recibida (versión corregida) para revisión: Cadenas de Markov aplicadas al rendimiento estudiantil.	2023-06-22 06:19:26.748078	2023-06-23 06:19:26.748078
725	123	23	Nueva entrega recibida (versión corregida) para revisión: Cadenas de Markov aplicadas al rendimiento estudiantil.	2023-06-22 06:19:26.748078	2023-06-23 06:19:26.748078
373	65	21	Nueva entrega recibida para revisión: Modelos de ecuaciones diferenciales para la propagación del dengue.	2021-07-20 06:27:01.281505	2021-07-21 06:27:01.281505
374	65	3	Nueva entrega recibida para revisión: Modelos de ecuaciones diferenciales para la propagación del dengue.	2021-07-20 06:27:01.281505	2021-07-21 06:27:01.281505
375	65	23	Nueva entrega recibida para revisión: Modelos de ecuaciones diferenciales para la propagación del dengue.	2021-07-20 06:27:01.281505	2021-07-21 06:27:01.281505
367	64	21	Nueva entrega recibida para revisión: Planificación de una unidad sobre el enlace químico.	2021-08-19 03:43:45.810107	2021-08-20 03:43:45.810107
368	64	3	Nueva entrega recibida para revisión: Planificación de una unidad sobre el enlace químico.	2021-08-19 03:43:45.810107	2021-08-20 03:43:45.810107
369	64	23	Nueva entrega recibida para revisión: Planificación de una unidad sobre el enlace químico.	2021-08-19 03:43:45.810107	2021-08-20 03:43:45.810107
370	64	22	Nueva entrega recibida para revisión: Planificación de una unidad sobre el enlace químico.	2021-08-19 03:43:45.810107	2021-08-20 03:43:45.810107
371	64	2	Nueva entrega recibida para revisión: Planificación de una unidad sobre el enlace químico.	2021-08-19 03:43:45.810107	2021-08-20 03:43:45.810107
376	65	22	Nueva entrega recibida para revisión: Modelos de ecuaciones diferenciales para la propagación del dengue.	2021-07-20 06:27:01.281505	2021-07-21 06:27:01.281505
377	65	2	Nueva entrega recibida para revisión: Modelos de ecuaciones diferenciales para la propagación del dengue.	2021-07-20 06:27:01.281505	2021-07-21 06:27:01.281505
378	65	93	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2021-07-30 04:05:51.635299	2021-07-31 04:05:51.635299
379	66	21	Nueva entrega recibida (versión corregida) para revisión: Modelos de ecuaciones diferenciales para la propagación del dengue.	2021-08-10 06:45:29.089453	2021-08-11 06:45:29.089453
380	66	3	Nueva entrega recibida (versión corregida) para revisión: Modelos de ecuaciones diferenciales para la propagación del dengue.	2021-08-10 06:45:29.089453	2021-08-11 06:45:29.089453
597	102	21	Nueva entrega recibida para revisión: Diseño de un secador solar de granos para pequeños productores de San Miguel.	2023-08-24 14:18:30.729963	2023-08-25 14:18:30.729963
598	102	3	Nueva entrega recibida para revisión: Diseño de un secador solar de granos para pequeños productores de San Miguel.	2023-08-24 14:18:30.729963	2023-08-25 14:18:30.729963
599	102	23	Nueva entrega recibida para revisión: Diseño de un secador solar de granos para pequeños productores de San Miguel.	2023-08-24 14:18:30.729963	2023-08-25 14:18:30.729963
600	102	22	Nueva entrega recibida para revisión: Diseño de un secador solar de granos para pequeños productores de San Miguel.	2023-08-24 14:18:30.729963	2023-08-25 14:18:30.729963
726	123	22	Nueva entrega recibida (versión corregida) para revisión: Cadenas de Markov aplicadas al rendimiento estudiantil.	2023-06-22 06:19:26.748078	2023-06-23 06:19:26.748078
727	123	2	Nueva entrega recibida (versión corregida) para revisión: Cadenas de Markov aplicadas al rendimiento estudiantil.	2023-06-22 06:19:26.748078	2023-06-23 06:19:26.748078
728	123	132	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-06-27 04:13:57.132192	2023-06-28 04:13:57.132192
681	116	21	Nueva entrega recibida para revisión: La cortesía verbal en inglés y en francés.	2023-09-19 03:27:19.377397	2023-09-20 03:27:19.377397
682	116	3	Nueva entrega recibida para revisión: La cortesía verbal en inglés y en francés.	2023-09-19 03:27:19.377397	2023-09-20 03:27:19.377397
729	124	21	Nueva entrega recibida para revisión: Revitalización del centro histórico de San Miguel.	2023-07-09 00:58:30.832042	2023-07-10 00:58:30.832042
730	124	3	Nueva entrega recibida para revisión: Revitalización del centro histórico de San Miguel.	2023-07-09 00:58:30.832042	2023-07-10 00:58:30.832042
731	124	23	Nueva entrega recibida para revisión: Revitalización del centro histórico de San Miguel.	2023-07-09 00:58:30.832042	2023-07-10 00:58:30.832042
732	124	22	Nueva entrega recibida para revisión: Revitalización del centro histórico de San Miguel.	2023-07-09 00:58:30.832042	2023-07-10 00:58:30.832042
733	124	2	Nueva entrega recibida para revisión: Revitalización del centro histórico de San Miguel.	2023-07-09 00:58:30.832042	2023-07-10 00:58:30.832042
734	124	133	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2023-07-20 01:15:13.235389	2023-07-21 01:15:13.235389
741	126	21	Nueva entrega recibida para revisión: Sistema de costos por órdenes de producción para una carpintería.	2023-03-08 10:19:13.410007	2023-03-09 10:19:13.410007
735	125	21	Nueva entrega recibida (versión corregida) para revisión: Revitalización del centro histórico de San Miguel.	2023-07-29 15:37:27.666543	2023-07-30 15:37:27.666543
736	125	3	Nueva entrega recibida (versión corregida) para revisión: Revitalización del centro histórico de San Miguel.	2023-07-29 15:37:27.666543	2023-07-30 15:37:27.666543
737	125	23	Nueva entrega recibida (versión corregida) para revisión: Revitalización del centro histórico de San Miguel.	2023-07-29 15:37:27.666543	2023-07-30 15:37:27.666543
738	125	22	Nueva entrega recibida (versión corregida) para revisión: Revitalización del centro histórico de San Miguel.	2023-07-29 15:37:27.666543	2023-07-30 15:37:27.666543
383	66	2	Nueva entrega recibida (versión corregida) para revisión: Modelos de ecuaciones diferenciales para la propagación del dengue.	2021-08-10 06:45:29.089453	2021-08-11 06:45:29.089453
385	66	93	Tu publicación fue retirada del catálogo. Motivo: Se detectaron datos personales de participantes en el documento.	2021-09-30 10:01:52.82362	2021-10-01 10:01:52.82362
396	68	2	Nueva entrega recibida (versión corregida) para revisión: Levantamiento arquitectónico de la catedral de San Miguel.	2021-06-03 00:34:01.923617	2021-06-04 00:34:01.923617
397	68	94	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-06-14 05:32:20.297828	2021-06-15 05:32:20.297828
403	69	58	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-09-17 06:27:50.366463	2021-09-18 06:27:50.366463
452	78	21	Nueva entrega recibida para revisión: Calidad de energía en la red de distribución de un centro comercial.	2022-03-27 13:57:47.773411	2022-03-28 13:57:47.773411
453	78	3	Nueva entrega recibida para revisión: Calidad de energía en la red de distribución de un centro comercial.	2022-03-27 13:57:47.773411	2022-03-28 13:57:47.773411
454	78	23	Nueva entrega recibida para revisión: Calidad de energía en la red de distribución de un centro comercial.	2022-03-27 13:57:47.773411	2022-03-28 13:57:47.773411
455	78	22	Nueva entrega recibida para revisión: Calidad de energía en la red de distribución de un centro comercial.	2022-03-27 13:57:47.773411	2022-03-28 13:57:47.773411
456	78	2	Nueva entrega recibida para revisión: Calidad de energía en la red de distribución de un centro comercial.	2022-03-27 13:57:47.773411	2022-03-28 13:57:47.773411
440	76	21	Nueva entrega recibida para revisión: Determinación de la constante de Planck con diodos LED.	2021-10-09 10:50:28.96663	2021-10-10 10:50:28.96663
441	76	3	Nueva entrega recibida para revisión: Determinación de la constante de Planck con diodos LED.	2021-10-09 10:50:28.96663	2021-10-10 10:50:28.96663
442	76	23	Nueva entrega recibida para revisión: Determinación de la constante de Planck con diodos LED.	2021-10-09 10:50:28.96663	2021-10-10 10:50:28.96663
443	76	22	Nueva entrega recibida para revisión: Determinación de la constante de Planck con diodos LED.	2021-10-09 10:50:28.96663	2021-10-10 10:50:28.96663
404	70	21	Nueva entrega recibida para revisión: Violencia de género en el ámbito universitario.	2021-08-28 21:15:15.038777	2021-08-29 21:15:15.038777
405	70	3	Nueva entrega recibida para revisión: Violencia de género en el ámbito universitario.	2021-08-28 21:15:15.038777	2021-08-29 21:15:15.038777
406	70	23	Nueva entrega recibida para revisión: Violencia de género en el ámbito universitario.	2021-08-28 21:15:15.038777	2021-08-29 21:15:15.038777
407	70	22	Nueva entrega recibida para revisión: Violencia de género en el ámbito universitario.	2021-08-28 21:15:15.038777	2021-08-29 21:15:15.038777
408	70	2	Nueva entrega recibida para revisión: Violencia de género en el ámbito universitario.	2021-08-28 21:15:15.038777	2021-08-29 21:15:15.038777
415	71	96	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-08-31 13:16:03.520699	2021-09-01 13:16:03.520699
444	76	2	Nueva entrega recibida para revisión: Determinación de la constante de Planck con diodos LED.	2021-10-09 10:50:28.96663	2021-10-10 10:50:28.96663
421	72	97	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-06-04 06:02:05.565149	2021-06-05 06:02:05.565149
445	76	100	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.	2021-10-21 07:16:42.345109	2021-10-22 07:16:42.345109
422	73	21	Nueva entrega recibida para revisión: Rincones de aprendizaje con materiales del entorno.	2021-06-04 16:20:32.306807	2021-06-05 16:20:32.306807
423	73	3	Nueva entrega recibida para revisión: Rincones de aprendizaje con materiales del entorno.	2021-06-04 16:20:32.306807	2021-06-05 16:20:32.306807
424	73	23	Nueva entrega recibida para revisión: Rincones de aprendizaje con materiales del entorno.	2021-06-04 16:20:32.306807	2021-06-05 16:20:32.306807
425	73	22	Nueva entrega recibida para revisión: Rincones de aprendizaje con materiales del entorno.	2021-06-04 16:20:32.306807	2021-06-05 16:20:32.306807
426	73	2	Nueva entrega recibida para revisión: Rincones de aprendizaje con materiales del entorno.	2021-06-04 16:20:32.306807	2021-06-05 16:20:32.306807
427	73	98	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2021-06-08 15:56:42.672706	2021-06-09 15:56:42.672706
433	74	98	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-06-30 22:59:10.484463	2021-07-01 22:59:10.484463
457	78	61	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2022-04-07 18:13:21.139507	2022-04-08 18:13:21.139507
470	81	21	Nueva entrega recibida para revisión: Cumplimiento de la cuota alimenticia en los juzgados de familia de San Miguel.	2022-03-16 22:56:04.746277	2022-03-17 22:56:04.746277
469	80	102	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-04-10 17:25:05.033516	2022-04-11 17:25:05.033516
446	77	21	Nueva entrega recibida para revisión: Conocimientos sobre educación ambiental en estudiantes de bachillerato de Usulután.	2022-06-03 06:31:28.675793	2022-06-04 06:31:28.675793
447	77	3	Nueva entrega recibida para revisión: Conocimientos sobre educación ambiental en estudiantes de bachillerato de Usulután.	2022-06-03 06:31:28.675793	2022-06-04 06:31:28.675793
448	77	23	Nueva entrega recibida para revisión: Conocimientos sobre educación ambiental en estudiantes de bachillerato de Usulután.	2022-06-03 06:31:28.675793	2022-06-04 06:31:28.675793
449	77	22	Nueva entrega recibida para revisión: Conocimientos sobre educación ambiental en estudiantes de bachillerato de Usulután.	2022-06-03 06:31:28.675793	2022-06-04 06:31:28.675793
450	77	2	Nueva entrega recibida para revisión: Conocimientos sobre educación ambiental en estudiantes de bachillerato de Usulután.	2022-06-03 06:31:28.675793	2022-06-04 06:31:28.675793
471	81	3	Nueva entrega recibida para revisión: Cumplimiento de la cuota alimenticia en los juzgados de familia de San Miguel.	2022-03-16 22:56:04.746277	2022-03-17 22:56:04.746277
472	81	23	Nueva entrega recibida para revisión: Cumplimiento de la cuota alimenticia en los juzgados de familia de San Miguel.	2022-03-16 22:56:04.746277	2022-03-17 22:56:04.746277
473	81	22	Nueva entrega recibida para revisión: Cumplimiento de la cuota alimenticia en los juzgados de familia de San Miguel.	2022-03-16 22:56:04.746277	2022-03-17 22:56:04.746277
622	106	3	Nueva entrega recibida para revisión: Calidad del agua del río Grande de San Miguel mediante macroinvertebrados.	2023-10-19 11:21:08.348793	2023-10-20 11:21:08.348793
623	106	23	Nueva entrega recibida para revisión: Calidad del agua del río Grande de San Miguel mediante macroinvertebrados.	2023-10-19 11:21:08.348793	2023-10-20 11:21:08.348793
624	106	22	Nueva entrega recibida para revisión: Calidad del agua del río Grande de San Miguel mediante macroinvertebrados.	2023-10-19 11:21:08.348793	2023-10-20 11:21:08.348793
627	107	21	Nueva entrega recibida para revisión: Protección de datos personales frente a las nuevas tecnologías.	2023-04-01 09:32:08.323151	2023-04-02 09:32:08.323151
435	75	3	Nueva entrega recibida para revisión: Deshidratado de mango como alternativa de agroindustria rural.	2021-10-15 14:18:18.204223	2021-10-16 14:18:18.204223
436	75	23	Nueva entrega recibida para revisión: Deshidratado de mango como alternativa de agroindustria rural.	2021-10-15 14:18:18.204223	2021-10-16 14:18:18.204223
437	75	22	Nueva entrega recibida para revisión: Deshidratado de mango como alternativa de agroindustria rural.	2021-10-15 14:18:18.204223	2021-10-16 14:18:18.204223
410	71	21	Nueva entrega recibida para revisión: Ansiedad matemática en estudiantes de séptimo grado.	2021-08-26 07:39:03.13098	2021-08-27 07:39:03.13098
411	71	3	Nueva entrega recibida para revisión: Ansiedad matemática en estudiantes de séptimo grado.	2021-08-26 07:39:03.13098	2021-08-27 07:39:03.13098
412	71	23	Nueva entrega recibida para revisión: Ansiedad matemática en estudiantes de séptimo grado.	2021-08-26 07:39:03.13098	2021-08-27 07:39:03.13098
413	71	22	Nueva entrega recibida para revisión: Ansiedad matemática en estudiantes de séptimo grado.	2021-08-26 07:39:03.13098	2021-08-27 07:39:03.13098
414	71	2	Nueva entrega recibida para revisión: Ansiedad matemática en estudiantes de séptimo grado.	2021-08-26 07:39:03.13098	2021-08-27 07:39:03.13098
698	118	129	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-07-01 21:34:51.639472	2023-07-02 21:34:51.639472
428	74	21	Nueva entrega recibida (versión corregida) para revisión: Rincones de aprendizaje con materiales del entorno.	2021-06-16 05:55:48.062506	2021-06-17 05:55:48.062506
429	74	3	Nueva entrega recibida (versión corregida) para revisión: Rincones de aprendizaje con materiales del entorno.	2021-06-16 05:55:48.062506	2021-06-17 05:55:48.062506
430	74	23	Nueva entrega recibida (versión corregida) para revisión: Rincones de aprendizaje con materiales del entorno.	2021-06-16 05:55:48.062506	2021-06-17 05:55:48.062506
431	74	22	Nueva entrega recibida (versión corregida) para revisión: Rincones de aprendizaje con materiales del entorno.	2021-06-16 05:55:48.062506	2021-06-17 05:55:48.062506
432	74	2	Nueva entrega recibida (versión corregida) para revisión: Rincones de aprendizaje con materiales del entorno.	2021-06-16 05:55:48.062506	2021-06-17 05:55:48.062506
687	117	21	Nueva entrega recibida (versión corregida) para revisión: La cortesía verbal en inglés y en francés.	2023-10-12 18:43:53.153139	2023-10-13 18:43:53.153139
688	117	3	Nueva entrega recibida (versión corregida) para revisión: La cortesía verbal en inglés y en francés.	2023-10-12 18:43:53.153139	2023-10-13 18:43:53.153139
689	117	23	Nueva entrega recibida (versión corregida) para revisión: La cortesía verbal en inglés y en francés.	2023-10-12 18:43:53.153139	2023-10-13 18:43:53.153139
690	117	22	Nueva entrega recibida (versión corregida) para revisión: La cortesía verbal en inglés y en francés.	2023-10-12 18:43:53.153139	2023-10-13 18:43:53.153139
691	117	2	Nueva entrega recibida (versión corregida) para revisión: La cortesía verbal en inglés y en francés.	2023-10-12 18:43:53.153139	2023-10-13 18:43:53.153139
699	119	21	Nueva entrega recibida para revisión: Estudio de tiempos en la línea de empaque de una procesadora de lácteos.	2023-09-26 14:21:51.962013	2023-09-27 14:21:51.962013
700	119	3	Nueva entrega recibida para revisión: Estudio de tiempos en la línea de empaque de una procesadora de lácteos.	2023-09-26 14:21:51.962013	2023-09-27 14:21:51.962013
701	119	23	Nueva entrega recibida para revisión: Estudio de tiempos en la línea de empaque de una procesadora de lácteos.	2023-09-26 14:21:51.962013	2023-09-27 14:21:51.962013
702	119	22	Nueva entrega recibida para revisión: Estudio de tiempos en la línea de empaque de una procesadora de lácteos.	2023-09-26 14:21:51.962013	2023-09-27 14:21:51.962013
703	119	2	Nueva entrega recibida para revisión: Estudio de tiempos en la línea de empaque de una procesadora de lácteos.	2023-09-26 14:21:51.962013	2023-09-27 14:21:51.962013
710	120	130	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-10-13 21:16:21.066898	2023-10-14 21:16:21.066898
463	79	61	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-04-23 02:39:55.902585	2022-04-24 02:39:55.902585
458	79	21	Nueva entrega recibida (versión corregida) para revisión: Calidad de energía en la red de distribución de un centro comercial.	2022-04-13 09:08:19.521473	2022-04-14 09:08:19.521473
459	79	3	Nueva entrega recibida (versión corregida) para revisión: Calidad de energía en la red de distribución de un centro comercial.	2022-04-13 09:08:19.521473	2022-04-14 09:08:19.521473
460	79	23	Nueva entrega recibida (versión corregida) para revisión: Calidad de energía en la red de distribución de un centro comercial.	2022-04-13 09:08:19.521473	2022-04-14 09:08:19.521473
461	79	22	Nueva entrega recibida (versión corregida) para revisión: Calidad de energía en la red de distribución de un centro comercial.	2022-04-13 09:08:19.521473	2022-04-14 09:08:19.521473
462	79	2	Nueva entrega recibida (versión corregida) para revisión: Calidad de energía en la red de distribución de un centro comercial.	2022-04-13 09:08:19.521473	2022-04-14 09:08:19.521473
636	108	22	Nueva entrega recibida para revisión: Uso de canciones para mejorar la pronunciación del inglés en séptimo grado.	2023-12-01 09:11:02.264778	2023-12-02 09:11:02.264778
637	108	2	Nueva entrega recibida para revisión: Uso de canciones para mejorar la pronunciación del inglés en séptimo grado.	2023-12-01 09:11:02.264778	2023-12-02 09:11:02.264778
476	82	21	Nueva entrega recibida (versión corregida) para revisión: Cumplimiento de la cuota alimenticia en los juzgados de familia de San Miguel.	2022-04-04 11:47:40.4974	2022-04-05 11:47:40.4974
477	82	3	Nueva entrega recibida (versión corregida) para revisión: Cumplimiento de la cuota alimenticia en los juzgados de familia de San Miguel.	2022-04-04 11:47:40.4974	2022-04-05 11:47:40.4974
478	82	23	Nueva entrega recibida (versión corregida) para revisión: Cumplimiento de la cuota alimenticia en los juzgados de familia de San Miguel.	2022-04-04 11:47:40.4974	2022-04-05 11:47:40.4974
479	82	22	Nueva entrega recibida (versión corregida) para revisión: Cumplimiento de la cuota alimenticia en los juzgados de familia de San Miguel.	2022-04-04 11:47:40.4974	2022-04-05 11:47:40.4974
480	82	2	Nueva entrega recibida (versión corregida) para revisión: Cumplimiento de la cuota alimenticia en los juzgados de familia de San Miguel.	2022-04-04 11:47:40.4974	2022-04-05 11:47:40.4974
464	80	21	Nueva entrega recibida para revisión: La prueba pericial en el proceso penal salvadoreño.	2022-04-02 19:42:56.605094	2022-04-03 19:42:56.605094
465	80	3	Nueva entrega recibida para revisión: La prueba pericial en el proceso penal salvadoreño.	2022-04-02 19:42:56.605094	2022-04-03 19:42:56.605094
466	80	23	Nueva entrega recibida para revisión: La prueba pericial en el proceso penal salvadoreño.	2022-04-02 19:42:56.605094	2022-04-03 19:42:56.605094
467	80	22	Nueva entrega recibida para revisión: La prueba pericial en el proceso penal salvadoreño.	2022-04-02 19:42:56.605094	2022-04-03 19:42:56.605094
468	80	2	Nueva entrega recibida para revisión: La prueba pericial en el proceso penal salvadoreño.	2022-04-02 19:42:56.605094	2022-04-03 19:42:56.605094
656	111	124	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-08-05 22:09:28.735368	2023-08-06 22:09:28.735368
628	107	3	Nueva entrega recibida para revisión: Protección de datos personales frente a las nuevas tecnologías.	2023-04-01 09:32:08.323151	2023-04-02 09:32:08.323151
629	107	23	Nueva entrega recibida para revisión: Protección de datos personales frente a las nuevas tecnologías.	2023-04-01 09:32:08.323151	2023-04-02 09:32:08.323151
630	107	22	Nueva entrega recibida para revisión: Protección de datos personales frente a las nuevas tecnologías.	2023-04-01 09:32:08.323151	2023-04-02 09:32:08.323151
631	107	2	Nueva entrega recibida para revisión: Protección de datos personales frente a las nuevas tecnologías.	2023-04-01 09:32:08.323151	2023-04-02 09:32:08.323151
482	83	21	Nueva entrega recibida para revisión: La sociedad por acciones simplificada en el Código de Comercio.	2022-07-05 17:46:50.546879	2022-07-06 17:46:50.546879
483	83	3	Nueva entrega recibida para revisión: La sociedad por acciones simplificada en el Código de Comercio.	2022-07-05 17:46:50.546879	2022-07-06 17:46:50.546879
484	83	23	Nueva entrega recibida para revisión: La sociedad por acciones simplificada en el Código de Comercio.	2022-07-05 17:46:50.546879	2022-07-06 17:46:50.546879
485	83	22	Nueva entrega recibida para revisión: La sociedad por acciones simplificada en el Código de Comercio.	2022-07-05 17:46:50.546879	2022-07-06 17:46:50.546879
486	83	2	Nueva entrega recibida para revisión: La sociedad por acciones simplificada en el Código de Comercio.	2022-07-05 17:46:50.546879	2022-07-06 17:46:50.546879
487	83	81	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2022-07-11 15:12:26.899645	2022-07-12 15:12:26.899645
493	84	81	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-07-25 00:58:03.656835	2022-07-26 00:58:03.656835
644	109	122	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.	2023-08-11 21:09:09.492383	2023-08-12 21:09:09.492383
645	110	21	Nueva entrega recibida para revisión: Actividad antibacteriana del extracto de hojas de guayaba.	2023-09-29 22:08:49.790761	2023-09-30 22:08:49.790761
646	110	3	Nueva entrega recibida para revisión: Actividad antibacteriana del extracto de hojas de guayaba.	2023-09-29 22:08:49.790761	2023-09-30 22:08:49.790761
647	110	23	Nueva entrega recibida para revisión: Actividad antibacteriana del extracto de hojas de guayaba.	2023-09-29 22:08:49.790761	2023-09-30 22:08:49.790761
648	110	22	Nueva entrega recibida para revisión: Actividad antibacteriana del extracto de hojas de guayaba.	2023-09-29 22:08:49.790761	2023-09-30 22:08:49.790761
649	110	2	Nueva entrega recibida para revisión: Actividad antibacteriana del extracto de hojas de guayaba.	2023-09-29 22:08:49.790761	2023-09-30 22:08:49.790761
663	113	21	Nueva entrega recibida (versión corregida) para revisión: Red de sensores para monitorear la humedad del suelo en cultivos.	2023-05-22 17:47:09.994881	2023-05-23 17:47:09.994881
664	113	3	Nueva entrega recibida (versión corregida) para revisión: Red de sensores para monitorear la humedad del suelo en cultivos.	2023-05-22 17:47:09.994881	2023-05-23 17:47:09.994881
665	113	23	Nueva entrega recibida (versión corregida) para revisión: Red de sensores para monitorear la humedad del suelo en cultivos.	2023-05-22 17:47:09.994881	2023-05-23 17:47:09.994881
474	81	2	Nueva entrega recibida para revisión: Cumplimiento de la cuota alimenticia en los juzgados de familia de San Miguel.	2022-03-16 22:56:04.746277	2022-03-17 22:56:04.746277
475	81	103	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2022-03-21 04:42:52.100381	2022-03-22 04:42:52.100381
481	82	103	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-04-17 08:27:09.860831	2022-04-18 08:27:09.860831
657	112	21	Nueva entrega recibida para revisión: Red de sensores para monitorear la humedad del suelo en cultivos.	2023-05-13 07:12:39.34142	2023-05-14 07:12:39.34142
658	112	3	Nueva entrega recibida para revisión: Red de sensores para monitorear la humedad del suelo en cultivos.	2023-05-13 07:12:39.34142	2023-05-14 07:12:39.34142
642	109	22	Nueva entrega recibida para revisión: Material didáctico de inglés para estudiantes con baja visión.	2023-07-29 09:56:34.169288	2023-07-30 09:56:34.169288
643	109	2	Nueva entrega recibida para revisión: Material didáctico de inglés para estudiantes con baja visión.	2023-07-29 09:56:34.169288	2023-07-30 09:56:34.169288
650	110	123	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-10-05 10:39:30.099858	2023-10-06 10:39:30.099858
503	86	23	Nueva entrega recibida para revisión: Evaluación postural en escolares que usan mochila.	2022-03-27 03:21:48.365765	2022-03-28 03:21:48.365765
488	84	21	Nueva entrega recibida (versión corregida) para revisión: La sociedad por acciones simplificada en el Código de Comercio.	2022-07-15 05:14:43.276322	2022-07-16 05:14:43.276322
489	84	3	Nueva entrega recibida (versión corregida) para revisión: La sociedad por acciones simplificada en el Código de Comercio.	2022-07-15 05:14:43.276322	2022-07-16 05:14:43.276322
490	84	23	Nueva entrega recibida (versión corregida) para revisión: La sociedad por acciones simplificada en el Código de Comercio.	2022-07-15 05:14:43.276322	2022-07-16 05:14:43.276322
491	84	22	Nueva entrega recibida (versión corregida) para revisión: La sociedad por acciones simplificada en el Código de Comercio.	2022-07-15 05:14:43.276322	2022-07-16 05:14:43.276322
492	84	2	Nueva entrega recibida (versión corregida) para revisión: La sociedad por acciones simplificada en el Código de Comercio.	2022-07-15 05:14:43.276322	2022-07-16 05:14:43.276322
499	85	104	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-05-17 02:43:42.69196	2022-05-18 02:43:42.69196
506	86	105	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-04-03 17:20:43.764764	2022-04-04 17:20:43.764764
659	112	23	Nueva entrega recibida para revisión: Red de sensores para monitorear la humedad del suelo en cultivos.	2023-05-13 07:12:39.34142	2023-05-14 07:12:39.34142
660	112	22	Nueva entrega recibida para revisión: Red de sensores para monitorear la humedad del suelo en cultivos.	2023-05-13 07:12:39.34142	2023-05-14 07:12:39.34142
513	88	21	Nueva entrega recibida para revisión: Extracción de pectina de la cáscara de naranja.	2022-07-24 14:04:28.10801	2022-07-25 14:04:28.10801
514	88	3	Nueva entrega recibida para revisión: Extracción de pectina de la cáscara de naranja.	2022-07-24 14:04:28.10801	2022-07-25 14:04:28.10801
515	88	23	Nueva entrega recibida para revisión: Extracción de pectina de la cáscara de naranja.	2022-07-24 14:04:28.10801	2022-07-25 14:04:28.10801
516	88	22	Nueva entrega recibida para revisión: Extracción de pectina de la cáscara de naranja.	2022-07-24 14:04:28.10801	2022-07-25 14:04:28.10801
517	88	2	Nueva entrega recibida para revisión: Extracción de pectina de la cáscara de naranja.	2022-07-24 14:04:28.10801	2022-07-25 14:04:28.10801
661	112	2	Nueva entrega recibida para revisión: Red de sensores para monitorear la humedad del suelo en cultivos.	2023-05-13 07:12:39.34142	2023-05-14 07:12:39.34142
662	112	125	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2023-05-16 09:01:44.663548	2023-05-17 09:01:44.663548
674	114	126	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.	2023-06-17 05:28:17.939204	2023-06-18 05:28:17.939204
651	111	21	Nueva entrega recibida para revisión: Sistema web para la gestión de citas de la clínica universitaria.	2023-08-03 01:36:01.399225	2023-08-04 01:36:01.399225
652	111	3	Nueva entrega recibida para revisión: Sistema web para la gestión de citas de la clínica universitaria.	2023-08-03 01:36:01.399225	2023-08-04 01:36:01.399225
653	111	23	Nueva entrega recibida para revisión: Sistema web para la gestión de citas de la clínica universitaria.	2023-08-03 01:36:01.399225	2023-08-04 01:36:01.399225
654	111	22	Nueva entrega recibida para revisión: Sistema web para la gestión de citas de la clínica universitaria.	2023-08-03 01:36:01.399225	2023-08-04 01:36:01.399225
655	111	2	Nueva entrega recibida para revisión: Sistema web para la gestión de citas de la clínica universitaria.	2023-08-03 01:36:01.399225	2023-08-04 01:36:01.399225
692	117	128	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-10-26 18:44:05.544396	2023-10-27 18:44:05.544396
675	115	21	Nueva entrega recibida para revisión: Plataformas virtuales en el aprendizaje del francés.	2023-06-30 13:43:49.281541	2023-07-01 13:43:49.281541
676	115	3	Nueva entrega recibida para revisión: Plataformas virtuales en el aprendizaje del francés.	2023-06-30 13:43:49.281541	2023-07-01 13:43:49.281541
677	115	23	Nueva entrega recibida para revisión: Plataformas virtuales en el aprendizaje del francés.	2023-06-30 13:43:49.281541	2023-07-01 13:43:49.281541
678	115	22	Nueva entrega recibida para revisión: Plataformas virtuales en el aprendizaje del francés.	2023-06-30 13:43:49.281541	2023-07-01 13:43:49.281541
679	115	2	Nueva entrega recibida para revisión: Plataformas virtuales en el aprendizaje del francés.	2023-06-30 13:43:49.281541	2023-07-01 13:43:49.281541
693	118	21	Nueva entrega recibida para revisión: Uso de la escala de Glasgow en la emergencia de un hospital nacional.	2023-06-19 22:20:05.257719	2023-06-20 22:20:05.257719
694	118	3	Nueva entrega recibida para revisión: Uso de la escala de Glasgow en la emergencia de un hospital nacional.	2023-06-19 22:20:05.257719	2023-06-20 22:20:05.257719
695	118	23	Nueva entrega recibida para revisión: Uso de la escala de Glasgow en la emergencia de un hospital nacional.	2023-06-19 22:20:05.257719	2023-06-20 22:20:05.257719
696	118	22	Nueva entrega recibida para revisión: Uso de la escala de Glasgow en la emergencia de un hospital nacional.	2023-06-19 22:20:05.257719	2023-06-20 22:20:05.257719
697	118	2	Nueva entrega recibida para revisión: Uso de la escala de Glasgow en la emergencia de un hospital nacional.	2023-06-19 22:20:05.257719	2023-06-20 22:20:05.257719
716	121	131	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-06-14 01:31:20.748969	2023-06-15 01:31:20.748969
705	120	21	Nueva entrega recibida (versión corregida) para revisión: Estudio de tiempos en la línea de empaque de una procesadora de lácteos.	2023-10-10 07:08:27.696448	2023-10-11 07:08:27.696448
494	85	21	Nueva entrega recibida para revisión: Unidad didáctica de inglés basada en tareas.	2022-05-11 22:31:26.324044	2022-05-12 22:31:26.324044
495	85	3	Nueva entrega recibida para revisión: Unidad didáctica de inglés basada en tareas.	2022-05-11 22:31:26.324044	2022-05-12 22:31:26.324044
496	85	23	Nueva entrega recibida para revisión: Unidad didáctica de inglés basada en tareas.	2022-05-11 22:31:26.324044	2022-05-12 22:31:26.324044
497	85	22	Nueva entrega recibida para revisión: Unidad didáctica de inglés basada en tareas.	2022-05-11 22:31:26.324044	2022-05-12 22:31:26.324044
498	85	2	Nueva entrega recibida para revisión: Unidad didáctica de inglés basada en tareas.	2022-05-11 22:31:26.324044	2022-05-12 22:31:26.324044
500	85	104	Tu publicación fue retirada del catálogo. Motivo: Se detectaron datos personales de participantes en el documento.	2022-09-12 13:18:48.019455	2022-09-13 13:18:48.019455
706	120	3	Nueva entrega recibida (versión corregida) para revisión: Estudio de tiempos en la línea de empaque de una procesadora de lácteos.	2023-10-10 07:08:27.696448	2023-10-11 07:08:27.696448
707	120	23	Nueva entrega recibida (versión corregida) para revisión: Estudio de tiempos en la línea de empaque de una procesadora de lácteos.	2023-10-10 07:08:27.696448	2023-10-11 07:08:27.696448
708	120	22	Nueva entrega recibida (versión corregida) para revisión: Estudio de tiempos en la línea de empaque de una procesadora de lácteos.	2023-10-10 07:08:27.696448	2023-10-11 07:08:27.696448
709	120	2	Nueva entrega recibida (versión corregida) para revisión: Estudio de tiempos en la línea de empaque de una procesadora de lácteos.	2023-10-10 07:08:27.696448	2023-10-11 07:08:27.696448
711	121	21	Nueva entrega recibida para revisión: Comportamiento del consumidor de comercio electrónico en San Miguel.	2023-05-30 18:00:32.390653	2023-05-31 18:00:32.390653
712	121	3	Nueva entrega recibida para revisión: Comportamiento del consumidor de comercio electrónico en San Miguel.	2023-05-30 18:00:32.390653	2023-05-31 18:00:32.390653
713	121	23	Nueva entrega recibida para revisión: Comportamiento del consumidor de comercio electrónico en San Miguel.	2023-05-30 18:00:32.390653	2023-05-31 18:00:32.390653
501	86	21	Nueva entrega recibida para revisión: Evaluación postural en escolares que usan mochila.	2022-03-27 03:21:48.365765	2022-03-28 03:21:48.365765
502	86	3	Nueva entrega recibida para revisión: Evaluación postural en escolares que usan mochila.	2022-03-27 03:21:48.365765	2022-03-28 03:21:48.365765
504	86	22	Nueva entrega recibida para revisión: Evaluación postural en escolares que usan mochila.	2022-03-27 03:21:48.365765	2022-03-28 03:21:48.365765
505	86	2	Nueva entrega recibida para revisión: Evaluación postural en escolares que usan mochila.	2022-03-27 03:21:48.365765	2022-03-28 03:21:48.365765
512	87	106	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-12-10 23:31:28.801334	2022-12-11 23:31:28.801334
518	88	107	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-08-08 01:36:18.463179	2022-08-09 01:36:18.463179
742	126	3	Nueva entrega recibida para revisión: Sistema de costos por órdenes de producción para una carpintería.	2023-03-08 10:19:13.410007	2023-03-09 10:19:13.410007
743	126	23	Nueva entrega recibida para revisión: Sistema de costos por órdenes de producción para una carpintería.	2023-03-08 10:19:13.410007	2023-03-09 10:19:13.410007
721	122	2	Nueva entrega recibida para revisión: Cadenas de Markov aplicadas al rendimiento estudiantil.	2023-05-29 02:02:39.053929	2023-05-30 02:02:39.053929
744	126	22	Nueva entrega recibida para revisión: Sistema de costos por órdenes de producción para una carpintería.	2023-03-08 10:19:13.410007	2023-03-09 10:19:13.410007
745	126	2	Nueva entrega recibida para revisión: Sistema de costos por órdenes de producción para una carpintería.	2023-03-08 10:19:13.410007	2023-03-09 10:19:13.410007
759	129	21	Nueva entrega recibida para revisión: Simulación térmica de un intercambiador de calor de tubos concéntricos.	2024-05-13 10:54:58.29451	2024-05-14 10:54:58.29451
760	129	3	Nueva entrega recibida para revisión: Simulación térmica de un intercambiador de calor de tubos concéntricos.	2024-05-13 10:54:58.29451	2024-05-14 10:54:58.29451
761	129	23	Nueva entrega recibida para revisión: Simulación térmica de un intercambiador de calor de tubos concéntricos.	2024-05-13 10:54:58.29451	2024-05-14 10:54:58.29451
762	129	22	Nueva entrega recibida para revisión: Simulación térmica de un intercambiador de calor de tubos concéntricos.	2024-05-13 10:54:58.29451	2024-05-14 10:54:58.29451
751	127	2	Nueva entrega recibida para revisión: Estudio de caso de una asociación de mujeres artesanas.	2023-06-30 05:49:13.535732	2023-07-01 05:49:13.535732
747	127	21	Nueva entrega recibida para revisión: Estudio de caso de una asociación de mujeres artesanas.	2023-06-30 05:49:13.535732	2023-07-01 05:49:13.535732
748	127	3	Nueva entrega recibida para revisión: Estudio de caso de una asociación de mujeres artesanas.	2023-06-30 05:49:13.535732	2023-07-01 05:49:13.535732
749	127	23	Nueva entrega recibida para revisión: Estudio de caso de una asociación de mujeres artesanas.	2023-06-30 05:49:13.535732	2023-07-01 05:49:13.535732
752	127	135	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-07-06 21:55:47.935613	2023-07-07 21:55:47.935613
763	129	2	Nueva entrega recibida para revisión: Simulación térmica de un intercambiador de calor de tubos concéntricos.	2024-05-13 10:54:58.29451	2024-05-14 10:54:58.29451
765	130	21	Nueva entrega recibida para revisión: Guía de prácticas de biología para centros escolares sin laboratorio.	2024-08-12 04:08:21.240532	2024-08-13 04:08:21.240532
766	130	3	Nueva entrega recibida para revisión: Guía de prácticas de biología para centros escolares sin laboratorio.	2024-08-12 04:08:21.240532	2024-08-13 04:08:21.240532
754	128	3	Nueva entrega recibida para revisión: Diseño estructural de una vivienda de dos niveles.	2023-04-01 20:38:46.262713	2023-04-02 20:38:46.262713
755	128	23	Nueva entrega recibida para revisión: Diseño estructural de una vivienda de dos niveles.	2023-04-01 20:38:46.262713	2023-04-02 20:38:46.262713
756	128	22	Nueva entrega recibida para revisión: Diseño estructural de una vivienda de dos niveles.	2023-04-01 20:38:46.262713	2023-04-02 20:38:46.262713
757	128	2	Nueva entrega recibida para revisión: Diseño estructural de una vivienda de dos niveles.	2023-04-01 20:38:46.262713	2023-04-02 20:38:46.262713
758	128	136	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-04-03 22:54:14.653284	2023-04-04 22:54:14.653284
776	131	139	Decisión del supervisor: Aprobada. La publicación espera el permiso de los autores.	2024-08-27 10:27:11.506444	2024-08-28 10:27:11.506444
764	129	137	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-05-15 20:00:53.642747	2024-05-16 20:00:53.642747
770	130	138	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-08-18 15:13:01.593856	2024-08-19 15:13:01.593856
790	134	21	Nueva entrega recibida para revisión: Protocolo de monitoreo en anestesia pediátrica.	2024-03-29 01:01:34.71129	2024-03-30 01:01:34.71129
794	134	2	Nueva entrega recibida para revisión: Protocolo de monitoreo en anestesia pediátrica.	2024-03-29 01:01:34.71129	2024-03-30 01:01:34.71129
829	140	22	Nueva entrega recibida (versión corregida) para revisión: Determinación de metales pesados en agua del río Lempa.	2024-10-13 00:30:46.024339	2024-10-14 00:30:46.024339
830	140	2	Nueva entrega recibida (versión corregida) para revisión: Determinación de metales pesados en agua del río Lempa.	2024-10-13 00:30:46.024339	2024-10-14 00:30:46.024339
832	140	145	Tu publicación fue retirada del catálogo. Motivo: Se detectaron datos personales de participantes en el documento.	2024-12-02 00:09:13.667534	2024-12-03 00:09:13.667534
807	136	143	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2024-09-12 17:44:22.250724	2024-09-13 17:44:22.250724
808	137	21	Nueva entrega recibida (versión corregida) para revisión: Frecuencia de grupos sanguíneos en donantes del banco de sangre regional.	2024-09-25 20:15:09.604322	2024-09-26 20:15:09.604322
809	137	3	Nueva entrega recibida (versión corregida) para revisión: Frecuencia de grupos sanguíneos en donantes del banco de sangre regional.	2024-09-25 20:15:09.604322	2024-09-26 20:15:09.604322
810	137	23	Nueva entrega recibida (versión corregida) para revisión: Frecuencia de grupos sanguíneos en donantes del banco de sangre regional.	2024-09-25 20:15:09.604322	2024-09-26 20:15:09.604322
811	137	22	Nueva entrega recibida (versión corregida) para revisión: Frecuencia de grupos sanguíneos en donantes del banco de sangre regional.	2024-09-25 20:15:09.604322	2024-09-26 20:15:09.604322
812	137	2	Nueva entrega recibida (versión corregida) para revisión: Frecuencia de grupos sanguíneos en donantes del banco de sangre regional.	2024-09-25 20:15:09.604322	2024-09-26 20:15:09.604322
819	138	144	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-03-16 14:19:54.624551	2024-03-17 14:19:54.624551
870	147	21	Nueva entrega recibida para revisión: Rasgos del habla popular en el oriente de El Salvador.	2024-03-25 14:36:26.754713	2024-03-26 14:36:26.754713
871	147	3	Nueva entrega recibida para revisión: Rasgos del habla popular en el oriente de El Salvador.	2024-03-25 14:36:26.754713	2024-03-26 14:36:26.754713
1075	180	171	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-02-25 12:35:11.308815	2025-02-26 12:35:11.308815
833	141	21	Nueva entrega recibida para revisión: Uso racional de antibióticos en farmacias de San Miguel.	2024-07-03 13:32:34.981855	2024-07-04 13:32:34.981855
834	141	3	Nueva entrega recibida para revisión: Uso racional de antibióticos en farmacias de San Miguel.	2024-07-03 13:32:34.981855	2024-07-04 13:32:34.981855
835	141	23	Nueva entrega recibida para revisión: Uso racional de antibióticos en farmacias de San Miguel.	2024-07-03 13:32:34.981855	2024-07-04 13:32:34.981855
836	141	22	Nueva entrega recibida para revisión: Uso racional de antibióticos en farmacias de San Miguel.	2024-07-03 13:32:34.981855	2024-07-04 13:32:34.981855
837	141	2	Nueva entrega recibida para revisión: Uso racional de antibióticos en farmacias de San Miguel.	2024-07-03 13:32:34.981855	2024-07-04 13:32:34.981855
838	141	123	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2024-07-17 19:44:51.354658	2024-07-18 19:44:51.354658
844	142	123	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-08-12 00:26:10.081494	2024-08-13 00:26:10.081494
1381	231	151	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-07-16 01:58:01.306206	2026-07-17 01:58:01.306206
863	146	21	Nueva entrega recibida para revisión: Panel de indicadores de rendimiento académico con ciencia de datos.	2024-05-13 08:22:39.76164	2024-05-14 08:22:39.76164
864	146	3	Nueva entrega recibida para revisión: Panel de indicadores de rendimiento académico con ciencia de datos.	2024-05-13 08:22:39.76164	2024-05-14 08:22:39.76164
865	146	23	Nueva entrega recibida para revisión: Panel de indicadores de rendimiento académico con ciencia de datos.	2024-05-13 08:22:39.76164	2024-05-14 08:22:39.76164
850	143	146	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-08-02 06:27:46.161873	2024-08-03 06:27:46.161873
866	146	22	Nueva entrega recibida para revisión: Panel de indicadores de rendimiento académico con ciencia de datos.	2024-05-13 08:22:39.76164	2024-05-14 08:22:39.76164
856	144	147	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-10-04 13:18:35.167055	2024-10-05 13:18:35.167055
867	146	2	Nueva entrega recibida para revisión: Panel de indicadores de rendimiento académico con ciencia de datos.	2024-05-13 08:22:39.76164	2024-05-14 08:22:39.76164
862	145	148	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-09-02 14:44:48.128883	2024-09-03 14:44:48.128883
869	146	124	Tu publicación fue retirada del catálogo. Motivo: La institución colaboradora solicitó no divulgar los resultados.	2024-09-01 23:29:53.40412	2024-09-02 23:29:53.40412
817	138	22	Nueva entrega recibida para revisión: Programa de ejercicios para la lumbalgia en trabajadores de oficina.	2024-03-07 04:40:23.261771	2024-03-08 04:40:23.261771
818	138	2	Nueva entrega recibida para revisión: Programa de ejercicios para la lumbalgia en trabajadores de oficina.	2024-03-07 04:40:23.261771	2024-03-08 04:40:23.261771
847	143	23	Nueva entrega recibida para revisión: Control de calidad de tabletas de paracetamol de distintos fabricantes.	2024-07-30 03:01:58.7298	2024-07-31 03:01:58.7298
848	143	22	Nueva entrega recibida para revisión: Control de calidad de tabletas de paracetamol de distintos fabricantes.	2024-07-30 03:01:58.7298	2024-07-31 03:01:58.7298
849	143	2	Nueva entrega recibida para revisión: Control de calidad de tabletas de paracetamol de distintos fabricantes.	2024-07-30 03:01:58.7298	2024-07-31 03:01:58.7298
839	142	21	Nueva entrega recibida (versión corregida) para revisión: Uso racional de antibióticos en farmacias de San Miguel.	2024-07-30 21:26:02.72772	2024-07-31 21:26:02.72772
840	142	3	Nueva entrega recibida (versión corregida) para revisión: Uso racional de antibióticos en farmacias de San Miguel.	2024-07-30 21:26:02.72772	2024-07-31 21:26:02.72772
841	142	23	Nueva entrega recibida (versión corregida) para revisión: Uso racional de antibióticos en farmacias de San Miguel.	2024-07-30 21:26:02.72772	2024-07-31 21:26:02.72772
842	142	22	Nueva entrega recibida (versión corregida) para revisión: Uso racional de antibióticos en farmacias de San Miguel.	2024-07-30 21:26:02.72772	2024-07-31 21:26:02.72772
843	142	2	Nueva entrega recibida (versión corregida) para revisión: Uso racional de antibióticos en farmacias de San Miguel.	2024-07-30 21:26:02.72772	2024-07-31 21:26:02.72772
893	150	151	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-11-10 21:32:58.351401	2024-11-11 21:32:58.351401
875	147	53	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-04-07 19:40:49.12221	2024-04-08 19:40:49.12221
820	139	21	Nueva entrega recibida para revisión: Determinación de metales pesados en agua del río Lempa.	2024-09-26 04:27:47.308895	2024-09-27 04:27:47.308895
821	139	3	Nueva entrega recibida para revisión: Determinación de metales pesados en agua del río Lempa.	2024-09-26 04:27:47.308895	2024-09-27 04:27:47.308895
822	139	23	Nueva entrega recibida para revisión: Determinación de metales pesados en agua del río Lempa.	2024-09-26 04:27:47.308895	2024-09-27 04:27:47.308895
823	139	22	Nueva entrega recibida para revisión: Determinación de metales pesados en agua del río Lempa.	2024-09-26 04:27:47.308895	2024-09-27 04:27:47.308895
824	139	2	Nueva entrega recibida para revisión: Determinación de metales pesados en agua del río Lempa.	2024-09-26 04:27:47.308895	2024-09-27 04:27:47.308895
825	139	145	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.	2024-09-30 20:14:36.658237	2024-10-01 20:14:36.658237
831	140	145	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-10-25 19:27:22.343679	2024-10-26 19:27:22.343679
881	148	149	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-09-29 06:56:56.177987	2024-09-30 06:56:56.177987
857	145	21	Nueva entrega recibida para revisión: Detección de enfermedades en hojas de café con redes neuronales.	2024-08-20 16:46:43.801735	2024-08-21 16:46:43.801735
858	145	3	Nueva entrega recibida para revisión: Detección de enfermedades en hojas de café con redes neuronales.	2024-08-20 16:46:43.801735	2024-08-21 16:46:43.801735
859	145	23	Nueva entrega recibida para revisión: Detección de enfermedades en hojas de café con redes neuronales.	2024-08-20 16:46:43.801735	2024-08-21 16:46:43.801735
860	145	22	Nueva entrega recibida para revisión: Detección de enfermedades en hojas de café con redes neuronales.	2024-08-20 16:46:43.801735	2024-08-21 16:46:43.801735
861	145	2	Nueva entrega recibida para revisión: Detección de enfermedades en hojas de café con redes neuronales.	2024-08-20 16:46:43.801735	2024-08-21 16:46:43.801735
851	144	21	Nueva entrega recibida para revisión: Determinantes del empleo informal en San Miguel.	2024-09-29 08:18:37.815957	2024-09-30 08:18:37.815957
852	144	3	Nueva entrega recibida para revisión: Determinantes del empleo informal en San Miguel.	2024-09-29 08:18:37.815957	2024-09-30 08:18:37.815957
853	144	23	Nueva entrega recibida para revisión: Determinantes del empleo informal en San Miguel.	2024-09-29 08:18:37.815957	2024-09-30 08:18:37.815957
854	144	22	Nueva entrega recibida para revisión: Determinantes del empleo informal en San Miguel.	2024-09-29 08:18:37.815957	2024-09-30 08:18:37.815957
855	144	2	Nueva entrega recibida para revisión: Determinantes del empleo informal en San Miguel.	2024-09-29 08:18:37.815957	2024-09-30 08:18:37.815957
912	154	21	Nueva entrega recibida para revisión: Química en la cocina: prácticas para tercer ciclo.	2024-04-07 09:56:44.6477	2024-04-08 09:56:44.6477
905	152	153	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-10-05 08:31:08.872718	2024-10-06 08:31:08.872718
882	149	21	Nueva entrega recibida para revisión: Programa de intervención en duelo para familias de migrantes.	2024-08-17 20:33:17.848493	2024-08-18 20:33:17.848493
883	149	3	Nueva entrega recibida para revisión: Programa de intervención en duelo para familias de migrantes.	2024-08-17 20:33:17.848493	2024-08-18 20:33:17.848493
884	149	23	Nueva entrega recibida para revisión: Programa de intervención en duelo para familias de migrantes.	2024-08-17 20:33:17.848493	2024-08-18 20:33:17.848493
885	149	22	Nueva entrega recibida para revisión: Programa de intervención en duelo para familias de migrantes.	2024-08-17 20:33:17.848493	2024-08-18 20:33:17.848493
886	149	2	Nueva entrega recibida para revisión: Programa de intervención en duelo para familias de migrantes.	2024-08-17 20:33:17.848493	2024-08-18 20:33:17.848493
911	153	154	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-04-26 18:16:19.007543	2024-04-27 18:16:19.007543
894	151	21	Nueva entrega recibida para revisión: Caso clínico de apendicitis aguda durante el embarazo.	2024-05-14 06:53:08.717728	2024-05-15 06:53:08.717728
895	151	3	Nueva entrega recibida para revisión: Caso clínico de apendicitis aguda durante el embarazo.	2024-05-14 06:53:08.717728	2024-05-15 06:53:08.717728
896	151	23	Nueva entrega recibida para revisión: Caso clínico de apendicitis aguda durante el embarazo.	2024-05-14 06:53:08.717728	2024-05-15 06:53:08.717728
897	151	22	Nueva entrega recibida para revisión: Caso clínico de apendicitis aguda durante el embarazo.	2024-05-14 06:53:08.717728	2024-05-15 06:53:08.717728
898	151	2	Nueva entrega recibida para revisión: Caso clínico de apendicitis aguda durante el embarazo.	2024-05-14 06:53:08.717728	2024-05-15 06:53:08.717728
909	153	22	Nueva entrega recibida para revisión: Secuencia de clases sobre la energía y sus transformaciones.	2024-04-19 18:47:49.640075	2024-04-20 18:47:49.640075
910	153	2	Nueva entrega recibida para revisión: Secuencia de clases sobre la energía y sus transformaciones.	2024-04-19 18:47:49.640075	2024-04-20 18:47:49.640075
876	148	21	Nueva entrega recibida para revisión: Hábitos de lectura en estudiantes universitarios.	2024-09-24 02:59:37.80986	2024-09-25 02:59:37.80986
877	148	3	Nueva entrega recibida para revisión: Hábitos de lectura en estudiantes universitarios.	2024-09-24 02:59:37.80986	2024-09-25 02:59:37.80986
878	148	23	Nueva entrega recibida para revisión: Hábitos de lectura en estudiantes universitarios.	2024-09-24 02:59:37.80986	2024-09-25 02:59:37.80986
879	148	22	Nueva entrega recibida para revisión: Hábitos de lectura en estudiantes universitarios.	2024-09-24 02:59:37.80986	2024-09-25 02:59:37.80986
880	148	2	Nueva entrega recibida para revisión: Hábitos de lectura en estudiantes universitarios.	2024-09-24 02:59:37.80986	2024-09-25 02:59:37.80986
900	152	21	Nueva entrega recibida para revisión: Guía didáctica de óptica geométrica con materiales reciclados.	2024-09-20 11:37:41.500765	2024-09-21 11:37:41.500765
887	149	150	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-08-25 16:06:17.249839	2024-08-26 16:06:17.249839
901	152	3	Nueva entrega recibida para revisión: Guía didáctica de óptica geométrica con materiales reciclados.	2024-09-20 11:37:41.500765	2024-09-21 11:37:41.500765
902	152	23	Nueva entrega recibida para revisión: Guía didáctica de óptica geométrica con materiales reciclados.	2024-09-20 11:37:41.500765	2024-09-21 11:37:41.500765
903	152	22	Nueva entrega recibida para revisión: Guía didáctica de óptica geométrica con materiales reciclados.	2024-09-20 11:37:41.500765	2024-09-21 11:37:41.500765
904	152	2	Nueva entrega recibida para revisión: Guía didáctica de óptica geométrica con materiales reciclados.	2024-09-20 11:37:41.500765	2024-09-21 11:37:41.500765
888	150	21	Nueva entrega recibida para revisión: Aplicación de una prueba de inteligencia en niños de primer ciclo.	2024-10-28 06:04:14.960206	2024-10-29 06:04:14.960206
889	150	3	Nueva entrega recibida para revisión: Aplicación de una prueba de inteligencia en niños de primer ciclo.	2024-10-28 06:04:14.960206	2024-10-29 06:04:14.960206
890	150	23	Nueva entrega recibida para revisión: Aplicación de una prueba de inteligencia en niños de primer ciclo.	2024-10-28 06:04:14.960206	2024-10-29 06:04:14.960206
891	150	22	Nueva entrega recibida para revisión: Aplicación de una prueba de inteligencia en niños de primer ciclo.	2024-10-28 06:04:14.960206	2024-10-29 06:04:14.960206
892	150	2	Nueva entrega recibida para revisión: Aplicación de una prueba de inteligencia en niños de primer ciclo.	2024-10-28 06:04:14.960206	2024-10-29 06:04:14.960206
924	156	21	Nueva entrega recibida para revisión: Plan estratégico para una cooperativa de ahorro y crédito.	2024-08-04 10:32:59.365624	2024-08-05 10:32:59.365624
925	156	3	Nueva entrega recibida para revisión: Plan estratégico para una cooperativa de ahorro y crédito.	2024-08-04 10:32:59.365624	2024-08-05 10:32:59.365624
926	156	23	Nueva entrega recibida para revisión: Plan estratégico para una cooperativa de ahorro y crédito.	2024-08-04 10:32:59.365624	2024-08-05 10:32:59.365624
927	156	22	Nueva entrega recibida para revisión: Plan estratégico para una cooperativa de ahorro y crédito.	2024-08-04 10:32:59.365624	2024-08-05 10:32:59.365624
928	156	2	Nueva entrega recibida para revisión: Plan estratégico para una cooperativa de ahorro y crédito.	2024-08-04 10:32:59.365624	2024-08-05 10:32:59.365624
918	155	21	Nueva entrega recibida para revisión: Oportunidades del tratado de libre comercio con Corea para productos agrícolas.	2024-06-13 16:37:11.644369	2024-06-14 16:37:11.644369
919	155	3	Nueva entrega recibida para revisión: Oportunidades del tratado de libre comercio con Corea para productos agrícolas.	2024-06-13 16:37:11.644369	2024-06-14 16:37:11.644369
920	155	23	Nueva entrega recibida para revisión: Oportunidades del tratado de libre comercio con Corea para productos agrícolas.	2024-06-13 16:37:11.644369	2024-06-14 16:37:11.644369
921	155	22	Nueva entrega recibida para revisión: Oportunidades del tratado de libre comercio con Corea para productos agrícolas.	2024-06-13 16:37:11.644369	2024-06-14 16:37:11.644369
913	154	3	Nueva entrega recibida para revisión: Química en la cocina: prácticas para tercer ciclo.	2024-04-07 09:56:44.6477	2024-04-08 09:56:44.6477
914	154	23	Nueva entrega recibida para revisión: Química en la cocina: prácticas para tercer ciclo.	2024-04-07 09:56:44.6477	2024-04-08 09:56:44.6477
915	154	22	Nueva entrega recibida para revisión: Química en la cocina: prácticas para tercer ciclo.	2024-04-07 09:56:44.6477	2024-04-08 09:56:44.6477
916	154	2	Nueva entrega recibida para revisión: Química en la cocina: prácticas para tercer ciclo.	2024-04-07 09:56:44.6477	2024-04-08 09:56:44.6477
917	154	92	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-04-15 22:41:45.984538	2024-04-16 22:41:45.984538
922	155	2	Nueva entrega recibida para revisión: Oportunidades del tratado de libre comercio con Corea para productos agrícolas.	2024-06-13 16:37:11.644369	2024-06-14 16:37:11.644369
923	155	155	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2024-06-16 22:22:08.011096	2024-06-17 22:22:08.011096
936	158	21	Nueva entrega recibida para revisión: Plan de negocios para una empresa de alimentos saludables.	2024-04-21 06:05:20.151789	2024-04-22 06:05:20.151789
937	158	3	Nueva entrega recibida para revisión: Plan de negocios para una empresa de alimentos saludables.	2024-04-21 06:05:20.151789	2024-04-22 06:05:20.151789
938	158	23	Nueva entrega recibida para revisión: Plan de negocios para una empresa de alimentos saludables.	2024-04-21 06:05:20.151789	2024-04-22 06:05:20.151789
929	156	156	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2024-08-08 01:49:14.71028	2024-08-09 01:49:14.71028
935	157	156	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-08-28 16:14:07.469226	2024-08-29 16:14:07.469226
945	159	22	Nueva entrega recibida para revisión: Demostraciones visuales de identidades algebraicas.	2024-03-20 11:51:24.20424	2024-03-21 11:51:24.20424
939	158	22	Nueva entrega recibida para revisión: Plan de negocios para una empresa de alimentos saludables.	2024-04-21 06:05:20.151789	2024-04-22 06:05:20.151789
940	158	2	Nueva entrega recibida para revisión: Plan de negocios para una empresa de alimentos saludables.	2024-04-21 06:05:20.151789	2024-04-22 06:05:20.151789
946	159	2	Nueva entrega recibida para revisión: Demostraciones visuales de identidades algebraicas.	2024-03-20 11:51:24.20424	2024-03-21 11:51:24.20424
947	159	158	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2024-03-26 04:52:18.574677	2024-03-27 04:52:18.574677
948	160	21	Nueva entrega recibida (versión corregida) para revisión: Demostraciones visuales de identidades algebraicas.	2024-04-07 18:28:22.955909	2024-04-08 18:28:22.955909
949	160	3	Nueva entrega recibida (versión corregida) para revisión: Demostraciones visuales de identidades algebraicas.	2024-04-07 18:28:22.955909	2024-04-08 18:28:22.955909
950	160	23	Nueva entrega recibida (versión corregida) para revisión: Demostraciones visuales de identidades algebraicas.	2024-04-07 18:28:22.955909	2024-04-08 18:28:22.955909
951	160	22	Nueva entrega recibida (versión corregida) para revisión: Demostraciones visuales de identidades algebraicas.	2024-04-07 18:28:22.955909	2024-04-08 18:28:22.955909
952	160	2	Nueva entrega recibida (versión corregida) para revisión: Demostraciones visuales de identidades algebraicas.	2024-04-07 18:28:22.955909	2024-04-08 18:28:22.955909
953	160	158	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-04-17 05:04:48.319022	2024-04-18 05:04:48.319022
960	162	21	Nueva entrega recibida para revisión: Accesibilidad universal en los edificios de la facultad.	2024-08-07 10:18:09.771789	2024-08-08 10:18:09.771789
961	162	3	Nueva entrega recibida para revisión: Accesibilidad universal en los edificios de la facultad.	2024-08-07 10:18:09.771789	2024-08-08 10:18:09.771789
962	162	23	Nueva entrega recibida para revisión: Accesibilidad universal en los edificios de la facultad.	2024-08-07 10:18:09.771789	2024-08-08 10:18:09.771789
963	162	22	Nueva entrega recibida para revisión: Accesibilidad universal en los edificios de la facultad.	2024-08-07 10:18:09.771789	2024-08-08 10:18:09.771789
964	162	2	Nueva entrega recibida para revisión: Accesibilidad universal en los edificios de la facultad.	2024-08-07 10:18:09.771789	2024-08-08 10:18:09.771789
954	161	21	Nueva entrega recibida para revisión: Diseño de un mercado municipal para Santa Rosa de Lima.	2024-08-24 09:41:44.048595	2024-08-25 09:41:44.048595
955	161	3	Nueva entrega recibida para revisión: Diseño de un mercado municipal para Santa Rosa de Lima.	2024-08-24 09:41:44.048595	2024-08-25 09:41:44.048595
956	161	23	Nueva entrega recibida para revisión: Diseño de un mercado municipal para Santa Rosa de Lima.	2024-08-24 09:41:44.048595	2024-08-25 09:41:44.048595
965	162	159	Decisión del supervisor: Rechazada. El archivo está incompleto y no incluye los resultados.	2024-08-17 22:54:32.135373	2024-08-18 22:54:32.135373
972	164	21	Nueva entrega recibida para revisión: GeoGebra en la enseñanza de funciones en bachillerato.	2024-04-11 05:00:49.209083	2024-04-12 05:00:49.209083
973	164	3	Nueva entrega recibida para revisión: GeoGebra en la enseñanza de funciones en bachillerato.	2024-04-11 05:00:49.209083	2024-04-12 05:00:49.209083
974	164	23	Nueva entrega recibida para revisión: GeoGebra en la enseñanza de funciones en bachillerato.	2024-04-11 05:00:49.209083	2024-04-12 05:00:49.209083
975	164	22	Nueva entrega recibida para revisión: GeoGebra en la enseñanza de funciones en bachillerato.	2024-04-11 05:00:49.209083	2024-04-12 05:00:49.209083
957	161	22	Nueva entrega recibida para revisión: Diseño de un mercado municipal para Santa Rosa de Lima.	2024-08-24 09:41:44.048595	2024-08-25 09:41:44.048595
958	161	2	Nueva entrega recibida para revisión: Diseño de un mercado municipal para Santa Rosa de Lima.	2024-08-24 09:41:44.048595	2024-08-25 09:41:44.048595
959	161	133	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.	2024-09-02 08:57:28.419779	2024-09-03 08:57:28.419779
990	167	21	Nueva entrega recibida para revisión: Bloques de concreto con agregado reciclado.	2024-11-12 21:40:41.057974	2024-11-13 21:40:41.057974
989	166	162	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-10-01 12:12:47.377196	2024-10-02 12:12:47.377196
966	163	21	Nueva entrega recibida para revisión: Migración irregular de jóvenes del oriente hacia Estados Unidos.	2024-04-02 07:05:50.467214	2024-04-03 07:05:50.467214
967	163	3	Nueva entrega recibida para revisión: Migración irregular de jóvenes del oriente hacia Estados Unidos.	2024-04-02 07:05:50.467214	2024-04-03 07:05:50.467214
968	163	23	Nueva entrega recibida para revisión: Migración irregular de jóvenes del oriente hacia Estados Unidos.	2024-04-02 07:05:50.467214	2024-04-03 07:05:50.467214
969	163	22	Nueva entrega recibida para revisión: Migración irregular de jóvenes del oriente hacia Estados Unidos.	2024-04-02 07:05:50.467214	2024-04-03 07:05:50.467214
970	163	2	Nueva entrega recibida para revisión: Migración irregular de jóvenes del oriente hacia Estados Unidos.	2024-04-02 07:05:50.467214	2024-04-03 07:05:50.467214
971	163	160	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-04-05 16:24:53.863486	2024-04-06 16:24:53.863486
978	165	21	Nueva entrega recibida (versión corregida) para revisión: GeoGebra en la enseñanza de funciones en bachillerato.	2024-04-24 20:11:02.967843	2024-04-25 20:11:02.967843
979	165	3	Nueva entrega recibida (versión corregida) para revisión: GeoGebra en la enseñanza de funciones en bachillerato.	2024-04-24 20:11:02.967843	2024-04-25 20:11:02.967843
980	165	23	Nueva entrega recibida (versión corregida) para revisión: GeoGebra en la enseñanza de funciones en bachillerato.	2024-04-24 20:11:02.967843	2024-04-25 20:11:02.967843
981	165	22	Nueva entrega recibida (versión corregida) para revisión: GeoGebra en la enseñanza de funciones en bachillerato.	2024-04-24 20:11:02.967843	2024-04-25 20:11:02.967843
982	165	2	Nueva entrega recibida (versión corregida) para revisión: GeoGebra en la enseñanza de funciones en bachillerato.	2024-04-24 20:11:02.967843	2024-04-25 20:11:02.967843
991	167	3	Nueva entrega recibida para revisión: Bloques de concreto con agregado reciclado.	2024-11-12 21:40:41.057974	2024-11-13 21:40:41.057974
992	167	23	Nueva entrega recibida para revisión: Bloques de concreto con agregado reciclado.	2024-11-12 21:40:41.057974	2024-11-13 21:40:41.057974
993	167	22	Nueva entrega recibida para revisión: Bloques de concreto con agregado reciclado.	2024-11-12 21:40:41.057974	2024-11-13 21:40:41.057974
994	167	2	Nueva entrega recibida para revisión: Bloques de concreto con agregado reciclado.	2024-11-12 21:40:41.057974	2024-11-13 21:40:41.057974
1001	168	164	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-05-21 20:19:20.596779	2024-05-22 20:19:20.596779
1007	169	165	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-07-15 15:49:24.63808	2024-07-16 15:49:24.63808
1013	170	166	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-06-16 05:45:42.937538	2024-06-17 05:45:42.937538
1019	171	167	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-06-13 13:18:47.616038	2025-06-14 13:18:47.616038
988	166	2	Nueva entrega recibida para revisión: Secuencia didáctica de ecuaciones de primer grado.	2024-09-24 14:04:37.982672	2024-09-25 14:04:37.982672
995	167	163	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-11-18 08:41:30.463443	2024-11-19 08:41:30.463443
1021	172	21	Nueva entrega recibida para revisión: Plan de mantenimiento preventivo para el parque vehicular de una alcaldía.	2025-05-06 18:43:27.250555	2025-05-07 18:43:27.250555
1002	169	21	Nueva entrega recibida para revisión: Estimulación del lenguaje oral mediante cuentos.	2024-07-04 21:42:10.257551	2024-07-05 21:42:10.257551
1003	169	3	Nueva entrega recibida para revisión: Estimulación del lenguaje oral mediante cuentos.	2024-07-04 21:42:10.257551	2024-07-05 21:42:10.257551
1004	169	23	Nueva entrega recibida para revisión: Estimulación del lenguaje oral mediante cuentos.	2024-07-04 21:42:10.257551	2024-07-05 21:42:10.257551
1005	169	22	Nueva entrega recibida para revisión: Estimulación del lenguaje oral mediante cuentos.	2024-07-04 21:42:10.257551	2024-07-05 21:42:10.257551
1006	169	2	Nueva entrega recibida para revisión: Estimulación del lenguaje oral mediante cuentos.	2024-07-04 21:42:10.257551	2024-07-05 21:42:10.257551
1014	171	21	Nueva entrega recibida para revisión: Análisis de vibraciones en motores eléctricos de la industria local.	2025-05-30 22:16:18.266998	2025-05-31 22:16:18.266998
1015	171	3	Nueva entrega recibida para revisión: Análisis de vibraciones en motores eléctricos de la industria local.	2025-05-30 22:16:18.266998	2025-05-31 22:16:18.266998
1016	171	23	Nueva entrega recibida para revisión: Análisis de vibraciones en motores eléctricos de la industria local.	2025-05-30 22:16:18.266998	2025-05-31 22:16:18.266998
1017	171	22	Nueva entrega recibida para revisión: Análisis de vibraciones en motores eléctricos de la industria local.	2025-05-30 22:16:18.266998	2025-05-31 22:16:18.266998
1018	171	2	Nueva entrega recibida para revisión: Análisis de vibraciones en motores eléctricos de la industria local.	2025-05-30 22:16:18.266998	2025-05-31 22:16:18.266998
1020	171	167	Tu publicación fue retirada del catálogo. Motivo: Se detectaron datos personales de participantes en el documento.	2025-07-10 02:16:17.911813	2025-07-11 02:16:17.911813
1023	172	23	Nueva entrega recibida para revisión: Plan de mantenimiento preventivo para el parque vehicular de una alcaldía.	2025-05-06 18:43:27.250555	2025-05-07 18:43:27.250555
1024	172	22	Nueva entrega recibida para revisión: Plan de mantenimiento preventivo para el parque vehicular de una alcaldía.	2025-05-06 18:43:27.250555	2025-05-07 18:43:27.250555
1025	172	2	Nueva entrega recibida para revisión: Plan de mantenimiento preventivo para el parque vehicular de una alcaldía.	2025-05-06 18:43:27.250555	2025-05-07 18:43:27.250555
1026	172	168	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2025-05-21 13:33:57.588359	2025-05-22 13:33:57.588359
1107	186	21	Nueva entrega recibida para revisión: Glosario trilingüe de términos agrícolas.	2025-10-05 14:18:18.773214	2025-10-06 14:18:18.773214
1106	185	176	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-11-08 03:06:19.137716	2025-11-09 03:06:19.137716
1039	175	21	Nueva entrega recibida (versión corregida) para revisión: Monitoreo del consumo eléctrico con sensores de corriente y plataforma web.	2025-07-29 13:52:25.31125	2025-07-30 13:52:25.31125
1040	175	3	Nueva entrega recibida (versión corregida) para revisión: Monitoreo del consumo eléctrico con sensores de corriente y plataforma web.	2025-07-29 13:52:25.31125	2025-07-30 13:52:25.31125
1041	175	23	Nueva entrega recibida (versión corregida) para revisión: Monitoreo del consumo eléctrico con sensores de corriente y plataforma web.	2025-07-29 13:52:25.31125	2025-07-30 13:52:25.31125
1042	175	22	Nueva entrega recibida (versión corregida) para revisión: Monitoreo del consumo eléctrico con sensores de corriente y plataforma web.	2025-07-29 13:52:25.31125	2025-07-30 13:52:25.31125
1043	175	2	Nueva entrega recibida (versión corregida) para revisión: Monitoreo del consumo eléctrico con sensores de corriente y plataforma web.	2025-07-29 13:52:25.31125	2025-07-30 13:52:25.31125
1108	186	3	Nueva entrega recibida para revisión: Glosario trilingüe de términos agrícolas.	2025-10-05 14:18:18.773214	2025-10-06 14:18:18.773214
1109	186	23	Nueva entrega recibida para revisión: Glosario trilingüe de términos agrícolas.	2025-10-05 14:18:18.773214	2025-10-06 14:18:18.773214
1082	182	21	Nueva entrega recibida para revisión: Impacto de las remesas en el consumo de los hogares de la zona oriental.	2025-07-19 11:33:45.876298	2025-07-20 11:33:45.876298
1070	180	21	Nueva entrega recibida (versión corregida) para revisión: Lesiones deportivas frecuentes en jugadores de fútbol universitario.	2025-02-20 03:31:26.940954	2025-02-21 03:31:26.940954
1071	180	3	Nueva entrega recibida (versión corregida) para revisión: Lesiones deportivas frecuentes en jugadores de fútbol universitario.	2025-02-20 03:31:26.940954	2025-02-21 03:31:26.940954
1072	180	23	Nueva entrega recibida (versión corregida) para revisión: Lesiones deportivas frecuentes en jugadores de fútbol universitario.	2025-02-20 03:31:26.940954	2025-02-21 03:31:26.940954
1073	180	22	Nueva entrega recibida (versión corregida) para revisión: Lesiones deportivas frecuentes en jugadores de fútbol universitario.	2025-02-20 03:31:26.940954	2025-02-21 03:31:26.940954
1074	180	2	Nueva entrega recibida (versión corregida) para revisión: Lesiones deportivas frecuentes en jugadores de fútbol universitario.	2025-02-20 03:31:26.940954	2025-02-21 03:31:26.940954
1083	182	3	Nueva entrega recibida para revisión: Impacto de las remesas en el consumo de los hogares de la zona oriental.	2025-07-19 11:33:45.876298	2025-07-20 11:33:45.876298
1084	182	23	Nueva entrega recibida para revisión: Impacto de las remesas en el consumo de los hogares de la zona oriental.	2025-07-19 11:33:45.876298	2025-07-20 11:33:45.876298
1085	182	22	Nueva entrega recibida para revisión: Impacto de las remesas en el consumo de los hogares de la zona oriental.	2025-07-19 11:33:45.876298	2025-07-20 11:33:45.876298
1086	182	2	Nueva entrega recibida para revisión: Impacto de las remesas en el consumo de los hogares de la zona oriental.	2025-07-19 11:33:45.876298	2025-07-20 11:33:45.876298
1088	183	21	Nueva entrega recibida para revisión: Efectos de la adopción del bitcoin en pequeños comercios.	2025-07-02 20:18:34.828552	2025-07-03 20:18:34.828552
1089	183	3	Nueva entrega recibida para revisión: Efectos de la adopción del bitcoin en pequeños comercios.	2025-07-02 20:18:34.828552	2025-07-03 20:18:34.828552
1090	183	23	Nueva entrega recibida para revisión: Efectos de la adopción del bitcoin en pequeños comercios.	2025-07-02 20:18:34.828552	2025-07-03 20:18:34.828552
1091	183	22	Nueva entrega recibida para revisión: Efectos de la adopción del bitcoin en pequeños comercios.	2025-07-02 20:18:34.828552	2025-07-03 20:18:34.828552
1092	183	2	Nueva entrega recibida para revisión: Efectos de la adopción del bitcoin en pequeños comercios.	2025-07-02 20:18:34.828552	2025-07-03 20:18:34.828552
1110	186	22	Nueva entrega recibida para revisión: Glosario trilingüe de términos agrícolas.	2025-10-05 14:18:18.773214	2025-10-06 14:18:18.773214
1099	184	175	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-04-26 23:57:06.203104	2025-04-27 23:57:06.203104
1111	186	2	Nueva entrega recibida para revisión: Glosario trilingüe de términos agrícolas.	2025-10-05 14:18:18.773214	2025-10-06 14:18:18.773214
1112	186	128	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.	2025-10-16 22:02:10.1288	2025-10-17 22:02:10.1288
1118	187	128	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-11-03 16:54:19.868822	2025-11-04 16:54:19.868822
1137	191	21	Nueva entrega recibida para revisión: Niveles de estrés académico en estudiantes de la facultad.	2025-05-25 21:09:25.869552	2025-05-26 21:09:25.869552
1136	190	177	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-11-17 08:45:54.236502	2025-11-18 08:45:54.236502
1119	188	21	Nueva entrega recibida para revisión: Memoria histórica del conflicto armado contada por habitantes de Morazán.	2025-10-05 06:01:08.509174	2025-10-06 06:01:08.509174
1120	188	3	Nueva entrega recibida para revisión: Memoria histórica del conflicto armado contada por habitantes de Morazán.	2025-10-05 06:01:08.509174	2025-10-06 06:01:08.509174
1121	188	23	Nueva entrega recibida para revisión: Memoria histórica del conflicto armado contada por habitantes de Morazán.	2025-10-05 06:01:08.509174	2025-10-06 06:01:08.509174
1122	188	22	Nueva entrega recibida para revisión: Memoria histórica del conflicto armado contada por habitantes de Morazán.	2025-10-05 06:01:08.509174	2025-10-06 06:01:08.509174
1123	188	2	Nueva entrega recibida para revisión: Memoria histórica del conflicto armado contada por habitantes de Morazán.	2025-10-05 06:01:08.509174	2025-10-06 06:01:08.509174
1124	188	68	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2025-10-12 09:49:41.823156	2025-10-13 09:49:41.823156
1143	192	21	Nueva entrega recibida para revisión: Complicaciones del dengue en niños atendidos en el hospital regional.	2025-04-02 21:30:55.918236	2025-04-03 21:30:55.918236
1044	175	139	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-08-07 12:42:27.645314	2025-08-08 12:42:27.645314
1064	179	21	Nueva entrega recibida para revisión: Lesiones deportivas frecuentes en jugadores de fútbol universitario.	2025-02-05 09:59:10.24998	2025-02-06 09:59:10.24998
1065	179	3	Nueva entrega recibida para revisión: Lesiones deportivas frecuentes en jugadores de fútbol universitario.	2025-02-05 09:59:10.24998	2025-02-06 09:59:10.24998
1051	177	21	Nueva entrega recibida para revisión: Detección de infección de vías urinarias en mujeres embarazadas.	2025-03-05 22:54:10.282683	2025-03-06 22:54:10.282683
1052	177	3	Nueva entrega recibida para revisión: Detección de infección de vías urinarias en mujeres embarazadas.	2025-03-05 22:54:10.282683	2025-03-06 22:54:10.282683
1053	177	23	Nueva entrega recibida para revisión: Detección de infección de vías urinarias en mujeres embarazadas.	2025-03-05 22:54:10.282683	2025-03-06 22:54:10.282683
1054	177	22	Nueva entrega recibida para revisión: Detección de infección de vías urinarias en mujeres embarazadas.	2025-03-05 22:54:10.282683	2025-03-06 22:54:10.282683
1055	177	2	Nueva entrega recibida para revisión: Detección de infección de vías urinarias en mujeres embarazadas.	2025-03-05 22:54:10.282683	2025-03-06 22:54:10.282683
1057	177	143	Tu publicación fue retirada del catálogo. Motivo: La institución colaboradora solicitó no divulgar los resultados.	2025-06-02 18:41:09.962154	2025-06-03 18:41:09.962154
1045	176	21	Nueva entrega recibida para revisión: Prevalencia de parasitosis intestinal en niños de escuelas rurales de Morazán.	2025-09-12 20:12:30.273366	2025-09-13 20:12:30.273366
1046	176	3	Nueva entrega recibida para revisión: Prevalencia de parasitosis intestinal en niños de escuelas rurales de Morazán.	2025-09-12 20:12:30.273366	2025-09-13 20:12:30.273366
1047	176	23	Nueva entrega recibida para revisión: Prevalencia de parasitosis intestinal en niños de escuelas rurales de Morazán.	2025-09-12 20:12:30.273366	2025-09-13 20:12:30.273366
1048	176	22	Nueva entrega recibida para revisión: Prevalencia de parasitosis intestinal en niños de escuelas rurales de Morazán.	2025-09-12 20:12:30.273366	2025-09-13 20:12:30.273366
1049	176	2	Nueva entrega recibida para revisión: Prevalencia de parasitosis intestinal en niños de escuelas rurales de Morazán.	2025-09-12 20:12:30.273366	2025-09-13 20:12:30.273366
1058	178	21	Nueva entrega recibida para revisión: Resistencia antimicrobiana de Escherichia coli en muestras de orina.	2025-10-22 22:08:10.26789	2025-10-23 22:08:10.26789
1059	178	3	Nueva entrega recibida para revisión: Resistencia antimicrobiana de Escherichia coli en muestras de orina.	2025-10-22 22:08:10.26789	2025-10-23 22:08:10.26789
1060	178	23	Nueva entrega recibida para revisión: Resistencia antimicrobiana de Escherichia coli en muestras de orina.	2025-10-22 22:08:10.26789	2025-10-23 22:08:10.26789
1061	178	22	Nueva entrega recibida para revisión: Resistencia antimicrobiana de Escherichia coli en muestras de orina.	2025-10-22 22:08:10.26789	2025-10-23 22:08:10.26789
1062	178	2	Nueva entrega recibida para revisión: Resistencia antimicrobiana de Escherichia coli en muestras de orina.	2025-10-22 22:08:10.26789	2025-10-23 22:08:10.26789
1066	179	23	Nueva entrega recibida para revisión: Lesiones deportivas frecuentes en jugadores de fútbol universitario.	2025-02-05 09:59:10.24998	2025-02-06 09:59:10.24998
1067	179	22	Nueva entrega recibida para revisión: Lesiones deportivas frecuentes en jugadores de fútbol universitario.	2025-02-05 09:59:10.24998	2025-02-06 09:59:10.24998
1068	179	2	Nueva entrega recibida para revisión: Lesiones deportivas frecuentes en jugadores de fútbol universitario.	2025-02-05 09:59:10.24998	2025-02-06 09:59:10.24998
1069	179	171	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2025-02-12 08:42:16.582257	2025-02-13 08:42:16.582257
1076	181	21	Nueva entrega recibida para revisión: Adaptaciones del hogar para adultos mayores con movilidad reducida.	2025-10-23 21:45:48.233041	2025-10-24 21:45:48.233041
1077	181	3	Nueva entrega recibida para revisión: Adaptaciones del hogar para adultos mayores con movilidad reducida.	2025-10-23 21:45:48.233041	2025-10-24 21:45:48.233041
1078	181	23	Nueva entrega recibida para revisión: Adaptaciones del hogar para adultos mayores con movilidad reducida.	2025-10-23 21:45:48.233041	2025-10-24 21:45:48.233041
1079	181	22	Nueva entrega recibida para revisión: Adaptaciones del hogar para adultos mayores con movilidad reducida.	2025-10-23 21:45:48.233041	2025-10-24 21:45:48.233041
1080	181	2	Nueva entrega recibida para revisión: Adaptaciones del hogar para adultos mayores con movilidad reducida.	2025-10-23 21:45:48.233041	2025-10-24 21:45:48.233041
1103	185	23	Nueva entrega recibida para revisión: Antología comentada de cuentos de Salarrué.	2025-11-04 06:05:56.803444	2025-11-05 06:05:56.803444
1087	182	173	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-07-27 04:54:35.218917	2025-07-28 04:54:35.218917
1104	185	22	Nueva entrega recibida para revisión: Antología comentada de cuentos de Salarrué.	2025-11-04 06:05:56.803444	2025-11-05 06:05:56.803444
1093	183	174	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-07-05 09:04:40.192888	2025-07-06 09:04:40.192888
1105	185	2	Nueva entrega recibida para revisión: Antología comentada de cuentos de Salarrué.	2025-11-04 06:05:56.803444	2025-11-05 06:05:56.803444
1155	194	21	Nueva entrega recibida para revisión: Concepciones erróneas sobre la gravedad en estudiantes de bachillerato.	2025-06-02 06:15:12.965051	2025-06-03 06:15:12.965051
1148	192	179	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-04-16 18:56:16.259908	2025-04-17 18:56:16.259908
1094	184	21	Nueva entrega recibida para revisión: Balanza comercial de El Salvador con Centroamérica.	2025-04-13 00:31:59.864704	2025-04-14 00:31:59.864704
1095	184	3	Nueva entrega recibida para revisión: Balanza comercial de El Salvador con Centroamérica.	2025-04-13 00:31:59.864704	2025-04-14 00:31:59.864704
1096	184	23	Nueva entrega recibida para revisión: Balanza comercial de El Salvador con Centroamérica.	2025-04-13 00:31:59.864704	2025-04-14 00:31:59.864704
1097	184	22	Nueva entrega recibida para revisión: Balanza comercial de El Salvador con Centroamérica.	2025-04-13 00:31:59.864704	2025-04-14 00:31:59.864704
1098	184	2	Nueva entrega recibida para revisión: Balanza comercial de El Salvador con Centroamérica.	2025-04-13 00:31:59.864704	2025-04-14 00:31:59.864704
1100	184	175	Tu publicación fue retirada del catálogo. Motivo: Los autores pidieron retirar la publicación para enviarla a una revista científica.	2025-07-12 03:41:52.514358	2025-07-13 03:41:52.514358
1125	189	21	Nueva entrega recibida (versión corregida) para revisión: Memoria histórica del conflicto armado contada por habitantes de Morazán.	2025-10-15 00:13:10.19818	2025-10-16 00:13:10.19818
1126	189	3	Nueva entrega recibida (versión corregida) para revisión: Memoria histórica del conflicto armado contada por habitantes de Morazán.	2025-10-15 00:13:10.19818	2025-10-16 00:13:10.19818
1127	189	23	Nueva entrega recibida (versión corregida) para revisión: Memoria histórica del conflicto armado contada por habitantes de Morazán.	2025-10-15 00:13:10.19818	2025-10-16 00:13:10.19818
1128	189	22	Nueva entrega recibida (versión corregida) para revisión: Memoria histórica del conflicto armado contada por habitantes de Morazán.	2025-10-15 00:13:10.19818	2025-10-16 00:13:10.19818
1129	189	2	Nueva entrega recibida (versión corregida) para revisión: Memoria histórica del conflicto armado contada por habitantes de Morazán.	2025-10-15 00:13:10.19818	2025-10-16 00:13:10.19818
1130	189	68	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2025-10-26 21:32:14.534444	2025-10-27 21:32:14.534444
1113	187	21	Nueva entrega recibida (versión corregida) para revisión: Glosario trilingüe de términos agrícolas.	2025-10-22 20:08:42.507032	2025-10-23 20:08:42.507032
1114	187	3	Nueva entrega recibida (versión corregida) para revisión: Glosario trilingüe de términos agrícolas.	2025-10-22 20:08:42.507032	2025-10-23 20:08:42.507032
1115	187	23	Nueva entrega recibida (versión corregida) para revisión: Glosario trilingüe de términos agrícolas.	2025-10-22 20:08:42.507032	2025-10-23 20:08:42.507032
1116	187	22	Nueva entrega recibida (versión corregida) para revisión: Glosario trilingüe de términos agrícolas.	2025-10-22 20:08:42.507032	2025-10-23 20:08:42.507032
1117	187	2	Nueva entrega recibida (versión corregida) para revisión: Glosario trilingüe de términos agrícolas.	2025-10-22 20:08:42.507032	2025-10-23 20:08:42.507032
1142	191	178	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-06-08 12:56:16.22716	2025-06-09 12:56:16.22716
1138	191	3	Nueva entrega recibida para revisión: Niveles de estrés académico en estudiantes de la facultad.	2025-05-25 21:09:25.869552	2025-05-26 21:09:25.869552
1139	191	23	Nueva entrega recibida para revisión: Niveles de estrés académico en estudiantes de la facultad.	2025-05-25 21:09:25.869552	2025-05-26 21:09:25.869552
1140	191	22	Nueva entrega recibida para revisión: Niveles de estrés académico en estudiantes de la facultad.	2025-05-25 21:09:25.869552	2025-05-26 21:09:25.869552
1131	190	21	Nueva entrega recibida para revisión: Mapas digitales para enseñar la geografía de El Salvador.	2025-11-14 18:29:33.860697	2025-11-15 18:29:33.860697
1132	190	3	Nueva entrega recibida para revisión: Mapas digitales para enseñar la geografía de El Salvador.	2025-11-14 18:29:33.860697	2025-11-15 18:29:33.860697
1133	190	23	Nueva entrega recibida para revisión: Mapas digitales para enseñar la geografía de El Salvador.	2025-11-14 18:29:33.860697	2025-11-15 18:29:33.860697
1134	190	22	Nueva entrega recibida para revisión: Mapas digitales para enseñar la geografía de El Salvador.	2025-11-14 18:29:33.860697	2025-11-15 18:29:33.860697
1135	190	2	Nueva entrega recibida para revisión: Mapas digitales para enseñar la geografía de El Salvador.	2025-11-14 18:29:33.860697	2025-11-15 18:29:33.860697
1141	191	2	Nueva entrega recibida para revisión: Niveles de estrés académico en estudiantes de la facultad.	2025-05-25 21:09:25.869552	2025-05-26 21:09:25.869552
1149	193	21	Nueva entrega recibida para revisión: Adherencia al tratamiento en pacientes con enfermedad renal crónica.	2025-06-15 06:35:37.880731	2025-06-16 06:35:37.880731
1150	193	3	Nueva entrega recibida para revisión: Adherencia al tratamiento en pacientes con enfermedad renal crónica.	2025-06-15 06:35:37.880731	2025-06-16 06:35:37.880731
1151	193	23	Nueva entrega recibida para revisión: Adherencia al tratamiento en pacientes con enfermedad renal crónica.	2025-06-15 06:35:37.880731	2025-06-16 06:35:37.880731
1152	193	22	Nueva entrega recibida para revisión: Adherencia al tratamiento en pacientes con enfermedad renal crónica.	2025-06-15 06:35:37.880731	2025-06-16 06:35:37.880731
1153	193	2	Nueva entrega recibida para revisión: Adherencia al tratamiento en pacientes con enfermedad renal crónica.	2025-06-15 06:35:37.880731	2025-06-16 06:35:37.880731
1242	208	23	Nueva entrega recibida para revisión: Juegos matemáticos para el cálculo mental.	2025-03-22 03:42:44.641749	2025-03-23 03:42:44.641749
1243	208	22	Nueva entrega recibida para revisión: Juegos matemáticos para el cálculo mental.	2025-03-22 03:42:44.641749	2025-03-23 03:42:44.641749
1244	208	2	Nueva entrega recibida para revisión: Juegos matemáticos para el cálculo mental.	2025-03-22 03:42:44.641749	2025-03-23 03:42:44.641749
1246	209	21	Nueva entrega recibida para revisión: Participación de las familias en la educación parvularia.	2025-06-18 03:31:49.649231	2025-06-19 03:31:49.649231
1146	192	22	Nueva entrega recibida para revisión: Complicaciones del dengue en niños atendidos en el hospital regional.	2025-04-02 21:30:55.918236	2025-04-03 21:30:55.918236
1147	192	2	Nueva entrega recibida para revisión: Complicaciones del dengue en niños atendidos en el hospital regional.	2025-04-02 21:30:55.918236	2025-04-03 21:30:55.918236
1154	193	180	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-06-20 19:28:11.234439	2025-06-21 19:28:11.234439
1160	194	181	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-06-11 04:22:22.34237	2025-06-12 04:22:22.34237
1166	195	112	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-08-05 01:35:18.410546	2025-08-06 01:35:18.410546
1172	196	182	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-09-09 08:24:25.479386	2025-09-10 08:24:25.479386
1215	203	186	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-09-15 18:46:59.687337	2025-09-16 18:46:59.687337
1173	197	21	Nueva entrega recibida para revisión: Control estadístico de calidad en el llenado de botellas.	2025-04-14 01:53:55.163071	2025-04-15 01:53:55.163071
1174	197	3	Nueva entrega recibida para revisión: Control estadístico de calidad en el llenado de botellas.	2025-04-14 01:53:55.163071	2025-04-15 01:53:55.163071
1175	197	23	Nueva entrega recibida para revisión: Control estadístico de calidad en el llenado de botellas.	2025-04-14 01:53:55.163071	2025-04-15 01:53:55.163071
1176	197	22	Nueva entrega recibida para revisión: Control estadístico de calidad en el llenado de botellas.	2025-04-14 01:53:55.163071	2025-04-15 01:53:55.163071
1177	197	2	Nueva entrega recibida para revisión: Control estadístico de calidad en el llenado de botellas.	2025-04-14 01:53:55.163071	2025-04-15 01:53:55.163071
1184	198	183	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-06-18 08:52:01.530866	2025-06-19 08:52:01.530866
1221	204	187	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-04-09 13:20:49.5887	2025-04-10 13:20:49.5887
1190	199	155	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-10-30 05:07:06.153858	2025-10-31 05:07:06.153858
1203	202	21	Nueva entrega recibida para revisión: Campaña de mercadeo digital para una cooperativa de productores.	2025-07-18 03:28:03.378001	2025-07-19 03:28:03.378001
1240	208	21	Nueva entrega recibida para revisión: Juegos matemáticos para el cálculo mental.	2025-03-22 03:42:44.641749	2025-03-23 03:42:44.641749
1241	208	3	Nueva entrega recibida para revisión: Juegos matemáticos para el cálculo mental.	2025-03-22 03:42:44.641749	2025-03-23 03:42:44.641749
1204	202	3	Nueva entrega recibida para revisión: Campaña de mercadeo digital para una cooperativa de productores.	2025-07-18 03:28:03.378001	2025-07-19 03:28:03.378001
1205	202	23	Nueva entrega recibida para revisión: Campaña de mercadeo digital para una cooperativa de productores.	2025-07-18 03:28:03.378001	2025-07-19 03:28:03.378001
1206	202	22	Nueva entrega recibida para revisión: Campaña de mercadeo digital para una cooperativa de productores.	2025-07-18 03:28:03.378001	2025-07-19 03:28:03.378001
1207	202	2	Nueva entrega recibida para revisión: Campaña de mercadeo digital para una cooperativa de productores.	2025-07-18 03:28:03.378001	2025-07-19 03:28:03.378001
1209	202	185	Tu publicación fue retirada del catálogo. Motivo: Los autores pidieron retirar la publicación para enviarla a una revista científica.	2025-09-03 15:05:12.067652	2025-09-04 15:05:12.067652
1222	205	21	Nueva entrega recibida para revisión: Cambios en la vida rural a partir de las remesas.	2025-07-19 21:12:16.208369	2025-07-20 21:12:16.208369
1223	205	3	Nueva entrega recibida para revisión: Cambios en la vida rural a partir de las remesas.	2025-07-19 21:12:16.208369	2025-07-20 21:12:16.208369
1224	205	23	Nueva entrega recibida para revisión: Cambios en la vida rural a partir de las remesas.	2025-07-19 21:12:16.208369	2025-07-20 21:12:16.208369
1225	205	22	Nueva entrega recibida para revisión: Cambios en la vida rural a partir de las remesas.	2025-07-19 21:12:16.208369	2025-07-20 21:12:16.208369
1226	205	2	Nueva entrega recibida para revisión: Cambios en la vida rural a partir de las remesas.	2025-07-19 21:12:16.208369	2025-07-20 21:12:16.208369
1228	206	21	Nueva entrega recibida para revisión: Mapa de actores sociales de un municipio de Morazán.	2025-04-01 03:10:30.323196	2025-04-02 03:10:30.323196
1229	206	3	Nueva entrega recibida para revisión: Mapa de actores sociales de un municipio de Morazán.	2025-04-01 03:10:30.323196	2025-04-02 03:10:30.323196
1230	206	23	Nueva entrega recibida para revisión: Mapa de actores sociales de un municipio de Morazán.	2025-04-01 03:10:30.323196	2025-04-02 03:10:30.323196
1231	206	22	Nueva entrega recibida para revisión: Mapa de actores sociales de un municipio de Morazán.	2025-04-01 03:10:30.323196	2025-04-02 03:10:30.323196
1232	206	2	Nueva entrega recibida para revisión: Mapa de actores sociales de un municipio de Morazán.	2025-04-01 03:10:30.323196	2025-04-02 03:10:30.323196
1233	206	189	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2025-04-03 13:56:15.659404	2025-04-04 13:56:15.659404
1239	207	189	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-04-15 14:11:07.342423	2025-04-16 14:11:07.342423
1197	201	21	Nueva entrega recibida (versión corregida) para revisión: Investigación de mercado para una cafetería universitaria.	2025-09-21 04:23:22.38772	2025-09-22 04:23:22.38772
1198	201	3	Nueva entrega recibida (versión corregida) para revisión: Investigación de mercado para una cafetería universitaria.	2025-09-21 04:23:22.38772	2025-09-22 04:23:22.38772
1167	196	21	Nueva entrega recibida para revisión: Pronóstico de la demanda para una distribuidora de productos de consumo.	2025-08-29 11:33:05.093157	2025-08-30 11:33:05.093157
1168	196	3	Nueva entrega recibida para revisión: Pronóstico de la demanda para una distribuidora de productos de consumo.	2025-08-29 11:33:05.093157	2025-08-30 11:33:05.093157
1169	196	23	Nueva entrega recibida para revisión: Pronóstico de la demanda para una distribuidora de productos de consumo.	2025-08-29 11:33:05.093157	2025-08-30 11:33:05.093157
1156	194	3	Nueva entrega recibida para revisión: Concepciones erróneas sobre la gravedad en estudiantes de bachillerato.	2025-06-02 06:15:12.965051	2025-06-03 06:15:12.965051
1157	194	23	Nueva entrega recibida para revisión: Concepciones erróneas sobre la gravedad en estudiantes de bachillerato.	2025-06-02 06:15:12.965051	2025-06-03 06:15:12.965051
1158	194	22	Nueva entrega recibida para revisión: Concepciones erróneas sobre la gravedad en estudiantes de bachillerato.	2025-06-02 06:15:12.965051	2025-06-03 06:15:12.965051
1159	194	2	Nueva entrega recibida para revisión: Concepciones erróneas sobre la gravedad en estudiantes de bachillerato.	2025-06-02 06:15:12.965051	2025-06-03 06:15:12.965051
1170	196	22	Nueva entrega recibida para revisión: Pronóstico de la demanda para una distribuidora de productos de consumo.	2025-08-29 11:33:05.093157	2025-08-30 11:33:05.093157
1171	196	2	Nueva entrega recibida para revisión: Pronóstico de la demanda para una distribuidora de productos de consumo.	2025-08-29 11:33:05.093157	2025-08-30 11:33:05.093157
1199	201	23	Nueva entrega recibida (versión corregida) para revisión: Investigación de mercado para una cafetería universitaria.	2025-09-21 04:23:22.38772	2025-09-22 04:23:22.38772
1178	197	130	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-04-18 11:05:01.55985	2025-04-19 11:05:01.55985
1161	195	21	Nueva entrega recibida para revisión: Reducción de desperdicios en una panadería con manufactura esbelta.	2025-07-25 12:02:47.030581	2025-07-26 12:02:47.030581
1162	195	3	Nueva entrega recibida para revisión: Reducción de desperdicios en una panadería con manufactura esbelta.	2025-07-25 12:02:47.030581	2025-07-26 12:02:47.030581
1163	195	23	Nueva entrega recibida para revisión: Reducción de desperdicios en una panadería con manufactura esbelta.	2025-07-25 12:02:47.030581	2025-07-26 12:02:47.030581
1164	195	22	Nueva entrega recibida para revisión: Reducción de desperdicios en una panadería con manufactura esbelta.	2025-07-25 12:02:47.030581	2025-07-26 12:02:47.030581
1165	195	2	Nueva entrega recibida para revisión: Reducción de desperdicios en una panadería con manufactura esbelta.	2025-07-25 12:02:47.030581	2025-07-26 12:02:47.030581
1200	201	22	Nueva entrega recibida (versión corregida) para revisión: Investigación de mercado para una cafetería universitaria.	2025-09-21 04:23:22.38772	2025-09-22 04:23:22.38772
1201	201	2	Nueva entrega recibida (versión corregida) para revisión: Investigación de mercado para una cafetería universitaria.	2025-09-21 04:23:22.38772	2025-09-22 04:23:22.38772
1211	203	3	Nueva entrega recibida para revisión: Análisis estadístico de la lluvia en la zona oriental de 1990 a 2024.	2025-09-10 09:24:52.354145	2025-09-11 09:24:52.354145
1185	199	21	Nueva entrega recibida para revisión: Estrategia de marca para las artesanías de barro de Guatajiagua.	2025-10-17 22:21:43.831697	2025-10-18 22:21:43.831697
1186	199	3	Nueva entrega recibida para revisión: Estrategia de marca para las artesanías de barro de Guatajiagua.	2025-10-17 22:21:43.831697	2025-10-18 22:21:43.831697
1187	199	23	Nueva entrega recibida para revisión: Estrategia de marca para las artesanías de barro de Guatajiagua.	2025-10-17 22:21:43.831697	2025-10-18 22:21:43.831697
1188	199	22	Nueva entrega recibida para revisión: Estrategia de marca para las artesanías de barro de Guatajiagua.	2025-10-17 22:21:43.831697	2025-10-18 22:21:43.831697
1189	199	2	Nueva entrega recibida para revisión: Estrategia de marca para las artesanías de barro de Guatajiagua.	2025-10-17 22:21:43.831697	2025-10-18 22:21:43.831697
1179	198	21	Nueva entrega recibida para revisión: Plan de exportación de café de especialidad de Morazán a Canadá.	2025-06-08 15:31:29.209648	2025-06-09 15:31:29.209648
1180	198	3	Nueva entrega recibida para revisión: Plan de exportación de café de especialidad de Morazán a Canadá.	2025-06-08 15:31:29.209648	2025-06-09 15:31:29.209648
1181	198	23	Nueva entrega recibida para revisión: Plan de exportación de café de especialidad de Morazán a Canadá.	2025-06-08 15:31:29.209648	2025-06-09 15:31:29.209648
1182	198	22	Nueva entrega recibida para revisión: Plan de exportación de café de especialidad de Morazán a Canadá.	2025-06-08 15:31:29.209648	2025-06-09 15:31:29.209648
1183	198	2	Nueva entrega recibida para revisión: Plan de exportación de café de especialidad de Morazán a Canadá.	2025-06-08 15:31:29.209648	2025-06-09 15:31:29.209648
1208	202	185	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-07-30 10:56:02.740964	2025-07-31 10:56:02.740964
1212	203	23	Nueva entrega recibida para revisión: Análisis estadístico de la lluvia en la zona oriental de 1990 a 2024.	2025-09-10 09:24:52.354145	2025-09-11 09:24:52.354145
1213	203	22	Nueva entrega recibida para revisión: Análisis estadístico de la lluvia en la zona oriental de 1990 a 2024.	2025-09-10 09:24:52.354145	2025-09-11 09:24:52.354145
1214	203	2	Nueva entrega recibida para revisión: Análisis estadístico de la lluvia en la zona oriental de 1990 a 2024.	2025-09-10 09:24:52.354145	2025-09-11 09:24:52.354145
1216	204	21	Nueva entrega recibida para revisión: Cumplimiento de obligaciones tributarias de los pequeños contribuyentes.	2025-04-05 19:52:49.26146	2025-04-06 19:52:49.26146
1217	204	3	Nueva entrega recibida para revisión: Cumplimiento de obligaciones tributarias de los pequeños contribuyentes.	2025-04-05 19:52:49.26146	2025-04-06 19:52:49.26146
1218	204	23	Nueva entrega recibida para revisión: Cumplimiento de obligaciones tributarias de los pequeños contribuyentes.	2025-04-05 19:52:49.26146	2025-04-06 19:52:49.26146
1219	204	22	Nueva entrega recibida para revisión: Cumplimiento de obligaciones tributarias de los pequeños contribuyentes.	2025-04-05 19:52:49.26146	2025-04-06 19:52:49.26146
1220	204	2	Nueva entrega recibida para revisión: Cumplimiento de obligaciones tributarias de los pequeños contribuyentes.	2025-04-05 19:52:49.26146	2025-04-06 19:52:49.26146
1227	205	188	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-07-30 23:35:05.641679	2025-07-31 23:35:05.641679
1234	207	21	Nueva entrega recibida (versión corregida) para revisión: Mapa de actores sociales de un municipio de Morazán.	2025-04-05 19:15:35.007497	2025-04-06 19:15:35.007497
1245	208	190	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-03-29 22:38:45.010316	2025-03-30 22:38:45.010316
1257	210	192	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-05-03 01:11:27.629305	2025-05-04 01:11:27.629305
1254	210	23	Nueva entrega recibida para revisión: Riego por goteo en el cultivo de chile dulce.	2025-04-25 16:03:27.280352	2025-04-26 16:03:27.280352
1255	210	22	Nueva entrega recibida para revisión: Riego por goteo en el cultivo de chile dulce.	2025-04-25 16:03:27.280352	2025-04-26 16:03:27.280352
1256	210	2	Nueva entrega recibida para revisión: Riego por goteo en el cultivo de chile dulce.	2025-04-25 16:03:27.280352	2025-04-26 16:03:27.280352
1263	211	193	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-08-09 03:16:37.290912	2025-08-10 03:16:37.290912
1281	214	195	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-09-27 01:06:36.188436	2025-09-28 01:06:36.188436
1311	220	21	Nueva entrega recibida para revisión: Incidencia de náuseas y vómitos postoperatorios en cirugía laparoscópica.	2026-06-05 00:40:47.60319	2026-06-06 00:40:47.60319
1283	215	21	Nueva entrega recibida para revisión: Actividad sísmica de la cadena volcánica del oriente.	2025-10-26 02:31:51.789741	2025-10-27 02:31:51.789741
1284	215	3	Nueva entrega recibida para revisión: Actividad sísmica de la cadena volcánica del oriente.	2025-10-26 02:31:51.789741	2025-10-27 02:31:51.789741
1285	215	23	Nueva entrega recibida para revisión: Actividad sísmica de la cadena volcánica del oriente.	2025-10-26 02:31:51.789741	2025-10-27 02:31:51.789741
1286	215	22	Nueva entrega recibida para revisión: Actividad sísmica de la cadena volcánica del oriente.	2025-10-26 02:31:51.789741	2025-10-27 02:31:51.789741
1287	215	2	Nueva entrega recibida para revisión: Actividad sísmica de la cadena volcánica del oriente.	2025-10-26 02:31:51.789741	2025-10-27 02:31:51.789741
1312	220	3	Nueva entrega recibida para revisión: Incidencia de náuseas y vómitos postoperatorios en cirugía laparoscópica.	2026-06-05 00:40:47.60319	2026-06-06 00:40:47.60319
1313	220	23	Nueva entrega recibida para revisión: Incidencia de náuseas y vómitos postoperatorios en cirugía laparoscópica.	2026-06-05 00:40:47.60319	2026-06-06 00:40:47.60319
1314	220	22	Nueva entrega recibida para revisión: Incidencia de náuseas y vómitos postoperatorios en cirugía laparoscópica.	2026-06-05 00:40:47.60319	2026-06-06 00:40:47.60319
1315	220	2	Nueva entrega recibida para revisión: Incidencia de náuseas y vómitos postoperatorios en cirugía laparoscópica.	2026-06-05 00:40:47.60319	2026-06-06 00:40:47.60319
1316	220	201	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2026-06-10 20:37:27.909515	2026-06-11 20:37:27.909515
1317	221	21	Nueva entrega recibida (versión corregida) para revisión: Incidencia de náuseas y vómitos postoperatorios en cirugía laparoscópica.	2026-06-17 22:51:59.246045	2026-06-18 22:51:59.246045
1318	221	3	Nueva entrega recibida (versión corregida) para revisión: Incidencia de náuseas y vómitos postoperatorios en cirugía laparoscópica.	2026-06-17 22:51:59.246045	2026-06-18 22:51:59.246045
1319	221	23	Nueva entrega recibida (versión corregida) para revisión: Incidencia de náuseas y vómitos postoperatorios en cirugía laparoscópica.	2026-06-17 22:51:59.246045	2026-06-18 22:51:59.246045
1320	221	22	Nueva entrega recibida (versión corregida) para revisión: Incidencia de náuseas y vómitos postoperatorios en cirugía laparoscópica.	2026-06-17 22:51:59.246045	2026-06-18 22:51:59.246045
1335	224	21	Nueva entrega recibida para revisión: Aprendizaje de vocabulario en inglés mediante aplicaciones móviles.	2026-09-06 17:00:14.551198	2026-09-07 17:00:14.551198
1336	224	3	Nueva entrega recibida para revisión: Aprendizaje de vocabulario en inglés mediante aplicaciones móviles.	2026-09-06 17:00:14.551198	2026-09-07 17:00:14.551198
1337	224	23	Nueva entrega recibida para revisión: Aprendizaje de vocabulario en inglés mediante aplicaciones móviles.	2026-09-06 17:00:14.551198	2026-09-07 17:00:14.551198
1338	224	22	Nueva entrega recibida para revisión: Aprendizaje de vocabulario en inglés mediante aplicaciones móviles.	2026-09-06 17:00:14.551198	2026-09-07 17:00:14.551198
1339	224	2	Nueva entrega recibida para revisión: Aprendizaje de vocabulario en inglés mediante aplicaciones móviles.	2026-09-06 17:00:14.551198	2026-09-07 17:00:14.551198
1260	211	23	Nueva entrega recibida para revisión: Abono orgánico elaborado con residuos de la cosecha de café.	2025-08-03 05:05:21.942469	2025-08-04 05:05:21.942469
1261	211	22	Nueva entrega recibida para revisión: Abono orgánico elaborado con residuos de la cosecha de café.	2025-08-03 05:05:21.942469	2025-08-04 05:05:21.942469
1262	211	2	Nueva entrega recibida para revisión: Abono orgánico elaborado con residuos de la cosecha de café.	2025-08-03 05:05:21.942469	2025-08-04 05:05:21.942469
1266	212	23	Nueva entrega recibida para revisión: Fertilidad de los suelos de las parcelas de la estación experimental.	2025-03-04 12:02:37.59221	2025-03-05 12:02:37.59221
1267	212	22	Nueva entrega recibida para revisión: Fertilidad de los suelos de las parcelas de la estación experimental.	2025-03-04 12:02:37.59221	2025-03-05 12:02:37.59221
1268	212	2	Nueva entrega recibida para revisión: Fertilidad de los suelos de las parcelas de la estación experimental.	2025-03-04 12:02:37.59221	2025-03-05 12:02:37.59221
1269	212	194	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2025-03-08 02:41:59.911335	2025-03-09 02:41:59.911335
1270	213	21	Nueva entrega recibida (versión corregida) para revisión: Fertilidad de los suelos de las parcelas de la estación experimental.	2025-03-21 00:03:50.255117	2025-03-22 00:03:50.255117
1271	213	3	Nueva entrega recibida (versión corregida) para revisión: Fertilidad de los suelos de las parcelas de la estación experimental.	2025-03-21 00:03:50.255117	2025-03-22 00:03:50.255117
1272	213	23	Nueva entrega recibida (versión corregida) para revisión: Fertilidad de los suelos de las parcelas de la estación experimental.	2025-03-21 00:03:50.255117	2025-03-22 00:03:50.255117
1273	213	22	Nueva entrega recibida (versión corregida) para revisión: Fertilidad de los suelos de las parcelas de la estación experimental.	2025-03-21 00:03:50.255117	2025-03-22 00:03:50.255117
1274	213	2	Nueva entrega recibida (versión corregida) para revisión: Fertilidad de los suelos de las parcelas de la estación experimental.	2025-03-21 00:03:50.255117	2025-03-22 00:03:50.255117
1275	213	194	Decisión del supervisor: Rechazada. Este trabajo ya fue registrado en el repositorio por otro integrante del grupo.	2025-04-03 23:46:47.564293	2025-04-04 23:46:47.564293
1276	214	21	Nueva entrega recibida para revisión: Medición de la radiación solar en San Miguel con instrumentación de bajo costo.	2025-09-14 12:08:13.864117	2025-09-15 12:08:13.864117
1277	214	3	Nueva entrega recibida para revisión: Medición de la radiación solar en San Miguel con instrumentación de bajo costo.	2025-09-14 12:08:13.864117	2025-09-15 12:08:13.864117
1278	214	23	Nueva entrega recibida para revisión: Medición de la radiación solar en San Miguel con instrumentación de bajo costo.	2025-09-14 12:08:13.864117	2025-09-15 12:08:13.864117
1279	214	22	Nueva entrega recibida para revisión: Medición de la radiación solar en San Miguel con instrumentación de bajo costo.	2025-09-14 12:08:13.864117	2025-09-15 12:08:13.864117
1280	214	2	Nueva entrega recibida para revisión: Medición de la radiación solar en San Miguel con instrumentación de bajo costo.	2025-09-14 12:08:13.864117	2025-09-15 12:08:13.864117
1282	214	195	Tu publicación fue retirada del catálogo. Motivo: La institución colaboradora solicitó no divulgar los resultados.	2025-11-02 07:28:18.475182	2025-11-03 07:28:18.475182
1371	230	3	Nueva entrega recibida para revisión: Efectos del uso de redes sociales en la autoestima de adolescentes.	2026-07-17 04:48:04.255202	2026-07-18 04:48:04.255202
1372	230	23	Nueva entrega recibida para revisión: Efectos del uso de redes sociales en la autoestima de adolescentes.	2026-07-17 04:48:04.255202	2026-07-18 04:48:04.255202
1373	230	22	Nueva entrega recibida para revisión: Efectos del uso de redes sociales en la autoestima de adolescentes.	2026-07-17 04:48:04.255202	2026-07-18 04:48:04.255202
1374	230	2	Nueva entrega recibida para revisión: Efectos del uso de redes sociales en la autoestima de adolescentes.	2026-07-17 04:48:04.255202	2026-07-18 04:48:04.255202
1509	254	3	Nueva entrega recibida (actualización de un trabajo publicado) para revisión: Movimiento amortiguado de un sistema masa-resorte.	2026-10-29 13:42:37.939713	2026-10-30 13:42:37.939713
1510	254	23	Nueva entrega recibida (actualización de un trabajo publicado) para revisión: Movimiento amortiguado de un sistema masa-resorte.	2026-10-29 13:42:37.939713	2026-10-30 13:42:37.939713
1511	254	22	Nueva entrega recibida (actualización de un trabajo publicado) para revisión: Movimiento amortiguado de un sistema masa-resorte.	2026-10-29 13:42:37.939713	2026-10-30 13:42:37.939713
1500	252	2	Nueva entrega recibida para revisión: Propiedades ópticas de películas delgadas.	2026-04-28 11:40:15.334293	2026-04-29 11:40:15.334293
2125	356	21	Nueva entrega recibida para revisión: Propuesta de mobiliario urbano para el parque central.	2025-05-24 05:35:09.451774	2025-05-25 05:35:09.451774
2124	355	289	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-10-21 01:10:15.73329	2025-10-22 01:10:15.73329
1654	278	23	Nueva entrega recibida (versión corregida) para revisión: Errores frecuentes en la traducción de textos técnicos al inglés.	2021-09-14 23:28:44.366628	2021-09-15 23:28:44.366628
1655	278	22	Nueva entrega recibida (versión corregida) para revisión: Errores frecuentes en la traducción de textos técnicos al inglés.	2021-09-14 23:28:44.366628	2021-09-15 23:28:44.366628
2156	361	3	Nueva entrega recibida para revisión: Inclusión de niños con discapacidad en la educación parvularia.	2025-04-19 11:36:19.607911	2025-04-20 11:36:19.607911
2157	361	23	Nueva entrega recibida para revisión: Inclusión de niños con discapacidad en la educación parvularia.	2025-04-19 11:36:19.607911	2025-04-20 11:36:19.607911
2158	361	22	Nueva entrega recibida para revisión: Inclusión de niños con discapacidad en la educación parvularia.	2025-04-19 11:36:19.607911	2025-04-20 11:36:19.607911
2159	361	2	Nueva entrega recibida para revisión: Inclusión de niños con discapacidad en la educación parvularia.	2025-04-19 11:36:19.607911	2025-04-20 11:36:19.607911
2160	361	293	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2025-05-02 18:21:41.913122	2025-05-03 18:21:41.913122
2174	364	21	Nueva entrega recibida para revisión: Análisis de fallas en ejes de transmisión de maquinaria agrícola.	2026-03-21 22:48:51.768738	2026-03-22 22:48:51.768738
2175	364	3	Nueva entrega recibida para revisión: Análisis de fallas en ejes de transmisión de maquinaria agrícola.	2026-03-21 22:48:51.768738	2026-03-22 22:48:51.768738
2176	364	23	Nueva entrega recibida para revisión: Análisis de fallas en ejes de transmisión de maquinaria agrícola.	2026-03-21 22:48:51.768738	2026-03-22 22:48:51.768738
2163	362	23	Nueva entrega recibida para revisión: Producción de hongos comestibles con residuos agrícolas.	2025-05-08 14:55:45.197425	2025-05-09 14:55:45.197425
2164	362	22	Nueva entrega recibida para revisión: Producción de hongos comestibles con residuos agrícolas.	2025-05-08 14:55:45.197425	2025-05-09 14:55:45.197425
2165	362	2	Nueva entrega recibida para revisión: Producción de hongos comestibles con residuos agrícolas.	2025-05-08 14:55:45.197425	2025-05-09 14:55:45.197425
2166	362	294	Decisión del supervisor: Con correcciones. Incluye a todos los integrantes del grupo como autores.	2025-05-19 02:25:49.506755	2025-05-20 02:25:49.506755
2167	363	21	Nueva entrega recibida (versión corregida) para revisión: Producción de hongos comestibles con residuos agrícolas.	2025-05-29 05:50:35.836683	2025-05-30 05:50:35.836683
2173	363	294	Tu publicación fue retirada del catálogo. Motivo: La institución colaboradora solicitó no divulgar los resultados.	2025-08-10 18:46:42.470739	2025-08-11 18:46:42.470739
2177	364	22	Nueva entrega recibida para revisión: Análisis de fallas en ejes de transmisión de maquinaria agrícola.	2026-03-21 22:48:51.768738	2026-03-22 22:48:51.768738
1697	285	22	Nueva entrega recibida para revisión: Efecto del biochar en la fertilidad del suelo.	2021-04-04 21:36:10.213395	2021-04-05 21:36:10.213395
1698	285	2	Nueva entrega recibida para revisión: Efecto del biochar en la fertilidad del suelo.	2021-04-04 21:36:10.213395	2021-04-05 21:36:10.213395
1699	285	231	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2021-04-11 16:15:44.608741	2021-04-12 16:15:44.608741
1700	285	231	Tu publicación fue retirada del catálogo. Motivo: La institución colaboradora solicitó no divulgar los resultados.	2021-08-02 19:47:22.961175	2021-08-03 19:47:22.961175
1707	287	21	Nueva entrega recibida para revisión: Resiliencia en jóvenes afectados por la violencia.	2022-03-08 09:42:31.377769	2022-03-09 09:42:31.377769
1708	287	3	Nueva entrega recibida para revisión: Resiliencia en jóvenes afectados por la violencia.	2022-03-08 09:42:31.377769	2022-03-09 09:42:31.377769
1709	287	23	Nueva entrega recibida para revisión: Resiliencia en jóvenes afectados por la violencia.	2022-03-08 09:42:31.377769	2022-03-09 09:42:31.377769
1710	287	22	Nueva entrega recibida para revisión: Resiliencia en jóvenes afectados por la violencia.	2022-03-08 09:42:31.377769	2022-03-09 09:42:31.377769
1711	287	2	Nueva entrega recibida para revisión: Resiliencia en jóvenes afectados por la violencia.	2022-03-08 09:42:31.377769	2022-03-09 09:42:31.377769
1706	286	243	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-09-11 09:54:20.710618	2022-09-12 09:54:20.710618
1713	288	21	Nueva entrega recibida para revisión: Construcción de un circuito eléctrico didáctico.	2022-05-24 01:14:17.507287	2022-05-25 01:14:17.507287
1714	288	3	Nueva entrega recibida para revisión: Construcción de un circuito eléctrico didáctico.	2022-05-24 01:14:17.507287	2022-05-25 01:14:17.507287
1715	288	23	Nueva entrega recibida para revisión: Construcción de un circuito eléctrico didáctico.	2022-05-24 01:14:17.507287	2022-05-25 01:14:17.507287
1716	288	22	Nueva entrega recibida para revisión: Construcción de un circuito eléctrico didáctico.	2022-05-24 01:14:17.507287	2022-05-25 01:14:17.507287
1717	288	2	Nueva entrega recibida para revisión: Construcción de un circuito eléctrico didáctico.	2022-05-24 01:14:17.507287	2022-05-25 01:14:17.507287
1712	287	244	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-03-18 19:39:37.782459	2022-03-19 19:39:37.782459
1721	289	23	Nueva entrega recibida para revisión: Gestión financiera de las pequeñas empresas familiares de San Miguel.	2022-10-09 06:06:34.633495	2022-10-10 06:06:34.633495
1722	289	22	Nueva entrega recibida para revisión: Gestión financiera de las pequeñas empresas familiares de San Miguel.	2022-10-09 06:06:34.633495	2022-10-10 06:06:34.633495
1718	288	245	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-06-07 16:10:11.91467	2022-06-08 16:10:11.91467
1734	291	22	Nueva entrega recibida para revisión: Errores en el aprendizaje del álgebra en séptimo grado.	2022-10-20 05:10:29.097327	2022-10-21 05:10:29.097327
1735	291	2	Nueva entrega recibida para revisión: Errores en el aprendizaje del álgebra en séptimo grado.	2022-10-20 05:10:29.097327	2022-10-21 05:10:29.097327
1736	291	247	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2022-10-25 22:44:18.482805	2022-10-26 22:44:18.482805
1737	292	21	Nueva entrega recibida (versión corregida) para revisión: Errores en el aprendizaje del álgebra en séptimo grado.	2022-11-05 17:39:17.881228	2022-11-06 17:39:17.881228
1738	292	3	Nueva entrega recibida (versión corregida) para revisión: Errores en el aprendizaje del álgebra en séptimo grado.	2022-11-05 17:39:17.881228	2022-11-06 17:39:17.881228
1739	292	23	Nueva entrega recibida (versión corregida) para revisión: Errores en el aprendizaje del álgebra en séptimo grado.	2022-11-05 17:39:17.881228	2022-11-06 17:39:17.881228
1740	292	22	Nueva entrega recibida (versión corregida) para revisión: Errores en el aprendizaje del álgebra en séptimo grado.	2022-11-05 17:39:17.881228	2022-11-06 17:39:17.881228
1741	292	2	Nueva entrega recibida (versión corregida) para revisión: Errores en el aprendizaje del álgebra en séptimo grado.	2022-11-05 17:39:17.881228	2022-11-06 17:39:17.881228
1755	295	21	Nueva entrega recibida para revisión: Caracterización de paneles solares en condiciones del oriente del país.	2022-02-26 05:32:53.452918	2022-02-27 05:32:53.452918
1756	295	3	Nueva entrega recibida para revisión: Caracterización de paneles solares en condiciones del oriente del país.	2022-02-26 05:32:53.452918	2022-02-27 05:32:53.452918
1757	295	23	Nueva entrega recibida para revisión: Caracterización de paneles solares en condiciones del oriente del país.	2022-02-26 05:32:53.452918	2022-02-27 05:32:53.452918
1758	295	22	Nueva entrega recibida para revisión: Caracterización de paneles solares en condiciones del oriente del país.	2022-02-26 05:32:53.452918	2022-02-27 05:32:53.452918
1759	295	2	Nueva entrega recibida para revisión: Caracterización de paneles solares en condiciones del oriente del país.	2022-02-26 05:32:53.452918	2022-02-27 05:32:53.452918
1760	295	249	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-02-28 10:50:35.820317	2022-03-01 10:50:35.820317
1864	312	260	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-11-05 12:10:19.499536	2023-11-06 12:10:19.499536
1761	295	249	Tu publicación fue retirada del catálogo. Motivo: Se detectaron datos personales de participantes en el documento.	2022-05-28 13:26:51.146701	2022-05-29 13:26:51.146701
1767	296	250	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2022-07-13 10:05:05.811216	2022-07-14 10:05:05.811216
1775	298	3	Nueva entrega recibida para revisión: Germinación de semillas de árboles nativos para reforestación.	2023-05-02 16:57:50.800545	2023-05-03 16:57:50.800545
1768	297	21	Nueva entrega recibida (versión corregida) para revisión: Medición de la velocidad del sonido con un tubo de resonancia.	2022-07-22 12:33:44.181578	2022-07-23 12:33:44.181578
1769	297	3	Nueva entrega recibida (versión corregida) para revisión: Medición de la velocidad del sonido con un tubo de resonancia.	2022-07-22 12:33:44.181578	2022-07-23 12:33:44.181578
1770	297	23	Nueva entrega recibida (versión corregida) para revisión: Medición de la velocidad del sonido con un tubo de resonancia.	2022-07-22 12:33:44.181578	2022-07-23 12:33:44.181578
1771	297	22	Nueva entrega recibida (versión corregida) para revisión: Medición de la velocidad del sonido con un tubo de resonancia.	2022-07-22 12:33:44.181578	2022-07-23 12:33:44.181578
1772	297	2	Nueva entrega recibida (versión corregida) para revisión: Medición de la velocidad del sonido con un tubo de resonancia.	2022-07-22 12:33:44.181578	2022-07-23 12:33:44.181578
1773	297	250	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2022-08-03 23:01:15.517116	2022-08-04 23:01:15.517116
2208	369	298	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2026-09-04 19:01:47.556188	2026-09-05 19:01:47.556188
1823	306	21	Nueva entrega recibida (versión corregida) para revisión: Percepción de los jóvenes sobre la democracia.	2023-04-06 23:23:19.000766	2023-04-07 23:23:19.000766
1824	306	3	Nueva entrega recibida (versión corregida) para revisión: Percepción de los jóvenes sobre la democracia.	2023-04-06 23:23:19.000766	2023-04-07 23:23:19.000766
1825	306	23	Nueva entrega recibida (versión corregida) para revisión: Percepción de los jóvenes sobre la democracia.	2023-04-06 23:23:19.000766	2023-04-07 23:23:19.000766
1826	306	22	Nueva entrega recibida (versión corregida) para revisión: Percepción de los jóvenes sobre la democracia.	2023-04-06 23:23:19.000766	2023-04-07 23:23:19.000766
1805	303	21	Nueva entrega recibida para revisión: Acceso al crédito de la micro y pequeña empresa en San Miguel.	2023-07-16 01:33:16.504915	2023-07-17 01:33:16.504915
1806	303	3	Nueva entrega recibida para revisión: Acceso al crédito de la micro y pequeña empresa en San Miguel.	2023-07-16 01:33:16.504915	2023-07-17 01:33:16.504915
1807	303	23	Nueva entrega recibida para revisión: Acceso al crédito de la micro y pequeña empresa en San Miguel.	2023-07-16 01:33:16.504915	2023-07-17 01:33:16.504915
1808	303	22	Nueva entrega recibida para revisión: Acceso al crédito de la micro y pequeña empresa en San Miguel.	2023-07-16 01:33:16.504915	2023-07-17 01:33:16.504915
1809	303	2	Nueva entrega recibida para revisión: Acceso al crédito de la micro y pequeña empresa en San Miguel.	2023-07-16 01:33:16.504915	2023-07-17 01:33:16.504915
1810	303	254	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-07-18 11:47:57.88962	2023-07-19 11:47:57.88962
1827	306	2	Nueva entrega recibida (versión corregida) para revisión: Percepción de los jóvenes sobre la democracia.	2023-04-06 23:23:19.000766	2023-04-07 23:23:19.000766
1811	304	21	Nueva entrega recibida para revisión: Interpretación simultánea en un congreso académico simulado.	2023-08-10 13:34:19.574491	2023-08-11 13:34:19.574491
1812	304	3	Nueva entrega recibida para revisión: Interpretación simultánea en un congreso académico simulado.	2023-08-10 13:34:19.574491	2023-08-11 13:34:19.574491
1813	304	23	Nueva entrega recibida para revisión: Interpretación simultánea en un congreso académico simulado.	2023-08-10 13:34:19.574491	2023-08-11 13:34:19.574491
1814	304	22	Nueva entrega recibida para revisión: Interpretación simultánea en un congreso académico simulado.	2023-08-10 13:34:19.574491	2023-08-11 13:34:19.574491
1815	304	2	Nueva entrega recibida para revisión: Interpretación simultánea en un congreso académico simulado.	2023-08-10 13:34:19.574491	2023-08-11 13:34:19.574491
1816	304	238	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-08-12 23:41:39.949628	2023-08-13 23:41:39.949628
1829	307	21	Nueva entrega recibida para revisión: Simulación de un sistema de colas en una agencia bancaria.	2023-08-10 07:50:35.667569	2023-08-11 07:50:35.667569
1830	307	3	Nueva entrega recibida para revisión: Simulación de un sistema de colas en una agencia bancaria.	2023-08-10 07:50:35.667569	2023-08-11 07:50:35.667569
1831	307	23	Nueva entrega recibida para revisión: Simulación de un sistema de colas en una agencia bancaria.	2023-08-10 07:50:35.667569	2023-08-11 07:50:35.667569
1832	307	22	Nueva entrega recibida para revisión: Simulación de un sistema de colas en una agencia bancaria.	2023-08-10 07:50:35.667569	2023-08-11 07:50:35.667569
1833	307	2	Nueva entrega recibida para revisión: Simulación de un sistema de colas en una agencia bancaria.	2023-08-10 07:50:35.667569	2023-08-11 07:50:35.667569
1835	308	21	Nueva entrega recibida para revisión: Impacto de la reforma fiscal en las pequeñas empresas.	2023-08-12 18:14:29.679107	2023-08-13 18:14:29.679107
1836	308	3	Nueva entrega recibida para revisión: Impacto de la reforma fiscal en las pequeñas empresas.	2023-08-12 18:14:29.679107	2023-08-13 18:14:29.679107
1837	308	23	Nueva entrega recibida para revisión: Impacto de la reforma fiscal en las pequeñas empresas.	2023-08-12 18:14:29.679107	2023-08-13 18:14:29.679107
1838	308	22	Nueva entrega recibida para revisión: Impacto de la reforma fiscal en las pequeñas empresas.	2023-08-12 18:14:29.679107	2023-08-13 18:14:29.679107
1839	308	2	Nueva entrega recibida para revisión: Impacto de la reforma fiscal en las pequeñas empresas.	2023-08-12 18:14:29.679107	2023-08-13 18:14:29.679107
1828	306	255	Decisión del supervisor: Aprobada. No se publicará porque los autores no autorizaron la difusión.	2023-04-19 21:39:59.341956	2023-04-20 21:39:59.341956
1834	307	222	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-08-16 10:20:50.04425	2023-08-17 10:20:50.04425
1841	309	21	Nueva entrega recibida para revisión: Juventud rural y oportunidades de empleo en el oriente.	2023-06-05 13:07:19.725842	2023-06-06 13:07:19.725842
1842	309	3	Nueva entrega recibida para revisión: Juventud rural y oportunidades de empleo en el oriente.	2023-06-05 13:07:19.725842	2023-06-06 13:07:19.725842
1843	309	23	Nueva entrega recibida para revisión: Juventud rural y oportunidades de empleo en el oriente.	2023-06-05 13:07:19.725842	2023-06-06 13:07:19.725842
1844	309	22	Nueva entrega recibida para revisión: Juventud rural y oportunidades de empleo en el oriente.	2023-06-05 13:07:19.725842	2023-06-06 13:07:19.725842
1840	308	256	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-08-17 11:51:56.052069	2023-08-18 11:51:56.052069
1855	311	23	Nueva entrega recibida para revisión: Plan de transporte para una empresa exportadora de frutas.	2023-11-28 15:38:39.416847	2023-11-29 15:38:39.416847
1856	311	22	Nueva entrega recibida para revisión: Plan de transporte para una empresa exportadora de frutas.	2023-11-28 15:38:39.416847	2023-11-29 15:38:39.416847
1857	311	2	Nueva entrega recibida para revisión: Plan de transporte para una empresa exportadora de frutas.	2023-11-28 15:38:39.416847	2023-11-29 15:38:39.416847
1858	311	259	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2023-12-11 22:33:55.808077	2023-12-12 22:33:55.808077
1860	312	3	Nueva entrega recibida para revisión: Huerto escolar para niños de cinco años.	2023-10-25 10:56:51.136828	2023-10-26 10:56:51.136828
1861	312	23	Nueva entrega recibida para revisión: Huerto escolar para niños de cinco años.	2023-10-25 10:56:51.136828	2023-10-26 10:56:51.136828
1862	312	22	Nueva entrega recibida para revisión: Huerto escolar para niños de cinco años.	2023-10-25 10:56:51.136828	2023-10-26 10:56:51.136828
1863	312	2	Nueva entrega recibida para revisión: Huerto escolar para niños de cinco años.	2023-10-25 10:56:51.136828	2023-10-26 10:56:51.136828
1870	313	261	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-03-11 17:15:30.536862	2024-03-12 17:15:30.536862
1871	314	21	Nueva entrega recibida para revisión: Herbario escolar con plantas de la zona oriental.	2024-10-13 12:06:25.19386	2024-10-14 12:06:25.19386
1872	314	3	Nueva entrega recibida para revisión: Herbario escolar con plantas de la zona oriental.	2024-10-13 12:06:25.19386	2024-10-14 12:06:25.19386
1873	314	23	Nueva entrega recibida para revisión: Herbario escolar con plantas de la zona oriental.	2024-10-13 12:06:25.19386	2024-10-14 12:06:25.19386
1874	314	22	Nueva entrega recibida para revisión: Herbario escolar con plantas de la zona oriental.	2024-10-13 12:06:25.19386	2024-10-14 12:06:25.19386
1875	314	2	Nueva entrega recibida para revisión: Herbario escolar con plantas de la zona oriental.	2024-10-13 12:06:25.19386	2024-10-14 12:06:25.19386
1876	314	262	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-10-24 06:00:26.57973	2024-10-25 06:00:26.57973
1879	315	23	Nueva entrega recibida para revisión: Polinizadores en cultivos de café de la zona oriental.	2024-03-12 13:16:23.610962	2024-03-13 13:16:23.610962
1880	315	22	Nueva entrega recibida para revisión: Polinizadores en cultivos de café de la zona oriental.	2024-03-12 13:16:23.610962	2024-03-13 13:16:23.610962
1881	315	2	Nueva entrega recibida para revisión: Polinizadores en cultivos de café de la zona oriental.	2024-03-12 13:16:23.610962	2024-03-13 13:16:23.610962
1882	315	263	Decisión del supervisor: Con correcciones. Amplía la descripción de la metodología en el resumen.	2024-03-19 17:04:56.994633	2024-03-20 17:04:56.994633
1883	316	21	Nueva entrega recibida (versión corregida) para revisión: Polinizadores en cultivos de café de la zona oriental.	2024-03-22 07:28:25.409395	2024-03-23 07:28:25.409395
1884	316	3	Nueva entrega recibida (versión corregida) para revisión: Polinizadores en cultivos de café de la zona oriental.	2024-03-22 07:28:25.409395	2024-03-23 07:28:25.409395
1885	316	23	Nueva entrega recibida (versión corregida) para revisión: Polinizadores en cultivos de café de la zona oriental.	2024-03-22 07:28:25.409395	2024-03-23 07:28:25.409395
1886	316	22	Nueva entrega recibida (versión corregida) para revisión: Polinizadores en cultivos de café de la zona oriental.	2024-03-22 07:28:25.409395	2024-03-23 07:28:25.409395
1901	318	264	Tu publicación fue retirada del catálogo. Motivo: La institución colaboradora solicitó no divulgar los resultados.	2024-04-26 09:50:04.797943	2024-04-27 09:50:04.797943
1902	319	21	Nueva entrega recibida para revisión: Dolor postoperatorio en pacientes con bloqueo de plexo braquial.	2024-04-28 03:00:32.144799	2024-04-29 03:00:32.144799
1887	316	2	Nueva entrega recibida (versión corregida) para revisión: Polinizadores en cultivos de café de la zona oriental.	2024-03-22 07:28:25.409395	2024-03-23 07:28:25.409395
1888	316	263	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-04-03 04:47:29.80798	2024-04-04 04:47:29.80798
1903	319	3	Nueva entrega recibida para revisión: Dolor postoperatorio en pacientes con bloqueo de plexo braquial.	2024-04-28 03:00:32.144799	2024-04-29 03:00:32.144799
1904	319	23	Nueva entrega recibida para revisión: Dolor postoperatorio en pacientes con bloqueo de plexo braquial.	2024-04-28 03:00:32.144799	2024-04-29 03:00:32.144799
1905	319	22	Nueva entrega recibida para revisión: Dolor postoperatorio en pacientes con bloqueo de plexo braquial.	2024-04-28 03:00:32.144799	2024-04-29 03:00:32.144799
1906	319	2	Nueva entrega recibida para revisión: Dolor postoperatorio en pacientes con bloqueo de plexo braquial.	2024-04-28 03:00:32.144799	2024-04-29 03:00:32.144799
1937	324	253	Decisión del supervisor: Con correcciones. Revisa la redacción del título; debe indicar el lugar donde se hizo el estudio.	2024-09-02 12:42:15.683072	2024-09-03 12:42:15.683072
1939	325	3	Nueva entrega recibida (versión corregida) para revisión: Pausas activas para el personal administrativo de la facultad.	2024-09-16 16:29:21.047655	2024-09-17 16:29:21.047655
1940	325	23	Nueva entrega recibida (versión corregida) para revisión: Pausas activas para el personal administrativo de la facultad.	2024-09-16 16:29:21.047655	2024-09-17 16:29:21.047655
1941	325	22	Nueva entrega recibida (versión corregida) para revisión: Pausas activas para el personal administrativo de la facultad.	2024-09-16 16:29:21.047655	2024-09-17 16:29:21.047655
1942	325	2	Nueva entrega recibida (versión corregida) para revisión: Pausas activas para el personal administrativo de la facultad.	2024-09-16 16:29:21.047655	2024-09-17 16:29:21.047655
1951	327	3	Nueva entrega recibida para revisión: Sistema de control de asistencia con reconocimiento facial.	2024-06-22 05:26:37.741439	2024-06-23 05:26:37.741439
1952	327	23	Nueva entrega recibida para revisión: Sistema de control de asistencia con reconocimiento facial.	2024-06-22 05:26:37.741439	2024-06-23 05:26:37.741439
1953	327	22	Nueva entrega recibida para revisión: Sistema de control de asistencia con reconocimiento facial.	2024-06-22 05:26:37.741439	2024-06-23 05:26:37.741439
1954	327	2	Nueva entrega recibida para revisión: Sistema de control de asistencia con reconocimiento facial.	2024-06-22 05:26:37.741439	2024-06-23 05:26:37.741439
1955	327	269	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-06-27 22:14:44.096872	2024-06-28 22:14:44.096872
1964	329	23	Nueva entrega recibida (versión corregida) para revisión: Abordaje de la neumonía adquirida en la comunidad en niños.	2024-07-31 13:16:11.473158	2024-08-01 13:16:11.473158
1965	329	22	Nueva entrega recibida (versión corregida) para revisión: Abordaje de la neumonía adquirida en la comunidad en niños.	2024-07-31 13:16:11.473158	2024-08-01 13:16:11.473158
1966	329	2	Nueva entrega recibida (versión corregida) para revisión: Abordaje de la neumonía adquirida en la comunidad en niños.	2024-07-31 13:16:11.473158	2024-08-01 13:16:11.473158
1967	329	270	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-08-13 22:06:00.842132	2024-08-14 22:06:00.842132
1992	334	21	Nueva entrega recibida para revisión: Las redes de apoyo de las madres solteras en San Miguel.	2024-02-16 03:46:42.993669	2024-02-17 03:46:42.993669
1993	334	3	Nueva entrega recibida para revisión: Las redes de apoyo de las madres solteras en San Miguel.	2024-02-16 03:46:42.993669	2024-02-17 03:46:42.993669
1994	334	23	Nueva entrega recibida para revisión: Las redes de apoyo de las madres solteras en San Miguel.	2024-02-16 03:46:42.993669	2024-02-17 03:46:42.993669
1995	334	22	Nueva entrega recibida para revisión: Las redes de apoyo de las madres solteras en San Miguel.	2024-02-16 03:46:42.993669	2024-02-17 03:46:42.993669
1996	334	2	Nueva entrega recibida para revisión: Las redes de apoyo de las madres solteras en San Miguel.	2024-02-16 03:46:42.993669	2024-02-17 03:46:42.993669
1986	333	21	Nueva entrega recibida para revisión: Elaboración de estados financieros para una tienda de abarrotes.	2024-09-07 15:14:59.290209	2024-09-08 15:14:59.290209
1987	333	3	Nueva entrega recibida para revisión: Elaboración de estados financieros para una tienda de abarrotes.	2024-09-07 15:14:59.290209	2024-09-08 15:14:59.290209
1988	333	23	Nueva entrega recibida para revisión: Elaboración de estados financieros para una tienda de abarrotes.	2024-09-07 15:14:59.290209	2024-09-08 15:14:59.290209
1989	333	22	Nueva entrega recibida para revisión: Elaboración de estados financieros para una tienda de abarrotes.	2024-09-07 15:14:59.290209	2024-09-08 15:14:59.290209
1990	333	2	Nueva entrega recibida para revisión: Elaboración de estados financieros para una tienda de abarrotes.	2024-09-07 15:14:59.290209	2024-09-08 15:14:59.290209
1980	332	21	Nueva entrega recibida para revisión: Diseño de un albergue temporal para emergencias.	2024-09-11 07:56:52.254624	2024-09-12 07:56:52.254624
1981	332	3	Nueva entrega recibida para revisión: Diseño de un albergue temporal para emergencias.	2024-09-11 07:56:52.254624	2024-09-12 07:56:52.254624
1982	332	23	Nueva entrega recibida para revisión: Diseño de un albergue temporal para emergencias.	2024-09-11 07:56:52.254624	2024-09-12 07:56:52.254624
1983	332	22	Nueva entrega recibida para revisión: Diseño de un albergue temporal para emergencias.	2024-09-11 07:56:52.254624	2024-09-12 07:56:52.254624
1984	332	2	Nueva entrega recibida para revisión: Diseño de un albergue temporal para emergencias.	2024-09-11 07:56:52.254624	2024-09-12 07:56:52.254624
1974	331	21	Nueva entrega recibida para revisión: Diseño organizacional de una cooperativa de transporte.	2024-04-23 20:01:25.236263	2024-04-24 20:01:25.236263
1975	331	3	Nueva entrega recibida para revisión: Diseño organizacional de una cooperativa de transporte.	2024-04-23 20:01:25.236263	2024-04-24 20:01:25.236263
1976	331	23	Nueva entrega recibida para revisión: Diseño organizacional de una cooperativa de transporte.	2024-04-23 20:01:25.236263	2024-04-24 20:01:25.236263
1977	331	22	Nueva entrega recibida para revisión: Diseño organizacional de una cooperativa de transporte.	2024-04-23 20:01:25.236263	2024-04-24 20:01:25.236263
1978	331	2	Nueva entrega recibida para revisión: Diseño organizacional de una cooperativa de transporte.	2024-04-23 20:01:25.236263	2024-04-24 20:01:25.236263
1979	331	272	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-05-05 18:49:59.607577	2024-05-06 18:49:59.607577
1985	332	273	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-09-25 11:04:19.625714	2024-09-26 11:04:19.625714
1991	333	274	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-09-20 19:35:52.674112	2024-09-21 19:35:52.674112
1997	334	275	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2024-03-01 15:24:08.337571	2024-03-02 15:24:08.337571
1998	335	21	Nueva entrega recibida (versión corregida) para revisión: Las redes de apoyo de las madres solteras en San Miguel.	2024-03-03 22:50:00.683726	2024-03-04 22:50:00.683726
2003	335	275	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-03-13 20:33:33.056238	2024-03-14 20:33:33.056238
2004	335	275	Tu publicación fue retirada del catálogo. Motivo: Los autores pidieron retirar la publicación para enviarla a una revista científica.	2024-04-03 22:35:57.382813	2024-04-04 22:35:57.382813
2011	337	21	Nueva entrega recibida para revisión: Taller de geometría con origami.	2024-07-07 19:13:54.759753	2024-07-08 19:13:54.759753
2012	337	3	Nueva entrega recibida para revisión: Taller de geometría con origami.	2024-07-07 19:13:54.759753	2024-07-08 19:13:54.759753
2013	337	23	Nueva entrega recibida para revisión: Taller de geometría con origami.	2024-07-07 19:13:54.759753	2024-07-08 19:13:54.759753
2014	337	22	Nueva entrega recibida para revisión: Taller de geometría con origami.	2024-07-07 19:13:54.759753	2024-07-08 19:13:54.759753
2015	337	2	Nueva entrega recibida para revisión: Taller de geometría con origami.	2024-07-07 19:13:54.759753	2024-07-08 19:13:54.759753
2016	337	276	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-07-13 21:20:48.12783	2024-07-14 21:20:48.12783
2005	336	21	Nueva entrega recibida para revisión: Diagnóstico participativo de una comunidad del Bajo Lempa.	2024-11-08 15:30:16.713484	2024-11-09 15:30:16.713484
2006	336	3	Nueva entrega recibida para revisión: Diagnóstico participativo de una comunidad del Bajo Lempa.	2024-11-08 15:30:16.713484	2024-11-09 15:30:16.713484
2007	336	23	Nueva entrega recibida para revisión: Diagnóstico participativo de una comunidad del Bajo Lempa.	2024-11-08 15:30:16.713484	2024-11-09 15:30:16.713484
2008	336	22	Nueva entrega recibida para revisión: Diagnóstico participativo de una comunidad del Bajo Lempa.	2024-11-08 15:30:16.713484	2024-11-09 15:30:16.713484
2009	336	2	Nueva entrega recibida para revisión: Diagnóstico participativo de una comunidad del Bajo Lempa.	2024-11-08 15:30:16.713484	2024-11-09 15:30:16.713484
2010	336	257	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2024-11-14 12:07:10.085487	2024-11-15 12:07:10.085487
2029	340	21	Nueva entrega recibida para revisión: Diseño de la instalación eléctrica de un centro de salud rural.	2025-09-08 11:00:24.514811	2025-09-09 11:00:24.514811
2030	340	3	Nueva entrega recibida para revisión: Diseño de la instalación eléctrica de un centro de salud rural.	2025-09-08 11:00:24.514811	2025-09-09 11:00:24.514811
2023	339	21	Nueva entrega recibida para revisión: Uso del microscopio en la enseñanza de la biología en centros públicos.	2025-05-23 18:53:25.810479	2025-05-24 18:53:25.810479
2024	339	3	Nueva entrega recibida para revisión: Uso del microscopio en la enseñanza de la biología en centros públicos.	2025-05-23 18:53:25.810479	2025-05-24 18:53:25.810479
2025	339	23	Nueva entrega recibida para revisión: Uso del microscopio en la enseñanza de la biología en centros públicos.	2025-05-23 18:53:25.810479	2025-05-24 18:53:25.810479
2026	339	22	Nueva entrega recibida para revisión: Uso del microscopio en la enseñanza de la biología en centros públicos.	2025-05-23 18:53:25.810479	2025-05-24 18:53:25.810479
2027	339	2	Nueva entrega recibida para revisión: Uso del microscopio en la enseñanza de la biología en centros públicos.	2025-05-23 18:53:25.810479	2025-05-24 18:53:25.810479
2028	339	278	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-05-28 16:29:56.184029	2025-05-29 16:29:56.184029
2043	342	23	Nueva entrega recibida (versión corregida) para revisión: Rehabilitación de la rodilla tras lesiones de ligamento cruzado.	2025-10-13 00:06:45.242253	2025-10-14 00:06:45.242253
2051	343	2	Nueva entrega recibida para revisión: Obtención de jabón artesanal a partir de aceites vegetales.	2025-04-22 06:07:44.285104	2025-04-23 06:07:44.285104
2052	343	280	Decisión del supervisor: Con correcciones. Las palabras clave no describen bien el contenido; ajústalas.	2025-05-06 23:27:37.653135	2025-05-07 23:27:37.653135
2053	344	21	Nueva entrega recibida (versión corregida) para revisión: Obtención de jabón artesanal a partir de aceites vegetales.	2025-05-21 21:03:51.017623	2025-05-22 21:03:51.017623
2060	345	3	Nueva entrega recibida para revisión: Formulación de una crema hidratante con aceite de coco.	2025-05-18 20:21:25.731853	2025-05-19 20:21:25.731853
2061	345	23	Nueva entrega recibida para revisión: Formulación de una crema hidratante con aceite de coco.	2025-05-18 20:21:25.731853	2025-05-19 20:21:25.731853
2062	345	22	Nueva entrega recibida para revisión: Formulación de una crema hidratante con aceite de coco.	2025-05-18 20:21:25.731853	2025-05-19 20:21:25.731853
2058	344	280	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-05-28 03:52:04.400606	2025-05-29 03:52:04.400606
2063	345	2	Nueva entrega recibida para revisión: Formulación de una crema hidratante con aceite de coco.	2025-05-18 20:21:25.731853	2025-05-19 20:21:25.731853
2065	346	21	Nueva entrega recibida para revisión: El lenguaje juvenil en las redes sociales.	2025-06-14 19:36:15.772093	2025-06-15 19:36:15.772093
2064	345	281	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-05-30 03:51:05.107889	2025-05-31 03:51:05.107889
2077	348	21	Nueva entrega recibida para revisión: Infecciones asociadas a la atención en salud en un hospital regional.	2025-11-10 00:40:09.824017	2025-11-11 00:40:09.824017
2078	348	3	Nueva entrega recibida para revisión: Infecciones asociadas a la atención en salud en un hospital regional.	2025-11-10 00:40:09.824017	2025-11-11 00:40:09.824017
2079	348	23	Nueva entrega recibida para revisión: Infecciones asociadas a la atención en salud en un hospital regional.	2025-11-10 00:40:09.824017	2025-11-11 00:40:09.824017
2080	348	22	Nueva entrega recibida para revisión: Infecciones asociadas a la atención en salud en un hospital regional.	2025-11-10 00:40:09.824017	2025-11-11 00:40:09.824017
2081	348	2	Nueva entrega recibida para revisión: Infecciones asociadas a la atención en salud en un hospital regional.	2025-11-10 00:40:09.824017	2025-11-11 00:40:09.824017
2073	347	23	Nueva entrega recibida para revisión: Taller de habilidades sociales para niños de primaria.	2025-04-17 11:34:32.780517	2025-04-18 11:34:32.780517
2074	347	22	Nueva entrega recibida para revisión: Taller de habilidades sociales para niños de primaria.	2025-04-17 11:34:32.780517	2025-04-18 11:34:32.780517
2075	347	2	Nueva entrega recibida para revisión: Taller de habilidades sociales para niños de primaria.	2025-04-17 11:34:32.780517	2025-04-18 11:34:32.780517
2076	347	283	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-04-20 07:18:18.165224	2025-04-21 07:18:18.165224
2089	350	21	Nueva entrega recibida para revisión: La química del agua potable: prácticas para educación media.	2025-07-10 13:04:10.863118	2025-07-11 13:04:10.863118
2090	350	3	Nueva entrega recibida para revisión: La química del agua potable: prácticas para educación media.	2025-07-10 13:04:10.863118	2025-07-11 13:04:10.863118
2091	350	23	Nueva entrega recibida para revisión: La química del agua potable: prácticas para educación media.	2025-07-10 13:04:10.863118	2025-07-11 13:04:10.863118
2092	350	22	Nueva entrega recibida para revisión: La química del agua potable: prácticas para educación media.	2025-07-10 13:04:10.863118	2025-07-11 13:04:10.863118
2093	350	2	Nueva entrega recibida para revisión: La química del agua potable: prácticas para educación media.	2025-07-10 13:04:10.863118	2025-07-11 13:04:10.863118
2082	348	240	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-11-21 18:58:26.188345	2025-11-22 18:58:26.188345
2088	349	284	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-11-05 04:01:44.223271	2025-11-06 04:01:44.223271
2095	351	21	Nueva entrega recibida para revisión: Balanceo de línea en una maquila textil.	2025-05-03 13:26:17.907199	2025-05-04 13:26:17.907199
2096	351	3	Nueva entrega recibida para revisión: Balanceo de línea en una maquila textil.	2025-05-03 13:26:17.907199	2025-05-04 13:26:17.907199
2094	350	285	Decisión del supervisor: Aprobada. Se publicó en el catálogo.	2025-07-12 21:16:09.2242	2025-07-13 21:16:09.2242
2118	354	289	Decisión del supervisor: Con correcciones. Adjunta la versión final del documento aprobada por el jurado.	2025-10-05 03:09:19.99982	2025-10-06 03:09:19.99982
2119	355	21	Nueva entrega recibida (versión corregida) para revisión: Confort térmico en las aulas de la facultad.	2025-10-08 19:04:48.364922	2025-10-09 19:04:48.364922
2120	355	3	Nueva entrega recibida (versión corregida) para revisión: Confort térmico en las aulas de la facultad.	2025-10-08 19:04:48.364922	2025-10-09 19:04:48.364922
2121	355	23	Nueva entrega recibida (versión corregida) para revisión: Confort térmico en las aulas de la facultad.	2025-10-08 19:04:48.364922	2025-10-09 19:04:48.364922
2122	355	22	Nueva entrega recibida (versión corregida) para revisión: Confort térmico en las aulas de la facultad.	2025-10-08 19:04:48.364922	2025-10-09 19:04:48.364922
2123	355	2	Nueva entrega recibida (versión corregida) para revisión: Confort térmico en las aulas de la facultad.	2025-10-08 19:04:48.364922	2025-10-09 19:04:48.364922
\.


--
-- Data for Name: tbl_proyecto; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_proyecto (id_proyecto, titulo, resumen, anio, id_tipo_proyecto, id_carrera, id_tematica, id_materia, estado_publicacion, estado_autorizacion, es_destacado, fecha_registro, fecha_actualizacion) FROM stdin;
9	La poesía de Roque Dalton desde la crítica social	Este trabajo de graduación desarrolla el tema «La poesía de Roque Dalton desde la crítica social». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de Roque Dalton, poesía y crítica social. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2019	1	14	42	\N	no_publicado	pendiente	f	2019-05-17 17:40:26.860285	2019-06-01 17:29:57.173297
7	Cinética de degradación de colorantes por fotocatálisis	El proyecto de investigación «Cinética de degradación de colorantes por fotocatálisis» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de fotocatálisis, colorantes y cinética química. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2019	3	10	18	\N	publicado	autorizado	f	2019-08-10 20:03:08.938318	2019-08-16 03:17:28.27708
4	Huerto escolar como recurso didáctico para la enseñanza de la biología	El trabajo de graduación «Huerto escolar como recurso didáctico para la enseñanza de la biología» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de huerto escolar, didáctica y biología. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2019	1	2	15	\N	publicado	autorizado	f	2019-11-23 06:12:27.49384	2019-12-07 06:40:58.126001
10	Traducción al francés de folletos turísticos de la ruta de Morazán	Este trabajo de graduación desarrolla el tema «Traducción al francés de folletos turísticos de la ruta de Morazán». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de traducción, turismo y francés. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2019	1	15	42	\N	publicado	autorizado	f	2019-12-08 08:35:42.464199	2019-12-10 17:37:46.803312
189	Prevalencia de hipertensión arterial en trabajadores de la facultad	El trabajo de graduación «Prevalencia de hipertensión arterial en trabajadores de la facultad» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de hipertensión, prevalencia y tamizaje. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	1	18	13	\N	no_publicado	pendiente	f	2026-11-17 02:31:20.615673	2026-11-21 02:50:27.335219
13	Anteproyecto de un parque lineal junto al río Grande de San Miguel	Proyecto desarrollado en la asignatura Iniciación al Urbanismo, con el tema «Anteproyecto de un parque lineal junto al río Grande de San Miguel». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de parque lineal, paisajismo y espacio público. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2019	4	25	16	1260	publicado	autorizado	t	2019-05-14 07:45:18.514068	2019-05-30 21:50:49.162108
6	Estimulación temprana en niños con síndrome de Down	Este trabajo de graduación desarrolla el tema «Estimulación temprana en niños con síndrome de Down». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de estimulación temprana, síndrome de Down y terapia ocupacional. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2019	1	9	30	\N	publicado	autorizado	f	2019-08-22 13:30:05.28599	2019-08-25 07:57:46.625682
190	Simuladores PhET en la enseñanza de la electricidad	La tesis «Simuladores PhET en la enseñanza de la electricidad» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de simuladores, electricidad y PhET. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2026	2	19	33	\N	no_publicado	pendiente	f	2026-11-20 17:22:30.673394	2026-11-20 17:22:30.673394
11	Enseñanza de la historia local en centros escolares de San Miguel	Este trabajo de graduación desarrolla el tema «Enseñanza de la historia local en centros escolares de San Miguel». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de historia local, enseñanza y centros escolares. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2019	1	16	15	\N	publicado	autorizado	f	2019-04-16 09:56:40.10946	2019-04-20 16:05:25.436972
5	Estrategias lúdicas para la enseñanza de la genética en educación media	La tesis «Estrategias lúdicas para la enseñanza de la genética en educación media» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de genética, juegos didácticos y educación media. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2019	2	2	15	\N	publicado	autorizado	f	2019-05-26 06:15:16.446794	2019-06-07 03:54:50.636777
8	Chatbot de atención a estudiantes de nuevo ingreso	El trabajo de graduación «Chatbot de atención a estudiantes de nuevo ingreso» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de chatbot, procesamiento de lenguaje natural y atención estudiantil. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2019	1	13	4	\N	publicado	autorizado	t	2019-05-01 05:29:38.590797	2019-05-14 18:10:33.248292
12	Manual de puestos para una empresa familiar de transporte	El trabajo de graduación «Manual de puestos para una empresa familiar de transporte» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de manual de puestos, organización y empresa familiar. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2019	1	23	40	\N	publicado	autorizado	f	2019-03-05 08:31:28.112614	2019-04-01 02:10:25.190582
193	Satisfacción del cliente en supermercados de la ciudad de San Miguel	Este proyecto de investigación estudia el tema «Satisfacción del cliente en supermercados de la ciudad de San Miguel». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de satisfacción del cliente, servicio y encuesta. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	3	23	40	\N	no_publicado	pendiente	f	2026-11-21 09:16:34.998017	2026-11-21 09:16:34.998017
191	Distribución en planta de una fábrica de muebles	El trabajo de graduación «Distribución en planta de una fábrica de muebles» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de distribución en planta, productividad y muebles. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	1	21	25	\N	no_publicado	pendiente	f	2026-11-19 03:05:07.010721	2026-11-21 04:57:49.334564
15	Dificultades en la resolución de problemas con fracciones	Esta tesis estudia el tema «Dificultades en la resolución de problemas con fracciones». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de fracciones, resolución de problemas y tercer ciclo. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2019	2	28	15	\N	publicado	autorizado	f	2019-09-04 19:52:04.392613	2019-09-21 11:01:54.40471
194	Teoría de grafos aplicada a las rutas de transporte de San Miguel	El trabajo de graduación «Teoría de grafos aplicada a las rutas de transporte de San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de teoría de grafos, rutas y optimización. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2026	1	24	38	\N	no_publicado	pendiente	f	2026-11-20 00:46:50.316049	2026-11-21 07:57:46.63877
17	Control de velocidad de un motor trifásico con variador de frecuencia	Proyecto desarrollado en la asignatura Máquinas Eléctricas I, con el tema «Control de velocidad de un motor trifásico con variador de frecuencia». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de variador de frecuencia, motor trifásico y control. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2020	4	3	41	1176	publicado	autorizado	f	2020-08-09 00:41:07.976645	2020-08-16 02:34:46.323324
14	Control interno para una cooperativa agrícola	El trabajo de graduación «Control interno para una cooperativa agrícola» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de control interno, COSO y cooperativa. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2019	1	26	12	\N	no_publicado	no_autorizado	f	2019-11-30 00:48:42.780161	2019-12-02 07:01:37.090162
20	Inflación de la canasta básica alimentaria entre 2020 y 2025	Este trabajo de graduación desarrolla el tema «Inflación de la canasta básica alimentaria entre 2020 y 2025». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de inflación, canasta básica y precios. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2020	1	12	11	\N	publicado	autorizado	f	2020-10-25 22:53:32.524231	2020-11-06 15:12:38.851819
16	Rediseño de una prensa hidráulica para el taller de la facultad	Como proyecto final de Sistemas Hidráulicos y Neumáticos se trabajó el tema «Rediseño de una prensa hidráulica para el taller de la facultad». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de hidráulica, diseño y taller. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	4	1	48	708	publicado	autorizado	f	2020-10-13 05:16:27.004032	2020-10-19 08:48:44.347491
18	Uso de dexmedetomidina como sedante en cuidados intensivos	El proyecto de investigación «Uso de dexmedetomidina como sedante en cuidados intensivos» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de sedación, dexmedetomidina y cuidados intensivos. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2020	3	6	22	\N	publicado	autorizado	f	2020-06-25 14:51:27.624935	2020-07-04 23:54:38.958888
19	Rehabilitación de pacientes con secuelas de accidente cerebrovascular	La tesis «Rehabilitación de pacientes con secuelas de accidente cerebrovascular» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de accidente cerebrovascular, rehabilitación y neurología. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2020	2	9	30	\N	retirado	autorizado	f	2020-03-29 09:27:20.582369	2020-06-15 20:14:12.226978
21	Aplicación móvil de reporte de baches para la alcaldía de San Miguel	El trabajo de graduación «Aplicación móvil de reporte de baches para la alcaldía de San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de aplicación móvil, geolocalización y participación ciudadana. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2020	1	13	2	\N	publicado	autorizado	f	2020-11-24 12:08:24.146858	2020-11-26 14:56:24.46931
23	Análisis de vulnerabilidades en sitios web de instituciones públicas	Este proyecto de investigación estudia el tema «Análisis de vulnerabilidades en sitios web de instituciones públicas». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de ciberseguridad, vulnerabilidades y OWASP. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2020	3	13	37	\N	publicado	autorizado	f	2020-08-23 16:34:41.037665	2020-09-03 02:35:08.371803
22	Base de datos para el control de inventario de una farmacia	Proyecto desarrollado en la asignatura Base de Datos I, con el tema «Base de datos para el control de inventario de una farmacia». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de base de datos, inventario y modelo relacional. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	4	13	1	14	publicado	autorizado	f	2020-04-03 07:19:55.059736	2020-04-14 09:09:40.396765
26	Juegos de mesa para aprender la tabla periódica	La tesis «Juegos de mesa para aprender la tabla periódica» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de tabla periódica, juegos y aprendizaje. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	2	20	15	\N	publicado	autorizado	t	2020-06-15 22:07:17.27547	2020-08-10 18:31:19.712287
192	Factores de éxito de los emprendimientos de mujeres en San Miguel	Esta tesis estudia el tema «Factores de éxito de los emprendimientos de mujeres en San Miguel». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de emprendimiento, mujeres y microempresa. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	2	23	49	\N	publicado	autorizado	f	2026-07-01 06:27:50.63215	2026-07-14 07:36:32.670107
35	Modelos tridimensionales de la célula para estudiantes de tercer ciclo	Como proyecto final de Didáctica General se trabajó el tema «Modelos tridimensionales de la célula para estudiantes de tercer ciclo». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de material didáctico, célula y tercer ciclo. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2021	4	2	15	389	publicado	autorizado	f	2021-07-16 02:22:49.999608	2021-07-28 03:27:19.337362
34	Control biológico de la mosca blanca en el cultivo de tomate	El trabajo de graduación «Control biológico de la mosca blanca en el cultivo de tomate» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en parcelas y fincas de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de control biológico, mosca blanca y tomate. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	1	32	34	\N	publicado	autorizado	f	2020-04-01 02:44:54.993699	2020-04-15 12:06:02.344847
24	Educación cívica y participación de los jóvenes en su comunidad	El trabajo de graduación «Educación cívica y participación de los jóvenes en su comunidad» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de educación cívica, participación juvenil y ciudadanía. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	1	16	19	\N	no_publicado	pendiente	f	2020-05-06 15:41:11.674071	2020-05-17 13:58:23.011585
30	Material manipulativo para la enseñanza de la geometría	Este trabajo de graduación desarrolla el tema «Material manipulativo para la enseñanza de la geometría». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de material manipulativo, geometría y didáctica. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	1	28	15	\N	publicado	autorizado	f	2020-04-14 01:51:33.363523	2020-04-18 11:02:39.730017
33	Indicadores logísticos para una ferretería	Proyecto desarrollado en la asignatura Operadores Económicos y Cadenas de Suministros, con el tema «Indicadores logísticos para una ferretería». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de indicadores, KPI y cadena de suministro. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2020	4	30	43	485	no_publicado	pendiente	f	2020-10-21 14:46:24.659428	2020-11-17 11:08:33.644049
25	Experimentos de bajo costo para enseñar cinemática en noveno grado	Este trabajo de graduación desarrolla el tema «Experimentos de bajo costo para enseñar cinemática en noveno grado». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de experimentos, cinemática y bajo costo. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	1	19	15	\N	publicado	autorizado	f	2020-10-02 21:23:36.313528	2020-10-17 06:42:03.649504
28	Diagnóstico de la gestión del talento humano en una alcaldía	Como proyecto final de Administración de Personal I se trabajó el tema «Diagnóstico de la gestión del talento humano en una alcaldía». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de talento humano, diagnóstico y sector público. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2020	4	23	40	593	publicado	autorizado	f	2020-08-24 03:25:42.021823	2020-09-19 05:42:12.010221
195	Vivienda social bioclimática para el oriente del país	Este trabajo de graduación desarrolla el tema «Vivienda social bioclimática para el oriente del país». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de vivienda social, arquitectura bioclimática y confort térmico. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	1	25	16	\N	no_publicado	pendiente	f	2026-11-20 20:54:15.936625	2026-11-20 20:54:15.936625
36	Propagación in vitro de orquídeas nativas en peligro de extinción	El trabajo de graduación «Propagación in vitro de orquídeas nativas en peligro de extinción» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de cultivo in vitro, orquídeas y conservación. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	1	4	28	\N	no_publicado	pendiente	f	2021-04-27 05:30:44.973427	2021-05-02 12:06:24.29515
196	Aplicación de las NIIF para pymes en empresas comerciales	La tesis «Aplicación de las NIIF para pymes en empresas comerciales» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de NIIF para pymes, estados financieros y comercio. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	2	26	12	\N	no_publicado	pendiente	f	2026-11-21 15:50:37.273565	2026-11-21 15:50:37.273565
29	Métodos numéricos para sistemas de ecuaciones no lineales	Proyecto desarrollado en la asignatura Análisis Numérico, con el tema «Métodos numéricos para sistemas de ecuaciones no lineales». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de métodos numéricos, método de Newton y sistemas no lineales. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	4	24	38	194	publicado	autorizado	f	2020-07-17 06:24:07.591005	2020-08-19 08:17:57.688359
27	Actitudes hacia la química en estudiantes de educación media	El proyecto de investigación «Actitudes hacia la química en estudiantes de educación media» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de actitudes, química y educación media. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2020	3	20	15	\N	publicado	autorizado	f	2020-08-31 02:15:16.041305	2020-09-13 17:46:02.403906
245	Interpretación simultánea en un congreso académico simulado	Como proyecto final de Interpretación Simultánea se trabajó el tema «Interpretación simultánea en un congreso académico simulado». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de interpretación simultánea, congreso y práctica. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2023	4	15	42	713	publicado	autorizado	f	2023-08-10 13:34:19.574491	2023-08-12 23:41:39.947283
250	Estadística con datos reales en el aula de bachillerato	El trabajo de graduación «Estadística con datos reales en el aula de bachillerato» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de estadística, datos reales y bachillerato. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	1	28	15	\N	no_publicado	no_autorizado	f	2023-04-30 06:53:42.736278	2023-05-05 21:05:52.087566
197	Uso de la factura electrónica en los negocios de San Miguel	El proyecto de investigación «Uso de la factura electrónica en los negocios de San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de factura electrónica, Ministerio de Hacienda y negocios. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	3	26	12	\N	no_publicado	pendiente	f	2026-11-18 07:55:16.581762	2026-11-21 20:42:53.22668
255	Polinizadores en cultivos de café de la zona oriental	El trabajo de graduación «Polinizadores en cultivos de café de la zona oriental» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de polinizadores, abejas y café. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	1	4	46	\N	publicado	autorizado	t	2024-03-12 13:16:23.610962	2024-04-28 07:34:26.148696
31	Estudio de suelos para la ampliación de un puente vehicular	Proyecto desarrollado en la asignatura Mecánica de Suelos, con el tema «Estudio de suelos para la ampliación de un puente vehicular». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de mecánica de suelos, capacidad de carga y puente. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	4	29	7	605	publicado	autorizado	f	2020-11-02 12:48:17.389775	2020-11-21 13:02:47.460311
262	Pausas activas para el personal administrativo de la facultad	Como proyecto final de Ergonomía se trabajó el tema «Pausas activas para el personal administrativo de la facultad». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de pausas activas, ergonomía y salud laboral. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	4	9	30	805	publicado	autorizado	f	2024-08-26 11:56:40.332388	2024-09-21 14:13:10.412699
259	Comprensión auditiva del inglés con pódcast en noveno grado	Este proyecto de investigación estudia el tema «Comprensión auditiva del inglés con pódcast en noveno grado». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de comprensión auditiva, pódcast y inglés. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	3	7	42	\N	publicado	autorizado	t	2024-06-24 07:41:17.293843	2024-07-31 15:15:40.968899
265	Abordaje de la neumonía adquirida en la comunidad en niños	Proyecto desarrollado en la asignatura Pediatría I, con el tema «Abordaje de la neumonía adquirida en la comunidad en niños». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de neumonía, pediatría y tratamiento. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	4	18	13	579	publicado	autorizado	f	2024-07-21 20:23:38.770128	2024-08-13 22:06:00.841133
41	Control de calidad interno en el laboratorio de química clínica	Proyecto desarrollado en la asignatura Bioquímica Clínica, con el tema «Control de calidad interno en el laboratorio de química clínica». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de control de calidad, química clínica y reglas de Westgard. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2021	4	8	35	309	publicado	autorizado	f	2021-10-12 20:37:30.412356	2021-10-18 19:23:30.762739
32	Trámites aduaneros para exportar productos agrícolas	Este trabajo de graduación desarrolla el tema «Trámites aduaneros para exportar productos agrícolas». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de aduanas, exportación y trámites. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	1	30	8	\N	publicado	autorizado	f	2020-08-05 05:54:49.754748	2020-08-08 23:04:34.080082
49	Manual de seguridad para laboratorios escolares de química	El trabajo de graduación «Manual de seguridad para laboratorios escolares de química» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de seguridad, laboratorio escolar y manual. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	1	20	18	\N	publicado	autorizado	f	2021-06-15 05:11:34.080312	2021-07-05 08:56:29.264041
43	Modelo de regresión del precio internacional del café	Proyecto desarrollado en la asignatura Econometría, con el tema «Modelo de regresión del precio internacional del café». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de café, regresión y precios internacionales. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	4	12	11	187	no_publicado	no_autorizado	f	2021-08-27 07:54:00.379051	2021-08-31 05:05:55.713632
40	Manejo de la vía aérea difícil en pacientes con obesidad	Esta tesis estudia el tema «Manejo de la vía aérea difícil en pacientes con obesidad». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de vía aérea, obesidad y intubación. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	2	6	22	\N	publicado	autorizado	f	2021-04-28 23:00:36.341193	2021-05-07 01:59:49.709648
198	Organización comunitaria en asentamientos de San Miguel	El trabajo de graduación «Organización comunitaria en asentamientos de San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de organización comunitaria, asentamientos y participación. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	1	27	23	\N	publicado	autorizado	f	2026-09-22 16:47:01.541647	2026-10-18 04:22:06.534744
54	Auditoría de inventarios en una ferretería	Proyecto desarrollado en la asignatura Auditoría I, con el tema «Auditoría de inventarios en una ferretería». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de auditoría, inventarios y ferretería. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2021	4	26	12	1012	publicado	autorizado	f	2021-09-06 13:28:28.983904	2021-09-17 06:27:50.364798
45	Errores ortográficos frecuentes en textos de estudiantes de bachillerato	Como proyecto final de Expresión Oral y Escrita se trabajó el tema «Errores ortográficos frecuentes en textos de estudiantes de bachillerato». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de ortografía, redacción y bachillerato. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	4	14	42	1164	publicado	autorizado	f	2021-11-03 18:49:18.663465	2021-11-26 17:45:35.709212
199	Vulnerabilidad sísmica de escuelas construidas con adobe	El proyecto de investigación «Vulnerabilidad sísmica de escuelas construidas con adobe» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de vulnerabilidad sísmica, adobe y escuelas. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	3	29	7	\N	publicado	autorizado	f	2026-08-14 11:33:36.831918	2026-08-25 02:41:50.17126
53	Levantamiento arquitectónico de la catedral de San Miguel	Como proyecto final de Dibujo Básico se trabajó el tema «Levantamiento arquitectónico de la catedral de San Miguel». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de levantamiento, patrimonio y dibujo arquitectónico. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2021	4	25	16	407	publicado	autorizado	f	2021-05-19 09:19:27.156896	2021-06-14 05:32:20.295154
200	Optimización de rutas de distribución para una embotelladora	Este trabajo de graduación desarrolla el tema «Optimización de rutas de distribución para una embotelladora». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de rutas de distribución, optimización y transporte. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	1	30	43	\N	no_publicado	pendiente	f	2026-11-21 04:31:55.760165	2026-11-22 10:02:38.059004
42	Interacciones medicamentosas en pacientes polimedicados	Proyecto desarrollado en la asignatura Farmacología, con el tema «Interacciones medicamentosas en pacientes polimedicados». El estudio se llevó a cabo con muestras y productos obtenidos en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de interacciones, polifarmacia y farmacia clínica. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	4	11	24	983	no_publicado	pendiente	f	2021-08-20 09:58:24.059398	2021-09-23 19:42:24.080699
37	Efecto de la temperatura en el desarrollo de larvas de Aedes aegypti	Como proyecto final de Zoología I se trabajó el tema «Efecto de la temperatura en el desarrollo de larvas de Aedes aegypti». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de Aedes aegypti, temperatura y entomología. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	4	4	46	526	no_publicado	pendiente	f	2021-04-22 20:58:42.622983	2021-05-03 02:33:18.957483
39	Bloqueo subaracnoideo frente a anestesia general en cesáreas	Este trabajo de graduación desarrolla el tema «Bloqueo subaracnoideo frente a anestesia general en cesáreas». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de anestesia raquídea, cesárea y complicaciones. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	1	6	22	\N	publicado	autorizado	f	2021-03-21 15:15:48.374278	2021-03-27 22:36:42.729687
38	El despido de trabajadoras embarazadas en la legislación laboral	El trabajo de graduación «El despido de trabajadoras embarazadas en la legislación laboral» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo a partir de la legislación vigente, la jurisprudencia y casos de los tribunales de San Miguel. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de derecho laboral, maternidad y despido. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	1	5	44	\N	publicado	autorizado	f	2021-07-09 05:54:11.257637	2021-07-22 12:09:02.627355
48	Péndulo con sensor para medir la aceleración de la gravedad	Como proyecto final de Introducción a la Física se trabajó el tema «Péndulo con sensor para medir la aceleración de la gravedad». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de péndulo, sensores y laboratorio. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	4	19	36	1180	no_publicado	pendiente	f	2021-07-02 01:20:51.381296	2021-07-15 22:34:33.733071
47	Factores de riesgo de diabetes tipo 2 en unidades de salud rurales	La tesis «Factores de riesgo de diabetes tipo 2 en unidades de salud rurales» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de diabetes, factores de riesgo y atención primaria. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	2	18	26	\N	publicado	autorizado	f	2021-05-26 15:29:24.329904	2021-06-09 15:35:37.68947
44	Aplicación de escritorio para la gestión de bibliotecas escolares	Proyecto desarrollado en la asignatura Fundamentos de Programación, con el tema «Aplicación de escritorio para la gestión de bibliotecas escolares». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de programación orientada a objetos, biblioteca y escritorio. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	4	13	20	1	publicado	autorizado	f	2021-12-07 03:31:15.034979	2021-12-10 16:51:16.361236
46	Secuencia didáctica sobre la independencia centroamericana	Como proyecto final de Didáctica de las Ciencias Sociales se trabajó el tema «Secuencia didáctica sobre la independencia centroamericana». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de secuencia didáctica, independencia y historia. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	4	16	15	376	retirado	autorizado	f	2021-02-20 09:30:33.333592	2021-05-16 00:01:50.993644
50	Indicadores ácido-base elaborados con repollo morado	Como proyecto final de Química General I se trabajó el tema «Indicadores ácido-base elaborados con repollo morado». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de indicadores, ácido-base y experimento. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2021	4	20	18	786	publicado	autorizado	f	2021-08-03 08:01:12.950139	2021-09-07 22:36:56.100146
51	Planificación de una unidad sobre el enlace químico	Como proyecto final de Didáctica General se trabajó el tema «Planificación de una unidad sobre el enlace químico». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de enlace químico, planificación y didáctica. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	4	20	15	389	publicado	autorizado	t	2021-08-19 03:43:45.810107	2021-09-22 10:55:26.566586
201	Gestión de almacenes en un centro de distribución de alimentos	La tesis «Gestión de almacenes en un centro de distribución de alimentos» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de almacenes, inventario y centro de distribución. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2026	2	30	43	\N	no_publicado	pendiente	f	2026-11-22 02:47:28.346744	2026-11-22 02:47:28.346744
64	Cumplimiento de la cuota alimenticia en los juzgados de familia de San Miguel	El proyecto de investigación «Cumplimiento de la cuota alimenticia en los juzgados de familia de San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo a partir de la legislación vigente, la jurisprudencia y casos de los tribunales de San Miguel. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de cuota alimenticia, derecho de familia y juzgados. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2022	3	5	47	\N	publicado	autorizado	f	2022-03-16 22:56:04.746277	2022-04-17 08:27:09.858741
58	Rincones de aprendizaje con materiales del entorno	Este trabajo de graduación desarrolla el tema «Rincones de aprendizaje con materiales del entorno». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de rincones de aprendizaje, materiales y aula. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	1	31	15	\N	publicado	autorizado	f	2021-06-04 16:20:32.306807	2021-06-30 22:59:10.482122
55	Violencia de género en el ámbito universitario	Este trabajo de graduación desarrolla el tema «Violencia de género en el ámbito universitario». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de violencia de género, universidad y percepciones. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	1	27	19	\N	publicado	autorizado	f	2021-08-28 21:15:15.038777	2021-09-09 00:25:05.439165
61	Conocimientos sobre educación ambiental en estudiantes de bachillerato de Usulután	Este proyecto de investigación estudia el tema «Conocimientos sobre educación ambiental en estudiantes de bachillerato de Usulután». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de educación ambiental, bachillerato y encuesta. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2022	3	2	14	\N	publicado	autorizado	f	2022-06-03 06:31:28.675793	2022-06-11 15:24:42.044065
60	Determinación de la constante de Planck con diodos LED	Como proyecto final de Mecánica Cuántica I se trabajó el tema «Determinación de la constante de Planck con diodos LED». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de constante de Planck, LED y física moderna. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	4	33	36	492	no_publicado	pendiente	f	2021-10-09 10:50:28.96663	2021-10-21 07:16:42.344029
52	Modelos de ecuaciones diferenciales para la propagación del dengue	Esta tesis estudia el tema «Modelos de ecuaciones diferenciales para la propagación del dengue». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de ecuaciones diferenciales, epidemiología y modelación. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	2	24	38	\N	retirado	autorizado	f	2021-07-20 06:27:01.281505	2021-09-30 10:01:52.822386
62	Calidad de energía en la red de distribución de un centro comercial	La tesis «Calidad de energía en la red de distribución de un centro comercial» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de calidad de energía, armónicos y distribución. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2022	2	3	41	\N	publicado	autorizado	f	2022-03-27 13:57:47.773411	2022-04-23 02:39:55.900763
68	Síntesis de biodiésel a partir de aceite de cocina usado	Este trabajo de graduación desarrolla el tema «Síntesis de biodiésel a partir de aceite de cocina usado». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de biodiésel, transesterificación y reciclaje. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2022	1	10	18	\N	publicado	autorizado	f	2022-11-27 18:59:17.424206	2022-12-10 23:31:28.798674
202	El puerto de La Unión como plataforma logística regional	Este proyecto de investigación estudia el tema «El puerto de La Unión como plataforma logística regional». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de puerto de La Unión, logística portuaria y comercio. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2026	3	30	43	\N	retirado	autorizado	f	2026-06-26 16:43:15.669105	2026-10-27 07:47:11.022947
65	La sociedad por acciones simplificada en el Código de Comercio	Como proyecto final de Derecho Societario y de la Empresa Mercantil se trabajó el tema «La sociedad por acciones simplificada en el Código de Comercio». El estudio se llevó a cabo a partir de la legislación vigente, la jurisprudencia y casos de los tribunales de San Miguel. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de derecho mercantil, sociedades y emprendimiento. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2022	4	5	44	937	publicado	autorizado	f	2022-07-05 17:46:50.546879	2022-07-25 00:58:03.654438
59	Deshidratado de mango como alternativa de agroindustria rural	El proyecto de investigación «Deshidratado de mango como alternativa de agroindustria rural» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en parcelas y fincas de la zona oriental. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de deshidratado, mango y agroindustria. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	3	32	45	\N	publicado	autorizado	f	2021-10-15 14:18:18.204223	2021-10-22 19:35:34.586691
56	Ansiedad matemática en estudiantes de séptimo grado	El proyecto de investigación «Ansiedad matemática en estudiantes de séptimo grado» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de ansiedad matemática, actitudes y tercer ciclo. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2021	3	28	15	\N	publicado	autorizado	f	2021-08-26 07:39:03.13098	2021-08-31 13:16:03.519281
57	Evaluación del pavimento de la carretera Panamericana en el tramo de San Miguel	Este trabajo de graduación desarrolla el tema «Evaluación del pavimento de la carretera Panamericana en el tramo de San Miguel». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de pavimento, evaluación y carreteras. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	1	29	7	\N	publicado	autorizado	f	2021-05-28 15:17:30.181522	2021-06-04 06:02:05.562588
205	Movimiento amortiguado de un sistema masa-resorte	Proyecto desarrollado en la asignatura Mecánica Clásica, con el tema «Movimiento amortiguado de un sistema masa-resorte». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de oscilaciones, amortiguamiento y mecánica. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	4	33	36	178	publicado	autorizado	f	2026-10-25 01:37:06.289426	2026-10-27 03:49:05.619738
63	La prueba pericial en el proceso penal salvadoreño	Esta tesis estudia el tema «La prueba pericial en el proceso penal salvadoreño». El estudio se llevó a cabo a partir de la legislación vigente, la jurisprudencia y casos de los tribunales de San Miguel. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de prueba pericial, proceso penal y peritaje. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2022	2	5	10	\N	publicado	autorizado	f	2022-04-02 19:42:56.605094	2022-04-10 17:25:05.031221
246	Percepción de los jóvenes sobre la democracia	El proyecto de investigación «Percepción de los jóvenes sobre la democracia» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de democracia, juventud y ciudadanía. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2023	3	16	19	\N	no_publicado	no_autorizado	f	2023-03-23 08:07:54.28206	2023-04-19 21:39:59.339618
203	Canciones infantiles para enseñar hábitos de higiene	Como proyecto final de Didáctica de la Expresión Musical y Expresión Corporal en Infantil se trabajó el tema «Canciones infantiles para enseñar hábitos de higiene». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de canciones, hábitos de higiene y primera infancia. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2026	4	31	15	448	publicado	autorizado	f	2026-10-11 19:10:02.334941	2026-10-14 04:56:45.701047
66	Unidad didáctica de inglés basada en tareas	Proyecto desarrollado en la asignatura Didáctica General, con el tema «Unidad didáctica de inglés basada en tareas». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de enseñanza basada en tareas, unidad didáctica y inglés. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2022	4	7	15	665	retirado	autorizado	f	2022-05-11 22:31:26.324044	2022-09-12 13:18:48.016689
204	Propiedades ópticas de películas delgadas	Este trabajo de graduación desarrolla el tema «Propiedades ópticas de películas delgadas». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de películas delgadas, óptica y espectroscopía. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	1	33	36	\N	publicado	autorizado	f	2026-04-28 11:40:15.334293	2026-05-03 07:45:33.668809
251	Plan de transporte para una empresa exportadora de frutas	Como proyecto final de Logística I - Transporte y Almacenamiento se trabajó el tema «Plan de transporte para una empresa exportadora de frutas». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de transporte, exportación y cadena de frío. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	4	30	43	1287	publicado	autorizado	f	2023-11-28 15:38:39.416847	2023-12-11 22:33:55.804817
207	Implementación de las 5S en una imprenta	El trabajo de graduación «Implementación de las 5S en una imprenta» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de 5S, orden y limpieza y productividad. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2019	1	21	25	\N	publicado	autorizado	f	2019-09-19 15:36:24.387132	2019-09-29 06:54:54.779934
67	Evaluación postural en escolares que usan mochila	Proyecto desarrollado en la asignatura Biofísica y Biomecánica, con el tema «Evaluación postural en escolares que usan mochila». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de postura, evaluación y escolares. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2022	4	9	30	1202	publicado	autorizado	f	2022-03-27 03:21:48.365765	2022-04-03 17:20:43.762174
209	Prototipo de iluminación pública con paneles solares y sensores	Como proyecto final de Electrónica I se trabajó el tema «Prototipo de iluminación pública con paneles solares y sensores». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de iluminación pública, energía solar y sensores. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2020	4	3	27	1082	publicado	autorizado	f	2020-06-08 15:37:26.234581	2020-06-20 15:05:53.630626
208	Diseño de una bomba de ariete para riego comunitario	Como proyecto final de Máquinas Hidráulicas se trabajó el tema «Diseño de una bomba de ariete para riego comunitario». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de bomba de ariete, hidráulica y riego. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2020	4	1	48	868	no_publicado	no_autorizado	f	2020-06-24 18:29:11.509955	2020-06-27 18:11:49.889542
206	Índice de precios de los mercados municipales de San Miguel	Proyecto desarrollado en la asignatura Estadística I, con el tema «Índice de precios de los mercados municipales de San Miguel». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de índice de precios, mercados municipales y inflación. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2019	4	12	11	882	publicado	autorizado	t	2019-03-12 19:00:23.327902	2019-04-01 17:12:46.699532
211	Manual de toma y transporte de muestras clínicas	Como proyecto final de Bioseguridad se trabajó el tema «Manual de toma y transporte de muestras clínicas». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de muestras clínicas, bioseguridad y manual. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2020	4	8	31	227	publicado	autorizado	f	2020-06-02 13:29:51.349377	2020-06-11 01:34:24.7174
210	La violencia intrafamiliar en los procesos de familia de San Miguel	Esta tesis estudia el tema «La violencia intrafamiliar en los procesos de familia de San Miguel». El estudio se llevó a cabo a partir de la legislación vigente, la jurisprudencia y casos de los tribunales de San Miguel. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de violencia intrafamiliar, derecho de familia y juzgados. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	2	5	47	\N	publicado	autorizado	f	2020-08-17 10:13:53.297914	2020-08-19 19:19:09.680051
212	Actividad antioxidante del extracto de flor de Jamaica	El trabajo de graduación «Actividad antioxidante del extracto de flor de Jamaica» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con muestras y productos obtenidos en la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de antioxidantes, flor de Jamaica y extracto. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	1	11	29	\N	publicado	autorizado	f	2020-07-02 16:47:36.343915	2020-07-13 17:47:54.696992
73	Interferencia del español en la pronunciación del francés	Este proyecto de investigación estudia el tema «Interferencia del español en la pronunciación del francés». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de fonética, interferencia lingüística y francés. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2022	3	15	42	\N	no_publicado	no_autorizado	f	2022-05-27 18:08:34.739319	2022-05-30 08:47:03.03974
76	Sistema de gestión de seguridad y salud ocupacional para un taller	La tesis «Sistema de gestión de seguridad y salud ocupacional para un taller» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de seguridad ocupacional, riesgos y gestión. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2022	2	21	25	\N	publicado	autorizado	t	2022-07-09 11:00:38.011701	2022-07-17 20:47:26.640971
69	Extracción de pectina de la cáscara de naranja	El trabajo de graduación «Extracción de pectina de la cáscara de naranja» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de pectina, extracción y residuos agrícolas. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2022	1	10	18	\N	publicado	autorizado	f	2022-07-24 14:04:28.10801	2022-08-08 01:36:18.461146
71	Formulación de un gel cicatrizante a base de sábila	El trabajo de graduación «Formulación de un gel cicatrizante a base de sábila» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con muestras y productos obtenidos en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de sábila, gel y formulación. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2022	1	11	29	\N	publicado	autorizado	f	2022-09-30 11:19:09.081503	2022-10-30 02:29:52.98596
70	Contenido de cafeína en bebidas energéticas comerciales	Proyecto desarrollado en la asignatura Química Analítica I, con el tema «Contenido de cafeína en bebidas energéticas comerciales». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de cafeína, cromatografía y bebidas. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2022	4	10	35	1169	publicado	autorizado	f	2022-08-19 10:20:07.116826	2022-08-22 16:12:26.467087
72	Diseño de la red de datos de un centro escolar	Proyecto desarrollado en la asignatura Fundamentos de Redes, con el tema «Diseño de la red de datos de un centro escolar». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de redes, cableado estructurado y VLAN. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2022	4	13	3	36	publicado	autorizado	f	2022-10-05 11:15:40.25802	2022-11-02 10:32:19.168717
74	Interpretación consecutiva en un foro de turismo	Como proyecto final de Interpretación Consecutiva se trabajó el tema «Interpretación consecutiva en un foro de turismo». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de interpretación, turismo y inglés y francés. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2022	4	15	42	740	publicado	autorizado	f	2022-04-05 23:41:35.310522	2022-04-19 14:02:40.597537
75	Ansiedad y depresión en adultos mayores de hogares de ancianos de San Miguel	La tesis «Ansiedad y depresión en adultos mayores de hogares de ancianos de San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de ansiedad, depresión y adulto mayor. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2022	2	17	21	\N	publicado	autorizado	f	2022-03-15 00:47:40.145248	2022-03-21 10:55:14.446516
77	Sistema de agua potable para un caserío de Morazán	El trabajo de graduación «Sistema de agua potable para un caserío de Morazán» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de agua potable, diseño hidráulico y comunidad rural. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2022	1	29	7	\N	publicado	autorizado	f	2022-08-20 21:35:52.941613	2022-08-29 12:21:13.278764
213	Juego de roles sobre los derechos humanos en tercer ciclo	Proyecto desarrollado en la asignatura Democracia y Derechos Humanos, con el tema «Juego de roles sobre los derechos humanos en tercer ciclo». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de derechos humanos, juego de roles y didáctica. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	4	16	15	670	no_publicado	pendiente	f	2020-10-12 04:20:52.288574	2020-11-04 21:38:24.591882
78	Selección de incoterms en la importación de maquinaria	Como proyecto final de Logística II - Procesos de Exportación se trabajó el tema «Selección de incoterms en la importación de maquinaria». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de incoterms, importación y contratos internacionales. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2022	4	30	8	742	publicado	autorizado	f	2022-03-29 02:37:30.887451	2022-04-09 05:30:29.220824
90	Red de sensores para monitorear la humedad del suelo en cultivos	El trabajo de graduación «Red de sensores para monitorear la humedad del suelo en cultivos» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de internet de las cosas, sensores y riego. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2023	1	13	27	\N	no_publicado	pendiente	f	2023-05-13 07:12:39.34142	2023-05-29 10:52:15.288865
89	Sistema web para la gestión de citas de la clínica universitaria	Este trabajo de graduación desarrolla el tema «Sistema web para la gestión de citas de la clínica universitaria». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de gestión de citas, aplicación web y clínica. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	1	13	20	\N	publicado	autorizado	f	2023-08-03 01:36:01.399225	2023-08-05 22:09:28.732759
79	Rendimiento de variedades de frijol rojo en el valle de San Miguel	Esta tesis estudia el tema «Rendimiento de variedades de frijol rojo en el valle de San Miguel». El estudio se llevó a cabo en parcelas y fincas de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de frijol, variedades y rendimiento. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2022	2	32	39	\N	publicado	autorizado	f	2022-03-17 15:24:06.844222	2022-03-23 08:25:35.193613
87	Material didáctico de inglés para estudiantes con baja visión	Este trabajo de graduación desarrolla el tema «Material didáctico de inglés para estudiantes con baja visión». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de inclusión, baja visión y material didáctico. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2023	1	7	15	\N	no_publicado	no_autorizado	f	2023-07-29 09:56:34.169288	2023-08-11 21:09:09.490168
94	Uso de la escala de Glasgow en la emergencia de un hospital nacional	Proyecto desarrollado en la asignatura Medicina Interna I, con el tema «Uso de la escala de Glasgow en la emergencia de un hospital nacional». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de escala de Glasgow, trauma craneoencefálico y emergencia. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	4	18	13	1072	publicado	autorizado	f	2023-06-19 22:20:05.257719	2023-07-01 21:34:51.636461
92	Plataformas virtuales en el aprendizaje del francés	Esta tesis estudia el tema «Plataformas virtuales en el aprendizaje del francés». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de aprendizaje en línea, francés y plataformas. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2023	2	15	33	\N	publicado	autorizado	f	2023-06-30 13:43:49.281541	2023-07-04 18:21:19.664098
214	Plan de mercadeo para una tienda en línea de artesanías	Como proyecto final de Mercadeo I se trabajó el tema «Plan de mercadeo para una tienda en línea de artesanías». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de plan de mercadeo, comercio electrónico y artesanías. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	4	22	8	783	publicado	autorizado	f	2020-04-10 18:55:03.901396	2020-04-14 12:50:43.36596
97	Cadenas de Markov aplicadas al rendimiento estudiantil	Este trabajo de graduación desarrolla el tema «Cadenas de Markov aplicadas al rendimiento estudiantil». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de cadenas de Markov, probabilidad y rendimiento estudiantil. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2023	1	24	38	\N	publicado	autorizado	f	2023-05-29 02:02:39.053929	2023-06-27 04:13:57.128489
81	Diseño de un secador solar de granos para pequeños productores de San Miguel	Este trabajo de graduación desarrolla el tema «Diseño de un secador solar de granos para pequeños productores de San Miguel». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de energía solar, secado de granos y diseño mecánico. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2023	1	1	41	\N	publicado	autorizado	f	2023-08-24 14:18:30.729963	2023-09-24 02:55:49.758738
80	Simulación del comportamiento caótico del péndulo doble	Este trabajo de graduación desarrolla el tema «Simulación del comportamiento caótico del péndulo doble». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de caos, péndulo doble y simulación. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2022	1	33	36	\N	publicado	autorizado	f	2022-09-01 21:58:46.802575	2022-09-07 10:07:14.124673
83	Coordinación de protecciones en una subestación de 46 kV	El trabajo de graduación «Coordinación de protecciones en una subestación de 46 kV» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de protecciones, subestación y cortocircuito. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2023	1	3	41	\N	publicado	autorizado	f	2023-11-15 22:35:46.32854	2023-11-18 18:50:58.6808
82	Factibilidad de un sistema fotovoltaico para la biblioteca de la facultad	Este trabajo de graduación desarrolla el tema «Factibilidad de un sistema fotovoltaico para la biblioteca de la facultad». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de energía fotovoltaica, factibilidad y biblioteca. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2023	1	3	41	\N	publicado	autorizado	f	2023-03-28 14:35:45.350772	2023-04-05 06:32:38.6881
88	Actividad antibacteriana del extracto de hojas de guayaba	Este trabajo de graduación desarrolla el tema «Actividad antibacteriana del extracto de hojas de guayaba». El estudio se llevó a cabo con muestras y productos obtenidos en la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de guayaba, extracto vegetal y actividad antibacteriana. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	1	11	29	\N	publicado	autorizado	f	2023-09-29 22:08:49.790761	2023-10-05 10:39:30.097898
85	Protección de datos personales frente a las nuevas tecnologías	El trabajo de graduación «Protección de datos personales frente a las nuevas tecnologías» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo a partir de la legislación vigente, la jurisprudencia y casos de los tribunales de San Miguel. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de datos personales, privacidad y derechos humanos. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2023	1	5	9	\N	publicado	autorizado	f	2023-04-01 09:32:08.323151	2023-04-05 06:49:23.65035
84	Calidad del agua del río Grande de San Miguel mediante macroinvertebrados	Este trabajo de graduación desarrolla el tema «Calidad del agua del río Grande de San Miguel mediante macroinvertebrados». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de bioindicadores, calidad del agua y macroinvertebrados. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	1	4	14	\N	publicado	autorizado	f	2023-10-19 11:21:08.348793	2023-10-30 06:18:12.700487
86	Uso de canciones para mejorar la pronunciación del inglés en séptimo grado	Este trabajo de graduación desarrolla el tema «Uso de canciones para mejorar la pronunciación del inglés en séptimo grado». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de pronunciación, canciones y inglés. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2023	1	7	42	\N	publicado	autorizado	f	2023-12-01 09:11:02.264778	2023-12-03 17:26:41.585449
91	La figura de la mujer en la narrativa de Claudia Lars	La tesis «La figura de la mujer en la narrativa de Claudia Lars» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de Claudia Lars, narrativa y literatura salvadoreña. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2023	2	14	42	\N	no_publicado	pendiente	f	2023-06-07 22:53:00.596872	2023-06-17 05:28:17.93582
215	Patologías en edificaciones de concreto de la zona oriental	La tesis «Patologías en edificaciones de concreto de la zona oriental» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de patologías, concreto y edificaciones. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	2	29	7	\N	publicado	autorizado	f	2020-06-04 09:22:08.990435	2020-06-11 08:50:38.345833
99	Sistema de costos por órdenes de producción para una carpintería	Como proyecto final de Contabilidad de Costos I se trabajó el tema «Sistema de costos por órdenes de producción para una carpintería». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de contabilidad de costos, órdenes de producción y carpintería. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2023	4	26	12	419	publicado	autorizado	f	2023-03-08 10:19:13.410007	2023-03-19 09:50:49.825189
95	Estudio de tiempos en la línea de empaque de una procesadora de lácteos	Proyecto desarrollado en la asignatura Ingeniería de Métodos, con el tema «Estudio de tiempos en la línea de empaque de una procesadora de lácteos». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de estudio de tiempos, estandarización y lácteos. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2023	4	21	25	552	publicado	autorizado	f	2023-09-26 14:21:51.962013	2023-10-13 21:16:21.063649
93	La cortesía verbal en inglés y en francés	Como proyecto final de Estudio Lingüístico del Idioma Inglés se trabajó el tema «La cortesía verbal en inglés y en francés». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de pragmática, cortesía y inglés y francés. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2023	4	15	42	814	publicado	autorizado	f	2023-09-19 03:27:19.377397	2023-10-26 18:44:05.541131
98	Revitalización del centro histórico de San Miguel	Esta tesis estudia el tema «Revitalización del centro histórico de San Miguel». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de centro histórico, revitalización y patrimonio. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2023	2	25	16	\N	publicado	autorizado	f	2023-07-09 00:58:30.832042	2023-07-31 18:39:59.06118
96	Comportamiento del consumidor de comercio electrónico en San Miguel	La tesis «Comportamiento del consumidor de comercio electrónico en San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de comercio electrónico, consumidor y encuesta. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2023	2	22	8	\N	publicado	autorizado	f	2023-05-30 18:00:32.390653	2023-06-14 01:31:20.745534
216	Manejo integrado de plagas en el cultivo de maíz	Como proyecto final de Entomología Agrícola se trabajó el tema «Manejo integrado de plagas en el cultivo de maíz». El estudio se llevó a cabo en parcelas y fincas de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de manejo integrado de plagas, maíz y control. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2020	4	32	34	1195	publicado	autorizado	f	2020-10-25 02:41:49.936219	2020-10-30 01:05:53.296294
107	Protocolo de monitoreo en anestesia pediátrica	Como proyecto final de Introducción de la Anestesiología se trabajó el tema «Protocolo de monitoreo en anestesia pediátrica». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de anestesia pediátrica, monitoreo y protocolo. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	4	6	22	281	publicado	autorizado	f	2024-03-29 01:01:34.71129	2024-04-04 12:04:56.048418
217	Diseño de un aerogenerador de eje vertical para zonas rurales	Este trabajo de graduación desarrolla el tema «Diseño de un aerogenerador de eje vertical para zonas rurales». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de energía eólica, aerogenerador y diseño mecánico. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2021	1	1	41	\N	publicado	autorizado	f	2021-07-11 04:39:48.926934	2021-07-20 22:00:21.261743
105	Diversidad de murciélagos en el manglar de la bahía de Jiquilisco	La tesis «Diversidad de murciélagos en el manglar de la bahía de Jiquilisco» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de murciélagos, manglar y biodiversidad. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	2	4	46	\N	retirado	autorizado	f	2024-07-17 22:22:29.799454	2024-10-04 01:59:38.434634
102	Simulación térmica de un intercambiador de calor de tubos concéntricos	Como proyecto final de Transferencia de Calor se trabajó el tema «Simulación térmica de un intercambiador de calor de tubos concéntricos». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de transferencia de calor, simulación y intercambiador. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	4	1	48	238	publicado	autorizado	f	2024-05-13 10:54:58.29451	2024-05-15 20:00:53.641707
100	Estudio de caso de una asociación de mujeres artesanas	Como proyecto final de Investigación Cualitativa se trabajó el tema «Estudio de caso de una asociación de mujeres artesanas». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de asociatividad, mujeres y artesanía. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2023	4	27	23	1111	publicado	autorizado	f	2023-06-30 05:49:13.535732	2023-07-06 21:55:47.934227
104	Potencial de generación eólica en la zona costera de La Unión	El proyecto de investigación «Potencial de generación eólica en la zona costera de La Unión» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de energía eólica, recurso eólico y La Unión. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	3	3	41	\N	no_publicado	pendiente	f	2024-08-19 04:41:40.19961	2024-08-27 10:27:11.505163
101	Diseño estructural de una vivienda de dos niveles	Proyecto desarrollado en la asignatura Estructuras de Concreto I, con el tema «Diseño estructural de una vivienda de dos niveles». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de diseño estructural, concreto reforzado y vivienda. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	4	29	7	820	publicado	autorizado	f	2023-04-01 20:38:46.262713	2023-04-03 22:54:14.651589
103	Guía de prácticas de biología para centros escolares sin laboratorio	Este trabajo de graduación desarrolla el tema «Guía de prácticas de biología para centros escolares sin laboratorio». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de prácticas de laboratorio, guía y centros escolares. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	1	2	15	\N	publicado	autorizado	f	2024-08-12 04:08:21.240532	2024-08-18 15:13:01.592754
219	Hipotermia postoperatoria en pacientes de cirugía mayor	Este trabajo de graduación desarrolla el tema «Hipotermia postoperatoria en pacientes de cirugía mayor». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de hipotermia, postoperatorio y cirugía mayor. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	1	6	22	\N	no_publicado	pendiente	f	2021-05-07 10:09:15.275388	2021-05-17 02:57:41.595607
106	Composición de la flora del cerro El Tigre en Morazán	Este proyecto de investigación estudia el tema «Composición de la flora del cerro El Tigre en Morazán». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de flora, inventario y Morazán. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	3	4	46	\N	publicado	autorizado	f	2024-11-16 04:25:28.736063	2024-11-20 11:36:11.071446
218	Anfibios como indicadores de la salud de los bosques de Morazán	Esta tesis estudia el tema «Anfibios como indicadores de la salud de los bosques de Morazán». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de anfibios, bioindicadores y bosque. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	2	4	46	\N	publicado	autorizado	f	2021-04-22 06:06:36.871404	2021-05-28 03:50:56.927844
109	Frecuencia de grupos sanguíneos en donantes del banco de sangre regional	Proyecto desarrollado en la asignatura Inmunohematología y Servicios de Sangre, con el tema «Frecuencia de grupos sanguíneos en donantes del banco de sangre regional». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de grupos sanguíneos, banco de sangre y inmunohematología. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	4	8	31	699	publicado	autorizado	f	2024-09-04 15:18:58.946538	2024-10-02 19:06:27.956325
108	Ansiedad al hablar inglés en estudiantes de bachillerato	Este proyecto de investigación estudia el tema «Ansiedad al hablar inglés en estudiantes de bachillerato». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de ansiedad, expresión oral y bachillerato. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	3	7	42	\N	no_publicado	pendiente	f	2024-06-05 23:11:44.348237	2024-06-19 13:26:44.65212
114	Determinantes del empleo informal en San Miguel	Este trabajo de graduación desarrolla el tema «Determinantes del empleo informal en San Miguel». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de empleo informal, mercado laboral y econometría. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	1	12	11	\N	publicado	autorizado	f	2024-09-29 08:18:37.815957	2024-10-04 13:18:35.164585
113	Control de calidad de tabletas de paracetamol de distintos fabricantes	Como proyecto final de Control de Calidad de Productos Farmacéuticos se trabajó el tema «Control de calidad de tabletas de paracetamol de distintos fabricantes». El estudio se llevó a cabo con muestras y productos obtenidos en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de control de calidad, disolución y paracetamol. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	4	11	35	853	publicado	autorizado	f	2024-07-30 03:01:58.7298	2024-08-02 06:27:46.159905
110	Programa de ejercicios para la lumbalgia en trabajadores de oficina	Este trabajo de graduación desarrolla el tema «Programa de ejercicios para la lumbalgia en trabajadores de oficina». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de lumbalgia, ejercicio terapéutico y ergonomía. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	1	9	30	\N	publicado	autorizado	f	2024-03-07 04:40:23.261771	2024-03-16 14:19:54.622688
111	Determinación de metales pesados en agua del río Lempa	La tesis «Determinación de metales pesados en agua del río Lempa» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de metales pesados, absorción atómica y agua. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	2	10	35	\N	retirado	autorizado	f	2024-09-26 04:27:47.308895	2024-12-02 00:09:13.665812
220	Lista de verificación de seguridad del equipo de anestesia	Como proyecto final de Introducción de la Anestesiología se trabajó el tema «Lista de verificación de seguridad del equipo de anestesia». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de seguridad del paciente, lista de verificación y equipo de anestesia. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	4	6	22	281	publicado	autorizado	f	2021-08-24 11:08:11.898629	2021-09-02 07:53:56.249633
221	Contenido de nitratos en agua de pozos de la zona oriental	Esta tesis estudia el tema «Contenido de nitratos en agua de pozos de la zona oriental». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de nitratos, agua de pozo y espectrofotometría. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2021	2	10	35	\N	retirado	autorizado	f	2021-08-04 16:33:41.914404	2021-09-28 05:39:24.202987
115	Detección de enfermedades en hojas de café con redes neuronales	La tesis «Detección de enfermedades en hojas de café con redes neuronales» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de redes neuronales, visión por computadora y roya del café. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	2	13	4	\N	publicado	autorizado	f	2024-08-20 16:46:43.801735	2024-09-02 14:44:48.126203
222	Plataforma web para la gestión de prácticas profesionales	Este trabajo de graduación desarrolla el tema «Plataforma web para la gestión de prácticas profesionales». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de prácticas profesionales, aplicación web y gestión. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2021	1	13	20	\N	publicado	autorizado	f	2021-11-23 22:35:44.516119	2021-12-05 10:33:28.847595
223	Diseño de una base de datos para un consultorio odontológico	Proyecto desarrollado en la asignatura Base de Datos I, con el tema «Diseño de una base de datos para un consultorio odontológico». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de base de datos, consultorio y modelo entidad-relación. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	4	13	1	14	no_publicado	no_autorizado	f	2021-06-26 11:33:13.488322	2021-07-06 12:57:02.794844
116	Panel de indicadores de rendimiento académico con ciencia de datos	El proyecto de investigación «Panel de indicadores de rendimiento académico con ciencia de datos» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de ciencia de datos, rendimiento académico y visualización. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	3	13	6	\N	retirado	autorizado	f	2024-05-13 08:22:39.76164	2024-09-01 23:29:53.401647
224	La oralidad y las leyendas del oriente salvadoreño	Este trabajo de graduación desarrolla el tema «La oralidad y las leyendas del oriente salvadoreño». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de tradición oral, leyendas y literatura popular. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	1	14	42	\N	publicado	autorizado	f	2021-05-20 16:24:24.08331	2021-05-27 16:24:20.43135
112	Uso racional de antibióticos en farmacias de San Miguel	El proyecto de investigación «Uso racional de antibióticos en farmacias de San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con muestras y productos obtenidos en la zona oriental del país. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de uso racional, antibióticos y farmacia comunitaria. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	3	11	24	\N	publicado	autorizado	f	2024-07-03 13:32:34.981855	2024-08-12 00:26:10.078751
226	La motivación en el aprendizaje del francés como tercera lengua	La tesis «La motivación en el aprendizaje del francés como tercera lengua» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de motivación, francés y tercera lengua. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	2	15	42	\N	no_publicado	pendiente	f	2021-06-21 15:27:23.298391	2021-06-30 06:49:07.606325
117	Rasgos del habla popular en el oriente de El Salvador	El trabajo de graduación «Rasgos del habla popular en el oriente de El Salvador» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de sociolingüística, habla popular y dialectología. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	1	14	42	\N	publicado	autorizado	f	2024-03-25 14:36:26.754713	2024-04-07 19:40:49.120138
227	Control prenatal y complicaciones del embarazo en zonas rurales	El trabajo de graduación «Control prenatal y complicaciones del embarazo en zonas rurales» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de control prenatal, embarazo y atención primaria. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2021	1	18	13	\N	publicado	autorizado	f	2021-05-18 08:45:11.911962	2021-06-01 08:51:34.914568
225	Errores frecuentes en la traducción de textos técnicos al inglés	Este trabajo de graduación desarrolla el tema «Errores frecuentes en la traducción de textos técnicos al inglés». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de traducción técnica, errores y inglés. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	1	15	42	\N	publicado	autorizado	t	2021-08-22 18:46:15.722735	2021-10-11 21:39:28.013405
228	Laboratorio virtual de ondas para estudiantes de bachillerato	El trabajo de graduación «Laboratorio virtual de ondas para estudiantes de bachillerato» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de laboratorio virtual, ondas y simulación. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	1	19	33	\N	publicado	autorizado	f	2021-10-15 07:39:20.592027	2021-10-30 01:37:12.023471
126	Plan estratégico para una cooperativa de ahorro y crédito	El trabajo de graduación «Plan estratégico para una cooperativa de ahorro y crédito» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de planeación estratégica, cooperativa y FODA. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	1	23	40	\N	publicado	autorizado	f	2024-08-04 10:32:59.365624	2024-08-28 16:14:07.4667
122	Guía didáctica de óptica geométrica con materiales reciclados	El trabajo de graduación «Guía didáctica de óptica geométrica con materiales reciclados» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de óptica, reciclaje y guía didáctica. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	1	19	15	\N	publicado	autorizado	f	2024-09-20 11:37:41.500765	2024-10-05 08:31:08.870472
118	Hábitos de lectura en estudiantes universitarios	El proyecto de investigación «Hábitos de lectura en estudiantes universitarios» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de hábitos de lectura, universitarios y encuesta. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	3	14	42	\N	publicado	autorizado	f	2024-09-24 02:59:37.80986	2024-09-29 06:56:56.175583
125	Oportunidades del tratado de libre comercio con Corea para productos agrícolas	Este proyecto de investigación estudia el tema «Oportunidades del tratado de libre comercio con Corea para productos agrícolas». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de tratado de libre comercio, Corea y agroexportación. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	3	22	8	\N	no_publicado	pendiente	f	2024-06-13 16:37:11.644369	2024-06-16 22:22:08.00907
120	Aplicación de una prueba de inteligencia en niños de primer ciclo	Como proyecto final de Introducción a la Evaluación Psicológica se trabajó el tema «Aplicación de una prueba de inteligencia en niños de primer ciclo». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de evaluación psicológica, inteligencia y niños. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	4	17	21	241	publicado	autorizado	f	2024-10-28 06:04:14.960206	2024-11-10 21:32:58.348279
127	Plan de negocios para una empresa de alimentos saludables	Como proyecto final de Formulación y Evaluación de Proyectos se trabajó el tema «Plan de negocios para una empresa de alimentos saludables». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de plan de negocios, alimentos saludables y factibilidad. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	4	23	49	1074	publicado	autorizado	f	2024-04-21 06:05:20.151789	2024-04-28 01:11:22.519085
123	Secuencia de clases sobre la energía y sus transformaciones	Como proyecto final de Didáctica General se trabajó el tema «Secuencia de clases sobre la energía y sus transformaciones». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de energía, transformaciones y didáctica. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	4	19	15	389	publicado	autorizado	f	2024-04-19 18:47:49.640075	2024-04-26 18:16:19.005209
229	Liderazgo y desempeño laboral en una institución pública	La tesis «Liderazgo y desempeño laboral en una institución pública» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de liderazgo, desempeño laboral y sector público. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2021	2	23	40	\N	publicado	autorizado	f	2021-03-07 15:35:21.772573	2021-04-05 10:14:20.880215
124	Química en la cocina: prácticas para tercer ciclo	Este trabajo de graduación desarrolla el tema «Química en la cocina: prácticas para tercer ciclo». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de prácticas, cocina y química cotidiana. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	1	20	15	\N	publicado	autorizado	f	2024-04-07 09:56:44.6477	2024-04-15 22:41:45.981728
119	Programa de intervención en duelo para familias de migrantes	El trabajo de graduación «Programa de intervención en duelo para familias de migrantes» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de duelo, migración y intervención. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	1	17	21	\N	publicado	autorizado	f	2024-08-17 20:33:17.848493	2024-08-25 16:06:17.247232
128	Demostraciones visuales de identidades algebraicas	Como proyecto final de Introducción al Álgebra se trabajó el tema «Demostraciones visuales de identidades algebraicas». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de demostraciones, álgebra y visualización. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	4	24	38	1232	publicado	autorizado	f	2024-03-20 11:51:24.20424	2024-04-17 05:04:48.315829
121	Caso clínico de apendicitis aguda durante el embarazo	Como proyecto final de Cirugía I se trabajó el tema «Caso clínico de apendicitis aguda durante el embarazo». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de apendicitis, embarazo y cirugía. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	4	18	13	871	publicado	autorizado	f	2024-05-14 06:53:08.717728	2024-05-25 09:59:24.139512
130	Accesibilidad universal en los edificios de la facultad	Este proyecto de investigación estudia el tema «Accesibilidad universal en los edificios de la facultad». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de accesibilidad, discapacidad y edificios. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	3	25	16	\N	no_publicado	pendiente	f	2024-08-07 10:18:09.771789	2024-08-17 22:54:32.134087
129	Diseño de un mercado municipal para Santa Rosa de Lima	El trabajo de graduación «Diseño de un mercado municipal para Santa Rosa de Lima» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de mercado municipal, diseño arquitectónico y espacio público. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	1	25	16	\N	no_publicado	no_autorizado	f	2024-08-24 09:41:44.048595	2024-09-02 08:57:28.417863
131	Migración irregular de jóvenes del oriente hacia Estados Unidos	La tesis «Migración irregular de jóvenes del oriente hacia Estados Unidos» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de migración, juventud y Estados Unidos. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	2	27	19	\N	publicado	autorizado	f	2024-04-02 07:05:50.467214	2024-04-05 16:24:53.861827
230	Efecto del biochar en la fertilidad del suelo	Esta tesis estudia el tema «Efecto del biochar en la fertilidad del suelo». El estudio se llevó a cabo en parcelas y fincas de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de biochar, fertilidad y suelo. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2021	2	32	32	\N	retirado	autorizado	f	2021-04-04 21:36:10.213395	2021-08-02 19:47:22.95791
137	Actividades de psicomotricidad fina para la primera infancia	Como proyecto final de Didáctica de la Psicomotricidad y la Educación Física se trabajó el tema «Actividades de psicomotricidad fina para la primera infancia». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de psicomotricidad fina, planificación y primera infancia. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	4	31	15	175	publicado	autorizado	f	2024-06-04 09:09:41.596409	2024-06-16 05:45:42.935731
133	Secuencia didáctica de ecuaciones de primer grado	Proyecto desarrollado en la asignatura Didáctica General, con el tema «Secuencia didáctica de ecuaciones de primer grado». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de ecuaciones, secuencia didáctica y álgebra. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	4	28	15	389	publicado	autorizado	f	2024-09-24 14:04:37.982672	2024-10-01 12:12:47.375034
136	Estimulación del lenguaje oral mediante cuentos	El proyecto de investigación «Estimulación del lenguaje oral mediante cuentos» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de lenguaje oral, cuentos y parvularia. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	3	31	15	\N	publicado	autorizado	t	2024-07-04 21:42:10.257551	2024-07-22 15:47:48.942157
135	El juego libre en el desarrollo social de niños de cuatro años	Este trabajo de graduación desarrolla el tema «El juego libre en el desarrollo social de niños de cuatro años». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de juego libre, desarrollo social y primera infancia. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	1	31	15	\N	publicado	autorizado	f	2024-05-07 20:19:08.182154	2024-05-21 20:19:20.594799
132	GeoGebra en la enseñanza de funciones en bachillerato	El trabajo de graduación «GeoGebra en la enseñanza de funciones en bachillerato» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de GeoGebra, funciones y tecnología educativa. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	1	28	33	\N	publicado	autorizado	f	2024-04-11 05:00:49.209083	2024-04-27 19:45:29.318413
138	Análisis de vibraciones en motores eléctricos de la industria local	La tesis «Análisis de vibraciones en motores eléctricos de la industria local» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de vibraciones, mantenimiento predictivo y motores. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	2	1	48	\N	retirado	autorizado	f	2025-05-30 22:16:18.266998	2025-07-10 02:16:17.909435
231	El turismo como motor del desarrollo económico de la ruta de la paz	Este trabajo de graduación desarrolla el tema «El turismo como motor del desarrollo económico de la ruta de la paz». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de turismo, desarrollo económico y Morazán. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2022	1	12	11	\N	publicado	autorizado	t	2022-08-30 20:28:35.318943	2022-09-25 08:15:10.048451
140	Monitoreo del consumo eléctrico con sensores de corriente y plataforma web	Como proyecto final de Electrónica I se trabajó el tema «Monitoreo del consumo eléctrico con sensores de corriente y plataforma web». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de monitoreo, consumo eléctrico y sensores. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	4	3	27	1082	publicado	autorizado	f	2025-07-18 21:48:10.593485	2025-08-07 12:42:27.643379
134	Bloques de concreto con agregado reciclado	La tesis «Bloques de concreto con agregado reciclado» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de concreto, agregado reciclado y resistencia. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	2	29	7	\N	publicado	autorizado	f	2024-11-12 21:40:41.057974	2024-11-18 08:41:30.461353
142	Detección de infección de vías urinarias en mujeres embarazadas	El trabajo de graduación «Detección de infección de vías urinarias en mujeres embarazadas» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de urocultivo, embarazo y infección urinaria. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	1	8	31	\N	retirado	autorizado	f	2025-03-05 22:54:10.282683	2025-06-02 18:41:09.960225
141	Prevalencia de parasitosis intestinal en niños de escuelas rurales de Morazán	Este trabajo de graduación desarrolla el tema «Prevalencia de parasitosis intestinal en niños de escuelas rurales de Morazán». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de parasitosis, niños y coproparasitología. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	1	8	31	\N	publicado	autorizado	f	2025-09-12 20:12:30.273366	2025-09-22 07:14:17.638637
232	Resiliencia en jóvenes afectados por la violencia	Este trabajo de graduación desarrolla el tema «Resiliencia en jóvenes afectados por la violencia». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de resiliencia, violencia y juventud. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2022	1	17	21	\N	publicado	autorizado	f	2022-03-08 09:42:31.377769	2022-03-18 19:39:37.781365
145	Adaptaciones del hogar para adultos mayores con movilidad reducida	Este proyecto de investigación estudia el tema «Adaptaciones del hogar para adultos mayores con movilidad reducida». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de terapia ocupacional, adulto mayor y accesibilidad. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	3	9	30	\N	publicado	autorizado	f	2025-10-23 21:45:48.233041	2025-10-30 21:23:33.578573
143	Resistencia antimicrobiana de Escherichia coli en muestras de orina	El proyecto de investigación «Resistencia antimicrobiana de Escherichia coli en muestras de orina» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de resistencia antimicrobiana, E. coli y antibiograma. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	3	8	26	\N	publicado	autorizado	f	2025-10-22 22:08:10.26789	2025-11-05 02:05:56.631318
144	Lesiones deportivas frecuentes en jugadores de fútbol universitario	El proyecto de investigación «Lesiones deportivas frecuentes en jugadores de fútbol universitario» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de lesiones deportivas, fútbol y prevención. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	3	9	30	\N	publicado	autorizado	t	2025-02-05 09:59:10.24998	2025-03-11 12:06:42.614379
233	Construcción de un circuito eléctrico didáctico	Proyecto desarrollado en la asignatura Física III Electricidad y Magnetismo, con el tema «Construcción de un circuito eléctrico didáctico». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de circuito eléctrico, material didáctico y electricidad. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2022	4	19	36	731	publicado	autorizado	f	2022-05-24 01:14:17.507287	2022-06-07 16:10:11.913195
148	Balanza comercial de El Salvador con Centroamérica	Proyecto desarrollado en la asignatura Economía Internacional, con el tema «Balanza comercial de El Salvador con Centroamérica». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de balanza comercial, comercio exterior y Centroamérica. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	4	12	11	210	retirado	autorizado	f	2025-04-13 00:31:59.864704	2025-07-12 03:41:52.511874
234	Gestión financiera de las pequeñas empresas familiares de San Miguel	El trabajo de graduación «Gestión financiera de las pequeñas empresas familiares de San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de gestión financiera, empresa familiar y pyme. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2022	1	23	40	\N	no_publicado	no_autorizado	f	2022-10-09 06:06:34.633495	2022-10-19 13:05:33.00932
146	Impacto de las remesas en el consumo de los hogares de la zona oriental	Esta tesis estudia el tema «Impacto de las remesas en el consumo de los hogares de la zona oriental». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de remesas, consumo y hogares. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	2	12	11	\N	publicado	autorizado	f	2025-07-19 11:33:45.876298	2025-07-27 04:54:35.215558
153	Niveles de estrés académico en estudiantes de la facultad	El trabajo de graduación «Niveles de estrés académico en estudiantes de la facultad» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de estrés académico, universitarios y salud mental. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	1	17	21	\N	publicado	autorizado	f	2025-05-25 21:09:25.869552	2025-06-08 12:56:16.223162
139	Plan de mantenimiento preventivo para el parque vehicular de una alcaldía	El trabajo de graduación «Plan de mantenimiento preventivo para el parque vehicular de una alcaldía» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de mantenimiento preventivo, flota vehicular y gestión. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	1	1	48	\N	no_publicado	pendiente	f	2025-05-06 18:43:27.250555	2025-06-01 04:26:11.265774
147	Efectos de la adopción del bitcoin en pequeños comercios	Este proyecto de investigación estudia el tema «Efectos de la adopción del bitcoin en pequeños comercios». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de bitcoin, comercio y política monetaria. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	3	12	11	\N	publicado	autorizado	f	2025-07-02 20:18:34.828552	2025-07-05 09:04:40.190411
150	Glosario trilingüe de términos agrícolas	El trabajo de graduación «Glosario trilingüe de términos agrícolas» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de glosario, terminología y traducción. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	1	15	42	\N	publicado	autorizado	f	2025-10-05 14:18:18.773214	2025-11-03 16:54:19.865937
151	Memoria histórica del conflicto armado contada por habitantes de Morazán	Esta tesis estudia el tema «Memoria histórica del conflicto armado contada por habitantes de Morazán». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de memoria histórica, conflicto armado y Morazán. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	2	16	19	\N	no_publicado	pendiente	f	2025-10-05 06:01:08.509174	2025-10-26 21:32:14.532607
154	Complicaciones del dengue en niños atendidos en el hospital regional	El trabajo de graduación «Complicaciones del dengue en niños atendidos en el hospital regional» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de dengue, pediatría y complicaciones. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	1	18	13	\N	publicado	autorizado	f	2025-04-02 21:30:55.918236	2025-04-16 18:56:16.256506
159	Control estadístico de calidad en el llenado de botellas	Como proyecto final de Gestión de la Calidad se trabajó el tema «Control estadístico de calidad en el llenado de botellas». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de control estadístico, calidad y gráficos de control. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	4	21	25	292	publicado	autorizado	f	2025-04-14 01:53:55.163071	2025-04-18 11:05:01.558601
235	Programación lineal aplicada a la planificación de cosechas	Este trabajo de graduación desarrolla el tema «Programación lineal aplicada a la planificación de cosechas». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de programación lineal, optimización y agricultura. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2022	1	24	38	\N	publicado	autorizado	f	2022-04-29 23:18:30.364049	2022-05-07 08:40:55.752355
158	Pronóstico de la demanda para una distribuidora de productos de consumo	El proyecto de investigación «Pronóstico de la demanda para una distribuidora de productos de consumo» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de pronósticos, demanda y inventario. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	3	21	43	\N	publicado	autorizado	f	2025-08-29 11:33:05.093157	2025-09-09 08:24:25.477837
155	Adherencia al tratamiento en pacientes con enfermedad renal crónica	El proyecto de investigación «Adherencia al tratamiento en pacientes con enfermedad renal crónica» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de enfermedad renal crónica, adherencia y Bajo Lempa. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	3	18	26	\N	publicado	autorizado	f	2025-06-15 06:35:37.880731	2025-06-20 19:28:11.231078
149	Antología comentada de cuentos de Salarrué	Como proyecto final de Literatura Salvadoreña se trabajó el tema «Antología comentada de cuentos de Salarrué». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de Salarrué, cuento y antología. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	4	14	42	191	publicado	autorizado	f	2025-11-04 06:05:56.803444	2025-11-08 03:06:19.135203
157	Reducción de desperdicios en una panadería con manufactura esbelta	Este trabajo de graduación desarrolla el tema «Reducción de desperdicios en una panadería con manufactura esbelta». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de manufactura esbelta, desperdicios y panadería. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	1	21	25	\N	publicado	autorizado	f	2025-07-25 12:02:47.030581	2025-08-05 01:35:18.409168
152	Mapas digitales para enseñar la geografía de El Salvador	El proyecto de investigación «Mapas digitales para enseñar la geografía de El Salvador» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de mapas digitales, geografía y didáctica. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	3	16	33	\N	publicado	autorizado	f	2025-11-14 18:29:33.860697	2025-11-17 08:45:54.233062
156	Concepciones erróneas sobre la gravedad en estudiantes de bachillerato	Este proyecto de investigación estudia el tema «Concepciones erróneas sobre la gravedad en estudiantes de bachillerato». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de concepciones alternativas, gravedad y bachillerato. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	3	19	36	\N	publicado	autorizado	f	2025-06-02 06:15:12.965051	2025-06-11 04:22:22.34146
160	Plan de exportación de café de especialidad de Morazán a Canadá	Este trabajo de graduación desarrolla el tema «Plan de exportación de café de especialidad de Morazán a Canadá». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de exportación, café de especialidad y Canadá. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	1	22	8	\N	publicado	autorizado	f	2025-06-08 15:31:29.209648	2025-06-18 08:52:01.52988
236	Errores en el aprendizaje del álgebra en séptimo grado	El proyecto de investigación «Errores en el aprendizaje del álgebra en séptimo grado» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de álgebra, errores y tercer ciclo. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2022	3	28	15	\N	publicado	autorizado	f	2022-10-20 05:10:29.097327	2022-11-19 19:59:08.295941
239	Medición de la velocidad del sonido con un tubo de resonancia	Como proyecto final de Fundamentos de Física se trabajó el tema «Medición de la velocidad del sonido con un tubo de resonancia». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de velocidad del sonido, resonancia y laboratorio. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2022	4	33	36	278	publicado	autorizado	f	2022-06-30 14:05:34.470767	2022-08-03 23:01:15.516113
237	Logística inversa de envases en una distribuidora de bebidas	Este trabajo de graduación desarrolla el tema «Logística inversa de envases en una distribuidora de bebidas». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de logística inversa, envases y reciclaje. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2022	1	30	43	\N	publicado	autorizado	f	2022-06-16 21:34:43.665465	2022-07-07 03:41:52.804301
161	Estrategia de marca para las artesanías de barro de Guatajiagua	Este trabajo de graduación desarrolla el tema «Estrategia de marca para las artesanías de barro de Guatajiagua». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de marca, artesanías y Guatajiagua. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	1	22	8	\N	publicado	autorizado	f	2025-10-17 22:21:43.831697	2025-10-30 05:07:06.153069
165	Cumplimiento de obligaciones tributarias de los pequeños contribuyentes	El trabajo de graduación «Cumplimiento de obligaciones tributarias de los pequeños contribuyentes» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de tributación, IVA y pequeños contribuyentes. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	1	26	12	\N	publicado	autorizado	f	2025-04-05 19:52:49.26146	2025-04-09 13:20:49.587427
164	Análisis estadístico de la lluvia en la zona oriental de 1990 a 2024	El proyecto de investigación «Análisis estadístico de la lluvia en la zona oriental de 1990 a 2024» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de series de tiempo, precipitación y estadística. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	3	24	38	\N	publicado	autorizado	f	2025-09-10 09:24:52.354145	2025-09-15 18:46:59.684474
238	Caracterización de paneles solares en condiciones del oriente del país	Esta tesis estudia el tema «Caracterización de paneles solares en condiciones del oriente del país». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de paneles solares, eficiencia y radiación. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2022	2	33	36	\N	retirado	autorizado	f	2022-02-26 05:32:53.452918	2022-05-28 13:26:51.144814
171	Abono orgánico elaborado con residuos de la cosecha de café	Este proyecto de investigación estudia el tema «Abono orgánico elaborado con residuos de la cosecha de café». El estudio se llevó a cabo en parcelas y fincas de la zona oriental. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de abono orgánico, compost y café. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	3	32	39	\N	publicado	autorizado	f	2025-08-03 05:05:21.942469	2025-08-09 03:16:37.289272
172	Fertilidad de los suelos de las parcelas de la estación experimental	Proyecto desarrollado en la asignatura Fertilidad de Suelos, con el tema «Fertilidad de los suelos de las parcelas de la estación experimental». El estudio se llevó a cabo en parcelas y fincas de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de fertilidad, análisis de suelos y estación experimental. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	4	32	32	743	no_publicado	pendiente	f	2025-03-04 12:02:37.59221	2025-04-03 23:46:47.563602
240	Germinación de semillas de árboles nativos para reforestación	Proyecto desarrollado en la asignatura Botánica I, con el tema «Germinación de semillas de árboles nativos para reforestación». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de germinación, árboles nativos y reforestación. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	4	4	14	913	publicado	autorizado	f	2023-05-02 16:57:50.800545	2023-05-13 10:32:59.139458
241	Aprendizaje cooperativo en las clases de inglés de bachillerato	El trabajo de graduación «Aprendizaje cooperativo en las clases de inglés de bachillerato» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de aprendizaje cooperativo, inglés y bachillerato. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2023	1	7	15	\N	publicado	autorizado	f	2023-06-23 09:39:53.743487	2023-06-27 17:40:00.079447
181	Aprendizaje de vocabulario en inglés mediante aplicaciones móviles	Esta tesis estudia el tema «Aprendizaje de vocabulario en inglés mediante aplicaciones móviles». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de vocabulario, aplicaciones móviles y inglés. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	2	7	33	\N	no_publicado	pendiente	f	2026-09-06 17:00:14.551198	2026-09-15 10:32:01.902932
179	Incidencia de náuseas y vómitos postoperatorios en cirugía laparoscópica	El trabajo de graduación «Incidencia de náuseas y vómitos postoperatorios en cirugía laparoscópica» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de náuseas, vómitos y postoperatorio. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	1	6	22	\N	publicado	autorizado	f	2026-06-05 00:40:47.60319	2026-06-30 04:18:02.580108
163	Campaña de mercadeo digital para una cooperativa de productores	Proyecto desarrollado en la asignatura Mercadeo I, con el tema «Campaña de mercadeo digital para una cooperativa de productores». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de mercadeo digital, redes sociales y cooperativa. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	4	22	8	783	retirado	autorizado	f	2025-07-18 03:28:03.378001	2025-09-03 15:05:12.065787
168	Juegos matemáticos para el cálculo mental	Proyecto desarrollado en la asignatura Didáctica General, con el tema «Juegos matemáticos para el cálculo mental». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de cálculo mental, juegos y aritmética. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	4	28	15	389	publicado	autorizado	f	2025-03-22 03:42:44.641749	2025-03-29 22:38:45.008753
170	Riego por goteo en el cultivo de chile dulce	Este trabajo de graduación desarrolla el tema «Riego por goteo en el cultivo de chile dulce». El estudio se llevó a cabo en parcelas y fincas de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de riego por goteo, chile dulce y eficiencia hídrica. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	1	32	32	\N	publicado	autorizado	f	2025-04-25 16:03:27.280352	2025-05-03 01:11:27.627575
162	Investigación de mercado para una cafetería universitaria	Como proyecto final de Metodología de la Investigación de Mercados se trabajó el tema «Investigación de mercado para una cafetería universitaria». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de investigación de mercado, segmentación y cafetería. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	4	22	8	377	publicado	autorizado	f	2025-08-24 14:41:07.731759	2025-09-29 10:11:49.733459
166	Cambios en la vida rural a partir de las remesas	El proyecto de investigación «Cambios en la vida rural a partir de las remesas» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de remesas, vida rural y cambio social. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	3	27	19	\N	publicado	autorizado	f	2025-07-19 21:12:16.208369	2025-07-30 23:35:05.639773
167	Mapa de actores sociales de un municipio de Morazán	Como proyecto final de Teorías del Desarrollo se trabajó el tema «Mapa de actores sociales de un municipio de Morazán». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de actores sociales, municipio y desarrollo local. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	4	27	23	184	publicado	autorizado	f	2025-04-01 03:10:30.323196	2025-04-15 14:11:07.340605
169	Participación de las familias en la educación parvularia	Esta tesis estudia el tema «Participación de las familias en la educación parvularia». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de familia, educación parvularia y participación. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	2	31	15	\N	no_publicado	pendiente	f	2025-06-18 03:31:49.649231	2025-06-27 12:07:18.984195
174	Actividad sísmica de la cadena volcánica del oriente	El proyecto de investigación «Actividad sísmica de la cadena volcánica del oriente» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de sismología, volcanes y datos sísmicos. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	3	33	36	\N	publicado	autorizado	f	2025-10-26 02:31:51.789741	2025-10-28 18:29:17.128587
182	Corrección de errores escritos frecuentes en noveno grado	Como proyecto final de English Grammar I se trabajó el tema «Corrección de errores escritos frecuentes en noveno grado». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de escritura, errores y retroalimentación. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2026	4	7	42	375	no_publicado	pendiente	f	2026-11-20 23:00:38.235065	2026-11-21 08:28:03.585564
260	Guía de actividades de lectura en inglés para tercer ciclo	Proyecto desarrollado en la asignatura Reading and Conversation, con el tema «Guía de actividades de lectura en inglés para tercer ciclo». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de lectura, inglés y tercer ciclo. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	4	7	42	476	no_publicado	pendiente	f	2024-07-23 16:49:43.631526	2024-08-04 16:58:31.972566
263	Automedicación en estudiantes universitarios de San Miguel	El proyecto de investigación «Automedicación en estudiantes universitarios de San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con muestras y productos obtenidos en la zona oriental del país. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de automedicación, universitarios y farmacia. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	3	11	24	\N	publicado	autorizado	f	2024-11-12 05:42:12.04642	2024-11-18 02:04:15.416888
242	Anemia ferropénica en mujeres en edad fértil de comunidades rurales	Este trabajo de graduación desarrolla el tema «Anemia ferropénica en mujeres en edad fértil de comunidades rurales». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de anemia, hemoglobina y mujeres. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	1	8	31	\N	publicado	autorizado	f	2023-11-03 17:27:34.752845	2023-11-09 15:13:09.138108
173	Medición de la radiación solar en San Miguel con instrumentación de bajo costo	La tesis «Medición de la radiación solar en San Miguel con instrumentación de bajo costo» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de radiación solar, instrumentación y Arduino. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	2	33	36	\N	retirado	autorizado	f	2025-09-14 12:08:13.864117	2025-11-02 07:28:18.472865
175	Eficiencia energética de calderas en beneficios de café	El proyecto de investigación «Eficiencia energética de calderas en beneficios de café» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de calderas, eficiencia energética y café. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	3	1	41	\N	no_publicado	pendiente	f	2026-11-22 03:43:56.724639	2026-11-22 03:43:56.724639
252	Huerto escolar para niños de cinco años	Como proyecto final de Didáctica del Conocimiento del Medio Social y Natural en la Educación Infantil de 0 a 7 Años I se trabajó el tema «Huerto escolar para niños de cinco años». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de huerto escolar, medio natural y primera infancia. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	4	31	15	655	publicado	autorizado	f	2023-10-25 10:56:51.136828	2023-11-05 12:10:19.496715
176	Inventario de aves del campus de la Facultad Multidisciplinaria Oriental	Proyecto desarrollado en la asignatura Zoología general, con el tema «Inventario de aves del campus de la Facultad Multidisciplinaria Oriental». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de aves, inventario y campus. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	4	2	46	572	no_publicado	pendiente	f	2026-11-20 13:02:08.036359	2026-11-22 10:36:39.347041
247	Simulación de un sistema de colas en una agencia bancaria	Proyecto desarrollado en la asignatura Investigación de Operaciones I, con el tema «Simulación de un sistema de colas en una agencia bancaria». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de simulación, teoría de colas y servicio. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	4	21	25	1118	publicado	autorizado	f	2023-08-10 07:50:35.667569	2023-08-16 10:20:50.042104
256	El teletrabajo en la legislación laboral salvadoreña	El trabajo de graduación «El teletrabajo en la legislación laboral salvadoreña» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo a partir de la legislación vigente, la jurisprudencia y casos de los tribunales de San Miguel. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de teletrabajo, derecho laboral y legislación. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	1	5	44	\N	publicado	autorizado	f	2024-05-04 18:50:33.840772	2024-05-06 22:36:53.252599
266	Posicionamiento de la marca de un café de altura de Morazán	El trabajo de graduación «Posicionamiento de la marca de un café de altura de Morazán» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de posicionamiento, café y marca. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	1	22	8	\N	publicado	autorizado	f	2024-09-21 08:14:45.154224	2024-09-23 20:53:04.542014
267	Diseño organizacional de una cooperativa de transporte	Como proyecto final de Administración de Personal I se trabajó el tema «Diseño organizacional de una cooperativa de transporte». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de diseño organizacional, cooperativa y organigrama. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	4	23	40	593	publicado	autorizado	f	2024-04-23 20:01:25.236263	2024-05-05 18:49:59.606345
180	Valoración preanestésica en pacientes hipertensos	Como proyecto final de Introducción de la Anestesiología se trabajó el tema «Valoración preanestésica en pacientes hipertensos». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de valoración preanestésica, hipertensión y riesgo anestésico. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2026	4	6	22	281	no_publicado	pendiente	f	2026-11-16 00:59:59.218826	2026-11-20 19:54:31.237743
177	Identificación de hongos comestibles silvestres del oriente del país	Como proyecto final de Botánica I se trabajó el tema «Identificación de hongos comestibles silvestres del oriente del país». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de hongos, micología y taxonomía. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	4	4	46	913	no_publicado	pendiente	f	2026-11-19 23:01:37.645657	2026-11-21 11:12:55.981928
178	Análisis de la sentencia de inconstitucionalidad de la ley de amnistía	Proyecto desarrollado en la asignatura Derecho Constitucional I, con el tema «Análisis de la sentencia de inconstitucionalidad de la ley de amnistía». El estudio se llevó a cabo a partir de la legislación vigente, la jurisprudencia y casos de los tribunales de San Miguel. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de inconstitucionalidad, amnistía y Sala de lo Constitucional. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	4	5	9	845	no_publicado	pendiente	f	2026-11-21 19:00:41.281019	2026-11-21 19:00:41.281019
187	Efectos del uso de redes sociales en la autoestima de adolescentes	Este proyecto de investigación estudia el tema «Efectos del uso de redes sociales en la autoestima de adolescentes». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de redes sociales, autoestima y adolescentes. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	3	17	21	\N	publicado	autorizado	f	2026-07-17 04:48:04.255202	2026-07-26 23:55:04.626428
186	Línea de tiempo interactiva de la historia política salvadoreña	Proyecto desarrollado en la asignatura Historia de Centroamérica y El Salvador, con el tema «Línea de tiempo interactiva de la historia política salvadoreña». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de línea de tiempo, historia política y recurso digital. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	4	16	33	819	no_publicado	pendiente	f	2026-04-07 00:07:26.605777	2026-04-13 06:17:55.956571
184	Titulación potenciométrica de la acidez del vinagre comercial	Proyecto desarrollado en la asignatura Química Analítica I, con el tema «Titulación potenciométrica de la acidez del vinagre comercial». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de titulación, acidez y potenciometría. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	4	10	35	1169	no_publicado	pendiente	f	2026-05-28 11:07:11.578109	2026-05-30 15:01:31.919169
185	Estabilidad de una suspensión de amoxicilina reconstituida	Esta tesis estudia el tema «Estabilidad de una suspensión de amoxicilina reconstituida». El estudio se llevó a cabo con muestras y productos obtenidos en la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de estabilidad, amoxicilina y suspensión. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	2	11	24	\N	no_publicado	pendiente	f	2026-11-22 07:32:56.249189	2026-11-22 07:32:56.249189
253	Salidas de campo como estrategia para enseñar ecosistemas	El trabajo de graduación «Salidas de campo como estrategia para enseñar ecosistemas» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de salidas de campo, ecosistemas y didáctica. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	1	2	15	\N	publicado	autorizado	f	2024-03-08 06:50:39.151392	2024-03-11 17:15:30.534537
248	Impacto de la reforma fiscal en las pequeñas empresas	Este trabajo de graduación desarrolla el tema «Impacto de la reforma fiscal en las pequeñas empresas». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de reforma fiscal, impuestos y pymes. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	1	26	12	\N	publicado	autorizado	f	2023-08-12 18:14:29.679107	2023-08-17 11:51:56.049973
243	Hidroterapia en niños con parálisis cerebral	La tesis «Hidroterapia en niños con parálisis cerebral» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de hidroterapia, parálisis cerebral y niños. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2023	2	9	30	\N	retirado	autorizado	f	2023-05-18 00:46:48.817903	2023-09-19 12:03:51.173984
257	El debido proceso en el procedimiento administrativo sancionador	Proyecto desarrollado en la asignatura Derecho Administrativo I, con el tema «El debido proceso en el procedimiento administrativo sancionador». El estudio se llevó a cabo a partir de la legislación vigente, la jurisprudencia y casos de los tribunales de San Miguel. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de debido proceso, procedimiento administrativo y garantías. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	4	5	9	539	retirado	autorizado	f	2024-03-11 09:19:47.019601	2024-04-26 09:50:04.79494
188	Clima laboral en una empresa de servicios de la zona oriental	Este proyecto de investigación estudia el tema «Clima laboral en una empresa de servicios de la zona oriental». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de clima laboral, psicología organizacional y encuesta. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2026	3	17	21	\N	publicado	autorizado	f	2026-07-07 18:00:34.953754	2026-07-16 01:58:01.302617
183	Valores de referencia del hemograma en adultos de San Miguel	La tesis «Valores de referencia del hemograma en adultos de San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de hemograma, valores de referencia y hematología. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	2	8	31	\N	no_publicado	pendiente	f	2026-11-20 20:16:02.918121	2026-11-21 05:46:09.260348
258	Dolor postoperatorio en pacientes con bloqueo de plexo braquial	Esta tesis estudia el tema «Dolor postoperatorio en pacientes con bloqueo de plexo braquial». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de dolor postoperatorio, bloqueo de plexo y anestesia regional. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	2	6	22	\N	publicado	autorizado	t	2024-04-28 03:00:32.144799	2024-05-22 14:01:36.603607
244	Acceso al crédito de la micro y pequeña empresa en San Miguel	La tesis «Acceso al crédito de la micro y pequeña empresa en San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de crédito, mype y financiamiento. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	2	12	11	\N	publicado	autorizado	f	2023-07-16 01:33:16.504915	2023-07-18 11:47:57.887895
254	Herbario escolar con plantas de la zona oriental	Como proyecto final de Botánica General se trabajó el tema «Herbario escolar con plantas de la zona oriental». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de herbario, botánica y material didáctico. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	4	2	46	417	publicado	autorizado	t	2024-10-13 12:06:25.19386	2024-11-03 16:52:33.91686
249	Juventud rural y oportunidades de empleo en el oriente	El trabajo de graduación «Juventud rural y oportunidades de empleo en el oriente» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de juventud rural, empleo y desarrollo. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2023	1	27	19	\N	publicado	autorizado	f	2023-06-05 13:07:19.725842	2023-06-17 13:38:05.079112
261	Perfil lipídico en estudiantes universitarios de la facultad	Este proyecto de investigación estudia el tema «Perfil lipídico en estudiantes universitarios de la facultad». El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de perfil lipídico, colesterol y universitarios. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	3	8	31	\N	publicado	autorizado	f	2024-09-09 01:43:00.300296	2024-09-13 17:46:42.675333
284	Balanceo de línea en una maquila textil	La tesis «Balanceo de línea en una maquila textil» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de balanceo de línea, maquila y productividad. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	2	21	25	\N	publicado	autorizado	f	2025-05-03 13:26:17.907199	2025-05-14 04:00:14.276679
264	Sistema de control de asistencia con reconocimiento facial	Esta tesis estudia el tema «Sistema de control de asistencia con reconocimiento facial». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de reconocimiento facial, asistencia y visión por computadora. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	2	13	4	\N	publicado	autorizado	f	2024-06-22 05:26:37.741439	2024-06-27 22:14:44.096364
272	Taller de geometría con origami	Como proyecto final de Geometría I se trabajó el tema «Taller de geometría con origami». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de origami, geometría y material manipulativo. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	4	28	15	215	publicado	autorizado	f	2024-07-07 19:13:54.759753	2024-07-13 21:20:48.125558
273	Diseño de una mezcla de concreto con ceniza volcánica	Como proyecto final de Tecnología del Concreto se trabajó el tema «Diseño de una mezcla de concreto con ceniza volcánica». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de concreto, ceniza volcánica y materiales. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2024	4	29	7	981	publicado	autorizado	t	2024-07-04 08:45:17.801208	2024-08-08 04:29:30.495888
286	Modelos de regresión para el rendimiento del maíz	Esta tesis estudia el tema «Modelos de regresión para el rendimiento del maíz». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de regresión, estadística y maíz. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	2	24	38	\N	publicado	autorizado	f	2025-11-24 12:51:56.601117	2025-11-28 21:53:51.990108
277	Obtención de jabón artesanal a partir de aceites vegetales	Proyecto desarrollado en la asignatura Química Orgánica I, con el tema «Obtención de jabón artesanal a partir de aceites vegetales». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de saponificación, jabón y aceites vegetales. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	4	10	18	158	publicado	autorizado	f	2025-04-22 06:07:44.285104	2025-05-28 03:52:04.39852
274	Uso del microscopio en la enseñanza de la biología en centros públicos	Este proyecto de investigación estudia el tema «Uso del microscopio en la enseñanza de la biología en centros públicos». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de microscopio, laboratorio escolar y biología. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	3	2	15	\N	publicado	autorizado	f	2025-05-23 18:53:25.810479	2025-05-28 16:29:56.181684
268	Diseño de un albergue temporal para emergencias	El trabajo de graduación «Diseño de un albergue temporal para emergencias» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de albergue, emergencias y diseño arquitectónico. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	1	25	16	\N	publicado	autorizado	f	2024-09-11 07:56:52.254624	2024-09-25 11:04:19.624328
269	Elaboración de estados financieros para una tienda de abarrotes	Como proyecto final de Contabilidad Financiera I se trabajó el tema «Elaboración de estados financieros para una tienda de abarrotes». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de estados financieros, contabilidad y tienda. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2024	4	26	12	1159	publicado	autorizado	f	2024-09-07 15:14:59.290209	2024-09-20 19:35:52.672317
270	Las redes de apoyo de las madres solteras en San Miguel	La tesis «Las redes de apoyo de las madres solteras en San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de redes de apoyo, madres solteras y familia. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	2	27	19	\N	retirado	autorizado	f	2024-02-16 03:46:42.993669	2024-04-03 22:35:57.380925
276	Rehabilitación de la rodilla tras lesiones de ligamento cruzado	El trabajo de graduación «Rehabilitación de la rodilla tras lesiones de ligamento cruzado» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de ligamento cruzado, rodilla y rehabilitación. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	1	9	30	\N	publicado	autorizado	f	2025-09-29 14:47:45.540503	2025-10-25 13:04:15.624174
275	Diseño de la instalación eléctrica de un centro de salud rural	El trabajo de graduación «Diseño de la instalación eléctrica de un centro de salud rural» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de instalaciones eléctricas, normativa y centro de salud. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	1	3	41	\N	publicado	autorizado	f	2025-09-08 11:00:24.514811	2025-09-21 02:08:07.896909
271	Diagnóstico participativo de una comunidad del Bajo Lempa	Como proyecto final de Investigación Sociocrítica se trabajó el tema «Diagnóstico participativo de una comunidad del Bajo Lempa». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de diagnóstico participativo, comunidad y desarrollo local. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2024	4	27	23	608	publicado	autorizado	f	2024-11-08 15:30:16.713484	2024-11-14 12:07:10.083526
278	Formulación de una crema hidratante con aceite de coco	Proyecto desarrollado en la asignatura Tecnología Farmacéutica, con el tema «Formulación de una crema hidratante con aceite de coco». El estudio se llevó a cabo con muestras y productos obtenidos en la zona oriental del país. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de crema, formulación y aceite de coco. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	4	11	29	857	publicado	autorizado	f	2025-05-18 20:21:25.731853	2025-05-30 03:51:05.105252
279	El lenguaje juvenil en las redes sociales	Este proyecto de investigación estudia el tema «El lenguaje juvenil en las redes sociales». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de lenguaje juvenil, redes sociales y sociolingüística. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	3	14	42	\N	publicado	autorizado	f	2025-06-14 19:36:15.772093	2025-06-17 01:12:28.131824
282	Aprendizaje de la física a través de la resolución de problemas	El proyecto de investigación «Aprendizaje de la física a través de la resolución de problemas» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de resolución de problemas, física y aprendizaje. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	3	19	15	\N	publicado	autorizado	t	2025-10-21 10:13:29.844519	2025-12-04 17:14:00.539712
280	Taller de habilidades sociales para niños de primaria	Proyecto desarrollado en la asignatura Psicología de la Infancia y la Adolescencia, con el tema «Taller de habilidades sociales para niños de primaria». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de habilidades sociales, niños y taller. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	4	17	21	153	publicado	autorizado	f	2025-04-17 11:34:32.780517	2025-04-20 07:18:18.162203
281	Infecciones asociadas a la atención en salud en un hospital regional	La tesis «Infecciones asociadas a la atención en salud en un hospital regional» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con pacientes atendidos en hospitales y unidades de salud de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de infecciones nosocomiales, vigilancia y hospital. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	2	18	26	\N	publicado	autorizado	f	2025-11-10 00:40:09.824017	2025-11-21 18:58:26.185757
283	La química del agua potable: prácticas para educación media	Este trabajo de graduación desarrolla el tema «La química del agua potable: prácticas para educación media». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de agua potable, química y prácticas. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	1	20	18	\N	publicado	autorizado	f	2025-07-10 13:04:10.863118	2025-07-12 21:16:09.221273
285	Exportación de marañón procesado a Europa	Este proyecto de investigación estudia el tema «Exportación de marañón procesado a Europa». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de marañón, exportación y Unión Europea. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	3	22	8	\N	no_publicado	pendiente	f	2025-03-30 19:06:41.935529	2025-04-13 01:47:51.281127
289	Diseño de un sistema de drenaje pluvial para una colonia de San Miguel	El trabajo de graduación «Diseño de un sistema de drenaje pluvial para una colonia de San Miguel» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de drenaje pluvial, hidrología y colonia. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	1	29	7	\N	publicado	autorizado	f	2025-05-30 05:34:59.506826	2025-06-25 21:03:05.468077
288	Propuesta de mobiliario urbano para el parque central	Proyecto desarrollado en la asignatura Fundamentos de Diseño I, con el tema «Propuesta de mobiliario urbano para el parque central». El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de mobiliario urbano, espacio público y diseño. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	4	25	16	198	publicado	autorizado	f	2025-05-24 05:35:09.451774	2025-05-30 03:12:07.820313
290	Tiempos de despacho en la aduana terrestre de El Amatillo	Esta tesis estudia el tema «Tiempos de despacho en la aduana terrestre de El Amatillo». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. Se combinó la revisión de literatura especializada con mediciones y entrevistas en campo. Se abordan aspectos de aduana, tiempos de despacho y comercio regional. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	2	30	43	\N	publicado	autorizado	f	2025-08-05 21:39:03.033292	2025-08-24 16:49:05.013065
292	Producción de hongos comestibles con residuos agrícolas	El trabajo de graduación «Producción de hongos comestibles con residuos agrícolas» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en parcelas y fincas de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de hongos comestibles, residuos agrícolas y agroindustria. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2025	1	32	45	\N	retirado	autorizado	f	2025-05-08 14:55:45.197425	2025-08-10 18:46:42.469231
287	Confort térmico en las aulas de la facultad	El proyecto de investigación «Confort térmico en las aulas de la facultad» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de confort térmico, aulas y arquitectura bioclimática. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2025	3	25	16	\N	publicado	autorizado	f	2025-09-24 20:44:09.650857	2025-10-21 01:10:15.732181
291	Inclusión de niños con discapacidad en la educación parvularia	Esta tesis estudia el tema «Inclusión de niños con discapacidad en la educación parvularia». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de inclusión, discapacidad y parvularia. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2025	2	31	15	\N	no_publicado	pendiente	f	2025-04-19 11:36:19.607911	2025-05-02 18:21:41.91308
293	Análisis de fallas en ejes de transmisión de maquinaria agrícola	El proyecto de investigación «Análisis de fallas en ejes de transmisión de maquinaria agrícola» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de análisis de fallas, ejes y fatiga. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	3	1	48	\N	publicado	autorizado	t	2026-03-21 22:48:51.768738	2026-04-23 23:56:51.044956
295	Adsorción de colorantes con carbón activado de cáscara de coco	Este trabajo de graduación desarrolla el tema «Adsorción de colorantes con carbón activado de cáscara de coco». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se siguió un enfoque mixto con revisión bibliográfica, trabajo de campo y análisis de datos. Se abordan aspectos de carbón activado, adsorción y coco. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	1	10	18	\N	no_publicado	pendiente	f	2026-11-20 15:59:09.600281	2026-11-21 09:32:54.923288
294	Pérdidas técnicas en la red de distribución de un municipio	La tesis «Pérdidas técnicas en la red de distribución de un municipio» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo en condiciones reales de la zona oriental del país. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de pérdidas técnicas, distribución y eficiencia. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2026	2	3	41	\N	no_publicado	pendiente	f	2026-11-17 05:57:24.651361	2026-11-22 15:03:08.292661
300	Feria científica escolar sobre reacciones químicas	Proyecto desarrollado en la asignatura Didáctica General, con el tema «Feria científica escolar sobre reacciones químicas». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de feria científica, reacciones químicas y tercer ciclo. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	4	20	15	389	no_publicado	pendiente	f	2026-11-18 07:58:49.69521	2026-11-21 23:11:39.349483
299	Uso de modelos moleculares en la enseñanza de la química orgánica	El proyecto de investigación «Uso de modelos moleculares en la enseñanza de la química orgánica» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se planteó como un estudio exploratorio con recolección de datos primarios y secundarios. Se abordan aspectos de modelos moleculares, química orgánica y didáctica. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	3	20	15	\N	no_publicado	pendiente	f	2026-11-20 04:23:26.086515	2026-11-21 09:07:41.407163
296	Taller de escritura creativa para estudiantes de bachillerato	Proyecto desarrollado en la asignatura Expresión Oral y Escrita, con el tema «Taller de escritura creativa para estudiantes de bachillerato». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. El equipo trabajó por etapas: planteamiento del problema, desarrollo y presentación de resultados. Se abordan aspectos de escritura creativa, taller y bachillerato. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2026	4	14	42	1164	publicado	autorizado	f	2026-09-01 04:16:30.221532	2026-09-04 19:01:47.554335
297	El patrimonio cultural de San Miguel en la enseñanza de la historia	Este trabajo de graduación desarrolla el tema «El patrimonio cultural de San Miguel en la enseñanza de la historia». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de patrimonio cultural, historia y enseñanza. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	1	16	15	\N	no_publicado	pendiente	f	2026-11-22 08:08:45.180104	2026-11-22 08:08:45.180104
301	Aplicaciones de la teoría de números en criptografía	Proyecto desarrollado en la asignatura Teoría de Números, con el tema «Aplicaciones de la teoría de números en criptografía». El estudio se llevó a cabo con datos recolectados en la zona oriental del país. Se aplicaron los contenidos de la asignatura en un caso práctico de la región. Se abordan aspectos de teoría de números, criptografía y aritmética modular. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2026	4	24	38	380	no_publicado	pendiente	f	2026-11-18 11:49:03.647498	2026-11-21 13:03:59.297695
298	Síndrome de desgaste profesional en el personal de enfermería	Esta tesis estudia el tema «Síndrome de desgaste profesional en el personal de enfermería». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La investigación siguió un diseño cuantitativo con muestreo aleatorio y análisis estadístico. Se abordan aspectos de burnout, enfermería y salud mental. Los resultados permiten proponer recomendaciones para instituciones y estudios posteriores.	2026	2	17	21	\N	no_publicado	pendiente	f	2026-11-20 08:28:22.495697	2026-11-21 20:21:35.800741
302	Control de inventarios en farmacias independientes	Este proyecto de investigación estudia el tema «Control de inventarios en farmacias independientes». El estudio se llevó a cabo con información de empresas, instituciones y hogares de la zona oriental. El equipo aplicó instrumentos de recolección de datos y analizó los resultados con estadística descriptiva. Se abordan aspectos de control de inventarios, farmacias y costos. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	3	26	12	\N	publicado	autorizado	f	2026-09-01 07:01:10.601473	2026-09-14 21:04:43.938018
303	El arte infantil como medio de expresión emocional	Este trabajo de graduación desarrolla el tema «El arte infantil como medio de expresión emocional». El estudio se llevó a cabo con la participación de estudiantes, docentes y comunidades de la zona oriental. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de arte infantil, emociones y primera infancia. Se presentan conclusiones y recomendaciones que pueden aplicarse en contextos similares.	2026	1	31	15	\N	publicado	autorizado	f	2026-05-28 04:12:34.606846	2026-06-11 12:39:18.989963
304	Simulación numérica de la conducción de calor	El trabajo de graduación «Simulación numérica de la conducción de calor» se realizó en la Facultad Multidisciplinaria Oriental. El estudio se llevó a cabo con datos recolectados en la zona oriental del país. La metodología incluyó un diagnóstico inicial, el diseño de la propuesta y su validación con expertos. Se abordan aspectos de conducción de calor, simulación numérica y ecuaciones diferenciales. El documento incluye los resultados obtenidos, su discusión y líneas de trabajo futuro.	2026	1	33	36	\N	publicado	autorizado	f	2026-07-15 01:46:54.313046	2026-07-22 15:58:36.692972
\.


--
-- Data for Name: tbl_proyecto_autor; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_proyecto_autor (id_proyecto, id_autor, orden_autoria) FROM stdin;
4	3	1
4	4	2
5	5	1
5	6	2
6	7	1
6	8	2
7	9	1
7	10	2
8	11	1
9	12	1
10	13	1
11	14	1
11	15	2
12	16	1
12	17	2
13	18	1
13	19	2
14	20	1
14	21	2
14	22	3
15	23	1
16	24	1
16	25	2
16	26	3
17	27	1
17	28	2
18	29	1
18	30	2
18	31	3
18	32	4
19	33	1
19	34	2
20	35	1
21	36	1
21	37	2
21	38	3
22	39	1
22	40	2
22	41	3
22	42	4
23	43	1
23	44	2
24	45	1
24	46	2
24	47	3
25	48	1
26	49	1
26	50	2
27	51	1
27	52	2
27	53	3
28	54	1
28	55	2
28	56	3
28	57	4
29	58	1
29	59	2
29	60	3
30	23	1
30	61	2
30	62	3
31	63	1
31	64	2
31	65	3
32	66	1
32	67	2
33	68	1
33	69	2
33	70	3
33	71	4
34	72	1
35	73	1
35	74	2
36	75	1
36	76	2
37	77	1
37	78	2
37	79	3
38	80	1
38	81	2
38	82	3
39	83	1
39	84	2
40	85	1
40	86	2
41	87	1
41	88	2
41	89	3
41	90	4
42	91	1
42	92	2
42	93	3
42	94	4
43	95	1
43	96	2
43	97	3
43	98	4
44	36	1
44	99	2
44	100	3
45	101	1
45	102	2
46	103	1
46	104	2
47	105	1
48	106	1
48	107	2
48	108	3
49	51	1
50	109	1
50	110	2
51	111	1
51	112	2
51	113	3
52	114	1
53	115	1
53	116	2
53	117	3
53	118	4
54	20	1
54	119	2
55	120	1
56	121	1
56	122	2
56	123	3
57	124	1
58	125	1
58	126	2
58	127	3
59	128	1
59	129	2
60	130	1
60	131	2
60	132	3
60	133	4
61	134	1
61	135	2
62	27	1
62	136	2
63	137	1
64	138	1
64	139	2
65	80	1
65	140	2
66	141	1
66	142	2
67	143	1
67	144	2
67	145	3
67	146	4
68	147	1
68	148	2
69	149	1
69	150	2
69	151	3
70	9	1
70	152	2
70	153	3
71	154	1
71	155	2
71	156	3
72	157	1
72	158	2
72	159	3
73	160	1
73	161	2
74	160	1
74	162	2
75	163	1
76	164	1
76	165	2
77	166	1
77	167	2
77	168	3
78	169	1
78	170	2
79	171	1
80	130	1
80	172	2
82	175	1
83	176	1
84	177	1
85	178	1
85	179	2
86	180	1
88	184	1
90	186	1
90	187	2
91	188	1
93	190	1
93	191	2
96	196	1
97	197	1
97	198	2
97	199	3
98	200	1
99	201	1
99	202	2
99	203	3
99	204	4
107	224	1
107	225	2
107	226	3
107	227	4
109	229	1
109	230	2
109	231	3
111	234	1
111	235	2
116	185	1
116	243	2
116	244	3
117	12	1
117	245	2
118	246	1
118	247	2
118	248	3
120	251	1
120	252	2
120	253	3
122	257	1
122	258	2
122	259	3
123	260	1
123	261	2
125	262	1
125	263	2
125	264	3
127	266	1
127	267	2
81	173	1
81	174	2
87	181	1
87	182	2
87	183	3
89	185	1
92	189	1
94	192	1
94	193	2
95	194	1
95	195	2
100	205	1
100	206	2
100	207	3
100	208	4
101	209	1
101	210	2
102	211	1
102	212	2
102	213	3
102	214	4
103	215	1
103	216	2
104	217	1
104	218	2
105	219	1
105	220	2
106	221	1
106	222	2
106	223	3
108	141	1
108	228	2
110	232	1
110	233	2
112	184	1
112	236	2
113	237	1
113	238	2
113	239	3
114	240	1
114	241	2
115	242	1
119	249	1
119	250	2
121	254	1
121	255	2
121	256	3
124	111	1
126	265	1
128	268	1
128	269	2
128	270	3
129	200	1
130	271	1
130	272	2
130	273	3
131	274	1
132	275	1
132	276	2
132	277	3
133	278	1
133	279	2
133	280	3
134	281	1
135	282	1
136	283	1
136	284	2
136	285	3
136	286	4
137	287	1
137	288	2
138	289	1
139	290	1
139	291	2
140	217	1
140	292	2
141	293	1
141	294	2
141	295	3
142	229	1
142	296	2
142	297	3
143	298	1
143	299	2
144	300	1
144	301	2
144	302	3
144	303	4
145	304	1
145	305	2
145	306	3
146	307	1
147	308	1
147	309	2
147	310	3
148	311	1
148	312	2
148	313	3
149	314	1
149	315	2
149	316	3
149	317	4
150	190	1
150	318	2
150	319	3
151	45	1
152	320	1
152	321	2
153	322	1
153	323	2
154	324	1
155	325	1
155	326	2
155	327	3
156	328	1
156	329	2
156	330	3
156	331	4
157	164	1
158	332	1
158	333	2
158	334	3
159	194	1
159	335	2
160	336	1
160	337	2
161	262	1
161	338	2
161	339	3
162	340	1
162	341	2
162	342	3
163	343	1
163	344	2
164	345	1
164	346	2
164	347	3
165	348	1
165	349	2
166	350	1
166	351	2
166	352	3
166	353	4
167	354	1
167	355	2
167	356	3
168	357	1
168	358	2
168	359	3
169	360	1
169	361	2
170	362	1
170	363	2
170	364	3
171	365	1
171	366	2
172	367	1
172	368	2
173	369	1
174	370	1
174	371	2
174	372	3
175	373	1
175	374	2
175	375	3
176	376	1
176	377	2
177	378	1
177	379	2
177	380	3
178	381	1
178	382	2
179	383	1
179	384	2
180	85	1
180	385	2
180	386	3
181	181	1
181	387	2
182	388	1
182	389	2
182	390	3
182	391	4
183	392	1
188	251	1
188	404	2
184	393	1
184	394	2
184	395	3
185	396	1
185	397	2
186	398	1
186	399	2
186	400	3
186	401	4
187	402	1
187	403	2
189	192	1
189	405	2
189	406	3
190	106	1
190	407	2
191	408	1
192	265	1
192	409	2
193	410	1
193	411	2
194	412	1
194	413	2
195	414	1
196	415	1
197	416	1
197	417	2
197	418	3
198	419	1
198	420	2
199	209	1
199	421	2
199	422	3
200	423	1
201	424	1
201	425	2
202	426	1
202	427	2
202	428	3
202	429	4
203	430	1
203	431	2
203	432	3
203	433	4
204	434	1
205	435	1
205	436	2
205	437	3
206	438	1
206	439	2
206	440	3
206	441	4
207	442	1
207	443	2
207	444	3
208	445	1
208	446	2
208	447	3
209	448	1
209	449	2
209	450	3
209	451	4
210	452	1
211	453	1
211	454	2
212	455	1
212	456	2
212	457	3
213	458	1
213	459	2
213	460	3
214	461	1
214	462	2
215	463	1
216	464	1
216	465	2
216	466	3
216	467	4
217	468	1
218	469	1
218	470	2
219	471	1
219	472	2
219	473	3
220	471	1
220	474	2
220	475	3
221	476	1
222	477	1
222	478	2
222	479	3
223	477	1
223	480	2
223	481	3
224	482	1
225	483	1
225	484	2
226	485	1
226	486	2
227	487	1
227	488	2
228	489	1
228	490	2
228	491	3
229	492	1
230	464	1
231	493	1
232	494	1
232	495	2
232	496	3
233	497	1
233	498	2
233	499	3
233	500	4
234	492	1
234	501	2
235	502	1
236	503	1
236	504	2
236	505	3
237	506	1
237	507	2
238	508	1
239	509	1
239	510	2
240	511	1
240	512	2
240	513	3
241	514	1
241	515	2
241	516	3
242	453	1
242	517	2
242	518	3
243	519	1
244	520	1
245	483	1
245	521	2
246	522	1
246	523	2
247	442	1
247	524	2
248	525	1
248	526	2
249	527	1
249	528	2
250	529	1
250	530	2
250	531	3
251	532	1
251	533	2
251	534	3
251	535	4
252	536	1
252	537	2
252	538	3
253	539	1
253	540	2
253	541	3
254	542	1
254	543	2
255	544	1
256	452	1
256	545	2
256	546	3
257	547	1
257	548	2
257	549	3
257	550	4
258	551	1
258	552	2
259	553	1
259	554	2
260	555	1
260	556	2
261	557	1
261	558	2
262	519	1
262	559	2
262	560	3
262	561	4
263	455	1
263	562	2
264	563	1
264	564	2
265	565	1
265	566	2
266	567	1
266	568	2
266	569	3
267	570	1
267	571	2
268	572	1
269	573	1
269	574	2
270	575	1
270	576	2
271	527	1
271	577	2
271	578	3
271	579	4
272	580	1
272	581	2
272	582	3
272	583	4
273	584	1
273	585	2
273	586	3
274	587	1
274	588	2
275	448	1
275	589	2
275	590	3
276	591	1
277	592	1
277	593	2
277	594	3
277	595	4
278	596	1
278	597	2
278	598	3
278	599	4
279	600	1
279	601	2
279	602	3
279	603	4
280	604	1
280	605	2
280	606	3
281	487	1
281	607	2
282	608	1
282	609	2
282	610	3
282	611	4
283	612	1
283	613	2
284	614	1
285	615	1
285	616	2
285	617	3
285	618	4
286	619	1
287	620	1
287	621	2
287	622	3
287	623	4
288	624	1
288	625	2
288	626	3
289	627	1
289	628	2
290	629	1
291	630	1
291	631	2
292	632	1
292	633	2
292	634	3
293	635	1
293	636	2
293	637	3
293	638	4
294	639	1
294	640	2
295	641	1
296	642	1
296	643	2
297	522	1
297	644	2
297	645	3
298	646	1
298	647	2
299	648	1
299	649	2
299	650	3
299	651	4
300	652	1
300	653	2
301	654	1
301	655	2
301	656	3
302	657	1
302	658	2
303	659	1
303	660	2
303	661	3
304	662	1
\.


--
-- Data for Name: tbl_proyecto_docente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_proyecto_docente (id_proyecto, id_docente, nombre_autorizado) FROM stdin;
4	26	t
4	28	t
5	7	f
5	8	t
6	19	t
7	8	f
8	35	t
8	37	t
9	12	f
9	32	f
11	33	t
11	34	t
12	30	t
13	14	t
13	37	t
14	9	f
14	29	f
15	28	t
16	14	t
17	13	t
17	37	t
18	19	t
19	2	t
19	18	t
20	30	t
20	31	t
21	36	t
23	13	t
23	37	t
24	12	f
25	8	f
25	28	f
26	28	t
27	27	t
30	26	t
32	10	t
32	29	t
33	10	f
33	31	f
34	39	f
34	15	t
36	28	f
38	24	t
38	25	t
39	17	f
39	1	t
40	1	f
40	17	t
47	1	t
48	7	f
48	27	f
50	8	f
50	7	t
53	13	t
53	37	t
56	26	f
57	36	f
57	35	t
58	32	t
59	16	f
59	15	t
61	27	t
62	35	t
63	5	f
63	24	t
64	5	t
64	6	t
68	26	t
70	26	t
70	28	t
71	3	t
73	32	f
75	33	f
76	14	t
76	36	t
77	14	t
78	9	f
79	38	f
79	15	t
80	28	t
81	35	t
84	26	t
85	25	f
85	6	t
86	33	t
86	34	t
87	34	f
88	3	t
89	35	t
90	14	f
90	35	f
91	33	f
92	12	t
93	32	t
96	29	t
97	7	f
97	28	t
99	9	t
100	12	t
101	13	t
103	26	f
104	14	f
106	7	t
107	18	f
107	19	f
108	11	f
108	33	f
110	18	f
111	27	f
111	7	t
112	21	f
112	20	t
114	29	t
114	30	t
115	14	t
115	35	t
116	37	t
117	33	f
118	34	f
119	33	t
120	34	t
122	7	t
122	8	t
124	26	f
125	10	f
125	30	f
126	29	f
126	30	t
127	10	f
127	30	t
129	37	f
131	12	t
132	28	f
135	33	f
135	32	t
136	12	t
136	32	t
139	13	f
139	35	f
141	19	t
142	2	t
143	1	f
143	19	t
144	1	t
144	18	t
145	18	t
145	19	t
146	10	f
147	10	f
147	9	t
148	30	f
150	12	t
151	32	f
152	34	t
153	33	f
153	12	t
155	2	t
155	18	t
157	14	t
157	37	t
158	36	f
159	13	t
160	9	f
160	31	t
162	30	f
162	9	t
165	30	t
169	33	f
170	39	t
171	38	f
171	40	t
172	15	f
181	12	f
172	16	f
173	8	f
175	14	f
184	8	f
184	28	f
181	34	f
182	32	f
182	34	f
183	1	f
183	19	f
188	32	t
189	18	f
191	37	f
193	9	f
193	31	f
194	27	f
194	28	f
195	35	f
195	36	f
196	29	f
197	9	f
197	10	f
198	12	t
199	13	t
199	37	t
200	9	f
200	29	f
201	9	f
201	30	f
202	10	t
202	31	t
203	34	f
203	11	t
204	7	t
204	28	t
208	35	f
208	36	f
210	24	t
212	3	t
213	33	f
213	34	f
214	10	t
215	14	f
215	35	f
217	36	f
217	37	f
218	27	t
218	28	t
219	17	f
220	17	f
221	28	t
222	36	f
222	13	t
223	36	f
223	37	f
224	12	f
224	34	t
225	11	t
225	12	t
226	33	f
227	1	t
227	17	t
228	26	t
230	16	t
230	38	t
231	10	t
232	11	t
232	32	t
234	29	f
234	30	f
236	27	t
237	30	t
237	31	t
238	27	f
238	28	t
239	26	t
240	27	t
241	11	t
242	1	f
242	17	t
243	1	t
243	2	t
244	10	t
245	32	f
245	12	t
246	32	f
246	34	f
247	36	f
247	14	t
248	29	t
249	11	f
249	34	t
250	7	f
250	26	f
254	26	t
254	27	t
255	28	t
256	24	t
257	25	t
258	1	f
258	19	f
259	34	t
263	22	f
263	21	t
264	35	t
266	30	t
267	29	t
268	35	t
270	11	t
270	33	t
271	11	t
273	35	t
273	36	t
274	28	f
274	26	t
275	36	t
275	37	t
277	27	t
277	28	t
279	11	t
279	12	t
280	33	f
280	34	t
281	1	f
282	26	t
283	7	t
283	27	t
284	13	t
284	36	t
285	9	f
286	26	f
287	35	f
287	37	f
289	35	f
289	14	t
290	29	t
291	34	f
292	16	t
293	13	t
294	37	f
295	7	f
298	11	f
298	34	f
299	26	f
299	27	f
302	29	f
302	9	t
303	11	t
303	34	t
\.


--
-- Data for Name: tbl_proyecto_etiqueta; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_proyecto_etiqueta (id_proyecto, id_etiqueta) FROM stdin;
4	4
4	5
4	6
5	7
5	8
5	9
6	10
6	11
6	12
7	13
7	14
7	15
8	16
8	17
8	18
9	19
9	20
9	21
10	22
10	23
10	24
11	25
11	26
11	27
12	28
12	29
12	30
13	31
13	32
13	33
14	34
14	35
14	36
15	37
15	38
15	39
16	40
16	41
16	42
17	43
17	44
17	45
18	46
18	47
18	48
19	49
19	50
19	51
20	52
20	53
20	54
21	55
21	56
21	57
22	58
22	59
22	60
23	61
23	62
23	63
24	64
24	65
24	66
25	67
25	68
25	69
26	70
26	71
26	72
27	9
27	73
27	74
28	75
28	76
28	77
29	78
29	79
29	80
30	5
30	81
30	82
31	83
31	84
31	85
32	86
32	87
32	88
33	89
33	90
33	91
34	92
34	93
34	94
35	39
35	95
35	96
36	97
36	98
36	99
37	100
37	101
37	102
38	103
38	104
38	105
39	106
39	107
39	108
40	109
40	110
40	111
41	112
41	113
41	114
42	115
42	116
42	117
43	118
43	119
43	120
44	121
44	122
44	123
45	124
45	125
45	126
46	127
46	128
46	129
47	130
47	131
47	132
48	133
48	134
48	135
49	136
49	137
49	138
50	89
50	139
50	140
51	5
51	141
51	142
52	143
52	144
52	145
53	146
53	147
53	148
54	149
54	150
54	151
55	152
55	153
55	154
56	39
56	73
56	155
57	156
57	157
57	158
58	159
58	160
58	161
59	162
59	163
59	164
60	165
60	166
60	167
61	126
61	168
61	169
62	170
62	171
62	172
63	173
63	174
63	175
64	176
64	177
64	178
65	179
65	180
65	181
66	182
66	183
66	184
67	157
67	185
67	186
68	187
68	188
68	189
69	190
69	191
69	192
70	193
70	194
70	195
71	196
71	197
71	198
72	199
72	200
72	201
73	24
73	202
73	203
74	23
74	204
74	205
75	206
75	207
75	208
76	209
76	210
76	211
77	212
77	213
77	214
78	215
78	216
78	217
80	221
80	222
80	223
81	224
81	225
81	226
82	122
82	227
82	228
83	229
83	230
83	231
84	232
84	233
84	234
85	235
85	236
85	237
86	184
86	238
86	239
88	242
88	243
88	244
91	250
91	251
91	252
93	205
93	255
93	256
95	260
95	261
95	262
96	169
96	263
96	264
98	147
98	268
98	269
99	270
99	271
99	272
107	291
107	292
107	293
112	304
112	305
112	306
116	315
116	316
116	317
117	318
117	319
117	320
118	169
118	321
118	322
120	326
120	327
120	328
122	189
122	332
122	333
123	5
123	334
123	335
125	339
125	340
125	341
126	36
126	342
126	343
127	228
127	344
127	345
79	218
79	219
79	220
87	95
87	240
87	241
89	245
89	246
89	247
90	134
90	248
90	249
92	24
92	253
92	254
94	257
94	258
94	259
97	265
97	266
97	267
100	273
100	274
100	275
101	276
101	277
101	278
102	223
102	279
102	280
103	27
103	281
103	282
104	283
104	284
104	285
105	286
105	287
105	288
106	59
106	289
106	290
108	126
108	206
108	294
109	295
109	296
109	297
110	298
110	299
110	300
111	301
111	302
111	303
113	112
113	307
113	308
114	309
114	310
114	311
115	312
115	313
115	314
119	323
119	324
119	325
121	329
121	330
121	331
124	336
124	337
124	338
128	317
128	346
128	347
129	33
129	348
129	349
130	350
130	351
130	352
131	324
131	353
131	354
132	355
132	356
132	357
133	127
133	347
133	358
134	359
134	360
134	361
135	362
135	363
135	364
136	365
136	366
136	367
137	142
137	364
137	368
138	369
138	370
138	371
139	211
139	372
139	373
140	134
140	292
140	374
141	328
141	375
141	376
142	330
142	377
142	378
143	379
143	380
143	381
144	382
144	383
144	384
145	12
145	208
145	350
146	385
146	386
146	387
147	388
147	389
147	390
148	391
148	392
148	393
149	394
149	395
149	396
150	22
150	397
150	398
151	290
151	399
151	400
152	5
152	401
152	402
153	322
153	403
153	404
154	108
154	405
154	406
155	407
155	408
155	409
156	126
156	410
156	411
157	412
157	413
157	414
158	59
158	415
158	416
159	417
159	418
159	419
160	87
160	420
160	421
161	422
161	423
161	424
162	425
162	426
162	427
163	36
163	428
163	429
164	430
164	431
164	432
165	433
165	434
165	435
166	385
166	436
166	437
167	438
167	439
167	440
168	71
168	441
168	442
169	443
169	444
169	445
170	446
170	447
170	448
171	118
171	449
171	450
172	451
172	452
172	453
173	454
173	455
173	456
174	457
174	458
174	459
175	118
175	460
175	461
176	59
176	462
176	463
177	464
177	465
177	466
178	467
178	468
178	469
179	470
179	471
179	472
181	184
181	476
181	477
182	478
182	479
182	480
183	481
183	482
183	483
188	169
188	495
188	496
180	473
180	474
180	475
184	484
184	485
184	486
185	487
185	488
185	489
186	490
186	491
186	492
187	429
187	493
187	494
189	474
189	497
189	498
190	499
190	500
190	501
191	502
191	503
191	504
192	181
192	274
192	505
193	169
193	506
193	507
194	508
194	509
194	510
195	511
195	512
195	513
196	389
196	514
196	515
197	516
197	517
197	518
198	445
198	519
198	520
199	521
199	522
199	523
200	510
200	524
200	525
201	59
201	526
201	527
202	389
202	528
202	529
203	239
203	364
203	530
204	332
204	531
204	532
205	533
205	534
205	535
206	52
206	536
206	537
207	503
207	538
207	539
208	40
208	249
208	540
209	134
209	224
209	541
210	177
210	178
210	542
211	138
211	543
211	544
212	545
212	546
212	547
213	5
213	237
213	548
214	263
214	423
214	549
215	359
215	550
215	551
216	45
216	552
216	553
217	226
217	283
217	554
218	232
218	555
218	556
219	472
219	557
219	558
220	559
220	560
220	561
221	562
221	563
221	564
222	211
222	246
222	565
223	58
223	566
223	567
224	568
224	569
224	570
225	184
225	479
225	571
226	24
226	572
226	573
227	132
227	330
227	574
228	223
228	575
228	576
229	77
229	577
229	578
230	451
230	579
230	580
231	23
231	290
231	581
232	353
232	582
232	583
233	95
233	500
233	584
234	30
234	585
234	586
235	510
235	587
235	588
236	39
236	347
236	479
237	189
237	589
237	590
238	591
238	592
238	593
239	135
239	594
239	595
240	596
240	597
240	598
241	126
241	184
241	599
242	274
242	600
242	601
243	328
243	602
243	603
244	604
244	605
244	606
245	607
245	608
245	609
246	66
246	353
246	610
247	223
247	507
247	611
248	612
248	613
248	614
249	615
249	616
249	617
250	126
250	432
250	618
251	87
251	525
251	619
252	4
252	364
252	620
253	5
253	621
253	622
254	95
254	623
254	624
255	118
255	625
255	626
256	103
256	627
256	628
257	629
257	630
257	631
258	632
258	633
258	634
259	184
259	635
259	636
260	39
260	184
260	637
261	322
261	638
261	639
262	300
262	640
262	641
263	322
263	642
263	643
264	313
264	644
264	645
265	406
265	646
265	647
266	118
266	422
266	648
267	36
267	649
267	650
268	349
268	651
268	652
269	515
269	653
269	654
270	443
270	655
270	656
271	440
271	657
271	658
272	81
272	82
272	659
273	160
273	359
273	660
274	6
274	137
274	661
275	662
275	663
275	664
276	50
276	665
276	666
277	667
277	668
277	669
278	198
278	670
278	671
279	318
279	429
279	672
280	42
280	328
280	673
281	674
281	675
281	676
282	38
282	72
282	677
283	74
283	212
283	336
284	503
284	678
284	679
285	87
285	680
285	681
286	119
286	432
286	553
287	512
287	513
287	682
288	33
288	41
288	683
289	684
289	685
289	686
290	687
290	688
290	689
291	240
291	351
291	367
292	164
292	192
292	690
293	691
293	692
293	693
294	172
294	592
294	694
295	695
295	696
295	697
296	42
296	126
296	698
297	26
297	129
297	699
298	404
298	700
298	701
299	5
299	702
299	703
300	39
300	704
300	705
301	706
301	707
301	708
302	709
302	710
302	711
303	364
303	712
303	713
304	143
304	714
304	715
\.


--
-- Data for Name: tbl_recurso; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_recurso (id_recurso, id_entrega, id_tipo_recurso, nombre, ubicacion, difusion_autorizada) FROM stdin;
7	5	1	huerto-escolar-como-recurso-didactico-para-la-ensenanza.pdf	App_Data/entregas/5/7f91b647136c4d1f916e02659906fd89.pdf	t
8	6	1	estrategias-ludicas-para-la-ensenanza-de-la-genetica-en.pdf	App_Data/entregas/6/63bc249feb394986b559b306d9fc7353.pdf	f
9	7	1	estrategias-ludicas-para-la-ensenanza-de-la-genetica-en.pdf	App_Data/entregas/6/63bc249feb394986b559b306d9fc7353.pdf	f
10	8	1	estimulacion-temprana-en-ninos-con-sindrome-de-down.pdf	App_Data/entregas/8/e494bd5badc845a3855bfae56074810e.pdf	t
11	9	1	cinetica-de-degradacion-de-colorantes-por-fotocatalisis.pdf	App_Data/entregas/9/a610b3bad21844d9a8bebbf06c28fa52.pdf	t
12	10	1	chatbot-de-atencion-a-estudiantes-de-nuevo-ingreso.pdf	App_Data/entregas/10/444d97e1cbb14c7e82721c449a56c99f.pdf	t
13	10	3	Enlace: github.com	https://github.com/ues-fmo/chatbot-de-atencion-a-estudiantes-de-nuevo-ingreso	t
14	11	1	la-poesia-de-roque-dalton-desde-la-critica-social.pdf	App_Data/entregas/11/5e92583ef83541ca8232498cb33112b3.pdf	f
15	12	1	traduccion-al-frances-de-folletos-turisticos-de-la-ruta.pdf	App_Data/entregas/12/e42b08a81f034a1c867dd2b59c4676a6.pdf	t
16	13	1	ensenanza-de-la-historia-local-en-centros-escolares-de.pdf	App_Data/entregas/13/8e318b7e88894915b0b2a996bc176d28.pdf	t
17	14	1	manual-de-puestos-para-una-empresa-familiar-de-transpor.pdf	App_Data/entregas/14/9d6d07fe6ba54ed29e44b726dee75aee.pdf	f
18	15	1	manual-de-puestos-para-una-empresa-familiar-de-transpor.pdf	App_Data/entregas/14/9d6d07fe6ba54ed29e44b726dee75aee.pdf	t
19	16	1	anteproyecto-de-un-parque-lineal-junto-al-rio-grande-de.pdf	App_Data/entregas/16/acc456605bcf4e62960fd0b2a7540061.pdf	t
20	17	1	control-interno-para-una-cooperativa-agricola.pdf	App_Data/entregas/17/e4dcbc476cc5419dab87973e98492499.pdf	f
21	18	1	dificultades-en-la-resolucion-de-problemas-con-fraccion.pdf	App_Data/entregas/18/6c223d052bf142c4bc859f044f594ba8.pdf	f
22	19	1	dificultades-en-la-resolucion-de-problemas-con-fraccion.pdf	App_Data/entregas/18/6c223d052bf142c4bc859f044f594ba8.pdf	t
23	20	1	rediseno-de-una-prensa-hidraulica-para-el-taller-de-la.pdf	App_Data/entregas/20/a7b449b5bb584da88b5d5251febf88aa.pdf	t
24	21	1	control-de-velocidad-de-un-motor-trifasico-con-variador.pdf	App_Data/entregas/21/6f1c0b8d743742e4ae0cfaa6c57669d0.pdf	t
25	22	1	uso-de-dexmedetomidina-como-sedante-en-cuidados-intensi.pdf	App_Data/entregas/22/fc164ed4ae8a45a3a57e2f0af448234e.pdf	t
26	23	1	rehabilitacion-de-pacientes-con-secuelas-de-accidente-c.pdf	App_Data/entregas/23/6c1b0204c2174e7c9285d5e904369f2d.pdf	f
27	24	1	inflacion-de-la-canasta-basica-alimentaria-entre-2020-y.pdf	App_Data/entregas/24/f25bc5dbfeba4351a6e7e60509ddf852.pdf	f
29	25	2	aplicacion-movil-de-reporte-de-baches-para-la-alcaldia-codigo.zip	App_Data/entregas/25/2a130d40415f46f785b0ebc41d6d3271.zip	f
28	25	1	aplicacion-movil-de-reporte-de-baches-para-la-alcaldia.pdf	App_Data/entregas/25/a0124672f85b4e47bf9bac87d88a00b3.pdf	t
30	25	3	Enlace: github.com	https://github.com/ues-fmo/aplicacion-movil-de-reporte-de-baches-para-la-alcaldia	t
31	26	1	base-de-datos-para-el-control-de-inventario-de-una-farm.pdf	App_Data/entregas/26/7afa5f38ab8345708eb8ce4213669fae.pdf	t
32	27	1	analisis-de-vulnerabilidades-en-sitios-web-de-instituci.pdf	App_Data/entregas/27/2bba40f61cef4ff187bb24fdf964cff1.pdf	f
33	27	3	Enlace: github.com	https://github.com/ues-fmo/analisis-de-vulnerabilidades-en-sitios-web-de-instituci	f
34	28	1	educacion-civica-y-participacion-de-los-jovenes-en-su-c.pdf	App_Data/entregas/28/58cd6c2a40ac4816bb4158fafa4bdff3.pdf	f
35	29	1	experimentos-de-bajo-costo-para-ensenar-cinematica-en-n.pdf	App_Data/entregas/29/0538e7f6fc4a40deb56ad85ff3bc41a7.pdf	f
36	30	1	juegos-de-mesa-para-aprender-la-tabla-periodica.pdf	App_Data/entregas/30/56d00f7d06ee47b0ab5f297b483887e0.pdf	f
37	31	1	juegos-de-mesa-para-aprender-la-tabla-periodica.pdf	App_Data/entregas/30/56d00f7d06ee47b0ab5f297b483887e0.pdf	t
38	32	1	actitudes-hacia-la-quimica-en-estudiantes-de-educacion.pdf	App_Data/entregas/32/f4b82dfe9e1249a1923874b7a33b978d.pdf	t
39	33	1	diagnostico-de-la-gestion-del-talento-humano-en-una-alc.pdf	App_Data/entregas/33/5c37667d6aac4f41ba63baf5821f1362.pdf	f
40	34	1	diagnostico-de-la-gestion-del-talento-humano-en-una-alc.pdf	App_Data/entregas/33/5c37667d6aac4f41ba63baf5821f1362.pdf	t
41	35	1	metodos-numericos-para-sistemas-de-ecuaciones-no-lineal.pdf	App_Data/entregas/35/989b072d669047dda3d7a94b3750cd7e.pdf	f
42	36	1	metodos-numericos-para-sistemas-de-ecuaciones-no-lineal.pdf	App_Data/entregas/35/989b072d669047dda3d7a94b3750cd7e.pdf	t
43	37	1	material-manipulativo-para-la-ensenanza-de-la-geometria.pdf	App_Data/entregas/37/d70a86d170664c378d15571e80197883.pdf	f
44	38	1	estudio-de-suelos-para-la-ampliacion-de-un-puente-vehic.pdf	App_Data/entregas/38/8a4609f9333c4d23a1c71069d8a65e85.pdf	f
45	39	1	estudio-de-suelos-para-la-ampliacion-de-un-puente-vehic.pdf	App_Data/entregas/38/8a4609f9333c4d23a1c71069d8a65e85.pdf	f
46	40	1	tramites-aduaneros-para-exportar-productos-agricolas.pdf	App_Data/entregas/40/2b9e9ab184244066a1f737ae7fb46b17.pdf	f
47	41	1	indicadores-logisticos-para-una-ferreteria.pdf	App_Data/entregas/41/40238c0ab46f45238c50bdaedfcdbad1.pdf	f
48	42	1	indicadores-logisticos-para-una-ferreteria.pdf	App_Data/entregas/41/40238c0ab46f45238c50bdaedfcdbad1.pdf	f
49	43	1	control-biologico-de-la-mosca-blanca-en-el-cultivo-de-t.pdf	App_Data/entregas/43/28e738039eaf4fd598741404d53e6175.pdf	f
50	44	1	modelos-tridimensionales-de-la-celula-para-estudiantes.pdf	App_Data/entregas/44/4ebcb528ec0d4f9aa8ec067d3ecca6d1.pdf	f
51	45	1	propagacion-in-vitro-de-orquideas-nativas-en-peligro-de.pdf	App_Data/entregas/45/5a081cf4ef724f2a9ad4933be9a43d50.pdf	f
52	46	1	efecto-de-la-temperatura-en-el-desarrollo-de-larvas-de.pdf	App_Data/entregas/46/c221c18c388a43c0a8cd60a0c36c85fc.pdf	f
53	47	1	el-despido-de-trabajadoras-embarazadas-en-la-legislacio.pdf	App_Data/entregas/47/60eb8bc190504fef93e8e0ef06a060ff.pdf	f
54	48	1	bloqueo-subaracnoideo-frente-a-anestesia-general-en-ces.pdf	App_Data/entregas/48/394a3385ea5a4c0ab0e44ffbad18dfa4.pdf	t
57	51	1	interacciones-medicamentosas-en-pacientes-polimedicados.pdf	App_Data/entregas/51/a436e4b1fd084bd0a89072c3a90d4dd3.pdf	f
60	54	1	aplicacion-de-escritorio-para-la-gestion-de-bibliotecas.pdf	App_Data/entregas/54/bddcc7abaf5e4cc98962e08decdc29be.pdf	f
61	54	2	aplicacion-de-escritorio-para-la-gestion-de-bibliotecas-codigo.zip	App_Data/entregas/54/f3afa6dd88294734bcaabe7dfac87800.zip	f
63	56	1	errores-ortograficos-frecuentes-en-textos-de-estudiante.pdf	App_Data/entregas/55/cdcc8e36057240658f0a7f6021fa2615.pdf	f
64	57	1	secuencia-didactica-sobre-la-independencia-centroameric.pdf	App_Data/entregas/57/ed05049fe03a4cb5a9d4a1f72b371bf7.pdf	t
65	58	1	factores-de-riesgo-de-diabetes-tipo-2-en-unidades-de-sa.pdf	App_Data/entregas/58/00e0e8f977234582b7b651e4d365cc6a.pdf	t
66	59	1	pendulo-con-sensor-para-medir-la-aceleracion-de-la-grav.pdf	App_Data/entregas/59/f75ad9740999456ba4ddc6c28c734c75.pdf	f
69	62	1	indicadores-acido-base-elaborados-con-repollo-morado.pdf	App_Data/entregas/62/a60530c34d8345969403f6a6363874f8.pdf	f
70	63	1	indicadores-acido-base-elaborados-con-repollo-morado.pdf	App_Data/entregas/62/a60530c34d8345969403f6a6363874f8.pdf	f
71	64	1	planificacion-de-una-unidad-sobre-el-enlace-quimico.pdf	App_Data/entregas/64/701460413313415fae45a11e1a4e408f.pdf	t
72	65	1	modelos-de-ecuaciones-diferenciales-para-la-propagacion.pdf	App_Data/entregas/65/3004000cdb184688a0829c8cb6a317e2.pdf	f
73	66	1	modelos-de-ecuaciones-diferenciales-para-la-propagacion.pdf	App_Data/entregas/65/3004000cdb184688a0829c8cb6a317e2.pdf	t
77	70	1	violencia-de-genero-en-el-ambito-universitario.pdf	App_Data/entregas/70/2dcd35795fcc49c5a65c5b07b18a8927.pdf	t
80	73	1	rincones-de-aprendizaje-con-materiales-del-entorno.pdf	App_Data/entregas/73/61127970641b4834962288c25c98db66.pdf	f
83	76	1	determinacion-de-la-constante-de-planck-con-diodos-led.pdf	App_Data/entregas/76/b01a020d699a4200a75bc4f7f5f8812f.pdf	f
84	77	1	conocimientos-sobre-educacion-ambiental-en-estudiantes.pdf	App_Data/entregas/77/4c5f8965fbac4d9f8b48c7059576f178.pdf	f
85	78	1	calidad-de-energia-en-la-red-de-distribucion-de-un-cent.pdf	App_Data/entregas/78/08ce9f617ba941e98caad9aa368e2b5e.pdf	f
88	81	1	cumplimiento-de-la-cuota-alimenticia-en-los-juzgados-de.pdf	App_Data/entregas/81/a249eb92ab6b481d8a208a28937a293a.pdf	f
91	84	1	la-sociedad-por-acciones-simplificada-en-el-codigo-de-c.pdf	App_Data/entregas/83/a9696428a459468b8cfc7571998ad9e5.pdf	t
94	87	1	sintesis-de-biodiesel-a-partir-de-aceite-de-cocina-usad.pdf	App_Data/entregas/87/b85b56f1d9e64cee87152120c6cf2dc6.pdf	f
95	88	1	extraccion-de-pectina-de-la-cascara-de-naranja.pdf	App_Data/entregas/88/ec3bf39f5b714f3a9da501fbedc70021.pdf	t
55	49	1	manejo-de-la-via-aerea-dificil-en-pacientes-con-obesida.pdf	App_Data/entregas/49/e1d3972dd241464f9862b712459e297c.pdf	f
56	50	1	control-de-calidad-interno-en-el-laboratorio-de-quimica.pdf	App_Data/entregas/50/b1b6da5140fd49bf82e5a2feec69e3f0.pdf	f
58	52	1	interacciones-medicamentosas-en-pacientes-polimedicados.pdf	App_Data/entregas/51/a436e4b1fd084bd0a89072c3a90d4dd3.pdf	f
59	53	1	modelo-de-regresion-del-precio-internacional-del-cafe.pdf	App_Data/entregas/53/61292b392d3840d88f7bdae84740ba3c.pdf	f
62	55	1	errores-ortograficos-frecuentes-en-textos-de-estudiante.pdf	App_Data/entregas/55/cdcc8e36057240658f0a7f6021fa2615.pdf	f
67	60	1	manual-de-seguridad-para-laboratorios-escolares-de-quim.pdf	App_Data/entregas/60/668c3b1d5cb643f6b729058e6e37dd43.pdf	f
68	61	1	manual-de-seguridad-para-laboratorios-escolares-de-quim.pdf	App_Data/entregas/60/668c3b1d5cb643f6b729058e6e37dd43.pdf	t
74	67	1	levantamiento-arquitectonico-de-la-catedral-de-san-migu.pdf	App_Data/entregas/67/27162bb1ed18423f8138d7fe20300dfe.pdf	f
75	68	1	levantamiento-arquitectonico-de-la-catedral-de-san-migu.pdf	App_Data/entregas/67/27162bb1ed18423f8138d7fe20300dfe.pdf	t
76	69	1	auditoria-de-inventarios-en-una-ferreteria.pdf	App_Data/entregas/69/d584817e29984de1bacd1e4f57205600.pdf	t
78	71	1	ansiedad-matematica-en-estudiantes-de-septimo-grado.pdf	App_Data/entregas/71/32a8dd04aafd45c9bd3bb24e99e5a2d1.pdf	f
79	72	1	evaluacion-del-pavimento-de-la-carretera-panamericana-e.pdf	App_Data/entregas/72/f82ed110a94f48438c42840efc600e9e.pdf	t
81	74	1	rincones-de-aprendizaje-con-materiales-del-entorno.pdf	App_Data/entregas/73/61127970641b4834962288c25c98db66.pdf	t
82	75	1	deshidratado-de-mango-como-alternativa-de-agroindustria.pdf	App_Data/entregas/75/19edbb1ab9614cc28cdca220dfa19fe7.pdf	t
86	79	1	calidad-de-energia-en-la-red-de-distribucion-de-un-cent.pdf	App_Data/entregas/78/08ce9f617ba941e98caad9aa368e2b5e.pdf	t
87	80	1	la-prueba-pericial-en-el-proceso-penal-salvadoreno.pdf	App_Data/entregas/80/f5b233733d414214aff9d2e3c9f9e2a6.pdf	t
89	82	1	cumplimiento-de-la-cuota-alimenticia-en-los-juzgados-de.pdf	App_Data/entregas/81/a249eb92ab6b481d8a208a28937a293a.pdf	f
90	83	1	la-sociedad-por-acciones-simplificada-en-el-codigo-de-c.pdf	App_Data/entregas/83/a9696428a459468b8cfc7571998ad9e5.pdf	f
92	85	1	unidad-didactica-de-ingles-basada-en-tareas.pdf	App_Data/entregas/85/ae565550bd8a408ba4095a62fa532259.pdf	t
93	86	1	evaluacion-postural-en-escolares-que-usan-mochila.pdf	App_Data/entregas/86/988883fcc18c4a999afadc6144775599.pdf	t
96	89	1	contenido-de-cafeina-en-bebidas-energeticas-comerciales.pdf	App_Data/entregas/89/5fe9518b32f34f3b81fc0d78a0c93879.pdf	f
97	90	1	formulacion-de-un-gel-cicatrizante-a-base-de-sabila.pdf	App_Data/entregas/90/b37df00c6dbc4275a7a4acf3ffe724bb.pdf	f
98	91	1	formulacion-de-un-gel-cicatrizante-a-base-de-sabila.pdf	App_Data/entregas/90/b37df00c6dbc4275a7a4acf3ffe724bb.pdf	t
99	92	1	diseno-de-la-red-de-datos-de-un-centro-escolar.pdf	App_Data/entregas/92/f991566fbd7f4864a0daf217a4842f57.pdf	f
100	92	2	diseno-de-la-red-de-datos-de-un-centro-escolar-codigo.zip	App_Data/entregas/92/adafcdaa02074418854aef1d9f0f5748.zip	f
101	92	3	Enlace: github.com	https://github.com/ues-fmo/diseno-de-la-red-de-datos-de-un-centro-escolar	f
102	93	3	Enlace: github.com	https://github.com/ues-fmo/diseno-de-la-red-de-datos-de-un-centro-escolar	f
103	93	1	diseno-de-la-red-de-datos-de-un-centro-escolar.pdf	App_Data/entregas/92/f991566fbd7f4864a0daf217a4842f57.pdf	f
104	93	2	diseno-de-la-red-de-datos-de-un-centro-escolar-codigo.zip	App_Data/entregas/92/adafcdaa02074418854aef1d9f0f5748.zip	f
105	93	3	Enlace: github.com	https://github.com/ues-fmo/diseno-de-la-red-de-datos-de-un-centro-escolar	f
106	94	1	interferencia-del-espanol-en-la-pronunciacion-del-franc.pdf	App_Data/entregas/94/7c7c993e2e3d4fa0b43643a376b0af77.pdf	f
107	95	1	interpretacion-consecutiva-en-un-foro-de-turismo.pdf	App_Data/entregas/95/a2f0241c0d1d45789534fa949efc5649.pdf	t
108	96	1	ansiedad-y-depresion-en-adultos-mayores-de-hogares-de-a.pdf	App_Data/entregas/96/0faf5bdb67514df9a5858d54618b3905.pdf	f
109	97	1	sistema-de-gestion-de-seguridad-y-salud-ocupacional-par.pdf	App_Data/entregas/97/0c3b9b1aebbb444583bee5173f514f78.pdf	t
110	98	1	sistema-de-agua-potable-para-un-caserio-de-morazan.pdf	App_Data/entregas/98/3813ebebc6df474592f0d3b9ac28b694.pdf	f
111	99	1	seleccion-de-incoterms-en-la-importacion-de-maquinaria.pdf	App_Data/entregas/99/7394786d52c6498391a57095bd62d0e6.pdf	t
112	100	1	rendimiento-de-variedades-de-frijol-rojo-en-el-valle-de.pdf	App_Data/entregas/100/d8e80e89032d43239c0843daaee7f5f5.pdf	f
113	101	1	simulacion-del-comportamiento-caotico-del-pendulo-doble.pdf	App_Data/entregas/101/6c754c081cd544fe87bf5de7874e0b96.pdf	f
114	102	1	diseno-de-un-secador-solar-de-granos-para-pequenos-prod.pdf	App_Data/entregas/102/87d40bb2f8094d3c8feabcf63745cf1c.pdf	f
115	103	1	diseno-de-un-secador-solar-de-granos-para-pequenos-prod.pdf	App_Data/entregas/102/87d40bb2f8094d3c8feabcf63745cf1c.pdf	t
116	104	1	factibilidad-de-un-sistema-fotovoltaico-para-la-bibliot.pdf	App_Data/entregas/104/fe83def55954430186f6a84f0a704c8c.pdf	f
117	105	1	coordinacion-de-protecciones-en-una-subestacion-de-46-k.pdf	App_Data/entregas/105/a9be4141952546449bf27bbebc0bef5a.pdf	t
118	106	1	calidad-del-agua-del-rio-grande-de-san-miguel-mediante.pdf	App_Data/entregas/106/c03274062af84fc38bbb530901f56673.pdf	t
119	107	1	proteccion-de-datos-personales-frente-a-las-nuevas-tecn.pdf	App_Data/entregas/107/df0ff7485ea94b47ac76d32761a649b0.pdf	f
120	108	1	uso-de-canciones-para-mejorar-la-pronunciacion-del-ingl.pdf	App_Data/entregas/108/812b0f02ab7c405db4b349be7ad726e2.pdf	f
121	109	1	material-didactico-de-ingles-para-estudiantes-con-baja.pdf	App_Data/entregas/109/ad2ca776b8af4796ade97cafeb2ab65f.pdf	f
122	110	1	actividad-antibacteriana-del-extracto-de-hojas-de-guaya.pdf	App_Data/entregas/110/318ab7f686f64ea88b8b9221a7c2f161.pdf	f
123	111	1	sistema-web-para-la-gestion-de-citas-de-la-clinica-univ.pdf	App_Data/entregas/111/4baaa2f62d814ce7aaae3987ea8ac21d.pdf	t
124	111	2	sistema-web-para-la-gestion-de-citas-de-la-clinica-univ-codigo.zip	App_Data/entregas/111/2bf015da61d64159862d49066064cf4d.zip	t
125	111	3	Enlace: github.com	https://github.com/ues-fmo/sistema-web-para-la-gestion-de-citas-de-la-clinica-univ	t
129	113	3	Enlace: github.com	https://github.com/ues-fmo/red-de-sensores-para-monitorear-la-humedad-del-suelo-en	f
130	113	1	red-de-sensores-para-monitorear-la-humedad-del-suelo-en.pdf	App_Data/entregas/112/596fbf4f84154a0e8d1c2a59f1aa4bb0.pdf	f
131	113	2	red-de-sensores-para-monitorear-la-humedad-del-suelo-en-codigo.zip	App_Data/entregas/112/45dc5a83495a49329b36f18e6b967ad9.zip	f
132	113	3	Enlace: github.com	https://github.com/ues-fmo/red-de-sensores-para-monitorear-la-humedad-del-suelo-en	f
133	114	1	la-figura-de-la-mujer-en-la-narrativa-de-claudia-lars.pdf	App_Data/entregas/114/f837bb1381e448e2a8ed14f18ef20106.pdf	f
135	116	1	la-cortesia-verbal-en-ingles-y-en-frances.pdf	App_Data/entregas/116/d1c54d86711a492eb1bc60faeb1b612c.pdf	f
136	117	1	la-cortesia-verbal-en-ingles-y-en-frances.pdf	App_Data/entregas/116/d1c54d86711a492eb1bc60faeb1b612c.pdf	f
138	119	1	estudio-de-tiempos-en-la-linea-de-empaque-de-una-proces.pdf	App_Data/entregas/119/7665050ad52445ffae06a8d9053c2c51.pdf	f
140	121	1	comportamiento-del-consumidor-de-comercio-electronico-e.pdf	App_Data/entregas/121/9fa637dbcb67458a84402534893aa25b.pdf	f
142	123	1	cadenas-de-markov-aplicadas-al-rendimiento-estudiantil.pdf	App_Data/entregas/122/ecf7f01f01e043b8838442545e847cfb.pdf	t
143	124	1	revitalizacion-del-centro-historico-de-san-miguel.pdf	App_Data/entregas/124/a0ec9d01961446c39b8d50984555541a.pdf	f
144	125	1	revitalizacion-del-centro-historico-de-san-miguel.pdf	App_Data/entregas/124/a0ec9d01961446c39b8d50984555541a.pdf	t
145	126	1	sistema-de-costos-por-ordenes-de-produccion-para-una-ca.pdf	App_Data/entregas/126/b4fde29a4968476b9b50db9e3814e2e9.pdf	t
153	134	1	protocolo-de-monitoreo-en-anestesia-pediatrica.pdf	App_Data/entregas/134/5df60f040edc441aa01419fcf6414f19.pdf	t
156	137	1	frecuencia-de-grupos-sanguineos-en-donantes-del-banco-d.pdf	App_Data/entregas/136/a76846b560574342bfd50055faaaf62c.pdf	t
159	140	1	determinacion-de-metales-pesados-en-agua-del-rio-lempa.pdf	App_Data/entregas/139/ae9eb29d08e240ffbd5bff9881b27e7f.pdf	f
160	141	1	uso-racional-de-antibioticos-en-farmacias-de-san-miguel.pdf	App_Data/entregas/141/ba37fe5a2b1f4551b0ad527c1f8234c9.pdf	f
166	146	1	panel-de-indicadores-de-rendimiento-academico-con-cienc.pdf	App_Data/entregas/146/e320ce2ed83345ba9e6281636f27d5bc.pdf	t
167	146	3	Enlace: github.com	https://github.com/ues-fmo/panel-de-indicadores-de-rendimiento-academico-con-cienc	t
168	147	1	rasgos-del-habla-popular-en-el-oriente-de-el-salvador.pdf	App_Data/entregas/147/fc8094ff6f084b5480a2a6fd3fe259a7.pdf	t
169	148	1	habitos-de-lectura-en-estudiantes-universitarios.pdf	App_Data/entregas/148/7e35ff5cace24654902b1344c9695828.pdf	t
171	150	1	aplicacion-de-una-prueba-de-inteligencia-en-ninos-de-pr.pdf	App_Data/entregas/150/8b39cf3d523342cf9073d9c54b86a593.pdf	f
173	152	1	guia-didactica-de-optica-geometrica-con-materiales-reci.pdf	App_Data/entregas/152/4d65ae62c0024c159cc6ba2017664c5c.pdf	t
174	153	1	secuencia-de-clases-sobre-la-energia-y-sus-transformaci.pdf	App_Data/entregas/153/8689ca90fae143bda67839b34c07f772.pdf	f
176	155	1	oportunidades-del-tratado-de-libre-comercio-con-corea-p.pdf	App_Data/entregas/155/421b6d966e89448ca11e15a7d3a7ca67.pdf	f
177	156	1	plan-estrategico-para-una-cooperativa-de-ahorro-y-credi.pdf	App_Data/entregas/156/742a660d6521460fadf1fc72b48fc9b0.pdf	f
179	158	1	plan-de-negocios-para-una-empresa-de-alimentos-saludabl.pdf	App_Data/entregas/158/bb1cec96751143f6a2fc593ead9f3a65.pdf	t
126	112	1	red-de-sensores-para-monitorear-la-humedad-del-suelo-en.pdf	App_Data/entregas/112/596fbf4f84154a0e8d1c2a59f1aa4bb0.pdf	f
127	112	2	red-de-sensores-para-monitorear-la-humedad-del-suelo-en-codigo.zip	App_Data/entregas/112/45dc5a83495a49329b36f18e6b967ad9.zip	f
128	112	3	Enlace: github.com	https://github.com/ues-fmo/red-de-sensores-para-monitorear-la-humedad-del-suelo-en	f
134	115	1	plataformas-virtuales-en-el-aprendizaje-del-frances.pdf	App_Data/entregas/115/6ef8eb25616f4b9f89f627fdd946643d.pdf	t
137	118	1	uso-de-la-escala-de-glasgow-en-la-emergencia-de-un-hosp.pdf	App_Data/entregas/118/41b5f72c3ebc469f829d6789f7514bca.pdf	t
139	120	1	estudio-de-tiempos-en-la-linea-de-empaque-de-una-proces.pdf	App_Data/entregas/119/7665050ad52445ffae06a8d9053c2c51.pdf	f
141	122	1	cadenas-de-markov-aplicadas-al-rendimiento-estudiantil.pdf	App_Data/entregas/122/ecf7f01f01e043b8838442545e847cfb.pdf	f
146	127	1	estudio-de-caso-de-una-asociacion-de-mujeres-artesanas.pdf	App_Data/entregas/127/30a6b3cc5b1a47a3ad397eb177401230.pdf	t
147	128	1	diseno-estructural-de-una-vivienda-de-dos-niveles.pdf	App_Data/entregas/128/faf476432b8c41398d48b2f9e2c98cae.pdf	t
148	129	1	simulacion-termica-de-un-intercambiador-de-calor-de-tub.pdf	App_Data/entregas/129/5f650a2fe1074dc2a522eed80c757407.pdf	f
149	130	1	guia-de-practicas-de-biologia-para-centros-escolares-si.pdf	App_Data/entregas/130/3ff3755e746443a1b698300ea4a6f013.pdf	t
150	131	1	potencial-de-generacion-eolica-en-la-zona-costera-de-la.pdf	App_Data/entregas/131/ef7ea6dac78d4cd59933457ff3ad7ce7.pdf	f
151	132	1	diversidad-de-murcielagos-en-el-manglar-de-la-bahia-de.pdf	App_Data/entregas/132/8d7b951c4cc54b3aaff63a62b8c16d7b.pdf	f
152	133	1	composicion-de-la-flora-del-cerro-el-tigre-en-morazan.pdf	App_Data/entregas/133/763e1432185c43b0b4ce3ce86c580941.pdf	t
154	135	1	ansiedad-al-hablar-ingles-en-estudiantes-de-bachillerat.pdf	App_Data/entregas/135/1e54cfce2f394aefaeaddd4052954123.pdf	f
155	136	1	frecuencia-de-grupos-sanguineos-en-donantes-del-banco-d.pdf	App_Data/entregas/136/a76846b560574342bfd50055faaaf62c.pdf	f
157	138	1	programa-de-ejercicios-para-la-lumbalgia-en-trabajadore.pdf	App_Data/entregas/138/e538db1f0a2f43b3813641b90f86d0c9.pdf	f
158	139	1	determinacion-de-metales-pesados-en-agua-del-rio-lempa.pdf	App_Data/entregas/139/ae9eb29d08e240ffbd5bff9881b27e7f.pdf	f
161	142	1	uso-racional-de-antibioticos-en-farmacias-de-san-miguel.pdf	App_Data/entregas/141/ba37fe5a2b1f4551b0ad527c1f8234c9.pdf	t
162	143	1	control-de-calidad-de-tabletas-de-paracetamol-de-distin.pdf	App_Data/entregas/143/791e9a8d3b91482da1bd920459e41aa6.pdf	t
163	144	1	determinantes-del-empleo-informal-en-san-miguel.pdf	App_Data/entregas/144/a9f4241f33304cc894ffc6eee275adff.pdf	f
164	145	1	deteccion-de-enfermedades-en-hojas-de-cafe-con-redes-ne.pdf	App_Data/entregas/145/8aaf7688b1dd400798c562602d282608.pdf	f
165	145	2	deteccion-de-enfermedades-en-hojas-de-cafe-con-redes-ne-codigo.zip	App_Data/entregas/145/d1de06ce13aa4592a4f1fc2fa9b64cfd.zip	f
170	149	1	programa-de-intervencion-en-duelo-para-familias-de-migr.pdf	App_Data/entregas/149/41d792b638dd432c8b043703d70964d7.pdf	t
172	151	1	caso-clinico-de-apendicitis-aguda-durante-el-embarazo.pdf	App_Data/entregas/151/625960a32bd3427dac4ff0e0ce2624d1.pdf	f
175	154	1	quimica-en-la-cocina-practicas-para-tercer-ciclo.pdf	App_Data/entregas/154/63a50090b1274ceba7d79fd233c3afe6.pdf	f
178	157	1	plan-estrategico-para-una-cooperativa-de-ahorro-y-credi.pdf	App_Data/entregas/156/742a660d6521460fadf1fc72b48fc9b0.pdf	f
180	159	1	demostraciones-visuales-de-identidades-algebraicas.pdf	App_Data/entregas/159/38ec39955310468bb8d60e4804099175.pdf	f
181	160	1	demostraciones-visuales-de-identidades-algebraicas.pdf	App_Data/entregas/159/38ec39955310468bb8d60e4804099175.pdf	f
182	161	1	diseno-de-un-mercado-municipal-para-santa-rosa-de-lima.pdf	App_Data/entregas/161/934e1e45f27548bba676bbf6d9bff717.pdf	f
183	162	1	accesibilidad-universal-en-los-edificios-de-la-facultad.pdf	App_Data/entregas/162/57a2bdfc51684133a975967d63d51af1.pdf	f
184	163	1	migracion-irregular-de-jovenes-del-oriente-hacia-estado.pdf	App_Data/entregas/163/a6bee92178b343f689db343397f3722e.pdf	t
185	164	1	geogebra-en-la-ensenanza-de-funciones-en-bachillerato.pdf	App_Data/entregas/164/2ca7380daf0646f98da86e0cac95bab0.pdf	f
186	165	1	geogebra-en-la-ensenanza-de-funciones-en-bachillerato.pdf	App_Data/entregas/164/2ca7380daf0646f98da86e0cac95bab0.pdf	f
187	166	1	secuencia-didactica-de-ecuaciones-de-primer-grado.pdf	App_Data/entregas/166/552b9873d84a47bba5104e046356ca75.pdf	t
188	167	1	bloques-de-concreto-con-agregado-reciclado.pdf	App_Data/entregas/167/740cd4ec503b4e1899504806e0e888ea.pdf	t
189	168	1	el-juego-libre-en-el-desarrollo-social-de-ninos-de-cuat.pdf	App_Data/entregas/168/abb3e04fc9b440f6939a911fbadc09de.pdf	f
190	169	1	estimulacion-del-lenguaje-oral-mediante-cuentos.pdf	App_Data/entregas/169/082f03ee44914a4596903575721289ed.pdf	t
191	170	1	actividades-de-psicomotricidad-fina-para-la-primera-inf.pdf	App_Data/entregas/170/17302b8d3c31431f87cd24e8916a8c50.pdf	f
192	171	1	analisis-de-vibraciones-en-motores-electricos-de-la-ind.pdf	App_Data/entregas/171/9f3c799310f74c77925d25ecab9ededf.pdf	t
193	172	1	plan-de-mantenimiento-preventivo-para-el-parque-vehicul.pdf	App_Data/entregas/172/cf65b236237341b089b83134152bf909.pdf	f
194	173	1	plan-de-mantenimiento-preventivo-para-el-parque-vehicul.pdf	App_Data/entregas/172/cf65b236237341b089b83134152bf909.pdf	f
195	174	1	monitoreo-del-consumo-electrico-con-sensores-de-corrien.pdf	App_Data/entregas/174/07521676e47045d69496a1c7b4f7d524.pdf	f
196	174	2	monitoreo-del-consumo-electrico-con-sensores-de-corrien-codigo.zip	App_Data/entregas/174/1a1c10bdce3b478c8d6627c261bc298a.zip	f
197	174	3	Enlace: github.com	https://github.com/ues-fmo/monitoreo-del-consumo-electrico-con-sensores-de-corrien	f
198	175	3	Enlace: github.com	https://github.com/ues-fmo/monitoreo-del-consumo-electrico-con-sensores-de-corrien	t
206	180	1	lesiones-deportivas-frecuentes-en-jugadores-de-futbol-u.pdf	App_Data/entregas/179/ad72aa498433472f98b79a35e2536766.pdf	f
208	182	1	impacto-de-las-remesas-en-el-consumo-de-los-hogares-de.pdf	App_Data/entregas/182/887ab8eb922f42db842ad99f7a575316.pdf	f
209	183	1	efectos-de-la-adopcion-del-bitcoin-en-pequenos-comercio.pdf	App_Data/entregas/183/3b281a11484d4cf49d5bb31c122d711c.pdf	t
212	186	1	glosario-trilingue-de-terminos-agricolas.pdf	App_Data/entregas/186/6a1fcdc2944e44e1aa7dde263d9b7ddf.pdf	f
199	175	1	monitoreo-del-consumo-electrico-con-sensores-de-corrien.pdf	App_Data/entregas/174/07521676e47045d69496a1c7b4f7d524.pdf	t
200	175	2	monitoreo-del-consumo-electrico-con-sensores-de-corrien-codigo.zip	App_Data/entregas/174/1a1c10bdce3b478c8d6627c261bc298a.zip	t
201	175	3	Enlace: github.com	https://github.com/ues-fmo/monitoreo-del-consumo-electrico-con-sensores-de-corrien	t
202	176	1	prevalencia-de-parasitosis-intestinal-en-ninos-de-escue.pdf	App_Data/entregas/176/8d0634d11cee474690b5ca8d5e0c44fc.pdf	t
203	177	1	deteccion-de-infeccion-de-vias-urinarias-en-mujeres-emb.pdf	App_Data/entregas/177/1d9dc3e530274b6bb3a8d479ac36a4ec.pdf	t
204	178	1	resistencia-antimicrobiana-de-escherichia-coli-en-muest.pdf	App_Data/entregas/178/0575adc493d84193adeb0862686fd76e.pdf	t
205	179	1	lesiones-deportivas-frecuentes-en-jugadores-de-futbol-u.pdf	App_Data/entregas/179/ad72aa498433472f98b79a35e2536766.pdf	f
207	181	1	adaptaciones-del-hogar-para-adultos-mayores-con-movilid.pdf	App_Data/entregas/181/b64c5d28aa81444e895822cd8d9bd08c.pdf	t
210	184	1	balanza-comercial-de-el-salvador-con-centroamerica.pdf	App_Data/entregas/184/6ef54fbbef564bde9b968003a5549b41.pdf	t
211	185	1	antologia-comentada-de-cuentos-de-salarrue.pdf	App_Data/entregas/185/09da5cede7414ed4b6c0f2b658ad1e4b.pdf	t
213	187	1	glosario-trilingue-de-terminos-agricolas.pdf	App_Data/entregas/186/6a1fcdc2944e44e1aa7dde263d9b7ddf.pdf	f
215	189	1	memoria-historica-del-conflicto-armado-contada-por-habi.pdf	App_Data/entregas/188/800144cd5fba4c4a880542a82ac3fdb2.pdf	f
216	190	1	mapas-digitales-para-ensenar-la-geografia-de-el-salvado.pdf	App_Data/entregas/190/f696acb9cd9142168c2ff19f01d551eb.pdf	t
219	193	1	adherencia-al-tratamiento-en-pacientes-con-enfermedad-r.pdf	App_Data/entregas/193/6671fb0031334ca2ad47fe732a02a8ae.pdf	t
220	194	1	concepciones-erroneas-sobre-la-gravedad-en-estudiantes.pdf	App_Data/entregas/194/cfee0c0fa45e40d78c11477eeccdaed9.pdf	t
221	195	1	reduccion-de-desperdicios-en-una-panaderia-con-manufact.pdf	App_Data/entregas/195/636cf3bd15e54d1cbe8aeef25750675e.pdf	f
222	196	1	pronostico-de-la-demanda-para-una-distribuidora-de-prod.pdf	App_Data/entregas/196/5867da7c49904defb40112a8060f4812.pdf	f
224	198	1	plan-de-exportacion-de-cafe-de-especialidad-de-morazan.pdf	App_Data/entregas/198/6cfe82c519ca45d386f16635f47cf443.pdf	f
225	199	1	estrategia-de-marca-para-las-artesanias-de-barro-de-gua.pdf	App_Data/entregas/199/9473849f8c214f7d823aed22e336376d.pdf	t
229	203	1	analisis-estadistico-de-la-lluvia-en-la-zona-oriental-d.pdf	App_Data/entregas/203/a195b34955ee4adebf606db4ffb09fff.pdf	t
230	204	1	cumplimiento-de-obligaciones-tributarias-de-los-pequeno.pdf	App_Data/entregas/204/5610531a90d0493e851a914cefe04acd.pdf	t
233	207	1	mapa-de-actores-sociales-de-un-municipio-de-morazan.pdf	App_Data/entregas/206/6a9dfd94a8a848fcaef5f44560d270d2.pdf	t
237	211	1	abono-organico-elaborado-con-residuos-de-la-cosecha-de.pdf	App_Data/entregas/211/570418e3bd8d4db49d8e8199086dc33d.pdf	t
238	212	1	fertilidad-de-los-suelos-de-las-parcelas-de-la-estacion.pdf	App_Data/entregas/212/1500428af01547a8a59d4b60b0be5bb9.pdf	f
239	213	1	fertilidad-de-los-suelos-de-las-parcelas-de-la-estacion.pdf	App_Data/entregas/212/1500428af01547a8a59d4b60b0be5bb9.pdf	f
240	214	1	medicion-de-la-radiacion-solar-en-san-miguel-con-instru.pdf	App_Data/entregas/214/ae629a9265ec492e9f4f034d41db9ae8.pdf	t
242	216	1	eficiencia-energetica-de-calderas-en-beneficios-de-cafe.pdf	App_Data/entregas/216/57d53511340c4b69a86921ca1f26b486.pdf	f
243	217	1	inventario-de-aves-del-campus-de-la-facultad-multidisci.pdf	App_Data/entregas/217/059484f7f973490ba3cd6e3462b541c9.pdf	f
244	218	1	identificacion-de-hongos-comestibles-silvestres-del-ori.pdf	App_Data/entregas/218/e06b48a531894058b26945ae30c7fa83.pdf	f
245	219	1	analisis-de-la-sentencia-de-inconstitucionalidad-de-la.pdf	App_Data/entregas/219/66bc439f109a44e58904cd34045613e9.pdf	f
248	222	1	valoracion-preanestesica-en-pacientes-hipertensos.pdf	App_Data/entregas/222/540a43fc847544eda609fb98ea11b77b.pdf	f
253	227	1	titulacion-potenciometrica-de-la-acidez-del-vinagre-com.pdf	App_Data/entregas/227/3cea74b8792e4b9aaf3d497d9f6a6e2c.pdf	f
254	228	1	estabilidad-de-una-suspension-de-amoxicilina-reconstitu.pdf	App_Data/entregas/228/67db85c267e54fad9f46ca4a2fbc147a.pdf	f
255	229	1	linea-de-tiempo-interactiva-de-la-historia-politica-sal.pdf	App_Data/entregas/229/5146338ca8aa441daa543afe85234821.pdf	f
256	230	1	efectos-del-uso-de-redes-sociales-en-la-autoestima-de-a.pdf	App_Data/entregas/230/a932b927306544f89eb3482ec641b39f.pdf	f
214	188	1	memoria-historica-del-conflicto-armado-contada-por-habi.pdf	App_Data/entregas/188/800144cd5fba4c4a880542a82ac3fdb2.pdf	f
217	191	1	niveles-de-estres-academico-en-estudiantes-de-la-facult.pdf	App_Data/entregas/191/9bb3bbcd074543cd973c7463c69eb79d.pdf	t
218	192	1	complicaciones-del-dengue-en-ninos-atendidos-en-el-hosp.pdf	App_Data/entregas/192/77c62b0ed9434b51b0314685dc963fc6.pdf	f
223	197	1	control-estadistico-de-calidad-en-el-llenado-de-botella.pdf	App_Data/entregas/197/c5ad22f169eb4660b268d50d2ed75744.pdf	f
226	200	1	investigacion-de-mercado-para-una-cafeteria-universitar.pdf	App_Data/entregas/200/21161311c2364dd183419740fb71817f.pdf	f
227	201	1	investigacion-de-mercado-para-una-cafeteria-universitar.pdf	App_Data/entregas/200/21161311c2364dd183419740fb71817f.pdf	t
228	202	1	campana-de-mercadeo-digital-para-una-cooperativa-de-pro.pdf	App_Data/entregas/202/0d1b85d410b047e28e57a00e13176d89.pdf	t
231	205	1	cambios-en-la-vida-rural-a-partir-de-las-remesas.pdf	App_Data/entregas/205/bbcf90e401284ad583eb2a01e362f5c3.pdf	f
232	206	1	mapa-de-actores-sociales-de-un-municipio-de-morazan.pdf	App_Data/entregas/206/6a9dfd94a8a848fcaef5f44560d270d2.pdf	f
234	208	1	juegos-matematicos-para-el-calculo-mental.pdf	App_Data/entregas/208/8d85518579b04251a3f39a6fa8cd8e6f.pdf	f
235	209	1	participacion-de-las-familias-en-la-educacion-parvulari.pdf	App_Data/entregas/209/793eca3e4bbe4ee2a02885b5b6d046fc.pdf	f
236	210	1	riego-por-goteo-en-el-cultivo-de-chile-dulce.pdf	App_Data/entregas/210/d1dd94c92913422fa652c7a8a5c09e8b.pdf	t
241	215	1	actividad-sismica-de-la-cadena-volcanica-del-oriente.pdf	App_Data/entregas/215/66d12e24296649829f6f947ba3476d8d.pdf	f
246	220	1	incidencia-de-nauseas-y-vomitos-postoperatorios-en-ciru.pdf	App_Data/entregas/220/2337e2b5f0e547cb93c13dae1c1abc25.pdf	f
247	221	1	incidencia-de-nauseas-y-vomitos-postoperatorios-en-ciru.pdf	App_Data/entregas/220/2337e2b5f0e547cb93c13dae1c1abc25.pdf	t
249	223	1	valoracion-preanestesica-en-pacientes-hipertensos.pdf	App_Data/entregas/222/540a43fc847544eda609fb98ea11b77b.pdf	f
250	224	1	aprendizaje-de-vocabulario-en-ingles-mediante-aplicacio.pdf	App_Data/entregas/224/0dd4e0c7bb214a98a7361367ac61d358.pdf	f
251	225	1	correccion-de-errores-escritos-frecuentes-en-noveno-gra.pdf	App_Data/entregas/225/fa356132296e414fa49ad81cea62e54a.pdf	f
252	226	1	valores-de-referencia-del-hemograma-en-adultos-de-san-m.pdf	App_Data/entregas/226/780e3e2782244e3696beb23f143c8a95.pdf	f
257	231	1	clima-laboral-en-una-empresa-de-servicios-de-la-zona-or.pdf	App_Data/entregas/231/effeba5b8167499d9c202282da0fadc9.pdf	t
258	232	1	prevalencia-de-hipertension-arterial-en-trabajadores-de.pdf	App_Data/entregas/232/7d0b8f1ceedc42d48f03eac7dac5c26d.pdf	f
259	233	1	prevalencia-de-hipertension-arterial-en-trabajadores-de.pdf	App_Data/entregas/232/7d0b8f1ceedc42d48f03eac7dac5c26d.pdf	f
260	234	1	simuladores-phet-en-la-ensenanza-de-la-electricidad.pdf	App_Data/entregas/234/966cd7f436bd4518978e3776d5896c69.pdf	f
261	235	1	distribucion-en-planta-de-una-fabrica-de-muebles.pdf	App_Data/entregas/235/1e6651386a244d95b97d7378e0ec465c.pdf	f
262	236	1	factores-de-exito-de-los-emprendimientos-de-mujeres-en.pdf	App_Data/entregas/236/6b612912ecae4659bf218255960c477c.pdf	f
263	237	1	factores-de-exito-de-los-emprendimientos-de-mujeres-en.pdf	App_Data/entregas/236/6b612912ecae4659bf218255960c477c.pdf	t
264	238	1	satisfaccion-del-cliente-en-supermercados-de-la-ciudad.pdf	App_Data/entregas/238/d7e1cf9b739f4e2cbd9f715cb930d80b.pdf	f
265	239	1	teoria-de-grafos-aplicada-a-las-rutas-de-transporte-de.pdf	App_Data/entregas/239/50bec0273ec344a28a5bafcff82d9665.pdf	f
266	240	1	vivienda-social-bioclimatica-para-el-oriente-del-pais.pdf	App_Data/entregas/240/7f1d4c524ecb4445b0ebb3c760c93b9e.pdf	f
267	241	1	aplicacion-de-las-niif-para-pymes-en-empresas-comercial.pdf	App_Data/entregas/241/219e9c91d59244d4a68b11b5dc42ac07.pdf	f
268	242	1	uso-de-la-factura-electronica-en-los-negocios-de-san-mi.pdf	App_Data/entregas/242/f8a441f9b16b4cacbcbbcaacba0929cb.pdf	f
269	243	1	uso-de-la-factura-electronica-en-los-negocios-de-san-mi.pdf	App_Data/entregas/242/f8a441f9b16b4cacbcbbcaacba0929cb.pdf	f
270	244	1	organizacion-comunitaria-en-asentamientos-de-san-miguel.pdf	App_Data/entregas/244/73dbe124f514418191cb10615030ae30.pdf	f
271	245	1	organizacion-comunitaria-en-asentamientos-de-san-miguel.pdf	App_Data/entregas/244/73dbe124f514418191cb10615030ae30.pdf	t
272	246	1	vulnerabilidad-sismica-de-escuelas-construidas-con-adob.pdf	App_Data/entregas/246/6bbc98d7d2b7421a89c5eee36cb11617.pdf	t
273	247	1	optimizacion-de-rutas-de-distribucion-para-una-embotell.pdf	App_Data/entregas/247/c2e199b232d8455bac4dab183a07eaa4.pdf	f
274	248	1	gestion-de-almacenes-en-un-centro-de-distribucion-de-al.pdf	App_Data/entregas/248/0b48fac9517a4c149975b2691f61dcac.pdf	f
275	249	1	el-puerto-de-la-union-como-plataforma-logistica-regiona.pdf	App_Data/entregas/249/fb66bd9bd6e848f68a3753ce371761f7.pdf	f
276	250	1	el-puerto-de-la-union-como-plataforma-logistica-regiona.pdf	App_Data/entregas/249/fb66bd9bd6e848f68a3753ce371761f7.pdf	t
277	251	1	canciones-infantiles-para-ensenar-habitos-de-higiene.pdf	App_Data/entregas/251/054f376d6eb54b3b8cfe70d44acbf419.pdf	t
278	252	1	propiedades-opticas-de-peliculas-delgadas.pdf	App_Data/entregas/252/852d43aec793472d8314e33caafe708c.pdf	t
279	253	1	movimiento-amortiguado-de-un-sistema-masa-resorte.pdf	App_Data/entregas/253/bec3f682299245b79f506fdfa9f622d9.pdf	t
280	254	1	movimiento-amortiguado-de-un-sistema-masa-resorte-v2.pdf	App_Data/entregas/254/3674224d934e4235bdb4a934dd88383c.pdf	f
281	255	1	indice-de-precios-de-los-mercados-municipales-de-san-mi.pdf	App_Data/entregas/255/9fc816ea273a4b6196c7952be64801c2.pdf	t
282	256	1	implementacion-de-las-5s-en-una-imprenta.pdf	App_Data/entregas/256/d43f83401b794495aad48939061ea158.pdf	t
283	257	1	diseno-de-una-bomba-de-ariete-para-riego-comunitario.pdf	App_Data/entregas/257/b344167951624c118656d48cdf293db6.pdf	f
284	258	1	prototipo-de-iluminacion-publica-con-paneles-solares-y.pdf	App_Data/entregas/258/ab2e3ceb3c12490db640a06649f9039c.pdf	t
285	258	2	prototipo-de-iluminacion-publica-con-paneles-solares-y-codigo.zip	App_Data/entregas/258/1e82a9ab103044228a1fdb6181a34e12.zip	t
286	258	3	Enlace: github.com	https://github.com/ues-fmo/prototipo-de-iluminacion-publica-con-paneles-solares-y	t
287	259	1	la-violencia-intrafamiliar-en-los-procesos-de-familia-d.pdf	App_Data/entregas/259/5faaec5ff6b74a2db83242046aa9c537.pdf	f
288	260	1	manual-de-toma-y-transporte-de-muestras-clinicas.pdf	App_Data/entregas/260/75cc415c90244afc88e8951522c2e7a9.pdf	t
289	261	1	actividad-antioxidante-del-extracto-de-flor-de-jamaica.pdf	App_Data/entregas/261/31b53af33aaf47fda0e6b7f85bea9e62.pdf	t
290	262	1	juego-de-roles-sobre-los-derechos-humanos-en-tercer-cic.pdf	App_Data/entregas/262/35cf3ca78b7e428281492abb2b4b4880.pdf	f
291	263	1	juego-de-roles-sobre-los-derechos-humanos-en-tercer-cic.pdf	App_Data/entregas/262/35cf3ca78b7e428281492abb2b4b4880.pdf	f
292	264	1	plan-de-mercadeo-para-una-tienda-en-linea-de-artesanias.pdf	App_Data/entregas/264/1de8b2d4102d4790939a3fd3237adfdd.pdf	f
293	265	1	patologias-en-edificaciones-de-concreto-de-la-zona-orie.pdf	App_Data/entregas/265/643fd07681954ff9b9f5146411895336.pdf	f
294	266	1	manejo-integrado-de-plagas-en-el-cultivo-de-maiz.pdf	App_Data/entregas/266/1cc9a73566274d51936f1496c0c068a7.pdf	f
295	267	1	diseno-de-un-aerogenerador-de-eje-vertical-para-zonas-r.pdf	App_Data/entregas/267/1b93066461ec44879535e0b382cd373c.pdf	f
296	268	1	anfibios-como-indicadores-de-la-salud-de-los-bosques-de.pdf	App_Data/entregas/268/67d0505532fc4ddfa190caa28597db04.pdf	f
297	269	1	anfibios-como-indicadores-de-la-salud-de-los-bosques-de.pdf	App_Data/entregas/268/67d0505532fc4ddfa190caa28597db04.pdf	t
298	270	1	hipotermia-postoperatoria-en-pacientes-de-cirugia-mayor.pdf	App_Data/entregas/270/17e73abae70c4a7bb67836cbaad6bc5d.pdf	f
299	271	1	lista-de-verificacion-de-seguridad-del-equipo-de-aneste.pdf	App_Data/entregas/271/c23b684b75784901816f6ecdb1c59fbd.pdf	t
300	272	1	contenido-de-nitratos-en-agua-de-pozos-de-la-zona-orien.pdf	App_Data/entregas/272/b240bf7050a54135844c6c18bb9619a8.pdf	f
301	273	1	contenido-de-nitratos-en-agua-de-pozos-de-la-zona-orien.pdf	App_Data/entregas/272/b240bf7050a54135844c6c18bb9619a8.pdf	f
302	274	1	plataforma-web-para-la-gestion-de-practicas-profesional.pdf	App_Data/entregas/274/6be9707f519e44389cc9b8dad2e9f8fb.pdf	t
303	274	3	Enlace: github.com	https://github.com/ues-fmo/plataforma-web-para-la-gestion-de-practicas-profesional	t
304	275	1	diseno-de-una-base-de-datos-para-un-consultorio-odontol.pdf	App_Data/entregas/275/09093d4dad004b00804a5e96564999cd.pdf	f
305	275	2	diseno-de-una-base-de-datos-para-un-consultorio-odontol-codigo.zip	App_Data/entregas/275/0dfd1906967345638d91443706e80c60.zip	f
306	275	3	Enlace: github.com	https://github.com/ues-fmo/diseno-de-una-base-de-datos-para-un-consultorio-odontol	f
307	276	1	la-oralidad-y-las-leyendas-del-oriente-salvadoreno.pdf	App_Data/entregas/276/3df91a5329d84e8cacc2ce435bc4384d.pdf	f
308	277	1	errores-frecuentes-en-la-traduccion-de-textos-tecnicos.pdf	App_Data/entregas/277/0efd5490ad3a48d9b7de84d90c9b8253.pdf	f
309	278	1	errores-frecuentes-en-la-traduccion-de-textos-tecnicos.pdf	App_Data/entregas/277/0efd5490ad3a48d9b7de84d90c9b8253.pdf	t
310	279	1	la-motivacion-en-el-aprendizaje-del-frances-como-tercer.pdf	App_Data/entregas/279/807a9a2236fc464394f94dbe42870831.pdf	f
311	280	1	control-prenatal-y-complicaciones-del-embarazo-en-zonas.pdf	App_Data/entregas/280/9bf6ecca4eff43378b277fccbc6ef715.pdf	f
312	281	1	control-prenatal-y-complicaciones-del-embarazo-en-zonas.pdf	App_Data/entregas/280/9bf6ecca4eff43378b277fccbc6ef715.pdf	t
313	282	1	laboratorio-virtual-de-ondas-para-estudiantes-de-bachil.pdf	App_Data/entregas/282/f56c7efd717845c6be92bbe859c4655d.pdf	f
314	283	1	liderazgo-y-desempeno-laboral-en-una-institucion-public.pdf	App_Data/entregas/283/ba156c7d0fa4425480bd5315bb383b08.pdf	f
315	284	1	liderazgo-y-desempeno-laboral-en-una-institucion-public.pdf	App_Data/entregas/283/ba156c7d0fa4425480bd5315bb383b08.pdf	t
316	285	1	efecto-del-biochar-en-la-fertilidad-del-suelo.pdf	App_Data/entregas/285/f54e681d743e4a85964978f88eef3183.pdf	t
317	286	1	el-turismo-como-motor-del-desarrollo-economico-de-la-ru.pdf	App_Data/entregas/286/1e8c9407f0e64ad28464b175cab22ccb.pdf	t
318	287	1	resiliencia-en-jovenes-afectados-por-la-violencia.pdf	App_Data/entregas/287/5680380241424fb1bd277ec4512d0a76.pdf	f
319	288	1	construccion-de-un-circuito-electrico-didactico.pdf	App_Data/entregas/288/98e2177681bc46f2bc10caf807e7548d.pdf	f
320	289	1	gestion-financiera-de-las-pequenas-empresas-familiares.pdf	App_Data/entregas/289/7f7eaf7a79a74690bd5c1b930eb0ac91.pdf	f
321	290	1	programacion-lineal-aplicada-a-la-planificacion-de-cose.pdf	App_Data/entregas/290/5a490fd6216148d7a648bae60f774058.pdf	t
322	291	1	errores-en-el-aprendizaje-del-algebra-en-septimo-grado.pdf	App_Data/entregas/291/75b642eb36bd4ff6a4b55f30e0b2869b.pdf	f
323	292	1	errores-en-el-aprendizaje-del-algebra-en-septimo-grado.pdf	App_Data/entregas/291/75b642eb36bd4ff6a4b55f30e0b2869b.pdf	f
324	293	1	logistica-inversa-de-envases-en-una-distribuidora-de-be.pdf	App_Data/entregas/293/0f04b536bfa946e08150b1fbcf10aa09.pdf	f
325	294	1	logistica-inversa-de-envases-en-una-distribuidora-de-be.pdf	App_Data/entregas/293/0f04b536bfa946e08150b1fbcf10aa09.pdf	t
326	295	1	caracterizacion-de-paneles-solares-en-condiciones-del-o.pdf	App_Data/entregas/295/682cdb0b91334415b5efa81c91eb8c9e.pdf	t
327	296	1	medicion-de-la-velocidad-del-sonido-con-un-tubo-de-reso.pdf	App_Data/entregas/296/f92400a457694e47afaa9b8fc3f3ca87.pdf	f
328	297	1	medicion-de-la-velocidad-del-sonido-con-un-tubo-de-reso.pdf	App_Data/entregas/296/f92400a457694e47afaa9b8fc3f3ca87.pdf	t
329	298	1	germinacion-de-semillas-de-arboles-nativos-para-refores.pdf	App_Data/entregas/298/06e6463331284c52a4c93fe0e17a4191.pdf	f
330	299	1	aprendizaje-cooperativo-en-las-clases-de-ingles-de-bach.pdf	App_Data/entregas/299/a2a3281cc9794f9f9ccb6fc35f1c1312.pdf	f
331	300	1	anemia-ferropenica-en-mujeres-en-edad-fertil-de-comunid.pdf	App_Data/entregas/300/c2bc94d0f4674d438760293f0179dd57.pdf	f
332	301	1	hidroterapia-en-ninos-con-paralisis-cerebral.pdf	App_Data/entregas/301/213efeca0c174cb6b862fc5831bfd78c.pdf	f
333	302	1	hidroterapia-en-ninos-con-paralisis-cerebral.pdf	App_Data/entregas/301/213efeca0c174cb6b862fc5831bfd78c.pdf	f
334	303	1	acceso-al-credito-de-la-micro-y-pequena-empresa-en-san.pdf	App_Data/entregas/303/86a222bd22c741929c50c1a708a2f5d0.pdf	t
335	304	1	interpretacion-simultanea-en-un-congreso-academico-simu.pdf	App_Data/entregas/304/8f5b2b6af6434a4ea8ecc7d05a395e3c.pdf	t
336	305	1	percepcion-de-los-jovenes-sobre-la-democracia.pdf	App_Data/entregas/305/da427b29ac344453b36f27797544abf3.pdf	f
337	306	1	percepcion-de-los-jovenes-sobre-la-democracia.pdf	App_Data/entregas/305/da427b29ac344453b36f27797544abf3.pdf	f
338	307	1	simulacion-de-un-sistema-de-colas-en-una-agencia-bancar.pdf	App_Data/entregas/307/78c379f52fcb4a49864930e6f585bd3e.pdf	f
339	308	1	impacto-de-la-reforma-fiscal-en-las-pequenas-empresas.pdf	App_Data/entregas/308/b23e919351584899870cb519b737a253.pdf	t
340	309	1	juventud-rural-y-oportunidades-de-empleo-en-el-oriente.pdf	App_Data/entregas/309/b8477f4b643a47f68875e3c1af07c5ba.pdf	t
341	310	1	estadistica-con-datos-reales-en-el-aula-de-bachillerato.pdf	App_Data/entregas/310/a1b99f9ed5a04823acbfe683ae78a1fd.pdf	f
342	311	1	plan-de-transporte-para-una-empresa-exportadora-de-frut.pdf	App_Data/entregas/311/db2992ab5db5430f94110688f36d1215.pdf	f
343	312	1	huerto-escolar-para-ninos-de-cinco-anos.pdf	App_Data/entregas/312/e23c8678195e4346a6087f3d11482527.pdf	t
344	313	1	salidas-de-campo-como-estrategia-para-ensenar-ecosistem.pdf	App_Data/entregas/313/f26f85cd9b9c4884aea65562534e6f4c.pdf	t
345	314	1	herbario-escolar-con-plantas-de-la-zona-oriental.pdf	App_Data/entregas/314/83c332e5fdc043da82dca330486f381e.pdf	t
346	315	1	polinizadores-en-cultivos-de-cafe-de-la-zona-oriental.pdf	App_Data/entregas/315/4b3e28e6ba7c4cd6b8860dce54611295.pdf	f
347	316	1	polinizadores-en-cultivos-de-cafe-de-la-zona-oriental.pdf	App_Data/entregas/315/4b3e28e6ba7c4cd6b8860dce54611295.pdf	t
348	317	1	el-teletrabajo-en-la-legislacion-laboral-salvadorena.pdf	App_Data/entregas/317/7d838da7501f4110a0fa61b3b3e5e432.pdf	t
349	318	1	el-debido-proceso-en-el-procedimiento-administrativo-sa.pdf	App_Data/entregas/318/be6339c97d444893928b8edc7f4ea9bd.pdf	t
350	319	1	dolor-postoperatorio-en-pacientes-con-bloqueo-de-plexo.pdf	App_Data/entregas/319/5084c07b094b483c93a8f194294bae0e.pdf	f
351	320	1	dolor-postoperatorio-en-pacientes-con-bloqueo-de-plexo.pdf	App_Data/entregas/319/5084c07b094b483c93a8f194294bae0e.pdf	f
352	321	1	comprension-auditiva-del-ingles-con-podcast-en-noveno-g.pdf	App_Data/entregas/321/6b0253465ed244e496afa82f076c7661.pdf	t
353	322	1	guia-de-actividades-de-lectura-en-ingles-para-tercer-ci.pdf	App_Data/entregas/322/21d0120437874677ae016345dea10ea2.pdf	f
354	323	1	perfil-lipidico-en-estudiantes-universitarios-de-la-fac.pdf	App_Data/entregas/323/6b4f39077dd1481c9eccdd612491fd80.pdf	t
355	324	1	pausas-activas-para-el-personal-administrativo-de-la-fa.pdf	App_Data/entregas/324/f300fdef63444078b6c782d3b6555b08.pdf	f
356	325	1	pausas-activas-para-el-personal-administrativo-de-la-fa.pdf	App_Data/entregas/324/f300fdef63444078b6c782d3b6555b08.pdf	t
357	326	1	automedicacion-en-estudiantes-universitarios-de-san-mig.pdf	App_Data/entregas/326/60983dc842524c2083dbf8e641a6757d.pdf	t
358	327	1	sistema-de-control-de-asistencia-con-reconocimiento-fac.pdf	App_Data/entregas/327/e47f41075fe844ffad7b7490a23d6538.pdf	t
359	327	2	sistema-de-control-de-asistencia-con-reconocimiento-fac-codigo.zip	App_Data/entregas/327/a948595b08aa4528b31a64bb492d5350.zip	t
360	327	3	Enlace: github.com	https://github.com/ues-fmo/sistema-de-control-de-asistencia-con-reconocimiento-fac	t
361	328	1	abordaje-de-la-neumonia-adquirida-en-la-comunidad-en-ni.pdf	App_Data/entregas/328/b9af5113d40c4f2d8e7008932784b783.pdf	f
362	329	1	abordaje-de-la-neumonia-adquirida-en-la-comunidad-en-ni.pdf	App_Data/entregas/328/b9af5113d40c4f2d8e7008932784b783.pdf	f
363	330	1	posicionamiento-de-la-marca-de-un-cafe-de-altura-de-mor.pdf	App_Data/entregas/330/a55a1061c04c4722b7343bffe34e190a.pdf	t
364	331	1	diseno-organizacional-de-una-cooperativa-de-transporte.pdf	App_Data/entregas/331/d35c3ba7c7c24967b803dba0db9ebf9f.pdf	t
365	332	1	diseno-de-un-albergue-temporal-para-emergencias.pdf	App_Data/entregas/332/88509ae666704313a66e89e0463b4599.pdf	t
366	333	1	elaboracion-de-estados-financieros-para-una-tienda-de-a.pdf	App_Data/entregas/333/0743ffc12dc94bb7905f34bd4d136071.pdf	f
367	334	1	las-redes-de-apoyo-de-las-madres-solteras-en-san-miguel.pdf	App_Data/entregas/334/09cef204572d4c2ab56dc8a5e78fa02d.pdf	f
368	335	1	las-redes-de-apoyo-de-las-madres-solteras-en-san-miguel.pdf	App_Data/entregas/334/09cef204572d4c2ab56dc8a5e78fa02d.pdf	t
369	336	1	diagnostico-participativo-de-una-comunidad-del-bajo-lem.pdf	App_Data/entregas/336/60d0b53919444221ad197fbae98dc76c.pdf	t
370	337	1	taller-de-geometria-con-origami.pdf	App_Data/entregas/337/2657b94efc24441fbf910014d0fdc359.pdf	f
371	338	1	diseno-de-una-mezcla-de-concreto-con-ceniza-volcanica.pdf	App_Data/entregas/338/efbb724232d64b52a301f88def313536.pdf	t
372	339	1	uso-del-microscopio-en-la-ensenanza-de-la-biologia-en-c.pdf	App_Data/entregas/339/1ebd4192d3ab42428ce113612b23060c.pdf	t
373	340	1	diseno-de-la-instalacion-electrica-de-un-centro-de-salu.pdf	App_Data/entregas/340/5b14fc41275640268252332eaff521b1.pdf	f
374	341	1	rehabilitacion-de-la-rodilla-tras-lesiones-de-ligamento.pdf	App_Data/entregas/341/b77d9f0dc639472884f31576ec927f3d.pdf	f
375	342	1	rehabilitacion-de-la-rodilla-tras-lesiones-de-ligamento.pdf	App_Data/entregas/341/b77d9f0dc639472884f31576ec927f3d.pdf	f
376	343	1	obtencion-de-jabon-artesanal-a-partir-de-aceites-vegeta.pdf	App_Data/entregas/343/27f1936e97e74a838ef305d64eaf1d5f.pdf	f
377	344	1	obtencion-de-jabon-artesanal-a-partir-de-aceites-vegeta.pdf	App_Data/entregas/343/27f1936e97e74a838ef305d64eaf1d5f.pdf	t
378	345	1	formulacion-de-una-crema-hidratante-con-aceite-de-coco.pdf	App_Data/entregas/345/d01e604f723c4e0ebfb6b9d5706b2160.pdf	f
379	346	1	el-lenguaje-juvenil-en-las-redes-sociales.pdf	App_Data/entregas/346/7c78d02a827f4326a082793c2dd495bb.pdf	t
380	347	1	taller-de-habilidades-sociales-para-ninos-de-primaria.pdf	App_Data/entregas/347/b4b97daa517c46b8bc672713fc5196ca.pdf	f
381	348	1	infecciones-asociadas-a-la-atencion-en-salud-en-un-hosp.pdf	App_Data/entregas/348/fa85101ad01d480aba1cfc20fad212c1.pdf	f
382	349	1	aprendizaje-de-la-fisica-a-traves-de-la-resolucion-de-p.pdf	App_Data/entregas/349/9a0efbe32ff14b82b0abfebebbb8be74.pdf	f
383	350	1	la-quimica-del-agua-potable-practicas-para-educacion-me.pdf	App_Data/entregas/350/695345d1e9674124a7778359edb65bc8.pdf	t
384	351	1	balanceo-de-linea-en-una-maquila-textil.pdf	App_Data/entregas/351/5b0b5be8ec324463a4afe2270e12d482.pdf	f
385	352	1	exportacion-de-maranon-procesado-a-europa.pdf	App_Data/entregas/352/73fe4565ea36473788239499ac359180.pdf	f
386	353	1	modelos-de-regresion-para-el-rendimiento-del-maiz.pdf	App_Data/entregas/353/12a742187d6c4f02b7c331a35ed27d88.pdf	t
387	354	1	confort-termico-en-las-aulas-de-la-facultad.pdf	App_Data/entregas/354/1ae3758ae28344d6a3038046f604500a.pdf	f
388	355	1	confort-termico-en-las-aulas-de-la-facultad.pdf	App_Data/entregas/354/1ae3758ae28344d6a3038046f604500a.pdf	t
389	356	1	propuesta-de-mobiliario-urbano-para-el-parque-central.pdf	App_Data/entregas/356/53d11f6d1db944329099d2e781b4fe69.pdf	t
390	357	1	diseno-de-un-sistema-de-drenaje-pluvial-para-una-coloni.pdf	App_Data/entregas/357/d92f3223792c4b9c81e0d386dba06f51.pdf	f
391	358	1	diseno-de-un-sistema-de-drenaje-pluvial-para-una-coloni.pdf	App_Data/entregas/357/d92f3223792c4b9c81e0d386dba06f51.pdf	f
392	359	1	tiempos-de-despacho-en-la-aduana-terrestre-de-el-amatil.pdf	App_Data/entregas/359/b2e2bd94d10541519b579ee13a729f17.pdf	f
393	360	1	tiempos-de-despacho-en-la-aduana-terrestre-de-el-amatil.pdf	App_Data/entregas/359/b2e2bd94d10541519b579ee13a729f17.pdf	f
394	361	1	inclusion-de-ninos-con-discapacidad-en-la-educacion-par.pdf	App_Data/entregas/361/f6e76db35c6b486c8358bbede9571764.pdf	f
395	362	1	produccion-de-hongos-comestibles-con-residuos-agricolas.pdf	App_Data/entregas/362/efe1c5a760454e2184908555601ae678.pdf	f
396	363	1	produccion-de-hongos-comestibles-con-residuos-agricolas.pdf	App_Data/entregas/362/efe1c5a760454e2184908555601ae678.pdf	f
397	364	1	analisis-de-fallas-en-ejes-de-transmision-de-maquinaria.pdf	App_Data/entregas/364/1aed80da995946ab8d233f6a87bc4353.pdf	f
398	365	1	analisis-de-fallas-en-ejes-de-transmision-de-maquinaria.pdf	App_Data/entregas/364/1aed80da995946ab8d233f6a87bc4353.pdf	f
399	366	1	perdidas-tecnicas-en-la-red-de-distribucion-de-un-munic.pdf	App_Data/entregas/366/8a1735745ad64481adf2f0481524ac59.pdf	f
400	367	1	perdidas-tecnicas-en-la-red-de-distribucion-de-un-munic.pdf	App_Data/entregas/366/8a1735745ad64481adf2f0481524ac59.pdf	f
401	368	1	adsorcion-de-colorantes-con-carbon-activado-de-cascara.pdf	App_Data/entregas/368/21db4c4b877b44e8adcf10d2bb1063a0.pdf	f
402	369	1	taller-de-escritura-creativa-para-estudiantes-de-bachil.pdf	App_Data/entregas/369/b968aa45b5634df0a5268410ad16768e.pdf	t
403	370	1	el-patrimonio-cultural-de-san-miguel-en-la-ensenanza-de.pdf	App_Data/entregas/370/38e0d7c6617240328b758531b018ed11.pdf	f
404	371	1	sindrome-de-desgaste-profesional-en-el-personal-de-enfe.pdf	App_Data/entregas/371/aaf85f0cc58748e29ef1668ae72e4532.pdf	f
405	372	1	uso-de-modelos-moleculares-en-la-ensenanza-de-la-quimic.pdf	App_Data/entregas/372/ea85e4e1202f47b1b523203a2f433483.pdf	f
406	373	1	feria-cientifica-escolar-sobre-reacciones-quimicas.pdf	App_Data/entregas/373/a409dfeacd9e4c7ca16169c25e9412bc.pdf	f
407	374	1	feria-cientifica-escolar-sobre-reacciones-quimicas.pdf	App_Data/entregas/373/a409dfeacd9e4c7ca16169c25e9412bc.pdf	f
408	375	1	aplicaciones-de-la-teoria-de-numeros-en-criptografia.pdf	App_Data/entregas/375/2dd77b400d3a4ef39a58d9931349c8a2.pdf	f
409	376	1	aplicaciones-de-la-teoria-de-numeros-en-criptografia.pdf	App_Data/entregas/375/2dd77b400d3a4ef39a58d9931349c8a2.pdf	f
410	377	1	control-de-inventarios-en-farmacias-independientes.pdf	App_Data/entregas/377/d6a9e28d9ce440828bc28906c6255b8a.pdf	t
411	378	1	el-arte-infantil-como-medio-de-expresion-emocional.pdf	App_Data/entregas/378/e8a71e897ab04395a7e3ac52ede6b8ee.pdf	f
412	379	1	simulacion-numerica-de-la-conduccion-de-calor.pdf	App_Data/entregas/379/4e7b703b0da649ad960548759026fd84.pdf	t
\.


--
-- Data for Name: tbl_rol; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_rol (id_rol, nombre_rol, descripcion) FROM stdin;
1	administrador	Gestiona usuarios, asigna roles y administra los catálogos del sistema.
2	supervisor	Revisa las entregas y decide si se aprueban, requieren correcciones o se rechazan.
3	usuario	Registra proyectos, envía materiales y consulta el estado de sus entregas.
\.


--
-- Data for Name: tbl_tematica; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_tematica (id_tematica, nombre, descripcion) FROM stdin;
1	bases de datos	Bases de datos y gestión de información.
2	desarrollo web	Aplicaciones, servicios y plataformas web.
3	redes y comunicación	Redes, comunicaciones y telecomunicaciones.
4	inteligencia artificial	Inteligencia artificial y aprendizaje automático.
5	otros	Otras áreas temáticas.
6	ciencia de datos	Análisis de datos, minería de datos y visualización.
7	ingeniería civil y construcción	Estructuras, hidráulica, geotecnia y obras civiles.
8	mercadeo y comercio internacional	Marketing, negocios internacionales y comercio exterior.
9	derecho constitucional y derechos humanos	Constitución, garantías y derechos fundamentales.
10	derecho penal	Delitos, procesos penales y criminología.
11	economía y finanzas	Macroeconomía, microeconomía, finanzas y desarrollo económico.
12	contabilidad y auditoría	Contabilidad, auditoría, costos e impuestos.
13	medicina clínica y diagnóstico	Clínica médica, diagnóstico y tratamiento de enfermedades.
14	medio ambiente y sostenibilidad	Cambio climático, recursos naturales y desarrollo sostenible.
15	educación y pedagogía	Didáctica, currículo, evaluación y educación inicial.
16	arquitectura y urbanismo	Diseño arquitectónico, planificación urbana y territorial.
17	enfermería y cuidado del paciente	Cuidados de enfermería y atención hospitalaria.
18	química	Química general, orgánica, inorgánica y ambiental.
19	sociología y ciencias sociales	Sociedad, cultura, historia y estudios sociales.
20	ingeniería de software	Análisis, diseño, desarrollo y pruebas de sistemas de software.
21	psicología	Psicología clínica, educativa, social y organizacional.
22	anestesiología y cuidados críticos	Anestesia, inhaloterapia y atención al paciente crítico.
23	responsabilidad social y desarrollo comunitario	Proyectos de impacto social y proyección social.
24	farmacia y farmacología	Medicamentos, farmacología, farmacovigilancia y atención farmacéutica.
25	ingeniería industrial y procesos	Optimización de procesos, calidad y producción.
26	salud pública y epidemiología	Prevención, vigilancia epidemiológica y salud comunitaria.
27	internet de las cosas y sistemas embebidos	Dispositivos conectados, sensores y electrónica programable.
28	biotecnología	Aplicaciones biológicas en salud, agricultura e industria.
29	productos naturales	Fitoquímica, plantas medicinales y extractos naturales.
30	fisioterapia y rehabilitación	Terapia física, ocupacional y rehabilitación funcional.
31	laboratorio clínico	Análisis clínicos, hematología, microbiología e inmunología.
32	suelos, riego y recursos hídricos	Fertilidad de suelos, riego y manejo del agua.
33	tecnología educativa	Uso de TIC y plataformas digitales en la enseñanza.
34	sanidad vegetal y manejo de plagas	Fitopatología, entomología y control de plagas.
35	química analítica y control de calidad	Métodos analíticos y control de calidad de productos.
36	física	Física teórica, aplicada y experimental.
37	ciberseguridad	Seguridad de la información, redes y sistemas.
38	matemática y estadística	Álgebra, cálculo, probabilidad, estadística y modelado matemático.
39	agronomía y producción agrícola	Cultivos, manejo agronómico y productividad.
40	administración y gestión empresarial	Dirección, recursos humanos y planificación estratégica.
41	energía y electricidad	Sistemas eléctricos, energías renovables y electrónica de potencia.
42	lengua, literatura e idiomas	Lingüística, literatura, traducción y enseñanza de idiomas.
43	logística y cadena de suministro	Transporte, almacenamiento y distribución.
44	derecho laboral y mercantil	Relaciones laborales, sociedades y comercio.
45	agroindustria	Procesamiento y transformación de productos agropecuarios.
46	biología y ecología	Biodiversidad, ecosistemas, genética y conservación.
47	derecho civil y familia	Obligaciones, contratos, propiedad y derecho de familia.
48	ingeniería mecánica	Diseño mecánico, manufactura, termodinámica y mantenimiento.
49	emprendimiento e innovación	Creación de empresas, startups y modelos de negocio.
\.


--
-- Data for Name: tbl_tipo_proyecto; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_tipo_proyecto (id_tipo_proyecto, nombre, descripcion) FROM stdin;
1	trabajo de graduación	Trabajo académico para optar a un título universitario.
2	tesis	Investigación académica desarrollada por el estudiante.
3	proyecto de investigación	Proyecto académico de investigación.
4	proyecto de curso	Proyecto realizado en una asignatura.
\.


--
-- Data for Name: tbl_tipo_recurso; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_tipo_recurso (id_tipo_recurso, nombre, descripcion) FROM stdin;
1	pdf	Documento PDF adjunto a una entrega.
2	zip	Archivo ZIP adjunto a una entrega.
3	enlace	Enlace externo relacionado con una entrega.
\.


--
-- Data for Name: tbl_usuario; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_usuario (id_usuario, nombres, apellidos, correo, contrasena_hash, activo, fecha_registro) FROM stdin;
4	Roberto	Aguilar	roberto.aguilar@example.com	AQAAAAIAAYagAAAAEFGDnbW97X/HpzdbLv/80TGivVFzDX4oLrPzFv8Z0gXtKQlmir7IxTqVKJYpwNde5A==	t	2026-11-21 21:57:55.53674
5	Claudia	Menjívar	claudia.menjivar@example.com	AQAAAAIAAYagAAAAEMrOTUpkKIqjz77cIb461mpCakyx36oiln01EJduuEUk0s5A/Qi3g4cmygzcy82Apw==	t	2026-11-21 21:57:56.112685
6	Mauricio	Portillo	mauricio.portillo@example.com	AQAAAAIAAYagAAAAEDdan8RoIKFtWgxdvyoX2t0Fpdr7tUWiB8COqi3TPZf2m8J/5I4vl/ZCJD5uG3VB5g==	t	2026-11-21 21:57:56.550374
7	Silvia	Campos	silvia.campos@example.com	AQAAAAIAAYagAAAAEO2qB/0pFtCFeXo2F3y68qZEirpJAJ/3MDZaSW9Q61lno3mx8mbFymyUVxeXf1ZHeQ==	t	2026-11-21 21:57:56.989961
8	Ernesto	Valle	ernesto.valle@example.com	AQAAAAIAAYagAAAAEMRkJgCD3BO1m6Gge5iGvzsWSKn4CKTuylRclYYEq0KxCHwnbeWzm7HlW3vKe553Vw==	t	2026-11-21 21:57:57.444642
9	Patricia	Quintanilla	patricia.quintanilla@example.com	AQAAAAIAAYagAAAAEF6WE/K84jvKVd/JPDdNyjj5CY/IN6Xw7fOmxP5xAiN70GlFbldLUlIwZuLqARkIpw==	t	2026-11-21 21:57:57.903131
10	Óscar	Linares	oscar.linares@example.com	AQAAAAIAAYagAAAAEAC2wQPJrCFrAIibCtcp1CpEXEGSmYLEagwsoADP5zV5e3dHiRW1JanhDSdnFwnNsw==	t	2026-11-21 21:57:58.370352
11	Gabriela	Recinos	gabriela.recinos@example.com	AQAAAAIAAYagAAAAEKHdh5Nbzd+aar2D2tEz2Mv+qg4ZAIEeFdZIerFFTbzvc4F/LRFPHp8uTG1C3njCqQ==	t	2026-11-21 21:57:58.823156
12	Francisco	Guardado	francisco.guardado@example.com	AQAAAAIAAYagAAAAEPv7VU9WXLiEGTEAVpHUC35kHBJGRH+qnBqt61Vn4Sxl0UJK833gySV8i38nc5z/Lg==	t	2026-11-21 21:57:59.283351
13	Lorena	Escobar	lorena.escobar@example.com	AQAAAAIAAYagAAAAEK/98VvmMdLPrp83Tnc+ewC2ejDIzSnALVQH0RO22bAoWCM1COkk6aCdiT6YohXKPQ==	t	2026-11-21 21:57:59.686518
14	Héctor	Mejía	hector.mejia@example.com	AQAAAAIAAYagAAAAEBZAQIwQzkITNY7PNmgo7lpQTkdV7BqmIi2Oin4HWks+8f8us8IjOL2QhNupHIBMbg==	t	2026-11-21 21:58:00.140373
15	Beatriz	Alvarado	beatriz.alvarado@example.com	AQAAAAIAAYagAAAAEOQnn060lJZW595iVLvHeOsxt1JXEkz2DvX4UjWLamve3zsokQ7xBtD8jAntLPBWew==	t	2026-11-21 21:58:00.53452
16	Carlos	Rivera	carlos.rivera@example.com	AQAAAAIAAYagAAAAEL8USa2o01ZQMN50qyC6Jm5lpLiuur9DSSVpArR6qGXG8xV4WJQbR4kfoUGTGQ24TQ==	t	2026-11-21 21:58:00.932261
17	Marta	Henríquez	marta.henriquez@example.com	AQAAAAIAAYagAAAAELwswvzYDAKQr4ba9QR836qvBFedhzgM66aTnPiQT3ujGf9OwNJBWEN9motGy5nLuA==	t	2026-11-21 21:58:01.353168
18	Julio	Orellana	julio.orellana@example.com	AQAAAAIAAYagAAAAEIaZzeItIIb10ahMF4wYKTHgRV/LJKbyuux2HDZN76JdZvmJ/dDvaW4MhWJPMdncug==	t	2026-11-21 21:58:01.743258
19	Rosa	Martínez	rosa.martinez@example.com	AQAAAAIAAYagAAAAEPqBUt976iZupjO8U50BlqGLUDzCEEz/PQFSntxjyBBU5caaNtRsrY2p6GQH4zS/Ag==	t	2026-11-21 21:58:02.138928
45	Alejandra Carolina	Lazo Canales	alejandra.lazo.doc38@example.com	AQAAAAIAAYagAAAAEN+qkU48VxuaD9iIwoyMbz3STcr3teSkWZpWbvUESuwN4Un5ab6Xv611E7m9heMG+Q==	t	2018-08-06 15:00:00
46	Francisco Diego	Benítez Rodríguez	francisco.benitez.doc39@example.com	AQAAAAIAAYagAAAAEIZdcWpkJVpp+M0TurEyuyq8iA6hUPBKwoZCgCGWTREMPAeNVlXBSJkhWQVmKubPCg==	t	2018-08-06 15:00:00
47	Jennifer Patricia	Sánchez Rivera	jennifer.sanchez.doc40@example.com	AQAAAAIAAYagAAAAEM7fjhmt6aw2XOjOaoCPy0I1yAx8o/QHCJScumfqyDFrvZ+R52B3m0zWrYGSsgbtCA==	t	2018-08-06 15:00:00
299	Sofía Gabriela	Benítez Canales	bc21808@example.com	AQAAAAIAAYagAAAAEPE+PPUhIlu/c+S9EZ4pLZtFTMUwZyHyWGpiNputuzBGg0YOUAnF3cZm5LcXNep0gQ==	t	2026-11-11 08:28:22.495697
292	David Luis	Rodríguez Ventura	rv20452@example.com	AQAAAAIAAYagAAAAEOPO+JB/R+1CCadjlTK5NkJ1bR16WxTh1JDroAGPr1uCKzgi9Dz1Ysfcas10DTrJcQ==	t	2025-07-27 21:39:03.033292
291	Elena Jennifer	Amaya Flores	af20592@example.com	AQAAAAIAAYagAAAAEFC/KgHMvuU9+avqrchfbL5NeYIN3FG0JqcmFlzTD+s6WJgGKbkjsdhzkthCqspWCQ==	t	2025-05-21 05:34:59.506826
298	Gerson Josué	López Portillo	lp21985@example.com	AQAAAAIAAYagAAAAEHhwNKqZul+dFi3U/vfGVltONJBakGBB1+eObP9oIk1EMlKvudPD9BJRG+EbKjZ+5w==	t	2026-08-23 04:16:30.221532
305	Fernando José	Díaz Sánchez	ds21394@example.com	AQAAAAIAAYagAAAAECsc767hF3whi6+1KiX0t9fqMcadApurufWWq1X5hFLWirZ9vM8IkV10vt6+dCR8Ag==	t	2026-07-06 01:46:54.313046
297	Emerson Alexander	Fuentes Benítez	fb21043@example.com	AQAAAAIAAYagAAAAEBB3yChJl+jI99J5h8EQsKd+OHlsD5y4CHCRNpXsVR7WpBcSb1yMlD4Xz3EFFOUURA==	t	2026-11-11 15:59:09.600281
303	Óscar Mario	Fuentes Torres	ft21401@example.com	AQAAAAIAAYagAAAAEH3Lukq0Te1mgfuZR/PXMnrWg8D9AbS31VDlIRv0IsJXqw156oh6JT7TD8OXSZTCiQ==	t	2026-08-23 07:01:10.601473
301	Wilfredo Fernando	Bonilla Lazo	bl21122@example.com	AQAAAAIAAYagAAAAEIv7dv2Vhl6N+aawSXSb7u1jEcij7+h2ygqUA6IjOeaLFgqSx46qGa98Q+iHcmoLkQ==	t	2026-11-09 07:58:49.69521
294	Beatriz Gabriela	Amaya Chávez	ac20929@example.com	AQAAAAIAAYagAAAAECf1FtT5CyZ1hkKzbgbCa7/jzYkl7Sbbn8JRQ3fcaxxqLRO2F1ec2Er67HF7FyiMdw==	t	2025-04-29 14:55:45.197425
304	Bryan Alexander	Fuentes Bonilla	fb21858@example.com	AQAAAAIAAYagAAAAEPsux3lZC0a3fGcQCF6YNN6ORoo63RoM2AMSs4f7AMlM2zKKOQfR06F1aQxE4IQhzg==	t	2026-05-19 04:12:34.606846
289	Ricardo Gerson	Umaña González	ug20392@example.com	AQAAAAIAAYagAAAAEKSRUqjPIhlUAmS7DexUtBF8qqgvNUoRevDAntpzw1JwwKe1CV9YPGljYZzoMcST2w==	t	2025-09-15 20:44:09.650857
302	Henry Diego	Guevara Cruz	gc21669@example.com	AQAAAAIAAYagAAAAEG2WOtjaq1rMilA41ZXZ8c1jWimp38wIGftAp0yafYD7mOk7/5Odgg/TPquWcioP/Q==	t	2026-11-09 11:49:03.647498
296	Yesenia Sofía	Majano Benítez	mb21227@example.com	AQAAAAIAAYagAAAAEAjSGy/1QEUD1cKNOMVhcYXDn84Rz1K0n/paeY67pcaahqjQrjCIY4U0JUt8+Xio3g==	t	2026-11-08 05:57:24.651361
295	Emerson Juan	Díaz Portillo	dp21394@example.com	AQAAAAIAAYagAAAAENvD8MQ6QPWeqcTr4vYdmaMWheUUNHgbj/Ab1Z/ssKIpA+FmapSeuavF6d+8KpD28A==	t	2026-03-12 22:48:51.768738
290	Daniela Patricia	González Cruz	gc20236@example.com	AQAAAAIAAYagAAAAEI/u/wwVvEF+k2e0qA6wms4fUeVIIkDIcni3E799iiCKjSbYNtEE4/znQEX9trl91A==	t	2025-05-15 05:35:09.451774
300	Wendy María	Granados Argueta	ga21086@example.com	AQAAAAIAAYagAAAAENuDgL78MsNCijwBppFQqLZiMOETaJpqY1Kz42cOJfnTwdaEf6dKfRZ9DTzPWhcqvw==	t	2026-11-11 04:23:26.086515
293	Lucía Silvia	Díaz Guevara	dg20946@example.com	AQAAAAIAAYagAAAAELqLXZkIIRE1Y0ygWNdegF84m6o1sbL2ezo0iDZ2gFrD+fL1MpACZBy7Pobo7ZvmEA==	t	2025-04-10 11:36:19.607911
273	Alejandra Fátima	Díaz Orellana	do19460@example.com	AQAAAAIAAYagAAAAEFVg2ZWxCetMM+pf8FjkrTm65fczXCktyQWpw+w61IFI5+H16AouZH7cyDDXgtU7Iw==	t	2024-09-02 07:56:52.254624
272	Daniela Paola	Granados Canales	gc19907@example.com	AQAAAAIAAYagAAAAELTM6X77dJpNCHsyQs2vyiDCx9qLYLFOub3YD2jqizZB1ijWzcekYuY7FOnHIHk4HQ==	t	2024-04-14 20:01:25.236263
278	Ana Alejandra	Lazo Canales	lc20647@example.com	AQAAAAIAAYagAAAAELHDj4ahrHBpqRbmsg4IsdzpD6vu9uX8RRAf20aLOhdkZ22HTuSjmjLVEXABdoodgQ==	t	2025-05-14 18:53:25.810479
236	Patricia Sofía	López Villalobos	lv16350@example.com	AQAAAAIAAYagAAAAECLTxRi+NemvDK1YUFNrE8rSGFKnmKSUnVToox1Yqeiwb1PG7EZ+/YkTPAdV8yn22g==	t	2021-06-17 11:33:13.488322
271	José Ricardo	Martínez Pérez	mp19924@example.com	AQAAAAIAAYagAAAAEBn7tVP3dhrDk5BOfdc3v11Pr53ge8/5rIqH984zwpREAury35jtUVdtL5fd5fDXWA==	t	2024-09-12 08:14:45.154224
263	Daniela Lucía	Gómez López	gl19540@example.com	AQAAAAIAAYagAAAAENouo1dy8ZdH4POy4hZ3iyddVEYnwIxEm5GzwLCpX28SX5HChfNkrJuVdhsoXsxLtQ==	t	2024-03-03 13:16:23.610962
227	Rafael José	López Alvarenga	la15340@example.com	AQAAAAIAAYagAAAAENO9pKa3+zOGL2kcd8cXR5A/gAmNk0LhxqhTXM2S/t9CIiFbo66dNxxtDbLD9KMlfw==	t	2020-06-23 16:47:36.343915
282	Alejandra Ana	Alvarenga Díaz	ad20289@example.com	AQAAAAIAAYagAAAAEP2JiXXJk54wI3Tmrtlf40fevxC8hMhPhVbuBMWeqg/FY0zfSBoOKHKhh2Msw/Gfig==	t	2025-06-05 19:36:15.772093
269	Gloria Elena	Sorto Sánchez	ss19375@example.com	AQAAAAIAAYagAAAAEEnDSJeip0KSGMbLKDHwKFL3Z9YPInSbvStYIgKLyWI6ELpm6b0U6iYUiQ03nGuv4Q==	t	2024-06-13 05:26:37.741439
261	Mónica Gabriela	Gómez Chávez	gc19916@example.com	AQAAAAIAAYagAAAAENKVg1IN78OQjZh4bBnvcZiIn0E6Q5Kpo9fhrC+wWB91i1jb94301XfSJMUxWoq95g==	t	2024-02-28 06:50:39.151392
280	José Carlos	Chávez Sánchez	cs20635@example.com	AQAAAAIAAYagAAAAEAmu5FFcgfx3cTfZz7QauV7u2NuXkcOAkOUdw2OHeaAZbsh3rMoJp2YGG4UOuVBdGA==	t	2025-04-13 06:07:44.285104
239	Paola Alejandra	Zelaya Benítez	zb16608@example.com	AQAAAAIAAYagAAAAEJckPttH2gvVRbtWxfW7UqUNtkpXHg5cJoXzgbZxojOI5ZYZvLVMvtIsn0Zaz4pB3g==	t	2021-06-12 15:27:23.298391
257	Fátima Alejandra	Chávez Canales	cc18464@example.com	AQAAAAIAAYagAAAAEBqh62OTp9bODJvhHZXtIDRldByvmQfk4mABPapi0Qc5uPNoQK6Zz5W0OgeFU1AazQ==	t	2023-05-27 13:07:19.725842
240	Rodrigo José	Zelaya Granados	zg16281@example.com	AQAAAAIAAYagAAAAENxEkCFxjvcOLKc2ueFD7XRtgP5haMePa5e9c+GfnG1hKXtCyU7KCdVDZi5O3gRlyQ==	t	2021-05-09 08:45:11.911962
226	Mónica María	González Romero	gr15526@example.com	AQAAAAIAAYagAAAAEKcGzI5g2JqcOZ9PpmdLlAv4cLUEw8Vs8gyDJcc3XVlhQQftcm38K5rDYqjqlVOW6w==	t	2020-05-24 13:29:51.349377
244	Diego Gerson	Mejía Romero	mr17673@example.com	AQAAAAIAAYagAAAAEBG261PlqnA4nbQ19H3uOaa0rVQCofvYsAs58N74q/vTp4SQS4tMjnmfboO2RjiO2w==	t	2022-02-27 09:42:31.377769
242	Beatriz Patricia	Zelaya Flores	zf16627@example.com	AQAAAAIAAYagAAAAEPyv/HOmj/G27gW6hEfD31tW7NaFZcU556BxmcVQTUNMY6E6zqlGGSWN+k7b2otz+Q==	t	2021-02-26 15:35:21.772573
251	Francisco Rodrigo	Sánchez Majano	sm18081@example.com	AQAAAAIAAYagAAAAEBT7tP6F0wq3ksTuzYZEQBdF3O3ua1c0KvpUe5Si+T6ALiTZ2B4RMotqhaIiXxPNqw==	t	2023-04-23 16:57:50.800545
266	Wendy Patricia	Ayala Díaz	ad19839@example.com	AQAAAAIAAYagAAAAEBQ7Yub5Nbk2mZLlISicddqytbWl3T3zuDQ2QKm8AHmjYlqVfsW5RDa5uW4DbdlOZw==	t	2024-06-15 07:41:17.293843
283	Jorge Luis	Zelaya Rivera	zr20210@example.com	AQAAAAIAAYagAAAAEKexIWZbL/fKj7akJSTbucTj9qDCKPLMCBwl8DHme0FEffoLmkd0bONUbv79ke8QIA==	t	2025-04-08 11:34:32.780517
233	Emerson Juan	Canales Argueta	ca16879@example.com	AQAAAAIAAYagAAAAECe5YoxkOs1uIu/JQDRyxvlNbD7qFQLX/3viSgmNIKKCuXFiETC+P6DKafvjg8mgpg==	t	2021-04-13 06:06:36.871404
252	Juan Wilfredo	Alvarenga Hernández	ah18033@example.com	AQAAAAIAAYagAAAAEG3dLSBzFwxUTHS4NSbycA7x4Wp7xYMgrtynHICOG9Qh2F2WEfq68R6ReIvf4XGWEw==	t	2023-06-14 09:39:53.743487
241	Paola Sofía	Argueta Reyes	ar16329@example.com	AQAAAAIAAYagAAAAEK+r+/e9RsIYKxqON4Hj2n2AwaeCf7D4jQ2PCnF4iDtDqdwdN2N7JGFSaLoDcYuM/Q==	t	2021-10-06 07:39:20.592027
285	Rocío Tatiana	Portillo Umaña	pu20638@example.com	AQAAAAIAAYagAAAAENe4tAyV92uwIehWYvM4/F4UjE3lkKKAm7ixf/hK5JiRB8WBsZWOO2ZUsitP9Op18w==	t	2025-07-01 13:04:10.863118
253	Valeria Rebeca	Saravia González	sg18509@example.com	AQAAAAIAAYagAAAAEJgXAo9w3hmmiDm9rfVVrFmxpvcxJNSJx/uhYW4k/SaE2jJqMUwVIrgEBbqbZulIeQ==	t	2023-05-09 00:46:48.817903
231	Kevin Bryan	Alvarenga Orellana	ao15215@example.com	AQAAAAIAAYagAAAAEFZgeMGsTwjLXgeKGCHuXcFdHvxdeQ5fM3C8CWp+Ur1xheQV1YHJYHZHki8Q1ooHPw==	t	2020-10-16 02:41:49.936219
246	Daniel Wilfredo	Guevara Quintanilla	gq17054@example.com	AQAAAAIAAYagAAAAEHz5zGq8vaC1Q3c8TZTsyN91TKMgC5vBdBg25Dp/4OmTkuR2zB8UHZndsb8JmXEapA==	t	2022-04-20 23:18:30.364049
243	Jennifer Ana	Ayala Mejía	am17518@example.com	AQAAAAIAAYagAAAAEEtxhCm6430MSYC4KrtipjxgjMJrOfY8zpxNOWoIxDZux+6KajL8DxaScA/63e6zBA==	t	2022-08-21 20:28:35.318943
230	Sofía Marisol	Sánchez Quintanilla	sq15781@example.com	AQAAAAIAAYagAAAAEDcXKdhN1A6xofkR7JQLxDStZwLwghtGYK8iO6ABZfTaGn7SGsr9l+LNBG4fCaDT2g==	t	2020-05-26 09:22:08.990435
222	Paola Jennifer	Villalobos Cruz	vc14883@example.com	AQAAAAIAAYagAAAAEEfwjnreAVYOMzG4OmcHXh/NdZhvcU+u+sn+pmkwRBmwbNh8mX7JBc0vP+/UMj78kA==	t	2019-09-10 15:36:24.387132
254	Fernando Rafael	Romero Hernández	rh18684@example.com	AQAAAAIAAYagAAAAECwt1/jBMrJ7fITu/J81hmxSiMj40x0neEKxT+zjCODM4kLhXPvMMpNeJpJxkL6nRg==	t	2023-07-07 01:33:16.504915
250	Juan Fernando	Ramírez González	rg17682@example.com	AQAAAAIAAYagAAAAEPrRzI4NbtklrWYWOdE8oK4qqmorwhh7CdklAnK4CYUCvCt+osJfXl6jD+MeXZ9I0w==	t	2022-06-21 14:05:34.470767
228	Elena Gloria	Lazo Sánchez	ls15743@example.com	AQAAAAIAAYagAAAAEHmQMcr0ib+PjBhnas//A2nbCBAZU6WhVR2ZuiNJztt9O91kyCveA6SX16bqrxhXQw==	t	2020-10-03 04:20:52.288574
267	Fátima Yesenia	Orellana Sánchez	os19312@example.com	AQAAAAIAAYagAAAAEMO+b6BDxXIGKlcAKMQ2TN6PL70IfzfonPadfPvm+enOODMMK3yel0DiHbgtkgz5nw==	t	2024-07-14 16:49:43.631526
229	Francisco Daniel	Argueta Ramírez	ar15958@example.com	AQAAAAIAAYagAAAAEMC/+KOvQhU1iPAss6kWiRKE3kwnrM9dMynCAA4wUu3iySyGdFTM+IedIN/j9Op2AA==	t	2020-04-01 18:55:03.901396
258	Carlos Henry	Martínez Guevara	mg18024@example.com	AQAAAAIAAYagAAAAEFegUcKsipqN90pGVlo9iILtbcRZelMFn1OgXecAvyU56SqK1+wR1WizjfORbDJVbg==	t	2023-04-21 06:53:42.736278
276	Josué Carlos	Torres Amaya	ta19500@example.com	AQAAAAIAAYagAAAAEL3EkxCW9SXQYVJNVI6VAwytMuMQi0qAO/BOBbnV5+asL5apmcHo4E8YE9ai1mLV+A==	t	2024-06-28 19:13:54.759753
237	Bryan Henry	Zelaya Fuentes	zf16218@example.com	AQAAAAIAAYagAAAAENZsUm8if3Ch7HFjxt5a/dTEgzxGXxMn7LoMleTxl8Qclc9ZQ8N0SWdbc3k99RVk4Q==	t	2021-05-11 16:24:24.08331
262	Alexander José	Argueta Ramírez	ar19458@example.com	AQAAAAIAAYagAAAAEH8rF8ksq+J0vlFPqqJ6zgvMBYfctnhwMdwuU5Ky7Fzb64eRGZvB6IL3LoIOWjLsDQ==	t	2024-10-04 12:06:25.19386
238	Yesenia Katherine	Orellana Zelaya	oz16273@example.com	AQAAAAIAAYagAAAAEJlmP6rQCClm39AKcXl6lg+zv9nCnUh5eT+Edo9iPAzD3EYCSyo0KrfpCeM4arCLpA==	t	2021-08-13 18:46:15.722735
268	Karla Yesenia	Majano Cruz	mc19220@example.com	AQAAAAIAAYagAAAAEA/PU4nszAGY9rmSzpBbniIZk4ZpvdCd232GCl+Gn1qFqVk6pYdqMVRJZ3e5e2YB6w==	t	2024-08-31 01:43:00.300296
235	Emerson Jorge	Umaña García	ug16966@example.com	AQAAAAIAAYagAAAAEOquiax9c8GSvsKl+QrKmLpuZHoPpDRaUVDodNEM5bgBWChNnmUzOjVgZ18ynzis2Q==	t	2021-07-26 16:33:41.914404
286	Carlos Mario	Torres Sorto	ts20601@example.com	AQAAAAIAAYagAAAAEMpIUvr8yWiRrcSXL41rlbNr6YW7aStZ1iXp/vTalA/V+rtMtxoecybEOOcOC+h2RA==	t	2025-04-24 13:26:17.907199
134	Beatriz Paola	Villalobos Majano	vm18449@example.com	AQAAAAIAAYagAAAAEG6zL25VRwZEuUj4nwPbxa9n4cKrmWQOkFQfGOOv2tL3EP4Kx0Wv+7+uPGgpdKNZeA==	t	2023-02-27 10:19:13.410007
279	Alejandra Silvia	Pérez Umaña	pu20026@example.com	AQAAAAIAAYagAAAAEDOLtZhlhqsG1+O66/89z9BwS74pJmPAfQ3nMW0igi0Ib3RfZEWERe4wzgouWnXIVg==	t	2025-09-20 14:47:45.540503
281	Walter Mario	Díaz Sánchez	ds20929@example.com	AQAAAAIAAYagAAAAEPPJWdaEjAbvjbUeMlQgAfkGUL9G2Ht1/bOg6ZO0Ecz1HjVfOG5DJLU8tdMO+wA8oA==	t	2025-05-09 20:21:25.731853
259	Marisol Rocío	Mejía Chávez	mc18719@example.com	AQAAAAIAAYagAAAAEFf7cAndXLUmKfG0MUGrX+FOzR4fR6cC+at1Z1LdmyBU972Tavg04ZLyvrnhGL3C0Q==	t	2023-11-19 15:38:39.416847
232	Henry Bryan	García López	gl16676@example.com	AQAAAAIAAYagAAAAEPEouLD8Q6MBENUUxk1ZJ+zDsQ5wu7PX0DWZ1IvwIE3aOSyg7m9MA95I8mQdJr5ICg==	t	2021-07-02 04:39:48.926934
288	Wilfredo Alexander	Fuentes Umaña	fu20985@example.com	AQAAAAIAAYagAAAAEM/1Xm7XDwEptTqnrHMeNuH8bBMD57/fx+yaNWNuB2dPtoGYUI3yqq/BBcOsxrrYkA==	t	2025-11-15 12:51:56.601117
249	Diego Julio	Bonilla López	bl17976@example.com	AQAAAAIAAYagAAAAEAvcwQbl/+sZooYEKGxyND59+zSc6hgpB6orv8NJNtVLIdnTkwTQvVQP3J/Ti7mpxA==	t	2022-02-17 05:32:53.452918
255	Mónica Rocío	Mejía Guevara	mg18843@example.com	AQAAAAIAAYagAAAAEAXF4eQM7FqoOkn7ivxyOHYNAE5wRcyg4WBR34ODFw3TKkG3a3d49YuzvihpCCm1wg==	t	2023-03-14 08:07:54.28206
225	Jorge Diego	Saravia Flores	sf15021@example.com	AQAAAAIAAYagAAAAENu6yNL/33gtQLg0FVMVnMBpYlPcMatlEc/bejDPXAFHfX8JiKMbyFS6CcvZZYHvqw==	t	2020-08-08 10:13:53.297914
245	Miguel Daniel	Alvarenga Majano	am17450@example.com	AQAAAAIAAYagAAAAEFwimiFLEjAgc6E8WPLKqW7OCkjTtt8ResjlySyvmbCc9X91jVjl1xhqtaJCf+N9iQ==	t	2022-05-15 01:14:17.507287
274	Silvia Ana	Sánchez Ayala	sa19830@example.com	AQAAAAIAAYagAAAAEB59FSx5GjR1Wbp0SBmTLgVDLYLmqakiMEPMEhoyj0rN4IEaa3mWGHzdRXHDNpxeFg==	t	2024-08-29 15:14:59.290209
223	Wendy Karla	Cruz Bonilla	cb15964@example.com	AQAAAAIAAYagAAAAEOqJN/V2wV/C4vZCEirUiKkXQzwLTal7b/CirjedIt7TAkZzwfmtx5DnhhQwoibI3w==	t	2020-06-15 18:29:11.509955
287	Patricia Beatriz	Rivera Canales	rc20995@example.com	AQAAAAIAAYagAAAAEOZsDJC+7ZXwngE1zGcZvYWcW5wax7i09qbP9dJHX2PQZBAVEptPVlcmpyeXc/ulzg==	t	2025-03-21 19:06:41.935529
221	Jorge Daniel	Amaya Rodríguez	ar14778@example.com	AQAAAAIAAYagAAAAEAhSbQrCcBHCuot3iTlHQWhrzeak2ln4KtDfS4ySlISoAxdUn2lXwQjn375i4BcdLg==	t	2019-03-03 19:00:23.327902
277	Walter Francisco	Ramírez Portillo	rp19052@example.com	AQAAAAIAAYagAAAAEMX20biMx0sqGYZzV+m5R2fLy0rk7E99Gr/QJ6zrqSX4ih3obZrtYYHxeZNtdTjzng==	t	2024-06-25 08:45:17.801208
265	Patricia Lucía	Pérez Villalobos	pv19474@example.com	AQAAAAIAAYagAAAAEJIuUfSes9GUYNjY3lm13q9EMI9JiCsyYWtoYQDNkIIXmki1bQC8YajZkHiReKvOlQ==	t	2024-04-19 03:00:32.144799
284	Diego Miguel	Hernández Ventura	hv20990@example.com	AQAAAAIAAYagAAAAEOZs2YY1G8XF21mq2VObJAc2TiPgdkdOrZGQyMlz8tXN0/rE93qfPL6DeegnCRmMEA==	t	2025-10-12 10:13:29.844519
224	Rodrigo Andrés	Díaz Ayala	da15978@example.com	AQAAAAIAAYagAAAAEEZBVIneqGgBM3QDlxAmci6AfZd2rl/C2G9bE5IAmCx6D5/xMWgay974CoFvy7G5YQ==	t	2020-05-30 15:37:26.234581
275	Henry Walter	Majano Fuentes	mf19979@example.com	AQAAAAIAAYagAAAAEAi3gqeR/q8PKT7UPJvzpI508vmF5pkMd/eEPoDTUe3XwUdZBQDV3FmqPkPhDf2eLw==	t	2024-02-07 03:46:42.993669
247	Carlos Óscar	Ayala Amaya	aa17826@example.com	AQAAAAIAAYagAAAAEIN6b2Fq07o+o1tcwSAGOn5YIOWB2wbLnmms8hx8NCRgrzUv+n5fkw3kKzseZysHAw==	t	2022-10-11 05:10:29.097327
260	Fátima Jennifer	Guevara Amaya	ga18166@example.com	AQAAAAIAAYagAAAAELRtZgtmbfvV1gGvNIouzAfMZV8h1Nq0gsNPwFzqEKuwSVCZkA9FLcUw9GF6IJY+2A==	t	2023-10-16 10:56:51.136828
248	María Silvia	Sánchez Pérez	sp17689@example.com	AQAAAAIAAYagAAAAEO5WwujLEZf4EjUsjS6pNXJXNbOxqnd9br477qtO4Vc1QUMxKm+R42CE4xi+5IWczw==	t	2022-06-07 21:34:43.665465
234	Wendy Paola	Ventura Bonilla	vb16263@example.com	AQAAAAIAAYagAAAAEFs+XpZ4XWT1bb+JCKryTAlUcxa3E0kvijPuVwywgwBeYKXDsTg8l8v0gUWh0+i4Xw==	t	2021-04-28 10:09:15.275388
256	Bryan Alexander	Benítez Ayala	ba18438@example.com	AQAAAAIAAYagAAAAEGVEJe8t+6D8v4Q4KaLSh9sfa8JvWpv5P6uCwIkMwGq5EYglGjuivG79iWUg+Q0NsQ==	t	2023-08-03 18:14:29.679107
264	Luis Emerson	Pérez Sánchez	ps19574@example.com	AQAAAAIAAYagAAAAEIpUBK85OYHMrorpcivXKXB11Qtxjtum5JsH2x48puYJZ7tb+gin2ZpR6zaaIie/uQ==	t	2024-03-02 09:19:47.019601
270	José Rafael	Sánchez Majano	sm19163@example.com	AQAAAAIAAYagAAAAEOZW0uJpf1p1MgvktcvjGMpxMMESeg2QitGVUo65UaHxZrHxecKi680SHKAOH58MMA==	t	2024-07-12 20:23:38.770128
48	Andrea Rebeca	Villalobos González	vg14648@example.com	AQAAAAIAAYagAAAAEHY6cbuCWhh66CZZB+rAHuOSWlaVvAWJ6M8sZmn6RDc0XbBALjvMg4mv3UuYuZATPw==	t	2019-11-14 06:12:27.49384
49	Mónica Alejandra	Quintanilla Romero	qr14905@example.com	AQAAAAIAAYagAAAAEDlYE4kExLIEdKPMYBCAlqIJYyW+xEGBss64IQCv0w6lqpHAixQfu0Ifp+onSxPxrw==	t	2019-05-17 06:15:16.446794
50	Josué Ricardo	Lazo López	ll14425@example.com	AQAAAAIAAYagAAAAEDrslX5UOnTkH2cVnLu7MJkFPqTJoHQTY9e6RH+FbzkMZqCbnelPzzonqDTB4RWv8Q==	t	2019-08-13 13:30:05.28599
51	Edwin Miguel	Chávez López	cl14785@example.com	AQAAAAIAAYagAAAAECf/j9hMu3mXFxnbyeP3h9TqPNBG8hum/7at0L5H0O4YMmlpJByJMR4ayROMjmEzMg==	t	2019-08-01 20:03:08.938318
52	Fátima Lucía	Gómez Flores	gf14065@example.com	AQAAAAIAAYagAAAAEEslVVrESvxsGiOtyoQwv9NoOXajJpBh9RG6aqLu0k4hd7PyGR2ZpS4pd7nMq8w4Ew==	t	2019-04-22 05:29:38.590797
53	Gabriela Patricia	Reyes Guevara	rg14954@example.com	AQAAAAIAAYagAAAAECw7uSfNJA9vVKQrCcC8Detu3Il+nihqR/BbHS+Mp/zv3UtY7awWT+j+ssZK7lXdLg==	t	2019-05-08 17:40:26.860285
54	Fátima Mónica	Ventura García	vg14148@example.com	AQAAAAIAAYagAAAAEDyWQkC604P89lh5DqXF72se2CUnMu9CS2hR7TmnUw78MUa1tErWMhlmEZQoVpp2rQ==	t	2019-11-29 08:35:42.464199
55	Rebeca Jennifer	Amaya Rodríguez	ar14796@example.com	AQAAAAIAAYagAAAAEE1oJGB64wXi8aqd40sRzeaSCMFuDMEMlbCTDygDgSlbCRR6mUJhZVmiA77bgyFikQ==	t	2019-04-07 09:56:40.10946
56	Emerson Gerson	Benítez Reyes	br14797@example.com	AQAAAAIAAYagAAAAEGEgcOuL1yMYCia5knfHOgAA60kIQlow1qGGEXdikvOOa1RUrAUIXQw5nFyjfsHHDw==	t	2019-02-24 08:31:28.112614
57	Mónica Alejandra	Villalobos Chávez	vc14251@example.com	AQAAAAIAAYagAAAAEKCa0xxdZLFAX3cKzzb2YN8qQOlWZWjZaMiTch+QgxJMF/2zvfn8hrw1tJwgVdCG0g==	t	2019-05-05 07:45:18.514068
58	Andrea Rocío	Romero Sorto	rs14167@example.com	AQAAAAIAAYagAAAAELNv7F/gaMCYLv3D8nWRrK3h2c1Og8FpVvQhwFMP6y69kBjKP6YljrJl2wz/ZYj5GA==	t	2019-11-21 00:48:42.780161
59	Silvia Lucía	Flores Benítez	fb14568@example.com	AQAAAAIAAYagAAAAEHsHNQAtxzOCAtQyD2Tsopun6OtyVr2R4TAxjMEyo9XyTEi4mC6hWzKVe8JhrQHunQ==	t	2019-08-26 19:52:04.392613
60	Óscar Edwin	Argueta Fuentes	af15749@example.com	AQAAAAIAAYagAAAAEPoSY0T4XsMiJ7x9scz+RihmSEfIoMSZtWS0u19xMWFcZ113LVIyLaQItrLldy22Rg==	t	2020-10-04 05:16:27.004032
61	Elena Mónica	Quintanilla Granados	qg15526@example.com	AQAAAAIAAYagAAAAEAtNqLYJPq7CksnbVXT/NoW8K6+sLTCs5FTFFb9Bt3z7AiO+EdQuPL1ycLrQVXhCHQ==	t	2020-07-31 00:41:07.976645
62	Fátima Yesenia	Rivera Benítez	rb15893@example.com	AQAAAAIAAYagAAAAEEIGlypiqz0NxyjnNDZ91g7gNUzeAMoWDO2NRkuDtcadXFxXssURacSgnkziKnL+uQ==	t	2020-06-16 14:51:27.624935
63	Wilfredo David	Argueta Canales	ac15928@example.com	AQAAAAIAAYagAAAAELQnBnemcFbDyOt2E/0kWcGgQz0jP4FBxAei+l+l4wLWkaOAoY/ws0h6ZhQ9QE3Zgw==	t	2020-03-20 09:27:20.582369
64	Fátima Jennifer	Quintanilla Lazo	ql15387@example.com	AQAAAAIAAYagAAAAEMjkfbtEYaQG6sG8T/AOKY9gk1ecg0Ub560sNrwToo3oy51XnEFQZVQryR6+pMzFXg==	t	2020-10-16 22:53:32.524231
65	Ricardo Walter	Saravia Ramírez	sr15032@example.com	AQAAAAIAAYagAAAAEJ81de/T9b8YDc/R3rQxfmHQwj6WqI4z8XWVbELTpi2yJ+jxApS1+bMTjr4k5KoT9g==	t	2020-11-15 12:08:24.146858
66	Miguel Fernando	Díaz García	dg15995@example.com	AQAAAAIAAYagAAAAEMy96qpBxHh9AoYx2bmDeafV4pRAIOsoRGL9kbXLqsCLrxQI7hESXFjW/RwnKRSkjA==	t	2020-03-25 07:19:55.059736
67	Valeria Patricia	Ventura Hernández	vh15365@example.com	AQAAAAIAAYagAAAAEDRhbaFuSYG8XyJOaf9RZJKq3cpPQf1VCTfA28WFLdUf8U37X/K5zwjE4oPKshpjgg==	t	2020-08-14 16:34:41.037665
68	Josué Francisco	Díaz Saravia	ds15224@example.com	AQAAAAIAAYagAAAAEDmUF4yVXypwqcScSlOGmO6BytvPpqb8jPG/swcIbCM5jGiBp00IktKX6D6o/Y40kg==	t	2020-04-27 15:41:11.674071
69	Fernando Mario	Sorto Villalobos	sv15526@example.com	AQAAAAIAAYagAAAAEAMDiiDefrVTVLr9uizEUnwURVnT6J0mpsIC4wGrf/CCFVWbsulU/SQj65fYssbH4g==	t	2020-09-23 21:23:36.313528
70	Carlos Diego	Díaz González	dg15162@example.com	AQAAAAIAAYagAAAAEAZ9APd6Kp/Rv4410pw0HZOXdrJlWlinftZzOsBAb9N4M6UURN4eZepzaJNTs7N7IQ==	t	2020-06-06 22:07:17.27547
71	Ana Yesenia	Zelaya Umaña	zu15194@example.com	AQAAAAIAAYagAAAAEFtNfnIAaNeSGR3ETFtRE74hh/RF1pqCr55aPSkthE7EsN/ytUlKBSJ7NJ++PKvQaA==	t	2020-08-22 02:15:16.041305
72	Edwin Walter	Canales Sánchez	cs15292@example.com	AQAAAAIAAYagAAAAEAISMoJ0qo/Mla3Z+fKIGSwdF4bGuuqcUexc8i3QugU2f+JT000blP/AaWrtVR/9wA==	t	2020-08-15 03:25:42.021823
73	Miguel Rafael	Martínez Quintanilla	mq15973@example.com	AQAAAAIAAYagAAAAEGAnuSbZy2sHSs2nCkb7S9a+R7poabMAMIabbOTENTNXWxGxdwIfqVPuQKnIas51TA==	t	2020-07-08 06:24:07.591005
74	Edwin David	González García	gg15934@example.com	AQAAAAIAAYagAAAAEC4c4T6iG3LFhCnIh2cAI3s31SSTQfEnERdp4C0Y4JNlyR89YMsDuHEXR3vD5qt4bQ==	t	2020-10-24 12:48:17.389775
75	Sofía Ana	Romero Hernández	rh15919@example.com	AQAAAAIAAYagAAAAEFlkh3fcrQglAaWivLNtn8JvltYnBhzDiq5PX+42NbQUK8pH81Ut8UnMetqRWRLc1g==	t	2020-07-27 05:54:49.754748
76	Carlos Gerson	Majano Gómez	mg15721@example.com	AQAAAAIAAYagAAAAEJrArUp6KZ42/fZnEvT8qhoGvYioiuOt/wLrOZDhoUdGoez09A2D92lGjONFBcAw0Q==	t	2020-10-12 14:46:24.659428
77	José Bryan	Díaz Pérez	dp15127@example.com	AQAAAAIAAYagAAAAELe4uupZxLaRrZ90VDjKbrxCppFLcbTm08OeA8HIgdnhBwsbN3+CUiT9GHqrBMTR9Q==	t	2020-03-23 02:44:54.993699
78	Elena Rebeca	Granados Sánchez	gs16828@example.com	AQAAAAIAAYagAAAAEDvck0od0BlLYeAKg8NjmqlERgT3uuKBXqeatlifH5dWej7h6QtTkmVtOfGwqCSAHQ==	t	2021-07-07 02:22:49.999608
79	Marisol Patricia	Majano Zelaya	mz16997@example.com	AQAAAAIAAYagAAAAEKbrWJExTvB430lmqk7uxynExm+VsKymrB3QH7rh0SWSbM/QZ1LwHGvKVO++3IrAvw==	t	2021-04-18 05:30:44.973427
80	Andrea Daniela	Cruz Pérez	cp16419@example.com	AQAAAAIAAYagAAAAEGYPOx0Bhq6iNJS0NQvD1kppAoL4mXU8p1SDpatNlNL56waDHZd7NwLv3xtJye23Aw==	t	2021-04-13 20:58:42.622983
81	Miguel Juan	Martínez Díaz	md16247@example.com	AQAAAAIAAYagAAAAEEQbv7wLZ5R0io3cjEQFdcNV0aBJjXzE7KkOaptv0cRxfvS11jgbRS9Yr9VoxAu45w==	t	2021-06-30 05:54:11.257637
82	Mario Josué	Orellana López	ol16862@example.com	AQAAAAIAAYagAAAAENz4qPeskzokQHZYHX8DaucgnXwhz/wjuJz4LU7TcdAcDvbHSmhprH7pHJv/O94cYw==	t	2021-03-12 15:15:48.374278
83	Gerson José	Reyes Ramírez	rr16491@example.com	AQAAAAIAAYagAAAAEDSuCPjIV2w4J8zH72xTf09yjBBq66Pt2CPKLo8HdlDRqKV0nJ98xldAlDI/2xYUEA==	t	2021-04-19 23:00:36.341193
84	Karla Patricia	Bonilla Reyes	br16672@example.com	AQAAAAIAAYagAAAAEFtXPCZ/1gKcbxgvqtJwPvRUqcDfB+6x6IkloIgW7YcjOLzjNWQ73fYCSmw7Ik63tg==	t	2021-10-03 20:37:30.412356
85	Francisco Carlos	Martínez García	mg16360@example.com	AQAAAAIAAYagAAAAEDY/SYJCSPpeP/YpcsuR6Blmtbesm5lwlU0Q1pj3e/4Wl1ef7qxvlskDSGUTvaVw5w==	t	2021-08-11 09:58:24.059398
86	Andrés Daniel	Chávez Orellana	co16404@example.com	AQAAAAIAAYagAAAAEPBwenNxlWKioOuYHORXzpge9GdG3oo1qbWtr144Qt2GFrsqIa/0oJnSo4hikc5Uyg==	t	2021-08-18 07:54:00.379051
87	Julio Fernando	Benítez Gómez	bg16956@example.com	AQAAAAIAAYagAAAAEAhlio5oqrSF2epjs+3xfLqeI/TD6ng0CMuOXop0SUtW+hzgkEdoWeXzW5gmTUWCbw==	t	2021-10-25 18:49:18.663465
88	Beatriz Lucía	Torres Ayala	ta16659@example.com	AQAAAAIAAYagAAAAEMJEsMvjBOmLKZ93wJ1Wj39G/d6ntyw/yGCNnqXq3MJbLr1YK6bNlxutVhzQWGHbsA==	t	2021-02-11 09:30:33.333592
89	Óscar Luis	Ventura Quintanilla	vq16600@example.com	AQAAAAIAAYagAAAAEIKIG0ccJyI/pqB0QHIeCKZRGVJW96lSy4MDPwZThUpdoegdFTbSU/qQkfQgtagAYQ==	t	2021-05-17 15:29:24.329904
90	Silvia Beatriz	Zelaya Argueta	za16931@example.com	AQAAAAIAAYagAAAAEJKDnSKj4saZansb4wIblrL80TuV8WAlP+yYln/3fvJj/4E8Y+OlfaapZKGF8a81PA==	t	2021-06-23 01:20:51.381296
91	Patricia Ana	Chávez Romero	cr16758@example.com	AQAAAAIAAYagAAAAEA3NBp98KY5/DrlBq4a5rogbDoPBtgjhbslayR1VUBxKEwxugvbFHC2tkQyLsNnT4g==	t	2021-07-25 08:01:12.950139
92	Yesenia Mónica	Ayala Chávez	ac16463@example.com	AQAAAAIAAYagAAAAEI6tsBE1b8AC35aI9IcoDaRKN5K6VZgGq3KP+5nDEh9D5A+7A9zLPQR7VkhWLU7DRw==	t	2021-08-10 03:43:45.810107
93	Fernando Gerson	Pérez Sánchez	ps16642@example.com	AQAAAAIAAYagAAAAEHSGB/zuIdk+pLl1auI5AaZBibvFHWtKPuxnrJsySf5QPG+ZkPkfwTw4Q0RmGajs3Q==	t	2021-07-11 06:27:01.281505
94	Gloria Andrea	Flores Ventura	fv16161@example.com	AQAAAAIAAYagAAAAEIePPT2t/t8rOlxQ986lpKsD/weGf55AOA2jinOuV2TyueXyh/wh9Uz5uLnQy2VkhA==	t	2021-05-10 09:19:27.156896
95	Juan David	Fuentes Rivera	fr16748@example.com	AQAAAAIAAYagAAAAENSGESwb9VN8vaukcS40hAU3kILZ51QhKZRvOG6xJoc7z0WSPg79W67Y+Ym+pUst3w==	t	2021-08-19 21:15:15.038777
96	Wilfredo Jorge	Cruz Fuentes	cf16336@example.com	AQAAAAIAAYagAAAAEGD+q7urRcZh7VVLqGukZgRalIOmORwta27X7N8tj1vSUnv7PBKMs0jxOuVxu8wDZg==	t	2021-08-17 07:39:03.13098
97	Juan Daniel	Fuentes Rivera	fr16004@example.com	AQAAAAIAAYagAAAAEFnMtwid/jEmNojgQbsm6UNdS7Z5it2WJ8B7XFQ+IqcT3W5cP2yq9ogcj0TMea90fA==	t	2021-05-19 15:17:30.181522
98	Rocío Marisol	García Pérez	gp16931@example.com	AQAAAAIAAYagAAAAELXZ1XdOFVBGomE/syCwx9ikC4xK0GgUz/1G98detmAMdMIIFyvTv33fziiuE8krYA==	t	2021-05-26 16:20:32.306807
99	Claudia Lucía	Benítez Sánchez	bs16135@example.com	AQAAAAIAAYagAAAAEMhGVgx5U5liTUf/oG5gSJOYSRhjie0GMONX69ryTikE2W+0ywOlYU1N3TZ6To1ICQ==	t	2021-10-06 14:18:18.204223
100	José Julio	Orellana Zelaya	oz16096@example.com	AQAAAAIAAYagAAAAEAFsWhQMEppoVfzWQwaeWc32C91SJf5HxFJ/2Kt9uLLbm/eoJHxfcj+EnzHNAodvcQ==	t	2021-09-30 10:50:28.96663
101	Alejandra Wendy	García Hernández	gh17318@example.com	AQAAAAIAAYagAAAAEGZeeIg/am1p44KZELyynm81cVm4yvDmzuZpXH+ztcdRnsQfBH5HvWU+8OXCB+dvOg==	t	2022-05-25 06:31:28.675793
102	Alexander David	Benítez Saravia	bs17161@example.com	AQAAAAIAAYagAAAAEN6mzlcAg410HYDV2FwMQBC9JYp1pZ/Q5QPt5LuigLMvmMpui9SF1hQtQrVL5SxdMw==	t	2022-03-24 19:42:56.605094
103	Claudia Paola	Villalobos Umaña	vu17101@example.com	AQAAAAIAAYagAAAAEJEoYD3tQ40AizQrgm2HdYt3uu7AUwwlhV3vjjuU+P97GDkvq7RMcYnQBLFY0EqJlQ==	t	2022-03-07 22:56:04.746277
104	Mónica Rocío	Flores Pérez	fp17863@example.com	AQAAAAIAAYagAAAAEEUW+PZGn9KN7/sNJSUaV9Dk153Z08tzeawhiUPet4Rzwu8WTOCbstJps/XmpBsZWA==	t	2022-05-02 22:31:26.324044
105	Katherine Beatriz	González Torres	gt17966@example.com	AQAAAAIAAYagAAAAEGXZoGJxO4UaI2zu1npLPkWxsnDDS/GAdgt5+kaU0E3EtKQfL09ZwqxpG2Dwprgp4w==	t	2022-03-18 03:21:48.365765
106	Wilfredo Edwin	Portillo Umaña	pu17845@example.com	AQAAAAIAAYagAAAAEL8M6t87jgHEsbxyiR0oWbpsGsf6NCEO5xBh4etArvPUT+ZZX9ndkFuDFDuy+SP20w==	t	2022-11-18 18:59:17.424206
107	Luis Kevin	Lazo Ramírez	lr17979@example.com	AQAAAAIAAYagAAAAEAem6weJ3vkkvPWdo1k7h3qQKIPkX4Hoz44oz8CWRXtdsFz+C7YVIpl6IBfgTzdJww==	t	2022-07-15 14:04:28.10801
108	Wilfredo Gerson	González Pérez	gp17780@example.com	AQAAAAIAAYagAAAAECeLY5Buq/p/Cf7UUFobpfB1wElZziV6Wfgo3xlOinOIAXUt/H0kDJKBNxCW26k5wA==	t	2022-09-21 11:19:09.081503
109	Elena Yesenia	Gómez Díaz	gd17813@example.com	AQAAAAIAAYagAAAAEP1BznAMLIxuMKQzC9PRwn4Ds6HliQjRBeTI6wln5CUjeOwS0kb4hbji5Qj3jAo0ig==	t	2022-09-26 11:15:40.25802
110	Kevin Henry	Quintanilla Fuentes	qf17731@example.com	AQAAAAIAAYagAAAAEIXS0PEloJFc1EwsiCEFN4VMRV3dp649Dih6u+sXmPKxFYAgtwvkuxDGaQ7jF359YQ==	t	2022-03-27 23:41:35.310522
111	Alexander Josué	Canales Ramírez	cr17001@example.com	AQAAAAIAAYagAAAAEGkvXIZQXCsJ1NlbSD5yEhNUJomLmpx0XjK6zYecFKLHHvHo2xdlFZU+OIF4pC6I9A==	t	2022-03-06 00:47:40.145248
112	Óscar Gerson	Ventura Chávez	vc17430@example.com	AQAAAAIAAYagAAAAEFKXQBs7oqXa76/NTedvrFD4bzHx3jHm7JTyW/K8+El4tL9bDvpZ0YnILmN726Bc7w==	t	2022-06-30 11:00:38.011701
113	Óscar Gerson	Gómez Alvarenga	ga17150@example.com	AQAAAAIAAYagAAAAEN0jIbe8F36JdTDs1UJI6Rc8VDJZppVklU98NCQ0xtAL39Q5608JP8UMJY1XZwnr3Q==	t	2022-08-11 21:35:52.941613
114	Bryan Mario	Torres Ramírez	tr17211@example.com	AQAAAAIAAYagAAAAEKwyUn8zQ4DSq0oBSGV5lNagLtgb8VOVQS/hQPeKba7JnVZL+KnVSnxk9INvqgrWtw==	t	2022-03-20 02:37:30.887451
115	Wendy Katherine	Portillo Quintanilla	pq17091@example.com	AQAAAAIAAYagAAAAEBbxPxM1jtUrsRMWZd0H645iTBbWzfPXNIMhnOkM1H4UmBlf86QbCPXkdv5hbRhZfw==	t	2022-03-08 15:24:06.844222
116	Andrea Sofía	García Majano	gm18377@example.com	AQAAAAIAAYagAAAAEL59smVoPZ16GAEaPbLE9CHJNjxz/C/Q50TQ3BbIrBQ7Tf/gc2sVs/ZNCMYAz9wMIA==	t	2023-08-15 14:18:30.729963
117	Fátima Yesenia	Zelaya Reyes	zr18213@example.com	AQAAAAIAAYagAAAAENUBmdqiShn+9i0XyS1fWyiLuPrd1LogF7cw5ziU1/+M26HmpNR6Nq+4B4714wubuQ==	t	2023-03-19 14:35:45.350772
118	David Wilfredo	García Villalobos	gv18668@example.com	AQAAAAIAAYagAAAAEHbPcc9zY8Xf9s7x9KvB0wro8CJIRPDDzatiAHtmDApq0OhJ2pYnbGoRDJ+YPQT7Zw==	t	2023-11-06 22:35:46.32854
119	Kevin Juan	Mejía López	ml18083@example.com	AQAAAAIAAYagAAAAEGvI/jIeL+FFtm22slj3GZ47HaSXVmcl3nyXYkO4Yp3IpXnMerPpkSGZLFgY7PnyLg==	t	2023-10-10 11:21:08.348793
120	Rodrigo Emerson	Martínez García	mg18950@example.com	AQAAAAIAAYagAAAAEJryc2P08b24ahJOkzbPd4np99KaKRD1r1C/Ab0vehoe8ztaL19KMmry1pOkqh7ZTA==	t	2023-03-23 09:32:08.323151
121	Rocío Alejandra	Martínez Rodríguez	mr18888@example.com	AQAAAAIAAYagAAAAEJRCghQDmdcqP29FKS/7inYtC9bjsniro/kqUcxvacLrBUpD82Az2bL5nj0kv5bkAg==	t	2023-11-22 09:11:02.264778
122	Miguel Gerson	Saravia Guevara	sg18648@example.com	AQAAAAIAAYagAAAAEGCL7X/sgmLLC0/Kf1S3Amb2K9J+K1cLAuJ1NRIhxbNRsAgPRejKLAPcHSMDDPRv6A==	t	2023-07-20 09:56:34.169288
123	Mónica Marisol	Quintanilla Romero	qr18663@example.com	AQAAAAIAAYagAAAAENBWEg/yIEMafjR5gBJN2P3hKvJfsAIAKh9Uksl+cFZ5mEiUsNq5zTZqYbx/3WN5YA==	t	2023-09-20 22:08:49.790761
124	Carolina Paola	Ventura Chávez	vc18563@example.com	AQAAAAIAAYagAAAAEPvbzoBn2ZuioL1FBrvuHystEFOZO8kKzQ3METRDbzsOljhqsnGhHuxpxwM+BstXbA==	t	2023-07-25 01:36:01.399225
125	Alexander Gerson	Argueta Canales	ac18021@example.com	AQAAAAIAAYagAAAAEEYplrueVx2pDZ0lpZwSRCl5OFqRSjGgkF51THvIlIVeQpbc6IAdhzxs2wpiyk0WWA==	t	2023-05-04 07:12:39.34142
126	Bryan Wilfredo	Rodríguez Pérez	rp18170@example.com	AQAAAAIAAYagAAAAEGDbG7b1ICbY13A9T0BDNG2qfV96zfBU6c+lqmtBD0M6WZmBnK2SKAjAQQI8d//zhg==	t	2023-05-29 22:53:00.596872
127	Elena Silvia	Martínez Benítez	mb18222@example.com	AQAAAAIAAYagAAAAEFJKMMxjxAIVvnSuEItOzplTVSavmfL+iGzt33OysV8kmbymSWOtlJiZfxBFGlEzFA==	t	2023-06-21 13:43:49.281541
128	Wendy Katherine	Argueta Ayala	aa18755@example.com	AQAAAAIAAYagAAAAEHMuMxG0bgUG9nQ98LMDnFc70jWc4UK9C2nrtH42BQD2HS8wmCLb4HXD1t/KX/u5lg==	t	2023-09-10 03:27:19.377397
129	Rafael Alexander	Díaz Ayala	da18379@example.com	AQAAAAIAAYagAAAAEEwJXcmWH+g6kZwIN05wT1UvftLihLZBH2aj3DQhaa5dvgLwKdTyM2BIIfA6MKboVw==	t	2023-06-10 22:20:05.257719
130	Elena Daniela	Flores Amaya	fa18537@example.com	AQAAAAIAAYagAAAAELgwXH+D2XJ+M96swtMQcz9CVzfNwoEe8yLUxux4282a3E3gm2k3h4vh4ekJYLBDjQ==	t	2023-09-17 14:21:51.962013
131	Gloria Rebeca	Villalobos Portillo	vp18653@example.com	AQAAAAIAAYagAAAAEJbaIjUUyx+Gbe/h9qleZ4VG6pi82dK73IIYOooZ+0ND3ETthIGG3mruycW7E1cf5g==	t	2023-05-21 18:00:32.390653
132	Valeria Rocío	Lazo Bonilla	lb18981@example.com	AQAAAAIAAYagAAAAEIMG5Em10F0K0k7+IHfaRPRGJBsEtnuex9cQuwPUYt8j7APHY5M5rs/oRXSwcW32iA==	t	2023-05-20 02:02:39.053929
133	Gerson Luis	Reyes Saravia	rs18997@example.com	AQAAAAIAAYagAAAAECRJWeFAFSoFIizqS7QUbE3ileaTovinBVq/OeIH5V/oVTH4OvpGVMSi5TW3Tk+KNg==	t	2023-06-30 00:58:30.832042
136	Juan David	Argueta Sánchez	as18697@example.com	AQAAAAIAAYagAAAAEFSBon0KSU71KXtbtTgANXrSl2VJ2TlpxHb47tag6ecxWIwEgVy91k4xozrAGLRipA==	t	2023-03-23 20:38:46.262713
138	Sofía Patricia	Sorto Martínez	sm19718@example.com	AQAAAAIAAYagAAAAENwTarTVax3uEjaGZkyInyEU8a7SfJVri0xgsqemhW4xOdNK00aFpc7B2VF41LROZw==	t	2024-08-03 04:08:21.240532
140	Gabriela Patricia	Sorto Amaya	sa19366@example.com	AQAAAAIAAYagAAAAEC1rpC0zT9g/vZxFeSBMwQxLisxe9AN0LP4SH+hi6iPFcQIzyp9tX9QeU7r0M8qW6w==	t	2024-07-08 22:22:29.799454
142	Mario Julio	Orellana Sorto	os19502@example.com	AQAAAAIAAYagAAAAEFntUaGysJaSrS5knC7E94CD2k/FEtJBXlDFZoUDfKijNunq//Eye/bC+8Gf4u7ecQ==	t	2024-03-20 01:01:34.71129
144	Silvia Paola	Romero Guevara	rg19952@example.com	AQAAAAIAAYagAAAAEPr9+j0yu4yomzrMT077TUGAnl1iwqPP5OicvPLDqDfYYveXOELtvL/FBs2AD91dog==	t	2024-02-27 04:40:23.261771
146	Fátima Tatiana	Ayala Argueta	aa19661@example.com	AQAAAAIAAYagAAAAEJZUmJS0lEQ2+HsvItV8r2i0PTuenjAHXGSEbD/al78NQbrt3Ikpwq4ckJN7iJ/qlg==	t	2024-07-21 03:01:58.7298
148	Claudia Gloria	Romero Orellana	ro19173@example.com	AQAAAAIAAYagAAAAEM2WzY4XEpvyTflPQ7DBaGwdWXBEEOVmTN4Yqog8reT50lwxiC+Fe3aGWsDhpk+jIg==	t	2024-08-11 16:46:43.801735
150	Katherine Wendy	Guevara Sánchez	gs19978@example.com	AQAAAAIAAYagAAAAED4NLraLaET/mT/KtA1SfHC9aLGGj98iUeQiOlOrFoTFMapLQtqMoxw4ZdmdR0RbuA==	t	2024-08-08 20:33:17.848493
152	Tatiana Lucía	Umaña Chávez	uc19741@example.com	AQAAAAIAAYagAAAAEI9qaHSMWXycM/GAnHF8yaaq3OLJCIy8FyiqiaJFVMnNnwi7+svED9wQayxtTlu3ZQ==	t	2024-05-05 06:53:08.717728
154	Patricia Mónica	Chávez Canales	cc19224@example.com	AQAAAAIAAYagAAAAEPjkemy6FbRkmxTkfYDhas2saInz4YWyZk8fjrqxsV68Cz4Is+XefSBFpcwjlETdvA==	t	2024-04-10 18:47:49.640075
156	Yesenia Silvia	Benítez Chávez	bc19730@example.com	AQAAAAIAAYagAAAAEL3VW6JZ0bQ7LvfkTjivv5wLSSBLbvHe123dNFhxR3W98GCwn8XiatyPAXVmccDJig==	t	2024-07-26 10:32:59.365624
158	Rafael Andrés	López Alvarenga	la19738@example.com	AQAAAAIAAYagAAAAEHgxVDb5Cjco6aynZGvwXho+jQKTBvAHSfOXw9L8qAZ50hAbdRi5voy28hfeH7i0Uw==	t	2024-03-11 11:51:24.20424
160	Gloria Gabriela	Hernández Rodríguez	hr19482@example.com	AQAAAAIAAYagAAAAEMpBhMaWP/VzQ4HgBJV2bDybLLoHnpuULA6OqClLtdG4tQrBgObJOt/xM5LNZzA1Vg==	t	2024-03-24 07:05:50.467214
162	Rodrigo José	Saravia Umaña	su19882@example.com	AQAAAAIAAYagAAAAEDVJLm4zMUqJC7DzNteAUeEKQ4uP6/oBGJdvtH87fRqJ7WAmGM0wrRU6bL20sSKNSA==	t	2024-09-15 14:04:37.982672
164	Yesenia Alejandra	López Sorto	ls19377@example.com	AQAAAAIAAYagAAAAEIin2dltqugsSVQGBkNe8zqJ+RaT/X+Jb7HMp4Cbr8ND1XkgISupFE5NFAAPe2Lzrg==	t	2024-04-28 20:19:08.182154
166	Alexander Josué	Villalobos Argueta	va19730@example.com	AQAAAAIAAYagAAAAEONHf9OsmhvnC3q5tCdczxwMouwocqbXbvswPczaNMQnx3CrAKldbI2nrri8ArTVBQ==	t	2024-05-26 09:09:41.596409
168	Andrés Jorge	Díaz Torres	dt20926@example.com	AQAAAAIAAYagAAAAEMBg3c7a0CWRqTAGAc2PSS+o5MPnNWIGi0av4M4+sWfbuViTSBeHr9mDmFdBzvsIVg==	t	2025-04-27 18:43:27.250555
170	José Fernando	Portillo Quintanilla	pq20737@example.com	AQAAAAIAAYagAAAAEMLZ9Uy7dYNLo5tt1y749ZxURNiFznhHT7N/d4kKHdC0EIhZnT53/V0j55RKIOK5Hg==	t	2025-10-13 22:08:10.26789
172	Katherine María	Pérez Amaya	pa20755@example.com	AQAAAAIAAYagAAAAEDFXJ9bQCVumnsjcP7gX0c4Bh08RXvmdgWbhE+1HwPCabF8wooHU4IcA/FBDRlE15g==	t	2025-10-14 21:45:48.233041
174	Mario Ricardo	Rivera Amaya	ra20592@example.com	AQAAAAIAAYagAAAAEF5txDSPPn2+ZNVrMopNrayWGPT77y1uzcLdauDiWb1ArTN26kf8siRtHONc0m5ZyQ==	t	2025-06-23 20:18:34.828552
176	Claudia María	González Villalobos	gv20295@example.com	AQAAAAIAAYagAAAAECVoCnEaGIO0905hvOTmHkiJWbZLk/oMY6LGS19pT1bV/ea2KqO/CIb4i62FpYdCXg==	t	2025-10-26 06:05:56.803444
178	Julio David	Sorto García	sg20974@example.com	AQAAAAIAAYagAAAAEAr3yDHg3D8eGuNluSXOMCrGhSLB4seUElSjrHKu+jlyLzpX8vj/BMqn0xZ7p2S3Jw==	t	2025-05-16 21:09:25.869552
180	Rebeca Daniela	Majano Fuentes	mf20016@example.com	AQAAAAIAAYagAAAAENj0suGw2Q5nhWozG7kwEOysfc9rY+8cl0LvO6Unrb9CXl2T9xz6UFdcDC5Nc4+rCA==	t	2025-06-06 06:35:37.880731
182	Beatriz Ana	Rivera Guevara	rg20900@example.com	AQAAAAIAAYagAAAAEM/Tia2VlYFuaubuVrYWpRPVYZAW194PVqeK2+gO1MKTqjKBoAnACygLwhQ8+PwmfA==	t	2025-08-20 11:33:05.093157
184	Rocío Claudia	Ventura Pérez	vp20991@example.com	AQAAAAIAAYagAAAAEPTR/zrURN1UpLYvwmEqdlUvFTazO2wCiT6rytJzisRenftIrh+196AMSfaUFX4i+g==	t	2025-08-15 14:41:07.731759
186	Julio Ricardo	Granados Umaña	gu20998@example.com	AQAAAAIAAYagAAAAELHBA9xfim5+V94DcE45HL0fKgmQeEjqBx+xIkniZFI+QUlEntVtOtzdcGFVPjkq1w==	t	2025-09-01 09:24:52.354145
188	Óscar Juan	Orellana García	og20153@example.com	AQAAAAIAAYagAAAAEBo1F3/3rdyyrYX/eeL8oUF7rAIAFLfjQZGr7wOP4EXh6o7ke6QHhhWzD1etH4JTnA==	t	2025-07-10 21:12:16.208369
190	Fernando Andrés	Bonilla Rodríguez	br20924@example.com	AQAAAAIAAYagAAAAEPHXiDD4wJhJv2sJHAzyW7JEtparWqgPlLtw7QcukVHa/a3IE8TdlLdBbyYHtD3J8A==	t	2025-03-13 03:42:44.641749
192	Carlos Rafael	Reyes Hernández	rh20059@example.com	AQAAAAIAAYagAAAAENwHgWhZesBCqs0go5VNQYeu0MyqU0ko/offF8e3AKnsM+4ooV3K/I+lZEGqN6xBTw==	t	2025-04-16 16:03:27.280352
194	Daniela Wendy	Quintanilla Zelaya	qz20320@example.com	AQAAAAIAAYagAAAAEGVuhFbXuLmU+DAKjShTfVC8tNFFbtQvTpvDTpw2UNlb8dwFjfOhyAxLERuCnTyPPw==	t	2025-02-23 12:02:37.59221
196	Sofía Lucía	Umaña Hernández	uh20032@example.com	AQAAAAIAAYagAAAAEHiQyqYGL13zprI2SA8zt1z4uQzOcJ1j5PLZNFWeaJfeZJKlDqueYvbXOcRqAVTWqQ==	t	2025-10-17 02:31:51.789741
198	Josué Rafael	Pérez Mejía	pm21840@example.com	AQAAAAIAAYagAAAAEI7D35lwKBoWqU8zzyCp8R+qfHvh/Kg1nRJacqLAr1Zwdt879RbryEAkxL6QIYgFcA==	t	2026-11-11 13:02:08.036359
200	Ricardo José	Argueta Díaz	ad21705@example.com	AQAAAAIAAYagAAAAECwrzqZvkd4bhPu7UF+8ns8vHoGqkN9njo2o3E4SCxJLRXDK8pJEwkbzgnTMKpHwjg==	t	2026-11-12 19:00:41.281019
202	Karla María	González Ayala	ga21807@example.com	AQAAAAIAAYagAAAAEAK2fxfNI13UhvAhwL4BPNvJ2ceph92V3YG3vKjseIwnzC3nEVXX5IoSv7igarmeyg==	t	2026-11-11 23:00:38.235065
204	Andrea Alejandra	Quintanilla Orellana	qo21991@example.com	AQAAAAIAAYagAAAAEB7R5OIla+yP+BheAiHf2IEa1zkhYaVwwpdEWny5f5Um0KBrcG9+RwKHUoK6l1qHjw==	t	2026-05-19 11:07:11.578109
206	Ana María	Pérez Chávez	pc21760@example.com	AQAAAAIAAYagAAAAED3TzX2m1rufw6tjuTqTro5QbTWGNCt529jTmR2esTtVdbWIoPCgUtnRSVWwVBcIbg==	t	2026-03-29 00:07:26.605777
208	Jennifer Carolina	Lazo Chávez	lc21327@example.com	AQAAAAIAAYagAAAAEMO06Bzu6pCmG+WYMwyP+1pIkAhOV6rnrc/9Zr1LLBhyNsbYZ4ZGSJI9Z6edtVAwOw==	t	2026-11-10 03:05:07.010721
210	Francisco Mario	Zelaya González	zg21149@example.com	AQAAAAIAAYagAAAAEDkr17Sqh2OQ1Gz6FYDgaScjRjPH/3j2UDu29/i+wSQGUBM653W7PJ2zPThYp0bjMQ==	t	2026-11-11 00:46:50.316049
212	Julio José	López Romero	lr21793@example.com	AQAAAAIAAYagAAAAEFRAujYCmjnxz9bUXlAm15q0dT850EIInuEA5MaoXlETQHKY4Q3NRL4wiwBX5GU+sA==	t	2026-11-12 15:50:37.273565
214	Walter Alexander	Orellana Cruz	oc21356@example.com	AQAAAAIAAYagAAAAEPc80MOgNkyg/10oGigjwxo9ad07sIEXiAlNzJ3kW5IPTed5b0h7s0oubEVNIM/GbA==	t	2026-09-13 16:47:01.541647
216	José Jorge	Flores Romero	fr21789@example.com	AQAAAAIAAYagAAAAEGGl7TWvvtfrARR5JYNuwteM+kGeS3NApYER73tci5ZWz5tGqbdWlL42OcXtgFNFLg==	t	2026-11-13 02:47:28.346744
218	Lucía Rebeca	Bonilla Cruz	bc21511@example.com	AQAAAAIAAYagAAAAEPMu1MI0aQGuz4Sb+QjSIY4V7a8W0gR+Zmspuo5EjyjzCp2lltpjTTPHViZ53u07Cw==	t	2026-10-02 19:10:02.334941
220	Daniel José	Orellana Ayala	oa21134@example.com	AQAAAAIAAYagAAAAECxBAksEgE6rWU6S5DCHN3ndZDESPbjR0CVGo5PHS8mP+wpRAzyzxFUOJhyrvno7rQ==	t	2026-10-16 01:37:06.289426
135	Henry Francisco	Rodríguez López	rl18443@example.com	AQAAAAIAAYagAAAAEBdLPRiDLxACVRDOvjZDAadQUb7zCc/isr6AMtMqIXtMpK9p5hH1oSnED//phaIA+Q==	t	2023-06-21 05:49:13.535732
137	Tatiana Katherine	Ramírez Benítez	rb19468@example.com	AQAAAAIAAYagAAAAEAJ1QGmLgwzHS4u60N4/5TF9CJNN12b7H4IOulZkP5vm5/m2ZH1xYMEuZBMQc8X4LQ==	t	2024-05-04 10:54:58.29451
139	Fátima Katherine	Reyes Torres	rt19010@example.com	AQAAAAIAAYagAAAAEBnkZxlzoAfaC2Q9Wx2hRZTKPfC8DW8pxGJoptIbvxQKVp2sbEgK5t06PUmEV8d6AQ==	t	2024-08-10 04:41:40.19961
141	Emerson Fernando	Rodríguez Reyes	rr19645@example.com	AQAAAAIAAYagAAAAEC4VS8f4pVoQnkcfUfjhbPZCtEg6o85+9WHJ1urfj3R3U2yGRSYbYnwWx4PD7TpwHA==	t	2024-11-07 04:25:28.736063
143	Diego Fernando	Torres Benítez	tb19914@example.com	AQAAAAIAAYagAAAAELWK7Ftdiw/9HD5CGcBz+ezd6jBrJlQWgNFpXqGJKopWhoMZPRepwXB3xwxaco73og==	t	2024-08-26 15:18:58.946538
145	Kevin Wilfredo	Hernández Orellana	ho19815@example.com	AQAAAAIAAYagAAAAEEoRwENNgcfbJ1xmmOhJJBTLpf2oVO3xcW5LNs8qgy31WE7AbDpLDtREgq73To111w==	t	2024-09-17 04:27:47.308895
147	Walter Julio	Pérez Reyes	pr19010@example.com	AQAAAAIAAYagAAAAEAJwhsTP0z8eMnKWFw265A49mron6+IjRjTE0mQyGbXYsSlswLV60RfxCQnksJ9WUg==	t	2024-09-20 08:18:37.815957
149	Carlos Josué	Ramírez Quintanilla	rq19907@example.com	AQAAAAIAAYagAAAAEERHNOzHS/osoQRlpl63Zstd/Z0Gs+Oc14nCNlNd3AjI6HvgqIOz9+FZHoXCd2Nj5A==	t	2024-09-15 02:59:37.80986
151	Ricardo Josué	López Sorto	ls19015@example.com	AQAAAAIAAYagAAAAEExcDcp1aBIolVwBadHE212DyaW42lPclXEGmoUH9NcmnzfyCw+H+ZS5fNAtLtxF1Q==	t	2024-10-19 06:04:14.960206
153	Óscar David	Benítez Majano	bm19927@example.com	AQAAAAIAAYagAAAAECCtQ4Kzavc0siCMxjF4eRFKW6ZZhWdUwklY673DhLxOcCpaTdvF0x9tuuN2lPnTpQ==	t	2024-09-11 11:37:41.500765
155	Beatriz Wendy	Martínez Argueta	ma19004@example.com	AQAAAAIAAYagAAAAEDgyCIPZfd+Lgl+wtEQ/gIZddtYOihAzBvFaR5VyE2n+dZ1GMMrBtKVDBzSdwEg0TQ==	t	2024-06-04 16:37:11.644369
157	Kevin Josué	Flores Hernández	fh19857@example.com	AQAAAAIAAYagAAAAEK//xj+Q4ewoqG/vu8zAro3cnmq3/UYtaBglJv//46gOWS/aXF5CzK0IJDSykJFhCQ==	t	2024-04-12 06:05:20.151789
159	María Rocío	Chávez Flores	cf19160@example.com	AQAAAAIAAYagAAAAEObaadBECDoPi7Njc65xwXXXVHZklV6vYYZSOw1OEDAkhAR3Z/9CLkXZAiNRcBJaQA==	t	2024-07-29 10:18:09.771789
161	Wilfredo Andrés	García Zelaya	gz19144@example.com	AQAAAAIAAYagAAAAEFyOnJlrV99hKiugtcUBGxYahdWIjsXOy7vPbdYjffW/i+I/MlOtG0D7J6k7pFCW6w==	t	2024-04-02 05:00:49.209083
163	Gerson Ricardo	Mejía Chávez	mc19551@example.com	AQAAAAIAAYagAAAAEB+qvnfjJy5AN6CqQtpoTuqG6JtxCY2Zx7v9G6w+9mS1frMrP4IGN5jJB+wF9IC8FA==	t	2024-11-03 21:40:41.057974
165	Mario David	López González	lg19275@example.com	AQAAAAIAAYagAAAAEN3UczYbVbmr3hBR6h9AtgpN3s4q7BFnp68bi1LjBRVMsuhpcX0Q4FaRi5HbMnGmcQ==	t	2024-06-25 21:42:10.257551
167	Juan Rodrigo	Alvarenga Pérez	ap20722@example.com	AQAAAAIAAYagAAAAEMg+9/Y0UzskRfPTgxXrtoLfXzxtPJNRLOlPGQGR48m/DGMZymwZOWaDb4q3DE5VGg==	t	2025-05-21 22:16:18.266998
169	Claudia Silvia	García Torres	gt20939@example.com	AQAAAAIAAYagAAAAEAbdNE8fmUdDWwMxn13P265Flbvs4KNVaS1II5Pd0C/EW5jAhERo6U+9ZWc2Z6NGtA==	t	2025-09-03 20:12:30.273366
171	María Sofía	García González	gg20568@example.com	AQAAAAIAAYagAAAAEBVZN0uK1pgjdQ448i0d7vSWRAgQ5SPVT3ZIzbF1a1yA3sQd064N7gic+cihZOeN9Q==	t	2025-01-27 09:59:10.24998
173	Fátima Rebeca	Amaya Cruz	ac20835@example.com	AQAAAAIAAYagAAAAENPGepcWcONf9js4vwnELSNNh9E+5jV1dYdhJ/0GeCizaUlEoRhODwiFYLd8PfdMiA==	t	2025-07-10 11:33:45.876298
175	Fernando Bryan	Amaya Torres	at20837@example.com	AQAAAAIAAYagAAAAELOVXjtnMZmYAtJpU2VrYHQ4EhgEOV/BWAGhVOsEhucAMemZcX6B9I1KNqceENPyVA==	t	2025-04-04 00:31:59.864704
177	Francisco Miguel	Chávez Quintanilla	cq20148@example.com	AQAAAAIAAYagAAAAEPfmFSXdWyMdFi3dADDyS+p+4ra50UatlRtC49S6uElwPfQZzUHlXejJv1oDhbLZFw==	t	2025-11-05 18:29:33.860697
179	Andrea Elena	Ventura García	vg20895@example.com	AQAAAAIAAYagAAAAEKt6ihcIYUHbdOZocWsn1EdEJVQwM7P3o+WvsXPfjWIWUXHTDLfsEId4PNw2gUz5qw==	t	2025-03-24 21:30:55.918236
181	Edwin Bryan	Lazo Portillo	lp20983@example.com	AQAAAAIAAYagAAAAEBvyQhtu4CY0sKg9Hse6OcNbMOE8X2kTRVdTQ13NWtOqLzkoPRMWozBH2oE4MRIshw==	t	2025-05-24 06:15:12.965051
183	Carlos Rafael	Ventura Alvarenga	va20837@example.com	AQAAAAIAAYagAAAAECU/aIf/OliC1WsG+ACCvp3ejEgzR6NC2RrfKkT8PqyuxRHJKtRk0nWEUCTsFra0sQ==	t	2025-05-30 15:31:29.209648
185	Henry Ricardo	López Rodríguez	lr20306@example.com	AQAAAAIAAYagAAAAEDZouOFP8VGNAAGH1OsFlu2MNYy0uHoa5xogcWp6wdQ96DRxEjcNzqoO6w54VWB16g==	t	2025-07-09 03:28:03.378001
187	Karla Rocío	Amaya Lazo	al20515@example.com	AQAAAAIAAYagAAAAEOTf5pgzIUVIL8rkqNGiGpfLyEE/kWClZLeszaMzhMLMaaHPSK1Kj9GsdufUgDGeOg==	t	2025-03-27 19:52:49.26146
189	Katherine Carolina	Guevara Orellana	go20908@example.com	AQAAAAIAAYagAAAAEE19sejopZQisPOyF20y0tDba7dkLTJ0tjdRbRqhxOzoi/BBGqkRJM6+fu80ZoEf9g==	t	2025-03-23 03:10:30.323196
191	Gloria Valeria	Villalobos Zelaya	vz20872@example.com	AQAAAAIAAYagAAAAEFD6LqlTWfNWqMyze3DiOGrt9oLAQaMys1H1A3u9yUvRyQoe+vI3sm5jlqgZchSozQ==	t	2025-06-09 03:31:49.649231
193	Gerson Diego	Saravia Cruz	sc20205@example.com	AQAAAAIAAYagAAAAEMd3ZQTcmTqkZRyqMj+Lg019P1JB4S6Vrrsa94gvui6ynD1Q31UKUFVrltGO9+eWRA==	t	2025-07-25 05:05:21.942469
195	Mario Rodrigo	Ayala Cruz	ac20143@example.com	AQAAAAIAAYagAAAAEH7Cz+U1/sR0AWNqIur5D6ipIUOz/yZwu+0FyVt6nfdD8phi6vnI8t3iRYXy5HCrnQ==	t	2025-09-05 12:08:13.864117
197	Daniel Wilfredo	Díaz Chávez	dc21780@example.com	AQAAAAIAAYagAAAAEDVoO3nE38WGqLnVyszyBNxq6/VUmLiFFBGSzO707UgcOf3Lu4AwBs6iSOWV/XW8Aw==	t	2026-11-13 03:43:56.724639
199	Valeria Paola	Pérez Guevara	pg21035@example.com	AQAAAAIAAYagAAAAEJHdi6WVsKfhzJ2E1Juwv7aGS10t7jMb3jBmJmw+2o4PKk2700Hgzr8FMb8QCt65mg==	t	2026-11-10 23:01:37.645657
201	Yesenia Fátima	Sorto Guevara	sg21396@example.com	AQAAAAIAAYagAAAAEPFYhlYtLzVlO+Xaq2a1zhGdNfRM4tluTGNhywrDf55j9i+d/bTTKliZEU44qaY94A==	t	2026-05-27 00:40:47.60319
203	Daniela Katherine	Argueta Torres	at21659@example.com	AQAAAAIAAYagAAAAEC9x5DLIMM42eMr3g0VtIfvyccrCmwHKad/x1Ci3eOTVqZGANgGr9X5jsfOWstpPJA==	t	2026-11-11 20:16:02.918121
205	Wendy Patricia	Flores Villalobos	fv21332@example.com	AQAAAAIAAYagAAAAEJeKnhgERVoA4Jjb2Vc4qDVXBYGuWv+neC2levoEwv6Zb8O2tTEZYYG8HQhdFWfgNA==	t	2026-11-13 07:32:56.249189
207	María Ana	Pérez Sánchez	ps21634@example.com	AQAAAAIAAYagAAAAECiz/4NGa2qL/p8IWBTtjz39O5QXgARahr5k5m24jgQEm2yJFxFYCAVGG7g8xB1IvA==	t	2026-07-08 04:48:04.255202
209	Mónica Karla	Ventura Rivera	vr21891@example.com	AQAAAAIAAYagAAAAEDkpb2USJnqLbKDvkdDTLYShp5zfOLyP6w5eKSbAsmMBVdZ5X4cmlzwGO6gw+8dZ0A==	t	2026-11-12 09:16:34.998017
211	Wilfredo Carlos	Sorto Cruz	sc21871@example.com	AQAAAAIAAYagAAAAEPy1ktjlIF6hv8aVH3+TBgLgZR79jJ19o/g1G3TBBrQd0eDyI9Jk08AuqJWz39VOvg==	t	2026-11-11 20:54:15.936625
213	Sofía Carolina	Ramírez Romero	rr21894@example.com	AQAAAAIAAYagAAAAEOteRSoiuolpULTnqaQ6pS0kSDSgOgckvxwmZGQl5Cz/p4fBkVfeobMVC5YDi8ERQw==	t	2026-11-09 07:55:16.581762
215	David Jorge	Martínez Bonilla	mb21649@example.com	AQAAAAIAAYagAAAAEKt7DO2WOU+aXanKIzErJ8hu0D4Sv91aQWn5sSeoNUc2WAeNi7kP5uffZ3k82z7r7A==	t	2026-11-12 04:31:55.760165
217	Juan Mario	Díaz Portillo	dp21411@example.com	AQAAAAIAAYagAAAAEHpoqN2909oHx4LnxTPO0ahlxV9FVTNyg29gKVtxNDgNTAgksuBXMNFJfDyiX7uwkQ==	t	2026-06-17 16:43:15.669105
219	Ana Rocío	Amaya Ayala	aa21974@example.com	AQAAAAIAAYagAAAAEGGMrMrE59um8s5uuhZ2+4JMOON0k4o+MUzbp91MmnVxgBP5pqT0hV3paEMq9nbnew==	t	2026-04-19 11:40:15.334293
21	Carlos Ernesto	Ventura Lazo	carlos.ventura@example.com	AQAAAAIAAYagAAAAEHOLXPACJyHDgL5TJiM8HgxCiL9JvP44NhPp9W54heicmhUZ8oyENjgM87Hg5a9ZNg==	t	2018-08-06 15:00:00
22	María Elena	Sorto Amaya	maria.sorto@example.com	AQAAAAIAAYagAAAAEI9kZXGN2r6jyIaetfiSPtYh0Rfb5QdqcDekl7PAHefD9THX2todkd0lndsRZxIRdQ==	t	2018-08-06 15:00:00
23	José Luis	Argueta Fuentes	jose.argueta@example.com	AQAAAAIAAYagAAAAELvfRJCNzhGafb+uq4hLY381MQXpLPNSNqrcTcN86zvfm0ci5kZRR4MY5QC1lXHb+w==	t	2018-08-06 15:00:00
24	Edwin Óscar	Rivera Reyes	edwin.rivera.doc17@example.com	AQAAAAIAAYagAAAAENu4u6nIBEYsnWSidncFXj0ZYVEUMHzsrK86PrzYF0WKTvo961j6Ncah6GHmM1sriw==	t	2018-08-06 15:00:00
25	Alejandra Rebeca	Sánchez García	alejandra.sanchez.doc18@example.com	AQAAAAIAAYagAAAAELMdhSGP1z9CxuGXgV/+L9CFEUse3lYIoJRyK+qA87fq4KH/0xFzsgOAc3/bBBu8cw==	t	2018-08-06 15:00:00
26	Emerson Francisco	Romero Lazo	emerson.romero.doc19@example.com	AQAAAAIAAYagAAAAEBlr7v+yP8Zlo+VPjrOMk28MQYzbN5tWgQCUH31ytiq2fJNVG4wte77Vk1QUX758Cw==	t	2018-08-06 15:00:00
27	Luis Josué	García Argueta	luis.garcia.doc20@example.com	AQAAAAIAAYagAAAAENUFogAI9JusEEi8jRBY8ky16TU/0Ar5u/9BEsy9db3PEAyuwtKUjJJkWjDUoj2/1w==	t	2018-08-06 15:00:00
28	Elena Mónica	López Ventura	elena.lopez.doc21@example.com	AQAAAAIAAYagAAAAECSp7UhHXr34KycUTwfubpDfoW6IrAVMG2ZHty0hYK1Q1HA/ViRvpuEje4zyEdLjpQ==	t	2018-08-06 15:00:00
29	Lucía Mónica	Canales Guevara	lucia.canales.doc22@example.com	AQAAAAIAAYagAAAAEJ7X8NfTQRkI/71/qBajUlN1WpXmeEMhTBIeyCQXT5pVzHeba8LFW9lOGacihFpT8w==	t	2018-08-06 15:00:00
30	Gerson Fernando	Sánchez Cruz	gerson.sanchez.doc23@example.com	AQAAAAIAAYagAAAAEOq20rhVVKIJhDzIZPki1IwVs1eX1S2gZ0Si0S9YJYyuC3bVax21Kc6hC4X3AKsezA==	t	2018-08-06 15:00:00
31	Karla Mónica	Orellana Quintanilla	karla.orellana.doc24@example.com	AQAAAAIAAYagAAAAEOyVMtPYIwJWwOEDI3RP0uMqshnzQXU8oHuu9fasOjN8wjRPs3smsgdgwQA2TBgttg==	t	2018-08-06 15:00:00
32	Alejandra Gloria	Chávez Villalobos	alejandra.chavez.doc25@example.com	AQAAAAIAAYagAAAAELgMh9eTqCeNPdx65iOi4AbZVFqxYjY16Aj6ZSuNSRTSEa0UBhe0CaZhUdF5TVwEWQ==	t	2018-08-06 15:00:00
33	Ricardo Julio	Zelaya Sánchez	ricardo.zelaya.doc26@example.com	AQAAAAIAAYagAAAAEMB2icpCHDu776myLcjoStA4EhrrHx78q4peuJi1BiSuD8imp1MBdRRQkCy0/xxRBg==	t	2018-08-06 15:00:00
34	Rebeca Sofía	Fuentes Torres	rebeca.fuentes.doc27@example.com	AQAAAAIAAYagAAAAECzt6JFkEnP29+FvouroD51w4b8iMEipfVzyp/cBRAyoCGYsDpqdcclZe9tz0+17AQ==	t	2018-08-06 15:00:00
35	Kevin Julio	Pérez Ayala	kevin.perez.doc28@example.com	AQAAAAIAAYagAAAAEAPOzDh9cKcJ4PI9byf70ObYhRe3BArh68cUm1PGBy9Fq2pCW4nt74dpXe0TcQ0U8A==	t	2018-08-06 15:00:00
36	Claudia María	Quintanilla Majano	claudia.quintanilla.doc29@example.com	AQAAAAIAAYagAAAAEE52Mnw6tmWNu29bEJcZH2DAMC62wbb//rFESOOZk2VAJn7G0oNYUz9u0jDqTmnhfQ==	t	2018-08-06 15:00:00
37	Daniel Óscar	Ayala Romero	daniel.ayala.doc30@example.com	AQAAAAIAAYagAAAAEOUS4RWiQLlJ1Uteqfa4kJgk1PCufy/LQfB3mAwYAlG08Dbkxy/rDBd/ttwSpHyoNg==	t	2018-08-06 15:00:00
38	Andrés Miguel	Fuentes Canales	andres.fuentes.doc31@example.com	AQAAAAIAAYagAAAAECnrmaXoyUBm07/rtwytxLkZyQcpg83YniFpM5UmgWlLGh3IZQkqw4hrRCtMcQEGtw==	t	2018-08-06 15:00:00
39	Bryan Fernando	Fuentes Zelaya	bryan.fuentes.doc32@example.com	AQAAAAIAAYagAAAAEI3vmskUxp1LYn30+an2byuHigFgjcOx9qjxjDxtyOrBuTTzBb59KG+rAQUo/9z3aQ==	t	2018-08-06 15:00:00
40	Yesenia Silvia	Ayala Granados	yesenia.ayala.doc33@example.com	AQAAAAIAAYagAAAAECUAUOLPTeY+V+5Y++gmGcqEaL9UeY09/Wvvec62GnzHVxVIrC7lDUkxqZw63rvO4A==	t	2018-08-06 15:00:00
41	Daniel Henry	Mejía Ventura	daniel.mejia.doc34@example.com	AQAAAAIAAYagAAAAECSSyQyNPAuH8lnkMRcGVuEqdsHDPcCvbwd99PddbOUzZzr5cQE9hmY1YxOn4YAZyw==	t	2018-08-06 15:00:00
42	Rocío Katherine	Díaz Guevara	rocio.diaz.doc35@example.com	AQAAAAIAAYagAAAAEG3CdihnEMPOFs+IWTRoB+xKnnyyMUMrCgrYKg8UcLYQQu8zFWIO8qTnCnvrAsYz1w==	t	2018-08-06 15:00:00
43	Marisol Wendy	Martínez Alvarenga	marisol.martinez.doc36@example.com	AQAAAAIAAYagAAAAEMkjNZg1w6PMhvjIt1fTlDWCxqabVJcTtUPbHFXRTDhJw2jwCMfhF858XtofMnJqVA==	t	2018-08-06 15:00:00
44	Mario Fernando	Amaya Flores	mario.amaya.doc37@example.com	AQAAAAIAAYagAAAAEKWPHuvv31sVLXJ7vYeYmCybf8gtCu3MkkLCv3SEKmKm10nHXXxJEqyJgyXjiT1Krw==	t	2018-08-06 15:00:00
1	Administrador	de Prueba	admin@example.com	AQAAAAIAAYagAAAAEHOLXPACJyHDgL5TJiM8HgxCiL9JvP44NhPp9W54heicmhUZ8oyENjgM87Hg5a9ZNg==	t	2026-11-20 19:51:10.80074
2	Supervisora	de Prueba	supervisora@example.com	AQAAAAIAAYagAAAAEHOLXPACJyHDgL5TJiM8HgxCiL9JvP44NhPp9W54heicmhUZ8oyENjgM87Hg5a9ZNg==	t	2026-11-21 21:24:37.307622
3	Segundo Supervisor	de Prueba	supervisor2@example.com	AQAAAAIAAYagAAAAEHOLXPACJyHDgL5TJiM8HgxCiL9JvP44NhPp9W54heicmhUZ8oyENjgM87Hg5a9ZNg==	t	2026-11-21 21:32:04.391885
20	Estudiante	de Prueba	estudiante@example.com	AQAAAAIAAYagAAAAEHOLXPACJyHDgL5TJiM8HgxCiL9JvP44NhPp9W54heicmhUZ8oyENjgM87Hg5a9ZNg==	t	2026-11-21 22:02:41.900431
\.


--
-- Data for Name: tbl_usuario_rol; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tbl_usuario_rol (id_usuario, id_rol) FROM stdin;
1	3
1	1
2	3
2	2
3	3
3	2
4	3
5	3
6	3
7	3
8	3
9	3
10	3
11	3
12	3
13	3
14	3
15	3
16	3
17	3
18	3
19	3
20	3
21	3
21	2
22	3
22	2
23	3
23	2
24	3
25	3
26	3
27	3
28	3
29	3
30	3
31	3
32	3
33	3
34	3
35	3
36	3
37	3
38	3
39	3
40	3
41	3
42	3
43	3
44	3
45	3
46	3
47	3
48	3
49	3
50	3
51	3
52	3
53	3
54	3
55	3
56	3
57	3
58	3
59	3
60	3
61	3
62	3
63	3
64	3
65	3
66	3
67	3
68	3
69	3
70	3
71	3
72	3
73	3
74	3
75	3
76	3
77	3
78	3
79	3
80	3
81	3
82	3
83	3
84	3
85	3
86	3
87	3
88	3
89	3
90	3
91	3
92	3
93	3
94	3
95	3
96	3
97	3
98	3
99	3
100	3
101	3
102	3
103	3
104	3
105	3
106	3
107	3
108	3
109	3
110	3
111	3
112	3
113	3
114	3
115	3
116	3
117	3
118	3
119	3
120	3
121	3
122	3
123	3
124	3
125	3
126	3
127	3
128	3
129	3
130	3
131	3
132	3
133	3
134	3
135	3
136	3
137	3
138	3
139	3
140	3
141	3
142	3
143	3
144	3
145	3
146	3
147	3
148	3
149	3
150	3
151	3
152	3
153	3
154	3
155	3
156	3
157	3
158	3
159	3
160	3
161	3
162	3
163	3
164	3
165	3
166	3
167	3
168	3
169	3
170	3
171	3
172	3
173	3
174	3
175	3
176	3
177	3
178	3
179	3
180	3
181	3
182	3
183	3
184	3
185	3
186	3
187	3
188	3
189	3
190	3
191	3
192	3
193	3
194	3
195	3
196	3
197	3
199	3
201	3
203	3
205	3
207	3
209	3
211	3
213	3
215	3
217	3
219	3
198	3
200	3
202	3
204	3
206	3
208	3
210	3
212	3
214	3
216	3
218	3
220	3
221	3
222	3
223	3
224	3
225	3
226	3
227	3
228	3
229	3
230	3
231	3
232	3
233	3
234	3
235	3
236	3
237	3
238	3
239	3
240	3
241	3
242	3
243	3
244	3
245	3
246	3
247	3
248	3
249	3
250	3
251	3
252	3
253	3
254	3
255	3
256	3
257	3
258	3
259	3
260	3
261	3
262	3
263	3
264	3
265	3
266	3
267	3
268	3
269	3
270	3
271	3
272	3
273	3
274	3
275	3
276	3
277	3
278	3
279	3
280	3
281	3
282	3
283	3
284	3
285	3
286	3
287	3
288	3
289	3
290	3
291	3
292	3
293	3
294	3
295	3
296	3
297	3
298	3
299	3
300	3
301	3
302	3
303	3
304	3
305	3
\.


--
-- Name: tbl_autor_id_autor_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_autor_id_autor_seq', 662, true);


--
-- Name: tbl_carrera_id_carrera_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_carrera_id_carrera_seq', 33, true);


--
-- Name: tbl_departamento_id_departamento_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_departamento_id_departamento_seq', 8, true);


--
-- Name: tbl_docente_id_docente_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_docente_id_docente_seq', 40, true);


--
-- Name: tbl_entrega_id_entrega_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_entrega_id_entrega_seq', 379, true);


--
-- Name: tbl_etiquetas_id_etiqueta_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_etiquetas_id_etiqueta_seq', 715, true);


--
-- Name: tbl_historial_id_historial_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_historial_id_historial_seq', 780, true);


--
-- Name: tbl_materia_id_materia_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_materia_id_materia_seq', 2458, true);


--
-- Name: tbl_notificacion_id_notificacion_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_notificacion_id_notificacion_seq', 2265, true);


--
-- Name: tbl_proyecto_id_proyecto_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_proyecto_id_proyecto_seq', 304, true);


--
-- Name: tbl_recurso_id_recurso_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_recurso_id_recurso_seq', 412, true);


--
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_rol_id_rol_seq', 3, true);


--
-- Name: tbl_tematica_id_tematica_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_tematica_id_tematica_seq', 49, true);


--
-- Name: tbl_tipo_proyecto_id_tipo_proyecto_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_tipo_proyecto_id_tipo_proyecto_seq', 6, true);


--
-- Name: tbl_tipo_recurso_id_tipo_recurso_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_tipo_recurso_id_tipo_recurso_seq', 3, true);


--
-- Name: tbl_usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tbl_usuario_id_usuario_seq', 305, true);


--
-- Name: tbl_carrera_materia pk_carrera_materia; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_carrera_materia
    ADD CONSTRAINT pk_carrera_materia PRIMARY KEY (id_carrera, id_materia);


--
-- Name: tbl_favorito pk_favorito; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_favorito
    ADD CONSTRAINT pk_favorito PRIMARY KEY (id_usuario, id_proyecto);


--
-- Name: tbl_materia_docente pk_materia_docente; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_materia_docente
    ADD CONSTRAINT pk_materia_docente PRIMARY KEY (id_materia, id_docente);


--
-- Name: tbl_proyecto_autor pk_proyecto_autor; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto_autor
    ADD CONSTRAINT pk_proyecto_autor PRIMARY KEY (id_proyecto, id_autor);


--
-- Name: tbl_proyecto_docente pk_proyecto_docente; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto_docente
    ADD CONSTRAINT pk_proyecto_docente PRIMARY KEY (id_proyecto, id_docente);


--
-- Name: tbl_proyecto_etiqueta pk_proyecto_etiqueta; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto_etiqueta
    ADD CONSTRAINT pk_proyecto_etiqueta PRIMARY KEY (id_proyecto, id_etiqueta);


--
-- Name: tbl_usuario_rol pk_usuario_rol; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_usuario_rol
    ADD CONSTRAINT pk_usuario_rol PRIMARY KEY (id_usuario, id_rol);


--
-- Name: tbl_autor tbl_autor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_autor
    ADD CONSTRAINT tbl_autor_pkey PRIMARY KEY (id_autor);


--
-- Name: tbl_carrera tbl_carrera_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_carrera
    ADD CONSTRAINT tbl_carrera_pkey PRIMARY KEY (id_carrera);


--
-- Name: tbl_departamento tbl_departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_departamento
    ADD CONSTRAINT tbl_departamento_pkey PRIMARY KEY (id_departamento);


--
-- Name: tbl_docente tbl_docente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_docente
    ADD CONSTRAINT tbl_docente_pkey PRIMARY KEY (id_docente);


--
-- Name: tbl_entrega tbl_entrega_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_entrega
    ADD CONSTRAINT tbl_entrega_pkey PRIMARY KEY (id_entrega);


--
-- Name: tbl_etiquetas tbl_etiquetas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_etiquetas
    ADD CONSTRAINT tbl_etiquetas_pkey PRIMARY KEY (id_etiqueta);


--
-- Name: tbl_historial tbl_historial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_historial
    ADD CONSTRAINT tbl_historial_pkey PRIMARY KEY (id_historial);


--
-- Name: tbl_materia tbl_materia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_materia
    ADD CONSTRAINT tbl_materia_pkey PRIMARY KEY (id_materia);


--
-- Name: tbl_notificacion tbl_notificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_notificacion
    ADD CONSTRAINT tbl_notificacion_pkey PRIMARY KEY (id_notificacion);


--
-- Name: tbl_proyecto tbl_proyecto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto
    ADD CONSTRAINT tbl_proyecto_pkey PRIMARY KEY (id_proyecto);


--
-- Name: tbl_recurso tbl_recurso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_recurso
    ADD CONSTRAINT tbl_recurso_pkey PRIMARY KEY (id_recurso);


--
-- Name: tbl_rol tbl_rol_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_rol
    ADD CONSTRAINT tbl_rol_pkey PRIMARY KEY (id_rol);


--
-- Name: tbl_tematica tbl_tematica_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_tematica
    ADD CONSTRAINT tbl_tematica_pkey PRIMARY KEY (id_tematica);


--
-- Name: tbl_tipo_proyecto tbl_tipo_proyecto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_tipo_proyecto
    ADD CONSTRAINT tbl_tipo_proyecto_pkey PRIMARY KEY (id_tipo_proyecto);


--
-- Name: tbl_tipo_recurso tbl_tipo_recurso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_tipo_recurso
    ADD CONSTRAINT tbl_tipo_recurso_pkey PRIMARY KEY (id_tipo_recurso);


--
-- Name: tbl_usuario tbl_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_usuario
    ADD CONSTRAINT tbl_usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: tbl_autor uq_autor_carnet; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_autor
    ADD CONSTRAINT uq_autor_carnet UNIQUE (carnet);


--
-- Name: tbl_autor uq_autor_usuario; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_autor
    ADD CONSTRAINT uq_autor_usuario UNIQUE (id_usuario);


--
-- Name: tbl_carrera uq_carrera_codigo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_carrera
    ADD CONSTRAINT uq_carrera_codigo UNIQUE (codigo);


--
-- Name: tbl_docente uq_docente_codigo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_docente
    ADD CONSTRAINT uq_docente_codigo UNIQUE (codigo_docente);


--
-- Name: tbl_docente uq_docente_usuario; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_docente
    ADD CONSTRAINT uq_docente_usuario UNIQUE (id_usuario);


--
-- Name: tbl_etiquetas uq_etiqueta_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_etiquetas
    ADD CONSTRAINT uq_etiqueta_nombre UNIQUE (nombre);


--
-- Name: tbl_materia uq_materia_codigo_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_materia
    ADD CONSTRAINT uq_materia_codigo_nombre UNIQUE (codigo, nombre);


--
-- Name: tbl_proyecto_autor uq_proyecto_orden_autoria; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto_autor
    ADD CONSTRAINT uq_proyecto_orden_autoria UNIQUE (id_proyecto, orden_autoria);


--
-- Name: tbl_rol uq_rol_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_rol
    ADD CONSTRAINT uq_rol_nombre UNIQUE (nombre_rol);


--
-- Name: tbl_tematica uq_tematica_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_tematica
    ADD CONSTRAINT uq_tematica_nombre UNIQUE (nombre);


--
-- Name: tbl_tipo_proyecto uq_tipo_proyecto_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_tipo_proyecto
    ADD CONSTRAINT uq_tipo_proyecto_nombre UNIQUE (nombre);


--
-- Name: tbl_tipo_recurso uq_tipo_recurso_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_tipo_recurso
    ADD CONSTRAINT uq_tipo_recurso_nombre UNIQUE (nombre);


--
-- Name: tbl_usuario uq_usuario_correo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_usuario
    ADD CONSTRAINT uq_usuario_correo UNIQUE (correo);


--
-- Name: ix_carrera_materia_materia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_carrera_materia_materia ON public.tbl_carrera_materia USING btree (id_materia);


--
-- Name: ix_docente_departamento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_docente_departamento ON public.tbl_docente USING btree (id_departamento);


--
-- Name: ix_materia_docente_docente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_materia_docente_docente ON public.tbl_materia_docente USING btree (id_docente);


--
-- Name: tbl_autor fk_autor_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_autor
    ADD CONSTRAINT fk_autor_usuario FOREIGN KEY (id_usuario) REFERENCES public.tbl_usuario(id_usuario) ON DELETE RESTRICT;


--
-- Name: tbl_carrera fk_carrera_departamento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_carrera
    ADD CONSTRAINT fk_carrera_departamento FOREIGN KEY (id_departamento) REFERENCES public.tbl_departamento(id_departamento) ON DELETE RESTRICT;


--
-- Name: tbl_carrera_materia fk_carrera_materia_carrera; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_carrera_materia
    ADD CONSTRAINT fk_carrera_materia_carrera FOREIGN KEY (id_carrera) REFERENCES public.tbl_carrera(id_carrera) ON DELETE RESTRICT;


--
-- Name: tbl_carrera_materia fk_carrera_materia_materia; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_carrera_materia
    ADD CONSTRAINT fk_carrera_materia_materia FOREIGN KEY (id_materia) REFERENCES public.tbl_materia(id_materia) ON DELETE RESTRICT;


--
-- Name: tbl_docente fk_docente_departamento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_docente
    ADD CONSTRAINT fk_docente_departamento FOREIGN KEY (id_departamento) REFERENCES public.tbl_departamento(id_departamento) ON DELETE RESTRICT;


--
-- Name: tbl_docente fk_docente_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_docente
    ADD CONSTRAINT fk_docente_usuario FOREIGN KEY (id_usuario) REFERENCES public.tbl_usuario(id_usuario) ON DELETE RESTRICT;


--
-- Name: tbl_entrega fk_entrega_proyecto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_entrega
    ADD CONSTRAINT fk_entrega_proyecto FOREIGN KEY (id_proyecto) REFERENCES public.tbl_proyecto(id_proyecto) ON DELETE RESTRICT;


--
-- Name: tbl_entrega fk_entrega_usuario_envia; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_entrega
    ADD CONSTRAINT fk_entrega_usuario_envia FOREIGN KEY (id_usuario_envia) REFERENCES public.tbl_usuario(id_usuario) ON DELETE RESTRICT;


--
-- Name: tbl_entrega fk_entrega_usuario_revisa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_entrega
    ADD CONSTRAINT fk_entrega_usuario_revisa FOREIGN KEY (id_usuario_revisa) REFERENCES public.tbl_usuario(id_usuario) ON DELETE RESTRICT;


--
-- Name: tbl_favorito fk_favorito_proyecto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_favorito
    ADD CONSTRAINT fk_favorito_proyecto FOREIGN KEY (id_proyecto) REFERENCES public.tbl_proyecto(id_proyecto) ON DELETE RESTRICT;


--
-- Name: tbl_favorito fk_favorito_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_favorito
    ADD CONSTRAINT fk_favorito_usuario FOREIGN KEY (id_usuario) REFERENCES public.tbl_usuario(id_usuario) ON DELETE RESTRICT;


--
-- Name: tbl_historial fk_historial_proyecto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_historial
    ADD CONSTRAINT fk_historial_proyecto FOREIGN KEY (id_proyecto) REFERENCES public.tbl_proyecto(id_proyecto) ON DELETE RESTRICT;


--
-- Name: tbl_historial fk_historial_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_historial
    ADD CONSTRAINT fk_historial_usuario FOREIGN KEY (id_usuario) REFERENCES public.tbl_usuario(id_usuario) ON DELETE RESTRICT;


--
-- Name: tbl_materia_docente fk_materia_docente_docente; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_materia_docente
    ADD CONSTRAINT fk_materia_docente_docente FOREIGN KEY (id_docente) REFERENCES public.tbl_docente(id_docente) ON DELETE RESTRICT;


--
-- Name: tbl_materia_docente fk_materia_docente_materia; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_materia_docente
    ADD CONSTRAINT fk_materia_docente_materia FOREIGN KEY (id_materia) REFERENCES public.tbl_materia(id_materia) ON DELETE RESTRICT;


--
-- Name: tbl_notificacion fk_notificacion_destinatario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_notificacion
    ADD CONSTRAINT fk_notificacion_destinatario FOREIGN KEY (id_usuario_destino) REFERENCES public.tbl_usuario(id_usuario) ON DELETE RESTRICT;


--
-- Name: tbl_notificacion fk_notificacion_entrega; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_notificacion
    ADD CONSTRAINT fk_notificacion_entrega FOREIGN KEY (id_entrega) REFERENCES public.tbl_entrega(id_entrega) ON DELETE RESTRICT;


--
-- Name: tbl_proyecto_autor fk_proyecto_autor_autor; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto_autor
    ADD CONSTRAINT fk_proyecto_autor_autor FOREIGN KEY (id_autor) REFERENCES public.tbl_autor(id_autor) ON DELETE RESTRICT;


--
-- Name: tbl_proyecto_autor fk_proyecto_autor_proyecto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto_autor
    ADD CONSTRAINT fk_proyecto_autor_proyecto FOREIGN KEY (id_proyecto) REFERENCES public.tbl_proyecto(id_proyecto) ON DELETE RESTRICT;


--
-- Name: tbl_proyecto fk_proyecto_carrera; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto
    ADD CONSTRAINT fk_proyecto_carrera FOREIGN KEY (id_carrera) REFERENCES public.tbl_carrera(id_carrera) ON DELETE RESTRICT;


--
-- Name: tbl_proyecto fk_proyecto_carrera_materia; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto
    ADD CONSTRAINT fk_proyecto_carrera_materia FOREIGN KEY (id_carrera, id_materia) REFERENCES public.tbl_carrera_materia(id_carrera, id_materia) ON DELETE RESTRICT;


--
-- Name: tbl_proyecto_docente fk_proyecto_docente_docente; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto_docente
    ADD CONSTRAINT fk_proyecto_docente_docente FOREIGN KEY (id_docente) REFERENCES public.tbl_docente(id_docente) ON DELETE RESTRICT;


--
-- Name: tbl_proyecto_docente fk_proyecto_docente_proyecto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto_docente
    ADD CONSTRAINT fk_proyecto_docente_proyecto FOREIGN KEY (id_proyecto) REFERENCES public.tbl_proyecto(id_proyecto) ON DELETE RESTRICT;


--
-- Name: tbl_proyecto_etiqueta fk_proyecto_etiqueta_etiqueta; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto_etiqueta
    ADD CONSTRAINT fk_proyecto_etiqueta_etiqueta FOREIGN KEY (id_etiqueta) REFERENCES public.tbl_etiquetas(id_etiqueta) ON DELETE RESTRICT;


--
-- Name: tbl_proyecto_etiqueta fk_proyecto_etiqueta_proyecto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto_etiqueta
    ADD CONSTRAINT fk_proyecto_etiqueta_proyecto FOREIGN KEY (id_proyecto) REFERENCES public.tbl_proyecto(id_proyecto) ON DELETE RESTRICT;


--
-- Name: tbl_proyecto fk_proyecto_materia; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto
    ADD CONSTRAINT fk_proyecto_materia FOREIGN KEY (id_materia) REFERENCES public.tbl_materia(id_materia) ON DELETE RESTRICT;


--
-- Name: tbl_proyecto fk_proyecto_tematica; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto
    ADD CONSTRAINT fk_proyecto_tematica FOREIGN KEY (id_tematica) REFERENCES public.tbl_tematica(id_tematica) ON DELETE RESTRICT;


--
-- Name: tbl_proyecto fk_proyecto_tipo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_proyecto
    ADD CONSTRAINT fk_proyecto_tipo FOREIGN KEY (id_tipo_proyecto) REFERENCES public.tbl_tipo_proyecto(id_tipo_proyecto) ON DELETE RESTRICT;


--
-- Name: tbl_recurso fk_recurso_entrega; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_recurso
    ADD CONSTRAINT fk_recurso_entrega FOREIGN KEY (id_entrega) REFERENCES public.tbl_entrega(id_entrega) ON DELETE RESTRICT;


--
-- Name: tbl_recurso fk_recurso_tipo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_recurso
    ADD CONSTRAINT fk_recurso_tipo FOREIGN KEY (id_tipo_recurso) REFERENCES public.tbl_tipo_recurso(id_tipo_recurso) ON DELETE RESTRICT;


--
-- Name: tbl_usuario_rol fk_usuario_rol_rol; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_usuario_rol
    ADD CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (id_rol) REFERENCES public.tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- Name: tbl_usuario_rol fk_usuario_rol_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_usuario_rol
    ADD CONSTRAINT fk_usuario_rol_usuario FOREIGN KEY (id_usuario) REFERENCES public.tbl_usuario(id_usuario) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict b8HIBz6Wpw5Um5QvdyvgcUrxb9yfrOxuxBAwMnqLwjJX9bbtWnheamEdFiI2qsQ

