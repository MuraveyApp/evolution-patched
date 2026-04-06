FROM atendai/evolution-api:v2.2.3

# Patch: Allow @lid JIDs (used by 98% of WhatsApp contacts in China)
# Evolution API v2.2.3 calls onWhatsApp() which returns exists:false for @lid
# This patch makes it skip the check for @lid JIDs
RUN FILE="/evolution/dist/api/integrations/channel/whatsapp/whatsapp.baileys.service.js" && \
    node -e " \
      const fs = require('fs'); \
      let code = fs.readFileSync('${FILE}', 'utf8'); \
      const orig = code.length; \
      code = code.replace( \
        /const onWhatsApp = await this\.client\.onWhatsApp\((\w+)\)/g, \
        'const onWhatsApp = (String(\$1).includes(\"@lid\")) ? [{exists: true, jid: String(\$1)}] : await this.client.onWhatsApp(\$1)' \
      ); \
      fs.writeFileSync('${FILE}', code); \
      console.log('Patched ' + (code.length - orig) + ' chars diff'); \
    "

EXPOSE 8080
