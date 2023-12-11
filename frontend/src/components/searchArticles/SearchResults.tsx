import {
    Card,
    CardBody,
    CardFooter,
    CardHeader,
    HStack,
    Heading,
    Link,
    SimpleGrid,
    Text,
    VStack,
} from '@chakra-ui/react'
import { type FC, useState } from 'react'
import { useParams } from 'react-router-dom'
import { useSelector } from 'react-redux'
import { scraperApi } from '../../services'
import type { SearchArticlesResult } from '../../types'
import { ExternalLinkIcon } from '@chakra-ui/icons'
import { useTranslation } from 'react-i18next'
import { parseDateTime } from '../../utils'

export const SearchResults: FC = () => {
    const { topic } = useParams()
    // const [searchArticles, { isLoading }] = scraperApi.endpoints.searchArticles.useLazyQuery({})
    // const [articleResults, setArticleResults] = useState<SearchArticlesResult[]>([])
    const [page, setPage] = useState<number>(0)
    // const [hasSearchError, sethasSearchError] = useState<boolean>(false)
    const { t } = useTranslation()

    const articleResults = useSelector(
        scraperApi.endpoints.searchArticles.select({ topic: topic ?? '', page, limit: 4 })
    ).data as SearchArticlesResult[]

    return (
        <VStack>
            <HStack>
                <Heading as='h1' fontSize='1.75rem'>
                    {t('results-for') + ': '}
                </Heading>
                <Text as='i' fontSize='1.75rem'>
                    {topic}
                </Text>
            </HStack>
            <SimpleGrid columns={{ sm: 1, lg: 2 }} spacing='2rem' margin='2rem'>
                {articleResults.map(articleResult => {
                    return articleResult.results.map((articleSumm, index) => {
                        return (
                            <Card key={index}>
                                <CardHeader>
                                    <Link href={articleSumm.url}>
                                        <HStack spacing='0.5rem'>
                                            <Heading as='h1'>{articleSumm.title}</Heading>
                                            <ExternalLinkIcon />
                                        </HStack>
                                    </Link>
                                </CardHeader>
                                <CardBody>
                                    <Text fontSize={{ sm: '1.25rem', md: '1.5rem', lg: '1.55rem' }}>
                                        {articleSumm.excerpt}
                                    </Text>
                                </CardBody>
                                <CardFooter>
                                    <VStack spacing='0.5rem' align='left'>
                                        {articleSumm.authors.map((author, index) => {
                                            return (
                                                <Link
                                                    key={index}
                                                    href={author.url}
                                                    isExternal={true}
                                                >
                                                    <HStack spacing='0.5rem'>
                                                        <Text>{author.name}</Text>
                                                        <ExternalLinkIcon />
                                                    </HStack>
                                                </Link>
                                            )
                                        })}
                                        <Text>
                                            {articleSumm.newspaper +
                                                ' - ' +
                                                parseDateTime(articleSumm.date_time)}
                                        </Text>
                                    </VStack>
                                </CardFooter>
                            </Card>
                        )
                    })
                })}
            </SimpleGrid>
        </VStack>
    )
}
