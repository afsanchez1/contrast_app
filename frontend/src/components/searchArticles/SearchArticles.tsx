import React, { type FC, useState } from 'react'
import { useTranslation } from 'react-i18next'
import {
    Flex,
    Box,
    Input,
    FormControl,
    FormErrorMessage,
    Spinner,
    SlideFade,
    Alert,
    AlertIcon,
    AlertDescription,
    VStack,
    InputGroup,
    InputLeftElement,
} from '@chakra-ui/react'
import { Logo } from '../../components'
import { scraperApi } from '../../services/scraper'
import { useNavigate } from 'react-router-dom'
import { ErrorType } from '../../types'
import { getError } from '../../utils'
import { SearchIcon } from '@chakra-ui/icons'

export const SearchArticles: FC = () => {
    const { t } = useTranslation()
    const [topic, setTopic] = useState<string>('')
    const [hasEmptyError, setHasEmptyError] = useState<boolean>(false)
    const [formError, setFormError] = useState<string>()
    const [hasSearchError, sethasSearchError] = useState<boolean>(false)

    const [searchArticles, { isLoading }] = scraperApi.endpoints.searchArticles.useLazyQuery({})
    const navigate = useNavigate()

    const handleChange = (event: React.ChangeEvent<HTMLInputElement>): void => {
        const value = event.target.value

        if (value === '') {
            setHasEmptyError(true)
            setFormError(getError(ErrorType.EmptyTopicError))
        } else {
            setHasEmptyError(false)
        }

        setTopic(value)
    }

    const handleSubmit = (event: React.FormEvent<HTMLFormElement>): void => {
        event.preventDefault()

        // If the topic is empty set errors and do nothing
        if (topic.trim() === '') {
            setHasEmptyError(true)
            setFormError(getError(ErrorType.EmptyTopicError))
            return
        }

        // When topic is not empty, clean errors and make the request
        setHasEmptyError(false)

        const queryParams = {
            topic,
            page: 0,
            limit: 4,
        }

        searchArticles(queryParams, false)
            .then(value => {
                if (value.isSuccess) navigate(`search_results/${topic}`)
                else if (value.isError) {
                    sethasSearchError(true)
                    setFormError(getError(ErrorType.FetchError))
                }
            })
            .catch((error: any) => {
                console.log(error)
            })
    }

    return (
        <Flex direction='column' align='center' justify='center' minWidth='20rem'>
            {/* Header */}
            <Box mb={{ base: '1.75rem', md: '2rem', lg: '3rem' }}>
                <Logo fontSize={{ base: '2.5rem', md: '3rem', lg: '3.5rem' }} />
            </Box>

            {/* Search input section */}
            <Box as='section'>
                <form onSubmit={handleSubmit}>
                    <FormControl isInvalid={hasEmptyError || hasSearchError}>
                        <VStack
                            alignItems='center'
                            maxWidth={{ base: '15rem', md: '20rem', lg: '25rem' }}
                        >
                            <InputGroup size={{ base: 'sm', md: 'md', lg: 'lg' }}>
                                <InputLeftElement
                                    pointerEvents='none'
                                    alignContent='center'
                                    justifyContent='center'
                                >
                                    <SearchIcon />
                                </InputLeftElement>
                                <Input
                                    type='search'
                                    placeholder={t('search-a-topic')}
                                    mb={{ base: '0.15rem', md: '0.25rem', lg: '0.5rem' }}
                                    rounded='full'
                                    variant='filled'
                                    disabled={isLoading}
                                    value={topic}
                                    onInput={handleChange}
                                    _focus={{
                                        borderColor: hasEmptyError ? 'red' : '',
                                    }}
                                />
                            </InputGroup>
                            {isLoading ? <Spinner /> : null}
                            <SlideFade in={formError != null ? formError.length > 0 : false}>
                                <FormErrorMessage size={{ base: 'sm', md: 'md', lg: 'lg' }}>
                                    <Alert status='error' rounded='full'>
                                        <AlertIcon />
                                        <AlertDescription>{t(formError ?? '')}</AlertDescription>
                                    </Alert>
                                </FormErrorMessage>
                            </SlideFade>
                        </VStack>
                    </FormControl>
                </form>
            </Box>
        </Flex>
    )
}
