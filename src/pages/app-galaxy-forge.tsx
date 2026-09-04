/**
 * One entry per product. To add one: copy this file and apps/<slug>/index.html,
 * and change the slug in both. The slug must match an entry in `apps` in
 * src/content/site.ts.
 */
import { mount } from './mount';
import { AppPage } from '../components/AppPage';

mount(<AppPage slug="galaxy-forge" />);
