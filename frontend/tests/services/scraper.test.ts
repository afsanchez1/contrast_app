import { afterEach, beforeAll, describe, expect, test } from '@jest/globals'
import MockAdapter from 'axios-mock-adapter'
import { getArticle, searchArticles } from '../../src/services/scraper'
import axiosInst from '../../src/services/axiosInstance'
import ArticleSummary from '../../src/types/scraper/articleSummary'
import articleSummsMock from './mocks/articleSummsMock'
import articleMock from './mocks/articleMock'

let mock: MockAdapter
const topic = 'testTopic'
const page = 1
const limit = 3

const searchParams = {
    topic,
    page,
    limit,
}

const url = 'testUrl'

const getArticleParams = {
    url,
}

beforeAll(() => {
    mock = new MockAdapter(axiosInst)
})

afterEach(() => {
    mock.resetHandlers()
})

describe('Search articles', () => {
    test('works as expected', async () => {
        mock.onGet('/search_articles', {
            params: searchParams,
        }).reply(200, articleSummsMock)

        const expected_resp = articleSummsMock.map<ArticleSummary>(articleSummMock => ({
            ...articleSummMock,
            date_time: new Date(articleSummMock.date_time).toLocaleString(),
        }))

        const resp = await searchArticles(topic, page, limit)

        expect(resp).toEqual(expected_resp)
    })

    test('handles errors as expected (setup error)', async () => {
        mock.onGet('/search_articles').networkError()

        const expected_resp = {
            message: 'Error setting up the request',
        }
        const resp = await searchArticles(topic, page, limit)

        expect(resp).toEqual(expected_resp)
    })

    test('handles errors as expected (not found)', async () => {
        mock.onGet('search_articles', {
            params: searchParams,
        }).reply(404, 'Not found')

        const expected_resp = {
            message: 'Request failed with status: 404',
            status: 404,
            data: 'Not found',
        }

        const resp = await searchArticles(topic, page, limit)

        expect(resp).toEqual(expected_resp)
    })
})

describe('Get article', () => {
    test('works as expected', async () => {
        mock.onGet('/get_article', {
            params: getArticleParams,
        }).reply(200, articleMock)

        const expected_resp = {
            ...articleMock,
            last_date_time: new Date(articleMock.last_date_time).toLocaleString(),
        }

        const resp = await getArticle(url)

        expect(resp).toEqual(expected_resp)
    })

    test('handles errors as expected (timeout error)', async () => {
        mock.onGet('/get_article').timeout()

        const expected_resp = {
            message: 'Request timed out',
        }
        const resp = await getArticle(url)

        expect(resp).toEqual(expected_resp)
    })

    test('handles errors as expected (abort error)', async () => {
        mock.onGet('/get_article').abortRequest()

        const expected_resp = {
            message: 'Request aborted',
        }
        const resp = await getArticle(url)

        expect(resp).toEqual(expected_resp)
    })
})
