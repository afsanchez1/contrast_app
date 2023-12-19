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
    test('has logo', () => {
        renderWithProviders(
            buildSingleRouterWrapper(<NavBar hasLogo={true} hasSideBarButton={false} />)
        )
        expect(screen.getByText(/CON/)).toBeInTheDocument()
        expect(screen.getByText(/TRAST/)).toBeInTheDocument()
    })
})
