import {
    Flex,
    Button,
    Spacer,
    HStack,
    useColorMode,
    IconButton,
    useDisclosure,
} from '@chakra-ui/react'
import { SunIcon, MoonIcon, HamburgerIcon } from '@chakra-ui/icons'
import { CollapsedSideBar, Logo, SideBar } from '.'
import type { FC } from 'react'

/**
 * Props for NavBar
 */
export interface NavBarProps {
    /**
     * A boolean for controlling logo displaying
     */
    hasLogo: boolean
    /**
     * A boolean for controlling toggle sidebar button displaying
     */
    hasSideBarButton: boolean
}
/**
 * NavBar is a custom React component for the navigation bar of the app
 * @param {NavBarProps}
 * @returns {JSX.Element}
 */
export const NavBar: FC<NavBarProps> = ({ hasLogo, hasSideBarButton }) => {
    const { colorMode, toggleColorMode } = useColorMode()
    const { isOpen, onToggle } = useDisclosure()

    return (
        <Flex as='nav' p='10px' alignItems='center'>
            <CollapsedSideBar isSidebarOpen={isOpen} toggleSideBar={onToggle}>
                <SideBar />
            </CollapsedSideBar>
            {hasSideBarButton ? (
                <IconButton
                    data-testid='side-bar-button'
                    aria-label='Toggle SideBar'
                    icon={<HamburgerIcon />}
                    onClick={onToggle}
                />
            ) : null}
            <Spacer />
            {hasLogo ? <Logo fontSize={{ base: '2rem' }} /> : null}
            <Spacer />
            <HStack spacing='20px'>
                <Button data-testid='theme-mode-button' onClick={toggleColorMode}>
                    {colorMode === 'light' ? (
                        <SunIcon data-testid='sun-icon' />
                    ) : (
                        <MoonIcon data-testid='moon-icon' />
                    )}
                </Button>
            </HStack>
        </Flex>
    )
}
