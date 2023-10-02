# Use an official Node.js runtime as a parent image
FROM node:16

# Set the working directory in the container
WORKDIR /

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install application dependencies
RUN npm install

# Copy your application source code to the container
COPY . .

# Expose the port your application will run on
ENV PORT=8080
# EXPOSE 8080

# Define the command to start your application
CMD ["node", "cloudRunN.js"]