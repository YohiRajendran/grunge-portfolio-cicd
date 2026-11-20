# Stage 1: Build
FROM node:22-bookworm AS builder

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

#install dependencies
RUN npm ci

#copy project source
COPY . .

#Build project 
RUN npm run build

# stage 2 production

FROM node:22-bookworm-slim AS runner

WORKDIR /app

#install static server

RUN npm install -g http-server

#copy build output
COPY --from=builder /app/dist ./dist

EXPOSE 4321

CMD ["http-server", "dist", "-p", "4321", "-a", "0.0.0.0"]