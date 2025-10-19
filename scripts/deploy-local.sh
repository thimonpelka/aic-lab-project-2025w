# ============================================================================
# scripts/deploy_local.sh
# ============================================================================
#!/bin/bash

echo "Deploying to LocalStack..."

# Set LocalStack environment variables
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ENDPOINT_URL_S3=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=eu-west-1

# Check if LocalStack is running
if ! curl -s http://localhost:4566/_localstack/health > /dev/null; then
    echo "LocalStack is not running!"
    exit 1
fi
echo "✅ LocalStack is running"
echo ""

# Check if CDK is installed
if ! command -v cdk &> /dev/null; then
    echo "AWS CDK is not installed! Install with: npm install -g aws-cdk"
    exit 1
fi

# Check if cdklocal is installed
if ! command -v cdklocal &> /dev/null; then
    echo "cdklocal is not installed. Installing..."
    npm install -g aws-cdk-local
fi

# Bootstrap CDK (only needed once)
echo "Bootstrapping CDK for LocalStack..."
cdklocal bootstrap 2>&1 | grep -v "Stack already exists" || true
echo ""

# Synthesize the stack
echo "Synthesizing CDK stack..."
cdk synth --context local=true > /dev/null
if [ $? -ne 0 ]; then
    echo "CDK synthesis failed!"
    exit 1
fi
echo "Stack synthesized successfully"
echo ""

# Deploy the stack
echo "🏗️  Deploying stack to LocalStack..."
cdklocal deploy --context local=true --require-approval never

if [ $? -eq 0 ]; then
    echo ""
    echo "Deployment successful!"
    echo ""
    echo "Stack Outputs:"
    cdklocal outputs --context local=true
    echo ""
    echo "Useful commands:"
    echo "  - List tables: awslocal dynamodb list-tables"
    echo "  - List functions: awslocal lambda list-functions"
    echo "  - View logs: docker-compose logs -f"
else
    echo ""
    echo "Deployment failed!"
    exit 1
fi
