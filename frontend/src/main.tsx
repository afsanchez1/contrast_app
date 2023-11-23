import React from 'react'
import ReactDOM from 'react-dom/client'
import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import { Provider } from 'react-redux'
import { ChakraProvider, ColorModeScript } from '@chakra-ui/react'
import { store } from './app/store'
// import App from './App.tsx'
import theme from './theme.ts'
import { HomePage, ErrorPage } from './pages'
import { SearchResults } from './components'

const router = createBrowserRouter([
    {
        path: '/',
        element: <HomePage />,
        errorElement: <ErrorPage />,
    },
    {
        path: '/search_results/:topic',
        element: <SearchResults />,
    },
])

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <Provider store={store}>
            <ChakraProvider>
                <ColorModeScript initialColorMode={theme.config.initialColorMode} />
                <RouterProvider router={router}></RouterProvider>
            </ChakraProvider>
        </Provider>
    </React.StrictMode>
)
