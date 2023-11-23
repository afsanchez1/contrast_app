/**
 * Represents the api's query arguments for searching articles
 * @interface ArticleSummaryQuery
 */
export interface ArticleSummaryQuery {
    /**
     * The topic of the articles
     * @type {string}
     */
    topic: string
    /**
     * @type {number}
     */
    page: number
    /**
     * @type {number}
     */
    limit: number
}
