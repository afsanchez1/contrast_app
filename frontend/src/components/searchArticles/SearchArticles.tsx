import React, { type FC, useState } from 'react'
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
    const [topic, setTopic] = useState<string>('')
    const [hasEmptyError, setHasEmptyError] = useState<boolean>(false)
    const [formErrors, setFormErrors] = useState<string[]>([])
    const [hasSearchError, sethasSearchError] = useState<boolean>(false)

    const [searchArticles, { isLoading }] = scraperApi.endpoints.searchArticles.useLazyQuery({})

    const navigate = useNavigate()

    const updateFormErrors = (error: string): void => {
        if (!formErrors.includes(error)) setFormErrors([...formErrors, error])
    }

    const cleanFormErrors = (): void => {
        setFormErrors([])
    }

    const handleChange = (event: React.ChangeEvent<HTMLInputElement>): void => {
        const value = event.target.value

        if (value === '') {
            setHasEmptyError(true)
            updateFormErrors(getError(ErrorType.EmptyTopicError))
        } else {
            setHasEmptyError(false)
            cleanFormErrors()
        }

        setTopic(value)
    }

    const handleSubmit = (event: React.FormEvent<HTMLFormElement>): void => {
        event.preventDefault()

        if (topic.trim() === '') {
            setHasEmptyError(true)
            updateFormErrors(getError(ErrorType.EmptyTopicError))
            return
        }
        setHasEmptyError(false)

        searchArticles(
            {
                topic,
                page: 0,
                limit: 2,
            },
            false
        )
            .then(value => {
                if (value.isSuccess) navigate(`search_results/${topic}`)
                else if (value.isError) {
                    console.log(value.error)
                    sethasSearchError(true)
                    updateFormErrors(getError(ErrorType.FetchError))
                }
            })
            .catch((error: any) => {
                console.log(error)
            })
    }

    return (
        <Flex direction='column' align='center' justify='center' height='100vh' minWidth='20rem'>
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
                                    placeholder='Busca un tema...'
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
                            <SlideFade in={hasEmptyError || hasSearchError}>
                                {formErrors.map((error: string, index: number) => {
                                    return (
                                        <FormErrorMessage
                                            key={index}
                                            size={{ base: 'sm', md: 'md', lg: 'lg' }}
                                        >
                                            <Alert status='error' rounded='full'>
                                                <AlertIcon />
                                                <AlertDescription>{error}</AlertDescription>
                                            </Alert>
                                        </FormErrorMessage>
                                    )
                                })}
                            </SlideFade>
                        </VStack>
                    </FormControl>
                </form>
            </Box>
        </Flex>
    )
}
