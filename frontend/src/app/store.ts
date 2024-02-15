import { combineReducers, configureStore } from '@reduxjs/toolkit'
import { scraperApi } from '../services'
import { cartSlice } from '../components/articleCart'
import type { ToolkitStore } from '@reduxjs/toolkit/dist/configureStore'
import { articleSlice } from '../components'
import { persistReducer } from 'redux-persist'
import storage from 'redux-persist/lib/storage'

const cartPersistConfig = {
    key: 'cart',
    storage,
}

const rootReducer = combineReducers({
    [scraperApi.reducerPath]: scraperApi.reducer,
    cart: persistReducer(cartPersistConfig, cartSlice.reducer),
    compare: articleSlice.reducer,
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
