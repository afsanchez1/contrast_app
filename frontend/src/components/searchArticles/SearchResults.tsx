import { Center, Heading } from '@chakra-ui/react'
import type { FC } from 'react'
import { useParams } from 'react-router-dom'
import { useSelector } from 'react-redux'
import { scraperApi } from '../../services'
import type { SearchArticlesResult } from '../../types'

export const SearchResults: FC = () => {
    const { topic } = useParams()
    const result = useSelector(
        scraperApi.endpoints.searchArticles.select({ topic: topic ?? '', page: 0, limit: 2 })
    ).data as SearchArticlesResult[]

    return (
        <Center h='100vh'>
            <Heading as='h1' fontWeight='bold'>
                {result[0].results[0].title}
            </Heading>
        </Center>
    )
}
