import { type PayloadAction, createSlice } from '@reduxjs/toolkit'
import { type ArticleSummary } from '../../types'
import { type RootState } from '../../app/store'

interface cartSliceState {
    cartItems: ArticleSummary[]
    cartTotalItems: number
}
const initialState: cartSliceState = {
    cartItems: [] as ArticleSummary[],
    cartTotalItems: 0,
}

export const cartSlice = createSlice({
    name: 'cart',
    initialState,
    reducers: {
        addToCart(state, action: PayloadAction<ArticleSummary>) {
            state.cartItems = [...state.cartItems, action.payload]
            state.cartTotalItems += 1
        },
        removeFromCart(state, action: PayloadAction<ArticleSummary>) {
            state.cartItems = state.cartItems.filter(artSumm => artSumm.url !== action.payload.url)
            state.cartTotalItems -= 1
        },
    },
})

export const selectCartItems = (state: RootState): ArticleSummary[] => state.cart.cartItems
export const selectCartTotalItems = (state: RootState): number => state.cart.cartTotalItems
export const { addToCart, removeFromCart } = cartSlice.actions
