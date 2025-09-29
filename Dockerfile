# ===== STAGE 1: build =====
FROM python:3.12-alpine AS builder
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build
COPY app/requirements.txt .
RUN apk add --no-cache build-base \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt

# ===== STAGE 2: runtime =====
FROM python:3.12-alpine

# Usuario no root
RUN addgroup -S appgrp && adduser -S appuser -G appgrp
WORKDIR /app

# Dependencias desde el builder
COPY --from=builder /install /usr/local

# Código
COPY app /app/

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app.main:app", "--workers", "2", "--threads", "4"]
