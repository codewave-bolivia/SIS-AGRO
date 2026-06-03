import { createContext, useContext, useState, useEffect, useCallback } from 'react';
import axios from 'axios';

const ConfigContext = createContext(null);

const CONFIG_DEFECTO = {
  nombre_empresa: 'SIS-AGRO',
  nit: null,
  direccion: null,
  ciudad: null,
  telefono: null,
  correo: null,
  logo: null,
};

export function ConfigProvider({ children }) {
  const [configuracion, setConfiguracion] = useState(CONFIG_DEFECTO);

  const recargarConfig = useCallback(async () => {
    try {
      const base = import.meta.env.VITE_API_URL || '';
      const res = await axios.get(`${base}/configuracion`);
      setConfiguracion({ ...CONFIG_DEFECTO, ...res.data });
    } catch { /* silencioso — usa valores por defecto */ }
  }, []);

  useEffect(() => { recargarConfig(); }, [recargarConfig]);

  return (
    <ConfigContext.Provider value={{ configuracion, recargarConfig }}>
      {children}
    </ConfigContext.Provider>
  );
}

export function useConfig() {
  return useContext(ConfigContext);
}
