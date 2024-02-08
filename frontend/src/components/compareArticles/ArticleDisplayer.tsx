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
} from '@chakra-ui/react'
import { useState, type FC, useEffect } from 'react'
import {
    ArticleSelector,
    type compareSelection,
    removeFromCompare,
    selectCompareArticles,
    setCurrSelector,
    switchCompare,
    ArticleBuilder,
} from '.'
import { useAppDispatch, useAppSelector } from '../../app/hooks'
import { useTranslation } from 'react-i18next'
import { CloseIcon, RepeatIcon } from '@chakra-ui/icons'
import { scraperApi } from '../../services'
import type { Article, ArticleSummary } from '../../types'

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
    const dispatch = useAppDispatch()
    const [getArticle, { isLoading }] = scraperApi.endpoints.getArticle.useLazyQuery({})
    const [articlesCache, setArticlesCache] = useState<Article[]>([])
    const [articlesToCompare, setArticlesToCompare] = useState<ArticleToCompare[]>([])
    const [hasErrorUrl, setHasErrorUrl] = useState<string>('')

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
    const handleRemove = (index: number): void => {
        dispatch(removeFromCompare(index))
    }

    // Checks if it's in cache
    const findArticleInCache = (artSumm: ArticleSummary): Article | undefined => {
        return articlesCache.find(cachedArt => {
            return cachedArt.url === artSumm.url
        })
    }
    const handleArticleSelection = (compareSelections: compareSelection[]): void => {
        const requestedArts = compareSelections.filter(
            compareSelection => findArticleInCache(compareSelection.articleSummary) == null
        )

        requestedArts.forEach(requestedArt => {
            const url = encodeURIComponent(requestedArt.articleSummary.url)
            getArticle({ url }, false)
                .then(value => {
                    if (value.isSuccess) {
                        setArticlesCache([...articlesCache, value.data as Article])
                        setArticlesToCompare([
                            ...articlesToCompare,
                            { article: value.data as Article, index: requestedArt.index },
                        ])
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
        // TODO fix racing condition when handling articles
        handleArticleSelection(compareArticles)
    }, [compareArticles])

    return (
        <>
            <ArticleSelector isOpen={isOpen} onClose={onClose} />
            <VStack maxW='90%' minW='80%' mt='1rem'>
                <Flex
                    bgColor='black'
                    width='100%'
                    mb='1rem'
                    justify='space-between'
                    align='center'
                    roundedLeft='base'
                    roundedRight='base'
                    h='4rem'
                >
                    <Spacer />
                    <Button
                        onClick={() => {
                            dispatch(switchCompare())
                        }}
                    >
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
                            <Card key={index} boxShadow='lg'>
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
                                        <Flex align='center' justify='center'>
                                            <Spinner size='xl' />
                                        </Flex>
                                    ) : (
                                        articlesToCompare.map(artToCompare => {
                                            if (artToCompare.index === index) {
                                                return (
                                                    <ArticleBuilder
                                                        key={index}
                                                        article={artToCompare.article}
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
