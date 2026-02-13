'use client';

import { useEffect, useMemo, useState } from 'react';
import { Download, Plus, X } from 'lucide-react';
import api from '@/lib/axios';
import { exportToCSV } from '@/utils/exportData';
import { uploadImage } from '@/lib/upload';
import { resolveMediaUrl } from '@/lib/media';
import { useAuthStore } from '@/store/authStore';

const initialForm = {
  projectId: '',
  budgetId: '',
  amount: '',
  description: '',
  date: new Date().toISOString().slice(0, 10),
  gpsLat: '',
  gpsLng: '',
};

export default function ExpensesPage() {
  const [expenses, setExpenses] = useState([]);
  const [projects, setProjects] = useState([]);
  const [budgets, setBudgets] = useState([]);
  const [projectBudgets, setProjectBudgets] = useState([]);
  const [receipt, setReceipt] = useState(null);
  const [error, setError] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [loading, setLoading] = useState(false);
  const [selectedExpense, setSelectedExpense] = useState(null);
  const [formData, setFormData] = useState(initialForm);
  const role = useAuthStore((state) => state.user?.role);

  const canApprove = role === 'ADMIN' || role === 'FINANCE';

  const fetchExpenses = async () => {
    try {
      const res = await api.get('/expenses');
      setExpenses(res.data || []);
    } catch {
      setError('Impossible de charger les depenses.');
    }
  };

  const fetchProjectsAndBudgets = async () => {
    const [projectsRes, budgetsRes] = await Promise.allSettled([api.get('/projects'), api.get('/budgets')]);

    if (projectsRes.status === 'fulfilled') {
      setProjects(projectsRes.value.data || []);
    }

    if (budgetsRes.status === 'fulfilled') {
      setBudgets(budgetsRes.value.data || []);
    }
  };

  useEffect(() => {
    fetchExpenses();
    fetchProjectsAndBudgets();
  }, []);

  useEffect(() => {
    const projectId = Number(formData.projectId);
    if (!projectId) {
      setProjectBudgets([]);
      return;
    }

    const local = budgets.filter((item) => Number(item.project?.id) === projectId);
    setProjectBudgets(local);
  }, [formData.projectId, budgets]);

  const approve = async (id, status) => {
    try {
      await api.patch(`/expenses/${id}/approve`, { status });
      fetchExpenses();
    } catch {
      setError('Action impossible pour cette depense (verification role ADMIN/FINANCE).');
    }
  };

  const createExpense = async (event) => {
    event.preventDefault();
    setLoading(true);
    setError('');

    try {
      let receiptUrl = '';
      if (receipt) {
        receiptUrl = await uploadImage(receipt);
      }

      const projectId = Number(formData.projectId);
      const budgetId = Number(formData.budgetId);

      await api.post(`/expenses/${projectId}/${budgetId}`, {
        projectId,
        budgetCategoryId: budgetId,
        amount: Number(formData.amount),
        description: formData.description,
        date: formData.date,
        receiptUrl,
        gpsLat: formData.gpsLat ? Number(formData.gpsLat) : undefined,
        gpsLng: formData.gpsLng ? Number(formData.gpsLng) : undefined,
      });

      setShowModal(false);
      setFormData(initialForm);
      setReceipt(null);
      fetchExpenses();
    } catch (err) {
      const message = err?.response?.data?.message;
      setError(Array.isArray(message) ? message.join(' ') : message || 'Creation de depense impossible.');
    } finally {
      setLoading(false);
    }
  };

  const rowsForCsv = useMemo(
    () =>
      expenses.map((expense) => ({
        id: expense.id,
        description: expense.description,
        amount: expense.amount,
        date: expense.date,
        status: expense.status,
        project: expense.project?.name || '',
      })),
    [expenses],
  );

  const handleExport = () => {
    if (rowsForCsv.length > 0) {
      exportToCSV(rowsForCsv, 'rapport-depenses-ngo');
    }
  };

  const totalAmount = useMemo(
    () => expenses.reduce((sum, item) => sum + Number(item.amount || 0), 0),
    [expenses],
  );
  const pendingCount = useMemo(
    () => expenses.filter((item) => (item.status || '').toUpperCase() === 'PENDING').length,
    [expenses],
  );
  const approvedCount = useMemo(
    () => expenses.filter((item) => (item.status || '').toUpperCase() === 'APPROVED').length,
    [expenses],
  );

  const getStatusClasses = (status) => {
    const value = (status || 'PENDING').toUpperCase();
    if (value === 'APPROVED') {
      return 'bg-emerald-50 text-emerald-700 border border-emerald-200';
    }
    if (value === 'REJECTED') {
      return 'bg-rose-50 text-rose-700 border border-rose-200';
    }
    return 'bg-amber-50 text-amber-700 border border-amber-200';
  };

  const formatAmount = (value) => `${Number(value || 0).toLocaleString('fr-FR')} XOF`;

  return (
    <div className="p-6 space-y-8 bg-[#F8FAFC] min-h-screen text-slate-900">
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Depenses</h1>
          <p className="text-sm text-slate-500 mt-1">Suivi, validation et audit des depenses terrain.</p>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={handleExport}
            className="inline-flex items-center gap-2 bg-white text-slate-700 px-4 py-2 rounded-xl border border-slate-200 hover:bg-slate-50 transition text-sm font-semibold shadow-sm"
          >
            <Download size={18} /> Exporter CSV
          </button>
          <button
            onClick={() => setShowModal(true)}
            className="inline-flex items-center gap-2 bg-emerald-600 text-white px-4 py-2 rounded-xl hover:bg-emerald-700 shadow-sm text-sm font-semibold"
          >
            <Plus size={18} /> Nouvelle depense
          </button>
        </div>
      </div>

      {error ? <p className="text-sm text-red-600">{error}</p> : null}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Depenses totales</p>
          <p className="text-2xl font-bold text-slate-900 mt-2">{formatAmount(totalAmount)}</p>
        </div>
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">En attente</p>
          <p className="text-2xl font-bold text-amber-600 mt-2">{pendingCount}</p>
        </div>
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Approuvees</p>
          <p className="text-2xl font-bold text-emerald-600 mt-2">{approvedCount}</p>
        </div>
      </div>

      <div className="md:hidden space-y-3">
        {expenses.map((exp) => (
          <div key={exp.id} className="bg-white rounded-2xl border border-slate-200 p-4 shadow-sm space-y-3">
            <div className="flex items-start justify-between gap-3">
              <p className="font-semibold leading-tight">{exp.description}</p>
              <span className={`text-xs px-2.5 py-1 rounded-full font-semibold ${getStatusClasses(exp.status)}`}>
                {exp.status || 'PENDING'}
              </span>
            </div>
            <div className="text-sm text-slate-600 space-y-1">
              <p><span className="font-semibold">Projet:</span> {exp.project?.name || '-'}</p>
              <p><span className="font-semibold">Date:</span> {exp.date || '-'}</p>
              <p className="text-emerald-700 font-bold">{formatAmount(exp.amount)}</p>
            </div>
            <div className="flex flex-wrap gap-2">
              <button
                onClick={() => setSelectedExpense(exp)}
                className="bg-slate-100 text-slate-700 px-3 py-1.5 rounded-lg text-sm font-medium"
              >
                Details
              </button>
              {exp.receiptUrl ? (
                <a
                  className="bg-blue-50 text-blue-700 px-3 py-1.5 rounded-lg text-sm font-medium"
                  href={resolveMediaUrl(exp.receiptUrl)}
                  target="_blank"
                  rel="noreferrer"
                >
                  Justificatif
                </a>
              ) : null}
            </div>
          </div>
        ))}
      </div>

      <div className="hidden md:block bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead className="bg-slate-50 border-b border-slate-200">
            <tr>
              <th className="p-4 font-semibold text-slate-700">Description</th>
              <th className="p-4 font-semibold text-slate-700">Montant</th>
              <th className="p-4 font-semibold text-slate-700">Projet</th>
              <th className="p-4 font-semibold text-slate-700">Date</th>
              <th className="p-4 font-semibold text-slate-700">Statut</th>
              <th className="p-4 font-semibold text-slate-700">Justificatif</th>
              <th className="p-4 font-semibold text-slate-700">Actions</th>
            </tr>
          </thead>
          <tbody>
            {expenses.map((exp) => (
              <tr key={exp.id} className="border-b border-slate-100 hover:bg-slate-50 transition">
                <td className="p-4 font-medium">{exp.description}</td>
                <td className="p-4 text-emerald-600 font-bold">{formatAmount(exp.amount)}</td>
                <td className="p-4">{exp.project?.name || '-'}</td>
                <td className="p-4">{exp.date || '-'}</td>
                <td className="p-4">
                  <span className={`text-xs px-2.5 py-1 rounded-full font-semibold ${getStatusClasses(exp.status)}`}>
                    {exp.status || 'PENDING'}
                  </span>
                </td>
                <td className="p-4">
                  {exp.receiptUrl ? (
                    <a className="text-blue-600 hover:text-blue-700 underline text-sm" href={resolveMediaUrl(exp.receiptUrl)} target="_blank" rel="noreferrer">
                      Voir
                    </a>
                  ) : (
                    <span className="text-slate-400">-</span>
                  )}
                </td>
                <td className="p-4">
                  <div className="min-w-[220px] space-y-2">
                    <div className="grid grid-cols-2 gap-2">
                      <button
                        onClick={() => setSelectedExpense(exp)}
                        className="bg-slate-100 text-slate-700 px-3 py-1.5 rounded-lg text-sm font-medium"
                      >
                        Details
                      </button>
                      {canApprove ? (
                        <button
                          onClick={() => approve(exp.id, 'REJECTED')}
                          className="bg-rose-50 text-rose-700 px-3 py-1.5 rounded-lg text-sm font-medium"
                        >
                          Rejeter
                        </button>
                      ) : (
                        <span className="text-xs text-slate-400 flex items-center justify-center">Lecture seule</span>
                      )}
                    </div>
                    <button
                      onClick={() => approve(exp.id, 'APPROVED')}
                      className={`w-full px-3 py-1.5 rounded-lg text-sm font-medium ${
                        canApprove ? 'bg-emerald-500 text-white' : 'bg-slate-100 text-slate-400 cursor-not-allowed'
                      }`}
                      disabled={!canApprove}
                    >
                      Valider
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <form onSubmit={createExpense} className="bg-white rounded-2xl p-8 w-full max-w-xl space-y-4 max-h-[90vh] overflow-y-auto border border-slate-200">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-bold">Nouvelle depense</h2>
              <button type="button" onClick={() => setShowModal(false)} className="text-slate-500 hover:text-slate-700">
                <X />
              </button>
            </div>

            <select
              className="w-full border border-slate-200 p-3 rounded-xl"
              value={formData.projectId}
              onChange={(e) => setFormData({ ...formData, projectId: e.target.value, budgetId: '' })}
              required
            >
              <option value="">Choisir projet</option>
              {projects.map((project) => (
                <option key={project.id} value={project.id}>
                  {project.name}
                </option>
              ))}
            </select>

            <select
              className="w-full border border-slate-200 p-3 rounded-xl"
              value={formData.budgetId}
              onChange={(e) => setFormData({ ...formData, budgetId: e.target.value })}
              required
            >
              <option value="">Choisir budget</option>
              {projectBudgets.map((budget) => (
                <option key={budget.id} value={budget.id}>
                  {budget.category} - {Number(budget.allocatedAmount || 0).toLocaleString('fr-FR')}
                </option>
              ))}
            </select>

            <input
              type="number"
              min="0"
              placeholder="Montant"
              className="w-full border border-slate-200 p-3 rounded-xl"
              value={formData.amount}
              onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
              required
            />

            <textarea
              placeholder="Description"
              className="w-full border border-slate-200 p-3 rounded-xl"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              required
            />

            <input
              type="date"
              className="w-full border border-slate-200 p-3 rounded-xl"
              value={formData.date}
              onChange={(e) => setFormData({ ...formData, date: e.target.value })}
              required
            />

            <input
              type="file"
              accept="image/*"
              className="w-full border border-slate-200 p-3 rounded-xl"
              onChange={(e) => setReceipt(e.target.files?.[0] || null)}
            />

            <div className="grid grid-cols-2 gap-2">
              <input
                type="number"
                step="0.000001"
                placeholder="GPS latitude"
                className="w-full border border-slate-200 p-3 rounded-xl"
                value={formData.gpsLat}
                onChange={(e) => setFormData({ ...formData, gpsLat: e.target.value })}
              />
              <input
                type="number"
                step="0.000001"
                placeholder="GPS longitude"
                className="w-full border border-slate-200 p-3 rounded-xl"
                value={formData.gpsLng}
                onChange={(e) => setFormData({ ...formData, gpsLng: e.target.value })}
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-emerald-600 text-white py-3 rounded-xl font-bold disabled:opacity-60"
            >
              {loading ? 'Enregistrement...' : 'Soumettre depense'}
            </button>
          </form>
        </div>
      )}

      {selectedExpense && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl p-6 w-full max-w-2xl space-y-5 border border-slate-200">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-bold">Detail depense #{selectedExpense.id}</h2>
              <button onClick={() => setSelectedExpense(null)} className="text-slate-500 hover:text-slate-700">Fermer</button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
              <div className="bg-slate-50 rounded-lg p-3"><span className="font-semibold">Projet:</span> {selectedExpense.project?.name || '-'}</div>
              <div className="bg-slate-50 rounded-lg p-3"><span className="font-semibold">Budget:</span> {selectedExpense.budget?.category || '-'}</div>
              <div className="bg-slate-50 rounded-lg p-3"><span className="font-semibold">Montant:</span> {formatAmount(selectedExpense.amount)}</div>
              <div className="bg-slate-50 rounded-lg p-3"><span className="font-semibold">Date:</span> {selectedExpense.date || '-'}</div>
              <div className="bg-slate-50 rounded-lg p-3"><span className="font-semibold">Statut:</span> {selectedExpense.status || '-'}</div>
              <div className="bg-slate-50 rounded-lg p-3"><span className="font-semibold">Approuve le:</span> {(selectedExpense.approvedAt || '').slice(0, 10) || '-'}</div>
            </div>

            <div className="text-sm bg-slate-50 rounded-lg p-3">
              <p className="font-semibold">Description</p>
              <p className="text-slate-700">{selectedExpense.description || '-'}</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
              <div className="bg-slate-50 rounded-lg p-3"><span className="font-semibold">GPS:</span> {selectedExpense.gpsLat || '-'}, {selectedExpense.gpsLng || '-'}</div>
              <div className="bg-slate-50 rounded-lg p-3"><span className="font-semibold">Commentaire validation:</span> {selectedExpense.approvalComment || '-'}</div>
            </div>

            {selectedExpense.receiptUrl ? (
              <a
                href={resolveMediaUrl(selectedExpense.receiptUrl)}
                target="_blank"
                rel="noreferrer"
                className="inline-flex items-center px-4 py-2 rounded-xl bg-emerald-600 text-white text-sm font-semibold"
              >
                Ouvrir justificatif
              </a>
            ) : null}
          </div>
        </div>
      )}
    </div>
  );
}
