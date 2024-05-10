#!/usr/bin/env bash
set -e
set -x

cd backend
mix phx.server &
cd ../frontend
npm run dev &
