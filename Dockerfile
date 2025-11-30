## Multi-stage Dockerfile
# Stage 1: build front (node)
FROM node:18-bullseye AS build-frontend
WORKDIR /app
COPY package.json package-lock.json* ./
COPY src ./src
COPY public ./public
COPY diststyle ./diststyle
COPY vite.config.js ./vite.config.js
RUN npm ci || true
RUN npm run build

# Stage 2: runtime (python)
FROM python:3.11-slim
WORKDIR /opt/stackedit

# Install system deps for common backends; users may need to add pandoc/wkhtmltopdf manually
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy server code
COPY server ./server
# Copy built frontend
COPY --from=build-frontend /app/dist ./dist

# Create venv and install Python deps
RUN python -m venv /opt/stackedit/venv && \
    /opt/stackedit/venv/bin/pip install --upgrade pip && \
    if [ -f server/requirements.txt ]; then /opt/stackedit/venv/bin/pip install -r server/requirements.txt; fi && \
    # install gunicorn as production WSGI server
    /opt/stackedit/venv/bin/pip install gunicorn

ENV PATH="/opt/stackedit/venv/bin:$PATH"
ENV LISTENING_PORT=8080

EXPOSE 8080

CMD ["gunicorn", "-b", "0.0.0.0:8080", "app:app", "-w", "4", "--chdir", "server"]
FROM registry.cn-hangzhou.aliyuncs.com/mafgwo/python311-wkhtmltopdf:1.0

WORKDIR /app
COPY server /app/server
RUN pip install -r /app/server/requirements.txt

COPY dist /app/dist
COPY static /app/static

EXPOSE 8080

CMD [ "python", "server/app.py" ]
