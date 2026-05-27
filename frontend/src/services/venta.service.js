import api from '../api/axios';

const ventaService = {
  listarProductosPOS: () => api.get('/ventas/pos-productos'),
  listar:  () => api.get('/ventas'),
  obtener: (id) => api.get(`/ventas/${id}`),
  crear:   (data) => api.post('/ventas', data),
  anular:  (id) => api.patch(`/ventas/${id}/anular`)
};

export default ventaService;
