# Dockerfile
FROM elixir:latest


# Update package lists and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js using the updated method
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs

# Expose the port the app runs on
EXPOSE 4000

