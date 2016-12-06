import json

import locust

TOKEN_PATH = 'http://172.29.236.100:5000/v3/auth/tokens'


class Task(locust.TaskSet):
    @locust.task
    def authenticate(self):
        # authenticate for a token and validate it
        with open('auth.json', 'r') as f:
            body = json.loads(f.read())
        headers = {'Content-Type': 'application/json'}
        response = self.client.post(TOKEN_PATH, json=body, headers=headers)
        token = response.headers.get('X-Subject-Token')
        headers = {
            'X-Subject-Token': token,
            'X-Auth-Token': token
        }
        self.client.get(TOKEN_PATH, headers=headers)


class MyLocust(locust.HttpLocust):
    task_set = Task
