/**
 * @jest-environment jsdom
 */
import { cleanup, screen } from '@testing-library/react'
import { renderWithProviders } from '../../../src/utils'
import { NavBar } from '../../../src/components'
import '@testing-library/jest-dom'

afterEach(cleanup)

describe('NavBar component', () => {
    test('has logo', () => {
        renderWithProviders(<NavBar hasLogo={true} hasSideBarButton={false} />)

        expect(screen.getByText(/CON/)).toBeInTheDocument()
        expect(screen.getByText(/TRAST/)).toBeInTheDocument()
    })
})
