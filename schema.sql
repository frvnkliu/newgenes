-- 1. Core entities
CREATE TABLE Person (
  person_id     SERIAL PRIMARY KEY,
  name          TEXT       NOT NULL,
  date_of_birth DATE,
  sex           VARCHAR(10),
  photo_url     TEXT,
  ethnicity     TEXT,
  /* …other demographics… */
  created_at    TIMESTAMP  DEFAULT NOW()
);

CREATE TABLE COUPLE(
  person_id1 REFERENCES Person(person_id),
  person_id2 REFERENCES Person(person_id)
)

CREATE TABLE Gene (
  gene_id    SERIAL PRIMARY KEY,
  symbol     VARCHAR(20) UNIQUE NOT NULL,
  name       TEXT,
  chromosome VARCHAR(2)         -- 1-22, x, y
);

CREATE TABLE Variant (
  variant_id           SERIAL PRIMARY KEY,
  gene_id              INT      REFERENCES Gene(gene_id),
  hgvs_c               TEXT,    -- e.g. “c.1521_1523delCTT”
  reference_genome     VARCHAR(10) DEFAULT 'GRCh38',
  clinvar_significance TEXT,    -- pathogenic/benign/VUS…
  allele_frequency     REAL
);

CREATE TABLE PersonVariant (
  person_id    INT      REFERENCES Person(person_id),
  variant_id   INT      REFERENCES Variant(variant_id),
  zygosity     VARCHAR(10),     -- homozygous, heterozygous
  PRIMARY KEY (person_id, variant_id)
);

-- 2. Features (diseases or traits) and linking
CREATE TABLE Feature (
  feature_id   SERIAL PRIMARY KEY,
  name         TEXT      NOT NULL,
  type         VARCHAR(10) CHECK (type IN ('disease','trait')),
  category     TEXT,     -- metabolic, neurological, appearance…
  description  TEXT
);

CREATE TABLE FeatureVariant (
  feature_id  INT      REFERENCES Feature(feature_id),
  variant_id  INT      REFERENCES Variant(variant_id),
  inheritance VARCHAR(20),      -- recessive, dominant, X-linked, Complex…
  penetrance  REAL,             -- e.g. 0.6 for 60% risk
  outcome     VARCHAR(20),      -- Blue, Brown, Wavy, Curly, etc.
  PRIMARY KEY (feature_id, variant_id)
);

-- 3. Symptoms & preventative measures
CREATE TABLE Symptom (
  symptom_id  SERIAL PRIMARY KEY,
  name        TEXT UNIQUE NOT NULL
);

CREATE TABLE FeatureSymptom (
  feature_id INT REFERENCES Feature(feature_id),
  symptom_id INT REFERENCES Symptom(symptom_id),
  PRIMARY KEY(feature_id, symptom_id)
);

CREATE TABLE PreventativeMeasure (
  measure_id  SERIAL PRIMARY KEY,
  feature_id  INT    REFERENCES Feature(feature_id),
  text        TEXT
);