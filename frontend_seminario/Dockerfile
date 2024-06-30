FROM ghcr.io/cirruslabs/flutter:latest
WORKDIR /app
COPY . .
RUN flutter build web
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
