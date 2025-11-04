FROM nginx:latest
RUN echo "<h1>Hello from Jenkins CI pipeline! updated version Hi Rapyder</h1>" > /usr/share/nginx/html/index.html
