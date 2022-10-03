# # FROM node:lts-alpine
# # ENV NODE_ENV=production
# # WORKDIR /src
# # COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
# # RUN npm install --production --silent && mv node_modules ../
# # COPY . .
# # EXPOSE 3000
# # RUN chown -R node /src
# # USER node
# # CMD ["npm", "start"]
# # syntax=docker/dockerfile:1.4

# FROM node:lts AS development

# ENV CI=true
# ENV PORT=3000

# WORKDIR /code
# COPY package.json /code/package.json
# COPY package-lock.json /code/package-lock.json
# RUN npm ci --legacy-peer-deps
# COPY . /code

# CMD [ "npm", "start" ]

# # FROM development AS builder

# # RUN npm run build

# # FROM development as dev-envs
# # RUN <<EOF
# # apt-get update
# # apt-get install -y --no-install-recommends git
# # EOF

# # RUN <<EOF
# # useradd -s /bin/bash -m vscode
# # groupadd docker
# # usermod -aG docker vscode
# # EOF
# # install Docker tools (cli, buildx, compose)
# # COPY --from=gloursdocker/docker / /
# # CMD [ "npm", "start" ]

# # FROM nginx:1.13-alpine

# # COPY --from=builder /code/build /usr/share/nginx/html
# Stage 1
FROM node:14 as build-stage

WORKDIR /front
COPY package.json .
RUN npm install
COPY . .

ARG REACT_APP_API_BASE_URL
ENV REACT_APP_API_BASE_URL=$REACT_APP_API_BASE_URL

RUN npm run build

# Stage 2
FROM nginx:1.17.0-alpine

COPY --from=build-stage /front/build /usr/share/nginx/html
EXPOSE $REACT_DOCKER_PORT

CMD nginx -g 'daemon off;'
