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

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_conductor.csv'
INTO TABLE dim_conductor
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(
conductor_id,
nombre,
@anno_incorporacion,
@antiguedad_anos,
turno_habitual,
depot_id,
formacion,
licencia_tipo,
@activo,
@ausencias_2024
)
SET
anno_incorporacion = NULLIF(@anno_incorporacion, ''),
antiguedad_anos = NULLIF(@antiguedad_anos, ''),
activo = IF(@activo = 'True', 1, 0),
ausencias_2024 = NULLIF(@ausencias_2024, '');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_parada.csv'
INTO TABLE dim_parada
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(
parada_id,
nombre_parada,
barrio,
tipo,
latitud,
longitud,
@accesible_silla,
@marquesina,
@panel_informacion,
@activa
)
SET 
accesible_silla = IF(@accesible_silla = 'True', 1, 0),
marquesina = IF(@marquesina = 'True', 1, 0),
panel_informacion = IF(@panel_informacion = 'True', 1, 0),
activa = IF(@activa = 'True', 1, 0);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_parada.csv'
INTO TABLE dim_parada
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(
parada_id,
nombre_parada,
barrio,
tipo,
@latitud,
@longitud,
@accesible_silla,
@marquesina,
@panel_informacion,
@activa
)
SET
latitud = NULLIF(@latitud, ''),
longitud = NULLIF(@longitud, ''),

accesible_silla = IF(@accesible_silla = 'True', 1, 0),
marquesina = IF(@marquesina = 'True', 1, 0),
panel_informacion = IF(@panel_informacion = 'True', 1, 0),
activa = IF(@activa = 'True', 1, 0);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_vehiculo.csv'
INTO TABLE dim_vehiculo
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(
vehiculo_id,
matricula,
modelo,
@combustible,
@capacidad_sentados,
@capacidad_total,
@anno_fabricacion,
@anno_incorporacion,
@km_totales,
depot_id,
@emisiones_co2_gkm,
@en_servicio
)
SET
combustible = NULLIF(@combustible, ''),

capacidad_sentados = NULLIF(@capacidad_sentados, ''),
capacidad_total = NULLIF(@capacidad_total, ''),
anno_fabricacion = NULLIF(@anno_fabricacion, ''),
anno_incorporacion = NULLIF(@anno_incorporacion, ''),
km_totales = NULLIF(@km_totales, ''),
emisiones_co2_gkm = NULLIF(@emisiones_co2_gkm, ''),

en_servicio = IF(@en_servicio = 'True', 1, 0);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_viajes.csv'
INTO TABLE fact_viajes
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(
    viaje_id,
    linea_id,
    vehiculo_id,
    conductor_id,
    parada_origen_id,
    parada_destino_id,
    @fecha,
    anno,
    mes,
    dia_semana,
    @es_festivo,
    franja_horaria,
    @hora_salida_prog,
    @hora_salida_real,
    @hora_llegada_real,
    retraso_salida_min,
    duracion_real_min,
    @pasajeros_subidos,
    ocupacion_pct,
    km_programados,
    km_recorridos,
    @viaje_completado,
    @consumo,
    tarifa_predominante_id
)
SET
-- Fechas
fecha = STR_TO_DATE(@fecha, '%Y-%m-%d'),

-- Horas
hora_salida_prog = STR_TO_DATE(@hora_salida_prog, '%H:%i:%s'),
hora_salida_real = STR_TO_DATE(@hora_salida_real, '%H:%i:%s'),
hora_llegada_real = STR_TO_DATE(@hora_llegada_real, '%H:%i:%s'),

-- Booleanos
es_festivo = IF(@es_festivo = 'True', 1, 0),
viaje_completado = IF(@viaje_completado = 'True', 1, 0),

-- Nulos en enteros
pasajeros_subidos = NULLIF(@pasajeros_subidos, ''),

-- Nulos en float
consumo = NULLIF(@consumo, '');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_incidencias.csv'
INTO TABLE fact_incidencias
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(
    incidencia_id,
    viaje_id,
    vehiculo_id,
    conductor_id,
    linea_id,
    @fecha,
    anno,
    mes,
    @hora_incidencia,
    tipo_incidencia,
    categoria,
    severidad,
    @requiere_retirada,
    duracion_resolucion_min,
    @vehiculo_sustituto,
    coste_estimado_eur
)
SET
-- Fecha
fecha = STR_TO_DATE(@fecha, '%Y-%m-%d'),

-- Hora
hora_incidencia = STR_TO_DATE(@hora_incidencia, '%H:%i:%s'),

-- Booleanos
requiere_retirada = IF(@requiere_retirada = 'True', 1, 0),
vehiculo_sustituto = IF(@vehiculo_sustituto = 'True', 1, 0);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_mantenimiento.csv'
INTO TABLE fact_mantenimiento
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(
    mantenimiento_id,
    vehiculo_id,
    depot_id,
    @fecha_entrada,
    @fecha_salida,
    anno,
    mes,
    tipo_mantenimiento,
    @categoria,
    @es_correctivo,
    dias_fuera_servicio,
    km_en_revision,
    coste_eur,
    proveedor,
    garantia_meses
)
SET
-- Fechas
fecha_entrada = STR_TO_DATE(@fecha_entrada, '%Y-%m-%d'),
fecha_salida  = STR_TO_DATE(@fecha_salida, '%Y-%m-%d'),

-- Boolean
es_correctivo = IF(@es_correctivo = 'True', 1, 0),

-- Nulos en categoria
categoria = NULLIF(@categoria, '');