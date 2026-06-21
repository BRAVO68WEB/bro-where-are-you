import { useEffect } from 'react';
import { useAuth } from 'react-oidc-context';

export function CallbackPage() {
  const auth = useAuth();

  useEffect(() => {
    // react-oidc-context processes the callback automatically
    // This component just shows a spinner while processing
    if (auth.isAuthenticated) {
      window.location.href = '/';
    }
  }, [auth.isAuthenticated]);

  if (auth.error) {
    return (
      <div className="loading-screen">
        <div style={{ textAlign: 'center' }}>
          <h2 style={{ color: 'var(--color-error)', marginBottom: '16px' }}>Authentication Failed</h2>
          <p style={{ color: 'var(--color-muted)' }}>{auth.error.message}</p>
          <button
            className="btn-primary"
            style={{ marginTop: '24px' }}
            onClick={() => auth.signinRedirect()}
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="loading-screen">
      <div className="spinner" />
    </div>
  );
}
