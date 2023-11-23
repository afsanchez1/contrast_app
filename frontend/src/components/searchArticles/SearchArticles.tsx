import React, { type FC, useState } from 'react'
import {
    Flex,
    Box,
    Heading,
    Text,
    Input,
    FormControl,
    FormErrorMessage,
    Spinner,
    SlideFade,
    Alert,
    AlertIcon,
    AlertDescription,
} from '@chakra-ui/react'
import { scraperApi } from '../../services/scraper'
import { useNavigate } from 'react-router-dom'
import { ErrorType } from '../../types'
import { getError } from '../../utils'

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
                limit: 5,
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
            .catch(error => {
                console.log(error)
            })
    }

    return (
        <Flex direction='column' align='center' justify='center' height='100vh'>
            {/* Header */}
            <Box as='header'>
                <Heading
                    as='h1'
                    size='2xl'
                    fontWeight='bold'
                    mb={{ base: '1.5rem', md: '2rem', lg: '3rem' }}
                >
                    CON
                    <Text as='span' bg='black' color='white'>
                        TRAST
                    </Text>
                </Heading>
            </Box>

            <Flex direction='column' align='center' width='100%'>
                {/* Search input section */}
                <Box as='section'>
                    <form onSubmit={handleSubmit}>
                        <FormControl isInvalid={hasEmptyError || hasSearchError}>
                            <Input
                                placeholder='Busca un tema...'
                                mr={{ base: '0.5rem', md: '1rem', lg: '1.25rem' }}
                                size={{ base: 'sm', sm: 'sm', md: 'lg' }}
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
                            <SlideFade in={hasEmptyError || hasSearchError}>
                                {formErrors.map((error: string, index: number) => {
                                    return (
                                        <FormErrorMessage
                                            key={index}
                                            size={{ base: 'sm', sm: 'sm', md: 'lg' }}
                                        >
                                            <Alert status='error' rounded='full'>
                                                <AlertIcon />
                                                <AlertDescription>{error}</AlertDescription>
                                            </Alert>
                                        </FormErrorMessage>
                                    )
                                })}
                            </SlideFade>
                        </FormControl>
                    </form>
                </Box>
                <Box alignContent='center' justifyItems='center'>
                    {isLoading ? <Spinner mt='1rem' /> : null}
                </Box>
            </Flex>
        </Flex>
    )
}
