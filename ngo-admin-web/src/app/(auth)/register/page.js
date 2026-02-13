'use client';
import Link from 'next/link';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import api from '@/lib/axios';
import { useAuthStore } from '@/store/authStore';

const initialForm = {
  name: '',
  email: '',
  password: '',
};

export default function RegisterPage() {
  const [formData, setFormData] = useState(initialForm);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const router = useRouter();
  const setToken = useAuthStore((state) => state.setToken);

  const handleSubmit = async (event) => {
    event.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    try {
      await api.post('/auth/register', formData);
      const login = await api.post('/auth/login', {
        email: formData.email,
        password: formData.password,
      });

      const token = login.data?.access_token;
      if (token) {
        setToken(token);
        router.replace('/dashboard');
        return;
      }

      setSuccess('Compte cree. Connecte-toi maintenant.');
      router.replace('/login');
    } catch (err) {
      const message = err?.response?.data?.message;
      if (Array.isArray(message)) {
        setError(message.join(' '));
      } else if (typeof message === 'string' && message.trim()) {
        setError(message);
      } else {
        setError("Impossible de creer le compte pour l'instant.");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 p-4">
      <form onSubmit={handleSubmit} className="bg-white p-8 rounded-2xl shadow-xl w-full max-w-md space-y-5 border border-slate-200">
        <h1 className="text-3xl font-bold text-center text-slate-900">Creer un compte Admin</h1>

        <input
          type="text"
          placeholder="Nom complet"
          className="w-full p-3 border rounded-lg focus:ring-2 focus:ring-emerald-500 outline-none"
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
          required
        />

        <input
          type="email"
          placeholder="Email"
          className="w-full p-3 border rounded-lg focus:ring-2 focus:ring-emerald-500 outline-none"
          value={formData.email}
          onChange={(e) => setFormData({ ...formData, email: e.target.value })}
          required
        />

        <input
          type="password"
          placeholder="Mot de passe (min 6 caracteres)"
          className="w-full p-3 border rounded-lg focus:ring-2 focus:ring-emerald-500 outline-none"
          value={formData.password}
          onChange={(e) => setFormData({ ...formData, password: e.target.value })}
          required
        />

        {error ? <p className="text-sm text-red-600">{error}</p> : null}
        {success ? <p className="text-sm text-emerald-600">{success}</p> : null}

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-emerald-600 text-white p-3 rounded-lg font-bold hover:bg-emerald-700 transition disabled:opacity-60"
        >
          {loading ? 'Creation...' : 'Creer le compte'}
        </button>

        <p className="text-sm text-center text-slate-500">
          Deja inscrit ?{' '}
          <Link href="/login" className="text-emerald-600 font-semibold hover:underline">
            Se connecter
          </Link>
        </p>
      </form>
    </div>
  );
}