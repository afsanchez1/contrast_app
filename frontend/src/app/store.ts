import { configureStore } from '@reduxjs/toolkit'
import { scraperApi } from '../services'

export const store = configureStore({
    reducer: {
        [scraperApi.reducerPath]: scraperApi.reducer,
    },
    middleware: getDefaultMiddleware => {
        return getDefaultMiddleware().concat(scraperApi.middleware)
    },
})

export type AppDispatch = typeof store.dispatch
export type RootState = ReturnType<typeof store.getState>
