import pandas as pd
import os

# 1. Leer las tres tablas de hechos
viajes = pd.read_csv("Data/raw/fact_viajes.csv")
incidencias = pd.read_csv("Data/raw/fact_incidencias.csv")
mantenimiento = pd.read_csv("Data/raw/fact_mantenimiento.csv")

# 2. Convertir las columnas de fecha a formato datetime
fechas_viajes = pd.to_datetime(
    viajes["fecha"], errors="coerce", dayfirst=True
)

fechas_incidencias = pd.to_datetime(
    incidencias["fecha"], errors="coerce", dayfirst=True
)

fechas_mantenimiento = pd.to_datetime(
    mantenimiento["fecha_entrada"], errors="coerce", dayfirst=True
)

# 3. Obtener la fecha mínima y máxima de las tres tablas
todas_las_fechas = pd.concat([
    fechas_viajes,
    fechas_incidencias,
    fechas_mantenimiento
]).dropna()

fecha_inicio = todas_las_fechas.min().normalize()
fecha_fin = todas_las_fechas.max().normalize()

print("Fecha inicial:", fecha_inicio)
print("Fecha final:", fecha_fin)

# 4. Crear el calendario completo
os.makedirs("Data/processed", exist_ok=True)
dim_date = pd.DataFrame({
    "fecha": pd.date_range(
        start=fecha_inicio,
        end=fecha_fin,
        freq="D"
    )
})

# 5. Crear las columnas de la dimensión temporal
dim_date["date_key"] = (
    dim_date["fecha"].dt.strftime("%Y%m%d").astype(int)
)

dim_date["anno"] = dim_date["fecha"].dt.year

dim_date["trimestre"] = (
    "T" + dim_date["fecha"].dt.quarter.astype(str)
)

dim_date["mes_numero"] = dim_date["fecha"].dt.month

meses = {
    1: "Enero",
    2: "Febrero",
    3: "Marzo",
    4: "Abril",
    5: "Mayo",
    6: "Junio",
    7: "Julio",
    8: "Agosto",
    9: "Septiembre",
    10: "Octubre",
    11: "Noviembre",
    12: "Diciembre"
}

dim_date["mes_nombre"] = (
    dim_date["mes_numero"].map(meses)
)

dim_date["semana"] = (
    dim_date["fecha"].dt.isocalendar().week.astype(int)
)

dim_date["dia"] = dim_date["fecha"].dt.day

dias = {
    0: "Lunes",
    1: "Martes",
    2: "Miércoles",
    3: "Jueves",
    4: "Viernes",
    5: "Sábado",
    6: "Domingo"
}

dim_date["dia_semana"] = (
    dim_date["fecha"].dt.dayofweek.map(dias)
)

dim_date["es_fin_semana"] = (
    dim_date["fecha"].dt.dayofweek >= 5
)

# 6. Exportar el CSV
dim_date["fecha"] = dim_date["fecha"].dt.strftime("%Y-%m-%d")

dim_date.to_csv(
    "Data/processed/dim_date.csv",
    index=False,
    encoding="utf-8-sig"
)

print("\nTabla dim_date creada correctamente")
print(dim_date.head())
print("Total de fechas:", len(dim_date))

print("¡DIM_DATE CREADA CORRECTAMENTE!")
print("Número de registros:", len(dim_date))
print("Primera fecha:", dim_date["fecha"].min())
print("Última fecha:", dim_date["fecha"].max())
print(dim_date.head(10))