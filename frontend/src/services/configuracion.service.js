import api from '../api/axios';

const configuracionService = {
  obtener:    ()     => api.get('/configuracion'),
  actualizar: (data) => api.put('/configuracion', data),
};

export default configuracionService;
