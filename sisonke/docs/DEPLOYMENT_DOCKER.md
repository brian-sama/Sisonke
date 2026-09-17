# Sisonke VPS Deployment

This deployment runs PostgreSQL, Ollama, the Node backend, and the Flutter Web admin dashboard on one VPS. Host Nginx handles public HTTP/HTTPS.

## 1. DNS

Create an `A` record:

```text
sisonke.mmpzmne.co.zw -> YOUR_VPS_PUBLIC_IP
```

Wait until DNS resolves before enabling the Nginx server block.

## 2. VPS Setup

Install Docker and the Compose plugin:

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 3. Environment

Copy the example and edit strong secrets:

```bash
cp .env.production.example .env.production
nano .env.production
```

Required values:

```text
POSTGRES_PASSWORD=<long random database password>
JWT_SECRET=<at least 32 random characters>
ADMIN_EMAIL=<your admin email>
ADMIN_PASSWORD=<strong admin password, 12+ characters>
```

## 4. Start Production

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml up -d --build
```

The first run creates the PostgreSQL database volume and runs migrations before the backend starts.

The backend and admin dashboard bind only to localhost for host Nginx:

```text
backend: http://127.0.0.1:3001
admin:   http://127.0.0.1:3016
```

Example Nginx server block:

```nginx
server {
    server_name sisonke.mmpzmne.co.zw;

    location /api/ {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /socket.io/ {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }

    location / {
        proxy_pass http://127.0.0.1:3016;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Pull the local AI model once on the VPS:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml exec ollama ollama pull qwen2.5:1.5b
```

## 5. Create First Admin

After the stack is running:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml run --rm backend npm run admin:create
```

## 6. Verify

```bash
curl https://sisonke.mmpzmne.co.zw/api/health
```

Open:

```text
https://sisonke.mmpzmne.co.zw
```

Use the admin email and password from `.env.production`.

## 7. Mobile APK

Build production APK:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://sisonke.mmpzmne.co.zw/api
```

The current built APK is:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 8. Operations

View logs:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml logs -f backend
```

View AI runtime logs:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml logs -f ollama
```

Restart:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml restart
```

Update after pulling new code:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml up -d --build
```

Back up PostgreSQL:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml exec db pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > sisonke-backup.sql
```
