-- Table: public."global_superstore"

CREATE TABLE public.global_superstore
(
  "City" character varying(45) NOT NULL,
  "Customer_Id" character varying(12) NOT NULL,
  "Customer_Name" character varying(50),
  "Order_Date" date NOT NULL,
  "Order_Id" character varying(24) NOT NULL,
  "Postal_Code" character varying(10),
  "Quantity" integer NOT NULL,
  "Row_Id" integer NOT NULL,
  "Sales" numeric(9,2) NOT NULL,
  "Segment" character varying(15) NOT NULL,
  "Ship_Date" date NOT NULL,
  "Ship_Mode" character varying(15) NOT NULL,
  "State" character varying(45) NOT NULL,
  "Discount" numeric(5,2),
  "Region" character varying(20) NOT NULL,
  "Market" character varying(15) NOT NULL,
  "Product_Id" character varying(15) NOT NULL,
  "Category" character varying(15) NOT NULL,
  "Sub_Category" character varying(15) NOT NULL,
  "Product_Name" character varying(150) NOT NULL,
  "Order_Priority" character varying(10) NOT NULL,
  "Country" character varying(45) NOT NULL,
  "Profit" numeric(9,2) NOT NULL,
  "Shipping_Cost" numeric(9,2) NOT NULL,
  CONSTRAINT global_superstore_pkey PRIMARY KEY ("Row_Id")
)
WITH (
  OIDS=FALSE
);

ALTER TABLE public.global_superstore
    OWNER to postgres;

GRANT SELECT, REFERENCES ON TABLE public.global_superstore TO dev_user;

GRANT ALL ON TABLE public.global_superstore TO postgres;

-- Table: public."entitlements"

CREATE TABLE public.entitlements
(
  "Username" character varying(20),
  "Region" character varying(50),
  CONSTRAINT entitlements_pkey PRIMARY KEY ("Username", "Region")
)
WITH (
  OIDS=FALSE
);

ALTER TABLE public.entitlements
  OWNER TO postgres;
GRANT ALL ON TABLE public.entitlements TO postgres;
GRANT SELECT, REFERENCES ON TABLE public.entitlements TO dev_user;

CREATE TABLE public.webapp_users
(
  "Username" character varying(30) NOT NULL,
  "Email" character varying(60) NOT NULL,
  "Password" character varying(20) NOT NULL,
  CONSTRAINT webapp_users_pkey PRIMARY KEY ("Username")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.webapp_users
  OWNER TO postgres;
  

GRANT ALL ON TABLE public.webapp_users TO postgres;
GRANT SELECT, REFERENCES ON TABLE public.webapp_users TO dev_user;