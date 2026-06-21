import { useEffect, useRef, useState } from 'react';
import L from 'leaflet';
import { useAuth } from 'react-oidc-context';
import { subscribe } from '../graphql/client';
import { GeoPoint } from '../graphql/subscriptions';

interface Device {
  id: string;
  name: string;
  platform: string;
  last_seen: number;
  active: boolean;
}

interface LivePoint {
  journey_id: string;
  device_id: string;
  geog: GeoPoint;
  speed: number | null;
  recorded_at: string;
}

const DEVICE_COLORS = ['#faff69', '#22c55e', '#3b82f6', '#ef4444', '#f59e0b', '#8b5cf6', '#ec4899'];

function parseGeog(geog: GeoPoint): [number, number] {
  const [lng, lat] = geog.coordinates;
  return [lat, lng];
}

export function MultiDeviceMap() {
  const auth = useAuth();
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstance = useRef<L.Map | null>(null);
  const markersRef = useRef<Map<string, L.Marker>>(new Map());
  const [devices, setDevices] = useState<Device[]>([]);
  const [latestPositions, setLatestPositions] = useState<Map<string, LivePoint>>(new Map());
  const [mapReady, setMapReady] = useState(false);

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
    setMapReady(true);
    return () => { map.remove(); mapInstance.current = null; };
  }, []);

  // Subscribe to devices
  useEffect(() => {
    if (!auth.isAuthenticated) return;
    const unsub = subscribe<{ devices: Device[] }>(
      `subscription { devices(order_by: {last_seen: desc}) { id name platform last_seen active } }`,
      {},
      (data) => setDevices(data.devices),
    );
    return unsub;
  }, [auth.isAuthenticated]);

  // Subscribe to latest locations
  useEffect(() => {
    if (!auth.isAuthenticated) return;

    const unsub = subscribe<{ location_points: Array<{ journey_id: string; device_id: string; geog: GeoPoint; speed: number | null; recorded_at: string }> }>(
      `subscription {
        location_points(
          order_by: { recorded_at: desc }
          limit: 100
        ) {
          journey_id
          device_id
          geog
          speed
          recorded_at
        }
      }`,
      {},
      (data) => {
        const newPositions = new Map<string, LivePoint>();
        for (const pt of data.location_points) {
          // Keep latest per device (first one wins since sorted by recorded_at desc)
          if (!newPositions.has(pt.device_id)) {
            newPositions.set(pt.device_id, pt);
          }
        }
        setLatestPositions(newPositions);
      },
    );
    return unsub;
  }, [auth.isAuthenticated]);

  // Update markers when positions change
  useEffect(() => {
    const map = mapInstance.current;
    if (!map || !mapReady) return;

    const currentIds = new Set(latestPositions.keys());

    // Remove stale markers
    for (const [id, marker] of markersRef.current) {
      if (!currentIds.has(id)) {
        map.removeLayer(marker);
        markersRef.current.delete(id);
      }
    }

    // Update or create markers
    let i = 0;
    for (const [deviceId, point] of latestPositions) {
      const pos = parseGeog(point.geog);
      const color = DEVICE_COLORS[i % DEVICE_COLORS.length];
      const device = devices.find((d) => d.id === deviceId);
      const name = device?.name || deviceId.slice(0, 8);

      const existing = markersRef.current.get(deviceId);
      if (existing) {
        existing.setLatLng(pos);
      } else {
        const icon = L.divIcon({
          className: 'device-marker',
          html: `<div style="
            width: 18px; height: 18px;
            background: ${color};
            border: 3px solid #0a0a0a;
            border-radius: 50%;
            box-shadow: 0 0 8px ${color}40;
          "></div>
          <div style="
            font-size: 11px; color: ${color}; font-weight: 600;
            text-align: center; margin-top: 2px; white-space: nowrap;
            text-shadow: 0 1px 2px #000;
          ">${name}</div>`,
          iconSize: [60, 30],
          iconAnchor: [30, 15],
        });
        const marker = L.marker(pos, { icon })
          .bindPopup(`<b>${name}</b><br>${point.speed ? (point.speed * 3.6).toFixed(1) + ' km/h' : 'Stationary'}`)
          .addTo(map);
        markersRef.current.set(deviceId, marker);
      }
      i++;
    }

    // Fit bounds if we have positions
    if (latestPositions.size > 0) {
      const allPos = Array.from(latestPositions.values()).map((p) => parseGeog(p.geog));
      if (allPos.length > 1) {
        map.fitBounds(L.latLngBounds(allPos), { padding: [60, 60], maxZoom: 15 });
      } else if (allPos.length === 1) {
        map.setView(allPos[0], 15);
      }
    }
  }, [latestPositions, devices, mapReady]);

  return (
    <div className="multi-device-map">
      <div ref={mapRef} style={{ width: '100%', height: '100%' }} />
      {/* Device legend */}
      {devices.length > 1 && (
        <div className="device-legend">
          {devices.map((d, i) => (
            <div key={d.id} className="device-legend-item">
              <span
                className="device-legend-dot"
                style={{ background: DEVICE_COLORS[i % DEVICE_COLORS.length] }}
              />
              <span>{d.name}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
