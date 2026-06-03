const router = require('express').Router();
const { authMiddleware, checkPermission } = require('../middlewares/authMiddleware');
const ctrl = require('../controllers/configuracion.Controller');

// GET es público — logo y nombre aparecen en la página de login
router.get('/', ctrl.obtener);

router.put('/', authMiddleware, checkPermission('editar', 'configuracion'), ctrl.actualizar);

module.exports = router;
