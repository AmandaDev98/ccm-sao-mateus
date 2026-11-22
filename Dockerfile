# Dockerfile de produção (Google Cloud Run): React + Django no mesmo serviço.
# Para desenvolvimento local continue usando o docker-compose.yml.

# 1) Build do frontend React
FROM node:22-slim AS frontend
WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
# API no mesmo endereço do site, então a URL base fica vazia
RUN VITE_API_URL= npm run build

# 2) Backend Django servindo a API e o build do React
FROM python:3.13-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_DEBUG=False
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/ ./
COPY --from=frontend /frontend/dist ./frontend_dist
RUN python manage.py collectstatic --noinput
CMD ["sh", "iniciar.sh"]
