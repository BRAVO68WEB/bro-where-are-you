import { useEffect } from 'react';
import { BrowserRouter, Routes, Route, NavLink, Navigate } from 'react-router-dom';
import { useAuth, AuthProvider } from 'react-oidc-context';
import { oidcConfig } from './auth/oidcConfig';
import { setTokenGetter, clearClient } from './graphql/client';
import { initOneSignal } from './lib/onesignal';
import { ThemeProvider } from './contexts/ThemeContext';
import { ThemeToggle } from './components/ThemeToggle';
import { LoginScreen } from './components/LoginScreen';
import { IOSInstallPrompt } from './components/IOSInstallPrompt';
import { LiveMapPage } from './pages/LiveMapPage';
import { JourneysPage } from './pages/JourneysPage';
import { JourneyDetailPage } from './pages/JourneyDetailPage';
import { DevicesPage } from './pages/DevicesPage';
import { PlacesPage } from './pages/PlacesPage';
import { MapViewsPage } from './pages/MapViewsPage';
import { StatsPage } from './pages/StatsPage';
import { CallbackPage } from './pages/CallbackPage';

function AppLayout() {
  const auth = useAuth();

  // Set token getter for GraphQL client
  useEffect(() => {
    setTokenGetter(() => auth.user?.id_token ?? null);
    return () => setTokenGetter(() => null);
  }, [auth.user]);

  // Init OneSignal immediately (shows notification prompt)
  useEffect(() => {
    initOneSignal();
  }, []);

  // Link OneSignal to device_id after auth (matches webhook targeting)
  useEffect(() => {
    if (auth.isAuthenticated) {
      const devices = JSON.parse(localStorage.getItem('paired_devices') || '[]');
      if (devices.length > 0) {
        // Use the most recently paired device_id as OneSignal external_id
        const deviceId = devices[devices.length - 1].id;
        initOneSignal(deviceId);
      }
    }
  }, [auth.isAuthenticated]);

  // Loading (also handles OIDC callback processing)
  if (auth.isLoading) {
    return (
      <div className="loading-screen">
        <div className="spinner" />
      </div>
    );
  }

  // Error
  if (auth.error) {
    return (
      <div className="loading-screen">
        <div style={{ textAlign: 'center' }}>
          <h2 style={{ color: 'var(--color-error)', marginBottom: '16px' }}>Authentication Error</h2>
          <p style={{ color: 'var(--color-muted)' }}>{auth.error.message}</p>
          <button className="btn-primary" style={{ marginTop: '24px' }} onClick={() => auth.signinRedirect()}>
            Retry
          </button>
        </div>
      </div>
    );
  }

  // Not authenticated
  if (!auth.isAuthenticated) {
    return <LoginScreen />;
  }

  const handleLogout = () => {
    clearClient();
    auth.signoutRedirect();
  };

  return (
    <div className="app-shell">
      <IOSInstallPrompt />
      {/* Top Nav */}
      <nav className="top-nav">
        <div className="nav-brand">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#faff69" strokeWidth="2">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
            <circle cx="12" cy="10" r="3"/>
          </svg>
          <span>Bro Where Are You</span>
        </div>
        <div className="nav-links">
          <NavLink to="/" end className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
            Live
          </NavLink>
          <NavLink to="/map" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
            Map
          </NavLink>
          <NavLink to="/stats" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
            Stats
          </NavLink>
          <NavLink to="/journeys" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
            Journeys
          </NavLink>
          <NavLink to="/places" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
            Places
          </NavLink>
          <NavLink to="/devices" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
            Devices
          </NavLink>
        </div>
        <div className="nav-actions">
          <ThemeToggle />
          <button className="btn-small btn-logout" onClick={handleLogout}>
            Sign Out
          </button>
        </div>
      </nav>

      {/* Routes */}
      <div className="app-content">
        <Routes>
          <Route path="/" element={<LiveMapPage />} />
          <Route path="/map" element={<MapViewsPage />} />
          <Route path="/stats" element={<StatsPage />} />
          <Route path="/journeys" element={<JourneysPage />} />
          <Route path="/journey/:id" element={<JourneyDetailPage />} />
          <Route path="/places" element={<PlacesPage />} />
          <Route path="/devices" element={<DevicesPage />} />
          <Route path="/callback" element={<CallbackPage />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </div>
    </div>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <ThemeProvider>
        <AuthProvider {...oidcConfig}>
          <AppLayout />
        </AuthProvider>
      </ThemeProvider>
    </BrowserRouter>
  );
}
