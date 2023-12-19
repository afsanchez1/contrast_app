import {
    Flex,
    Button,
    Spacer,
    HStack,
    useColorMode,
    IconButton,
    Link as ChakraLink,
    useDisclosure,
} from '@chakra-ui/react'
import { SunIcon, MoonIcon, HamburgerIcon } from '@chakra-ui/icons'
import { CollapsedSideBar, Logo, SideBar } from '.'
import type { FC } from 'react'
import { Link as ReactRouterLink } from 'react-router-dom'

interface NavBarProps {
    hasLogo: boolean
    hasSideBarButton: boolean
}
export const NavBar: FC<NavBarProps> = ({ hasLogo, hasSideBarButton }: NavBarProps) => {
    const { colorMode, toggleColorMode } = useColorMode()
    const { isOpen, onToggle } = useDisclosure()

    return (
        <Flex as='nav' p='10px' alignItems='center'>
            <CollapsedSideBar isSidebarOpen={isOpen} toggleSideBar={onToggle}>
                <SideBar />
            </CollapsedSideBar>
            {hasSideBarButton ? (
                <IconButton
                    aria-label='Toggle SideBar'
                    icon={<HamburgerIcon />}
                    onClick={onToggle}
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
