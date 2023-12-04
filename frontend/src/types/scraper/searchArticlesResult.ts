import type { ArticleSummary } from '.'

export interface SearchArticlesResult {
    scraper: string
    results: ArticleSummary[]
}
