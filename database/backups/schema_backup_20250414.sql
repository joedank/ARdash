--
-- PostgreSQL database dump
--

-- Dumped from database version 14.17 (Homebrew)
-- Dumped by pg_dump version 14.17 (Homebrew)

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
    'completed'
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
 SELECT clients.id,
    clients.display_name AS name,
    clients.company,
    clients.email,
    clients.phone,
    clients.payment_terms,
    clients.default_tax_rate,
    clients.default_currency,
    clients.notes,
    clients.is_active,
    clients.client_type,
    clients.created_at,
    clients.updated_at
   FROM public.clients;


ALTER TABLE public.client_view OWNER TO josephmcmyne;

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


ALTER TABLE public.llm_prompts_id_seq OWNER TO josephmcmyne;

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
    payment_method character varying(50),
    notes text,
    reference_number character varying(100),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.payments OWNER TO josephmcmyne;

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
    "group" character varying(255) DEFAULT 'general'::character varying,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
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


ALTER TABLE public.settings_id_seq OWNER TO josephmcmyne;

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
-- Name: users users_username_key92; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key92 UNIQUE (username);


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
    ADD CONSTRAINT estimates_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;


--
-- Name: estimates estimates_client_id_new_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_client_id_new_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id);


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
    ADD CONSTRAINT invoices_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;


--
-- Name: invoices invoices_client_id_new_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_client_id_new_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id);


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

