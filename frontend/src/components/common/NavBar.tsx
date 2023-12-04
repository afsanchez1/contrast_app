import { Flex, Button, Spacer, HStack, useColorMode, IconButton } from '@chakra-ui/react'
import { SunIcon, MoonIcon, HamburgerIcon } from '@chakra-ui/icons'
import { Logo } from '.'
import type { FC } from 'react'
import type { toggleSideBarFunction } from '../../layouts/root'

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
            {hasLogo ? <Logo fontSize={{ base: '2rem' }} /> : null}
            <Spacer />
            <HStack spacing='20px'>
                <Button onClick={toggleColorMode}>
                    {colorMode === 'light' ? <SunIcon /> : <MoonIcon />}
                </Button>
            </HStack>
        </Flex>
    )
}
