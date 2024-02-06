import { createApi } from '@reduxjs/toolkit/query/react'
import { appFetchBaseQuery } from '../app/hooks'
import {
    type GetArticleQuery,
    type GetArticleResult,
    type SearchArticlesQuery,
    type SearchResult,
} from '../types'

export const scraperApi = createApi({
    reducerPath: 'scraperApi',
    baseQuery: appFetchBaseQuery,
    endpoints: builder => ({
        searchArticles: builder.query<SearchResult, SearchArticlesQuery>({
            query: args => {
                const { topic, page, limit } = args
                return `search_articles?topic=${topic}&page=${page}&limit=${limit}`
            },
        }),
        getArticle: builder.query<GetArticleResult, GetArticleQuery>({
            query: args => {
                const { url } = args
                return `get_article?url=${url}`
            },
        }),
    }),
})

export const useSearchArticlesQuery = scraperApi.endpoints.searchArticles.useQuery
export const useGetArticleQuery = scraperApi.endpoints.getArticle.useQuery
