type BannerProps = {
  title: string;
  subtitlu: string;
  imagineFundal?: { // Câmpul este opțional
    path: string;
  };
};

export default function Banner({ title, subtitlu, imagineFundal }: BannerProps) {
  const bgStyle = imagineFundal 
    ? { backgroundImage: `url(http://nginx-server${imagineFundal.path})` }
    : {};

  return (
    <section className="h-64 bg-cover bg-center text-white flex flex-col justify-center items-center" style={bgStyle}>
      <h1 className="text-4xl font-bold">{title}</h1>
      <p className="text-xl">{subtitlu}</p>
    </section>
  );
}