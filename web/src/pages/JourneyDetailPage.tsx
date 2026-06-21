import { useParams, useNavigate } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { useAuth } from 'react-oidc-context';
import { subscribe } from '../graphql/client';
import { JourneyDetail } from '../components/JourneyDetail';
import { JourneyReplay } from '../components/JourneyReplay';
import { JOURNEYS, JourneysData } from '../graphql/subscriptions';

export function JourneyDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const auth = useAuth();
  const [journey, setJourney] = useState<JourneysData['journeys'][0] | null>(null);
  const [replayMode, setReplayMode] = useState(false);

  useEffect(() => {
    if (!auth.isAuthenticated || !id) return;

    const unsub = subscribe<JourneysData>(
      JOURNEYS,
      {},
      (data) => {
        const found = data.journeys.find((j) => j.id === id);
        if (found) setJourney(found);
      },
    );
    return unsub;
  }, [auth.isAuthenticated, id]);

  if (!id) {
    navigate('/');
    return null;
  }

  if (replayMode) {
    return (
      <JourneyReplay
        journeyId={id}
        onClose={() => setReplayMode(false)}
      />
    );
  }

  return (
    <JourneyDetail
      journeyId={id}
      label={journey?.label || 'Journey'}
      distance={journey?.total_distance_m || 0}
      startedAt={journey?.started_at || ''}
      endedAt={journey?.ended_at || null}
      deviceId={journey?.device_id}
      onClose={() => navigate('/')}
      onReplay={() => setReplayMode(true)}
    />
  );
}
