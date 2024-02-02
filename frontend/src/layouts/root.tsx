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
        <>
            <Grid templateRows='0.1% 90.9% 9%' height='100vh' alignItems='center'>
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
        </>
    )
}
