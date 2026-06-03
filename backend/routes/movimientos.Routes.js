const router = require('express').Router();
const { authMiddleware, checkPermission } = require('../middlewares/authMiddleware');
const ctrl = require('../controllers/movimientos.Controller');

router.use(authMiddleware);

// /libro-caja debe ir ANTES de /:id para evitar conflictos de ruta
router.get('/libro-caja', checkPermission('ver',      'movimientos'), ctrl.libroCaja);
router.get('/',           checkPermission('ver',      'movimientos'), ctrl.listar);
router.post('/',          checkPermission('crear',    'movimientos'), ctrl.crear);
router.put('/:id',        checkPermission('editar',   'movimientos'), ctrl.actualizar);
router.delete('/:id',     checkPermission('eliminar', 'movimientos'), ctrl.eliminar);

module.exports = router;
