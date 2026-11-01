# =========================================================
# Stage 1: Build & Dependency Isolation
# =========================================================
FROM python:3.11-alpine AS builder

WORKDIR /app

# Create a clean virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade core tools and install dependencies inside /opt/venv
RUN pip install --no-cache-dir --upgrade pip setuptools wheel urllib3 msgpack
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# =========================================================
# Stage 2: Minimal Production Runtime
# =========================================================
FROM python:3.11-alpine AS runner

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Copy ONLY the clean virtual environment from the builder stage
COPY --from=builder /opt/venv /opt/venv

# Copy application source code
COPY app/ .

# Enforce Non-Root User Execution
RUN chown -R nobody:nogroup /app
USER nobody

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/ || exit 1

CMD ["python", "main.py"]