FROM atendai/evolution-api:v2.2.3

# Patch: Allow @lid JIDs (used by 98% of WhatsApp contacts in China)
# Evolution API v2.2.3 calls onWhatsApp() which returns exists:false for @lid
# This causes 400 Bad Request for all LID contacts
#
# Two patches needed:
# 1. onWhatsApp() check — return exists:true for @lid JIDs
# 2. The send result handler — handle the response properly for @lid

RUN FILE="/evolution/dist/api/integrations/channel/whatsapp/whatsapp.baileys.service.js" && \
    node -e " \
      const fs = require('fs'); \
      let code = fs.readFileSync(process.env.FILE || '${FILE}', 'utf8'); \
      let changes = 0; \
      \
      /* Patch 1: onWhatsApp validation — skip for @lid */ \
      code = code.replace( \
        /const onWhatsApp = await this\.client\.onWhatsApp\((\w+)\)/g, \
        (match, varName) => { changes++; return 'const onWhatsApp = (String(' + varName + ').includes(\"@lid\")) ? [{exists: true, jid: String(' + varName + ')}] : await this.client.onWhatsApp(' + varName + ')'; } \
      ); \
      \
      /* Patch 2: jid assignment after onWhatsApp — ensure jid is set for @lid */ \
      code = code.replace( \
        /if \(!onWhatsApp\[0\]\?\.exists\)/g, \
        (match) => { changes++; return 'if (!onWhatsApp[0]?.exists && !String(onWhatsApp[0]?.jid || \"\").includes(\"@lid\"))'; } \
      ); \
      \
      /* Patch 3: handle case where formatJid fails on @lid */ \
      code = code.replace( \
        /this\.createJid\((\w+)\)/g, \
        (match, varName) => { changes++; return '(String(' + varName + ').includes(\"@lid\") ? String(' + varName + ') : this.createJid(' + varName + '))'; } \
      ); \
      \
      fs.writeFileSync(process.env.FILE || '${FILE}', code); \
      console.log('Applied ' + changes + ' patches'); \
    "

EXPOSE 8080
