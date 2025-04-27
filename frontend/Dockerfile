# Use Node.js with ARM64 support for Apple Silicon
# Multi-stage build to properly handle Vite in development

# Stage 1: Build stage with all dependencies
FROM node:20-alpine AS builder

# Install netcat for wait-for-it script
RUN apk --no-cache add netcat-openbsd

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies including dev dependencies
RUN npm ci

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
