import requests

def handler(event, context):
    r = requests.get("https://api.kanye.rest/")
    return {
        event["name"]: r.json()["quote"]
    }