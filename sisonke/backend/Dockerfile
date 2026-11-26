# Build stage
FROM node:20-alpine AS build

WORKDIR /app

ENV NPM_CONFIG_FETCH_RETRIES=5 \
    NPM_CONFIG_FETCH_RETRY_MINTIMEOUT=20000 \
    NPM_CONFIG_FETCH_RETRY_MAXTIMEOUT=120000 \
    NPM_CONFIG_MAXSOCKETS=5

COPY package*.json ./
RUN NODE_OPTIONS="--dns-result-order=ipv4first" npm ci --no-audit --no-fund

COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
COPY --from=build /app/node_modules ./node_modules
RUN npm prune --omit=dev --no-audit --no-fund

COPY --from=build /app/dist ./dist
COPY src/db/migrations ./src/db/migrations

EXPOSE 3001

CMD ["node", "dist/index.js"]
