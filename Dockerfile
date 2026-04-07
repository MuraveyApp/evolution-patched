FROM atendai/evolution-api:v2.2.3

# Patch: Allow @lid JIDs (98% of WhatsApp contacts in China)
# THREE patch points needed:
# 1. The pre-send validation: if(!o.exists) throw → skip for @lid
# 2. The whatsappNumber return: exists:!!g?.exists → force true for @lid
# 3. The filter: d.filter(u=>u.exists) → also pass @lid

RUN node -e " \
  const fs = require('fs'); \
  const f = '/evolution/dist/api/integrations/channel/whatsapp/whatsapp.baileys.service.js'; \
  let c = fs.readFileSync(f, 'utf8'); \
  let patches = 0; \
  \
  /* Patch 1: Pre-send validation - the MAIN fix */ \
  if (c.includes('if(!o.exists)throw new f(o)')) { \
    c = c.replace('if(!o.exists)throw new f(o)', 'if(!o.exists&&!String(o.jid||\"\").includes(\"@lid\"))throw new f(o)'); \
    patches++; console.log('Patch 1: pre-send validation'); \
  } \
  \
  /* Patch 2: whatsappNumber return */ \
  if (c.includes('exists:!!g?.exists,jid:h,')) { \
    c = c.replace('exists:!!g?.exists,jid:h,', 'exists:!!g?.exists||String(h).includes(\"@lid\"),jid:h,'); \
    patches++; console.log('Patch 2: whatsappNumber return'); \
  } \
  \
  /* Patch 3: filter */ \
  if (c.includes('.filter(u=>u.exists)')) { \
    c = c.replace('.filter(u=>u.exists)', '.filter(u=>u.exists||String(u.jid).includes(\"@lid\"))'); \
    patches++; console.log('Patch 3: filter'); \
  } \
  \
  fs.writeFileSync(f, c); \
  console.log('Total patches:', patches); \
  if (patches === 0) { console.error('NO PATCHES APPLIED'); process.exit(1); } \
" && echo "LID PATCH OK"

EXPOSE 8080
