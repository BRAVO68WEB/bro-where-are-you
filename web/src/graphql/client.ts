import { createClient, Client } from 'graphql-ws';

const HASURA_URL = import.meta.env.VITE_HASURA_URL || 'http://localhost:8080/v1/graphql';
const HASURA_WS_URL = HASURA_URL.replace(/^http/, 'ws');

let client: Client | null = null;
let tokenGetter: (() => string | null) | null = null;

export function setTokenGetter(getter: () => string | null) {
  tokenGetter = getter;
  // Reset client so it picks up new token on next connection
  client = null;
}

export function getGqlClient(): Client {
  if (!client) {
    client = createClient({
      url: HASURA_WS_URL,
      connectionParams: () => {
        // Use id_token (JWT) for Hasura, not opaque access_token
        const token = tokenGetter?.();
        const adminSecret = import.meta.env.VITE_HASURA_ADMIN_SECRET;

        if (token) {
          return {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          };
        }
        if (adminSecret) {
          return {
            headers: {
              'x-hasura-admin-secret': adminSecret,
              'x-hasura-role': 'user',
            },
          };
        }
        return { headers: { 'x-hasura-role': 'user' } };
      },
      retryAttempts: Infinity,
      shouldRetry: () => true,
      on: {
        connecting: () => console.log('[gql] connecting...'),
        connected: () => console.log('[gql] connected'),
        closed: () => console.log('[gql] closed'),
        error: (err) => console.error('[gql] error', err),
      },
    });
  }
  return client;
}

export function subscribe<T>(
  query: string,
  variables: Record<string, unknown>,
  onData: (data: T) => void,
  onError?: (err: unknown) => void,
): () => void {
  const client = getGqlClient();

  let unsubscribe: (() => void) | undefined;

  unsubscribe = client.subscribe<T>(
    { query, variables },
    {
      next: (result) => {
        if ('data' in result && result.data) {
          onData(result.data);
        }
      },
      error: (err) => {
        console.error('[gql] subscription error', err);
        onError?.(err);
      },
      complete: () => {
        console.log('[gql] subscription complete');
      },
    },
  );

  return () => unsubscribe?.();
}

export function clearClient() {
  client = null;
}
