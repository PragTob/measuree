#!/usr/bin/env bash
set -e
set -x

cd backend && mix credo && mix format --check-formatted && mix test
cd ../frontend && npm run lint && npm run check-formatted && npm test
