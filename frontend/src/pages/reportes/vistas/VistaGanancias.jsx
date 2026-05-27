import { useState, useEffect } from 'react';
import { usePermission } from '../../../hooks/usePermission';
import reporteService from '../../../services/reporte.service';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import BotonesExportar from '../components/BotonesExportar';
import TablaReporte from '../components/TablaReporte';
import FiltrosAvanzados from '../components/FiltrosAvanzados';

export default function VistaGanancias() {
  const { puede } = usePermission();

  const SUB_TABS = [
    { id: 'generales',        label: 'Resumen Financiero',    permiso: 'ganancias' },
    { id: 'top_productos',    label: 'Top Productos',          permiso: 'top_productos' },
    { id: 'ganancias_producto', label: 'Por Producto',         permiso: 'ganancias_producto' }
  ];

  const tabsPermitidos = SUB_TABS.filter(t => puede(t.permiso, 'reportes'));
  const [activeTab, setActiveTab] = useState(tabsPermitidos.length > 0 ? tabsPermitidos[0].id : null);

  const [financiero, setFinanciero] = useState(null);
  const [topProductos, setTopProductos] = useState([]);
  const [datosGanancia, setDatosGanancia] = useState([]);
  const [resumenGanancia, setResumenGanancia] = useState(null);
  const [filtros, setFiltros] = useState({});
  const [cargando, setCargando] = useState(false);

  useEffect(() => {
    if (!activeTab) return;
    setCargando(true);

    if (activeTab === 'generales') {
      reporteService.financiero().then(res => setFinanciero(res.data)).finally(() => setCargando(false));
    } else if (activeTab === 'top_productos') {
      reporteService.topProductos().then(res => setTopProductos(res.data)).finally(() => setCargando(false));
    } else if (activeTab === 'ganancias_producto') {
      setCargando(false);
    }
  }, [activeTab]);

  const buscarGananciasProducto = async () => {
    setCargando(true);
    try {
      const res = await reporteService.gananciasProducto(filtros);
      setDatosGanancia(res.data.data || []);
      setResumenGanancia(res.data.resumen || {});
    } catch (err) {
      console.error(err);
    } finally {
      setCargando(false);
    }
  };

  const COLORS = ['#10b981', '#3b82f6', '#f59e0b', '#ef4444', '#8b5cf6'];

  if (!activeTab) {
    return <div className="p-8 text-center text-zinc-500">No tienes permisos para ver reportes financieros.</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap gap-2">
        {tabsPermitidos.map(tab => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`px-3 py-1.5 text-xs font-semibold rounded-lg transition-all ${
              activeTab === tab.id
                ? 'bg-zinc-800 text-white dark:bg-white dark:text-zinc-900 shadow-md'
                : 'bg-white dark:bg-zinc-800 text-zinc-600 dark:text-zinc-300 border border-zinc-200 dark:border-zinc-700 hover:bg-zinc-50 dark:hover:bg-zinc-700'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {cargando ? (
        <div className="p-12 text-center text-zinc-500">Cargando métricas...</div>
      ) : (
        <>
          {activeTab === 'generales' && financiero && (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 animate-fade-in">
              <div className="bg-white dark:bg-zinc-900 rounded-2xl p-6 border border-zinc-200 dark:border-zinc-800 shadow-sm relative overflow-hidden">
                <div className="absolute top-0 right-0 p-4 opacity-10">
                  <svg className="w-16 h-16 text-emerald-500" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg>
                </div>
                <p className="text-sm font-semibold text-zinc-500 uppercase tracking-wider mb-2">Ventas (Ingresos)</p>
                <h3 className="text-3xl font-black text-emerald-600 dark:text-emerald-400">Bs {parseFloat(financiero.ingresos_mes).toLocaleString('en-US', {minimumFractionDigits: 2})}</h3>
                <p className="text-xs text-zinc-400 mt-2">Acumulado mes actual</p>
              </div>
              
              <div className="bg-white dark:bg-zinc-900 rounded-2xl p-6 border border-zinc-200 dark:border-zinc-800 shadow-sm relative overflow-hidden">
                 <div className="absolute top-0 right-0 p-4 opacity-10">
                  <svg className="w-16 h-16 text-red-500" fill="currentColor" viewBox="0 0 24 24"><path d="M19 13H5v-2h14v2z"/></svg>
                </div>
                <p className="text-sm font-semibold text-zinc-500 uppercase tracking-wider mb-2">Compras (Egresos)</p>
                <h3 className="text-3xl font-black text-red-600 dark:text-red-400">Bs {parseFloat(financiero.egresos_mes).toLocaleString('en-US', {minimumFractionDigits: 2})}</h3>
                <p className="text-xs text-zinc-400 mt-2">Pagos a proveedores en el mes</p>
              </div>

              <div className="bg-white dark:bg-zinc-900 rounded-2xl p-6 border border-zinc-200 dark:border-zinc-800 shadow-sm relative overflow-hidden">
                 <div className="absolute top-0 right-0 p-4 opacity-10">
                  <svg className="w-16 h-16 text-blue-500" fill="currentColor" viewBox="0 0 24 24"><path d="M3 13h2v-2H3v2zm0 4h2v-2H3v2zm0-8h2V7H3v2zm4 4h14v-2H7v2zm0 4h14v-2H7v2zM7 7v2h14V7H7z"/></svg>
                </div>
                <p className="text-sm font-semibold text-zinc-500 uppercase tracking-wider mb-2">Utilidad Bruta</p>
                <h3 className={`text-3xl font-black ${financiero.utilidad_bruta_mes >= 0 ? 'text-blue-600 dark:text-blue-400' : 'text-orange-600 dark:text-orange-400'}`}>
                  Bs {parseFloat(financiero.utilidad_bruta_mes).toLocaleString('en-US', {minimumFractionDigits: 2})}
                </h3>
                <p className="text-xs text-zinc-400 mt-2">Diferencia neta del periodo</p>
              </div>
            </div>
          )}

          {activeTab === 'ganancias_producto' && (
            <div className="space-y-4 animate-fade-in">
              <FiltrosAvanzados
                filtros={filtros}
                setFiltros={setFiltros}
                onBuscar={buscarGananciasProducto}
                cargando={cargando}
                opciones={{ fechas: true }}
                catalogos={{}}
              />
              <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-white dark:bg-zinc-900 p-4 rounded-xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
                <div className="flex gap-6 flex-wrap">
                  <div>
                    <p className="text-[10px] uppercase tracking-wider text-zinc-500 font-bold mb-1">Productos</p>
                    <p className="text-xl font-black text-zinc-900 dark:text-white">{resumenGanancia?.total_registros || 0}</p>
                  </div>
                  {resumenGanancia?.total_ingresos !== undefined && (
                    <div>
                      <p className="text-[10px] uppercase tracking-wider text-zinc-500 font-bold mb-1">Ingresos Totales</p>
                      <p className="text-xl font-black text-emerald-600">Bs {parseFloat(resumenGanancia.total_ingresos).toLocaleString('en-US', {minimumFractionDigits: 2})}</p>
                    </div>
                  )}
                  {resumenGanancia?.ganancia_total !== undefined && (
                    <div>
                      <p className="text-[10px] uppercase tracking-wider text-zinc-500 font-bold mb-1">Ganancia Bruta</p>
                      <p className={`text-xl font-black ${resumenGanancia.ganancia_total >= 0 ? 'text-blue-600' : 'text-red-600'}`}>
                        Bs {parseFloat(resumenGanancia.ganancia_total).toLocaleString('en-US', {minimumFractionDigits: 2})}
                      </p>
                    </div>
                  )}
                </div>
                <BotonesExportar
                  datos={datosGanancia}
                  columnas={[
                    { key: 'codigo_barras', header: 'Código', excelValue: r => r.codigo_barras || 'N/A' },
                    { key: 'nombre', header: 'Producto', excelValue: r => r.nombre },
                    { key: 'unidades_vendidas', header: 'Unidades', excelValue: r => r.unidades_vendidas },
                    { key: 'total_ingresos', header: 'Ingresos (Bs)', excelValue: r => parseFloat(r.total_ingresos) },
                    { key: 'costo_total', header: 'Costo (Bs)', excelValue: r => parseFloat(r.costo_total) },
                    { key: 'ganancia_bruta', header: 'Ganancia (Bs)', excelValue: r => parseFloat(r.ganancia_bruta) }
                  ]}
                  titulo="Reporte_Ganancias_Por_Producto"
                />
              </div>
              <div className="bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
                <TablaReporte
                  cargando={cargando}
                  datos={datosGanancia}
                  columnas={[
                    { key: 'codigo_barras', header: 'Código', render: v => v || 'N/A' },
                    { key: 'nombre', header: 'Producto' },
                    { key: 'unidades_vendidas', header: 'Unidades', align: 'center' },
                    { key: 'total_ingresos', header: 'Ingresos (Bs)', align: 'right', render: v => parseFloat(v).toFixed(2) },
                    { key: 'costo_total', header: 'Costo (Bs)', align: 'right', render: v => parseFloat(v).toFixed(2) },
                    { key: 'ganancia_bruta', header: 'Ganancia Bruta (Bs)', align: 'right', render: (v) => (
                      <span className={`font-bold ${parseFloat(v) >= 0 ? 'text-emerald-600' : 'text-red-600'}`}>
                        {parseFloat(v).toFixed(2)}
                      </span>
                    ), excelValue: r => parseFloat(r.ganancia_bruta) },
                    { key: 'margen', header: 'Margen %', align: 'right', render: (_, r) => {
                      const ing = parseFloat(r.total_ingresos);
                      const gan = parseFloat(r.ganancia_bruta);
                      const margen = ing > 0 ? ((gan / ing) * 100).toFixed(1) : '0.0';
                      return <span className={parseFloat(margen) >= 0 ? 'text-blue-600 font-semibold' : 'text-red-600 font-semibold'}>{margen}%</span>;
                    }, excelValue: r => parseFloat(r.total_ingresos) > 0 ? ((parseFloat(r.ganancia_bruta)/parseFloat(r.total_ingresos))*100).toFixed(1) : 0 }
                  ]}
                />
              </div>
            </div>
          )}

          {activeTab === 'top_productos' && (
            <div className="bg-white dark:bg-zinc-900 rounded-2xl border border-zinc-200 dark:border-zinc-800 shadow-sm p-6 animate-fade-in">
              <div className="flex justify-between items-center mb-6">
                <h3 className="font-bold text-lg text-zinc-900 dark:text-white flex items-center gap-2">
                  🏆 Top 5 Productos Más Vendidos
                </h3>
                <BotonesExportar 
                  datos={topProductos} 
                  columnas={[
                    { key: 'codigo_barras', header: 'Código', excelValue: r => r.codigo_barras },
                    { key: 'nombre', header: 'Producto', excelValue: r => r.nombre },
                    { key: 'unidades_vendidas', header: 'Unidades', excelValue: r => r.unidades_vendidas },
                    { key: 'ingresos_generados', header: 'Ingresos (Bs)', excelValue: r => parseFloat(r.ingresos_generados) }
                  ]} 
                  titulo="Ranking_Top_Productos" 
                />
              </div>
              
              {topProductos.length === 0 ? (
                <div className="h-64 flex items-center justify-center text-zinc-400">No hay datos de ventas suficientes</div>
              ) : (
                <div className="h-72">
                  <ResponsiveContainer width="100%" height="100%">
                    <BarChart data={topProductos} layout="vertical" margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                      <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#3f3f46" opacity={0.2} />
                      <XAxis type="number" tick={{fill: '#71717a', fontSize: 12}} />
                      <YAxis dataKey="nombre" type="category" width={120} tick={{fill: '#71717a', fontSize: 12}} />
                      <Tooltip 
                        cursor={{fill: 'rgba(16, 185, 129, 0.1)'}} 
                        contentStyle={{backgroundColor: '#18181b', border: 'none', borderRadius: '8px', color: '#fff'}}
                        formatter={(value) => [`${value} unidades`, 'Vendido']}
                      />
                      <Bar dataKey="unidades_vendidas" radius={[0, 4, 4, 0]}>
                        {topProductos.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                        ))}
                      </Bar>
                    </BarChart>
                  </ResponsiveContainer>
                </div>
              )}
            </div>
          )}
        </>
      )}
    </div>
  );
}
