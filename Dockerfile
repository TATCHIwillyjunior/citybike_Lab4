# Stage 1: Build stage
FROM node:20 AS builder

ARG GITHUB_SHA=local-dev
ENV GITHUB_SHA=${GITHUB_SHA}

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# Stage 2: Runtime stage
FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/server.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/dist/build-manifest.json ./dist/build-manifest.json

USER node

EXPOSE 4173
CMD ["node", "server.js"]