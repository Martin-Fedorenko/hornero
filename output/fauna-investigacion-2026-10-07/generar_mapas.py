"""Mapas científicos de observaciones GBIF; no modifica archivos del juego.

Python + requests + numpy + matplotlib + Pillow. Cada mapa usa todas las
observaciones humanas indexadas por las teselas, no una muestra de 300 puntos.
Los PNG de GBIF se usan como capa geográfica con su extensión Web Mercator.
"""
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
import io
import json
import math
import time
import threading
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
import numpy as np
from PIL import Image
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from matplotlib.lines import Line2D

ROOT = Path(__file__).resolve().parent
CACHE = ROOT / 'datos'
MAPS = ROOT / 'mapas'
for directory in (CACHE, MAPS):
    directory.mkdir(exist_ok=True)
SPECIES = json.loads((ROOT / 'especies.json').read_text(encoding='utf-8'))
DATE = '2026-10-07'
WORLD_URL = 'https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_110m_admin_0_countries.geojson'
WORLD = CACHE / 'natural_earth_110m.geojson'
LOCAL = threading.local()
def session():
    if not hasattr(LOCAL, 'session'):
        LOCAL.session = requests.Session()
        LOCAL.session.headers['User-Agent'] = 'Hornero-fauna-research/1.0'
        LOCAL.session.mount('https://', HTTPAdapter(max_retries=Retry(total=3, backoff_factor=1, status_forcelist=[429,500,502,503,504])))
    return LOCAL.session
def get(url, params=None):
    r = session().get(url, params=params, timeout=70)
    r.raise_for_status()
    return r
if not WORLD.exists():
    WORLD.write_bytes(get(WORLD_URL).content)
world = json.loads(WORLD.read_text(encoding='utf-8'))
R = 6378137
HALF = math.pi * R
def project(lon, lat):
    lat = np.clip(np.asarray(lat), -85, 85)
    return R*np.radians(lon), R*np.log(np.tan(np.pi/4+np.radians(lat)/2))
def polygons(feature):
    geom = feature['geometry']
    return [geom['coordinates']] if geom['type']=='Polygon' else geom['coordinates']
def draw_countries(ax, fill=False, mask_context=False):
    for f in world['features']:
        name = f['properties'].get('ADMIN','')
        context = name in ['United States of America','Canada']
        if mask_context and not context:
            continue
        for poly in polygons(f):
            xy=np.asarray(poly[0])
            if xy[:,0].max() < -120 or xy[:,0].min() > -29 or xy[:,1].max() < -59 or xy[:,1].min() > 34:
                continue
            x,y=project(xy[:,0],xy[:,1])
            ax.add_patch(Polygon(np.column_stack([x,y]),closed=True,facecolor=('#e5e9e5' if fill or mask_context else 'none'),edgecolor='#81918b',linewidth=.45,zorder=4 if mask_context else (0 if fill else 3)))
def resolve(s):
    p=CACHE/(s['id']+'_taxon.json')
    if p.exists():
        match=json.loads(p.read_text(encoding='utf-8'))
    else:
        match=get('https://api.gbif.org/v1/species/match',{'name':s['cientifico'],'strict':'true'}).json()
        p.write_text(json.dumps(match,ensure_ascii=False,indent=2),encoding='utf-8')
    if match.get('matchType')!='EXACT' or match.get('rank')!='SPECIES':
        raise ValueError(f"Taxón no resuelto exactamente: {s['cientifico']}: {match}")
    return match,match.get('acceptedUsageKey',match['usageKey'])
def tile(s,key,x,y):
    p=CACHE/f"{s['id']}_3_{x}_{y}.png"
    url=f'https://api.gbif.org/v2/map/occurrence/density/3/{x}/{y}@1x.png'
    params={'taxonKey':key,'style':'red.point','srs':'EPSG:3857','basisOfRecord':'HUMAN_OBSERVATION','year':'2000,2026'}
    if not p.exists():
        r=get(url,params)
        if 'image/png' not in r.headers.get('Content-Type',''):
            raise ValueError('Respuesta no PNG: '+r.text[:200])
        p.write_bytes(r.content)
    im=Image.open(p).convert('RGBA')
    side=2*HALF/8
    bounds=(-HALF+x*side,-HALF+(x+1)*side,HALF-(y+1)*side,HALF-y*side)
    return {'array':np.asarray(im),'extent':bounds,'url':requests.Request('GET',url,params=params).prepare().url}
def fetch_species(s):
    match,key=resolve(s)
    with ThreadPoolExecutor(max_workers=3) as pool:
        layers=list(pool.map(lambda pair:tile(s,key,*pair),[(x,y) for x in [1,2,3] for y in [3,4,5]]))
    return s,match,key,layers
def render(s,match,key,layers):
    fig,ax=plt.subplots(figsize=(9,11.4),dpi=150)
    fig.patch.set_facecolor('#faf9f5')
    ax.set_facecolor('#edf4f6')
    fig.subplots_adjust(left=.06,right=.97,top=.89,bottom=.15)
    draw_countries(ax,fill=True)
    for t in layers:
        ax.imshow(t['array'],extent=t['extent'],origin='upper',interpolation='nearest',zorder=2)
    draw_countries(ax)
    draw_countries(ax,mask_context=True)
    xmin,ymin=project(-119,-57)
    xmax,ymax=project(-30,33)
    ax.set_xlim(xmin,xmax)
    ax.set_ylim(ymin,ymax)
    ax.set_aspect('equal')
    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_color('#b8c7c0')
    labels=[('MÉXICO',-102,24),('CUBA',-79,22),('COLOMBIA',-73,5),('VENEZUELA',-65,9),('ECUADOR',-78,-2),('PERÚ',-74,-11),('BRASIL',-52,-10),('BOLIVIA',-64,-18),('PARAGUAY',-58,-23),('CHILE',-73,-31),('ARGENTINA',-65,-36),('URUGUAY',-55,-33),('AMÉRICA\nCENTRAL',-90,11)]
    for label,lon,lat in labels:
        px,py=project(lon,lat)
        ax.text(px,py,label,fontsize=6.5,color='#243c37',ha='center',va='center',zorder=5,bbox=dict(facecolor='white',alpha=.65,edgecolor='none',pad=1))
    fig.text(.075,.965,'FAUNA · ESTUDIO PREVIO',fontsize=10,color='#477168',weight='bold')
    fig.text(.075,.931,s['nombre'],fontsize=23,color='#193f35',weight='bold')
    fig.text(.075,.905,s['cientifico'],fontsize=13,color='#477168',style='italic')
    ax.legend(handles=[Line2D([0],[0],marker='o',color='none',markerfacecolor='#d51920',markeredgecolor='none',markersize=7,label='Observaciones humanas registradas en GBIF')],loc='lower left',fontsize=8,framealpha=.97)
    fig.text(.075,.115,'América Latina y Caribe · registros de 2000–2026',fontsize=11,color='#193f35',weight='bold')
    fig.text(.075,.090,'Rojo = presencia registrada de esta especie; no indica ataques al hornero.',fontsize=9,color='#364d46')
    fig.text(.075,.071,'Los vacíos no prueban ausencia. La intensidad depende del esfuerzo de observación.',fontsize=8.1,color='#52625c')
    fig.text(.075,.052,'Puede incluir registros históricos, introducidos o mal identificados; no es un mapa de abundancia.',fontsize=7.7,color='#52625c')
    fig.text(.075,.028,f'GBIF Maps API · taxonKey {key} · Natural Earth 1:110m · Web Mercator · consulta {DATE}',fontsize=7.4,color='#52625c')
    fig.savefig(MAPS/(s['id']+'.png'),facecolor=fig.get_facecolor())
    plt.close(fig)
    return {'id':s['id'],'requestedName':s['cientifico'],'gbifTaxonKey':key,'gbifMatch':match,'queriedOn':DATE,'basisOfRecord':'HUMAN_OBSERVATION','years':[2000,2026],'projection':'EPSG:3857','extentLonLat':[-119,-57,-30,33],'tileUrls':[t['url'] for t in layers],'basemapUrl':WORLD_URL,'occurrenceExplorer':f'https://www.gbif.org/occurrence/search?taxon_key={key}&basis_of_record=HUMAN_OBSERVATION&year=2000,2026'}

if __name__=='__main__':
    metadata=[]
    errors=[]
    with ThreadPoolExecutor(max_workers=4) as pool:
        jobs={pool.submit(fetch_species,s):s for s in SPECIES}
        for future in as_completed(jobs):
            s=jobs[future]
            try:
                metadata.append(render(*future.result()))
                print('OK',s['id'],flush=True)
            except Exception as e:
                errors.append({'id':s['id'],'error':str(e)})
                print('ERROR',s['id'],str(e),flush=True)
    (ROOT/'mapas_fuentes.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2),encoding='utf-8')
    (ROOT/'mapas_errores.json').write_text(json.dumps(errors,ensure_ascii=False,indent=2),encoding='utf-8')
    print(f'Mapas: {len(metadata)}/{len(SPECIES)}; errores: {len(errors)}',flush=True)
    raise SystemExit(bool(errors))
