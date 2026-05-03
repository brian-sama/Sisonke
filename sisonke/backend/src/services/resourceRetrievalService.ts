import { and, eq, isNull } from 'drizzle-orm';
import { db } from '../db';
import { resources, cmsContent } from '../db/schema';

type RetrievedContent = {
  title: string;
  category: string;
  body: string;
  source: 'resource' | 'cms';
};

const stopWords = new Set([
  'about',
  'after',
  'again',
  'what',
  'when',
  'where',
  'which',
  'with',
  'from',
  'that',
  'this',
  'have',
  'need',
  'help',
  'feel',
  'like',
  'your',
  'you',
  'and',
  'the',
  'for',
  'are',
]);

function tokensFor(text: string) {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, ' ')
    .split(/\s+/)
    .filter((token) => token.length > 2 && !stopWords.has(token));
}

function scoreContent(queryTokens: string[], item: RetrievedContent) {
  const haystack = `${item.title} ${item.category} ${item.body}`.toLowerCase();
  return queryTokens.reduce((score, token) => score + (haystack.includes(token) ? 1 : 0), 0);
}

export async function retrieveApprovedContext(query: string, limit = 4) {
  const queryTokens = tokensFor(query);
  if (!queryTokens.length) return '';

  const [resourceRows, cmsRows] = await Promise.all([
    db
      .select()
      .from(resources)
      .where(and(eq(resources.status, 'published'), eq(resources.isPublished, true), isNull(resources.deletedAt)))
      .limit(100),
    db
      .select()
      .from(cmsContent)
      .where(eq(cmsContent.status, 'published'))
      .limit(100),
  ]);

  const candidates: RetrievedContent[] = [
    ...resourceRows.map((item) => ({
      title: item.title,
      category: item.category,
      body: item.content || item.description,
      source: 'resource' as const,
    })),
    ...cmsRows.map((item) => ({
      title: item.title,
      category: item.category,
      body: item.body,
      source: 'cms' as const,
    })),
  ];

  return candidates
    .map((item) => ({ item, score: scoreContent(queryTokens, item) }))
    .filter((entry) => entry.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .map(({ item }) => {
      const body = item.body.length > 700 ? `${item.body.slice(0, 700)}...` : item.body;
      return `[${item.source}] ${item.title} (${item.category})\n${body}`;
    })
    .join('\n\n');
}
