--
-- PostgreSQL database dump
--

-- Dumped from database version 16.8
-- Dumped by pg_dump version 16.8

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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: enum_clients_client_type; Type: TYPE; Schema: public; Owner: josephmcmyne
--

CREATE TYPE public.enum_clients_client_type AS ENUM (
    'property_manager',
    'resident'
);


ALTER TYPE public.enum_clients_client_type OWNER TO josephmcmyne;

--
-- Name: enum_estimate_item_photos_photo_type; Type: TYPE; Schema: public; Owner: josephmcmyne
--

CREATE TYPE public.enum_estimate_item_photos_photo_type AS ENUM (
    'progress',
    'completed',
    'issue',
    'material',
    'other'
);


ALTER TYPE public.enum_estimate_item_photos_photo_type OWNER TO josephmcmyne;

--
-- Name: enum_estimates_status; Type: TYPE; Schema: public; Owner: josephmcmyne
--

CREATE TYPE public.enum_estimates_status AS ENUM (
    'draft',
    'sent',
    'accepted',
    'rejected',
    'expired'
);


ALTER TYPE public.enum_estimates_status OWNER TO josephmcmyne;

--
-- Name: enum_invoices_status; Type: TYPE; Schema: public; Owner: josephmcmyne
--

CREATE TYPE public.enum_invoices_status AS ENUM (
    'draft',
    'sent',
    'viewed',
    'paid',
    'overdue'
);


ALTER TYPE public.enum_invoices_status OWNER TO josephmcmyne;

--
-- Name: enum_payments_payment_method; Type: TYPE; Schema: public; Owner: josephmcmyne
--

CREATE TYPE public.enum_payments_payment_method AS ENUM (
    'cash',
    'check',
    'credit_card',
    'bank_transfer',
    'other'
);


ALTER TYPE public.enum_payments_payment_method OWNER TO josephmcmyne;

--
-- Name: enum_products_type; Type: TYPE; Schema: public; Owner: josephmcmyne
--

CREATE TYPE public.enum_products_type AS ENUM (
    'product',
    'service'
);


ALTER TYPE public.enum_products_type OWNER TO josephmcmyne;

--
-- Name: enum_project_inspections_category; Type: TYPE; Schema: public; Owner: josephmcmyne
--

CREATE TYPE public.enum_project_inspections_category AS ENUM (
    'condition',
    'measurements',
    'materials'
);


ALTER TYPE public.enum_project_inspections_category OWNER TO josephmcmyne;

--
-- Name: enum_project_photos_photo_type; Type: TYPE; Schema: public; Owner: josephmcmyne
--

CREATE TYPE public.enum_project_photos_photo_type AS ENUM (
    'before',
    'after',
    'receipt',
    'assessment',
    'condition'
);


ALTER TYPE public.enum_project_photos_photo_type OWNER TO josephmcmyne;

--
-- Name: enum_projects_status; Type: TYPE; Schema: public; Owner: josephmcmyne
--

CREATE TYPE public.enum_projects_status AS ENUM (
    'pending',
    'in_progress',
    'completed',
    'upcoming'
);


ALTER TYPE public.enum_projects_status OWNER TO josephmcmyne;

--
-- Name: enum_projects_type; Type: TYPE; Schema: public; Owner: josephmcmyne
--

CREATE TYPE public.enum_projects_type AS ENUM (
    'assessment',
    'active'
);


ALTER TYPE public.enum_projects_type OWNER TO josephmcmyne;

--
-- Name: enum_users_role; Type: TYPE; Schema: public; Owner: josephmcmyne
--

CREATE TYPE public.enum_users_role AS ENUM (
    'user',
    'admin'
);


ALTER TYPE public.enum_users_role OWNER TO josephmcmyne;

--
-- Name: estimate_item_photo_type; Type: TYPE; Schema: public; Owner: josephmcmyne
--

CREATE TYPE public.estimate_item_photo_type AS ENUM (
    'progress',
    'completed',
    'issue',
    'material',
    'other'
);


ALTER TYPE public.estimate_item_photo_type OWNER TO josephmcmyne;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: SequelizeMeta; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public."SequelizeMeta" (
    name character varying(255) NOT NULL
);


ALTER TABLE public."SequelizeMeta" OWNER TO josephmcmyne;

--
-- Name: client_addresses; Type: TABLE; Schema: public; Owner: josephmcmyne
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


ALTER TABLE public.client_addresses OWNER TO josephmcmyne;

--
-- Name: COLUMN client_addresses.name; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON COLUMN public.client_addresses.name IS 'Name or label for this address (e.g., "Main Office", "Property at 123 Main St")';


--
-- Name: COLUMN client_addresses.is_primary; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON COLUMN public.client_addresses.is_primary IS 'Indicates if this is the primary address for the client';


--
-- Name: clients; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.clients (
    id uuid NOT NULL,
    payment_terms character varying(255),
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


ALTER TABLE public.clients OWNER TO josephmcmyne;

--
-- Name: client_view; Type: VIEW; Schema: public; Owner: josephmcmyne
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


ALTER VIEW public.client_view OWNER TO josephmcmyne;

--
-- Name: estimate_item_additional_work; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.estimate_item_additional_work (
    id uuid NOT NULL,
    estimate_item_id uuid NOT NULL,
    description text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.estimate_item_additional_work OWNER TO josephmcmyne;

--
-- Name: estimate_item_photos; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.estimate_item_photos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    estimate_item_id uuid NOT NULL,
    file_path character varying(255) NOT NULL,
    original_name character varying(255),
    photo_type public.estimate_item_photo_type DEFAULT 'progress'::public.estimate_item_photo_type NOT NULL,
    notes text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.estimate_item_photos OWNER TO josephmcmyne;

--
-- Name: TABLE estimate_item_photos; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON TABLE public.estimate_item_photos IS 'Stores photos associated with specific estimate line items for project documentation';


--
-- Name: estimate_items; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.estimate_items (
    id uuid NOT NULL,
    estimate_id uuid NOT NULL,
    description text NOT NULL,
    quantity numeric(10,2) DEFAULT 1 NOT NULL,
    price numeric(10,2) DEFAULT 0 NOT NULL,
    tax_rate numeric(5,2) DEFAULT 0 NOT NULL,
    item_total numeric(10,2) DEFAULT 0 NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    product_id uuid,
    source_data jsonb,
    unit character varying(50),
    custom_product_data jsonb
);


ALTER TABLE public.estimate_items OWNER TO josephmcmyne;

--
-- Name: estimates; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.estimates (
    id uuid NOT NULL,
    status public.enum_estimates_status DEFAULT 'draft'::public.enum_estimates_status,
    subtotal numeric(10,2) DEFAULT 0 NOT NULL,
    tax_total numeric(10,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(10,2) DEFAULT 0 NOT NULL,
    total numeric(10,2) DEFAULT 0 NOT NULL,
    notes text,
    terms text,
    pdf_path character varying(255),
    converted_to_invoice_id uuid,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone,
    estimate_number character varying(255) NOT NULL,
    date_created date NOT NULL,
    valid_until date NOT NULL,
    address_id uuid,
    project_id uuid,
    client_id uuid
);


ALTER TABLE public.estimates OWNER TO josephmcmyne;

--
-- Name: COLUMN estimates.pdf_path; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON COLUMN public.estimates.pdf_path IS 'Path to the generated PDF file';


--
-- Name: COLUMN estimates.converted_to_invoice_id; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON COLUMN public.estimates.converted_to_invoice_id IS 'Reference to invoice if this estimate was converted';


--
-- Name: COLUMN estimates.address_id; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON COLUMN public.estimates.address_id IS 'Foreign key to client_addresses table for the selected address';


--
-- Name: COLUMN estimates.project_id; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON COLUMN public.estimates.project_id IS 'Reference to project if this estimate is associated with a project';


--
-- Name: COLUMN estimates.client_id; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON COLUMN public.estimates.client_id IS 'Foreign key to clients table';


--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.invoice_items (
    id uuid NOT NULL,
    invoice_id uuid NOT NULL,
    description text NOT NULL,
    quantity numeric(10,2) DEFAULT 1 NOT NULL,
    price numeric(10,2) DEFAULT 0 NOT NULL,
    tax_rate numeric(5,2) DEFAULT 0 NOT NULL,
    item_total numeric(10,2) DEFAULT 0 NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.invoice_items OWNER TO josephmcmyne;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.invoices (
    id uuid NOT NULL,
    invoice_number character varying(255) NOT NULL,
    status public.enum_invoices_status DEFAULT 'draft'::public.enum_invoices_status,
    subtotal numeric(10,2) DEFAULT 0 NOT NULL,
    total numeric(10,2) DEFAULT 0 NOT NULL,
    notes text,
    terms text,
    address_id uuid,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone,
    date_created date NOT NULL,
    date_due date NOT NULL,
    tax_total numeric(10,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(10,2) DEFAULT 0 NOT NULL,
    pdf_path character varying(255),
    client_id uuid
);


ALTER TABLE public.invoices OWNER TO josephmcmyne;

--
-- Name: COLUMN invoices.address_id; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON COLUMN public.invoices.address_id IS 'Foreign key to client_addresses table for the selected address';


--
-- Name: COLUMN invoices.pdf_path; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON COLUMN public.invoices.pdf_path IS 'Path to the generated PDF file';


--
-- Name: COLUMN invoices.client_id; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON COLUMN public.invoices.client_id IS 'Foreign key to clients table';


--
-- Name: llm_prompts; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.llm_prompts (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    prompt_text text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.llm_prompts OWNER TO josephmcmyne;

--
-- Name: llm_prompts_id_seq; Type: SEQUENCE; Schema: public; Owner: josephmcmyne
--

CREATE SEQUENCE public.llm_prompts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.llm_prompts_id_seq OWNER TO josephmcmyne;

--
-- Name: llm_prompts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: josephmcmyne
--

ALTER SEQUENCE public.llm_prompts_id_seq OWNED BY public.llm_prompts.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.payments (
    id uuid NOT NULL,
    invoice_id uuid NOT NULL,
    amount numeric(10,2) NOT NULL,
    payment_date date NOT NULL,
    payment_method character varying(255) DEFAULT 'other'::character varying,
    notes text,
    reference_number character varying(255),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.payments OWNER TO josephmcmyne;

--
-- Name: COLUMN payments.reference_number; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON COLUMN public.payments.reference_number IS 'Reference/transaction number for the payment';


--
-- Name: pre_assessment_photos; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.pre_assessment_photos (
    id uuid NOT NULL,
    pre_assessment_id uuid,
    file_path character varying(255),
    original_name character varying(255),
    description text,
    area_label character varying(255),
    annotations jsonb,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.pre_assessment_photos OWNER TO josephmcmyne;

--
-- Name: pre_assessment_project_types; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.pre_assessment_project_types (
    id uuid NOT NULL,
    pre_assessment_id uuid NOT NULL,
    project_type character varying(255) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_subtype character varying(255)
);


ALTER TABLE public.pre_assessment_project_types OWNER TO josephmcmyne;

--
-- Name: pre_assessments; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.pre_assessments (
    id uuid NOT NULL,
    client_id uuid,
    project_type character varying(255),
    project_subtype character varying(255),
    problem_description text,
    timeline_requirements jsonb,
    budget_parameters jsonb,
    access_information text,
    decision_maker_info jsonb,
    questionnaire_data jsonb,
    llm_generated_checklist jsonb,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    client_address_id uuid
);


ALTER TABLE public.pre_assessments OWNER TO josephmcmyne;

--
-- Name: products; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.products (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    price numeric(10,2) DEFAULT 0 NOT NULL,
    tax_rate numeric(5,2) DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    type public.enum_products_type DEFAULT 'service'::public.enum_products_type,
    unit character varying(255) DEFAULT 'each'::character varying,
    deleted_at timestamp with time zone
);


ALTER TABLE public.products OWNER TO josephmcmyne;

--
-- Name: COLUMN products.unit; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON COLUMN public.products.unit IS 'Unit of measurement (sq ft, linear ft, each, etc.)';


--
-- Name: project_inspections; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.project_inspections (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    category public.enum_project_inspections_category NOT NULL,
    content jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.project_inspections OWNER TO josephmcmyne;

--
-- Name: project_photos; Type: TABLE; Schema: public; Owner: josephmcmyne
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


ALTER TABLE public.project_photos OWNER TO josephmcmyne;

--
-- Name: project_subtypes; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.project_subtypes (
    id uuid NOT NULL,
    project_type_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    description text,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.project_subtypes OWNER TO josephmcmyne;

--
-- Name: project_type_questionnaires; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.project_type_questionnaires (
    id uuid NOT NULL,
    project_type character varying(255) NOT NULL,
    project_subtype character varying(255),
    questionnaire_schema jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.project_type_questionnaires OWNER TO josephmcmyne;

--
-- Name: project_types; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.project_types (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    description text,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.project_types OWNER TO josephmcmyne;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: josephmcmyne
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
    assessment_id uuid,
    converted_to_job_id uuid,
    pre_assessment_id uuid
);


ALTER TABLE public.projects OWNER TO josephmcmyne;

--
-- Name: settings; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.settings (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    value text,
    description text,
    "group" character varying(255) DEFAULT 'general'::character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.settings OWNER TO josephmcmyne;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: josephmcmyne
--

CREATE SEQUENCE public.settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.settings_id_seq OWNER TO josephmcmyne;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: josephmcmyne
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: source_maps; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.source_maps (
    id uuid NOT NULL,
    estimate_item_id uuid NOT NULL,
    source_type character varying(50) NOT NULL,
    source_data jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.source_maps OWNER TO josephmcmyne;

--
-- Name: users; Type: TABLE; Schema: public; Owner: josephmcmyne
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    username character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role public.enum_users_role DEFAULT 'user'::public.enum_users_role,
    theme_preference character varying(255) DEFAULT 'dark'::character varying NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone,
    avatar character varying(255)
);


ALTER TABLE public.users OWNER TO josephmcmyne;

--
-- Name: llm_prompts id; Type: DEFAULT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.llm_prompts ALTER COLUMN id SET DEFAULT nextval('public.llm_prompts_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Data for Name: SequelizeMeta; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public."SequelizeMeta" (name) FROM stdin;
20250331160336-fix-carddav-uri-column.js
20250331000000-add-pdf-settings.js
20250331000001-fix-carddav-cache.js
20250331074510-create-missing-invoice-tables.js
20250331160925-add-date-created-to-invoices.js
20250331170000-fix-settings-column-names.js
20250401000000-create-client-tables.js
20250401100000-remove-carddav-update-clients.js
20250401200000-final-carddav-removal.js
20250401200000-add-client-type.js
20250401300000-fix-client-references.js
20250402000000-add-address-id-to-invoices.js
20250401000001-enhance-pdf-settings.js
20250401000002-insert-pdf-settings.js
20250401175626-add-address-id-to-estimates.js
20250401185505-cleanup-estimates-table-schema.js
20250402100000-update-invoice-client-id-nullable.js
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
20250402150000-fix-client-display-name.js
20250403000001-add-additional-work-to-projects.js
20250404000001-add-address-id-to-projects.js
add-assessment-id-to-projects.js
add-project-id-to-estimates.js
20250330000000-create-users-table.js
20250404000010-add-converted-to-job-id-to-projects.js
20250406041035-add-condition-to-photo-type-enum.js
20250406221212-add-avatar-to-users.js
20250407-remove-services-from-products.js
20250407034210-fix-settings-timestamp-columns.js
20250407165000-create-llm-prompts.js
20250408000001-update-project-inspections-measurements.js
20250408000002-cleanup-project-photos.js
20250408021900-add-type-to-products.js
20250408150000-add-source-mapping.js
20250410-add-pre-assessment-tables.js
20250410000001-create-pre-assessment-tables.js
20250411-add-project-subtype-to-pre-assessment-project-types.js
20250412001000-standardize-project-fields.js
20250413000000-standardize-id-fields.js
20250414000000-cleanup-standardization.js
20250414090000-create-estimate-item-photos.js
20250414161844-create-estimate-item-additional-work.js
\.


--
-- Data for Name: client_addresses; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.client_addresses (id, client_id, name, street_address, city, state, postal_code, country, is_primary, notes, created_at, updated_at) FROM stdin;
6b8a50c2-439a-4daa-a868-0431cbe28bd5	cef8a5e0-ba91-45da-9cb8-e20c4292b2a1	Primary Address	9010 Stinger Dr	Championsgate	FL	33896	USA	t		2025-04-04 02:25:54.432+00	2025-04-04 02:25:54.432+00
3cd9e874-8bbd-40ed-ab8e-a846fd4b31ae	a04af1e2-7946-4387-ad73-7456c91af533	Primary Address	3712 pioneer trails dr	Lakeland	FL	33810	USA	t		2025-04-08 20:13:27.766+00	2025-04-08 20:13:27.766+00
91ed4d70-ae14-467a-89b4-8109914ef512	26ff807d-0535-49c3-8144-2aae123c02ed	Primary Address	526 Lyndol St	Lakeland	FL	33815	USA	f		2025-04-12 02:56:46.153+00	2025-04-12 12:34:14.375+00
91dfe526-6171-418b-80d8-279e7baee1c7	26ff807d-0535-49c3-8144-2aae123c02ed	Primary Address	526 Lyndol St	Lakeland	FL	33815	USA	f		2025-04-12 02:56:46.153+00	2025-04-12 19:23:03.647+00
69d54a11-531e-4da2-98fd-028a42b9296d	26ff807d-0535-49c3-8144-2aae123c02ed	Primary Address	256 Lyndol St	Lakeland	FL	33815	USA	f		2025-04-12 02:56:46.153+00	2025-04-12 19:23:03.674+00
c18892a9-8e8a-4592-a61d-10293cb131a3	26ff807d-0535-49c3-8144-2aae123c02ed	Primary Address	256 Lyndol St	Lakeland	FL	33815	USA	t		2025-04-12 02:56:46.153+00	2025-04-12 19:23:03.676+00
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.clients (id, payment_terms, default_tax_rate, default_currency, notes, is_active, created_at, updated_at, display_name, company, email, phone, client_type) FROM stdin;
c48c7458-f18e-4a5f-bfd5-5f329cc3e141	\N	\N	USD	\N	t	2025-04-01 00:32:56.049+00	2025-04-01 00:32:56.049+00	Mr Johnson Science	\N	\N	(904) 274-0181	resident
4ee99d82-9f8f-496f-aba4-0969fe49c248	\N	\N	USD	\N	t	2025-04-01 00:28:53.418+00	2025-04-01 00:28:53.418+00	Hardy Century 21	\N	\N	+1 407-922-1555	resident
d89d95d1-e8da-43e2-a978-5aac979fc89a	\N	\N	USD	\N	t	2025-04-01 00:32:56.042+00	2025-04-01 00:32:56.043+00	rich lee roofer	\N	\N	+1 314-458-3449	resident
953de72c-3590-4889-a8ce-ca22c46d947f	\N	\N	USD	\N	t	2025-04-01 00:32:56.044+00	2025-04-01 00:32:56.044+00	Sandra	\N	\N	(321) 317-7337	resident
9e0906d7-e5ae-4881-bd6f-37b6a33766dc	\N	\N	USD	\N	t	2025-04-01 00:32:56.046+00	2025-04-01 00:32:56.046+00	SteveBlueSky	\N	\N	+14075754920	resident
08220ad2-1103-4a20-bb83-9e5118d7df96	\N	\N	USD	\N	t	2025-04-01 00:32:56.047+00	2025-04-01 00:32:56.047+00	fyi inspection	\N	\N	8635130349	resident
4fcdbe23-0268-44e7-a1bb-b651d78b5e19	\N	\N	USD	\N	t	2025-04-01 00:32:56.05+00	2025-04-01 00:32:56.05+00	justin white	\N	\N	+1 813-526-6880	resident
af1b56fe-b223-4313-b0ef-a99a09921242	\N	\N	USD	\N	t	2025-04-01 00:32:56.045+00	2025-04-01 00:32:56.045+00	Charliemac	\N	\N	+14073982304	resident
6a710a33-e265-4a11-b79e-c3dda94dd20f	\N	\N	USD	\N	t	2025-04-01 00:32:56.045+00	2025-04-01 00:32:56.045+00	Delia	\N	\N	(407) 579-2090	resident
8603d9db-c72b-4610-9a97-4d8a1a26ecf5	\N	\N	USD	\N	t	2025-04-01 00:32:56.048+00	2025-04-01 00:32:56.048+00	Mrs Lieb	\N	\N	(727) 265-2019	resident
0988f598-9cff-4149-90ff-b107bc667c32	\N	\N	USD	\N	t	2025-04-01 00:32:56.048+00	2025-04-01 00:32:56.048+00	Daniel Young	\N	\N	(407) 361-6236	resident
bd581223-d667-480e-9970-2a0178a60783	\N	\N	USD	\N	t	2025-04-01 00:32:56.049+00	2025-04-01 00:32:56.049+00	Carol Romaine	\N	\N	+1 203-424-7566	resident
7dd3f661-d7e0-492e-9c91-51349efaafdd	\N	\N	USD	\N	t	2025-04-01 00:28:53.41+00	2025-04-01 00:28:53.41+00	Donny  McMyne	\N	dmcmyne@yahoo.com	8049310777	resident
44b50b41-1f47-4490-b28f-c5b348e9fbd9	\N	\N	USD	\N	t	2025-04-01 00:32:56.054+00	2025-04-01 00:32:56.054+00	Son	myContacts	\N	(321) 234-4692	resident
a1719805-3586-4a27-96ea-3a4b301b1242	\N	\N	USD	\N	t	2025-04-01 00:32:56.055+00	2025-04-01 00:32:56.055+00	Mrs. Downing Peer Counseling	\N	\N	(828) 539-0695	resident
bee611fc-54de-4908-965d-8e64aa36ce4b	\N	\N	USD	\N	t	2025-04-01 00:32:56.055+00	2025-04-01 00:32:56.055+00	Barrington	\N	\N	(407) 536-1177	resident
d45153b4-b0e2-47a0-8a30-f3d8149a00cf	\N	\N	USD	\N	t	2025-04-01 00:32:56.051+00	2025-04-01 00:32:56.051+00	Jean Carlo	\N	\N	(407) 720-0422	resident
362f4c7a-54da-45d4-8f1e-c97fc84a4638	\N	\N	USD	\N	t	2025-04-01 00:32:56.053+00	2025-04-01 00:32:56.053+00	pete rv world	\N	\N	+1 863-602-6144	resident
4caa2f57-2c77-4d71-93d3-76f7cfdeb58a	\N	\N	USD	\N	t	2025-04-01 00:32:56.054+00	2025-04-01 00:32:56.054+00	Sean Website	\N	\N	(407) 361-6237	resident
800b0a22-72bb-4693-b618-0324bf38aa07	\N	\N	USD	\N	t	2025-04-01 00:32:56.055+00	2025-04-01 00:32:56.055+00	phil young	\N	\N	+1 407-818-7187	resident
9afa4ce9-72cd-4222-a15c-4217044de20e	\N	\N	USD	\N	t	2025-04-01 00:32:56.056+00	2025-04-01 00:32:56.056+00	Twank En	\N	\N	+18637097760	resident
4744c422-3a7e-4ccf-a9c1-4b8fab01fff5	\N	\N	USD	\N	t	2025-04-01 00:32:56.051+00	2025-04-01 00:32:56.051+00	TereGPS	\N	\N	(407) 534-0276	resident
904637a8-4c4e-49b1-9151-ef39854130db	\N	\N	USD	\N	t	2025-04-01 00:32:56.052+00	2025-04-01 00:32:56.052+00	Mrs Brown Math	\N	\N	+1 850-583-6791	resident
a2e2eb31-6f6b-43a4-b279-c60d507685c7	\N	\N	USD	\N	t	2025-04-01 00:32:56.052+00	2025-04-01 00:32:56.052+00	Sabrina Mouton	\N	\N	+1 971-413-3237	resident
0752f297-3d07-41c2-ad78-dc25e9367d6c	\N	\N	USD	\N	t	2025-04-01 00:32:56.052+00	2025-04-01 00:32:56.052+00	Dean	\N	\N	+1 407-807-2969	resident
46a8e233-6b15-4261-8689-7861a5ad78b8	\N	\N	USD	\N	t	2025-04-01 00:32:56.053+00	2025-04-01 00:32:56.053+00	Phillip And Helen	\N	\N	+1 407-201-4333	resident
398a9280-0994-4e06-836f-eb298090c838	\N	\N	USD	\N	t	2025-04-01 00:32:56.053+00	2025-04-01 00:32:56.053+00	Denise	Macaroni Grill	\N	(321) 945-2628	resident
10a64445-290b-48d2-b40f-55a0da7aac89	\N	\N	USD	\N	t	2025-04-01 00:32:56.059+00	2025-04-01 00:32:56.059+00	Mrs Jackson Civics	\N	\N	+1 754-227-9337	resident
08f74d1f-da2a-4de2-a926-f8ca1c199e19	\N	\N	USD	\N	t	2025-04-01 00:32:56.057+00	2025-04-01 00:32:56.057+00	Joe	\N	joe@806040.xyz	+18633988284	resident
8f0faa0a-1753-44b3-a718-36ed127707be	\N	\N	USD	\N	t	2025-04-01 00:32:56.059+00	2025-04-01 00:32:56.059+00	Son	\N	jamesmcmyne09@gmail.com	\N	resident
37375fe7-12d1-49b5-b75c-cb51e3f861cc	\N	\N	USD	\N	t	2025-04-01 00:32:56.059+00	2025-04-01 00:32:56.059+00	fidel	\N	\N	+1 407-301-1861	resident
5cfa7c4a-0a62-40bb-aae4-b0efcbb21526	\N	\N	USD	\N	t	2025-04-01 00:32:56.06+00	2025-04-01 00:32:56.06+00	Suzy McMyne	\N	\N	(570) 903-1610	resident
cd762aa4-a9c3-4377-9676-2fe9252b102c	\N	\N	USD	\N	t	2025-04-01 00:32:56.06+00	2025-04-01 00:32:56.06+00	Fabio	\N	\N	+1407-538-8311	resident
c0bfa559-799c-44bf-aec5-aec34591c3f0	\N	\N	USD	\N	t	2025-04-01 00:32:56.06+00	2025-04-01 00:32:56.06+00	Mrs Carlan	Guitar FLVS	\N	8502967566	resident
4afef814-629b-44d6-a3d8-5b2895604e06	\N	\N	USD	\N	t	2025-04-01 00:32:56.061+00	2025-04-01 00:32:56.061+00	Paul	\N	\N	+15857348989	resident
e34d9cae-14a1-4582-852a-e2175e1a4c6e	\N	\N	USD	\N	t	2025-04-01 00:32:56.056+00	2025-04-01 00:32:56.056+00	Bastard	\N	\N	+18632428856	resident
6c2e3eea-0054-4904-90c2-6bb4a262e79f	\N	\N	USD	\N	t	2025-04-01 00:32:56.056+00	2025-04-01 00:32:56.056+00	Joseph McMyne	\N	\N	\N	resident
7c919d09-6708-415a-a700-d7f74fe3ea4a	\N	\N	USD	\N	t	2025-04-01 00:32:56.058+00	2025-04-01 00:32:56.058+00	James	\N	\N	\N	resident
89fb8712-e96b-4233-8fc8-9d6fad2a767a	\N	\N	USD	\N	t	2025-04-01 00:28:53.413+00	2025-04-01 00:28:53.413+00	Kim Mood Service Channel	\N	\N	5163906784	resident
4b939430-ff8d-4cc3-9eec-31efc6141cfd	\N	\N	USD	\N	t	2025-04-01 00:28:53.427+00	2025-04-01 00:28:53.427+00	Kathy	\N	\N	(407) 750-1813	resident
7e2d71fd-7939-4f31-b75a-a14915e14ee8	\N	\N	USD	\N	t	2025-04-01 00:32:56.057+00	2025-04-01 00:32:56.057+00	Jayson	myContacts	\N	+1 863-709-5053	resident
8254beb6-ec9f-4f48-9850-36a434b7e67f	\N	\N	USD	\N	t	2025-04-01 00:32:56.057+00	2025-04-01 00:32:56.057+00	luismex	\N	\N	+1 407-486-2435	resident
f8170db2-6183-48b1-9644-65541e7bb27e	\N	\N	USD	\N	t	2025-04-01 00:32:56.062+00	2025-04-01 00:32:56.062+00	Pat	\N	\N	+1 863-816-4689	resident
0d78e4f3-763c-456b-a2a9-58674715b19a	\N	\N	USD	\N	t	2025-04-01 00:32:56.063+00	2025-04-01 00:32:56.063+00	shameer.kassim	\N	shameer.kassim@macgrill.com	+1 321-438-6005	resident
32b63f52-e2bd-4d47-97b8-ef714a8c7628	\N	\N	USD	\N	t	2025-04-01 00:32:56.063+00	2025-04-01 00:32:56.063+00	Nancy Iglesia	\N	\N	(407) 318-0064	resident
2c47b34a-bee9-476a-aae8-313c34f880e4	\N	\N	USD	\N	t	2025-04-01 00:32:56.063+00	2025-04-01 00:32:56.063+00	Brandon	\N	\N	+1 407-489-0159	resident
3124186b-91f5-4601-9646-67df23ea6cb8	\N	\N	USD	\N	t	2025-04-01 00:32:56.064+00	2025-04-01 00:32:56.064+00	Michael Huxell	\N	\N	(407) 346-3029	resident
531945d3-c25f-46c6-98bf-8be916528a06	\N	\N	USD	\N	t	2025-04-01 00:32:56.064+00	2025-04-01 00:32:56.064+00	Momma GOVT	\N	\N	+1 318-791-0268	resident
0ff3cdc5-ef41-409e-99f3-fd0e1c8626bd	\N	\N	USD	\N	t	2025-04-01 00:32:56.065+00	2025-04-01 00:32:56.065+00	AuntPatty	\N	\N	570-290-2373	resident
507860f4-eea2-441d-a4bf-0a8a60bacec5	\N	\N	USD	\N	t	2025-04-01 00:28:53.386+00	2025-04-01 00:28:53.386+00	Nancy	\N	\N	863-660-1773	resident
f07101e5-202b-4ecd-b250-5aa515751931	\N	\N	USD	\N	t	2025-04-01 00:32:56.066+00	2025-04-01 00:32:56.066+00	Eli Firm Inc	\N	\N	+1 863-738-0775	resident
3844b687-cb9b-4092-892f-5f787d88ea79	\N	\N	USD	\N	t	2025-04-01 00:32:56.061+00	2025-04-01 00:32:56.061+00	Christian	\N	\N	(407) 837-1199	resident
4f304b90-f8ac-412f-8405-8266495be854	\N	\N	USD	\N	t	2025-04-01 00:32:56.062+00	2025-04-01 00:32:56.062+00	Mark prager	\N	\N	(321) 444-9212	resident
5a1e5bd7-a873-41a9-8898-03c596429321	\N	\N	USD	\N	t	2025-04-01 00:32:56.063+00	2025-04-01 00:32:56.063+00	Teelee	\N	\N	+15044102026	resident
30a312e6-f0b1-49e6-acc2-1ae6dd62a693	\N	\N	USD	\N	t	2025-04-01 00:32:56.066+00	2025-04-01 00:32:56.066+00	Rich Be	\N	\N	8134842655	resident
57bcfb02-0daf-4171-9448-987306007f12	\N	\N	USD	\N	t	2025-04-01 00:32:56.065+00	2025-04-01 00:32:56.065+00	Sofia	\N	\N	+1 407-346-1202	resident
7a7706dd-223c-4ee4-9785-b41fd8244e47	\N	\N	USD	\N	t	2025-04-01 00:32:56.068+00	2025-04-01 00:32:56.068+00	Tanner Madsen	Aptive Solar;	madsentanner@gmail.com	435-262-0704	resident
45e9f03b-aabf-4a58-852e-97e3ddc4aa18	\N	\N	USD	\N	t	2025-04-01 00:32:56.038+00	2025-04-01 00:32:56.039+00	Nicholas Mid Atlantic Roofing Supply	\N	\N	+1 813-255-3032	resident
9219d786-0f1e-4717-93cd-34c95e216e90	\N	\N	USD	\N	t	2025-04-01 00:32:56.062+00	2025-04-01 00:32:56.062+00	Big Lu	\N	\N	+1 407-572-6589	resident
f59e7326-c301-4d77-9383-4b4f47c5ec86	\N	\N	USD	\N	t	2025-04-01 00:32:56.05+00	2025-04-01 00:32:56.05+00	Milanreal	\N	\N	+14073613233	resident
b726801f-052a-485e-a5d4-4f31bd3cb9dc	\N	\N	USD	\N	t	2025-04-01 00:32:56.069+00	2025-04-01 00:32:56.069+00	Elevate Wildlife Removal	Elevate Wildlife Removal;	tyler.elevatewildlife@gmail.com	863-225-1887	resident
ba911582-1daa-47d9-9d8a-5ed85bc0cf30	Net 30	8.25	USD	This is a test client created directly in the database.	t	2025-04-01 01:50:51.049+00	2025-04-01 01:50:51.049+00	Test Direct Client	Test Company Inc.	test@example.com	555-123-4567	resident
cef8a5e0-ba91-45da-9cb8-e20c4292b2a1		0.00	USD		t	2025-04-04 02:25:54.426+00	2025-04-04 02:25:54.426+00	Chris	Prestige Florida Villas	info@prestigefloridavillas.com	3529785126	property_manager
a04af1e2-7946-4387-ad73-7456c91af533		0.00	USD		t	2025-04-08 20:13:27.759+00	2025-04-08 20:13:27.759+00	Robin		odell.hicks.robin@gmail.com	9412539088	resident
26ff807d-0535-49c3-8144-2aae123c02ed		0.00	USD		t	2025-04-12 02:56:46.147+00	2025-04-12 19:23:03.586+00	Kassahun W. Gebremariam		Barragan91rosana@gmail.com	8132159096	resident
\.


--
-- Data for Name: estimate_item_additional_work; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.estimate_item_additional_work (id, estimate_item_id, description, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: estimate_item_photos; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.estimate_item_photos (id, estimate_item_id, file_path, original_name, photo_type, notes, metadata, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: estimate_items; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.estimate_items (id, estimate_id, description, quantity, price, tax_rate, item_total, sort_order, created_at, updated_at, product_id, source_data, unit, custom_product_data) FROM stdin;
f7603e15-fe20-4704-bee5-5d11a514483e	3913a2b7-dac8-447a-9e20-76fe2bf340b3	Install new insulation	250.00	1.00	0.00	250.00	0	2025-04-10 13:31:25.302+00	2025-04-10 13:40:05.006+00	\N	\N	sq ft	\N
3310d612-bf3f-46c1-ab94-ad60fe927873	3913a2b7-dac8-447a-9e20-76fe2bf340b3	Cabinet removal and disposal	1.00	200.00	0.00	200.00	1	2025-04-10 13:31:25.303+00	2025-04-10 13:40:05.006+00	\N	\N	each	\N
36d71313-e771-4ca3-a911-3286ecd64bb3	3913a2b7-dac8-447a-9e20-76fe2bf340b3	Install new cabinets	9.00	75.00	0.00	675.00	2	2025-04-10 13:31:25.304+00	2025-04-10 13:40:05.007+00	\N	\N	each	\N
c6c331d4-50b2-408b-9887-65f7aef81c9e	3913a2b7-dac8-447a-9e20-76fe2bf340b3	Job site preparation and cleanup	1.00	50.00	0.00	50.00	3	2025-04-10 13:31:25.305+00	2025-04-10 13:40:05.008+00	\N	\N	hours	\N
384c10f1-a4d6-4c7a-8b1a-3e736fb148cc	3913a2b7-dac8-447a-9e20-76fe2bf340b3	Debris disposal	1.00	250.00	0.00	250.00	4	2025-04-10 13:31:25.305+00	2025-04-10 13:40:05.009+00	\N	\N	each	\N
a8d0e32f-bef5-4d46-8181-fabbb1d315a9	3913a2b7-dac8-447a-9e20-76fe2bf340b3	Subfloor Replacement	160.00	4.00	0.00	640.00	5	2025-04-10 13:31:25.296+00	2025-04-10 13:40:05.009+00	b379628c-85a5-45d6-bda5-189e4196f46a	\N	sq ft	\N
7560ecca-9c91-418d-b3b9-e426158c1193	3913a2b7-dac8-447a-9e20-76fe2bf340b3	Laminate Flooring Installation with trim	160.00	4.50	0.00	720.00	6	2025-04-10 13:31:25.297+00	2025-04-10 13:40:05.01+00	e64c9e68-be27-45c5-9878-04c7c8e2ca57	\N	sq ft	\N
d478decb-1d6e-455e-8fe9-3468033ddbd5	3913a2b7-dac8-447a-9e20-76fe2bf340b3	Underpinning removal and disposal	100.00	2.50	0.00	250.00	7	2025-04-10 13:31:25.298+00	2025-04-10 13:40:05.011+00	\N	\N	ln ft	\N
4ae7df70-53a1-4309-9410-7bb8a7f3a1a9	3913a2b7-dac8-447a-9e20-76fe2bf340b3	Install new underpinning	100.00	5.00	0.00	500.00	8	2025-04-10 13:31:25.298+00	2025-04-10 13:40:05.012+00	\N	\N	ln ft	\N
d50c9df7-e996-42cd-a106-488199d79fa9	3913a2b7-dac8-447a-9e20-76fe2bf340b3	Insulation removal and disposal	1.00	45.00	0.00	45.00	9	2025-04-10 13:31:25.3+00	2025-04-10 13:40:05.014+00	\N	\N	sq ft	\N
acdceada-fe73-470a-93c3-49da685ab513	3913a2b7-dac8-447a-9e20-76fe2bf340b3	Plumbing adjustments	1.00	75.00	0.00	75.00	10	2025-04-10 13:40:05.004+00	2025-04-10 13:40:05.015+00	\N	\N	\N	\N
b0940752-88b0-40b8-86e2-bc4c69b6866e	7d0660d5-619c-4efc-b92d-775c55327319	Cleanup and Disposal	1.00	400.00	0.00	400.00	9	2025-04-12 11:45:27.964+00	2025-04-12 11:45:27.967+00	\N	\N	each	\N
76678439-3822-4f7a-af7b-dc1289569464	7d0660d5-619c-4efc-b92d-775c55327319	Insulate Roof Pans With Foam Inserts and Aluminum Cover	260.00	6.00	0.00	1560.00	0	2025-04-12 06:05:13.558+00	2025-04-12 11:45:27.968+00	\N	\N	sq ft	\N
9908752b-0cb1-49c2-8d3b-c2779da8c654	7d0660d5-619c-4efc-b92d-775c55327319	Exterior Home and Under Carport Painting	1849.00	2.00	0.00	3698.00	1	2025-04-12 06:05:13.56+00	2025-04-12 11:45:27.969+00	\N	\N	sq ft	\N
467a7189-421b-4c54-8980-588e303cfdd2	7d0660d5-619c-4efc-b92d-775c55327319	Underpinning	660.00	4.00	0.00	2640.00	2	2025-04-12 06:05:13.562+00	2025-04-12 11:45:27.969+00	\N	\N	sq ft	\N
3f72cfce-d63e-409e-8628-9d0c08769613	7d0660d5-619c-4efc-b92d-775c55327319	Insulation For Underpinning	81.00	3.00	0.00	243.00	3	2025-04-12 06:05:13.563+00	2025-04-12 11:45:27.97+00	\N	\N	sq ft	\N
23183260-0eeb-46ab-a583-852b1b68b3ea	7d0660d5-619c-4efc-b92d-775c55327319	Laminate Flooring Installation	500.00	1.00	0.00	500.00	4	2025-04-12 06:05:13.564+00	2025-04-12 11:45:27.97+00	\N	\N	sq ft	\N
cc8e7cbc-8bc0-4291-8df8-4eafca7f3a70	7d0660d5-619c-4efc-b92d-775c55327319	Subfloor Replacement	352.00	3.00	0.00	1056.00	5	2025-04-12 06:05:13.565+00	2025-04-12 11:45:27.971+00	\N	\N	sq ft	\N
539ffa35-b78b-4a3a-84cb-2612f73e30f7	7d0660d5-619c-4efc-b92d-775c55327319	Roof Pans 10'	10.00	125.00	0.00	1250.00	6	2025-04-12 06:05:13.566+00	2025-04-12 11:45:27.971+00	\N	\N	each	\N
198ca272-2c2f-4693-b9cf-5278315abac0	7d0660d5-619c-4efc-b92d-775c55327319	Leveling With Pads and Shims on Two Piers	2.00	75.00	0.00	150.00	7	2025-04-12 06:05:13.566+00	2025-04-12 11:45:27.972+00	\N	\N	hours	\N
4248357f-79c2-4089-889f-372407a8eb76	7d0660d5-619c-4efc-b92d-775c55327319	Wall Panels Installation and batten strips	9.00	65.00	0.00	585.00	8	2025-04-12 06:05:13.568+00	2025-04-12 11:45:27.972+00	\N	\N	pieces	\N
\.


--
-- Data for Name: estimates; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.estimates (id, status, subtotal, tax_total, discount_amount, total, notes, terms, pdf_path, converted_to_invoice_id, created_at, updated_at, deleted_at, estimate_number, date_created, valid_until, address_id, project_id, client_id) FROM stdin;
3913a2b7-dac8-447a-9e20-76fe2bf340b3	accepted	3655.00	0.00	0.00	3655.00	Adjustments made for additional 2 cabinets and plumbing as we discussed on the phone.	This estimate is valid for 30 days from the date issued.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00011.pdf	\N	2025-04-10 13:31:25.284+00	2025-04-14 15:32:43.494+00	\N	EST-00011	2025-04-10	2025-05-10	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
5cf1f48e-bd50-42f7-be27-c458854537ba	sent	3.00	0.00	0.00	3.00		This estimate is valid for 30 days.	\N	\N	2025-04-02 05:13:59.287+00	2025-04-15 15:48:36.034+00	2025-04-15 15:48:36.034+00	EST-00005	2025-04-02	2025-05-02	\N	\N	\N
ba5a2454-55b7-44e3-b7b0-53a4ab306173	sent	750.00	0.00	0.00	750.00		This estimate is valid for 30 days.	\N	\N	2025-04-04 14:06:35.744+00	2025-04-15 15:48:43.163+00	2025-04-15 15:48:43.162+00	EST-00007	2025-04-04	2025-05-04	6b8a50c2-439a-4daa-a868-0431cbe28bd5	\N	cef8a5e0-ba91-45da-9cb8-e20c4292b2a1
2590c2bc-1186-4a5c-a17b-57290b7438cf	sent	750.00	0.00	0.00	750.00		This estimate is valid for 30 days.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00006.pdf	\N	2025-04-04 13:54:24.22+00	2025-04-15 15:48:48.599+00	2025-04-15 15:48:48.598+00	EST-00006	2025-04-04	2025-05-04	6b8a50c2-439a-4daa-a868-0431cbe28bd5	\N	cef8a5e0-ba91-45da-9cb8-e20c4292b2a1
7c5f3027-d400-4f6d-bfae-63aef41b1c56	sent	1.00	0.00	0.00	1.00		This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-15 04:47:11.653+00	2025-04-15 04:47:20.166+00	2025-04-15 04:47:20.166+00	EST-00019	2025-04-15	2025-05-15	c18892a9-8e8a-4592-a61d-10293cb131a3	\N	26ff807d-0535-49c3-8144-2aae123c02ed
71b0dda5-7309-47e9-a5da-377ef213ee72	sent	1.00	0.00	0.00	1.00		This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_1744652886630.pdf	\N	2025-04-14 17:33:14.235+00	2025-04-15 04:47:26.693+00	2025-04-15 04:47:26.693+00	EST-00018	2025-04-14	2025-05-14	6b8a50c2-439a-4daa-a868-0431cbe28bd5	\N	cef8a5e0-ba91-45da-9cb8-e20c4292b2a1
c350c05a-0177-40db-8575-0139bbc3b885	draft	0.00	0.00	0.00	0.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00014.pdf	\N	2025-04-12 05:54:28.507+00	2025-04-15 04:47:34.879+00	2025-04-15 04:47:34.879+00	EST-00014	2025-04-12	2025-05-12	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
58a73b9a-c81a-46d7-9e4e-fcbdd2aff66a	draft	3612.50	0.00	0.00	3612.50	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-08 22:45:20.36+00	2025-04-15 15:49:09.409+00	2025-04-15 15:49:09.409+00	EST-00008	2025-04-08	2025-05-08	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
1a2940f4-12e9-4a85-9cdd-004007175af7	sent	38.00	0.00	0.00	38.00		This estimate is valid for 30 days.	\N	\N	2025-04-02 02:22:32.707+00	2025-04-02 02:22:45.853+00	2025-04-02 02:22:45.853+00	EST-00002	2025-04-02	2025-05-02	\N	\N	\N
79be0134-6cae-4429-a8ff-1e3677024302	draft	0.00	0.00	0.00	0.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-12 06:03:40.952+00	2025-04-15 04:47:41.319+00	2025-04-15 04:47:41.319+00	EST-00015	2025-04-12	2025-05-12	\N	\N	26ff807d-0535-49c3-8144-2aae123c02ed
7d0660d5-619c-4efc-b92d-775c55327319	accepted	12082.00	0.00	0.00	12082.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/app/uploads/estimates/estimate_EST_1744679678709.pdf	\N	2025-04-12 06:05:13.552+00	2025-04-15 01:14:44.948+00	\N	EST-00016	2025-04-12	2025-05-12	\N	\N	26ff807d-0535-49c3-8144-2aae123c02ed
9c585096-b8e6-441d-8e02-ad473a2ef850	draft	11395.75	0.00	0.00	11395.75	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00017.pdf	\N	2025-04-12 13:13:05.717+00	2025-04-15 04:47:46.364+00	2025-04-15 04:47:46.363+00	EST-00017	2025-04-12	2025-05-12	\N	\N	26ff807d-0535-49c3-8144-2aae123c02ed
04c13dc0-ebe1-49b1-a94b-6657d959831c	draft	0.00	0.00	0.00	0.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00012.pdf	\N	2025-04-12 04:56:57.596+00	2025-04-15 04:47:38.316+00	2025-04-15 04:47:38.316+00	EST-00012	2025-04-12	2025-05-12	\N	\N	26ff807d-0535-49c3-8144-2aae123c02ed
9f30fc2f-d0eb-416e-91aa-72634242de11	accepted	3.00	0.00	0.00	3.00		This estimate is valid for 30 days.	\N	6f0ab57d-767b-4a11-b353-69954af930d5	2025-04-02 03:27:25.536+00	2025-04-15 15:48:20.938+00	2025-04-15 15:48:20.936+00	EST-00003	2025-04-02	2025-05-02	\N	\N	\N
cff3f2d6-2159-41aa-9808-cae326f2ca19	accepted	9.00	0.00	0.00	9.00		This estimate is valid for 30 days.	\N	bbdfa5e0-f33c-4751-9b4a-ed894cffba6c	2025-04-02 04:42:53.278+00	2025-04-15 15:48:24.839+00	2025-04-15 15:48:24.839+00	EST-00004	2025-04-02	2025-05-02	\N	\N	\N
be712350-404e-457d-b3f8-97f02f7c42c1	accepted	9.00	0.00	0.00	9.00		This estimate is valid for 30 days.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00001.pdf	908b8942-ed53-4bbe-abe9-1529f624cb0e	2025-04-01 19:44:35.94+00	2025-04-15 15:48:29.416+00	2025-04-15 15:48:29.416+00	EST-00001	2025-04-01	2025-05-01	\N	\N	\N
b788d32f-45f9-412a-9828-869035d4df71	draft	3222.50	0.00	0.00	3222.50	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00010.pdf	\N	2025-04-09 04:36:45.196+00	2025-04-15 15:49:13.764+00	2025-04-15 15:49:13.764+00	EST-00010	2025-04-09	2025-05-09	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
4c93d611-ce81-4c2f-88ef-823c43e2b233	draft	3664.50	0.00	0.00	3664.50	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-09 04:18:32.668+00	2025-04-15 15:49:17.306+00	2025-04-15 15:49:17.306+00	EST-00009	2025-04-09	2025-05-09	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
223a8805-3f61-488b-b448-1ae9879297d4	draft	0.00	0.00	0.00	0.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-12 05:50:12.312+00	2025-04-15 15:49:24.669+00	2025-04-15 15:49:24.669+00	EST-00013	2025-04-12	2025-05-12	\N	\N	26ff807d-0535-49c3-8144-2aae123c02ed
\.


--
-- Data for Name: invoice_items; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.invoice_items (id, invoice_id, description, quantity, price, tax_rate, item_total, sort_order, created_at, updated_at) FROM stdin;
eb1f204b-fdac-4f80-b998-5cf33745eddc	44b4dbc5-bed8-47cb-a6db-f70b83e1071c	test	1.00	1.00	0.00	1.00	0	2025-04-01 15:49:22.419+00	2025-04-01 15:49:22.425+00
5525e949-0112-4f0d-8ab1-56caf7ca21c0	67d98cec-f3cb-4067-b2c1-5de6a2ec96d9	test	1.00	1.00	0.00	1.00	0	2025-04-01 15:51:11.066+00	2025-04-01 15:51:11.07+00
0a090aa4-5db5-4118-bf95-03c93c00d913	6f7fa546-7310-408a-8925-74c3820aaa73	test	1.00	1.00	0.00	1.00	0	2025-04-01 15:55:18.024+00	2025-04-01 15:55:18.027+00
e3b9639e-6a18-4024-bcbf-972b857c7bcc	f46f2f5d-d0ce-49b5-acb8-8282aee46884	test	1.00	1.00	0.00	1.00	0	2025-04-01 16:22:20.496+00	2025-04-01 16:22:20.498+00
b694133d-44fe-4d7b-8d73-e0b5d042bd2d	fdd35304-6477-43c0-904d-d751e05f875d	test	1.00	1.00	0.00	1.00	0	2025-04-01 16:45:14.797+00	2025-04-01 16:45:14.801+00
c9c17647-02ff-487b-b15a-c2397da3b36c	908b8942-ed53-4bbe-abe9-1529f624cb0e	test	1.00	1.00	0.00	1.00	0	2025-04-02 01:31:22.659+00	2025-04-02 01:31:22.665+00
cd72ad5e-e4d5-43cc-adb4-c846a0553cab	908b8942-ed53-4bbe-abe9-1529f624cb0e	test2	1.00	3.00	0.00	3.00	1	2025-04-02 01:31:22.66+00	2025-04-02 01:31:22.667+00
25277a1c-b3c3-426b-854d-358995f71336	908b8942-ed53-4bbe-abe9-1529f624cb0e	test3	1.00	5.00	0.00	5.00	2	2025-04-02 01:31:22.662+00	2025-04-02 01:31:22.668+00
efff8a89-2162-4180-b8a1-6137cb8614b0	064d98ee-2877-4a7e-a57e-70f7f121e765	test	1.00	3.00	0.00	3.00	0	2025-04-02 03:23:11.57+00	2025-04-02 03:23:11.572+00
00523c6a-f6c5-443a-845d-1fd63c0dcf49	6f0ab57d-767b-4a11-b353-69954af930d5	test	1.00	3.00	0.00	3.00	0	2025-04-02 03:30:25.001+00	2025-04-02 03:30:25.004+00
ccf60513-327f-421f-9ce1-9d3a169c8f72	bbdfa5e0-f33c-4751-9b4a-ed894cffba6c	test	3.00	3.00	0.00	9.00	0	2025-04-02 04:42:59.36+00	2025-04-02 04:42:59.361+00
cb0d1b9f-e86f-4f64-8015-bb6712e3c827	270c0ea0-56a0-44f6-acd3-85d5606ba459	test	1.00	30.00	0.00	30.00	0	2025-04-02 05:31:53.486+00	2025-04-02 05:31:53.491+00
612f4692-0f27-4bb8-b279-1bafe248b580	0009cdd0-dabf-4703-bf8e-d6087eccbef8	Remove tiles and replace underlayment. Reset tiles and fasten.	1.00	1200.00	0.00	1200.00	0	2025-04-14 17:15:46.757+00	2025-04-14 17:15:46.76+00
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.invoices (id, invoice_number, status, subtotal, total, notes, terms, address_id, created_at, updated_at, deleted_at, date_created, date_due, tax_total, discount_amount, pdf_path, client_id) FROM stdin;
0009cdd0-dabf-4703-bf8e-d6087eccbef8	INV-00011	paid	1200.00	1200.00		Payment is due within 30 days from the date of invoice.	6b8a50c2-439a-4daa-a868-0431cbe28bd5	2025-04-14 17:15:46.747+00	2025-04-15 00:35:23.71+00	\N	2025-04-14	2025-05-14	0.00	0.00	/app/uploads/invoices/invoice_INV_00011.pdf	cef8a5e0-ba91-45da-9cb8-e20c4292b2a1
f46f2f5d-d0ce-49b5-acb8-8282aee46884	INV-00004	paid	1.00	1.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:07:03.000004+00	2025-04-02 05:07:03.001523+00	\N	2025-04-02	2025-05-02	0.00	0.00	\N	\N
fdd35304-6477-43c0-904d-d751e05f875d	INV-00005	paid	1.00	1.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:07:03.000004+00	2025-04-02 05:07:03.001523+00	\N	2025-04-02	2025-05-02	0.00	0.00	\N	\N
6f7fa546-7310-408a-8925-74c3820aaa73	INV-00003	paid	1.00	1.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:07:03.000004+00	2025-04-02 05:07:03.001523+00	\N	2025-04-02	2025-05-02	0.00	0.00	\N	\N
67d98cec-f3cb-4067-b2c1-5de6a2ec96d9	INV-00002	paid	1.00	1.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:07:03.000004+00	2025-04-02 05:07:03.001523+00	\N	2025-04-02	2025-05-02	0.00	0.00	\N	\N
44b4dbc5-bed8-47cb-a6db-f70b83e1071c	INV-00001	paid	1.00	1.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:07:03.000004+00	2025-04-02 05:07:03.001523+00	\N	2025-04-02	2025-05-02	0.00	0.00	\N	\N
6f0ab57d-767b-4a11-b353-69954af930d5	INV-00008	draft	3.00	3.00		This estimate is valid for 30 days.	\N	2025-04-02 05:07:03.000004+00	2025-04-02 05:07:03.001523+00	\N	2025-04-02	2025-05-02	0.00	0.00	\N	\N
064d98ee-2877-4a7e-a57e-70f7f121e765	INV-00007	paid	3.00	3.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:07:03.000004+00	2025-04-02 05:07:03.001523+00	\N	2025-04-02	2025-05-02	0.00	0.00	\N	\N
270c0ea0-56a0-44f6-acd3-85d5606ba459	INV-00010	paid	30.00	30.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:31:53.481+00	2025-04-02 05:31:56.322+00	\N	2025-04-02	2025-05-02	0.00	0.00	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/invoices/invoice_INV_00010.pdf	\N
908b8942-ed53-4bbe-abe9-1529f624cb0e	INV-00006	sent	9.00	9.00		This estimate is valid for 30 days.	\N	2025-04-02 05:07:03.000004+00	2025-04-10 14:01:26.75+00	\N	2025-04-02	2025-05-02	0.00	0.00	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/invoices/invoice_INV_00006.pdf	\N
bbdfa5e0-f33c-4751-9b4a-ed894cffba6c	INV-00009	sent	9.00	9.00		This estimate is valid for 30 days.	\N	2025-04-02 05:07:03.000004+00	2025-04-13 19:14:42.018+00	\N	2025-04-02	2025-05-02	0.00	0.00	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/invoices/invoice_INV_00009.pdf	\N
\.


--
-- Data for Name: llm_prompts; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.llm_prompts (id, name, description, prompt_text, created_at, updated_at) FROM stdin;
1	initialAnalysis	Initial prompt for analyzing project description	Role: You are an expert estimator analyzing construction project requirements.\nTask: Analyze the given project description and identify required measurements and details.\nFormat: Return a JSON object with:\n- required_measurements: array of needed measurements\n- suggested_products: array of product types needed\n- clarifying_questions: array of specific questions if more detail needed\n\nExample Input: "2000 sq ft roof replacement with tear off"\nExample Output: {\n  "required_measurements": ["roof_square_footage", "roof_pitch", "number_of_layers"],\n  "required_services": ["roof_tear_off", "roof_installation", "cleanup"],\n  "clarifying_questions": ["What is the current roof condition?", "Are there any known leak areas?"]\n}	2025-04-08 04:17:54.736+00	2025-04-08 04:17:54.736+00
2	initialAnalysisWithAssessment	Prompt for analyzing project with assessment data	Role: You are an expert estimator analyzing construction project requirements with assessment data.\nTask: Analyze the given project description along with the assessment data provided and identify required measurements and details.\nFormat: Return a JSON object with:\n- required_measurements: array of needed measurements (only those not already in assessment data)\n- suggested_products: array of product types needed\n- clarifying_questions: array of specific questions if more detail needed (fewer needed with assessment data)\n\nExample Input: Project description + Assessment data\nExample Output: {\n  "required_measurements": ["additional_measurements_needed"],\n  "required_services": ["services_based_on_assessment_and_description"],\n  "clarifying_questions": ["specific_questions_not_addressed_in_assessment"]\n}	2025-04-08 04:17:54.736+00	2025-04-08 04:17:54.736+00
3	serviceMatch	Service matching for finding catalog items	Role: You are a service specialist matching project needs to available services.\nContext: You have access to the following data:\n- Project requirements\n- Available service catalog\n- Measurements and specifications\n\nTask: Match project needs to existing services or suggest new services.\nFormat: Return a JSON object with:\n- matched_services: array of existing service IDs\n- new_service_suggestions: array of suggested new services\n- estimated_hours: calculated labor hours for each service\n\nBase your estimates on industry standards and best practices.	2025-04-08 04:17:54.736+00	2025-04-08 04:17:54.736+00
5	newService	Create new services not in catalog	Role: You are a service catalog manager creating new service entries.\nTask: Generate complete service specifications for new offerings.\nRequired Fields:\n- name: Clear, standardized service name\n- description: Detailed service description\n- unit: Appropriate unit of measurement (typically hours or fixed fee)\n- type: Service classification\n- base_rate: Standard hourly or fixed fee rate\n\nFormat: Return a JSON object matching the service catalog schema.	2025-04-08 04:17:54.736+00	2025-04-08 04:17:54.736+00
4	laborHoursCalculation	Calculate labor hours for services.	Role: You are an estimation expert calculating required labor hours.\nTask: Calculate precise labor hours needed for each service based on measurements.\nRules:\n- Include standard labor rates\n- Account for job complexity factors\n- Consider crew size requirements\n- Factor in site conditions and access\n\nFormat: Return a JSON object with detailed calculations and explanations.	2025-04-08 04:17:54.736+00	2025-04-08 04:29:14.562+00
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.payments (id, invoice_id, amount, payment_date, payment_method, notes, reference_number, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: pre_assessment_photos; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.pre_assessment_photos (id, pre_assessment_id, file_path, original_name, description, area_label, annotations, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: pre_assessment_project_types; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.pre_assessment_project_types (id, pre_assessment_id, project_type, created_at, updated_at, project_subtype) FROM stdin;
\.


--
-- Data for Name: pre_assessments; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.pre_assessments (id, client_id, project_type, project_subtype, problem_description, timeline_requirements, budget_parameters, access_information, decision_maker_info, questionnaire_data, llm_generated_checklist, created_at, updated_at, client_address_id) FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.products (id, name, description, price, tax_rate, is_active, created_at, updated_at, type, unit, deleted_at) FROM stdin;
158aa720-2af4-4581-b0aa-af8135d4399c	Trim is linear feet 60ft		2.00	0.00	t	2025-04-09 04:23:43.112+00	2025-04-09 04:23:43.112+00	service	ln ft	\N
286f7ab6-948a-4e4a-8f97-07d918912ba7	Replace subfloor	Remove and replace subfloor. Additional bracing for security and stability.	5.00	6.00	t	2025-04-08 06:38:22.902+00	2025-04-08 06:40:14.38+00	product	sq ft	\N
6cdb1d5c-b001-4063-955e-09bbe02733b4	Vinyl Plank Flooring Installation	Installation of luxury vinyl plank flooring (floating click-lock planks) including underlayment and trimming (finished per square foot).	5.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
20c411bc-489a-468f-995b-c1a34b34b021	Sheet Vinyl Flooring Installation	Installation of sheet vinyl flooring, cut to fit and glued down, including adhesive (per square foot).	3.50	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
e64c9e68-be27-45c5-9878-04c7c8e2ca57	Laminate Flooring Installation	Installation of laminate wood flooring with underlayment and transitions, cut to fit (per square foot).	4.50	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
e8861f91-1c6b-4605-bc68-e91b0bfacfb6	Tile Flooring Installation	Installation of ceramic or porcelain floor tile, including mortar and grout application (per square foot).	7.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
b379628c-85a5-45d6-bda5-189e4196f46a	Subfloor Replacement/Repair	Removing damaged subfloor and installing new plywood/OSB subfloor panels, secured to floor joists (per square foot).	5.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
b8c7d0cb-8132-4db0-875b-ee14767c3ee8	Asphalt Shingle Roof Replacement	Tear-off of old roof and installation of new asphalt shingles with underlayment and flashing (per square foot of roof area).	6.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
7d15dd6a-3509-4589-ab26-f2cb96af0623	Roof Leak Repair (Minor Patch)	Minor roof leak patch – replace or seal around a small area of damaged shingles or flashing (cost per patch job).	300.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N
73cd8404-d9ad-475b-89c7-2437178be8dd	Roof Decking Replacement	Replacing rotted roof sheathing with new 4x8 ft plywood/OSB panels, nailed and sealed (per sheet).	90.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N
090b9c44-bd03-46bb-b8c3-19203da858ae	Window Replacement	Remove existing window and install new vinyl replacement window (e.g. 36\\x48\\ double-hung), including insulation and caulking (per window).	800.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N
c8d4be40-0f8e-4759-92a1-04ebd77b0e43	Interior Door Installation	Install a new interior door (pre-hung or slab) including fitting, hardware, and hinges (per door).	450.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N
994ef2cf-62e9-4678-88bb-63946d165568	Exterior Door Installation	Install a new exterior entry door (pre-hung unit) including threshold, weatherstripping, and lockset fitting (per door).	700.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N
946e35ec-1d20-4f2f-b25a-d788b34bf99a	Storm Door Installation	Install a storm/screen door over an existing exterior door frame, including hinge and closer installation (per door).	400.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N
1b4c3394-a36f-4b46-9df3-7127b595695a	Vinyl Siding Repair	Replace damaged vinyl siding panels on exterior walls, matching existing profile and securing properly (per square foot).	3.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
88e17346-15f9-4aa8-a462-a5175e266165	Stucco Patch Repair	Patch and texture small damaged stucco areas on exterior walls, blending with existing finish (per square foot).	20.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
6df80fe7-b4ac-4499-8504-9ea14fe7b45e	Exterior Trim Replacement	Replace rotted/damaged exterior wood trim or fascia (e.g. 1x6 fascia board), primed and ready for paint (per linear foot).	6.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	ln ft	\N
2b01f403-e055-49f5-a76d-16632418003a	General Caulking and Sealing	Re-caulk gaps and seams (around windows, doors, siding joints, tubs, etc.) to seal against water/air intrusion (per linear foot).	1.20	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	ln ft	\N
c3c4100c-7a64-4e97-957e-f30fc98be1d1	Exterior Painting	Repainting of exterior walls (stucco or siding) including surface prep, minor patching, and two coats of paint (per square foot of wall area).	4.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
a18c451f-8981-400f-8237-8eb9670eb770	Drywall Installation/Repair	Install new drywall or patch damaged drywall, including taping, mudding, and sanding ready for paint (per square foot).	4.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
5c12cfb7-fccf-4cc1-857e-97543fdb7b16	Baseboard Installation	Install or replace interior baseboard molding, including cutting to size, nailing, and caulking joints (per linear foot).	6.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	ln ft	\N
bf360b24-6c6b-4bc0-8c4c-c509177ff680	Crown Molding Installation	Install new interior crown molding at ceiling, including mitering or coping corners and caulking for a finished look (per linear foot).	8.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	ln ft	\N
94106546-f1d9-4194-9fd5-e05203a6b501	Interior Painting	Repaint interior walls and ceilings with minor prep (patching nail holes, etc.) and two finish coats of paint (per square foot of floor area).	3.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
6b16e8c6-a8c7-40b0-9cae-3086cc6e5251	Attic Insulation (Blown-In)	Install blown-in insulation (fiberglass or cellulose) in attic to recommended R-value, improving energy efficiency (per square foot of attic area).	1.80	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
64f39ece-610b-44d2-b948-f2250cf9f27b	Mobile Home Re-Leveling	Re-level a mobile or manufactured home by adjusting pier supports and shimming as needed to eliminate sagging (per home).	650.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N
fc3fd27c-ce56-41cf-8f4d-ecd30ca06b15	Mobile Home Anchor/Tie-Down Installation	Install or replace steel tie-down anchors and straps to secure mobile home to ground per Florida code (per anchor installed).	70.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N
2d81a67e-718c-461c-a45a-c15890c5d3ac	Mobile Home Skirting Installation	Install new vinyl skirting around mobile home base (including panels, vents, and access door), ventilated and secured (per linear foot).	7.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	ln ft	\N
ebc65e5b-02b2-411d-93c1-81dccea480cc	Mobile Home Pier Installation	Install additional or replacement support piers (e.g. concrete blocks with cap and shims) under a mobile home for stability (per pier).	100.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N
e8fd62e3-d15b-462d-81f2-f3802896bef9	Mobile Home Roof Coating	Clean and coat a mobile home metal roof with elastomeric or aluminum roof coating to seal leaks and reflect heat (per square foot).	2.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
09a32483-d170-44fc-ba81-84f4949cec82	Pressure Washing	Pressure wash exterior surfaces (driveway, siding, deck, etc.) to remove dirt, mold, and mildew; includes equipment and cleaners (per square foot).	0.20	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N
797e7ace-d5a1-408d-a89f-e2a23d2fa571	Water damage remediation		75.00	0.00	t	2025-04-10 01:00:29.547+00	2025-04-10 01:00:29.547+00	service	hours	\N
\.


--
-- Data for Name: project_inspections; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.project_inspections (id, project_id, category, content, created_at) FROM stdin;
f4784061-bfa2-49ad-beb8-6b5ef356833e	38edf41a-6968-48ed-af13-fed5c8d3060f	condition	{"notes": "", "assessment": "Sinking floor due to water leak in kitchen mobile home.", "projectTypes": ""}	2025-04-12 04:30:34.949+00
967cf129-6378-4d8c-814a-dc081d1969a9	38edf41a-6968-48ed-af13-fed5c8d3060f	measurements	{"items": [{"dimensions": {"units": "feet", "width": "16", "length": "10"}, "description": "Remove flooring and subfloor. Disposal", "_productInfo": {"id": "e8fd62e3-d15b-462d-81f2-f3802896bef9", "name": "Mobile Home Roof Coating", "unit": "sq ft", "price": "2.00"}, "projectTypes": "", "linkedProduct": "e8fd62e3-d15b-462d-81f2-f3802896bef9", "measurementType": "area"}, {"quantity": "9", "description": "Cabinet removal and disposal", "_productInfo": null, "projectTypes": "", "quantityUnit": "each", "linkedProduct": null, "measurementType": "quantity"}, {"dimensions": {"units": "feet", "width": "16", "length": "10"}, "description": "Subfloor Replacement/Repair", "_productInfo": {"id": "b379628c-85a5-45d6-bda5-189e4196f46a", "name": "Subfloor Replacement/Repair", "unit": "sq ft", "price": "5.00"}, "projectTypes": "", "linkedProduct": "b379628c-85a5-45d6-bda5-189e4196f46a", "measurementType": "area"}, {"dimensions": {"units": "feet", "width": "15", "length": "15"}, "description": "Additional bracing", "_productInfo": null, "projectTypes": "", "linkedProduct": null, "measurementType": "area"}, {"dimensions": {"units": "feet", "width": "16", "length": "10"}, "description": "Laminate Flooring Installation", "_productInfo": {"id": "e64c9e68-be27-45c5-9878-04c7c8e2ca57", "name": "Laminate Flooring Installation", "unit": "sq ft", "price": "4.50"}, "projectTypes": "", "linkedProduct": "e64c9e68-be27-45c5-9878-04c7c8e2ca57", "measurementType": "area"}, {"dimensions": {"units": "feet", "width": "1", "length": "2"}, "description": "Trim is linear feet 60ft", "_productInfo": null, "projectTypes": "", "linkedProduct": null, "measurementType": "area"}, {"quantity": "7", "description": "Install cabinets", "_productInfo": null, "projectTypes": "", "quantityUnit": "each", "linkedProduct": null, "measurementType": "quantity"}, {"dimensions": {"units": "feet", "width": "4", "length": "15"}, "description": "Underpinning and insulation", "_productInfo": null, "projectTypes": "", "linkedProduct": null, "measurementType": "area"}], "notes": ""}	2025-04-12 04:30:34.986+00
ef305402-81ca-4bdd-9cb3-9e71a28ff0ba	38edf41a-6968-48ed-af13-fed5c8d3060f	materials	{"items": [{"name": "", "quantity": "", "sourceType": "assessment", "projectTypes": ""}], "notes": "", "projectTypes": ""}	2025-04-12 04:30:35.017+00
\.


--
-- Data for Name: project_photos; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.project_photos (id, project_id, inspection_id, photo_type, file_path, notes, created_at) FROM stdin;
\.


--
-- Data for Name: project_subtypes; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.project_subtypes (id, project_type_id, name, value, description, active, created_at, updated_at) FROM stdin;
6243f849-0a5b-4a93-8690-1c7cc9b3fc97	46964786-d925-4bc7-a66a-50f2d3005109	Remove toilet	remove_toilet	Removing toilet requires replacing wax ring. Will have to examine flange and bolts to see if the need to be replaced. Caulking around toilet also necessary.	t	2025-04-12 01:41:02.03+00	2025-04-12 01:41:02.03+00
\.


--
-- Data for Name: project_type_questionnaires; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.project_type_questionnaires (id, project_type, project_subtype, questionnaire_schema, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: project_types; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.project_types (id, name, value, description, active, created_at, updated_at) FROM stdin;
46964786-d925-4bc7-a66a-50f2d3005109	Bathroom Remodel	bathroom_remodel	Bathroom renovation or remodeling projects	t	2025-04-11 21:15:00.973+00	2025-04-11 21:15:00.973+00
f93cae59-aebf-4191-8b21-f1892246ce2a	Kitchen Remodel	kitchen_remodel	Kitchen renovation or remodeling projects	t	2025-04-11 21:15:00.973+00	2025-04-11 21:15:00.973+00
62634851-0d57-45ae-be4b-5225c38618ae	Roof Repair	roof_repair	Roof repair and replacement projects	t	2025-04-11 21:15:00.973+00	2025-04-11 21:15:00.973+00
b0face71-cd0c-4232-b0f9-82b421862228	Flooring	flooring	Flooring installation and replacement projects	t	2025-04-11 21:15:00.973+00	2025-04-11 21:15:00.973+00
812cc5ca-f7fb-4c0e-a0c6-2c3f86171e69	Deck Construction	deck_construction	Deck building and renovation projects	t	2025-04-11 21:15:00.973+00	2025-04-11 21:15:00.973+00
631f8d40-a8c8-4035-bd0a-a1c7509035d0	Leveling	leveling	Leveling mobile home	t	2025-04-12 00:44:22.71+00	2025-04-12 00:44:22.71+00
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.projects (id, client_id, estimate_id, type, status, scheduled_date, scope, created_at, updated_at, additional_work, address_id, assessment_id, converted_to_job_id, pre_assessment_id) FROM stdin;
0d240d0f-fe51-4e42-8cf3-654f75d52b97	a04af1e2-7946-4387-ad73-7456c91af533	3913a2b7-dac8-447a-9e20-76fe2bf340b3	active	in_progress	2025-04-15	Customer had a leak underneath mobile home and has various issues that need to be fixed. Subfloor, needs new cabinets, flooring, underpinning and insulation 	2025-04-15 18:03:07.315+00	2025-04-15 18:03:07.315+00	\N	3cd9e874-8bbd-40ed-ab8e-a846fd4b31ae	38edf41a-6968-48ed-af13-fed5c8d3060f	\N	\N
38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533	3913a2b7-dac8-447a-9e20-76fe2bf340b3	assessment	completed	2025-04-08	Customer had a leak underneath mobile home and has various issues that need to be fixed. Subfloor, needs new cabinets, flooring, underpinning and insulation 	2025-04-08 20:15:08.386+00	2025-04-15 18:03:07.318+00	\N	3cd9e874-8bbd-40ed-ab8e-a846fd4b31ae	\N	0d240d0f-fe51-4e42-8cf3-654f75d52b97	\N
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.settings (id, key, value, description, "group", created_at, updated_at) FROM stdin;
12	pdf_font_family	Helvetica	Font family for PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-04-02 05:13:15.375417+00
6	pdf_invoice_footer	Thank you for your business!	Footer text for invoice PDFs	invoice	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.687+00
53	estimate_prefix	EST-	\N	estimate	2025-04-08 13:01:02.798+00	2025-04-08 13:01:14.713+00
54	estimate_valid_days	30	\N	estimate	2025-04-08 13:01:02.798+00	2025-04-08 13:01:14.713+00
55	default_estimate_terms	This estimate is valid for {valid_days} days from the date issued. To accept this estimate, please sign and return.	\N	estimate	2025-04-08 13:01:02.798+00	2025-04-08 13:01:14.713+00
56	pdf_estimate_footer	Thank you for considering our services. Please contact us with any questions regarding this estimate.	\N	estimate	2025-04-08 13:01:02.798+00	2025-04-08 13:01:14.713+00
5	company_name	Your Company	Company name for invoices and estimates	company	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.627+00
49	company_address		\N	company	2025-04-08 13:01:02.707+00	2025-04-08 13:01:14.627+00
50	company_phone		\N	company	2025-04-08 13:01:02.707+00	2025-04-08 13:01:14.627+00
51	company_email		\N	company	2025-04-08 13:01:02.707+00	2025-04-08 13:01:14.627+00
52	company_website		\N	company	2025-04-08 13:01:02.707+00	2025-04-08 13:01:14.627+00
10	company_logo_path	logo-1743544536073-495906630.png	\N	company	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.627+00
4	primary_color	#498bf5	Primary color for PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.657+00
13	pdf_secondary_color	#aac5eb	Secondary color for PDF accents	appearance	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.657+00
11	pdf_background_color	#f8f9fa	Background color for table headers in PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.657+00
14	pdf_table_border_color	#e2e8f0	Border color for tables in PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.657+00
15	pdf_page_margin	50	Page margin in points for PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.657+00
16	pdf_header_margin	30	Top margin for header in PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.657+00
17	pdf_footer_margin	30	Bottom margin for footer in PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.657+00
18	pdf_watermark_text		Watermark text for PDF documents (leave empty for no watermark)	appearance	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.657+00
1	invoice_prefix	INV-	Prefix for invoice numbers	invoice	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.687+00
2	invoice_due_days	30	Default number of days until invoice is due	invoice	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.687+00
3	default_invoice_terms	Payment is due within 30 days from the date of invoice.	Default terms for invoices	invoice	2025-04-02 05:13:15.373491+00	2025-04-08 13:01:14.687+00
207	default_tax_rate	0	Default tax rate percentage	invoicing	2025-04-15 01:20:28.619+00	2025-04-15 01:20:28.619+00
208	default_invoice_notes	Thank you for your business!	Default notes for new invoices	invoicing	2025-04-15 01:20:28.661+00	2025-04-15 01:20:28.661+00
\.


--
-- Data for Name: source_maps; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.source_maps (id, estimate_item_id, source_type, source_data, created_at, updated_at) FROM stdin;
345121cd-8009-4d04-a9d8-85d580122765	7af9f4f3-6662-4235-9f09-05f6575636c4	measurement	{"id": "measurement-1", "unit": "sq ft", "label": "Measurement", "value": 160}	2025-04-08 22:45:20.377+00	2025-04-08 22:45:20.377+00
8212a35e-f6c0-4d01-b5f6-d3106c0189b9	dbe7920f-ea97-4f7c-880b-f5527d052c8c	measurement	{"id": "measurement-2", "unit": "sq ft", "label": "Measurement", "value": 25}	2025-04-08 22:45:20.382+00	2025-04-08 22:45:20.382+00
46d32cec-d85d-4ca0-88a9-e1363a513ab4	74e4b47c-8273-4a08-82c4-4ea9ff1cdf37	measurement	{"id": "measurement-3", "unit": "sq ft", "label": "Measurement", "value": 160}	2025-04-08 22:45:20.385+00	2025-04-08 22:45:20.385+00
2a60286d-b008-4153-8d5b-f986e88c0fe1	608428d5-30cf-4ed2-ab95-72a1a61d8312	measurement	{"id": "measurement-4", "unit": "sq ft", "label": "Measurement", "value": 225}	2025-04-08 22:45:20.388+00	2025-04-08 22:45:20.388+00
fff68e65-f132-4adc-8407-20a403728a3d	a272ab68-41e4-4964-897e-5b011c0f4360	measurement	{"id": "measurement-5", "unit": "sq ft", "label": "Measurement", "value": 160}	2025-04-08 22:45:20.391+00	2025-04-08 22:45:20.392+00
9a01bd53-e960-4469-a45f-7abbd15daa40	7bc90588-91a0-4a71-ba83-d9e2337d02c1	measurement	{"id": "measurement-6", "unit": "ln ft", "label": "Measurement", "value": 60}	2025-04-08 22:45:20.394+00	2025-04-08 22:45:20.394+00
7b42cce3-d4e4-4b3d-9c5c-f55d01405e65	3832ecad-d27b-4e32-a9f9-840495bf59fa	measurement	{"id": "measurement-7", "unit": "each", "label": "Measurement", "value": 7}	2025-04-08 22:45:20.396+00	2025-04-08 22:45:20.396+00
7ca40d96-1b61-4242-a65a-0897f141a7fa	a4e35c28-5055-45a7-b2bc-3cfa879bf1ac	measurement	{"id": "measurement-1", "unit": "sq ft", "label": "Measurement", "value": 160}	2025-04-09 04:18:32.677+00	2025-04-09 04:18:32.677+00
1ac3802e-6fc8-4951-ac5e-44694a7fea2e	d20ca4d6-a673-4d27-8030-9dc6b6fd53be	measurement	{"id": "measurement-2", "unit": "sq ft", "label": "Measurement", "value": 25}	2025-04-09 04:18:32.68+00	2025-04-09 04:18:32.68+00
167df268-1a78-4e6b-80e4-7cdafecfd325	486c101e-5262-4f4d-a7e7-1dc3b53aab66	measurement	{"id": "measurement-3", "unit": "sq ft", "label": "Measurement", "value": 176}	2025-04-09 04:18:32.682+00	2025-04-09 04:18:32.682+00
dfbfd1eb-46a3-4cb7-8103-d007e4e26d54	c0b62f15-796e-44e4-b1b8-44b6fa8b9cb0	measurement	{"id": "measurement-4", "unit": "sq ft", "label": "Measurement", "value": 225}	2025-04-09 04:18:32.684+00	2025-04-09 04:18:32.684+00
d9834804-1810-4e97-8c8b-4ec4729a4cf9	b17921a8-4bf0-4280-b67b-5a1f700ff122	measurement	{"id": "measurement-5", "unit": "sq ft", "label": "Measurement", "value": 176}	2025-04-09 04:18:32.686+00	2025-04-09 04:18:32.687+00
0fce7e9b-31ca-45a2-a2f2-3cf998a43186	08aa19d4-d588-432b-9aa3-5449ca50233e	measurement	{"id": "measurement-6", "unit": "ln ft", "label": "Measurement", "value": 66}	2025-04-09 04:18:32.69+00	2025-04-09 04:18:32.69+00
45d9707b-16a4-41bc-9e22-1c0d2cc7896e	85859162-9f64-4eed-be13-d1aa26e5f1e3	measurement	{"id": "measurement-7", "unit": "each", "label": "Measurement", "value": 7}	2025-04-09 04:18:32.693+00	2025-04-09 04:18:32.693+00
f1066f2f-2fdf-4947-98d0-010669edd175	a19d1fde-f663-4642-b722-6a2f4bfd8c9b	measurement	{"id": "Remove Flooring and Subfloor. Disposal", "unit": "sq ft", "label": "Measurement", "value": 160}	2025-04-09 04:36:45.204+00	2025-04-09 04:36:45.204+00
989577a7-e9b3-4d24-84bf-0bcda78aa043	0ebc1aca-1e0e-41c1-ba35-c66613e7742d	measurement	{"id": "Subfloor Replacement/Repair", "unit": "sq ft", "label": "Measurement", "value": 160}	2025-04-09 04:36:45.206+00	2025-04-09 04:36:45.206+00
6f6ac09e-3f99-4802-9663-6b6c688767f6	25d22753-9a18-4161-8b75-3334503b25fc	measurement	{"id": "Additional Bracing", "unit": "sq ft", "label": "Measurement", "value": 225}	2025-04-09 04:36:45.208+00	2025-04-09 04:36:45.208+00
8eb8514f-4b59-405c-88fd-9bc169b39a9e	63cbc0a7-7cb0-42fb-bb76-55de9023201d	measurement	{"id": "Laminate Flooring Installation", "unit": "sq ft", "label": "Measurement", "value": 160}	2025-04-09 04:36:45.21+00	2025-04-09 04:36:45.21+00
8be44db5-e77b-4989-a45b-7e7124d63ec3	8864c82f-9fa5-4e45-bb95-64450bfb4dae	measurement	{"id": "Remove Island Cabinet and Dispose", "unit": "sq ft", "label": "Measurement", "value": 25}	2025-04-09 04:36:45.212+00	2025-04-09 04:36:45.212+00
436d47c6-b4af-4e53-807b-b079756aaa83	e38ba6ab-58ee-4289-91b7-ea357d308441	measurement	{"id": "Trim Is Linear Feet 60ft", "unit": "ln ft", "label": "Measurement", "value": 60}	2025-04-09 04:36:45.214+00	2025-04-09 04:36:45.214+00
0181c4cf-be85-4256-b073-05ddc1bba24f	cc18e2b8-a142-4421-8d74-c50986ff13b1	measurement	{"id": "Install Cabinets 7", "unit": "each", "label": "Measurement", "value": 7}	2025-04-09 04:36:45.216+00	2025-04-09 04:36:45.216+00
f19ac333-89c5-4253-b694-c9f7ab2dca86	4d1ebc84-ad97-41de-84a1-efa44dcd1744	measurement	{"id": "measurement-1", "unit": "sq ft", "label": "Measurement", "value": 260}	2025-04-12 13:13:05.724+00	2025-04-12 13:13:05.724+00
9a67fb7f-23e9-4cd9-88fb-cc08588b2050	e977f009-bdac-4686-93ed-608ab9251e56	measurement	{"id": "measurement-2", "unit": "sq ft", "label": "Measurement", "value": 1849}	2025-04-12 13:13:05.727+00	2025-04-12 13:13:05.727+00
750b784a-ccc8-4d3d-b6f6-4305c4e76691	5735411f-98a5-404d-b157-3e636407c048	measurement	{"id": "measurement-3", "unit": "sq ft", "label": "Measurement", "value": 660}	2025-04-12 13:13:05.729+00	2025-04-12 13:13:05.729+00
9da872f3-9bd6-41b7-922f-b21e2676f148	44c6301d-d4bf-4df4-b06d-bb08129c6ccc	measurement	{"id": "measurement-4", "unit": "sq ft", "label": "Measurement", "value": 81}	2025-04-12 13:13:05.731+00	2025-04-12 13:13:05.731+00
445748f1-b1d0-407e-8628-8c870daaa88e	e89172bd-0807-43b1-a734-30021c44376f	measurement	{"id": "measurement-5", "unit": "sq ft", "label": "Measurement", "value": 500}	2025-04-12 13:13:05.733+00	2025-04-12 13:13:05.733+00
26348e4b-4978-46f9-b97d-e1f16fd43eb6	24902548-0726-449b-a709-c739cd430e23	measurement	{"id": "measurement-6", "unit": "sq ft", "label": "Measurement", "value": 352}	2025-04-12 13:13:05.734+00	2025-04-12 13:13:05.734+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.users (id, username, email, password, role, theme_preference, first_name, last_name, is_active, created_at, updated_at, deleted_at, avatar) FROM stdin;
a9aaa74a-d8f4-4fe8-ba36-ee979a1e1e4e	Admin	joe@806040.xyz	$2b$10$KJqWx1y8kE0ER1d5ikvAXOc1gE5T7FI/Y5O9cONNGGBTeqFOPechm	admin	dark	\N	\N	t	2025-04-02 05:03:37.938514+00	2025-04-02 05:03:37.940615+00	\N	\N
e3e22c7c-8896-4302-8821-06456ffe06aa	admin	admin@example.com	$2b$10$1m4eKsR1rkqN3JJ1MZjWI.uuag6PtcQ4b2hRINrPHFjRpfvsrNFyy	user	dark	\N	\N	t	2025-04-02 05:03:37.938514+00	2025-04-02 05:03:37.940615+00	2025-04-08 06:23:41.677+00	\N
634a36de-3101-4c87-b3e3-76883f3dae72	Johnny	john@google.com	$2b$10$3EaDJ1n0Mu787Q3HX4kUvuo0wdIiC8eFHqzTVzbXI9iCb1VZ60Zxm	user	dark	\N	\N	t	2025-04-02 05:03:37.938514+00	2025-04-02 05:03:37.940615+00	2025-04-08 06:23:47.32+00	\N
aafa47ef-6944-4f1e-a035-23a2e2874f84	newtestuser	newtestuser@example.com	$2b$10$jTmQRvRnKqbBAVN9FlCxuu790jcM7uuB1C1116Sjulrwtu5o0uWuC	user	dark	\N	\N	t	2025-04-02 05:03:37.938514+00	2025-04-02 05:03:37.940615+00	2025-04-08 06:23:49.61+00	\N
f2ef2619-0d23-40f5-8519-1f02ef0bf1da	secondtestuser	secondtestuser@example.com	$2b$10$U3l/bzq6v2eHY95njX5fGemNwKfrNNHdVO7m45/6/evQgmXNyygqi	user	dark	\N	\N	t	2025-04-02 05:03:37.938514+00	2025-04-02 05:03:37.940615+00	2025-04-08 06:23:51.95+00	\N
333ae241-94ff-4abf-80ac-5e0d93996af8	test	test@test.com	$2b$10$Q0vqnPPAyEdLYMRHooB58.S4Z/ABVxofWFzxqxSxvwecDnpau6gQi	user	dark	\N	\N	t	2025-04-02 05:03:37.938514+00	2025-04-02 05:03:37.940615+00	2025-04-08 06:23:54.254+00	\N
1ae5d0b0-94aa-493a-8519-c02290108054	testdebug	testdebug@example.com	$2b$10$B1.8RktOfgNTHiqWCyHBl.3X3UOaRX0Vi0MtjixxAbvL/RMSkLcGe	user	dark	\N	\N	t	2025-04-02 05:03:37.938514+00	2025-04-02 05:03:37.940615+00	2025-04-08 06:23:56.445+00	\N
c8f6feda-0a53-4496-af43-e72780876e98	testdirect	testdirect@example.com	$2b$10$WKUlHKXwO1F/i0XM/vd/fu9iRjnsipDZ6UJqeZi1nduk2OXMGT7yG	user	dark	\N	\N	t	2025-04-02 05:03:37.938514+00	2025-04-02 05:03:37.940615+00	2025-04-08 06:23:58.617+00	\N
fe85106a-148c-419a-a20f-0bd648518e1d	testmanual	testmanual@example.com	$2b$10$uvf4BRoHdgMY5zieEIKak.lAoOMSi9pnJDJ.7kDVdGgjgkKjRsiki	user	dark	\N	\N	t	2025-04-02 05:03:37.938514+00	2025-04-02 05:03:37.940615+00	2025-04-08 06:24:01.011+00	\N
ee667a21-2826-4842-9b88-e40999742e60	testuser	testuser@example.com	$2b$10$CGFNq1LdIaS45VJpIB./6e70OPjQKb1UCaW3crdlsCztIQAoK9t4y	user	dark	\N	\N	t	2025-04-02 05:03:37.938514+00	2025-04-02 05:03:37.940615+00	2025-04-08 06:24:03.509+00	\N
5cdb2404-53c3-49fa-b978-7d2047ca9614	testuser1	test1@example.com	$2b$10$vEpoH0UEY6ekw3VZxBEv1uiqW6X8tjQgEjzwzZLpeS1ek9P2VY7M2	user	dark	\N	\N	t	2025-04-02 05:03:37.938514+00	2025-04-02 05:03:37.940615+00	2025-04-08 06:24:05.072+00	\N
6e3982d7-5c6d-4706-9b36-c17d7f7a646d	Joe	joemcmyne@gmail.com	$2b$10$5.obzCygDjajuYDuTOIEyOQjfqw3kDDqWDcGSUZKE.1XmBOofuXle	user	dark	Joe	McMyne	t	2025-04-08 06:35:53.847+00	2025-04-08 06:35:53.847+00	\N	\N
6dbedaf0-8f70-4bf5-9e99-0b30a80d4509	Jay	jay@mobilehomerepairfl.com	$2b$10$/RYb9lH2UUHAjBogneLsw.CrMzOWrBUWxh8yf6CC/iwB26y5SZsFW	user	dark	\N	\N	f	2025-04-02 05:03:37.938514+00	2025-04-15 00:37:29.157+00	\N	\N
\.


--
-- Name: llm_prompts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: josephmcmyne
--

SELECT pg_catalog.setval('public.llm_prompts_id_seq', 5, true);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: josephmcmyne
--

SELECT pg_catalog.setval('public.settings_id_seq', 208, true);


--
-- Name: SequelizeMeta SequelizeMeta_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public."SequelizeMeta"
    ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);


--
-- Name: client_addresses client_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.client_addresses
    ADD CONSTRAINT client_addresses_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: estimate_item_additional_work estimate_item_additional_work_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimate_item_additional_work
    ADD CONSTRAINT estimate_item_additional_work_pkey PRIMARY KEY (id);


--
-- Name: estimate_item_photos estimate_item_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimate_item_photos
    ADD CONSTRAINT estimate_item_photos_pkey PRIMARY KEY (id);


--
-- Name: estimate_items estimate_items_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimate_items
    ADD CONSTRAINT estimate_items_pkey PRIMARY KEY (id);


--
-- Name: estimates estimates_estimate_number_key; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key1; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key1 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key10; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key10 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key100; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key100 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key101; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key101 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key102; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key102 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key103; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key103 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key104; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key104 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key105; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key105 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key106; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key106 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key107; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key107 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key108; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key108 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key11; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key11 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key12; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key12 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key13; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key13 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key14; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key14 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key15; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key15 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key16; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key16 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key17; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key17 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key18; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key18 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key19; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key19 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key2; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key2 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key20; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key20 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key21; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key21 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key22; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key22 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key23; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key23 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key24; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key24 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key25; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key25 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key26; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key26 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key27; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key27 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key28; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key28 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key29; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key29 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key3; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key3 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key30; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key30 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key31; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key31 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key32; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key32 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key33; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key33 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key34; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key34 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key35; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key35 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key36; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key36 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key37; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key37 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key38; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key38 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key39; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key39 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key4; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key4 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key40; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key40 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key41; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key41 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key42; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key42 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key43; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key43 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key44; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key44 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key45; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key45 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key46; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key46 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key47; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key47 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key48; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key48 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key49; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key49 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key5; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key5 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key50; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key50 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key51; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key51 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key52; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key52 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key53; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key53 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key54; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key54 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key55; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key55 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key56; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key56 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key57; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key57 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key58; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key58 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key59; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key59 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key6; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key6 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key60; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key60 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key61; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key61 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key62; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key62 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key63; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key63 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key64; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key64 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key65; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key65 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key66; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key66 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key67; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key67 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key68; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key68 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key69; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key69 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key7; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key7 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key70; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key70 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key71; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key71 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key72; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key72 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key73; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key73 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key74; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key74 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key75; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key75 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key76; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key76 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key77; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key77 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key78; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key78 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key79; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key79 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key8; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key8 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key80; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key80 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key81; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key81 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key82; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key82 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key83; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key83 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key84; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key84 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key85; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key85 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key86; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key86 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key87; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key87 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key88; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key88 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key89; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key89 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key9; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key9 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key90; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key90 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key91; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key91 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key92; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key92 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key93; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key93 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key94; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key94 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key95; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key95 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key96; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key96 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key97; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key97 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key98; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key98 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key99; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key99 UNIQUE (estimate_number);


--
-- Name: estimates estimates_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_pkey PRIMARY KEY (id);


--
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_invoiceNumber_key; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT "invoices_invoiceNumber_key" UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key1; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key1 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key10; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key10 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key100; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key100 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key101; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key101 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key102; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key102 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key103; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key103 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key104; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key104 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key105; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key105 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key106; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key106 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key107; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key107 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key108; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key108 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key109; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key109 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key11; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key11 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key12; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key12 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key13; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key13 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key14; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key14 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key15; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key15 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key16; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key16 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key17; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key17 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key18; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key18 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key19; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key19 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key2; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key2 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key20; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key20 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key21; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key21 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key22; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key22 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key23; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key23 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key24; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key24 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key25; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key25 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key26; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key26 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key27; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key27 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key28; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key28 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key29; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key29 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key3; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key3 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key30; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key30 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key31; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key31 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key32; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key32 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key33; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key33 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key34; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key34 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key35; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key35 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key36; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key36 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key37; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key37 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key38; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key38 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key39; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key39 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key4; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key4 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key40; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key40 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key41; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key41 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key42; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key42 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key43; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key43 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key44; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key44 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key45; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key45 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key46; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key46 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key47; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key47 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key48; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key48 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key49; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key49 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key5; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key5 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key50; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key50 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key51; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key51 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key52; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key52 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key53; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key53 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key54; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key54 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key55; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key55 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key56; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key56 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key57; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key57 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key58; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key58 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key59; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key59 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key6; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key6 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key60; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key60 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key61; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key61 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key62; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key62 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key63; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key63 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key64; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key64 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key65; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key65 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key66; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key66 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key67; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key67 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key68; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key68 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key69; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key69 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key7; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key7 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key70; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key70 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key71; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key71 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key72; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key72 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key73; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key73 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key74; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key74 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key75; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key75 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key76; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key76 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key77; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key77 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key78; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key78 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key79; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key79 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key8; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key8 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key80; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key80 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key81; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key81 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key82; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key82 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key83; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key83 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key84; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key84 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key85; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key85 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key86; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key86 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key87; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key87 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key88; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key88 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key89; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key89 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key9; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key9 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key90; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key90 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key91; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key91 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key92; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key92 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key93; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key93 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key94; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key94 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key95; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key95 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key96; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key96 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key97; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key97 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key98; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key98 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key99; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key99 UNIQUE (invoice_number);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: llm_prompts llm_prompts_name_key; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.llm_prompts
    ADD CONSTRAINT llm_prompts_name_key UNIQUE (name);


--
-- Name: llm_prompts llm_prompts_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.llm_prompts
    ADD CONSTRAINT llm_prompts_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: pre_assessment_photos pre_assessment_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.pre_assessment_photos
    ADD CONSTRAINT pre_assessment_photos_pkey PRIMARY KEY (id);


--
-- Name: pre_assessment_project_types pre_assessment_project_types_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.pre_assessment_project_types
    ADD CONSTRAINT pre_assessment_project_types_pkey PRIMARY KEY (id);


--
-- Name: pre_assessments pre_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.pre_assessments
    ADD CONSTRAINT pre_assessments_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: project_inspections project_inspections_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.project_inspections
    ADD CONSTRAINT project_inspections_pkey PRIMARY KEY (id);


--
-- Name: project_photos project_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.project_photos
    ADD CONSTRAINT project_photos_pkey PRIMARY KEY (id);


--
-- Name: project_subtypes project_subtypes_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.project_subtypes
    ADD CONSTRAINT project_subtypes_pkey PRIMARY KEY (id);


--
-- Name: project_type_questionnaires project_type_questionnaires_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.project_type_questionnaires
    ADD CONSTRAINT project_type_questionnaires_pkey PRIMARY KEY (id);


--
-- Name: project_type_questionnaires project_type_questionnaires_project_type_key; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.project_type_questionnaires
    ADD CONSTRAINT project_type_questionnaires_project_type_key UNIQUE (project_type);


--
-- Name: project_type_questionnaires project_type_subtype_unique; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.project_type_questionnaires
    ADD CONSTRAINT project_type_subtype_unique UNIQUE (project_type, project_subtype);


--
-- Name: project_types project_types_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.project_types
    ADD CONSTRAINT project_types_pkey PRIMARY KEY (id);


--
-- Name: project_types project_types_value_key; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.project_types
    ADD CONSTRAINT project_types_value_key UNIQUE (value);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: settings settings_key_key; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key UNIQUE (key);


--
-- Name: settings settings_key_key1; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key1 UNIQUE (key);


--
-- Name: settings settings_key_key2; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key2 UNIQUE (key);


--
-- Name: settings settings_key_key3; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key3 UNIQUE (key);


--
-- Name: settings settings_key_key4; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key4 UNIQUE (key);


--
-- Name: settings settings_key_key5; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key5 UNIQUE (key);


--
-- Name: settings settings_key_key6; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key6 UNIQUE (key);


--
-- Name: settings settings_key_key7; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key7 UNIQUE (key);


--
-- Name: settings settings_key_key8; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key8 UNIQUE (key);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: source_maps source_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.source_maps
    ADD CONSTRAINT source_maps_pkey PRIMARY KEY (id);


--
-- Name: project_subtypes unique_project_subtype; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.project_subtypes
    ADD CONSTRAINT unique_project_subtype UNIQUE (project_type_id, value);


--
-- Name: project_type_questionnaires unique_project_type_questionnaire; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.project_type_questionnaires
    ADD CONSTRAINT unique_project_type_questionnaire UNIQUE (project_type, project_subtype);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_email_key1; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key1 UNIQUE (email);


--
-- Name: users users_email_key10; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key10 UNIQUE (email);


--
-- Name: users users_email_key100; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key100 UNIQUE (email);


--
-- Name: users users_email_key101; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key101 UNIQUE (email);


--
-- Name: users users_email_key102; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key102 UNIQUE (email);


--
-- Name: users users_email_key103; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key103 UNIQUE (email);


--
-- Name: users users_email_key104; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key104 UNIQUE (email);


--
-- Name: users users_email_key105; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key105 UNIQUE (email);


--
-- Name: users users_email_key106; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key106 UNIQUE (email);


--
-- Name: users users_email_key107; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key107 UNIQUE (email);


--
-- Name: users users_email_key108; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key108 UNIQUE (email);


--
-- Name: users users_email_key109; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key109 UNIQUE (email);


--
-- Name: users users_email_key11; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key11 UNIQUE (email);


--
-- Name: users users_email_key110; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key110 UNIQUE (email);


--
-- Name: users users_email_key111; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key111 UNIQUE (email);


--
-- Name: users users_email_key112; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key112 UNIQUE (email);


--
-- Name: users users_email_key113; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key113 UNIQUE (email);


--
-- Name: users users_email_key114; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key114 UNIQUE (email);


--
-- Name: users users_email_key115; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key115 UNIQUE (email);


--
-- Name: users users_email_key116; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key116 UNIQUE (email);


--
-- Name: users users_email_key117; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key117 UNIQUE (email);


--
-- Name: users users_email_key118; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key118 UNIQUE (email);


--
-- Name: users users_email_key119; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key119 UNIQUE (email);


--
-- Name: users users_email_key12; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key12 UNIQUE (email);


--
-- Name: users users_email_key120; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key120 UNIQUE (email);


--
-- Name: users users_email_key121; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key121 UNIQUE (email);


--
-- Name: users users_email_key122; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key122 UNIQUE (email);


--
-- Name: users users_email_key123; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key123 UNIQUE (email);


--
-- Name: users users_email_key124; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key124 UNIQUE (email);


--
-- Name: users users_email_key125; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key125 UNIQUE (email);


--
-- Name: users users_email_key126; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key126 UNIQUE (email);


--
-- Name: users users_email_key127; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key127 UNIQUE (email);


--
-- Name: users users_email_key128; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key128 UNIQUE (email);


--
-- Name: users users_email_key129; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key129 UNIQUE (email);


--
-- Name: users users_email_key13; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key13 UNIQUE (email);


--
-- Name: users users_email_key130; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key130 UNIQUE (email);


--
-- Name: users users_email_key131; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key131 UNIQUE (email);


--
-- Name: users users_email_key132; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key132 UNIQUE (email);


--
-- Name: users users_email_key133; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key133 UNIQUE (email);


--
-- Name: users users_email_key134; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key134 UNIQUE (email);


--
-- Name: users users_email_key135; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key135 UNIQUE (email);


--
-- Name: users users_email_key136; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key136 UNIQUE (email);


--
-- Name: users users_email_key137; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key137 UNIQUE (email);


--
-- Name: users users_email_key138; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key138 UNIQUE (email);


--
-- Name: users users_email_key139; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key139 UNIQUE (email);


--
-- Name: users users_email_key14; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key14 UNIQUE (email);


--
-- Name: users users_email_key140; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key140 UNIQUE (email);


--
-- Name: users users_email_key141; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key141 UNIQUE (email);


--
-- Name: users users_email_key142; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key142 UNIQUE (email);


--
-- Name: users users_email_key143; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key143 UNIQUE (email);


--
-- Name: users users_email_key144; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key144 UNIQUE (email);


--
-- Name: users users_email_key145; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key145 UNIQUE (email);


--
-- Name: users users_email_key146; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key146 UNIQUE (email);


--
-- Name: users users_email_key147; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key147 UNIQUE (email);


--
-- Name: users users_email_key148; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key148 UNIQUE (email);


--
-- Name: users users_email_key149; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key149 UNIQUE (email);


--
-- Name: users users_email_key15; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key15 UNIQUE (email);


--
-- Name: users users_email_key150; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key150 UNIQUE (email);


--
-- Name: users users_email_key151; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key151 UNIQUE (email);


--
-- Name: users users_email_key152; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key152 UNIQUE (email);


--
-- Name: users users_email_key153; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key153 UNIQUE (email);


--
-- Name: users users_email_key154; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key154 UNIQUE (email);


--
-- Name: users users_email_key155; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key155 UNIQUE (email);


--
-- Name: users users_email_key156; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key156 UNIQUE (email);


--
-- Name: users users_email_key157; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key157 UNIQUE (email);


--
-- Name: users users_email_key158; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key158 UNIQUE (email);


--
-- Name: users users_email_key159; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key159 UNIQUE (email);


--
-- Name: users users_email_key16; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key16 UNIQUE (email);


--
-- Name: users users_email_key160; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key160 UNIQUE (email);


--
-- Name: users users_email_key161; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key161 UNIQUE (email);


--
-- Name: users users_email_key162; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key162 UNIQUE (email);


--
-- Name: users users_email_key163; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key163 UNIQUE (email);


--
-- Name: users users_email_key164; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key164 UNIQUE (email);


--
-- Name: users users_email_key165; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key165 UNIQUE (email);


--
-- Name: users users_email_key166; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key166 UNIQUE (email);


--
-- Name: users users_email_key167; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key167 UNIQUE (email);


--
-- Name: users users_email_key168; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key168 UNIQUE (email);


--
-- Name: users users_email_key169; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key169 UNIQUE (email);


--
-- Name: users users_email_key17; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key17 UNIQUE (email);


--
-- Name: users users_email_key170; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key170 UNIQUE (email);


--
-- Name: users users_email_key171; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key171 UNIQUE (email);


--
-- Name: users users_email_key172; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key172 UNIQUE (email);


--
-- Name: users users_email_key173; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key173 UNIQUE (email);


--
-- Name: users users_email_key174; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key174 UNIQUE (email);


--
-- Name: users users_email_key175; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key175 UNIQUE (email);


--
-- Name: users users_email_key176; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key176 UNIQUE (email);


--
-- Name: users users_email_key177; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key177 UNIQUE (email);


--
-- Name: users users_email_key178; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key178 UNIQUE (email);


--
-- Name: users users_email_key179; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key179 UNIQUE (email);


--
-- Name: users users_email_key18; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key18 UNIQUE (email);


--
-- Name: users users_email_key180; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key180 UNIQUE (email);


--
-- Name: users users_email_key181; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key181 UNIQUE (email);


--
-- Name: users users_email_key182; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key182 UNIQUE (email);


--
-- Name: users users_email_key183; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key183 UNIQUE (email);


--
-- Name: users users_email_key184; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key184 UNIQUE (email);


--
-- Name: users users_email_key185; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key185 UNIQUE (email);


--
-- Name: users users_email_key186; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key186 UNIQUE (email);


--
-- Name: users users_email_key187; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key187 UNIQUE (email);


--
-- Name: users users_email_key188; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key188 UNIQUE (email);


--
-- Name: users users_email_key189; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key189 UNIQUE (email);


--
-- Name: users users_email_key19; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key19 UNIQUE (email);


--
-- Name: users users_email_key190; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key190 UNIQUE (email);


--
-- Name: users users_email_key191; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key191 UNIQUE (email);


--
-- Name: users users_email_key192; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key192 UNIQUE (email);


--
-- Name: users users_email_key193; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key193 UNIQUE (email);


--
-- Name: users users_email_key194; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key194 UNIQUE (email);


--
-- Name: users users_email_key195; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key195 UNIQUE (email);


--
-- Name: users users_email_key196; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key196 UNIQUE (email);


--
-- Name: users users_email_key197; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key197 UNIQUE (email);


--
-- Name: users users_email_key198; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key198 UNIQUE (email);


--
-- Name: users users_email_key199; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key199 UNIQUE (email);


--
-- Name: users users_email_key2; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key2 UNIQUE (email);


--
-- Name: users users_email_key20; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key20 UNIQUE (email);


--
-- Name: users users_email_key200; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key200 UNIQUE (email);


--
-- Name: users users_email_key201; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key201 UNIQUE (email);


--
-- Name: users users_email_key202; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key202 UNIQUE (email);


--
-- Name: users users_email_key203; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key203 UNIQUE (email);


--
-- Name: users users_email_key204; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key204 UNIQUE (email);


--
-- Name: users users_email_key205; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key205 UNIQUE (email);


--
-- Name: users users_email_key206; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key206 UNIQUE (email);


--
-- Name: users users_email_key207; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key207 UNIQUE (email);


--
-- Name: users users_email_key208; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key208 UNIQUE (email);


--
-- Name: users users_email_key209; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key209 UNIQUE (email);


--
-- Name: users users_email_key21; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key21 UNIQUE (email);


--
-- Name: users users_email_key210; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key210 UNIQUE (email);


--
-- Name: users users_email_key211; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key211 UNIQUE (email);


--
-- Name: users users_email_key212; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key212 UNIQUE (email);


--
-- Name: users users_email_key213; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key213 UNIQUE (email);


--
-- Name: users users_email_key214; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key214 UNIQUE (email);


--
-- Name: users users_email_key215; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key215 UNIQUE (email);


--
-- Name: users users_email_key216; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key216 UNIQUE (email);


--
-- Name: users users_email_key217; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key217 UNIQUE (email);


--
-- Name: users users_email_key218; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key218 UNIQUE (email);


--
-- Name: users users_email_key219; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key219 UNIQUE (email);


--
-- Name: users users_email_key22; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key22 UNIQUE (email);


--
-- Name: users users_email_key220; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key220 UNIQUE (email);


--
-- Name: users users_email_key221; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key221 UNIQUE (email);


--
-- Name: users users_email_key222; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key222 UNIQUE (email);


--
-- Name: users users_email_key223; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key223 UNIQUE (email);


--
-- Name: users users_email_key224; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key224 UNIQUE (email);


--
-- Name: users users_email_key225; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key225 UNIQUE (email);


--
-- Name: users users_email_key226; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key226 UNIQUE (email);


--
-- Name: users users_email_key227; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key227 UNIQUE (email);


--
-- Name: users users_email_key228; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key228 UNIQUE (email);


--
-- Name: users users_email_key229; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key229 UNIQUE (email);


--
-- Name: users users_email_key23; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key23 UNIQUE (email);


--
-- Name: users users_email_key230; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key230 UNIQUE (email);


--
-- Name: users users_email_key231; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key231 UNIQUE (email);


--
-- Name: users users_email_key232; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key232 UNIQUE (email);


--
-- Name: users users_email_key233; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key233 UNIQUE (email);


--
-- Name: users users_email_key234; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key234 UNIQUE (email);


--
-- Name: users users_email_key235; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key235 UNIQUE (email);


--
-- Name: users users_email_key236; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key236 UNIQUE (email);


--
-- Name: users users_email_key237; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key237 UNIQUE (email);


--
-- Name: users users_email_key238; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key238 UNIQUE (email);


--
-- Name: users users_email_key239; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key239 UNIQUE (email);


--
-- Name: users users_email_key24; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key24 UNIQUE (email);


--
-- Name: users users_email_key240; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key240 UNIQUE (email);


--
-- Name: users users_email_key241; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key241 UNIQUE (email);


--
-- Name: users users_email_key242; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key242 UNIQUE (email);


--
-- Name: users users_email_key243; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key243 UNIQUE (email);


--
-- Name: users users_email_key244; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key244 UNIQUE (email);


--
-- Name: users users_email_key245; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key245 UNIQUE (email);


--
-- Name: users users_email_key246; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key246 UNIQUE (email);


--
-- Name: users users_email_key247; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key247 UNIQUE (email);


--
-- Name: users users_email_key248; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key248 UNIQUE (email);


--
-- Name: users users_email_key249; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key249 UNIQUE (email);


--
-- Name: users users_email_key25; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key25 UNIQUE (email);


--
-- Name: users users_email_key250; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key250 UNIQUE (email);


--
-- Name: users users_email_key251; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key251 UNIQUE (email);


--
-- Name: users users_email_key252; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key252 UNIQUE (email);


--
-- Name: users users_email_key253; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key253 UNIQUE (email);


--
-- Name: users users_email_key254; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key254 UNIQUE (email);


--
-- Name: users users_email_key255; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key255 UNIQUE (email);


--
-- Name: users users_email_key256; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key256 UNIQUE (email);


--
-- Name: users users_email_key257; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key257 UNIQUE (email);


--
-- Name: users users_email_key258; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key258 UNIQUE (email);


--
-- Name: users users_email_key259; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key259 UNIQUE (email);


--
-- Name: users users_email_key26; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key26 UNIQUE (email);


--
-- Name: users users_email_key260; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key260 UNIQUE (email);


--
-- Name: users users_email_key261; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key261 UNIQUE (email);


--
-- Name: users users_email_key262; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key262 UNIQUE (email);


--
-- Name: users users_email_key263; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key263 UNIQUE (email);


--
-- Name: users users_email_key264; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key264 UNIQUE (email);


--
-- Name: users users_email_key265; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key265 UNIQUE (email);


--
-- Name: users users_email_key266; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key266 UNIQUE (email);


--
-- Name: users users_email_key267; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key267 UNIQUE (email);


--
-- Name: users users_email_key268; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key268 UNIQUE (email);


--
-- Name: users users_email_key269; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key269 UNIQUE (email);


--
-- Name: users users_email_key27; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key27 UNIQUE (email);


--
-- Name: users users_email_key270; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key270 UNIQUE (email);


--
-- Name: users users_email_key271; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key271 UNIQUE (email);


--
-- Name: users users_email_key272; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key272 UNIQUE (email);


--
-- Name: users users_email_key273; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key273 UNIQUE (email);


--
-- Name: users users_email_key274; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key274 UNIQUE (email);


--
-- Name: users users_email_key275; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key275 UNIQUE (email);


--
-- Name: users users_email_key276; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key276 UNIQUE (email);


--
-- Name: users users_email_key277; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key277 UNIQUE (email);


--
-- Name: users users_email_key278; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key278 UNIQUE (email);


--
-- Name: users users_email_key279; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key279 UNIQUE (email);


--
-- Name: users users_email_key28; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key28 UNIQUE (email);


--
-- Name: users users_email_key280; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key280 UNIQUE (email);


--
-- Name: users users_email_key281; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key281 UNIQUE (email);


--
-- Name: users users_email_key282; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key282 UNIQUE (email);


--
-- Name: users users_email_key283; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key283 UNIQUE (email);


--
-- Name: users users_email_key284; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key284 UNIQUE (email);


--
-- Name: users users_email_key285; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key285 UNIQUE (email);


--
-- Name: users users_email_key286; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key286 UNIQUE (email);


--
-- Name: users users_email_key287; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key287 UNIQUE (email);


--
-- Name: users users_email_key288; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key288 UNIQUE (email);


--
-- Name: users users_email_key289; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key289 UNIQUE (email);


--
-- Name: users users_email_key29; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key29 UNIQUE (email);


--
-- Name: users users_email_key290; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key290 UNIQUE (email);


--
-- Name: users users_email_key291; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key291 UNIQUE (email);


--
-- Name: users users_email_key292; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key292 UNIQUE (email);


--
-- Name: users users_email_key293; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key293 UNIQUE (email);


--
-- Name: users users_email_key294; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key294 UNIQUE (email);


--
-- Name: users users_email_key295; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key295 UNIQUE (email);


--
-- Name: users users_email_key296; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key296 UNIQUE (email);


--
-- Name: users users_email_key297; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key297 UNIQUE (email);


--
-- Name: users users_email_key298; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key298 UNIQUE (email);


--
-- Name: users users_email_key299; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key299 UNIQUE (email);


--
-- Name: users users_email_key3; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key3 UNIQUE (email);


--
-- Name: users users_email_key30; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key30 UNIQUE (email);


--
-- Name: users users_email_key300; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key300 UNIQUE (email);


--
-- Name: users users_email_key301; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key301 UNIQUE (email);


--
-- Name: users users_email_key302; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key302 UNIQUE (email);


--
-- Name: users users_email_key303; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key303 UNIQUE (email);


--
-- Name: users users_email_key304; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key304 UNIQUE (email);


--
-- Name: users users_email_key305; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key305 UNIQUE (email);


--
-- Name: users users_email_key306; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key306 UNIQUE (email);


--
-- Name: users users_email_key307; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key307 UNIQUE (email);


--
-- Name: users users_email_key308; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key308 UNIQUE (email);


--
-- Name: users users_email_key309; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key309 UNIQUE (email);


--
-- Name: users users_email_key31; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key31 UNIQUE (email);


--
-- Name: users users_email_key310; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key310 UNIQUE (email);


--
-- Name: users users_email_key311; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key311 UNIQUE (email);


--
-- Name: users users_email_key312; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key312 UNIQUE (email);


--
-- Name: users users_email_key313; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key313 UNIQUE (email);


--
-- Name: users users_email_key314; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key314 UNIQUE (email);


--
-- Name: users users_email_key315; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key315 UNIQUE (email);


--
-- Name: users users_email_key316; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key316 UNIQUE (email);


--
-- Name: users users_email_key317; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key317 UNIQUE (email);


--
-- Name: users users_email_key318; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key318 UNIQUE (email);


--
-- Name: users users_email_key319; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key319 UNIQUE (email);


--
-- Name: users users_email_key32; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key32 UNIQUE (email);


--
-- Name: users users_email_key320; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key320 UNIQUE (email);


--
-- Name: users users_email_key321; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key321 UNIQUE (email);


--
-- Name: users users_email_key322; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key322 UNIQUE (email);


--
-- Name: users users_email_key323; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key323 UNIQUE (email);


--
-- Name: users users_email_key324; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key324 UNIQUE (email);


--
-- Name: users users_email_key325; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key325 UNIQUE (email);


--
-- Name: users users_email_key326; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key326 UNIQUE (email);


--
-- Name: users users_email_key327; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key327 UNIQUE (email);


--
-- Name: users users_email_key328; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key328 UNIQUE (email);


--
-- Name: users users_email_key329; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key329 UNIQUE (email);


--
-- Name: users users_email_key33; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key33 UNIQUE (email);


--
-- Name: users users_email_key330; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key330 UNIQUE (email);


--
-- Name: users users_email_key331; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key331 UNIQUE (email);


--
-- Name: users users_email_key332; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key332 UNIQUE (email);


--
-- Name: users users_email_key333; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key333 UNIQUE (email);


--
-- Name: users users_email_key334; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key334 UNIQUE (email);


--
-- Name: users users_email_key335; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key335 UNIQUE (email);


--
-- Name: users users_email_key336; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key336 UNIQUE (email);


--
-- Name: users users_email_key337; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key337 UNIQUE (email);


--
-- Name: users users_email_key338; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key338 UNIQUE (email);


--
-- Name: users users_email_key339; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key339 UNIQUE (email);


--
-- Name: users users_email_key34; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key34 UNIQUE (email);


--
-- Name: users users_email_key340; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key340 UNIQUE (email);


--
-- Name: users users_email_key341; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key341 UNIQUE (email);


--
-- Name: users users_email_key342; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key342 UNIQUE (email);


--
-- Name: users users_email_key343; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key343 UNIQUE (email);


--
-- Name: users users_email_key344; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key344 UNIQUE (email);


--
-- Name: users users_email_key345; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key345 UNIQUE (email);


--
-- Name: users users_email_key346; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key346 UNIQUE (email);


--
-- Name: users users_email_key347; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key347 UNIQUE (email);


--
-- Name: users users_email_key348; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key348 UNIQUE (email);


--
-- Name: users users_email_key349; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key349 UNIQUE (email);


--
-- Name: users users_email_key35; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key35 UNIQUE (email);


--
-- Name: users users_email_key350; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key350 UNIQUE (email);


--
-- Name: users users_email_key351; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key351 UNIQUE (email);


--
-- Name: users users_email_key352; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key352 UNIQUE (email);


--
-- Name: users users_email_key353; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key353 UNIQUE (email);


--
-- Name: users users_email_key354; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key354 UNIQUE (email);


--
-- Name: users users_email_key355; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key355 UNIQUE (email);


--
-- Name: users users_email_key356; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key356 UNIQUE (email);


--
-- Name: users users_email_key357; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key357 UNIQUE (email);


--
-- Name: users users_email_key358; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key358 UNIQUE (email);


--
-- Name: users users_email_key359; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key359 UNIQUE (email);


--
-- Name: users users_email_key36; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key36 UNIQUE (email);


--
-- Name: users users_email_key360; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key360 UNIQUE (email);


--
-- Name: users users_email_key361; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key361 UNIQUE (email);


--
-- Name: users users_email_key362; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key362 UNIQUE (email);


--
-- Name: users users_email_key363; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key363 UNIQUE (email);


--
-- Name: users users_email_key364; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key364 UNIQUE (email);


--
-- Name: users users_email_key365; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key365 UNIQUE (email);


--
-- Name: users users_email_key366; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key366 UNIQUE (email);


--
-- Name: users users_email_key367; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key367 UNIQUE (email);


--
-- Name: users users_email_key368; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key368 UNIQUE (email);


--
-- Name: users users_email_key369; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key369 UNIQUE (email);


--
-- Name: users users_email_key37; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key37 UNIQUE (email);


--
-- Name: users users_email_key370; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key370 UNIQUE (email);


--
-- Name: users users_email_key371; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key371 UNIQUE (email);


--
-- Name: users users_email_key372; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key372 UNIQUE (email);


--
-- Name: users users_email_key373; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key373 UNIQUE (email);


--
-- Name: users users_email_key374; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key374 UNIQUE (email);


--
-- Name: users users_email_key375; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key375 UNIQUE (email);


--
-- Name: users users_email_key376; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key376 UNIQUE (email);


--
-- Name: users users_email_key377; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key377 UNIQUE (email);


--
-- Name: users users_email_key378; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key378 UNIQUE (email);


--
-- Name: users users_email_key379; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key379 UNIQUE (email);


--
-- Name: users users_email_key38; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key38 UNIQUE (email);


--
-- Name: users users_email_key380; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key380 UNIQUE (email);


--
-- Name: users users_email_key381; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key381 UNIQUE (email);


--
-- Name: users users_email_key382; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key382 UNIQUE (email);


--
-- Name: users users_email_key383; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key383 UNIQUE (email);


--
-- Name: users users_email_key384; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key384 UNIQUE (email);


--
-- Name: users users_email_key385; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key385 UNIQUE (email);


--
-- Name: users users_email_key386; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key386 UNIQUE (email);


--
-- Name: users users_email_key387; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key387 UNIQUE (email);


--
-- Name: users users_email_key388; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key388 UNIQUE (email);


--
-- Name: users users_email_key389; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key389 UNIQUE (email);


--
-- Name: users users_email_key39; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key39 UNIQUE (email);


--
-- Name: users users_email_key390; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key390 UNIQUE (email);


--
-- Name: users users_email_key391; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key391 UNIQUE (email);


--
-- Name: users users_email_key392; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key392 UNIQUE (email);


--
-- Name: users users_email_key393; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key393 UNIQUE (email);


--
-- Name: users users_email_key394; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key394 UNIQUE (email);


--
-- Name: users users_email_key395; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key395 UNIQUE (email);


--
-- Name: users users_email_key396; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key396 UNIQUE (email);


--
-- Name: users users_email_key397; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key397 UNIQUE (email);


--
-- Name: users users_email_key398; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key398 UNIQUE (email);


--
-- Name: users users_email_key399; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key399 UNIQUE (email);


--
-- Name: users users_email_key4; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key4 UNIQUE (email);


--
-- Name: users users_email_key40; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key40 UNIQUE (email);


--
-- Name: users users_email_key400; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key400 UNIQUE (email);


--
-- Name: users users_email_key401; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key401 UNIQUE (email);


--
-- Name: users users_email_key402; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key402 UNIQUE (email);


--
-- Name: users users_email_key41; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key41 UNIQUE (email);


--
-- Name: users users_email_key42; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key42 UNIQUE (email);


--
-- Name: users users_email_key43; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key43 UNIQUE (email);


--
-- Name: users users_email_key44; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key44 UNIQUE (email);


--
-- Name: users users_email_key45; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key45 UNIQUE (email);


--
-- Name: users users_email_key46; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key46 UNIQUE (email);


--
-- Name: users users_email_key47; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key47 UNIQUE (email);


--
-- Name: users users_email_key48; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key48 UNIQUE (email);


--
-- Name: users users_email_key49; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key49 UNIQUE (email);


--
-- Name: users users_email_key5; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key5 UNIQUE (email);


--
-- Name: users users_email_key50; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key50 UNIQUE (email);


--
-- Name: users users_email_key51; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key51 UNIQUE (email);


--
-- Name: users users_email_key52; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key52 UNIQUE (email);


--
-- Name: users users_email_key53; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key53 UNIQUE (email);


--
-- Name: users users_email_key54; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key54 UNIQUE (email);


--
-- Name: users users_email_key55; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key55 UNIQUE (email);


--
-- Name: users users_email_key56; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key56 UNIQUE (email);


--
-- Name: users users_email_key57; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key57 UNIQUE (email);


--
-- Name: users users_email_key58; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key58 UNIQUE (email);


--
-- Name: users users_email_key59; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key59 UNIQUE (email);


--
-- Name: users users_email_key6; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key6 UNIQUE (email);


--
-- Name: users users_email_key60; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key60 UNIQUE (email);


--
-- Name: users users_email_key61; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key61 UNIQUE (email);


--
-- Name: users users_email_key62; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key62 UNIQUE (email);


--
-- Name: users users_email_key63; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key63 UNIQUE (email);


--
-- Name: users users_email_key64; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key64 UNIQUE (email);


--
-- Name: users users_email_key65; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key65 UNIQUE (email);


--
-- Name: users users_email_key66; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key66 UNIQUE (email);


--
-- Name: users users_email_key67; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key67 UNIQUE (email);


--
-- Name: users users_email_key68; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key68 UNIQUE (email);


--
-- Name: users users_email_key69; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key69 UNIQUE (email);


--
-- Name: users users_email_key7; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key7 UNIQUE (email);


--
-- Name: users users_email_key70; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key70 UNIQUE (email);


--
-- Name: users users_email_key71; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key71 UNIQUE (email);


--
-- Name: users users_email_key72; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key72 UNIQUE (email);


--
-- Name: users users_email_key73; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key73 UNIQUE (email);


--
-- Name: users users_email_key74; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key74 UNIQUE (email);


--
-- Name: users users_email_key75; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key75 UNIQUE (email);


--
-- Name: users users_email_key76; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key76 UNIQUE (email);


--
-- Name: users users_email_key77; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key77 UNIQUE (email);


--
-- Name: users users_email_key78; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key78 UNIQUE (email);


--
-- Name: users users_email_key79; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key79 UNIQUE (email);


--
-- Name: users users_email_key8; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key8 UNIQUE (email);


--
-- Name: users users_email_key80; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key80 UNIQUE (email);


--
-- Name: users users_email_key81; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key81 UNIQUE (email);


--
-- Name: users users_email_key82; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key82 UNIQUE (email);


--
-- Name: users users_email_key83; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key83 UNIQUE (email);


--
-- Name: users users_email_key84; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key84 UNIQUE (email);


--
-- Name: users users_email_key85; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key85 UNIQUE (email);


--
-- Name: users users_email_key86; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key86 UNIQUE (email);


--
-- Name: users users_email_key87; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key87 UNIQUE (email);


--
-- Name: users users_email_key88; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key88 UNIQUE (email);


--
-- Name: users users_email_key89; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key89 UNIQUE (email);


--
-- Name: users users_email_key9; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key9 UNIQUE (email);


--
-- Name: users users_email_key90; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key90 UNIQUE (email);


--
-- Name: users users_email_key91; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key91 UNIQUE (email);


--
-- Name: users users_email_key92; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key92 UNIQUE (email);


--
-- Name: users users_email_key93; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key93 UNIQUE (email);


--
-- Name: users users_email_key94; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key94 UNIQUE (email);


--
-- Name: users users_email_key95; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key95 UNIQUE (email);


--
-- Name: users users_email_key96; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key96 UNIQUE (email);


--
-- Name: users users_email_key97; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key97 UNIQUE (email);


--
-- Name: users users_email_key98; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key98 UNIQUE (email);


--
-- Name: users users_email_key99; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key99 UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: users users_username_key1; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key1 UNIQUE (username);


--
-- Name: users users_username_key10; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key10 UNIQUE (username);


--
-- Name: users users_username_key100; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key100 UNIQUE (username);


--
-- Name: users users_username_key101; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key101 UNIQUE (username);


--
-- Name: users users_username_key102; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key102 UNIQUE (username);


--
-- Name: users users_username_key103; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key103 UNIQUE (username);


--
-- Name: users users_username_key104; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key104 UNIQUE (username);


--
-- Name: users users_username_key105; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key105 UNIQUE (username);


--
-- Name: users users_username_key106; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key106 UNIQUE (username);


--
-- Name: users users_username_key107; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key107 UNIQUE (username);


--
-- Name: users users_username_key108; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key108 UNIQUE (username);


--
-- Name: users users_username_key109; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key109 UNIQUE (username);


--
-- Name: users users_username_key11; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key11 UNIQUE (username);


--
-- Name: users users_username_key110; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key110 UNIQUE (username);


--
-- Name: users users_username_key111; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key111 UNIQUE (username);


--
-- Name: users users_username_key112; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key112 UNIQUE (username);


--
-- Name: users users_username_key113; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key113 UNIQUE (username);


--
-- Name: users users_username_key114; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key114 UNIQUE (username);


--
-- Name: users users_username_key115; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key115 UNIQUE (username);


--
-- Name: users users_username_key116; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key116 UNIQUE (username);


--
-- Name: users users_username_key117; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key117 UNIQUE (username);


--
-- Name: users users_username_key118; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key118 UNIQUE (username);


--
-- Name: users users_username_key119; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key119 UNIQUE (username);


--
-- Name: users users_username_key12; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key12 UNIQUE (username);


--
-- Name: users users_username_key120; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key120 UNIQUE (username);


--
-- Name: users users_username_key121; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key121 UNIQUE (username);


--
-- Name: users users_username_key122; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key122 UNIQUE (username);


--
-- Name: users users_username_key123; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key123 UNIQUE (username);


--
-- Name: users users_username_key124; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key124 UNIQUE (username);


--
-- Name: users users_username_key125; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key125 UNIQUE (username);


--
-- Name: users users_username_key126; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key126 UNIQUE (username);


--
-- Name: users users_username_key127; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key127 UNIQUE (username);


--
-- Name: users users_username_key128; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key128 UNIQUE (username);


--
-- Name: users users_username_key129; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key129 UNIQUE (username);


--
-- Name: users users_username_key13; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key13 UNIQUE (username);


--
-- Name: users users_username_key130; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key130 UNIQUE (username);


--
-- Name: users users_username_key131; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key131 UNIQUE (username);


--
-- Name: users users_username_key132; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key132 UNIQUE (username);


--
-- Name: users users_username_key133; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key133 UNIQUE (username);


--
-- Name: users users_username_key134; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key134 UNIQUE (username);


--
-- Name: users users_username_key135; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key135 UNIQUE (username);


--
-- Name: users users_username_key136; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key136 UNIQUE (username);


--
-- Name: users users_username_key137; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key137 UNIQUE (username);


--
-- Name: users users_username_key138; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key138 UNIQUE (username);


--
-- Name: users users_username_key139; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key139 UNIQUE (username);


--
-- Name: users users_username_key14; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key14 UNIQUE (username);


--
-- Name: users users_username_key140; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key140 UNIQUE (username);


--
-- Name: users users_username_key141; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key141 UNIQUE (username);


--
-- Name: users users_username_key142; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key142 UNIQUE (username);


--
-- Name: users users_username_key143; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key143 UNIQUE (username);


--
-- Name: users users_username_key144; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key144 UNIQUE (username);


--
-- Name: users users_username_key145; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key145 UNIQUE (username);


--
-- Name: users users_username_key146; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key146 UNIQUE (username);


--
-- Name: users users_username_key147; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key147 UNIQUE (username);


--
-- Name: users users_username_key148; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key148 UNIQUE (username);


--
-- Name: users users_username_key149; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key149 UNIQUE (username);


--
-- Name: users users_username_key15; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key15 UNIQUE (username);


--
-- Name: users users_username_key150; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key150 UNIQUE (username);


--
-- Name: users users_username_key151; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key151 UNIQUE (username);


--
-- Name: users users_username_key152; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key152 UNIQUE (username);


--
-- Name: users users_username_key153; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key153 UNIQUE (username);


--
-- Name: users users_username_key154; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key154 UNIQUE (username);


--
-- Name: users users_username_key155; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key155 UNIQUE (username);


--
-- Name: users users_username_key156; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key156 UNIQUE (username);


--
-- Name: users users_username_key157; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key157 UNIQUE (username);


--
-- Name: users users_username_key158; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key158 UNIQUE (username);


--
-- Name: users users_username_key159; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key159 UNIQUE (username);


--
-- Name: users users_username_key16; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key16 UNIQUE (username);


--
-- Name: users users_username_key160; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key160 UNIQUE (username);


--
-- Name: users users_username_key161; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key161 UNIQUE (username);


--
-- Name: users users_username_key162; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key162 UNIQUE (username);


--
-- Name: users users_username_key163; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key163 UNIQUE (username);


--
-- Name: users users_username_key164; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key164 UNIQUE (username);


--
-- Name: users users_username_key165; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key165 UNIQUE (username);


--
-- Name: users users_username_key166; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key166 UNIQUE (username);


--
-- Name: users users_username_key167; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key167 UNIQUE (username);


--
-- Name: users users_username_key168; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key168 UNIQUE (username);


--
-- Name: users users_username_key169; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key169 UNIQUE (username);


--
-- Name: users users_username_key17; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key17 UNIQUE (username);


--
-- Name: users users_username_key170; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key170 UNIQUE (username);


--
-- Name: users users_username_key171; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key171 UNIQUE (username);


--
-- Name: users users_username_key172; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key172 UNIQUE (username);


--
-- Name: users users_username_key173; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key173 UNIQUE (username);


--
-- Name: users users_username_key174; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key174 UNIQUE (username);


--
-- Name: users users_username_key175; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key175 UNIQUE (username);


--
-- Name: users users_username_key176; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key176 UNIQUE (username);


--
-- Name: users users_username_key177; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key177 UNIQUE (username);


--
-- Name: users users_username_key178; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key178 UNIQUE (username);


--
-- Name: users users_username_key179; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key179 UNIQUE (username);


--
-- Name: users users_username_key18; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key18 UNIQUE (username);


--
-- Name: users users_username_key180; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key180 UNIQUE (username);


--
-- Name: users users_username_key181; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key181 UNIQUE (username);


--
-- Name: users users_username_key182; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key182 UNIQUE (username);


--
-- Name: users users_username_key183; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key183 UNIQUE (username);


--
-- Name: users users_username_key184; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key184 UNIQUE (username);


--
-- Name: users users_username_key185; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key185 UNIQUE (username);


--
-- Name: users users_username_key186; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key186 UNIQUE (username);


--
-- Name: users users_username_key187; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key187 UNIQUE (username);


--
-- Name: users users_username_key188; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key188 UNIQUE (username);


--
-- Name: users users_username_key189; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key189 UNIQUE (username);


--
-- Name: users users_username_key19; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key19 UNIQUE (username);


--
-- Name: users users_username_key190; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key190 UNIQUE (username);


--
-- Name: users users_username_key191; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key191 UNIQUE (username);


--
-- Name: users users_username_key192; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key192 UNIQUE (username);


--
-- Name: users users_username_key193; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key193 UNIQUE (username);


--
-- Name: users users_username_key194; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key194 UNIQUE (username);


--
-- Name: users users_username_key195; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key195 UNIQUE (username);


--
-- Name: users users_username_key196; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key196 UNIQUE (username);


--
-- Name: users users_username_key197; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key197 UNIQUE (username);


--
-- Name: users users_username_key198; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key198 UNIQUE (username);


--
-- Name: users users_username_key199; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key199 UNIQUE (username);


--
-- Name: users users_username_key2; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key2 UNIQUE (username);


--
-- Name: users users_username_key20; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key20 UNIQUE (username);


--
-- Name: users users_username_key200; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key200 UNIQUE (username);


--
-- Name: users users_username_key201; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key201 UNIQUE (username);


--
-- Name: users users_username_key202; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key202 UNIQUE (username);


--
-- Name: users users_username_key203; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key203 UNIQUE (username);


--
-- Name: users users_username_key204; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key204 UNIQUE (username);


--
-- Name: users users_username_key205; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key205 UNIQUE (username);


--
-- Name: users users_username_key206; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key206 UNIQUE (username);


--
-- Name: users users_username_key207; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key207 UNIQUE (username);


--
-- Name: users users_username_key208; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key208 UNIQUE (username);


--
-- Name: users users_username_key209; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key209 UNIQUE (username);


--
-- Name: users users_username_key21; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key21 UNIQUE (username);


--
-- Name: users users_username_key210; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key210 UNIQUE (username);


--
-- Name: users users_username_key211; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key211 UNIQUE (username);


--
-- Name: users users_username_key212; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key212 UNIQUE (username);


--
-- Name: users users_username_key213; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key213 UNIQUE (username);


--
-- Name: users users_username_key214; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key214 UNIQUE (username);


--
-- Name: users users_username_key215; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key215 UNIQUE (username);


--
-- Name: users users_username_key216; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key216 UNIQUE (username);


--
-- Name: users users_username_key217; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key217 UNIQUE (username);


--
-- Name: users users_username_key218; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key218 UNIQUE (username);


--
-- Name: users users_username_key219; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key219 UNIQUE (username);


--
-- Name: users users_username_key22; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key22 UNIQUE (username);


--
-- Name: users users_username_key220; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key220 UNIQUE (username);


--
-- Name: users users_username_key221; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key221 UNIQUE (username);


--
-- Name: users users_username_key222; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key222 UNIQUE (username);


--
-- Name: users users_username_key223; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key223 UNIQUE (username);


--
-- Name: users users_username_key224; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key224 UNIQUE (username);


--
-- Name: users users_username_key225; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key225 UNIQUE (username);


--
-- Name: users users_username_key226; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key226 UNIQUE (username);


--
-- Name: users users_username_key227; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key227 UNIQUE (username);


--
-- Name: users users_username_key228; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key228 UNIQUE (username);


--
-- Name: users users_username_key229; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key229 UNIQUE (username);


--
-- Name: users users_username_key23; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key23 UNIQUE (username);


--
-- Name: users users_username_key230; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key230 UNIQUE (username);


--
-- Name: users users_username_key231; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key231 UNIQUE (username);


--
-- Name: users users_username_key232; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key232 UNIQUE (username);


--
-- Name: users users_username_key233; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key233 UNIQUE (username);


--
-- Name: users users_username_key234; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key234 UNIQUE (username);


--
-- Name: users users_username_key235; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key235 UNIQUE (username);


--
-- Name: users users_username_key236; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key236 UNIQUE (username);


--
-- Name: users users_username_key237; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key237 UNIQUE (username);


--
-- Name: users users_username_key238; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key238 UNIQUE (username);


--
-- Name: users users_username_key239; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key239 UNIQUE (username);


--
-- Name: users users_username_key24; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key24 UNIQUE (username);


--
-- Name: users users_username_key240; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key240 UNIQUE (username);


--
-- Name: users users_username_key241; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key241 UNIQUE (username);


--
-- Name: users users_username_key242; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key242 UNIQUE (username);


--
-- Name: users users_username_key243; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key243 UNIQUE (username);


--
-- Name: users users_username_key244; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key244 UNIQUE (username);


--
-- Name: users users_username_key245; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key245 UNIQUE (username);


--
-- Name: users users_username_key246; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key246 UNIQUE (username);


--
-- Name: users users_username_key247; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key247 UNIQUE (username);


--
-- Name: users users_username_key248; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key248 UNIQUE (username);


--
-- Name: users users_username_key249; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key249 UNIQUE (username);


--
-- Name: users users_username_key25; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key25 UNIQUE (username);


--
-- Name: users users_username_key250; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key250 UNIQUE (username);


--
-- Name: users users_username_key251; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key251 UNIQUE (username);


--
-- Name: users users_username_key252; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key252 UNIQUE (username);


--
-- Name: users users_username_key253; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key253 UNIQUE (username);


--
-- Name: users users_username_key254; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key254 UNIQUE (username);


--
-- Name: users users_username_key255; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key255 UNIQUE (username);


--
-- Name: users users_username_key256; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key256 UNIQUE (username);


--
-- Name: users users_username_key257; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key257 UNIQUE (username);


--
-- Name: users users_username_key258; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key258 UNIQUE (username);


--
-- Name: users users_username_key259; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key259 UNIQUE (username);


--
-- Name: users users_username_key26; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key26 UNIQUE (username);


--
-- Name: users users_username_key260; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key260 UNIQUE (username);


--
-- Name: users users_username_key261; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key261 UNIQUE (username);


--
-- Name: users users_username_key262; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key262 UNIQUE (username);


--
-- Name: users users_username_key263; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key263 UNIQUE (username);


--
-- Name: users users_username_key264; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key264 UNIQUE (username);


--
-- Name: users users_username_key265; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key265 UNIQUE (username);


--
-- Name: users users_username_key266; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key266 UNIQUE (username);


--
-- Name: users users_username_key267; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key267 UNIQUE (username);


--
-- Name: users users_username_key268; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key268 UNIQUE (username);


--
-- Name: users users_username_key269; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key269 UNIQUE (username);


--
-- Name: users users_username_key27; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key27 UNIQUE (username);


--
-- Name: users users_username_key270; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key270 UNIQUE (username);


--
-- Name: users users_username_key271; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key271 UNIQUE (username);


--
-- Name: users users_username_key272; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key272 UNIQUE (username);


--
-- Name: users users_username_key273; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key273 UNIQUE (username);


--
-- Name: users users_username_key274; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key274 UNIQUE (username);


--
-- Name: users users_username_key275; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key275 UNIQUE (username);


--
-- Name: users users_username_key276; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key276 UNIQUE (username);


--
-- Name: users users_username_key277; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key277 UNIQUE (username);


--
-- Name: users users_username_key278; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key278 UNIQUE (username);


--
-- Name: users users_username_key279; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key279 UNIQUE (username);


--
-- Name: users users_username_key28; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key28 UNIQUE (username);


--
-- Name: users users_username_key280; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key280 UNIQUE (username);


--
-- Name: users users_username_key281; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key281 UNIQUE (username);


--
-- Name: users users_username_key282; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key282 UNIQUE (username);


--
-- Name: users users_username_key283; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key283 UNIQUE (username);


--
-- Name: users users_username_key284; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key284 UNIQUE (username);


--
-- Name: users users_username_key285; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key285 UNIQUE (username);


--
-- Name: users users_username_key286; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key286 UNIQUE (username);


--
-- Name: users users_username_key287; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key287 UNIQUE (username);


--
-- Name: users users_username_key288; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key288 UNIQUE (username);


--
-- Name: users users_username_key289; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key289 UNIQUE (username);


--
-- Name: users users_username_key29; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key29 UNIQUE (username);


--
-- Name: users users_username_key290; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key290 UNIQUE (username);


--
-- Name: users users_username_key291; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key291 UNIQUE (username);


--
-- Name: users users_username_key292; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key292 UNIQUE (username);


--
-- Name: users users_username_key293; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key293 UNIQUE (username);


--
-- Name: users users_username_key294; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key294 UNIQUE (username);


--
-- Name: users users_username_key295; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key295 UNIQUE (username);


--
-- Name: users users_username_key296; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key296 UNIQUE (username);


--
-- Name: users users_username_key297; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key297 UNIQUE (username);


--
-- Name: users users_username_key298; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key298 UNIQUE (username);


--
-- Name: users users_username_key299; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key299 UNIQUE (username);


--
-- Name: users users_username_key3; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key3 UNIQUE (username);


--
-- Name: users users_username_key30; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key30 UNIQUE (username);


--
-- Name: users users_username_key300; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key300 UNIQUE (username);


--
-- Name: users users_username_key301; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key301 UNIQUE (username);


--
-- Name: users users_username_key302; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key302 UNIQUE (username);


--
-- Name: users users_username_key303; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key303 UNIQUE (username);


--
-- Name: users users_username_key304; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key304 UNIQUE (username);


--
-- Name: users users_username_key305; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key305 UNIQUE (username);


--
-- Name: users users_username_key306; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key306 UNIQUE (username);


--
-- Name: users users_username_key307; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key307 UNIQUE (username);


--
-- Name: users users_username_key308; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key308 UNIQUE (username);


--
-- Name: users users_username_key309; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key309 UNIQUE (username);


--
-- Name: users users_username_key31; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key31 UNIQUE (username);


--
-- Name: users users_username_key310; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key310 UNIQUE (username);


--
-- Name: users users_username_key311; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key311 UNIQUE (username);


--
-- Name: users users_username_key312; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key312 UNIQUE (username);


--
-- Name: users users_username_key313; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key313 UNIQUE (username);


--
-- Name: users users_username_key314; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key314 UNIQUE (username);


--
-- Name: users users_username_key315; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key315 UNIQUE (username);


--
-- Name: users users_username_key316; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key316 UNIQUE (username);


--
-- Name: users users_username_key317; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key317 UNIQUE (username);


--
-- Name: users users_username_key318; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key318 UNIQUE (username);


--
-- Name: users users_username_key319; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key319 UNIQUE (username);


--
-- Name: users users_username_key32; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key32 UNIQUE (username);


--
-- Name: users users_username_key320; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key320 UNIQUE (username);


--
-- Name: users users_username_key321; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key321 UNIQUE (username);


--
-- Name: users users_username_key322; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key322 UNIQUE (username);


--
-- Name: users users_username_key323; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key323 UNIQUE (username);


--
-- Name: users users_username_key324; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key324 UNIQUE (username);


--
-- Name: users users_username_key325; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key325 UNIQUE (username);


--
-- Name: users users_username_key326; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key326 UNIQUE (username);


--
-- Name: users users_username_key327; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key327 UNIQUE (username);


--
-- Name: users users_username_key328; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key328 UNIQUE (username);


--
-- Name: users users_username_key329; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key329 UNIQUE (username);


--
-- Name: users users_username_key33; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key33 UNIQUE (username);


--
-- Name: users users_username_key330; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key330 UNIQUE (username);


--
-- Name: users users_username_key331; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key331 UNIQUE (username);


--
-- Name: users users_username_key332; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key332 UNIQUE (username);


--
-- Name: users users_username_key333; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key333 UNIQUE (username);


--
-- Name: users users_username_key334; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key334 UNIQUE (username);


--
-- Name: users users_username_key335; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key335 UNIQUE (username);


--
-- Name: users users_username_key336; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key336 UNIQUE (username);


--
-- Name: users users_username_key337; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key337 UNIQUE (username);


--
-- Name: users users_username_key338; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key338 UNIQUE (username);


--
-- Name: users users_username_key339; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key339 UNIQUE (username);


--
-- Name: users users_username_key34; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key34 UNIQUE (username);


--
-- Name: users users_username_key340; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key340 UNIQUE (username);


--
-- Name: users users_username_key341; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key341 UNIQUE (username);


--
-- Name: users users_username_key342; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key342 UNIQUE (username);


--
-- Name: users users_username_key343; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key343 UNIQUE (username);


--
-- Name: users users_username_key344; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key344 UNIQUE (username);


--
-- Name: users users_username_key345; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key345 UNIQUE (username);


--
-- Name: users users_username_key346; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key346 UNIQUE (username);


--
-- Name: users users_username_key347; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key347 UNIQUE (username);


--
-- Name: users users_username_key348; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key348 UNIQUE (username);


--
-- Name: users users_username_key349; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key349 UNIQUE (username);


--
-- Name: users users_username_key35; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key35 UNIQUE (username);


--
-- Name: users users_username_key350; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key350 UNIQUE (username);


--
-- Name: users users_username_key351; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key351 UNIQUE (username);


--
-- Name: users users_username_key352; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key352 UNIQUE (username);


--
-- Name: users users_username_key353; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key353 UNIQUE (username);


--
-- Name: users users_username_key354; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key354 UNIQUE (username);


--
-- Name: users users_username_key355; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key355 UNIQUE (username);


--
-- Name: users users_username_key356; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key356 UNIQUE (username);


--
-- Name: users users_username_key357; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key357 UNIQUE (username);


--
-- Name: users users_username_key358; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key358 UNIQUE (username);


--
-- Name: users users_username_key359; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key359 UNIQUE (username);


--
-- Name: users users_username_key36; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key36 UNIQUE (username);


--
-- Name: users users_username_key360; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key360 UNIQUE (username);


--
-- Name: users users_username_key361; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key361 UNIQUE (username);


--
-- Name: users users_username_key362; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key362 UNIQUE (username);


--
-- Name: users users_username_key363; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key363 UNIQUE (username);


--
-- Name: users users_username_key364; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key364 UNIQUE (username);


--
-- Name: users users_username_key365; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key365 UNIQUE (username);


--
-- Name: users users_username_key366; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key366 UNIQUE (username);


--
-- Name: users users_username_key367; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key367 UNIQUE (username);


--
-- Name: users users_username_key368; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key368 UNIQUE (username);


--
-- Name: users users_username_key369; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key369 UNIQUE (username);


--
-- Name: users users_username_key37; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key37 UNIQUE (username);


--
-- Name: users users_username_key370; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key370 UNIQUE (username);


--
-- Name: users users_username_key371; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key371 UNIQUE (username);


--
-- Name: users users_username_key372; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key372 UNIQUE (username);


--
-- Name: users users_username_key373; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key373 UNIQUE (username);


--
-- Name: users users_username_key374; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key374 UNIQUE (username);


--
-- Name: users users_username_key375; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key375 UNIQUE (username);


--
-- Name: users users_username_key376; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key376 UNIQUE (username);


--
-- Name: users users_username_key377; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key377 UNIQUE (username);


--
-- Name: users users_username_key378; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key378 UNIQUE (username);


--
-- Name: users users_username_key379; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key379 UNIQUE (username);


--
-- Name: users users_username_key38; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key38 UNIQUE (username);


--
-- Name: users users_username_key380; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key380 UNIQUE (username);


--
-- Name: users users_username_key381; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key381 UNIQUE (username);


--
-- Name: users users_username_key382; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key382 UNIQUE (username);


--
-- Name: users users_username_key383; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key383 UNIQUE (username);


--
-- Name: users users_username_key384; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key384 UNIQUE (username);


--
-- Name: users users_username_key385; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key385 UNIQUE (username);


--
-- Name: users users_username_key386; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key386 UNIQUE (username);


--
-- Name: users users_username_key387; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key387 UNIQUE (username);


--
-- Name: users users_username_key388; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key388 UNIQUE (username);


--
-- Name: users users_username_key389; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key389 UNIQUE (username);


--
-- Name: users users_username_key39; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key39 UNIQUE (username);


--
-- Name: users users_username_key390; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key390 UNIQUE (username);


--
-- Name: users users_username_key391; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key391 UNIQUE (username);


--
-- Name: users users_username_key392; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key392 UNIQUE (username);


--
-- Name: users users_username_key393; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key393 UNIQUE (username);


--
-- Name: users users_username_key394; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key394 UNIQUE (username);


--
-- Name: users users_username_key395; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key395 UNIQUE (username);


--
-- Name: users users_username_key396; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key396 UNIQUE (username);


--
-- Name: users users_username_key397; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key397 UNIQUE (username);


--
-- Name: users users_username_key398; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key398 UNIQUE (username);


--
-- Name: users users_username_key399; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key399 UNIQUE (username);


--
-- Name: users users_username_key4; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key4 UNIQUE (username);


--
-- Name: users users_username_key40; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key40 UNIQUE (username);


--
-- Name: users users_username_key400; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key400 UNIQUE (username);


--
-- Name: users users_username_key401; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key401 UNIQUE (username);


--
-- Name: users users_username_key402; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key402 UNIQUE (username);


--
-- Name: users users_username_key403; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key403 UNIQUE (username);


--
-- Name: users users_username_key404; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key404 UNIQUE (username);


--
-- Name: users users_username_key405; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key405 UNIQUE (username);


--
-- Name: users users_username_key406; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key406 UNIQUE (username);


--
-- Name: users users_username_key407; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key407 UNIQUE (username);


--
-- Name: users users_username_key408; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key408 UNIQUE (username);


--
-- Name: users users_username_key409; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key409 UNIQUE (username);


--
-- Name: users users_username_key41; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key41 UNIQUE (username);


--
-- Name: users users_username_key410; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key410 UNIQUE (username);


--
-- Name: users users_username_key411; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key411 UNIQUE (username);


--
-- Name: users users_username_key412; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key412 UNIQUE (username);


--
-- Name: users users_username_key413; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key413 UNIQUE (username);


--
-- Name: users users_username_key414; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key414 UNIQUE (username);


--
-- Name: users users_username_key415; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key415 UNIQUE (username);


--
-- Name: users users_username_key416; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key416 UNIQUE (username);


--
-- Name: users users_username_key417; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key417 UNIQUE (username);


--
-- Name: users users_username_key418; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key418 UNIQUE (username);


--
-- Name: users users_username_key419; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key419 UNIQUE (username);


--
-- Name: users users_username_key42; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key42 UNIQUE (username);


--
-- Name: users users_username_key420; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key420 UNIQUE (username);


--
-- Name: users users_username_key421; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key421 UNIQUE (username);


--
-- Name: users users_username_key422; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key422 UNIQUE (username);


--
-- Name: users users_username_key423; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key423 UNIQUE (username);


--
-- Name: users users_username_key424; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key424 UNIQUE (username);


--
-- Name: users users_username_key425; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key425 UNIQUE (username);


--
-- Name: users users_username_key426; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key426 UNIQUE (username);


--
-- Name: users users_username_key427; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key427 UNIQUE (username);


--
-- Name: users users_username_key428; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key428 UNIQUE (username);


--
-- Name: users users_username_key429; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key429 UNIQUE (username);


--
-- Name: users users_username_key43; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key43 UNIQUE (username);


--
-- Name: users users_username_key430; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key430 UNIQUE (username);


--
-- Name: users users_username_key431; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key431 UNIQUE (username);


--
-- Name: users users_username_key432; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key432 UNIQUE (username);


--
-- Name: users users_username_key433; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key433 UNIQUE (username);


--
-- Name: users users_username_key434; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key434 UNIQUE (username);


--
-- Name: users users_username_key435; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key435 UNIQUE (username);


--
-- Name: users users_username_key436; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key436 UNIQUE (username);


--
-- Name: users users_username_key437; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key437 UNIQUE (username);


--
-- Name: users users_username_key438; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key438 UNIQUE (username);


--
-- Name: users users_username_key439; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key439 UNIQUE (username);


--
-- Name: users users_username_key44; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key44 UNIQUE (username);


--
-- Name: users users_username_key440; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key440 UNIQUE (username);


--
-- Name: users users_username_key441; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key441 UNIQUE (username);


--
-- Name: users users_username_key442; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key442 UNIQUE (username);


--
-- Name: users users_username_key443; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key443 UNIQUE (username);


--
-- Name: users users_username_key444; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key444 UNIQUE (username);


--
-- Name: users users_username_key445; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key445 UNIQUE (username);


--
-- Name: users users_username_key446; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key446 UNIQUE (username);


--
-- Name: users users_username_key447; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key447 UNIQUE (username);


--
-- Name: users users_username_key448; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key448 UNIQUE (username);


--
-- Name: users users_username_key449; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key449 UNIQUE (username);


--
-- Name: users users_username_key45; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key45 UNIQUE (username);


--
-- Name: users users_username_key450; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key450 UNIQUE (username);


--
-- Name: users users_username_key451; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key451 UNIQUE (username);


--
-- Name: users users_username_key452; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key452 UNIQUE (username);


--
-- Name: users users_username_key453; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key453 UNIQUE (username);


--
-- Name: users users_username_key454; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key454 UNIQUE (username);


--
-- Name: users users_username_key455; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key455 UNIQUE (username);


--
-- Name: users users_username_key456; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key456 UNIQUE (username);


--
-- Name: users users_username_key457; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key457 UNIQUE (username);


--
-- Name: users users_username_key458; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key458 UNIQUE (username);


--
-- Name: users users_username_key459; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key459 UNIQUE (username);


--
-- Name: users users_username_key46; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key46 UNIQUE (username);


--
-- Name: users users_username_key460; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key460 UNIQUE (username);


--
-- Name: users users_username_key461; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key461 UNIQUE (username);


--
-- Name: users users_username_key462; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key462 UNIQUE (username);


--
-- Name: users users_username_key463; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key463 UNIQUE (username);


--
-- Name: users users_username_key464; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key464 UNIQUE (username);


--
-- Name: users users_username_key465; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key465 UNIQUE (username);


--
-- Name: users users_username_key466; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key466 UNIQUE (username);


--
-- Name: users users_username_key467; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key467 UNIQUE (username);


--
-- Name: users users_username_key468; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key468 UNIQUE (username);


--
-- Name: users users_username_key469; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key469 UNIQUE (username);


--
-- Name: users users_username_key47; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key47 UNIQUE (username);


--
-- Name: users users_username_key470; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key470 UNIQUE (username);


--
-- Name: users users_username_key471; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key471 UNIQUE (username);


--
-- Name: users users_username_key472; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key472 UNIQUE (username);


--
-- Name: users users_username_key473; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key473 UNIQUE (username);


--
-- Name: users users_username_key474; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key474 UNIQUE (username);


--
-- Name: users users_username_key475; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key475 UNIQUE (username);


--
-- Name: users users_username_key476; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key476 UNIQUE (username);


--
-- Name: users users_username_key477; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key477 UNIQUE (username);


--
-- Name: users users_username_key478; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key478 UNIQUE (username);


--
-- Name: users users_username_key479; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key479 UNIQUE (username);


--
-- Name: users users_username_key48; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key48 UNIQUE (username);


--
-- Name: users users_username_key480; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key480 UNIQUE (username);


--
-- Name: users users_username_key481; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key481 UNIQUE (username);


--
-- Name: users users_username_key482; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key482 UNIQUE (username);


--
-- Name: users users_username_key483; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key483 UNIQUE (username);


--
-- Name: users users_username_key484; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key484 UNIQUE (username);


--
-- Name: users users_username_key485; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key485 UNIQUE (username);


--
-- Name: users users_username_key486; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key486 UNIQUE (username);


--
-- Name: users users_username_key487; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key487 UNIQUE (username);


--
-- Name: users users_username_key488; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key488 UNIQUE (username);


--
-- Name: users users_username_key489; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key489 UNIQUE (username);


--
-- Name: users users_username_key49; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key49 UNIQUE (username);


--
-- Name: users users_username_key490; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key490 UNIQUE (username);


--
-- Name: users users_username_key491; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key491 UNIQUE (username);


--
-- Name: users users_username_key492; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key492 UNIQUE (username);


--
-- Name: users users_username_key493; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key493 UNIQUE (username);


--
-- Name: users users_username_key494; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key494 UNIQUE (username);


--
-- Name: users users_username_key495; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key495 UNIQUE (username);


--
-- Name: users users_username_key496; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key496 UNIQUE (username);


--
-- Name: users users_username_key497; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key497 UNIQUE (username);


--
-- Name: users users_username_key498; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key498 UNIQUE (username);


--
-- Name: users users_username_key499; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key499 UNIQUE (username);


--
-- Name: users users_username_key5; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key5 UNIQUE (username);


--
-- Name: users users_username_key50; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key50 UNIQUE (username);


--
-- Name: users users_username_key500; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key500 UNIQUE (username);


--
-- Name: users users_username_key501; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key501 UNIQUE (username);


--
-- Name: users users_username_key502; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key502 UNIQUE (username);


--
-- Name: users users_username_key503; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key503 UNIQUE (username);


--
-- Name: users users_username_key504; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key504 UNIQUE (username);


--
-- Name: users users_username_key505; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key505 UNIQUE (username);


--
-- Name: users users_username_key506; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key506 UNIQUE (username);


--
-- Name: users users_username_key507; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key507 UNIQUE (username);


--
-- Name: users users_username_key508; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key508 UNIQUE (username);


--
-- Name: users users_username_key509; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key509 UNIQUE (username);


--
-- Name: users users_username_key51; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key51 UNIQUE (username);


--
-- Name: users users_username_key510; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key510 UNIQUE (username);


--
-- Name: users users_username_key511; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key511 UNIQUE (username);


--
-- Name: users users_username_key512; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key512 UNIQUE (username);


--
-- Name: users users_username_key513; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key513 UNIQUE (username);


--
-- Name: users users_username_key514; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key514 UNIQUE (username);


--
-- Name: users users_username_key515; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key515 UNIQUE (username);


--
-- Name: users users_username_key516; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key516 UNIQUE (username);


--
-- Name: users users_username_key517; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key517 UNIQUE (username);


--
-- Name: users users_username_key518; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key518 UNIQUE (username);


--
-- Name: users users_username_key519; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key519 UNIQUE (username);


--
-- Name: users users_username_key52; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key52 UNIQUE (username);


--
-- Name: users users_username_key520; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key520 UNIQUE (username);


--
-- Name: users users_username_key521; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key521 UNIQUE (username);


--
-- Name: users users_username_key522; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key522 UNIQUE (username);


--
-- Name: users users_username_key523; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key523 UNIQUE (username);


--
-- Name: users users_username_key524; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key524 UNIQUE (username);


--
-- Name: users users_username_key525; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key525 UNIQUE (username);


--
-- Name: users users_username_key526; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key526 UNIQUE (username);


--
-- Name: users users_username_key527; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key527 UNIQUE (username);


--
-- Name: users users_username_key528; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key528 UNIQUE (username);


--
-- Name: users users_username_key529; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key529 UNIQUE (username);


--
-- Name: users users_username_key53; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key53 UNIQUE (username);


--
-- Name: users users_username_key530; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key530 UNIQUE (username);


--
-- Name: users users_username_key531; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key531 UNIQUE (username);


--
-- Name: users users_username_key532; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key532 UNIQUE (username);


--
-- Name: users users_username_key533; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key533 UNIQUE (username);


--
-- Name: users users_username_key534; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key534 UNIQUE (username);


--
-- Name: users users_username_key535; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key535 UNIQUE (username);


--
-- Name: users users_username_key536; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key536 UNIQUE (username);


--
-- Name: users users_username_key537; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key537 UNIQUE (username);


--
-- Name: users users_username_key538; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key538 UNIQUE (username);


--
-- Name: users users_username_key539; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key539 UNIQUE (username);


--
-- Name: users users_username_key54; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key54 UNIQUE (username);


--
-- Name: users users_username_key540; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key540 UNIQUE (username);


--
-- Name: users users_username_key541; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key541 UNIQUE (username);


--
-- Name: users users_username_key542; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key542 UNIQUE (username);


--
-- Name: users users_username_key543; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key543 UNIQUE (username);


--
-- Name: users users_username_key544; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key544 UNIQUE (username);


--
-- Name: users users_username_key545; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key545 UNIQUE (username);


--
-- Name: users users_username_key546; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key546 UNIQUE (username);


--
-- Name: users users_username_key547; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key547 UNIQUE (username);


--
-- Name: users users_username_key548; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key548 UNIQUE (username);


--
-- Name: users users_username_key549; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key549 UNIQUE (username);


--
-- Name: users users_username_key55; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key55 UNIQUE (username);


--
-- Name: users users_username_key550; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key550 UNIQUE (username);


--
-- Name: users users_username_key551; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key551 UNIQUE (username);


--
-- Name: users users_username_key552; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key552 UNIQUE (username);


--
-- Name: users users_username_key553; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key553 UNIQUE (username);


--
-- Name: users users_username_key554; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key554 UNIQUE (username);


--
-- Name: users users_username_key555; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key555 UNIQUE (username);


--
-- Name: users users_username_key556; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key556 UNIQUE (username);


--
-- Name: users users_username_key557; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key557 UNIQUE (username);


--
-- Name: users users_username_key558; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key558 UNIQUE (username);


--
-- Name: users users_username_key559; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key559 UNIQUE (username);


--
-- Name: users users_username_key56; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key56 UNIQUE (username);


--
-- Name: users users_username_key560; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key560 UNIQUE (username);


--
-- Name: users users_username_key561; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key561 UNIQUE (username);


--
-- Name: users users_username_key562; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key562 UNIQUE (username);


--
-- Name: users users_username_key563; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key563 UNIQUE (username);


--
-- Name: users users_username_key564; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key564 UNIQUE (username);


--
-- Name: users users_username_key565; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key565 UNIQUE (username);


--
-- Name: users users_username_key566; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key566 UNIQUE (username);


--
-- Name: users users_username_key567; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key567 UNIQUE (username);


--
-- Name: users users_username_key568; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key568 UNIQUE (username);


--
-- Name: users users_username_key569; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key569 UNIQUE (username);


--
-- Name: users users_username_key57; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key57 UNIQUE (username);


--
-- Name: users users_username_key570; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key570 UNIQUE (username);


--
-- Name: users users_username_key571; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key571 UNIQUE (username);


--
-- Name: users users_username_key572; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key572 UNIQUE (username);


--
-- Name: users users_username_key573; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key573 UNIQUE (username);


--
-- Name: users users_username_key574; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key574 UNIQUE (username);


--
-- Name: users users_username_key575; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key575 UNIQUE (username);


--
-- Name: users users_username_key576; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key576 UNIQUE (username);


--
-- Name: users users_username_key577; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key577 UNIQUE (username);


--
-- Name: users users_username_key578; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key578 UNIQUE (username);


--
-- Name: users users_username_key579; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key579 UNIQUE (username);


--
-- Name: users users_username_key58; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key58 UNIQUE (username);


--
-- Name: users users_username_key580; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key580 UNIQUE (username);


--
-- Name: users users_username_key581; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key581 UNIQUE (username);


--
-- Name: users users_username_key582; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key582 UNIQUE (username);


--
-- Name: users users_username_key583; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key583 UNIQUE (username);


--
-- Name: users users_username_key584; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key584 UNIQUE (username);


--
-- Name: users users_username_key585; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key585 UNIQUE (username);


--
-- Name: users users_username_key586; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key586 UNIQUE (username);


--
-- Name: users users_username_key587; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key587 UNIQUE (username);


--
-- Name: users users_username_key588; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key588 UNIQUE (username);


--
-- Name: users users_username_key589; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key589 UNIQUE (username);


--
-- Name: users users_username_key59; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key59 UNIQUE (username);


--
-- Name: users users_username_key590; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key590 UNIQUE (username);


--
-- Name: users users_username_key591; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key591 UNIQUE (username);


--
-- Name: users users_username_key592; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key592 UNIQUE (username);


--
-- Name: users users_username_key593; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key593 UNIQUE (username);


--
-- Name: users users_username_key594; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key594 UNIQUE (username);


--
-- Name: users users_username_key595; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key595 UNIQUE (username);


--
-- Name: users users_username_key596; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key596 UNIQUE (username);


--
-- Name: users users_username_key597; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key597 UNIQUE (username);


--
-- Name: users users_username_key598; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key598 UNIQUE (username);


--
-- Name: users users_username_key599; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key599 UNIQUE (username);


--
-- Name: users users_username_key6; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key6 UNIQUE (username);


--
-- Name: users users_username_key60; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key60 UNIQUE (username);


--
-- Name: users users_username_key600; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key600 UNIQUE (username);


--
-- Name: users users_username_key601; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key601 UNIQUE (username);


--
-- Name: users users_username_key602; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key602 UNIQUE (username);


--
-- Name: users users_username_key603; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key603 UNIQUE (username);


--
-- Name: users users_username_key604; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key604 UNIQUE (username);


--
-- Name: users users_username_key605; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key605 UNIQUE (username);


--
-- Name: users users_username_key606; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key606 UNIQUE (username);


--
-- Name: users users_username_key607; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key607 UNIQUE (username);


--
-- Name: users users_username_key608; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key608 UNIQUE (username);


--
-- Name: users users_username_key609; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key609 UNIQUE (username);


--
-- Name: users users_username_key61; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key61 UNIQUE (username);


--
-- Name: users users_username_key610; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key610 UNIQUE (username);


--
-- Name: users users_username_key611; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key611 UNIQUE (username);


--
-- Name: users users_username_key612; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key612 UNIQUE (username);


--
-- Name: users users_username_key613; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key613 UNIQUE (username);


--
-- Name: users users_username_key614; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key614 UNIQUE (username);


--
-- Name: users users_username_key615; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key615 UNIQUE (username);


--
-- Name: users users_username_key616; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key616 UNIQUE (username);


--
-- Name: users users_username_key617; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key617 UNIQUE (username);


--
-- Name: users users_username_key618; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key618 UNIQUE (username);


--
-- Name: users users_username_key619; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key619 UNIQUE (username);


--
-- Name: users users_username_key62; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key62 UNIQUE (username);


--
-- Name: users users_username_key620; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key620 UNIQUE (username);


--
-- Name: users users_username_key621; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key621 UNIQUE (username);


--
-- Name: users users_username_key622; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key622 UNIQUE (username);


--
-- Name: users users_username_key623; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key623 UNIQUE (username);


--
-- Name: users users_username_key624; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key624 UNIQUE (username);


--
-- Name: users users_username_key625; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key625 UNIQUE (username);


--
-- Name: users users_username_key626; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key626 UNIQUE (username);


--
-- Name: users users_username_key627; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key627 UNIQUE (username);


--
-- Name: users users_username_key628; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key628 UNIQUE (username);


--
-- Name: users users_username_key629; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key629 UNIQUE (username);


--
-- Name: users users_username_key63; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key63 UNIQUE (username);


--
-- Name: users users_username_key630; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key630 UNIQUE (username);


--
-- Name: users users_username_key631; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key631 UNIQUE (username);


--
-- Name: users users_username_key632; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key632 UNIQUE (username);


--
-- Name: users users_username_key633; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key633 UNIQUE (username);


--
-- Name: users users_username_key634; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key634 UNIQUE (username);


--
-- Name: users users_username_key635; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key635 UNIQUE (username);


--
-- Name: users users_username_key636; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key636 UNIQUE (username);


--
-- Name: users users_username_key637; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key637 UNIQUE (username);


--
-- Name: users users_username_key638; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key638 UNIQUE (username);


--
-- Name: users users_username_key639; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key639 UNIQUE (username);


--
-- Name: users users_username_key64; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key64 UNIQUE (username);


--
-- Name: users users_username_key640; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key640 UNIQUE (username);


--
-- Name: users users_username_key641; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key641 UNIQUE (username);


--
-- Name: users users_username_key642; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key642 UNIQUE (username);


--
-- Name: users users_username_key643; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key643 UNIQUE (username);


--
-- Name: users users_username_key644; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key644 UNIQUE (username);


--
-- Name: users users_username_key645; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key645 UNIQUE (username);


--
-- Name: users users_username_key646; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key646 UNIQUE (username);


--
-- Name: users users_username_key647; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key647 UNIQUE (username);


--
-- Name: users users_username_key648; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key648 UNIQUE (username);


--
-- Name: users users_username_key649; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key649 UNIQUE (username);


--
-- Name: users users_username_key65; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key65 UNIQUE (username);


--
-- Name: users users_username_key650; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key650 UNIQUE (username);


--
-- Name: users users_username_key651; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key651 UNIQUE (username);


--
-- Name: users users_username_key652; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key652 UNIQUE (username);


--
-- Name: users users_username_key653; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key653 UNIQUE (username);


--
-- Name: users users_username_key654; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key654 UNIQUE (username);


--
-- Name: users users_username_key655; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key655 UNIQUE (username);


--
-- Name: users users_username_key656; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key656 UNIQUE (username);


--
-- Name: users users_username_key657; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key657 UNIQUE (username);


--
-- Name: users users_username_key658; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key658 UNIQUE (username);


--
-- Name: users users_username_key659; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key659 UNIQUE (username);


--
-- Name: users users_username_key66; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key66 UNIQUE (username);


--
-- Name: users users_username_key660; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key660 UNIQUE (username);


--
-- Name: users users_username_key661; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key661 UNIQUE (username);


--
-- Name: users users_username_key662; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key662 UNIQUE (username);


--
-- Name: users users_username_key663; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key663 UNIQUE (username);


--
-- Name: users users_username_key664; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key664 UNIQUE (username);


--
-- Name: users users_username_key665; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key665 UNIQUE (username);


--
-- Name: users users_username_key666; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key666 UNIQUE (username);


--
-- Name: users users_username_key667; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key667 UNIQUE (username);


--
-- Name: users users_username_key668; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key668 UNIQUE (username);


--
-- Name: users users_username_key669; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key669 UNIQUE (username);


--
-- Name: users users_username_key67; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key67 UNIQUE (username);


--
-- Name: users users_username_key670; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key670 UNIQUE (username);


--
-- Name: users users_username_key671; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key671 UNIQUE (username);


--
-- Name: users users_username_key672; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key672 UNIQUE (username);


--
-- Name: users users_username_key673; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key673 UNIQUE (username);


--
-- Name: users users_username_key674; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key674 UNIQUE (username);


--
-- Name: users users_username_key675; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key675 UNIQUE (username);


--
-- Name: users users_username_key676; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key676 UNIQUE (username);


--
-- Name: users users_username_key677; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key677 UNIQUE (username);


--
-- Name: users users_username_key678; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key678 UNIQUE (username);


--
-- Name: users users_username_key679; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key679 UNIQUE (username);


--
-- Name: users users_username_key68; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key68 UNIQUE (username);


--
-- Name: users users_username_key680; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key680 UNIQUE (username);


--
-- Name: users users_username_key681; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key681 UNIQUE (username);


--
-- Name: users users_username_key682; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key682 UNIQUE (username);


--
-- Name: users users_username_key683; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key683 UNIQUE (username);


--
-- Name: users users_username_key684; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key684 UNIQUE (username);


--
-- Name: users users_username_key685; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key685 UNIQUE (username);


--
-- Name: users users_username_key686; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key686 UNIQUE (username);


--
-- Name: users users_username_key687; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key687 UNIQUE (username);


--
-- Name: users users_username_key688; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key688 UNIQUE (username);


--
-- Name: users users_username_key689; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key689 UNIQUE (username);


--
-- Name: users users_username_key69; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key69 UNIQUE (username);


--
-- Name: users users_username_key690; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key690 UNIQUE (username);


--
-- Name: users users_username_key691; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key691 UNIQUE (username);


--
-- Name: users users_username_key692; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key692 UNIQUE (username);


--
-- Name: users users_username_key693; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key693 UNIQUE (username);


--
-- Name: users users_username_key694; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key694 UNIQUE (username);


--
-- Name: users users_username_key695; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key695 UNIQUE (username);


--
-- Name: users users_username_key696; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key696 UNIQUE (username);


--
-- Name: users users_username_key697; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key697 UNIQUE (username);


--
-- Name: users users_username_key698; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key698 UNIQUE (username);


--
-- Name: users users_username_key699; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key699 UNIQUE (username);


--
-- Name: users users_username_key7; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key7 UNIQUE (username);


--
-- Name: users users_username_key70; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key70 UNIQUE (username);


--
-- Name: users users_username_key700; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key700 UNIQUE (username);


--
-- Name: users users_username_key701; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key701 UNIQUE (username);


--
-- Name: users users_username_key702; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key702 UNIQUE (username);


--
-- Name: users users_username_key703; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key703 UNIQUE (username);


--
-- Name: users users_username_key704; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key704 UNIQUE (username);


--
-- Name: users users_username_key705; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key705 UNIQUE (username);


--
-- Name: users users_username_key706; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key706 UNIQUE (username);


--
-- Name: users users_username_key707; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key707 UNIQUE (username);


--
-- Name: users users_username_key708; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key708 UNIQUE (username);


--
-- Name: users users_username_key709; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key709 UNIQUE (username);


--
-- Name: users users_username_key71; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key71 UNIQUE (username);


--
-- Name: users users_username_key710; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key710 UNIQUE (username);


--
-- Name: users users_username_key711; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key711 UNIQUE (username);


--
-- Name: users users_username_key712; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key712 UNIQUE (username);


--
-- Name: users users_username_key713; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key713 UNIQUE (username);


--
-- Name: users users_username_key714; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key714 UNIQUE (username);


--
-- Name: users users_username_key715; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key715 UNIQUE (username);


--
-- Name: users users_username_key716; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key716 UNIQUE (username);


--
-- Name: users users_username_key717; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key717 UNIQUE (username);


--
-- Name: users users_username_key718; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key718 UNIQUE (username);


--
-- Name: users users_username_key719; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key719 UNIQUE (username);


--
-- Name: users users_username_key72; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key72 UNIQUE (username);


--
-- Name: users users_username_key720; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key720 UNIQUE (username);


--
-- Name: users users_username_key721; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key721 UNIQUE (username);


--
-- Name: users users_username_key722; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key722 UNIQUE (username);


--
-- Name: users users_username_key723; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key723 UNIQUE (username);


--
-- Name: users users_username_key724; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key724 UNIQUE (username);


--
-- Name: users users_username_key725; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key725 UNIQUE (username);


--
-- Name: users users_username_key726; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key726 UNIQUE (username);


--
-- Name: users users_username_key727; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key727 UNIQUE (username);


--
-- Name: users users_username_key728; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key728 UNIQUE (username);


--
-- Name: users users_username_key729; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key729 UNIQUE (username);


--
-- Name: users users_username_key73; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key73 UNIQUE (username);


--
-- Name: users users_username_key730; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key730 UNIQUE (username);


--
-- Name: users users_username_key731; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key731 UNIQUE (username);


--
-- Name: users users_username_key732; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key732 UNIQUE (username);


--
-- Name: users users_username_key733; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key733 UNIQUE (username);


--
-- Name: users users_username_key734; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key734 UNIQUE (username);


--
-- Name: users users_username_key735; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key735 UNIQUE (username);


--
-- Name: users users_username_key736; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key736 UNIQUE (username);


--
-- Name: users users_username_key737; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key737 UNIQUE (username);


--
-- Name: users users_username_key738; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key738 UNIQUE (username);


--
-- Name: users users_username_key739; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key739 UNIQUE (username);


--
-- Name: users users_username_key74; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key74 UNIQUE (username);


--
-- Name: users users_username_key740; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key740 UNIQUE (username);


--
-- Name: users users_username_key741; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key741 UNIQUE (username);


--
-- Name: users users_username_key742; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key742 UNIQUE (username);


--
-- Name: users users_username_key743; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key743 UNIQUE (username);


--
-- Name: users users_username_key744; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key744 UNIQUE (username);


--
-- Name: users users_username_key745; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key745 UNIQUE (username);


--
-- Name: users users_username_key746; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key746 UNIQUE (username);


--
-- Name: users users_username_key747; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key747 UNIQUE (username);


--
-- Name: users users_username_key748; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key748 UNIQUE (username);


--
-- Name: users users_username_key749; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key749 UNIQUE (username);


--
-- Name: users users_username_key75; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key75 UNIQUE (username);


--
-- Name: users users_username_key750; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key750 UNIQUE (username);


--
-- Name: users users_username_key751; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key751 UNIQUE (username);


--
-- Name: users users_username_key752; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key752 UNIQUE (username);


--
-- Name: users users_username_key753; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key753 UNIQUE (username);


--
-- Name: users users_username_key754; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key754 UNIQUE (username);


--
-- Name: users users_username_key755; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key755 UNIQUE (username);


--
-- Name: users users_username_key756; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key756 UNIQUE (username);


--
-- Name: users users_username_key757; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key757 UNIQUE (username);


--
-- Name: users users_username_key758; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key758 UNIQUE (username);


--
-- Name: users users_username_key759; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key759 UNIQUE (username);


--
-- Name: users users_username_key76; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key76 UNIQUE (username);


--
-- Name: users users_username_key760; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key760 UNIQUE (username);


--
-- Name: users users_username_key761; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key761 UNIQUE (username);


--
-- Name: users users_username_key762; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key762 UNIQUE (username);


--
-- Name: users users_username_key763; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key763 UNIQUE (username);


--
-- Name: users users_username_key764; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key764 UNIQUE (username);


--
-- Name: users users_username_key765; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key765 UNIQUE (username);


--
-- Name: users users_username_key766; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key766 UNIQUE (username);


--
-- Name: users users_username_key767; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key767 UNIQUE (username);


--
-- Name: users users_username_key768; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key768 UNIQUE (username);


--
-- Name: users users_username_key769; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key769 UNIQUE (username);


--
-- Name: users users_username_key77; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key77 UNIQUE (username);


--
-- Name: users users_username_key770; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key770 UNIQUE (username);


--
-- Name: users users_username_key771; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key771 UNIQUE (username);


--
-- Name: users users_username_key772; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key772 UNIQUE (username);


--
-- Name: users users_username_key773; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key773 UNIQUE (username);


--
-- Name: users users_username_key774; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key774 UNIQUE (username);


--
-- Name: users users_username_key775; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key775 UNIQUE (username);


--
-- Name: users users_username_key776; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key776 UNIQUE (username);


--
-- Name: users users_username_key777; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key777 UNIQUE (username);


--
-- Name: users users_username_key778; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key778 UNIQUE (username);


--
-- Name: users users_username_key779; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key779 UNIQUE (username);


--
-- Name: users users_username_key78; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key78 UNIQUE (username);


--
-- Name: users users_username_key780; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key780 UNIQUE (username);


--
-- Name: users users_username_key781; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key781 UNIQUE (username);


--
-- Name: users users_username_key782; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key782 UNIQUE (username);


--
-- Name: users users_username_key783; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key783 UNIQUE (username);


--
-- Name: users users_username_key784; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key784 UNIQUE (username);


--
-- Name: users users_username_key785; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key785 UNIQUE (username);


--
-- Name: users users_username_key786; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key786 UNIQUE (username);


--
-- Name: users users_username_key787; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key787 UNIQUE (username);


--
-- Name: users users_username_key788; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key788 UNIQUE (username);


--
-- Name: users users_username_key789; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key789 UNIQUE (username);


--
-- Name: users users_username_key79; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key79 UNIQUE (username);


--
-- Name: users users_username_key790; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key790 UNIQUE (username);


--
-- Name: users users_username_key791; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key791 UNIQUE (username);


--
-- Name: users users_username_key792; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key792 UNIQUE (username);


--
-- Name: users users_username_key793; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key793 UNIQUE (username);


--
-- Name: users users_username_key794; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key794 UNIQUE (username);


--
-- Name: users users_username_key795; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key795 UNIQUE (username);


--
-- Name: users users_username_key796; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key796 UNIQUE (username);


--
-- Name: users users_username_key797; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key797 UNIQUE (username);


--
-- Name: users users_username_key798; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key798 UNIQUE (username);


--
-- Name: users users_username_key799; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key799 UNIQUE (username);


--
-- Name: users users_username_key8; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key8 UNIQUE (username);


--
-- Name: users users_username_key80; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key80 UNIQUE (username);


--
-- Name: users users_username_key800; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key800 UNIQUE (username);


--
-- Name: users users_username_key801; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key801 UNIQUE (username);


--
-- Name: users users_username_key802; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key802 UNIQUE (username);


--
-- Name: users users_username_key803; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key803 UNIQUE (username);


--
-- Name: users users_username_key804; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key804 UNIQUE (username);


--
-- Name: users users_username_key805; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key805 UNIQUE (username);


--
-- Name: users users_username_key806; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key806 UNIQUE (username);


--
-- Name: users users_username_key807; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key807 UNIQUE (username);


--
-- Name: users users_username_key808; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key808 UNIQUE (username);


--
-- Name: users users_username_key809; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key809 UNIQUE (username);


--
-- Name: users users_username_key81; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key81 UNIQUE (username);


--
-- Name: users users_username_key810; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key810 UNIQUE (username);


--
-- Name: users users_username_key811; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key811 UNIQUE (username);


--
-- Name: users users_username_key812; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key812 UNIQUE (username);


--
-- Name: users users_username_key813; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key813 UNIQUE (username);


--
-- Name: users users_username_key814; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key814 UNIQUE (username);


--
-- Name: users users_username_key815; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key815 UNIQUE (username);


--
-- Name: users users_username_key816; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key816 UNIQUE (username);


--
-- Name: users users_username_key817; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key817 UNIQUE (username);


--
-- Name: users users_username_key818; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key818 UNIQUE (username);


--
-- Name: users users_username_key819; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key819 UNIQUE (username);


--
-- Name: users users_username_key82; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key82 UNIQUE (username);


--
-- Name: users users_username_key820; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key820 UNIQUE (username);


--
-- Name: users users_username_key821; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key821 UNIQUE (username);


--
-- Name: users users_username_key822; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key822 UNIQUE (username);


--
-- Name: users users_username_key823; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key823 UNIQUE (username);


--
-- Name: users users_username_key824; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key824 UNIQUE (username);


--
-- Name: users users_username_key825; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key825 UNIQUE (username);


--
-- Name: users users_username_key826; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key826 UNIQUE (username);


--
-- Name: users users_username_key827; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key827 UNIQUE (username);


--
-- Name: users users_username_key828; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key828 UNIQUE (username);


--
-- Name: users users_username_key829; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key829 UNIQUE (username);


--
-- Name: users users_username_key83; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key83 UNIQUE (username);


--
-- Name: users users_username_key830; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key830 UNIQUE (username);


--
-- Name: users users_username_key831; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key831 UNIQUE (username);


--
-- Name: users users_username_key832; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key832 UNIQUE (username);


--
-- Name: users users_username_key833; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key833 UNIQUE (username);


--
-- Name: users users_username_key834; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key834 UNIQUE (username);


--
-- Name: users users_username_key835; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key835 UNIQUE (username);


--
-- Name: users users_username_key836; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key836 UNIQUE (username);


--
-- Name: users users_username_key837; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key837 UNIQUE (username);


--
-- Name: users users_username_key838; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key838 UNIQUE (username);


--
-- Name: users users_username_key839; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key839 UNIQUE (username);


--
-- Name: users users_username_key84; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key84 UNIQUE (username);


--
-- Name: users users_username_key840; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key840 UNIQUE (username);


--
-- Name: users users_username_key841; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key841 UNIQUE (username);


--
-- Name: users users_username_key842; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key842 UNIQUE (username);


--
-- Name: users users_username_key843; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key843 UNIQUE (username);


--
-- Name: users users_username_key844; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key844 UNIQUE (username);


--
-- Name: users users_username_key845; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key845 UNIQUE (username);


--
-- Name: users users_username_key846; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key846 UNIQUE (username);


--
-- Name: users users_username_key847; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key847 UNIQUE (username);


--
-- Name: users users_username_key848; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key848 UNIQUE (username);


--
-- Name: users users_username_key849; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key849 UNIQUE (username);


--
-- Name: users users_username_key85; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key85 UNIQUE (username);


--
-- Name: users users_username_key850; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key850 UNIQUE (username);


--
-- Name: users users_username_key851; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key851 UNIQUE (username);


--
-- Name: users users_username_key852; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key852 UNIQUE (username);


--
-- Name: users users_username_key853; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key853 UNIQUE (username);


--
-- Name: users users_username_key854; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key854 UNIQUE (username);


--
-- Name: users users_username_key855; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key855 UNIQUE (username);


--
-- Name: users users_username_key856; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key856 UNIQUE (username);


--
-- Name: users users_username_key857; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key857 UNIQUE (username);


--
-- Name: users users_username_key858; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key858 UNIQUE (username);


--
-- Name: users users_username_key859; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key859 UNIQUE (username);


--
-- Name: users users_username_key86; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key86 UNIQUE (username);


--
-- Name: users users_username_key860; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key860 UNIQUE (username);


--
-- Name: users users_username_key861; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key861 UNIQUE (username);


--
-- Name: users users_username_key862; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key862 UNIQUE (username);


--
-- Name: users users_username_key863; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key863 UNIQUE (username);


--
-- Name: users users_username_key864; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key864 UNIQUE (username);


--
-- Name: users users_username_key865; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key865 UNIQUE (username);


--
-- Name: users users_username_key866; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key866 UNIQUE (username);


--
-- Name: users users_username_key867; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key867 UNIQUE (username);


--
-- Name: users users_username_key868; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key868 UNIQUE (username);


--
-- Name: users users_username_key869; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key869 UNIQUE (username);


--
-- Name: users users_username_key87; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key87 UNIQUE (username);


--
-- Name: users users_username_key870; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key870 UNIQUE (username);


--
-- Name: users users_username_key871; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key871 UNIQUE (username);


--
-- Name: users users_username_key872; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key872 UNIQUE (username);


--
-- Name: users users_username_key873; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key873 UNIQUE (username);


--
-- Name: users users_username_key874; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key874 UNIQUE (username);


--
-- Name: users users_username_key875; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key875 UNIQUE (username);


--
-- Name: users users_username_key876; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key876 UNIQUE (username);


--
-- Name: users users_username_key877; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key877 UNIQUE (username);


--
-- Name: users users_username_key878; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key878 UNIQUE (username);


--
-- Name: users users_username_key879; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key879 UNIQUE (username);


--
-- Name: users users_username_key88; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key88 UNIQUE (username);


--
-- Name: users users_username_key880; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key880 UNIQUE (username);


--
-- Name: users users_username_key881; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key881 UNIQUE (username);


--
-- Name: users users_username_key882; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key882 UNIQUE (username);


--
-- Name: users users_username_key883; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key883 UNIQUE (username);


--
-- Name: users users_username_key884; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key884 UNIQUE (username);


--
-- Name: users users_username_key885; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key885 UNIQUE (username);


--
-- Name: users users_username_key886; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key886 UNIQUE (username);


--
-- Name: users users_username_key887; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key887 UNIQUE (username);


--
-- Name: users users_username_key888; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key888 UNIQUE (username);


--
-- Name: users users_username_key889; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key889 UNIQUE (username);


--
-- Name: users users_username_key89; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key89 UNIQUE (username);


--
-- Name: users users_username_key890; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key890 UNIQUE (username);


--
-- Name: users users_username_key891; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key891 UNIQUE (username);


--
-- Name: users users_username_key892; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key892 UNIQUE (username);


--
-- Name: users users_username_key893; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key893 UNIQUE (username);


--
-- Name: users users_username_key894; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key894 UNIQUE (username);


--
-- Name: users users_username_key895; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key895 UNIQUE (username);


--
-- Name: users users_username_key896; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key896 UNIQUE (username);


--
-- Name: users users_username_key897; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key897 UNIQUE (username);


--
-- Name: users users_username_key898; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key898 UNIQUE (username);


--
-- Name: users users_username_key899; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key899 UNIQUE (username);


--
-- Name: users users_username_key9; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key9 UNIQUE (username);


--
-- Name: users users_username_key90; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key90 UNIQUE (username);


--
-- Name: users users_username_key900; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key900 UNIQUE (username);


--
-- Name: users users_username_key901; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key901 UNIQUE (username);


--
-- Name: users users_username_key902; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key902 UNIQUE (username);


--
-- Name: users users_username_key903; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key903 UNIQUE (username);


--
-- Name: users users_username_key904; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key904 UNIQUE (username);


--
-- Name: users users_username_key905; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key905 UNIQUE (username);


--
-- Name: users users_username_key906; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key906 UNIQUE (username);


--
-- Name: users users_username_key907; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key907 UNIQUE (username);


--
-- Name: users users_username_key908; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key908 UNIQUE (username);


--
-- Name: users users_username_key909; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key909 UNIQUE (username);


--
-- Name: users users_username_key91; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key91 UNIQUE (username);


--
-- Name: users users_username_key910; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key910 UNIQUE (username);


--
-- Name: users users_username_key911; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key911 UNIQUE (username);


--
-- Name: users users_username_key912; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key912 UNIQUE (username);


--
-- Name: users users_username_key913; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key913 UNIQUE (username);


--
-- Name: users users_username_key914; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key914 UNIQUE (username);


--
-- Name: users users_username_key915; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key915 UNIQUE (username);


--
-- Name: users users_username_key916; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key916 UNIQUE (username);


--
-- Name: users users_username_key917; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key917 UNIQUE (username);


--
-- Name: users users_username_key918; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key918 UNIQUE (username);


--
-- Name: users users_username_key919; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key919 UNIQUE (username);


--
-- Name: users users_username_key92; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key92 UNIQUE (username);


--
-- Name: users users_username_key920; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key920 UNIQUE (username);


--
-- Name: users users_username_key921; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key921 UNIQUE (username);


--
-- Name: users users_username_key922; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key922 UNIQUE (username);


--
-- Name: users users_username_key923; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key923 UNIQUE (username);


--
-- Name: users users_username_key924; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key924 UNIQUE (username);


--
-- Name: users users_username_key925; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key925 UNIQUE (username);


--
-- Name: users users_username_key926; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key926 UNIQUE (username);


--
-- Name: users users_username_key93; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key93 UNIQUE (username);


--
-- Name: users users_username_key94; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key94 UNIQUE (username);


--
-- Name: users users_username_key95; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key95 UNIQUE (username);


--
-- Name: users users_username_key96; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key96 UNIQUE (username);


--
-- Name: users users_username_key97; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key97 UNIQUE (username);


--
-- Name: users users_username_key98; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key98 UNIQUE (username);


--
-- Name: users users_username_key99; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key99 UNIQUE (username);


--
-- Name: client_addresses_client_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX client_addresses_client_id ON public.client_addresses USING btree (client_id);


--
-- Name: client_addresses_is_primary; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX client_addresses_is_primary ON public.client_addresses USING btree (is_primary);


--
-- Name: clients_client_type; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX clients_client_type ON public.clients USING btree (client_type);


--
-- Name: clients_display_name; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX clients_display_name ON public.clients USING btree (display_name);


--
-- Name: clients_is_active; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX clients_is_active ON public.clients USING btree (is_active);


--
-- Name: estimate_item_additional_work_estimate_item_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX estimate_item_additional_work_estimate_item_id ON public.estimate_item_additional_work USING btree (estimate_item_id);


--
-- Name: estimate_item_photos_estimate_item_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX estimate_item_photos_estimate_item_id ON public.estimate_item_photos USING btree (estimate_item_id);


--
-- Name: estimate_items_estimate_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX estimate_items_estimate_id ON public.estimate_items USING btree (estimate_id);


--
-- Name: estimate_items_estimate_id_idx; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX estimate_items_estimate_id_idx ON public.estimate_items USING btree (estimate_id);


--
-- Name: estimates_address_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX estimates_address_id ON public.estimates USING btree (address_id);


--
-- Name: estimates_client_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX estimates_client_id ON public.estimates USING btree (client_id);


--
-- Name: estimates_client_id_idx; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX estimates_client_id_idx ON public.estimates USING btree (client_id);


--
-- Name: estimates_estimate_number; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE UNIQUE INDEX estimates_estimate_number ON public.estimates USING btree (estimate_number);


--
-- Name: estimates_project_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX estimates_project_id ON public.estimates USING btree (project_id);


--
-- Name: estimates_status; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX estimates_status ON public.estimates USING btree (status);


--
-- Name: estimates_status_idx; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX estimates_status_idx ON public.estimates USING btree (status);


--
-- Name: idx_estimate_item_photos_estimate_item_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX idx_estimate_item_photos_estimate_item_id ON public.estimate_item_photos USING btree (estimate_item_id);


--
-- Name: invoice_items_invoice_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX invoice_items_invoice_id ON public.invoice_items USING btree (invoice_id);


--
-- Name: invoice_items_invoice_id_idx; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX invoice_items_invoice_id_idx ON public.invoice_items USING btree (invoice_id);


--
-- Name: invoices_address_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX invoices_address_id ON public.invoices USING btree (address_id);


--
-- Name: invoices_client_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX invoices_client_id ON public.invoices USING btree (client_id);


--
-- Name: invoices_client_id_idx; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX invoices_client_id_idx ON public.invoices USING btree (client_id);


--
-- Name: invoices_invoice_number; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE UNIQUE INDEX invoices_invoice_number ON public.invoices USING btree (invoice_number);


--
-- Name: invoices_status; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX invoices_status ON public.invoices USING btree (status);


--
-- Name: invoices_status_idx; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX invoices_status_idx ON public.invoices USING btree (status);


--
-- Name: payments_invoice_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX payments_invoice_id ON public.payments USING btree (invoice_id);


--
-- Name: payments_invoice_id_idx; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX payments_invoice_id_idx ON public.payments USING btree (invoice_id);


--
-- Name: payments_payment_date; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX payments_payment_date ON public.payments USING btree (payment_date);


--
-- Name: products_is_active; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX products_is_active ON public.products USING btree (is_active);


--
-- Name: products_name; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX products_name ON public.products USING btree (name);


--
-- Name: products_type; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX products_type ON public.products USING btree (type);


--
-- Name: project_inspections_project_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX project_inspections_project_id ON public.project_inspections USING btree (project_id);


--
-- Name: project_photos_inspection_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX project_photos_inspection_id ON public.project_photos USING btree (inspection_id);


--
-- Name: project_photos_project_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX project_photos_project_id ON public.project_photos USING btree (project_id);


--
-- Name: project_type_questionnaires_project_type_project_subtype; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE UNIQUE INDEX project_type_questionnaires_project_type_project_subtype ON public.project_type_questionnaires USING btree (project_type, project_subtype);


--
-- Name: projects_address_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX projects_address_id ON public.projects USING btree (address_id);


--
-- Name: projects_assessment_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX projects_assessment_id ON public.projects USING btree (assessment_id);


--
-- Name: projects_client_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX projects_client_id ON public.projects USING btree (client_id);


--
-- Name: projects_estimate_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX projects_estimate_id ON public.projects USING btree (estimate_id);


--
-- Name: projects_scheduled_date; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX projects_scheduled_date ON public.projects USING btree (scheduled_date);


--
-- Name: projects_status_idx; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX projects_status_idx ON public.projects USING btree (status);


--
-- Name: projects_type_status_idx; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX projects_type_status_idx ON public.projects USING btree (type, status);


--
-- Name: settings_group; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX settings_group ON public.settings USING btree ("group");


--
-- Name: settings_key; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE UNIQUE INDEX settings_key ON public.settings USING btree (key);


--
-- Name: users_email; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE UNIQUE INDEX users_email ON public.users USING btree (email);


--
-- Name: users_username; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE UNIQUE INDEX users_username ON public.users USING btree (username);


--
-- Name: client_addresses client_addresses_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.client_addresses
    ADD CONSTRAINT client_addresses_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: estimate_item_additional_work estimate_item_additional_work_estimate_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimate_item_additional_work
    ADD CONSTRAINT estimate_item_additional_work_estimate_item_id_fkey FOREIGN KEY (estimate_item_id) REFERENCES public.estimate_items(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: estimate_item_photos estimate_item_photos_estimate_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimate_item_photos
    ADD CONSTRAINT estimate_item_photos_estimate_item_id_fkey FOREIGN KEY (estimate_item_id) REFERENCES public.estimate_items(id) ON DELETE CASCADE;


--
-- Name: estimate_items estimate_items_estimate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimate_items
    ADD CONSTRAINT estimate_items_estimate_id_fkey FOREIGN KEY (estimate_id) REFERENCES public.estimates(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: estimate_items estimate_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimate_items
    ADD CONSTRAINT estimate_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: estimates estimates_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.client_addresses(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: estimates estimates_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: estimates estimates_converted_to_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_converted_to_invoice_id_fkey FOREIGN KEY (converted_to_invoice_id) REFERENCES public.invoices(id) ON DELETE SET NULL;


--
-- Name: estimates estimates_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoice_items invoice_items_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invoices invoices_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.client_addresses(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoices invoices_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: payments payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pre_assessments pre_assessments_client_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.pre_assessments
    ADD CONSTRAINT pre_assessments_client_address_id_fkey FOREIGN KEY (client_address_id) REFERENCES public.client_addresses(id);


--
-- Name: project_inspections project_inspections_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.project_inspections
    ADD CONSTRAINT project_inspections_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: project_photos project_photos_inspection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.project_photos
    ADD CONSTRAINT project_photos_inspection_id_fkey FOREIGN KEY (inspection_id) REFERENCES public.project_inspections(id);


--
-- Name: project_photos project_photos_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.project_photos
    ADD CONSTRAINT project_photos_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: projects projects_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.client_addresses(id);


--
-- Name: projects projects_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.projects(id);


--
-- Name: projects projects_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: projects projects_converted_to_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_converted_to_job_id_fkey FOREIGN KEY (converted_to_job_id) REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: projects projects_estimate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_estimate_id_fkey FOREIGN KEY (estimate_id) REFERENCES public.estimates(id);


--
-- Name: projects projects_pre_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pre_assessment_id_fkey FOREIGN KEY (pre_assessment_id) REFERENCES public.pre_assessments(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

