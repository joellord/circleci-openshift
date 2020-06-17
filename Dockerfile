FROM node:14 AS builder
COPY . /app
WORKDIR /app
RUN npm install
RUN npm run build

FROM nginx:1.17

## add permissions for nginx user 
COPY ./nginx.conf /etc/nginx/nginx.conf
RUN mkdir /app && \
    chown -R nginx:nginx /app && chmod -R 755 /app && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \ 
    chown -R nginx:nginx /etc/nginx/conf.d 
RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid   
RUN chgrp -R root /var/cache/nginx /var/run /var/log/nginx /var/run/nginx.pid && \
    chmod -R 770 /var/cache/nginx /var/run /var/log/nginx /var/run/nginx.pid

USER nginx
COPY --from=builder /app/dist /app

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]