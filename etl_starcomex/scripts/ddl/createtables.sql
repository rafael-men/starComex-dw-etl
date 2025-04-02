-- TABELAS DO DW
CREATE SEQUENCE dim_moeda_sk_moeda_seq;
CREATE TABLE dim_moeda (
    sk_moeda INTEGER NOT NULL DEFAULT nextval('dim_moeda_sk_moeda_seq'),
    codigo_moeda CHAR(3) NOT NULL UNIQUE,  -- ISO currency code (USD, EUR, etc)
    nome_moeda VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    CONSTRAINT dim_moeda_pk PRIMARY KEY (sk_moeda)
);
ALTER SEQUENCE dim_moeda_sk_moeda_seq OWNED BY dim_moeda.sk_moeda;

CREATE SEQUENCE dim_meio_transporte_sk_meio_transporte_seq;
CREATE TABLE dim_meio_transporte (
    sk_meio_transporte INTEGER NOT NULL DEFAULT nextval('dim_meio_transporte_sk_meio_transporte_seq'),
    tipo_meio_transporte VARCHAR(20) NOT NULL UNIQUE,  -- MARITIMO, AEREO, etc
    descricao VARCHAR(100),
    CONSTRAINT dim_meio_transporte_pk PRIMARY KEY (sk_meio_transporte)
);
ALTER SEQUENCE dim_meio_transporte_sk_meio_transporte_seq OWNED BY dim_meio_transporte.sk_meio_transporte;

CREATE SEQUENCE dim_produtos_sk_produto_seq;
CREATE TABLE dim_produtos (
    sk_produto INTEGER NOT NULL DEFAULT nextval('dim_produtos_sk_produto_seq'),
    codigo_produto VARCHAR(20) NOT NULL UNIQUE,  -- SKU or similar
    nome_produto VARCHAR(100) NOT NULL,
    categoria_produto VARCHAR(50) NOT NULL,
    peso_unitario DECIMAL(10,2),
    unidade_medida VARCHAR(10),
    CONSTRAINT dim_produtos_pk PRIMARY KEY (sk_produto)
);
ALTER SEQUENCE dim_produtos_sk_produto_seq OWNED BY dim_produtos.sk_produto;

CREATE SEQUENCE dim_bloco_economico_sk_bloco_economico_seq;
CREATE TABLE dim_bloco_economico (
    sk_bloco_economico INTEGER NOT NULL DEFAULT nextval('dim_bloco_economico_sk_bloco_economico_seq'),
    sigla_bloco CHAR(5) NOT NULL UNIQUE,  -- MERCOSUL, UE, etc
    nome_bloco_economico VARCHAR(50) NOT NULL,
    ano_fundacao INTEGER,
    CONSTRAINT dim_bloco_economico_pk PRIMARY KEY (sk_bloco_economico)
);
ALTER SEQUENCE dim_bloco_economico_sk_bloco_economico_seq OWNED BY dim_bloco_economico.sk_bloco_economico;

CREATE SEQUENCE dim_pais_sk_pais_seq;
CREATE TABLE dim_pais (
    sk_pais INTEGER NOT NULL DEFAULT nextval('dim_pais_sk_pais_seq'),
    codigo_pais CHAR(3) NOT NULL UNIQUE,  -- ISO 3166-1 alpha-3 (BRA, USA, etc)
    nome_pais VARCHAR(50) NOT NULL,
    continente VARCHAR(20) NOT NULL,
    sk_bloco_economico INTEGER,
    CONSTRAINT dim_pais_pk PRIMARY KEY (sk_pais),
    CONSTRAINT dim_pais_bloco_fk FOREIGN KEY (sk_bloco_economico) 
        REFERENCES dim_bloco_economico(sk_bloco_economico)
);
ALTER SEQUENCE dim_pais_sk_pais_seq OWNED BY dim_pais.sk_pais;

CREATE SEQUENCE dim_tempo_sk_tempo_seq;
CREATE TABLE dim_tempo (
    sk_tempo INTEGER NOT NULL DEFAULT nextval('dim_tempo_sk_tempo_seq'),
    data_completa DATE NOT NULL UNIQUE,
    dia INTEGER NOT NULL CHECK (dia BETWEEN 1 AND 31),
    mes INTEGER NOT NULL CHECK (mes BETWEEN 1 AND 12),
    nome_mes VARCHAR(10) NOT NULL,
    trimestre INTEGER NOT NULL CHECK (trimestre BETWEEN 1 AND 4),
    semestre INTEGER NOT NULL CHECK (semestre BETWEEN 1 AND 2),
    ano INTEGER NOT NULL,
    dia_semana VARCHAR(10) NOT NULL,
    flag_feriado BOOLEAN DEFAULT FALSE,
    CONSTRAINT dim_tempo_pk PRIMARY KEY (sk_tempo)
);
ALTER SEQUENCE dim_tempo_sk_tempo_seq OWNED BY dim_tempo.sk_tempo;

-- FACT TABLE
CREATE SEQUENCE fato_transacao_id_transacao_seq;
CREATE TABLE fato_transacao (
    id_transacao INTEGER NOT NULL DEFAULT nextval('fato_transacao_id_transacao_seq'),
    sk_meio_transporte INTEGER NOT NULL,
    sk_produto INTEGER NOT NULL,
    sk_pais_origem INTEGER NOT NULL,
    sk_pais_destino INTEGER NOT NULL,
    sk_tempo INTEGER NOT NULL,
    sk_moeda INTEGER NOT NULL,
    sk_bloco_economico_origem INTEGER,
    sk_bloco_economico_destino INTEGER,
    quantidade_produto INTEGER NOT NULL CHECK (quantidade_produto > 0),
    tipo_transacao CHAR(1) NOT NULL CHECK (tipo_transacao IN ('E', 'I')), -- E=Exportação, I=Importação
    taxa_cambio DECIMAL(15,6) NOT NULL,
    valor_transacao_original DECIMAL(15,2) NOT NULL,
    valor_transacao_dolar DECIMAL(15,2) NOT NULL,
    peso_total DECIMAL(15,2),
    volume_total DECIMAL(15,2),
    CONSTRAINT fato_transacao_pk PRIMARY KEY (id_transacao),
    CONSTRAINT fato_meio_transporte_fk FOREIGN KEY (sk_meio_transporte)
        REFERENCES dim_meio_transporte(sk_meio_transporte),
    CONSTRAINT fato_produto_fk FOREIGN KEY (sk_produto)
        REFERENCES dim_produtos(sk_produto),
    CONSTRAINT fato_pais_origem_fk FOREIGN KEY (sk_pais_origem)
        REFERENCES dim_pais(sk_pais),
    CONSTRAINT fato_pais_destino_fk FOREIGN KEY (sk_pais_destino)
        REFERENCES dim_pais(sk_pais),
    CONSTRAINT fato_tempo_fk FOREIGN KEY (sk_tempo)
        REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fato_moeda_fk FOREIGN KEY (sk_moeda)
        REFERENCES dim_moeda(sk_moeda),
    CONSTRAINT fato_bloco_origem_fk FOREIGN KEY (sk_bloco_economico_origem)
        REFERENCES dim_bloco_economico(sk_bloco_economico),
    CONSTRAINT fato_bloco_destino_fk FOREIGN KEY (sk_bloco_economico_destino)
        REFERENCES dim_bloco_economico(sk_bloco_economico)
);
ALTER SEQUENCE fato_transacao_id_transacao_seq OWNED BY fato_transacao.id_transacao;

-- INDEXES FOR PERFORMANCE
CREATE INDEX idx_fato_transacao_tempo ON fato_transacao(sk_tempo);
CREATE INDEX idx_fato_transacao_produto ON fato_transacao(sk_produto);
CREATE INDEX idx_fato_transacao_pais_origem ON fato_transacao(sk_pais_origem);
CREATE INDEX idx_fato_transacao_pais_destino ON fato_transacao(sk_pais_destino);
CREATE INDEX idx_fato_transacao_moeda ON fato_transacao(sk_moeda);
CREATE INDEX idx_fato_transacao_tipo ON fato_transacao(tipo_transacao);