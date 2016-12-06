set -e

export HOST=172.29.236.100:5000

echo "Warming up Apache..."
ab -c 100 -n 1000 -T 'application/json' http://$HOST/v3/ > /dev/null 2>&1

# I ended up replacing this benchmarking script with locust because the
# `authenticate.py` script would get a token, and continue to use that for the
# entire benchmark. This wasn't the intended behavior. I want to have each
# request authenticate for two tokens, and then one token would be used to
# validate the other. The nice thing about this approach is that it mixes
# authentication and validation together. What really happened is ApacheBench
# would get a token using `authenticate.py`, but continue to validate that
# token over and over, it wouldn't use new tokens on every request. I made a
# feeble attempt at covering that case with ApacheBench but I ended up using
# Locust to write a task instead. The downside is that Locust doesn't format
# the results as nicely as ApacheBench does, but we were still able to
# accomplish the test and prove rolling upgrades work.
echo "Benchmarking token validation..."
ab -r -c 4 -t 0 -T 'application/json' -H "X-Auth-Token: `python authenticate.py`" -H "X-Subject-Token: `python authenticate.py`" http://$HOST/v3/auth/tokens
