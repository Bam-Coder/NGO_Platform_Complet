'use client';

import Link from 'next/link';
import Image from 'next/image';
import {
  Activity,
  ArrowRight,
  BarChart3,
  FileCheck2,
  Globe2,
  MapPinned,
  Shield,
  Wallet,
  Users,
  Zap,
} from 'lucide-react';

const modules = [
  {
    icon: BarChart3,
    title: 'Pilotage des projets',
    description: 'Vue globale des statuts, assignations et execution terrain en temps reel.',
  },
  {
    icon: Wallet,
    title: 'Controle budgetaire',
    description: 'Budgets alloues, depenses approuvees et alertes de depassement par projet.',
  },
  {
    icon: FileCheck2,
    title: 'Validation terrain',
    description: 'Verification des justificatifs (photo, GPS, date) avec historique d approbation.',
  },
  {
    icon: MapPinned,
    title: 'Rapports d impact',
    description: 'Consolidation des activites terrain et beneficiaires avec preuves visuelles.',
  },
  {
    icon: Users,
    title: 'Gestion des donateurs',
    description: 'Suivi des contributeurs, montants finances et traçabilite par devise et pays.',
  },
  {
    icon: Shield,
    title: 'RBAC et gouvernance',
    description: 'Permissions strictes par role pour proteger les operations et l audit.',
  },
];

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-[#020617] text-slate-100 overflow-x-hidden">
      <div className="fixed inset-0 pointer-events-none">
        <div className="absolute -top-40 -left-20 h-96 w-96 rounded-full bg-emerald-500/20 blur-[120px]" />
        <div className="absolute top-1/3 -right-20 h-96 w-96 rounded-full bg-blue-500/20 blur-[120px]" />
      </div>

      <header className="relative z-10 border-b border-white/10 bg-slate-950/70 backdrop-blur-xl">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <span className="h-9 w-9 rounded-lg bg-emerald-400 text-slate-900 flex items-center justify-center shadow-lg shadow-emerald-500/30">
              <Zap size={18} />
            </span>
            <div className="font-black tracking-[0.06em] text-lg">NGO CONTROL</div>
          </div>
          <div className="flex items-center gap-3">
            <Link href="/login" className="px-4 py-2 rounded-xl border border-white/20 hover:bg-white/10 text-sm font-semibold">
              Se connecter
            </Link>
            <Link
              href="/register"
              className="px-4 py-2 rounded-xl bg-emerald-400 hover:bg-emerald-300 text-slate-950 text-sm font-extrabold"
            >
              Creer un compte
            </Link>
          </div>
        </div>
      </header>

      <main className="relative z-10">
        <section className="max-w-7xl mx-auto px-6 pt-16 pb-12 grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          <div>
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-emerald-400/25 bg-emerald-400/10 text-emerald-300 text-xs font-bold uppercase tracking-wider">
              <Activity size={13} />
              Back-office NGO en temps reel
            </div>
            <h1 className="text-5xl md:text-6xl font-black mt-6 leading-[1.02] tracking-tight">
              Gouverner les projets terrain
              <br />
              avec precision financiere.
            </h1>
            <p className="text-slate-300 mt-6 max-w-2xl text-lg leading-relaxed">
              Une plateforme admin qui relie mobile et web pour controler depenses, budgets, rapports d impact et audit. Toute la chaine reste verifiable, du terrain jusqu au bailleur.
            </p>
            <div className="mt-10 flex flex-wrap gap-4">
              <Link
                href="/register"
                className="px-6 py-3 rounded-2xl bg-emerald-400 hover:bg-emerald-300 text-slate-950 font-extrabold inline-flex items-center gap-2 shadow-xl shadow-emerald-500/25"
              >
                Demarrer maintenant <ArrowRight size={18} />
              </Link>
              <Link href="/login" className="px-6 py-3 rounded-2xl border border-white/20 hover:bg-white/10 font-bold">
                Ouvrir le dashboard
              </Link>
            </div>
            <div className="mt-10 grid grid-cols-2 md:grid-cols-3 gap-3 max-w-xl">
              <div className="rounded-xl border border-white/15 bg-white/5 p-3">
                <p className="text-xs text-slate-400 uppercase font-semibold">Projets</p>
                <p className="text-2xl font-black mt-1">12</p>
              </div>
              <div className="rounded-xl border border-white/15 bg-white/5 p-3">
                <p className="text-xs text-slate-400 uppercase font-semibold">Depenses</p>
                <p className="text-2xl font-black mt-1">284</p>
              </div>
              <div className="rounded-xl border border-white/15 bg-white/5 p-3 col-span-2 md:col-span-1">
                <p className="text-xs text-slate-400 uppercase font-semibold">Donateurs</p>
                <p className="text-2xl font-black mt-1">37</p>
              </div>
            </div>
          </div>

          <div className="rounded-3xl border border-white/15 bg-white/5 p-3 shadow-2xl">
            <div className="relative h-[420px] w-full overflow-hidden rounded-2xl">
              <Image
                src="https://images.unsplash.com/photo-1559027615-cd4628902d4a?auto=format&fit=crop&w=1400&q=80"
                alt="Equipe NGO en coordination terrain"
                fill
                className="object-cover"
                sizes="(max-width: 1024px) 100vw, 50vw"
                unoptimized
                priority
              />
              <div className="absolute inset-0 bg-gradient-to-t from-slate-950/70 via-transparent to-transparent" />
              <div className="absolute bottom-4 left-4 right-4 grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div className="rounded-xl bg-slate-950/75 border border-white/10 p-3">
                  <p className="text-xs uppercase text-emerald-300 font-semibold">Validation</p>
                  <p className="text-sm text-slate-200 mt-1">Workflow finance/admin strict</p>
                </div>
                <div className="rounded-xl bg-slate-950/75 border border-white/10 p-3">
                  <p className="text-xs uppercase text-cyan-300 font-semibold">Traçabilite</p>
                  <p className="text-sm text-slate-200 mt-1">Preuves GPS + photo + horodatage</p>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section className="max-w-7xl mx-auto px-6 py-8">
          <div className="rounded-3xl border border-white/15 bg-white/[0.04] p-6 md:p-8">
            <div className="flex items-center gap-2 text-cyan-300 text-sm font-semibold uppercase tracking-wider">
              <Globe2 size={16} />
              Vision operationnelle
            </div>
            <div className="mt-4 grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="rounded-xl bg-black/30 border border-white/10 p-4">
                <p className="text-xs uppercase text-slate-300">Collecte terrain</p>
                <p className="text-sm mt-1 text-slate-100">Depenses et preuves GPS/photos envoyees depuis mobile.</p>
              </div>
              <div className="rounded-xl bg-black/30 border border-white/10 p-4">
                <p className="text-xs uppercase text-slate-300">Validation management</p>
                <p className="text-sm mt-1 text-slate-100">Finance/Admin approuvent et controlent l execution.</p>
              </div>
              <div className="rounded-xl bg-black/30 border border-white/10 p-4">
                <p className="text-xs uppercase text-slate-300">Reporting bailleurs</p>
                <p className="text-sm mt-1 text-slate-100">Historique, indicateurs et transparence pour audits.</p>
              </div>
            </div>
          </div>
        </section>

        <section className="max-w-7xl mx-auto px-6 pb-20 pt-4">
          <h2 className="text-2xl md:text-3xl font-extrabold mb-6">Modules cles de la plateforme</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            {modules.map((module) => (
              <article
                key={module.title}
                className="rounded-2xl border border-white/15 bg-white/[0.04] p-6 hover:bg-white/[0.08] transition"
              >
                <module.icon size={20} className="text-cyan-300" />
                <h3 className="font-bold text-lg mt-3">{module.title}</h3>
                <p className="text-slate-200/85 mt-3 text-sm leading-relaxed">{module.description}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="max-w-7xl mx-auto px-6 pb-24">
          <div className="rounded-3xl border border-emerald-300/30 bg-emerald-400/10 p-8 md:p-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-5">
            <div>
              <h3 className="text-2xl font-black">Pret a industrialiser ton back-office NGO ?</h3>
              <p className="text-slate-100/90 mt-2 text-sm">
                Cree un compte admin, connecte ton equipe mobile et pilote les operations avec une gouvernance claire.
              </p>
            </div>
            <div className="flex gap-3">
              <Link
                href="/register"
                className="px-5 py-3 rounded-xl bg-emerald-300 text-slate-950 font-extrabold hover:bg-emerald-200"
              >
                Creer un compte
              </Link>
              <Link href="/login" className="px-5 py-3 rounded-xl border border-white/30 hover:bg-white/10 font-bold">
                Se connecter
              </Link>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}
