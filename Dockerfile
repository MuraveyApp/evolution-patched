FROM atendai/evolution-api:v2.2.3

# Patch: Allow @lid JIDs (98% of WhatsApp contacts in China use LID format)
# Patch BOTH .js and .mjs files

RUN node -e " \
  const fs = require('fs'); \
  const files = [ \
    '/evolution/dist/api/integrations/channel/whatsapp/whatsapp.baileys.service.js', \
    '/evolution/dist/exceptions/401.exception.mjs' \
  ]; \
  let total = 0; \
  for (const file of files) { \
    try { \
      let code = fs.readFileSync(file, 'utf8'); \
      const orig = code.length; \
      code = code.replace( \
        /return\{exists:\!\!g\?\.exists,jid:h,/g, \
        'return{exists:!!g?.exists||String(h).includes(\"@lid\"),jid:h,' \
      ); \
      code = code.replace( \
        /d\.filter\(u=>u\.exists\)/g, \
        'd.filter(u=>u.exists||String(u.jid).includes(\"@lid\"))' \
      ); \
      const diff = code.length - orig; \
      if (diff !== 0) { \
        fs.writeFileSync(file, code); \
        total += diff; \
        console.log('Patched ' + file + ' (+' + diff + ' chars)'); \
      } else { \
        console.log('No match in ' + file + ', trying alternate patterns...'); \
        /* Try alternate patterns for the .js file */ \
        let changed = false; \
        /* Pattern: exists:!!g?.exists */ \
        if (code.includes('exists:!!g?.exists')) { \
          code = code.replace('exists:!!g?.exists', 'exists:!!g?.exists||String(h||\"\").includes(\"@lid\")'); \
          changed = true; \
          console.log('  Applied exists patch'); \
        } \
        /* Pattern: .filter(u=>u.exists) */ \
        if (code.includes('.filter(u=>u.exists)')) { \
          code = code.replace('.filter(u=>u.exists)', '.filter(u=>u.exists||String(u.jid||\"\").includes(\"@lid\"))'); \
          changed = true; \
          console.log('  Applied filter patch'); \
        } \
        if (changed) { \
          fs.writeFileSync(file, code); \
          total++; \
          console.log('  Saved ' + file); \
        } \
      } \
    } catch(e) { \
      console.log('Skip ' + file + ': ' + e.message); \
    } \
  } \
  console.log('Total patches: ' + total); \
  if (total === 0) process.exit(1); \
  " && echo "LID PATCH SUCCESS"

EXPOSE 8080
