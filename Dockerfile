# Stage 1: Build Flutter Web App
FROM debian:latest AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y curl git unzip

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app
COPY . .

# Enable web support and build
RUN flutter config --enable-web
RUN flutter pub get

# In a real CI/CD pipeline, the variables would be injected here via build args
RUN flutter build web --release \
    --dart-define=OPENWEATHER_API_KEY="" \
    --dart-define=API_KEY="" \
    --dart-define=APP_ID="" \
    --dart-define=MESSAGING_SENDER_ID="" \
    --dart-define=PROJECT_ID=""

# Stage 2: Serve via Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
