import { Flex, IconButton, Slide, Spacer, useColorMode } from '@chakra-ui/react'
import type { FC, ReactNode } from 'react'
import { SmallCloseIcon } from '@chakra-ui/icons'

/**
 * Props for CollapsedSideBar
 */
export interface CollapsedSideBarProps {
    /**
     * The boolean for controlling if the sidebar is opened
     */
    isSidebarOpen: boolean
    /**
     * The function for opening the sidebar
     */
    toggleSideBar: () => void
    /**
     * The children of the component
     */
    children: ReactNode
}

/**
 * CollapsedSideBar is a custom React component that enables a sidebar to be collapsable
 * @param {CollapsedSideBarProps}
 * @returns {JSX.Element}
 */
export const CollapsedSideBar: FC<CollapsedSideBarProps> = ({
    isSidebarOpen,
    toggleSideBar,
    children,
}) => {
    const { colorMode } = useColorMode()
    return (
        <Slide direction='left' in={isSidebarOpen} style={{ zIndex: 2 }}>
            <Flex
                direction='column'
                backgroundColor={colorMode === 'light' ? 'gray.300' : 'gray.700'}
                width={{ base: '100%', sm: '70%', md: '50%', lg: '30%' }}
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
