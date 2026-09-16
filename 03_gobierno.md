## fact_viajes

| Campo                   | Tipo        | Descripción                              | Valores válidos / rango        | Observaciones |
|------------------------|------------|------------------------------------------|-------------------------------|--------------|
| viaje_id               | INT        | Identificador único del viaje            | > 0                           | PK |
| linea_id               | INT        | Línea asociada                           | FK dim_linea                  | - |
| vehiculo_id            | INT        | Vehículo utilizado                       | FK dim_vehiculo               | - |
| conductor_id           | INT        | Conductor asignado                       | FK dim_conductor              | - |
| fecha                  | DATE       | Fecha del viaje                          | YYYY-MM-DD                    | - |
| es_festivo             | BOOLEAN    | Indica si es festivo                     | 0/1                           | OK |
| retraso_salida_min     | INT        | Minutos de retraso                       | >= 0                          | Puede tener outliers |
| duracion_real_min      | INT        | Duración del viaje                       | > 0                           | Revisar coherencia |
| pasajeros_subidos      | INT        | Nº pasajeros                             | >= 0                          | Hay nulos detectados |
| ocupacion_pct          | FLOAT      | % ocupación                              | 0 - 1                         | Correcto |
| km_recorridos          | FLOAT      | Km realizados                            | > 0                           | Revisado en EDA |
| consumo                | FLOAT      | Consumo del vehículo                     | > 0                           | Hay valores nulos |
| viaje_completado       | BOOLEAN    | Si el viaje se completó                  | 0 / 1                         | Transformado desde True/False |


## dim_conductor

| Campo                   | Tipo       | Descripción                              | Valores válidos/rango         |  Obeservaciones     |
|---------------------------------------------------------------------------------------------------------------------------------------|
| conductor_id            | INT        | Identificador único del conductor        | >0                            | PK  |
| nombre                  | VARCHAR    | Nombre del conductor                     | nombres                       | OK  |
| anno_incorporacion      | INT        | Año de incorporación                     | 2020/2025 aporx               | Redudante (derivable de la fecha)
| antiguedad_annos        | INT        | Número de años en la empresa             | >0                            | Un valor nulo  |
| turno_habitual          | VARCHAR    | Indica el turno de trabajo               | manana, tarde, noche, partido | 















## Data Quality Log

| Tabla              | Campo                | Problema               | Frecuencia | Decisión tomada                          | Justificación |
|--------------------|----------------------|------------------------|------------|------------------------------------------|--------------|
| dim_linea          | separador CSV        | Uso de ";"             | 100%       | Cambio a separador coma                  | Incompatibilidad con LOAD DATA |
| dim_parada         | latitud              | Valores nulos          | 1 fila     | Convertido a NULL                        | Error de origen |
| dim_parada         | accesible_silla      | Tipo incorrecto        | 100%       | Convertido a BOOLEAN (0/1)               | Venía como texto |
| dim_conductor      | antiguedad_anos      | Valor vacío            | 1 fila     | Convertido a NULL                        | Dato faltante |
| dim_vehiculo       | combustible          | Valor nulo             | varias     | Permitido NULL                           | No crítico |
| fact_viajes        | pasajeros_subidos    | Valores nulos          | X filas    | Convertido a NULL                        | No imputado |
| fact_viajes        | consumo              | Valores nulos          | X filas    | Convertido a NULL                        | Evitar sesgo |
| fact_mantenimiento | categoria            | Valores nulos          | X filas    | Convertido a NULL                        | No obligatorio |
| fact_mantenimiento | es_correctivo        | Texto en lugar de bool | 100%       | Convertido a 0/1                         | Normalización |