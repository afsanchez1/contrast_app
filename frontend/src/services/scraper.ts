import { createApi } from '@reduxjs/toolkit/query/react'
import { appFetchBaseQuery } from '../app/hooks'
import type { SearchArticlesResult, SearchArticlesQuery } from '../types'

export const scraperApi = createApi({
    reducerPath: 'scraperApi',
    baseQuery: appFetchBaseQuery,
    endpoints: builder => ({
        searchArticles: builder.query<SearchArticlesResult[], SearchArticlesQuery>({
            query: args => {
                const { topic, page, limit } = args
                return `search_articles?topic=${topic}&page=${page}&limit=${limit}`
            },
        }),
    }),
})

export const useSearchArticlesQuery = scraperApi.endpoints.searchArticles.useQuery
