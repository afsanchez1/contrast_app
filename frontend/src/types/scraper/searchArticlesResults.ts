import type { ArticleSummary } from '.'

/**
 * Represents a SearchArticles query error result
 * @type SearchError
 * @example { error: 'parsing error' }
 */
export type SearchError = Record<string, string>

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
 */
export interface SearchArticlesErrorResult {
    /**
     * Name of the scraper
     * @type {string}
     */
    scraper: string
    /**
     * Search results
     * @type {SearchError}
     */
    results: SearchError
}

/**
 * Represents a SearchArticles query generic result
 * @type {SearchResult}
 */
export type SearchResult = Array<SearchArticlesSuccessResult | SearchArticlesErrorResult>
