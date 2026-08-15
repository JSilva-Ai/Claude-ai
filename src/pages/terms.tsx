import { mount } from './mount';
import { PageHead } from '../components/Shell';
import { Blocks, Sections, Toc } from '../components/Prose';
import { terms } from '../content/legal';
import { ui } from '../content/site';

mount(
  <>
    <PageHead
      title={terms.title}
      meta={<p className="mono pagehead__updated">{ui.lastUpdated}: {terms.updated}</p>}
    />
    <section className="section">
      <div className="container prose__layout">
        <Toc sections={terms.sections} label={ui.onThisPage} />
        <div className="prose">
          <Blocks blocks={terms.intro} />
          <Sections sections={terms.sections} />
        </div>
      </div>
    </section>
  </>,
);
