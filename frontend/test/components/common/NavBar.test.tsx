/**
 * @jest-environment jsdom
 */
import 'whatwg-fetch'
import '@testing-library/jest-dom'
import { cleanup, screen } from '@testing-library/react'
import { NavBar } from '../../../src/components'
import { renderWithProviders, buildSingleRouterWrapper } from '../../../src/utils'

afterEach(cleanup)

describe('NavBar component', () => {
    test('Has logo and no sidebar Button', () => {
        renderWithProviders(
            buildSingleRouterWrapper(<NavBar hasLogo={true} hasSideBarButton={false} />)
        )
        expect(screen.getByText(/CON/)).toBeInTheDocument()
        expect(screen.getByText(/TRAST/)).toBeInTheDocument()
        expect(screen.queryByTestId('side-bar-button')).toBeNull()
    })

    test('Has sidebar button and no logo', () => {
        renderWithProviders(
            buildSingleRouterWrapper(<NavBar hasLogo={false} hasSideBarButton={true} />)
        )

        expect(screen.queryByText(/CON/)).toBeNull()
        expect(screen.queryByText(/TRAST/)).toBeNull()
        expect(screen.getByTestId('side-bar-button')).toBeInTheDocument()
    })

    test('Has neither sidebar button or logo', () => {
        renderWithProviders(
            buildSingleRouterWrapper(<NavBar hasLogo={false} hasSideBarButton={false} />)
        )
        expect(screen.queryByText(/CON/)).toBeNull()
        expect(screen.queryByText(/TRAST/)).toBeNull()
        expect(screen.queryByTestId('side-bar-button')).toBeNull()
    })

    test('Has toggle theme button', () => {
        renderWithProviders(
            buildSingleRouterWrapper(<NavBar hasLogo={false} hasSideBarButton={false} />)
        )

        expect(screen.getByTestId('theme-mode-button')).toBeInTheDocument()
    })
})
