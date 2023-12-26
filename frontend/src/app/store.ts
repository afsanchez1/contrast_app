import { combineReducers, configureStore } from '@reduxjs/toolkit'
import { scraperApi } from '../services'
import type { ToolkitStore } from '@reduxjs/toolkit/dist/configureStore'

const rootReducer = combineReducers({
    [scraperApi.reducerPath]: scraperApi.reducer,
})

export function setupStore(preloadedState?: Partial<RootState>): ToolkitStore {
    return configureStore({
        reducer: rootReducer,
        preloadedState,
        middleware: getDefaultMiddleware => {
            return getDefaultMiddleware().concat(scraperApi.middleware)
        },
    })
}

export type RootState = ReturnType<typeof rootReducer>
export type AppStore = ReturnType<typeof setupStore>
export type AppDispatch = AppStore['dispatch']
