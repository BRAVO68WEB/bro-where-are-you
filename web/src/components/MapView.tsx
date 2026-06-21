import { useEffect, useRef, useState } from 'react';
import L from 'leaflet';

interface MapViewProps {
  currentPosition: [number, number] | null;
  routePoints: [number, number][];
}

const TILE_LAYERS = [
  {
    name: 'Standard',
    url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '&copy; OpenStreetMap',
    icon: '🗺️',
  },
  {
    name: 'Dark',
    url: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
    attribution: '&copy; CartoDB',
    subdomains: 'abcd',
    icon: '🌙',
  },
  {
    name: 'Satellite',
    url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution: '&copy; Esri',
    icon: '🛰️',
  },
  {
    name: 'Terrain',
    url: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
    attribution: '&copy; OpenTopoMap',
    subdomains: 'abc',
    icon: '⛰️',
  },
];

export function MapView({ currentPosition, routePoints }: MapViewProps) {
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstance = useRef<L.Map | null>(null);
  const markerRef = useRef<L.Marker | null>(null);
  const polylineRef = useRef<L.Polyline | null>(null);
  const tileLayerRef = useRef<L.TileLayer | null>(null);
  const [tileIndex, setTileIndex] = useState(0);

  // Initialize map
  useEffect(() => {
    if (!mapRef.current || mapInstance.current) return;

    const map = L.map(mapRef.current).setView([28.6139, 77.209], 13);

    const tile = TILE_LAYERS[0];
    const tl = L.tileLayer(tile.url, {
      attribution: tile.attribution,
      maxZoom: 19,
      subdomains: tile.subdomains ? tile.subdomains.split('') : [],
    }).addTo(map);

    mapInstance.current = map;
    tileLayerRef.current = tl;

    return () => {
      map.remove();
      mapInstance.current = null;
    };
  }, []);

  // Switch tile layer
  useEffect(() => {
    const map = mapInstance.current;
    if (!map || !tileLayerRef.current) return;

    map.removeLayer(tileLayerRef.current);

    const tile = TILE_LAYERS[tileIndex];
    const tl = L.tileLayer(tile.url, {
      attribution: tile.attribution,
      maxZoom: 19,
      subdomains: tile.subdomains ? tile.subdomains.split('') : [],
    }).addTo(map);

    tileLayerRef.current = tl;
  }, [tileIndex]);

  // Update marker position
  useEffect(() => {
    const map = mapInstance.current;
    if (!map || !currentPosition) return;

    const [lat, lng] = currentPosition;

    if (!markerRef.current) {
      const icon = L.divIcon({
        className: 'live-marker',
        html: `<div style="
          width: 16px; height: 16px;
          background: #faff69;
          border: 3px solid #0a0a0a;
          border-radius: 50%;
        "></div>`,
        iconSize: [22, 22],
        iconAnchor: [11, 11],
      });
      markerRef.current = L.marker([lat, lng], { icon }).addTo(map);
      map.setView([lat, lng], 16);
    } else {
      markerRef.current.setLatLng([lat, lng]);
      map.panTo([lat, lng]);
    }
  }, [currentPosition]);

  // Update polyline
  useEffect(() => {
    const map = mapInstance.current;
    if (!map) return;

    if (polylineRef.current) {
      map.removeLayer(polylineRef.current);
      polylineRef.current = null;
    }

    if (routePoints.length > 1) {
      polylineRef.current = L.polyline(routePoints, {
        color: '#faff69',
        weight: 4,
        opacity: 0.8,
      }).addTo(map);

      const bounds = L.latLngBounds(routePoints);
      map.fitBounds(bounds, { padding: [48, 48], maxZoom: 16 });
    }
  }, [routePoints]);

  const cycleTile = () => {
    setTileIndex((prev) => (prev + 1) % TILE_LAYERS.length);
  };

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      <div ref={mapRef} style={{ width: '100%', height: '100%' }} />
      <button
        className="btn-small"
        onClick={cycleTile}
        title={`Switch to ${TILE_LAYERS[(tileIndex + 1) % TILE_LAYERS.length].name}`}
        style={{
          position: 'absolute',
          bottom: 80,
          left: 16,
          zIndex: 1000,
          fontSize: '18px',
          padding: '8px 12px',
        }}
      >
        {TILE_LAYERS[tileIndex].icon}
      </button>
    </div>
  );
}
