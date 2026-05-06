export type Intervention = {
  id: string;
  triggerTags: string[];
  exerciseName: string;
  instructionBlocks: string[];
  presentationStyle: 'step_by_step' | 'single_step';
};

export const interventions: Intervention[] = [
  {
    id: 'grounding-54321',
    triggerTags: ['anxiety', 'panic', 'overwhelm', 'kufungisisa'],
    exerciseName: '5-4-3-2-1 Grounding',
    instructionBlocks: [
      'Look around and name 5 things you can see.',
      'Now notice 4 things you can physically feel.',
      'Take a slow breath and name 3 things you can hear.',
      'Notice 2 things you can smell.',
      'Finally, notice 1 thing you can taste.',
    ],
    presentationStyle: 'step_by_step',
  },
  {
    id: 'box-breathing',
    triggerTags: ['stress', 'heart racing', 'exhaustion', 'panic'],
    exerciseName: 'Box Breathing',
    instructionBlocks: [
      'Breathe in slowly for 4 seconds.',
      'Hold for 4 seconds.',
      'Breathe out slowly for 4 seconds.',
      'Hold empty for 4 seconds.',
    ],
    presentationStyle: 'step_by_step',
  },
  {
    id: 'friendship-bench-one-problem',
    triggerTags: ['overwhelmed', 'stuck', 'stress', 'problem'],
    exerciseName: 'One Manageable Problem',
    instructionBlocks: [
      'Let us choose just one small part of this problem for now.',
      'What is the one thing that feels most urgent or most possible to face today?',
    ],
    presentationStyle: 'single_step',
  },
];

export function selectIntervention(message: string, emotion?: string) {
  const haystack = `${message} ${emotion || ''}`.toLowerCase();
  return interventions.find((item) =>
    item.triggerTags.some((tag) => haystack.includes(tag.toLowerCase())),
  );
}
