interface JourneySummaryProps {
  distance: number;
  duration: number; // seconds
  avgSpeed: number; // m/s
  maxSpeed: number; // m/s
  elevationGain: number; // meters
  pointCount: number;
}

export function JourneySummary({
  distance,
  duration,
  avgSpeed,
  maxSpeed,
  elevationGain,
  pointCount,
}: JourneySummaryProps) {
  const formatDist = (m: number) => m >= 1000 ? `${(m / 1000).toFixed(2)} km` : `${Math.round(m)} m`;
  const formatSpeed = (mps: number) => `${(mps * 3.6).toFixed(1)} km/h`;
  const formatDur = (s: number) => {
    const h = Math.floor(s / 3600);
    const m = Math.floor((s % 3600) / 60);
    const sec = Math.floor(s % 60);
    if (h > 0) return `${h}h ${m}m ${sec}s`;
    if (m > 0) return `${m}m ${sec}s`;
    return `${sec}s`;
  };

  return (
    <div className="journey-summary">
      <div className="summary-grid">
        <div className="summary-item">
          <span className="summary-value">{formatDist(distance)}</span>
          <span className="summary-label">Distance</span>
        </div>
        <div className="summary-item">
          <span className="summary-value">{formatDur(duration)}</span>
          <span className="summary-label">Duration</span>
        </div>
        <div className="summary-item">
          <span className="summary-value">{formatSpeed(avgSpeed)}</span>
          <span className="summary-label">Avg Speed</span>
        </div>
        <div className="summary-item">
          <span className="summary-value">{formatSpeed(maxSpeed)}</span>
          <span className="summary-label">Max Speed</span>
        </div>
        <div className="summary-item">
          <span className="summary-value">{Math.round(elevationGain)} m</span>
          <span className="summary-label">Elevation +</span>
        </div>
        <div className="summary-item">
          <span className="summary-value">{pointCount}</span>
          <span className="summary-label">Points</span>
        </div>
      </div>
    </div>
  );
}
