import { useEffect, useState } from 'react';
import { useAuth } from 'react-oidc-context';
import { subscribe } from '../graphql/client';
import { JOURNEYS, JourneysData } from '../graphql/subscriptions';
import { Link } from 'react-router-dom';

export function JourneysPage() {
  const auth = useAuth();
  const [journeys, setJourneys] = useState<JourneysData['journeys']>([]);

  useEffect(() => {
    if (!auth.isAuthenticated) return;

    const unsub = subscribe<JourneysData>(
      JOURNEYS,
      {},
      (data) => setJourneys(data.journeys),
    );
    return unsub;
  }, [auth.isAuthenticated]);

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

  return (
    <div className="page-content">
      <div className="page-header">
        <h1>Journeys</h1>
      </div>
      {journeys.length === 0 ? (
        <div className="empty-state">
          <p>No journeys yet</p>
        </div>
      ) : (
        <div className="journey-cards">
          {journeys.map((j) => (
            <Link
              key={j.id}
              to={`/journey/${j.id}`}
              className="journey-card"
            >
              <div className="journey-card-header">
                <h3>{j.label || 'Untitled Journey'}</h3>
                {!j.ended_at && <span className="badge-yellow">LIVE</span>}
              </div>
              <div className="journey-card-meta">
                {formatDate(j.started_at)} · {formatDistance(j.total_distance_m)}
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
