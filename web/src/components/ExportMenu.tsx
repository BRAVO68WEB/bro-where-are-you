import { useState } from 'react';

interface ExportMenuProps {
  journeyId: string;
  serverUrl?: string;
}

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:8088';

export function ExportMenu({ journeyId }: ExportMenuProps) {
  const [exporting, setExporting] = useState<string | null>(null);

  const handleExport = async (format: 'gpx' | 'geojson' | 'csv') => {
    setExporting(format);
    try {
      const url = `${API_BASE}/api/export?journey_id=${journeyId}&format=${format}`;
      const resp = await fetch(url);
      if (!resp.ok) throw new Error(`Export failed: ${resp.status}`);

      const blob = await resp.blob();
      const disposition = resp.headers.get('Content-Disposition');
      const filename = disposition?.split('filename=')[1] || `journey.${format}`;

      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = filename;
      a.click();
      URL.revokeObjectURL(a.href);
    } catch (e) {
      console.error('Export failed:', e);
    } finally {
      setExporting(null);
    }
  };

  return (
    <div className="export-menu">
      <button
        className="btn-small"
        onClick={() => handleExport('gpx')}
        disabled={exporting !== null}
      >
        {exporting === 'gpx' ? '...' : 'GPX'}
      </button>
      <button
        className="btn-small"
        onClick={() => handleExport('geojson')}
        disabled={exporting !== null}
      >
        {exporting === 'geojson' ? '...' : 'GeoJSON'}
      </button>
      <button
        className="btn-small"
        onClick={() => handleExport('csv')}
        disabled={exporting !== null}
      >
        {exporting === 'csv' ? '...' : 'CSV'}
      </button>
    </div>
  );
}
