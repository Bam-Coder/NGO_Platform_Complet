'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import api from '@/lib/axios';
import { useAuthStore } from '@/store/authStore';
import { getJwtRole } from '@/lib/jwt';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const router = useRouter();
  const setToken = useAuthStore((state) => state.setToken);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token && getJwtRole(token) === 'ADMIN') {
      router.replace('/dashboard');
    } else if (token) {
      localStorage.removeItem('token');
      document.cookie = 'token=; Max-Age=0; Path=/; SameSite=Lax';
    }
  }, [router]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const { data } = await api.post('/auth/login', { email, password });
      const token = data?.access_token;

      if (!token) {
        throw new Error('Token manquant dans la reponse');
      }

      if (getJwtRole(token) !== 'ADMIN') {
        setError("Acces refuse");
        return;
      }

      const ok = setToken(token);
      if (!ok) {
        setError("Acces refuse");
        return;
      }
      router.replace('/dashboard');
    } catch (err) {
      const status = err?.response?.status;
      const message = err?.response?.data?.message;

      if (!err?.response) {
        setError('Backend inaccessible via le proxy web /api/proxy. Verifie que le conteneur backend est actif.');
      } else if (Array.isArray(message)) {
        setError(message.join(' '));
      } else if (typeof message === 'string' && message.trim()) {
        setError(message);
      } else if (status === 401) {
        setError('Email ou mot de passe incorrect.');
      } else if (status === 403) {
        setError('Acces refuse pour ce compte.');
      } else {
        setError('Erreur de connexion. Reessaie.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 p-4">
      <form
        onSubmit={handleSubmit}
        className="bg-white p-8 rounded-2xl shadow-xl w-full max-w-md space-y-6 border border-slate-200"
      >
        <h1 className="text-3xl font-bold text-center text-slate-900">Connexion</h1>
        <p className="text-xs text-center text-slate-500">
          <Link href="/" className="text-emerald-600 font-semibold hover:underline">
            Voir la presentation de la plateforme
          </Link>
        </p>

        <input
          type="email"
          placeholder="Email"
          className="w-full p-3 border rounded-lg focus:ring-2 focus:ring-emerald-500 outline-none"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
        />

        <input
          type="password"
          placeholder="Mot de passe"
          className="w-full p-3 border rounded-lg focus:ring-2 focus:ring-emerald-500 outline-none"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />

        {error ? <p className="text-sm text-red-600">{error}</p> : null}

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-emerald-600 text-white p-3 rounded-lg font-bold hover:bg-emerald-700 transition disabled:opacity-60"
        >
          {loading ? 'Connexion...' : 'Se connecter'}
        </button>

        <p className="text-sm text-center text-slate-500">
          Pas encore de compte ?{' '}
          <Link href="/register" className="text-emerald-600 font-semibold hover:underline">
            Creer un compte
          </Link>
        </p>
      </form>
    </div>
  );
}