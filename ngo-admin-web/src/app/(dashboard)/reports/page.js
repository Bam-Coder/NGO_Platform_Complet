'use client';

import { useEffect, useMemo, useState } from 'react';
import Image from 'next/image';
import { MapPin, Users, Calendar, Image as ImageIcon, Plus, X } from 'lucide-react';
import api from '@/lib/axios';
import { uploadImage } from '@/lib/upload';
import { resolveMediaUrl } from '@/lib/media';
import { useAuthStore } from '@/store/authStore';

const initialForm = {
  projectId: '',
  title: '',
  description: '',
  beneficiariesCount: '',
  activitiesDone: '',
  gpsLat: '',
  gpsLng: '',
  date: new Date().toISOString().slice(0, 10),
};

function safeCoord(value) {
  const num = Number(value);
  return Number.isFinite(num) ? num.toFixed(4) : '-';
}

function getFirstPhotoUrl(report) {
  if (Array.isArray(report?.photos)) {
    return report.photos[0] || '';
  }
  if (typeof report?.photos === 'string') {
    return report.photos.split(',')[0] || '';
  }
  return '';
}

export default function ReportsPage() {
  const [reports, setReports] = useState([]);
  const [projects, setProjects] = useState([]);
  const [photo, setPhoto] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [formData, setFormData] = useState(initialForm);
  const user = useAuthStore((state) => state.user);
  const totalBeneficiaries = useMemo(
    () => reports.reduce((sum, report) => sum + Number(report.beneficiariesCount || 0), 0),
    [reports],
  );
  const reportsWithPhotos = useMemo(
    () =>
      reports.filter((report) => {
        if (Array.isArray(report.photos)) return report.photos.length > 0;
        if (typeof report.photos === 'string') return report.photos.trim().length > 0;
        return false;
      }).length,
    [reports],
  );

  const fetchData = async () => {
    const [reportsRes, projectsRes] = await Promise.allSettled([api.get('/impact-reports'), api.get('/projects')]);

    if (reportsRes.status === 'fulfilled') {
      setReports(reportsRes.value.data || []);
    } else {
      setReports([]);
      setError("Impossible de charger les rapports d'impact.");
    }

    if (projectsRes.status === 'fulfilled') {
      setProjects(projectsRes.value.data || []);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const createReport = async (event) => {
    event.preventDefault();

    if (!user?.id) {
      setError('Session invalide. Reconnecte-toi.');
      return;
    }

    setError('');
    setLoading(true);

    try {
      let photos = [];
      if (photo) {
        const uploaded = await uploadImage(photo);
        if (uploaded) photos = [uploaded];
      }

      const projectId = Number(formData.projectId);
      await api.post(`/impact-reports/${projectId}/${user.id}`, {
        projectId,
        title: formData.title,
        description: formData.description,
        beneficiariesCount: Number(formData.beneficiariesCount),
        activitiesDone: formData.activitiesDone,
        photos,
        gpsLat: formData.gpsLat ? Number(formData.gpsLat) : undefined,
        gpsLng: formData.gpsLng ? Number(formData.gpsLng) : undefined,
        date: formData.date,
      });

      setShowModal(false);
      setPhoto(null);
      setFormData(initialForm);
      fetchData();
    } catch (err) {
      const message = err?.response?.data?.message;
      setError(Array.isArray(message) ? message.join(' ') : message || 'Creation du rapport impossible.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6 space-y-8 bg-[#F8FAFC] min-h-screen text-slate-900">
      <div className="flex flex-col md:flex-row md:justify-between md:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Rapports d&apos;impact terrain</h1>
          <p className="text-sm text-slate-500 mt-1">Consolidation des activites, preuves terrain et beneficiaries.</p>
        </div>
        <button
          onClick={() => setShowModal(true)}
          className="bg-emerald-600 text-white px-4 py-2 rounded-xl flex items-center gap-2 text-sm font-semibold shadow-sm hover:bg-emerald-700"
        >
          <Plus size={18} /> Nouveau rapport
        </button>
      </div>

      {error ? <p className="text-sm text-red-600">{error}</p> : null}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Rapports soumis</p>
          <p className="text-2xl font-bold text-slate-900 mt-2">{reports.length}</p>
        </div>
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Beneficiaires cumules</p>
          <p className="text-2xl font-bold text-emerald-700 mt-2">{totalBeneficiaries.toLocaleString('fr-FR')}</p>
        </div>
        <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
          <p className="text-xs uppercase tracking-wide text-slate-500 font-semibold">Rapports avec photos</p>
          <p className="text-2xl font-bold text-blue-600 mt-2">{reportsWithPhotos}</p>
        </div>
      </div>

      <div className="space-y-6">
        {reports.map((report) => {
          const firstPhoto = getFirstPhotoUrl(report);

          return (
            <div key={report.id} className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
              <div className="md:flex">
                <div className="md:w-1/3 bg-slate-100 h-48 md:h-auto relative flex items-center justify-center">
                  {firstPhoto ? (
                    <Image
                      src={resolveMediaUrl(firstPhoto)}
                      alt="Impact"
                      fill
                      className="object-cover"
                      sizes="(max-width: 768px) 100vw, 33vw"
                      unoptimized
                    />
                  ) : (
                    <ImageIcon className="text-slate-300" size={48} />
                  )}
                  <div className="absolute bottom-2 right-2 bg-black/60 text-white text-[10px] px-2 py-1 rounded">
                    {Array.isArray(report.photos)
                      ? report.photos.length
                      : typeof report.photos === 'string' && report.photos
                        ? report.photos.split(',').filter(Boolean).length
                        : 0}{' '}
                    photos
                  </div>
                </div>

                <div className="p-6 md:w-2/3 space-y-4">
                  <div className="flex justify-between items-start">
                    <div>
                      <h2 className="text-xl font-bold text-slate-900">{report.title}</h2>
                      <p className="text-sm text-emerald-600 font-semibold">
                        Projet: {report.project?.name || `#${report.project?.id || '-'}`}
                      </p>
                      <p className="text-xs text-slate-500 mt-1">Auteur: {report.createdBy?.name || '-'}</p>
                    </div>
                    <span className="text-sm text-slate-400 flex items-center gap-1">
                      <Calendar size={14} /> {(report.date || '').slice(0, 10)}
                    </span>
                  </div>

                  <p className="text-slate-600 text-sm leading-relaxed">{report.description}</p>
                  <p className="text-xs text-slate-500 bg-slate-50 rounded-lg p-2.5">Activites: {report.activitiesDone}</p>

                  <div className="grid grid-cols-2 md:grid-cols-3 gap-4 pt-4 border-t border-slate-100">
                    <div className="flex items-center gap-2 text-slate-700">
                      <Users className="text-blue-500" size={18} />
                      <div>
                        <p className="text-[10px] uppercase text-slate-400 font-bold">Beneficiaires</p>
                        <p className="font-bold">{Number(report.beneficiariesCount || 0)}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2 text-slate-700">
                      <MapPin className="text-red-500" size={18} />
                      <div>
                        <p className="text-[10px] uppercase text-slate-400 font-bold">Coordonnees</p>
                        <p className="font-mono text-[11px]">
                          {safeCoord(report.gpsLat)}, {safeCoord(report.gpsLng)}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          );
        })}

        {reports.length === 0 ? (
          <p className="text-center text-slate-400 py-20">Aucun rapport d&apos;impact soumis pour le moment.</p>
        ) : null}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <form onSubmit={createReport} className="bg-white rounded-2xl p-8 w-full max-w-xl space-y-4 max-h-[90vh] overflow-y-auto border border-slate-200">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-bold">Nouveau rapport d&apos;impact</h2>
              <button type="button" onClick={() => setShowModal(false)} className="text-slate-500 hover:text-slate-700">
                <X />
              </button>
            </div>

            <select
              className="w-full border border-slate-200 p-3 rounded-xl"
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

            <input
              type="text"
              placeholder="Titre"
              className="w-full border border-slate-200 p-3 rounded-xl"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              required
            />

            <textarea
              placeholder="Description"
              className="w-full border border-slate-200 p-3 rounded-xl"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              required
            />

            <textarea
              placeholder="Activites realisees"
              className="w-full border border-slate-200 p-3 rounded-xl"
              value={formData.activitiesDone}
              onChange={(e) => setFormData({ ...formData, activitiesDone: e.target.value })}
              required
            />

            <input
              type="number"
              min="0"
              placeholder="Nombre de beneficiaires"
              className="w-full border border-slate-200 p-3 rounded-xl"
              value={formData.beneficiariesCount}
              onChange={(e) => setFormData({ ...formData, beneficiariesCount: e.target.value })}
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
              onChange={(e) => setPhoto(e.target.files?.[0] || null)}
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
              {loading ? 'Enregistrement...' : 'Soumettre rapport'}
            </button>
          </form>
        </div>
      )}
    </div>
  );
}
