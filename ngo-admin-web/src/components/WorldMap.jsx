'use client';
import Image from 'next/image';

export default function WorldMap() {
  const points = [
    { top: '65%', left: '48%', label: 'Bamako, Mali', delay: '0s' },
    { top: '72%', left: '52%', label: 'Lagos, Nigeria', delay: '1.2s' },
    { top: '68%', left: '25%', label: 'Bogota, Colombie', delay: '0.8s' },
    { top: '45%', left: '82%', label: 'Hanoi, Vietnam', delay: '2s' },
  ];

  return (
    <div className="relative w-full aspect-video bg-slate-950/40 rounded-[3rem] border border-white/5 overflow-hidden group">
      {/* Texture de grille technologique */}
      <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/carbon-fibre.png')] opacity-20" />
      
      {/* Image de la carte du monde en fond (Sillhouette sombre) */}
      <Image
        src="https://upload.wikimedia.org/wikipedia/commons/e/ec/World_map_blank_without_borders.svg"
        className="absolute inset-0 object-contain opacity-10 invert p-12"
        alt="World Map"
        fill
        sizes="100vw"
      />

      {/* Points d'impact pulsants */}
      {points.map((p, i) => (
        <div 
          key={i} 
          className="absolute group/point" 
          style={{ top: p.top, left: p.left }}
        >
          {/* L'anneau qui pulse */}
          <div className="absolute -inset-4 bg-emerald-500/30 rounded-full animate-ping" style={{ animationDelay: p.delay }} />
          {/* Le point central */}
          <div className="relative w-3 h-3 bg-emerald-400 rounded-full shadow-[0_0_15px_rgba(52,211,153,0.8)] border border-white/20 cursor-pointer" />
          
          {/* Tooltip au survol */}
          <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-3 px-3 py-1 bg-slate-900 border border-white/10 rounded-lg text-[10px] font-bold whitespace-nowrap opacity-0 group-hover/point:opacity-100 transition-opacity pointer-events-none">
            {p.label}
          </div>
        </div>
      ))}

      {/* Legend / Info Overlay */}
      <div className="absolute top-8 left-8 p-4 border-l-2 border-emerald-500 bg-black/20 backdrop-blur">
        <p className="text-[10px] uppercase tracking-[0.3em] text-emerald-500 font-black">Réseau Global</p>
        <p className="text-xl font-bold">Auditabilité sans frontières</p>
      </div>
    </div>
  );
}
