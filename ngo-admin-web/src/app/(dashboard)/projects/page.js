'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import api from '@/lib/axios';
import { Plus, X } from 'lucide-react';
import { useAuthStore } from '@/store/authStore';

const initialForm = {
  name: '',
  description: '',
  location: '',
  startDate: '',
  endDate: '',
  budgetTotal: 0,
  currency: 'XOF',
  managerId: '',
  donorIds: [],
  status: 'PLANNED',
};

const projectStatuses = ['PLANNED', 'ACTIVE', 'PAUSED', 'COMPLETED', 'CANCELLED'];

export default function ProjectsPage() {
  const [projects, setProjects] = useState([]);
  const [users, setUsers] = useState([]);
  const [donors, setDonors] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [error, setError] = useState('');
  const [updatingStatusId, setUpdatingStatusId] = useState(null);
  const [formData, setFormData] = useState(initialForm);
  const role = useAuthStore((state) => state.user?.role);
  const canCreateProject = role === 'ADMIN';
  const canUpdateStatus = role === 'ADMIN';

  const managers = useMemo(
    () => users.filter((user) => user.role === 'ADMIN' || user.role === 'AGENT'),
    [users],
  );
  const totalBudget = useMemo(
    () => projects.reduce((sum, project) => sum + Number(project.budgetTotal || 0), 0),
    [projects],
  );
  const activeProjects = useMemo(
    () => projects.filter((project) => (project.status || '').toUpperCase() === 'ACTIVE').length,
    [projects],
  );
  const completedProjects = useMemo(
    () => projects.filter((project) => (project.status || '').toUpperCase() === 'COMPLETED').length,
    [projects],
  );

  const statusClass = (status) => {
    const value = (status || 'PLANNED').toUpperCase();
    if (value === 'ACTIVE') return 'bg-emerald-50 text-emerald-700 border border-emerald-200';
    if (value === 'COMPLETED') return 'bg-blue-50 text-blue-700 border border-blue-200';
    if (value === 'PAUSED') return 'bg-amber-50 text-amber-700 border border-amber-200';
    if (value === 'CANCELLED') return 'bg-rose-50 text-rose-700 border border-rose-200';
    return 'bg-slate-100 text-slate-700 border border-slate-200';
  };

  const fetchData = useCallback(async () => {
    const [projectsRes, donorsRes, usersRes] = await Promise.allSettled([
      api.get('/projects'),
      api.get('/donors'),
      canCreateProject ? api.get('/users') : Promise.resolve({ data: [] }),
    ]);

    if (projectsRes.status === 'fulfilled') {
      setProjects(projectsRes.value.data || []);
    } else {
      setError('Impossible de charger les donnees projets.');
      setProjects([]);
    }

    if (donorsRes.status === 'fulfilled') {
      setDonors(donorsRes.value.data || []);
    } else {
      setDonors([]);
    }

    if (usersRes.status === 'fulfilled') {
      setUsers(usersRes.value.data || []);
    } else {
      setUsers([]);
    }
  }, [canCreateProject]);

  useEffect(() => {
    void fetchData();
  }, [fetchData]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    if (!canCreateProject) {
      setError('Seul un ADMIN peut creer un projet.');
      return;
    }

    try {
      await api.post('/projects', {
        ...formData,
        budgetTotal: Number(formData.budgetTotal),
        managerId: Number(formData.managerId),
      });

      setFormData(initialForm);
      setShowModal(false);
      fetchData();
    } catch {
      setError('Erreur lors de la creation du projet.');
    }
  };

  const toggleDonor = (id) => {
    setFormData((prev) => {
      const exists = prev.donorIds.includes(id);
      return {
        ...prev,
        donorIds: exists ? prev.donorIds.filter((donorId) => donorId !== id) : [...prev.donorIds, id],
      };
    });
  };

  const handleStatusChange = async (projectId, status) => {
    setError('');
    setUpdatingStatusId(projectId);
    try {
      await api.patch(`/projects/${projectId}/status`, { status });
      fetchData();
    } catch (err) {
      const message = err?.response?.data?.message;
      setError(Array.isArray(message) ? message.join(' ') : message || 'Mise a jour du statut impossible.');
    } finally {
      setUpdatingStatusId(null);
    }
  };

  return (
    <div className="p-6 space-y-8 bg-[#F8FAFC] min-h-screen text-slate-900">
      <div className="flex flex-col md:flex-row md:justify-between md:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Projets ONG</h1>
          <p className="text-sm text-slate-500 mt-1">Creation, pilotage et suivi des statuts projets.</p>
        </div>
        {canCreateProject ? (
          <button
            onClick={() => setShowModal(true)}
            className="bg-emerald-600 text-white px-4 py-2 rounded-xl flex items-center gap-2 text-sm font-semibold shadow-sm hover:bg-emerald-700"
          >
            <Plus size={20} /> Nouveau Projet
          </button>
        ) : null}
      </div>

      {error ? <p className="text-sm text-red-600">{error}</p> : null}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Budget global</p>
          <p className="text-2xl font-bold text-emerald-700 mt-2">{totalBudget.toLocaleString('fr-FR')} XOF</p>
        </div>
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Projets actifs</p>
          <p className="text-2xl font-bold text-emerald-600 mt-2">{activeProjects}</p>
        </div>
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Projets completes</p>
          <p className="text-2xl font-bold text-blue-600 mt-2">{completedProjects}</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5">
        {projects.map((project) => (
          <div key={project.id} className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 space-y-4">
            <div className="flex items-start justify-between gap-3">
              <h3 className="font-bold text-lg leading-tight">{project.name}</h3>
              <span className={`text-xs px-2.5 py-1 rounded-full font-semibold ${statusClass(project.status)}`}>
                {project.status || 'PLANNED'}
              </span>
            </div>
            <p className="text-slate-500 text-sm">{project.location}</p>
            <p className="text-emerald-700 font-bold text-lg">
              {Number(project.budgetTotal || 0).toLocaleString('fr-FR')} {project.currency || 'XOF'}
            </p>

            <div className="pt-1">
              <p className="text-xs text-slate-500 mb-2 font-semibold uppercase tracking-wide">Changer statut</p>
              {canUpdateStatus ? (
                <select
                  className="w-full border border-slate-200 p-2.5 rounded-xl text-sm bg-white"
                  value={project.status}
                  disabled={updatingStatusId === project.id}
                  onChange={(e) => handleStatusChange(project.id, e.target.value)}
                >
                  {projectStatuses.map((status) => (
                    <option key={status} value={status}>
                      {status}
                    </option>
                  ))}
                </select>
              ) : null}
            </div>

            <div>
              <p className="text-xs text-slate-500 mb-2 font-semibold uppercase tracking-wide">Donateurs</p>
              {Array.isArray(project.donors) && project.donors.length > 0 ? (
                <div className="flex flex-wrap gap-2">
                  {project.donors.map((donor) => (
                    <span
                      key={donor.id}
                      className="text-xs px-2 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200"
                    >
                      {donor.name}
                    </span>
                  ))}
                </div>
              ) : (
                <p className="text-xs text-slate-400">Aucun donateur associe.</p>
              )}
            </div>

          </div>
        ))}
      </div>

      {showModal && canCreateProject && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-8 w-full max-w-2xl max-h-[90vh] overflow-y-auto border border-slate-200">
            <div className="flex justify-between mb-6">
              <h2 className="text-xl font-bold">Creer un nouveau projet</h2>
              <button onClick={() => setShowModal(false)} className="text-slate-500 hover:text-slate-700">
                <X />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="grid grid-cols-2 gap-4">
              <div className="col-span-2">
                <label className="block text-sm font-medium mb-1">Nom du projet</label>
                <input
                  className="w-full border border-slate-200 p-2.5 rounded-xl"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  required
                />
              </div>

              <div className="col-span-2">
                <label className="block text-sm font-medium mb-1">Description</label>
                <textarea
                  className="w-full border border-slate-200 p-2.5 rounded-xl"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Budget total</label>
                <input
                  type="number"
                  min="0"
                  className="w-full border border-slate-200 p-2.5 rounded-xl"
                  value={formData.budgetTotal}
                  onChange={(e) => setFormData({ ...formData, budgetTotal: e.target.value })}
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Devise</label>
                <input
                  className="w-full border border-slate-200 p-2.5 rounded-xl"
                  value={formData.currency}
                  onChange={(e) => setFormData({ ...formData, currency: e.target.value.toUpperCase() })}
                  maxLength={3}
                />
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Localisation</label>
                <input
                  className="w-full border border-slate-200 p-2.5 rounded-xl"
                  value={formData.location}
                  onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Manager</label>
                <select
                  className="w-full border border-slate-200 p-2.5 rounded-xl"
                  value={formData.managerId}
                  onChange={(e) => setFormData({ ...formData, managerId: e.target.value })}
                  required
                >
                  <option value="">Selectionner</option>
                  {managers.map((manager) => (
                    <option key={manager.id} value={manager.id}>
                      {manager.name} ({manager.role})
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Date debut</label>
                <input
                  type="date"
                  className="w-full border border-slate-200 p-2.5 rounded-xl"
                  value={formData.startDate}
                  onChange={(e) => setFormData({ ...formData, startDate: e.target.value })}
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Date fin</label>
                <input
                  type="date"
                  className="w-full border border-slate-200 p-2.5 rounded-xl"
                  value={formData.endDate}
                  onChange={(e) => setFormData({ ...formData, endDate: e.target.value })}
                />
              </div>

              <div className="col-span-2">
                <label className="block text-sm font-medium mb-2">Donateurs associes</label>
                <div className="grid grid-cols-2 gap-2 border border-slate-200 p-3 rounded-xl max-h-32 overflow-y-auto">
                  {donors.map((donor) => (
                    <label key={donor.id} className="flex items-center gap-2 text-sm">
                      <input
                        type="checkbox"
                        checked={formData.donorIds.includes(donor.id)}
                        onChange={() => toggleDonor(donor.id)}
                      />
                      {donor.name}
                    </label>
                  ))}
                </div>
              </div>

              <button type="submit" className="col-span-2 bg-emerald-600 text-white p-3 rounded-xl font-bold mt-4">
                Enregistrer le projet
              </button>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
