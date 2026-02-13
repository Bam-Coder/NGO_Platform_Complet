'use client';

import { useEffect } from 'react';
import { usePathname, useRouter } from 'next/navigation';
import Sidebar from '@/components/Sidebar';
import { useAuthStore } from '@/store/authStore';

export default function DashboardLayout({ children }) {
  const pathname = usePathname();
  const router = useRouter();
  const hydrateAuth = useAuthStore((state) => state.hydrateAuth);

  useEffect(() => {
    hydrateAuth();
    const token = localStorage.getItem('token');
    if (!token && !pathname.startsWith('/login')) {
      router.replace('/login');
    }
  }, [hydrateAuth, pathname, router]);

  return (
    <div className="min-h-screen bg-slate-50">
      <Sidebar />
      <main className="ml-72 p-6">{children}</main>
    </div>
  );
}
