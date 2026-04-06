FROM atendai/evolution-api:v2.2.3

# Find the EXACT file and function to patch
RUN echo "=== JS FILES ===" && \
    find /evolution -name "*.js" -path "*baileys*" 2>/dev/null && \
    echo "=== DIST STRUCTURE ===" && \
    ls -la /evolution/dist/ 2>/dev/null && \
    ls -la /evolution/dist/src/ 2>/dev/null | head -10 && \
    echo "=== FIND onWhatsApp ===" && \
    grep -rln "onWhatsApp" /evolution/dist/ 2>/dev/null | head -5 && \
    echo "=== EXACT PATTERN ===" && \
    FILE=$(grep -rln "onWhatsApp" /evolution/dist/ 2>/dev/null | head -1) && \
    echo "File: $FILE" && \
    grep -n "onWhatsApp" "$FILE" | head -10

EXPOSE 8080
