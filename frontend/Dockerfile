# Use Node.js with ARM64 support for Apple Silicon
FROM node:20-alpine

# Install netcat for wait-for-it script
RUN apk --no-cache add netcat-openbsd

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy project files
COPY . .

# Expose port
EXPOSE 5173

# Use development mode only - run the fix script first, then start the dev server
CMD ["sh", "-c", "node fix-imports.js && npm run dev"]
