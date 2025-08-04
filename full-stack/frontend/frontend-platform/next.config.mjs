/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    // Adăugăm aici originea de la care vine cererea în browser.
    // Aceasta permite funcționarea corectă a hot-reload-ului.
    allowedDevOrigins: ["http://192.168.88.32"],
  },
};

export default nextConfig;