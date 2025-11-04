# Use Debian-based Node image for smoother native binary support in dev
FROM node:20-bullseye-slim AS builder

# Install netcat for wait-for-it and common tools
RUN apt-get update \
  && apt-get install -y --no-install-recommends netcat-openbsd \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies including dev dependencies deterministically
RUN npm ci --include=optional

# Copy project files
COPY . .

# Ensure the fix-imports script is executable
RUN chmod +x fix-imports.js

# Run the fix script
RUN node fix-imports.js

# Stage 2: Development image that uses all the dependencies
FROM builder AS development

# Expose port
EXPOSE 5173

# Start the dev server
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# Stage 3: Build the production assets
FROM builder AS build

# Build the production assets
RUN npm run build

# Stage 4: Production image with minimal dependencies
FROM nginx:alpine AS production

# Copy built files from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port
EXPOSE 80

# Default to development stage when building without a target
FROM development
