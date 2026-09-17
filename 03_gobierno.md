## dim_linea

| Campo          | Tipo    | Descripción                     | Valores válidos / rango | Observaciones |
|----------------|---------|---------------------------------|-------------------------|--------------|
| linea_id       | INT     | Identificador único de la línea | > 0                     | PK |
| codigo         | VARCHAR | Código identificativo           | Texto                   | OK |
| nombre         | VARCHAR | Nombre de la línea              | Texto                   | OK |
| tipo           | VARCHAR | Tipo de línea                   | urbana/interurbana      | OK |
| km_recorrido   | FLOAT   | Km totales de la línea          | > 0                     | Posible incoherencia detectada |
| n_paradas      | INT     | Número de paradas               | > 0                     | OK |
| frecuencia_min | INT     | Frecuencia en minutos           | > 0                     | OK |

## dim_conductor

| Campo              | Tipo    | Descripción                 | Valores válidos / rango | Observaciones |
|--------------------|---------|-----------------------------|-------------------------|---------------|
| conductor_id       | INT     | Identificador del conductor | > 0                     | PK |
| nombre             | VARCHAR | Nombre del conductor        | Texto                   | OK |
| anno_incorporacion | INT     | Año de incorporación        | > 2000                  | Puede haber valores nulos |
| antiguedad_anos    | INT     | Años en la empresa          | >= 0                    | Derivable |
| turno_habitual     | VARCHAR | Turno habitual              | mañana/tarde/noche      | OK |
| depot_id           | INT     | Depósito asignado           | FK dim_depot            | OK |
| formacion          | VARCHAR | Formación del conductor     | Texto                   | OK |
| licencia_tipo      | VARCHAR | Tipo de licencia            | Texto                   | OK |
| activo             | BOOLEAN | Estado activo               | 0/1                     | Convertido desde texto |
| ausencias_2024     | INT     | Nº ausencias                | >= 0                    | OK |


## dim_vehiculo

| Campo              | Tipo    | Descripción                | Valores válidos / rango | Observaciones |
|--------------------|---------|----------------------------|-------------------------|---------------|
| vehiculo_id        | INT     | Identificador del vehículo | > 0                     | PK |
| matricula          | VARCHAR | Matrícula                  | Texto                   | OK |
| modelo             | VARCHAR | Modelo                     | Texto                   | OK |
| combustible        | VARCHAR | Tipo de combustible        | diesel/híbrido/etc      | Valores nulos detectados |
| capacidad_sentados | INT     | Plazas sentadas            | > 0                     | OK |
| capacidad_total    | INT     | Capacidad total            | > 0                     | OK |
| anno_fabricacion   | INT     | Año fabricación            | > 2000                  | OK |
| anno_incorporacion | INT     | Año incorporación          | > 2000                  | OK |
| km_totales         | FLOAT   | Km acumulados              | >= 0                    | OK |
| depot_id           | INT     | Depósito asignado          | FK dim_depot            | OK |
| emisiones_co2_gkm  | FLOAT   | Emisiones CO2              | >= 0                    | OK |
| en_servicio        | BOOLEAN | Estado operativo           | 0/1                     | Convertido desde texto |


## dim_parada

| Campo             | Tipo    | Descripción             | Valores válidos / rango | Observaciones |
|-------------------|---------|-------------------------|-------------------------|---------------|
| parada_id         | INT     | Identificador de parada | > 0                     | PK |
| nombre_parada     | VARCHAR | Nombre de parada        | Texto                   | OK |
| barrio            | VARCHAR | Barrio                  | Texto                   | OK |
| tipo              | VARCHAR | Tipo de parada          | inicio/intermedia/final | OK |
| latitud           | FLOAT   | Latitud geográfica      | -90 a 90                | Valores nulos detectados |
| longitud          | FLOAT   | Longitud geográfica     | -180 a 180              | Valores nulos detectados |
| accesible_silla   | BOOLEAN | Accesibilidad           | 0/1                     | Convertido desde texto |
| marquesina        | BOOLEAN | Tiene marquesina        | 0/1                     | OK |
| panel_informacion | BOOLEAN | Panel informativo       | 0/1                     | OK |
| activa            | BOOLEAN | Estado operativo        | 0/1                     | OK |


## dim_depot

| Campo               | Tipo    | Descripción                 | Valores válidos / rango | Observaciones |
|---------------------|---------|-----------------------------|-------------------------|---------------|
| depot_id            | INT     | Identificador del depósito  | > 0                     | PK |
| nombre              | VARCHAR | Nombre del depósito         | Texto                   | OK |
| barrio              | VARCHAR | Ubicación                   | Texto                   | OK |
| latitud             | FLOAT   | Latitud                     | -90 a 90                | OK |
| longitud            | FLOAT   | Longitud                    | -180 a 180              | OK |
| capacidad_vehiculos | INT     | Capacidad                   | > 0                     | OK |


## dim_tarifa

| Campo       | Tipo    | Descripción          | Valores válidos / rango | Observaciones |
|-------------|---------|----------------------|-------------------------|---------------|
| tarifa_id   | INT     | Identificador tarifa | > 0                     | PK |
| tipo_titulo | VARCHAR | Tipo de título       | Texto                   | OK |
| categoria   | VARCHAR | Categoría            | Texto                   | Puede tener nulos |
| precio_eur  | FLOAT   | Precio en euros      | >= 0                    | OK |
| es_abono    | BOOLEAN | Es abono             | 0/1                     | Convertido desde texto |
| bonificado  | BOOLEAN | Tarifa bonificada    | 0/1                     | OK |


## fact_incidencias

| Campo                   | Tipo    | Descripción         | Valores válidos / rango | Observaciones |
|-------------------------|---------|---------------------|-------------------------|---------------|
| incidencia_id           | INT     | ID incidencia       | > 0                     | PK |
| viaje_id                | INT     | Viaje asociado      | FK fact_viajes          | OK |
| vehiculo_id             | INT     | Vehículo afectado   | FK dim_vehiculo         | OK |
| conductor_id            | INT     | Conductor implicado | FK dim_conductor        | OK |
| linea_id                | INT     | Línea afectada      | FK dim_linea            | OK |
| fecha                   | DATE    | Fecha incidencia    | YYYY-MM-DD              | OK |
| anno                    | INT     | Año                 | Derivable               | Redundante |
| mes                     | INT     | Mes                 | 1–12                    | Redundante |
| hora_incidencia         | TIME    | Hora                | 00:00–23:59             | OK |
| tipo_incidencia         | VARCHAR | Tipo                | Texto                   | OK |
| categoria               | VARCHAR | Categoría           | Texto                   | OK |
| severidad               | VARCHAR | Gravedad            | baja/media/alta/crítica | OK |
| requiere_retirada       | BOOLEAN | Retirada vehículo   | 0/1                     | Convertido desde texto |
| duracion_resolucion_min | INT     | Tiempo resolución   | > 0                     | Poco realista en algunos casos |
| vehiculo_sustituto      | BOOLEAN | Sustitución         | 0/1                     | OK |
| coste_estimado_eur      | FLOAT   | Coste               | >= 0                    | OK |


## fact_mantenimiento

| Campo               | Tipo    | Descripción           | Valores válidos / rango | Observaciones |
|---------------------|---------|-----------------------|-------------------------|---------------|
| mantenimiento_id    | INT     | ID mantenimiento      | > 0                     | PK |
| vehiculo_id         | INT     | Vehículo              | FK dim_vehiculo         | OK |
| depot_id            | INT     | Depósito              | FK dim_depot            | OK |
| fecha_entrada       | DATE    | Entrada taller        | YYYY-MM-DD              | OK |
| fecha_salida        | DATE    | Salida taller         | YYYY-MM-DD              | OK |
| anno                | INT     | Año                   | Derivable               | Redundante |
| mes                 | INT     | Mes                   | 1–12                    | Redundante |
| tipo_mantenimiento  | VARCHAR | Tipo                  | Texto                   | OK |
| categoria           | VARCHAR | Categoría             | Texto                   | Valores nulos |
| es_correctivo       | BOOLEAN | Correctivo/preventivo | 0/1                     | Convertido desde texto |
| dias_fuera_servicio | INT     | Días fuera            | >= 0                    | OK |
| km_en_revision      | FLOAT   | Km en revisión        | >= 0                    | OK |
| coste_eur           | FLOAT   | Coste                 | >= 0                    | OK |
| proveedor           | VARCHAR | Proveedor             | Texto                   | OK |
| garantia_meses      | INT     | Garantía              | >= 0                    | OK |

## fact_viajes

| Campo              | Tipo    | Descripción                        | Valores válidos / rango  | Observaciones |
|--------------------|---------|------------------------------------|--------------------------|--------------|
| viaje_id           | INT     | Identificador único del viaje      | > 0                      | PK |
| linea_id           | INT     | Línea asociada                     | FK dim_linea             | - |
| vehiculo_id        | INT     | Vehículo utilizado                 | FK dim_vehiculo          | - |
| conductor_id       | INT     | Conductor asignado                 | FK dim_conductor         | - |
| fecha              | DATE    | Fecha del viaje                    | YYYY-MM-DD               | - |
| anno               | INT     | Año del viaje                      | 2020–2025 aprox          | Redundante (derivable de fecha) |
| mes                | INT     | Mes del viaje                      | 1–12                     | Redundante |
| dia_semana         | VARCHAR | Día de la semana                   | Lunes–Domingo            | OK |
| es_festivo         | BOOLEAN | Indica si es festivo               | 0/1                      | Transformado desde True/False |
| franja_horaria     | VARCHAR | Franja horaria del viaje           | mañana/tarde/noche       | OK |
| hora_salida_prog   | TIME    | Hora programada de salida          | 00:00–23:59              | OK |
| hora_salida_real   | TIME    | Hora real de salida                | 00:00–23:59              | Puede presentar retrasos |
| hora_llegada_real  | TIME    | Hora real de llegada               | 00:00–23:59              | OK |
| retraso_salida_min | INT     | Minutos de retraso en salida       | >= 0                     | Presencia de outliers |
| duracion_real_min  | INT     | Duración real del viaje en minutos | > 0                      | Valores poco realistas detectados |
| pasajeros_subidos  | INT     | Número de pasajeros que suben      | >= 0                     | Valores nulos detectados, excluidos en KPIs |
| ocupacion_pct      | FLOAT   | Porcentaje de ocupación            | 0 - 1                    | Correcto |
| km_programados     | FLOAT   | Km planificados del viaje          | > 0                      | Referencia para análisis de eficiencia |
| km_recorridos      | FLOAT   | Km realmente recorridos            | > 0                      | Posibles incoherencias con duración |
| consumo            | FLOAT   | Consumo del vehículo               | > 0                      | Valores nulos y semántica ambigua |
| viaje_completado   | BOOLEAN | Indica si el viaje se completó     | 0 / 1                    | Transformado desde True/False |





## Data Quality Log

| Tabla              | Campo                | Problema               | Frecuencia | Decisión tomada                          | Justificación |
|--------------------|----------------------|------------------------|------------|------------------------------------------|---------------|
| dim_linea          | separador CSV        | Uso de ";"             | 100%       | Cambio a separador coma                  | Incompatibilidad con LOAD DATA |
| dim_parada         | latitud              | Valores nulos          | 1 fila     | Convertido a NULL                        | Error de origen |
| dim_parada         | accesible_silla      | Tipo incorrecto        | 100%       | Convertido a BOOLEAN (0/1)               | Venía como texto |
| dim_conductor      | antiguedad_anos      | Valor vacío            | 1 fila     | Convertido a NULL                        | Dato faltante |
| dim_vehiculo       | combustible          | Valor nulo             | varias     | Permitido NULL                           | No crítico |
| fact_viajes        | pasajeros_subidos    | Valores nulos          | 40 filas   | Convertido a NULL                        | No imputado |
| fact_viajes        | consumo              | Valores nulos          | 1065 filas | Convertido a NULL                        | Evitar sesgo |
| fact_mantenimiento | categoria            | Valores nulos          | 15 filas   | Convertido a NULL                        | No obligatorio |
| fact_mantenimiento | es_correctivo        | Texto en lugar de bool | 100%       | Convertido a 0/1                         | Normalización |





## KPIs

| KPI                       | Descripción                                                                                                  |Fórmula                                 | Fuente                        | Exclusiones              | Responsable |
|---------------------------|--------------------------------------------------------------------------------------------------------------|-----------------------------------------|-------------------------------|--------------------------|-------------|
| Tasa de viajes completados| Porcentaje de viajes que se finalizan correctamente respecto al total de viajes realizados                    |SUM(viaje_completado) / COUNT(*)                     | fact_viajes.viaje_completado |  -                       | Operaciones |
| Ocupación media           | Nivel medio de ocupación de los vehículos en los viajes, indicando el grado de aprovechamiento de la capacidad|AVG(ocupacion_pct)                      | fact_viajes                   | viajes completados = 1    | Operaciones |
| Consumo medio             | Consumo medio de los vehículos por viaje, utilizado como indicador de eficiencia operativa                     |AVG(consumo)                            | fact_viajes                   | consumo IS NOT NULL      | Operaciones |
| Retraso medio             | Promedio de minutos de retraso en la salida de los viajes respecto a la hora programada                        |AVG(retraso_salida_min)                 | fact_viajes                   | -                        | Operaciones |
| Coste total mantenimiento | Coste total acumulado de las operaciones de mantenimiento realizadas sobre los vehículos                       |SUM(coste_eur)                          | fact_mantenimiento            | -                        | Finanzas    |
| Coste medio incidencia    | Coste promedio asociado a la resolución de incidencias registradas en la operativa                             |AVG(coste_estimado_eur)                 | fact_incidencias              |coste_estimado_eur > 0    | Mantenimiento |
| Duración media incidencia | Tiempo medio necesario para resolver incidencias, medido en minutos                                            |AVG(duracion_resolucion_min)            | fact_incidencias              | -                        | Mantenimiento |
| Km medios por viaje       | Distancia media recorrida por viaje, utilizada para analizar la eficiencia y planificación de rutas            | AVG(km_recorridos)                      | fact_viajes                   | -                        | Operaciones |