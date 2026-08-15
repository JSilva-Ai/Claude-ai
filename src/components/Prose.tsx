import type { Block, Section } from '../content/legal';

/**
 * Renders legal and help copy.
 *
 * A block is either a paragraph or a bullet list, which is all these documents
 * need. Any string containing "[TODO" is rendered as a visible marked note
 * rather than as body copy — the point of a template is that the unfinished
 * parts are impossible to miss, including by whoever ships the site in a hurry.
 */

function isTodo(s: string) {
  return s.includes('[TODO');
}

export function Blocks({ blocks }: { blocks: Block[] }) {
  return (
    <>
      {blocks.map((block, i) =>
        Array.isArray(block) ? (
          <ul className="prose__list" key={i}>
            {block.map((item) => (
              <li key={item}>{item}</li>
            ))}
          </ul>
        ) : isTodo(block) ? (
          <p className="todo" key={i}>
            {block}
          </p>
        ) : (
          <p key={i}>{block}</p>
        ),
      )}
    </>
  );
}

export function Sections({ sections }: { sections: Section[] }) {
  return (
    <>
      {sections.map((section) => (
        <section className="prose__section" key={section.heading}>
          <h2 className="prose__h2" id={slug(section.heading)}>
            {section.heading}
          </h2>
          <Blocks blocks={section.body} />
        </section>
      ))}
    </>
  );
}

/** A table of contents. Legal pages get long and reviewers scan them. */
export function Toc({ sections, label }: { sections: Section[]; label: string }) {
  return (
    <nav className="toc" aria-label={label}>
      <p className="label toc__label">{label}</p>
      <ol className="toc__list">
        {sections.map((s) => (
          <li key={s.heading}>
            <a href={`#${slug(s.heading)}`}>{s.heading}</a>
          </li>
        ))}
      </ol>
    </nav>
  );
}

export function slug(heading: string): string {
  return heading
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}
