# =========================================================
# Stage 1: Build & Dependency Isolation
# =========================================================
FROM python:3.11-alpine AS builder

WORKDIR /app

# 1. Create a bare virtualenv without legacy seeded setuptools/pip
RUN python -m venv --without-pip /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 2. Fetch latest standalone pip directly
RUN wget -q https://bootstrap.pypa.io/get-pip.py -O get-pip.py && \
    python get-pip.py --no-cache-dir && \
    rm get-pip.py

# 3. Install application requirements
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Strip build-only utilities (setuptools, wheel, pip) from runtime environment
RUN pip uninstall -y setuptools wheel pip || true && \
    find /opt/venv -type d -name "setuptools*" -exec rm -rf {} + && \
    find /opt/venv -type d -name "wheel*" -exec rm -rf {} + && \
    find /opt/venv -type d -name "pip*" -exec rm -rf {} +

# =========================================================
# Stage 2: Minimal Production Runtime
# =========================================================
FROM python:3.11-alpine AS runner

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Wipe default base image system site-packages
RUN rm -rf /usr/local/lib/python3.11/site-packages/*

# Copy only the hardened, production-only virtual environment
COPY --from=builder /opt/venv /opt/venv

# Copy application code
COPY app/ .

# Enforce Non-Root User Execution
RUN chown -R nobody:nogroup /app
USER nobody

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/ || exit 1

CMD ["python", "main.py"]