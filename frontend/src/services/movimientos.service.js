import api from '../api/axios';

const movimientosService = {
  libroCaja:  (params)     => api.get('/movimientos/libro-caja', { params }),
  listar:     (params)     => api.get('/movimientos', { params }),
  crear:      (data)       => api.post('/movimientos', data),
  actualizar: (id, data)   => api.put(`/movimientos/${id}`, data),
  eliminar:   (id)         => api.delete(`/movimientos/${id}`),
};

export default movimientosService;
