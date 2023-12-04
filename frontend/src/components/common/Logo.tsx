import type { FC } from 'react'
import { Box, Heading, type HeadingProps, type ResponsiveObject, Text } from '@chakra-ui/react'

interface LogoProps extends HeadingProps {
    fontSize: ResponsiveObject<string | number>
}
export const Logo: FC<LogoProps> = ({ fontSize }: LogoProps) => {
    return (
        <Box as='header'>
            <Heading as='h1' fontSize={fontSize} fontWeight='bold'>
                CON
                <Text as='span' bg='black' color='white'>
                    TRAST
                </Text>
            </Heading>
        </Box>
    )
}
