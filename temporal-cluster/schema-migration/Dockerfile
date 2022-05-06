FROM temporalio/auto-setup:1.15.1


FROM public.ecr.aws/lambda/nodejs:14

COPY --from=0 /etc/temporal/schema /etc/temporal/schema
COPY --from=0 /usr/local/bin/temporal-sql-tool /usr/local/bin/temporal-sql-tool
COPY --from=0 /usr/local/bin/temporal-cassandra-tool /usr/local/bin/temporal-cassandra-tool
COPY --from=0 /usr/local/bin/tctl  /usr/local/bin/tctl
COPY --from=0 /usr/local/bin/tctl-authorization-plugin  /usr/local/bin/tctl-authorization-plugin

RUN yum install -y nc

# Copy handler function and package.json
COPY src/ src/
COPY scripts/ scripts/
COPY package.json .
COPY package-lock.json .

# Install NPM dependencies for function
RUN npm ci --production

# Set the CMD to your handler
CMD [ "src/index.handler" ]



