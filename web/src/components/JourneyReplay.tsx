import { useEffect, useRef, useState } from 'react';
import L from 'leaflet';
import { subscribe } from '../graphql/client';
import { JOURNEY_ROUTE, JourneyRouteData, GeoPoint } from '../graphql/subscriptions';

interface JourneyReplayProps {
  journeyId: string;
  onClose: () => void;
}

interface RoutePoint {
  lat: number;
  lng: number;
  speed: number;
  altitude: number;
  recordedAt: string;
}

function parseGeog(geog: GeoPoint): [number, number] {
  const [lng, lat] = geog.coordinates;
  return [lat, lng];
}

export function JourneyReplay({ journeyId, onClose }: JourneyReplayProps) {
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstance = useRef<L.Map | null>(null);
  const polylineRef = useRef<L.Polyline | null>(null);
  const markerRef = useRef<L.Marker | null>(null);
  const [points, setPoints] = useState<RoutePoint[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isPlaying, setIsPlaying] = useState(false);
  const [mapReady, setMapReady] = useState(false);
  const playRef = useRef<ReturnType<typeof setInterval> | null>(null);

  // Subscribe to route
  useEffect(() => {
    const unsub = subscribe<JourneyRouteData>(
      JOURNEY_ROUTE,
      { journeyId },
      (data) => {
        const pts: RoutePoint[] = data.location_points.map((pt) => {
          const [lat, lng] = parseGeog(pt.geog);
          return {
            lat,
            lng,
            speed: pt.speed || 0,
            altitude: pt.altitude || 0,
            recordedAt: pt.recorded_at,
          };
        });
        setPoints(pts);
        setCurrentIndex(0);
      },
    );
    return unsub;
  }, [journeyId]);

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

  // Draw full route and current position
  useEffect(() => {
    const map = mapInstance.current;
    if (!map || !mapReady || points.length === 0) return;

    // Draw full route (dimmed)
    if (polylineRef.current) map.removeLayer(polylineRef.current);
    polylineRef.current = L.polyline(
      points.map((p) => [p.lat, p.lng]),
      { color: '#faff69', weight: 3, opacity: 0.3 },
    ).addTo(map);

    // Fit bounds on first load
    if (currentIndex === 0) {
      const bounds = L.latLngBounds(points.map((p) => [p.lat, p.lng]));
      map.fitBounds(bounds, { padding: [48, 48] });
    }
  }, [points, mapReady]);

  // Update marker and active segment
  useEffect(() => {
    const map = mapInstance.current;
    if (!map || points.length === 0 || currentIndex >= points.length) return;

    const pt = points[currentIndex];

    // Update marker
    if (markerRef.current) {
      markerRef.current.setLatLng([pt.lat, pt.lng]);
    } else {
      const icon = L.divIcon({
        className: 'replay-marker',
        html: `<div style="
          width: 20px; height: 20px;
          background: #faff69;
          border: 3px solid #0a0a0a;
          border-radius: 50%;
          box-shadow: 0 0 12px #faff69;
        "></div>`,
        iconSize: [26, 26],
        iconAnchor: [13, 13],
      });
      markerRef.current = L.marker([pt.lat, pt.lng], { icon }).addTo(map);
    }

    // Pan to current position
    map.panTo([pt.lat, pt.lng]);
  }, [currentIndex, points]);

  // Playback controls
  const play = () => {
    if (isPlaying) return;
    setIsPlaying(true);
    playRef.current = setInterval(() => {
      setCurrentIndex((prev) => {
        if (prev >= points.length - 1) {
          setIsPlaying(false);
          if (playRef.current) clearInterval(playRef.current);
          return prev;
        }
        return prev + 1;
      });
    }, 200); // 200ms per point
  };

  const pause = () => {
    setIsPlaying(false);
    if (playRef.current) clearInterval(playRef.current);
  };

  const seekTo = (index: number) => {
    setCurrentIndex(index);
    if (isPlaying) {
      if (playRef.current) clearInterval(playRef.current);
      playRef.current = setInterval(() => {
        setCurrentIndex((prev) => {
          if (prev >= points.length - 1) {
            setIsPlaying(false);
            if (playRef.current) clearInterval(playRef.current);
            return prev;
          }
          return prev + 1;
        });
      }, 200);
    }
  };

  useEffect(() => {
    return () => {
      if (playRef.current) clearInterval(playRef.current);
    };
  }, []);

  const current = points[currentIndex];
  const formatTime = (iso: string) => {
    const d = new Date(iso);
    return d.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false });
  };

  return (
    <div className="journey-replay">
      <div className="replay-header">
        <button className="btn-small" onClick={onClose}>&larr; Back</button>
        <h2>Journey Replay</h2>
        <span className="replay-count">{currentIndex + 1}/{points.length}</span>
      </div>

      <div className="replay-map">
        <div ref={mapRef} style={{ width: '100%', height: '100%' }} />
      </div>

      {/* Controls */}
      <div className="replay-controls">
        {current && (
          <div className="replay-stats">
            <span>{formatTime(current.recordedAt)}</span>
            <span>{(current.speed * 3.6).toFixed(1)} km/h</span>
            <span>{current.altitude.toFixed(0)}m</span>
          </div>
        )}

        <div className="replay-slider-container">
          <input
            type="range"
            className="replay-slider"
            min={0}
            max={Math.max(points.length - 1, 0)}
            value={currentIndex}
            onChange={(e) => seekTo(Number(e.target.value))}
          />
        </div>

        <div className="replay-buttons">
          <button
            className="btn-small"
            onClick={() => seekTo(0)}
            disabled={currentIndex === 0}
          >
            ⏮
          </button>
          <button
            className="btn-primary replay-play-btn"
            onClick={isPlaying ? pause : play}
            disabled={points.length === 0}
          >
            {isPlaying ? '⏸' : '▶'}
          </button>
          <button
            className="btn-small"
            onClick={() => seekTo(points.length - 1)}
            disabled={currentIndex >= points.length - 1}
          >
            ⏭
          </button>
        </div>
      </div>
    </div>
  );
}
