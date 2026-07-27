FROM ghcr.io/astral-sh/uv:alpine

RUN apk add --update nodejs npm && \
    npm install -g npx

RUN npm install -g @automattic/mcp-wordpress-remote@latest

CMD ["uvx", "mcp-proxy", "--named-server-config", "config.json", "--allow-origin", "*", "--host", "0.0.0.0", "--port", "8365", "--stateless"]
