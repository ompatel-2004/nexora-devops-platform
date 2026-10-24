--
-- PostgreSQL database dump
--

\restrict 88eGXN16iYy3fTfVVUzSDvjolvohBY1lpalxZTcIqeud2A4b3xSwzkZXjhOnlUE

-- Dumped from database version 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)
-- Dumped by pg_dump version 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)

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
-- Name: deployments; Type: TABLE; Schema: public; Owner: nexora_admin
--

CREATE TABLE public.deployments (
    id integer NOT NULL,
    application character varying(50) NOT NULL,
    version character varying(30) NOT NULL,
    environment character varying(20) NOT NULL,
    commit_sha character varying(40) NOT NULL,
    pipeline_id character varying(50) NOT NULL,
    status character varying(20) NOT NULL,
    started_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    completed_at timestamp with time zone,
    deployed_by character varying(50) NOT NULL,
    rollback_of character varying(30)
);


ALTER TABLE public.deployments OWNER TO nexora_admin;

--
-- Name: deployments_id_seq; Type: SEQUENCE; Schema: public; Owner: nexora_admin
--

CREATE SEQUENCE public.deployments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.deployments_id_seq OWNER TO nexora_admin;

--
-- Name: deployments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nexora_admin
--

ALTER SEQUENCE public.deployments_id_seq OWNED BY public.deployments.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: nexora_admin
--

CREATE TABLE public.products (
    id integer NOT NULL,
    sku character varying(50) NOT NULL,
    name character varying(150) NOT NULL,
    category character varying(50) NOT NULL,
    price numeric(10,2) NOT NULL,
    quantity integer NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.products OWNER TO nexora_admin;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: nexora_admin
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO nexora_admin;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nexora_admin
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: nexora_admin
--

CREATE TABLE public.schema_migrations (
    id integer NOT NULL,
    version character varying(50) NOT NULL,
    applied_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.schema_migrations OWNER TO nexora_admin;

--
-- Name: schema_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: nexora_admin
--

CREATE SEQUENCE public.schema_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.schema_migrations_id_seq OWNER TO nexora_admin;

--
-- Name: schema_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nexora_admin
--

ALTER SEQUENCE public.schema_migrations_id_seq OWNED BY public.schema_migrations.id;


--
-- Name: deployments id; Type: DEFAULT; Schema: public; Owner: nexora_admin
--

ALTER TABLE ONLY public.deployments ALTER COLUMN id SET DEFAULT nextval('public.deployments_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: nexora_admin
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: schema_migrations id; Type: DEFAULT; Schema: public; Owner: nexora_admin
--

ALTER TABLE ONLY public.schema_migrations ALTER COLUMN id SET DEFAULT nextval('public.schema_migrations_id_seq'::regclass);


--
-- Data for Name: deployments; Type: TABLE DATA; Schema: public; Owner: nexora_admin
--

COPY public.deployments (id, application, version, environment, commit_sha, pipeline_id, status, started_at, completed_at, deployed_by, rollback_of) FROM stdin;
1	inventory-api	1.4.1	DEV	local-commit	pipe-001	SUCCESS	2026-10-24 05:44:06.823713+00	2026-10-24 05:44:06.823713+00	ansible-automation	\N
2	inventory-web	1.4.1	DEV	frontend-commit	web-pipe-001	SUCCESS	2026-10-24 05:49:12.821511+00	2026-10-24 05:49:12.821511+00	ansible-automation	\N
3	inventory-api	1.4.1	DEV	local-commit	pipe-001	SUCCESS	2026-10-24 05:53:01.568562+00	2026-10-24 05:53:01.568562+00	ansible-automation	\N
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: nexora_admin
--

COPY public.products (id, sku, name, category, price, quantity, updated_at) FROM stdin;
1	SKU-0001	Developer Laptop 1	Laptops	537.50	13	2026-10-23 09:29:10.635456+00
2	SKU-0002	UltraWide Monitor 2	Displays	575.00	16	2026-10-23 08:29:10.635456+00
3	SKU-0003	Ergonomic Keyboard 3	Peripherals	612.50	19	2026-10-23 07:29:10.635456+00
4	SKU-0004	Gigabit Switch 4	Networking	650.00	22	2026-10-23 06:29:10.635456+00
5	SKU-0005	Enterprise Server 5	Servers	687.50	25	2026-10-23 05:29:10.635456+00
6	SKU-0006	Developer Laptop 6	Laptops	725.00	28	2026-10-23 04:29:10.635456+00
7	SKU-0007	UltraWide Monitor 7	Displays	762.50	31	2026-10-23 03:29:10.635456+00
8	SKU-0008	Ergonomic Keyboard 8	Peripherals	800.00	34	2026-10-23 02:29:10.635456+00
9	SKU-0009	Gigabit Switch 9	Networking	837.50	37	2026-10-23 01:29:10.635456+00
10	SKU-0010	Enterprise Server 10	Servers	875.00	40	2026-10-23 00:29:10.635456+00
11	SKU-0011	Developer Laptop 11	Laptops	912.50	43	2026-10-22 23:29:10.635456+00
12	SKU-0012	UltraWide Monitor 12	Displays	950.00	46	2026-10-22 22:29:10.635456+00
13	SKU-0013	Ergonomic Keyboard 13	Peripherals	987.50	49	2026-10-22 21:29:10.635456+00
14	SKU-0014	Gigabit Switch 14	Networking	1025.00	52	2026-10-22 20:29:10.635456+00
15	SKU-0015	Enterprise Server 15	Servers	1062.50	55	2026-10-22 19:29:10.635456+00
16	SKU-0016	Developer Laptop 16	Laptops	1100.00	58	2026-10-22 18:29:10.635456+00
17	SKU-0017	UltraWide Monitor 17	Displays	1137.50	61	2026-10-22 17:29:10.635456+00
18	SKU-0018	Ergonomic Keyboard 18	Peripherals	1175.00	64	2026-10-22 16:29:10.635456+00
19	SKU-0019	Gigabit Switch 19	Networking	1212.50	67	2026-10-22 15:29:10.635456+00
20	SKU-0020	Enterprise Server 20	Servers	1250.00	70	2026-10-22 14:29:10.635456+00
21	SKU-0021	Developer Laptop 21	Laptops	1287.50	73	2026-10-22 13:29:10.635456+00
22	SKU-0022	UltraWide Monitor 22	Displays	1325.00	76	2026-10-22 12:29:10.635456+00
23	SKU-0023	Ergonomic Keyboard 23	Peripherals	1362.50	79	2026-10-22 11:29:10.635456+00
24	SKU-0024	Gigabit Switch 24	Networking	1400.00	82	2026-10-22 10:29:10.635456+00
25	SKU-0025	Enterprise Server 25	Servers	1437.50	85	2026-10-22 09:29:10.635456+00
26	SKU-0026	Developer Laptop 26	Laptops	1475.00	88	2026-10-22 08:29:10.635456+00
27	SKU-0027	UltraWide Monitor 27	Displays	1512.50	91	2026-10-22 07:29:10.635456+00
28	SKU-0028	Ergonomic Keyboard 28	Peripherals	1550.00	94	2026-10-22 06:29:10.635456+00
29	SKU-0029	Gigabit Switch 29	Networking	1587.50	97	2026-10-22 05:29:10.635456+00
30	SKU-0030	Enterprise Server 30	Servers	1625.00	10	2026-10-22 04:29:10.635456+00
31	SKU-0031	Developer Laptop 31	Laptops	1662.50	13	2026-10-22 03:29:10.635456+00
32	SKU-0032	UltraWide Monitor 32	Displays	1700.00	16	2026-10-22 02:29:10.635456+00
33	SKU-0033	Ergonomic Keyboard 33	Peripherals	1737.50	19	2026-10-22 01:29:10.635456+00
34	SKU-0034	Gigabit Switch 34	Networking	1775.00	22	2026-10-22 00:29:10.635456+00
35	SKU-0035	Enterprise Server 35	Servers	1812.50	25	2026-10-21 23:29:10.635456+00
36	SKU-0036	Developer Laptop 36	Laptops	1850.00	28	2026-10-21 22:29:10.635456+00
37	SKU-0037	UltraWide Monitor 37	Displays	1887.50	31	2026-10-21 21:29:10.635456+00
38	SKU-0038	Ergonomic Keyboard 38	Peripherals	1925.00	34	2026-10-21 20:29:10.635456+00
39	SKU-0039	Gigabit Switch 39	Networking	1962.50	37	2026-10-21 19:29:10.635456+00
40	SKU-0040	Enterprise Server 40	Servers	2000.00	40	2026-10-21 18:29:10.635456+00
41	SKU-0041	Developer Laptop 41	Laptops	2037.50	43	2026-10-21 17:29:10.635456+00
42	SKU-0042	UltraWide Monitor 42	Displays	2075.00	46	2026-10-21 16:29:10.635456+00
43	SKU-0043	Ergonomic Keyboard 43	Peripherals	2112.50	49	2026-10-21 15:29:10.635456+00
44	SKU-0044	Gigabit Switch 44	Networking	2150.00	52	2026-10-21 14:29:10.635456+00
45	SKU-0045	Enterprise Server 45	Servers	2187.50	55	2026-10-21 13:29:10.635456+00
46	SKU-0046	Developer Laptop 46	Laptops	2225.00	58	2026-10-21 12:29:10.635456+00
47	SKU-0047	UltraWide Monitor 47	Displays	2262.50	61	2026-10-21 11:29:10.635456+00
48	SKU-0048	Ergonomic Keyboard 48	Peripherals	2300.00	64	2026-10-21 10:29:10.635456+00
49	SKU-0049	Gigabit Switch 49	Networking	2337.50	67	2026-10-21 09:29:10.635456+00
50	SKU-0050	Enterprise Server 50	Servers	2375.00	70	2026-10-21 08:29:10.635456+00
51	SKU-0051	Developer Laptop 51	Laptops	2412.50	73	2026-10-21 07:29:10.635456+00
52	SKU-0052	UltraWide Monitor 52	Displays	2450.00	76	2026-10-21 06:29:10.635456+00
53	SKU-0053	Ergonomic Keyboard 53	Peripherals	2487.50	79	2026-10-21 05:29:10.635456+00
54	SKU-0054	Gigabit Switch 54	Networking	2525.00	82	2026-10-21 04:29:10.635456+00
55	SKU-0055	Enterprise Server 55	Servers	2562.50	85	2026-10-21 03:29:10.635456+00
56	SKU-0056	Developer Laptop 56	Laptops	2600.00	88	2026-10-21 02:29:10.635456+00
57	SKU-0057	UltraWide Monitor 57	Displays	2637.50	91	2026-10-21 01:29:10.635456+00
58	SKU-0058	Ergonomic Keyboard 58	Peripherals	2675.00	94	2026-10-21 00:29:10.635456+00
59	SKU-0059	Gigabit Switch 59	Networking	2712.50	97	2026-10-20 23:29:10.635456+00
60	SKU-0060	Enterprise Server 60	Servers	2750.00	10	2026-10-20 22:29:10.635456+00
61	SKU-0061	Developer Laptop 61	Laptops	2787.50	13	2026-10-20 21:29:10.635456+00
62	SKU-0062	UltraWide Monitor 62	Displays	2825.00	16	2026-10-20 20:29:10.635456+00
63	SKU-0063	Ergonomic Keyboard 63	Peripherals	2862.50	19	2026-10-20 19:29:10.635456+00
64	SKU-0064	Gigabit Switch 64	Networking	2900.00	22	2026-10-20 18:29:10.635456+00
65	SKU-0065	Enterprise Server 65	Servers	2937.50	25	2026-10-20 17:29:10.635456+00
66	SKU-0066	Developer Laptop 66	Laptops	2975.00	28	2026-10-20 16:29:10.635456+00
67	SKU-0067	UltraWide Monitor 67	Displays	3012.50	31	2026-10-20 15:29:10.635456+00
68	SKU-0068	Ergonomic Keyboard 68	Peripherals	3050.00	34	2026-10-20 14:29:10.635456+00
69	SKU-0069	Gigabit Switch 69	Networking	3087.50	37	2026-10-20 13:29:10.635456+00
70	SKU-0070	Enterprise Server 70	Servers	3125.00	40	2026-10-20 12:29:10.635456+00
71	SKU-0071	Developer Laptop 71	Laptops	3162.50	43	2026-10-20 11:29:10.635456+00
72	SKU-0072	UltraWide Monitor 72	Displays	3200.00	46	2026-10-20 10:29:10.635456+00
73	SKU-0073	Ergonomic Keyboard 73	Peripherals	3237.50	49	2026-10-20 09:29:10.635456+00
74	SKU-0074	Gigabit Switch 74	Networking	3275.00	52	2026-10-20 08:29:10.635456+00
75	SKU-0075	Enterprise Server 75	Servers	3312.50	55	2026-10-20 07:29:10.635456+00
76	SKU-0076	Developer Laptop 76	Laptops	3350.00	58	2026-10-20 06:29:10.635456+00
77	SKU-0077	UltraWide Monitor 77	Displays	3387.50	61	2026-10-20 05:29:10.635456+00
78	SKU-0078	Ergonomic Keyboard 78	Peripherals	3425.00	64	2026-10-20 04:29:10.635456+00
79	SKU-0079	Gigabit Switch 79	Networking	3462.50	67	2026-10-20 03:29:10.635456+00
80	SKU-0080	Enterprise Server 80	Servers	3500.00	70	2026-10-20 02:29:10.635456+00
81	SKU-0081	Developer Laptop 81	Laptops	3537.50	73	2026-10-20 01:29:10.635456+00
82	SKU-0082	UltraWide Monitor 82	Displays	3575.00	76	2026-10-20 00:29:10.635456+00
83	SKU-0083	Ergonomic Keyboard 83	Peripherals	3612.50	79	2026-10-19 23:29:10.635456+00
84	SKU-0084	Gigabit Switch 84	Networking	3650.00	82	2026-10-19 22:29:10.635456+00
85	SKU-0085	Enterprise Server 85	Servers	3687.50	85	2026-10-19 21:29:10.635456+00
86	SKU-0086	Developer Laptop 86	Laptops	3725.00	88	2026-10-19 20:29:10.635456+00
87	SKU-0087	UltraWide Monitor 87	Displays	3762.50	91	2026-10-19 19:29:10.635456+00
88	SKU-0088	Ergonomic Keyboard 88	Peripherals	3800.00	94	2026-10-19 18:29:10.635456+00
89	SKU-0089	Gigabit Switch 89	Networking	3837.50	97	2026-10-19 17:29:10.635456+00
90	SKU-0090	Enterprise Server 90	Servers	3875.00	10	2026-10-19 16:29:10.635456+00
91	SKU-0091	Developer Laptop 91	Laptops	3912.50	13	2026-10-19 15:29:10.635456+00
92	SKU-0092	UltraWide Monitor 92	Displays	3950.00	16	2026-10-19 14:29:10.635456+00
93	SKU-0093	Ergonomic Keyboard 93	Peripherals	3987.50	19	2026-10-19 13:29:10.635456+00
94	SKU-0094	Gigabit Switch 94	Networking	4025.00	22	2026-10-19 12:29:10.635456+00
95	SKU-0095	Enterprise Server 95	Servers	4062.50	25	2026-10-19 11:29:10.635456+00
96	SKU-0096	Developer Laptop 96	Laptops	4100.00	28	2026-10-19 10:29:10.635456+00
97	SKU-0097	UltraWide Monitor 97	Displays	4137.50	31	2026-10-19 09:29:10.635456+00
98	SKU-0098	Ergonomic Keyboard 98	Peripherals	4175.00	34	2026-10-19 08:29:10.635456+00
99	SKU-0099	Gigabit Switch 99	Networking	4212.50	37	2026-10-19 07:29:10.635456+00
100	SKU-0100	Enterprise Server 100	Servers	4250.00	40	2026-10-19 06:29:10.635456+00
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: nexora_admin
--

COPY public.schema_migrations (id, version, applied_at) FROM stdin;
1	001_initial_schema	2026-10-23 10:29:10.643786+00
\.


--
-- Name: deployments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nexora_admin
--

SELECT pg_catalog.setval('public.deployments_id_seq', 3, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nexora_admin
--

SELECT pg_catalog.setval('public.products_id_seq', 100, true);


--
-- Name: schema_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nexora_admin
--

SELECT pg_catalog.setval('public.schema_migrations_id_seq', 1, true);


--
-- Name: deployments deployments_pkey; Type: CONSTRAINT; Schema: public; Owner: nexora_admin
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT deployments_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: nexora_admin
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: products products_sku_key; Type: CONSTRAINT; Schema: public; Owner: nexora_admin
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_sku_key UNIQUE (sku);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: nexora_admin
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_version_key; Type: CONSTRAINT; Schema: public; Owner: nexora_admin
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_version_key UNIQUE (version);


--
-- PostgreSQL database dump complete
--

\unrestrict 88eGXN16iYy3fTfVVUzSDvjolvohBY1lpalxZTcIqeud2A4b3xSwzkZXjhOnlUE

