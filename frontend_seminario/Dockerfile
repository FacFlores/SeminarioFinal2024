# Use the official Flutter image as the base image
FROM ghcr.io/cirruslabs/flutter:latest


# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the source code into the container
COPY . .

# Build the Flutter web app
RUN flutter build web

# Use a server to serve the static files
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx server
CMD ["nginx", "-g", "daemon off;"]
