import React from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import Translate, {translate} from '@docusaurus/Translate';
import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
      <div class="impressum">
    <h1 class="hero__title">Ludaro.de Impressum</h1>
    <p><strong>Inhaber:</strong>Lukas Geißbauer</p>
    <p><strong>Kontaktadresse:</strong>c/o RA Matutis</p>
    <p><strong>Straße:</strong> Berliner Straße 57</p>
    <p><strong>PLZ, Stadt:</strong> 14467 Potsdam</p>
    <p><strong>Land:</strong> Deutschland</p>
    <p><strong>E-Mail:</strong>ludaro@ludaro.de</p>
</div>
</div>

        
    </header>
  );
}

export default function Home() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`Ludaro.de Wiki!`}
      description= "Ludaro.de Wiki!" >
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
