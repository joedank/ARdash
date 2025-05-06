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
    'upcoming',
    'rejected'
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
    'estimator_manager',
    'admin'
);


ALTER TYPE public.enum_users_role OWNER TO josephmcmyne;

--
-- Name: enum_work_types_measurement_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_work_types_measurement_type AS ENUM (
    'area',
    'linear',
    'quantity'
);


ALTER TYPE public.enum_work_types_measurement_type OWNER TO postgres;

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
-- Name: ad_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ad_types (
    id bigint NOT NULL,
    community_id bigint,
    name text,
    width real,
    height real,
    cost real,
    start_date date,
    end_date date,
    deadline_date date,
    term_months bigint,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.ad_types OWNER TO postgres;

--
-- Name: ad_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ad_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ad_types_id_seq OWNER TO postgres;

--
-- Name: ad_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ad_types_id_seq OWNED BY public.ad_types.id;


--
-- Name: assessment_work_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assessment_work_types (
    id uuid NOT NULL,
    assessment_id uuid NOT NULL,
    work_type_id uuid NOT NULL,
    confidence numeric(4,3)
);


ALTER TABLE public.assessment_work_types OWNER TO postgres;

--
-- Name: COLUMN assessment_work_types.confidence; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.assessment_work_types.confidence IS '0-1 similarity score';


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
-- Name: COLUMN clients.client_type; Type: COMMENT; Schema: public; Owner: josephmcmyne
--

COMMENT ON COLUMN public.clients.client_type IS 'Indicates if client is a property manager or resident';


--
-- Name: communities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.communities (
    id bigint NOT NULL,
    name text,
    address text,
    city text,
    phone text,
    spaces bigint,
    ad_specialist_name text,
    ad_specialist_email text,
    ad_specialist_phone text,
    state text DEFAULT 'Inactive'::text,
    adtypes text,
    newsletter_link text,
    general_notes text,
    selected_ad_type_id bigint,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_active boolean DEFAULT false
);


ALTER TABLE public.communities OWNER TO postgres;

--
-- Name: communities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.communities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.communities_id_seq OWNER TO postgres;

--
-- Name: communities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.communities_id_seq OWNED BY public.communities.id;


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
    notes text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    photo_type text DEFAULT 'progress'::text NOT NULL,
    CONSTRAINT check_photo_type CHECK ((photo_type = ANY (ARRAY['progress'::text, 'completed'::text, 'issue'::text, 'material'::text, 'other'::text])))
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
    deleted_at timestamp with time zone,
    name_vec public.vector(384),
    embedding public.vector(384)
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
    condition text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    additional_work text,
    address_id uuid,
    assessment_id uuid,
    converted_to_job_id uuid,
    pre_assessment_id uuid,
    work_types jsonb DEFAULT '[]'::jsonb
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
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
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
-- Name: work_type_cost_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_type_cost_history (
    id uuid NOT NULL,
    work_type_id uuid NOT NULL,
    region character varying(50) DEFAULT 'default'::character varying NOT NULL,
    unit_cost_material numeric(10,2),
    unit_cost_labor numeric(10,2),
    captured_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_history_unit_cost_labor_non_negative CHECK (((unit_cost_labor IS NULL) OR (unit_cost_labor >= (0)::numeric))),
    CONSTRAINT check_history_unit_cost_material_non_negative CHECK (((unit_cost_material IS NULL) OR (unit_cost_material >= (0)::numeric)))
);


ALTER TABLE public.work_type_cost_history OWNER TO postgres;

--
-- Name: work_type_materials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_type_materials (
    id uuid NOT NULL,
    work_type_id uuid NOT NULL,
    product_id uuid NOT NULL,
    qty_per_unit numeric(10,4) DEFAULT 1.0 NOT NULL,
    unit character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_qty_per_unit_non_negative CHECK ((qty_per_unit >= (0)::numeric))
);


ALTER TABLE public.work_type_materials OWNER TO postgres;

--
-- Name: work_type_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_type_tags (
    work_type_id uuid NOT NULL,
    tag character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.work_type_tags OWNER TO postgres;

--
-- Name: work_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_types (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    parent_bucket character varying(100) NOT NULL,
    measurement_type public.enum_work_types_measurement_type NOT NULL,
    suggested_units character varying(50) NOT NULL,
    unit_cost_material numeric(10,2),
    unit_cost_labor numeric(10,2),
    productivity_unit_per_hr numeric(10,2),
    name_vec public.vector(3072),
    revision integer DEFAULT 1 NOT NULL,
    updated_by uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name_clean text GENERATED ALWAYS AS (regexp_replace(lower((name)::text), '\m(install|installation|replace|replacement|repair|repairs|service|services)\M'::text, ''::text, 'gi'::text)) STORED,
    CONSTRAINT check_productivity_non_negative CHECK (((productivity_unit_per_hr IS NULL) OR (productivity_unit_per_hr >= (0)::numeric))),
    CONSTRAINT check_productivity_unit_per_hr_non_negative CHECK (((productivity_unit_per_hr IS NULL) OR (productivity_unit_per_hr >= (0)::numeric))),
    CONSTRAINT check_unit_cost_labor_non_negative CHECK (((unit_cost_labor IS NULL) OR (unit_cost_labor >= (0)::numeric))),
    CONSTRAINT check_unit_cost_material_non_negative CHECK (((unit_cost_material IS NULL) OR (unit_cost_material >= (0)::numeric)))
);


ALTER TABLE public.work_types OWNER TO postgres;

--
-- Name: TABLE work_types; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.work_types IS 'Mobile-home repair and remodel work types with measurement specifications';


--
-- Name: COLUMN work_types.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_types.id IS 'Unique identifier for the work type';


--
-- Name: COLUMN work_types.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_types.name IS 'Descriptive name of the work type';


--
-- Name: COLUMN work_types.parent_bucket; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_types.parent_bucket IS 'Category grouping (Interior-Structural, Interior-Finish, Exterior-Structural, Exterior-Finish, Mechanical)';


--
-- Name: COLUMN work_types.measurement_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_types.measurement_type IS 'Type of measurement (area, linear, quantity)';


--
-- Name: COLUMN work_types.suggested_units; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.work_types.suggested_units IS 'Suggested unit for measurement (sq ft, ft, each, job, etc.)';


--
-- Name: ad_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ad_types ALTER COLUMN id SET DEFAULT nextval('public.ad_types_id_seq'::regclass);


--
-- Name: communities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.communities ALTER COLUMN id SET DEFAULT nextval('public.communities_id_seq'::regclass);


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
20250331-add-pdf-settings.js
20250407-add-type-to-products.js
20250407-add-unit-to-products.js
20250408000001-migrate-scope-to-condition.js
20250413001000-standardize-remaining-fields-modified.js
20250413001000-standardize-remaining-fields.js
20250414053000-create-estimate-item-additional-work.js
20250415000000-add-rejected-status.js
20250417000000-add-vector-column-to-products.js
20250418000001-add-vector-embedding.js
20250423-drop-client-view.js
20250423000000-enable-pgvector.js
20250423000001-fix-work-type-uuids.js
20250423144500-fix-payment-terms-column-type.js
20250424-add-client-type-comment.js
20250424-fix-payment-terms-column.js
20250424000001-add-ai-provider-settings.js
20250425000000-alter-estimate-item-photo-type.js
20250425000000-create-work-types-tables.js
20250425060000-alter-name-vec-dimension.js
20250426000000-add-pg-trgm-extension.js
20250426000000-create-settings-table.js
20250426000001-add-name-vec-hnsw-index.js
20250426000001-ensure-client-id-columns.js
20250426000002-fix-estimate-item-relations.js
20250426000200-seed-embedding-model.js
20250427130000-backfill-settings-timestamps.js
20250428-add-estimator-manager-role.js
20250428-add-productivity-check-constraint.js
20250429-add-product-id-index-to-work-type-materials.js
20250430-add-composite-unique-index-to-work-type-materials.js
20250431000000-update-source-maps-fk.js
20250432000000-fix-estimate-item-photos-enum.js
20250531000000-add-work-types-to-projects.js
202504270002-remove-deepseek-settings.js
20250427180000-fix-gemini-base-url.js
20250427200000-fix-gemini-api-key.js
20250427300000-update-gemini-api-config.js
20250428000000-add-work-type-name-clean-col.js
\.


--
-- Data for Name: ad_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ad_types (id, community_id, name, width, height, cost, start_date, end_date, deadline_date, term_months, created_at, updated_at) FROM stdin;
1	2	Test	0	0	0	\N	\N	\N	\N	2025-04-16 02:44:03.944338+00	2025-04-16 02:44:03.944338+00
2	1	Ad - 0x0	0	0	0	\N	\N	\N	\N	2025-04-16 02:44:03.944338+00	2025-04-16 02:44:03.944338+00
3	1	Ad - 21x22	21	22	3	\N	\N	\N	\N	2025-04-16 02:44:03.944338+00	2025-04-16 02:44:03.944338+00
4	1	Ad - 3x3	3	3	33	\N	\N	\N	\N	2025-04-16 02:44:03.944338+00	2025-04-16 02:44:03.944338+00
5	1	Ad - 32x22	32	22	5	2025-03-15	2025-05-15	2025-03-01	2	2025-04-16 02:44:03.944338+00	2025-04-16 02:44:03.944338+00
6	1	Ad - 11x11	11	11	1	\N	\N	\N	\N	2025-04-16 02:44:03.944338+00	2025-04-16 02:44:03.944338+00
7	3	3" × 1"	3	1	100	2025-05-01	2026-05-01	2026-03-01	12	2025-04-16 02:44:03.944338+00	2025-04-16 02:44:03.944338+00
8	1	Ad - 22x11	22	11	33	2025-04-01	2025-07-01	2025-03-15	3	2025-04-16 02:44:03.944338+00	2025-04-16 02:44:03.944338+00
9	2	Ad - 3.5x2	3.5	2	450	\N	\N	\N	\N	2025-04-16 02:44:03.944338+00	2025-04-16 02:44:03.944338+00
10	2	Ad - 4.75x6.75	4.75	6.75	875	\N	\N	\N	\N	2025-04-16 02:44:03.944338+00	2025-04-16 02:44:03.944338+00
11	2	Ad - 9.75x6.75	9.75	6.75	1750	\N	\N	\N	\N	2025-04-16 02:44:03.944338+00	2025-04-16 02:44:03.944338+00
12	1	Ad - 5x3	5	3	250	\N	\N	\N	6	2025-04-16 02:44:03.944338+00	2025-04-16 02:44:03.944338+00
13	1	Ad - 33x33	33	33	33	2025-02-05	2026-01-05	2025-02-02	11	2025-04-16 02:44:03.944338+00	2025-04-16 02:44:03.944338+00
14	522	Business card	2.5	2.5	100	2025-04-16	2025-10-03	2025-05-10	12	2025-04-16 03:59:25.498+00	2025-04-16 03:59:25.498+00
\.


--
-- Data for Name: assessment_work_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assessment_work_types (id, assessment_id, work_type_id, confidence) FROM stdin;
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
247649a3-fbe7-4dc7-bc12-43f61168d822	98c1612d-919c-4b88-8141-234bd88dea3e	Property	1443 Fairview Circle	Kissimmee	FL	34747	USA	t		2025-05-01 21:10:10.445+00	2025-05-01 21:10:10.445+00
3311ca1b-da19-4837-b8f8-b194580affab	6534a9e7-0e25-4c48-b1e2-284e78bc89c9	Primary Address	2130 Honeoye Trial	Lakeland	FL	33810	USA	f		2025-04-29 18:14:46.508+00	2025-05-06 17:28:24.106+00
e405a78c-1a22-4254-a815-d20252ba8795	6534a9e7-0e25-4c48-b1e2-284e78bc89c9	Primary Address	3120 Honeoye Trial	Lakeland	FL	33810	USA	t		2025-04-29 18:14:46.508+00	2025-05-06 17:28:24.109+00
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.clients (id, payment_terms, default_tax_rate, default_currency, notes, is_active, created_at, updated_at, display_name, company, email, phone, client_type) FROM stdin;
c48c7458-f18e-4a5f-bfd5-5f329cc3e141	\N	\N	USD	\N	t	2025-04-01 00:32:56.049+00	2025-04-01 00:32:56.049+00	Mr Johnson Science	\N	\N	(904) 274-0181	resident
d89d95d1-e8da-43e2-a978-5aac979fc89a	\N	\N	USD	\N	t	2025-04-01 00:32:56.042+00	2025-04-01 00:32:56.043+00	rich lee roofer	\N	\N	+1 314-458-3449	resident
953de72c-3590-4889-a8ce-ca22c46d947f	\N	\N	USD	\N	t	2025-04-01 00:32:56.044+00	2025-04-01 00:32:56.044+00	Sandra	\N	\N	(321) 317-7337	resident
9e0906d7-e5ae-4881-bd6f-37b6a33766dc	\N	\N	USD	\N	t	2025-04-01 00:32:56.046+00	2025-04-01 00:32:56.046+00	SteveBlueSky	\N	\N	+14075754920	resident
4fcdbe23-0268-44e7-a1bb-b651d78b5e19	\N	\N	USD	\N	t	2025-04-01 00:32:56.05+00	2025-04-01 00:32:56.05+00	justin white	\N	\N	+1 813-526-6880	resident
8603d9db-c72b-4610-9a97-4d8a1a26ecf5	\N	\N	USD	\N	t	2025-04-01 00:32:56.048+00	2025-04-01 00:32:56.048+00	Mrs Lieb	\N	\N	(727) 265-2019	resident
0988f598-9cff-4149-90ff-b107bc667c32	\N	\N	USD	\N	t	2025-04-01 00:32:56.048+00	2025-04-01 00:32:56.048+00	Daniel Young	\N	\N	(407) 361-6236	resident
44b50b41-1f47-4490-b28f-c5b348e9fbd9	\N	\N	USD	\N	t	2025-04-01 00:32:56.054+00	2025-04-01 00:32:56.054+00	Son	myContacts	\N	(321) 234-4692	resident
a1719805-3586-4a27-96ea-3a4b301b1242	\N	\N	USD	\N	t	2025-04-01 00:32:56.055+00	2025-04-01 00:32:56.055+00	Mrs. Downing Peer Counseling	\N	\N	(828) 539-0695	resident
d45153b4-b0e2-47a0-8a30-f3d8149a00cf	\N	\N	USD	\N	t	2025-04-01 00:32:56.051+00	2025-04-01 00:32:56.051+00	Jean Carlo	\N	\N	(407) 720-0422	resident
362f4c7a-54da-45d4-8f1e-c97fc84a4638	\N	\N	USD	\N	t	2025-04-01 00:32:56.053+00	2025-04-01 00:32:56.053+00	pete rv world	\N	\N	+1 863-602-6144	resident
4caa2f57-2c77-4d71-93d3-76f7cfdeb58a	\N	\N	USD	\N	t	2025-04-01 00:32:56.054+00	2025-04-01 00:32:56.054+00	Sean Website	\N	\N	(407) 361-6237	resident
800b0a22-72bb-4693-b618-0324bf38aa07	\N	\N	USD	\N	t	2025-04-01 00:32:56.055+00	2025-04-01 00:32:56.055+00	phil young	\N	\N	+1 407-818-7187	resident
9afa4ce9-72cd-4222-a15c-4217044de20e	\N	\N	USD	\N	t	2025-04-01 00:32:56.056+00	2025-04-01 00:32:56.056+00	Twank En	\N	\N	+18637097760	resident
4744c422-3a7e-4ccf-a9c1-4b8fab01fff5	\N	\N	USD	\N	t	2025-04-01 00:32:56.051+00	2025-04-01 00:32:56.051+00	TereGPS	\N	\N	(407) 534-0276	resident
904637a8-4c4e-49b1-9151-ef39854130db	\N	\N	USD	\N	t	2025-04-01 00:32:56.052+00	2025-04-01 00:32:56.052+00	Mrs Brown Math	\N	\N	+1 850-583-6791	resident
a2e2eb31-6f6b-43a4-b279-c60d507685c7	\N	\N	USD	\N	t	2025-04-01 00:32:56.052+00	2025-04-01 00:32:56.052+00	Sabrina Mouton	\N	\N	+1 971-413-3237	resident
46a8e233-6b15-4261-8689-7861a5ad78b8	\N	\N	USD	\N	t	2025-04-01 00:32:56.053+00	2025-04-01 00:32:56.053+00	Phillip And Helen	\N	\N	+1 407-201-4333	resident
10a64445-290b-48d2-b40f-55a0da7aac89	\N	\N	USD	\N	t	2025-04-01 00:32:56.059+00	2025-04-01 00:32:56.059+00	Mrs Jackson Civics	\N	\N	+1 754-227-9337	resident
08f74d1f-da2a-4de2-a926-f8ca1c199e19	\N	\N	USD	\N	t	2025-04-01 00:32:56.057+00	2025-04-01 00:32:56.057+00	Joe	\N	joe@806040.xyz	+18633988284	resident
8f0faa0a-1753-44b3-a718-36ed127707be	\N	\N	USD	\N	t	2025-04-01 00:32:56.059+00	2025-04-01 00:32:56.059+00	Son	\N	jamesmcmyne09@gmail.com	\N	resident
5cfa7c4a-0a62-40bb-aae4-b0efcbb21526	\N	\N	USD	\N	t	2025-04-01 00:32:56.06+00	2025-04-01 00:32:56.06+00	Suzy McMyne	\N	\N	(570) 903-1610	resident
c0bfa559-799c-44bf-aec5-aec34591c3f0	\N	\N	USD	\N	t	2025-04-01 00:32:56.06+00	2025-04-01 00:32:56.06+00	Mrs Carlan	Guitar FLVS	\N	8502967566	resident
4afef814-629b-44d6-a3d8-5b2895604e06	\N	\N	USD	\N	t	2025-04-01 00:32:56.061+00	2025-04-01 00:32:56.061+00	Paul	\N	\N	+15857348989	resident
6c2e3eea-0054-4904-90c2-6bb4a262e79f	\N	\N	USD	\N	t	2025-04-01 00:32:56.056+00	2025-04-01 00:32:56.056+00	Joseph McMyne	\N	\N	\N	resident
89fb8712-e96b-4233-8fc8-9d6fad2a767a	\N	\N	USD	\N	t	2025-04-01 00:28:53.413+00	2025-04-01 00:28:53.413+00	Kim Mood Service Channel	\N	\N	5163906784	resident
4b939430-ff8d-4cc3-9eec-31efc6141cfd	\N	\N	USD	\N	t	2025-04-01 00:28:53.427+00	2025-04-01 00:28:53.427+00	Kathy	\N	\N	(407) 750-1813	resident
8254beb6-ec9f-4f48-9850-36a434b7e67f	\N	\N	USD	\N	t	2025-04-01 00:32:56.057+00	2025-04-01 00:32:56.057+00	luismex	\N	\N	+1 407-486-2435	resident
f8170db2-6183-48b1-9644-65541e7bb27e	\N	\N	USD	\N	t	2025-04-01 00:32:56.062+00	2025-04-01 00:32:56.062+00	Pat	\N	\N	+1 863-816-4689	resident
0d78e4f3-763c-456b-a2a9-58674715b19a	\N	\N	USD	\N	t	2025-04-01 00:32:56.063+00	2025-04-01 00:32:56.063+00	shameer.kassim	\N	shameer.kassim@macgrill.com	+1 321-438-6005	resident
32b63f52-e2bd-4d47-97b8-ef714a8c7628	\N	\N	USD	\N	t	2025-04-01 00:32:56.063+00	2025-04-01 00:32:56.063+00	Nancy Iglesia	\N	\N	(407) 318-0064	resident
3124186b-91f5-4601-9646-67df23ea6cb8	\N	\N	USD	\N	t	2025-04-01 00:32:56.064+00	2025-04-01 00:32:56.064+00	Michael Huxell	\N	\N	(407) 346-3029	resident
531945d3-c25f-46c6-98bf-8be916528a06	\N	\N	USD	\N	t	2025-04-01 00:32:56.064+00	2025-04-01 00:32:56.064+00	Momma GOVT	\N	\N	+1 318-791-0268	resident
507860f4-eea2-441d-a4bf-0a8a60bacec5	\N	\N	USD	\N	t	2025-04-01 00:28:53.386+00	2025-04-01 00:28:53.386+00	Nancy	\N	\N	863-660-1773	resident
4f304b90-f8ac-412f-8405-8266495be854	\N	\N	USD	\N	t	2025-04-01 00:32:56.062+00	2025-04-01 00:32:56.062+00	Mark prager	\N	\N	(321) 444-9212	resident
5a1e5bd7-a873-41a9-8898-03c596429321	\N	\N	USD	\N	t	2025-04-01 00:32:56.063+00	2025-04-01 00:32:56.063+00	Teelee	\N	\N	+15044102026	resident
30a312e6-f0b1-49e6-acc2-1ae6dd62a693	\N	\N	USD	\N	t	2025-04-01 00:32:56.066+00	2025-04-01 00:32:56.066+00	Rich Be	\N	\N	8134842655	resident
57bcfb02-0daf-4171-9448-987306007f12	\N	\N	USD	\N	t	2025-04-01 00:32:56.065+00	2025-04-01 00:32:56.065+00	Sofia	\N	\N	+1 407-346-1202	resident
7a7706dd-223c-4ee4-9785-b41fd8244e47	\N	\N	USD	\N	t	2025-04-01 00:32:56.068+00	2025-04-01 00:32:56.068+00	Tanner Madsen	Aptive Solar;	madsentanner@gmail.com	435-262-0704	resident
45e9f03b-aabf-4a58-852e-97e3ddc4aa18	\N	\N	USD	\N	t	2025-04-01 00:32:56.038+00	2025-04-01 00:32:56.039+00	Nicholas Mid Atlantic Roofing Supply	\N	\N	+1 813-255-3032	resident
f59e7326-c301-4d77-9383-4b4f47c5ec86	\N	\N	USD	\N	t	2025-04-01 00:32:56.05+00	2025-04-01 00:32:56.05+00	Milanreal	\N	\N	+14073613233	resident
ba911582-1daa-47d9-9d8a-5ed85bc0cf30	Net 30	8.25	USD	This is a test client created directly in the database.	t	2025-04-01 01:50:51.049+00	2025-04-01 01:50:51.049+00	Test Direct Client	Test Company Inc.	test@example.com	555-123-4567	resident
cef8a5e0-ba91-45da-9cb8-e20c4292b2a1		0.00	USD		t	2025-04-04 02:25:54.426+00	2025-04-04 02:25:54.426+00	Chris	Prestige Florida Villas	info@prestigefloridavillas.com	3529785126	property_manager
a04af1e2-7946-4387-ad73-7456c91af533		0.00	USD		t	2025-04-08 20:13:27.759+00	2025-04-08 20:13:27.759+00	Robin		odell.hicks.robin@gmail.com	9412539088	resident
26ff807d-0535-49c3-8144-2aae123c02ed		0.00	USD		t	2025-04-12 02:56:46.147+00	2025-04-12 19:23:03.586+00	Kassahun W. Gebremariam		Barragan91rosana@gmail.com	8132159096	resident
98c1612d-919c-4b88-8141-234bd88dea3e		0.00	USD		t	2025-05-01 21:10:10.432+00	2025-05-01 21:10:10.432+00	Stacy Nelson	Reunion Realty	stacey@reunionrealty.com		property_manager
6534a9e7-0e25-4c48-b1e2-284e78bc89c9		0.00	USD		t	2025-04-29 18:14:46.497+00	2025-05-06 17:28:24.1+00	Michael Stevenson			4077329852	resident
\.


--
-- Data for Name: communities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.communities (id, name, address, city, phone, spaces, ad_specialist_name, ad_specialist_email, ad_specialist_phone, state, adtypes, newsletter_link, general_notes, selected_ad_type_id, created_at, updated_at, is_active) FROM stdin;
522		14666 Liberty Street	Orlando	3523481230	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 03:52:50.8+00	f
262	21 Palms On Lake Juliana  Inc.	584 State 559 Road	Auburndale	8639841843	5	\N	\N	\N	Inactive	\N			\N	2025-04-16 02:44:03.894332+00	2025-04-16 04:09:11.995+00	f
660	River Ranch RV Owners Association	3400 River Ranch Boulevard	Lake Wales	8636921116	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
661	Sandy Cove RV Park	714 N Crooked Lake Drive	Babson Park	8636381139	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
662	Lake Magic - Encore Orlando	9600 Hwy 192 West	Clermont	3122791400	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
663	Camp Wilderness/Florida Rangers Inc	3065 US Highway 17 S	Fort Meade	8632858067	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
664	Deer Creek Phase II UDI POA Class I	42759 US Highway 27 North	Davenport	8634240139	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
665	Sunshine Foundation Dream Village	5400 CR 547 North	Davenport	8634244188	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
666	Camp Wingmann	3404 Wingmann Road	Avon Park	8634535419	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
667	GMHT	2285 Boy Scout Road	Lake Wales	8635340100	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
668	Sun'N Fun Fly-In Inc	4175 Medulla Road	Lakeland	8636442431	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
669	Port Hatchineha Park & Campground	16000 Lake Hatchineha Road	Haines City	8634992613	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
670	Destination Aviation	4175 Medulla Road	Lakeland	8636442431	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
671	Lake Wales Municipal Airport Campground	440 S Airport Road	Lake Wales	8636780080	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
672	Coleman Landings	1800 Shady Oaks Road	Lake Wales	8635345527	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
673	Glamping	3200 River Ranch Boulevard	River Ranch	4077441558	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
674	Tipis	3200 River Ranch Boulevard	River Ranch	4077441558	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
675	Colt Creek State Park	16000 SR 471	Lakeland	8638156761	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
676	Camp Central RV Park, LLC	15710 U.S Hwy 27	Lake Wales	4436219757	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
677	Camp Central RV Park, LLC	15860 US. Hwy 27	Lake Wales	4436219757	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
678	Resort at Canopy Oaks	16950 Country Road 630	Lake Wales	8632130346	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
679	Camp Margaritaville Auburndale, LLC	361 Denton Avenue	Auburndale	8638757833	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
680	Granite Georgetowne Manor LLC	1501 Ariana Street	Lakeland	6025366679	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
1	Fairways Country Club	14205 E Colonial Drive	Orlando	4072732360	1141	Jeanna	test@test.com	3432323432	Inactive	\N	https://yahoo.com	called and left voicemail	5	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
2	Cypress Lakes Village	10000 US Highway 98 North	Lakeland	8638591431	1022	Joe1	dank1	3334343434	Inactive	\N	\N	transferred to lifestyle office left voicemail\n-follow up	1	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
3	Vista del Lago	14465 Vista Del Lago Boulevard	Winter Garden	4072397901	925	\N	\N	\N	Active	\N	https://www.vistadellago.net/	Newsletter link at the bottom of the page. \n-3 lines of text for ad in vendor directory. company, type of work, phone, website. \n-Vendor directory is alphabetical which is good as company name is accurate repairs.	7	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	t
4	Schalamar Creek Golf & CC	4500 US Highway 92 E 1030	Lakeland	8636650185	876	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
5	Hamptons, The	1094 US Highway 92 W	Auburndale	3053582750	829	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
6	Beacon Hill Colony	1112 W Beacon Road	Lakeland	8636885124	708	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
7	Lakeland Harbor	4747 N Road 33	Lakeland	8638582151	700	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
11	Schalamar Creek Golf & CC	4500 US Highway 92 E 1030	Lakeland	8636650185	876	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
12	Hamptons, The	1094 US Highway 92 W	Auburndale	3053582750	829	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
13	Four Lakes Golf Club  Ltd	990 Laquinta Boulevard	Winter Haven	8632992912	814	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
14	Starlight Ranch MH Estates	6000 E Pershing Avenue	Orlando	4072733130	783	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
15	Sherwood Forest Mobile Home Park	5302 W Irlo Bronson Memorial Highway	Kissimmee	4073967600	678	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
16	Shadow Hills Mobile Home Villa	8403 Millinockett Lane	Orlando	4072070076	670	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
17	Swiss Golf & Tennis Club	1 Century Drive	Winter Haven	8632999705	613	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
18	Lake Region MH Village Owners	31850 US Highway 27	Haines City	8634391623	611	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
19	Rock Springs MHP	1820 Rock Springs Road	Apopka	4078866511	555	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
20	Windmill Village	427 Windmill Boulevard	Davenport	8634207177	508	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
21	Deerwood MHP	1575 Pel Street	Orlando	4072825070	507	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
22	Lakeland Harbor	4747 N SR 33	Lakeland	8636886216	506	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
23	Siesta Lago MHV	4750 Siesta Lago Drive	Kissimmee	2486260737	485	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
24	Alafaya Palms	13600 Wesleyan Boulevard	Orlando	4072072239	481	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
25	Ridge, The	49473 US Highway 27 N	Davenport	8634248135	477	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
26	Spring Hill Estates	7500 S County Line Road	Mulberry	8634254410	462	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
27	Woodbrook Estates	1510 W Ariana Street	Lakeland	8636821510	458	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
28	Oakwood Estates	4028 Rolling Oaks Drive	Winter Haven	8632995696	445	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
29	The Groves	6775 Stardust Lane	Orlando	4072996320	442	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
30	Mai Tai Village MHC	7375 Mai Tai Drive	Orlando	4072737020	436	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
31	Tower Lakes Mobile Home Park	2060 US Highway 27 N	Lake Wales	8636781616	418	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
32	Silver Star Village MHP	2530 Hiawassee Road	Orlando	4072930406	406	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
33	Cypress Creek Village	SR 542 Dundee Road	Winter Haven	8632910731	405	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
34	Chalet North MHP	1800 Alpine Drive	Apopka	4078862491	404	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
35	Good Samaritan Village	1550 Aldersgate Drive	Kissimmee	4078467201	400	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
36	Mas Verde MH Estates Inc	2600 Harden Boulevard, Office	Lakeland	8636883028	400	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
37	Hyde Park MHP	14253 W Colonial Drive	Winter Garden	4076569712	396	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
38	Plantation Landings	23 O'Hara Drive	Haines City	8632169419	395	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
39	Angler's Green MHP	3500 State Road 37 N	Mulberry	8634254551	387	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
40	Highland Village MHP	375 Brannen Road	Lakeland	8636468541	385	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
41	Gulfstream Harbor	4505 Old Goldenrod Road	Orlando	4072826340	383	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
42	Swiss Village Mobile Home Park	Old Lucerne Park Road	Winter Haven	8636471581	381	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
43	The Mark, MHP	3200 13th Street	Saint Cloud	4078923979	366	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
44	Hickory Hills Manor MH Park	1601 W Josephine Street	Lakeland	8636865616	366	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
45	Lake Pointe Village, LLC	2000 State Road 37 North	Mulberry	8634255557	363	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
46	Foxwood Village	4700 Foxwood Boulevard, Lot 357	Lakeland	8638590277	356	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
47	Pedaler's Pond	1960 Pedaler's Pond Boulevard, Office	Lake Wales	8634397418	352	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
48	Winter Haven Oaks	5248 Spirit Lake Road	Winter Haven	8632933277	343	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
49	Hidden Golf Club	1 Century Drive	Winter Haven	8632999705	341	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
50	Sterling Mobile Home Park	7 Bridge Boulevard	Lakeland	8636831925	340	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
51	Towerwood Mobile Home Park	22301 Hwy 27 N	Lake Wales	8636766068	330	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
52	Sunshine Village	1234 Reynolds Road	Lakeland	8636653439	329	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
53	Gulfstream Harbor 111	4505 Old Goldenrod Road	Orlando	4072826340	309	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
54	Gulfstream Harbor II	4505 Old Goldenrod Road	Orlando	4072826340	309	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
55	Lakeshore Landings	2000 W 33rd Street	Orlando	4078436827	307	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
56	Whispering Pines	4658 Whispering Pines Boulevard	Kissimmee	4078472407	304	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
57	Hidden Valley MHP	8950 Polynesian Lane	Orlando	4072394755	303	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
58	Heatherwood Village	1925 Harden Boulevard	Lakeland	8636838962	301	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
59	Beacon Terrace	2425 Harden Boulevard #298	Lakeland	8636871695	297	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
60	Royal Palm Village	3000 US Hwy 17/92 W	Haines City	2482082500	297	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
61	May Manor MHC	340 N Brunnell Parkway	Lakeland	8633375007	297	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
62	Lake Juliana Landings	166 Juliana Boulevard	Auburndale	8639841288	285	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
63	Audobon Village MHP	6565 Beggs Road	Orlando	4072911094	280	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
64	Heartland Estates	1701 Commerce Avenue	Haines City	8632680313	278	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
65	Paradise Lakes	426 Apache Trail	Mulberry	8634255175	266	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
66	Cypress Greens	1000 Cypress Creek Boulevard	Lake Alfred	8636512095	262	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
67	Orange Manor West MH Park	18 Kinsmen Drive	Winter Haven	8633245316	253	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
68	Blue Heron Bay	36345 US Highway 27 North	Haines City	8634223157	252	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
69	City Mobile Home Park	199 Edgewood Drive S	Fort Meade	8632852355	245	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
70	Hidden Cove West MHP	Old Lucerne Park Road	Winter Haven	8632944591	243	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
71	Covington Estates	3942 Glenwick Drive	Saint Cloud	4079571720	241	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
72	Kings Manor	1500 W Highland Street	Lakeland	4084235700	240	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
73	Kissimmee Gardens MHP	2552 Tohope Boulevard	Kissimmee	4078464200	239	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
74	Polo Park East R O Association  Inc.	12512 US Highway 27 N	Davenport	8634246932	238	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
75	Winter Haven Mobile Home Park	50 Lake Charlotte Drive	Winter Haven	2397900004	238	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
76	Dell Lake Village	314 Frederick Avenue	Dundee	8634392262	234	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
77	Stoll Manor Mobile Home Park	1123 Walt Williams Road	Lakeland	8638592220	234	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
78	Woodalls Mobile Home Village	2121 New Tampa Highway	Lakeland	8636867462	234	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
79	Brightwood Manor LLC	838 Kelly Park Road	Apopka	4078864747	231	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
80	Kings Pointe Mobile Home Park	100 Winterdale Drive	Lake Alfred	8638004044	229	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
81	Bedrock Citrus Center	1111 W Beacon Road	Lakeland	8632369860	228	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
82	Cypress Cove MHP	4425 Pleasant Hill Road	Kissimmee	4079335870	225	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
83	Oakview Lakes MHP	300 S Washington Avenue	Fort Meade	8632858151	224	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
84	GCP Westside Ridge, LLC	911 Westside Ridge Boulevard	Auburndale	8638004044	224	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
85	Twin Palms Mobile Home Park	301 N Galloway Road	Lakeland	8636868404	222	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
86	Meadowbrook MHP	3801 New Tampa Highway	Lakeland	8638733811	220	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
87	Holiday Mobile Home Park	4141 New Tampa Highway	Lakeland	8636883943	214	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
88	Lake Hammock Village	36106 Hwy 27	Haines City	8634211286	214	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
89	Lakeside Ranch Investment Corp	400 Lakeside Ranch Circle	Winter Haven	8634225844	214	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
90	Ariana Village	1625 W Ariana Street, Lot 16	Lakeland	8636873835	210	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
91	Orange Acres Ranch	5130 A B C Road	Lake Wales	9417561800	210	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
92	Bali Hai MHP	5205 Kailua Lane	Orlando	4078556249	206	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
93	Country Life MHP LLC	1320 Roscoe Drive	Kissimmee	4079320898	206	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
94	Breit Orange Manor MHC LLC	206 Orange Manor Drive	Winter Haven	8633242470	205	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
95	Palm Key Village	48097 US Highway 27 N	Davenport	8634209700	204	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
96	Country Club Village MHP	1080 Jack Calhoun Drive, Stop 202	Kissimmee	4079332494	201	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
97	Beacon Hill Colony	1112 W Beacon Road	Lakeland		201	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
98	Sunlake Terrace Estates	6555 Old Lake Wilson Road	Davenport	8634249504	201	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
99	Imperial Manor Mobile Home Terrace	2321 New Tampa Highway	Lakeland	8636832556	200	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
100	Fountainview Mobile Home Park	600 Fountainview Drive S	Lakeland	8638159415	197	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
101	Lakeland Junction MHP	202 East Griffin Road	Lakeland	8632826754	194	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
102	Haines City Mobile Home Park	753 W Main Street	Haines City	8634222475	192	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
103	Colonial Village MHC LLC	2105 Harrell Road	Orlando	4072730800	187	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
104	Angler's Cove MHP	944 Reynolds Road, Box 380	Lakeland	8636658687	187	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
105	Whispering Pines	101 Sunshine Drive	Frostproof	8636355200	185	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
106	Oak Ridge Village MHP	5945 Nomad Avenue	Orlando	4078511712	184	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
107	Sugar Mill Mobile Home Park	3130-A Sugar Mill Lane	Saint Cloud	4079573055	179	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
108	Sundance Village MHP	1400 Banana Road	Lakeland	8638586806	174	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
109	Ridge Manor	1301 Polk City Road	Haines City	8634221069	171	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
110	Woodland Lakes	1901 US Hwy 17/92 W	Lake Alfred		167	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
111	Trailer City MHP	21 E Crest Avenue	Winter Garden	4076561252	166	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
112	Bonny Shores	164 Bonny Shores Drive	Lakeland	8636650640	165	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
113	Sherwood Mobile Home Park	1200 North Davis Avenue	Lakeland	8636860817	160	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
114	Tranquil Acres MHC LLC	70 Avenue E. N	Auburndale	8635351770	154	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
115	Angler's Cove West MHP	944 Reynolds Road	Lakeland	8636471581	153	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
116	Walden Shores	2204 Thoreau Drive	Lake Wales	8636967100	152	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
117	The Valley MHP	5100 Round Lake Road	Apopka	4078801212	148	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
118	Greenbrier Village MHP	2120 Duff Road	Lakeland	8638581403	146	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
119	Cypress Gardens MH & RV Park	1951 Lake Daisy Road	Winter Haven	8633243136	143	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
120	Granite Lucerne Lakeside LLC	39 1/2 Azalea Drive	Winter Haven	2392915794	140	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
121	Sugar Mill North	88 Nesting Loop	Saint Cloud	4078917350	139	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
122	Tamarack East Mobile Home Park	2312 S Goldenrod Road	Orlando	4072750553	135	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
123	Floridian Sandalwood MHC	5150 Boggy Creek Road	Saint Cloud	4078925171	131	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
124	Southern Pines RV & MHP Resort	1622 C R 630 West	Frostproof		131	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
125	Lake Deer Mobile Hamlet	3301 Avenue G NW	Winter Haven	8632941844	130	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
126	Magnolia Estates of Cen Fla	5600 Jaleen Avenue	Orlando	4072933021	129	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
127	Carriage Court East	3475 Goldenrod Road	Orlando	4072070076	128	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
128	Ariana Shores Mobile Home Park	116A Paradise Lane	Auburndale	8639654574	128	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
129	Kissimmee South	3700 US Highway 17 92 N	Davenport	8634241286	127	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
130	Shangri La Mobile Estates	2850 New Tampa Highway, Suite 74	Lakeland	8636833317	124	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
131	Tower Manor MHP	11 Tower Manor Drive	Auburndale	8632678688	124	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
132	Valencia Estates MHP	547 Drage Drive	Apopka	4078865776	122	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
133	Cypress Shores East	3275 US Highway 92 West	Winter Haven		122	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
134	Hidden Cove MHP	SR 544	Winter Haven	8632944591	122	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
135	Palm Isles Mobile Home Village	1820 Rock Springs Road	Apopka	4078866511	120	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
136	Enchanted MHP, LLC	5137 N Scenic Highway	Lake Wales	8634393911	120	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
137	Martin Estates	114 Martin Drive	Lakeland		119	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
138	Carriage Court Central	4820 W Oak Ridge Road	Orlando	4073510336	118	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
139	Shipp Reck Harbor MH Park	1600 S Lake Shipp Drive	Winter Haven	8636826326	112	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
140	Conway Circle MHP	5326 Kingfish Street	Orlando	4078551461	111	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
141	Central Park II of Haines City	1101 Commerce Avenue	Haines City	8634212622	110	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
142	Orange Tree MHP Inc	749 S Park Avenue	Winter Garden	4075902575	108	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
143	Bedrock Emerald Lake, LLC	200 Jeremy Drive	Davenport	8634245260	108	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
144	Kings & Queens MHP	2808 N Florida Avenue	Lakeland	8636887451	107	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
145	Pleasant Hill Village	2100 Pleasant Hill Road	Kissimmee	4079350098	106	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
146	Bedrock Lake Bonny LLC	30 Bonisee Circle	Lakeland	8139065345	106	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
147	Colony Club Estates	1501 11th Street NE	Winter Haven	4436219757	105	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
148	Lake Blue	713 Rose Street	Auburndale	8639670402	105	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
149	Pine Ridge Estates	7405 N Socrum Loop Road	Lakeland	8638587177	105	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
150	Parakeet Mobile Home Park	2400 Parakeet Park Boulevard	Lake Wales	4252607680	104	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
151	Oak Hammock Mobile Home Park	2455 US Highway 17 S	Bartow	8635338288	103	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
152	S-P Mobile Home Park	780 W Davidson Street, Suite A	Bartow	8635331271	102	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
153	Medallion Mobile Park	1315 Vagabond Lane	Orlando	4072866615	101	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
154	Jade Isle MHC	325 Rosedale Avenue	Saint Cloud	4078922322	101	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
155	NHC FL 207  LLC DBA The Hills MHP	1100 S Roger Williams Road	Apopka	4078868787	100	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
156	Bedrock Colonial, LLC	745 Pinewood Avenue	Lakeland	8636004555	100	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
157	Lakemont Ridge Home & RV Park	2000 Maine Street	Frostproof	8634124355	99	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
158	College Park MHP	4639 US Hwy 27 S	Lake Wales	8136776622	99	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
159	Lakeland Estates MHC	224 Tyler Avenue	Lakeland	8636866311	98	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
160	Palms Village	1610 S Orange Blossom Trail	Orlando	3059250225	97	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
161	Valencia Mobile Home Park	226 South Washington Street	Fort Meade	7273753420	95	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
162	Palm Shores Mobile Village Inc	1 East Lane	Lake Alfred	8639562162	94	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
163	Lake Deeson Mobile Home Park	5210 N State Road 33 108	Lakeland	8633981771	93	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
164	Windsor Mobile Home Village	4630 S Orange Blossom Trail	Kissimmee	4079335331	92	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
165	Sunset by the Lake	180 Sunset Drive NW	Lake Alfred	8632165323	91	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
166	El Camba Mobile Home Park	1841 George Jenkins Boulevard	Lakeland	8636866444	90	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
167	Pine Lake Mobile Home Park	7805 US Highway 98 North	Lakeland	8636451206	90	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
168	Royal Oaks MH & RV Travel Resort	1012 Dundee Rd W SR 542	Dundee	8634395954	90	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
169	Happy Day Trailer Park	1311 Us 92 W	Auburndale	8639674298	90	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
170	Peace River Village	2405 State Road 60 E, Lot 21	Bartow	8635337823	88	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
171	Sharps MHP	5620 Lake Lizzie Drive, Lot 1	Saint Cloud	4079576896	87	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
172	Lake Burbank Village	2105 Bruce Street	Lakeland	4019421538	86	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
173	Valencia Estates MHP	3325 US Hwy 98 South	Lakeland	8636651611	86	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
174	Bartow Mobile Home Park	1510 East Georgia Street, Suite 2	Bartow	8635333090	84	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
175	Lake Alfred Mobile Home Park	670 E Alfred Drive	Lake Alfred	2033495747	84	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
176	Melody Acres 1	5500 New Tampa Hwy	Lakeland	8134860995	84	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
177	Hidden Cove East MHP	Old Lucerne Park Road	Winter Haven	8632944591	83	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
178	Cypress Shores West	3255 US Highway 92 West	Winter Haven		82	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
179	Kissimmee River Park and Marina	3800 Bruce Boulevard	Lake Wales	8636963182	82	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
180	Cypress Harbor Mobile Home Pk	3400 Cypress Gardens Road	Winter Haven	8008467162	81	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
384	Victoria Gardens	1117 S CHRISTIANA Avenue	Apopka	4078876222	14	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
181	May Grove Mobile Home Park	1725 Gibsonia Galloway Road	Lakeland	8638585826	81	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
182	Whidden Mobile Home Park #1	400 CR 630A	Frostproof	3025591995	81	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
183	Central Leisure Lake	58 Leisure Drive	Auburndale	8636653855	80	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
184	Grove Shores Mobile Colony	83 Stebbins Drive	Winter Haven	8633241400	80	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
185	Florida Holiness Campground W	3335 South Florida Avenue	Lakeland	8636465152	79	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
186	Hammock Lake Mobile Estates	1801 US Highway 17 S	Fort Meade	8632859560	79	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
187	Oakhill Mobile Home Community	1331 Oakhill Street	Lakeland	3862410301	79	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
188	Lake Shore Village	4127 N Orange Blossom Trail	Orlando	4076167757	78	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
189	Lake Fox Village LLP	4950 Cypress Garden Road	Winter Haven	8633245689	78	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
190	Whispering Oaks Mobile Home Park	1510 N Royal Street	Kissimmee	4079332350	76	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
191	Sherwood Forest RV Park	5300 W Irlo Bronson Memorial Highway	Kissimmee	4073967600	76	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
192	Christmas Tree Trailer Park	2400 Hutchins Road	Fort Meade	8637732122	76	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
193	Town and Country MHP	4448 N Orange Blossom Trail	Orlando	4072916700	75	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
194	Oak Crest Mobile Park	5455 W Washington Street	Orlando	4072952090	75	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
195	Scenic View Mobile Home Park	2025 W Daughtery Road	Lakeland	8638594521	75	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
196	Lake Runnymede MHP	1316 W Rosewood Avenue	Saint Cloud	3053890873	74	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
197	Chapman's MHP	5600 New Tampa Highway	Lakeland	8134860995	74	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
198	Oak Harbor Campground & Mobile Home Park	10000 W Lake Lowery Road	Haines City	8639561341	73	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
199	Hickory Lake Estates	1640 S Scenic Highway	Frostproof		71	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
200	Lake Kissimmee Mobile Home Pk	Camp Lester Road, Lot 69	Lake Wales	4077060322	71	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
201	Osceola Mobile Village	2660 N Orange Blossom Trail	Kissimmee	4078474690	70	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
202	Jennings Resort Inc	4325 Jennings Fish Camp Road	Lake Wales	8634393811	70	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
203	Minerva Mobile Home Park	2800 US HWY 17 92 W	Haines City	9169892800	70	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
204	Lake Marian Resort LLC	901 Arnold Road	Kenansville	4074361464	69	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
205	Colonial Mobile Home Park	5595 E Irlo Bronson Memorial Highway	Saint Cloud	4078923291	67	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
206	Garden Mobile Village	2026 15th Street SW	Winter Haven	8632997193	67	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
207	Chelette Manor	2300 State Road 60 E	Lake Wales	8634520382	64	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
208	Sandy Shores MHP	4765 Sandy Shores Drive	Orlando	3523859110	63	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
209	Westwood Village	850 Swallowtail Drive	Winter Garden	4076566543	63	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
210	Tanglewood Village MH Park	2230 Tanglewood Drive	Lakeland	4076548675	63	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
211	Lake Downey Mobile Home Park	1410 N Dean Road	Orlando	4078765555	62	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
212	Jackson Square MHP	205 W Donegan Avenue	Kissimmee	4078476233	61	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
213	BEDROCK SUNNY PINES LLC	5902 N ORANGE BLOSSOM Trail	Mount Dora	3523833435	60	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
214	Bob's Landing MHP & Marina	903 Ohlinger Road	Babson Park	8636381912	60	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
215	Briarwood Estates MHP	5310 Deeson Road	Lakeland	4078763990	60	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
216	Camp Rosalie	3000 Camp Rosalie Road	Lake Wales	8635892067	59	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
217	Eaton Park MH Rentals	3301 Maine Avenue	Lakeland	8635592005	58	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
218	Conestoga MHP	5650 W Colonial Drive	Orlando	4072968400	57	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
219	Highlands Mobile Home Park	401 W Donegan Avenue	Kissimmee	4078473557	56	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
220	Citrus Grove MHP, LLC	1419 Steve Lane	Lake Wales	7722213500	56	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
221	Lake Toho Resort	4715 Kissimmee Park Road	Saint Cloud	4078928795	55	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
222	Granite Fish Haven LLC	201 Fish Haven Road	Auburndale	8639841183	55	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
223	Wheel Estates Mobile Manor	5225 S Orange Blossom Trail	Orlando	4073510336	54	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
224	Lakeside Gardens	13897 US Hwy 27	Lake Wales	8139494139	54	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
225	Leisure Homes MHP	1675 Lynchburg Road	Lake Alfred	8632071221	54	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
226	Palms Mobile Home Park	1805 US Highway 92 W	Auburndale	8139713750	54	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
227	Buccaneer Bay MHC LLC	643 Mathew Road	Lakeland	8634308744	54	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
228	Pine Isle Mobile Villa	607 N Pine Isle Drive	Orlando	4075684321	53	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
229	Oak Meadows MH & RV Park	3655 E Johnson Avenue	Haines City	8132672672	53	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
230	Frostproof Mobile Village	981 Ulmer Road, Lot 117	Frostproof	8636354800	53	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
231	Land South Oak Meadows LLC	8535 Mathews Road	Lakeland	8638597942	52	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
232	Sunset Cove	2410 US Highway 92 W	Winter Haven	8632681111	52	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
233	Sunset Shores Co-Op Inc	1000 S Clinch Lake Boulevard	Frostproof	8636352420	51	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
234	Orlando WFH I LLC d/b/a Ariel Gardens	4655 Teresa Road	Orlando	3212397760	50	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
235	Paradise Palms	3710 Old Tampa Highway	Lakeland	7034037774	50	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
236	Sanlan RV Park	3929 US Highway 98 S	Lakeland	8636651726	50	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
237	Golden Grove MHP	1101 Golden Parkway	Saint Cloud	4079577979	49	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
238	Golden Wings MHP	2709 Providence Road	Lakeland	8636860736	46	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
239	Hilltop Rentals LLC	20 Oleander Circle	Lakeland	8636830459	46	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
240	Lake Wales MHP	705 Scenic Highway N	Lake Wales	8632238011	46	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
241	21 Palms R.V. Resort	6951 Osceola Polk Line Road	Davenport	4073979110	45	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
242	Sun Friendly Community Village	2504 Sunset Drive	Kissimmee	4075747775	45	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
243	Camp Tiger Fish Camp	1731 Sam Keene Road	Lake Wales	8636921586	45	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
244	Country Villa	5435 Lewellyn Road	Lakeland	4073423851	45	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
245	Mouse Mountain RV Resort	7500 Osceola Polk Line Road	Davenport	8634242791	45	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
246	Coach Light Villa Mobile Home Park	1900 S Reedy Boulevard	Frostproof	7274014625	44	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
247	Willow Oak II MHP	3845 State Road 60 W	Mulberry	8633541155	43	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
248	Browns Rolling Home Estate	2540 N John Young Parkway	Kissimmee	5612787073	42	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
249	Lakeland Gardens MH Park	3741 Old Tampa Highway	Lakeland	8633046849	42	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
250	Green Acres Mobile Home Park	4331 Lake Buffum Road	Lake Wales	9414290116	41	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
251	Townsley Estates	200 E Robson Street	Lakeland	3072222472	41	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
252	Winterset Shores Estates	SR 540A Hummingbird Lane	Winter Haven	8632062383	41	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
253	Terio's Mobile Home Park	3520 E Gaskin Road lot 1	Bartow	8635333359	40	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
254	Lakefront Mobile Home Park	Highway 630 A	Frostproof	8636353974	39	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
255	Grape Hammock RV & MH Park	1400 Grape Hammock Road	Lake Wales	8636921500	38	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
256	College MHP	16268 E Colonial Drive	Orlando	4075741088	37	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
257	Rainbow RV Resort	700 CR 630A	Frostproof	8636357541	37	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
258	Evergreen Motel & MH Park	6650 New Tampa Highway	Lakeland	8636984910	36	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
259	Reedy Haven Trailer Park	285 Lake Avenue	Frostproof	8636354783	36	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
260	Ten Rocks Mobile Home Park	3925 N Combee Road	Lakeland	7042998878	36	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
261	Harrison Trailer Park	3414 Walker Road	Apopka	4078892437	35	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
263	Pleasant View Mobile Home Park	2251 Ft Meade Road	Frostproof	8636353650	35	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
264	Southwinds Mobile Home Court	1425 Ritter Road	Lakeland	8632552941	35	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
265	Lakemont Shores	285 Lake Avenue	Frostproof	8134465421	35	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
266	Charlin Park Community	4740 Dunkeld Avenue	Orlando	3219461056	34	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
267	El Tonteria Mobile Court	1520 Parsons Road	Kissimmee	4073192900	34	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
268	G & H Mobile Home Park	1501 G and H Drive	Kissimmee	4079324348	34	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
269	Whidden Mobile Home Park #2	400 CR 630A	Frostproof	3025591995	34	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
270	Highland Park Community	18721 US Hwy 27	Lake Wales	4073107599	34	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
271	Holiday Acres Mobile Home Park	325 Holiday Acres Drive	Orlando	4075688617	33	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
272	Cypress Shores Gardens Mobile Home Park	5864 Cypress Shores Court	Orlando	4075440825	33	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
273	Mill Creek R.V. Resort	2775 Michigan Avenue	Kissimmee	4078476288	33	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
274	Lake Clinch Mobile Home Park	14 Lake Street	Frostproof	8636355874	33	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
275	Midway RV	5100 E Johnson Avenue	Haines City	8139676316	33	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
276	Garden Gate Mobile Home Park	27881 US Hwy 27	Dundee	9169892800	33	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
277	Twelve Oaks Mobile Home Park	3345 N Florida Avenue	Lakeland	8638089082	33	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
278	Camino Park LLC	5316 Edgewater Drive	Orlando	4072976865	32	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
279	Overland Village LLC	3303 Overland Road	Apopka	4076167757	32	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
280	Lakeland Village	4535 US Highway 92 East	Lakeland	8636657151	32	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
281	Florida Camp Inn	48504 US Highway 27	Davenport	8634242494	32	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
282	Cypress Knee Cove MHP	3300 Canal Road	Lake Wales	8633531611	32	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
283	Outpost, The	2250 US Highway 92 West	Winter Haven	8632681111	31	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
284	Sundance Mobile Home Park	396 W Jackson	Kissimmee	4074431014	30	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
285	Shady Oaks Mobile Home Park	1215 US Highway 17 92 N	Davenport	8634211559	30	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
286	Shady Oaks Mobile Home Park	3245 E Main Street	Lakeland	8638383893	30	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
287	Southern Oaks	3276 Mt Tabor Road	Lakeland	8632552941	30	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
288	Spring Lake Estates LLC	3731 State Road 60 E	Lake Wales	4079009986	30	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
289	Frostproof Mobile Village	375 West H Street	Frostproof	8636354800	29	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
290	South Orange Avenue Trailer Park	2820 S Orange Avenue	Orlando	3216961785	28	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
291	Oak Haven MHP	1630 North CR 547	Davenport		28	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
292	Harbor Waterfront Resort, The	10511 Monroe Court	Lake Wales	8636961194	28	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
293	Buckland Mobile Home Park #1	1111 Us Hwy 17/92	Davenport	4074502252	28	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
294	Croft Mobile Home Park	2856 Brooks Street	Eaton Park	8636656921	27	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
295	Willow Oak Mobile Home Estates	2696 Regel Loop	Mulberry	8633541155	27	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
296	Tenoroc Park LLC	3015 Tenoroc Mine Road	Lakeland	7023553338	27	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
297	Hilltop Mobile Home Park	6101 Beggs Road	Orlando	4072900196	26	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
298	Zellwood Station and Country C	2126 Spillman Drive	Zellwood	4078860000	26	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
299	Arrow Wood MHP	3305 Skyview Drive	Lakeland	8638658751	26	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
300	Camp Lester Inc	14400 Reese Drive	Lake Wales	8636961123	26	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
301	Cypress Acres MHP	8 Powell Road	Winter Haven	8632910643	26	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
302	Pleasant Ridge Mobile Home Pk	330 Bracey Road	Lakeland	8635817231	26	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
303	Rainbow Chase RV Resort	6300 W Lake Wilson Road	Davenport	8634242688	26	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
304	Uncle Joes Fish Camp	4535 Walk In Water Road	Lake Wales	8636961101	26	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
305	Hillcrest Village	6185 Beggs Road	Orlando	4076167757	25	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
306	J & C MHP	973 N Belvedere Road	Orlando	4078988986	25	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
307	Bermuda MHP	2528 N John Young Parkway	Kissimmee	5612787073	25	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
308	Kings Mobile Park	2410 Old Vineland Road	Kissimmee	4073907562	25	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
309	Wagon Wheel Mobile Home Park	1410 S Hoagland Boulevard	Kissimmee	4079286002	25	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
310	Bailey Place MHP	2420 Bailey Road	Mulberry	8634252281	25	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
311	Hammondell Campgrounds	5601 Cypress Gardens Road	Winter Haven	8633245775	25	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
312	Lighthouse Oaks	5900 New Tampa Highway	Lakeland	8636837518	25	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
313	Lazy Dazy Recreational Veh Pk	6211 US Highway 98 North	Lakeland	8638582026	25	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
314	Pine Grove Mobile Home Park	2245 New Tampa Highway	Lakeland	8134948240	25	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
315	Siesta Palm Estates	1117 N Grady Avenue	Lakeland	8133712991	25	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
316	Lockhart MHP	6721 N Orange Blossom Trail	Orlando	4072998595	24	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
317	Florida Holiness Campground E	116 Hillsboro Street	Lakeland	8636465152	24	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
318	Highland Pines Mobile Home Pk	5616 3rd Street SE	Highland City	8635592005	24	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
319	Good News Mobile Home Park	101-145 7th Street	Eloise	8639673992	23	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
320	Shepherd Retirement Community	N Lk Reedy Blvd & Arbuckle Rd	Frostproof	8636355414	23	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
321	New Harmony Mobile Home Park	3105 Perry Loop	Lake Wales	8636324798	23	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
322	Remy Florida Group LLC	6035 Norton Road	Lakeland	4168291075	23	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
323	Ecovillage Real Estate LLC	2715 Providence Road	Lakeland	5104993938	23	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
324	Chester Dees Mobile Home Park	41 S 30th Street	Haines City	8637123770	23	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
325	Woodland Oaks	425 Woodland Avenue	Lakeland	7082576009	23	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
326	Shady Oaks MHP	15267 E Colonial Drive	Orlando	4075684670	22	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
327	Lakeview Terrace Mobile Home Park	6070 Alligator Lakeshore W	Saint Cloud	4078922698	22	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
328	Peak Haven	5480 Johnson Avenue	Haines City	8634225209	22	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
329	Dogwood Villa	5252 New Tampa Highway	Lakeland	2174128787	22	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
330	Rosemont Mobile Home Park LLC	145 Bomber Road	Wahneta	8636980042	22	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
331	Williams Park Venture I, Inc - DBA/ Union Drive MHP	405 Union Drive	Lakeland	8636984910	22	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
332	Kodiak Park, LLC	2805 Mineola Drive	Lakeland	8136512380	22	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
333	Melody Acres 2	5270 New Tampa Highway	Lakeland	8134860995	22	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
334	Limetree RV Park	444 Rawles Avenue	Orlando	4075681939	21	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
335	Glenn Road MHP	514 Glenn Road	Orlando	4075684579	21	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
336	Fairview Gardens Mobile Home Park	3550 N Orange Blossom Trail	Orlando	4075440825	21	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
337	Rifle Range Mobile Home	403 Rifle Range Road	Wahneta	8633242536	21	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
338	Carter Road MHP	111 W Carter Road	Lakeland	8132302235	21	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
339	Cauleys Mobile Home Park	3731 Old Tampa Highway	Lakeland	8637592242	20	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
340	G & H Mobile Home Park	4105 Ryals Road	Mulberry	8637735687	20	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
341	Norman Village	23 Tennessee Lane	Auburndale	8632991048	20	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
342	Estates at Reynolds Rd, The	1707 Reynolds Road	Lakeland	8635132549	20	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
343	Gifford Mobile Home Park	2615 Tanglewood Street	Lakeland	8636989974	20	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
344	Recker MHP, LLC	340 Recker Highway	Auburndale	6199806616	20	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
345	Holiday Park Mobile Home and RV	25 Hartman Road	Lake Wales	4076878272	20	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
346	Eagle Ridge MH/RV Park	2901 Shell Road	Lake Wales	8636766820	19	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
347	Lake Juliana Boating & Lodging	600 Lundy Road	Auburndale	8639841144	19	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
348	Sunny Acres	1400 US Hwy 17 N	Fort Meade	7276438397	19	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
349	Nona Global Park	6590 Narccoossee Road	Orlando	3212314103	18	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
350	Kennard MHP	3800 US Highway 17 92 W	Haines City	8636984910	18	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
351	Lake Parker Court	1140 E Lemon Street	Lakeland	9046742417	18	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
352	Lakemont Ridge II Home & RV Park	2000 Maine Street	Frostproof	8632143981	18	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
557	Eagle Trailer Park	1250 Payne Street	Auburndale	8636880606	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
353	P and R Holdings of Polk County LLC II	1640 Fish Hatchery Road	Lakeland	8638163879	18	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
354	Lakeland Palms	2965 New Tampa Highway	Lakeland	8633335390	18	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
355	Sunshine Acres	4010 Spiker Lane	Lake Wales	5865494637	18	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
356	Pine Lake Homes	4845 S Orange Blossom Trail	Kissimmee	4073194017	17	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
357	Sunnyside Mobile Home & RV Park	208 Clairmar Circle	Davenport		17	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
358	P and R Holdings of Polk County LLC I	3015 Ralph Road	Lakeland	8638163879	17	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
359	Pinewood Lane Mobile Home Park	192 Pinewood Lane	Lake Alfred	4073966493	17	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
360	Shipp Side MHP	1849 7th Street SW	Winter Haven	8639652951	17	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
361	Bert's Hideaway Resort	2854 Tindel Camp Road	Lake Wales	8634397570	16	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
362	Bomber Properties	135 Bomber Road	Eloise	8632939888	16	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
363	Butler Mobile Home Park	6227 Old Polk City Road	Haines City		16	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
364	Natures Cove	15 Fletcher Fish Camp Road	Haines City	8634222508	16	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
365	Hoosier Park	2735 West 10th Street	Lakeland	8638538761	16	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
366	Kathleen Oak MHP	3625 Kathleen Road	Lakeland	8638596630	16	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
367	Tice Mobile Home Park	710 N 91 Mile Road	Bartow	8635334920	16	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
368	Cherry Pocket Fish Camp	3100 Canal Road	Lake Wales	8634392031	16	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
369	Oakdale MHP	3325 Youngs Ridge Road	Lakeland	8638991762	16	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
370	Lake Drive Trailer Park	268 N Lakeshore Drive	Ocoee	5555555555	15	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
371	South Shore Mobile Home Park	17525 Broad Street	Winter Garden	4076450684	15	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
372	Orlando East Mobile Home Park	15169 E Colonial Drive	Orlando	5109135529	15	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
373	Arizona Holding I LLC dba Arizona Mobile Home Park	415 Arizona Avenue	Lakeland	8139188399	15	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
374	Reedy Lake Parks, LLC Mobile Home Park	2011 N Lk Reedy Box 0 Boulevard	Frostproof	8636353546	15	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
375	Hilliard Mobile Home Park	217 Hilliard Lane	Loughman	8634245825	15	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
376	Lake Mattie Mobile Home Park	563 Cone Road	Auburndale	8635591299	15	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
377	Palms MHP, The	4230 State Road 60 West	Mulberry		15	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
378	Windy Beach Mobile Home Park	425 Longfellow Boulevard	Lakeland	8636196677	15	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
379	Sunset by the Lake II	1203 Lynchburg Road	Lake Alfred	8632165323	15	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
380	Killarney MH & RV Park	J W Jones Rd	Killarney	4076562525	14	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
381	Hickory Heights TP	950 Orange Plaza	Killarney	4076562525	14	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
382	Lake Apopka Trailer Park	950 Orange Plaza	Killarney	4076562525	14	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
383	Rao's Property LLC	18843 Lansing Street	Orlando	2013205593	14	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
385	Harrys Harbor	3136 N Marina Parkway	Lake Wales	8636961843	14	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
386	Rifle Range Mobile Home Park	119 Monroe Road	Winter Haven	8633242100	14	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
387	T & M's Mobile Home Park	400 Block Lee Street	Auburndale	8639675766	14	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
388	Senate St. Mobile Home Park	412 1/2 Senate Street	Auburndale	4072477627	14	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
389	Flamingo Trail Corp	6512 N Orange Blossom Trail	Orlando	4072990371	13	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
390	K Brantley MHP	17488 Monroe Partin Road	Orlando	4076574742	13	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
391	2505 Tanglewood Street Inc	2505 Tanglewood Street	Lakeland	8636688967	13	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
392	Pine Cove Mobile Home Park	334 Recker Highway	Auburndale	8635513529	13	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
393	Cypress Inlet	2600 W Lake Eloise Drive SE	Winter Haven	8633189300	13	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
394	Oakwood MHP	4975 New Tampa Hwy	Lakeland	3475040999	13	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
395	Gourd Neck Village	17505 - 17548 Cottage Court	Killarney	4076562595	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
396	Hillard Lake Marian Country Campground	25 S Canoe Creek Road	Kenansville	4073612035	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
397	Forest Oak Estates	3804 N Florida Avenue	Lakeland	8636828792	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
398	Brookwood MHP	2985 Cornelius Court	Lakeland	8635592005	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
399	Bud's RV Park & Marina	1700 Tiger Lake Road	Lake Wales	8636962274	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
400	Dan's Mobile Home Park	US 27 S of Lake Wales	Lake Wales	8636792562	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
401	G & S Park	1 Harrell Road	Winter Haven	8145634005	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
402	Lake Dale Mobile Home Park	1122 McCampbell Road	Auburndale	8636045789	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
403	Lake Front Mobile Home Park	2500 US Highway 92 West	Winter Haven	8639564024	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
404	Mid Lakes Mobile Home Park	6509 Thornhill Road	Winter Haven	8632932595	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
405	Price Trailer Rentals	515 Woodland Avenue	Lakeland	8636662694	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
406	Sunshine MHP at Lake Alfred	600 Mosley Road	Lake Alfred	3216951288	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
407	Smokey Valley MHP	225 Ed Padgett Road	Lakeland	8638592564	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
408	Phoenix Mobile Home Park	4440 Academy Drive	Mulberry	8634253500	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
409	Homestead Mobile Home Park, The	1800 US Highway 17 N	Bartow	8635331051	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
410	Lake Bonny Oaks	215 Arizona Avenue	Lakeland	8139676316	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
411	Sunrise at the Lake MH/RV Park LLC	20 Graner Drive	Frostproof	2073185325	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
412	Brooklyn Meadows	1535 Duff Road	Lakeland	3476993385	12	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
413	Orlando Lake Front RV Park, LLC	3405 N Orange Blossom Trail	Orlando	4079364094	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
414	Lake Jennie Jewel Mobile Court	3430 S Lake Street	Orlando	4079218484	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
415	Cedarhurst MHP	18247 Cedarhurst Rd.	Orlando	3213200435	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
416	Lake Ida Mobile Home Park	2854 US Highway 17 N	Winter Haven	8633977997	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
417	Fairfax Mini Park	3404 Fairfax Park Place	Lakeland	8636045789	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
418	G & G Mobile Home Park	3303 East Johnson Avenue	Haines City	8634195827	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
419	Helen's Mobile Home Park	725 Chestnut Road	Lakeland		11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
420	El Rancho Mobile Home Park	4837 Deeson Road	Lakeland	8636988650	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
421	Jerico Mobile Home Park	Jerico Road	Auburndale	8639689223	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
422	Magana's Mobile Park	3491 E Hinson Avenue	Haines City	8634200106	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
423	River Ranch Inns & Cottages	6 Egret Lane	River Ranch	8636822424	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
424	Serene MH Court	2412 Broadway Street	Lakeland	8632485454	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
425	United Trailer Park	120 S Fortner Avenue	Lakeland	8636888801	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
426	Cozy Court Motel & MHP & RV	407 Woodland Avenue	Lakeland	8636654179	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
427	Crescent Court MHP A	527 W Crescent Drive	Lakeland	7036566028	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
428	A-OK Campground	6925 Thornhill Road	Winter Haven	5162442157	11	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
429	Sundown Trailer Park	265 S County  Road    13	Orlando	4075687388	10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
430	Carpenter Road Mobile Home Park	727 Carpenter Road	Orlando	4074251996	10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
431	Chisolm Trailer Estates	9400 8th Avenue	Orlando	4078591386	10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
432	Tip Top Mobile Home Park	4395 Helen Street	Kissimmee	4079322949	10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
433	Dranefield Mobile Home Park 1	3939 Hamilton Road	Lakeland		10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
434	Haskell Park	Haskell Homes Loop/ 540A	Lakeland	8636442193	10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
435	Laureti Park	3813 State Road 60 East	Lake Wales		10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
436	Colorado Court	118 Colorado Avenue	Lakeland	8635592005	10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
437	M & M Park LLC	5800 New Tampa Highway	Lakeland		10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
438	A & B RV & MHP	230 M Haire Lane	Auburndale	8636651115	10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
439	St Clairs Resort	9696 St Clair Road	Haines City	4073966493	10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
440	Yeats MHP LLC	2327 Yeats Street	Lakeland	8639340595	10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
441	J & M Mobile Home Park	1335 Bell Avenue	Lakeland	3216249542	10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
442	The Mobile Home Park LLC	1917 Marjorie Street	Lakeland	8635593329	10	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
443	City of Lake Buena Vista TP	2010 Royal Oak Court	Orlando	4078287272	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
444	City of Bay Lake TP	Bay Court Road	Lake Buena Vista	4078282034	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
445	Deharts Trailer Park	255 S County 13 Road	Orlando	4075687636	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
446	Wilson's Trailer Park	17400 Wilson Road	Orlando	4077193741	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
447	Sterling Park	1981 Ham Brown Road	Kissimmee	4079081855	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
448	Auburndale Parks Inc	802 West Bridgers Avenue	Auburndale	8639689313	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
449	Char-el Mobile Home Park LLC	2600 West Highland Street	Lakeland		9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
450	Lakeside Mobile Home Park	2501 Huddleston Lane	Auburndale	8636657783	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
451	Midway Mobile Home Park	Rt 2 Box 1131 McCampbell Road	Auburndale	8633189999	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
452	Paul's Mobile Park	3800 US Highway 17 92 W	Haines City	8636984908	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
453	Peachtree Park MHP	2125 Reynolds Road	Lakeland	8637090880	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
454	Peachtree Mobile Home Park	2422 E Peachtree Street, Office	Lakeland	8138333157	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
455	J & B Rentals	Grady & Parker	Lakeland	8638580213	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
456	Tropical Moon Mobile Home Park	612 Old Dixie Highway	Auburndale	8638155408	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
457	Timothy Ricketts & Shawn Ricketts	714 Woodland Avenue	Lakeland	8636688787	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
458	Shirah Estates	2202 Shirah Road, Lot 9	Auburndale	8639659300	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
459	Countryside Mobile Home Park	2410 State Road 540A	Lakeland	8636700099	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
460	Butch's Hideaway	2649 Mar Lisa Cove Road	Lake Wales	2252869463	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
461	Green Acres	6025 New Tampa Highway	Lakeland	8132302235	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
462	Buckland Mobile Home Park #2	1111 Us Hwy 17/92	Davenport	4074502252	9	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
463	Cozy Cove MHP	4025 N Orange Blossom Trail	Orlando	4074355848	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
464	Zegon Mobile Home Park	3440 Wynn Lane	Kissimmee	4079089600	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
465	Johnson Rainbow Trailer Park	5515 S Orange Blossom Trail	Intercession City	4079338394	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
466	Lakeside Mobile Home Park	5698 S Orange Blossom Trail	Kissimmee	4073907562	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
467	Shady Oaks Park	2400 Old Vineland Road	Kissimmee	4073907562	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
468	Williams Mobile Home Park	2725 Lake Vista Drive	Kissimmee	4073444417	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
469	Pine Crest MHP	2035 Reynolds Road	Auburndale	8639673258	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
470	New Beginning MHP	1215 Plant Avenue	Lakeland	8633980895	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
471	Crystal Lake Mobile Home Park	2910 Goodyear Avenue	Lakeland	8136906665	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
472	Westwood Baptist Village	32nd Street, NW	Winter Haven	8632933400	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
473	First Freewill Baptist Church	5531 3rd Street SE	Highland City	8636463093	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
474	Care Properties LLC	1505 Goodyear Avenue	Lakeland	3524756285	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
475	Grove Park Lane MHP	610 Cameron Road	Winter Haven	8632872318	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
476	Lake Millsite Estates LLC	310 Lake Millsite Road	Bartow		8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
477	J.B.'s Mobile Home Park	5445 State Road 60 E	Bartow	8635371548	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
478	Mulberry Estates	2880 2nd Avenue	Mulberry	8139862644	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
479	Warren RV Park	315 N Commonwealth Avenue	Polk City		8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
480	Penny Royal Court MHP	1329 C Penny Royal Court	Lakeland	8636616446	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
481	Pickren Rentals	418 Senate Street	Auburndale		8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
482	Bomber Properties #2	118 Cypress Street	Wahneta	4078300978	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
483	Spirit Lake Estates	5242 Spirit Lake Road	Winter Haven		8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
484	AJ's Trailer Park	3311-3343 Hughes Street	Lakeland	8639673280	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
485	Pat's Mobile Home Park	2121 Dillie Street	Lakeland	8636878244	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
486	Bennie's Trailer Park	4105 Glen Road	Lakeland	8638581063	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
487	Mobile Home Park Fuller	115 E Fuller Street	Davenport	3214431398	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
488	Otterwood Estates	5006 Lewellyn Road	Lakeland	8137635929	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
489	Blue Moon MHP	1439 34th NW Street	Winter Haven	4073998060	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
490	Old Dade City Road Country Park	11105 Old Dade City Road	Lakeland	8636980591	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
491	Crescent Way	1706 W Parker Street	Lakeland	3016557712	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
492	Crescent Court MHP B	625 W Crescent Drive	Lakeland	7006566028	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
493	Tenoroc Place LLC	2925 Tenoroc Mine Road	Lakeland	8139270021	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
494	Johnson Mobile Home Park	108 Walnut Lane	Lake Alfred	4072477624	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
495	Dexter Shores Mobile Park	3380 Dexter Shores Drive SE	Winter Haven	3174742805	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
496	B&W Mobile Home Park	5520 3rd Street SE	Highland City	7272011699	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
497	Happy Hollow Mobile Home Park	2620 Reynolds Road	Lakeland	3238688224	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
498	Hidden Park	2204-2218 Ellie Road	Auburndale	8639378867	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
499	Hickory Oaks, LLC	267 Chipman Lane	Auburndale	8639651855	8	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
500	Snoeblen MHP	1308 W Kaley Street	Orlando	4074251860	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
501	Harrell Road Mobile Home Park	2014 Harrell Road	Orlando	4072773042	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
502	Davis Island	2256 Missouri Avenue	Saint Cloud	4079337660	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
503	Green Swamp Mobile Home Park	8100 Golden Citrus Road	Saint Cloud	4076566900	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
504	Ballard Park Place	3146 Mt Tabor Road	Lakeland	8638596808	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
505	Beverly Hills Mobile Home Park	8925 Beverly Hills Road	Lakeland	8632268746	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
506	Carroll Mobile Home Park	659 Croom Road	Bartow	8635192489	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
507	Old Bartow Estates	611 Old Bartow Road	Homeland	8636471958	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
508	Lone Pine Mobile Home Park	3315 E Main Street	Lakeland		7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
509	Labarbera Properties	1035 East Lake Parker Drive	Lakeland	8636659664	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
510	McCoy's Place	1025 Socrum Loop Road W	Lakeland		7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
511	Mt Tabor MHP	3385 Mt Tabor Road	Lakeland	4108361628	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
512	Reuben Williams MHP	1410 US Highway 92 W	Auburndale	8639676675	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
513	Grape Hammock Fish Camp & Marina	1400 Grape Hammock Road	Lake Wales	8636921500	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
514	Warren RV Park	315 N Commonwealth Avenue	Polk City	8639047346	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
515	M & S Investment Property	4008 US Highway 17-92 W	Haines City		7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
516	Swindell Mobile Home Park	4660 Swindell Road	Lakeland	8638029706	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
517	Max Mobile Home Park	2204 Shirah Road	Auburndale	8635572731	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
518	Drift In Resort	2700 Drift In Street	Lake Wales	4076878272	7	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
519	Orange Lodge 36 F&AM	453 E Main Street	Apopka	4077746345	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
520	Denmarks Park	1416 9th Street	Winter Garden	4076562768	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
521	Oak Tree Park	4805 Plymouth Sorrento Road	Apopka	4078841888	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
523	East Toho RV Resort and Marina	3705 Big Bass Road	Kissimmee	4073482040	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
524	Richardsons Fish Camp	1550 Scotty's Road	Kissimmee	4078466540	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
525	St. Cloud Trailer Park	1269 Oregon Avenue	Saint Cloud	4078923693	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
526	Teels Mobile Home Park	1498 Crestridge Drive	Kissimmee	4079335429	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
527	Bailey's Trailer Park	1229 County 547 Road	Davenport	8634226942	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
528	Belyew Trailer Park	113 Locke Road	Davenport	8638525812	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
529	Big Oak Park	2503 Tanglewood Street Lot 3	Lakeland	8636689765	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
530	Bone Valley Mobile Home Park	Kirkland & Railroad	Bradley	8634281233	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
531	Burnum Trailer Park	3085 US Highway 17-92 West	Haines City	4073018443	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
532	Gafford Mobile Home Park	123 S Boulevard	Davenport	8634212557	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
533	Heritage Park	320 Wilder Road	Lakeland	8632074020	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
534	Whoville  LLC	1127 N Davis Avenue	Lakeland	8636074222	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
535	Lowes Mobile Home Park	3492 Dexter Shores Drive SE	Winter Haven	8633189999	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
536	Colorado West Mobile Home Park	301 Colorado Avenue	Lakeland		6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
537	Pine Acres MHP	5510 Old Eagle Lake Road	Winter Haven	8638758707	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
538	Ponderosa Estates	10835 US Hwy 98 North	Lakeland	6303779312	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
539	Shady Oaks MHP	2024 Milton Street	Lakeland	8636658119	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
540	Smith's Trailer Park	6962 Old Hwy 37 South	Mulberry		6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
541	Starr Rentals	2038 McCloud Lane	Davenport		6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
542	Sue's Mobile Home Park	3435 Spivey Road	Lakeland	8638583694	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
543	Lindus Park Mobile Home Park	909 Lincoln Street	Babson Park	8636050180	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
544	Camelia Lane MHP	305 Camelia Lane	Auburndale	8632876315	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
545	Marker Road MHP	1694 Marker Road	Polk City	4078946722	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
546	Combee Acres	2934 Brooks Street	Eaton Park	8636651617	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
547	MCM Mobile Home Park	4802 Puritan Lane	Lakeland	8639403582	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
548	Petersons Park	831 Robson Street	Lakeland	8632868189	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
549	Babson Hills MHP	31 Lake Patrick Drive	Babson Park	8632065358	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
550	Sango Trailer Park	2329 Denver Street	Lakeland	8137704451	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
551	Highland City Rentals, LLC	4057 Bay Avenue	Highland City	8639686610	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
552	A.D.Y. Mobile Home Park	3215 Maine Avenue	Lakeland	8637973373	6	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
553	Evan's Trailer Park	17780 Evans Trail	Orlando	4078987231	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
554	Bella Vista Mobile Home Park	3206-3222 Waldrup Lane	Lakeland	8133343349	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
555	Cedarwood Apartments	2605 E Jungle Street	Lakeland	8636662218	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
556	Dranefield Mobile Home Park 3	3825 Hamilton Road	Lakeland	8636466391	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
558	Gibsonia MH Park	5619 US Highway 98 N	Lakeland	8638533285	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
559	Grant Estates	1997 Marker Road	Polk City	8638538761	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
560	Hendersons Estates	2239 US Highway 17 S	Bartow	8636471958	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
561	Rosemont Mobile Home Park LLC	128-140 3rd Street W	Wahneta	8632861933	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
562	Youngs Mobile Home Park	2045 J Jackson Road S	Fort Meade		5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
563	Youngs Mobile Home Park	403 Crescent Drive	Lakeland	8636445555	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
564	Carroll MHP	3147 Wall Street	Bartow	8635336915	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
565	Hull Street Blues MHP	319 Hull Street	Lakeland	8639447897	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
566	J Park	3781 Rifle Range Road	Wahneta	8634195347	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
567	Bev's Trailer Park	4114 N Galloway Road	Lakeland	3526502565	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
568	Lake Jessie Mobile Home Park	747 Lake Jessie Drive	Winter Haven	8632930950	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
569	Ronnie's Mobile Home Park	3830 Hwy 60 E	Bartow	8635813342	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
570	5110 Lewellyn Street	5110 Lewellyn Street	Lakeland	8132228210	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
571	Chestnut MHP	722 Chestnut Road	Lakeland	8635132549	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
572	Sunset At the Lake Mobile Village LLC	1601 S Lake Reedy Boulevard	Frostproof	2073185325	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
573	Plant Avenue MHP	1212 Plant Avenue	Lakeland	8637381116	5	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
574	Friendly Village Inn Motel	2550 E Irlo Bronson Memorial Highway	Kissimmee	4078461007	4	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
575	Ely's Mobile Home Park	627 N Carroll Road	Lakeland		4	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
576	Morgan's RV Park	4411 US Highway 542 E	Lakeland	8636659631	4	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
577	Patrick's Mobile Home Park	1398 US Highway 92 West	Auburndale		4	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
578	Camp Arbuckle	8005 Highway 64 East	Avon Park		4	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
579	Los Fuentes	2710 W 10th Street	Lakeland	8139670626	4	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
580	Swiss Valley Estates Phase 1	1529 Ritter Road	Lakeland	3863837821	4	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
581	Lake Breeze RV Park	2040 W Lee Road	Orlando	4072939391	3	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
582	Orange Blossom KOA	3800 W Orange Blossom Trail	Apopka	4078863260	3	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
583	Kissimmee RV Park	2425 Old Vineland Road	Kissimmee	4073966655	3	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
584	Ripley's Sunrise Cove	449 Lake Van Road	Auburndale	9544941728	3	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
585	MHP Serendipity Lakeside Group	1090 Shady Cove Road E	Haines City	4074739769	3	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
586	Fairview Mobile Court	4462 Edgewater Drive	Orlando	4077988581	2	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
587	Lost Lake RV Resort	3400 S Clarcona Road	Apopka	4078861996	2	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
588	Full Gospel Interdenominational Church Camp	116 S Roma Way	Kissimmee	3212844090	2	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
589	Camp Gilead	1444 Camp Gilead Road	Polk City	8639841353	2	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
590	Davenport Mobile Estates Inc	2900 Powerline Road, Unit 300	Haines City	8634223261	2	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
591	Camp La Llanada USA, LLC	2819 Tiger Lake Road	Lake Wales	8636961948	2	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
592	Orlando SW KOA	2525 Frontage Road	Davenport	8634241880	2	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
593	Village of La Casa Del Sol	39610 US Highway 27 N	Davenport	8634211255	2	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
594	Lake Aurora Christian Assembly	237 Golden Bough Road	Lake Wales	8636961102	2	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
595	Reedy Lake Parks, LLC RV Park	1621 S Lake Reedy Boulevard	Frostproof	8636353546	2	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
596	Masterpiece Gardens Family Conference Center	3900 Great Masterpiece Road	Lake Wales	8636762518	2	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
597	Cottages at Lake Mable	5118 N Scenic Highway	Lake Wales	8132228210	2	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
598	Lake Wales Campground	15898 US HWY 27	Lake Wales	8636389011	2	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
599	Lake John Motel Apts	15992 W Highway 50	Winter Garden	4076568124	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
600	Woodward Ave MHP LLC	5624 Woodward Avenue	Zellwood	3866897771	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
601	Hidden River RV Park	15925 E Colonial Drive	Orlando	4075685346	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
602	Cypress Gardens Campground & RV Park	7400 Cypress Gardens Boulevard	Winter Haven	2039422745	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
603	Camp Inn RV Resort	10400 US Highway 27 N	Frostproof	8636352500	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
604	Lake Hatchineha Resort & RV Park	151 Catfish Street	Haines City	8634394666	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
605	Fort Meade American Legion Post 23	825 N Charleston Avenue	Fort Meade	8632858616	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
606	Gator Creek Campground	10545 US Highway 98 N	Lakeland	8638580340	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
607	Heartland RV Resort	1800 Commerce Avenue	Haines City	8634211485	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
608	Lake Arbuckle County Park	2600 Arbuckle Road	Frostproof	8636352811	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
609	Lake Rosalie Park	2925 Lake Rosalie Road	Lake Wales	8636794245	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
610	Lakeland RV Resort	900 Old Combee Road	Lakeland	4804235700	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
611	Lakeshore Palms Travel Park	4800 Eloise Loop Road	Winter Haven	8633241339	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
612	Paradise Island R.V. Park Inc	32000 US Hwy 27 South	Haines City	9547523084	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
613	Saddle Creek Park Campground	3711 Morgan Combee Road	Lakeland	8634132399	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
614	Friendly RV Park	1615 US Highway 17/92, West	Lake Alfred	8639560870	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
615	Circle F Dude Ranch Camp LLC	5301 Dude Ranch Road	Lake Wales	8636764113	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
616	Oak Hammock Resort LLC	3500 Canal Road	Lake Wales	9043277135	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
617	Lake Alfred RV Park	1640 US Hwy 17-92W	Lake Alfred	8635825037	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
618	Themeworld RV Resort	2727 Frontage Road	Davenport	8634248362	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
619	Prestlers RV Motel	2435 New Tampa Highway	Lakeland	8134862171	1	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
620	Rays Travel Trailers Inc	8424 E Colonial Drive	Orlando	4072774593	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
621	Disney Fort Wilderness Campground	4510 N Fort Wilderness Trail	Orlando	4078242745	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
622	Christmas R V  Park	25525 E Colonial Drive	Christmas	4075685207	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
623	Stage Stop Campground  Inc	14400 W Colonial Drive	Winter Garden		0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
624	Winter Garden RV Resort	13905 W Colonial Drive	Winter Garden	9167822224	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
625	Clarcona Horsemans Park	3535 Damon Road	Apopka	4078866255	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
626	Wekiwa Springs State Park	1800 Wekiwa Circle	Apopka	4075534374	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
627	Bill Frederick Park at Turkey Lake	3401 S Hiawassee Road	Orlando	4072995594	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
628	Moss Park	12901 Moss Park Road	Orlando	4072732327	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
629	Kelly Park   "Rock Springs"	400 E Kelly Park Road	Apopka	4078366200	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
630	Trimble Park	5802 Trimble Park Road	Mount Dora	3523831993	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
631	Magnolia Park - Orange County Parks & Recreation	2929 S Binion Road	Apopka	4078864231	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
632	Village Inn Motel & RV Park	17883 E Colonial Drive	Orlando	4075685431	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
633	Wycliffe Associates RV Park	10306 John Wycliffe Boulevard	Orlando	4078523600	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
634	Camp Thunderbird	909 E Welch Road	Apopka	4078898088	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
635	Aloha RV Park Campground	4648 S Orange Blossom Trail	Kissimmee	4079335730	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
636	Canoe Creek Campground	4101 Canoe Creek Road	Saint Cloud	4078927010	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
637	Great Oak RV Resort	4440 Yowell Road	Kissimmee	4073969092	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
638	Kissimmee/Osceola KOA	2644 Happy Camper Place	Kissimmee	4073966851	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
639	Johnston Springs	4261 Pleasant Hill Road	Kissimmee	4078700719	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
640	Ponderosa RV Park	1983 Fortune Road	Kissimmee	4078476002	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
641	Tropical Palms Fun Resort	2650 Holiday Trail	Kissimmee	4073964595	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
642	Overstreet Landing RV Park	4500 Joe Overstreet Road	Kenansville	4074361966	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
643	Central Florida Youth and Family Camp	3600 Deer Park Road	Saint Cloud	3217799967	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
644	Bullock's Landing	2041 Thompson Nursery Road	Lake Wales	5138762739	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
645	Sertoma Camp Endeavor  Inc	1301 Southern Road	Dundee	8634391300	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
646	Camp Mack's River Resort	14900 Camp Mack Road	Lake Wales	8636961108	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
647	Central Park of Haines City	1501 Commerce Avenue	Haines City	8634225322	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
648	Cypress Inn	5651 Cypress Gardens Road	Winter Haven	8633181246	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
649	East Haven RV Park	4320 Dundee Road	Winter Haven	8633242624	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
650	Fairview Village	7025 Fairview Village Circle	Winter Haven	8634229584	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
651	Flaming Arrow Scout Reservation	1201 Boy Scout Road	Lake Wales	8636320389	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
652	Florida FFA Leadership Training Center	5000 Firetower Road	Haines City	8634397332	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
653	Good Life Resort Inc	6815 State Road 60 E	Bartow	8635371971	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
654	Greenfield Village RV Park	1015 SR 542 W	Dundee	8634397409	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
655	H.T. System Management  Inc.	3527 US Highway 17 North	Winter Haven	8632973361	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
656	Lake Kissimmee State Park	14248 Camp Mack Road	Lake Wales	8636961112	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
657	LeLynn RV Resort	1513 SR 559	Polk City	8639841495	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
658	Outdoor Resorts At Orlando Inc.	9000 US Highway 192 W #1000	Clermont	8634241407	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
659	Peace Creek RV Park	26397 Hwy 27	Lake Wales	8634395205	0	\N	\N	\N	Inactive	\N	\N	\N	\N	2025-04-16 02:44:03.894332+00	2025-04-16 02:44:03.894332+00	f
\.


--
-- Data for Name: estimate_item_additional_work; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.estimate_item_additional_work (id, estimate_item_id, description, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: estimate_item_photos; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.estimate_item_photos (id, estimate_item_id, file_path, original_name, notes, metadata, created_at, updated_at, photo_type) FROM stdin;
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
6aa097b2-44d3-4b5a-a7ff-4503bbfc0251	cf860258-ff94-4b6d-8e97-a2f18ba4301f	Remove existing railing from the balcony to access the deck for repairs	40.00	3.00	0.00	120.00	0	2025-05-02 11:51:09.708+00	2025-05-02 11:51:09.717+00	\N	\N	ln ft	\N
63322996-d30a-4d55-9d50-b3395c23d09f	cf860258-ff94-4b6d-8e97-a2f18ba4301f	Remove existing decking to access the roof and sleeper boards	187.00	3.00	0.00	561.00	1	2025-05-02 11:51:09.712+00	2025-05-02 11:51:09.719+00	\N	\N	sq ft	\N
2517ce9e-5342-423c-a0fa-96ca993ba0f4	cf860258-ff94-4b6d-8e97-a2f18ba4301f	Remove the sleeper boards supporting the decking	9.00	10.00	0.00	90.00	2	2025-05-02 11:51:09.713+00	2025-05-02 11:51:09.719+00	\N	\N	each	\N
3bfb6937-3895-4cc0-8ff5-0d4c6ff6a350	cf860258-ff94-4b6d-8e97-a2f18ba4301f	Inspect and repair the modified bitumen roof, including sealing fasteners and correcting the drip edge installation if necessary.	187.00	4.00	0.00	748.00	3	2025-05-02 11:51:09.713+00	2025-05-02 11:51:09.72+00	\N	\N	sq ft	\N
dfc7bd38-3ad2-40af-afaf-87447fddd6e9	cf860258-ff94-4b6d-8e97-a2f18ba4301f	Reinstall the sleeper boards after roof repair	9.00	10.00	0.00	90.00	4	2025-05-02 11:51:09.714+00	2025-05-02 11:51:09.72+00	\N	\N	each	\N
245d38ea-0a6e-4af1-9987-b3c82feb0164	cf860258-ff94-4b6d-8e97-a2f18ba4301f	Reinstall the decking on top of the sleeper boards	187.00	4.00	0.00	748.00	5	2025-05-02 11:51:09.715+00	2025-05-02 11:51:09.72+00	\N	\N	sq ft	\N
67ce12c6-903c-4e6f-960e-f0a016daf1e8	cf860258-ff94-4b6d-8e97-a2f18ba4301f	Reinstall the railing on the balcony after deck and roof repairs are completed	40.00	3.00	0.00	120.00	6	2025-05-02 11:51:09.716+00	2025-05-02 11:51:09.72+00	\N	\N	ln ft	\N
b72784ed-1b7f-4810-bd15-6b924260f7ab	bbbf8e3a-a615-40cd-b6ac-7ca893b5618e	Construct and install support structure for pan roof, including posts, beams, and attachment to cement driveway.	1.00	600.00	0.00	600.00	4	2025-05-06 14:16:15.206+00	2025-05-06 17:34:13.364+00	\N	\N	each	\N
56dda5ac-f4a3-48e7-978e-646b7fe02eb4	bbbf8e3a-a615-40cd-b6ac-7ca893b5618e	Install 4 heavy-duty anchors to reinforce carport structure.	4.00	100.00	0.00	400.00	0	2025-05-06 14:16:15.207+00	2025-05-06 17:34:13.376+00	\N	\N	each	\N
57cc572b-8c1e-45e7-a6f8-53df28800bd8	bbbf8e3a-a615-40cd-b6ac-7ca893b5618e	Supply and install awning over entry door, including support brackets and fasteners.	1.00	1900.00	0.00	1900.00	1	2025-05-06 14:16:15.207+00	2025-05-06 17:34:13.389+00	\N	\N	each	\N
e0e4f123-f512-4b75-88d9-b002fa8fff1f	bbbf8e3a-a615-40cd-b6ac-7ca893b5618e	Prepare roof surface and install 1800 square feet of TPO roofing membrane, including adhesives, flashing, and terminations.	1800.00	3.80	0.00	6840.00	2	2025-05-06 14:16:15.208+00	2025-05-06 17:34:13.401+00	\N	\N	sq ft	\N
458e71e8-334e-491c-bf66-33dfcb56d74e	bbbf8e3a-a615-40cd-b6ac-7ca893b5618e	Supply and install 30 pan roof panels, each 13 feet long, including fasteners and sealants.	30.00	120.00	0.00	3600.00	3	2025-05-06 14:16:15.2+00	2025-05-06 17:34:13.414+00	\N	\N	each	\N
\.


--
-- Data for Name: estimates; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.estimates (id, status, subtotal, tax_total, discount_amount, total, notes, terms, pdf_path, converted_to_invoice_id, created_at, updated_at, deleted_at, estimate_number, date_created, valid_until, address_id, project_id, client_id) FROM stdin;
5cf1f48e-bd50-42f7-be27-c458854537ba	sent	3.00	0.00	0.00	3.00		This estimate is valid for 30 days.	\N	\N	2025-04-02 05:13:59.287+00	2025-04-15 15:48:36.034+00	2025-04-15 15:48:36.034+00	EST-00005	2025-04-02	2025-05-02	\N	\N	\N
ba5a2454-55b7-44e3-b7b0-53a4ab306173	sent	750.00	0.00	0.00	750.00		This estimate is valid for 30 days.	\N	\N	2025-04-04 14:06:35.744+00	2025-04-15 15:48:43.163+00	2025-04-15 15:48:43.162+00	EST-00007	2025-04-04	2025-05-04	6b8a50c2-439a-4daa-a868-0431cbe28bd5	\N	cef8a5e0-ba91-45da-9cb8-e20c4292b2a1
2590c2bc-1186-4a5c-a17b-57290b7438cf	sent	750.00	0.00	0.00	750.00		This estimate is valid for 30 days.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00006.pdf	\N	2025-04-04 13:54:24.22+00	2025-04-15 15:48:48.599+00	2025-04-15 15:48:48.598+00	EST-00006	2025-04-04	2025-05-04	6b8a50c2-439a-4daa-a868-0431cbe28bd5	\N	cef8a5e0-ba91-45da-9cb8-e20c4292b2a1
7c5f3027-d400-4f6d-bfae-63aef41b1c56	sent	1.00	0.00	0.00	1.00		This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-15 04:47:11.653+00	2025-04-15 04:47:20.166+00	2025-04-15 04:47:20.166+00	EST-00019	2025-04-15	2025-05-15	c18892a9-8e8a-4592-a61d-10293cb131a3	\N	26ff807d-0535-49c3-8144-2aae123c02ed
71b0dda5-7309-47e9-a5da-377ef213ee72	sent	1.00	0.00	0.00	1.00		This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_1744652886630.pdf	\N	2025-04-14 17:33:14.235+00	2025-04-15 04:47:26.693+00	2025-04-15 04:47:26.693+00	EST-00018	2025-04-14	2025-05-14	6b8a50c2-439a-4daa-a868-0431cbe28bd5	\N	cef8a5e0-ba91-45da-9cb8-e20c4292b2a1
c350c05a-0177-40db-8575-0139bbc3b885	draft	0.00	0.00	0.00	0.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00014.pdf	\N	2025-04-12 05:54:28.507+00	2025-04-15 04:47:34.879+00	2025-04-15 04:47:34.879+00	EST-00014	2025-04-12	2025-05-12	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
58a73b9a-c81a-46d7-9e4e-fcbdd2aff66a	draft	3612.50	0.00	0.00	3612.50	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-08 22:45:20.36+00	2025-04-15 15:49:09.409+00	2025-04-15 15:49:09.409+00	EST-00008	2025-04-08	2025-05-08	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
1a2940f4-12e9-4a85-9cdd-004007175af7	sent	38.00	0.00	0.00	38.00		This estimate is valid for 30 days.	\N	\N	2025-04-02 02:22:32.707+00	2025-04-02 02:22:45.853+00	2025-04-02 02:22:45.853+00	EST-00002	2025-04-02	2025-05-02	\N	\N	\N
79be0134-6cae-4429-a8ff-1e3677024302	draft	0.00	0.00	0.00	0.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-12 06:03:40.952+00	2025-04-15 04:47:41.319+00	2025-04-15 04:47:41.319+00	EST-00015	2025-04-12	2025-05-12	\N	\N	26ff807d-0535-49c3-8144-2aae123c02ed
9c585096-b8e6-441d-8e02-ad473a2ef850	draft	11395.75	0.00	0.00	11395.75	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00017.pdf	\N	2025-04-12 13:13:05.717+00	2025-04-15 04:47:46.364+00	2025-04-15 04:47:46.363+00	EST-00017	2025-04-12	2025-05-12	\N	\N	26ff807d-0535-49c3-8144-2aae123c02ed
04c13dc0-ebe1-49b1-a94b-6657d959831c	draft	0.00	0.00	0.00	0.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00012.pdf	\N	2025-04-12 04:56:57.596+00	2025-04-15 04:47:38.316+00	2025-04-15 04:47:38.316+00	EST-00012	2025-04-12	2025-05-12	\N	\N	26ff807d-0535-49c3-8144-2aae123c02ed
9f30fc2f-d0eb-416e-91aa-72634242de11	accepted	3.00	0.00	0.00	3.00		This estimate is valid for 30 days.	\N	6f0ab57d-767b-4a11-b353-69954af930d5	2025-04-02 03:27:25.536+00	2025-04-15 15:48:20.938+00	2025-04-15 15:48:20.936+00	EST-00003	2025-04-02	2025-05-02	\N	\N	\N
cff3f2d6-2159-41aa-9808-cae326f2ca19	accepted	9.00	0.00	0.00	9.00		This estimate is valid for 30 days.	\N	bbdfa5e0-f33c-4751-9b4a-ed894cffba6c	2025-04-02 04:42:53.278+00	2025-04-15 15:48:24.839+00	2025-04-15 15:48:24.839+00	EST-00004	2025-04-02	2025-05-02	\N	\N	\N
be712350-404e-457d-b3f8-97f02f7c42c1	accepted	9.00	0.00	0.00	9.00		This estimate is valid for 30 days.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00001.pdf	908b8942-ed53-4bbe-abe9-1529f624cb0e	2025-04-01 19:44:35.94+00	2025-04-15 15:48:29.416+00	2025-04-15 15:48:29.416+00	EST-00001	2025-04-01	2025-05-01	\N	\N	\N
b788d32f-45f9-412a-9828-869035d4df71	draft	3222.50	0.00	0.00	3222.50	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00010.pdf	\N	2025-04-09 04:36:45.196+00	2025-04-15 15:49:13.764+00	2025-04-15 15:49:13.764+00	EST-00010	2025-04-09	2025-05-09	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
4c93d611-ce81-4c2f-88ef-823c43e2b233	draft	3664.50	0.00	0.00	3664.50	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-09 04:18:32.668+00	2025-04-15 15:49:17.306+00	2025-04-15 15:49:17.306+00	EST-00009	2025-04-09	2025-05-09	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
223a8805-3f61-488b-b448-1ae9879297d4	draft	0.00	0.00	0.00	0.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-12 05:50:12.312+00	2025-04-15 15:49:24.669+00	2025-04-15 15:49:24.669+00	EST-00013	2025-04-12	2025-05-12	\N	\N	26ff807d-0535-49c3-8144-2aae123c02ed
8147fd0a-d0ca-4d40-a137-375bffcc30c3	sent	1.00	0.00	0.00	1.00		This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-15 22:15:30.424+00	2025-04-16 01:32:02.112+00	2025-04-16 01:32:02.111+00	EST-00020	2025-04-15	2025-05-15	c18892a9-8e8a-4592-a61d-10293cb131a3	\N	26ff807d-0535-49c3-8144-2aae123c02ed
fd56047b-07e6-4d40-8363-07ca41a77ac0	sent	1.00	0.00	0.00	1.00		This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-16 06:40:27.372+00	2025-04-16 13:26:16.788+00	2025-04-16 13:26:16.787+00	EST-00021	2025-04-16	2025-05-16	c18892a9-8e8a-4592-a61d-10293cb131a3	\N	26ff807d-0535-49c3-8144-2aae123c02ed
3913a2b7-dac8-447a-9e20-76fe2bf340b3	accepted	3655.00	0.00	0.00	3655.00	Adjustments made for additional 2 cabinets and plumbing as we discussed on the phone.	This estimate is valid for 30 days from the date issued.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00011.pdf	1afad0be-049c-4ffc-a887-45ba2421b48a	2025-04-10 13:31:25.284+00	2025-04-23 17:40:55.872+00	\N	EST-00011	2025-04-10	2025-05-10	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
cf860258-ff94-4b6d-8e97-a2f18ba4301f	sent	2477.00	0.00	0.00	2477.00		This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/app/uploads/estimates/estimate_EST_1746539415346.pdf	\N	2025-05-02 11:51:09.651+00	2025-05-06 13:50:21.886+00	\N	EST-00022	2025-05-02	2025-06-01	247649a3-fbe7-4dc7-bc12-43f61168d822	\N	98c1612d-919c-4b88-8141-234bd88dea3e
7d0660d5-619c-4efc-b92d-775c55327319	accepted	12082.00	0.00	0.00	12082.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/app/uploads/estimates/estimate_EST_1746539513933.pdf	\N	2025-04-12 06:05:13.552+00	2025-05-06 13:51:56.324+00	\N	EST-00016	2025-04-12	2025-05-12	\N	\N	26ff807d-0535-49c3-8144-2aae123c02ed
bbbf8e3a-a615-40cd-b6ac-7ca893b5618e	sent	13340.00	0.00	0.00	13340.00		This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/app/uploads/estimates/estimate_EST_1746556726089.pdf	\N	2025-05-06 14:16:15.194+00	2025-05-06 18:38:48.557+00	\N	EST-00023	2025-05-06	2025-06-05	3311ca1b-da19-4837-b8f8-b194580affab	\N	6534a9e7-0e25-4c48-b1e2-284e78bc89c9
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
46d407e0-d6c0-44d3-82f2-4faee7a5e61a	1afad0be-049c-4ffc-a887-45ba2421b48a	Cabinet removal and disposal	1.00	200.00	0.00	200.00	0	2025-04-23 17:40:48.599+00	2025-04-23 17:42:01.041+00
398b9976-8b5f-4b03-aeea-e6dc75a2604b	1afad0be-049c-4ffc-a887-45ba2421b48a	Install new cabinets	9.00	75.00	0.00	675.00	1	2025-04-23 17:40:48.619+00	2025-04-23 17:42:01.051+00
18ff996d-96d6-41f9-a76c-fc7ddc7463e9	1afad0be-049c-4ffc-a887-45ba2421b48a	Job site preparation and cleanup	1.00	50.00	0.00	50.00	2	2025-04-23 17:40:48.63+00	2025-04-23 17:42:01.063+00
880c4e27-54c6-4969-bd0d-343fc7f64a48	1afad0be-049c-4ffc-a887-45ba2421b48a	Subfloor Replacement	160.00	4.00	0.00	640.00	3	2025-04-23 17:40:48.656+00	2025-04-23 17:42:01.086+00
dfcaa444-d63a-4adc-b78e-2a82477236ac	1afad0be-049c-4ffc-a887-45ba2421b48a	Laminate Flooring Installation with trim	160.00	4.50	0.00	720.00	4	2025-04-23 17:40:48.675+00	2025-04-23 17:42:01.097+00
34eb5673-3c29-4f45-aa18-4ff52d32ed38	1afad0be-049c-4ffc-a887-45ba2421b48a	Underpinning removal and disposal	100.00	2.50	0.00	250.00	5	2025-04-23 17:40:48.687+00	2025-04-23 17:42:01.106+00
7b683ea4-1c09-4f09-a027-e075733e605a	1afad0be-049c-4ffc-a887-45ba2421b48a	Install new underpinning	100.00	5.00	0.00	500.00	6	2025-04-23 17:40:48.699+00	2025-04-23 17:42:01.117+00
99a84cd3-a5cf-4f26-a2b5-183a8894bab1	1afad0be-049c-4ffc-a887-45ba2421b48a	Insulation removal and disposal	1.00	45.00	0.00	45.00	7	2025-04-23 17:40:48.711+00	2025-04-23 17:42:01.127+00
340c757e-d6cb-4e10-b883-5493513148e1	1afad0be-049c-4ffc-a887-45ba2421b48a	Plumbing adjustments	1.00	75.00	0.00	75.00	8	2025-04-23 17:40:48.722+00	2025-04-23 17:42:01.138+00
11bd0aef-424c-43cb-8bcb-a1366904e0ab	1afad0be-049c-4ffc-a887-45ba2421b48a	Additional purchases and travel	1.00	845.00	0.00	845.00	9	2025-04-23 17:42:01.03+00	2025-04-23 17:42:01.148+00
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.invoices (id, invoice_number, status, subtotal, total, notes, terms, address_id, created_at, updated_at, deleted_at, date_created, date_due, tax_total, discount_amount, pdf_path, client_id) FROM stdin;
0009cdd0-dabf-4703-bf8e-d6087eccbef8	INV-00011	paid	1200.00	1200.00		Payment is due within 30 days from the date of invoice.	6b8a50c2-439a-4daa-a868-0431cbe28bd5	2025-04-14 17:15:46.747+00	2025-04-15 00:35:23.71+00	\N	2025-04-14	2025-05-14	0.00	0.00	/app/uploads/invoices/invoice_INV_00011.pdf	cef8a5e0-ba91-45da-9cb8-e20c4292b2a1
f46f2f5d-d0ce-49b5-acb8-8282aee46884	INV-00004	paid	1.00	1.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:07:03.000004+00	2025-04-02 05:07:03.001523+00	\N	2025-04-02	2025-05-02	0.00	0.00	\N	\N
fdd35304-6477-43c0-904d-d751e05f875d	INV-00005	paid	1.00	1.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:07:03.000004+00	2025-04-02 05:07:03.001523+00	\N	2025-04-02	2025-05-02	0.00	0.00	\N	\N
6f7fa546-7310-408a-8925-74c3820aaa73	INV-00003	paid	1.00	1.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:07:03.000004+00	2025-04-02 05:07:03.001523+00	\N	2025-04-02	2025-05-02	0.00	0.00	\N	\N
6f0ab57d-767b-4a11-b353-69954af930d5	INV-00008	draft	3.00	3.00		This estimate is valid for 30 days.	\N	2025-04-02 05:07:03.000004+00	2025-04-02 05:07:03.001523+00	\N	2025-04-02	2025-05-02	0.00	0.00	\N	\N
064d98ee-2877-4a7e-a57e-70f7f121e765	INV-00007	paid	3.00	3.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:07:03.000004+00	2025-04-02 05:07:03.001523+00	\N	2025-04-02	2025-05-02	0.00	0.00	\N	\N
270c0ea0-56a0-44f6-acd3-85d5606ba459	INV-00010	paid	30.00	30.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:31:53.481+00	2025-04-02 05:31:56.322+00	\N	2025-04-02	2025-05-02	0.00	0.00	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/invoices/invoice_INV_00010.pdf	\N
908b8942-ed53-4bbe-abe9-1529f624cb0e	INV-00006	sent	9.00	9.00		This estimate is valid for 30 days.	\N	2025-04-02 05:07:03.000004+00	2025-04-10 14:01:26.75+00	\N	2025-04-02	2025-05-02	0.00	0.00	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/invoices/invoice_INV_00006.pdf	\N
bbdfa5e0-f33c-4751-9b4a-ed894cffba6c	INV-00009	sent	9.00	9.00		This estimate is valid for 30 days.	\N	2025-04-02 05:07:03.000004+00	2025-04-13 19:14:42.018+00	\N	2025-04-02	2025-05-02	0.00	0.00	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/invoices/invoice_INV_00009.pdf	\N
44b4dbc5-bed8-47cb-a6db-f70b83e1071c	INV-00001	paid	1.00	1.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:07:03.000004+00	2025-04-23 17:26:56.515+00	2025-04-23 17:26:56.514+00	2025-04-02	2025-05-02	0.00	0.00	\N	\N
67d98cec-f3cb-4067-b2c1-5de6a2ec96d9	INV-00002	paid	1.00	1.00		Payment is due within 30 days from the date of invoice.	\N	2025-04-02 05:07:03.000004+00	2025-04-23 17:27:03.391+00	2025-04-23 17:27:03.391+00	2025-04-02	2025-05-02	0.00	0.00	\N	\N
1afad0be-049c-4ffc-a887-45ba2421b48a	INV-00012	draft	4000.00	4000.00	Adjustments made for additional 2 cabinets and plumbing as we discussed on the phone.	This estimate is valid for 30 days from the date issued.	3cd9e874-8bbd-40ed-ab8e-a846fd4b31ae	2025-04-23 17:40:48.491+00	2025-04-23 17:42:01.166+00	\N	2025-04-23	2025-05-23	0.00	0.00	/app/uploads/invoices/invoice_INV_00012.pdf	a04af1e2-7946-4387-ad73-7456c91af533
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

COPY public.products (id, name, description, price, tax_rate, is_active, created_at, updated_at, type, unit, deleted_at, name_vec, embedding) FROM stdin;
158aa720-2af4-4581-b0aa-af8135d4399c	Trim is linear feet 60ft		2.00	0.00	t	2025-04-09 04:23:43.112+00	2025-04-09 04:23:43.112+00	service	ln ft	\N	\N	\N
286f7ab6-948a-4e4a-8f97-07d918912ba7	Replace subfloor	Remove and replace subfloor. Additional bracing for security and stability.	5.00	6.00	t	2025-04-08 06:38:22.902+00	2025-04-08 06:40:14.38+00	product	sq ft	\N	\N	\N
6cdb1d5c-b001-4063-955e-09bbe02733b4	Vinyl Plank Flooring Installation	Installation of luxury vinyl plank flooring (floating click-lock planks) including underlayment and trimming (finished per square foot).	5.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
20c411bc-489a-468f-995b-c1a34b34b021	Sheet Vinyl Flooring Installation	Installation of sheet vinyl flooring, cut to fit and glued down, including adhesive (per square foot).	3.50	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
e64c9e68-be27-45c5-9878-04c7c8e2ca57	Laminate Flooring Installation	Installation of laminate wood flooring with underlayment and transitions, cut to fit (per square foot).	4.50	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
e8861f91-1c6b-4605-bc68-e91b0bfacfb6	Tile Flooring Installation	Installation of ceramic or porcelain floor tile, including mortar and grout application (per square foot).	7.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
b379628c-85a5-45d6-bda5-189e4196f46a	Subfloor Replacement/Repair	Removing damaged subfloor and installing new plywood/OSB subfloor panels, secured to floor joists (per square foot).	5.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
b8c7d0cb-8132-4db0-875b-ee14767c3ee8	Asphalt Shingle Roof Replacement	Tear-off of old roof and installation of new asphalt shingles with underlayment and flashing (per square foot of roof area).	6.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
7d15dd6a-3509-4589-ab26-f2cb96af0623	Roof Leak Repair (Minor Patch)	Minor roof leak patch – replace or seal around a small area of damaged shingles or flashing (cost per patch job).	300.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N	\N	\N
73cd8404-d9ad-475b-89c7-2437178be8dd	Roof Decking Replacement	Replacing rotted roof sheathing with new 4x8 ft plywood/OSB panels, nailed and sealed (per sheet).	90.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N	\N	\N
090b9c44-bd03-46bb-b8c3-19203da858ae	Window Replacement	Remove existing window and install new vinyl replacement window (e.g. 36\\x48\\ double-hung), including insulation and caulking (per window).	800.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N	\N	\N
c8d4be40-0f8e-4759-92a1-04ebd77b0e43	Interior Door Installation	Install a new interior door (pre-hung or slab) including fitting, hardware, and hinges (per door).	450.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N	\N	\N
994ef2cf-62e9-4678-88bb-63946d165568	Exterior Door Installation	Install a new exterior entry door (pre-hung unit) including threshold, weatherstripping, and lockset fitting (per door).	700.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N	\N	\N
946e35ec-1d20-4f2f-b25a-d788b34bf99a	Storm Door Installation	Install a storm/screen door over an existing exterior door frame, including hinge and closer installation (per door).	400.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N	\N	\N
1b4c3394-a36f-4b46-9df3-7127b595695a	Vinyl Siding Repair	Replace damaged vinyl siding panels on exterior walls, matching existing profile and securing properly (per square foot).	3.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
88e17346-15f9-4aa8-a462-a5175e266165	Stucco Patch Repair	Patch and texture small damaged stucco areas on exterior walls, blending with existing finish (per square foot).	20.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
6df80fe7-b4ac-4499-8504-9ea14fe7b45e	Exterior Trim Replacement	Replace rotted/damaged exterior wood trim or fascia (e.g. 1x6 fascia board), primed and ready for paint (per linear foot).	6.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	ln ft	\N	\N	\N
2b01f403-e055-49f5-a76d-16632418003a	General Caulking and Sealing	Re-caulk gaps and seams (around windows, doors, siding joints, tubs, etc.) to seal against water/air intrusion (per linear foot).	1.20	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	ln ft	\N	\N	\N
c3c4100c-7a64-4e97-957e-f30fc98be1d1	Exterior Painting	Repainting of exterior walls (stucco or siding) including surface prep, minor patching, and two coats of paint (per square foot of wall area).	4.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
a18c451f-8981-400f-8237-8eb9670eb770	Drywall Installation/Repair	Install new drywall or patch damaged drywall, including taping, mudding, and sanding ready for paint (per square foot).	4.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
5c12cfb7-fccf-4cc1-857e-97543fdb7b16	Baseboard Installation	Install or replace interior baseboard molding, including cutting to size, nailing, and caulking joints (per linear foot).	6.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	ln ft	\N	\N	\N
bf360b24-6c6b-4bc0-8c4c-c509177ff680	Crown Molding Installation	Install new interior crown molding at ceiling, including mitering or coping corners and caulking for a finished look (per linear foot).	8.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	ln ft	\N	\N	\N
94106546-f1d9-4194-9fd5-e05203a6b501	Interior Painting	Repaint interior walls and ceilings with minor prep (patching nail holes, etc.) and two finish coats of paint (per square foot of floor area).	3.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
6b16e8c6-a8c7-40b0-9cae-3086cc6e5251	Attic Insulation (Blown-In)	Install blown-in insulation (fiberglass or cellulose) in attic to recommended R-value, improving energy efficiency (per square foot of attic area).	1.80	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
64f39ece-610b-44d2-b948-f2250cf9f27b	Mobile Home Re-Leveling	Re-level a mobile or manufactured home by adjusting pier supports and shimming as needed to eliminate sagging (per home).	650.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N	\N	\N
fc3fd27c-ce56-41cf-8f4d-ecd30ca06b15	Mobile Home Anchor/Tie-Down Installation	Install or replace steel tie-down anchors and straps to secure mobile home to ground per Florida code (per anchor installed).	70.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N	\N	\N
2d81a67e-718c-461c-a45a-c15890c5d3ac	Mobile Home Skirting Installation	Install new vinyl skirting around mobile home base (including panels, vents, and access door), ventilated and secured (per linear foot).	7.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	ln ft	\N	\N	\N
ebc65e5b-02b2-411d-93c1-81dccea480cc	Mobile Home Pier Installation	Install additional or replacement support piers (e.g. concrete blocks with cap and shims) under a mobile home for stability (per pier).	100.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	each	\N	\N	\N
e8fd62e3-d15b-462d-81f2-f3802896bef9	Mobile Home Roof Coating	Clean and coat a mobile home metal roof with elastomeric or aluminum roof coating to seal leaks and reflect heat (per square foot).	2.00	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
09a32483-d170-44fc-ba81-84f4949cec82	Pressure Washing	Pressure wash exterior surfaces (driveway, siding, deck, etc.) to remove dirt, mold, and mildew; includes equipment and cleaners (per square foot).	0.20	0.00	t	2025-04-09 02:56:05.372+00	2025-04-09 02:56:05.372+00	service	sq ft	\N	\N	\N
797e7ace-d5a1-408d-a89f-e2a23d2fa571	Water damage remediation		75.00	0.00	t	2025-04-10 01:00:29.547+00	2025-04-10 01:00:29.547+00	service	hours	\N	\N	\N
\.


--
-- Data for Name: project_inspections; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.project_inspections (id, project_id, category, content, created_at) FROM stdin;
f4784061-bfa2-49ad-beb8-6b5ef356833e	38edf41a-6968-48ed-af13-fed5c8d3060f	condition	{"notes": "", "assessment": "Sinking floor due to water leak in kitchen mobile home.", "projectTypes": ""}	2025-04-12 04:30:34.949+00
967cf129-6378-4d8c-814a-dc081d1969a9	38edf41a-6968-48ed-af13-fed5c8d3060f	measurements	{"items": [{"dimensions": {"units": "feet", "width": "16", "length": "10"}, "description": "Remove flooring and subfloor. Disposal", "_productInfo": {"id": "e8fd62e3-d15b-462d-81f2-f3802896bef9", "name": "Mobile Home Roof Coating", "unit": "sq ft", "price": "2.00"}, "projectTypes": "", "linkedProduct": "e8fd62e3-d15b-462d-81f2-f3802896bef9", "measurementType": "area"}, {"quantity": "9", "description": "Cabinet removal and disposal", "_productInfo": null, "projectTypes": "", "quantityUnit": "each", "linkedProduct": null, "measurementType": "quantity"}, {"dimensions": {"units": "feet", "width": "16", "length": "10"}, "description": "Subfloor Replacement/Repair", "_productInfo": {"id": "b379628c-85a5-45d6-bda5-189e4196f46a", "name": "Subfloor Replacement/Repair", "unit": "sq ft", "price": "5.00"}, "projectTypes": "", "linkedProduct": "b379628c-85a5-45d6-bda5-189e4196f46a", "measurementType": "area"}, {"dimensions": {"units": "feet", "width": "15", "length": "15"}, "description": "Additional bracing", "_productInfo": null, "projectTypes": "", "linkedProduct": null, "measurementType": "area"}, {"dimensions": {"units": "feet", "width": "16", "length": "10"}, "description": "Laminate Flooring Installation", "_productInfo": {"id": "e64c9e68-be27-45c5-9878-04c7c8e2ca57", "name": "Laminate Flooring Installation", "unit": "sq ft", "price": "4.50"}, "projectTypes": "", "linkedProduct": "e64c9e68-be27-45c5-9878-04c7c8e2ca57", "measurementType": "area"}, {"dimensions": {"units": "feet", "width": "1", "length": "2"}, "description": "Trim is linear feet 60ft", "_productInfo": null, "projectTypes": "", "linkedProduct": null, "measurementType": "area"}, {"quantity": "7", "description": "Install cabinets", "_productInfo": null, "projectTypes": "", "quantityUnit": "each", "linkedProduct": null, "measurementType": "quantity"}, {"dimensions": {"units": "feet", "width": "4", "length": "15"}, "description": "Underpinning and insulation", "_productInfo": null, "projectTypes": "", "linkedProduct": null, "measurementType": "area"}], "notes": ""}	2025-04-12 04:30:34.986+00
ef305402-81ca-4bdd-9cb3-9e71a28ff0ba	38edf41a-6968-48ed-af13-fed5c8d3060f	materials	{"items": [{"name": "", "quantity": "", "sourceType": "assessment", "projectTypes": ""}], "notes": "", "projectTypes": ""}	2025-04-12 04:30:35.017+00
019e47f5-62eb-4749-9a5e-9858a3b02595	b3386254-0d2e-45e7-9736-b72612207a87	condition	{"notes": "", "assessment": "Repair subfloor and replace cabinets"}	2025-04-18 21:58:04.416+00
8e54e653-dce1-424d-8455-4ebf71e8a357	b3386254-0d2e-45e7-9736-b72612207a87	measurements	{"items": [{"quantity": "10", "description": "cabinets", "quantityUnit": "pieces", "measurementType": "quantity"}, {"dimensions": {"units": "feet", "width": "10", "length": "10"}, "description": "Vapor barrier and insulation", "measurementType": "area"}, {"dimensions": {"units": "feet", "width": "10", "length": "10"}, "description": "subfloor", "measurementType": "area"}], "notes": ""}	2025-04-18 21:58:04.456+00
004e1da5-b0a9-4e5f-9c51-02e96ca287c7	b3386254-0d2e-45e7-9736-b72612207a87	materials	{"items": [{"name": "", "unit": "sq_ft", "quantity": ""}], "notes": ""}	2025-04-18 21:58:04.479+00
9a54aebd-5295-43e6-be18-cbcd418cdc71	22eeb487-72f8-4e8b-92f7-b768a2df55d2	condition	{"notes": "", "assessment": "Remove sleeper boards. Remove decking. Modified bitumen repair. Sealing fasteners. Reinstall deck."}	2025-05-02 01:51:30.678+00
3fe88fa0-adf1-4f16-b2e7-da96b1ede420	22eeb487-72f8-4e8b-92f7-b768a2df55d2	measurements	{"items": [{"dimensions": {"units": "feet", "width": "17", "length": "11"}, "description": "Deck area", "measurement_type": "area"}], "notes": ""}	2025-05-02 01:51:30.712+00
66067937-8f1d-4d15-b4d7-8c31ca04fcf5	22eeb487-72f8-4e8b-92f7-b768a2df55d2	materials	{"items": [{"name": "Sleeper boards", "unit": "each", "quantity": "9"}], "notes": ""}	2025-05-02 01:51:30.742+00
9a3342ae-f3b5-445a-b76f-d69b7191542b	9f6ffe15-0ef1-4411-bb5f-1c020268066b	condition	{"notes": "", "assessment": "Pan roof anchor system. Tpo roof"}	2025-05-06 14:01:50.266+00
1791bc04-07c2-4575-a1f4-db0066d14239	9f6ffe15-0ef1-4411-bb5f-1c020268066b	materials	{"items": [{"name": "", "quantity": ""}], "notes": ""}	2025-05-06 14:01:50.308+00
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

COPY public.projects (id, client_id, estimate_id, type, status, scheduled_date, condition, created_at, updated_at, additional_work, address_id, assessment_id, converted_to_job_id, pre_assessment_id, work_types) FROM stdin;
38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533	3913a2b7-dac8-447a-9e20-76fe2bf340b3	assessment	completed	2025-04-08	Customer had a leak underneath mobile home and has various issues that need to be fixed. Subfloor, needs new cabinets, flooring, underpinning and insulation 	2025-04-08 20:15:08.386+00	2025-04-15 18:03:07.318+00	\N	3cd9e874-8bbd-40ed-ab8e-a846fd4b31ae	\N	0d240d0f-fe51-4e42-8cf3-654f75d52b97	\N	[]
b3386254-0d2e-45e7-9736-b72612207a87	26ff807d-0535-49c3-8144-2aae123c02ed	\N	assessment	pending	2025-04-16	\N	2025-04-16 03:12:17.846+00	2025-04-16 03:12:17.846+00	\N	c18892a9-8e8a-4592-a61d-10293cb131a3	\N	\N	\N	[]
0d240d0f-fe51-4e42-8cf3-654f75d52b97	a04af1e2-7946-4387-ad73-7456c91af533	3913a2b7-dac8-447a-9e20-76fe2bf340b3	active	completed	2025-04-15	Customer had a leak underneath mobile home and has various issues that need to be fixed. Subfloor, needs new cabinets, flooring, underpinning and insulation 	2025-04-15 18:03:07.315+00	2025-05-01 21:10:56.63+00	\N	3cd9e874-8bbd-40ed-ab8e-a846fd4b31ae	38edf41a-6968-48ed-af13-fed5c8d3060f	\N	\N	[]
22eeb487-72f8-4e8b-92f7-b768a2df55d2	98c1612d-919c-4b88-8141-234bd88dea3e	\N	assessment	pending	2025-05-01	\N	2025-05-01 21:11:15.808+00	2025-05-02 01:51:30.784+00	\N	247649a3-fbe7-4dc7-bc12-43f61168d822	\N	\N	\N	["0b9e3ec5-ed14-4e9e-925c-62a73095d1f4", "e16f2221-6308-4f41-8a5c-ab2a77b2bc1e", "bb99d236-1d6f-4b24-acf5-d5bd71fb8ad6", "20fba07f-5687-433b-b518-eb0564590d74", "6e659c54-5b16-437b-a1d5-855e0a3aedda"]
9f6ffe15-0ef1-4411-bb5f-1c020268066b	6534a9e7-0e25-4c48-b1e2-284e78bc89c9	\N	assessment	pending	2025-04-30	\N	2025-04-29 18:15:44.666+00	2025-05-06 14:01:50.345+00	\N	3311ca1b-da19-4837-b8f8-b194580affab	\N	\N	\N	["5b8413ed-0d06-4a0a-9426-0243d376974d", "d9f1c8cf-13a2-412f-8482-7b826bf56e16"]
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.settings (id, key, value, description, "group", created_at, updated_at) FROM stdin;
12	pdf_font_family	Helvetica	Font family for PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-04-02 05:13:15.375417+00
207	default_tax_rate	0	Default tax rate percentage	invoicing	2025-04-15 01:20:28.619+00	2025-04-15 01:20:28.619+00
208	default_invoice_notes	Thank you for your business!	Default notes for new invoices	invoicing	2025-04-15 01:20:28.661+00	2025-04-15 01:20:28.661+00
213	embedding_provider	gemini	Provider for vector embeddings	ai_provider	2025-04-24 14:56:46.601371+00	2025-04-27 18:09:56.656+00
214	embedding_model	gemini-embedding-exp-03-07	Model name for vector embeddings	ai_provider	2025-04-24 14:56:54.69458+00	2025-04-27 18:09:56.657+00
215	embedding_api_key	AIzaSyBnoXQYtgI54--0oYVaIFxgdR0eebE7CMw	API key for embedding provider	ai_provider	2025-04-24 14:57:02.585739+00	2025-04-27 18:09:56.657+00
216	embedding_base_url	https://generativelanguage.googleapis.com/v1beta	Base URL for embedding provider	ai_provider	2025-04-24 14:57:10.985196+00	2025-04-27 18:09:56.658+00
217	enable_vector_similarity	true	Enable vector-based similarity search	ai_provider	2025-04-24 14:57:19.2464+00	2025-04-27 18:09:56.658+00
17	pdf_footer_margin	30	Bottom margin for footer in PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-05-06 13:51:47.281+00
1	invoice_prefix	INV-	Prefix for invoice numbers	invoice	2025-04-02 05:13:15.373491+00	2025-05-06 13:51:47.304+00
2	invoice_due_days	30	Default number of days until invoice is due	invoice	2025-04-02 05:13:15.373491+00	2025-05-06 13:51:47.305+00
3	default_invoice_terms	Payment is due within {due_days} days from the date of invoice. Late payments are subject to a 1.5% monthly fee.	Default terms for invoices	invoice	2025-04-02 05:13:15.373491+00	2025-05-06 13:51:47.307+00
6	pdf_invoice_footer	Thank you for your business. Please contact us with any questions regarding this invoice.	Footer text for invoice PDFs	invoice	2025-04-02 05:13:15.373491+00	2025-05-06 13:51:47.308+00
53	estimate_prefix	EST-	\N	estimate	2025-04-08 13:01:02.798+00	2025-05-06 13:51:47.328+00
54	estimate_valid_days	30	\N	estimate	2025-04-08 13:01:02.798+00	2025-05-06 13:51:47.329+00
49	company_address		\N	company	2025-04-08 13:01:02.707+00	2025-05-05 00:47:43.635+00
55	default_estimate_terms	This estimate is valid for {valid_days} days from the date issued. To accept this estimate, please sign and return.	\N	estimate	2025-04-08 13:01:02.798+00	2025-05-06 13:51:47.329+00
50	company_phone		\N	company	2025-04-08 13:01:02.707+00	2025-05-05 00:47:43.637+00
56	pdf_estimate_footer	Thank you for considering our services. Please contact us with any questions regarding this estimate.	\N	estimate	2025-04-08 13:01:02.798+00	2025-05-06 13:51:47.329+00
209	language_model_provider	deepseek	Provider for language model tasks	ai_provider	2025-04-24 14:56:11.2232+00	2025-04-27 18:09:56.646+00
210	language_model	deepseek-chat	Model name for language tasks	ai_provider	2025-04-24 14:56:21.894182+00	2025-04-27 18:09:56.653+00
211	language_model_api_key	sk-aebbce11d90a4a5190d6be5ccf1ee504	API key for language model provider	ai_provider	2025-04-24 14:56:30.627969+00	2025-04-27 18:09:56.654+00
212	language_model_base_url	https://api.deepseek.com/v1	Base URL for language model provider	ai_provider	2025-04-24 14:56:38.940132+00	2025-04-27 18:09:56.655+00
51	company_email		\N	company	2025-04-08 13:01:02.707+00	2025-05-05 00:47:43.638+00
52	company_website		\N	company	2025-04-08 13:01:02.707+00	2025-05-05 00:47:43.639+00
4	primary_color	#3b82f6	Primary color for PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-05-06 13:51:47.27+00
13	pdf_secondary_color	#abb8c9	Secondary color for PDF accents	appearance	2025-04-02 05:13:15.373491+00	2025-05-06 13:51:47.276+00
11	pdf_background_color	#f8f9fa	Background color for table headers in PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-05-06 13:51:47.278+00
14	pdf_table_border_color	#e2e8f0	Border color for tables in PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-05-06 13:51:47.279+00
15	pdf_page_margin	50	Page margin in points for PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-05-06 13:51:47.28+00
16	pdf_header_margin	30	Top margin for header in PDF documents	appearance	2025-04-02 05:13:15.373491+00	2025-05-06 13:51:47.28+00
5	company_name	Accurate Repairs LLC	Company name for invoices and estimates	company	2025-04-02 05:13:15.373491+00	2025-05-05 22:12:54.278+00
10	company_logo_path	logo-1746449086674-134211607.png	\N	company	2025-04-02 05:13:15.373491+00	2025-05-05 12:44:51.987+00
18	pdf_watermark_text		Watermark text for PDF documents (leave empty for no watermark)	appearance	2025-04-02 05:13:15.373491+00	2025-05-05 00:47:43.682+00
\.


--
-- Data for Name: source_maps; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.source_maps (id, estimate_item_id, source_type, source_data, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: josephmcmyne
--

COPY public.users (id, username, email, password, role, theme_preference, first_name, last_name, is_active, created_at, updated_at, deleted_at, avatar) FROM stdin;
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
a9aaa74a-d8f4-4fe8-ba36-ee979a1e1e4e	Admin	joe@806040.xyz	$2b$10$KJqWx1y8kE0ER1d5ikvAXOc1gE5T7FI/Y5O9cONNGGBTeqFOPechm	admin	system	\N	\N	t	2025-04-02 05:03:37.938514+00	2025-04-18 19:35:49.482+00	\N	\N
\.


--
-- Data for Name: work_type_cost_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_type_cost_history (id, work_type_id, region, unit_cost_material, unit_cost_labor, captured_at, updated_by, created_at, updated_at) FROM stdin;
ea0f2473-41b1-48c4-b3d3-b28d95e5bd56	f05d3fab-349e-43c2-91ff-d3becf3b3fd1	default	1.25	2.75	2025-04-21 19:25:14.546438+00	\N	2025-04-21 19:25:14.546438+00	2025-04-21 19:25:14.546438+00
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
f05d3fab-349e-43c2-91ff-d3becf3b3fd1	dust-control	2025-04-21 19:25:14.546438+00	2025-04-21 19:25:14.546438+00
\.


--
-- Data for Name: work_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_types (id, name, parent_bucket, measurement_type, suggested_units, unit_cost_material, unit_cost_labor, productivity_unit_per_hr, name_vec, revision, updated_by, created_at, updated_at) FROM stdin;
f05d3fab-349e-43c2-91ff-d3becf3b3fd1	Install Drywall	Interior-Finish	area	sq ft	1.25	2.75	50.00	\N	1	\N	2025-04-21 19:25:14.546438+00	2025-04-21 19:25:14.546438+00
85f2c1a0-3f3a-4ba4-a0c1-76d789e0f7a1	Subfloor Replacement	Interior-Structural	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.392+00	2025-04-23 16:53:31.392+00
4a1fb3c2-90de-42b6-b3f7-c5e7a8d10c9b	Floor Joist Sistering	Interior-Structural	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.396+00	2025-04-23 16:53:31.396+00
e20378d5-6fa4-48e9-b215-3c9d8f67c42a	Floor Insulation Replacement	Interior-Structural	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.398+00	2025-04-23 16:53:31.398+00
7c23db1a-f82e-4d3c-95b0-42a1e8c7b593	Mobile-Home Leveling	Exterior-Structural	quantity	job	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.401+00	2025-04-23 16:53:31.401+00
f68d4a91-c2e0-4f7b-8d32-61a9e507c124	Pier/Block Replacement	Exterior-Structural	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.402+00	2025-04-23 16:53:31.402+00
a012c3e4-5f67-48d9-b0a1-c2d3e4f5a6b7	Tornado Anchor Installation	Exterior-Structural	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.404+00	2025-04-23 16:53:31.404+00
b123d4e5-6f78-49e0-a1b2-c3d4e5f6a7b8	Metal Roof-Over (Single-Wide)	Exterior-Structural	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.406+00	2025-04-23 16:53:31.406+00
c234e5f6-7a89-4af1-b2c3-d4e5f6a7b8c9	Metal Roof-Over (Double-Wide)	Exterior-Structural	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.408+00	2025-04-23 16:53:31.408+00
b789d0e1-2f34-4fe6-a7b8-c9d0e1f2a3b4	Skirting Vent Replacement	Exterior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.414+00	2025-04-23 16:53:31.414+00
c890e1f2-3a45-4af7-b8c9-d0e1f2a3b4c5	Vinyl Siding Replacement	Exterior-Finish	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.414+00	2025-04-23 16:53:31.414+00
b345d6e7-8f90-4fec-a3b4-c5d6e7f8a9b0	Deck Construction (8×16)	Exterior-Structural	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.424+00	2025-04-23 16:53:31.424+00
c456e7f8-9a01-4afd-b4c5-d6e7f8a9b0c1	Deck Railing Replacement	Exterior-Finish	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.424+00	2025-04-23 16:53:31.424+00
b901d2e3-4f56-4fd2-a9b0-c1d2e3f4a5b6	PEX Re-Pipe (Whole Home)	Mechanical	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.428+00	2025-04-23 16:53:31.428+00
c012e3f4-5a67-4ae3-b0c1-d2e3f4a5b6c7	Under-Belly Repair	Interior-Structural	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.429+00	2025-04-23 16:53:31.429+00
b567d8e9-0f12-4fd8-a5b6-c7d8e9f0a1b2	Countertop Install (Laminate)	Interior-Finish	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.432+00	2025-04-23 16:53:31.432+00
c678e9f0-1a23-4ae9-b6c7-d8e9f0a1b2c3	Back-Splash Tile Install	Interior-Finish	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.433+00	2025-04-23 16:53:31.433+00
b123d4e5-6f78-4fce-a1b2-c3d4e5f6a7b8	Baseboard Install	Interior-Finish	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.441+00	2025-04-23 16:53:31.441+00
c234e5f6-7a89-4adf-b2c3-d4e5f6a7b8c9	Interior Door Replacement	Interior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.441+00	2025-04-23 16:53:31.441+00
b789d0e1-2f34-4fc4-a7b8-c9d0e1f2a3b4	Toilet Replacement	Interior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.445+00	2025-04-23 16:53:31.445+00
c890e1f2-3a45-4ad5-b8c9-d0e1f2a3b4c5	Bathroom Vanity Install	Interior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.446+00	2025-04-23 16:53:31.446+00
b345d6e7-8f90-4fca-a3b4-c5d6e7f8a9b0	Electrical Outlet Upgrade	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.451+00	2025-04-23 16:53:31.451+00
c456e7f8-9a01-4adb-b4c5-d6e7f8a9b0c1	LED Ceiling Light Install	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.451+00	2025-04-23 16:53:31.451+00
b901d2e3-4f56-4fa0-a9b0-c1d2e3f4a5b6	Storm-Door Install	Exterior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.455+00	2025-04-23 16:53:31.455+00
c012e3f4-5a67-4ab1-b0c1-d2e3f4a5b6c7	Insulated Belly Wrap	Interior-Structural	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.456+00	2025-04-23 16:53:31.456+00
2ef9a407-ff16-4020-bc89-64ee9a3be33b	Gutter Installation	Exterior-Finish	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.41+00	2025-04-23 16:53:31.41+00
7506d5df-a6ca-4ac4-ab3a-2e78f95d6deb	Gutter Guard Install	Exterior-Finish	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.411+00	2025-04-23 16:53:31.411+00
cb3585ce-e434-4837-953c-deb8363901e9	Skirting Installation	Exterior-Finish	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.413+00	2025-04-23 16:53:31.413+00
0a1f03a6-1fb1-4ed8-ae16-5f690707c8d6	Window Replacement	Exterior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.416+00	2025-04-23 16:53:31.416+00
52df45de-a80b-4411-916c-373dbbe6c28e	Exterior Door Replacement	Exterior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.421+00	2025-04-23 16:53:31.421+00
4b83cd9b-d594-4594-bbef-d2fd7fa1a114	French-Door Install	Exterior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.422+00	2025-04-23 16:53:31.422+00
329a0e90-8582-41d4-b7f2-b90f8224d1b4	Exterior Painting	Exterior-Finish	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.423+00	2025-04-23 16:53:31.423+00
a8b69939-0b22-410b-ad65-a76ffdf941ae	Ramp Construction (ADA)	Exterior-Structural	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.425+00	2025-04-23 16:53:31.425+00
d0ebe760-3cd1-4caa-9197-ecee9e90b17c	HVAC Package-Unit Swap	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.426+00	2025-04-23 16:53:31.426+00
da143bfa-b1e9-4184-9b02-274b40b2d0a0	Ductwork Reseal	Mechanical	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.427+00	2025-04-23 16:53:31.427+00
aa2a2b65-77d6-40b3-9922-2e7f50d56864	Water-Heater Replacement	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.427+00	2025-04-23 16:53:31.427+00
62e45da4-2004-42c7-87fb-9a8c2fd66f8c	Electrical Panel Upgrade	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.43+00	2025-04-23 16:53:31.43+00
8739f725-4bf6-4751-bc75-26e746cde1b2	Branch-Circuit Rewire	Mechanical	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.43+00	2025-04-23 16:53:31.43+00
48a85d99-bbfc-4fc8-a7e2-252f3f9a4432	Smoke Detector Install	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.431+00	2025-04-23 16:53:31.431+00
0382d7e3-d2a2-4889-b055-d4622c29b129	Kitchen Cabinet Replacement	Interior-Finish	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.432+00	2025-04-23 16:53:31.432+00
0b9159d6-5b47-4113-97f5-95563b63b56c	Appliance Set Install	Interior-Finish	quantity	set	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.436+00	2025-04-23 16:53:31.436+00
75de6a86-0ba2-4793-87af-fd7e0ad9907d	Carpet Replacement	Interior-Finish	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.439+00	2025-04-23 16:53:31.439+00
868fd4d2-0ca9-4b05-a08f-be075cc9c370	Interior Painting (Walls)	Interior-Finish	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.44+00	2025-04-23 16:53:31.44+00
28a1b168-7e19-4b23-bf92-ea7b9efeb78e	Drywall Repair (Small Hole)	Interior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.442+00	2025-04-23 16:53:31.442+00
4181f486-8b2d-440b-a21a-140df7d679ae	Textured Ceiling Repair	Interior-Finish	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.443+00	2025-04-23 16:53:31.443+00
2d2283d5-e004-4bb0-8cad-a2f52dc9c2b5	Standing Shower Installation	Interior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.443+00	2025-04-23 16:53:31.443+00
53c43c3b-5cc6-40f7-8230-d8ec4516d3eb	Tub-to-Shower Conversion	Interior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.444+00	2025-04-23 16:53:31.444+00
0e07f5cf-4710-4478-93c9-2ee475fd1869	Exhaust Fan Install (Bath)	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.446+00	2025-04-23 16:53:31.446+00
5a4b3c7e-b22b-4172-b581-9929c5ab0511	Closet Door Install	Interior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.447+00	2025-04-23 16:53:31.447+00
533c0feb-4322-4afe-afbd-3761970e8b6c	Interior Trim Caulking	Interior-Finish	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.448+00	2025-04-23 16:53:31.448+00
f4319bb9-54a2-4b67-9c67-aaf9ef010ae7	Interior Door Hardware Swap	Interior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.449+00	2025-04-23 16:53:31.449+00
d453fb26-e92f-45ce-940a-64b6b7860df8	Skylight Replacement	Exterior-Structural	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.452+00	2025-04-23 16:53:31.452+00
44c15df5-3ffb-456a-8ece-f7b70dcf880c	Roof Vent Installation	Exterior-Structural	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.453+00	2025-04-23 16:53:31.453+00
bb6b992c-d9a0-4f4b-9f87-e29c0786519e	Awning Installation	Exterior-Finish	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.453+00	2025-04-23 16:53:31.453+00
cddff742-18d4-4428-bf8b-045a0848d559	Carport Post Replacement	Exterior-Structural	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.454+00	2025-04-23 16:53:31.454+00
32a3cfd6-e7c6-46f6-82fa-4c9edcf35797	Vapor Barrier Install	Interior-Structural	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.456+00	2025-04-23 16:53:31.456+00
e7d62852-315b-4d6b-b436-201768994ec3	Laundry Hook-Up Install	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.457+00	2025-04-23 16:53:31.457+00
a66cb133-cf5a-4bf1-9b09-3e5492d958a5	Dryer Vent Reroute	Mechanical	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.458+00	2025-04-23 16:53:31.458+00
b567d8e9-0f12-4fa6-a5b6-c7d8e9f0a1b2	Kitchen Sink Replacement	Interior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.459+00	2025-04-23 16:53:31.459+00
c678e9f0-1a23-4ab7-b6c7-d8e9f0a1b2c3	Faucet Replacement (Kitchen)	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.46+00	2025-04-23 16:53:31.46+00
b123d4e5-6f78-4fac-a1b2-c3d4e5f6a7b8	Water Softener Install	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.468+00	2025-04-23 16:53:31.468+00
c234e5f6-7a89-4abd-b2c3-d4e5f6a7b8c9	Interior Wall Panel Remove & Replace	Interior-Structural	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.469+00	2025-04-23 16:53:31.469+00
b789d0e1-2f34-4fa2-a7b8-c9d0e1f2a3b4	Tie-Down Strap Replacement	Exterior-Structural	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.472+00	2025-04-23 16:53:31.472+00
c890e1f2-3a45-4ab3-b8c9-d0e1f2a3b4c5	Roof Jack Flashing Replace	Exterior-Structural	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.473+00	2025-04-23 16:53:31.473+00
b345d6e7-8f90-4fa8-a3b4-c5d6e7f8a9b0	Water Line Insulation	Mechanical	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.476+00	2025-04-23 16:53:31.476+00
c456e7f8-9a01-4ab9-b4c5-d6e7f8a9b0c1	Foundation Skirt Foam Backfill	Exterior-Structural	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.477+00	2025-04-23 16:53:31.477+00
0cbcb29e-c6b5-4198-9863-c84c43d51d77	EPDM Roof Coating	Exterior-Structural	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.409+00	2025-04-23 16:53:31.409+00
6740e26c-e777-440d-9dcf-438ad888f6ad	Vinyl Plank Flooring Install	Interior-Finish	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.437+00	2025-04-23 16:53:31.437+00
aa38c232-cb03-4c4c-9962-d4015fa75314	Range Hood Install	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.458+00	2025-04-23 16:53:31.458+00
99bdbb65-e1d9-4a44-8aaf-8f713b8b372c	Faucet Replacement (Bath)	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.461+00	2025-04-23 16:53:31.461+00
44b8c34a-04c3-48a1-8091-46af6736ff81	Sub-Panel Add-On	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.461+00	2025-04-23 16:53:31.461+00
997c95b4-fbae-408a-96d4-f6ea11c5e9f7	Smart Thermostat Install	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.465+00	2025-04-23 16:53:31.465+00
c7936c3a-b2fa-4917-9a6a-eceba8324beb	Whole-House Surge Protector	Mechanical	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.466+00	2025-04-23 16:53:31.466+00
7138cf0f-5e85-4b1c-ac43-9eac9e8289b4	Interior Wall Panel Paint-Prep	Interior-Finish	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.469+00	2025-04-23 16:53:31.469+00
b622a2be-a61b-4a62-829d-4d78aaf6a208	Mold Remediation (Spot)	Interior-Structural	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.47+00	2025-04-23 16:53:31.47+00
654ce835-c7cf-4789-9098-c5af79bc2ceb	Asbestos Tile Abatement	Interior-Structural	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.471+00	2025-04-23 16:53:31.471+00
e4bf1195-787c-48dc-8fc3-273ec415e372	Skirting Access Door Install	Exterior-Finish	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.472+00	2025-04-23 16:53:31.472+00
ea723e9b-2426-451d-9243-b979f7bf784f	Refrigerator Vent Cap Replace	Exterior-Structural	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.473+00	2025-04-23 16:53:31.473+00
6dff931f-b07d-412f-a2c6-8029d5045ea7	Porch Screen Repair	Exterior-Finish	area	sq ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.474+00	2025-04-23 16:53:31.474+00
ae192513-8d31-4daa-a6e3-8a22fe6d00fd	Window AC Cut-In	Exterior-Structural	quantity	each	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.474+00	2025-04-23 16:53:31.474+00
eb747a45-153f-43ef-9e1b-2ce5590f50b4	Heat Tape Install (Water Line)	Mechanical	linear	ft	0.00	0.00	0.00	\N	1	\N	2025-04-23 16:53:31.475+00	2025-04-23 16:53:31.475+00
5b8413ed-0d06-4a0a-9426-0243d376974d	Pan roof anchor system	Exterior-Structural	quantity	each	\N	\N	\N	\N	1	\N	2025-05-01 13:46:31.297+00	2025-05-01 13:46:31.297+00
0b9e3ec5-ed14-4e9e-925c-62a73095d1f4	Remove sleeper boards	Exterior-Structural	area	sq ft	\N	\N	\N	\N	1	\N	2025-05-02 01:16:59.284+00	2025-05-02 01:16:59.284+00
e16f2221-6308-4f41-8a5c-ab2a77b2bc1e	Remove decking	Exterior-Structural	area	sq ft	\N	\N	\N	\N	1	\N	2025-05-02 01:40:56.472+00	2025-05-02 01:40:56.472+00
bb99d236-1d6f-4b24-acf5-d5bd71fb8ad6	Modified bitumen patch	Exterior-Structural	quantity	each	\N	\N	\N	\N	1	\N	2025-05-02 01:44:26.481+00	2025-05-02 01:44:26.481+00
20fba07f-5687-433b-b518-eb0564590d74	Sealing fasteners	Exterior-Finish	quantity	each	\N	\N	\N	\N	1	\N	2025-05-02 01:49:35.738+00	2025-05-02 01:49:35.738+00
6e659c54-5b16-437b-a1d5-855e0a3aedda	Reinstall deck	Exterior-Structural	area	sq ft	\N	\N	\N	\N	1	\N	2025-05-02 01:51:11.354+00	2025-05-02 01:51:11.354+00
ca75142a-dbaf-4e08-8b0a-01e1b2065e77	Pan roof installation	Exterior-Structural	linear	ft	\N	\N	\N	\N	1	\N	2025-05-06 13:56:13.865+00	2025-05-06 13:56:13.865+00
d9f1c8cf-13a2-412f-8482-7b826bf56e16	New TPO Roof system	Exterior-Structural	area	sq ft	\N	\N	\N	\N	1	\N	2025-05-06 14:01:32.982+00	2025-05-06 14:01:32.982+00
\.


--
-- Name: ad_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ad_types_id_seq', 14, true);


--
-- Name: communities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.communities_id_seq', 680, true);


--
-- Name: llm_prompts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: josephmcmyne
--

SELECT pg_catalog.setval('public.llm_prompts_id_seq', 5, true);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: josephmcmyne
--

SELECT pg_catalog.setval('public.settings_id_seq', 605, true);


--
-- Name: SequelizeMeta SequelizeMeta_pkey; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public."SequelizeMeta"
    ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);


--
-- Name: assessment_work_types assessment_work_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_work_types
    ADD CONSTRAINT assessment_work_types_pkey PRIMARY KEY (id);


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
-- Name: estimates estimates_estimate_number_key109; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key109 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key11; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key11 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key110; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key110 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key111; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key111 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key112; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key112 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key113; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key113 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key114; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key114 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key115; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key115 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key116; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key116 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key117; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key117 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key118; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key118 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key119; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key119 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key12; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key12 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key120; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key120 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key121; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key121 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key122; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key122 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key123; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key123 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key124; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key124 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key125; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key125 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key126; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key126 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key127; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key127 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key128; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key128 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key129; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key129 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key13; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key13 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key130; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key130 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key131; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key131 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key132; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key132 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key133; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key133 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key134; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key134 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key135; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key135 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key136; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key136 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key137; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key137 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key138; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key138 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key139; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key139 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key14; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key14 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key140; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key140 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key141; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key141 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key142; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key142 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key143; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key143 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key144; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key144 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key145; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key145 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key146; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key146 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key147; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key147 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key148; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key148 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key149; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key149 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key15; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key15 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key150; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key150 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key151; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key151 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key152; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key152 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key153; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key153 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key154; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key154 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key155; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key155 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key156; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key156 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key157; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key157 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key158; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key158 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key159; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key159 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key16; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key16 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key160; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key160 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key161; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key161 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key162; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key162 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key163; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key163 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key164; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key164 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key165; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key165 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key166; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key166 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key167; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key167 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key168; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key168 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key169; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key169 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key17; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key17 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key170; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key170 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key171; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key171 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key172; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key172 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key173; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key173 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key174; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key174 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key175; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key175 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key176; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key176 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key177; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key177 UNIQUE (estimate_number);


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
-- Name: communities idx_63850_communities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.communities
    ADD CONSTRAINT idx_63850_communities_pkey PRIMARY KEY (id);


--
-- Name: ad_types idx_63858_ad_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ad_types
    ADD CONSTRAINT idx_63858_ad_types_pkey PRIMARY KEY (id);


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
-- Name: invoices invoices_invoice_number_key110; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key110 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key111; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key111 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key112; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key112 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key113; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key113 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key114; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key114 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key115; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key115 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key116; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key116 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key117; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key117 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key118; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key118 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key119; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key119 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key12; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key12 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key120; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key120 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key121; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key121 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key122; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key122 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key123; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key123 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key124; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key124 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key125; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key125 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key126; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key126 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key127; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key127 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key128; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key128 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key129; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key129 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key13; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key13 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key130; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key130 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key131; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key131 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key132; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key132 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key133; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key133 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key134; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key134 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key135; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key135 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key136; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key136 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key137; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key137 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key138; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key138 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key139; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key139 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key14; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key14 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key140; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key140 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key141; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key141 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key142; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key142 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key143; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key143 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key144; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key144 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key145; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key145 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key146; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key146 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key147; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key147 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key148; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key148 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key149; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key149 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key15; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key15 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key150; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key150 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key151; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key151 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key152; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key152 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key153; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key153 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key154; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key154 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key155; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key155 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key156; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key156 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key157; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key157 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key158; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key158 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key159; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key159 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key16; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key16 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key160; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key160 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key161; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key161 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key162; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key162 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key163; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key163 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key164; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key164 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key165; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key165 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key166; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key166 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key167; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key167 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key168; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key168 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key169; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key169 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key17; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key17 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key170; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key170 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key171; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key171 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key172; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key172 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key173; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key173 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key174; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key174 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key175; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key175 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key176; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key176 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key177; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key177 UNIQUE (invoice_number);


--
-- Name: invoices invoices_invoice_number_key178; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key178 UNIQUE (invoice_number);


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
-- Name: settings settings_key_key10; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key10 UNIQUE (key);


--
-- Name: settings settings_key_key11; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key11 UNIQUE (key);


--
-- Name: settings settings_key_key12; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key12 UNIQUE (key);


--
-- Name: settings settings_key_key13; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key13 UNIQUE (key);


--
-- Name: settings settings_key_key14; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key14 UNIQUE (key);


--
-- Name: settings settings_key_key15; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key15 UNIQUE (key);


--
-- Name: settings settings_key_key16; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key16 UNIQUE (key);


--
-- Name: settings settings_key_key17; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key17 UNIQUE (key);


--
-- Name: settings settings_key_key18; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key18 UNIQUE (key);


--
-- Name: settings settings_key_key19; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key19 UNIQUE (key);


--
-- Name: settings settings_key_key2; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key2 UNIQUE (key);


--
-- Name: settings settings_key_key20; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key20 UNIQUE (key);


--
-- Name: settings settings_key_key21; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key21 UNIQUE (key);


--
-- Name: settings settings_key_key22; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key22 UNIQUE (key);


--
-- Name: settings settings_key_key23; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key23 UNIQUE (key);


--
-- Name: settings settings_key_key24; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key24 UNIQUE (key);


--
-- Name: settings settings_key_key25; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key25 UNIQUE (key);


--
-- Name: settings settings_key_key26; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key26 UNIQUE (key);


--
-- Name: settings settings_key_key27; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key27 UNIQUE (key);


--
-- Name: settings settings_key_key28; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key28 UNIQUE (key);


--
-- Name: settings settings_key_key29; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key29 UNIQUE (key);


--
-- Name: settings settings_key_key3; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key3 UNIQUE (key);


--
-- Name: settings settings_key_key30; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key30 UNIQUE (key);


--
-- Name: settings settings_key_key31; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key31 UNIQUE (key);


--
-- Name: settings settings_key_key32; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key32 UNIQUE (key);


--
-- Name: settings settings_key_key33; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key33 UNIQUE (key);


--
-- Name: settings settings_key_key34; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key34 UNIQUE (key);


--
-- Name: settings settings_key_key35; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key35 UNIQUE (key);


--
-- Name: settings settings_key_key36; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key36 UNIQUE (key);


--
-- Name: settings settings_key_key37; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key37 UNIQUE (key);


--
-- Name: settings settings_key_key38; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key38 UNIQUE (key);


--
-- Name: settings settings_key_key39; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key39 UNIQUE (key);


--
-- Name: settings settings_key_key4; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key4 UNIQUE (key);


--
-- Name: settings settings_key_key40; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key40 UNIQUE (key);


--
-- Name: settings settings_key_key41; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key41 UNIQUE (key);


--
-- Name: settings settings_key_key42; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key42 UNIQUE (key);


--
-- Name: settings settings_key_key43; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key43 UNIQUE (key);


--
-- Name: settings settings_key_key44; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key44 UNIQUE (key);


--
-- Name: settings settings_key_key45; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key45 UNIQUE (key);


--
-- Name: settings settings_key_key46; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key46 UNIQUE (key);


--
-- Name: settings settings_key_key47; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key47 UNIQUE (key);


--
-- Name: settings settings_key_key48; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key48 UNIQUE (key);


--
-- Name: settings settings_key_key49; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key49 UNIQUE (key);


--
-- Name: settings settings_key_key5; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key5 UNIQUE (key);


--
-- Name: settings settings_key_key50; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key50 UNIQUE (key);


--
-- Name: settings settings_key_key51; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key51 UNIQUE (key);


--
-- Name: settings settings_key_key52; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key52 UNIQUE (key);


--
-- Name: settings settings_key_key53; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key53 UNIQUE (key);


--
-- Name: settings settings_key_key54; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key54 UNIQUE (key);


--
-- Name: settings settings_key_key55; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key55 UNIQUE (key);


--
-- Name: settings settings_key_key56; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key56 UNIQUE (key);


--
-- Name: settings settings_key_key57; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key57 UNIQUE (key);


--
-- Name: settings settings_key_key58; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key58 UNIQUE (key);


--
-- Name: settings settings_key_key59; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key59 UNIQUE (key);


--
-- Name: settings settings_key_key6; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key6 UNIQUE (key);


--
-- Name: settings settings_key_key60; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key60 UNIQUE (key);


--
-- Name: settings settings_key_key61; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key61 UNIQUE (key);


--
-- Name: settings settings_key_key62; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key62 UNIQUE (key);


--
-- Name: settings settings_key_key63; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key63 UNIQUE (key);


--
-- Name: settings settings_key_key64; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key64 UNIQUE (key);


--
-- Name: settings settings_key_key65; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key65 UNIQUE (key);


--
-- Name: settings settings_key_key66; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key66 UNIQUE (key);


--
-- Name: settings settings_key_key67; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key67 UNIQUE (key);


--
-- Name: settings settings_key_key68; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key68 UNIQUE (key);


--
-- Name: settings settings_key_key69; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key69 UNIQUE (key);


--
-- Name: settings settings_key_key7; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key7 UNIQUE (key);


--
-- Name: settings settings_key_key70; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key70 UNIQUE (key);


--
-- Name: settings settings_key_key71; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key71 UNIQUE (key);


--
-- Name: settings settings_key_key72; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key72 UNIQUE (key);


--
-- Name: settings settings_key_key73; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key73 UNIQUE (key);


--
-- Name: settings settings_key_key74; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key74 UNIQUE (key);


--
-- Name: settings settings_key_key75; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key75 UNIQUE (key);


--
-- Name: settings settings_key_key76; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key76 UNIQUE (key);


--
-- Name: settings settings_key_key77; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key77 UNIQUE (key);


--
-- Name: settings settings_key_key8; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key8 UNIQUE (key);


--
-- Name: settings settings_key_key9; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key9 UNIQUE (key);


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
-- Name: users users_email_key403; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key403 UNIQUE (email);


--
-- Name: users users_email_key404; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key404 UNIQUE (email);


--
-- Name: users users_email_key405; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key405 UNIQUE (email);


--
-- Name: users users_email_key406; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key406 UNIQUE (email);


--
-- Name: users users_email_key407; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key407 UNIQUE (email);


--
-- Name: users users_email_key408; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key408 UNIQUE (email);


--
-- Name: users users_email_key409; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key409 UNIQUE (email);


--
-- Name: users users_email_key41; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key41 UNIQUE (email);


--
-- Name: users users_email_key410; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key410 UNIQUE (email);


--
-- Name: users users_email_key411; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key411 UNIQUE (email);


--
-- Name: users users_email_key412; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key412 UNIQUE (email);


--
-- Name: users users_email_key413; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key413 UNIQUE (email);


--
-- Name: users users_email_key414; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key414 UNIQUE (email);


--
-- Name: users users_email_key415; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key415 UNIQUE (email);


--
-- Name: users users_email_key416; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key416 UNIQUE (email);


--
-- Name: users users_email_key417; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key417 UNIQUE (email);


--
-- Name: users users_email_key418; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key418 UNIQUE (email);


--
-- Name: users users_email_key419; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key419 UNIQUE (email);


--
-- Name: users users_email_key42; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key42 UNIQUE (email);


--
-- Name: users users_email_key420; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key420 UNIQUE (email);


--
-- Name: users users_email_key421; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key421 UNIQUE (email);


--
-- Name: users users_email_key422; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key422 UNIQUE (email);


--
-- Name: users users_email_key423; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key423 UNIQUE (email);


--
-- Name: users users_email_key424; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key424 UNIQUE (email);


--
-- Name: users users_email_key425; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key425 UNIQUE (email);


--
-- Name: users users_email_key426; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key426 UNIQUE (email);


--
-- Name: users users_email_key427; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key427 UNIQUE (email);


--
-- Name: users users_email_key428; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key428 UNIQUE (email);


--
-- Name: users users_email_key429; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key429 UNIQUE (email);


--
-- Name: users users_email_key43; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key43 UNIQUE (email);


--
-- Name: users users_email_key430; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key430 UNIQUE (email);


--
-- Name: users users_email_key431; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key431 UNIQUE (email);


--
-- Name: users users_email_key432; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key432 UNIQUE (email);


--
-- Name: users users_email_key433; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key433 UNIQUE (email);


--
-- Name: users users_email_key434; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key434 UNIQUE (email);


--
-- Name: users users_email_key435; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key435 UNIQUE (email);


--
-- Name: users users_email_key436; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key436 UNIQUE (email);


--
-- Name: users users_email_key437; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key437 UNIQUE (email);


--
-- Name: users users_email_key438; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key438 UNIQUE (email);


--
-- Name: users users_email_key439; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key439 UNIQUE (email);


--
-- Name: users users_email_key44; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key44 UNIQUE (email);


--
-- Name: users users_email_key440; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key440 UNIQUE (email);


--
-- Name: users users_email_key441; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key441 UNIQUE (email);


--
-- Name: users users_email_key442; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key442 UNIQUE (email);


--
-- Name: users users_email_key443; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key443 UNIQUE (email);


--
-- Name: users users_email_key444; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key444 UNIQUE (email);


--
-- Name: users users_email_key445; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key445 UNIQUE (email);


--
-- Name: users users_email_key446; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key446 UNIQUE (email);


--
-- Name: users users_email_key447; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key447 UNIQUE (email);


--
-- Name: users users_email_key448; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key448 UNIQUE (email);


--
-- Name: users users_email_key449; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key449 UNIQUE (email);


--
-- Name: users users_email_key45; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key45 UNIQUE (email);


--
-- Name: users users_email_key450; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key450 UNIQUE (email);


--
-- Name: users users_email_key451; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key451 UNIQUE (email);


--
-- Name: users users_email_key452; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key452 UNIQUE (email);


--
-- Name: users users_email_key453; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key453 UNIQUE (email);


--
-- Name: users users_email_key454; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key454 UNIQUE (email);


--
-- Name: users users_email_key455; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key455 UNIQUE (email);


--
-- Name: users users_email_key456; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key456 UNIQUE (email);


--
-- Name: users users_email_key457; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key457 UNIQUE (email);


--
-- Name: users users_email_key458; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key458 UNIQUE (email);


--
-- Name: users users_email_key459; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key459 UNIQUE (email);


--
-- Name: users users_email_key46; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key46 UNIQUE (email);


--
-- Name: users users_email_key460; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key460 UNIQUE (email);


--
-- Name: users users_email_key461; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key461 UNIQUE (email);


--
-- Name: users users_email_key462; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key462 UNIQUE (email);


--
-- Name: users users_email_key463; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key463 UNIQUE (email);


--
-- Name: users users_email_key464; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key464 UNIQUE (email);


--
-- Name: users users_email_key465; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key465 UNIQUE (email);


--
-- Name: users users_email_key466; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key466 UNIQUE (email);


--
-- Name: users users_email_key467; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key467 UNIQUE (email);


--
-- Name: users users_email_key468; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key468 UNIQUE (email);


--
-- Name: users users_email_key469; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key469 UNIQUE (email);


--
-- Name: users users_email_key47; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key47 UNIQUE (email);


--
-- Name: users users_email_key470; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key470 UNIQUE (email);


--
-- Name: users users_email_key471; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key471 UNIQUE (email);


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
-- Name: users users_username_key927; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key927 UNIQUE (username);


--
-- Name: users users_username_key928; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key928 UNIQUE (username);


--
-- Name: users users_username_key929; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key929 UNIQUE (username);


--
-- Name: users users_username_key93; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key93 UNIQUE (username);


--
-- Name: users users_username_key930; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key930 UNIQUE (username);


--
-- Name: users users_username_key931; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key931 UNIQUE (username);


--
-- Name: users users_username_key932; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key932 UNIQUE (username);


--
-- Name: users users_username_key933; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key933 UNIQUE (username);


--
-- Name: users users_username_key934; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key934 UNIQUE (username);


--
-- Name: users users_username_key935; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key935 UNIQUE (username);


--
-- Name: users users_username_key936; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key936 UNIQUE (username);


--
-- Name: users users_username_key937; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key937 UNIQUE (username);


--
-- Name: users users_username_key938; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key938 UNIQUE (username);


--
-- Name: users users_username_key939; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key939 UNIQUE (username);


--
-- Name: users users_username_key94; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key94 UNIQUE (username);


--
-- Name: users users_username_key940; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key940 UNIQUE (username);


--
-- Name: users users_username_key941; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key941 UNIQUE (username);


--
-- Name: users users_username_key942; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key942 UNIQUE (username);


--
-- Name: users users_username_key943; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key943 UNIQUE (username);


--
-- Name: users users_username_key944; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key944 UNIQUE (username);


--
-- Name: users users_username_key945; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key945 UNIQUE (username);


--
-- Name: users users_username_key946; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key946 UNIQUE (username);


--
-- Name: users users_username_key947; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key947 UNIQUE (username);


--
-- Name: users users_username_key948; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key948 UNIQUE (username);


--
-- Name: users users_username_key949; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key949 UNIQUE (username);


--
-- Name: users users_username_key95; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key95 UNIQUE (username);


--
-- Name: users users_username_key950; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key950 UNIQUE (username);


--
-- Name: users users_username_key951; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key951 UNIQUE (username);


--
-- Name: users users_username_key952; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key952 UNIQUE (username);


--
-- Name: users users_username_key953; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key953 UNIQUE (username);


--
-- Name: users users_username_key954; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key954 UNIQUE (username);


--
-- Name: users users_username_key955; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key955 UNIQUE (username);


--
-- Name: users users_username_key956; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key956 UNIQUE (username);


--
-- Name: users users_username_key957; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key957 UNIQUE (username);


--
-- Name: users users_username_key958; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key958 UNIQUE (username);


--
-- Name: users users_username_key959; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key959 UNIQUE (username);


--
-- Name: users users_username_key96; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key96 UNIQUE (username);


--
-- Name: users users_username_key960; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key960 UNIQUE (username);


--
-- Name: users users_username_key961; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key961 UNIQUE (username);


--
-- Name: users users_username_key962; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key962 UNIQUE (username);


--
-- Name: users users_username_key963; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key963 UNIQUE (username);


--
-- Name: users users_username_key964; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key964 UNIQUE (username);


--
-- Name: users users_username_key965; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key965 UNIQUE (username);


--
-- Name: users users_username_key966; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key966 UNIQUE (username);


--
-- Name: users users_username_key967; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key967 UNIQUE (username);


--
-- Name: users users_username_key968; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key968 UNIQUE (username);


--
-- Name: users users_username_key969; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key969 UNIQUE (username);


--
-- Name: users users_username_key97; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key97 UNIQUE (username);


--
-- Name: users users_username_key970; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key970 UNIQUE (username);


--
-- Name: users users_username_key971; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key971 UNIQUE (username);


--
-- Name: users users_username_key972; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key972 UNIQUE (username);


--
-- Name: users users_username_key973; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key973 UNIQUE (username);


--
-- Name: users users_username_key974; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key974 UNIQUE (username);


--
-- Name: users users_username_key975; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key975 UNIQUE (username);


--
-- Name: users users_username_key976; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key976 UNIQUE (username);


--
-- Name: users users_username_key977; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key977 UNIQUE (username);


--
-- Name: users users_username_key978; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key978 UNIQUE (username);


--
-- Name: users users_username_key979; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key979 UNIQUE (username);


--
-- Name: users users_username_key98; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key98 UNIQUE (username);


--
-- Name: users users_username_key980; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key980 UNIQUE (username);


--
-- Name: users users_username_key981; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key981 UNIQUE (username);


--
-- Name: users users_username_key982; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key982 UNIQUE (username);


--
-- Name: users users_username_key983; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key983 UNIQUE (username);


--
-- Name: users users_username_key984; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key984 UNIQUE (username);


--
-- Name: users users_username_key985; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key985 UNIQUE (username);


--
-- Name: users users_username_key986; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key986 UNIQUE (username);


--
-- Name: users users_username_key987; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key987 UNIQUE (username);


--
-- Name: users users_username_key988; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key988 UNIQUE (username);


--
-- Name: users users_username_key989; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key989 UNIQUE (username);


--
-- Name: users users_username_key99; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key99 UNIQUE (username);


--
-- Name: users users_username_key990; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key990 UNIQUE (username);


--
-- Name: users users_username_key991; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key991 UNIQUE (username);


--
-- Name: users users_username_key992; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key992 UNIQUE (username);


--
-- Name: users users_username_key993; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key993 UNIQUE (username);


--
-- Name: users users_username_key994; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key994 UNIQUE (username);


--
-- Name: users users_username_key995; Type: CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key995 UNIQUE (username);


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
-- Name: ad_types_community_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ad_types_community_id ON public.ad_types USING btree (community_id);


--
-- Name: ad_types_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ad_types_name ON public.ad_types USING btree (name);


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
-- Name: communities_city; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX communities_city ON public.communities USING btree (city);


--
-- Name: communities_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX communities_is_active ON public.communities USING btree (is_active);


--
-- Name: communities_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX communities_name ON public.communities USING btree (name);


--
-- Name: estimate_item_additional_work_estimate_item_id; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX estimate_item_additional_work_estimate_item_id ON public.estimate_item_additional_work USING btree (estimate_item_id);


--
-- Name: estimate_item_additional_work_estimate_item_id_idx; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX estimate_item_additional_work_estimate_item_id_idx ON public.estimate_item_additional_work USING btree (estimate_item_id);


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
-- Name: idx_products_name_gin; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX idx_products_name_gin ON public.products USING gin (name public.gin_trgm_ops);


--
-- Name: idx_settings_group; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX idx_settings_group ON public.settings USING btree ("group");


--
-- Name: idx_work_types_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_work_types_name ON public.work_types USING gin (name public.gin_trgm_ops);


--
-- Name: idx_work_types_parent_bucket; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_work_types_parent_bucket ON public.work_types USING btree (parent_bucket);


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
-- Name: products_embedding_idx; Type: INDEX; Schema: public; Owner: josephmcmyne
--

CREATE INDEX products_embedding_idx ON public.products USING ivfflat (embedding public.vector_cosine_ops) WITH (lists='100');


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
-- Name: work_types_name_clean_gin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX work_types_name_clean_gin ON public.work_types USING gin (name_clean public.gin_trgm_ops);


--
-- Name: ad_types ad_types_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ad_types
    ADD CONSTRAINT ad_types_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.communities(id);


--
-- Name: client_addresses client_addresses_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.client_addresses
    ADD CONSTRAINT client_addresses_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: communities communities_selected_ad_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.communities
    ADD CONSTRAINT communities_selected_ad_type_id_fkey FOREIGN KEY (selected_ad_type_id) REFERENCES public.ad_types(id);


--
-- Name: estimate_item_additional_work estimate_item_additional_work_estimate_item_id; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.estimate_item_additional_work
    ADD CONSTRAINT estimate_item_additional_work_estimate_item_id FOREIGN KEY (estimate_item_id) REFERENCES public.estimate_items(id) ON UPDATE CASCADE ON DELETE CASCADE;


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
-- Name: source_maps source_maps_estimate_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: josephmcmyne
--

ALTER TABLE ONLY public.source_maps
    ADD CONSTRAINT source_maps_estimate_item_id_fkey FOREIGN KEY (estimate_item_id) REFERENCES public.estimate_items(id) DEFERRABLE INITIALLY DEFERRED;


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

