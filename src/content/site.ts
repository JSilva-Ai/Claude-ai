/**
 * All visible copy lives here. Sections consume it; nothing is hardcoded in
 * JSX. Keeping it in one file is what makes a copy pass possible without
 * touching layout.
 */

export const nav = [
  { id: 'thesis', label: 'Thesis' },
  { id: 'capabilities', label: 'Capabilities' },
  { id: 'proving-grounds', label: 'Proving Grounds' },
  { id: 'research', label: 'Research' },
  { id: 'applications', label: 'Applications' },
  { id: 'lab', label: 'Lab' },
] as const;

export const hero = {
  status: 'Ten worlds running',
  /** Second half of the eyebrow. The lab's name is already in the nav one row
   *  above; repeating it there spent a phosphor label on nothing. */
  mode: 'Field live · scanning',
  headline: ['We build the worlds', 'where machines', 'learn to see.'],
  accentWord: 'see',
  lede: 'A machine perception research lab. We author synthetic worlds, raise vision systems inside them, and attack those systems until they break. Failure is cheaper in simulation than on a live camera.',
  /** Labels for the live readout drawn over the field. Values come from the renderer. */
  readout: ['Samples returned', 'Sweep radius', 'Sensor origin'],
  primaryCta: { label: 'Enter the Proving Grounds', href: '#proving-grounds' },
  secondaryCta: { label: 'Read the research', href: '#research' },
  telemetry: [
    { label: 'Worlds running', value: '10', unit: 'live' },
    { label: 'Frames rendered', value: '4.1M', unit: '/ day' },
    { label: 'Pixels to command', value: '18', unit: 'ms' },
    { label: 'Sim-to-real gap', value: '2.7', unit: '%' },
  ],
};

export const thesis = {
  index: '01',
  label: 'Thesis',
  headline: 'Perception is the bottleneck.',
  accentWord: 'bottleneck.',
  body: [
    'A machine that acts in the physical world spends almost none of its difficulty on deciding what to do. It spends its difficulty on knowing what is there: how far, how fast, how many, and whether that is the same object it saw four frames ago. Solve that and the rest is arithmetic.',
    'The problem does not yield to more parameters. It yields to experience, and reality issues experience at one second per second. A robot arm learns from an afternoon of failures. A camera on a bridge learns from one winter.',
    'So we manufacture the experience. Ten environments render continuously, producing the cases reality supplies about once a year: the occlusion at the worst moment, the sensor that drops out mid-turn, the object that resembles nothing in the training set. A model should meet its worst day early, and often.',
  ],
  pullQuote: 'A model is only as honest as the world that tested it.',
  attribution: 'Operating principle',
  /**
   * The three failure cases named in the third paragraph, each against the
   * environment that manufactures it. A cross-reference into the Proving
   * Grounds, so the argument in this section resolves to a mechanism further
   * down the page rather than ending on an assertion.
   */
  casesLabel: 'Cases, manufactured on demand',
  cases: [
    { case: 'Occlusion at the worst moment', env: 'Drift', code: '01' },
    { case: 'Sensor drops out mid-turn', env: 'Relay', code: '07' },
    { case: 'Object outside the training set', env: 'Parse', code: '10' },
  ],
};

export const capabilities = {
  index: '02',
  label: 'Capabilities',
  headline: 'Four research lines, one loop.',
  lede: 'Each line owns a segment of the path from photons to actuation. All four share a codebase, an evaluation harness, and the same ten worlds.',
  items: [
    {
      code: 'GP',
      title: 'Geometric perception',
      summary:
        'Metric structure — depth, pose, scale — recovered from ordinary cameras, with no depth sensor to lean on.',
      points: [
        'Monocular depth with calibrated uncertainty, not a pretty heatmap',
        'Six-degree-of-freedom pose under motion blur and rolling shutter',
        'Absolute scale from a single moving camera',
      ],
    },
    {
      code: 'TU',
      title: 'Temporal understanding',
      summary:
        'Identity held across time — through occlusion, through crowds, through the frames where the object simply is not there.',
      points: [
        'Tracking that survives eleven frames of total occlusion',
        'Trajectory forecasting to a three-second horizon',
        'Event detection on continuous, unsegmented video',
      ],
    },
    {
      code: 'EC',
      title: 'Embodied control',
      summary:
        'Pixels to actuation inside a latency budget that does not forgive a late answer, however correct it is.',
      points: [
        'Perception to command in 18 ms on commodity silicon',
        'Policies that degrade predictably when a sensor drops out',
        'Hard envelopes on what the controller is permitted to do',
      ],
    },
    {
      code: 'WG',
      title: 'World generation',
      summary:
        'The simulators themselves — and the harder question of which synthetic experience survives contact with reality.',
      points: [
        'Procedural worlds with ground truth for every pixel',
        'Adversarial scenario search: the failure, found on purpose',
        'Domain gap measured as a first-class metric',
      ],
    },
  ],
};

/**
 * The loop the Capabilities headline names. Each research line hands the next
 * one a specific thing, and the last hands back to the first — which is the
 * argument the section is making, drawn instead of asserted.
 */
export const capabilityLoop = {
  label: 'The loop',
  stations: [
    { code: 'GP', hands: 'metric structure' },
    { code: 'TU', hands: 'identity over time' },
    { code: 'EC', hands: 'a command, and its failures' },
    { code: 'WG', hands: 'a world that contains them' },
  ],
  returnLabel: 'Every failure becomes a world the next model is raised in',
};

export const provingGrounds = {
  index: '03',
  label: 'Proving Grounds',
  headline: 'Ten worlds. Running now.',
  lede: 'Each environment isolates one way perception fails. All ten render continuously, with ground truth for every pixel, and all are built to be hostile. A world nothing fails in teaches nothing.',
  note: 'World in grey. Model output in phosphor. What you see is what the model sees.',
};

/** Detail for each of the ten captured environments. Ids match public/media/env. */
export const environments = [
  {
    id: 'drift',
    code: '01',
    name: 'Drift',
    discipline: 'Multi-object tracking',
    blurb:
      'An aerial grid at rush hour, where a bridge hides every vehicle for eleven frames and every identity has to survive it.',
    metric: { label: 'ID switches / 10k frames', value: '0' },
  },
  {
    id: 'canopy',
    code: '02',
    name: 'Canopy',
    discipline: 'Monocular depth',
    blurb:
      'Flight through dense foliage, where every cue for scale is self-similar and half of them are moving.',
    metric: { label: 'δ < 1.25', value: '0.962' },
  },
  {
    id: 'hallway',
    code: '03',
    name: 'Hallway',
    discipline: 'Visual SLAM',
    blurb:
      'Deliberately repeating architecture, where the map is only correct if the loop closes on the right corridor.',
    metric: { label: 'Trajectory drift', value: '0.31%' },
  },
  {
    id: 'swarm',
    code: '04',
    name: 'Swarm',
    discipline: 'Trajectory forecasting',
    blurb:
      'Forty-six agents whose futures depend on one another, so predicting any single one means predicting all of them.',
    metric: { label: 'Average displacement error', value: '0.14 m' },
  },
  {
    id: 'lattice',
    code: '05',
    name: 'Lattice',
    discipline: 'Instance segmentation',
    blurb:
      'Identical parts stacked in contact, where the boundary between two objects is the only thing worth getting right.',
    metric: { label: 'mAP', value: '0.891' },
  },
  {
    id: 'tide',
    code: '06',
    name: 'Tide',
    discipline: 'Optical flow',
    blurb:
      'Non-rigid motion across low-texture surfaces — the case where feature matching has nothing to match.',
    metric: { label: 'End-point error', value: '0.62 px' },
  },
  {
    id: 'relay',
    code: '07',
    name: 'Relay',
    discipline: 'Predictive control',
    blurb:
      'A closed loop carrying 90 ms of injected latency, where the only way to be on time is to have been early.',
    metric: { label: 'Return rate', value: '99.1%' },
  },
  {
    id: 'quarry',
    code: '08',
    name: 'Quarry',
    discipline: 'Volumetric occupancy',
    blurb:
      'Sparse returns over terrain that shifts under the sensor, where free space has to be proven rather than assumed.',
    metric: { label: 'Voxel IoU', value: '0.847' },
  },
  {
    id: 'orbit',
    code: '09',
    name: 'Orbit',
    discipline: 'Collision avoidance',
    blurb:
      'Thirty tracks and a two-second decision window, scored by the one miss that matters rather than the average.',
    metric: { label: 'Minimum separation', value: '41 m' },
  },
  {
    id: 'parse',
    code: '10',
    name: 'Parse',
    discipline: 'Symbol recognition',
    blurb:
      'Glyphs the model has never seen, under noise authored by a second model whose only job is defeating the first.',
    metric: { label: 'Top-1 accuracy', value: '97.4%' },
  },
] as const;

export const research = {
  index: '04',
  label: 'Research',
  headline: 'Open problems we are stuck on.',
  lede: 'Published where publishing helps, and stated plainly where nothing works yet. A lab that reports only its wins is not reporting.',
  items: [
    {
      status: 'Active',
      title: 'Calibrated uncertainty in monocular depth',
      abstract:
        'A depth network that is confidently wrong is more dangerous than one that abstains, so we train the abstention directly. The open question is whether the confidence still means anything out of distribution. So far, beyond thirty meters, it does not.',
      tags: ['Geometric perception', 'Uncertainty'],
    },
    {
      status: 'Active',
      title: 'What actually transfers from simulation',
      abstract:
        'Photorealism is expensive and, we suspect, mostly beside the point. We ablate renderer fidelity against real-world performance to find which visual properties carry the transfer and which are decoration.',
      tags: ['World generation', 'Sim-to-real'],
    },
    {
      status: 'Preprint',
      title: 'Identity through total occlusion',
      abstract:
        'Re-identifying an object that has been entirely absent for a second or more, from motion priors rather than appearance. Appearance is the easy signal and the first one to go.',
      tags: ['Temporal understanding'],
    },
    {
      status: 'Early',
      title: 'Adversarial scenario search',
      abstract:
        'Instead of sampling environments uniformly, we search them for the configuration that breaks the current policy, then add it to the curriculum. The search is the contribution; the failures are the dataset.',
      tags: ['World generation', 'Evaluation'],
    },
    {
      status: 'Active',
      title: 'Perception under a fixed latency budget',
      abstract:
        'Accuracy is a curve against compute, and every deployed system reads a single point on it. We are working out where that point belongs when arriving late is indistinguishable from being wrong.',
      tags: ['Embodied control'],
    },
  ],
};

export const applications = {
  index: '05',
  label: 'Applications',
  headline: 'Where perception becomes consequence.',
  lede: 'A small number of partners, taken on for problems that are physical, measurable, and expensive to get wrong.',
  items: [
    {
      sector: 'Industrial inspection',
      claim: 'The defect with no examples',
      detail:
        'A good production line produces defects too rarely to learn from. We generate the negative class reality withholds, then check the model against the handful of real failures that exist.',
    },
    {
      sector: 'Robotics',
      claim: 'Manipulation in clutter',
      detail:
        'Grasping identical parts in contact is the Lattice problem with a gripper attached. Instance boundaries under contact are the difference between a pick and a jam.',
    },
    {
      sector: 'Earth observation',
      claim: 'Change seen through cloud',
      detail:
        'The signal is small, the revisit is irregular, and the ground truth arrives months late. We train temporal models on synthetic revisit schedules, including the passes that are lost.',
    },
    {
      sector: 'Medical imaging',
      claim: 'Uncertainty a clinician can act on',
      detail:
        'A model that says "I do not know" at the right moment beats a model with a better average. Calibration is the deliverable; accuracy is the by-product.',
    },
  ],
};

export const lab = {
  index: '06',
  label: 'The Lab',
  headline: 'Small, senior, and slow on purpose.',
  lede: 'Twenty-six people. No growth target. We hire when a problem needs a person, not when a quarter needs headcount.',
  principles: [
    {
      title: 'Publish the failure',
      body: 'Internal reviews open with what broke. A result nobody tried to break is not a result.',
    },
    {
      title: 'Measure the gap',
      body: 'Every synthetic number carries a real-world number beside it, or it does not ship.',
    },
    {
      title: 'Own the stack',
      body: 'Renderer, training harness, evaluation, deployment. A borrowed abstraction hides the failure inside someone else\'s code.',
    },
  ],
  stats: [
    { label: 'Researchers & engineers', value: '26' },
    { label: 'Founded', value: '2021' },
    { label: 'Papers published', value: '31' },
    { label: 'GPU-hours / week', value: '180k' },
  ],
  rolesLabel: 'Open roles',
  rolesNote:
    'We read every application. Send work — a paper, a repository, a demo that failed interestingly — rather than a cover letter.',
  roles: [
    {
      code: 'GP',
      title: 'Perception researcher',
      note: 'Depth and pose under motion. You have shipped something that ran on a real camera.',
    },
    {
      code: 'WG',
      title: 'Renderer engineer',
      note: 'You care what a shading model costs, and whether that cost buys any transfer.',
    },
    {
      code: 'EC',
      title: 'Controls engineer',
      note: 'Closing loops inside a latency budget, on hardware that will not wait for you.',
    },
    {
      code: 'EV',
      title: 'Evaluation lead',
      note: 'You would rather find the failure than the headline. This role reports the bad numbers.',
    },
  ],
};

export const contact = {
  index: '07',
  label: 'Contact',
  headline: 'If perception is the bottleneck, we should talk.',
  accentWord: 'talk.',
  lede: 'We take on a handful of engagements a year. Every application to work here is read by someone you would work with.',
  channels: [
    {
      kind: 'Partnerships',
      detail: 'Bring a problem that is physical, measurable, and currently unsolved.',
      action: 'partners@newaivisionlabs.com',
    },
    {
      kind: 'Research',
      detail: 'Collaborations, datasets, and reproductions of published work. Reproductions especially.',
      action: 'research@newaivisionlabs.com',
    },
    {
      kind: 'Careers',
      detail: 'Four open roles across perception, simulation, and systems. Send work, not a cover letter.',
      action: 'careers@newaivisionlabs.com',
    },
  ],
};

/**
 * Interface strings. These were previously hardcoded in JSX, which put the
 * page's closing line and its final CTA outside copy control.
 */
export const ui = {
  skipToContent: 'Skip to content',
  navContact: 'Contact',
  sheetCta: 'Contact the lab',
  scroll: 'Scroll',
  scrollLabel: 'Scroll to the thesis',
  running: 'Running',
  standby: 'Standby',
  motionOn: 'Motion on',
  motionOff: 'Motion off',
  closingLine: 'The field above is the one you arrived on, finished resolving.',
  closingCta: 'Send us the problem',
};

export const footer = {
  blurb: 'A machine perception research lab. Synthetic worlds, honest evaluation.',
  location: 'Lisbon · Zürich',
  columns: [
    {
      title: 'Lab',
      links: [
        { label: 'Thesis', href: '#thesis' },
        { label: 'Capabilities', href: '#capabilities' },
        { label: 'Research', href: '#research' },
        { label: 'Careers', href: '#contact' },
      ],
    },
    {
      title: 'Environments',
      links: [
        { label: 'Proving Grounds', href: '#proving-grounds' },
        { label: 'Applications', href: '#applications' },
        { label: 'How we evaluate', href: '#research' },
      ],
    },
  ],
};
