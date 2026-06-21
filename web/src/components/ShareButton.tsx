import { useState } from 'react';

interface ShareButtonProps {
  journeyId: string;
  deviceId: string;
}

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:8088';

export function ShareButton({ journeyId, deviceId }: ShareButtonProps) {
  const [shareUrl, setShareUrl] = useState<string | null>(null);
  const [creating, setCreating] = useState(false);
  const [copied, setCopied] = useState(false);

  const handleShare = async () => {
    setCreating(true);
    try {
      const resp = await fetch(`${API_BASE}/api/share`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          journey_id: journeyId,
          device_id: deviceId,
          duration_hours: 0, // no expiry
        }),
      });

      if (!resp.ok) throw new Error('Failed to create share link');
      const data = await resp.json();
      const url = `${window.location.origin}/share/${data.id}`;
      setShareUrl(url);
    } catch (e) {
      console.error('Share failed:', e);
    } finally {
      setCreating(false);
    }
  };

  const handleCopy = async () => {
    if (!shareUrl) return;
    try {
      await navigator.clipboard.writeText(shareUrl);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (e) {
      console.error('Copy failed:', e);
    }
  };

  if (shareUrl) {
    return (
      <div className="share-result">
        <input
          type="text"
          className="text-input"
          value={shareUrl}
          readOnly
          onClick={(e) => (e.target as HTMLInputElement).select()}
        />
        <button className="btn-small" onClick={handleCopy}>
          {copied ? 'Copied!' : 'Copy'}
        </button>
      </div>
    );
  }

  return (
    <button
      className="btn-small"
      onClick={handleShare}
      disabled={creating}
    >
      {creating ? '...' : 'Share'}
    </button>
  );
}
