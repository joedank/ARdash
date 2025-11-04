# Debian-based image for smoother native modules and headless browsers
FROM node:20-bullseye-slim

# Install system dependencies (Puppeteer/Chromium, build tools, fonts, healthcheck utils)
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    netcat-openbsd \
    python3 \
    build-essential \
    chromium \
    libnss3 \
    libfreetype6 \
    libharfbuzz0b \
    ca-certificates \
    fonts-freefont-ttf \
    fontconfig \
    dbus \
  && rm -rf /var/lib/apt/lists/*

# Set environment for Puppeteer to use system Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (lockfile currently out-of-sync with peers)
RUN npm install

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
