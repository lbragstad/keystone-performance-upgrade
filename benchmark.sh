set -e

export HOST=172.29.236.100:5000

echo "Warming up Apache..."
ab -c 100 -n 1000 -T 'application/json' http://$HOST/v3/ > /dev/null 2>&1

# This will run until it's interrupted, at which point it will print a
# report summarizing the run. This benchmarks both token creation and token
# validation because we're getting new tokens to validate on every request.
echo "Benchmarking token validation..."
ab -r -c 4 -t 0 -T 'application/json' -H "X-Auth-Token: `python authenticate.py`" -H "X-Subject-Token: `python authenticate.py`" http://$HOST/v3/auth/tokens
