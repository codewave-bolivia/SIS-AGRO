import api from '../api/axios';

const categoriasMovimientoService = {
  listar:     (params)     => api.get('/categorias-movimiento', { params }),
  crear:      (data)       => api.post('/categorias-movimiento', data),
  actualizar: (id, data)   => api.put(`/categorias-movimiento/${id}`, data),
  eliminar:   (id)         => api.delete(`/categorias-movimiento/${id}`),
};

export default categoriasMovimientoService;
