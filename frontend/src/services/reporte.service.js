import api from '../api/axios';

const reporteService = {
  // Originales
  financiero:   () => api.get('/reportes/financiero'),
  topProductos: () => api.get('/reportes/top-productos'),
  vencimientos: () => api.get('/reportes/vencimientos'),

  // Ventas Avanzadas
  ventas: (tipo, params) => api.get(`/reportes/ventas/${tipo}`, { params }),

  // Compras Avanzadas
  compras: (tipo, params) => api.get(`/reportes/compras/${tipo}`, { params }),

  // Inventario Avanzado
  inventario: (tipo, params) => api.get(`/reportes/inventario/${tipo}`, { params }),

  // Ganancias desglosadas por producto
  gananciasProducto: (params) => api.get('/reportes/ganancias/producto', { params }),

  // Sucursales
  traslados:          (params) => api.get('/reportes/sucursales/traslados', { params }),
  comparativoSucursales: (params) => api.get('/reportes/sucursales/comparativo', { params }),

  // Caja / Arqueos
  caja: (params) => api.get('/reportes/caja', { params }),

  // Catálogos para los filtros
  catalogos: {
    clientes:    () => api.get('/clientes'),
    proveedores: () => api.get('/proveedores'),
    usuarios:    () => api.get('/usuarios'),
    productos:   () => api.get('/productos')
  }
};

export default reporteService;
