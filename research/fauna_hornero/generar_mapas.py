"""Create occurrence maps for the Hornero fauna research notes.

Uses a capped sample of GBIF georeferenced records and Natural Earth country
boundaries. Red dots are reported occurrences, not a modeled range polygon.
"""

from pathlib import Path
from urllib.request import urlopen
import json

import geopandas as gpd
import matplotlib.pyplot as plt


OUT = Path(__file__).parent
TAXA = [
    ("taguato_comun", "Taguató común", "Rupornis magnirostris", 5844398),
    ("lechuzon_orejudo", "Lechuzón orejudo", "Asio clamator", 4843115),
    ("tordo_renegrido", "Tordo renegrido", "Molothrus bonariensis", 2484396),
    ("carancho", "Carancho", "Caracara plancus", 2480989),
]
COUNTRIES_URL = (
    "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/"
    "master/geojson/ne_110m_admin_0_countries.geojson"
)
BOUNDS = (-120, -30, -60, 35)


def load_countries():
    with urlopen(COUNTRIES_URL, timeout=60) as response:
        geojson = json.load(response)
    return gpd.GeoDataFrame.from_features(geojson["features"], crs="EPSG:4326")


def load_occurrences(taxon_key):
    url = (
        "https://api.gbif.org/v1/occurrence/search"
        f"?taxonKey={taxon_key}&continent=SOUTH_AMERICA"
        "&hasCoordinate=true&hasGeospatialIssue=false&limit=300"
    )
    with urlopen(url, timeout=60) as response:
        payload = json.load(response)
    points = [
        (row["decimalLongitude"], row["decimalLatitude"])
        for row in payload["results"]
        if row.get("decimalLongitude") is not None
        and row.get("decimalLatitude") is not None
    ]
    return payload["count"], points


def make_map(countries, slug, common, scientific, taxon_key):
    total, points = load_occurrences(taxon_key)
    west, east, south, north = BOUNDS
    fig, ax = plt.subplots(figsize=(10, 7), dpi=180)
    fig.patch.set_facecolor("#f7f4ec")
    ax.set_facecolor("#e8f0f2")
    countries.cx[west:east, south:north].plot(
        ax=ax, color="#e6e1d4", edgecolor="#958f82", linewidth=0.48
    )
    xs = [x for x, y in points if west <= x <= east and south <= y <= north]
    ys = [y for x, y in points if west <= x <= east and south <= y <= north]
    ax.scatter(
        xs,
        ys,
        s=8,
        color="#d8262f",
        alpha=0.52,
        linewidths=0,
        rasterized=True,
        zorder=3,
    )
    ax.set_xlim(west, east)
    ax.set_ylim(south, north)
    ax.set_aspect("equal", adjustable="box")
    ax.axis("off")
    ax.set_title(f"{common}\n{scientific}", loc="left", fontsize=19, weight="bold", color="#25271f", pad=14)
    fig.text(
        0.125,
        0.065,
        f"Puntos rojos: muestra de {len(xs)} observaciones georreferenciadas de GBIF. "
        f"La consulta encontró {total:,} registros en Sudamérica.\n"
        "Los puntos reflejan dónde hubo registros; no son límites de distribución ni indican ausencia. "
        "Consulta: 7 oct 2026.",
        fontsize=8.5,
        color="#45443f",
    )
    fig.text(0.88, 0.018, "Datos: GBIF  |  Mapa base: Natural Earth", ha="right", fontsize=7.5, color="#65625b")
    fig.subplots_adjust(left=0.06, right=0.98, top=0.88, bottom=0.19)
    path = OUT / f"mapa_{slug}_gbif.png"
    fig.savefig(path, facecolor=fig.get_facecolor(), bbox_inches="tight")
    plt.close(fig)
    print(f"{path.name}: {len(xs)} plotted / {total} GBIF South America records")


if __name__ == "__main__":
    country_shapes = load_countries()
    for taxon in TAXA:
        make_map(country_shapes, *taxon)
