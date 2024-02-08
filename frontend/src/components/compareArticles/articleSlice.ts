import { type PayloadAction, createSlice } from '@reduxjs/toolkit'
import { type ArticleSummary } from '../../types'
import { type RootState } from '../../app/store'

export interface compareSelection {
    articleSummary: ArticleSummary
    index: number
}

interface articleSliceState {
    compareSelections: compareSelection[]
    currSelectorIndex: number
}

const initialState: articleSliceState = {
    compareSelections: [],
    currSelectorIndex: 0,
}

export const articleSlice = createSlice({
    name: 'compare',
    initialState,
    reducers: {
        addToCompare(state, action: PayloadAction<ArticleSummary>) {
            const index = state.currSelectorIndex
            const selection = {
                articleSummary: action.payload,
                index,
            }
            state.compareSelections = [...state.compareSelections, selection]
        },
        removeFromCompare(state, action: PayloadAction<number>) {
            state.compareSelections = state.compareSelections.filter(
                compareSelection => compareSelection.index !== action.payload
            )
        },
        setCurrSelector(state, action: PayloadAction<number>) {
            state.currSelectorIndex = action.payload
        },
        switchCompare(state) {
            state.compareSelections = state.compareSelections.reverse()
        },
        clearCompare(state) {
            state.compareSelections = []
            state.currSelectorIndex = 0
        },
    },
})

export const selectCompareArticles = (state: RootState): compareSelection[] => {
    return state.compare.compareSelections
}

export const { addToCompare, removeFromCompare, setCurrSelector, switchCompare, clearCompare } =
    articleSlice.actions
