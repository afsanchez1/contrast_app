/**
 * @jest-environment jsdom
 */
import { screen } from '@testing-library/react'
import { renderWithProviders } from '../../../src/utils'
import { Logo } from '../../../src/components'
import '@testing-library/jest-dom'

describe('Footer component', () => {
    test('Shows the expected information', () => {
        renderWithProviders(<Logo fontSize={{ base: '2rem' }} />)

        expect(screen.getByText(/CON/)).toBeInTheDocument()
        expect(screen.getByText(/TRAST/)).toBeInTheDocument()
    })
})
