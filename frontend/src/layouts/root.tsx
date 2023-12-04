import { Grid, GridItem, useDisclosure } from '@chakra-ui/react'
import type { FC } from 'react'
import { Outlet } from 'react-router-dom'
import { SideBar, NavBar, CollapsedSideBar, Footer } from '../components'

export type toggleSideBarFunction = () => void
export const Root: FC = () => {
    const { isOpen, onToggle } = useDisclosure()

    return (
        <Grid templateColumns='repeat(6, 1fr)' templateRows='10% 1fr 10%'>
            {/* NavBar */}
            <GridItem colSpan={6} rowSpan={1}>
                <NavBar hasLogo={false} hasSideBarButton={true} toggleSideBar={onToggle}></NavBar>
            </GridItem>

            {/* Sidebar */}
            <GridItem as='aside'>
                <CollapsedSideBar isSidebarOpen={isOpen} toggleSideBar={onToggle}>
                    <SideBar />
                </CollapsedSideBar>
            </GridItem>

            {/* Main Content */}
            <GridItem colSpan={6} rowSpan={2}>
                <Outlet />
            </GridItem>

            {/* Footer */}
            <GridItem textAlign='center' colSpan={6} rowSpan={1}>
                <Footer />
            </GridItem>
        </Grid>
    )
}
