import { create } from 'zustand';
import { parseJwt, getJwtRole } from '@/lib/jwt';

export const useAuthStore = create((set) => ({
  user: null,
  isAuthenticated: false,

  hydrateAuth: () => {
    if (typeof window === 'undefined') return;
    const token = localStorage.getItem('token');
    if (!token) {
      set({ user: null, isAuthenticated: false });
      return;
    }

    const payload = parseJwt(token);
    const role = getJwtRole(token);
    if (!payload?.sub || role !== 'ADMIN') {
      localStorage.removeItem('token');
      document.cookie = 'token=; Max-Age=0; Path=/; SameSite=Lax';
      set({ user: null, isAuthenticated: false });
      return;
    }

    set({
      user: { id: payload.sub, role },
      isAuthenticated: true,
    });
  },

  setToken: (token) => {
    if (typeof window === 'undefined') return;

    const payload = parseJwt(token);
    const role = getJwtRole(token);
    if (!payload?.sub || role !== 'ADMIN') {
      localStorage.removeItem('token');
      document.cookie = 'token=; Max-Age=0; Path=/; SameSite=Lax';
      set({ user: null, isAuthenticated: false });
      return false;
    }

    localStorage.setItem('token', token);
    document.cookie = `token=${token}; Path=/; SameSite=Lax`;
    set({
      user: { id: payload.sub, role },
      isAuthenticated: true,
    });
    return true;
  },

  setAuth: (user) => set({ user, isAuthenticated: true }),

  logout: () => {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('token');
      document.cookie = 'token=; Max-Age=0; Path=/; SameSite=Lax';
      window.location.href = '/login';
    }
    set({ user: null, isAuthenticated: false });
  },
}));
