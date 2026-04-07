FROM atendai/evolution-api:v2.2.3

# Patch /evolution/dist/main.js — the ACTUAL runtime bundle
RUN node -e " \
  const fs = require('fs'); \
  const f = '/evolution/dist/main.js'; \
  let c = fs.readFileSync(f, 'utf8'); \
  let p = 0; \
  \
  if (c.includes('if(!o.exists)throw new f(o)')) { \
    c = c.replace(/if\(!o\.exists\)throw new f\(o\)/g, 'if(!o.exists&&!String(o.jid||o.number||\"\").includes(\"@lid\"))throw new f(o)'); \
    p++; \
  } \
  if (c.includes('exists:!!g?.exists,jid:h,')) { \
    c = c.replace(/exists:!!g\?\.exists,jid:h,/g, 'exists:!!g?.exists||String(h).includes(\"@lid\"),jid:h,'); \
    p++; \
  } \
  if (c.includes('.filter(u=>u.exists)')) { \
    c = c.replaceAll('.filter(u=>u.exists)', '.filter(u=>u.exists||String(u.jid||\"\").includes(\"@lid\"))'); \
    p++; \
  } \
  fs.writeFileSync(f, c); \
  console.log('Patches applied:', p); \
  if (p === 0) process.exit(1); \
" && echo "MAIN.JS PATCHED"

EXPOSE 8080
