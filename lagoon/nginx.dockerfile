ARG CLI_IMAGE
FROM ${CLI_IMAGE} as cli

FROM uselagoon/nginx-drupal:latest

COPY --from=cli /app /app

COPY lagoon/nginx/nginx.conf /etc/nginx/conf.d/app.conf

# Define where the Drupal Root is located
ENV WEBROOT=web
