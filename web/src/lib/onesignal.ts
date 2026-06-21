const APP_ID = import.meta.env.VITE_ONESIGNAL_APP_ID || '';
const SAFARI_WEB_ID = import.meta.env.VITE_ONESIGNAL_SAFARI_WEB_ID || '';

let initialized = false;

export function initOneSignal(externalId?: string) {
  if (!APP_ID) {
    console.warn('[OneSignal] Missing VITE_ONESIGNAL_APP_ID');
    return;
  }

  if (initialized) {
    if (externalId) {
      // @ts-expect-error OneSignalDeferred global
      window.OneSignalDeferred = window.OneSignalDeferred || [];
      // @ts-expect-error OneSignalDeferred global
      window.OneSignalDeferred.push(async function (OneSignal: any) {
        await OneSignal.login(externalId);
        console.log('[OneSignal] Linked to user', externalId);
      });
    }
    return;
  }
  initialized = true;

  // @ts-expect-error OneSignalDeferred global
  window.OneSignalDeferred = window.OneSignalDeferred || [];
  // @ts-expect-error OneSignalDeferred global
  window.OneSignalDeferred.push(async function (OneSignal: any) {
    await OneSignal.init({
      appId: APP_ID,
      safari_web_id: SAFARI_WEB_ID || undefined,
      serviceWorkerPath: 'OneSignalSDKWorker.js',
      serviceWorkerParam: { scope: '/' },
      autoResubscribe: true,
      notifyButton: {
        enable: true,
        prenotify: {
          show: true,
          message: 'Enable notifications for journey updates?',
        },
        position: 'bottom-right',
        offset: { bottom: '20px', right: '20px' },
        colors: {
          'circle.background': '#faff69',
          'circle.foreground': '#0a0a0a',
          'badge.background': '#faff69',
          'badge.foreground': '#0a0a0a',
          'badge.bordercolor': '#0a0a0a',
          'pulse.color': '#faff69',
          'dialog.button.background.hovering': '#e6eb52',
          'dialog.button.background.active': '#3a3a1f',
          'dialog.button.background': '#faff69',
          'dialog.button.foreground': '#0a0a0a',
        },
      },
      welcomeNotification: {
        disable: false,
        title: 'Bro Where Are You',
        message: 'Notifications enabled! You\'ll receive journey updates.',
      },
    });

    if (externalId) {
      await OneSignal.login(externalId);
    }

    console.log('[OneSignal] Initialized', externalId ? `for user ${externalId}` : '');
  });
}

export function sendTestNotification() {
  // @ts-expect-error OneSignalDeferred is loaded from CDN script in index.html
  window.OneSignalDeferred = window.OneSignalDeferred || [];
  // @ts-expect-error OneSignalDeferred is loaded from CDN script in index.html
  window.OneSignalDeferred.push(async function (OneSignal: any) {
    const id = await OneSignal.getUserId();
    console.log('[OneSignal] Player ID:', id);
  });
}
