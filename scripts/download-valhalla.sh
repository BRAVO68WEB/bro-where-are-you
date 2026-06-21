#!/bin/sh
set -e

if [ "${LOAD_VALHALLA}" != "true" ]; then
    echo "[valhalla-downloader] LOAD_VALHALLA is not true, skipping download."
    exit 0
fi

OSM_URL="${OSM_URL:-https://download.geofabrik.de/asia/india-latest.osm.pbf}"
DEST="/custom_files/planet.osm.pbf"

if [ -s "$DEST" ]; then
    echo "[valhalla-downloader] $DEST already exists ($(du -h "$DEST" | cut -f1)), skipping."
    exit 0
fi

echo "[valhalla-downloader] Downloading OSM data from $OSM_URL ..."
mkdir -p /custom_files
wget -c -O "$DEST" "$OSM_URL"
echo "[valhalla-downloader] Download complete: $(du -h "$DEST" | cut -f1)"
