'use client';

import { useState, useEffect, useMemo } from 'react';
import api from '@/lib/axios';
import { Plus, Mail, Building } from 'lucide-react';

export default function DonorsPage() {
  const [donors, setDonors] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [error, setError] = useState('');
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    organization: '',
    type: 'institutional',
    fundedAmount: 0,
    country: 'ML',
    currency: 'XOF',
  });
  const totalFunded = useMemo(
    () => donors.reduce((sum, donor) => sum + Number(donor.fundedAmount || 0), 0),
    [donors],
  );
  const institutionalCount = useMemo(
    () => donors.filter((donor) => donor.type === 'institutional').length,
    [donors],
  );

  const fetchDonors = async () => {
    try {
      const res = await api.get('/donors');
      setDonors(res.data || []);
    } catch {
      setError('Impossible de charger les donateurs.');
    }
  };

  useEffect(() => {
    let cancelled = false;

    const load = async () => {
      try {
        const res = await api.get('/donors');
        if (cancelled) return;
        setDonors(res.data || []);
      } catch {
        if (!cancelled) {
          setError('Impossible de charger les donateurs.');
        }
      }
    };

    void load();
    return () => {
      cancelled = true;
    };
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    try {
      await api.post('/donors', {
        ...formData,
        fundedAmount: Number(formData.fundedAmount || 0),
      });
      setShowModal(false);
      setFormData({
        name: '',
        email: '',
        phone: '',
        organization: '',
        type: 'institutional',
        fundedAmount: 0,
        country: 'ML',
        currency: 'XOF',
      });
      fetchDonors();
    } catch {
      setError('Erreur lors de la creation du donateur.');
    }
  };

  return (
    <div className="p-6 space-y-8 bg-[#F8FAFC] min-h-screen text-slate-900">
      <div className="flex flex-col md:flex-row md:justify-between md:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Bailleurs de fonds</h1>
          <p className="text-sm text-slate-500 mt-1">Suivi des donateurs et montants finances.</p>
        </div>
        <button
          onClick={() => setShowModal(true)}
          className="bg-slate-900 text-white px-4 py-2 rounded-xl flex items-center gap-2 hover:bg-slate-800 text-sm font-semibold shadow-sm"
        >
          <Plus size={20} /> Nouveau Donateur
        </button>
      </div>

      {error ? <p className="text-sm text-red-600">{error}</p> : null}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Donateurs</p>
          <p className="text-2xl font-bold text-slate-900 mt-2">{donors.length}</p>
        </div>
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Montant total</p>
          <p className="text-2xl font-bold text-emerald-700 mt-2">{totalFunded.toLocaleString('fr-FR')} XOF</p>
        </div>
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Institutionnels</p>
          <p className="text-2xl font-bold text-blue-700 mt-2">{institutionalCount}</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
        {donors.map((donor) => (
          <div
            key={donor.id}
            className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex justify-between items-center"
          >
            <div className="space-y-1">
              <h3 className="font-bold text-lg text-slate-800">{donor.name}</h3>
              <p className="text-sm text-slate-500 flex items-center gap-2">
                <Building size={14} /> {donor.organization || '-'}
              </p>
              <p className="text-sm text-slate-500 flex items-center gap-2">
                <Mail size={14} /> {donor.email}
              </p>
            </div>
            <div className="text-right">
              <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Total finance</p>
              <p className="text-xl font-black text-emerald-600">
                {Number(donor.fundedAmount || 0).toLocaleString('fr-FR')} {donor.currency || 'XOF'}
              </p>
              <span className="text-[10px] bg-slate-100 px-2 py-0.5 rounded text-slate-600 font-bold mr-1">
                {donor.country || '-'}
              </span>
              <span className="text-[10px] bg-blue-50 px-2 py-0.5 rounded text-blue-700 font-bold uppercase">
                {donor.type || '-'}
              </span>
            </div>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <form onSubmit={handleSubmit} className="bg-white rounded-2xl p-8 w-full max-w-md space-y-4 border border-slate-200">
            <h2 className="text-xl font-bold">Ajouter un donateur</h2>
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
              placeholder="Organisation"
              className="w-full border border-slate-200 p-2.5 rounded-xl"
              value={formData.organization}
              onChange={(e) => setFormData({ ...formData, organization: e.target.value })}
            />
            <div className="grid grid-cols-2 gap-2">
              <input
                placeholder="Montant"
                type="number"
                className="w-full border border-slate-200 p-2.5 rounded-xl"
                value={formData.fundedAmount}
                onChange={(e) => setFormData({ ...formData, fundedAmount: e.target.value })}
              />
              <select
                className="border border-slate-200 p-2.5 rounded-xl"
                value={formData.type}
                onChange={(e) => setFormData({ ...formData, type: e.target.value })}
              >
                <option value="institutional">Institutionnel</option>
                <option value="individual">Individuel</option>
              </select>
            </div>
            <div className="flex gap-2">
              <button type="button" onClick={() => setShowModal(false)} className="flex-1 py-2 text-slate-500 font-bold">
                Annuler
              </button>
              <button type="submit" className="flex-1 bg-emerald-600 text-white py-2 rounded-xl font-bold">
                Enregistrer
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}
