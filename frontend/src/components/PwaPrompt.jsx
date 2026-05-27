/**
 * PwaPrompt
 * ─────────────────────────────────────────────────────────────────────────────
 * Maneja tres aspectos de la PWA visibles para el usuario:
 *
 *  1. Banner "Nueva versión disponible" — aparece cuando el SW detecta
 *     una actualización; el usuario puede aceptar para recargar.
 *
 *  2. Toast "Listo para usar sin conexión" — se muestra una vez cuando
 *     el SW termina de cachear todos los assets.
 *
 *  3. Indicador de estado de red — barra fija en la parte superior cuando
 *     el dispositivo pierde conexión a internet.
 */

import { useState, useEffect, useCallback } from 'react';
import { useRegisterSW } from 'virtual:pwa-register/react';

// ── Indicador offline (barra top) ─────────────────────────────────────────────
function OfflineBanner({ offline }) {
  if (!offline) return null;
  return (
    <div
      className="fixed top-0 inset-x-0 z-[9999]
                 bg-amber-500 text-zinc-900 text-center
                 text-xs font-semibold py-1 px-4
                 shadow-md"
      role="status"
      aria-live="polite"
    >
      ⚠️ Sin conexión — mostrando datos en caché
    </div>
  );
}

// ── Toast "offline ready" ─────────────────────────────────────────────────────
function OfflineReadyToast({ visible, onClose }) {
  useEffect(() => {
    if (!visible) return;
    const t = setTimeout(onClose, 4000);
    return () => clearTimeout(t);
  }, [visible, onClose]);

  if (!visible) return null;
  return (
    <div
      className="fixed bottom-5 left-1/2 -translate-x-1/2 z-[9998]
                 flex items-center gap-3
                 bg-zinc-900 dark:bg-zinc-800 text-white
                 text-sm font-medium px-5 py-3 rounded-2xl
                 shadow-2xl shadow-black/40
                 border border-zinc-700
                 animate-fade-in"
      role="status"
    >
      <span className="text-base">✅</span>
      <span>SIS-AGRO listo para usar sin conexión</span>
      <button
        onClick={onClose}
        className="ml-1 text-zinc-400 hover:text-white transition-colors text-lg leading-none"
        aria-label="Cerrar"
      >
        ×
      </button>
    </div>
  );
}

// ── Banner de actualización disponible ───────────────────────────────────────
function UpdateBanner({ visible, onUpdate, onDismiss }) {
  if (!visible) return null;
  return (
    <div
      className="fixed bottom-5 right-5 z-[9997]
                 bg-white dark:bg-zinc-900
                 border border-zinc-200 dark:border-zinc-700
                 rounded-2xl shadow-2xl shadow-black/30
                 p-4 max-w-xs w-full
                 flex flex-col gap-3"
      role="alert"
      aria-live="assertive"
    >
      <div className="flex items-start gap-3">
        {/* icono */}
        <div className="w-9 h-9 rounded-xl bg-yellow-400 flex items-center justify-center text-lg shrink-0">
          🔄
        </div>
        <div>
          <p className="text-sm font-bold text-zinc-900 dark:text-white leading-tight">
            Nueva versión disponible
          </p>
          <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
            Actualiza para obtener las últimas mejoras del sistema.
          </p>
        </div>
        <button
          onClick={onDismiss}
          className="text-zinc-300 hover:text-zinc-600 dark:hover:text-zinc-200
                     transition-colors text-xl leading-none shrink-0 ml-auto"
          aria-label="Cerrar"
        >
          ×
        </button>
      </div>
      <div className="flex gap-2">
        <button
          onClick={onDismiss}
          className="flex-1 py-1.5 text-xs font-medium rounded-xl
                     border border-zinc-200 dark:border-zinc-700
                     text-zinc-600 dark:text-zinc-400
                     hover:bg-zinc-50 dark:hover:bg-zinc-800
                     transition-colors"
        >
          Después
        </button>
        <button
          onClick={onUpdate}
          className="flex-1 py-1.5 text-xs font-bold rounded-xl
                     bg-yellow-400 hover:bg-yellow-300 text-zinc-900
                     transition-colors shadow-sm shadow-yellow-400/30"
        >
          Actualizar ahora
        </button>
      </div>
    </div>
  );
}

// ── Componente principal ──────────────────────────────────────────────────────
export default function PwaPrompt() {
  const [offline,       setOffline]       = useState(!navigator.onLine);
  const [showReady,     setShowReady]     = useState(false);
  const [showUpdate,    setShowUpdate]    = useState(false);
  const [dismissUpdate, setDismissUpdate] = useState(false);

  // Hook de vite-plugin-pwa
  const {
    offlineReady: [offlineReady, setOfflineReady],
    needRefresh:  [needRefresh,  setNeedRefresh],
    updateServiceWorker,
  } = useRegisterSW({
    onRegistered(r) {
      // Verificar actualizaciones cada 60 minutos
      if (r) {
        setInterval(() => r.update(), 60 * 60 * 1000);
      }
    },
    onRegisterError(error) {
      console.warn('[PWA] Error al registrar service worker:', error);
    },
  });

  // Mostrar toast cuando el SW está listo
  useEffect(() => {
    if (offlineReady) setShowReady(true);
  }, [offlineReady]);

  // Mostrar banner cuando hay actualización
  useEffect(() => {
    if (needRefresh && !dismissUpdate) setShowUpdate(true);
  }, [needRefresh, dismissUpdate]);

  // Escuchar cambios de conectividad
  useEffect(() => {
    const goOnline  = () => setOffline(false);
    const goOffline = () => setOffline(true);
    window.addEventListener('online',  goOnline);
    window.addEventListener('offline', goOffline);
    return () => {
      window.removeEventListener('online',  goOnline);
      window.removeEventListener('offline', goOffline);
    };
  }, []);

  const handleUpdate = useCallback(() => {
    setShowUpdate(false);
    setNeedRefresh(false);
    updateServiceWorker(true);
  }, [updateServiceWorker, setNeedRefresh]);

  const handleDismissUpdate = useCallback(() => {
    setShowUpdate(false);
    setDismissUpdate(true);
    setNeedRefresh(false);
  }, [setNeedRefresh]);

  const handleCloseReady = useCallback(() => {
    setShowReady(false);
    setOfflineReady(false);
  }, [setOfflineReady]);

  return (
    <>
      <OfflineBanner     offline={offline} />
      <OfflineReadyToast visible={showReady}  onClose={handleCloseReady} />
      <UpdateBanner
        visible={showUpdate}
        onUpdate={handleUpdate}
        onDismiss={handleDismissUpdate}
      />
    </>
  );
}
