set -e

export HOST=172.29.236.100:5000

echo "Creating a token to run benchmarks with..."
ADMIN_TOKEN=`python authenticate.py`
SUBJECT_TOKEN=`python authenticate.py`
echo "Admin token: $ADMIN_TOKEN"
echo "Subject token: $SUBJECT_TOKEN"

echo "Warming up Apache..."
ab -c 100 -n 1000 -T 'application/json' http://$HOST/v3/ > /dev/null 2>&1

# This will run until it's interrupted, at which point it will print a
# report summarizing the run.
echo "Benchmarking token validation..."
ab -r -c 4 -t 60 -T 'application/json' -H "X-Auth-Token: $ADMIN_TOKEN" -H "X-Subject-Token: $SUBJECT_TOKEN" http://$HOST/v3/auth/tokens
