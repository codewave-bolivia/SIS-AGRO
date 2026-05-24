import { useState, useEffect, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import PageWrapper from '../../components/PageWrapper';
import ventaService from '../../services/venta.service';
import clienteService from '../../services/cliente.service';
import almacenService from '../../services/almacen.service';

export default function NuevaVenta() {
  const navigate = useNavigate();

  // Datos Base
  const [clientes, setClientes] = useState([]);
  const [productosStock, setProductosStock] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [guardando, setGuardando] = useState(false);

  // Buscador
  const [busqueda, setBusqueda] = useState('');

  // Carrito y Cabecera
  const [carrito, setCarrito] = useState([]);
  const [idCliente, setIdCliente] = useState('');
  const [tipoVenta, setTipoVenta] = useState('MENOR');
  const [metodoPago, setMetodoPago] = useState('EFECTIVO');
  const [montoPagado, setMontoPagado] = useState('');

  useEffect(() => {
    cargarDatos();
  }, []);

  useEffect(() => {
    if (carrito.length > 0 && productosStock.length > 0) {
      const nuevoCar = carrito.map(item => {
        const prod = productosStock.find(p => p.id_producto === item.id_producto);
        if (prod) {
          const nuevoPrecio = tipoVenta === 'MAYOR' ? prod.precio_mayor : prod.precio_menor;
          const cant = parseFloat(item.cantidad) || 0;
          return {
            ...item,
            precio_unitario: nuevoPrecio || 0,
            subtotal: cant * (nuevoPrecio || 0)
          };
        }
        return item;
      });
      setCarrito(nuevoCar);
    }
  }, [tipoVenta]);

  const cargarDatos = async () => {
    try {
      const [cliRes, almRes] = await Promise.all([
        clienteService.listar(),
        almacenService.listarLotes()
      ]);

      setClientes(cliRes.data.filter(c => c.activo === 1));

      // Agrupar lotes por producto para saber el stock total disponible y precios
      const stockMap = new Map();
      almRes.data.forEach(lote => {
        if (lote.stock_unidades > 0) {
          if (!stockMap.has(lote.id_producto)) {
            stockMap.set(lote.id_producto, {
              id_producto: lote.id_producto,
              nombre: lote.producto_nombre,
              codigo_barras: lote.codigo_barras,
              precio_menor: lote.precio_menor || 0, // Asumiendo que el lote o producto tiene precios
              precio_mayor: lote.precio_mayor || 0, // Ojo: en bd.txt, lote tiene 'precio_por_caja', producto no tiene precios definidos claramente en el schema excepto costo.
              // Para simplificar, asumiremos un precio unitario basado en el lote o lo pediremos manual.
              // Vamos a pedir el precio manual en el POS o usar un default si existe.
              unidades_por_caja: lote.unidades_por_caja,
              stock_unidades_total: 0
            });
          }
          const p = stockMap.get(lote.id_producto);
          p.stock_unidades_total += lote.stock_unidades;
        }
      });
      setProductosStock(Array.from(stockMap.values()));

    } catch (err) {
      console.error(err);
      alert('Error al cargar datos del POS');
    } finally {
      setCargando(false);
    }
  };

  const productosFiltrados = useMemo(() => {
    if (!busqueda) return productosStock;
    const b = busqueda.toLowerCase();
    return productosStock.filter(p => 
      p.nombre.toLowerCase().includes(b) || 
      (p.codigo_barras && p.codigo_barras.toLowerCase().includes(b))
    );
  }, [busqueda, productosStock]);

  const agregarAlCarrito = (prod) => {
    // Verificar si ya está
    const index = carrito.findIndex(item => item.id_producto === prod.id_producto);
    if (index >= 0) {
      const nuevoCar = [...carrito];
      // Validar stock
      if (nuevoCar[index].cantidad + 1 > prod.stock_unidades_total) {
        return alert('No hay suficiente stock');
      }
      nuevoCar[index].cantidad += 1;
      nuevoCar[index].subtotal = nuevoCar[index].cantidad * nuevoCar[index].precio_unitario;
      setCarrito(nuevoCar);
    } else {
      const precioBase = tipoVenta === 'MAYOR' ? prod.precio_mayor : prod.precio_menor;
      setCarrito([...carrito, {
        id_producto: prod.id_producto,
        nombre: prod.nombre,
        tipo_cantidad: 'UNIDAD',
        cantidad: 1,
        precio_unitario: precioBase || 0,
        unidades_por_caja: prod.unidades_por_caja,
        stock_maximo: prod.stock_unidades_total,
        subtotal: (precioBase || 0) * 1
      }]);
    }
  };

  const actualizarItem = (index, campo, valor) => {
    const nuevoCar = [...carrito];
    nuevoCar[index][campo] = valor;

    // Recalcular subtotal si cambia precio o cantidad
    if (campo === 'cantidad' || campo === 'precio_unitario') {
      const cant = parseFloat(nuevoCar[index].cantidad) || 0;
      const precio = parseFloat(nuevoCar[index].precio_unitario) || 0;
      
      // Validar stock (si es caja, multiplicar)
      let unidadesReq = cant;
      if (nuevoCar[index].tipo_cantidad === 'CAJA') {
        unidadesReq = cant * nuevoCar[index].unidades_por_caja;
      }
      
      if (unidadesReq > nuevoCar[index].stock_maximo) {
        alert('Cantidad excede el stock disponible (' + nuevoCar[index].stock_maximo + ' unidades)');
        nuevoCar[index].cantidad = 1; // reset
        nuevoCar[index].subtotal = 1 * precio;
      } else {
        nuevoCar[index].subtotal = cant * precio;
      }
    }

    setCarrito(nuevoCar);
  };

  const eliminarDelCarrito = (index) => {
    setCarrito(carrito.filter((_, i) => i !== index));
  };

  const totales = useMemo(() => {
    const subtotal = carrito.reduce((acc, item) => acc + (parseFloat(item.subtotal) || 0), 0);
    const descuento_total = 0; // Podría haber un input general
    const total = subtotal - descuento_total;
    const pagado = parseFloat(montoPagado) || 0;
    const cambio = pagado > 0 ? pagado - total : 0;
    return { subtotal, descuento_total, total, cambio };
  }, [carrito, montoPagado]);

  const finalizarVenta = async () => {
    if (carrito.length === 0) return alert('El carrito está vacío');
    if (totales.total <= 0) return alert('El total debe ser mayor a 0');
    if (parseFloat(montoPagado) > 0 && totales.cambio < 0) return alert('El monto pagado es insuficiente');

    // Validar que todos tengan precio
    const sinPrecio = carrito.find(c => parseFloat(c.precio_unitario) <= 0);
    if (sinPrecio) return alert(`Debe establecer un precio mayor a 0 para ${sinPrecio.nombre}`);

    setGuardando(true);
    try {
      const payload = {
        id_cliente: idCliente || null,
        tipo_venta: tipoVenta,
        subtotal: totales.subtotal,
        descuento_total: totales.descuento_total,
        total: totales.total,
        monto_pagado: parseFloat(montoPagado) || totales.total, // Si no pone nada, asume exacto
        cambio: totales.cambio > 0 ? totales.cambio : 0,
        metodo_pago: metodoPago,
        detalles: carrito.map(c => ({
          id_producto: c.id_producto,
          tipo_cantidad: c.tipo_cantidad,
          cantidad: parseFloat(c.cantidad),
          precio_unitario: parseFloat(c.precio_unitario),
          unidades_por_caja: c.unidades_por_caja,
          subtotal: parseFloat(c.subtotal)
        }))
      };

      await ventaService.crear(payload);
      navigate('/ventas', { state: { msg: 'Venta completada con éxito' } });
    } catch (err) {
      alert(err.response?.data?.error || 'Error al procesar la venta');
    } finally {
      setGuardando(false);
    }
  };

  if (cargando) return <div className="p-8 text-center">Cargando POS...</div>;

  return (
    <div className="min-h-screen bg-zinc-100 dark:bg-zinc-950 flex flex-col md:flex-row">
      
      {/* Panel Izquierdo: Catálogo de Productos */}
      <div className="w-full md:w-7/12 lg:w-2/3 flex flex-col h-[50vh] md:h-screen border-r border-zinc-200 dark:border-zinc-800">
        
        {/* Topbar Buscador */}
        <div className="p-4 bg-white dark:bg-zinc-900 shadow-sm z-10 flex gap-4 items-center shrink-0">
          <button onClick={() => navigate('/ventas')} className="p-2 text-zinc-500 hover:text-zinc-800 bg-zinc-100 rounded-lg">
            <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
          </button>
          <div className="relative flex-1">
            <input
              type="text"
              placeholder="Buscar por nombre o código de barras..."
              value={busqueda}
              onChange={(e) => setBusqueda(e.target.value)}
              className="w-full pl-10 pr-4 py-3 bg-zinc-100 dark:bg-zinc-800 border-none rounded-xl text-zinc-900 dark:text-white focus:ring-2 focus:ring-emerald-500 outline-none"
            />
            <svg className="w-5 h-5 absolute left-3 top-3.5 text-zinc-400" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
        </div>

        {/* Grilla de Productos */}
        <div className="flex-1 overflow-y-auto p-4 bg-zinc-50 dark:bg-zinc-950">
          <div className="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {productosFiltrados.map(p => (
              <div 
                key={p.id_producto}
                onClick={() => agregarAlCarrito(p)}
                className="bg-white dark:bg-zinc-900 rounded-2xl p-4 shadow-sm border border-zinc-200 dark:border-zinc-800 cursor-pointer hover:border-emerald-500 hover:shadow-md transition-all flex flex-col h-full"
              >
                <div className="flex-1">
                  <h3 className="font-bold text-zinc-900 dark:text-white leading-tight mb-1">{p.nombre}</h3>
                  <p className="text-xs text-zinc-500 font-mono">{p.codigo_barras || 'S/C'}</p>
                </div>
                <div className="mt-3 pt-3 border-t border-zinc-100 dark:border-zinc-800 flex justify-between items-end">
                  <div>
                    <p className="text-[10px] text-zinc-400 uppercase tracking-wider">Stock Disp.</p>
                    <p className="font-bold text-emerald-600 dark:text-emerald-400">{p.stock_unidades_total} u</p>
                  </div>
                  <div className="w-8 h-8 rounded-full bg-zinc-100 dark:bg-zinc-800 flex items-center justify-center text-zinc-400">
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={3} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4"/></svg>
                  </div>
                </div>
              </div>
            ))}
          </div>
          {productosFiltrados.length === 0 && (
             <div className="text-center mt-12 text-zinc-400">No se encontraron productos con stock.</div>
          )}
        </div>
      </div>

      {/* Panel Derecho: Carrito y Cobro */}
      <div className="w-full md:w-5/12 lg:w-1/3 bg-white dark:bg-zinc-900 flex flex-col h-[50vh] md:h-screen shadow-2xl z-20">
        
        {/* Cabecera Venta */}
        <div className="p-4 border-b border-zinc-200 dark:border-zinc-800 shrink-0 space-y-3">
          <div className="flex gap-2">
            <select
              value={idCliente} onChange={(e) => setIdCliente(e.target.value)}
              className="flex-1 px-3 py-2 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-lg text-sm outline-none focus:ring-2 focus:ring-emerald-500"
            >
              <option value="">Cliente Casual</option>
              {clientes.map(c => <option key={c.id_cliente} value={c.id_cliente}>{c.nombre} {c.apellido || c.empresa}</option>)}
            </select>
            <select
              value={tipoVenta} onChange={(e) => setTipoVenta(e.target.value)}
              className="w-1/3 px-3 py-2 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-lg text-sm outline-none focus:ring-2 focus:ring-emerald-500"
            >
              <option value="MENOR">Menor</option>
              <option value="MAYOR">Mayor</option>
            </select>
          </div>
        </div>

        {/* Lista de Items */}
        <div className="flex-1 overflow-y-auto p-4 space-y-3 bg-zinc-50/50 dark:bg-zinc-900">
          {carrito.length === 0 ? (
            <div className="h-full flex flex-col items-center justify-center text-zinc-400 space-y-4">
              <svg className="w-16 h-16 opacity-20" fill="none" stroke="currentColor" strokeWidth={1} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
              <p>El carrito está vacío</p>
            </div>
          ) : (
            carrito.map((item, idx) => (
              <div key={idx} className="bg-white dark:bg-zinc-800 p-3 rounded-xl border border-zinc-200 dark:border-zinc-700 shadow-sm relative">
                <button onClick={() => eliminarDelCarrito(idx)} className="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full flex items-center justify-center hover:bg-red-600 shadow">
                  <svg className="w-3 h-3" fill="none" stroke="currentColor" strokeWidth={3} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>
                </button>
                <h4 className="font-bold text-sm text-zinc-900 dark:text-white truncate pr-4">{item.nombre}</h4>
                <div className="flex gap-2 mt-2">
                  <div className="w-1/4">
                    <input type="number" min="1" className="w-full text-center py-1 border rounded text-sm dark:bg-zinc-900 dark:border-zinc-700" value={item.cantidad} onChange={(e) => actualizarItem(idx, 'cantidad', e.target.value)} />
                  </div>
                  <div className="w-1/4">
                    <select className="w-full py-1 border rounded text-xs dark:bg-zinc-900 dark:border-zinc-700" value={item.tipo_cantidad} onChange={(e) => actualizarItem(idx, 'tipo_cantidad', e.target.value)}>
                      <option value="UNIDAD">Un.</option>
                      <option value="CAJA">Caj.</option>
                    </select>
                  </div>
                  <div className="w-1/4">
                    <input type="number" step="0.5" placeholder="Precio" className="w-full text-center py-1 border rounded text-sm dark:bg-zinc-900 dark:border-zinc-700" value={item.precio_unitario || ''} onChange={(e) => actualizarItem(idx, 'precio_unitario', e.target.value)} />
                  </div>
                  <div className="w-1/4 flex items-center justify-end font-bold text-emerald-600 dark:text-emerald-400">
                    {item.subtotal.toFixed(2)}
                  </div>
                </div>
              </div>
            ))
          )}
        </div>

        {/* Totales y Cobro */}
        <div className="p-6 bg-white dark:bg-zinc-900 border-t border-zinc-200 dark:border-zinc-800 shrink-0">
          <div className="flex justify-between text-zinc-500 mb-1">
            <span>Subtotal</span>
            <span>Bs {totales.subtotal.toFixed(2)}</span>
          </div>
          <div className="flex justify-between text-4xl font-black text-zinc-900 dark:text-white my-4">
            <span>Total</span>
            <span>Bs {totales.total.toFixed(2)}</span>
          </div>

          <div className="grid grid-cols-2 gap-3 mb-4">
            <div>
              <label className="text-xs text-zinc-500 mb-1 block">Método</label>
              <select value={metodoPago} onChange={(e) => setMetodoPago(e.target.value)} className="w-full p-3 bg-zinc-100 dark:bg-zinc-800 rounded-xl outline-none font-medium">
                <option value="EFECTIVO">💵 Efectivo</option>
                <option value="QR">📱 QR</option>
                <option value="TRANSFERENCIA">🏦 Transf.</option>
                <option value="CREDITO">📝 Crédito</option>
              </select>
            </div>
            <div>
              <label className="text-xs text-zinc-500 mb-1 block">Recibí (Bs)</label>
              <input type="number" placeholder="Ej. 100" value={montoPagado} onChange={(e) => setMontoPagado(e.target.value)} className="w-full p-3 bg-zinc-100 dark:bg-zinc-800 rounded-xl outline-none font-medium text-right text-emerald-600 focus:ring-2 focus:ring-emerald-500" />
            </div>
          </div>

          {totales.cambio > 0 && (
            <div className="p-3 bg-amber-50 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400 rounded-xl flex justify-between font-bold mb-4">
              <span>Cambio a devolver:</span>
              <span>Bs {totales.cambio.toFixed(2)}</span>
            </div>
          )}

          <button
            onClick={finalizarVenta}
            disabled={guardando || carrito.length === 0}
            className="w-full py-4 rounded-xl text-white font-black text-lg bg-emerald-600 hover:bg-emerald-500 shadow-xl shadow-emerald-500/20 disabled:opacity-50 transition-all flex items-center justify-center gap-2"
          >
            {guardando ? 'Procesando...' : (
              <>
                <svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
                COBRAR Bs {totales.total.toFixed(2)}
              </>
            )}
          </button>
        </div>

      </div>
    </div>
  );
}
