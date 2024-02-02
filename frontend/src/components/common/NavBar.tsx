import {
    Flex,
    Button,
    HStack,
    useColorMode,
    IconButton,
    useDisclosure,
    Box,
} from '@chakra-ui/react'
import { SunIcon, MoonIcon, HamburgerIcon } from '@chakra-ui/icons'
import { CollapsedSideBar, Logo, SideBar } from '.'
import type { FC } from 'react'
import { CartDisplayer } from '../articleCart'

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
        <>
            <CollapsedSideBar isSidebarOpen={isOpen} toggleSideBar={onToggle}>
                <SideBar />
            </CollapsedSideBar>
            <Flex
                as='nav'
                p='0.5rem'
                alignItems='center'
                justify='space-between'
                position='fixed'
                w='100%'
                backdropFilter='saturate(180%)'
                zIndex='1'
                backgroundColor={colorMode === 'light' ? 'white' : 'gray.800'}
                boxShadow={colorMode === 'light' ? 'base' : 'xl'}
            >
                {hasSideBarButton ? (
                    <IconButton
                        data-testid='side-bar-button'
                        aria-label='Toggle SideBar'
                        icon={<HamburgerIcon />}
                        onClick={onToggle}
                    ></IconButton>
                ) : null}

                <Box position='absolute' left='50%' transform='translateX(-50%)'>
                    {hasLogo ? <Logo fontSize={{ base: '2rem' }} /> : null}
                </Box>

                <HStack>
                    <CartDisplayer />
                    <Button data-testid='theme-mode-button' onClick={toggleColorMode}>
                        {colorMode === 'light' ? (
                            <SunIcon data-testid='sun-icon' />
                        ) : (
                            <MoonIcon data-testid='moon-icon' />
                        )}
                    </Button>
                </HStack>
            </Flex>
        </>
    )
}
