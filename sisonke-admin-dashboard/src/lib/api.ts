const DASHBOARD_ROLES = [
  'admin', 'system-admin', 'super-admin', 'counselor',
  'moderator', 'content-admin', 'content-manager', 'safety-reviewer', 'analyst',
];

export function getToken(): string | null {
  return sessionStorage.getItem('sisonke_admin_token');
}

export function clearSession(): void {
  sessionStorage.removeItem('sisonke_admin_token');
  sessionStorage.removeItem('sisonke_admin_user');
}

export function apiFetch(path: string, init?: RequestInit): Promise<Response> {
  const token = getToken();
  return fetch(path, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(init?.headers ?? {}),
    },
  });
}

export async function loginUser(
  email: string,
  password: string,
): Promise<{ token: string; user: { email: string; roles: string[] } }> {
  const res = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });
  const data = await res.json();
  if (!data.success) throw new Error(data.error || 'Login failed');
  const { token, user } = data.data;
  const hasDashboardRole = (user.roles as string[]).some((r) => DASHBOARD_ROLES.includes(r));
  if (!hasDashboardRole) throw new Error('Your account does not have dashboard access.');
  return { token, user };
}
