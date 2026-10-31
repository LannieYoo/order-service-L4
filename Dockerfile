# Start with Node.js 24 on the lightweight Alpine Linux image.
FROM node:24-alpine

# Use this folder inside the image for the application.
WORKDIR /usr/src/app

# Copy the dependency list and the file recording exact package versions.
COPY package.json package-lock.json ./

# Install the packages needed to run the service.
RUN npm ci --omit=dev

# Copy the application files, excluding anything in .dockerignore.
COPY . .

# Document the port the application listens on inside the container.
EXPOSE 3000

# Set the default listening port for the application.
ENV PORT=3000

# Start the service when a container is created from this image.
CMD ["node", "index.js"]
