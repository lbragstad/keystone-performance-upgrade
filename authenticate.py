import json
import time

import requests


TOKEN_PATH = 'http://172.29.236.100:5000/v3/auth/tokens'


def authenticate():
    with open('auth.json', 'r') as f:
        body = json.loads(f.read())
    headers = {'Content-Type': 'application/json'}
    response = requests.post(TOKEN_PATH, json=body, headers=headers)
    assert response.status_code == 201
    return response.headers.get('X-Subject-Token')


def validate(token):
    headers = {
        'X-Subject-Token': token,
        'X-Auth-Token': token
    }
    return requests.get(TOKEN_PATH, headers=headers)


if __name__ == '__main__':
    token = authenticate()
    response = validate(token)
    while response.status_code == 401:
        time.sleep(1)
        token = authenticate()
        response = validate(token)
    else:
        print token
