-- Migración: Columnas para integración con CodePay (pagos QR)
ALTER TABLE `venta`
  ADD COLUMN `codepay_order_id` VARCHAR(25)  NULL DEFAULT NULL AFTER `observaciones`,
  ADD COLUMN `codepay_tx_id`    VARCHAR(60)  NULL DEFAULT NULL AFTER `codepay_order_id`,
  ADD COLUMN `codepay_voucher`  VARCHAR(20)  NULL DEFAULT NULL AFTER `codepay_tx_id`;
