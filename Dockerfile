FROM atendai/evolution-api:v2.2.3

# Patch: Allow @lid JIDs (98% of WhatsApp contacts in China use LID format)
# The validation in whatsapp.baileys.service rejects @lid because onWhatsApp()
# returns exists:false for them. We patch to force exists:true for @lid JIDs.

RUN FILE="/evolution/dist/exceptions/401.exception.mjs" && \
    node -e " \
      const fs = require('fs'); \
      let code = fs.readFileSync('$FILE', 'utf8'); \
      const orig = code.length; \
      \
      // Patch 1: In the exists return, force true for @lid JIDs \
      // Original: return{exists:!!g?.exists,jid:h, \
      // Patched:  return{exists:!!g?.exists||h.includes('@lid'),jid:h, \
      code = code.replace( \
        'return{exists:!!g?.exists,jid:h,', \
        'return{exists:!!g?.exists||String(h).includes(\"@lid\"),jid:h,' \
      ); \
      \
      // Patch 2: In the filter, also pass @lid contacts through \
      // Original: d.filter(u=>u.exists) \
      // Patched:  d.filter(u=>u.exists||String(u.jid).includes('@lid')) \
      code = code.replace( \
        'd.filter(u=>u.exists)', \
        'd.filter(u=>u.exists||String(u.jid).includes(\"@lid\"))' \
      ); \
      \
      fs.writeFileSync('$FILE', code); \
      console.log('Patched. Diff: ' + (code.length - orig) + ' chars'); \
    " && echo "LID patch applied successfully"

EXPOSE 8080
