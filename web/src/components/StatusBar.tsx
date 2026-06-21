interface StatusBarProps {
  connected: boolean;
  speed: number | null;
  pointCount: number;
}

export function StatusBar({ connected, speed, pointCount }: StatusBarProps) {
  const speedKmh = speed != null ? (speed * 3.6).toFixed(1) : '0.0';

  return (
    <div className="status-bar">
      <span>
        <span className={`dot ${connected ? 'connected' : 'disconnected'}`} />
        {connected ? 'Live' : 'Disconnected'}
      </span>
      <span>{speedKmh} km/h</span>
      <span>{pointCount} pts</span>
    </div>
  );
}
