import './globals.css';

export const metadata = {
  title: 'NGO Admin Platform',
  description: 'Pilotage des projets, budgets et impacts NGO',
};

export default function RootLayout({ children }) {
  return (
    <html lang="fr">
      <body>{children}</body>
    </html>
  );
}
