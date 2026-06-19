# Backend image for docker-compose
FROM node:20-bookworm-slim

WORKDIR /app

ENV NODE_ENV=production

COPY --chown=node:node package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --chown=node:node . .

USER node

EXPOSE 8080

CMD ["node", "./bin/www"]
