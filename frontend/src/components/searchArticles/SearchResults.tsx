import { Center, Heading } from '@chakra-ui/react'
import type { FC } from 'react'
import { useParams } from 'react-router-dom'
// import { scraperApi } from '../../services'

export const SearchResults: FC = () => {
    const { topic } = useParams()
    // const newTopic = topic ?? ''

    return (
        <Center h='100vh'>
            <Heading as='h1' fontWeight='bold'>
                {topic}
            </Heading>
        </Center>
    )
}
