import {
    Button,
    Card,
    CardBody,
    VStack,
    useDisclosure,
    Text,
    CardHeader,
    IconButton,
    Flex,
    SimpleGrid,
    Spacer,
    HStack,
    Spinner,
    useColorMode,
} from '@chakra-ui/react'
import { useState, type FC, useEffect } from 'react'
import {
    ArticleSelector,
    type compareSelection,
    removeFromCompare,
    selectCompareArticles,
    setCurrSelector,
    ArticleBuilder,
    selectCurrSelection,
    clearCompare,
} from '.'
import { useAppDispatch, useAppSelector } from '../../app/hooks'
import { useTranslation } from 'react-i18next'
import { CloseIcon, RepeatIcon } from '@chakra-ui/icons'
import { scraperApi } from '../../services'
import type { Article, ArticleSummary } from '../../types'
import { BackButton } from '..'
import { selectTopic } from '../searchArticles/searchSlice'

/**
 * ArticleDisplayer props
 */
export interface ArticleDisplayerProps {
    displayCount: number
}

/**
 * ArticleDisplayer is a custom React component for managing article comparison
 * @returns {JSX.Element}
 */
export const ArticleDisplayer: FC<ArticleDisplayerProps> = ({ displayCount }) => {
    const { isOpen, onOpen, onClose } = useDisclosure()
    const { t } = useTranslation()
    const compareIndexes = new Array<number>(displayCount).fill(0).map((_, i) => i)
    const compareArticles = useAppSelector(state => selectCompareArticles(state))
    const currSelection = useAppSelector(state => selectCurrSelection(state))
    const lastTopic = useAppSelector(state => selectTopic(state))
    const dispatch = useAppDispatch()
    const [getArticle, { isLoading }] = scraperApi.endpoints.getArticle.useLazyQuery({})
    const [articlesCache, setArticlesCache] = useState<Article[]>([])
    const [articlesToCompare, setArticlesToCompare] = useState<ArticleToCompare[]>([])
    const [hasErrorUrl, setHasErrorUrl] = useState<string>('')
    const { colorMode } = useColorMode()

    interface ArticleToCompare {
        article: Article
        index: number
    }

    // Checks if it's in store
    const findCompareArt = (index: number): compareSelection | undefined => {
        return compareArticles.find(compareArticle => compareArticle.index === index)
    }
    const handlePreSelection = (index: number): void => {
        dispatch(setCurrSelector(index))
        onOpen()
    }
    const handleSwitchCompare = (): void => {
        const switched = articlesToCompare.map(art => {
            if (art.index === 0)
                return {
                    ...art,
                    index: 1,
                }
            else
                return {
                    ...art,
                    index: 0,
                }
        })

        setArticlesToCompare(switched)
    }
    const handleRemove = (index: number): void => {
        console.log(`remove index: ${index}`)
        const filtered = articlesToCompare.filter(art => art.index !== index)
        console.log(filtered)
        setArticlesToCompare(filtered)
        dispatch(removeFromCompare(index))
    }

    const updateToCompareArticles = (articleToCompare: ArticleToCompare): void => {
        console.log(articlesToCompare.length)
        if (articlesToCompare.length === 0) {
            setArticlesToCompare([...articlesToCompare, articleToCompare])
        } else {
            const filtered = articlesToCompare.filter(art => art.index !== articleToCompare.index)
            setArticlesToCompare([...filtered, articleToCompare])
        }
    }

    // Checks if it's in cache
    const findArticleInCache = (artSumm: ArticleSummary): Article | undefined => {
        return articlesCache.find(cachedArt => {
            return cachedArt.url === artSumm.url
        })
    }

    const handleArticleSelection = (compareSelections: compareSelection[]): void => {
        // Filter only the ones not requested previously
        const requestedArts = compareSelections.filter(
            compareSelection => findArticleInCache(compareSelection.articleSummary) == null
        )

        if (requestedArts.length === 0) {
            if (currSelection != null) {
                const artToCompare = findArticleInCache(currSelection.articleSummary)
                if (artToCompare != null)
                    updateToCompareArticles({ article: artToCompare, index: currSelection.index })
            }
            return
        }

        // Make requests for the not requested ones
        requestedArts.forEach(requestedArt => {
            const url = encodeURIComponent(requestedArt.articleSummary.url)
            getArticle({ url }, false)
                .then(value => {
                    if (value.isSuccess) {
                        console.log(`requestedart index: ${requestedArt.index}`)
                        setArticlesCache([...articlesCache, value.data as Article])
                        updateToCompareArticles({
                            article: value.data as Article,
                            index: requestedArt.index,
                        })
                    } else {
                        setHasErrorUrl(requestedArt.articleSummary.url)
                    }
                })
                .catch(e => {
                    console.log(e)
                })
        })
    }

    useEffect(() => {
        dispatch(clearCompare())
    }, [])

    useEffect(() => {
        if (compareArticles.length === 0) {
            setTimeout(() => {
                onOpen()
            }, 200)
        } else handleArticleSelection(compareArticles)
    }, [compareArticles])

    return (
        <>
            <ArticleSelector isOpen={isOpen} onClose={onClose} />
            <VStack maxW='90%' minW='80%' mt='1rem'>
                <Flex width='100%' mb='2.5rem' h='0.5rem'>
                    <BackButton route={`/search_results/${lastTopic}`} />
                </Flex>

                <Flex
                    bgColor={colorMode === 'light' ? 'black' : 'blackAlpha.500'}
                    width='100%'
                    mb='1rem'
                    justify='space-between'
                    align='center'
                    roundedLeft='base'
                    roundedRight='base'
                    h='4rem'
                    border={colorMode === 'light' ? '1px' : 'hidden'}
                >
                    <Spacer />
                    <Button onClick={handleSwitchCompare}>
                        <HStack spacing='0.5rem'>
                            <Text>{t('switch-articles')}</Text>
                            <RepeatIcon />
                        </HStack>
                    </Button>
                    <Spacer />
                </Flex>
                <SimpleGrid width='100%' columns={{ base: 1, md: 2 }} spacing='1rem'>
                    {compareIndexes.map(index => {
                        return (
                            <Card
                                key={index}
                                boxShadow='lg'
                                border={colorMode === 'light' ? '1px' : 'hidden'}
                                bgColor={colorMode === 'light' ? 'gray.50' : 'blackAlpha.400'}
                            >
                                {findCompareArt(index) == null ? null : (
                                    <CardHeader h='0.5rem' mb='0.5rem'>
                                        <Flex justify='right'>
                                            <IconButton
                                                icon={<CloseIcon />}
                                                onClick={() => {
                                                    handleRemove(index)
                                                }}
                                                size='xs'
                                                aria-label={'remove-compare-article'}
                                                variant='ghost'
                                            />
                                        </Flex>
                                    </CardHeader>
                                )}
                                <CardBody>
                                    {findCompareArt(index) == null ? (
                                        <VStack
                                            align='center'
                                            justify='center'
                                            h='50vh'
                                            textAlign='center'
                                        >
                                            <Text fontWeight='bold' fontSize='1.2rem' p='1rem'>
                                                {t('no-article-selected-yet')}
                                            </Text>
                                            <Button
                                                onClick={() => {
                                                    handlePreSelection(index)
                                                }}
                                            >
                                                {t('select-article')}
                                            </Button>
                                        </VStack>
                                    ) : isLoading ? (
                                        <Flex align='center' justify='center' h='40vh'>
                                            <Spinner size='xl' />
                                        </Flex>
                                    ) : (
                                        articlesToCompare.map(artToCompare => {
                                            if (artToCompare.index === index) {
                                                return (
                                                    <ArticleBuilder
                                                        article={artToCompare.article}
                                                        key={artToCompare.index}
                                                    />
                                                )
                                            } else return null
                                        })
                                    )}
                                </CardBody>
                            </Card>
                        )
                    })}
                </SimpleGrid>
            </VStack>
        </>
    )
}
