# DevSecOps Flask Microservice & Automated Security Pipeline

A production-grade, containerized Flask microservice featuring an automated **DevSecOps CI/CD security pipeline** with strict shift-left security gates, multi-stage Docker hardening, and zero-vulnerability compliance.

---

## Architecture & Security Highlights

* **Application Stack:** Python 3.11, Flask, Werkzeug.
* **Container Hardening:** 
  * **Multi-Stage Build:** Isolates application dependencies in a virtual environment (`/opt/venv`) and completely strips build tools (`pip`, `setuptools`, `wheel`) from the final runtime image.
  * **Minimal Attack Surface:** Built on Alpine Linux (`python:3.11-alpine`) with all unneeded system site-packages purged.
  * **Least Privilege Execution:** Runs under an unprivileged user account (`nobody`, UID 65534).
* **Local Orchestration:** Docker Compose support for simplified local development and health checks.

---

## Automated Security Pipeline (GitHub Actions)

The repository enforces automated security controls on every push and pull request through four sequential gates:

1. **Gate 1 (Gitleaks):** Scans code commits and diffs for hardcoded API keys, tokens, and credentials.
2. **Gate 2 (Bandit):** Performs Static Application Security Testing (SAST) on Python source code to detect insecure coding patterns.
3. **Gate 3 (Docker Engine):** Builds the hardened multi-stage container image and enforces non-root safety constraints.
4. **Gate 4 (Trivy):** Scans the built container image for base OS and language-specific package vulnerabilities (blocking on High/Critical CVEs).

---

## Repository Structure

```text
devsecops-homelab/
├── .github/
│   └── workflows/
│       └── devsecops-pipeline.yml   # Automated 4-stage CI/CD pipeline
├── app/
│   ├── main.py                      # Flask microservice source code
│   └── requirements.txt             # Python dependencies
├── Dockerfile                       # Multi-stage hardened container build
├── docker-compose.yml               # Local container orchestration & healthchecks
├── SECURITY-POSTMORTEM.md           # Audit logs, incident reports, and remediation history
└── README.md                        # Project documentation
```

---

## Local Quick Start

Clone the repository and run the service locally using Docker Compose:

```bash
# 1. Clone the repository
git clone https://github.com/carelli99/devsecops-homelab.git
cd devsecops-homelab

# 2. Build and start the container stack in the background
docker compose up -d --build

# 3. Test the health check endpoint
curl -i http://localhost:5000/

# 4. View container logs
docker compose logs -f

# 5. Stop the containers
docker compose down
```

---

## Security Audit & Compliance

For detailed documentation on security findings resolved during development, false-positive suppressions, and controlled vulnerability injection tests, refer to the [SECURITY-POSTMORTEM.md](SECURITY-POSTMORTEM.md).