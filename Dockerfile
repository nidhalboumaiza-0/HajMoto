FROM ghcr.io/cirruslabs/flutter:stable AS build

LABEL org.opencontainers.image.title="HajMoto Web" \
      org.opencontainers.image.description="Flutter stock management showcase for motorcycle parts shops" \
      org.opencontainers.image.source="https://github.com/nidhalboumaiza-0/HajMoto"

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="HajMoto Web" \
      org.opencontainers.image.description="Flutter stock management showcase for motorcycle parts shops" \
      org.opencontainers.image.source="https://github.com/nidhalboumaiza-0/HajMoto"

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
