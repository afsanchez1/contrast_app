import type { RequestError, Article, ArticleSummary } from '../types'
import axiosInst from './axiosInstance'
import { handleError, handleResponse, parseArticleSummaries, parseArticle, logger } from '../utils'

/**
 * Makes a request to /search_articles backend route
 * @param {string} topic - The topic of the articles
 * @param {number} page - Page for pagination
 * @param {number}limit - The number of results
 * @returns {Promise<ArticleSummary[] | RequestError>} - Response data
 */
export async function searchArticles(
    topic: string,
    page: number,
    limit: number
): Promise<ArticleSummary[] | RequestError> {
    const endPoint = '/search_articles'
    const req = `${endPoint}?topic=${topic}&page=${page}&limit=${limit}`
    logger.info({ message: 'Fetching ' + req })

    return await axiosInst
        .get(endPoint, { params: { topic, page, limit } })
        .then(response => {
            const artSumms = handleResponse(response) as ArticleSummary[]
            return parseArticleSummaries(artSumms)
        })
        .catch(error => handleError(error))
}

/**
 * Makes a request to /get_article backend route
 * @param {string} url - URL of the article to scrape
 * @returns {Promise<Article | RequestError>} - Response data
 */
export async function getArticle(url: string): Promise<Article | RequestError> {
    const endPoint = '/get_article'
    const req = `${endPoint}?url=${url}`
    logger.info({ message: 'Fetching ' + req })

    return await axiosInst
        .get(endPoint, { params: { url } })
        .then(response => {
            const art = handleResponse(response)
            return parseArticle(art)
        })
        .catch(error => handleError(error))
}
