import { useEffect, useRef, useState } from 'react';
import L from 'leaflet';
import { subscribe } from '../graphql/client';
import { JOURNEY_ROUTE, JourneyRouteData, GeoPoint } from '../graphql/subscriptions';
import { SpeedChart } from './SpeedChart';
import { ElevationProfile } from './ElevationProfile';
import { JourneySummary } from './JourneySummary';
import { ExportMenu } from './ExportMenu';
import { ShareButton } from './ShareButton';

interface JourneyDetailProps {
  journeyId: string;
  label: string;
  distance: number;
  startedAt: string;
  endedAt: string | null;
  deviceId?: string;
  onClose: () => void;
  onReplay?: () => void;
}

function parseGeog(geog: GeoPoint): [number, number] {
  const [lng, lat] = geog.coordinates;
  return [lat, lng];
}

export function JourneyDetail({ journeyId, label, distance, startedAt, endedAt, deviceId, onClose, onReplay }: JourneyDetailProps) {
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstance = useRef<L.Map | null>(null);
  const markersRef = useRef<L.Marker[]>([]);
  const polylineRef = useRef<L.Polyline | null>(null);
  const [points, setPoints] = useState<[number, number][]>([]);
  const [maxSpeed, setMaxSpeed] = useState(0);
  const [avgSpeed, setAvgSpeed] = useState(0);
  const [elevationGain, setElevationGain] = useState(0);
  const [speedData, setSpeedData] = useState<Array<{ time: string; speed: number }>>([]);
  const [elevationData, setElevationData] = useState<Array<{ time: string; altitude: number }>>([]);
  const [mapReady, setMapReady] = useState(false);

  // Subscribe to route points
  useEffect(() => {
    setPoints([]);
    setMaxSpeed(0);
    setAvgSpeed(0);
    setElevationGain(0);
    setSpeedData([]);
    setElevationData([]);

    const unsub = subscribe<JourneyRouteData>(
      JOURNEY_ROUTE,
      { journeyId },
      (data) => {
        const pts = data.location_points.map((pt) => parseGeog(pt.geog));
        setPoints(pts);

        let totalSpeed = 0;
        let speedCount = 0;
        let max = 0;
        let elevGain = 0;
        let prevAlt: number | null = null;
        const spdData: Array<{ time: string; speed: number }> = [];
        const elevData: Array<{ time: string; altitude: number }> = [];

        for (const pt of data.location_points) {
          const time = new Date(pt.recorded_at).toLocaleTimeString('en-US', {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false,
          });

          // Speed
          if (pt.speed && pt.speed > 0) {
            totalSpeed += pt.speed;
            speedCount++;
            if (pt.speed > max) max = pt.speed;
          }
          spdData.push({ time, speed: pt.speed || 0 });

          // Elevation
          const alt = pt.altitude || 0;
          elevData.push({ time, altitude: alt });
          if (prevAlt !== null && alt > prevAlt) {
            elevGain += alt - prevAlt;
          }
          prevAlt = alt;
        }

        setMaxSpeed(max);
        setAvgSpeed(speedCount > 0 ? totalSpeed / speedCount : 0);
        setElevationGain(elevGain);
        setSpeedData(spdData);
        setElevationData(elevData);
      },
    );
    return unsub;
  }, [journeyId]);

  // Initialize map
  useEffect(() => {
    if (!mapRef.current) return;

    const map = L.map(mapRef.current, {
      zoomControl: true,
      attributionControl: true,
    }).setView([28.6139, 77.209], 13);

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap',
      maxZoom: 19,
    }).addTo(map);

    mapInstance.current = map;
    setMapReady(true);

    return () => {
      map.remove();
      mapInstance.current = null;
      markersRef.current = [];
      polylineRef.current = null;
    };
  }, []);

  // Draw route when points arrive
  useEffect(() => {
    const map = mapInstance.current;
    if (!map || !mapReady || points.length === 0) return;

    if (polylineRef.current) {
      map.removeLayer(polylineRef.current);
      polylineRef.current = null;
    }
    for (const m of markersRef.current) {
      map.removeLayer(m);
    }
    markersRef.current = [];

    if (points.length > 1) {
      polylineRef.current = L.polyline(points, {
        color: '#faff69',
        weight: 4,
        opacity: 0.9,
      }).addTo(map);
    }

    // Start marker
    const startMarker = L.marker(points[0], {
      icon: L.divIcon({
        className: 'marker-start',
        html: '<div style="width:14px;height:14px;background:#22c55e;border:3px solid #0a0a0a;border-radius:50%"></div>',
        iconSize: [20, 20],
        iconAnchor: [10, 10],
      }),
    }).addTo(map);
    markersRef.current.push(startMarker);

    // End marker
    if (points.length > 1) {
      const endMarker = L.marker(points[points.length - 1], {
        icon: L.divIcon({
          className: 'marker-end',
          html: '<div style="width:14px;height:14px;background:#ef4444;border:3px solid #0a0a0a;border-radius:50%"></div>',
          iconSize: [20, 20],
          iconAnchor: [10, 10],
        }),
      }).addTo(map);
      markersRef.current.push(endMarker);
    }

    requestAnimationFrame(() => {
      if (!mapInstance.current) return;
      if (points.length > 1) {
        const bounds = L.latLngBounds(points);
        map.fitBounds(bounds, { padding: [48, 48], maxZoom: 16 });
      } else {
        map.setView(points[0], 16);
      }
    });
  }, [points, mapReady]);

  // Calculate duration in seconds
  const durationSec = (() => {
    const start = new Date(startedAt).getTime();
    const end = endedAt ? new Date(endedAt).getTime() : Date.now();
    return (end - start) / 1000;
  })();

  return (
    <div className="journey-detail">
      <div className="journey-detail-header">
        <button className="btn-small" onClick={onClose}>&larr; Back</button>
        <h2>{label}</h2>
        <div className="journey-detail-actions">
          {onReplay && (
            <button className="btn-small" onClick={onReplay}>▶ Replay</button>
          )}
          <ExportMenu journeyId={journeyId} />
          {deviceId && <ShareButton journeyId={journeyId} deviceId={deviceId} />}
        </div>
      </div>

      {/* Summary cards */}
      <JourneySummary
        distance={distance}
        duration={durationSec}
        avgSpeed={avgSpeed}
        maxSpeed={maxSpeed}
        elevationGain={elevationGain}
        pointCount={points.length}
      />

      {/* Map */}
      <div className="journey-detail-map">
        <div ref={mapRef} style={{ width: '100%', height: '100%' }} />
      </div>

      {/* Charts */}
      <div className="journey-detail-charts">
        <SpeedChart data={speedData} />
        <ElevationProfile data={elevationData} />
      </div>
    </div>
  );
}
