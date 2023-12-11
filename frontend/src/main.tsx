import React from 'react'
import ReactDOM from 'react-dom/client'
import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import { Provider } from 'react-redux'
import { ChakraProvider, ColorModeScript } from '@chakra-ui/react'
import { store } from './app/store'
import { I18nextProvider } from 'react-i18next'
import i18n from './i18n'
import theme from './theme.ts'
import { ErrorPage } from './pages'
import { SearchArticles, SearchResults } from './components'
import { Root } from './layouts/root.tsx'

const router = createBrowserRouter([
    {
        path: '/',
        element: <Root />,
        errorElement: <ErrorPage />,
        children: [
            {
                path: '/',
                element: <SearchArticles />,
            },
            {
                path: '/search_results/:topic',
                element: <SearchResults />,
            },
        ],
    },
])

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <Provider store={store}>
            <ChakraProvider>
                <ColorModeScript initialColorMode={theme.config.initialColorMode} />
                <I18nextProvider i18n={i18n}>
                    <RouterProvider router={router}></RouterProvider>
                </I18nextProvider>
            </ChakraProvider>
        </Provider>
    </React.StrictMode>
)
