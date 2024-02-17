import { createApi } from '@reduxjs/toolkit/query/react'
import { compareFetchBaseQuery } from '../app/hooks'
import type { compareResult } from '../types/compareArticles/compareResults'
import type { compareQuery } from '../types/compareArticles/compareQuery'
const token = process.env.COMPARE_API_TOKEN

export const compareApi = createApi({
    reducerPath: 'compareApi',
    baseQuery: compareFetchBaseQuery,
    endpoints: builder => ({
        getSimilarityRatio: builder.query<compareResult, compareQuery>({
            query: ({ text1, text2 }) => {
                const body = {
                    text1,
                    text2,
                    token,
                    bow: 'never',
                    lang: 'es',
                }

                return {
                    url: '',
                    method: 'POST',
                    body,
                }
            },
        }),
    }),
})
