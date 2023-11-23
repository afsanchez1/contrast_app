import type { FC } from 'react'
import { Flex, Button, Spacer, HStack, useColorMode } from '@chakra-ui/react'
import { SunIcon, MoonIcon } from '@chakra-ui/icons'

export const NavBar: FC = () => {
    const { colorMode, toggleColorMode } = useColorMode()

    return (
        <Flex as='nav' p='10px' alignItems='center'>
            <Spacer />
            <HStack spacing='20px'>
                <Button onClick={toggleColorMode}>
                    {colorMode === 'light' ? <SunIcon /> : <MoonIcon />}
                </Button>
            </HStack>
        </Flex>
    )
}
