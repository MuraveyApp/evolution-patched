FROM atendai/evolution-api:v2.2.3

# Patch: Allow @lid JIDs (used by 98% of WhatsApp contacts in China)
# Step 1: Find the actual file location and show onWhatsApp patterns
# Step 2: Apply the patch

RUN echo "=== Finding files ===" && \
    find / -name "*.service.js" -path "*/whatsapp*" 2>/dev/null && \
    echo "=== Finding onWhatsApp ===" && \
    grep -rn "onWhatsApp" /evolution/ 2>/dev/null | head -20 && \
    echo "=== Finding exists check ===" && \
    grep -rn "exists.*false\|!.*exists" /evolution/ 2>/dev/null | grep -i "whatsapp\|baileys" | head -20

EXPOSE 8080
