import type ArticleSummary from '../types/scraper/articleSummary'
import type RequestError from '../types/services/requestError'
import type Article from '../types/scraper/article'
import handleResponse from '../utils/services/handleResponse'
import handleError from '../utils/services/handleError'
import axiosInst from './axiosInstance'
import logger from '../utils/logs/logger'

export async function searchArticles(
    topic: string,
    page: number,
    limit: number
): Promise<ArticleSummary[] | RequestError> {
    const req = `/search_articles?topic=${topic}&page=${page}&limit=${limit}`
    logger.info({ message: 'Fetching ' + req })

    return await axiosInst
        .get(req)
        .then(response => handleResponse(response)) // TODO Manage ArticleSummary creation
        .catch(error => handleError(error))
}

export async function getArticle(url: string): Promise<Article | RequestError> {
    const req = `/get_article?url=${url}`
    logger.info({ message: 'Fetching ' + req })

    return await axiosInst
        .get(req)
        .then(response => handleResponse(response)) // TODO Manage Article creation
        .catch(error => handleError(error))
}
