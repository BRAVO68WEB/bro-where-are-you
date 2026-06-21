import { useState } from 'react';
import { MultiDeviceMap } from '../components/MultiDeviceMap';
import { HeatmapView } from '../components/HeatmapView';

type MapView = 'live' | 'heatmap';

export function MapViewsPage() {
  const [view, setView] = useState<MapView>('live');

  return (
    <div className="map-views-page">
      <div className="map-views-tabs">
        <button
          className={`tab-btn ${view === 'live' ? 'active' : ''}`}
          onClick={() => setView('live')}
        >
          Live Devices
        </button>
        <button
          className={`tab-btn ${view === 'heatmap' ? 'active' : ''}`}
          onClick={() => setView('heatmap')}
        >
          Heatmap
        </button>
      </div>
      <div className="map-views-content">
        {view === 'live' ? <MultiDeviceMap /> : <HeatmapView />}
      </div>
    </div>
  );
}
