// src/components/Footer.tsx

// Definim un tip pentru un singur link din sitemap
type FooterLink = {
  label: string;
  link: string;
}

// --- MODIFICARE AICI: Am adăugat proprietățile lipsă ---
// Definim tipurile pentru TOATE datele pe care le poate primi Footer-ul
// Folosim `?` pentru a le face opționale, astfel încât componenta
// să nu crape dacă datele lipsesc din CMS.
type FooterProps = {
  copyrightText?: string;
  contactInfo?: string;
  sitemapLinks?: FooterLink[];
};

export default function Footer({ copyrightText, contactInfo, sitemapLinks }: FooterProps) {
  return (
    <footer className="bg-gray-900 text-white p-6 text-center">
      <div className="container mx-auto">
        {/* Afișează informațiile de contact doar dacă există */}
        {contactInfo && <p className="mb-2">{contactInfo}</p>}
        
        {/* Afișează link-urile de sitemap doar dacă există și nu sunt goale */}
        {sitemapLinks && sitemapLinks.length > 0 && (
          <nav className="mb-4">
            <ul className="flex justify-center space-x-4">
              {sitemapLinks.map(item => (
                <li key={item.link}>
                  <a href={item.link} className="hover:underline">{item.label}</a>
                </li>
              ))}
            </ul>
          </nav>
        )}

        {/* Afișează textul de copyright doar dacă există */}
        {copyrightText && <p className="text-sm text-gray-400">{copyrightText}</p>}
      </div>
    </footer>
  );
}