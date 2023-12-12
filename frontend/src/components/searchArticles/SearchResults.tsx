import {
    Flex,
    Spacer,
    Button,
    Card,
    CardBody,
    CardFooter,
    CardHeader,
    Center,
    HStack,
    Heading,
    Link,
    SimpleGrid,
    Spinner,
    Text,
    VStack,
    Alert,
    AlertIcon,
    AlertTitle,
    IconButton,
} from '@chakra-ui/react'
import { type FC, useState, useEffect } from 'react'
import { useParams } from 'react-router-dom'
import { scraperApi } from '../../services'
import {
    ErrorType,
    type SearchResult,
    type SearchArticlesErrorResult,
    type SearchArticlesSuccessResult,
} from '../../types'
import { ChevronDownIcon, ExternalLinkIcon, RepeatIcon } from '@chakra-ui/icons'
import { useTranslation } from 'react-i18next'
import { getError, parseDateTime } from '../../utils'

export const SearchResults: FC = () => {
    const { topic } = useParams()
    const [searchArticles, { isLoading }] = scraperApi.endpoints.searchArticles.useLazyQuery({})
    const [moreIsLoading, setMoreIsLoading] = useState<boolean>(false)
    const [articleSumms, setArticleSumms] = useState<SearchArticlesSuccessResult[]>([])
    const [page, setPage] = useState<number>(0)
    const [scraperErrors, setScraperErrors] = useState<SearchArticlesErrorResult[]>([])
    const [hasSearchError, sethasSearchError] = useState<boolean>(false)
    const [searchErrorMessage, setSearchErrorMessage] = useState<string>('')
    const { t } = useTranslation()

    const setData = (data: SearchResult): void => {
        // Filter the errors and set them
        const errorResults = data.filter(searchResult => {
            return 'error' in searchResult
        }) as SearchArticlesErrorResult[]

        setScraperErrors([...scraperErrors, ...errorResults])

        // Filter the successful responses and set it
        const successResults = data.filter(searchResult => {
            return 'scraper' in searchResult
        }) as SearchArticlesSuccessResult[]

        setArticleSumms([...articleSumms, ...successResults])
    }

    const handleSearchArticles = (): void => {
        if (topic != null) {
            searchArticles(
                {
                    topic,
                    page,
                    limit: 4,
                },
                true
            )
                .then(value => {
                    if (value.isSuccess) {
                        setData(value.data)
                        sethasSearchError(false)
                    } else if (value.isError) {
                        sethasSearchError(true)
                        setSearchErrorMessage(getError(ErrorType.FetchError))
                    }
                    setMoreIsLoading(prevState => !prevState)
                })
                .catch((error: any) => {
                    console.log(error)
                    setMoreIsLoading(prevState => !prevState)
                })
        }
    }

    const handleShowMore = (): void => {
        setMoreIsLoading(prevState => !prevState)
        setPage(prevPage => prevPage + 1)
    }

    useEffect(() => {
        handleSearchArticles()
    }, [searchArticles, page])

    return (
        <VStack margin='2rem' spacing='1.75rem'>
            {hasSearchError ? null : (
                <Flex
                    direction={{ base: 'column', sm: 'column', md: 'row' }}
                    align='center'
                    justify='center'
                >
                    <Heading as='h1' fontSize='1.75rem'>
                        {t('results-for') + ': '}
                    </Heading>
                    <Spacer ml='1rem' />
                    <Text as='i' fontSize='1.75rem'>
                        {topic}
                    </Text>
                </Flex>
            )}

            {isLoading ? (
                <Center h='100vh'>
                    <Spinner size='xl' />
                </Center>
            ) : hasSearchError ? (
                <>
                    <VStack>
                        <Alert
                            status='error'
                            variant='subtle'
                            flexDirection='column'
                            textAlign='center'
                            rounded='2xl'
                        >
                            <AlertIcon boxSize='4rem' mr={0} />
                            <AlertTitle mt={4} mb={1} fontSize='lg'>
                                {t(searchErrorMessage)}
                            </AlertTitle>
                            <IconButton
                                aria-label='refresh'
                                icon={<RepeatIcon />}
                                variant='ghost'
                                onClick={handleSearchArticles}
                            />
                        </Alert>
                    </VStack>
                </>
            ) : (
                <>
                    <SimpleGrid columns={{ sm: 1, lg: 2 }} spacing='2rem'>
                        {articleSumms.map(articleResult => {
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
                                            <Text
                                                fontSize={{
                                                    sm: '1.25rem',
                                                    md: '1.5rem',
                                                    lg: '1.55rem',
                                                }}
                                            >
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
                    <Button isLoading={moreIsLoading} onClick={handleShowMore}>
                        <SimpleGrid columns={3} alignItems='center'>
                            <ChevronDownIcon />
                            <Text>{t('show-more')}</Text>
                        </SimpleGrid>
                    </Button>
                </>
            )}
        </VStack>
    )
}
