import { useState, useEffect } from 'react';

export function IOSInstallPrompt() {
  const [show, setShow] = useState(false);

  useEffect(() => {
    const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
    const isStandalone = window.matchMedia('(display-mode: standalone)').matches;
    const dismissed = sessionStorage.getItem('ios-install-dismissed');

    if (isIOS && !isStandalone && !dismissed) {
      setShow(true);
    }
  }, []);

  if (!show) return null;

  return (
    <div className="ios-install-banner">
      <div className="ios-install-content">
        <span>For push notifications, tap</span>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" style={{ margin: '0 4px' }}>
          <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/>
          <polyline points="16 6 12 2 8 6"/>
          <line x1="12" y1="2" x2="12" y2="15"/>
        </svg>
        <span>then <strong>"Add to Home Screen"</strong></span>
      </div>
      <button
        className="ios-install-dismiss"
        onClick={() => {
          sessionStorage.setItem('ios-install-dismissed', '1');
          setShow(false);
        }}
      >
        ✕
      </button>
    </div>
  );
}
