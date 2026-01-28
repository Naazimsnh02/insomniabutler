# Use the official Dart image for the build stage.
FROM dart:stable AS build

WORKDIR /app

# Copy the server coffee content into the container.
COPY . .

# Fetch dependencies.
RUN dart pub get

# Compile the server.
RUN dart compile exe bin/main.dart -o bin/main

# Use a slim Debian image for the runtime stage.
FROM debian:slim

WORKDIR /app

# Copy the compiled binary from the build stage.
COPY --from=build /app/bin/main /app/bin/main
# Copy any required assets or configuration files.
COPY --from=build /app/config /app/config
COPY --from=build /app/web /app/web

# Expose the port your server listens on.
EXPOSE 8080

# Run the server.
CMD ["/app/bin/main"]
