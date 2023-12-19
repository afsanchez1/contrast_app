import type { FC } from 'react'
import {
    Box,
    Heading,
    type HeadingProps,
    type ResponsiveObject,
    Text,
    Link as ChakraLink,
    useColorMode,
} from '@chakra-ui/react'
import { Link as ReactRouterLink } from 'react-router-dom'

interface LogoProps extends HeadingProps {
    fontSize: ResponsiveObject<string | number>
}
export const Logo: FC<LogoProps> = ({ fontSize }: LogoProps) => {
    const { colorMode } = useColorMode()

    return (
        <ChakraLink as={ReactRouterLink} to='/' _hover={{ textDecoration: 'none' }}>
            <Box as='header'>
                <Heading
                    as='h1'
                    fontSize={fontSize}
                    fontWeight='bold'
                    color={colorMode === 'light' ? 'black' : 'white'}
                >
                    CON
                    <Text
                        as='span'
                        bg={colorMode === 'light' ? 'black' : 'white'}
                        color={colorMode !== 'light' ? 'blackAlpha.900' : 'white'}
                    >
                        TRAST
                    </Text>
                </Heading>
            </Box>
        </ChakraLink>
    )
}
