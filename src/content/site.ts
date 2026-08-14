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
  eyebrow: 'New AI Vision Labs',
  status: 'Ten environments running',
  headline: ['We build the worlds', 'where machines', 'learn to see.'],
  accentWord: 'see',
  lede: 'A machine perception lab. We author synthetic worlds, train vision systems inside them, and break those systems on purpose — so perception is proven long before it meets a real camera.',
  primaryCta: { label: 'Enter the Proving Grounds', href: '#proving-grounds' },
  secondaryCta: { label: 'Read the research', href: '#research' },
  telemetry: [
    { label: 'Environments', value: '10', unit: 'live' },
    { label: 'Frames rendered', value: '4.1M', unit: '/ day' },
    { label: 'Perception loop', value: '18', unit: 'ms' },
    { label: 'Sim-to-real gap', value: '2.7', unit: '%' },
  ],
};

export const thesis = {
  index: '01',
  label: 'Thesis',
  headline: 'Perception is the bottleneck. Everything downstream is arithmetic.',
  accentWord: 'bottleneck.',
  body: [
    'A system that acts in the physical world spends almost none of its difficulty on deciding what to do. It spends its difficulty on knowing what is in front of it — how far, how fast, how many, and which of them is the same object it saw four frames ago.',
    'That problem does not yield to more parameters. It yields to more experience, and the physical world hands out experience at one second per second. A robot arm learns from one afternoon of failures. A camera on a bridge sees one winter.',
    'So we build the experience instead. Ten synthetic environments run continuously, generating the hard cases the real world produces once a year: the occlusion at the wrong moment, the sensor dropout, the object that looks like nothing in the training set.',
  ],
  pullQuote: 'A model is only as honest as the world that tested it.',
  attribution: 'Operating principle · New AI Vision Labs',
};

export const capabilities = {
  index: '02',
  label: 'Capabilities',
  headline: 'Four research lines, one loop.',
  lede: 'Each line owns a piece of the path from photons to action. They share a codebase, an evaluation harness, and the same ten worlds.',
  items: [
    {
      code: 'GP',
      title: 'Geometric perception',
      summary:
        'Recovering metric structure — depth, pose, and scale — from ordinary cameras, without a depth sensor to lean on.',
      points: [
        'Monocular depth with calibrated uncertainty, not just a heatmap',
        'Six-degree-of-freedom pose under motion blur and rolling shutter',
        'Scale recovery from a single moving camera',
      ],
    },
    {
      code: 'TU',
      title: 'Temporal understanding',
      summary:
        'Holding object identity across time — through occlusion, through crowds, through the frames where the object simply is not there.',
      points: [
        'Multi-object tracking that survives full occlusion',
        'Trajectory forecasting with a three-second horizon',
        'Event detection on continuous, unsegmented video',
      ],
    },
    {
      code: 'EC',
      title: 'Embodied control',
      summary:
        'Closing the loop from pixels to actuation, inside a latency budget that does not forgive a late answer.',
      points: [
        'Perception-to-command in 18 ms on commodity silicon',
        'Policies that degrade predictably when a sensor drops out',
        'Formal envelopes on what the controller is permitted to do',
      ],
    },
    {
      code: 'WG',
      title: 'World generation',
      summary:
        'The simulators themselves — and the harder question of which synthetic experience actually transfers to reality.',
      points: [
        'Procedural environments with ground truth for every pixel',
        'Adversarial scenario search: the failure, found deliberately',
        'Domain-gap measurement as a first-class metric',
      ],
    },
  ],
};

export const provingGrounds = {
  index: '03',
  label: 'Proving Grounds',
  headline: 'Ten worlds. Running now.',
  lede: 'Every environment isolates one way perception fails. They render continuously, with ground truth for every pixel, and they are designed to be hostile — an environment nothing fails in teaches nothing.',
  note: 'World layer in grey. Perception layer in phosphor. What you see is what the model sees.',
};

/** Detail for each of the ten captured environments. Ids match public/media/env. */
export const environments = [
  {
    id: 'drift',
    code: '01',
    name: 'Drift',
    discipline: 'Multi-object tracking',
    blurb:
      'An aerial grid at rush hour. Identities must survive a bridge that hides every vehicle for eleven frames.',
    metric: { label: 'ID switches / 10k frames', value: '0' },
  },
  {
    id: 'canopy',
    code: '02',
    name: 'Canopy',
    discipline: 'Monocular depth',
    blurb:
      'Flight through dense foliage, where every visual cue for scale is self-similar and half of them are moving.',
    metric: { label: 'δ < 1.25', value: '0.962' },
  },
  {
    id: 'hallway',
    code: '03',
    name: 'Hallway',
    discipline: 'Visual SLAM',
    blurb:
      'Deliberately repeating architecture. The map is only correct if the loop closes on the right corridor.',
    metric: { label: 'Trajectory drift', value: '0.31%' },
  },
  {
    id: 'swarm',
    code: '04',
    name: 'Swarm',
    discipline: 'Trajectory forecasting',
    blurb:
      'Forty-six agents whose futures depend on each other. Predicting one requires predicting all of them.',
    metric: { label: 'Average displacement error', value: '0.14 m' },
  },
  {
    id: 'lattice',
    code: '05',
    name: 'Lattice',
    discipline: 'Instance segmentation',
    blurb:
      'Identical parts stacked in contact. The boundary between two objects is the only thing worth getting right.',
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
      'A closed loop with 90 ms of injected latency. The only way to be on time is to have been early.',
    metric: { label: 'Return rate', value: '99.1%' },
  },
  {
    id: 'quarry',
    code: '08',
    name: 'Quarry',
    discipline: 'Volumetric occupancy',
    blurb:
      'Sparse returns over terrain that changes under the sensor. Free space must be proven, not assumed.',
    metric: { label: 'Voxel IoU', value: '0.847' },
  },
  {
    id: 'orbit',
    code: '09',
    name: 'Orbit',
    discipline: 'Collision avoidance',
    blurb:
      'Thirty tracks, a two-second decision window, and a cost function where one miss is the only one that counts.',
    metric: { label: 'Minimum separation', value: '41 m' },
  },
  {
    id: 'parse',
    code: '10',
    name: 'Parse',
    discipline: 'Symbol recognition',
    blurb:
      'Glyph sets the model has never seen, under noise designed by a second model to defeat the first.',
    metric: { label: 'Top-1 accuracy', value: '97.4%' },
  },
] as const;

export const research = {
  index: '04',
  label: 'Research',
  headline: 'Open problems we are actually stuck on.',
  lede: 'Published where it is useful, and stated plainly where it is not yet working. A lab that only reports its wins is not reporting.',
  items: [
    {
      status: 'Active',
      title: 'Calibrated uncertainty in monocular depth',
      abstract:
        'A depth network that is confidently wrong is more dangerous than one that abstains. We are training the abstention directly, and measuring whether the confidence means anything out of distribution.',
      tags: ['Geometric perception', 'Uncertainty'],
    },
    {
      status: 'Active',
      title: 'What actually transfers from simulation',
      abstract:
        'Photorealism is expensive and, we suspect, largely irrelevant. We are ablating renderer fidelity against real-world performance to find which visual properties carry the transfer and which are decoration.',
      tags: ['World generation', 'Sim-to-real'],
    },
    {
      status: 'Preprint',
      title: 'Identity through total occlusion',
      abstract:
        'Re-identification after an object has been entirely absent for a second or more, using motion priors rather than appearance. Appearance is the easy signal and the first one to disappear.',
      tags: ['Temporal understanding'],
    },
    {
      status: 'Early',
      title: 'Adversarial scenario search',
      abstract:
        'Rather than sampling environments uniformly, we search them for the configuration that breaks the current policy — then add it to the curriculum. The search is the contribution.',
      tags: ['World generation', 'Evaluation'],
    },
    {
      status: 'Active',
      title: 'Perception under a fixed latency budget',
      abstract:
        'Accuracy is a curve against compute, and every deployed system reads a single point on it. We study where that point should sit when being late is equivalent to being wrong.',
      tags: ['Embodied control'],
    },
  ],
};

export const applications = {
  index: '05',
  label: 'Applications',
  headline: 'Where perception becomes consequence.',
  lede: 'We work with a small number of partners whose problems are physical, measurable, and expensive to get wrong.',
  items: [
    {
      sector: 'Industrial inspection',
      claim: 'Finding the defect that has no training examples',
      detail:
        'Production lines produce defects at rates too low to learn from. Synthetic defect generation supplies the negative class that reality withholds.',
    },
    {
      sector: 'Robotics',
      claim: 'Manipulation in clutter, without a fixture',
      detail:
        'Grasping identical parts in contact is the Lattice problem exactly. Instance boundaries under contact are the difference between a pick and a jam.',
    },
    {
      sector: 'Earth observation',
      claim: 'Change detection through weather and revisit gaps',
      detail:
        'The signal is small, the sensor is inconsistent, and the ground truth arrives months late. Temporal models trained on synthetic revisit schedules close the gap.',
    },
    {
      sector: 'Medical imaging',
      claim: 'Uncertainty a clinician can act on',
      detail:
        'A model that says "I do not know" at the right moment is worth more than a model with a better average. Calibration is the deliverable, not accuracy.',
    },
  ],
};

export const lab = {
  index: '06',
  label: 'The Lab',
  headline: 'Small, senior, and unusually patient.',
  lede: 'Twenty-six people. No growth target. We hire when a problem needs a person, not when a quarter needs headcount.',
  principles: [
    {
      title: 'Publish the failure',
      body: 'Internal reviews lead with what broke. A result nobody tried to break is not a result.',
    },
    {
      title: 'Measure the gap',
      body: 'Every synthetic claim carries a real-world number beside it, or it does not ship.',
    },
    {
      title: 'Own the stack',
      body: 'Renderer, training harness, evaluation, deployment. Borrowed abstractions hide the failure.',
    },
  ],
  stats: [
    { label: 'Researchers & engineers', value: '26' },
    { label: 'Founded', value: '2021' },
    { label: 'Papers published', value: '31' },
    { label: 'GPU-hours / week', value: '180k' },
  ],
};

export const contact = {
  index: '07',
  label: 'Contact',
  headline: 'If perception is your bottleneck, we should talk.',
  accentWord: 'talk.',
  lede: 'We take on a small number of engagements a year, and we read every application from people who want to work here.',
  channels: [
    {
      kind: 'Partnerships',
      detail: 'Bring a problem that is physical, measurable, and currently unsolved.',
      action: 'partners@newaivisionlabs.com',
    },
    {
      kind: 'Research',
      detail: 'Collaborations, datasets, and reproductions of published work.',
      action: 'research@newaivisionlabs.com',
    },
    {
      kind: 'Careers',
      detail: 'Four open roles across perception, simulation, and systems.',
      action: 'careers@newaivisionlabs.com',
    },
  ],
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
        { label: 'Evaluation harness', href: '#research' },
      ],
    },
  ],
};
