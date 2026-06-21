import { useEffect, useState } from 'react';
import { useAuth } from 'react-oidc-context';
import { MapView } from '../components/MapView';
import { StatusBar } from '../components/StatusBar';
import { subscribe } from '../graphql/client';
import {
  LIVE_LOCATION,
  JOURNEY_ROUTE,
  LiveLocationData,
  JourneyRouteData,
  GeoPoint,
} from '../graphql/subscriptions';

function parseGeog(geog: GeoPoint): [number, number] {
  const [lng, lat] = geog.coordinates;
  return [lat, lng];
}

export function LiveMapPage() {
  const auth = useAuth();
  const [connected, setConnected] = useState(false);
  const [currentPosition, setCurrentPosition] = useState<[number, number] | null>(null);
  const [routePoints, setRoutePoints] = useState<[number, number][]>([]);
  const [speed, setSpeed] = useState<number | null>(null);
  const [pointCount, setPointCount] = useState(0);
  const [activeJourneyId, setActiveJourneyId] = useState<string | null>(null);

  // Find active journey on mount
  useEffect(() => {
    if (!auth.isAuthenticated) return;

    const unsub = subscribe<{ journeys: Array<{ id: string; ended_at: string | null }> }>(
      `subscription { journeys(order_by: {started_at: desc}, limit: 10) { id ended_at } }`,
      {},
      (data) => {
        const active = data.journeys.find((j) => !j.ended_at);
        if (active) setActiveJourneyId(active.id);
        else if (data.journeys.length > 0) setActiveJourneyId(data.journeys[0].id);
      },
    );
    return unsub;
  }, [auth.isAuthenticated]);

  // Subscribe to live location
  useEffect(() => {
    if (!activeJourneyId || !auth.isAuthenticated) return;

    const unsub = subscribe<LiveLocationData>(
      LIVE_LOCATION,
      { journeyId: activeJourneyId },
      (data) => {
        if (data.location_points.length > 0) {
          const pt = data.location_points[0];
          setCurrentPosition(parseGeog(pt.geog));
          setSpeed(pt.speed);
          setConnected(true);
        }
      },
      () => setConnected(false),
    );
    return unsub;
  }, [activeJourneyId, auth.isAuthenticated]);

  // Subscribe to route
  useEffect(() => {
    if (!activeJourneyId || !auth.isAuthenticated) return;

    const unsub = subscribe<JourneyRouteData>(
      JOURNEY_ROUTE,
      { journeyId: activeJourneyId },
      (data) => {
        const points = data.location_points.map((pt) => parseGeog(pt.geog));
        setRoutePoints(points);
        setPointCount(points.length);
      },
    );
    return unsub;
  }, [activeJourneyId, auth.isAuthenticated]);

  return (
    <>
      <StatusBar connected={connected} speed={speed} pointCount={pointCount} />
      <MapView currentPosition={currentPosition} routePoints={routePoints} />
    </>
  );
}
