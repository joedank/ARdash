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

ALTER TABLE IF EXISTS ONLY public.projects DROP CONSTRAINT IF EXISTS projects_pre_assessment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.projects DROP CONSTRAINT IF EXISTS projects_estimate_id_fkey;
ALTER TABLE IF EXISTS ONLY public.projects DROP CONSTRAINT IF EXISTS projects_converted_to_job_id_fkey;
ALTER TABLE IF EXISTS ONLY public.projects DROP CONSTRAINT IF EXISTS projects_client_id_fkey;
ALTER TABLE IF EXISTS ONLY public.projects DROP CONSTRAINT IF EXISTS projects_assessment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.projects DROP CONSTRAINT IF EXISTS projects_address_id_fkey;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_project_id_fkey;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_converted_to_invoice_id_fkey;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_client_id_new_fkey;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_client_id_fkey;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_address_id_fkey;
DROP INDEX IF EXISTS public.projects_type_status_idx;
DROP INDEX IF EXISTS public.projects_status_idx;
DROP INDEX IF EXISTS public.projects_scheduled_date;
DROP INDEX IF EXISTS public.projects_estimate_id;
DROP INDEX IF EXISTS public.projects_client_id;
DROP INDEX IF EXISTS public.projects_assessment_id;
DROP INDEX IF EXISTS public.projects_address_id;
DROP INDEX IF EXISTS public.estimates_status_idx;
DROP INDEX IF EXISTS public.estimates_status;
DROP INDEX IF EXISTS public.estimates_project_id;
DROP INDEX IF EXISTS public.estimates_estimate_number;
DROP INDEX IF EXISTS public.estimates_client_id_idx;
DROP INDEX IF EXISTS public.estimates_address_id;
ALTER TABLE IF EXISTS ONLY public.projects DROP CONSTRAINT IF EXISTS projects_pkey;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_pkey;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key99;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key98;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key97;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key96;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key95;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key94;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key93;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key92;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key91;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key90;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key9;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key89;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key88;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key87;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key86;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key85;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key84;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key83;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key82;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key81;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key80;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key8;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key79;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key78;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key77;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key76;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key75;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key74;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key73;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key72;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key71;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key70;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key7;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key69;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key68;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key67;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key66;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key65;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key64;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key63;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key62;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key61;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key60;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key6;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key59;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key58;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key57;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key56;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key55;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key54;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key53;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key52;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key51;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key50;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key5;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key49;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key48;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key47;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key46;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key45;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key44;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key43;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key42;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key41;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key40;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key4;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key39;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key38;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key37;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key36;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key35;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key34;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key33;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key32;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key31;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key30;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key3;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key29;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key28;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key27;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key26;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key25;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key24;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key23;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key22;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key21;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key20;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key2;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key19;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key18;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key17;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key16;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key15;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key14;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key13;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key12;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key11;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key100;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key10;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key1;
ALTER TABLE IF EXISTS ONLY public.estimates DROP CONSTRAINT IF EXISTS estimates_estimate_number_key;
DROP TABLE IF EXISTS public.projects;
DROP TABLE IF EXISTS public.estimates;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: estimates; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: COLUMN estimates.pdf_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.estimates.pdf_path IS 'Path to the generated PDF file';


--
-- Name: COLUMN estimates.converted_to_invoice_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.estimates.converted_to_invoice_id IS 'Reference to invoice if this estimate was converted';


--
-- Name: COLUMN estimates.address_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.estimates.address_id IS 'Foreign key to client_addresses table for the selected address';


--
-- Name: COLUMN estimates.project_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.estimates.project_id IS 'Reference to project if this estimate is associated with a project';


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
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


--
-- Data for Name: estimates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.estimates (id, status, subtotal, tax_total, discount_amount, total, notes, terms, pdf_path, converted_to_invoice_id, created_at, updated_at, deleted_at, estimate_number, date_created, valid_until, address_id, project_id, client_id) FROM stdin;
9f30fc2f-d0eb-416e-91aa-72634242de11	accepted	3.00	0.00	0.00	3.00		This estimate is valid for 30 days.	\N	6f0ab57d-767b-4a11-b353-69954af930d5	2025-04-01 23:27:25.536-04	2025-04-14 00:17:48.875-04	\N	EST-00003	2025-04-02	2025-05-02	6c0fc1d8-ec1d-4eb7-8704-db93bf2f0e5a	00a85a20-8096-45c1-94d0-6297d1faed20	343be5ec-1b12-4b8d-bf80-998e89ab4c8b
5cf1f48e-bd50-42f7-be27-c458854537ba	sent	3.00	0.00	0.00	3.00		This estimate is valid for 30 days.	\N	\N	2025-04-02 01:13:59.287-04	2025-04-14 00:17:48.877-04	\N	EST-00005	2025-04-02	2025-05-02	6c0fc1d8-ec1d-4eb7-8704-db93bf2f0e5a	65599204-dd64-4d61-b602-33b657bf0eaf	343be5ec-1b12-4b8d-bf80-998e89ab4c8b
be712350-404e-457d-b3f8-97f02f7c42c1	accepted	9.00	0.00	0.00	9.00		This estimate is valid for 30 days.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00001.pdf	908b8942-ed53-4bbe-abe9-1529f624cb0e	2025-04-01 15:44:35.94-04	2025-04-01 21:31:25.524-04	\N	EST-00001	2025-04-01	2025-05-01	6c0fc1d8-ec1d-4eb7-8704-db93bf2f0e5a	\N	343be5ec-1b12-4b8d-bf80-998e89ab4c8b
1a2940f4-12e9-4a85-9cdd-004007175af7	sent	38.00	0.00	0.00	38.00		This estimate is valid for 30 days.	\N	\N	2025-04-01 22:22:32.707-04	2025-04-01 22:22:45.853-04	2025-04-01 22:22:45.853-04	EST-00002	2025-04-02	2025-05-02	6c0fc1d8-ec1d-4eb7-8704-db93bf2f0e5a	\N	343be5ec-1b12-4b8d-bf80-998e89ab4c8b
cff3f2d6-2159-41aa-9808-cae326f2ca19	accepted	9.00	0.00	0.00	9.00		This estimate is valid for 30 days.	\N	bbdfa5e0-f33c-4751-9b4a-ed894cffba6c	2025-04-02 00:42:53.278-04	2025-04-02 00:43:02.008-04	\N	EST-00004	2025-04-02	2025-05-02	6c0fc1d8-ec1d-4eb7-8704-db93bf2f0e5a	\N	343be5ec-1b12-4b8d-bf80-998e89ab4c8b
ba5a2454-55b7-44e3-b7b0-53a4ab306173	sent	750.00	0.00	0.00	750.00		This estimate is valid for 30 days.	\N	\N	2025-04-04 10:06:35.744-04	2025-04-04 10:06:35.754-04	\N	EST-00007	2025-04-04	2025-05-04	6b8a50c2-439a-4daa-a868-0431cbe28bd5	e5fa1c99-bd74-4e64-b81a-4603f52d9410	cef8a5e0-ba91-45da-9cb8-e20c4292b2a1
2590c2bc-1186-4a5c-a17b-57290b7438cf	sent	750.00	0.00	0.00	750.00		This estimate is valid for 30 days.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00006.pdf	\N	2025-04-04 09:54:24.22-04	2025-04-08 08:50:07.543-04	\N	EST-00006	2025-04-04	2025-05-04	6b8a50c2-439a-4daa-a868-0431cbe28bd5	\N	cef8a5e0-ba91-45da-9cb8-e20c4292b2a1
58a73b9a-c81a-46d7-9e4e-fcbdd2aff66a	draft	3612.50	0.00	0.00	3612.50	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-08 18:45:20.36-04	2025-04-08 18:45:20.41-04	\N	EST-00008	2025-04-08	2025-05-08	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
4c93d611-ce81-4c2f-88ef-823c43e2b233	draft	3664.50	0.00	0.00	3664.50	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-09 00:18:32.668-04	2025-04-09 00:18:32.705-04	\N	EST-00009	2025-04-09	2025-05-09	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
b788d32f-45f9-412a-9828-869035d4df71	draft	3222.50	0.00	0.00	3222.50	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00010.pdf	\N	2025-04-09 00:36:45.196-04	2025-04-09 01:00:28.442-04	\N	EST-00010	2025-04-09	2025-05-09	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
3913a2b7-dac8-447a-9e20-76fe2bf340b3	draft	3655.00	0.00	0.00	3655.00	Adjustments made for additional 2 cabinets and plumbing as we discussed on the phone.	This estimate is valid for 30 days from the date issued.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00011.pdf	\N	2025-04-10 09:31:25.284-04	2025-04-10 09:40:12.258-04	\N	EST-00011	2025-04-10	2025-05-10	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
223a8805-3f61-488b-b448-1ae9879297d4	draft	0.00	0.00	0.00	0.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-12 01:50:12.312-04	2025-04-12 01:50:12.34-04	\N	EST-00013	2025-04-12	2025-05-12	\N	4c05a6ed-d367-4d32-82e2-34f441852c31	26ff807d-0535-49c3-8144-2aae123c02ed
04c13dc0-ebe1-49b1-a94b-6657d959831c	draft	0.00	0.00	0.00	0.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00012.pdf	\N	2025-04-12 00:56:57.596-04	2025-04-12 01:50:31.02-04	\N	EST-00012	2025-04-12	2025-05-12	\N	4c05a6ed-d367-4d32-82e2-34f441852c31	26ff807d-0535-49c3-8144-2aae123c02ed
c350c05a-0177-40db-8575-0139bbc3b885	draft	0.00	0.00	0.00	0.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00014.pdf	\N	2025-04-12 01:54:28.507-04	2025-04-12 01:56:19.908-04	\N	EST-00014	2025-04-12	2025-05-12	\N	38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533
79be0134-6cae-4429-a8ff-1e3677024302	draft	0.00	0.00	0.00	0.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	\N	\N	2025-04-12 02:03:40.952-04	2025-04-12 02:03:40.974-04	\N	EST-00015	2025-04-12	2025-05-12	\N	4c05a6ed-d367-4d32-82e2-34f441852c31	26ff807d-0535-49c3-8144-2aae123c02ed
9c585096-b8e6-441d-8e02-ad473a2ef850	draft	11395.75	0.00	0.00	11395.75	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00017.pdf	\N	2025-04-12 09:13:05.717-04	2025-04-13 11:46:04.731-04	\N	EST-00017	2025-04-12	2025-05-12	\N	4c05a6ed-d367-4d32-82e2-34f441852c31	26ff807d-0535-49c3-8144-2aae123c02ed
7d0660d5-619c-4efc-b92d-775c55327319	accepted	12082.00	0.00	0.00	12082.00	\N	This estimate is valid for 30 days from the date issued. To accept this estimate, please sign and return.	/Volumes/4TB/Users/josephmcmyne/myProjects/management/backend/uploads/estimates/estimate_EST_00016.pdf	\N	2025-04-12 02:05:13.552-04	2025-04-14 00:16:47.032-04	\N	EST-00016	2025-04-12	2025-05-12	\N	4c05a6ed-d367-4d32-82e2-34f441852c31	26ff807d-0535-49c3-8144-2aae123c02ed
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.projects (id, client_id, estimate_id, type, status, scheduled_date, scope, created_at, updated_at, additional_work, address_id, assessment_id, converted_to_job_id, pre_assessment_id) FROM stdin;
00a85a20-8096-45c1-94d0-6297d1faed20	343be5ec-1b12-4b8d-bf80-998e89ab4c8b	9f30fc2f-d0eb-416e-91aa-72634242de11	assessment	pending	2025-04-04	test	2025-04-03 23:16:35.362-04	2025-04-03 23:16:35.362-04	\N	778075a9-1df7-4666-b705-a76015d925e0	\N	\N	\N
65599204-dd64-4d61-b602-33b657bf0eaf	343be5ec-1b12-4b8d-bf80-998e89ab4c8b	5cf1f48e-bd50-42f7-be27-c458854537ba	active	in_progress	2025-04-04	test	2025-04-03 23:17:14.633-04	2025-04-03 23:17:14.633-04	\N	778075a9-1df7-4666-b705-a76015d925e0	\N	\N	\N
a99874ae-3fc4-42ab-8d43-10c2b5c3b526	cef8a5e0-ba91-45da-9cb8-e20c4292b2a1	ba5a2454-55b7-44e3-b7b0-53a4ab306173	active	in_progress	2025-04-04	Door code 1066, restroom upstairs, left side of house at top of stairs.	2025-04-04 10:06:35.832-04	2025-04-04 10:06:35.832-04	\N	6b8a50c2-439a-4daa-a868-0431cbe28bd5	e5fa1c99-bd74-4e64-b81a-4603f52d9410	\N	\N
a39c8905-dac1-4770-88a4-ddb3d012de03	343be5ec-1b12-4b8d-bf80-998e89ab4c8b	\N	assessment	pending	2025-04-08	test	2025-04-08 00:40:51.342-04	2025-04-08 00:40:51.342-04	\N	778075a9-1df7-4666-b705-a76015d925e0	\N	\N	\N
859f67ad-d08d-44c1-88f0-c3d2ff9c9524	26ff807d-0535-49c3-8144-2aae123c02ed	7d0660d5-619c-4efc-b92d-775c55327319	active	in_progress	2025-04-14	\N	2025-04-14 00:16:47.024-04	2025-04-14 00:16:47.024-04	\N	91ed4d70-ae14-467a-89b4-8109914ef512	4c05a6ed-d367-4d32-82e2-34f441852c31	\N	\N
4c05a6ed-d367-4d32-82e2-34f441852c31	26ff807d-0535-49c3-8144-2aae123c02ed	7d0660d5-619c-4efc-b92d-775c55327319	assessment	completed	2025-04-12	\N	2025-04-11 23:07:53.667-04	2025-04-14 00:16:47.038-04	\N	91ed4d70-ae14-467a-89b4-8109914ef512	\N	859f67ad-d08d-44c1-88f0-c3d2ff9c9524	\N
e5fa1c99-bd74-4e64-b81a-4603f52d9410	cef8a5e0-ba91-45da-9cb8-e20c4292b2a1	ba5a2454-55b7-44e3-b7b0-53a4ab306173	assessment	completed	2025-04-04	Door code 1066, restroom upstairs, left side of house at top of stairs.	2025-04-03 22:27:09.061-04	2025-04-14 00:17:48.863-04	\N	6b8a50c2-439a-4daa-a868-0431cbe28bd5	\N	\N	\N
38edf41a-6968-48ed-af13-fed5c8d3060f	a04af1e2-7946-4387-ad73-7456c91af533	58a73b9a-c81a-46d7-9e4e-fcbdd2aff66a	assessment	pending	2025-04-08	Customer had a leak underneath mobile home and has various issues that need to be fixed. Subfloor, needs new cabinets, flooring, underpinning and insulation 	2025-04-08 16:15:08.386-04	2025-04-14 00:17:48.868-04	\N	3cd9e874-8bbd-40ed-ab8e-a846fd4b31ae	\N	\N	\N
\.


--
-- Name: estimates estimates_estimate_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key1 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key10; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key10 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key100; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key100 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key11; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key11 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key12; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key12 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key13; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key13 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key14; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key14 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key15; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key15 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key16; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key16 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key17; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key17 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key18; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key18 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key19; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key19 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key2 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key20; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key20 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key21; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key21 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key22; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key22 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key23; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key23 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key24; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key24 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key25; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key25 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key26; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key26 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key27; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key27 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key28; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key28 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key29; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key29 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key3 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key30; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key30 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key31; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key31 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key32; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key32 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key33; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key33 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key34; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key34 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key35; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key35 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key36; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key36 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key37; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key37 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key38; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key38 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key39; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key39 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key4 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key40; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key40 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key41; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key41 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key42; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key42 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key43; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key43 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key44; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key44 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key45; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key45 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key46; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key46 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key47; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key47 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key48; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key48 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key49; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key49 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key5 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key50; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key50 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key51; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key51 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key52; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key52 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key53; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key53 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key54; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key54 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key55; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key55 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key56; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key56 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key57; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key57 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key58; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key58 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key59; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key59 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key6; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key6 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key60; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key60 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key61; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key61 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key62; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key62 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key63; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key63 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key64; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key64 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key65; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key65 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key66; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key66 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key67; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key67 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key68; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key68 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key69; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key69 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key7 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key70; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key70 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key71; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key71 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key72; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key72 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key73; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key73 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key74; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key74 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key75; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key75 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key76; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key76 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key77; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key77 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key78; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key78 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key79; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key79 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key8; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key8 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key80; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key80 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key81; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key81 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key82; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key82 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key83; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key83 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key84; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key84 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key85; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key85 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key86; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key86 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key87; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key87 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key88; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key88 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key89; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key89 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key9; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key9 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key90; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key90 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key91; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key91 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key92; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key92 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key93; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key93 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key94; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key94 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key95; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key95 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key96; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key96 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key97; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key97 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key98; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key98 UNIQUE (estimate_number);


--
-- Name: estimates estimates_estimate_number_key99; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_estimate_number_key99 UNIQUE (estimate_number);


--
-- Name: estimates estimates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: estimates_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX estimates_address_id ON public.estimates USING btree (address_id);


--
-- Name: estimates_client_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX estimates_client_id_idx ON public.estimates USING btree (client_id);


--
-- Name: estimates_estimate_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX estimates_estimate_number ON public.estimates USING btree (estimate_number);


--
-- Name: estimates_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX estimates_project_id ON public.estimates USING btree (project_id);


--
-- Name: estimates_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX estimates_status ON public.estimates USING btree (status);


--
-- Name: estimates_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX estimates_status_idx ON public.estimates USING btree (status);


--
-- Name: projects_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX projects_address_id ON public.projects USING btree (address_id);


--
-- Name: projects_assessment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX projects_assessment_id ON public.projects USING btree (assessment_id);


--
-- Name: projects_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX projects_client_id ON public.projects USING btree (client_id);


--
-- Name: projects_estimate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX projects_estimate_id ON public.projects USING btree (estimate_id);


--
-- Name: projects_scheduled_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX projects_scheduled_date ON public.projects USING btree (scheduled_date);


--
-- Name: projects_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX projects_status_idx ON public.projects USING btree (status);


--
-- Name: projects_type_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX projects_type_status_idx ON public.projects USING btree (type, status);


--
-- Name: estimates estimates_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.client_addresses(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: estimates estimates_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;


--
-- Name: estimates estimates_client_id_new_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_client_id_new_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: estimates estimates_converted_to_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_converted_to_invoice_id_fkey FOREIGN KEY (converted_to_invoice_id) REFERENCES public.invoices(id) ON DELETE SET NULL;


--
-- Name: estimates estimates_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: projects projects_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.client_addresses(id);


--
-- Name: projects projects_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.projects(id);


--
-- Name: projects projects_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: projects projects_converted_to_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_converted_to_job_id_fkey FOREIGN KEY (converted_to_job_id) REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: projects projects_estimate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_estimate_id_fkey FOREIGN KEY (estimate_id) REFERENCES public.estimates(id);


--
-- Name: projects projects_pre_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pre_assessment_id_fkey FOREIGN KEY (pre_assessment_id) REFERENCES public.pre_assessments(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

