const router = require('express').Router();
const { authMiddleware, checkPermission } = require('../middlewares/authMiddleware');
const ctrl = require('../controllers/configuracion.Controller');

router.use(authMiddleware);

router.get('/', checkPermission('ver',    'configuracion'), ctrl.obtener);
router.put('/', checkPermission('editar', 'configuracion'), ctrl.actualizar);

module.exports = router;
