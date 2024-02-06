import { Grid, GridItem, useBreakpoint } from '@chakra-ui/react'
import type { FC } from 'react'
import { Outlet } from 'react-router-dom'
import { NavBar, Footer } from '../components'

/**
 * Compare is a custom React component for creating the article comparing layout of the app
 * @returns {JSX.Element}
 */
export const Compare: FC = () => {
    const breakpoint = useBreakpoint('sm')
    const hasLogo = !(breakpoint === 'base' || breakpoint === 'sm' || breakpoint === 'md')

    return (
        <>
            <Grid
                templateColumns='1fr'
                templateRows='repeat(auto-fill, 1fr)'
                height='100vh'
                alignItems='center'
            >
                {/* NavBar */}
                <GridItem rowSpan={1} mb='3rem'>
                    <NavBar
                        hasLogo={hasLogo}
                        hasSideBarButton={true}
                        hasSelectedArticlesButton={false}
                    />
                </GridItem>

                {/* Main Content */}
                <GridItem rowSpan={40}>
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
