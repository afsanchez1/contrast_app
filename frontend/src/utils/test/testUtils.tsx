import React, { type ReactElement, type PropsWithChildren } from 'react'
import { render } from '@testing-library/react'
import type { RenderOptions } from '@testing-library/react'
import { Provider } from 'react-redux'
import { ChakraProvider, ColorModeScript } from '@chakra-ui/react'
import { I18nextProvider } from 'react-i18next'
import i18n from '../../i18n'
import theme from '../../theme.ts'
import { setupStore, type AppStore, type RootState } from '../../app/store'
import { MemoryRouter } from 'react-router-dom'
import { PersistGate } from 'redux-persist/integration/react'
import { persistStore } from 'redux-persist'

interface ExtendedRenderOptions extends Omit<RenderOptions, 'queries'> {
    preloadedState?: Partial<RootState>
    store?: AppStore
}

// eslint-disable-next-line @typescript-eslint/explicit-function-return-type
export function renderWithProviders(
    ui: React.ReactElement,
    {
        preloadedState = {},
        // Automatically create a store instance if no store was passed in
        store = setupStore(),
        ...renderOptions
    }: ExtendedRenderOptions = {}
) {
    // eslint-disable-next-line @typescript-eslint/ban-types
    function Wrapper({ children }: PropsWithChildren<{}>): JSX.Element {
        return (
            <Provider store={store}>
                <PersistGate persistor={persistStore(store)}>
                    <ChakraProvider>
                        <ColorModeScript initialColorMode={theme.config.initialColorMode} />
                        <I18nextProvider i18n={i18n}>{children}</I18nextProvider>
                    </ChakraProvider>
                </PersistGate>
            </Provider>
        )
    }

    // Return an object with the store and all of RTL's query functions
    return { store, ...render(ui, { wrapper: Wrapper, ...renderOptions }) }
}

export function buildSingleRouterWrapper(children: ReactElement<any, any>): JSX.Element {
    return <MemoryRouter initialEntries={['/']}>{children}</MemoryRouter>
}
