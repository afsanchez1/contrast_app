import { Grid, GridItem } from '@chakra-ui/react'
import type { FC } from 'react'
import { Outlet } from 'react-router-dom'
import { NavBar, Footer } from '../components'

/**
 * Root is a custom React component for creating the root layout of the app
 * @returns {JSX.Element}
 */
export const Root: FC = () => {
    return (
        <Grid
            templateColumns='repeat(6 1fr)'
            templateRows='10% 80% 10%'
            height='100vh'
            alignItems='center'
        >
            {/* NavBar */}
            <GridItem>
                <NavBar hasLogo={false} hasSideBarButton={true} />
            </GridItem>

            {/* Main Content */}
            <GridItem>
                <Outlet />
            </GridItem>

            {/* Footer */}
            <GridItem textAlign='center'>
                <Footer />
            </GridItem>
        </Grid>
    )
}
