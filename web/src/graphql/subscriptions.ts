export const LIVE_LOCATION = `
  subscription LiveLocation($journeyId: uuid!) {
    location_points(
      where: { journey_id: { _eq: $journeyId } }
      order_by: { recorded_at: desc }
      limit: 1
    ) {
      geog
      speed
      accuracy
      heading
      recorded_at
    }
  }
`;

export const JOURNEY_ROUTE = `
  subscription JourneyRoute($journeyId: uuid!) {
    location_points(
      where: { journey_id: { _eq: $journeyId } }
      order_by: { recorded_at: asc }
    ) {
      geog
      speed
      altitude
      recorded_at
    }
  }
`;

export const JOURNEYS = `
  subscription Journeys {
    journeys(
      order_by: { started_at: desc }
    ) {
      id
      label
      started_at
      ended_at
      total_distance_m
      source
      device_id
      transport_mode
      start_place
      end_place
    }
  }
`;

export interface GeoPoint {
  type: 'Point';
  coordinates: [number, number]; // [lng, lat]
}

export interface LocationPointRow {
  geog: GeoPoint;
  speed: number | null;
  accuracy: number | null;
  heading: number | null;
  altitude: number | null;
  recorded_at: string;
}

export interface JourneyRow {
  id: string;
  label: string;
  started_at: string;
  ended_at: string | null;
  total_distance_m: number;
  source: string;
  device_id: string;
  transport_mode: string | null;
  start_place: string | null;
  end_place: string | null;
}

export interface LiveLocationData {
  location_points: LocationPointRow[];
}

export interface JourneyRouteData {
  location_points: LocationPointRow[];
}

export interface JourneysData {
  journeys: JourneyRow[];
}
