import { Grid, GridItem } from '@chakra-ui/react'
import type { FC } from 'react'
import { Outlet } from 'react-router-dom'
import { NavBar, Footer } from '../components'

export type toggleSideBarFunction = () => void
export const Results: FC = () => {
    return (
        <>
            <Grid
                templateColumns='repeat(6 1fr) '
                templateRows='repeat(6 1fr)'
                height='100vh'
                alignItems='center'
            >
                {/* NavBar */}
                <GridItem rowSpan={1}>
                    <NavBar hasLogo={true} hasSideBarButton={true} />
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
