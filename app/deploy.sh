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
npm run start
