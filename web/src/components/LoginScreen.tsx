import { useAuth } from 'react-oidc-context';

export function LoginScreen() {
  const auth = useAuth();

  const handleLogin = () => {
    auth.signinRedirect();
  };

  return (
    <div className="login-screen">
      <div className="login-card">
        <div className="login-header">
          <div className="login-icon">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#faff69" strokeWidth="2">
              <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
              <circle cx="12" cy="10" r="3"/>
            </svg>
          </div>
          <h1>Bro Where Are You</h1>
          <p>Commute &amp; Journey Tracker</p>
        </div>

        <div className="login-body">
          <button className="btn-primary btn-full" onClick={handleLogin}>
            Sign In
          </button>

          <div className="login-divider">
            <span>or</span>
          </div>

          <p className="login-hint">
            Connect your phone or watch by entering the device code shown on screen.
          </p>
        </div>
      </div>
    </div>
  );
}
