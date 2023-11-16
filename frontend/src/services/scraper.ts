import type ArticleSummary from '../types/scraper/articleSummary'
import type RequestError from '../types/services/requestError'
import type Article from '../types/scraper/article'
import handleResponse from '../utils/services/handleResponse'
import handleError from '../utils/services/handleError'
import axiosInst from './axiosInstance'
import logger from '../utils/logs/logger'
import { parseArticleSummaries, parseArticle } from '../utils/services/scraper/parsingUtils'

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
