import { useEffect, useRef, useState } from 'react';
import L from 'leaflet';
import 'leaflet.heat';
import { useAuth } from 'react-oidc-context';
import { subscribe } from '../graphql/client';
import { GeoPoint } from '../graphql/subscriptions';

function parseGeog(geog: GeoPoint): [number, number] {
  const [lng, lat] = geog.coordinates;
  return [lat, lng];
}

export function HeatmapView() {
  const auth = useAuth();
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstance = useRef<L.Map | null>(null);
  const heatRef = useRef<L.Layer | null>(null);
  const [points, setPoints] = useState<[number, number][]>([]);

  // Initialize map
  useEffect(() => {
    if (!mapRef.current) return;
    const map = L.map(mapRef.current).setView([28.6139, 77.209], 13);
    L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
      attribution: '&copy; CartoDB',
      subdomains: 'abcd',
      maxZoom: 19,
    }).addTo(map);
    mapInstance.current = map;
    return () => { map.remove(); mapInstance.current = null; };
  }, []);

  // Subscribe to all location points
  useEffect(() => {
    if (!auth.isAuthenticated) return;

    const unsub = subscribe<{ location_points: Array<{ geog: GeoPoint }> }>(
      `subscription { location_points(limit: 5000, order_by: {recorded_at: desc}) { geog } }`,
      {},
      (data) => {
        const pts = data.location_points.map((p) => parseGeog(p.geog));
        setPoints(pts);
      },
    );
    return unsub;
  }, [auth.isAuthenticated]);

  // Update heatmap layer
  useEffect(() => {
    const map = mapInstance.current;
    if (!map || points.length === 0) return;

    // Remove old layer
    if (heatRef.current) {
      map.removeLayer(heatRef.current);
    }

    // Create heat layer
    const heatData: L.HeatLatLngTuple[] = points.map(([lat, lng]) => [lat, lng, 0.5] as L.HeatLatLngTuple);

    const heat = (L as unknown as { heatLayer: (data: L.HeatLatLngTuple[], options: Record<string, unknown>) => L.Layer })
      .heatLayer(heatData, {
      radius: 20,
      blur: 15,
      maxZoom: 17,
      max: 1.0,
      gradient: {
        0.2: '#0a0a0a',
        0.4: '#1a1a2e',
        0.6: '#faff69',
        0.8: '#f59e0b',
        1.0: '#ef4444',
      },
    }).addTo(map);

    heatRef.current = heat;

    // Fit bounds
    const bounds = L.latLngBounds(points);
    map.fitBounds(bounds, { padding: [48, 48] });
  }, [points]);

  return (
    <div className="heatmap-view">
      <div className="heatmap-header">
        <span className="heatmap-count">{points.length.toLocaleString()} points</span>
      </div>
      <div ref={mapRef} style={{ width: '100%', height: '100%' }} />
    </div>
  );
}
