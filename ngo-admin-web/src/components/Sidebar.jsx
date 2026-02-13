'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  LayoutDashboard,
  Briefcase,
  Receipt,
  Users,
  FileText,
  LogOut,
  Wallet,
  Landmark,
} from 'lucide-react';
import { useAuthStore } from '@/store/authStore';

const menu = [
  { name: 'Dashboard', path: '/dashboard', icon: LayoutDashboard, roles: ['ADMIN', 'AGENT', 'FINANCE', 'DONOR'] },
  { name: 'Projets', path: '/projects', icon: Briefcase, roles: ['ADMIN', 'AGENT', 'FINANCE', 'DONOR'] },
  { name: 'Budgets', path: '/budgets', icon: Wallet, roles: ['ADMIN', 'FINANCE'] },
  { name: 'Depenses', path: '/expenses', icon: Receipt, roles: ['ADMIN', 'AGENT', 'FINANCE'] },
  { name: 'Rapports', path: '/reports', icon: FileText, roles: ['ADMIN', 'AGENT', 'FINANCE', 'DONOR'] },
  { name: 'Donateurs', path: '/donors', icon: Landmark, roles: ['ADMIN', 'FINANCE', 'DONOR'] },
  { name: 'Utilisateurs', path: '/users', icon: Users, roles: ['ADMIN'] },
];

export default function Sidebar() {
  const pathname = usePathname();
  const logout = useAuthStore((state) => state.logout);
  const user = useAuthStore((state) => state.user);
  const role = user?.role || 'AGENT';

  const visibleMenu = menu.filter((item) => item.roles.includes(role));

  return (
    <aside className="w-72 bg-slate-900 h-screen fixed text-white p-4 flex flex-col">
      <div className="text-2xl font-bold text-emerald-500 mb-2 px-2">NGO Admin</div>
      <div className="text-xs text-slate-400 px-2 mb-8">Role actif: {role}</div>

      <nav className="space-y-2 flex-1">
        {visibleMenu.map((item) => {
          const isActive = pathname === item.path || pathname.startsWith(`${item.path}/`);
          return (
            <Link
              key={item.path}
              href={item.path}
              className={`flex items-center gap-3 p-3 rounded-lg transition ${
                isActive ? 'bg-emerald-600 text-white' : 'text-slate-300 hover:bg-slate-800'
              }`}
            >
              <item.icon size={19} /> {item.name}
            </Link>
          );
        })}
      </nav>

      <button
        onClick={logout}
        className="flex items-center gap-3 p-3 text-red-300 hover:bg-slate-800 rounded-lg"
      >
        <LogOut size={20} /> Deconnexion
      </button>
    </aside>
  );
}
