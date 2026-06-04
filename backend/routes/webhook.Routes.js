const router = require('express').Router();
const ctrl   = require('../controllers/webhook.Controller');

// Ruta pública — CodePay la llama directamente sin JWT
router.post('/codepay', ctrl.confirmarPago);

module.exports = router;
