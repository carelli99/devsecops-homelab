import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/", methods=["GET"])
def health_check():
    return jsonify({
        "status": "healthy",
        "service": "devsecops-microservice",
        "version": "1.0.0",
        "user_id": os.getuid()
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)  # nosec B104