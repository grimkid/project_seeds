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


const GET_GLOBAL_DATA = `query GetGlobalData {
  ComponentaMeniuCollection(limit: 1) {
    linkUriMeniu {
      title
      urlLink
    }
  }
  TextCopyrightCollection(limit: 1) {
    textCopyright
    infoContact
    linkUriSitemap {
      title
      urlLink
    }
  }
}`;

// Layout-ul devine o funcție asincronă!
export default async function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  
  // Debug: log query-ul GraphQL efectiv
  console.log("QUERY TRIMIS LA DOTCMS:\n", GET_GLOBAL_DATA);
  // Preluăm datele globale direct pe server
  const globalData = await fetchDotCMS<any>({ query: GET_GLOBAL_DATA });
  const rawMenuItems = globalData?.ComponentaMeniuCollection?.[0]?.linkUriMeniu || [];
  const menuItems = rawMenuItems.map((item: any) => ({
    label: item.title,
    link: item.urlLink
  }));
  const footerData = globalData?.TextCopyrightCollection?.[0];
  const copyrightText = footerData?.textCopyright || "© 2025 Compania Mea";
  const rawSitemapLinks = footerData?.linkUriSitemap || [];
  const sitemapLinks = rawSitemapLinks.map((item: any) => ({
    label: item.title,
    link: item.urlLink
  }));

  return (
    <html lang="ro">
      <body className={`${inter.className} flex flex-col min-h-screen`}>
        {/* Pasăm datele procesate către componente */}
        <Header menuItems={menuItems} />
        
        <main className="flex-grow">
          {children}
        </main>

        {/* Trebuie să ajustăm și componenta Footer să accepte noile date */}
        <Footer 
          copyrightText={copyrightText} 
          contactInfo={footerData?.infoContact}
          sitemapLinks={sitemapLinks} 
        />
      </body>
    </html>
  );
}