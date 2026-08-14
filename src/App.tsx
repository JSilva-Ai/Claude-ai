import { Nav } from './components/Nav';
import { Hero } from './components/Hero';
import { Thesis } from './components/Thesis';
import { Capabilities } from './components/Capabilities';
import { ProvingGrounds } from './components/ProvingGrounds';
import { Research } from './components/Research';
import { Applications } from './components/Applications';
import { Lab } from './components/Lab';
import { Contact } from './components/Contact';
import { Footer } from './components/Footer';

export default function App() {
  return (
    <>
      <Nav />
      <Hero />
      <main id="main">
        <Thesis />
        <Capabilities />
        <ProvingGrounds />
        <Research />
        <Applications />
        <Lab />
        <Contact />
      </main>
      <Footer />
    </>
  );
}
