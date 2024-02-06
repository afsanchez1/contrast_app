import { type PayloadAction, createSlice } from '@reduxjs/toolkit'
import { type ArticleSummary } from '../../types'
import { type RootState } from '../../app/store'

interface articleSliceState {
    selectedArticles: ArticleSummary[]
}

const initialState: articleSliceState = {
    selectedArticles: [] as ArticleSummary[],
}

export const articleSlice = createSlice({
    name: 'compare',
    initialState,
    reducers: {
        addToCompare(state, action: PayloadAction<ArticleSummary>) {
            state.selectedArticles = [...state.selectedArticles, action.payload]
        },
        removeFromCompare(state, action: PayloadAction<ArticleSummary>) {
            state.selectedArticles = state.selectedArticles.filter(
                artSumm => artSumm.url !== action.payload.url
            )
        },
        switchCompare(state) {
            state.selectedArticles = state.selectedArticles.reverse()
        },
    },
})

export const selectCompareArticles = (state: RootState): ArticleSummary[] =>
    state.compare.selectedArticles

export const { addToCompare, removeFromCompare, switchCompare } = articleSlice.actions
