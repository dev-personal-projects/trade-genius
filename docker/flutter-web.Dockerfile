### Multi-stage Dockerfile for building Flutter web and serving with nginx
FROM cirrusci/flutter:stable AS builder
WORKDIR /app

# Copy pubspec first for efficient caching
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the project
COPY . .

# Ensure web is enabled and build
RUN flutter channel stable && flutter upgrade --force || true
RUN flutter config --enable-web
RUN flutter build web --release

# Serve with nginx
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
