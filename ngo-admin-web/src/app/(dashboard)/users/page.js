'use client';

import { useState, useEffect, useMemo } from 'react';
import api from '@/lib/axios';
import { UserPlus } from 'lucide-react';

export default function UsersPage() {
  const [users, setUsers] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [error, setError] = useState('');
  const [formData, setFormData] = useState({ name: '', email: '', password: '', role: 'AGENT' });
  const adminCount = useMemo(() => users.filter((user) => user.role === 'ADMIN').length, [users]);
  const agentCount = useMemo(() => users.filter((user) => user.role === 'AGENT').length, [users]);
  const financeCount = useMemo(() => users.filter((user) => user.role === 'FINANCE').length, [users]);

  const roleClass = (role) => {
    if (role === 'ADMIN') return 'bg-purple-100 text-purple-700';
    if (role === 'FINANCE') return 'bg-amber-100 text-amber-700';
    return 'bg-blue-100 text-blue-700';
  };

  const fetchUsers = async () => {
    try {
      const res = await api.get('/users');
      setUsers(res.data || []);
    } catch {
      setError("Impossible de charger les utilisateurs (acces ADMIN requis).");
      setUsers([]);
    }
  };

  useEffect(() => {
    let cancelled = false;

    const load = async () => {
      try {
        const res = await api.get('/users');
        if (cancelled) return;
        setUsers(res.data || []);
      } catch {
        if (!cancelled) {
          setError("Impossible de charger les utilisateurs (acces ADMIN requis).");
          setUsers([]);
        }
      }
    };

    void load();
    return () => {
      cancelled = true;
    };
  }, []);

  const handleCreateUser = async (e) => {
    e.preventDefault();
    setError('');

    try {
      await api.post('/auth/register', formData);
      setShowModal(false);
      setFormData({ name: '', email: '', password: '', role: 'AGENT' });
      fetchUsers();
    } catch {
      setError("Erreur lors de la creation de l'utilisateur.");
    }
  };

  return (
    <div className="p-6 space-y-8 bg-[#F8FAFC] min-h-screen text-slate-900">
      <div className="flex flex-col md:flex-row md:justify-between md:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Equipe & Utilisateurs</h1>
          <p className="text-sm text-slate-500 mt-1">Gestion des comptes, roles et acces admin.</p>
        </div>
        <button onClick={() => setShowModal(true)} className="bg-blue-600 text-white px-4 py-2 rounded-xl flex items-center gap-2 text-sm font-semibold shadow-sm hover:bg-blue-700">
          <UserPlus size={20} /> Ajouter un membre
        </button>
      </div>

      {error ? <p className="text-sm text-red-600">{error}</p> : null}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Utilisateurs</p>
          <p className="text-2xl font-bold text-slate-900 mt-2">{users.length}</p>
        </div>
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Administrateurs</p>
          <p className="text-2xl font-bold text-purple-700 mt-2">{adminCount}</p>
        </div>
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Agents / Finance</p>
          <p className="text-2xl font-bold text-blue-700 mt-2">{agentCount + financeCount}</p>
        </div>
      </div>

      <div className="md:hidden space-y-3">
        {users.map((user) => (
          <div key={user.id} className="bg-white rounded-2xl border border-slate-200 p-4 shadow-sm">
            <div className="flex items-start justify-between gap-3">
              <div>
                <p className="font-semibold">{user.name || '-'}</p>
                <p className="text-sm text-slate-500">{user.email}</p>
              </div>
              <span className={`px-2 py-1 rounded-md text-[10px] font-bold ${roleClass(user.role)}`}>{user.role}</span>
            </div>
          </div>
        ))}
      </div>

      <div className="hidden md:block bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <table className="w-full text-left">
          <thead className="bg-slate-50 border-b">
            <tr>
              <th className="p-4 font-semibold text-sm">Nom</th>
              <th className="p-4 font-semibold text-sm">Email</th>
              <th className="p-4 font-semibold text-sm">Role</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {users.map((user) => (
              <tr key={user.id} className="hover:bg-slate-50">
                <td className="p-4 font-medium">{user.name}</td>
                <td className="p-4 text-slate-500">{user.email}</td>
                <td className="p-4">
                  <span className={`px-2 py-1 rounded-md text-[10px] font-bold ${roleClass(user.role)}`}>
                    {user.role}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <form onSubmit={handleCreateUser} className="bg-white p-6 rounded-2xl w-full max-w-md space-y-4 border border-slate-200">
            <h2 className="text-xl font-bold">Nouvel utilisateur</h2>
            <input
              placeholder="Nom complet"
              className="w-full border border-slate-200 p-2.5 rounded-xl"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              required
            />
            <input
              type="email"
              placeholder="Email"
              className="w-full border border-slate-200 p-2.5 rounded-xl"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              required
            />
            <input
              type="password"
              placeholder="Mot de passe (min 6 car.)"
              className="w-full border border-slate-200 p-2.5 rounded-xl"
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
              required
            />
            <select
              className="w-full border border-slate-200 p-2.5 rounded-xl"
              value={formData.role}
              onChange={(e) => setFormData({ ...formData, role: e.target.value })}
            >
              <option value="AGENT">Agent terrain</option>
              <option value="FINANCE">Responsable finance</option>
              <option value="ADMIN">Administrateur</option>
            </select>
            <div className="flex gap-2 pt-2">
              <button type="button" onClick={() => setShowModal(false)} className="flex-1 py-2 text-slate-500">
                Annuler
              </button>
              <button type="submit" className="flex-1 bg-blue-600 text-white py-2 rounded-xl font-bold">
                Creer le compte
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}
