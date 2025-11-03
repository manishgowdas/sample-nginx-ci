FROM nginx:latest
RUN echo "<h1>Hello from Jenkins CI pipeline!</h1>" > /usr/share/nginx/html/index.html
