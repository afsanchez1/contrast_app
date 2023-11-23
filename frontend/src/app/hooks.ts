import { useDispatch, useSelector } from 'react-redux'
import { fetchBaseQuery } from '@reduxjs/toolkit/query/react'
import type { TypedUseSelectorHook } from 'react-redux'
import type { RootState, AppDispatch } from './store'
const baseUrl = process.env.SCRAPER_URL

export const useAppDispatch: () => AppDispatch = useDispatch
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector
export const appFetchBaseQuery = fetchBaseQuery({
    baseUrl,
})
