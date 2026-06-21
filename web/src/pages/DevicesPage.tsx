import { useState, useEffect } from 'react';
import { useAuth } from 'react-oidc-context';
import { DeviceActivation } from '../components/DeviceActivation';
import { subscribe } from '../graphql/client';

const SERVER_URL = import.meta.env.VITE_API_URL || 'http://localhost:8088';

interface Device {
  id: string;
  name: string;
  platform: string;
  last_seen: string;
  active: boolean;
}

export function DevicesPage() {
  const auth = useAuth();
  const [showPairing, setShowPairing] = useState(false);
  const [devices, setDevices] = useState<Device[]>([]);

  // Fetch devices via Hasura
  useEffect(() => {
    if (!auth.isAuthenticated) return;

    const unsub = subscribe<{ devices: Device[] }>(
      `subscription { devices(order_by: {last_seen: desc}) { id name platform last_seen active } }`,
      {},
      (data) => setDevices(data.devices),
    );
    return unsub;
  }, [auth.isAuthenticated]);

  if (showPairing) {
    return (
      <DeviceActivation
        serverUrl={SERVER_URL}
        userId={auth.user?.profile.sub ?? 'unknown'}
        onActivated={() => setShowPairing(false)}
      />
    );
  }

  return (
    <div className="page-content">
      <div className="page-header">
        <h1>Devices</h1>
        <button className="btn-primary" onClick={() => setShowPairing(true)}>
          + Pair Device
        </button>
      </div>
      {devices.length === 0 ? (
        <div className="empty-state">
          <p>No devices paired yet</p>
          <p style={{ color: 'var(--color-muted)', marginTop: '8px' }}>
            Pair your phone or watch to start tracking.
          </p>
        </div>
      ) : (
        <div className="device-list">
          {devices.map((d) => (
            <div key={d.id} className="device-card">
              <div className="device-icon">
                {d.platform === 'wearos' ? '⌚' : '📱'}
              </div>
              <div className="device-info">
                <h3>{d.name}</h3>
                <div className="device-meta">
                  {d.platform} · Last seen {new Date(d.last_seen).toLocaleString()}
                </div>
              </div>
              <div className={`device-status ${d.active ? 'active' : 'inactive'}`}>
                {d.active ? 'Active' : 'Inactive'}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
