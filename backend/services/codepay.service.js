const { createHmac } = require('crypto');

/**
 * Firma un payload como JWT con HMAC-SHA256.
 * Se usa para generar el token de checkout que se envía a CodePay.
 */
function signCheckoutToken(payload, secretKey) {
  const header = { alg: 'HS256', typ: 'JWT' };
  const h   = Buffer.from(JSON.stringify(header)).toString('base64url');
  const p   = Buffer.from(JSON.stringify(payload)).toString('base64url');
  const sig = createHmac('sha256', secretKey)
                .update(`${h}.${p}`)
                .digest('base64url');
  return `${h}.${p}.${sig}`;
}

/**
 * Verifica la firma X-Codepay-Signature del webhook.
 * Formato del header: t={timestamp},v1={hmac_hex}
 */
function verifyWebhookSignature(header, rawBody, secret) {
  try {
    const [tPart, v1Part] = header.split(',');
    const timestamp = tPart.split('=')[1];
    const received  = v1Part.split('=')[1];
    const expected  = createHmac('sha256', secret)
                        .update(`${timestamp}.${rawBody}`)
                        .digest('hex');
    if (expected.length !== received.length) return false;
    const a = Buffer.from(expected);
    const b = Buffer.from(received);
    let diff = 0;
    for (let i = 0; i < a.length; i++) diff |= a[i] ^ b[i];
    return diff === 0;
  } catch {
    return false;
  }
}

/**
 * Genera un order_id único para CodePay.
 * Reglas: max 25 chars, solo letras/números/guión_bajo
 */
function generarOrderId() {
  // Ej: VTA_pf7b9og0_abc → 17 chars
  return `VTA_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 5)}`;
}

/**
 * Construye la URL de checkout de CodePay con el JWT firmado.
 */
function buildCheckoutUrl(token) {
  const base    = process.env.CODEPAY_GATEWAY_URL || 'https://pay.codepay.bo';
  const appKey  = process.env.CODEPAY_PUBLIC_KEY;
  return `${base}/checkout/${token}&lang=es&app_key=${appKey}`;
}

module.exports = { signCheckoutToken, verifyWebhookSignature, generarOrderId, buildCheckoutUrl };
