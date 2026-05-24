import { useState } from 'react';
import { usePermission } from '../../../hooks/usePermission';
import PageWrapper from '../../../components/PageWrapper';

export default function VistaSucursales() {
  const { puede } = usePermission();

  return (
    <div className="p-8 text-center bg-white dark:bg-zinc-900 rounded-2xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
      <div className="w-20 h-20 bg-blue-50 text-blue-500 rounded-full flex items-center justify-center mx-auto mb-4">
        <svg className="w-10 h-10" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>
      </div>
      <h2 className="text-xl font-bold text-zinc-900 dark:text-white mb-2">Reportes de Sucursales</h2>
      <p className="text-zinc-500 max-w-md mx-auto">
        El módulo de comparativo entre sucursales y registro de traslados estará disponible próximamente en la siguiente actualización.
      </p>
    </div>
  );
}
