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
