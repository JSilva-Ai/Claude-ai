import { mount } from './mount';
import { PageHead } from '../components/Shell';
import { Blocks, Sections, Toc } from '../components/Prose';
import { privacy } from '../content/legal';
import { ui } from '../content/site';

mount(
  <>
    <PageHead
      title={privacy.title}
      meta={<p className="mono pagehead__updated">{ui.lastUpdated}: {privacy.updated}</p>}
    />
    <section className="section">
      <div className="container prose__layout">
        <Toc sections={privacy.sections} label={ui.onThisPage} />
        <div className="prose">
          <Blocks blocks={privacy.intro} />
          <Sections sections={privacy.sections} />
        </div>
      </div>
    </section>
  </>,
);
