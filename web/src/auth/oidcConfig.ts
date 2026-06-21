import { UserManagerSettings } from 'oidc-client-ts';

const authority = import.meta.env.VITE_OIDC_AUTHORITY;
const clientId = import.meta.env.VITE_OIDC_CLIENT_ID;
const redirectUri = import.meta.env.VITE_OIDC_REDIRECT_URI || 'http://localhost:3000/callback';

if (!authority || !clientId) {
  console.warn('[OIDC] Missing VITE_OIDC_AUTHORITY or VITE_OIDC_CLIENT_ID');
}

export const oidcConfig: UserManagerSettings = {
  authority: authority || '',
  client_id: clientId || '',
  redirect_uri: redirectUri,
  response_type: 'code',
  scope: 'openid profile email',
  automaticSilentRenew: true,
  silent_redirect_uri: redirectUri,
  post_logout_redirect_uri: redirectUri.replace('/callback', ''),
};
