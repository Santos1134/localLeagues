#!/bin/bash

# Vercel Manual Deploy Script
# 1. Go to Vercel Dashboard > Your Project > Settings > Git
# 2. Scroll to "Deploy Hooks"
# 3. Create a hook named "Manual Deploy" for branch "main"
# 4. Copy the URL and replace WEBHOOK_URL below

WEBHOOK_URL="REPLACE_WITH_YOUR_DEPLOY_HOOK_URL"

echo "Triggering Vercel deployment..."
curl -X POST "$WEBHOOK_URL"
echo ""
echo "Deployment triggered! Check https://vercel.com/dashboard for status"
