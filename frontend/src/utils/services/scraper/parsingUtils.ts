import type { Article, ArticleSummary } from '../../../types'

/**
 * A function for parsing well-formatted dates to locale date format
 * @param {string} dateTime
 * @returns {string}
 */
export function parseDateTime(dateTime: string): string {
    return new Date(dateTime).toLocaleString()
}

/**
 * Parses articleSummaries' date
 * @param {ArticleSummary[]} artSumms
 * @returns {ArticleSummary[]}
 */
export function parseArticleSummaries(artSumms: ArticleSummary[]): ArticleSummary[] {
    return artSumms.map<ArticleSummary>(artSumm => ({
        ...artSumm,
        date_time: parseDateTime(artSumm.date_time),
    }))
}

/**
 * Parses articles' date
 * @param {Article} art
 * @returns {Article}
 */
export function parseArticle(art: Article): Article {
    return {
        ...art,
        last_date_time: parseDateTime(art.last_date_time),
    }
}
