import type { FC } from 'react'
import { Box, Heading, type HeadingProps, type ResponsiveObject, Text } from '@chakra-ui/react'
import { useColorMode } from '@chakra-ui/react'

interface LogoProps extends HeadingProps {
    fontSize: ResponsiveObject<string | number>
}
export const Logo: FC<LogoProps> = ({ fontSize }: LogoProps) => {
    const { colorMode } = useColorMode()

    return (
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
                    color={colorMode !== 'light' ? 'black' : 'white'}
                >
                    TRAST
                </Text>
            </Heading>
        </Box>
    )
}
