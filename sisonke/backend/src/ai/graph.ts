import { Annotation, END, START, StateGraph } from '@langchain/langgraph';
import { SisonkeGraphInput, SisonkeGraphState } from './types';
import { safetyNode } from './nodes/safetyNode';
import { emotionNode } from './nodes/emotionNode';
import { stageNode } from './nodes/stageNode';
import { ragNode } from './nodes/ragNode';
import { localModelNode } from './nodes/localModelNode';
import { geminiFallbackNode } from './nodes/geminiFallbackNode';
import { counselorEscalationNode } from './nodes/counselorEscalationNode';

const SisonkeState = Annotation.Root({
  userId: Annotation<string | undefined>(),
  deviceId: Annotation<string | undefined>(),
  sessionId: Annotation<string | undefined>(),
  message: Annotation<string>(),
  persona: Annotation<'male' | 'female'>(),
  riskLevel: Annotation<SisonkeGraphState['riskLevel']>(),
  turnsElapsed: Annotation<number | undefined>(),
  history: Annotation<SisonkeGraphState['history']>(),
  approvedContext: Annotation<string | undefined>(),
  currentSessionState: Annotation<SisonkeGraphState['currentSessionState']>(),
  preferredName: Annotation<string | undefined>(),
  detectedPrimaryEmotion: Annotation<string | undefined>(),
  detectedIntent: Annotation<string | undefined>(),
  detectedLanguage: Annotation<string | undefined>(),
  conversationState: Annotation<SisonkeGraphState['conversationState']>(),
  personaMode: Annotation<SisonkeGraphState['personaMode']>(),
  matchedLocalExpressions: Annotation<SisonkeGraphState['matchedLocalExpressions']>(),
  culturalContextNote: Annotation<string | undefined>(),
  interventionId: Annotation<string | undefined>(),
  interventionText: Annotation<string | undefined>(),
  response: Annotation<string | undefined>(),
  fallbackReason: Annotation<string | undefined>(),
  escalationRequired: Annotation<boolean | undefined>(),
  safetySource: Annotation<SisonkeGraphState['safetySource']>(),
  aiProvider: Annotation<SisonkeGraphState['aiProvider']>(),
  handoffSummary: Annotation<string | undefined>(),
});

function routeAfterSafety(state: SisonkeGraphState) {
  return state.riskLevel === 'high' ? 'escalate' : 'emotion';
}

function routeAfterStage(state: SisonkeGraphState) {
  return state.response ? 'done' : 'rag';
}

export const sisonkeGraph = new StateGraph(SisonkeState)
  .addNode('safety', safetyNode)
  .addNode('emotion', emotionNode)
  .addNode('stage', stageNode)
  .addNode('rag', ragNode)
  .addNode('localModel', localModelNode)
  .addNode('geminiFallback', geminiFallbackNode)
  .addNode('escalate', counselorEscalationNode)
  .addEdge(START, 'safety')
  .addConditionalEdges('safety', routeAfterSafety, {
    escalate: 'escalate',
    emotion: 'emotion',
  })
  .addEdge('emotion', 'stage')
  .addConditionalEdges('stage', routeAfterStage, {
    done: END,
    rag: 'rag',
  })
  .addEdge('rag', 'localModel')
  .addEdge('localModel', 'geminiFallback')
  .addEdge('geminiFallback', END)
  .addEdge('escalate', END)
  .compile();

export async function invokeSisonkeGraph(input: SisonkeGraphInput) {
  return await sisonkeGraph.invoke(input);
}
