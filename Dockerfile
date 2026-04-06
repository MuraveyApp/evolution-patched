FROM atendai/evolution-api:v2.2.3

# Cache bust
ARG CACHEBUST=7

# Patch: Allow @lid JIDs (98% of WhatsApp contacts in China use LID format)
RUN node -e " \
  const fs = require('fs'); \
  const file = '/evolution/dist/api/integrations/channel/whatsapp/whatsapp.baileys.service.js'; \
  let code = fs.readFileSync(file, 'utf8'); \
  const orig = code.length; \
  code = code.replace('exists:!!g?.exists,jid:h,', 'exists:!!g?.exists||String(h).includes(\"@lid\"),jid:h,'); \
  code = code.replace('.filter(u=>u.exists)', '.filter(u=>u.exists||String(u.jid).includes(\"@lid\"))'); \
  fs.writeFileSync(file, code); \
  console.log('Patched .js: ' + (code.length - orig) + ' chars diff'); \
  console.log('Verify @lid in code: ' + code.includes('@lid')); \
  " && echo "LID PATCH SUCCESS"

EXPOSE 8080
