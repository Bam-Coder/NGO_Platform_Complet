'use client';

import { useEffect, useMemo, useState } from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  LineChart,
  Line,
} from 'recharts';
import api from '@/lib/axios';

function monthLabel(dateString) {
  if (!dateString) return 'N/A';
  const date = new Date(dateString);
  if (Number.isNaN(date.getTime())) return 'N/A';
  return date.toLocaleString('fr-FR', { month: 'short' });
}

function formatAmount(value) {
  return Number(value || 0).toLocaleString('fr-FR');
}

export default function DashboardPage() {
  const [projects, setProjects] = useState([]);
  const [donors, setDonors] = useState([]);
  const [expenses, setExpenses] = useState([]);
  const [reports, setReports] = useState([]);

  useEffect(() => {
    Promise.allSettled([
      api.get('/projects'),
      api.get('/donors'),
      api.get('/expenses'),
      api.get('/impact-reports'),
    ]).then(([projectsRes, donorsRes, expensesRes, reportsRes]) => {
      setProjects(projectsRes.status === 'fulfilled' ? projectsRes.value.data || [] : []);
      setDonors(donorsRes.status === 'fulfilled' ? donorsRes.value.data || [] : []);
      setExpenses(expensesRes.status === 'fulfilled' ? expensesRes.value.data || [] : []);
      setReports(reportsRes.status === 'fulfilled' ? reportsRes.value.data || [] : []);
    });
  }, []);

  const totalBudget = useMemo(
    () => projects.reduce((sum, project) => sum + Number(project.budgetTotal || 0), 0),
    [projects],
  );

  const spent = useMemo(
    () => expenses.filter((item) => item.status === 'APPROVED').reduce((sum, item) => sum + Number(item.amount || 0), 0),
    [expenses],
  );

  const pendingExpenses = useMemo(
    () => expenses.filter((expense) => expense.status === 'PENDING').length,
    [expenses],
  );

  const expensesByMonth = useMemo(() => {
    const map = new Map();

    for (const expense of expenses) {
      const key = monthLabel(expense.date);
      map.set(key, (map.get(key) || 0) + Number(expense.amount || 0));
    }

    return Array.from(map, ([name, value]) => ({ name, value }));
  }, [expenses]);

  const projectByStatus = useMemo(() => {
    const map = new Map();

    for (const project of projects) {
      const key = project.status || 'UNKNOWN';
      map.set(key, (map.get(key) || 0) + 1);
    }

    return Array.from(map, ([name, value]) => ({ name, value }));
  }, [projects]);

  return (
    <div className="p-6 space-y-8 bg-[#F8FAFC] min-h-screen text-slate-900">
      <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-3">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-slate-900">Tableau de bord global</h1>
          <p className="text-slate-500 mt-1">Vue strategique projets, finances, impacts et bailleurs.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Projets</p>
          <p className="text-2xl font-bold mt-1">{projects.length}</p>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Budget total</p>
          <p className="text-2xl font-bold mt-1 text-emerald-600">{formatAmount(totalBudget)}</p>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Depenses approuvees</p>
          <p className="text-2xl font-bold mt-1 text-blue-600">{formatAmount(spent)}</p>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Depenses en attente</p>
          <p className="text-2xl font-bold mt-1 text-orange-500">{pendingExpenses}</p>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Rapports d&apos;impact</p>
          <p className="text-2xl font-bold mt-1 text-fuchsia-600">{reports.length}</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 h-[360px]">
          <h3 className="text-lg font-bold mb-1">Depenses par mois</h3>
          <p className="text-xs text-slate-500 mb-4">Evolution mensuelle des montants declares.</p>
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={expensesByMonth}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="value" stroke="#3b82f6" strokeWidth={3} />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 h-[360px]">
          <h3 className="text-lg font-bold mb-1">Projets par statut</h3>
          <p className="text-xs text-slate-500 mb-4">Repartition actuelle du portefeuille projets.</p>
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={projectByStatus}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} />
              <XAxis dataKey="name" />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Bar dataKey="value" fill="#10b981" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm">
        <h3 className="text-lg font-bold">Donateurs actifs</h3>
        <p className="text-slate-600 text-sm mt-1 mb-4">Nombre total: {donors.length}</p>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
          {donors.slice(0, 6).map((donor) => (
            <div key={donor.id} className="border border-slate-200 rounded-xl p-3 bg-slate-50/70">
              <p className="font-semibold">{donor.name}</p>
              <p className="text-xs text-slate-500">{donor.type}</p>
              <p className="text-sm text-emerald-600 font-semibold mt-1">
                {formatAmount(donor.fundedAmount)} {donor.currency || 'XOF'}
              </p>
            </div>
          ))}
        </div>
        {donors.length === 0 ? <p className="text-sm text-slate-400">Aucun donateur disponible.</p> : null}
      </div>
    </div>
  );
}
