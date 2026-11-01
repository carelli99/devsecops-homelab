# DevSecOps Pipeline Audit & Post-Mortem Report

## Environment & Architecture
* **Target Workstation:** Windows 11 + WSL2 (Ubuntu 24.04 LTS)
* **Application Stack:** Python 3.11 / Flask / Werkzeug
* **Container Hardening:** Multi-stage Docker build, stripped build tools (`pip`, `setuptools`, `wheel`), non-root execution (`nobody` / UID 65534)
* **Pipeline Gates:** GitHub Actions (Gitleaks -> Bandit -> Docker Build -> Trivy)

---

## Security Incident & Remediation Log

### Incident 1: Static Code Analysis False Positive (Bandit)
* **Branch:** `main`
* **Scanner:** Bandit (Gate 2)
* **Finding:** Rule `B104` flagged `host="0.0.0.0"` as a hardcoded bind to all network interfaces.
* **Pipeline Impact:** Build failed with exit code 1.
* **Remediation:** Verified binding as required for Docker container ingress. Added inline suppression comment `# nosec B104` in `app/main.py`.

### Incident 2: Base Image Dependency Vulnerabilities (Trivy)
* **Branch:** `main`
* **Scanner:** Trivy (Gate 4)
* **Finding:** Detected High-severity CVEs (`CVE-2026-23949`, `CVE-2026-24049`, `CVE-2025-47273`) in pre-installed base image build tools (`setuptools`, `msgpack`, `urllib3`).
* **Pipeline Impact:** Build failed with exit code 1.
* **Remediation:** Converted Dockerfile to a Multi-Stage build. Isolated application dependencies into `/opt/venv`, uninstalled build utilities from the virtualenv, and purged base-image site-packages in the runtime runner stage.

### Incident 3: Controlled Secret Leakage Verification (Gitleaks)
* **Branch:** `dev`
* **Scanner:** Gitleaks 8.24.3 (Gate 1)
* **Finding:** High-entropy string matching `aws-access-token` pattern injected into `app/main.py:7`.
* **Pipeline Impact:** Pipeline terminated at Gate 1 with exit code 2 (`leaks found: 1`). Downstream Docker build and container scan were blocked.
* **Remediation:** Removed hardcoded secret pattern from source code and verified secret management policy enforcement.

---

## Final Security Gate Verification
| Gate | Scanner | Target Scope | Status |
| :--- | :--- | :--- | :--- |
| **Gate 1** | Gitleaks v8.24.3 | Hardcoded Credentials & Tokens | **PASSED** (0 Findings) |
| **Gate 2** | Bandit | Python Application SAST | **PASSED** (0 High/Med Findings) |
| **Gate 3** | Docker Engine | Container Multi-Stage Build | **PASSED** (Non-root `nobody`) |
| **Gate 4** | Trivy | Base OS & Dependency CVEs | **PASSED** (0 High/Critical CVEs) |
