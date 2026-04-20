set -e

# Load nvm for non-interactive SSH sessions if it is installed.
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
fi

# GitHub SSH actions often use a non-interactive shell, so PATH from
# ~/.bashrc may not be available. Add the Node.js bin path explicitly.
export PATH="$HOME/.nvm/versions/node/v24.15.0/bin:$PATH"

cd ~/ci-cd-110xdevs

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is not installed or not available in PATH on the EC2 instance."
  exit 1
fi

git pull origin main
npm install
npm run build

# Stop the previous Next.js process if one is already running.
pkill -f "node_modules/next/dist/bin/next start" || true

APP_DIR="$HOME/ci-cd-110xdevs"
APP_LOG="$APP_DIR/app.log"
NODE_BIN="$HOME/.nvm/versions/node/v24.15.0/bin"

# Start the app detached from the SSH session so GitHub Actions can finish cleanly.
setsid env PATH="$NODE_BIN:$PATH" sh -c "cd $APP_DIR && nohup npm run start > $APP_LOG 2>&1 < /dev/null &" >/dev/null 2>&1

sleep 5

if ! pgrep -f "node_modules/next/dist/bin/next start" >/dev/null 2>&1; then
  echo "App failed to stay running after deploy."
  tail -n 50 "$APP_LOG" || true
  exit 1
fi
