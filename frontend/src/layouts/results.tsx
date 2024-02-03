import { Grid, GridItem, useBreakpoint } from '@chakra-ui/react'
import type { FC } from 'react'
import { Outlet } from 'react-router-dom'
import { NavBar, Footer } from '../components'

/**
 * Results is a custom React component for creating the search result displaying layout of the app
 * @returns {JSX.Element}
 */
export const Results: FC = () => {
    const breakpoint = useBreakpoint('sm')
    const hasLogo = !(breakpoint === 'base' || breakpoint === 'sm' || breakpoint === 'md')

    return (
        <>
            <Grid
                templateColumns='repeat(6 1fr)'
                templateRows='repeat(6 1fr)'
                height='100vh'
                alignItems='center'
            >
                {/* NavBar */}
                <GridItem rowSpan={1} mb='3rem'>
                    <NavBar hasLogo={hasLogo} hasSideBarButton={true} />
                </GridItem>

                {/* Main Content */}
                <GridItem rowSpan={10}>
                    <Outlet />
                </GridItem>

                {/* Footer */}
                <GridItem rowSpan={1} textAlign='center'>
                    <Footer />
                </GridItem>
            </Grid>
        </>
    )
}
