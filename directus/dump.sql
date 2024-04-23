--
-- PostgreSQL database dump
--

-- Dumped from database version 15.6
-- Dumped by pg_dump version 15.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
-- Name: directus_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_activity (
    id integer NOT NULL,
    action character varying(45) NOT NULL,
    "user" uuid,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ip character varying(50),
    user_agent character varying(255),
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    comment text,
    origin character varying(255)
);


ALTER TABLE public.directus_activity OWNER TO postgres;

--
-- Name: directus_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.directus_activity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.directus_activity_id_seq OWNER TO postgres;

--
-- Name: directus_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.directus_activity_id_seq OWNED BY public.directus_activity.id;


--
-- Name: directus_collections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_collections (
    collection character varying(64) NOT NULL,
    icon character varying(30),
    note text,
    display_template character varying(255),
    hidden boolean DEFAULT false NOT NULL,
    singleton boolean DEFAULT false NOT NULL,
    translations json,
    archive_field character varying(64),
    archive_app_filter boolean DEFAULT true NOT NULL,
    archive_value character varying(255),
    unarchive_value character varying(255),
    sort_field character varying(64),
    accountability character varying(255) DEFAULT 'all'::character varying,
    color character varying(255),
    item_duplication_fields json,
    sort integer,
    "group" character varying(64),
    collapse character varying(255) DEFAULT 'open'::character varying NOT NULL,
    preview_url character varying(255),
    versioning boolean DEFAULT false NOT NULL
);


ALTER TABLE public.directus_collections OWNER TO postgres;

--
-- Name: directus_dashboards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_dashboards (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(30) DEFAULT 'dashboard'::character varying NOT NULL,
    note text,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    color character varying(255)
);


ALTER TABLE public.directus_dashboards OWNER TO postgres;

--
-- Name: directus_extensions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_extensions (
    enabled boolean DEFAULT true NOT NULL,
    id uuid NOT NULL,
    folder character varying(255) NOT NULL,
    source character varying(255) NOT NULL,
    bundle uuid
);


ALTER TABLE public.directus_extensions OWNER TO postgres;

--
-- Name: directus_fields; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_fields (
    id integer NOT NULL,
    collection character varying(64) NOT NULL,
    field character varying(64) NOT NULL,
    special character varying(64),
    interface character varying(64),
    options json,
    display character varying(64),
    display_options json,
    readonly boolean DEFAULT false NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    sort integer,
    width character varying(30) DEFAULT 'full'::character varying,
    translations json,
    note text,
    conditions json,
    required boolean DEFAULT false,
    "group" character varying(64),
    validation json,
    validation_message text
);


ALTER TABLE public.directus_fields OWNER TO postgres;

--
-- Name: directus_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.directus_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.directus_fields_id_seq OWNER TO postgres;

--
-- Name: directus_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.directus_fields_id_seq OWNED BY public.directus_fields.id;


--
-- Name: directus_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_files (
    id uuid NOT NULL,
    storage character varying(255) NOT NULL,
    filename_disk character varying(255),
    filename_download character varying(255) NOT NULL,
    title character varying(255),
    type character varying(255),
    folder uuid,
    uploaded_by uuid,
    uploaded_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_by uuid,
    modified_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    charset character varying(50),
    filesize bigint,
    width integer,
    height integer,
    duration integer,
    embed character varying(200),
    description text,
    location text,
    tags text,
    metadata json,
    focal_point_x integer,
    focal_point_y integer
);


ALTER TABLE public.directus_files OWNER TO postgres;

--
-- Name: directus_flows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_flows (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(30),
    color character varying(255),
    description text,
    status character varying(255) DEFAULT 'active'::character varying NOT NULL,
    trigger character varying(255),
    accountability character varying(255) DEFAULT 'all'::character varying,
    options json,
    operation uuid,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid
);


ALTER TABLE public.directus_flows OWNER TO postgres;

--
-- Name: directus_folders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_folders (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    parent uuid
);


ALTER TABLE public.directus_folders OWNER TO postgres;

--
-- Name: directus_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_migrations (
    version character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.directus_migrations OWNER TO postgres;

--
-- Name: directus_notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_notifications (
    id integer NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(255) DEFAULT 'inbox'::character varying,
    recipient uuid NOT NULL,
    sender uuid,
    subject character varying(255) NOT NULL,
    message text,
    collection character varying(64),
    item character varying(255)
);


ALTER TABLE public.directus_notifications OWNER TO postgres;

--
-- Name: directus_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.directus_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.directus_notifications_id_seq OWNER TO postgres;

--
-- Name: directus_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.directus_notifications_id_seq OWNED BY public.directus_notifications.id;


--
-- Name: directus_operations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_operations (
    id uuid NOT NULL,
    name character varying(255),
    key character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    position_x integer NOT NULL,
    position_y integer NOT NULL,
    options json,
    resolve uuid,
    reject uuid,
    flow uuid NOT NULL,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid
);


ALTER TABLE public.directus_operations OWNER TO postgres;

--
-- Name: directus_panels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_panels (
    id uuid NOT NULL,
    dashboard uuid NOT NULL,
    name character varying(255),
    icon character varying(30) DEFAULT NULL::character varying,
    color character varying(10),
    show_header boolean DEFAULT false NOT NULL,
    note text,
    type character varying(255) NOT NULL,
    position_x integer NOT NULL,
    position_y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    options json,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid
);


ALTER TABLE public.directus_panels OWNER TO postgres;

--
-- Name: directus_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_permissions (
    id integer NOT NULL,
    role uuid,
    collection character varying(64) NOT NULL,
    action character varying(10) NOT NULL,
    permissions json,
    validation json,
    presets json,
    fields text
);


ALTER TABLE public.directus_permissions OWNER TO postgres;

--
-- Name: directus_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.directus_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.directus_permissions_id_seq OWNER TO postgres;

--
-- Name: directus_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.directus_permissions_id_seq OWNED BY public.directus_permissions.id;


--
-- Name: directus_presets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_presets (
    id integer NOT NULL,
    bookmark character varying(255),
    "user" uuid,
    role uuid,
    collection character varying(64),
    search character varying(100),
    layout character varying(100) DEFAULT 'tabular'::character varying,
    layout_query json,
    layout_options json,
    refresh_interval integer,
    filter json,
    icon character varying(30) DEFAULT 'bookmark'::character varying,
    color character varying(255)
);


ALTER TABLE public.directus_presets OWNER TO postgres;

--
-- Name: directus_presets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.directus_presets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.directus_presets_id_seq OWNER TO postgres;

--
-- Name: directus_presets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.directus_presets_id_seq OWNED BY public.directus_presets.id;


--
-- Name: directus_relations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_relations (
    id integer NOT NULL,
    many_collection character varying(64) NOT NULL,
    many_field character varying(64) NOT NULL,
    one_collection character varying(64),
    one_field character varying(64),
    one_collection_field character varying(64),
    one_allowed_collections text,
    junction_field character varying(64),
    sort_field character varying(64),
    one_deselect_action character varying(255) DEFAULT 'nullify'::character varying NOT NULL
);


ALTER TABLE public.directus_relations OWNER TO postgres;

--
-- Name: directus_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.directus_relations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.directus_relations_id_seq OWNER TO postgres;

--
-- Name: directus_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.directus_relations_id_seq OWNED BY public.directus_relations.id;


--
-- Name: directus_revisions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_revisions (
    id integer NOT NULL,
    activity integer NOT NULL,
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    data json,
    delta json,
    parent integer,
    version uuid
);


ALTER TABLE public.directus_revisions OWNER TO postgres;

--
-- Name: directus_revisions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.directus_revisions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.directus_revisions_id_seq OWNER TO postgres;

--
-- Name: directus_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.directus_revisions_id_seq OWNED BY public.directus_revisions.id;


--
-- Name: directus_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_roles (
    id uuid NOT NULL,
    name character varying(100) NOT NULL,
    icon character varying(30) DEFAULT 'supervised_user_circle'::character varying NOT NULL,
    description text,
    ip_access text,
    enforce_tfa boolean DEFAULT false NOT NULL,
    admin_access boolean DEFAULT false NOT NULL,
    app_access boolean DEFAULT true NOT NULL
);


ALTER TABLE public.directus_roles OWNER TO postgres;

--
-- Name: directus_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_sessions (
    token character varying(64) NOT NULL,
    "user" uuid,
    expires timestamp with time zone NOT NULL,
    ip character varying(255),
    user_agent character varying(255),
    share uuid,
    origin character varying(255)
);


ALTER TABLE public.directus_sessions OWNER TO postgres;

--
-- Name: directus_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_settings (
    id integer NOT NULL,
    project_name character varying(100) DEFAULT 'Directus'::character varying NOT NULL,
    project_url character varying(255),
    project_color character varying(255) DEFAULT '#6644FF'::character varying NOT NULL,
    project_logo uuid,
    public_foreground uuid,
    public_background uuid,
    public_note text,
    auth_login_attempts integer DEFAULT 25,
    auth_password_policy character varying(100),
    storage_asset_transform character varying(7) DEFAULT 'all'::character varying,
    storage_asset_presets json,
    custom_css text,
    storage_default_folder uuid,
    basemaps json,
    mapbox_key character varying(255),
    module_bar json,
    project_descriptor character varying(100),
    default_language character varying(255) DEFAULT 'en-US'::character varying NOT NULL,
    custom_aspect_ratios json,
    public_favicon uuid,
    default_appearance character varying(255) DEFAULT 'auto'::character varying NOT NULL,
    default_theme_light character varying(255),
    theme_light_overrides json,
    default_theme_dark character varying(255),
    theme_dark_overrides json
);


ALTER TABLE public.directus_settings OWNER TO postgres;

--
-- Name: directus_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.directus_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.directus_settings_id_seq OWNER TO postgres;

--
-- Name: directus_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.directus_settings_id_seq OWNED BY public.directus_settings.id;


--
-- Name: directus_shares; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_shares (
    id uuid NOT NULL,
    name character varying(255),
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    role uuid,
    password character varying(255),
    user_created uuid,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    times_used integer DEFAULT 0,
    max_uses integer
);


ALTER TABLE public.directus_shares OWNER TO postgres;

--
-- Name: directus_translations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_translations (
    id uuid NOT NULL,
    language character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.directus_translations OWNER TO postgres;

--
-- Name: directus_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_users (
    id uuid NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    email character varying(128),
    password character varying(255),
    location character varying(255),
    title character varying(50),
    description text,
    tags json,
    avatar uuid,
    language character varying(255) DEFAULT NULL::character varying,
    tfa_secret character varying(255),
    status character varying(16) DEFAULT 'active'::character varying NOT NULL,
    role uuid,
    token character varying(255),
    last_access timestamp with time zone,
    last_page character varying(255),
    provider character varying(128) DEFAULT 'default'::character varying NOT NULL,
    external_identifier character varying(255),
    auth_data json,
    email_notifications boolean DEFAULT true,
    appearance character varying(255),
    theme_dark character varying(255),
    theme_light character varying(255),
    theme_light_overrides json,
    theme_dark_overrides json
);


ALTER TABLE public.directus_users OWNER TO postgres;

--
-- Name: directus_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_versions (
    id uuid NOT NULL,
    key character varying(64) NOT NULL,
    name character varying(255),
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    hash character varying(255),
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    user_updated uuid
);


ALTER TABLE public.directus_versions OWNER TO postgres;

--
-- Name: directus_webhooks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.directus_webhooks (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    method character varying(10) DEFAULT 'POST'::character varying NOT NULL,
    url character varying(255) NOT NULL,
    status character varying(10) DEFAULT 'active'::character varying NOT NULL,
    data boolean DEFAULT true NOT NULL,
    actions character varying(100) NOT NULL,
    collections character varying(255) NOT NULL,
    headers json
);


ALTER TABLE public.directus_webhooks OWNER TO postgres;

--
-- Name: directus_webhooks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.directus_webhooks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.directus_webhooks_id_seq OWNER TO postgres;

--
-- Name: directus_webhooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.directus_webhooks_id_seq OWNED BY public.directus_webhooks.id;


--
-- Name: faq_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.faq_categories (
    id uuid NOT NULL,
    sort integer,
    user_created uuid,
    date_created timestamp with time zone,
    user_updated uuid,
    date_updated timestamp with time zone,
    icon uuid,
    published boolean DEFAULT false
);


ALTER TABLE public.faq_categories OWNER TO postgres;

--
-- Name: faq_categories_translations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.faq_categories_translations (
    id integer NOT NULL,
    faq_categories_id uuid,
    languages_code character varying(255),
    title character varying(255)
);


ALTER TABLE public.faq_categories_translations OWNER TO postgres;

--
-- Name: faq_categories_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.faq_categories_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.faq_categories_translations_id_seq OWNER TO postgres;

--
-- Name: faq_categories_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.faq_categories_translations_id_seq OWNED BY public.faq_categories_translations.id;


--
-- Name: faq_content; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.faq_content (
    id integer NOT NULL,
    sort integer,
    user_created uuid,
    date_created timestamp with time zone,
    user_updated uuid,
    date_updated timestamp with time zone,
    published boolean DEFAULT false,
    category uuid
);


ALTER TABLE public.faq_content OWNER TO postgres;

--
-- Name: faq_content_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.faq_content_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.faq_content_id_seq OWNER TO postgres;

--
-- Name: faq_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.faq_content_id_seq OWNED BY public.faq_content.id;


--
-- Name: faq_content_translations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.faq_content_translations (
    id integer NOT NULL,
    faq_content_id integer,
    languages_code character varying(255),
    question character varying(255),
    answer text
);


ALTER TABLE public.faq_content_translations OWNER TO postgres;

--
-- Name: faq_content_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.faq_content_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.faq_content_translations_id_seq OWNER TO postgres;

--
-- Name: faq_content_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.faq_content_translations_id_seq OWNED BY public.faq_content_translations.id;


--
-- Name: languages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.languages (
    code character varying(255) NOT NULL,
    name character varying(255),
    direction character varying(255) DEFAULT 'ltr'::character varying
);


ALTER TABLE public.languages OWNER TO postgres;

--
-- Name: directus_activity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_activity ALTER COLUMN id SET DEFAULT nextval('public.directus_activity_id_seq'::regclass);


--
-- Name: directus_fields id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_fields ALTER COLUMN id SET DEFAULT nextval('public.directus_fields_id_seq'::regclass);


--
-- Name: directus_notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_notifications ALTER COLUMN id SET DEFAULT nextval('public.directus_notifications_id_seq'::regclass);


--
-- Name: directus_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_permissions ALTER COLUMN id SET DEFAULT nextval('public.directus_permissions_id_seq'::regclass);


--
-- Name: directus_presets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_presets ALTER COLUMN id SET DEFAULT nextval('public.directus_presets_id_seq'::regclass);


--
-- Name: directus_relations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_relations ALTER COLUMN id SET DEFAULT nextval('public.directus_relations_id_seq'::regclass);


--
-- Name: directus_revisions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_revisions ALTER COLUMN id SET DEFAULT nextval('public.directus_revisions_id_seq'::regclass);


--
-- Name: directus_settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_settings ALTER COLUMN id SET DEFAULT nextval('public.directus_settings_id_seq'::regclass);


--
-- Name: directus_webhooks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_webhooks ALTER COLUMN id SET DEFAULT nextval('public.directus_webhooks_id_seq'::regclass);


--
-- Name: faq_categories_translations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_categories_translations ALTER COLUMN id SET DEFAULT nextval('public.faq_categories_translations_id_seq'::regclass);


--
-- Name: faq_content id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_content ALTER COLUMN id SET DEFAULT nextval('public.faq_content_id_seq'::regclass);


--
-- Name: faq_content_translations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_content_translations ALTER COLUMN id SET DEFAULT nextval('public.faq_content_translations_id_seq'::regclass);


--
-- Data for Name: directus_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_activity (id, action, "user", "timestamp", ip, user_agent, collection, item, comment, origin) FROM stdin;
1	login	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:42:50.817+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_users	daa1631c-ab80-409e-9e08-f73f54a3d3fe	\N	http://vtopidor.intra.inist.fr:8055
2	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:44:12.763+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_users	c2f71b69-f015-4f40-a239-a9a83ff7f3ca	\N	http://vtopidor.intra.inist.fr:8055
3	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:44:39.762+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_users	624fb2f6-29df-4e7f-836b-4e9eb64f235e	\N	http://vtopidor.intra.inist.fr:8055
4	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:45:03.739+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_roles	19467255-1682-415f-b26a-77b5c5268d27	\N	http://vtopidor.intra.inist.fr:8055
5	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:45:03.84+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_users	40f23ace-5553-4327-a916-3d1cea2d601a	\N	http://vtopidor.intra.inist.fr:8055
6	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:45:22.76+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_users	19a62574-2afc-48a3-a8f6-df7013162b89	\N	http://vtopidor.intra.inist.fr:8055
7	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:45:57.609+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	1	\N	http://vtopidor.intra.inist.fr:8055
8	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:45:57.617+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	2	\N	http://vtopidor.intra.inist.fr:8055
9	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:45:57.625+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	3	\N	http://vtopidor.intra.inist.fr:8055
10	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:45:57.632+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	4	\N	http://vtopidor.intra.inist.fr:8055
11	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:45:57.644+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	5	\N	http://vtopidor.intra.inist.fr:8055
12	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:45:57.667+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	6	\N	http://vtopidor.intra.inist.fr:8055
13	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:45:57.679+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories	\N	http://vtopidor.intra.inist.fr:8055
14	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:06.993+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	7	\N	http://vtopidor.intra.inist.fr:8055
15	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.082+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	8	\N	http://vtopidor.intra.inist.fr:8055
16	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.088+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories_translations	\N	http://vtopidor.intra.inist.fr:8055
17	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.168+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	9	\N	http://vtopidor.intra.inist.fr:8055
18	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.186+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	10	\N	http://vtopidor.intra.inist.fr:8055
19	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.198+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	11	\N	http://vtopidor.intra.inist.fr:8055
20	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.211+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	languages	\N	http://vtopidor.intra.inist.fr:8055
21	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.292+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	12	\N	http://vtopidor.intra.inist.fr:8055
22	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.388+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	13	\N	http://vtopidor.intra.inist.fr:8055
23	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.621+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	en-US	\N	http://vtopidor.intra.inist.fr:8055
24	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.627+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	ar-SA	\N	http://vtopidor.intra.inist.fr:8055
25	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.632+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	de-DE	\N	http://vtopidor.intra.inist.fr:8055
26	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.637+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	fr-FR	\N	http://vtopidor.intra.inist.fr:8055
27	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.643+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	ru-RU	\N	http://vtopidor.intra.inist.fr:8055
28	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.651+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	es-ES	\N	http://vtopidor.intra.inist.fr:8055
29	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.659+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	it-IT	\N	http://vtopidor.intra.inist.fr:8055
30	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:07.666+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	pt-BR	\N	http://vtopidor.intra.inist.fr:8055
31	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:21.013+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_folders	e07a884b-cfa0-4ec1-ba2a-7288050e39fd	\N	http://vtopidor.intra.inist.fr:8055
32	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:32.869+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	14	\N	http://vtopidor.intra.inist.fr:8055
33	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:43.686+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	15	\N	http://vtopidor.intra.inist.fr:8055
34	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:51.593+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories_translations	\N	http://vtopidor.intra.inist.fr:8055
35	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:51.649+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories	\N	http://vtopidor.intra.inist.fr:8055
36	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:51.658+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	languages	\N	http://vtopidor.intra.inist.fr:8055
44	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:08.661+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	en-GB	\N	http://vtopidor.intra.inist.fr:8055
45	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:20.546+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	16	\N	http://vtopidor.intra.inist.fr:8055
37	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:59.145+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	ar-SA	\N	http://vtopidor.intra.inist.fr:8055
38	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:59.147+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	de-DE	\N	http://vtopidor.intra.inist.fr:8055
39	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:59.148+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	en-US	\N	http://vtopidor.intra.inist.fr:8055
40	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:59.15+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	es-ES	\N	http://vtopidor.intra.inist.fr:8055
41	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:59.151+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	it-IT	\N	http://vtopidor.intra.inist.fr:8055
42	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:59.153+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	pt-BR	\N	http://vtopidor.intra.inist.fr:8055
43	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:46:59.155+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	languages	ru-RU	\N	http://vtopidor.intra.inist.fr:8055
53	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:45.333+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	23	\N	http://vtopidor.intra.inist.fr:8055
46	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:32.757+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	17	\N	http://vtopidor.intra.inist.fr:8055
47	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:32.762+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	18	\N	http://vtopidor.intra.inist.fr:8055
48	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:32.768+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	19	\N	http://vtopidor.intra.inist.fr:8055
49	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:32.774+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	20	\N	http://vtopidor.intra.inist.fr:8055
50	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:32.78+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	21	\N	http://vtopidor.intra.inist.fr:8055
51	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:32.786+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	22	\N	http://vtopidor.intra.inist.fr:8055
52	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:32.792+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_content	\N	http://vtopidor.intra.inist.fr:8055
54	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:54.407+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	24	\N	http://vtopidor.intra.inist.fr:8055
55	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:54.492+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	25	\N	http://vtopidor.intra.inist.fr:8055
56	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:54.503+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_content_translations	\N	http://vtopidor.intra.inist.fr:8055
57	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:54.559+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	26	\N	http://vtopidor.intra.inist.fr:8055
58	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:54.635+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	27	\N	http://vtopidor.intra.inist.fr:8055
59	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:56.146+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	17	\N	http://vtopidor.intra.inist.fr:8055
60	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:56.191+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	18	\N	http://vtopidor.intra.inist.fr:8055
61	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:56.231+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	19	\N	http://vtopidor.intra.inist.fr:8055
62	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:56.302+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	20	\N	http://vtopidor.intra.inist.fr:8055
63	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:56.341+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	21	\N	http://vtopidor.intra.inist.fr:8055
64	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:56.383+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	22	\N	http://vtopidor.intra.inist.fr:8055
65	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:56.429+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	24	\N	http://vtopidor.intra.inist.fr:8055
66	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:56.475+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	23	\N	http://vtopidor.intra.inist.fr:8055
67	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:59.07+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_content_translations	\N	http://vtopidor.intra.inist.fr:8055
68	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:59.116+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories	\N	http://vtopidor.intra.inist.fr:8055
69	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:59.124+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	languages	\N	http://vtopidor.intra.inist.fr:8055
70	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:47:59.139+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_content	\N	http://vtopidor.intra.inist.fr:8055
71	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:48:00.058+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories	\N	http://vtopidor.intra.inist.fr:8055
72	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:48:00.067+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_content	\N	http://vtopidor.intra.inist.fr:8055
73	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:48:00.075+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	languages	\N	http://vtopidor.intra.inist.fr:8055
74	login	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-07 12:48:05.176+00	172.16.99.63	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_users	624fb2f6-29df-4e7f-836b-4e9eb64f235e	\N	http://vtopidor.intra.inist.fr:8055
75	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:48:09.471+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	28	\N	http://vtopidor.intra.inist.fr:8055
76	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:48:23.196+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	29	\N	http://vtopidor.intra.inist.fr:8055
77	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:22.583+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	30	\N	http://vtopidor.intra.inist.fr:8055
78	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:33.972+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	1	\N	http://vtopidor.intra.inist.fr:8055
79	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:35.142+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	2	\N	http://vtopidor.intra.inist.fr:8055
80	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:36.012+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	3	\N	http://vtopidor.intra.inist.fr:8055
81	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:36.909+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	4	\N	http://vtopidor.intra.inist.fr:8055
94	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:52.753+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	14	\N	http://vtopidor.intra.inist.fr:8055
100	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:53.847+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	14	\N	http://vtopidor.intra.inist.fr:8055
106	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:00.739+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	18	\N	http://vtopidor.intra.inist.fr:8055
117	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:02.229+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	25	\N	http://vtopidor.intra.inist.fr:8055
121	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:03.185+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	5	\N	http://vtopidor.intra.inist.fr:8055
124	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:06.081+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	30	\N	http://vtopidor.intra.inist.fr:8055
82	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:42.081+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	5	\N	http://vtopidor.intra.inist.fr:8055
83	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:42.982+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	6	\N	http://vtopidor.intra.inist.fr:8055
84	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:43.735+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	7	\N	http://vtopidor.intra.inist.fr:8055
85	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:44.774+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	8	\N	http://vtopidor.intra.inist.fr:8055
86	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:46.101+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	9	\N	http://vtopidor.intra.inist.fr:8055
87	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:47.815+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	10	\N	http://vtopidor.intra.inist.fr:8055
90	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-07 12:49:49.199+00	172.16.99.63	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_categories	8575ac79-0d76-41a2-8dcb-b0bada51130c	\N	http://vtopidor.intra.inist.fr:8055
91	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:50.341+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	11	\N	http://vtopidor.intra.inist.fr:8055
92	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:52.733+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	12	\N	http://vtopidor.intra.inist.fr:8055
93	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:52.744+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	13	\N	http://vtopidor.intra.inist.fr:8055
95	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:52.775+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	15	\N	http://vtopidor.intra.inist.fr:8055
96	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:52.78+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	16	\N	http://vtopidor.intra.inist.fr:8055
97	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:53.842+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	12	\N	http://vtopidor.intra.inist.fr:8055
98	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:53.843+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	13	\N	http://vtopidor.intra.inist.fr:8055
99	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:53.844+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	15	\N	http://vtopidor.intra.inist.fr:8055
101	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:53.847+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	16	\N	http://vtopidor.intra.inist.fr:8055
102	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:56.803+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	17	\N	http://vtopidor.intra.inist.fr:8055
103	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:49:59.555+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	16	\N	http://vtopidor.intra.inist.fr:8055
104	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:00.714+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	10	\N	http://vtopidor.intra.inist.fr:8055
105	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:00.738+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	17	\N	http://vtopidor.intra.inist.fr:8055
107	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:00.74+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	19	\N	http://vtopidor.intra.inist.fr:8055
108	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:00.75+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	20	\N	http://vtopidor.intra.inist.fr:8055
109	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:01.513+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	11	\N	http://vtopidor.intra.inist.fr:8055
110	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:01.514+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	21	\N	http://vtopidor.intra.inist.fr:8055
111	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:01.515+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	22	\N	http://vtopidor.intra.inist.fr:8055
112	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:01.517+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	9	\N	http://vtopidor.intra.inist.fr:8055
113	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:01.728+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	23	\N	http://vtopidor.intra.inist.fr:8055
114	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:02.221+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	7	\N	http://vtopidor.intra.inist.fr:8055
115	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:02.221+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	8	\N	http://vtopidor.intra.inist.fr:8055
116	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:02.222+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	24	\N	http://vtopidor.intra.inist.fr:8055
118	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:02.231+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	26	\N	http://vtopidor.intra.inist.fr:8055
120	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:03.184+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	6	\N	http://vtopidor.intra.inist.fr:8055
125	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:22.843+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_categories	8575ac79-0d76-41a2-8dcb-b0bada51130c	\N	http://vtopidor.intra.inist.fr:8055
126	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-07 12:50:41.8+00	172.16.99.63	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	e733d9d4-0e10-4985-baa3-0c0d2002790c	\N	http://vtopidor.intra.inist.fr:8055
127	delete	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-07 12:50:41.811+00	172.16.99.63	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	e733d9d4-0e10-4985-baa3-0c0d2002790c	\N	http://vtopidor.intra.inist.fr:8055
119	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:03.18+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	27	\N	http://vtopidor.intra.inist.fr:8055
122	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:03.187+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	28	\N	http://vtopidor.intra.inist.fr:8055
123	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:03.192+00	172.16.99.62	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	29	\N	http://vtopidor.intra.inist.fr:8055
128	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:57.133+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	e53cfad0-d4a8-4158-bc32-b5f41b24c73e	\N	http://vtopidor.intra.inist.fr:8055
129	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:50:57.144+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	e53cfad0-d4a8-4158-bc32-b5f41b24c73e	\N	http://vtopidor.intra.inist.fr:8055
132	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-07 12:51:10.158+00	172.16.99.63	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_categories	e71ff11c-c405-475c-ab08-66512c596500	\N	http://vtopidor.intra.inist.fr:8055
133	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:53:41.868+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	0500bb4a-bb32-48d4-86ba-df48fc3f0d87	\N	http://vtopidor.intra.inist.fr:8055
134	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:53:45.97+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	0500bb4a-bb32-48d4-86ba-df48fc3f0d87	\N	http://vtopidor.intra.inist.fr:8055
135	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:54:10.324+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_categories	e71ff11c-c405-475c-ab08-66512c596500	\N	http://vtopidor.intra.inist.fr:8055
136	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:54:32.509+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	541cbca4-3b1d-466a-8227-41cbcac99fbf	\N	http://vtopidor.intra.inist.fr:8055
139	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:54:51.785+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_categories	30824b70-d55c-4bd8-b626-075d695ca166	\N	http://vtopidor.intra.inist.fr:8055
140	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:56:32.565+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_content_translations	1	\N	http://vtopidor.intra.inist.fr:8055
141	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:56:32.572+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_content_translations	2	\N	http://vtopidor.intra.inist.fr:8055
142	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:56:32.576+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_content	1	\N	http://vtopidor.intra.inist.fr:8055
143	login	40f23ace-5553-4327-a916-3d1cea2d601a	2023-12-07 12:57:35.392+00	172.16.103.78	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0	directus_users	40f23ace-5553-4327-a916-3d1cea2d601a	\N	http://vtopidor.intra.inist.fr:8055
144	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 12:59:30.088+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	31	\N	http://vtopidor.intra.inist.fr:8055
145	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:00:39.186+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_categories	30824b70-d55c-4bd8-b626-075d695ca166	\N	http://vtopidor.intra.inist.fr:8055
146	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:01:58.275+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	32	\N	http://vtopidor.intra.inist.fr:8055
147	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:01.942+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	8	\N	http://vtopidor.intra.inist.fr:8055
148	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:01.984+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	12	\N	http://vtopidor.intra.inist.fr:8055
149	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:02.019+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	32	\N	http://vtopidor.intra.inist.fr:8055
150	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:02.059+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	13	\N	http://vtopidor.intra.inist.fr:8055
151	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:02.09+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	16	\N	http://vtopidor.intra.inist.fr:8055
152	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:13.143+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	32	\N	http://vtopidor.intra.inist.fr:8055
153	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:23.968+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories_translations	\N	http://vtopidor.intra.inist.fr:8055
154	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:36.748+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	33	\N	http://vtopidor.intra.inist.fr:8055
155	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:36.853+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	34	\N	http://vtopidor.intra.inist.fr:8055
156	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:36.858+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories_translations	\N	http://vtopidor.intra.inist.fr:8055
157	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:36.912+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	35	\N	http://vtopidor.intra.inist.fr:8055
158	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:36.992+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	36	\N	http://vtopidor.intra.inist.fr:8055
159	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:41.516+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	1	\N	http://vtopidor.intra.inist.fr:8055
160	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:41.56+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	2	\N	http://vtopidor.intra.inist.fr:8055
161	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:41.589+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	3	\N	http://vtopidor.intra.inist.fr:8055
162	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:41.62+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	4	\N	http://vtopidor.intra.inist.fr:8055
163	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:41.661+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	5	\N	http://vtopidor.intra.inist.fr:8055
164	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:41.69+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	6	\N	http://vtopidor.intra.inist.fr:8055
165	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:41.728+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	33	\N	http://vtopidor.intra.inist.fr:8055
166	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:41.779+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	14	\N	http://vtopidor.intra.inist.fr:8055
167	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:41.823+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	15	\N	http://vtopidor.intra.inist.fr:8055
168	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:41.859+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	31	\N	http://vtopidor.intra.inist.fr:8055
169	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:44.096+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories	\N	http://vtopidor.intra.inist.fr:8055
170	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:44.103+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories_translations	\N	http://vtopidor.intra.inist.fr:8055
171	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:44.11+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_content	\N	http://vtopidor.intra.inist.fr:8055
172	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:44.117+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	languages	\N	http://vtopidor.intra.inist.fr:8055
173	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:45.517+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories_translations	\N	http://vtopidor.intra.inist.fr:8055
174	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:45.519+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories	\N	http://vtopidor.intra.inist.fr:8055
175	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:45.531+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_content	\N	http://vtopidor.intra.inist.fr:8055
176	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:45.54+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	languages	\N	http://vtopidor.intra.inist.fr:8055
177	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:50.722+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	37	\N	http://vtopidor.intra.inist.fr:8055
178	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:02:58.062+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	31	\N	http://vtopidor.intra.inist.fr:8055
179	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:03:21.373+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_categories_translations	1	\N	http://vtopidor.intra.inist.fr:8055
180	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:03:21.38+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_categories_translations	2	\N	http://vtopidor.intra.inist.fr:8055
181	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:03:21.385+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_categories	30824b70-d55c-4bd8-b626-075d695ca166	\N	http://vtopidor.intra.inist.fr:8055
182	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:04:06.298+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	38	\N	http://vtopidor.intra.inist.fr:8055
183	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:04:33.524+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_categories	30824b70-d55c-4bd8-b626-075d695ca166	\N	http://vtopidor.intra.inist.fr:8055
184	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:05:07.144+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	32	\N	http://vtopidor.intra.inist.fr:8055
185	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:05:10.273+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	33	\N	http://vtopidor.intra.inist.fr:8055
186	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:05:13.383+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	32	\N	http://vtopidor.intra.inist.fr:8055
187	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:09:11.212+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_users	b1aca500-a889-4138-b44b-429ed58b8125	\N	http://vtopidor.intra.inist.fr:8055
188	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:09:22.801+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories	\N	http://vtopidor.intra.inist.fr:8055
189	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:09:28.842+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_content	\N	http://vtopidor.intra.inist.fr:8055
190	login	b1aca500-a889-4138-b44b-429ed58b8125	2023-12-07 13:10:20.565+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_users	b1aca500-a889-4138-b44b-429ed58b8125	\N	http://vtopidor.intra.inist.fr:8055
191	login	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:10:57.506+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_users	daa1631c-ab80-409e-9e08-f73f54a3d3fe	\N	http://vtopidor.intra.inist.fr:8055
192	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:11:53.235+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_users	b1aca500-a889-4138-b44b-429ed58b8125	\N	http://vtopidor.intra.inist.fr:8055
193	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:12:07.158+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_users	19a62574-2afc-48a3-a8f6-df7013162b89	\N	http://vtopidor.intra.inist.fr:8055
194	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:12:15.77+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	34	\N	http://vtopidor.intra.inist.fr:8055
195	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:12:15.777+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	35	\N	http://vtopidor.intra.inist.fr:8055
196	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:12:15.781+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	36	\N	http://vtopidor.intra.inist.fr:8055
197	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:12:15.785+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	37	\N	http://vtopidor.intra.inist.fr:8055
198	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:12:15.787+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	38	\N	http://vtopidor.intra.inist.fr:8055
199	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:12:58.074+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	39	\N	http://vtopidor.intra.inist.fr:8055
200	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-07 13:13:01.488+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_permissions	39	\N	http://vtopidor.intra.inist.fr:8055
201	login	19a62574-2afc-48a3-a8f6-df7013162b89	2023-12-07 14:41:20.526+00	172.16.99.72	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0	directus_users	19a62574-2afc-48a3-a8f6-df7013162b89	\N	http://vtopidor.intra.inist.fr:8055
202	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 07:23:09.423+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	30dffb61-ac17-48d9-b6a7-515f6a9e1576	\N	http://vtopidor.intra.inist.fr:8055
203	update	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 07:37:30.165+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_content_translations	1	\N	http://vtopidor.intra.inist.fr:8055
204	update	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 07:37:30.177+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_content	1	\N	http://vtopidor.intra.inist.fr:8055
205	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 07:38:06.204+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	7ad1dbf4-f94a-4a89-a767-714305aa6595	\N	http://vtopidor.intra.inist.fr:8055
206	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 07:38:18.012+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_content_translations	3	\N	http://vtopidor.intra.inist.fr:8055
207	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 07:38:18.023+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_content	2	\N	http://vtopidor.intra.inist.fr:8055
208	update	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 07:38:41.883+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_content	2	\N	http://vtopidor.intra.inist.fr:8055
209	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 07:42:43.935+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	dd2e43ec-19e7-4273-b532-4a5650c34f0c	\N	http://vtopidor.intra.inist.fr:8055
210	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 07:43:20.537+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_categories_translations	3	\N	http://vtopidor.intra.inist.fr:8055
211	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 07:43:20.544+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_categories_translations	4	\N	http://vtopidor.intra.inist.fr:8055
212	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 07:43:20.55+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	faq_categories	5a0c3ac0-f06c-4c04-9fa7-d56478c1a282	\N	http://vtopidor.intra.inist.fr:8055
213	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 08:07:19.448+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_settings	1	\N	http://vtopidor.intra.inist.fr:8055
214	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 08:07:50.501+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	33c82aec-2886-4bfe-9224-5800a89de2fc	\N	http://vtopidor.intra.inist.fr:8055
215	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 08:08:54.321+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	2d92cb61-efbe-4574-b7b3-cdf691ebdeca	\N	http://vtopidor.intra.inist.fr:8055
216	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 08:09:10.547+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	a0db2cde-ebc4-4f9d-bada-084a8b22f9c9	\N	http://vtopidor.intra.inist.fr:8055
217	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 08:09:26.62+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_files	b77965d7-1cc6-46be-ac89-e106b6c76ab6	\N	http://vtopidor.intra.inist.fr:8055
218	update	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 08:10:14.552+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_settings	1	\N	http://vtopidor.intra.inist.fr:8055
219	update	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 08:11:24.692+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories	\N	http://vtopidor.intra.inist.fr:8055
220	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-08 08:46:45.056+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	37	\N	http://vtopidor.intra.inist.fr:8055
221	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-08 08:47:24.225+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	37	\N	http://vtopidor.intra.inist.fr:8055
222	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-08 08:47:29.163+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	37	\N	http://vtopidor.intra.inist.fr:8055
223	create	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 08:50:25.681+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_dashboards	070670d8-a854-485e-a44f-1c717795c094	\N	http://vtopidor.intra.inist.fr:8055
224	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-08 08:57:27.352+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	39	\N	http://vtopidor.intra.inist.fr:8055
225	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-08 08:58:52.763+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	39	\N	http://vtopidor.intra.inist.fr:8055
226	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2023-12-08 08:59:50.096+00	10.2.5.26	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	30	\N	http://vtopidor.intra.inist.fr:8055
227	update	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 11:04:51.043+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_dashboards	070670d8-a854-485e-a44f-1c717795c094	\N	http://vtopidor.intra.inist.fr:8055
228	update	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 11:07:40.948+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_fields	33	\N	http://vtopidor.intra.inist.fr:8055
229	update	624fb2f6-29df-4e7f-836b-4e9eb64f235e	2023-12-08 11:08:01.96+00	10.2.5.43	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36	directus_collections	faq_categories	\N	http://vtopidor.intra.inist.fr:8055
230	login	19a62574-2afc-48a3-a8f6-df7013162b89	2024-01-07 08:59:01.055+00	10.2.3.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0	directus_users	19a62574-2afc-48a3-a8f6-df7013162b89	\N	http://vtopidor.intra.inist.fr:8055
231	login	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-19 15:27:07.669+00	172.16.99.62	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_users	daa1631c-ab80-409e-9e08-f73f54a3d3fe	\N	http://vtopidor.intra.inist.fr:8055
232	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-19 15:45:47.926+00	172.16.99.62	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_collections	faq_categories	\N	http://vtopidor.intra.inist.fr:8055
233	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-19 15:49:44.414+00	172.16.99.62	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_permissions	40	\N	http://vtopidor.intra.inist.fr:8055
234	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-19 15:49:47.319+00	172.16.99.62	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_permissions	41	\N	http://vtopidor.intra.inist.fr:8055
235	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-19 15:49:48.886+00	172.16.99.62	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_permissions	40	\N	http://vtopidor.intra.inist.fr:8055
236	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-19 15:49:53.97+00	172.16.99.62	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_permissions	42	\N	http://vtopidor.intra.inist.fr:8055
237	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-19 15:50:25.371+00	172.16.99.62	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_permissions	42	\N	http://vtopidor.intra.inist.fr:8055
238	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-19 15:50:27.401+00	172.16.99.62	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_permissions	41	\N	http://vtopidor.intra.inist.fr:8055
239	login	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:08:58.004+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_users	daa1631c-ab80-409e-9e08-f73f54a3d3fe	\N	http://localhost:8055
240	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:09:26.295+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_users	624fb2f6-29df-4e7f-836b-4e9eb64f235e	\N	http://localhost:8055
241	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:09:26.298+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_users	b1aca500-a889-4138-b44b-429ed58b8125	\N	http://localhost:8055
242	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:09:26.3+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_users	c2f71b69-f015-4f40-a239-a9a83ff7f3ca	\N	http://localhost:8055
243	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:09:26.311+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_roles	1d82af5b-8e27-4d24-8f83-3a0669f68855	\N	http://localhost:8055
244	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:12:17.947+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_users	40f23ace-5553-4327-a916-3d1cea2d601a	\N	http://localhost:8055
245	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:12:17.949+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_users	c2f71b69-f015-4f40-a239-a9a83ff7f3ca	\N	http://localhost:8055
246	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:12:17.951+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_users	19a62574-2afc-48a3-a8f6-df7013162b89	\N	http://localhost:8055
247	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:12:17.953+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_users	624fb2f6-29df-4e7f-836b-4e9eb64f235e	\N	http://localhost:8055
248	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:12:17.955+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_users	b1aca500-a889-4138-b44b-429ed58b8125	\N	http://localhost:8055
249	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:12:32.588+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_dashboards	070670d8-a854-485e-a44f-1c717795c094	\N	http://localhost:8055
250	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:13:14.949+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_roles	1d82af5b-8e27-4d24-8f83-3a0669f68855	\N	http://localhost:8055
251	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:15:12.418+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories_translations	5	\N	http://localhost:8055
252	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:15:12.426+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories_translations	6	\N	http://localhost:8055
253	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:15:12.43+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories	9936d8a2-8369-4f00-9c10-34bb0391af3a	\N	http://localhost:8055
254	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:15:41.433+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_content_translations	4	\N	http://localhost:8055
255	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:15:41.44+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_content_translations	5	\N	http://localhost:8055
256	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:15:41.445+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_content	3	\N	http://localhost:8055
257	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:16:36.584+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories	9936d8a2-8369-4f00-9c10-34bb0391af3a	\N	http://localhost:8055
258	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:17:07.138+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories_translations	7	\N	http://localhost:8055
259	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:17:07.145+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories_translations	8	\N	http://localhost:8055
260	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:17:07.149+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories	1f7143bb-d35e-4e9a-a52e-8c70318d9361	\N	http://localhost:8055
261	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:17:07.157+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_content	3	\N	http://localhost:8055
262	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:18:08.878+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	languages	en-GB	\N	http://localhost:8055
263	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:18:13.259+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	languages	fr-FR	\N	http://localhost:8055
264	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:18:21.276+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	languages	en-GB	\N	http://localhost:8055
265	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 15:13:35.544+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_permissions	43	\N	http://localhost:8080
266	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 15:14:51.661+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_permissions	43	\N	http://localhost:8080
267	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 15:23:25.989+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_permissions	44	\N	http://localhost:8080
268	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:27:43.775+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_files	4adae99e-e1e1-467c-ba78-d7297ef78524	\N	http://localhost:8080
269	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:27:47.886+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories	1f7143bb-d35e-4e9a-a52e-8c70318d9361	\N	http://localhost:8080
270	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:41:50.933+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_content_translations	4	\N	http://localhost:8080
271	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:41:50.942+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_content	3	\N	http://localhost:8080
272	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:42:04.777+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_content_translations	5	\N	http://localhost:8080
273	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:42:04.786+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_content	3	\N	http://localhost:8080
274	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:42:30.879+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_content_translations	6	\N	http://localhost:8080
275	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:42:30.886+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_content_translations	7	\N	http://localhost:8080
276	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:42:30.891+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_content	4	\N	http://localhost:8080
277	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:49:56.686+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_files	9b18efa3-a8e7-47ad-9836-6aa1ed5d39f7	\N	http://localhost:8080
278	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:50:13.375+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_files	858b3148-7d99-4314-b471-7a5623c76557	\N	http://localhost:8080
279	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:50:17.028+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories_translations	9	\N	http://localhost:8080
280	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:50:17.033+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories_translations	10	\N	http://localhost:8080
281	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:50:17.037+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories	d10f89b8-25b7-41e3-92cd-994692acc004	\N	http://localhost:8080
282	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:55:51.225+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories_translations	7	\N	http://localhost:8080
283	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:55:51.234+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories_translations	8	\N	http://localhost:8080
284	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:55:51.24+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	faq_categories	1f7143bb-d35e-4e9a-a52e-8c70318d9361	\N	http://localhost:8080
285	login	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-25 12:13:12.703+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_users	daa1631c-ab80-409e-9e08-f73f54a3d3fe	\N	http://localhost:8080
286	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-25 12:13:33.836+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_files	9b18efa3-a8e7-47ad-9836-6aa1ed5d39f7	\N	http://localhost:8080
287	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-25 12:15:01.051+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_extensions	5270bb94-9425-4e60-a4dd-65f4c0a0921c	\N	http://localhost:8080
288	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-25 12:15:28.675+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_extensions	5270bb94-9425-4e60-a4dd-65f4c0a0921c	\N	http://localhost:8080
289	update	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-25 12:15:35.249+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_extensions	5270bb94-9425-4e60-a4dd-65f4c0a0921c	\N	http://localhost:8080
290	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-25 12:18:01.55+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_flows	2fd35489-ab21-403a-87a5-39bc1ded0de9	\N	http://localhost:8080
291	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-25 12:20:06.647+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_flows	2fd35489-ab21-403a-87a5-39bc1ded0de9	\N	http://localhost:8080
292	create	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-25 12:20:30.055+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_flows	dd0af7be-3ff0-424a-9687-7d4b6c1c0b5a	\N	http://localhost:8080
293	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-25 12:21:05.537+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_flows	dd0af7be-3ff0-424a-9687-7d4b6c1c0b5a	\N	http://localhost:8080
294	delete	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-25 12:21:10.37+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_extensions	5270bb94-9425-4e60-a4dd-65f4c0a0921c	\N	http://localhost:8080
295	login	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-25 12:31:58.514+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	directus_users	daa1631c-ab80-409e-9e08-f73f54a3d3fe	\N	http://localhost:8080
\.


--
-- Data for Name: directus_collections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_collections (collection, icon, note, display_template, hidden, singleton, translations, archive_field, archive_app_filter, archive_value, unarchive_value, sort_field, accountability, color, item_duplication_fields, sort, "group", collapse, preview_url, versioning) FROM stdin;
faq_content_translations	import_export	\N	\N	t	f	\N	\N	t	\N	\N	\N	all	\N	\N	1	faq_content	open	\N	f
faq_categories_translations	import_export	\N	\N	t	f	\N	\N	t	\N	\N	\N	all	\N	\N	1	faq_categories	open	\N	f
languages	\N	\N	\N	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	3	\N	open	\N	f
faq_content	\N	\N	\N	f	f	\N	\N	t	\N	\N	sort	all	\N	\N	2	\N	open	\N	t
faq_categories	\N	\N	\N	f	f	\N	\N	t	\N	\N	sort	all	\N	[]	1	\N	locked	{{questions}}	t
\.


--
-- Data for Name: directus_dashboards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_dashboards (id, name, icon, note, date_created, user_created, color) FROM stdin;
\.


--
-- Data for Name: directus_extensions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_extensions (enabled, id, folder, source, bundle) FROM stdin;
\.


--
-- Data for Name: directus_fields; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_fields (id, collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, translations, note, conditions, required, "group", validation, validation_message) FROM stdin;
9	languages	code	\N	\N	\N	\N	\N	f	f	1	full	\N	\N	\N	f	\N	\N	\N
10	languages	name	\N	\N	\N	\N	\N	f	f	2	full	\N	\N	\N	f	\N	\N	\N
11	languages	direction	\N	select-dropdown	{"choices":[{"text":"$t:left_to_right","value":"ltr"},{"text":"$t:right_to_left","value":"rtl"}]}	labels	{"choices":[{"text":"$t:left_to_right","value":"ltr"},{"text":"$t:right_to_left","value":"rtl"}],"format":false}	f	f	3	full	\N	\N	\N	f	\N	\N	\N
25	faq_content_translations	id	\N	\N	\N	\N	\N	f	t	1	full	\N	\N	\N	f	\N	\N	\N
26	faq_content_translations	faq_content_id	\N	\N	\N	\N	\N	f	t	2	full	\N	\N	\N	f	\N	\N	\N
27	faq_content_translations	languages_code	\N	\N	\N	\N	\N	f	t	3	full	\N	\N	\N	f	\N	\N	\N
17	faq_content	id	\N	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N
18	faq_content	sort	\N	input	\N	\N	\N	f	t	2	full	\N	\N	\N	f	\N	\N	\N
19	faq_content	user_created	user-created	select-dropdown-m2o	{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"}	user	\N	t	t	3	half	\N	\N	\N	f	\N	\N	\N
20	faq_content	date_created	date-created	datetime	\N	datetime	{"relative":true}	t	t	4	half	\N	\N	\N	f	\N	\N	\N
21	faq_content	user_updated	user-updated	select-dropdown-m2o	{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"}	user	\N	t	t	5	half	\N	\N	\N	f	\N	\N	\N
22	faq_content	date_updated	date-updated	datetime	\N	datetime	{"relative":true}	t	t	6	half	\N	\N	\N	f	\N	\N	\N
24	faq_content	translations	translations	translations	{"defaultLanguage":"fr-FR"}	\N	\N	f	f	7	full	\N	\N	\N	f	\N	\N	\N
23	faq_content	published	cast-boolean	boolean	\N	\N	\N	f	f	8	full	\N	\N	\N	f	\N	\N	\N
28	faq_content_translations	question	\N	input	\N	\N	\N	f	f	4	full	\N	\N	\N	t	\N	\N	\N
29	faq_content_translations	answer	\N	input-rich-text-html	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd"}	\N	\N	f	f	5	full	\N	\N	\N	t	\N	\N	\N
37	faq_categories_translations	title	\N	input	\N	\N	{"choices":null}	f	f	4	full	\N	\N	\N	t	\N	\N	\N
34	faq_categories_translations	id	\N	\N	\N	\N	\N	f	t	1	full	\N	\N	\N	f	\N	\N	\N
35	faq_categories_translations	faq_categories_id	\N	\N	\N	\N	\N	f	t	2	full	\N	\N	\N	f	\N	\N	\N
36	faq_categories_translations	languages_code	\N	\N	\N	\N	\N	f	t	3	full	\N	\N	\N	f	\N	\N	\N
1	faq_categories	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N
2	faq_categories	sort	\N	input	\N	\N	\N	f	t	2	full	\N	\N	\N	f	\N	\N	\N
3	faq_categories	user_created	user-created	select-dropdown-m2o	{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"}	user	\N	t	t	3	half	\N	\N	\N	f	\N	\N	\N
4	faq_categories	date_created	date-created	datetime	\N	datetime	{"relative":true}	t	t	4	half	\N	\N	\N	f	\N	\N	\N
5	faq_categories	user_updated	user-updated	select-dropdown-m2o	{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"}	user	\N	t	t	5	half	\N	\N	\N	f	\N	\N	\N
6	faq_categories	date_updated	date-updated	datetime	\N	datetime	{"relative":true}	t	t	6	half	\N	\N	\N	f	\N	\N	\N
14	faq_categories	icon	file	file-image	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd"}	\N	\N	f	f	8	full	\N	\N	\N	f	\N	\N	\N
15	faq_categories	published	cast-boolean	boolean	\N	\N	\N	f	f	9	full	\N	\N	\N	f	\N	\N	\N
39	faq_categories	questions	o2m	list-o2m	\N	related-values	{"template":"{{translations.question}}"}	f	f	10	full	\N	\N	\N	f	\N	\N	\N
30	faq_content	category	m2o	select-dropdown-m2o	{"template":"{{translations.title}}"}	related-values	{"template":"{{translations.title}}"}	f	f	9	full	\N	\N	\N	f	\N	\N	\N
33	faq_categories	translations	translations	translations	{"defaultLanguage":"fr-FR"}	translations	{"template":"{{title}}"}	f	f	7	full	\N	\N	\N	f	\N	\N	\N
\.


--
-- Data for Name: directus_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_files (id, storage, filename_disk, filename_download, title, type, folder, uploaded_by, uploaded_on, modified_by, modified_on, charset, filesize, width, height, duration, embed, description, location, tags, metadata, focal_point_x, focal_point_y) FROM stdin;
4adae99e-e1e1-467c-ba78-d7297ef78524	local	4adae99e-e1e1-467c-ba78-d7297ef78524.svg	info.svg	Info	image/svg+xml	e07a884b-cfa0-4ec1-ba2a-7288050e39fd	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:27:43.768783+00	\N	2024-03-22 10:27:43.791+00	\N	2576	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
858b3148-7d99-4314-b471-7a5623c76557	local	858b3148-7d99-4314-b471-7a5623c76557.svg	redact.svg	Redact	image/svg+xml	e07a884b-cfa0-4ec1-ba2a-7288050e39fd	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:50:13.369692+00	\N	2024-03-22 10:50:13.39+00	\N	3046	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: directus_flows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_flows (id, name, icon, color, description, status, trigger, accountability, options, operation, date_created, user_created) FROM stdin;
\.


--
-- Data for Name: directus_folders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_folders (id, name, parent) FROM stdin;
e07a884b-cfa0-4ec1-ba2a-7288050e39fd	FAQ	\N
\.


--
-- Data for Name: directus_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_migrations (version, name, "timestamp") FROM stdin;
20201028A	Remove Collection Foreign Keys	2023-12-07 12:42:27.03553+00
20201029A	Remove System Relations	2023-12-07 12:42:27.040409+00
20201029B	Remove System Collections	2023-12-07 12:42:27.050763+00
20201029C	Remove System Fields	2023-12-07 12:42:27.065905+00
20201105A	Add Cascade System Relations	2023-12-07 12:42:27.132783+00
20201105B	Change Webhook URL Type	2023-12-07 12:42:27.13743+00
20210225A	Add Relations Sort Field	2023-12-07 12:42:27.141831+00
20210304A	Remove Locked Fields	2023-12-07 12:42:27.159311+00
20210312A	Webhooks Collections Text	2023-12-07 12:42:27.163726+00
20210331A	Add Refresh Interval	2023-12-07 12:42:27.166145+00
20210415A	Make Filesize Nullable	2023-12-07 12:42:27.178394+00
20210416A	Add Collections Accountability	2023-12-07 12:42:27.182481+00
20210422A	Remove Files Interface	2023-12-07 12:42:27.18472+00
20210506A	Rename Interfaces	2023-12-07 12:42:27.204699+00
20210510A	Restructure Relations	2023-12-07 12:42:27.219693+00
20210518A	Add Foreign Key Constraints	2023-12-07 12:42:27.226918+00
20210519A	Add System Fk Triggers	2023-12-07 12:42:27.258525+00
20210521A	Add Collections Icon Color	2023-12-07 12:42:27.260954+00
20210525A	Add Insights	2023-12-07 12:42:27.276376+00
20210608A	Add Deep Clone Config	2023-12-07 12:42:27.278742+00
20210626A	Change Filesize Bigint	2023-12-07 12:42:27.290045+00
20210716A	Add Conditions to Fields	2023-12-07 12:42:27.296507+00
20210721A	Add Default Folder	2023-12-07 12:42:27.307687+00
20210802A	Replace Groups	2023-12-07 12:42:27.313696+00
20210803A	Add Required to Fields	2023-12-07 12:42:27.315903+00
20210805A	Update Groups	2023-12-07 12:42:27.319213+00
20210805B	Change Image Metadata Structure	2023-12-07 12:42:27.322915+00
20210811A	Add Geometry Config	2023-12-07 12:42:27.325196+00
20210831A	Remove Limit Column	2023-12-07 12:42:27.327152+00
20210903A	Add Auth Provider	2023-12-07 12:42:27.33889+00
20210907A	Webhooks Collections Not Null	2023-12-07 12:42:27.344427+00
20210910A	Move Module Setup	2023-12-07 12:42:27.347659+00
20210920A	Webhooks URL Not Null	2023-12-07 12:42:27.35216+00
20210924A	Add Collection Organization	2023-12-07 12:42:27.356036+00
20210927A	Replace Fields Group	2023-12-07 12:42:27.36257+00
20210927B	Replace M2M Interface	2023-12-07 12:42:27.364391+00
20210929A	Rename Login Action	2023-12-07 12:42:27.366118+00
20211007A	Update Presets	2023-12-07 12:42:27.371325+00
20211009A	Add Auth Data	2023-12-07 12:42:27.373353+00
20211016A	Add Webhook Headers	2023-12-07 12:42:27.375329+00
20211103A	Set Unique to User Token	2023-12-07 12:42:27.378494+00
20211103B	Update Special Geometry	2023-12-07 12:42:27.380393+00
20211104A	Remove Collections Listing	2023-12-07 12:42:27.382487+00
20211118A	Add Notifications	2023-12-07 12:42:27.39399+00
20211211A	Add Shares	2023-12-07 12:42:27.412427+00
20211230A	Add Project Descriptor	2023-12-07 12:42:27.415372+00
20220303A	Remove Default Project Color	2023-12-07 12:42:27.420819+00
20220308A	Add Bookmark Icon and Color	2023-12-07 12:42:27.423229+00
20220314A	Add Translation Strings	2023-12-07 12:42:27.425212+00
20220322A	Rename Field Typecast Flags	2023-12-07 12:42:27.42867+00
20220323A	Add Field Validation	2023-12-07 12:42:27.431232+00
20220325A	Fix Typecast Flags	2023-12-07 12:42:27.436446+00
20220325B	Add Default Language	2023-12-07 12:42:27.446571+00
20220402A	Remove Default Value Panel Icon	2023-12-07 12:42:27.451392+00
20220429A	Add Flows	2023-12-07 12:42:27.48003+00
20220429B	Add Color to Insights Icon	2023-12-07 12:42:27.482128+00
20220429C	Drop Non Null From IP of Activity	2023-12-07 12:42:27.483948+00
20220429D	Drop Non Null From Sender of Notifications	2023-12-07 12:42:27.485749+00
20220614A	Rename Hook Trigger to Event	2023-12-07 12:42:27.48745+00
20220801A	Update Notifications Timestamp Column	2023-12-07 12:42:27.492862+00
20220802A	Add Custom Aspect Ratios	2023-12-07 12:42:27.494836+00
20220826A	Add Origin to Accountability	2023-12-07 12:42:27.497476+00
20230401A	Update Material Icons	2023-12-07 12:42:27.503631+00
20230525A	Add Preview Settings	2023-12-07 12:42:27.50566+00
20230526A	Migrate Translation Strings	2023-12-07 12:42:27.514162+00
20230721A	Require Shares Fields	2023-12-07 12:42:27.517916+00
20230823A	Add Content Versioning	2023-12-07 12:42:27.533416+00
20230927A	Themes	2023-12-07 12:42:27.54726+00
20231009A	Update CSV Fields to Text	2023-12-07 12:42:27.550305+00
20231009B	Update Panel Options	2023-12-07 12:42:27.553537+00
20231010A	Add Extensions	2023-12-07 12:42:27.557705+00
20231215A	Add Focalpoints	2024-03-21 09:25:02.084451+00
20240204A	Marketplace	2024-03-21 09:25:02.122303+00
\.


--
-- Data for Name: directus_notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_notifications (id, "timestamp", status, recipient, sender, subject, message, collection, item) FROM stdin;
\.


--
-- Data for Name: directus_operations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_operations (id, name, key, type, position_x, position_y, options, resolve, reject, flow, date_created, user_created) FROM stdin;
\.


--
-- Data for Name: directus_panels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_panels (id, dashboard, name, icon, color, show_header, note, type, position_x, position_y, width, height, options, date_created, user_created) FROM stdin;
\.


--
-- Data for Name: directus_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_permissions (id, role, collection, action, permissions, validation, presets, fields) FROM stdin;
1	\N	faq_categories	read	{}	{}	\N	*
3	\N	faq_content	read	{}	{}	\N	*
4	\N	faq_content_translations	read	{}	{}	\N	*
12	19467255-1682-415f-b26a-77b5c5268d27	languages	create	{}	{}	\N	*
13	19467255-1682-415f-b26a-77b5c5268d27	languages	read	{}	{}	\N	*
15	19467255-1682-415f-b26a-77b5c5268d27	languages	delete	{}	{}	\N	*
14	19467255-1682-415f-b26a-77b5c5268d27	languages	update	{}	{}	\N	*
10	19467255-1682-415f-b26a-77b5c5268d27	faq_content_translations	create	{}	{}	\N	*
17	19467255-1682-415f-b26a-77b5c5268d27	faq_content_translations	read	{}	{}	\N	*
18	19467255-1682-415f-b26a-77b5c5268d27	faq_content_translations	update	{}	{}	\N	*
19	19467255-1682-415f-b26a-77b5c5268d27	faq_content_translations	delete	{}	{}	\N	*
20	19467255-1682-415f-b26a-77b5c5268d27	faq_content_translations	share	{}	{}	\N	*
11	19467255-1682-415f-b26a-77b5c5268d27	faq_content	create	{}	{}	\N	*
21	19467255-1682-415f-b26a-77b5c5268d27	faq_content	update	{}	{}	\N	*
9	19467255-1682-415f-b26a-77b5c5268d27	faq_content	read	{}	{}	\N	*
22	19467255-1682-415f-b26a-77b5c5268d27	faq_content	delete	{}	{}	\N	*
23	19467255-1682-415f-b26a-77b5c5268d27	faq_content	share	{}	{}	\N	*
6	19467255-1682-415f-b26a-77b5c5268d27	faq_categories	create	{}	{}	\N	*
5	19467255-1682-415f-b26a-77b5c5268d27	faq_categories	read	{}	{}	\N	*
27	19467255-1682-415f-b26a-77b5c5268d27	faq_categories	update	{}	{}	\N	*
28	19467255-1682-415f-b26a-77b5c5268d27	faq_categories	share	{}	{}	\N	*
29	19467255-1682-415f-b26a-77b5c5268d27	faq_categories	delete	{}	{}	\N	*
30	19467255-1682-415f-b26a-77b5c5268d27	languages	share	{}	{}	\N	*
31	\N	faq_categories_translations	read	{}	{}	\N	*
33	\N	directus_files	read	{}	{}	\N	*
34	19467255-1682-415f-b26a-77b5c5268d27	faq_categories_translations	create	{}	{}	\N	*
35	19467255-1682-415f-b26a-77b5c5268d27	faq_categories_translations	read	{}	{}	\N	*
36	19467255-1682-415f-b26a-77b5c5268d27	faq_categories_translations	update	{}	{}	\N	*
37	19467255-1682-415f-b26a-77b5c5268d27	faq_categories_translations	share	{}	{}	\N	*
38	19467255-1682-415f-b26a-77b5c5268d27	faq_categories_translations	delete	{}	{}	\N	*
44	\N	languages	read	{}	{}	\N	*
\.


--
-- Data for Name: directus_presets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_presets (id, bookmark, "user", role, collection, search, layout, layout_query, layout_options, refresh_interval, filter, icon, color) FROM stdin;
13	\N	daa1631c-ab80-409e-9e08-f73f54a3d3fe	\N	directus_users	\N	cards	{"cards":{"sort":["email"],"page":1}}	{"cards":{"icon":"account_circle","title":"{{ first_name }} {{ last_name }}","subtitle":"{{ email }}","size":4}}	\N	\N	bookmark	\N
14	\N	daa1631c-ab80-409e-9e08-f73f54a3d3fe	\N	faq_content	\N	\N	{"tabular":{"page":1}}	\N	\N	\N	bookmark	\N
12	\N	daa1631c-ab80-409e-9e08-f73f54a3d3fe	\N	languages	\N	tabular	{"tabular":{"page":1}}	\N	\N	\N	bookmark	\N
15	\N	daa1631c-ab80-409e-9e08-f73f54a3d3fe	\N	directus_files	\N	cards	{"cards":{"sort":["-uploaded_on"],"page":1}}	{"cards":{"icon":"insert_drive_file","title":"{{ title }}","subtitle":"{{ type }} • {{ filesize }}","size":4,"imageFit":"crop"}}	\N	\N	bookmark	\N
\.


--
-- Data for Name: directus_relations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_relations (id, many_collection, many_field, one_collection, one_field, one_collection_field, one_allowed_collections, junction_field, sort_field, one_deselect_action) FROM stdin;
1	faq_categories	user_created	directus_users	\N	\N	\N	\N	\N	nullify
2	faq_categories	user_updated	directus_users	\N	\N	\N	\N	\N	nullify
5	faq_categories	icon	directus_files	\N	\N	\N	\N	\N	nullify
6	faq_content	user_created	directus_users	\N	\N	\N	\N	\N	nullify
7	faq_content	user_updated	directus_users	\N	\N	\N	\N	\N	nullify
8	faq_content_translations	languages_code	languages	\N	\N	\N	faq_content_id	\N	nullify
9	faq_content_translations	faq_content_id	faq_content	translations	\N	\N	languages_code	\N	nullify
12	faq_categories_translations	languages_code	languages	\N	\N	\N	faq_categories_id	\N	nullify
13	faq_categories_translations	faq_categories_id	faq_categories	translations	\N	\N	languages_code	\N	nullify
10	faq_content	category	faq_categories	questions	\N	\N	\N	\N	nullify
\.


--
-- Data for Name: directus_revisions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_revisions (id, activity, collection, item, data, delta, parent, version) FROM stdin;
1	2	directus_users	c2f71b69-f015-4f40-a239-a9a83ff7f3ca	{"email":"benjamin.faure@inist.fr","password":"**********","first_name":"Benjamin","last_name":"FAURE","email_notifications":false,"role":"1d82af5b-8e27-4d24-8f83-3a0669f68855"}	{"email":"benjamin.faure@inist.fr","password":"**********","first_name":"Benjamin","last_name":"FAURE","email_notifications":false,"role":"1d82af5b-8e27-4d24-8f83-3a0669f68855"}	\N	\N
2	3	directus_users	624fb2f6-29df-4e7f-836b-4e9eb64f235e	{"email":"marie-christine.jacquemot@inist.fr","password":"**********","last_name":"JACQUEMOT","first_name":"Marie-Christine","email_notifications":false,"role":"1d82af5b-8e27-4d24-8f83-3a0669f68855"}	{"email":"marie-christine.jacquemot@inist.fr","password":"**********","last_name":"JACQUEMOT","first_name":"Marie-Christine","email_notifications":false,"role":"1d82af5b-8e27-4d24-8f83-3a0669f68855"}	\N	\N
4	5	directus_users	40f23ace-5553-4327-a916-3d1cea2d601a	{"email":"anne.busin@inist.fr","password":"**********","first_name":"Anne","last_name":"BUSIN","email_notifications":false,"role":{"name":"Users"}}	{"email":"anne.busin@inist.fr","password":"**********","first_name":"Anne","last_name":"BUSIN","email_notifications":false,"role":{"name":"Users"}}	\N	\N
3	4	directus_roles	19467255-1682-415f-b26a-77b5c5268d27	{"name":"Users"}	{"name":"Users"}	4	\N
5	6	directus_users	19a62574-2afc-48a3-a8f6-df7013162b89	{"email":"francoise.cosserat@inist.fr","password":"**********","first_name":"Françoise","last_name":"COSSERAT"}	{"email":"francoise.cosserat@inist.fr","password":"**********","first_name":"Françoise","last_name":"COSSERAT"}	\N	\N
6	7	directus_fields	1	{"sort":1,"hidden":true,"readonly":true,"interface":"input","special":["uuid"],"field":"id","collection":"faq_categories"}	{"sort":1,"hidden":true,"readonly":true,"interface":"input","special":["uuid"],"field":"id","collection":"faq_categories"}	\N	\N
7	8	directus_fields	2	{"sort":2,"interface":"input","hidden":true,"field":"sort","collection":"faq_categories"}	{"sort":2,"interface":"input","hidden":true,"field":"sort","collection":"faq_categories"}	\N	\N
8	9	directus_fields	3	{"sort":3,"special":["user-created"],"interface":"select-dropdown-m2o","options":{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"},"display":"user","readonly":true,"hidden":true,"width":"half","field":"user_created","collection":"faq_categories"}	{"sort":3,"special":["user-created"],"interface":"select-dropdown-m2o","options":{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"},"display":"user","readonly":true,"hidden":true,"width":"half","field":"user_created","collection":"faq_categories"}	\N	\N
9	10	directus_fields	4	{"sort":4,"special":["date-created"],"interface":"datetime","readonly":true,"hidden":true,"width":"half","display":"datetime","display_options":{"relative":true},"field":"date_created","collection":"faq_categories"}	{"sort":4,"special":["date-created"],"interface":"datetime","readonly":true,"hidden":true,"width":"half","display":"datetime","display_options":{"relative":true},"field":"date_created","collection":"faq_categories"}	\N	\N
10	11	directus_fields	5	{"sort":5,"special":["user-updated"],"interface":"select-dropdown-m2o","options":{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"},"display":"user","readonly":true,"hidden":true,"width":"half","field":"user_updated","collection":"faq_categories"}	{"sort":5,"special":["user-updated"],"interface":"select-dropdown-m2o","options":{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"},"display":"user","readonly":true,"hidden":true,"width":"half","field":"user_updated","collection":"faq_categories"}	\N	\N
11	12	directus_fields	6	{"sort":6,"special":["date-updated"],"interface":"datetime","readonly":true,"hidden":true,"width":"half","display":"datetime","display_options":{"relative":true},"field":"date_updated","collection":"faq_categories"}	{"sort":6,"special":["date-updated"],"interface":"datetime","readonly":true,"hidden":true,"width":"half","display":"datetime","display_options":{"relative":true},"field":"date_updated","collection":"faq_categories"}	\N	\N
12	13	directus_collections	faq_categories	{"sort_field":"sort","singleton":false,"collection":"faq_categories"}	{"sort_field":"sort","singleton":false,"collection":"faq_categories"}	\N	\N
13	14	directus_fields	7	{"sort":7,"interface":"translations","special":["translations"],"options":{"defaultLanguage":"fr-FR"},"collection":"faq_categories","field":"translations"}	{"sort":7,"interface":"translations","special":["translations"],"options":{"defaultLanguage":"fr-FR"},"collection":"faq_categories","field":"translations"}	\N	\N
14	15	directus_fields	8	{"sort":1,"hidden":true,"field":"id","collection":"faq_categories_translations"}	{"sort":1,"hidden":true,"field":"id","collection":"faq_categories_translations"}	\N	\N
15	16	directus_collections	faq_categories_translations	{"hidden":true,"icon":"import_export","collection":"faq_categories_translations"}	{"hidden":true,"icon":"import_export","collection":"faq_categories_translations"}	\N	\N
16	17	directus_fields	9	{"sort":1,"field":"code","collection":"languages"}	{"sort":1,"field":"code","collection":"languages"}	\N	\N
17	18	directus_fields	10	{"sort":2,"field":"name","collection":"languages"}	{"sort":2,"field":"name","collection":"languages"}	\N	\N
18	19	directus_fields	11	{"sort":3,"interface":"select-dropdown","options":{"choices":[{"text":"$t:left_to_right","value":"ltr"},{"text":"$t:right_to_left","value":"rtl"}]},"display":"labels","display_options":{"choices":[{"text":"$t:left_to_right","value":"ltr"},{"text":"$t:right_to_left","value":"rtl"}],"format":false},"field":"direction","collection":"languages"}	{"sort":3,"interface":"select-dropdown","options":{"choices":[{"text":"$t:left_to_right","value":"ltr"},{"text":"$t:right_to_left","value":"rtl"}]},"display":"labels","display_options":{"choices":[{"text":"$t:left_to_right","value":"ltr"},{"text":"$t:right_to_left","value":"rtl"}],"format":false},"field":"direction","collection":"languages"}	\N	\N
19	20	directus_collections	languages	{"collection":"languages"}	{"collection":"languages"}	\N	\N
20	21	directus_fields	12	{"sort":2,"hidden":true,"collection":"faq_categories_translations","field":"faq_categories_id"}	{"sort":2,"hidden":true,"collection":"faq_categories_translations","field":"faq_categories_id"}	\N	\N
21	22	directus_fields	13	{"sort":3,"hidden":true,"collection":"faq_categories_translations","field":"languages_id"}	{"sort":3,"hidden":true,"collection":"faq_categories_translations","field":"languages_id"}	\N	\N
22	23	languages	en-US	{"code":"en-US","name":"English","direction":"ltr"}	{"code":"en-US","name":"English","direction":"ltr"}	\N	\N
23	24	languages	ar-SA	{"code":"ar-SA","name":"Arabic","direction":"rtl"}	{"code":"ar-SA","name":"Arabic","direction":"rtl"}	\N	\N
24	25	languages	de-DE	{"code":"de-DE","name":"German","direction":"ltr"}	{"code":"de-DE","name":"German","direction":"ltr"}	\N	\N
25	26	languages	fr-FR	{"code":"fr-FR","name":"French","direction":"ltr"}	{"code":"fr-FR","name":"French","direction":"ltr"}	\N	\N
30	31	directus_folders	e07a884b-cfa0-4ec1-ba2a-7288050e39fd	{"name":"FAQ"}	{"name":"FAQ"}	\N	\N
26	27	languages	ru-RU	{"code":"ru-RU","name":"Russian","direction":"ltr"}	{"code":"ru-RU","name":"Russian","direction":"ltr"}	\N	\N
27	28	languages	es-ES	{"code":"es-ES","name":"Spanish","direction":"ltr"}	{"code":"es-ES","name":"Spanish","direction":"ltr"}	\N	\N
28	29	languages	it-IT	{"code":"it-IT","name":"Italian","direction":"ltr"}	{"code":"it-IT","name":"Italian","direction":"ltr"}	\N	\N
29	30	languages	pt-BR	{"code":"pt-BR","name":"Portuguese","direction":"ltr"}	{"code":"pt-BR","name":"Portuguese","direction":"ltr"}	\N	\N
45	53	directus_fields	23	{"sort":7,"interface":"boolean","special":["cast-boolean"],"collection":"faq_content","field":"published"}	{"sort":7,"interface":"boolean","special":["cast-boolean"],"collection":"faq_content","field":"published"}	\N	\N
46	54	directus_fields	24	{"sort":8,"interface":"translations","special":["translations"],"options":{"defaultLanguage":"fr-FR"},"collection":"faq_content","field":"translations"}	{"sort":8,"interface":"translations","special":["translations"],"options":{"defaultLanguage":"fr-FR"},"collection":"faq_content","field":"translations"}	\N	\N
47	55	directus_fields	25	{"sort":1,"hidden":true,"field":"id","collection":"faq_content_translations"}	{"sort":1,"hidden":true,"field":"id","collection":"faq_content_translations"}	\N	\N
48	56	directus_collections	faq_content_translations	{"hidden":true,"icon":"import_export","collection":"faq_content_translations"}	{"hidden":true,"icon":"import_export","collection":"faq_content_translations"}	\N	\N
49	57	directus_fields	26	{"sort":2,"hidden":true,"collection":"faq_content_translations","field":"faq_content_id"}	{"sort":2,"hidden":true,"collection":"faq_content_translations","field":"faq_content_id"}	\N	\N
50	58	directus_fields	27	{"sort":3,"hidden":true,"collection":"faq_content_translations","field":"languages_code"}	{"sort":3,"hidden":true,"collection":"faq_content_translations","field":"languages_code"}	\N	\N
59	67	directus_collections	faq_content_translations	{"collection":"faq_content_translations","icon":"import_export","note":null,"display_template":null,"hidden":true,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":1,"group":"faq_content","collapse":"open","preview_url":null,"versioning":false}	{"sort":1,"group":"faq_content"}	\N	\N
60	68	directus_collections	faq_categories	{"collection":"faq_categories","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":null,"sort":1,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":1,"group":null}	\N	\N
61	69	directus_collections	languages	{"collection":"languages","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":2,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":2,"group":null}	\N	\N
62	70	directus_collections	faq_content	{"collection":"faq_content","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":null,"sort":3,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":3,"group":null}	\N	\N
63	71	directus_collections	faq_categories	{"collection":"faq_categories","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":null,"sort":1,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":1,"group":null}	\N	\N
64	72	directus_collections	faq_content	{"collection":"faq_content","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":null,"sort":2,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":2,"group":null}	\N	\N
65	73	directus_collections	languages	{"collection":"languages","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":3,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":3,"group":null}	\N	\N
31	32	directus_fields	14	{"sort":8,"interface":"file-image","special":["file"],"options":{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd"},"collection":"faq_categories","field":"icon"}	{"sort":8,"interface":"file-image","special":["file"],"options":{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd"},"collection":"faq_categories","field":"icon"}	\N	\N
32	33	directus_fields	15	{"sort":9,"interface":"boolean","special":["cast-boolean"],"collection":"faq_categories","field":"published"}	{"sort":9,"interface":"boolean","special":["cast-boolean"],"collection":"faq_categories","field":"published"}	\N	\N
33	34	directus_collections	faq_categories_translations	{"collection":"faq_categories_translations","icon":"import_export","note":null,"display_template":null,"hidden":true,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":1,"group":"faq_categories","collapse":"open","preview_url":null,"versioning":false}	{"sort":1,"group":"faq_categories"}	\N	\N
34	35	directus_collections	faq_categories	{"collection":"faq_categories","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":null,"sort":1,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":1,"group":null}	\N	\N
35	36	directus_collections	languages	{"collection":"languages","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":2,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":2,"group":null}	\N	\N
36	44	languages	en-GB	{"code":"en-GB","name":"Engish (UK)"}	{"code":"en-GB","name":"Engish (UK)"}	\N	\N
37	45	directus_fields	16	{"sort":4,"interface":"input","special":null,"required":true,"collection":"faq_categories_translations","field":"title"}	{"sort":4,"interface":"input","special":null,"required":true,"collection":"faq_categories_translations","field":"title"}	\N	\N
51	59	directus_fields	17	{"id":17,"collection":"faq_content","field":"id","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":true,"hidden":true,"sort":1,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_content","field":"id","sort":1,"group":null}	\N	\N
52	60	directus_fields	18	{"id":18,"collection":"faq_content","field":"sort","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":true,"sort":2,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_content","field":"sort","sort":2,"group":null}	\N	\N
53	61	directus_fields	19	{"id":19,"collection":"faq_content","field":"user_created","special":["user-created"],"interface":"select-dropdown-m2o","options":{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"},"display":"user","display_options":null,"readonly":true,"hidden":true,"sort":3,"width":"half","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_content","field":"user_created","sort":3,"group":null}	\N	\N
54	62	directus_fields	20	{"id":20,"collection":"faq_content","field":"date_created","special":["date-created"],"interface":"datetime","options":null,"display":"datetime","display_options":{"relative":true},"readonly":true,"hidden":true,"sort":4,"width":"half","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_content","field":"date_created","sort":4,"group":null}	\N	\N
55	63	directus_fields	21	{"id":21,"collection":"faq_content","field":"user_updated","special":["user-updated"],"interface":"select-dropdown-m2o","options":{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"},"display":"user","display_options":null,"readonly":true,"hidden":true,"sort":5,"width":"half","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_content","field":"user_updated","sort":5,"group":null}	\N	\N
56	64	directus_fields	22	{"id":22,"collection":"faq_content","field":"date_updated","special":["date-updated"],"interface":"datetime","options":null,"display":"datetime","display_options":{"relative":true},"readonly":true,"hidden":true,"sort":6,"width":"half","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_content","field":"date_updated","sort":6,"group":null}	\N	\N
57	65	directus_fields	24	{"id":24,"collection":"faq_content","field":"translations","special":["translations"],"interface":"translations","options":{"defaultLanguage":"fr-FR"},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":7,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_content","field":"translations","sort":7,"group":null}	\N	\N
58	66	directus_fields	23	{"id":23,"collection":"faq_content","field":"published","special":["cast-boolean"],"interface":"boolean","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":8,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_content","field":"published","sort":8,"group":null}	\N	\N
66	75	directus_fields	28	{"sort":4,"interface":"input","special":null,"required":true,"collection":"faq_content_translations","field":"question"}	{"sort":4,"interface":"input","special":null,"required":true,"collection":"faq_content_translations","field":"question"}	\N	\N
67	76	directus_fields	29	{"sort":5,"interface":"input-rich-text-html","special":null,"options":{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd"},"required":true,"collection":"faq_content_translations","field":"answer"}	{"sort":5,"interface":"input-rich-text-html","special":null,"options":{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd"},"required":true,"collection":"faq_content_translations","field":"answer"}	\N	\N
38	46	directus_fields	17	{"sort":1,"hidden":true,"interface":"input","readonly":true,"field":"id","collection":"faq_content"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"field":"id","collection":"faq_content"}	\N	\N
39	47	directus_fields	18	{"sort":2,"interface":"input","hidden":true,"field":"sort","collection":"faq_content"}	{"sort":2,"interface":"input","hidden":true,"field":"sort","collection":"faq_content"}	\N	\N
40	48	directus_fields	19	{"sort":3,"special":["user-created"],"interface":"select-dropdown-m2o","options":{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"},"display":"user","readonly":true,"hidden":true,"width":"half","field":"user_created","collection":"faq_content"}	{"sort":3,"special":["user-created"],"interface":"select-dropdown-m2o","options":{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"},"display":"user","readonly":true,"hidden":true,"width":"half","field":"user_created","collection":"faq_content"}	\N	\N
41	49	directus_fields	20	{"sort":4,"special":["date-created"],"interface":"datetime","readonly":true,"hidden":true,"width":"half","display":"datetime","display_options":{"relative":true},"field":"date_created","collection":"faq_content"}	{"sort":4,"special":["date-created"],"interface":"datetime","readonly":true,"hidden":true,"width":"half","display":"datetime","display_options":{"relative":true},"field":"date_created","collection":"faq_content"}	\N	\N
42	50	directus_fields	21	{"sort":5,"special":["user-updated"],"interface":"select-dropdown-m2o","options":{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"},"display":"user","readonly":true,"hidden":true,"width":"half","field":"user_updated","collection":"faq_content"}	{"sort":5,"special":["user-updated"],"interface":"select-dropdown-m2o","options":{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"},"display":"user","readonly":true,"hidden":true,"width":"half","field":"user_updated","collection":"faq_content"}	\N	\N
43	51	directus_fields	22	{"sort":6,"special":["date-updated"],"interface":"datetime","readonly":true,"hidden":true,"width":"half","display":"datetime","display_options":{"relative":true},"field":"date_updated","collection":"faq_content"}	{"sort":6,"special":["date-updated"],"interface":"datetime","readonly":true,"hidden":true,"width":"half","display":"datetime","display_options":{"relative":true},"field":"date_updated","collection":"faq_content"}	\N	\N
44	52	directus_collections	faq_content	{"sort_field":"sort","singleton":false,"collection":"faq_content"}	{"sort_field":"sort","singleton":false,"collection":"faq_content"}	\N	\N
140	157	directus_fields	35	{"sort":2,"hidden":true,"collection":"faq_categories_translations","field":"faq_categories_id"}	{"sort":2,"hidden":true,"collection":"faq_categories_translations","field":"faq_categories_id"}	\N	\N
68	77	directus_fields	30	{"sort":9,"interface":"select-dropdown-m2o","special":["m2o"],"options":{"template":"{{translations.title}}"},"collection":"faq_content","field":"category"}	{"sort":9,"interface":"select-dropdown-m2o","special":["m2o"],"options":{"template":"{{translations.title}}"},"collection":"faq_content","field":"category"}	\N	\N
69	78	directus_permissions	1	{"role":null,"collection":"faq_categories","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":null,"collection":"faq_categories","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
70	79	directus_permissions	2	{"role":null,"collection":"faq_categories_translations","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":null,"collection":"faq_categories_translations","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
71	80	directus_permissions	3	{"role":null,"collection":"faq_content","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":null,"collection":"faq_content","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
72	81	directus_permissions	4	{"role":null,"collection":"faq_content_translations","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":null,"collection":"faq_content_translations","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
73	82	directus_permissions	5	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
74	83	directus_permissions	6	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories","action":"create","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories","action":"create","fields":["*"],"permissions":{},"validation":{}}	\N	\N
75	84	directus_permissions	7	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"create","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"create","fields":["*"],"permissions":{},"validation":{}}	\N	\N
76	85	directus_permissions	8	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
77	86	directus_permissions	9	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
78	87	directus_permissions	10	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content_translations","action":"create","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content_translations","action":"create","fields":["*"],"permissions":{},"validation":{}}	\N	\N
81	90	faq_categories	8575ac79-0d76-41a2-8dcb-b0bada51130c	{"translations":{"create":[{"languages_id":{"code":"fr-FR"},"title":"Création de compte"},{"languages_id":{"code":"en-GB"},"title":"Account creation"}],"update":[],"delete":[]},"published":true}	{"translations":{"create":[{"languages_id":{"code":"fr-FR"},"title":"Création de compte"},{"languages_id":{"code":"en-GB"},"title":"Account creation"}],"update":[],"delete":[]},"published":true}	\N	\N
82	91	directus_permissions	11	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content","action":"create","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content","action":"create","fields":["*"],"permissions":{},"validation":{}}	\N	\N
83	92	directus_permissions	12	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"create","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"create","fields":["*"],"permissions":{},"validation":{}}	\N	\N
84	93	directus_permissions	13	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
90	99	directus_permissions	15	{"id":15,"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"delete","permissions":{},"validation":{},"presets":null,"fields":["*"]}	{"permissions":{},"validation":{},"fields":["*"]}	\N	\N
92	101	directus_permissions	16	{"id":16,"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"share","permissions":{},"validation":{},"presets":null,"fields":["*"]}	{"permissions":{},"validation":{},"fields":["*"]}	\N	\N
96	107	directus_permissions	19	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content_translations","action":"delete","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content_translations","action":"delete","fields":["*"],"permissions":{},"validation":{}}	\N	\N
98	108	directus_permissions	20	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content_translations","action":"share","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content_translations","action":"share","fields":["*"],"permissions":{},"validation":{}}	\N	\N
100	111	directus_permissions	22	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content","action":"delete","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content","action":"delete","fields":["*"],"permissions":{},"validation":{}}	\N	\N
101	109	directus_permissions	11	{"id":11,"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content","action":"create","permissions":{},"validation":{},"presets":null,"fields":["*"]}	{"permissions":{},"validation":{},"fields":["*"]}	\N	\N
104	116	directus_permissions	24	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"update","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"update","fields":["*"],"permissions":{},"validation":{}}	\N	\N
106	115	directus_permissions	8	{"id":8,"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"read","permissions":{},"validation":{},"presets":null,"fields":["*"]}	{"permissions":{},"validation":{},"fields":["*"]}	\N	\N
141	158	directus_fields	36	{"sort":3,"hidden":true,"collection":"faq_categories_translations","field":"languages_code"}	{"sort":3,"hidden":true,"collection":"faq_categories_translations","field":"languages_code"}	\N	\N
109	119	directus_permissions	27	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories","action":"update","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories","action":"update","fields":["*"],"permissions":{},"validation":{}}	\N	\N
110	122	directus_permissions	28	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories","action":"share","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories","action":"share","fields":["*"],"permissions":{},"validation":{}}	\N	\N
116	128	directus_files	e53cfad0-d4a8-4158-bc32-b5f41b24c73e	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Pencil","filename_download":"pencil.png","type":"image/png","storage":"local"}	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Pencil","filename_download":"pencil.png","type":"image/png","storage":"local"}	\N	\N
119	132	faq_categories	e71ff11c-c405-475c-ab08-66512c596500	{"translations":{"create":[{"title":"Plan creation","languages_id":{"code":"en-GB"}},{"languages_id":{"code":"fr-FR"},"title":"Création de plan"}],"update":[],"delete":[]},"published":true}	{"translations":{"create":[{"title":"Plan creation","languages_id":{"code":"en-GB"}},{"languages_id":{"code":"fr-FR"},"title":"Création de plan"}],"update":[],"delete":[]},"published":true}	\N	\N
85	94	directus_permissions	14	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"update","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"update","fields":["*"],"permissions":{},"validation":{}}	\N	\N
86	95	directus_permissions	15	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"delete","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"delete","fields":["*"],"permissions":{},"validation":{}}	\N	\N
87	96	directus_permissions	16	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"share","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"share","fields":["*"],"permissions":{},"validation":{}}	\N	\N
88	97	directus_permissions	12	{"id":12,"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"create","permissions":{},"validation":{},"presets":null,"fields":["*"]}	{"permissions":{},"validation":{},"fields":["*"]}	\N	\N
89	98	directus_permissions	13	{"id":13,"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"read","permissions":{},"validation":{},"presets":null,"fields":["*"]}	{"permissions":{},"validation":{},"fields":["*"]}	\N	\N
91	100	directus_permissions	14	{"id":14,"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"update","permissions":{},"validation":{},"presets":null,"fields":["*"]}	{"permissions":{},"validation":{},"fields":["*"]}	\N	\N
93	102	directus_permissions	17	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content_translations","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content_translations","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
94	104	directus_permissions	10	{"id":10,"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content_translations","action":"create","permissions":{},"validation":{},"presets":null,"fields":["*"]}	{"permissions":{},"validation":{},"fields":["*"]}	\N	\N
95	106	directus_permissions	18	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content_translations","action":"update","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content_translations","action":"update","fields":["*"],"permissions":{},"validation":{}}	\N	\N
97	105	directus_permissions	17	{"id":17,"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content_translations","action":"read","permissions":{},"validation":{},"presets":null,"fields":["*"]}	{"permissions":{},"validation":{},"fields":["*"]}	\N	\N
99	110	directus_permissions	21	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content","action":"update","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content","action":"update","fields":["*"],"permissions":{},"validation":{}}	\N	\N
102	112	directus_permissions	9	{"id":9,"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content","action":"read","permissions":{},"validation":{},"presets":null,"fields":["*"]}	{"permissions":{},"validation":{},"fields":["*"]}	\N	\N
103	113	directus_permissions	23	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content","action":"share","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_content","action":"share","fields":["*"],"permissions":{},"validation":{}}	\N	\N
105	114	directus_permissions	7	{"id":7,"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"create","permissions":{},"validation":{},"presets":null,"fields":["*"]}	{"permissions":{},"validation":{},"fields":["*"]}	\N	\N
107	117	directus_permissions	25	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"share","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"share","fields":["*"],"permissions":{},"validation":{}}	\N	\N
108	118	directus_permissions	26	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"delete","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"delete","fields":["*"],"permissions":{},"validation":{}}	\N	\N
111	123	directus_permissions	29	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories","action":"delete","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories","action":"delete","fields":["*"],"permissions":{},"validation":{}}	\N	\N
112	120	directus_permissions	6	{"id":6,"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories","action":"create","permissions":{},"validation":{},"presets":null,"fields":["*"]}	{"permissions":{},"validation":{},"fields":["*"]}	\N	\N
113	121	directus_permissions	5	{"id":5,"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories","action":"read","permissions":{},"validation":{},"presets":null,"fields":["*"]}	{"permissions":{},"validation":{},"fields":["*"]}	\N	\N
114	124	directus_permissions	30	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"share","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"languages","action":"share","fields":["*"],"permissions":{},"validation":{}}	\N	\N
115	126	directus_files	e733d9d4-0e10-4985-baa3-0c0d2002790c	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Dmp Opidor","filename_download":"dmp-opidor.png","type":"image/png","storage":"local"}	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Dmp Opidor","filename_download":"dmp-opidor.png","type":"image/png","storage":"local"}	\N	\N
120	133	directus_files	0500bb4a-bb32-48d4-86ba-df48fc3f0d87	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Pencil","filename_download":"pencil.png","type":"image/png","storage":"local"}	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Pencil","filename_download":"pencil.png","type":"image/png","storage":"local"}	\N	\N
121	136	directus_files	541cbca4-3b1d-466a-8227-41cbcac99fbf	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Pencil","filename_download":"pencil.png","type":"image/png","storage":"local"}	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Pencil","filename_download":"pencil.png","type":"image/png","storage":"local"}	\N	\N
124	139	faq_categories	30824b70-d55c-4bd8-b626-075d695ca166	{"translations":{"create":[{"title":"Ma première catégorie","languages_id":{"code":"fr-FR"}},{"title":"My first category","languages_id":{"code":"en-GB"}}],"update":[],"delete":[]},"icon":"541cbca4-3b1d-466a-8227-41cbcac99fbf","published":true}	{"translations":{"create":[{"title":"Ma première catégorie","languages_id":{"code":"fr-FR"}},{"title":"My first category","languages_id":{"code":"en-GB"}}],"update":[],"delete":[]},"icon":"541cbca4-3b1d-466a-8227-41cbcac99fbf","published":true}	\N	\N
127	142	faq_content	1	{"translations":{"create":[{"question":"Une question","languages_code":{"code":"fr-FR"},"answer":"<p>Une reponse</p>"},{"question":"A question","languages_code":{"code":"en-GB"},"answer":"<p>An answer</p>"}],"update":[],"delete":[]},"published":true,"category":"30824b70-d55c-4bd8-b626-075d695ca166"}	{"translations":{"create":[{"question":"Une question","languages_code":{"code":"fr-FR"},"answer":"<p>Une reponse</p>"},{"question":"A question","languages_code":{"code":"en-GB"},"answer":"<p>An answer</p>"}],"update":[],"delete":[]},"published":true,"category":"30824b70-d55c-4bd8-b626-075d695ca166"}	\N	\N
125	140	faq_content_translations	1	{"question":"Une question","languages_code":{"code":"fr-FR"},"answer":"<p>Une reponse</p>","faq_content_id":1}	{"question":"Une question","languages_code":{"code":"fr-FR"},"answer":"<p>Une reponse</p>","faq_content_id":1}	127	\N
126	141	faq_content_translations	2	{"question":"A question","languages_code":{"code":"en-GB"},"answer":"<p>An answer</p>","faq_content_id":1}	{"question":"A question","languages_code":{"code":"en-GB"},"answer":"<p>An answer</p>","faq_content_id":1}	127	\N
128	144	directus_fields	31	{"sort":10,"interface":"select-dropdown-m2o","special":["m2o"],"options":{"template":"{{translations.question}}"},"collection":"faq_categories","field":"questions"}	{"sort":10,"interface":"select-dropdown-m2o","special":["m2o"],"options":{"template":"{{translations.question}}"},"collection":"faq_categories","field":"questions"}	\N	\N
129	145	faq_categories	30824b70-d55c-4bd8-b626-075d695ca166	{"id":"30824b70-d55c-4bd8-b626-075d695ca166","sort":null,"user_created":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_created":"2023-12-07T12:54:51.769Z","user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2023-12-07T13:00:39.183Z","icon":"541cbca4-3b1d-466a-8227-41cbcac99fbf","published":true,"questions":1,"translations":[5,6]}	{"questions":1,"user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2023-12-07T13:00:39.183Z"}	\N	\N
130	146	directus_fields	32	{"sort":5,"interface":"input","special":null,"collection":"faq_categories_translations","field":"languages_code"}	{"sort":5,"interface":"input","special":null,"collection":"faq_categories_translations","field":"languages_code"}	\N	\N
131	147	directus_fields	8	{"id":8,"collection":"faq_categories_translations","field":"id","special":null,"interface":null,"options":null,"display":null,"display_options":null,"readonly":false,"hidden":true,"sort":1,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories_translations","field":"id","sort":1,"group":null}	\N	\N
132	148	directus_fields	12	{"id":12,"collection":"faq_categories_translations","field":"faq_categories_id","special":null,"interface":null,"options":null,"display":null,"display_options":null,"readonly":false,"hidden":true,"sort":2,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories_translations","field":"faq_categories_id","sort":2,"group":null}	\N	\N
133	149	directus_fields	32	{"id":32,"collection":"faq_categories_translations","field":"languages_code","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":3,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories_translations","field":"languages_code","sort":3,"group":null}	\N	\N
134	150	directus_fields	13	{"id":13,"collection":"faq_categories_translations","field":"languages_id","special":null,"interface":null,"options":null,"display":null,"display_options":null,"readonly":false,"hidden":true,"sort":4,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories_translations","field":"languages_id","sort":4,"group":null}	\N	\N
135	151	directus_fields	16	{"id":16,"collection":"faq_categories_translations","field":"title","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":5,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories_translations","field":"title","sort":5,"group":null}	\N	\N
136	152	directus_fields	32	{"id":32,"collection":"faq_categories_translations","field":"languages_code","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":true,"sort":3,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories_translations","field":"languages_code","hidden":true}	\N	\N
137	154	directus_fields	33	{"sort":11,"interface":"translations","special":["translations"],"options":{"defaultLanguage":"fr-FR"},"collection":"faq_categories","field":"translations"}	{"sort":11,"interface":"translations","special":["translations"],"options":{"defaultLanguage":"fr-FR"},"collection":"faq_categories","field":"translations"}	\N	\N
138	155	directus_fields	34	{"sort":1,"hidden":true,"field":"id","collection":"faq_categories_translations"}	{"sort":1,"hidden":true,"field":"id","collection":"faq_categories_translations"}	\N	\N
139	156	directus_collections	faq_categories_translations	{"hidden":true,"icon":"import_export","collection":"faq_categories_translations"}	{"hidden":true,"icon":"import_export","collection":"faq_categories_translations"}	\N	\N
142	159	directus_fields	1	{"id":1,"collection":"faq_categories","field":"id","special":["uuid"],"interface":"input","options":null,"display":null,"display_options":null,"readonly":true,"hidden":true,"sort":1,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories","field":"id","sort":1,"group":null}	\N	\N
157	174	directus_collections	faq_categories	{"collection":"faq_categories","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":null,"sort":1,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":1,"group":null}	\N	\N
158	175	directus_collections	faq_content	{"collection":"faq_content","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":null,"sort":2,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":2,"group":null}	\N	\N
159	176	directus_collections	languages	{"collection":"languages","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":3,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":3,"group":null}	\N	\N
143	160	directus_fields	2	{"id":2,"collection":"faq_categories","field":"sort","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":true,"sort":2,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories","field":"sort","sort":2,"group":null}	\N	\N
144	161	directus_fields	3	{"id":3,"collection":"faq_categories","field":"user_created","special":["user-created"],"interface":"select-dropdown-m2o","options":{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"},"display":"user","display_options":null,"readonly":true,"hidden":true,"sort":3,"width":"half","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories","field":"user_created","sort":3,"group":null}	\N	\N
145	162	directus_fields	4	{"id":4,"collection":"faq_categories","field":"date_created","special":["date-created"],"interface":"datetime","options":null,"display":"datetime","display_options":{"relative":true},"readonly":true,"hidden":true,"sort":4,"width":"half","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories","field":"date_created","sort":4,"group":null}	\N	\N
146	163	directus_fields	5	{"id":5,"collection":"faq_categories","field":"user_updated","special":["user-updated"],"interface":"select-dropdown-m2o","options":{"template":"{{avatar.$thumbnail}} {{first_name}} {{last_name}}"},"display":"user","display_options":null,"readonly":true,"hidden":true,"sort":5,"width":"half","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories","field":"user_updated","sort":5,"group":null}	\N	\N
147	164	directus_fields	6	{"id":6,"collection":"faq_categories","field":"date_updated","special":["date-updated"],"interface":"datetime","options":null,"display":"datetime","display_options":{"relative":true},"readonly":true,"hidden":true,"sort":6,"width":"half","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories","field":"date_updated","sort":6,"group":null}	\N	\N
148	165	directus_fields	33	{"id":33,"collection":"faq_categories","field":"translations","special":["translations"],"interface":"translations","options":{"defaultLanguage":"fr-FR"},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":7,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories","field":"translations","sort":7,"group":null}	\N	\N
149	166	directus_fields	14	{"id":14,"collection":"faq_categories","field":"icon","special":["file"],"interface":"file-image","options":{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd"},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":8,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories","field":"icon","sort":8,"group":null}	\N	\N
150	167	directus_fields	15	{"id":15,"collection":"faq_categories","field":"published","special":["cast-boolean"],"interface":"boolean","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":9,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories","field":"published","sort":9,"group":null}	\N	\N
151	168	directus_fields	31	{"id":31,"collection":"faq_categories","field":"questions","special":["m2o"],"interface":"select-dropdown-m2o","options":{"template":"{{translations.question}}"},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":10,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories","field":"questions","sort":10,"group":null}	\N	\N
152	169	directus_collections	faq_categories	{"collection":"faq_categories","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":null,"sort":1,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":1,"group":null}	\N	\N
153	170	directus_collections	faq_categories_translations	{"collection":"faq_categories_translations","icon":"import_export","note":null,"display_template":null,"hidden":true,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":2,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":2,"group":null}	\N	\N
154	171	directus_collections	faq_content	{"collection":"faq_content","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":null,"sort":3,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":3,"group":null}	\N	\N
155	172	directus_collections	languages	{"collection":"languages","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":4,"group":null,"collapse":"open","preview_url":null,"versioning":false}	{"sort":4,"group":null}	\N	\N
156	173	directus_collections	faq_categories_translations	{"collection":"faq_categories_translations","icon":"import_export","note":null,"display_template":null,"hidden":true,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":1,"group":"faq_categories","collapse":"open","preview_url":null,"versioning":false}	{"sort":1,"group":"faq_categories"}	\N	\N
160	177	directus_fields	37	{"sort":4,"interface":"input","special":null,"collection":"faq_categories_translations","field":"title"}	{"sort":4,"interface":"input","special":null,"collection":"faq_categories_translations","field":"title"}	\N	\N
161	178	directus_permissions	31	{"role":null,"collection":"faq_categories_translations","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":null,"collection":"faq_categories_translations","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
164	181	faq_categories	30824b70-d55c-4bd8-b626-075d695ca166	{"id":"30824b70-d55c-4bd8-b626-075d695ca166","sort":null,"user_created":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_created":"2023-12-07T12:54:51.769Z","user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2023-12-07T13:03:21.366Z","icon":"541cbca4-3b1d-466a-8227-41cbcac99fbf","published":true,"questions":1,"translations":[1,2]}	{"user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2023-12-07T13:03:21.366Z"}	\N	\N
162	179	faq_categories_translations	1	{"title":"Ma catégorie","languages_code":{"code":"fr-FR"},"faq_categories_id":"30824b70-d55c-4bd8-b626-075d695ca166"}	{"title":"Ma catégorie","languages_code":{"code":"fr-FR"},"faq_categories_id":"30824b70-d55c-4bd8-b626-075d695ca166"}	164	\N
163	180	faq_categories_translations	2	{"title":"My category","languages_code":{"code":"en-GB"},"faq_categories_id":"30824b70-d55c-4bd8-b626-075d695ca166"}	{"title":"My category","languages_code":{"code":"en-GB"},"faq_categories_id":"30824b70-d55c-4bd8-b626-075d695ca166"}	164	\N
165	182	directus_fields	38	{"sort":11,"interface":"file","special":["file"],"options":{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd"},"collection":"faq_categories","field":"img"}	{"sort":11,"interface":"file","special":["file"],"options":{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd"},"collection":"faq_categories","field":"img"}	\N	\N
166	183	faq_categories	30824b70-d55c-4bd8-b626-075d695ca166	{"id":"30824b70-d55c-4bd8-b626-075d695ca166","sort":null,"user_created":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_created":"2023-12-07T12:54:51.769Z","user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2023-12-07T13:04:33.521Z","icon":"541cbca4-3b1d-466a-8227-41cbcac99fbf","published":true,"questions":1,"img":"541cbca4-3b1d-466a-8227-41cbcac99fbf","translations":[1,2]}	{"img":"541cbca4-3b1d-466a-8227-41cbcac99fbf","user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2023-12-07T13:04:33.521Z"}	\N	\N
167	184	directus_permissions	32	{"role":null,"collection":"directus_collections","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":null,"collection":"directus_collections","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
168	185	directus_permissions	33	{"role":null,"collection":"directus_files","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":null,"collection":"directus_files","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
169	187	directus_users	b1aca500-a889-4138-b44b-429ed58b8125	{"first_name":"Steven","last_name":"WILMOUTH","email":"steven.wilmouth@inist.fr","password":"**********","email_notifications":false,"role":"19467255-1682-415f-b26a-77b5c5268d27"}	{"first_name":"Steven","last_name":"WILMOUTH","email":"steven.wilmouth@inist.fr","password":"**********","email_notifications":false,"role":"19467255-1682-415f-b26a-77b5c5268d27"}	\N	\N
170	188	directus_collections	faq_categories	{"collection":"faq_categories","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":null,"sort":1,"group":null,"collapse":"open","preview_url":null,"versioning":true}	{"versioning":true}	\N	\N
171	189	directus_collections	faq_content	{"collection":"faq_content","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":null,"sort":2,"group":null,"collapse":"open","preview_url":null,"versioning":true}	{"versioning":true}	\N	\N
172	192	directus_users	b1aca500-a889-4138-b44b-429ed58b8125	{"id":"b1aca500-a889-4138-b44b-429ed58b8125","first_name":"Steven","last_name":"WILMOUTH","email":"steven.wilmouth@inist.fr","password":"**********","location":null,"title":null,"description":null,"tags":null,"avatar":null,"language":null,"tfa_secret":null,"status":"active","role":"1d82af5b-8e27-4d24-8f83-3a0669f68855","token":null,"last_access":"2023-12-07T13:10:49.614Z","last_page":"/content/faq_categories/30824b70-d55c-4bd8-b626-075d695ca166","provider":"default","external_identifier":null,"auth_data":null,"email_notifications":false,"appearance":null,"theme_dark":null,"theme_light":null,"theme_light_overrides":null,"theme_dark_overrides":null}	{"role":"1d82af5b-8e27-4d24-8f83-3a0669f68855"}	\N	\N
173	193	directus_users	19a62574-2afc-48a3-a8f6-df7013162b89	{"id":"19a62574-2afc-48a3-a8f6-df7013162b89","first_name":"Françoise","last_name":"COSSERAT","email":"francoise.cosserat@inist.fr","password":"**********","location":null,"title":null,"description":null,"tags":null,"avatar":null,"language":null,"tfa_secret":null,"status":"active","role":"19467255-1682-415f-b26a-77b5c5268d27","token":null,"last_access":null,"last_page":null,"provider":"default","external_identifier":null,"auth_data":null,"email_notifications":true,"appearance":null,"theme_dark":null,"theme_light":null,"theme_light_overrides":null,"theme_dark_overrides":null}	{"role":"19467255-1682-415f-b26a-77b5c5268d27"}	\N	\N
174	194	directus_permissions	34	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"create","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"create","fields":["*"],"permissions":{},"validation":{}}	\N	\N
175	195	directus_permissions	35	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
176	196	directus_permissions	36	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"update","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"update","fields":["*"],"permissions":{},"validation":{}}	\N	\N
177	197	directus_permissions	37	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"share","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"share","fields":["*"],"permissions":{},"validation":{}}	\N	\N
178	198	directus_permissions	38	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"delete","fields":["*"],"permissions":{},"validation":{}}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"faq_categories_translations","action":"delete","fields":["*"],"permissions":{},"validation":{}}	\N	\N
179	199	directus_permissions	39	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"directus_activity","action":"update"}	{"role":"19467255-1682-415f-b26a-77b5c5268d27","collection":"directus_activity","action":"update"}	\N	\N
180	202	directus_files	30dffb61-ac17-48d9-b6a7-515f6a9e1576	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Dmp Opidor","filename_download":"dmp-opidor.png","type":"image/png","storage":"local"}	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Dmp Opidor","filename_download":"dmp-opidor.png","type":"image/png","storage":"local"}	\N	\N
182	204	faq_content	1	{"id":1,"sort":null,"user_created":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_created":"2023-12-07T12:56:32.557Z","user_updated":"624fb2f6-29df-4e7f-836b-4e9eb64f235e","date_updated":"2023-12-08T07:37:30.156Z","published":true,"category":"30824b70-d55c-4bd8-b626-075d695ca166","translations":[1,2]}	{"user_updated":"624fb2f6-29df-4e7f-836b-4e9eb64f235e","date_updated":"2023-12-08T07:37:30.156Z"}	\N	\N
181	203	faq_content_translations	1	{"id":1,"faq_content_id":1,"languages_code":"fr-FR","question":"Une question","answer":"<h1>Une reponse<img src=\\"http://vtopidor.intra.inist.fr:8055/assets/30dffb61-ac17-48d9-b6a7-515f6a9e1576?width=602&amp;height=240\\" alt=\\"Dmp Opidor\\"></h1>"}	{"faq_content_id":"1","languages_code":"fr-FR","answer":"<h1>Une reponse<img src=\\"http://vtopidor.intra.inist.fr:8055/assets/30dffb61-ac17-48d9-b6a7-515f6a9e1576?width=602&amp;height=240\\" alt=\\"Dmp Opidor\\"></h1>"}	182	\N
183	205	directus_files	7ad1dbf4-f94a-4a89-a767-714305aa6595	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Img 8035","filename_download":"IMG_8035.mp4","type":"video/mp4","storage":"local"}	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Img 8035","filename_download":"IMG_8035.mp4","type":"video/mp4","storage":"local"}	\N	\N
185	207	faq_content	2	{"translations":{"create":[{"languages_code":{"code":"fr-FR"},"question":"Peut-on ajouter des videos ?","answer":"<p><video controls=\\"controls\\" width=\\"300\\" height=\\"150\\"><source src=\\"http://vtopidor.intra.inist.fr:8055/assets/7ad1dbf4-f94a-4a89-a767-714305aa6595\\" type=\\"video/mp4\\"></video></p>"}],"update":[],"delete":[]},"published":true}	{"translations":{"create":[{"languages_code":{"code":"fr-FR"},"question":"Peut-on ajouter des videos ?","answer":"<p><video controls=\\"controls\\" width=\\"300\\" height=\\"150\\"><source src=\\"http://vtopidor.intra.inist.fr:8055/assets/7ad1dbf4-f94a-4a89-a767-714305aa6595\\" type=\\"video/mp4\\"></video></p>"}],"update":[],"delete":[]},"published":true}	\N	\N
184	206	faq_content_translations	3	{"languages_code":{"code":"fr-FR"},"question":"Peut-on ajouter des videos ?","answer":"<p><video controls=\\"controls\\" width=\\"300\\" height=\\"150\\"><source src=\\"http://vtopidor.intra.inist.fr:8055/assets/7ad1dbf4-f94a-4a89-a767-714305aa6595\\" type=\\"video/mp4\\"></video></p>","faq_content_id":2}	{"languages_code":{"code":"fr-FR"},"question":"Peut-on ajouter des videos ?","answer":"<p><video controls=\\"controls\\" width=\\"300\\" height=\\"150\\"><source src=\\"http://vtopidor.intra.inist.fr:8055/assets/7ad1dbf4-f94a-4a89-a767-714305aa6595\\" type=\\"video/mp4\\"></video></p>","faq_content_id":2}	185	\N
186	208	faq_content	2	{"id":2,"sort":null,"user_created":"624fb2f6-29df-4e7f-836b-4e9eb64f235e","date_created":"2023-12-08T07:38:18.006Z","user_updated":"624fb2f6-29df-4e7f-836b-4e9eb64f235e","date_updated":"2023-12-08T07:38:41.880Z","published":true,"category":"30824b70-d55c-4bd8-b626-075d695ca166","translations":[3]}	{"category":"30824b70-d55c-4bd8-b626-075d695ca166","user_updated":"624fb2f6-29df-4e7f-836b-4e9eb64f235e","date_updated":"2023-12-08T07:38:41.880Z"}	\N	\N
187	209	directus_files	dd2e43ec-19e7-4273-b532-4a5650c34f0c	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Audio A","filename_download":"Audio_a.svg","type":"image/svg+xml","storage":"local"}	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Audio A","filename_download":"Audio_a.svg","type":"image/svg+xml","storage":"local"}	\N	\N
190	212	faq_categories	5a0c3ac0-f06c-4c04-9fa7-d56478c1a282	{"translations":{"create":[{"title":"Vidéo","languages_code":{"code":"fr-FR"}},{"title":"Video","languages_code":{"code":"en-GB"}}],"update":[],"delete":[]},"icon":"dd2e43ec-19e7-4273-b532-4a5650c34f0c","published":true}	{"translations":{"create":[{"title":"Vidéo","languages_code":{"code":"fr-FR"}},{"title":"Video","languages_code":{"code":"en-GB"}}],"update":[],"delete":[]},"icon":"dd2e43ec-19e7-4273-b532-4a5650c34f0c","published":true}	\N	\N
188	210	faq_categories_translations	3	{"title":"Vidéo","languages_code":{"code":"fr-FR"},"faq_categories_id":"5a0c3ac0-f06c-4c04-9fa7-d56478c1a282"}	{"title":"Vidéo","languages_code":{"code":"fr-FR"},"faq_categories_id":"5a0c3ac0-f06c-4c04-9fa7-d56478c1a282"}	190	\N
189	211	faq_categories_translations	4	{"title":"Video","languages_code":{"code":"en-GB"},"faq_categories_id":"5a0c3ac0-f06c-4c04-9fa7-d56478c1a282"}	{"title":"Video","languages_code":{"code":"en-GB"},"faq_categories_id":"5a0c3ac0-f06c-4c04-9fa7-d56478c1a282"}	190	\N
191	213	directus_settings	1	{"project_name":"DMP OPIDOR","project_descriptor":"DMP OPIDoR : aide en ligne"}	{"project_name":"DMP OPIDOR","project_descriptor":"DMP OPIDoR : aide en ligne"}	\N	\N
192	214	directus_files	33c82aec-2886-4bfe-9224-5800a89de2fc	{"title":"Dmp Opidor","filename_download":"dmp-opidor.png","type":"image/png","storage":"local"}	{"title":"Dmp Opidor","filename_download":"dmp-opidor.png","type":"image/png","storage":"local"}	\N	\N
193	215	directus_files	2d92cb61-efbe-4574-b7b3-cdf691ebdeca	{"title":"Img 5669","filename_download":"IMG_5669.JPG","type":"image/jpeg","storage":"local"}	{"title":"Img 5669","filename_download":"IMG_5669.JPG","type":"image/jpeg","storage":"local"}	\N	\N
194	216	directus_files	a0db2cde-ebc4-4f9d-bada-084a8b22f9c9	{"title":"Img 5594","filename_download":"IMG_5594.JPG","type":"image/jpeg","storage":"local"}	{"title":"Img 5594","filename_download":"IMG_5594.JPG","type":"image/jpeg","storage":"local"}	\N	\N
195	217	directus_files	b77965d7-1cc6-46be-ac89-e106b6c76ab6	{"title":"Dmp Opidor","filename_download":"dmp-opidor.png","type":"image/png","storage":"local"}	{"title":"Dmp Opidor","filename_download":"dmp-opidor.png","type":"image/png","storage":"local"}	\N	\N
196	218	directus_settings	1	{"id":1,"project_name":"DMP OPIDOR","project_url":null,"project_color":"#429EFF","project_logo":"33c82aec-2886-4bfe-9224-5800a89de2fc","public_foreground":"2d92cb61-efbe-4574-b7b3-cdf691ebdeca","public_background":"a0db2cde-ebc4-4f9d-bada-084a8b22f9c9","public_note":"Bienvenue !","auth_login_attempts":25,"auth_password_policy":null,"storage_asset_transform":"all","storage_asset_presets":null,"custom_css":null,"storage_default_folder":null,"basemaps":null,"mapbox_key":null,"module_bar":null,"project_descriptor":"DMP OPIDoR : aide en ligne","default_language":"en-US","custom_aspect_ratios":null,"public_favicon":"b77965d7-1cc6-46be-ac89-e106b6c76ab6","default_appearance":"dark","default_theme_light":"Directus Color Match","theme_light_overrides":null,"default_theme_dark":null,"theme_dark_overrides":null}	{"project_color":"#429EFF","project_logo":"33c82aec-2886-4bfe-9224-5800a89de2fc","public_foreground":"2d92cb61-efbe-4574-b7b3-cdf691ebdeca","public_background":"a0db2cde-ebc4-4f9d-bada-084a8b22f9c9","public_note":"Bienvenue !","public_favicon":"b77965d7-1cc6-46be-ac89-e106b6c76ab6","default_appearance":"dark","default_theme_light":"Directus Color Match"}	\N	\N
197	219	directus_collections	faq_categories	{"collection":"faq_categories","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":null,"sort":1,"group":null,"collapse":"open","preview_url":"{{questions}}","versioning":true}	{"preview_url":"{{questions}}"}	\N	\N
198	220	directus_fields	37	{"id":37,"collection":"faq_categories_translations","field":"title","special":null,"interface":"input","options":null,"display":"raw","display_options":null,"readonly":false,"hidden":false,"sort":4,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories_translations","field":"title","special":null,"interface":"input","options":null,"display":"raw","display_options":null,"readonly":false,"hidden":false,"sort":4,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	\N	\N
199	221	directus_fields	37	{"id":37,"collection":"faq_categories_translations","field":"title","special":null,"interface":"input","options":null,"display":null,"display_options":{"choices":null},"readonly":false,"hidden":false,"sort":4,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories_translations","field":"title","special":null,"interface":"input","options":null,"display":null,"display_options":{"choices":null},"readonly":false,"hidden":false,"sort":4,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	\N	\N
200	222	directus_fields	37	{"id":37,"collection":"faq_categories_translations","field":"title","special":null,"interface":"input","options":null,"display":null,"display_options":{"choices":null},"readonly":false,"hidden":false,"sort":4,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories_translations","field":"title","special":null,"interface":"input","options":null,"display":null,"display_options":{"choices":null},"readonly":false,"hidden":false,"sort":4,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"group":null,"validation":null,"validation_message":null}	\N	\N
201	223	directus_dashboards	070670d8-a854-485e-a44f-1c717795c094	{"name":"Catégorie","icon":"space_dashboard","color":null,"note":null}	{"name":"Catégorie","icon":"space_dashboard","color":null,"note":null}	\N	\N
202	224	directus_fields	39	{"sort":10,"interface":"list-o2m","special":["o2m"],"collection":"faq_categories","field":"questions"}	{"sort":10,"interface":"list-o2m","special":["o2m"],"collection":"faq_categories","field":"questions"}	\N	\N
203	225	directus_fields	39	{"id":39,"collection":"faq_categories","field":"questions","special":["o2m"],"interface":"list-o2m","options":null,"display":"related-values","display_options":{"template":"{{translations.question}}"},"readonly":false,"hidden":false,"sort":10,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories","field":"questions","special":["o2m"],"interface":"list-o2m","options":null,"display":"related-values","display_options":{"template":"{{translations.question}}"},"readonly":false,"hidden":false,"sort":10,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	\N	\N
204	226	directus_fields	30	{"id":30,"collection":"faq_content","field":"category","special":["m2o"],"interface":"select-dropdown-m2o","options":{"template":"{{translations.title}}"},"display":"related-values","display_options":{"template":"{{translations.title}}"},"readonly":false,"hidden":false,"sort":9,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_content","field":"category","special":["m2o"],"interface":"select-dropdown-m2o","options":{"template":"{{translations.title}}"},"display":"related-values","display_options":{"template":"{{translations.title}}"},"readonly":false,"hidden":false,"sort":9,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	\N	\N
205	227	directus_dashboards	070670d8-a854-485e-a44f-1c717795c094	{"id":"070670d8-a854-485e-a44f-1c717795c094","name":"Catégorie","icon":"space_dashboard","note":null,"date_created":"2023-12-08T08:50:25.677Z","user_created":"624fb2f6-29df-4e7f-836b-4e9eb64f235e","color":"#FFC23B","panels":[]}	{"name":"Catégorie","icon":"space_dashboard","note":null,"color":"#FFC23B"}	\N	\N
206	228	directus_fields	33	{"id":33,"collection":"faq_categories","field":"translations","special":["translations"],"interface":"translations","options":{"defaultLanguage":"fr-FR"},"display":"translations","display_options":{"template":"{{title}}"},"readonly":false,"hidden":false,"sort":7,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	{"collection":"faq_categories","field":"translations","special":["translations"],"interface":"translations","options":{"defaultLanguage":"fr-FR"},"display":"translations","display_options":{"template":"{{title}}"},"readonly":false,"hidden":false,"sort":7,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"group":null,"validation":null,"validation_message":null}	\N	\N
207	229	directus_collections	faq_categories	{"collection":"faq_categories","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":[],"sort":1,"group":null,"collapse":"open","preview_url":"{{questions}}","versioning":true}	{"item_duplication_fields":[]}	\N	\N
208	232	directus_collections	faq_categories	{"collection":"faq_categories","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":"sort","accountability":"all","color":null,"item_duplication_fields":[],"sort":1,"group":null,"collapse":"locked","preview_url":"{{questions}}","versioning":true}	{"collapse":"locked"}	\N	\N
209	233	directus_permissions	40	{"role":null,"collection":"directus_collections","action":"create","fields":["*"],"permissions":{},"validation":{}}	{"role":null,"collection":"directus_collections","action":"create","fields":["*"],"permissions":{},"validation":{}}	\N	\N
210	234	directus_permissions	41	{"role":null,"collection":"directus_collections","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":null,"collection":"directus_collections","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
211	236	directus_permissions	42	{"role":null,"collection":"directus_collections","action":"share","fields":["*"],"permissions":{},"validation":{}}	{"role":null,"collection":"directus_collections","action":"share","fields":["*"],"permissions":{},"validation":{}}	\N	\N
212	240	directus_users	624fb2f6-29df-4e7f-836b-4e9eb64f235e	{"id":"624fb2f6-29df-4e7f-836b-4e9eb64f235e","first_name":"Marie-Christine","last_name":"JACQUEMOT","email":"marie-christine.jacquemot@inist.fr","password":"**********","location":null,"title":null,"description":null,"tags":null,"avatar":null,"language":null,"tfa_secret":null,"status":"active","role":null,"token":null,"last_access":"2023-12-08T11:03:41.933Z","last_page":"/content/faq_content","provider":"default","external_identifier":null,"auth_data":null,"email_notifications":false,"appearance":null,"theme_dark":null,"theme_light":null,"theme_light_overrides":null,"theme_dark_overrides":null}	{"role":null}	\N	\N
213	241	directus_users	b1aca500-a889-4138-b44b-429ed58b8125	{"id":"b1aca500-a889-4138-b44b-429ed58b8125","first_name":"Steven","last_name":"WILMOUTH","email":"steven.wilmouth@inist.fr","password":"**********","location":null,"title":null,"description":null,"tags":null,"avatar":null,"language":null,"tfa_secret":null,"status":"active","role":null,"token":null,"last_access":"2023-12-07T13:10:49.614Z","last_page":"/content/faq_categories/30824b70-d55c-4bd8-b626-075d695ca166","provider":"default","external_identifier":null,"auth_data":null,"email_notifications":false,"appearance":null,"theme_dark":null,"theme_light":null,"theme_light_overrides":null,"theme_dark_overrides":null}	{"role":null}	\N	\N
214	242	directus_users	c2f71b69-f015-4f40-a239-a9a83ff7f3ca	{"id":"c2f71b69-f015-4f40-a239-a9a83ff7f3ca","first_name":"Benjamin","last_name":"FAURE","email":"benjamin.faure@inist.fr","password":"**********","location":null,"title":null,"description":null,"tags":null,"avatar":null,"language":null,"tfa_secret":null,"status":"active","role":null,"token":null,"last_access":null,"last_page":null,"provider":"default","external_identifier":null,"auth_data":null,"email_notifications":false,"appearance":null,"theme_dark":null,"theme_light":null,"theme_light_overrides":null,"theme_dark_overrides":null}	{"role":null}	\N	\N
217	253	faq_categories	9936d8a2-8369-4f00-9c10-34bb0391af3a	{"translations":{"create":[{"title":"Une catégorie","languages_code":{"code":"fr-FR"}},{"title":"A category","languages_code":{"code":"en-GB"}}],"update":[],"delete":[]},"published":true}	{"translations":{"create":[{"title":"Une catégorie","languages_code":{"code":"fr-FR"}},{"title":"A category","languages_code":{"code":"en-GB"}}],"update":[],"delete":[]},"published":true}	\N	\N
215	251	faq_categories_translations	5	{"title":"Une catégorie","languages_code":{"code":"fr-FR"},"faq_categories_id":"9936d8a2-8369-4f00-9c10-34bb0391af3a"}	{"title":"Une catégorie","languages_code":{"code":"fr-FR"},"faq_categories_id":"9936d8a2-8369-4f00-9c10-34bb0391af3a"}	217	\N
216	252	faq_categories_translations	6	{"title":"A category","languages_code":{"code":"en-GB"},"faq_categories_id":"9936d8a2-8369-4f00-9c10-34bb0391af3a"}	{"title":"A category","languages_code":{"code":"en-GB"},"faq_categories_id":"9936d8a2-8369-4f00-9c10-34bb0391af3a"}	217	\N
220	256	faq_content	3	{"translations":{"create":[{"question":"Une réponse","languages_code":{"code":"fr-FR"},"answer":"<p>Ma super r&eacute;ponse</p>"},{"question":"An answer","languages_code":{"code":"en-GB"},"answer":"<p>My awesome answer</p>"}],"update":[],"delete":[]},"published":true}	{"translations":{"create":[{"question":"Une réponse","languages_code":{"code":"fr-FR"},"answer":"<p>Ma super r&eacute;ponse</p>"},{"question":"An answer","languages_code":{"code":"en-GB"},"answer":"<p>My awesome answer</p>"}],"update":[],"delete":[]},"published":true}	\N	\N
218	254	faq_content_translations	4	{"question":"Une réponse","languages_code":{"code":"fr-FR"},"answer":"<p>Ma super r&eacute;ponse</p>","faq_content_id":3}	{"question":"Une réponse","languages_code":{"code":"fr-FR"},"answer":"<p>Ma super r&eacute;ponse</p>","faq_content_id":3}	220	\N
219	255	faq_content_translations	5	{"question":"An answer","languages_code":{"code":"en-GB"},"answer":"<p>My awesome answer</p>","faq_content_id":3}	{"question":"An answer","languages_code":{"code":"en-GB"},"answer":"<p>My awesome answer</p>","faq_content_id":3}	220	\N
221	258	faq_categories_translations	7	{"title":"Une catégorie","languages_code":{"code":"fr-FR"},"faq_categories_id":"1f7143bb-d35e-4e9a-a52e-8c70318d9361"}	{"title":"Une catégorie","languages_code":{"code":"fr-FR"},"faq_categories_id":"1f7143bb-d35e-4e9a-a52e-8c70318d9361"}	223	\N
222	259	faq_categories_translations	8	{"title":"A category","languages_code":{"code":"en-GB"},"faq_categories_id":"1f7143bb-d35e-4e9a-a52e-8c70318d9361"}	{"title":"A category","languages_code":{"code":"en-GB"},"faq_categories_id":"1f7143bb-d35e-4e9a-a52e-8c70318d9361"}	223	\N
224	261	faq_content	3	{"id":3,"sort":null,"user_created":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_created":"2024-03-21T09:15:41.427Z","user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2024-03-21T09:17:07.155Z","published":true,"category":"1f7143bb-d35e-4e9a-a52e-8c70318d9361","translations":[4,5]}	{"category":"1f7143bb-d35e-4e9a-a52e-8c70318d9361","user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2024-03-21T09:17:07.155Z"}	\N	\N
223	260	faq_categories	1f7143bb-d35e-4e9a-a52e-8c70318d9361	{"translations":{"create":[{"title":"Une catégorie","languages_code":{"code":"fr-FR"}},{"title":"A category","languages_code":{"code":"en-GB"}}],"update":[],"delete":[]},"published":true}	{"translations":{"create":[{"title":"Une catégorie","languages_code":{"code":"fr-FR"}},{"title":"A category","languages_code":{"code":"en-GB"}}],"update":[],"delete":[]},"published":true}	224	\N
225	265	directus_permissions	43	{"role":null,"collection":"languages","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":null,"collection":"languages","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
226	267	directus_permissions	44	{"role":null,"collection":"languages","action":"read","fields":["*"],"permissions":{},"validation":{}}	{"role":null,"collection":"languages","action":"read","fields":["*"],"permissions":{},"validation":{}}	\N	\N
227	268	directus_files	4adae99e-e1e1-467c-ba78-d7297ef78524	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Info","filename_download":"info.svg","type":"image/svg+xml","storage":"local"}	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Info","filename_download":"info.svg","type":"image/svg+xml","storage":"local"}	\N	\N
228	269	faq_categories	1f7143bb-d35e-4e9a-a52e-8c70318d9361	{"id":"1f7143bb-d35e-4e9a-a52e-8c70318d9361","sort":null,"user_created":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_created":"2024-03-21T09:17:07.133Z","user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2024-03-22T10:27:47.881Z","icon":"4adae99e-e1e1-467c-ba78-d7297ef78524","published":true,"questions":[3],"translations":[7,8]}	{"icon":"4adae99e-e1e1-467c-ba78-d7297ef78524","user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2024-03-22T10:27:47.881Z"}	\N	\N
230	271	faq_content	3	{"id":3,"sort":null,"user_created":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_created":"2024-03-21T09:15:41.427Z","user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2024-03-22T10:41:50.923Z","published":true,"category":"1f7143bb-d35e-4e9a-a52e-8c70318d9361","translations":[4,5]}	{"user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2024-03-22T10:41:50.923Z"}	\N	\N
229	270	faq_content_translations	4	{"id":4,"faq_content_id":3,"languages_code":"fr-FR","question":"Une question","answer":"<p>Une super r&eacute;ponse</p>"}	{"faq_content_id":"3","languages_code":"fr-FR","question":"Une question","answer":"<p>Une super r&eacute;ponse</p>"}	230	\N
232	273	faq_content	3	{"id":3,"sort":null,"user_created":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_created":"2024-03-21T09:15:41.427Z","user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2024-03-22T10:42:04.771Z","published":true,"category":"1f7143bb-d35e-4e9a-a52e-8c70318d9361","translations":[4,5]}	{"user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2024-03-22T10:42:04.771Z"}	\N	\N
231	272	faq_content_translations	5	{"id":5,"faq_content_id":3,"languages_code":"en-GB","question":"An question","answer":"<p>An awesome answer</p>"}	{"faq_content_id":"3","languages_code":"en-GB","question":"An question","answer":"<p>An awesome answer</p>"}	232	\N
235	276	faq_content	4	{"translations":{"create":[{"question":"Une autre question","languages_code":{"code":"fr-FR"},"answer":"<p>Une autre r&eacute;ponse</p>"},{"question":"An other question","languages_code":{"code":"en-GB"},"answer":"<p>An other answer</p>"}],"update":[],"delete":[]},"published":true,"category":"1f7143bb-d35e-4e9a-a52e-8c70318d9361"}	{"translations":{"create":[{"question":"Une autre question","languages_code":{"code":"fr-FR"},"answer":"<p>Une autre r&eacute;ponse</p>"},{"question":"An other question","languages_code":{"code":"en-GB"},"answer":"<p>An other answer</p>"}],"update":[],"delete":[]},"published":true,"category":"1f7143bb-d35e-4e9a-a52e-8c70318d9361"}	\N	\N
233	274	faq_content_translations	6	{"question":"Une autre question","languages_code":{"code":"fr-FR"},"answer":"<p>Une autre r&eacute;ponse</p>","faq_content_id":4}	{"question":"Une autre question","languages_code":{"code":"fr-FR"},"answer":"<p>Une autre r&eacute;ponse</p>","faq_content_id":4}	235	\N
234	275	faq_content_translations	7	{"question":"An other question","languages_code":{"code":"en-GB"},"answer":"<p>An other answer</p>","faq_content_id":4}	{"question":"An other question","languages_code":{"code":"en-GB"},"answer":"<p>An other answer</p>","faq_content_id":4}	235	\N
236	277	directus_files	9b18efa3-a8e7-47ad-9836-6aa1ed5d39f7	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Rediger","filename_download":"rediger.xml","type":"text/xml","storage":"local"}	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Rediger","filename_download":"rediger.xml","type":"text/xml","storage":"local"}	\N	\N
237	278	directus_files	858b3148-7d99-4314-b471-7a5623c76557	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Redact","filename_download":"redact.svg","type":"image/svg+xml","storage":"local"}	{"folder":"e07a884b-cfa0-4ec1-ba2a-7288050e39fd","title":"Redact","filename_download":"redact.svg","type":"image/svg+xml","storage":"local"}	\N	\N
240	281	faq_categories	d10f89b8-25b7-41e3-92cd-994692acc004	{"translations":{"create":[{"title":"Rédiger","languages_code":{"code":"fr-FR"}},{"title":"Redact","languages_code":{"code":"en-GB"}}],"update":[],"delete":[]},"icon":"858b3148-7d99-4314-b471-7a5623c76557","published":true}	{"translations":{"create":[{"title":"Rédiger","languages_code":{"code":"fr-FR"}},{"title":"Redact","languages_code":{"code":"en-GB"}}],"update":[],"delete":[]},"icon":"858b3148-7d99-4314-b471-7a5623c76557","published":true}	\N	\N
238	279	faq_categories_translations	9	{"title":"Rédiger","languages_code":{"code":"fr-FR"},"faq_categories_id":"d10f89b8-25b7-41e3-92cd-994692acc004"}	{"title":"Rédiger","languages_code":{"code":"fr-FR"},"faq_categories_id":"d10f89b8-25b7-41e3-92cd-994692acc004"}	240	\N
239	280	faq_categories_translations	10	{"title":"Redact","languages_code":{"code":"en-GB"},"faq_categories_id":"d10f89b8-25b7-41e3-92cd-994692acc004"}	{"title":"Redact","languages_code":{"code":"en-GB"},"faq_categories_id":"d10f89b8-25b7-41e3-92cd-994692acc004"}	240	\N
243	284	faq_categories	1f7143bb-d35e-4e9a-a52e-8c70318d9361	{"id":"1f7143bb-d35e-4e9a-a52e-8c70318d9361","sort":null,"user_created":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_created":"2024-03-21T09:17:07.133Z","user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2024-03-22T10:55:51.220Z","icon":"4adae99e-e1e1-467c-ba78-d7297ef78524","published":true,"questions":[3,4],"translations":[7,8]}	{"user_updated":"daa1631c-ab80-409e-9e08-f73f54a3d3fe","date_updated":"2024-03-22T10:55:51.220Z"}	\N	\N
241	282	faq_categories_translations	7	{"id":7,"faq_categories_id":"1f7143bb-d35e-4e9a-a52e-8c70318d9361","languages_code":"fr-FR","title":"Informations générales"}	{"faq_categories_id":"1f7143bb-d35e-4e9a-a52e-8c70318d9361","languages_code":"fr-FR","title":"Informations générales"}	243	\N
242	283	faq_categories_translations	8	{"id":8,"faq_categories_id":"1f7143bb-d35e-4e9a-a52e-8c70318d9361","languages_code":"en-GB","title":"General informations"}	{"faq_categories_id":"1f7143bb-d35e-4e9a-a52e-8c70318d9361","languages_code":"en-GB","title":"General informations"}	243	\N
244	287	directus_extensions	5270bb94-9425-4e60-a4dd-65f4c0a0921c	{"id":"5270bb94-9425-4e60-a4dd-65f4c0a0921c","enabled":true,"folder":"e4f291d4-6c57-48b2-b328-1da8f8e24979","source":"registry","bundle":null}	{"id":"5270bb94-9425-4e60-a4dd-65f4c0a0921c","enabled":true,"folder":"e4f291d4-6c57-48b2-b328-1da8f8e24979","source":"registry","bundle":null}	\N	\N
245	288	directus_extensions	5270bb94-9425-4e60-a4dd-65f4c0a0921c	{"enabled":false,"id":"5270bb94-9425-4e60-a4dd-65f4c0a0921c","folder":"e4f291d4-6c57-48b2-b328-1da8f8e24979","source":"registry","bundle":null}	{"enabled":false}	\N	\N
246	289	directus_extensions	5270bb94-9425-4e60-a4dd-65f4c0a0921c	{"enabled":true,"id":"5270bb94-9425-4e60-a4dd-65f4c0a0921c","folder":"e4f291d4-6c57-48b2-b328-1da8f8e24979","source":"registry","bundle":null}	{"enabled":true}	\N	\N
247	290	directus_flows	2fd35489-ab21-403a-87a5-39bc1ded0de9	{"name":"Test","icon":"bolt","color":null,"description":null,"status":"active","accountability":"all","trigger":"manual","options":{"collections":["faq_categories","faq_categories_translations","faq_content","faq_content_translations","languages"],"async":true,"requireConfirmation":true}}	{"name":"Test","icon":"bolt","color":null,"description":null,"status":"active","accountability":"all","trigger":"manual","options":{"collections":["faq_categories","faq_categories_translations","faq_content","faq_content_translations","languages"],"async":true,"requireConfirmation":true}}	\N	\N
248	292	directus_flows	dd0af7be-3ff0-424a-9687-7d4b6c1c0b5a	{"name":"Test","icon":"bolt","color":null,"description":null,"status":"active","accountability":"all","trigger":"schedule","options":{"cron":"* * 1 * * *"}}	{"name":"Test","icon":"bolt","color":null,"description":null,"status":"active","accountability":"all","trigger":"schedule","options":{"cron":"* * 1 * * *"}}	\N	\N
\.


--
-- Data for Name: directus_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_roles (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access) FROM stdin;
1d82af5b-8e27-4d24-8f83-3a0669f68855	Administrator	verified	$t:admin_description	\N	f	t	t
19467255-1682-415f-b26a-77b5c5268d27	Users	supervised_user_circle	\N	\N	f	f	t
\.


--
-- Data for Name: directus_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_sessions (token, "user", expires, ip, user_agent, share, origin) FROM stdin;
ELFxRBuoAVdEZxLKWEL7Yf6ATK4ALsyertPUaFY15R68ga1KbEqDZTMdnkhf1zFl	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-26 15:57:48.237+00	172.16.99.62	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	\N	http://vtopidor.intra.inist.fr:8055
5VBJHRfObQD0EPWVx15O6JTDLMMlfLgizp78EZydtmyEuDElXI_IgoSokvyx6Ay-	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-29 10:41:37.922+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	\N	http://localhost:8055
jHUyvJaF5qFT3nS6H8hoJRj8jkXd3XHUboC1hMFm9voeBbaRNunUv8V2m5yRrYr9	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-04-01 12:31:48.723+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	\N	http://localhost:8080
2vcjyFDSw89VFA81yK-xswBUWT-T7tCZ5a9iBUt4VzUsxnGrD9fLQtaAKOBmeLDI	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-04-01 12:33:25.985+00	172.19.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0	\N	http://localhost:8080
\.


--
-- Data for Name: directus_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_settings (id, project_name, project_url, project_color, project_logo, public_foreground, public_background, public_note, auth_login_attempts, auth_password_policy, storage_asset_transform, storage_asset_presets, custom_css, storage_default_folder, basemaps, mapbox_key, module_bar, project_descriptor, default_language, custom_aspect_ratios, public_favicon, default_appearance, default_theme_light, theme_light_overrides, default_theme_dark, theme_dark_overrides) FROM stdin;
\.


--
-- Data for Name: directus_shares; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_shares (id, name, collection, item, role, password, user_created, date_created, date_start, date_end, times_used, max_uses) FROM stdin;
\.


--
-- Data for Name: directus_translations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_translations (id, language, key, value) FROM stdin;
\.


--
-- Data for Name: directus_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_users (id, first_name, last_name, email, password, location, title, description, tags, avatar, language, tfa_secret, status, role, token, last_access, last_page, provider, external_identifier, auth_data, email_notifications, appearance, theme_dark, theme_light, theme_light_overrides, theme_dark_overrides) FROM stdin;
daa1631c-ab80-409e-9e08-f73f54a3d3fe	Admin	User	admin@example.com	$argon2id$v=19$m=65536,t=3,p=4$EBP0XqkjbQygdJRV6blhmA$Ut7wpRwZnTRDF0OnQemDQ3m72V/iCI4r3ZHo7T/5CaU	\N	\N	\N	\N	\N	\N	\N	active	1d82af5b-8e27-4d24-8f83-3a0669f68855	\N	2024-03-25 12:33:25.991+00	/files/folders/e07a884b-cfa0-4ec1-ba2a-7288050e39fd	default	\N	\N	t	\N	\N	\N	\N	\N
\.


--
-- Data for Name: directus_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_versions (id, key, name, collection, item, hash, date_created, date_updated, user_created, user_updated) FROM stdin;
\.


--
-- Data for Name: directus_webhooks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.directus_webhooks (id, name, method, url, status, data, actions, collections, headers) FROM stdin;
\.


--
-- Data for Name: faq_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.faq_categories (id, sort, user_created, date_created, user_updated, date_updated, icon, published) FROM stdin;
1f7143bb-d35e-4e9a-a52e-8c70318d9361	1	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:17:07.133+00	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:55:51.22+00	4adae99e-e1e1-467c-ba78-d7297ef78524	t
d10f89b8-25b7-41e3-92cd-994692acc004	2	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:50:17.015+00	\N	\N	858b3148-7d99-4314-b471-7a5623c76557	t
\.


--
-- Data for Name: faq_categories_translations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.faq_categories_translations (id, faq_categories_id, languages_code, title) FROM stdin;
5	\N	fr-FR	Une catégorie
6	\N	en-GB	A category
9	d10f89b8-25b7-41e3-92cd-994692acc004	fr-FR	Rédiger
10	d10f89b8-25b7-41e3-92cd-994692acc004	en-GB	Redact
7	1f7143bb-d35e-4e9a-a52e-8c70318d9361	fr-FR	Informations générales
8	1f7143bb-d35e-4e9a-a52e-8c70318d9361	en-GB	General informations
\.


--
-- Data for Name: faq_content; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.faq_content (id, sort, user_created, date_created, user_updated, date_updated, published, category) FROM stdin;
3	\N	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-21 09:15:41.427+00	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:42:04.771+00	t	1f7143bb-d35e-4e9a-a52e-8c70318d9361
4	\N	daa1631c-ab80-409e-9e08-f73f54a3d3fe	2024-03-22 10:42:30.865+00	\N	\N	t	1f7143bb-d35e-4e9a-a52e-8c70318d9361
\.


--
-- Data for Name: faq_content_translations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.faq_content_translations (id, faq_content_id, languages_code, question, answer) FROM stdin;
4	3	fr-FR	Une question	<p>Une super r&eacute;ponse</p>
5	3	en-GB	An question	<p>An awesome answer</p>
6	4	fr-FR	Une autre question	<p>Une autre r&eacute;ponse</p>
7	4	en-GB	An other question	<p>An other answer</p>
\.


--
-- Data for Name: languages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.languages (code, name, direction) FROM stdin;
fr-FR	French	ltr
en-GB	Engish (UK)	ltr
\.


--
-- Name: directus_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.directus_activity_id_seq', 295, true);


--
-- Name: directus_fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.directus_fields_id_seq', 39, true);


--
-- Name: directus_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.directus_notifications_id_seq', 1, false);


--
-- Name: directus_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.directus_permissions_id_seq', 44, true);


--
-- Name: directus_presets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.directus_presets_id_seq', 15, true);


--
-- Name: directus_relations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.directus_relations_id_seq', 14, true);


--
-- Name: directus_revisions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.directus_revisions_id_seq', 248, true);


--
-- Name: directus_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.directus_settings_id_seq', 1, true);


--
-- Name: directus_webhooks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.directus_webhooks_id_seq', 1, false);


--
-- Name: faq_categories_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.faq_categories_translations_id_seq', 10, true);


--
-- Name: faq_content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.faq_content_id_seq', 4, true);


--
-- Name: faq_content_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.faq_content_translations_id_seq', 7, true);


--
-- Name: directus_activity directus_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_activity
    ADD CONSTRAINT directus_activity_pkey PRIMARY KEY (id);


--
-- Name: directus_collections directus_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_collections
    ADD CONSTRAINT directus_collections_pkey PRIMARY KEY (collection);


--
-- Name: directus_dashboards directus_dashboards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_dashboards
    ADD CONSTRAINT directus_dashboards_pkey PRIMARY KEY (id);


--
-- Name: directus_extensions directus_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_extensions
    ADD CONSTRAINT directus_extensions_pkey PRIMARY KEY (id);


--
-- Name: directus_fields directus_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_fields
    ADD CONSTRAINT directus_fields_pkey PRIMARY KEY (id);


--
-- Name: directus_files directus_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_pkey PRIMARY KEY (id);


--
-- Name: directus_flows directus_flows_operation_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_flows
    ADD CONSTRAINT directus_flows_operation_unique UNIQUE (operation);


--
-- Name: directus_flows directus_flows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_flows
    ADD CONSTRAINT directus_flows_pkey PRIMARY KEY (id);


--
-- Name: directus_folders directus_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_folders
    ADD CONSTRAINT directus_folders_pkey PRIMARY KEY (id);


--
-- Name: directus_migrations directus_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_migrations
    ADD CONSTRAINT directus_migrations_pkey PRIMARY KEY (version);


--
-- Name: directus_notifications directus_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_notifications
    ADD CONSTRAINT directus_notifications_pkey PRIMARY KEY (id);


--
-- Name: directus_operations directus_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_pkey PRIMARY KEY (id);


--
-- Name: directus_operations directus_operations_reject_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_reject_unique UNIQUE (reject);


--
-- Name: directus_operations directus_operations_resolve_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_resolve_unique UNIQUE (resolve);


--
-- Name: directus_panels directus_panels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_panels
    ADD CONSTRAINT directus_panels_pkey PRIMARY KEY (id);


--
-- Name: directus_permissions directus_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_permissions
    ADD CONSTRAINT directus_permissions_pkey PRIMARY KEY (id);


--
-- Name: directus_presets directus_presets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_presets
    ADD CONSTRAINT directus_presets_pkey PRIMARY KEY (id);


--
-- Name: directus_relations directus_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_relations
    ADD CONSTRAINT directus_relations_pkey PRIMARY KEY (id);


--
-- Name: directus_revisions directus_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_pkey PRIMARY KEY (id);


--
-- Name: directus_roles directus_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_roles
    ADD CONSTRAINT directus_roles_pkey PRIMARY KEY (id);


--
-- Name: directus_sessions directus_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_sessions
    ADD CONSTRAINT directus_sessions_pkey PRIMARY KEY (token);


--
-- Name: directus_settings directus_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_pkey PRIMARY KEY (id);


--
-- Name: directus_shares directus_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_pkey PRIMARY KEY (id);


--
-- Name: directus_translations directus_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_translations
    ADD CONSTRAINT directus_translations_pkey PRIMARY KEY (id);


--
-- Name: directus_users directus_users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_email_unique UNIQUE (email);


--
-- Name: directus_users directus_users_external_identifier_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_external_identifier_unique UNIQUE (external_identifier);


--
-- Name: directus_users directus_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_pkey PRIMARY KEY (id);


--
-- Name: directus_users directus_users_token_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_token_unique UNIQUE (token);


--
-- Name: directus_versions directus_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_pkey PRIMARY KEY (id);


--
-- Name: directus_webhooks directus_webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_webhooks
    ADD CONSTRAINT directus_webhooks_pkey PRIMARY KEY (id);


--
-- Name: faq_categories faq_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_categories
    ADD CONSTRAINT faq_categories_pkey PRIMARY KEY (id);


--
-- Name: faq_categories_translations faq_categories_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_categories_translations
    ADD CONSTRAINT faq_categories_translations_pkey PRIMARY KEY (id);


--
-- Name: faq_content faq_content_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_content
    ADD CONSTRAINT faq_content_pkey PRIMARY KEY (id);


--
-- Name: faq_content_translations faq_content_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_content_translations
    ADD CONSTRAINT faq_content_translations_pkey PRIMARY KEY (id);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (code);


--
-- Name: directus_collections directus_collections_group_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_collections
    ADD CONSTRAINT directus_collections_group_foreign FOREIGN KEY ("group") REFERENCES public.directus_collections(collection);


--
-- Name: directus_dashboards directus_dashboards_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_dashboards
    ADD CONSTRAINT directus_dashboards_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_files directus_files_folder_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_folder_foreign FOREIGN KEY (folder) REFERENCES public.directus_folders(id) ON DELETE SET NULL;


--
-- Name: directus_files directus_files_modified_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_modified_by_foreign FOREIGN KEY (modified_by) REFERENCES public.directus_users(id);


--
-- Name: directus_files directus_files_uploaded_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_uploaded_by_foreign FOREIGN KEY (uploaded_by) REFERENCES public.directus_users(id);


--
-- Name: directus_flows directus_flows_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_flows
    ADD CONSTRAINT directus_flows_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_folders directus_folders_parent_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_folders
    ADD CONSTRAINT directus_folders_parent_foreign FOREIGN KEY (parent) REFERENCES public.directus_folders(id);


--
-- Name: directus_notifications directus_notifications_recipient_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_notifications
    ADD CONSTRAINT directus_notifications_recipient_foreign FOREIGN KEY (recipient) REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_notifications directus_notifications_sender_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_notifications
    ADD CONSTRAINT directus_notifications_sender_foreign FOREIGN KEY (sender) REFERENCES public.directus_users(id);


--
-- Name: directus_operations directus_operations_flow_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_flow_foreign FOREIGN KEY (flow) REFERENCES public.directus_flows(id) ON DELETE CASCADE;


--
-- Name: directus_operations directus_operations_reject_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_reject_foreign FOREIGN KEY (reject) REFERENCES public.directus_operations(id);


--
-- Name: directus_operations directus_operations_resolve_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_resolve_foreign FOREIGN KEY (resolve) REFERENCES public.directus_operations(id);


--
-- Name: directus_operations directus_operations_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_panels directus_panels_dashboard_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_panels
    ADD CONSTRAINT directus_panels_dashboard_foreign FOREIGN KEY (dashboard) REFERENCES public.directus_dashboards(id) ON DELETE CASCADE;


--
-- Name: directus_panels directus_panels_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_panels
    ADD CONSTRAINT directus_panels_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_permissions directus_permissions_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_permissions
    ADD CONSTRAINT directus_permissions_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE CASCADE;


--
-- Name: directus_presets directus_presets_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_presets
    ADD CONSTRAINT directus_presets_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE CASCADE;


--
-- Name: directus_presets directus_presets_user_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_presets
    ADD CONSTRAINT directus_presets_user_foreign FOREIGN KEY ("user") REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_revisions directus_revisions_activity_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_activity_foreign FOREIGN KEY (activity) REFERENCES public.directus_activity(id) ON DELETE CASCADE;


--
-- Name: directus_revisions directus_revisions_parent_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_parent_foreign FOREIGN KEY (parent) REFERENCES public.directus_revisions(id);


--
-- Name: directus_revisions directus_revisions_version_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_version_foreign FOREIGN KEY (version) REFERENCES public.directus_versions(id) ON DELETE CASCADE;


--
-- Name: directus_sessions directus_sessions_share_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_sessions
    ADD CONSTRAINT directus_sessions_share_foreign FOREIGN KEY (share) REFERENCES public.directus_shares(id) ON DELETE CASCADE;


--
-- Name: directus_sessions directus_sessions_user_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_sessions
    ADD CONSTRAINT directus_sessions_user_foreign FOREIGN KEY ("user") REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_settings directus_settings_project_logo_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_project_logo_foreign FOREIGN KEY (project_logo) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_background_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_background_foreign FOREIGN KEY (public_background) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_favicon_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_favicon_foreign FOREIGN KEY (public_favicon) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_foreground_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_foreground_foreign FOREIGN KEY (public_foreground) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_storage_default_folder_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_storage_default_folder_foreign FOREIGN KEY (storage_default_folder) REFERENCES public.directus_folders(id) ON DELETE SET NULL;


--
-- Name: directus_shares directus_shares_collection_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_collection_foreign FOREIGN KEY (collection) REFERENCES public.directus_collections(collection) ON DELETE CASCADE;


--
-- Name: directus_shares directus_shares_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE CASCADE;


--
-- Name: directus_shares directus_shares_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_users directus_users_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE SET NULL;


--
-- Name: directus_versions directus_versions_collection_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_collection_foreign FOREIGN KEY (collection) REFERENCES public.directus_collections(collection) ON DELETE CASCADE;


--
-- Name: directus_versions directus_versions_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_versions directus_versions_user_updated_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_user_updated_foreign FOREIGN KEY (user_updated) REFERENCES public.directus_users(id);


--
-- Name: faq_categories faq_categories_icon_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_categories
    ADD CONSTRAINT faq_categories_icon_foreign FOREIGN KEY (icon) REFERENCES public.directus_files(id) ON DELETE SET NULL;


--
-- Name: faq_categories_translations faq_categories_translations_faq_categories_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_categories_translations
    ADD CONSTRAINT faq_categories_translations_faq_categories_id_foreign FOREIGN KEY (faq_categories_id) REFERENCES public.faq_categories(id) ON DELETE SET NULL;


--
-- Name: faq_categories_translations faq_categories_translations_languages_code_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_categories_translations
    ADD CONSTRAINT faq_categories_translations_languages_code_foreign FOREIGN KEY (languages_code) REFERENCES public.languages(code) ON DELETE SET NULL;


--
-- Name: faq_categories faq_categories_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_categories
    ADD CONSTRAINT faq_categories_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id);


--
-- Name: faq_categories faq_categories_user_updated_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_categories
    ADD CONSTRAINT faq_categories_user_updated_foreign FOREIGN KEY (user_updated) REFERENCES public.directus_users(id);


--
-- Name: faq_content faq_content_category_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_content
    ADD CONSTRAINT faq_content_category_foreign FOREIGN KEY (category) REFERENCES public.faq_categories(id) ON DELETE SET NULL;


--
-- Name: faq_content_translations faq_content_translations_faq_content_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_content_translations
    ADD CONSTRAINT faq_content_translations_faq_content_id_foreign FOREIGN KEY (faq_content_id) REFERENCES public.faq_content(id) ON DELETE SET NULL;


--
-- Name: faq_content_translations faq_content_translations_languages_code_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_content_translations
    ADD CONSTRAINT faq_content_translations_languages_code_foreign FOREIGN KEY (languages_code) REFERENCES public.languages(code) ON DELETE SET NULL;


--
-- Name: faq_content faq_content_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_content
    ADD CONSTRAINT faq_content_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id);


--
-- Name: faq_content faq_content_user_updated_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faq_content
    ADD CONSTRAINT faq_content_user_updated_foreign FOREIGN KEY (user_updated) REFERENCES public.directus_users(id);


--
-- PostgreSQL database dump complete
--

