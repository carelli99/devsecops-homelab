# =========================================================
# Stage 1: Build & Dependency Isolation
# =========================================================
FROM python:3.11-alpine AS builder

WORKDIR /app

# Create isolated virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install application requirements
RUN pip install --no-cache-dir --upgrade pip
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

# Completely wipe default base image system site-packages (pip/setuptools/wheel vendor clutter)
RUN find /usr/local/lib/python3.11/site-packages -mindepth 1 -delete

# Copy only the clean isolated virtual environment from Stage 1
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