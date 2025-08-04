import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

import Header from "@/components/Header";
import Footer from "@/components/Footer";
import { fetchDotCMS } from "@/lib/dotcms";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Site-ul Meu Next.js cu dotCMS",
};

// O interogare GraphQL separată pentru datele globale (Meniu, Footer)
const GET_GLOBAL_DATA = `
  query {
    ComponentaMeniuCollection(limit: 1) {
      menuItems {
        label
        link
      }
    }
    TextCopyrightCollection(limit: 1) {
      text
    }
  }
`;

// Layout-ul devine o funcție asincronă!
export default async function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  
  // Preluăm datele globale direct pe server
  const globalData = await fetchDotCMS<any>({ query: GET_GLOBAL_DATA });
  const menuItems = globalData?.ComponentaMeniuCollection?.[0]?.menuItems || [];
  const copyrightText = globalData?.TextCopyrightCollection?.[0]?.text || "© 2025 Compania Mea";

  return (
    <html lang="ro">
      <body className={`${inter.className} flex flex-col min-h-screen`}>
        {/* Pasăm datele globale către componentele Header și Footer */}
        <Header menuItems={menuItems} />
        
        <main className="flex-grow">
          {children} {/* Aici va fi randat conținutul paginii specifice */}
        </main>

        <Footer copyrightText={copyrightText} />
      </body>
    </html>
  );
}