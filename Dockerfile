FROM docker.n8n.io/n8nio/n8n:latest

COPY startup.sh /
COPY install-community-nodes.sh /
COPY community-nodes.txt /tmp/

USER root
RUN chmod +x /startup.sh /install-community-nodes.sh
RUN /install-community-nodes.sh

USER node
EXPOSE 5678
ENTRYPOINT ["/bin/sh", "/startup.sh"]
