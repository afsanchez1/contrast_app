import { Grid, GridItem, useDisclosure } from '@chakra-ui/react'
import type { FC } from 'react'
import { Outlet } from 'react-router-dom'
import { SideBar, NavBar, CollapsedSideBar, Footer } from '../components'

export type toggleSideBarFunction = () => void
export const Results: FC = () => {
    const { isOpen, onToggle } = useDisclosure()

    return (
        <>
            <Grid
                templateColumns='repeat(6 1fr) '
                templateRows='repeat(6 1fr)'
                height='100vh'
                alignItems='center'
            >
                {/* NavBar */}
                <GridItem>
                    <NavBar
                        hasLogo={true}
                        hasSideBarButton={true}
                        toggleSideBar={onToggle}
                    ></NavBar>
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
            <CollapsedSideBar isSidebarOpen={isOpen} toggleSideBar={onToggle}>
                <SideBar />
            </CollapsedSideBar>
        </>
    )
}
