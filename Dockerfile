# Stage 1: Build stage
FROM node:22-alpine AS build

WORKDIR /app

# Copy package manifests first to leverage Docker layer caching
COPY package*.json ./

# Install dependencies deterministically
RUN npm ci

# Copy remaining source code and build production bundle
COPY . .
RUN npm run build

# Stage 2: Production runtime stage
FROM nginx:alpine

# Copy custom Nginx configuration for client-side SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy only compiled static assets from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

