CREATE DATABASE if not exists  metrobus;

use metrobus;

-- ==================
-- DIMENSIONES 
-- ==================

CREATE TABLE dim_linea (
    linea_id INT PRIMARY KEY,
    codigo VARCHAR(10),
    nombre VARCHAR(100),
    tipo VARCHAR(50),
    km_recorrido FLOAT,
    n_paradas INT,
    frecuencia_min INT
);



CREATE TABLE dim_conductor (
    conductor_id INT PRIMARY KEY,
    nombre VARCHAR(100),
    anno_incorporacion INT,
    antiguedad_anos INT,
    turno_habitual VARCHAR(50),
    depot_id INT,
    formacion VARCHAR(100),
    licencia_tipo VARCHAR(50),
    activo BOOLEAN,
    ausencias_2024 INT
);


CREATE TABLE dim_vehiculo (
    vehiculo_id INT PRIMARY KEY,
    matricula VARCHAR(20),
    modelo VARCHAR(100),
    combustible VARCHAR(50),
    capacidad_sentados INT,
    capacidad_total INT,
    anno_fabricacion INT,
    anno_incorporacion INT,
    km_totales FLOAT,
    depot_id INT,
    emisiones_co2_gkm FLOAT,
    en_servicio BOOLEAN
);

CREATE TABLE dim_parada (
    parada_id INT PRIMARY KEY,
    nombre_parada VARCHAR(100),
    barrio VARCHAR(100),
    tipo VARCHAR(50),
    latitud FLOAT,
    longitud FLOAT,
    accesible_silla BOOLEAN,
    marquesina BOOLEAN,
    panel_informacion BOOLEAN,
    activa BOOLEAN
);

CREATE TABLE dim_depot (
    depot_id INT PRIMARY KEY,
    nombre VARCHAR(100),
    barrio VARCHAR(100),
    latitud FLOAT,
    longitud FLOAT,
    capacidad_vehiculos INT
);

CREATE TABLE dim_tarifa (
    tarifa_id INT PRIMARY KEY,
    tipo_titulo VARCHAR(100),
    categoria VARCHAR(50),
    precio_eur FLOAT,
    es_abono BOOLEAN,
    bonificado BOOLEAN
);

-- =========================
-- FACT TABLES
-- =========================

CREATE TABLE fact_viajes (
    viaje_id INT PRIMARY KEY,

    linea_id INT,
    vehiculo_id INT,
    conductor_id INT,
    parada_origen_id INT,
    parada_destino_id INT,

    fecha DATE,
    anno INT,
    mes INT,
    dia_semana VARCHAR(20),
    es_festivo BOOLEAN,
    franja_horaria VARCHAR(50),

    hora_salida_prog TIME,
    hora_salida_real TIME,
    hora_llegada_real TIME,

    retraso_salida_min INT,
    duracion_real_min INT,

    pasajeros_subidos INT,
    ocupacion_pct FLOAT,

    km_programados FLOAT,
    km_recorridos FLOAT,

    viaje_completado BOOLEAN,
    consumo FLOAT,

    tarifa_predominante_id INT,

    FOREIGN KEY (linea_id) REFERENCES dim_linea(linea_id),
    FOREIGN KEY (vehiculo_id) REFERENCES dim_vehiculo(vehiculo_id),
    FOREIGN KEY (conductor_id) REFERENCES dim_conductor(conductor_id),
    FOREIGN KEY (parada_origen_id) REFERENCES dim_parada(parada_id),
    FOREIGN KEY (parada_destino_id) REFERENCES dim_parada(parada_id),
    FOREIGN KEY (tarifa_predominante_id) REFERENCES dim_tarifa(tarifa_id)
);

CREATE TABLE fact_incidencias (
    incidencia_id INT PRIMARY KEY,

    viaje_id INT,
    vehiculo_id INT,
    conductor_id INT,
    linea_id INT,

    fecha DATE,
    anno INT,
    mes INT,
    hora_incidencia TIME,

    tipo_incidencia VARCHAR(100),
    categoria VARCHAR(50),
    severidad VARCHAR(50),

    requiere_retirada BOOLEAN,
    duracion_resolucion_min INT,
    vehiculo_sustituto BOOLEAN,
    coste_estimado_eur FLOAT,

    FOREIGN KEY (viaje_id) REFERENCES fact_viajes(viaje_id),
    FOREIGN KEY (vehiculo_id) REFERENCES dim_vehiculo(vehiculo_id),
    FOREIGN KEY (conductor_id) REFERENCES dim_conductor(conductor_id),
    FOREIGN KEY (linea_id) REFERENCES dim_linea(linea_id)
);

CREATE TABLE fact_mantenimiento (
    mantenimiento_id INT PRIMARY KEY,

    vehiculo_id INT,
    depot_id INT,

    fecha_entrada DATE,
    fecha_salida DATE,
    anno INT,
    mes INT,

    tipo_mantenimiento VARCHAR(100),
    categoria VARCHAR(50),
    es_correctivo BOOLEAN,

    dias_fuera_servicio INT,
    km_en_revision FLOAT,
    coste_eur FLOAT,

    proveedor VARCHAR(100),
    garantia_meses INT,

    FOREIGN KEY (vehiculo_id) REFERENCES dim_vehiculo(vehiculo_id),
    FOREIGN KEY (depot_id) REFERENCES dim_depot(depot_id)
);


SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_linea.csv'
INTO TABLE dim_linea
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_depot.csv'
INTO TABLE dim_depot
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_tarifa.csv'
INTO TABLE dim_tarifa
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(
tarifa_id,
tipo_titulo,
categoria,
precio_eur,
@es_abono,
@bonificado
)
SET 
es_abono = (@es_abono = 'VERDADERO'),
bonificado = (@bonificado = 'VERDADERO');
