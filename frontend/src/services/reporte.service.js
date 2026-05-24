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

  // Catálogos para los filtros
  catalogos: {
    clientes: () => api.get('/clientes'),
    proveedores: () => api.get('/proveedores'),
    usuarios: () => api.get('/usuarios'), // asumiendo que existe o adaptaremos
    productos: () => api.get('/productos')
  }
};

export default reporteService;
