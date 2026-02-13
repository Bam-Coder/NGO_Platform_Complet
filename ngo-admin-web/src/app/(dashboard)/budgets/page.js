'use client';

import { useEffect, useMemo, useState } from 'react';
import { Plus, X } from 'lucide-react';
import api from '@/lib/axios';

const categories = [
  'Transport',
  'Food',
  'Logistics',
  'Training',
  'Health',
  'Education',
  'Equipment',
  'Staff',
  'Utilities',
  'Other',
];

const initialForm = {
  projectId: '',
  category: 'Other',
  allocatedAmount: '',
  description: '',
};

export default function BudgetsPage() {
  const [budgets, setBudgets] = useState([]);
  const [expenses, setExpenses] = useState([]);
  const [projects, setProjects] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [error, setError] = useState('');
  const [formData, setFormData] = useState(initialForm);

  const fetchData = async () => {
    setError('');
    const [budgetRes, projectsRes, expensesRes] = await Promise.allSettled([
      api.get('/budgets'),
      api.get('/projects'),
      api.get('/expenses'),
    ]);

    if (budgetRes.status === 'fulfilled') {
      setBudgets(budgetRes.value.data || []);
    } else {
      setBudgets([]);
      setError('Impossible de charger les budgets.');
    }

    if (projectsRes.status === 'fulfilled') {
      setProjects(projectsRes.value.data || []);
    } else {
      setProjects([]);
    }

    if (expensesRes.status === 'fulfilled') {
      setExpenses(expensesRes.value.data || []);
    } else {
      setExpenses([]);
    }
  };

  useEffect(() => {
    let cancelled = false;

    const load = async () => {
      setError('');
      const [budgetRes, projectsRes, expensesRes] = await Promise.allSettled([
        api.get('/budgets'),
        api.get('/projects'),
        api.get('/expenses'),
      ]);

      if (cancelled) return;

      if (budgetRes.status === 'fulfilled') {
        setBudgets(budgetRes.value.data || []);
      } else {
        setBudgets([]);
        setError('Impossible de charger les budgets.');
      }

      if (projectsRes.status === 'fulfilled') {
        setProjects(projectsRes.value.data || []);
      } else {
        setProjects([]);
      }

      if (expensesRes.status === 'fulfilled') {
        setExpenses(expensesRes.value.data || []);
      } else {
        setExpenses([]);
      }
    };

    void load();
    return () => {
      cancelled = true;
    };
  }, []);

  const spentByBudget = useMemo(() => {
    const map = new Map();
    for (const expense of expenses) {
      if (expense.status !== 'APPROVED') continue;
      const budgetId = Number(expense.budget?.id);
      if (!budgetId) continue;
      map.set(budgetId, (map.get(budgetId) || 0) + Number(expense.amount || 0));
    }
    return map;
  }, [expenses]);

  const totals = useMemo(() => {
    const allocated = budgets.reduce((acc, budget) => acc + Number(budget.allocatedAmount || 0), 0);
    const spent = budgets.reduce((acc, budget) => {
      const computed = spentByBudget.get(Number(budget.id));
      return acc + (computed ?? Number(budget.spentAmount || 0));
    }, 0);
    return { allocated, spent };
  }, [budgets, spentByBudget]);

  const groupedByProject = useMemo(() => {
    const groups = new Map();

    for (const budget of budgets) {
      const projectId = Number(budget.project?.id);
      const fallbackId = Number.isFinite(projectId) && projectId > 0 ? projectId : -1;
      const key = fallbackId;
      const projectName = budget.project?.name || 'Projet non renseigne';
      const allocated = Number(budget.allocatedAmount || 0);
      const spent = Number(spentByBudget.get(Number(budget.id)) ?? Number(budget.spentAmount || 0));

      if (!groups.has(key)) {
        groups.set(key, {
          projectId: key,
          projectName,
          allocated: 0,
          spent: 0,
          items: [],
        });
      }

      const current = groups.get(key);
      current.allocated += allocated;
      current.spent += spent;
      current.items.push({
        id: budget.id,
        category: budget.category,
        description: budget.description,
        allocated,
        spent,
        remaining: allocated - spent,
      });
    }

    return Array.from(groups.values()).sort((a, b) => a.projectName.localeCompare(b.projectName, 'fr'));
  }, [budgets, spentByBudget]);

  const submit = async (event) => {
    event.preventDefault();
    setError('');

    try {
      await api.post(`/budgets/${formData.projectId}`, {
        projectId: Number(formData.projectId),
        category: formData.category,
        allocatedAmount: Number(formData.allocatedAmount),
        description: formData.description,
      });
      setShowModal(false);
      setFormData(initialForm);
      fetchData();
    } catch (err) {
      const msg = err?.response?.data?.message;
      setError(Array.isArray(msg) ? msg.join(' ') : msg || 'Creation de budget impossible.');
    }
  };

  return (
    <div className="p-6 space-y-8 bg-[#F8FAFC] min-h-screen text-slate-900">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold">Budgets</h1>
        <button
          onClick={() => setShowModal(true)}
          className="bg-emerald-600 text-white px-4 py-2 rounded-lg flex items-center gap-2"
        >
          <Plus size={20} /> Nouveau Budget
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-xl border p-5">
          <p className="text-xs uppercase text-slate-500">Budgets</p>
          <p className="text-2xl font-bold mt-1">{budgets.length}</p>
        </div>
        <div className="bg-white rounded-xl border p-5">
          <p className="text-xs uppercase text-slate-500">Alloue</p>
          <p className="text-2xl font-bold mt-1 text-emerald-600">{totals.allocated.toLocaleString('fr-FR')} XOF</p>
        </div>
        <div className="bg-white rounded-xl border p-5">
          <p className="text-xs uppercase text-slate-500">Depense</p>
          <p className="text-2xl font-bold mt-1 text-orange-500">{totals.spent.toLocaleString('fr-FR')} XOF</p>
        </div>
        <div className="bg-white rounded-xl border p-5">
          <p className="text-xs uppercase text-slate-500">Reste</p>
          <p className="text-2xl font-bold mt-1 text-blue-600">
            {(totals.allocated - totals.spent).toLocaleString('fr-FR')} XOF
          </p>
        </div>
      </div>

      {error ? <p className="text-sm text-red-600">{error}</p> : null}

      <div className="space-y-5">
        {groupedByProject.map((group) => {
          const remaining = group.allocated - group.spent;

          return (
            <section key={group.projectId} className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
              <div className="p-5 border-b border-slate-100 bg-slate-50/60">
                <h3 className="text-lg font-bold text-slate-900">{group.projectName}</h3>
                <div className="mt-3 grid grid-cols-1 md:grid-cols-3 gap-3 text-sm">
                  <div className="rounded-lg bg-emerald-50 border border-emerald-100 px-3 py-2">
                    <p className="text-xs uppercase text-emerald-700 font-semibold">Alloue</p>
                    <p className="font-bold text-emerald-700">{group.allocated.toLocaleString('fr-FR')} XOF</p>
                  </div>
                  <div className="rounded-lg bg-orange-50 border border-orange-100 px-3 py-2">
                    <p className="text-xs uppercase text-orange-700 font-semibold">Depense</p>
                    <p className="font-bold text-orange-700">{group.spent.toLocaleString('fr-FR')} XOF</p>
                  </div>
                  <div className="rounded-lg bg-blue-50 border border-blue-100 px-3 py-2">
                    <p className="text-xs uppercase text-blue-700 font-semibold">Reste</p>
                    <p className="font-bold text-blue-700">{remaining.toLocaleString('fr-FR')} XOF</p>
                  </div>
                </div>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full text-left">
                  <thead className="bg-white border-b border-slate-100">
                    <tr>
                      <th className="p-4 text-xs font-semibold uppercase tracking-wide text-slate-500">Categorie</th>
                      <th className="p-4 text-xs font-semibold uppercase tracking-wide text-slate-500">Alloue</th>
                      <th className="p-4 text-xs font-semibold uppercase tracking-wide text-slate-500">Depense</th>
                      <th className="p-4 text-xs font-semibold uppercase tracking-wide text-slate-500">Reste</th>
                      <th className="p-4 text-xs font-semibold uppercase tracking-wide text-slate-500">Description</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {group.items.map((item) => (
                      <tr key={item.id}>
                        <td className="p-4 font-medium">{item.category}</td>
                        <td className="p-4 text-emerald-700 font-semibold">{item.allocated.toLocaleString('fr-FR')} XOF</td>
                        <td className="p-4 text-orange-700 font-semibold">{item.spent.toLocaleString('fr-FR')} XOF</td>
                        <td className={`p-4 font-semibold ${item.remaining < 0 ? 'text-rose-600' : 'text-blue-700'}`}>
                          {item.remaining.toLocaleString('fr-FR')} XOF
                        </td>
                        <td className="p-4 text-slate-600">{item.description || '-'}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </section>
          );
        })}

        {groupedByProject.length === 0 ? (
          <div className="bg-white rounded-2xl border border-slate-200 p-8 text-center text-slate-500">
            Aucun budget disponible.
          </div>
        ) : null}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <form onSubmit={submit} className="bg-white rounded-2xl p-8 w-full max-w-lg space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-bold">Nouveau budget</h2>
              <button type="button" onClick={() => setShowModal(false)}>
                <X />
              </button>
            </div>

            <select
              className="w-full border p-3 rounded"
              value={formData.projectId}
              onChange={(e) => setFormData({ ...formData, projectId: e.target.value })}
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
              className="w-full border p-3 rounded"
              value={formData.category}
              onChange={(e) => setFormData({ ...formData, category: e.target.value })}
            >
              {categories.map((category) => (
                <option key={category} value={category}>
                  {category}
                </option>
              ))}
            </select>

            <input
              type="number"
              min="0"
              placeholder="Montant alloue"
              className="w-full border p-3 rounded"
              value={formData.allocatedAmount}
              onChange={(e) => setFormData({ ...formData, allocatedAmount: e.target.value })}
              required
            />

            <textarea
              placeholder="Description"
              className="w-full border p-3 rounded"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            />

            <button type="submit" className="w-full bg-emerald-600 text-white py-3 rounded-lg font-bold">
              Enregistrer
            </button>
          </form>
        </div>
      )}
    </div>
  );
}
