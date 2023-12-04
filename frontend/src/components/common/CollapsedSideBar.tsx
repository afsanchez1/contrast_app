import { Flex, IconButton, Slide, Spacer } from '@chakra-ui/react'
import type { toggleSideBarFunction } from '../../layouts/root'
import type { FC, ReactNode } from 'react'
import { SmallCloseIcon } from '@chakra-ui/icons'
interface CollapsedSideBarProps {
    isSidebarOpen: boolean
    toggleSideBar: toggleSideBarFunction
    children: ReactNode
}

export const CollapsedSideBar: FC<CollapsedSideBarProps> = ({
    isSidebarOpen,
    toggleSideBar,
    children,
}) => {
    return (
        <Slide direction='left' in={isSidebarOpen} style={{ zIndex: 10 }}>
            <Flex
                direction='column'
                backgroundColor='gray.400'
                width={{ base: '100%', sm: '60%', md: '50%', lg: '30%' }}
                height='100%'
            >
                <Flex alignItems='center' p={3}>
                    <Spacer />
                    <IconButton
                        aria-label='Close Side Bar'
                        icon={<SmallCloseIcon />}
                        onClick={toggleSideBar}
                    />
                </Flex>
                {children}
            </Flex>
        </Slide>
    )
}
