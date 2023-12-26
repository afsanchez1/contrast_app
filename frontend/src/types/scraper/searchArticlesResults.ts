import type { ArticleSummary } from '.'

/**
 * Represents a SearchArticles query successful result
 * @interface SearchArticlesSuccessResult
 */
export interface SearchArticlesSuccessResult {
    /**
     * Name of the scraper
     * @type {string}
     */
    scraper: string
    /**
     * Search results
     * @type {ArticleSummary[]}
     */
    results: ArticleSummary[]
}

/**
 * Represents a SearchArticles query error result
 * @interface SearchArticlesErrorResult
 * @example { error: { 'el-pais': 'Parsing error' } }
 */
export interface SearchArticlesErrorResult {
    /**
     * Error result
     * @type {Record<string, string>}
     */
    error: Record<string, string>
}

/**
 * Represents a SearchArticles query generic result
 * @type {SearchResult}
 */
export type SearchResult = Array<SearchArticlesSuccessResult | SearchArticlesErrorResult>
