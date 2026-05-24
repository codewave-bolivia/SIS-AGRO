const router = require('express').Router();
const ctrl = require('../controllers/ventas.Controller');
const { authMiddleware, checkPermission } = require('../middlewares/authMiddleware');

router.use(authMiddleware);

router.get('/', checkPermission('ver', 'ventas'), ctrl.listar);
router.get('/:id', checkPermission('ver', 'ventas'), ctrl.obtener);
router.post('/', checkPermission('crear', 'ventas'), ctrl.crear);
router.patch('/:id/anular', checkPermission('anular', 'ventas'), ctrl.anular);

module.exports = router;
