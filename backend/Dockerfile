# Use Node.js with ARM64 support for Apple Silicon
FROM node:20-alpine

# Install dependencies for Puppeteer, healthcheck, wait-for-it script, and build tools
RUN apk --no-cache add \
    curl \
    netcat-openbsd \
    python3 \
    make \
    g++ \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    fontconfig \
    dbus

# Set environment variables for Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies and add bcryptjs as an alternative to bcrypt
RUN npm install && npm install bcryptjs

# Copy project files
COPY . .

# Create uploads directory and subdirectories if they don't exist
RUN mkdir -p uploads/estimates uploads/invoices uploads/photos uploads/logos

# Copy health check script
COPY healthcheck.sh /app/healthcheck.sh
RUN chmod +x /app/healthcheck.sh

# Expose port
EXPOSE 3000

# Add healthcheck
HEALTHCHECK --interval=10s --timeout=5s --start-period=15s --retries=3 CMD /app/healthcheck.sh

# Make entrypoint script executable
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# Command to run migrations and then start the app
CMD ["/app/docker-entrypoint.sh"]
