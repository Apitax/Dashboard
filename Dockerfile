FROM nginx

# Update repo listings
RUN apt-get update

# Install system level things
RUN apt-get -y install git pandoc curl wget gnupg

# Install NodeJS and NPM
RUN cd /tmp && curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get -y install nodejs npm
RUN apt-get -y install build-essential

COPY . /tmp/apitax/build

# Add config prior to building
#RUN echo "var config = {}; config.endpoints.core = '${ENDPOINT_CORE}'; module.exports = config;" >> config.js
#RUN echo "window.appConfig = { API_URL: '${API_URL}'} " >> config.js

# Navigate to the web directory and install npm packages and build using webpack
RUN cd /tmp/apitax/build && npm install
 #&& npm run build

# Move the build JavaScript to the the nginx directory
#RUN cp -r /tmp/apitax/build/dist /usr/share/nginx/html/dist

COPY src/pages /usr/share/nginx/html

#RUN rm -rf /tmp/apitax

COPY config.sh /tmp/apitax/build
RUN ["chmod", "+x", "/tmp/apitax/build/config.sh"]

RUN ls -alh /tmp/apitax/build

CMD bash /tmp/apitax/build/config.sh
#&& npm run --prefix /tmp/apitax/build build && cp -r /tmp/apitax/build/dist /usr/share/nginx/html/dist && rm -rf /tmp/apitax


