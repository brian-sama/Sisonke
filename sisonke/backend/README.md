# Sisonke Backend API

A lightweight Express.js API for the Sisonke Wellness App, focused on mental health, SRHR, and emergency support for young people in Zimbabwe.

## Tech Stack

- **Framework**: [Express.js](https://expressjs.com/)
- **Language**: [TypeScript](https://www.typescriptlang.org/)
- **ORM**: [Drizzle ORM](https://orm.drizzle.team/)
- **Database**: [Neon PostgreSQL](https://neon.tech/)
- **Validation**: [Zod](https://zod.dev/)
- **Deployment**: [Vercel](https://vercel.com/)

## Getting Started

### Prerequisites

- Node.js 18+ LTS
- A Neon PostgreSQL database (or any PostgreSQL)

### Installation

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file based on `.env.example`:
   ```bash
   cp .env.example .env
   ```
   Update the `DATABASE_URL` with your Neon connection string.

### Database Setup

1. Generate migrations:
   ```bash
   npm run db:generate
   ```

2. Run migrations:
   ```bash
   npm run db:migrate
   ```

3. (Optional) Open Drizzle Studio to view data:
   ```bash
   npm run db:studio
   ```

### Development

Run the development server with hot reload:
```bash
npm run dev
```

The API will be available at `http://localhost:3001`.

## API Documentation

### Authentication
- `POST /api/auth/register` - Create user account
- `POST /api/auth/login` - Get JWT token
- `POST /api/auth/guest` - Get guest session token
- `POST /api/auth/refresh` - Refresh JWT token

### Resources
- `GET /api/resources` - List articles (with search/filter)
- `GET /api/resources/:id` - Get article details
- `POST /api/resources` - Create article (Admin)
- `PUT /api/resources/:id` - Update article (Admin)
- `DELETE /api/resources/:id` - Delete article (Admin)

### Q&A System
- `GET /api/questions` - List public questions
- `GET /api/questions/:id` - Get question with answers
- `POST /api/questions` - Submit anonymous question

### Emergency Toolkit
- `GET /api/emergency/contacts` - Get helpline numbers
- `GET /api/emergency/toolkit` - Get breathing/grounding guides
- `GET /api/emergency/quick-exit` - Neutral content for quick exit

## Deployment to Vercel

1. Install Vercel CLI: `npm i -g vercel`
2. Run `vercel` in the backend directory.
3. Configure environment variables in Vercel dashboard.

## License

MIT
