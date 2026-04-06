"""
Rakshak AI - Cyber Safety Web App
Team: Binary Brains | 24-Hour Hackathon Prototype
"""

import time
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)


@app.route("/")
def index():
    return render_template("index.html")


# ──────────────────────────────────────────────
# Feature 1 — Risk Meter  (POST /api/scan)
# ──────────────────────────────────────────────
@app.route("/api/scan", methods=["POST"])
def scan_message():
    data = request.get_json(force=True)
    text = (data.get("text") or "").lower()

    # Simulate AI processing
    time.sleep(1.2)

    if any(kw in text for kw in ["kyc", "bank", "suspend"]):
        return jsonify(
            {
                "status": "danger",
                "emoji": "🔴",
                "title": "High Risk – Scam Detected!",
                "message": "Someone is trying to steal your money!",
                "message_hi": "कोई आपके पैसे चुराने की कोशिश कर रहा है!",
                "tips": [
                    "Do NOT click any link in this message.",
                    "Block the sender immediately.",
                    "Report to Cyber Crime helpline 1930.",
                ],
            }
        )

    if any(kw in text for kw in ["lottery", "urgent"]):
        return jsonify(
            {
                "status": "warning",
                "emoji": "🟡",
                "title": "Suspicious Message",
                "message": "This message looks suspicious. Be careful!",
                "message_hi": "यह संदेश संदिग्ध लगता है। सावधान रहें!",
                "tips": [
                    "Do not share personal details.",
                    "Verify the sender before replying.",
                ],
            }
        )

    return jsonify(
        {
            "status": "safe",
            "emoji": "🟢",
            "title": "Looks Safe",
            "message": "This message appears to be safe.",
            "message_hi": "यह संदेश सुरक्षित प्रतीत होता है।",
            "tips": [],
        }
    )


# ──────────────────────────────────────────────
# Feature 3 — Fact Checker  (POST /api/factcheck)
# ──────────────────────────────────────────────
@app.route("/api/factcheck", methods=["POST"])
def fact_check():
    data = request.get_json(force=True)
    text = (data.get("text") or "").lower()

    # Simulate RAG pipeline
    time.sleep(1.0)

    if any(kw in text for kw in ["free recharge", "jio"]):
        return jsonify(
            {
                "status": "fake",
                "emoji": "❌",
                "title": "Fake News Alert!",
                "message": "This is a known viral scam. Do not forward this message.",
                "message_hi": "यह एक ज्ञात वायरल घोटाला है। इस संदेश को आगे न भेजें।",
            }
        )

    return jsonify(
        {
            "status": "unverified",
            "emoji": "ℹ️",
            "title": "Unverified Claim",
            "message": "This claim could not be verified. Do not forward without checking.",
            "message_hi": "इस दावे की पुष्टि नहीं हो सकी। बिना जाँचे आगे न भेजें।",
        }
    )


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
