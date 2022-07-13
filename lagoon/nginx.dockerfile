ARG RUBY_IMAGE
FROM ${RUBY_IMAGE} as cli

FROM uselagoon/nginx:latest

COPY --from=cli /app /app

COPY lagoon/nginx/nginx.conf /etc/nginx/conf.d/app.conf


EXPOSE 8080

# tells the local development environment on which port we are running
ENV LAGOON_LOCALDEV_HTTP_PORT=8080

