import { Grid, GridItem, useDisclosure } from '@chakra-ui/react'
import type { FC } from 'react'
import { Outlet } from 'react-router-dom'
import { SideBar, NavBar, CollapsedSideBar, Footer } from '../components'

export const Root: FC = () => {
    const { isOpen, onToggle } = useDisclosure()

    return (
        <Grid
            templateColumns='repeat(6 1fr)'
            templateRows='10% 0% 80% 10%'
            height='100vh'
            alignItems='center'
        >
            {/* NavBar */}
            <GridItem>
                <NavBar hasLogo={false} hasSideBarButton={true} toggleSideBar={onToggle}></NavBar>
            </GridItem>

            {/* Sidebar */}
            <GridItem as='aside'>
                <CollapsedSideBar isSidebarOpen={isOpen} toggleSideBar={onToggle}>
                    <SideBar />
                </CollapsedSideBar>
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
