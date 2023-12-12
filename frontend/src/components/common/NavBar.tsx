import {
    Flex,
    Button,
    Spacer,
    HStack,
    useColorMode,
    IconButton,
    Link as ChakraLink,
} from '@chakra-ui/react'
import { SunIcon, MoonIcon, HamburgerIcon } from '@chakra-ui/icons'
import { Logo } from '.'
import type { FC } from 'react'
import type { toggleSideBarFunction } from '../../layouts'
import { Link as ReactRouterLink } from 'react-router-dom'

interface NavBarProps {
    hasLogo: boolean
    hasSideBarButton: boolean
    toggleSideBar: toggleSideBarFunction
}
export const NavBar: FC<NavBarProps> = ({
    hasLogo,
    hasSideBarButton,
    toggleSideBar,
}: NavBarProps) => {
    const { colorMode, toggleColorMode } = useColorMode()

    return (
        <Flex as='nav' p='10px' alignItems='center'>
            {hasSideBarButton ? (
                <IconButton
                    aria-label='Toggle SideBar'
                    icon={<HamburgerIcon />}
                    onClick={toggleSideBar}
                />
            ) : null}
            <Spacer />
            {hasLogo ? (
                <>
                    <ChakraLink as={ReactRouterLink} to='/' _hover={{ textDecoration: 'none' }}>
                        <Logo fontSize={{ base: '2rem' }} />
                    </ChakraLink>
                </>
            ) : null}
            <Spacer />
            <HStack spacing='20px'>
                <Button onClick={toggleColorMode}>
                    {colorMode === 'light' ? <SunIcon /> : <MoonIcon />}
                </Button>
            </HStack>
        </Flex>
    )
}
