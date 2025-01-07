FROM nginx:alpine
# Set the working directory inside the container
WORKDIR /usr/share/nginx/html

# Copy static files to the Nginx default directory
COPY index.html .
COPY script.js .
COPY style.css .

# Expose port 80 to access the application
EXPOSE 80

# Default command to run Nginx
CMD ["nginx", "-g", "daemon off;"]
