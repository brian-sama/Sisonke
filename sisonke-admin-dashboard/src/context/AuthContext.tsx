import React, { createContext, useContext, useState } from 'react';
import { AdminUser, AuthState } from '../types';
import { loginUser, clearSession } from '../lib/api';

const AuthContext = createContext<AuthState | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<AdminUser | null>(() => {
    const saved = sessionStorage.getItem('sisonke_admin_user');
    return saved ? JSON.parse(saved) : null;
  });
  const [authError, setAuthError] = useState<string | null>(null);
  const [authLoading, setAuthLoading] = useState(false);

  const login = async (email: string, password: string) => {
    setAuthLoading(true);
    setAuthError(null);
    try {
      const { token, user: userData } = await loginUser(email, password);
      sessionStorage.setItem('sisonke_admin_token', token);
      sessionStorage.setItem(
        'sisonke_admin_user',
        JSON.stringify({
          email: userData.email,
          roles: userData.roles,
          name: (userData as any).name,
          avatarUrl: (userData as any).avatarUrl,
          mustChangePassword: userData.mustChangePassword,
        })
      );
      setUser({
        email: userData.email,
        roles: userData.roles,
        name: (userData as any).name,
        avatarUrl: (userData as any).avatarUrl,
        mustChangePassword: userData.mustChangePassword,
      });
    } catch (err: any) {
      setAuthError(err.message || 'Login failed');
    } finally {
      setAuthLoading(false);
    }
  };

  const logout = () => {
    setUser(null);
    clearSession();
  };

  const finishPasswordChange = () => {
    if (user) {
      const updated = { ...user, mustChangePassword: false };
      sessionStorage.setItem('sisonke_admin_user', JSON.stringify(updated));
      setUser(updated);
    }
  };

  const hasRole = (role: string): boolean => {
    if (!user) return false;
    const normRole = role.toLowerCase();
    return user.roles.some((r) => r.toLowerCase() === normRole || r.toLowerCase() === 'super-admin' || r.toLowerCase() === 'super_admin');
  };

  const hasAnyRole = (roles: string[]): boolean => {
    if (!user) return false;
    if (user.roles.some((r) => r.toLowerCase() === 'super-admin' || r.toLowerCase() === 'super_admin')) return true;
    const normRoles = roles.map((r) => r.toLowerCase());
    return user.roles.some((r) => normRoles.includes(r.toLowerCase()));
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated: !!user,
        authError,
        authLoading,
        login,
        logout,
        finishPasswordChange,
        hasRole,
        hasAnyRole,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthState => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
