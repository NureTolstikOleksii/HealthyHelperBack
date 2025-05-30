--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

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

--
-- Name: create_compartments_for_container(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_compartments_for_container() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO compartments (compartment_number, container_id) VALUES
        (1, NEW.container_id),
        (2, NEW.container_id),
        (3, NEW.container_id),
        (4, NEW.container_id),
        (5, NEW.container_id),
        (6, NEW.container_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.create_compartments_for_container() OWNER TO postgres;

--
-- Name: set_prescription_end_date(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_prescription_end_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Обчислення дати завершення лікування: date_issued + duration (в днях) - 1 день
    IF NEW.date_issued IS NOT NULL AND NEW.duration IS NOT NULL THEN
        NEW.end_date := NEW.date_issued + (NEW.duration - 1 || ' days')::INTERVAL;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_prescription_end_date() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: compartment_medications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compartment_medications (
    compartment_med_id integer NOT NULL,
    fill_time timestamp without time zone,
    filled_by integer,
    compartment_id integer,
    open_time timestamp without time zone,
    prescription_med_id integer
);


ALTER TABLE public.compartment_medications OWNER TO postgres;

--
-- Name: compartment_medications_compartment_med_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.compartment_medications_compartment_med_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.compartment_medications_compartment_med_id_seq OWNER TO postgres;

--
-- Name: compartment_medications_compartment_med_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compartment_medications_compartment_med_id_seq OWNED BY public.compartment_medications.compartment_med_id;


--
-- Name: compartments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compartments (
    compartment_id integer NOT NULL,
    compartment_number integer,
    container_id integer
);


ALTER TABLE public.compartments OWNER TO postgres;

--
-- Name: compartments_compartment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.compartments_compartment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.compartments_compartment_id_seq OWNER TO postgres;

--
-- Name: compartments_compartment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compartments_compartment_id_seq OWNED BY public.compartments.compartment_id;


--
-- Name: containers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.containers (
    container_id integer NOT NULL,
    container_number integer,
    status character varying(50),
    patient_id integer
);


ALTER TABLE public.containers OWNER TO postgres;

--
-- Name: containers_container_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.containers_container_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.containers_container_id_seq OWNER TO postgres;

--
-- Name: containers_container_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.containers_container_id_seq OWNED BY public.containers.container_id;


--
-- Name: medical_staff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medical_staff (
    staff_id integer NOT NULL,
    specialization character varying(100),
    shift character varying(50),
    admission_date date
);


ALTER TABLE public.medical_staff OWNER TO postgres;

--
-- Name: medications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medications (
    medication_id integer NOT NULL,
    name character varying(100),
    description text,
    type character varying(50),
    manufacturer character varying(100),
    dosage character varying(50)
);


ALTER TABLE public.medications OWNER TO postgres;

--
-- Name: medications_medication_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.medications_medication_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.medications_medication_id_seq OWNER TO postgres;

--
-- Name: medications_medication_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.medications_medication_id_seq OWNED BY public.medications.medication_id;


--
-- Name: notification_recipients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_recipients (
    notification_id integer NOT NULL,
    user_id integer NOT NULL,
    is_read boolean DEFAULT false
);


ALTER TABLE public.notification_recipients OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    notification_id integer NOT NULL,
    notification_type character varying(100) NOT NULL,
    message text,
    sent_time time without time zone,
    sent_date date,
    container_id integer
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_notification_id_seq OWNER TO postgres;

--
-- Name: notifications_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_notification_id_seq OWNED BY public.notifications.notification_id;


--
-- Name: prescription_medications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescription_medications (
    prescription_med_id integer NOT NULL,
    quantity integer,
    intake_date date,
    intake_time time without time zone,
    frequency character varying(100),
    prescription_id integer,
    medication_id integer,
    intake_status boolean
);


ALTER TABLE public.prescription_medications OWNER TO postgres;

--
-- Name: prescription_medications_prescription_med_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.prescription_medications_prescription_med_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prescription_medications_prescription_med_id_seq OWNER TO postgres;

--
-- Name: prescription_medications_prescription_med_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.prescription_medications_prescription_med_id_seq OWNED BY public.prescription_medications.prescription_med_id;


--
-- Name: prescriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescriptions (
    prescription_id integer NOT NULL,
    date_issued date,
    duration integer,
    patient_id integer,
    doctor_id integer,
    diagnosis character varying(255),
    ward_id integer,
    end_date date
);


ALTER TABLE public.prescriptions OWNER TO postgres;

--
-- Name: prescriptions_prescription_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.prescriptions_prescription_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prescriptions_prescription_id_seq OWNER TO postgres;

--
-- Name: prescriptions_prescription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.prescriptions_prescription_id_seq OWNED BY public.prescriptions.prescription_id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    role_id integer NOT NULL,
    role_name character varying(100) NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_role_id_seq OWNER TO postgres;

--
-- Name: roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_role_id_seq OWNED BY public.roles.role_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    contact_info character varying(255),
    role_id integer,
    login character varying(100) NOT NULL,
    password character varying(100) NOT NULL,
    date_of_birth date,
    avatar character varying(255),
    patronymic character varying(100),
    phone character varying(50),
    firebase_token text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: wards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wards (
    ward_id integer NOT NULL,
    ward_number character varying(50),
    capacity integer
);


ALTER TABLE public.wards OWNER TO postgres;

--
-- Name: wards_ward_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wards_ward_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wards_ward_id_seq OWNER TO postgres;

--
-- Name: wards_ward_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wards_ward_id_seq OWNED BY public.wards.ward_id;


--
-- Name: compartment_medications compartment_med_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartment_medications ALTER COLUMN compartment_med_id SET DEFAULT nextval('public.compartment_medications_compartment_med_id_seq'::regclass);


--
-- Name: compartments compartment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartments ALTER COLUMN compartment_id SET DEFAULT nextval('public.compartments_compartment_id_seq'::regclass);


--
-- Name: containers container_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.containers ALTER COLUMN container_id SET DEFAULT nextval('public.containers_container_id_seq'::regclass);


--
-- Name: medications medication_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medications ALTER COLUMN medication_id SET DEFAULT nextval('public.medications_medication_id_seq'::regclass);


--
-- Name: notifications notification_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN notification_id SET DEFAULT nextval('public.notifications_notification_id_seq'::regclass);


--
-- Name: prescription_medications prescription_med_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_medications ALTER COLUMN prescription_med_id SET DEFAULT nextval('public.prescription_medications_prescription_med_id_seq'::regclass);


--
-- Name: prescriptions prescription_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescriptions ALTER COLUMN prescription_id SET DEFAULT nextval('public.prescriptions_prescription_id_seq'::regclass);


--
-- Name: roles role_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN role_id SET DEFAULT nextval('public.roles_role_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: wards ward_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wards ALTER COLUMN ward_id SET DEFAULT nextval('public.wards_ward_id_seq'::regclass);


--
-- Data for Name: compartment_medications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compartment_medications (compartment_med_id, fill_time, filled_by, compartment_id, open_time, prescription_med_id) FROM stdin;
26	2025-05-24 15:07:32.616	50	7	2025-05-24 07:00:00	178
29	2025-05-27 15:05:10.075	50	8	2025-05-27 07:00:00	215
30	2025-05-27 15:06:32.341	50	14	2025-05-27 07:00:00	284
52	2025-05-29 20:24:01.585	50	1	2025-05-29 23:30:00	311
\.


--
-- Data for Name: compartments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compartments (compartment_id, compartment_number, container_id) FROM stdin;
1	1	1
2	2	1
3	3	1
4	4	1
5	5	1
6	6	1
7	1	2
8	2	2
9	3	2
10	4	2
11	5	2
12	6	2
13	1	3
14	2	3
15	3	3
16	4	3
17	5	3
18	6	3
\.


--
-- Data for Name: containers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.containers (container_id, container_number, status, patient_id) FROM stdin;
2	2	unactive	\N
1	1	active	51
3	3	unactive	18
\.


--
-- Data for Name: medical_staff; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medical_staff (staff_id, specialization, shift, admission_date) FROM stdin;
1	Терапевт	Денна	2025-05-05
50	Медсестра	Нічна	2025-05-14
70	Терапевт	Денна	2025-05-21
\.


--
-- Data for Name: medications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medications (medication_id, name, description, type, manufacturer, dosage) FROM stdin;
8	Aspirin	Анальгетик, жарознижувальне	Таблетки	Bayer	500 мг
19	Nazivin	Судинозвужувальний	Краплі	Merck	10 мл
2	Paracetamol	Жарознижувальне	Таблетки	Дарниця	500 мг
16	Flukold	Проти застуди	Капсули	Ранбаксі	капс.
6	Ambroxol	Відхаркувальний засіб	Сироп	Здоров'я	100 мл
7	Loratadine	Протиалергічне	Таблетки	Київський ВЗ	10 мг
15	Erespal	Протизапальне	Сироп	Servier	150 мл
12	Festal	Ферментативний засіб	Таблетки	Sanofi	табл.
18	Omez	Антацид	Капсули	Dr. Reddy's	20 мг
14	Drotaverine	Спазмолітик	Ін'єкції	Дарниця	2 мл
17	Mukaltin	Відхаркувальне	Таблетки	Артеріум	табл.
4	Citramon	Знеболююче, жарознижувальне	Таблетки	Дарниця	250 мг
11	Renny	Антацид	Таблетки	Bayer	табл.
1	Nurofen	Жарознижувальне	Капсули	Дарниця	табл.
20	Aquamaris	Зволоження слизової	Спрей	Ядран	30 мл
13	Suprastin	Протиалергічне	Таблетки	Egis	25 мг
10	Analgin	Знеболююче	Ін'єкції	Дарниця	2 мл
9	Corvalol	Седативне	Краплі	Фармак	25 мл
5	No-Shpa	Спазмолітик	Таблетки	Санофі	40 мг
3	Ibuprofen	Знеболююче	Суспензія	Фармак	100 мл
\.


--
-- Data for Name: notification_recipients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification_recipients (notification_id, user_id, is_read) FROM stdin;
21	50	t
20	50	t
22	50	t
21	51	t
22	51	t
20	51	t
23	50	t
24	50	t
25	50	t
26	50	t
27	50	t
30	50	t
32	50	t
1	50	t
2	50	t
3	50	t
34	50	t
23	51	t
24	51	t
25	51	t
26	51	t
4	51	t
27	51	t
28	51	t
29	51	t
30	51	t
31	51	t
32	51	t
33	51	t
34	51	t
35	51	t
36	50	f
36	51	t
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (notification_id, notification_type, message, sent_time, sent_date, container_id) FROM stdin;
1	warning	Нема таблеток	15:01:50	2025-05-19	1
2	error	Срочно погано	15:02:49	2025-05-19	2
3	success	You have successfully completed the course of treatment for a cold	15:29:58	2025-05-19	2
4	success	Вітаємо у системі HealthyHelper. У вас э можливість...	13:46:02	2025-05-20	\N
20	warning	Пацієнт Толстік Олексій Віталійович (палата 2, контейнер №1) пропустив прийом препарату: Ibuprofen.	13:34:26.424	2025-05-29	1
21	warning	Пацієнт Толстік Олексій Віталійович (палата 2, контейнер №1) пропустив прийом препарату: Ibuprofen.	13:45:08.662	2025-05-29	1
22	warning	Пацієнт Толстік Олексій Віталійович (палата 2, контейнер №1) пропустив прийом препарату: Ibuprofen.	17:18:12.814	2025-05-29	1
23	warning	Пацієнт Толстік Олексій Віталійович (палата 2, контейнер №1) пропустив прийом препарату: Ibuprofen.	20:24:05.046	2025-05-29	1
24	warning	Пацієнт Толстік Олексій Віталійович (палата 2, контейнер №1) пропустив прийом препарату: Ibuprofen.	20:25:15.697	2025-05-29	1
25	warning	Пацієнт Толстік Олексій Віталійович (палата 2, контейнер №1) пропустив прийом препарату: Ibuprofen.	20:26:34.438	2025-05-29	1
26	warning	Пацієнт Толстік Олексій Віталійович (палата 2, контейнер №1) пропустив прийом препарату: Ibuprofen.	20:27:04.208	2025-05-29	1
27	warning	Пацієнт Толстік Олексій Віталійович (палата 2, контейнер №1) пропустив прийом препарату: Ibuprofen.	20:34:06.946	2025-05-29	1
28	info	Час прийняти препарат: Ibuprofen. Контейнер №1, відсік №1.	21:00:20.899	2025-05-29	1
29	info	Час прийняти препарат: Ibuprofen. Контейнер №1, відсік №1.	21:11:07.037	2025-05-29	1
30	warning	Пацієнт Толстік Олексій Віталійович (палата 2, контейнер №1) пропустив прийом препарату: Ibuprofen.	21:12:12.705	2025-05-29	1
31	info	Час прийняти препарат: Ibuprofen. Контейнер №1, відсік №1.	21:23:14.599	2025-05-29	1
32	warning	Пацієнт Толстік Олексій Віталійович (палата 2, контейнер №1) пропустив прийом препарату: Ibuprofen.	21:24:23.231	2025-05-29	1
33	info	Час прийняти препарат: Ibuprofen. Контейнер №1, відсік №1.	21:27:18.426	2025-05-29	1
34	warning	Пацієнт Толстік Олексій Віталійович (палата 2, контейнер №1) пропустив прийом препарату: Ibuprofen.	21:28:33.526	2025-05-29	1
35	info	Час прийняти препарат: Ibuprofen. Контейнер №1, відсік №1.	23:30:07.413	2025-05-29	1
36	warning	Пацієнт Толстік Олексій Віталійович (палата 2, контейнер №1) пропустив прийом препарату: Ibuprofen.	23:35:10.987	2025-05-29	1
\.


--
-- Data for Name: prescription_medications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.prescription_medications (prescription_med_id, quantity, intake_date, intake_time, frequency, prescription_id, medication_id, intake_status) FROM stdin;
179	1	2025-05-24	14:00:00	2 раз(и) на день	38	2	\N
168	1	2025-05-19	07:00:00	2 раз(и) на день	38	2	f
170	1	2025-05-20	07:00:00	2 раз(и) на день	38	2	f
189	2	2025-05-19	14:00:00	2 раз(и) на день	38	3	f
190	2	2025-05-20	07:00:00	2 раз(и) на день	38	3	f
208	2	2025-05-20	07:00:00	1 раз(и) на день	38	4	f
201	2	2025-05-25	14:00:00	2 раз(и) на день	38	3	\N
200	2	2025-05-25	07:00:00	2 раз(и) на день	38	3	\N
187	2	2025-05-18	14:00:00	2 раз(и) на день	38	3	t
186	2	2025-05-18	07:00:00	2 раз(и) на день	38	3	t
209	2	2025-05-21	07:00:00	1 раз(и) на день	38	4	\N
207	2	2025-05-19	07:00:00	1 раз(и) на день	38	4	t
213	2	2025-05-25	07:00:00	1 раз(и) на день	38	4	\N
211	2	2025-05-23	07:00:00	1 раз(и) на день	38	4	\N
173	1	2025-05-21	14:00:00	2 раз(и) на день	38	2	\N
210	2	2025-05-22	07:00:00	1 раз(и) на день	38	4	\N
214	2	2025-05-26	07:00:00	1 раз(и) на день	38	4	\N
182	1	2025-05-26	07:00:00	2 раз(и) на день	38	2	\N
202	2	2025-05-26	07:00:00	2 раз(и) на день	38	3	\N
203	2	2025-05-26	14:00:00	2 раз(и) на день	38	3	\N
188	2	2025-05-19	07:00:00	2 раз(и) на день	38	3	t
195	2	2025-05-22	14:00:00	2 раз(и) на день	38	3	\N
172	1	2025-05-21	07:00:00	2 раз(и) на день	38	2	\N
174	1	2025-05-22	07:00:00	2 раз(и) на день	38	2	\N
171	1	2025-05-20	14:00:00	2 раз(и) на день	38	2	t
206	2	2025-05-18	07:00:00	1 раз(и) на день	38	4	t
177	1	2025-05-23	14:00:00	2 раз(и) на день	38	2	\N
169	1	2025-05-19	14:00:00	2 раз(и) на день	38	2	t
191	2	2025-05-20	14:00:00	2 раз(и) на день	38	3	t
194	2	2025-05-22	07:00:00	2 раз(и) на день	38	3	\N
192	2	2025-05-21	07:00:00	2 раз(и) на день	38	3	\N
166	1	2025-05-18	07:00:00	2 раз(и) на день	38	2	t
167	1	2025-05-18	14:00:00	2 раз(и) на день	38	2	t
193	2	2025-05-21	14:00:00	2 раз(и) на день	38	3	\N
176	1	2025-05-23	07:00:00	2 раз(и) на день	38	2	\N
178	1	2025-05-24	07:00:00	2 раз(и) на день	38	2	\N
237	1	2025-05-20	07:00:00	2 раз(и) на день	42	2	\N
238	1	2025-05-20	14:00:00	2 раз(и) на день	42	2	\N
198	2	2025-05-24	07:00:00	2 раз(и) на день	38	3	\N
239	1	2025-05-21	07:00:00	2 раз(и) на день	42	2	\N
204	2	2025-05-27	07:00:00	2 раз(и) на день	38	3	\N
184	1	2025-05-27	07:00:00	2 раз(и) на день	38	2	\N
185	1	2025-05-27	14:00:00	2 раз(и) на день	38	2	\N
215	2	2025-05-27	07:00:00	1 раз(и) на день	38	4	\N
205	2	2025-05-27	14:00:00	2 раз(и) на день	38	3	\N
183	1	2025-05-26	14:00:00	2 раз(и) на день	38	2	\N
240	1	2025-05-21	14:00:00	2 раз(и) на день	42	2	\N
241	1	2025-05-22	07:00:00	2 раз(и) на день	42	2	\N
175	1	2025-05-22	14:00:00	2 раз(и) на день	38	2	\N
212	2	2025-05-24	07:00:00	1 раз(и) на день	38	4	\N
199	2	2025-05-24	14:00:00	2 раз(и) на день	38	3	\N
197	2	2025-05-23	14:00:00	2 раз(и) на день	38	3	\N
196	2	2025-05-23	07:00:00	2 раз(и) на день	38	3	\N
180	1	2025-05-25	07:00:00	2 раз(и) на день	38	2	\N
181	1	2025-05-25	14:00:00	2 раз(и) на день	38	2	\N
242	1	2025-05-22	14:00:00	2 раз(и) на день	42	2	\N
243	1	2025-05-20	07:00:00	1 раз(и) на день	42	7	\N
244	1	2025-05-21	07:00:00	1 раз(и) на день	42	7	\N
245	1	2025-05-22	07:00:00	1 раз(и) на день	42	7	\N
267	1	2025-05-17	07:00:00	1 раз(и) на день	44	2	\N
284	22	2025-05-27	07:00:00	22 раз(и) на день	46	2	\N
285	22	2025-05-28	07:00:00	22 раз(и) на день	46	2	\N
286	22	2025-05-29	07:00:00	22 раз(и) на день	46	2	\N
287	22	2025-05-30	07:00:00	22 раз(и) на день	46	2	\N
288	22	2025-05-31	07:00:00	22 раз(и) на день	46	2	\N
289	22	2025-06-01	07:00:00	22 раз(и) на день	46	2	\N
290	22	2025-06-02	07:00:00	22 раз(и) на день	46	2	\N
291	22	2025-06-03	07:00:00	22 раз(и) на день	46	2	\N
292	22	2025-06-04	07:00:00	22 раз(и) на день	46	2	\N
293	22	2025-06-05	07:00:00	22 раз(и) на день	46	2	\N
294	22	2025-06-06	07:00:00	22 раз(и) на день	46	2	\N
295	22	2025-06-07	07:00:00	22 раз(и) на день	46	2	\N
296	22	2025-06-08	07:00:00	22 раз(и) на день	46	2	\N
297	22	2025-06-09	07:00:00	22 раз(и) на день	46	2	\N
298	22	2025-06-10	07:00:00	22 раз(и) на день	46	2	\N
299	22	2025-06-11	07:00:00	22 раз(и) на день	46	2	\N
300	22	2025-06-12	07:00:00	22 раз(и) на день	46	2	\N
301	22	2025-06-13	07:00:00	22 раз(и) на день	46	2	\N
302	22	2025-06-14	07:00:00	22 раз(и) на день	46	2	\N
303	22	2025-06-15	07:00:00	22 раз(и) на день	46	2	\N
304	22	2025-06-16	07:00:00	22 раз(и) на день	46	2	\N
305	22	2025-06-17	07:00:00	22 раз(и) на день	46	2	\N
306	1	2025-05-28	05:00:00	3 раз(и) на день	47	3	\N
307	1	2025-05-28	11:00:00	3 раз(и) на день	47	3	\N
308	1	2025-05-28	17:00:00	3 раз(и) на день	47	3	\N
309	1	2025-05-29	05:00:00	3 раз(и) на день	47	3	\N
312	1	2025-05-30	05:00:00	3 раз(и) на день	47	3	\N
313	1	2025-05-30	11:00:00	3 раз(и) на день	47	3	\N
314	1	2025-05-30	17:00:00	3 раз(и) на день	47	3	\N
315	1	2025-05-31	05:00:00	3 раз(и) на день	47	3	\N
316	1	2025-05-31	11:00:00	3 раз(и) на день	47	3	\N
317	1	2025-05-31	17:00:00	3 раз(и) на день	47	3	\N
318	1	2025-06-01	05:00:00	3 раз(и) на день	47	3	\N
319	1	2025-06-01	11:00:00	3 раз(и) на день	47	3	\N
320	1	2025-06-01	17:00:00	3 раз(и) на день	47	3	\N
321	2	2025-05-28	07:00:00	2 раз(и) на день	47	4	\N
322	2	2025-05-28	14:00:00	2 раз(и) на день	47	4	\N
310	1	2025-05-29	11:00:00	3 раз(и) на день	47	3	t
311	1	2025-05-29	14:00:00	3 раз(и) на день	47	3	f
\.


--
-- Data for Name: prescriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.prescriptions (prescription_id, date_issued, duration, patient_id, doctor_id, diagnosis, ward_id, end_date) FROM stdin;
42	2025-05-20	3	18	1	Застуда	2	2025-05-22
44	2025-05-17	1	18	1	Діагноз	2	2025-05-18
46	2025-05-27	22	18	1	Призначечень	1	2025-06-17
47	2025-05-28	5	51	1	Застуда	2	2025-06-01
38	2025-05-18	10	51	1	Просто тест	1	2025-05-27
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (role_id, role_name) FROM stdin;
1	doctor
3	patient
2	staff
4	admin
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, first_name, last_name, contact_info, role_id, login, password, date_of_birth, avatar, patronymic, phone, firebase_token) FROM stdin;
8	Петро	Петренко	м. Харків, вул. Квітуча, 44	3	petrenko@gmail.com	$2a$10$xTrbsl0bolUbatt0aeFcdOu0z2Enviax7I8izbhm0t0LCpUypMHtG	1973-06-06	\N	Петрович	+385051525333	\N
61	Тарас	Тарасенко	м. Полтава, вул. Сумська, 76	3	tarasenko@gmail.com	$2a$10$xTrbsl0bolUbatt0aeFcdOu0z2Enviax7I8izbhm0t0LCpUypMHtG	1978-05-20	\N	Тарасович	+380996554422	\N
51	Олексій	Толстік	м. Мерефа	3	alextolstik78@gmail.com	$2a$10$xTrbsl0bolUbatt0aeFcdOu0z2Enviax7I8izbhm0t0LCpUypMHtG	2023-10-08	https://res.cloudinary.com/djst5z72d/image/upload/v1748550419/healthyhelper/avatars/w4ihkzpwde0fogrp4x0e.png	Віталійович	+380992896292	ezalns6oTv27tthzsL1aLO:APA91bFypIFH2tIwJCemjS5kD2tDxc8bhYSH1oe_r-eH218EHsUUTTSAkr_wfSiUqeXymXltC9MKm8Lsh1Xb8YgnYh83tGol7Zecd7tI7TxvndEszehtXFM
62	Степан	Степаненко	м. Суми, вул. Кривенька, 356	3	stepanenko@gmail.com	$2a$10$xTrbsl0bolUbatt0aeFcdOu0z2Enviax7I8izbhm0t0LCpUypMHtG	1976-05-23	\N	Степанович	+380233635344	\N
21	Степан	Степаненко	Харків, вул. Квітуча, 45	4	admin@gmail.com	$2a$10$XBGx45OoHSWBEP8US2edg.//7aDMtlMWxldG9kLqpi8gdKggI1gXO	1985-11-10	https://res.cloudinary.com/djst5z72d/image/upload/v1747832402/healthyhelper/avatars/xctyad8i3btwbhtmxdej.jpg	Іванович	+380331112222	\N
1	Іван	Іванов	м. Харків, вул. Квітуча, 44	1	ivanov@gmail.com	$2a$10$xPkvpTG2jb/BUTIcbaXX7u3BeXNSsINrGoGqtY.D8zRar83X/Yiza	1987-11-10	https://res.cloudinary.com/djst5z72d/image/upload/v1747012476/healthyhelper/avatars/tpl9zaj7itb6rlmgmutt.png	Іванович	+380332625232	\N
70	Григорій	Григоренко	м. Харків, вул. Сонна, 11	1	grygorenko@gmail.com	$2a$10$qM1aF2njfIIWFu1MOySgReIee9X4GUxw1CG7lrortfVkyiBCrO2HW	1936-05-21	\N	Григорович	+380255668989	\N
18	Олексій	Толстік	м. Мерефа	3	oleksi.tolstik@nure.ua	$2a$10$DzKYau46/piBVYTHkE6vfOl53cqv8wp2c0X08NMgidscwwf0cCuli	2004-11-11	https://res.cloudinary.com/djst5z72d/image/upload/v1747012476/healthyhelper/avatars/tpl9zaj7itb6rlmgmutt.png	Віталійович	+380992896292	\N
50	Валентина	Сергієнко	м. Мерефа	2	alextolstik@gmail.com	$2a$10$39g0YWj0BrYlqK4btgOPqeR9AUdJNpjSdoyED6duPfn4Xhjls0SpC	1961-05-13	https://res.cloudinary.com/djst5z72d/image/upload/v1748543868/healthyhelper/avatars/fgfllwgtf8a0s23wrqag.png	Степанівна	+380442524454	cSM58RtaQPOTOPsRNgWHub:APA91bFztlzb1L69CNuiUihU5AeCVp_oqqyu-GX62UL4OmWbFRlxiqCq9wQY7azKGAFqDMs4HaGXB8-L-UvhBRYJm5cuhXRrGQ9GtG0Pv5opelOwrWHEuAw
\.


--
-- Data for Name: wards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wards (ward_id, ward_number, capacity) FROM stdin;
1	1	4
2	2	4
3	3	4
\.


--
-- Name: compartment_medications_compartment_med_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.compartment_medications_compartment_med_id_seq', 52, true);


--
-- Name: compartments_compartment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.compartments_compartment_id_seq', 18, true);


--
-- Name: containers_container_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.containers_container_id_seq', 3, true);


--
-- Name: medications_medication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medications_medication_id_seq', 1, true);


--
-- Name: notifications_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_notification_id_seq', 36, true);


--
-- Name: prescription_medications_prescription_med_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.prescription_medications_prescription_med_id_seq', 322, true);


--
-- Name: prescriptions_prescription_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.prescriptions_prescription_id_seq', 47, true);


--
-- Name: roles_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_role_id_seq', 13, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 71, true);


--
-- Name: wards_ward_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wards_ward_id_seq', 1, true);


--
-- Name: compartment_medications compartment_medications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartment_medications
    ADD CONSTRAINT compartment_medications_pkey PRIMARY KEY (compartment_med_id);


--
-- Name: compartments compartments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartments
    ADD CONSTRAINT compartments_pkey PRIMARY KEY (compartment_id);


--
-- Name: containers containers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.containers
    ADD CONSTRAINT containers_pkey PRIMARY KEY (container_id);


--
-- Name: medical_staff medical_staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_staff
    ADD CONSTRAINT medical_staff_pkey PRIMARY KEY (staff_id);


--
-- Name: medications medications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medications
    ADD CONSTRAINT medications_pkey PRIMARY KEY (medication_id);


--
-- Name: notification_recipients notification_recipients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_recipients
    ADD CONSTRAINT notification_recipients_pkey PRIMARY KEY (notification_id, user_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (notification_id);


--
-- Name: prescription_medications prescription_medications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_medications
    ADD CONSTRAINT prescription_medications_pkey PRIMARY KEY (prescription_med_id);


--
-- Name: prescriptions prescriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_pkey PRIMARY KEY (prescription_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- Name: users users_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_login_key UNIQUE (login);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: wards wards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wards
    ADD CONSTRAINT wards_pkey PRIMARY KEY (ward_id);


--
-- Name: containers trg_create_compartments; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_create_compartments AFTER INSERT ON public.containers FOR EACH ROW EXECUTE FUNCTION public.create_compartments_for_container();


--
-- Name: prescriptions trg_set_end_date; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_set_end_date BEFORE INSERT ON public.prescriptions FOR EACH ROW EXECUTE FUNCTION public.set_prescription_end_date();


--
-- Name: compartment_medications compartment_medications_compartment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartment_medications
    ADD CONSTRAINT compartment_medications_compartment_id_fkey FOREIGN KEY (compartment_id) REFERENCES public.compartments(compartment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: compartment_medications compartment_medications_filled_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartment_medications
    ADD CONSTRAINT compartment_medications_filled_by_fkey FOREIGN KEY (filled_by) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: compartment_medications compartment_medications_prescription_med_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartment_medications
    ADD CONSTRAINT compartment_medications_prescription_med_id_fkey FOREIGN KEY (prescription_med_id) REFERENCES public.prescription_medications(prescription_med_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: compartments compartments_container_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartments
    ADD CONSTRAINT compartments_container_id_fkey FOREIGN KEY (container_id) REFERENCES public.containers(container_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: containers containers_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.containers
    ADD CONSTRAINT containers_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: medical_staff medical_staff_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_staff
    ADD CONSTRAINT medical_staff_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notification_recipients notification_recipients_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_recipients
    ADD CONSTRAINT notification_recipients_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(notification_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notification_recipients notification_recipients_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_recipients
    ADD CONSTRAINT notification_recipients_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notifications notifications_container_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_container_id_fkey FOREIGN KEY (container_id) REFERENCES public.containers(container_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: prescription_medications prescription_medications_medication_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_medications
    ADD CONSTRAINT prescription_medications_medication_id_fkey FOREIGN KEY (medication_id) REFERENCES public.medications(medication_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: prescription_medications prescription_medications_prescription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescription_medications
    ADD CONSTRAINT prescription_medications_prescription_id_fkey FOREIGN KEY (prescription_id) REFERENCES public.prescriptions(prescription_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prescriptions prescriptions_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: prescriptions prescriptions_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prescriptions prescriptions_ward_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_ward_id_fkey FOREIGN KEY (ward_id) REFERENCES public.wards(ward_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

