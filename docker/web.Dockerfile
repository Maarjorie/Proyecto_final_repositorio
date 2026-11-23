# Interfaz Angular servida con nginx
FROM node:24-alpine AS compilar
WORKDIR /src
COPY frontend-angular/package.json frontend-angular/package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY frontend-angular/ ./
RUN npx ng build
# En Docker la API se llama por /api
RUN echo "window.API_URL = '/api';" > dist/frontend-angular/browser/config.js

FROM nginx:1.27-alpine
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=compilar /src/dist/frontend-angular/browser /usr/share/nginx/html
