import type { ArticleSummary } from '.'

export interface SearchArticlesSuccessResult {
    scraper: string
    results: ArticleSummary[]
}

export interface SearchArticlesErrorResult {
    error: Record<string, string>
}

export type SearchResult = Array<SearchArticlesSuccessResult | SearchArticlesErrorResult>
