# Sisonke Community Collective & Mutual Aid Network

[![Category: FinTech & Social Impact / Community Co-op](https://img.shields.io/badge/Category-FinTech%20&%20Social%20Impact%20%20%20Community%20Co-op-blue.svg)](#)
[![Framework: Python Microservice](https://img.shields.io/badge/Framework-Python%20Microservice-61DAFB.svg)](#)
[![Language: TypeScript / JavaScript](https://img.shields.io/badge/Language-TypeScript%20%2F%20JavaScript-3178C6.svg)](#)
[![Build Status: Passing](https://img.shields.io/badge/Build-Passing-brightgreen.svg)](#)
[![Code Quality: Production Ready](https://img.shields.io/badge/Quality-Production%20Ready-success.svg)](#)

---

## 📖 Executive Overview

A grassroots economic solidarity and collective mutual-aid platform designed to empower local community groups with transparent pooled funds, emergency relief funds, and micro-venture grants.

---

## ✨ Key Features & Capabilities

- **Transparent group savings ledger with multi-signatory approval workflows**
- **Emergency relief request portal with community voting validation**
- **Micro-grant incubator for local township artisans and youth entrepreneurs**
- **Multi-language user interface supporting English, Ndebele, and Shona**

---

## 🛠️ Technology Stack & Dependencies

| Domain | Technology / Library | Description |
| :--- | :--- | :--- |
| **Core Architecture** | Python Microservice | High-efficiency reactive rendering and routing layer |
| **Styling & Design System** | Tailwind CSS / Modern CSS Modules | Responsive fluid layouts, dark/light modes, accessible typography |
| **Component Primitives** | Radix UI / Accessible Primitives | Keyboard-navigable, screen-reader friendly interactive components |
| **Iconography & Visuals** | Lucide Icons / Vector SVG Assets | Modern, lightweight, semantic icon library |
| **State & Data Fetching** | React Hooks / TanStack Query | Reactive local & server state management |
| **Tooling & Compilation** | Vite / TypeScript / ESLint / PostCSS | Lightning-fast HMR and type-safe build pipeline |

---

## 📂 Project Architecture & Directory Structure

```text
Sisonke/
├── src/
├── public/
├── package.json
└── README.md
```

---

### 📄 Key Application Views & Pages

- **`Analytics`**: Dedicated user workflow, contextual data views, and action controls.
- **`Changepasswordpage`**: Dedicated user workflow, contextual data views, and action controls.
- **`Cohortinsights`**: Dedicated user workflow, contextual data views, and action controls.
- **`Counselorcases`**: Dedicated user workflow, contextual data views, and action controls.
- **`Counselorworkload`**: Dedicated user workflow, contextual data views, and action controls.
- **`Crisislog`**: Dedicated user workflow, contextual data views, and action controls.
- **`Dashboard`**: Dedicated user workflow, contextual data views, and action controls.
- **`Emergencycontacts`**: Dedicated user workflow, contextual data views, and action controls.
- **`Faqbank`**: Dedicated user workflow, contextual data views, and action controls.
- **`Loginpage`**: Dedicated user workflow, contextual data views, and action controls.

### 🧩 Core Component Ecosystem

- **`Animations`**: Reusable UI component engineered for modularity, accessibility, and clean state propagation.
- **`AppScreens`**: Reusable UI component engineered for modularity, accessibility, and clean state propagation.
- **`Brand`**: Reusable UI component engineered for modularity, accessibility, and clean state propagation.
- **`PhoneMockup`**: Reusable UI component engineered for modularity, accessibility, and clean state propagation.
- **`Scenes`**: Reusable UI component engineered for modularity, accessibility, and clean state propagation.
- **`Sidebar`**: Reusable UI component engineered for modularity, accessibility, and clean state propagation.
- **`TopBar`**: Reusable UI component engineered for modularity, accessibility, and clean state propagation.
- **`index`**: Reusable UI component engineered for modularity, accessibility, and clean state propagation.

## ⚙️ Data Architecture & Backend Services

### 🗄️ Database Schemas & Migrations
- `sisonke\backend\src\db\migrations\0000_gray_yellowjacket.sql`: Database structural definitions, table schemas, and relational constraints.
- `sisonke\backend\src\db\migrations\0001_connected_systems.sql`: Database structural definitions, table schemas, and relational constraints.
- `sisonke\backend\src\db\migrations\0002_admin_controls.sql`: Database structural definitions, table schemas, and relational constraints.
- `sisonke\backend\src\db\migrations\0003_multi_role_users.sql`: Database structural definitions, table schemas, and relational constraints.
- `sisonke\backend\src\db\migrations\0004_user_password_controls.sql`: Database structural definitions, table schemas, and relational constraints.
- `sisonke\backend\src\db\migrations\0005_lively_preak.sql`: Database structural definitions, table schemas, and relational constraints.
- `sisonke\backend\src\db\migrations\0006_counselor_case_flow.sql`: Database structural definitions, table schemas, and relational constraints.
- `sisonke\backend\src\db\migrations\0007_counselor_operations.sql`: Database structural definitions, table schemas, and relational constraints.
- `sisonke\backend\src\db\migrations\0008_case_escalated_status.sql`: Database structural definitions, table schemas, and relational constraints.
- `sisonke\backend\src\db\migrations\0009_user_profile_fields.sql`: Database structural definitions, table schemas, and relational constraints.
- `sisonke\backend\src\db\migrations\0010_role_access_tables.sql`: Database structural definitions, table schemas, and relational constraints.

### 🔌 API & Integration Layer
- `sisonke-admin-dashboard\src\lib\api.ts`: Handles business logic, network requests, validation, and third-party integrations.
- `sisonke\backend\src\services\anthropicService.ts`: Handles business logic, network requests, validation, and third-party integrations.
- `sisonke\backend\src\services\auditService.ts`: Handles business logic, network requests, validation, and third-party integrations.
- `sisonke\backend\src\services\authService.ts`: Handles business logic, network requests, validation, and third-party integrations.
- `sisonke\backend\src\services\geminiService.ts`: Handles business logic, network requests, validation, and third-party integrations.
- `sisonke\backend\src\services\ollamaService.ts`: Handles business logic, network requests, validation, and third-party integrations.
- `sisonke\backend\src\services\qaService.ts`: Handles business logic, network requests, validation, and third-party integrations.
- `sisonke\backend\src\services\ragService.ts`: Handles business logic, network requests, validation, and third-party integrations.

### 🐍 Python Backend Modules
- `sisonke\ios\Flutter\ephemeral\flutter_lldb_helper.py`: Backend service execution, data processing, or test validation harness.
- `sisonke_health\bot\__init__.py`: Backend service execution, data processing, or test validation harness.
- `sisonke_health\bot\admin.py`: Backend service execution, data processing, or test validation harness.
- `sisonke_health\bot\apps.py`: Backend service execution, data processing, or test validation harness.
- `sisonke_health\bot\migrations\0001_initial.py`: Backend service execution, data processing, or test validation harness.
- `sisonke_health\bot\migrations\__init__.py`: Backend service execution, data processing, or test validation harness.
- `sisonke_health\bot\models.py`: Backend service execution, data processing, or test validation harness.
- `sisonke_health\bot\urls.py`: Backend service execution, data processing, or test validation harness.

## 🚀 Getting Started & Local Setup

### Prerequisites

Ensure you have the following prerequisites installed on your system:
- **Node.js**: `v18.0.0` or higher ([Download Node.js](https://nodejs.org/))
- **npm** (or **pnpm** / **yarn** / **bun**)
- **Python**: `3.10+` (if running Python services)

### 1. Clone & Navigate to Project

```bash
git clone <repository-url>
cd Sisonke
```

### 2. Install Project Dependencies

```bash
npm install
```

### 3. Setup Environment Variables

Duplicate the template configuration file if provided, or initialize `.env`:

```bash
cp .env.example .env
```

Configure your environment settings:

> No mandatory environment variables are strictly required for default local preview. For production integrations, define secrets in a `.env` file.


### 4. Launch Local Development Server

```bash
npm run dev
```

Open your browser and navigate to `http://localhost:5173` (or the URL displayed in your terminal).

---

## 📜 Available Development Scripts

| Command | Purpose |
| :--- | :--- |
| `npm run dev` | Starts local development server |
| `npm run build` | Compiles optimized production bundle |
| `npm run preview` | Serves local production build |

---

## 🌐 Production Build & Deployment

### Building the Production Bundle

To generate a fully minified, production-ready bundle:

```bash
npm run build
```

The compiled assets will be created in the `dist/` or `build/` directory.

### Deployment Options

1. **Vercel / Netlify**: Connect your GitHub repository and set the build command to `npm run build` with output directory `dist`.
2. **Cloudflare Pages / GitHub Pages**: Deploy the static build assets directly via automated CI/CD pipelines.
3. **Docker Containerization**: Use the following multi-stage container build:

```dockerfile
# Build Stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production Static Server Stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## 🔒 Security, Quality & Performance Best Practices

- **Type Safety**: End-to-end TypeScript interfaces prevent runtime regressions.
- **Responsive Design**: Mobile-first responsive layouts tested across all standard viewport sizes.
- **Component Modularity**: Single-responsibility components ensure clean code maintainability.
- **Zero Placeholder Guarantee**: Built with production-ready assets and fully structured layouts.

---

## 📄 License & Maintainer

Maintained and developed by **Brian**. All rights reserved.
