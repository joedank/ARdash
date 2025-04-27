--
-- PostgreSQL database dump
--

-- Dumped from database version 16.8 (Debian 16.8-1.pgdg120+1)
-- Dumped by pg_dump version 16.8 (Debian 16.8-1.pgdg120+1)

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

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


--
-- Name: enum_clients_client_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_clients_client_type AS ENUM (
    'property_manager',
    'resident'
);


ALTER TYPE public.enum_clients_client_type OWNER TO postgres;

--
-- Name: enum_estimate_item_photos_photo_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_estimate_item_photos_photo_type AS ENUM (
    'progress',
    'completed',
    'issue',
    'material',
    'other'
);


ALTER TYPE public.enum_estimate_item_photos_photo_type OWNER TO postgres;

--
-- Name: enum_estimates_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_estimates_status AS ENUM (
    'draft',
    'sent',
    'viewed',
    'accepted',
    'rejected',
    'expired'
);


ALTER TYPE public.enum_estimates_status OWNER TO postgres;

--
-- Name: enum_invoices_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_invoices_status AS ENUM (
    'draft',
    'sent',
    'viewed',
    'paid',
    'overdue'
);


ALTER TYPE public.enum_invoices_status OWNER TO postgres;

--
-- Name: enum_products_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_products_type AS ENUM (
    'product'
);


ALTER TYPE public.enum_products_type OWNER TO postgres;

--
-- Name: enum_project_inspections_category; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_project_inspections_category AS ENUM (
    'condition',
    'measurements',
    'materials'
);


ALTER TYPE public.enum_project_inspections_category OWNER TO postgres;

--
-- Name: enum_project_photos_photo_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_project_photos_photo_type AS ENUM (
    'before',
    'after',
    'receipt',
    'assessment',
    'condition'
);


ALTER TYPE public.enum_project_photos_photo_type OWNER TO postgres;

--
-- Name: enum_projects_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_projects_status AS ENUM (
    'pending',
    'in_progress',
    'completed',
    'rejected'
);


ALTER TYPE public.enum_projects_status OWNER TO postgres;

--
-- Name: enum_projects_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_projects_type AS ENUM (
    'assessment',
    'active'
);


ALTER TYPE public.enum_projects_type OWNER TO postgres;

--
-- Name: enum_users_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_users_role AS ENUM (
    'user',
    'admin'
);


ALTER TYPE public.enum_users_role OWNER TO postgres;

--
-- Name: enum_work_types_measurement_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_work_types_measurement_type AS ENUM (
    'area',
    'linear',
    'quantity'
);


ALTER TYPE public.enum_work_types_measurement_type OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: SequelizeMeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SequelizeMeta" (
    name character varying(255) NOT NULL
);


ALTER TABLE public."SequelizeMeta" OWNER TO postgres;

--
-- Name: client_addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client_addresses (
    id uuid NOT NULL,
    client_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    street_address text NOT NULL,
    city character varying(255) NOT NULL,
    state character varying(255) NOT NULL,
    postal_code character varying(255) NOT NULL,
    country character varying(255) DEFAULT 'USA'::character varying,
    is_primary boolean DEFAULT false NOT NULL,
    notes text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.client_addresses OWNER TO postgres;

--
-- Name: COLUMN client_addresses.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.client_addresses.name IS 'Name or label for this address (e.g., "Main Office", "Property at 123 Main St")';


--
-- Name: COLUMN client_addresses.is_primary; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.client_addresses.is_primary IS 'Indicates if this is the primary address for the client';


--
-- Name: clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clients (
    id uuid NOT NULL,
    payment_terms text,
    default_tax_rate numeric(5,2) DEFAULT NULL::numeric,
    default_currency character varying(3) DEFAULT 'USD'::character varying,
    notes text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    display_name character varying(255) NOT NULL,
    company character varying(255),
    email character varying(255),
    phone character varying(255),
    client_type public.enum_clients_client_type DEFAULT 'resident'::public.enum_clients_client_type
);


ALTER TABLE public.clients OWNER TO postgres;

--
-- Name: client_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.client_view AS
 SELECT id,
    display_name AS name,
    company,
    email,
    phone,
    payment_terms,
    default_tax_rate,
    default_currency,
    notes,
    is_active,
    client_type,
    created_at,
    updated_at
   FROM public.clients;


ALTER VIEW public.client_view OWNER TO postgres;

--
-- Name: estimate_item_additional_work; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estimate_item_additional_work (
    id uuid NOT NULL,
    estimate_item_id uuid NOT NULL,
    description text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.estimate_item_additional_work OWNER TO postgres;

--
-- Name: estimate_item_photos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estimate_item_photos (
    id uuid NOT NULL,
    estimate_item_id uuid NOT NULL,
    file_path character varying(255) NOT NULL,
    original_name character varying(255),
    photo_type public.enum_estimate_item_photos_photo_type DEFAULT 'progress'::public.enum_estimate_item_photos_photo_type NOT NULL,
    notes text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.estimate_item_photos OWNER TO postgres;

--
-- Name: estimate_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estimate_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    estimate_id uuid NOT NULL,
    description text NOT NULL,
    quantity numeric(10,2) DEFAULT 1 NOT NULL,
    price numeric(10,2) DEFAULT 0 NOT NULL,
    tax_rate numeric(5,2) DEFAULT 0 NOT NULL,
    item_total numeric(10,2) DEFAULT 0 NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    product_id uuid,
    source_data jsonb,
    unit character varying(50),
    custom_product_data jsonb
);


ALTER TABLE public.estimate_items OWNER TO postgres;

--
-- Name: estimates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estimates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    estimate_number character varying(255) NOT NULL,
    card_dav_uri character varying(255),
    date_created date NOT NULL,
    date_valid_until date NOT NULL,
    status public.enum_estimates_status DEFAULT 'draft'::public.enum_estimates_status NOT NULL,
    subtotal numeric(10,2) DEFAULT 0 NOT NULL,
    tax_total numeric(10,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(10,2) DEFAULT 0 NOT NULL,
    total numeric(10,2) DEFAULT 0 NOT NULL,
    notes text,
    terms text,
    pdf_path character varying(255),
    converted_to_invoice_id uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone,
    address_id uuid,
    client_id uuid
);


ALTER TABLE public.estimates OWNER TO postgres;

--
-- Name: COLUMN estimates.pdf_path; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.estimates.pdf_path IS 'Path to the generated PDF file';


--
-- Name: COLUMN estimates.address_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.estimates.address_id IS 'Foreign key to client_addresses table for the selected address';


--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoice_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    invoice_id uuid NOT NULL,
    description text NOT NULL,
    quantity numeric(10,2) DEFAULT 1 NOT NULL,
    price numeric(10,2) DEFAULT 0 NOT NULL,
    tax_rate numeric(5,2) DEFAULT 0 NOT NULL,
    item_total numeric(10,2) DEFAULT 0 NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.invoice_items OWNER TO postgres;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    invoice_number character varying(255) NOT NULL,
    card_dav_uri character varying(255),
    date_created date NOT NULL,
    date_due date NOT NULL,
    status public.enum_invoices_status DEFAULT 'draft'::public.enum_invoices_status,
    subtotal numeric(10,2) DEFAULT 0 NOT NULL,
    tax_total numeric(10,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(10,2) DEFAULT 0 NOT NULL,
    total numeric(10,2) DEFAULT 0 NOT NULL,
    notes text,
    terms text,
    pdf_path character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone,
    address_id uuid,
    client_id uuid
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- Name: COLUMN invoices.pdf_path; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.invoices.pdf_path IS 'Path to the generated PDF file';


--
-- Name: COLUMN invoices.address_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.invoices.address_id IS 'Foreign key to client_addresses table for the selected address';


--
-- Name: llm_prompts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.llm_prompts (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    prompt_text text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.llm_prompts OWNER TO postgres;

--
-- Name: llm_prompts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.llm_prompts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.llm_prompts_id_seq OWNER TO postgres;

--
-- Name: llm_prompts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.llm_prompts_id_seq OWNED BY public.llm_prompts.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    invoice_id uuid NOT NULL,
    amount numeric(10,2) NOT NULL,
    payment_date date NOT NULL,
    payment_method character varying(50),
    notes text,
    reference_number character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    price numeric(10,2) DEFAULT 0 NOT NULL,
    tax_rate numeric(5,2) DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type public.enum_products_type DEFAULT 'product'::public.enum_products_type NOT NULL,
    unit character varying(255) DEFAULT 'each'::character varying,
    name_vec public.vector(384),
    embedding public.vector(384)
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: project_inspections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_inspections (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    category public.enum_project_inspections_category NOT NULL,
    content jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.project_inspections OWNER TO postgres;

--
-- Name: project_photos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_photos (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    inspection_id uuid,
    photo_type public.enum_project_photos_photo_type NOT NULL,
    file_path character varying(255) NOT NULL,
    notes text,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.project_photos OWNER TO postgres;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id uuid NOT NULL,
    client_id uuid NOT NULL,
    estimate_id uuid,
    type public.enum_projects_type DEFAULT 'assessment'::public.enum_projects_type NOT NULL,
    status public.enum_projects_status DEFAULT 'pending'::public.enum_projects_status NOT NULL,
    scheduled_date date NOT NULL,
    scope text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    additional_work text,
    address_id uuid,
    converted_to_job_id uuid,
    work_types jsonb DEFAULT '[]'::jsonb
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- Name: settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.settings (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    value text,
    "group" character varying(255) DEFAULT 'general'::character varying NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.settings OWNER TO postgres;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.settings_id_seq OWNER TO postgres;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: source_maps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.source_maps (
    id uuid NOT NULL,
    estimate_item_id uuid,
    source_type character varying(50) NOT NULL,
    source_data jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.source_maps OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    username character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    role public.enum_users_role DEFAULT 'user'::public.enum_users_role NOT NULL,
    theme_preference character varying(255) DEFAULT 'dark'::character varying NOT NULL,
    avatar character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: work_type_cost_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_type_cost_history (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    work_type_id uuid NOT NULL,
    region character varying(50) DEFAULT 'default'::character varying NOT NULL,
    unit_cost_material numeric(10,2),
    unit_cost_labor numeric(10,2),
    captured_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_history_unit_cost_labor_non_negative CHECK (((unit_cost_labor IS NULL) OR (unit_cost_labor >= (0)::numeric))),
    CONSTRAINT check_history_unit_cost_material_non_negative CHECK (((unit_cost_material IS NULL) OR (unit_cost_material >= (0)::numeric)))
);


ALTER TABLE public.work_type_cost_history OWNER TO postgres;

--
-- Name: work_type_materials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_type_materials (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    work_type_id uuid NOT NULL,
    product_id uuid NOT NULL,
    qty_per_unit numeric(10,4) DEFAULT 1.0 NOT NULL,
    unit character varying(20) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_qty_per_unit_non_negative CHECK ((qty_per_unit >= (0)::numeric))
);


ALTER TABLE public.work_type_materials OWNER TO postgres;

--
-- Name: work_type_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_type_tags (
    work_type_id uuid NOT NULL,
    tag character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.work_type_tags OWNER TO postgres;

--
-- Name: work_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_types (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    parent_bucket character varying(100) NOT NULL,
    measurement_type public.enum_work_types_measurement_type NOT NULL,
    suggested_units character varying(50) NOT NULL,
    unit_cost_material numeric(10,2),
    unit_cost_labor numeric(10,2),
    productivity_unit_per_hr numeric(10,2),
    name_vec public.vector(384),
    revision integer DEFAULT 1 NOT NULL,
    updated_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_productivity_unit_per_hr_non_negative CHECK (((productivity_unit_per_hr IS NULL) OR (productivity_unit_per_hr >= (0)::numeric))),
    CONSTRAINT check_unit_cost_labor_non_negative CHECK (((unit_cost_labor IS NULL) OR (unit_cost_labor >= (0)::numeric))),
    CONSTRAINT check_unit_cost_material_non_negative CHECK (((unit_cost_material IS NULL) OR (unit_cost_material >= (0)::numeric)))
);


ALTER TABLE public.work_types OWNER TO postgres;

--
-- Name: llm_prompts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.llm_prompts ALTER COLUMN id SET DEFAULT nextval('public.llm_prompts_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Data for Name: SequelizeMeta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SequelizeMeta" (name) FROM stdin;
20250330000000-create-users-table.js
20250331-add-pdf-settings.js
20250331000000-add-pdf-settings.js
20250331000001-fix-carddav-cache.js
20250331074510-create-missing-invoice-tables.js
20250331160336-fix-carddav-uri-column.js
20250331160925-add-date-created-to-invoices.js
20250331170000-fix-settings-column-names.js
20250401000000-create-client-tables.js
20250401000001-enhance-pdf-settings.js
20250401000002-insert-pdf-settings.js
20250401100000-remove-carddav-update-clients.js
20250401175626-add-address-id-to-estimates.js
20250401185505-cleanup-estimates-table-schema.js
20250401200000-add-client-type.js
20250401200000-final-carddav-removal.js
20250401300000-fix-client-references.js
20250402000000-add-address-id-to-invoices.js
20250402000001-create-project-tables.js
20250402050323-add-timestamps-to-users.js
20250402050639-add-timestamps-to-invoices.js
20250402050754-add-date-created-to-invoices.js
20250402050857-add-date-due-to-invoices.js
20250402050943-add-tax-total-to-invoices.js
20250402051021-add-discount-amount-to-invoices.js
20250402051058-add-pdf-path-to-invoices.js
20250402051255-add-timestamps-to-settings.js
20250402053003-cleanup-duplicate-invoice-columns.js
20250402053053-cleanup-duplicate-invoice-columns.js
20250402100000-update-invoice-client-id-nullable.js
20250402150000-fix-client-display-name.js
20250403000001-add-additional-work-to-projects.js
20250404000001-add-address-id-to-projects.js
20250404000010-add-converted-to-job-id-to-projects.js
20250406041035-add-condition-to-photo-type-enum.js
20250406221212-add-avatar-to-users.js
20250407-add-type-to-products.js
20250407-add-unit-to-products.js
20250407-remove-services-from-products.js
20250407034210-fix-settings-timestamp-columns.js
20250407165000-create-llm-prompts.js
20250408000001-migrate-scope-to-condition.js
20250408000001-update-project-inspections-measurements.js
20250408000002-cleanup-project-photos.js
20250408021900-add-type-to-products.js
20250408150000-add-source-mapping.js
20250412001000-standardize-project-fields.js
20250413000000-standardize-id-fields.js
20250413001000-standardize-remaining-fields-modified.js
20250413001000-standardize-remaining-fields.js
20250414000000-cleanup-standardization.js
20250414053000-create-estimate-item-additional-work.js
20250414090000-create-estimate-item-photos.js
20250415000000-add-rejected-status.js
20250417000000-add-vector-column-to-products.js
20250418000001-add-vector-embedding.js
20250423-drop-client-view.js
20250423000000-enable-pgvector.js
20250423000001-fix-work-type-uuids.js
20250423144500-fix-payment-terms-column-type.js
\.


--
-- Data for Name: client_addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.client_addresses (id, client_id, name, street_address, city, state, postal_code, country, is_primary, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clients (id, payment_terms, default_tax_rate, default_currency, notes, is_active, created_at, updated_at, display_name, company, email, phone, client_type) FROM stdin;
\.


--
-- Data for Name: estimate_item_additional_work; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estimate_item_additional_work (id, estimate_item_id, description, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: estimate_item_photos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estimate_item_photos (id, estimate_item_id, file_path, original_name, photo_type, notes, metadata, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: estimate_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estimate_items (id, estimate_id, description, quantity, price, tax_rate, item_total, sort_order, created_at, updated_at, product_id, source_data, unit, custom_product_data) FROM stdin;
\.


--
-- Data for Name: estimates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estimates (id, estimate_number, card_dav_uri, date_created, date_valid_until, status, subtotal, tax_total, discount_amount, total, notes, terms, pdf_path, converted_to_invoice_id, created_at, updated_at, deleted_at, address_id, client_id) FROM stdin;
\.


--
-- Data for Name: invoice_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoice_items (id, invoice_id, description, quantity, price, tax_rate, item_total, sort_order, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoices (id, invoice_number, card_dav_uri, date_created, date_due, status, subtotal, tax_total, discount_amount, total, notes, terms, pdf_path, created_at, updated_at, deleted_at, address_id, client_id) FROM stdin;
\.


--
-- Data for Name: llm_prompts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.llm_prompts (id, name, description, prompt_text, created_at, updated_at) FROM stdin;
1	initialAnalysis	Initial prompt for analyzing project description	Role: You are an expert estimator analyzing construction project requirements.\nTask: Analyze the given project description and identify required measurements and details.\nFormat: Return a JSON object with:\n- required_measurements: array of needed measurements\n- suggested_products: array of product types needed\n- clarifying_questions: array of specific questions if more detail needed\n\nExample Input: "2000 sq ft roof replacement with tear off"\nExample Output: {\n  "required_measurements": ["roof_square_footage", "roof_pitch", "number_of_layers"],\n  "required_services": ["roof_tear_off", "roof_installation", "cleanup"],\n  "clarifying_questions": ["What is the current roof condition?", "Are there any known leak areas?"]\n}	2025-04-26 05:16:20.18+00	2025-04-26 05:16:20.18+00
2	initialAnalysisWithAssessment	Prompt for analyzing project with assessment data	Role: You are an expert estimator analyzing construction project requirements with assessment data.\nTask: Analyze the given project description along with the assessment data provided and identify required measurements and details.\nFormat: Return a JSON object with:\n- required_measurements: array of needed measurements (only those not already in assessment data)\n- suggested_products: array of product types needed\n- clarifying_questions: array of specific questions if more detail needed (fewer needed with assessment data)\n\nExample Input: Project description + Assessment data\nExample Output: {\n  "required_measurements": ["additional_measurements_needed"],\n  "required_services": ["services_based_on_assessment_and_description"],\n  "clarifying_questions": ["specific_questions_not_addressed_in_assessment"]\n}	2025-04-26 05:16:20.18+00	2025-04-26 05:16:20.18+00
3	serviceMatch	Service matching for finding catalog items	Role: You are a service specialist matching project needs to available services.\nContext: You have access to the following data:\n- Project requirements\n- Available service catalog\n- Measurements and specifications\n\nTask: Match project needs to existing services or suggest new services.\nFormat: Return a JSON object with:\n- matched_services: array of existing service IDs\n- new_service_suggestions: array of suggested new services\n- estimated_hours: calculated labor hours for each service\n\nBase your estimates on industry standards and best practices.	2025-04-26 05:16:20.18+00	2025-04-26 05:16:20.18+00
4	laborHoursCalculation	Calculate labor hours for services	Role: You are an estimation expert calculating required labor hours.\nTask: Calculate precise labor hours needed for each service based on measurements.\nRules:\n- Include standard labor rates\n- Account for job complexity factors\n- Consider crew size requirements\n- Factor in site conditions and access\n\nFormat: Return a JSON object with detailed calculations and explanations.	2025-04-26 05:16:20.18+00	2025-04-26 05:16:20.18+00
5	newService	Create new services not in catalog	Role: You are a service catalog manager creating new service entries.\nTask: Generate complete service specifications for new offerings.\nRequired Fields:\n- name: Clear, standardized service name\n- description: Detailed service description\n- unit: Appropriate unit of measurement (typically hours or fixed fee)\n- type: Service classification\n- base_rate: Standard hourly or fixed fee rate\n\nFormat: Return a JSON object matching the service catalog schema.	2025-04-26 05:16:20.18+00	2025-04-26 05:16:20.18+00
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, invoice_id, amount, payment_date, payment_method, notes, reference_number, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, description, price, tax_rate, is_active, created_at, updated_at, type, unit, name_vec, embedding) FROM stdin;
\.


--
-- Data for Name: project_inspections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_inspections (id, project_id, category, content, created_at) FROM stdin;
\.


--
-- Data for Name: project_photos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_photos (id, project_id, inspection_id, photo_type, file_path, notes, created_at) FROM stdin;
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, client_id, estimate_id, type, status, scheduled_date, scope, created_at, updated_at, additional_work, address_id, converted_to_job_id, work_types) FROM stdin;
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.settings (id, key, value, "group", description, created_at, updated_at) FROM stdin;
34	company_name	Your Company	general	Company name displayed on invoices and estimates	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
35	company_address	123 Business St, Suite 100, City, State, 12345	general	Company address displayed on invoices and estimates	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
36	company_phone	(555) 123-4567	general	Company phone number displayed on invoices and estimates	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
37	company_email	billing@yourcompany.com	general	Company email displayed on invoices and estimates	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
38	company_website	www.yourcompany.com	general	Company website displayed on invoices and estimates	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
39	company_logo_path		general	Path to company logo file for invoices and estimates (within uploads/logos directory)	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
40	invoice_prefix	INV-	general	Prefix for invoice numbers (e.g., INV-00001)	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
41	invoice_due_days	30	general	Default number of days until invoice is due	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
42	default_invoice_terms	Payment is due within {due_days} days from the date of invoice. Late payments are subject to a 1.5% monthly fee.	general	Default terms and conditions for invoices	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
43	pdf_invoice_footer	Thank you for your business. Please contact us with any questions regarding this invoice.	general	Custom footer text for invoice PDFs	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
44	estimate_prefix	EST-	general	Prefix for estimate numbers (e.g., EST-00001)	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
45	estimate_valid_days	30	general	Default number of days estimates are valid	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
46	default_estimate_terms	This estimate is valid for {valid_days} days from the date issued. To accept this estimate, please sign and return.	general	Default terms and conditions for estimates	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
47	pdf_estimate_footer	Thank you for considering our services. Please contact us with any questions regarding this estimate.	general	Custom footer text for estimate PDFs	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
48	primary_color	#3b82f6	general	Primary color for PDF documents (hex code)	2025-04-26 05:16:16.715+00	2025-04-26 05:16:16.715+00
58	pdf_background_color	#f8f9fa	appearance	Background color for table headers in PDF documents	2025-04-26 05:16:17.936+00	2025-04-26 05:16:18.07+00
59	pdf_font_family	Helvetica	appearance	Font family for PDF documents	2025-04-26 05:16:17.936+00	2025-04-26 05:16:18.07+00
60	pdf_secondary_color	#64748b	appearance	Secondary color for PDF accents	2025-04-26 05:16:17.936+00	2025-04-26 05:16:18.07+00
61	pdf_table_border_color	#e2e8f0	appearance	Border color for tables in PDF documents	2025-04-26 05:16:17.936+00	2025-04-26 05:16:18.07+00
62	pdf_page_margin	50	layout	Page margin in points for PDF documents	2025-04-26 05:16:17.936+00	2025-04-26 05:16:18.07+00
63	pdf_header_margin	30	layout	Top margin for header in PDF documents	2025-04-26 05:16:17.936+00	2025-04-26 05:16:18.07+00
64	pdf_footer_margin	30	layout	Bottom margin for footer in PDF documents	2025-04-26 05:16:17.936+00	2025-04-26 05:16:18.07+00
65	pdf_watermark_text		appearance	Watermark text for PDF documents (leave empty for no watermark)	2025-04-26 05:16:17.936+00	2025-04-26 05:16:18.07+00
1	deepseek_embedding_model	deepseek-embedding	ai	Default embedding model for DeepSeek	2025-04-26 05:15:10.510955+00	2025-04-26 05:15:10.510955+00
2	embedding_provider	deepseek	ai	Default embedding provider	2025-04-26 05:15:10.543634+00	2025-04-26 05:15:10.543634+00
3	enable_vector_similarity	true	ai	Enable vector similarity search	2025-04-26 05:15:10.572428+00	2025-04-26 05:15:10.572428+00
\.


--
-- Data for Name: source_maps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.source_maps (id, estimate_item_id, source_type, source_data, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, password, first_name, last_name, is_active, role, theme_preference, avatar, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: work_type_cost_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_type_cost_history (id, work_type_id, region, unit_cost_material, unit_cost_labor, captured_at, updated_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: work_type_materials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_type_materials (id, work_type_id, product_id, qty_per_unit, unit, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: work_type_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_type_tags (work_type_id, tag, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: work_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_types (id, name, parent_bucket, measurement_type, suggested_units, unit_cost_material, unit_cost_labor, productivity_unit_per_hr, name_vec, revision, updated_by, created_at, updated_at) FROM stdin;
\.


--
-- Name: llm_prompts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.llm_prompts_id_seq', 5, true);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.settings_id_seq', 91, true);


--
-- Name: SequelizeMeta SequelizeMeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SequelizeMeta"
    ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);


--
-- Name: client_addresses client_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_addresses
    ADD CONSTRAINT client_addresses_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: estimate_item_additional_work estimate_item_additional_work_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estimate_item_additional_work
    ADD CONSTRAINT estimate_item_additional_work_pkey PRIMARY KEY (id);


--
-- Name: estimate_item_photos estimate_item_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estimate_item_photos
    ADD CONSTRAINT estimate_item_photos_pkey PRIMARY KEY (id);


--
-- Name: estimate_items estimate_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estimate_items
    ADD CONSTRAINT estimate_items_pkey PRIMARY KEY (id);


--
-- Name: estimates estimates_estimate_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key UNIQUE (estimate_number);


--
-- Name: estimates estimates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_pkey PRIMARY KEY (id);


--
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: llm_prompts llm_prompts_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.llm_prompts
    ADD CONSTRAINT llm_prompts_name_key UNIQUE (name);


--
-- Name: llm_prompts llm_prompts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.llm_prompts
    ADD CONSTRAINT llm_prompts_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: project_inspections project_inspections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_inspections
    ADD CONSTRAINT project_inspections_pkey PRIMARY KEY (id);


--
-- Name: project_photos project_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_photos
    ADD CONSTRAINT project_photos_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: settings settings_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key UNIQUE (key);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: source_maps source_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_maps
    ADD CONSTRAINT source_maps_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: work_type_cost_history work_type_cost_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_type_cost_history
    ADD CONSTRAINT work_type_cost_history_pkey PRIMARY KEY (id);


--
-- Name: work_type_materials work_type_materials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_type_materials
    ADD CONSTRAINT work_type_materials_pkey PRIMARY KEY (id);


--
-- Name: work_type_tags work_type_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_type_tags
    ADD CONSTRAINT work_type_tags_pkey PRIMARY KEY (work_type_id, tag);


--
-- Name: work_types work_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_types
    ADD CONSTRAINT work_types_pkey PRIMARY KEY (id);


--
-- Name: client_addresses_client_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX client_addresses_client_id ON public.client_addresses USING btree (client_id);


--
-- Name: client_addresses_is_primary; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX client_addresses_is_primary ON public.client_addresses USING btree (is_primary);


--
-- Name: clients_client_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX clients_client_type ON public.clients USING btree (client_type);


--
-- Name: clients_display_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX clients_display_name ON public.clients USING btree (display_name);


--
-- Name: clients_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX clients_is_active ON public.clients USING btree (is_active);


--
-- Name: estimate_item_additional_work_estimate_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX estimate_item_additional_work_estimate_item_id ON public.estimate_item_additional_work USING btree (estimate_item_id);


--
-- Name: estimate_item_photos_estimate_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX estimate_item_photos_estimate_item_id ON public.estimate_item_photos USING btree (estimate_item_id);


--
-- Name: estimate_items_estimate_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX estimate_items_estimate_id ON public.estimate_items USING btree (estimate_id);


--
-- Name: estimate_items_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX estimate_items_product_id ON public.estimate_items USING btree (product_id);


--
-- Name: estimates_address_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX estimates_address_id ON public.estimates USING btree (address_id);


--
-- Name: estimates_client_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX estimates_client_id_idx ON public.estimates USING btree (client_id);


--
-- Name: estimates_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX estimates_status ON public.estimates USING btree (status);


--
-- Name: idx_products_name_gin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_name_gin ON public.products USING gin (name public.gin_trgm_ops);


--
-- Name: idx_settings_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_settings_group ON public.settings USING btree ("group");


--
-- Name: idx_work_types_name_vec; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_work_types_name_vec ON public.work_types USING ivfflat (name_vec public.vector_cosine_ops);


--
-- Name: invoice_items_invoice_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX invoice_items_invoice_id ON public.invoice_items USING btree (invoice_id);


--
-- Name: invoices_client_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX invoices_client_id_idx ON public.invoices USING btree (client_id);


--
-- Name: invoices_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX invoices_status ON public.invoices USING btree (status);


--
-- Name: payments_invoice_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX payments_invoice_id ON public.payments USING btree (invoice_id);


--
-- Name: products_embedding_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX products_embedding_idx ON public.products USING ivfflat (embedding public.vector_cosine_ops) WITH (lists='100');


--
-- Name: products_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX products_type ON public.products USING btree (type);


--
-- Name: project_inspections_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX project_inspections_project_id ON public.project_inspections USING btree (project_id);


--
-- Name: project_photos_inspection_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX project_photos_inspection_id ON public.project_photos USING btree (inspection_id);


--
-- Name: project_photos_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX project_photos_project_id ON public.project_photos USING btree (project_id);


--
-- Name: projects_address_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX projects_address_id ON public.projects USING btree (address_id);


--
-- Name: projects_client_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX projects_client_id ON public.projects USING btree (client_id);


--
-- Name: projects_estimate_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX projects_estimate_id ON public.projects USING btree (estimate_id);


--
-- Name: projects_scheduled_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX projects_scheduled_date ON public.projects USING btree (scheduled_date);


--
-- Name: source_maps_estimate_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX source_maps_estimate_item_id ON public.source_maps USING btree (estimate_item_id);


--
-- Name: users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email ON public.users USING btree (email);


--
-- Name: users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_username ON public.users USING btree (username);


--
-- Name: work_type_cost_history_work_type_id_captured_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX work_type_cost_history_work_type_id_captured_at_idx ON public.work_type_cost_history USING btree (work_type_id, captured_at);


--
-- Name: work_type_materials_product_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX work_type_materials_product_id_idx ON public.work_type_materials USING btree (product_id);


--
-- Name: work_type_materials_work_type_id_product_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX work_type_materials_work_type_id_product_id_unique ON public.work_type_materials USING btree (work_type_id, product_id);


--
-- Name: client_addresses client_addresses_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_addresses
    ADD CONSTRAINT client_addresses_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: estimate_item_additional_work estimate_item_additional_work_estimate_item_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estimate_item_additional_work
    ADD CONSTRAINT estimate_item_additional_work_estimate_item_id FOREIGN KEY (estimate_item_id) REFERENCES public.estimate_items(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: estimate_item_additional_work estimate_item_additional_work_estimate_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estimate_item_additional_work
    ADD CONSTRAINT estimate_item_additional_work_estimate_item_id_fkey FOREIGN KEY (estimate_item_id) REFERENCES public.estimate_items(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: estimate_item_photos estimate_item_photos_estimate_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estimate_item_photos
    ADD CONSTRAINT estimate_item_photos_estimate_item_id_fkey FOREIGN KEY (estimate_item_id) REFERENCES public.estimate_items(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: estimate_items estimate_items_estimate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estimate_items
    ADD CONSTRAINT estimate_items_estimate_id_fkey FOREIGN KEY (estimate_id) REFERENCES public.estimates(id) ON DELETE CASCADE;


--
-- Name: estimate_items estimate_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estimate_items
    ADD CONSTRAINT estimate_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: estimates estimates_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.client_addresses(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: estimates estimates_client_id_new_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_client_id_new_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: estimates estimates_converted_to_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_converted_to_invoice_id_fkey FOREIGN KEY (converted_to_invoice_id) REFERENCES public.invoices(id) ON DELETE SET NULL;


--
-- Name: invoice_items invoice_items_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.client_addresses(id);


--
-- Name: invoices invoices_client_id_new_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_client_id_new_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: payments payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: project_inspections project_inspections_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_inspections
    ADD CONSTRAINT project_inspections_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: project_photos project_photos_inspection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_photos
    ADD CONSTRAINT project_photos_inspection_id_fkey FOREIGN KEY (inspection_id) REFERENCES public.project_inspections(id);


--
-- Name: project_photos project_photos_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_photos
    ADD CONSTRAINT project_photos_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: projects projects_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.client_addresses(id);


--
-- Name: projects projects_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: projects projects_converted_to_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_converted_to_job_id_fkey FOREIGN KEY (converted_to_job_id) REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: projects projects_estimate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_estimate_id_fkey FOREIGN KEY (estimate_id) REFERENCES public.estimates(id);


--
-- Name: source_maps source_maps_estimate_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_maps
    ADD CONSTRAINT source_maps_estimate_item_id_fkey FOREIGN KEY (estimate_item_id) REFERENCES public.estimate_items(id) ON DELETE CASCADE;


--
-- Name: work_type_cost_history work_type_cost_history_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_type_cost_history
    ADD CONSTRAINT work_type_cost_history_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: work_type_cost_history work_type_cost_history_work_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_type_cost_history
    ADD CONSTRAINT work_type_cost_history_work_type_id_fkey FOREIGN KEY (work_type_id) REFERENCES public.work_types(id) ON DELETE CASCADE;


--
-- Name: work_type_materials work_type_materials_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_type_materials
    ADD CONSTRAINT work_type_materials_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: work_type_materials work_type_materials_work_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_type_materials
    ADD CONSTRAINT work_type_materials_work_type_id_fkey FOREIGN KEY (work_type_id) REFERENCES public.work_types(id) ON DELETE CASCADE;


--
-- Name: work_type_tags work_type_tags_work_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_type_tags
    ADD CONSTRAINT work_type_tags_work_type_id_fkey FOREIGN KEY (work_type_id) REFERENCES public.work_types(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

