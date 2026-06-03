function fmt(n) { return parseFloat(n || 0).toLocaleString('es-BO', { minimumFractionDigits: 2 }); }

function BadgeTipo({ tipo }) {
  return tipo === 'INGRESO'
    ? <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-emerald-100 dark:bg-emerald-900/40 text-emerald-700 dark:text-emerald-400">↑ INGRESO</span>
    : <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-red-100 dark:bg-red-900/40 text-red-700 dark:text-red-400">↓ EGRESO</span>;
}

function BadgeOrigen({ origen }) {
  const map = {
    venta:      { label: 'Venta',   cls: 'bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-400' },
    compra:     { label: 'Compra',  cls: 'bg-orange-100 dark:bg-orange-900/40 text-orange-700 dark:text-orange-400' },
    movimiento: { label: 'Manual',  cls: 'bg-zinc-100 dark:bg-zinc-700 text-zinc-600 dark:text-zinc-300' },
  };
  const { label, cls } = map[origen] ?? map.movimiento;
  return <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${cls}`}>{label}</span>;
}

export default function TablaLibroCaja({ movimientos, cargando, onEditar, onEliminar, puedeEditar, puedeEliminar }) {
  if (cargando) {
    return (
      <div className="flex justify-center py-20">
        <span className="w-7 h-7 rounded-full border-2 border-zinc-300 dark:border-zinc-600 border-t-emerald-500 animate-spin" />
      </div>
    );
  }

  if (movimientos.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-16 text-zinc-400 dark:text-zinc-500">
        <span className="text-4xl mb-3">📒</span>
        <p className="text-sm">Sin movimientos en el período seleccionado</p>
      </div>
    );
  }

  return (
    <div className="overflow-x-auto rounded-xl border border-zinc-200 dark:border-zinc-800">
      <table className="w-full text-sm">
        <thead className="bg-zinc-50 dark:bg-zinc-800/50">
          <tr>
            <th className="text-left px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Fecha</th>
            <th className="text-left px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Tipo</th>
            <th className="text-left px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Categoría</th>
            <th className="text-left px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Descripción</th>
            <th className="text-left px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase hidden sm:table-cell">Sucursal</th>
            <th className="text-right px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Monto</th>
            <th className="text-center px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Origen</th>
            <th className="text-center px-4 py-3 text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase">Acciones</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800">
          {movimientos.map((mov, i) => (
            <tr key={`${mov.origen}-${mov.id_origen}-${i}`}
                className="hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-colors">
              <td className="px-4 py-3 text-zinc-600 dark:text-zinc-400 whitespace-nowrap">
                {mov.fecha ? String(mov.fecha).split('T')[0] : '—'}
              </td>
              <td className="px-4 py-3"><BadgeTipo tipo={mov.tipo} /></td>
              <td className="px-4 py-3 text-zinc-700 dark:text-zinc-300">{mov.categoria}</td>
              <td className="px-4 py-3 text-zinc-900 dark:text-white max-w-xs truncate">{mov.descripcion}</td>
              <td className="px-4 py-3 text-zinc-500 dark:text-zinc-400 hidden sm:table-cell">{mov.sucursal}</td>
              <td className={`px-4 py-3 text-right font-semibold whitespace-nowrap ${
                mov.tipo === 'INGRESO' ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-600 dark:text-red-400'
              }`}>
                {mov.tipo === 'INGRESO' ? '+' : '-'} Bs. {fmt(mov.monto)}
              </td>
              <td className="px-4 py-3 text-center"><BadgeOrigen origen={mov.origen} /></td>
              <td className="px-4 py-3 text-center">
                {mov.origen === 'movimiento' ? (
                  <div className="flex items-center justify-center gap-1">
                    {puedeEditar && (
                      <button onClick={() => onEditar(mov)}
                              className="px-2 py-1 text-xs text-zinc-500 hover:text-zinc-700 dark:hover:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-700 rounded transition-colors">
                        ✏️
                      </button>
                    )}
                    {puedeEliminar && (
                      <button onClick={() => onEliminar(mov.id_origen)}
                              className="px-2 py-1 text-xs text-red-500 hover:text-red-700 hover:bg-red-50 dark:hover:bg-red-500/10 rounded transition-colors">
                        🗑
                      </button>
                    )}
                  </div>
                ) : (
                  <span className="text-zinc-300 dark:text-zinc-600 text-xs">—</span>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
