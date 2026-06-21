import { useEffect, useRef, useState } from 'react';
import L from 'leaflet';
import { useAuth } from 'react-oidc-context';
import { subscribe } from '../graphql/client';

interface SavedLocation {
  id: string;
  device_id: string;
  name: string;
  latitude: number;
  longitude: number;
  radius_m: number;
  created_at: string;
}

export function PlacesPage() {
  const auth = useAuth();
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstance = useRef<L.Map | null>(null);
  const markersRef = useRef<L.Marker[]>([]);
  const [locations, setLocations] = useState<SavedLocation[]>([]);

  // Subscribe to saved locations
  useEffect(() => {
    if (!auth.isAuthenticated) return;

    const unsub = subscribe<{ saved_locations_view: SavedLocation[] }>(
      `subscription { saved_locations_view(order_by: {created_at: desc}) { id device_id name latitude longitude radius_m created_at } }`,
      {},
      (data) => {
        setLocations(data.saved_locations_view);
      },
    );
    return unsub;
  }, [auth.isAuthenticated]);

  // Initialize map
  useEffect(() => {
    if (!mapRef.current || mapInstance.current) return;

    const map = L.map(mapRef.current).setView([28.6139, 77.209], 13);
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap',
      maxZoom: 19,
    }).addTo(map);

    mapInstance.current = map;
    return () => { map.remove(); mapInstance.current = null; };
  }, []);

  // Update markers when locations change
  useEffect(() => {
    const map = mapInstance.current;
    if (!map) return;

    // Clear old markers
    for (const m of markersRef.current) {
      map.removeLayer(m);
    }
    markersRef.current = [];

    const iconMap: Record<string, string> = {
      home: '🏠',
      work: '💼',
      gym: '🏋️',
      school: '🎓',
    };

    for (const loc of locations) {
      const lower = loc.name.toLowerCase();
      let emoji = '📍';
      for (const [key, val] of Object.entries(iconMap)) {
        if (lower.includes(key)) { emoji = val; break; }
      }

      const icon = L.divIcon({
        className: 'place-marker',
        html: `<div style="font-size:24px;text-align:center">${emoji}</div><div style="font-size:11px;text-align:center;color:#faff69;font-weight:600;margin-top:-4px">${loc.name}</div>`,
        iconSize: [60, 40],
        iconAnchor: [30, 40],
      });

      const marker = L.marker([loc.latitude, loc.longitude], { icon })
        .bindPopup(`<b>${loc.name}</b><br>${loc.latitude.toFixed(5)}, ${loc.longitude.toFixed(5)}<br>Radius: ${loc.radius_m}m`)
        .addTo(map);
      markersRef.current.push(marker);

      // Draw geofence circle
      L.circle([loc.latitude, loc.longitude], {
        radius: loc.radius_m,
        color: '#faff69',
        fillColor: '#faff69',
        fillOpacity: 0.08,
        weight: 1,
      }).addTo(map);
    }

    // Fit bounds if we have locations
    if (locations.length > 0) {
      const bounds = L.latLngBounds(locations.map((l) => [l.latitude, l.longitude]));
      map.fitBounds(bounds, { padding: [48, 48] });
    }
  }, [locations]);

  const getIcon = (name: string) => {
    const lower = name.toLowerCase();
    if (lower.includes('home')) return '🏠';
    if (lower.includes('work') || lower.includes('office')) return '💼';
    if (lower.includes('gym')) return '🏋️';
    if (lower.includes('school') || lower.includes('uni')) return '🎓';
    return '📍';
  };

  return (
    <div className="places-page">
      <div className="places-sidebar">
        <div className="page-header">
          <h1>Places</h1>
        </div>
        {locations.length === 0 ? (
          <div className="empty-state">
            <p>No saved locations</p>
            <p style={{ color: 'var(--color-muted)', marginTop: '8px', fontSize: '13px' }}>
              Add places from the mobile app.
            </p>
          </div>
        ) : (
          <div className="places-list">
            {locations.map((loc) => (
              <div key={loc.id} className="place-item">
                <span className="place-icon">{getIcon(loc.name)}</span>
                <div className="place-info">
                  <h3>{loc.name}</h3>
                  <div className="place-meta">
                    {loc.latitude.toFixed(5)}, {loc.longitude.toFixed(5)} · {loc.radius_m}m
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
      <div className="places-map">
        <div ref={mapRef} style={{ width: '100%', height: '100%' }} />
      </div>
    </div>
  );
}
