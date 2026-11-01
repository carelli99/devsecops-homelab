# Step 1: Use an explicit, lightweight minimal base image
FROM python:3.11-alpine

# Set security and performance environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Upgrade all pre-installed base build tools & libraries with findings
RUN pip install --no-cache-dir --upgrade pip setuptools wheel urllib3 msgpack

# Install application dependencies as root before switching users
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY app/ .

# Enforce Non-Root User for Execution Safety
RUN chown -R nobody:nogroup /app
USER nobody

# Expose non-privileged container port
EXPOSE 5000

# Health check instruction for container runtime
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/ || exit 1

CMD ["python", "main.py"]