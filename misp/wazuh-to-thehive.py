# Wazuh → TheHive Alert Forwarder (Simplified for SOC Lab)

import requests
import json

THEHIVE_URL = "http://thehive:9000/api/alert"
HEADERS = {"Content-Type": "application/json"}

def send_to_thehive(alert):
    payload = {
        "title": alert.get("rule", {}).get("description", "Wazuh Alert"),
        "description": json.dumps(alert, indent=2),
        "type": "external",
        "source": "wazuh",
        "severity": alert.get("rule", {}).get("level", 1)
    }

    response = requests.post(THEHIVE_URL, headers=HEADERS, data=json.dumps(payload))
    return response.status_code

# Example usage
if __name__ == "__main__":
    sample_alert = {
        "rule": {"description": "SSH Failed Login", "level": 5},
        "agent": {"name": "ubuntu-server"}
    }
    print(send_to_thehive(sample_alert))
