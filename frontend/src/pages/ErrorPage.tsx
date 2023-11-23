import type { FC } from 'react'
import { Center, Heading, Text, VStack } from '@chakra-ui/react'
import { useRouteError } from 'react-router-dom'
import type { routerError } from '../types'

export const ErrorPage: FC = () => {
    const error = useRouteError() as routerError

    return (
        <Center h='100vh'>
            <VStack alignContent='center'>
                <Heading as='h1' fontWeight='bold'>
                    Ups!
                </Heading>
                <Text as='p'>Lo siento, parece que hay un problema</Text>
                <Text as='i'>{error.statusText ?? error.message}</Text>
            </VStack>
        </Center>
    )
}
