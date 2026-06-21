import { JourneyRow } from '../graphql/subscriptions';

interface JourneySidebarProps {
  journeys: JourneyRow[];
  activeJourneyId: string | null;
  onSelect: (journeyId: string) => void;
}

const TRANSPORT_ICONS: Record<string, string> = {
  walking: '🚶',
  cycling: '🚴',
  driving: '🚗',
  highway: '🛣️',
};

export function JourneySidebar({ journeys, activeJourneyId, onSelect }: JourneySidebarProps) {
  const formatDate = (iso: string) => {
    const d = new Date(iso);
    return d.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const formatDistance = (meters: number) => {
    if (meters >= 1000) return `${(meters / 1000).toFixed(1)} km`;
    return `${Math.round(meters)} m`;
  };

  const formatRoute = (j: JourneyRow) => {
    if (j.start_place && j.end_place) {
      return `${j.start_place} → ${j.end_place}`;
    }
    if (j.start_place) return `From ${j.start_place}`;
    return '';
  };

  return (
    <div className="sidebar">
      <div className="sidebar-header">Journeys</div>
      {journeys.length === 0 ? (
        <div className="journey-empty">No journeys yet</div>
      ) : (
        <ul className="journey-list">
          {journeys.map((j) => {
            const icon = j.transport_mode ? TRANSPORT_ICONS[j.transport_mode] || '📍' : '📍';
            const route = formatRoute(j);
            return (
              <li
                key={j.id}
                className={`journey-item ${j.id === activeJourneyId ? 'active' : ''}`}
                onClick={() => onSelect(j.id)}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <span style={{ fontSize: 16 }}>{icon}</span>
                  <div style={{ flex: 1 }}>
                    <h3>{j.label || 'Untitled Journey'}</h3>
                    {route && (
                      <div style={{ fontSize: 12, color: 'var(--color-primary)', marginBottom: 2 }}>
                        {route}
                      </div>
                    )}
                    <div className="meta">
                      {formatDate(j.started_at)} · {formatDistance(j.total_distance_m)}
                      {!j.ended_at && (
                        <span className="badge-live">Live</span>
                      )}
                    </div>
                  </div>
                </div>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
