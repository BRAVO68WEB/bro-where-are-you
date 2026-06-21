import { useState } from 'react';

interface DeviceActivationProps {
  serverUrl: string;
  userId: string;
  onActivated: () => void;
}

export function DeviceActivation({ serverUrl, userId, onActivated }: DeviceActivationProps) {
  const [code, setCode] = useState('');
  const [status, setStatus] = useState<'idle' | 'activating' | 'success' | 'error'>('idle');
  const [message, setMessage] = useState('');

  const handleActivate = async () => {
    if (code.length !== 5) {
      setMessage('Enter a 5-character code');
      setStatus('error');
      return;
    }

    setStatus('activating');
    setMessage('');

    try {
      const url = serverUrl.replace(/\/$/, '') + '/auth/activate';
      const resp = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          device_code: code.toUpperCase(),
          user_id: userId,
        }),
      });

      if (!resp.ok) {
        const text = await resp.text();
        throw new Error(text || `HTTP ${resp.status}`);
      }

      const data = await resp.json();
      setStatus('success');
      setMessage(`Device "${data.DeviceName}" paired successfully!`);

      const devices = JSON.parse(localStorage.getItem('paired_devices') || '[]');
      devices.push({
        id: data.DeviceID,
        name: data.DeviceName,
        token: data.DeviceToken,
        paired_at: new Date().toISOString(),
      });
      localStorage.setItem('paired_devices', JSON.stringify(devices));

      setTimeout(onActivated, 1500);
    } catch (e) {
      setStatus('error');
      setMessage(e instanceof Error ? e.message : 'Activation failed');
    }
  };

  return (
    <div className="activation-panel">
      <h2>Pair a Device</h2>
      <p className="activation-hint">
        Enter the 5-character code shown on your phone or watch.
      </p>

      <div className="activation-input-group">
        <input
          type="text"
          className="activation-code-input"
          placeholder="XXXXX"
          maxLength={5}
          value={code}
          onChange={(e) => setCode(e.target.value.toUpperCase())}
          onKeyDown={(e) => e.key === 'Enter' && handleActivate()}
          disabled={status === 'activating'}
          autoFocus
        />
        <button
          className="btn-primary"
          onClick={handleActivate}
          disabled={status === 'activating' || code.length !== 5}
        >
          {status === 'activating' ? '...' : 'Pair'}
        </button>
      </div>

      {message && (
        <div className={`activation-message ${status}`}>
          {status === 'success' && <span className="check-icon">&#10003;</span>}
          {status === 'error' && <span className="error-icon">&#10007;</span>}
          {message}
        </div>
      )}
    </div>
  );
}
