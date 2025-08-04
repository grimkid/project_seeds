type FooterProps = {
  copyrightText: string;
};

export default function Footer({ copyrightText }: FooterProps) {
  return (
    <footer className="bg-gray-900 text-white p-4 text-center">
      <p>{copyrightText}</p>
    </footer>
  );
}