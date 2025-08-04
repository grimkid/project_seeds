// src/app/layout.tsx

import type { Metadata } from "next";
import "./globals.css"; // Importă stilurile Tailwind

// Metadate pentru SEO. Le putem popula dinamic mai târziu.
export const metadata: Metadata = {
  title: "Platformă Digitală",
  description: "O nouă platformă digitală modernă",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ro">
      <body>
        {/* Aici vom adăuga Header-ul și Footer-ul mai târziu */}
        <main>
          {/* 'children' este locul unde Next.js va injecta
              conținutul paginilor (de ex., conținutul din page.tsx) */}
          {children}
        </main>
      </body>
    </html>
  );
}