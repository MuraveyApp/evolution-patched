FROM atendai/evolution-api:v2.2.3

# Force no cache - unique timestamp
RUN echo "build-20260407-001" > /tmp/build_id

# Patch: Allow @lid JIDs
RUN set -ex && \
    FILE="/evolution/dist/api/integrations/channel/whatsapp/whatsapp.baileys.service.js" && \
    ls -la "$FILE" && \
    node -e " \
      const fs=require('fs'); \
      const f='/evolution/dist/api/integrations/channel/whatsapp/whatsapp.baileys.service.js'; \
      let c=fs.readFileSync(f,'utf8'); \
      const before=c.includes('@lid'); \
      c=c.replace('exists:!!g?.exists,jid:h,','exists:!!g?.exists||String(h).includes(\"@lid\"),jid:h,'); \
      c=c.replace('.filter(u=>u.exists)','.filter(u=>u.exists||String(u.jid).includes(\"@lid\"))'); \
      fs.writeFileSync(f,c); \
      const after=c.includes('@lid'); \
      console.log('Before @lid:',before,'After:',after); \
      if(!after){console.error('PATCH FAILED');process.exit(1);} \
    "

EXPOSE 8080
