import { RepeatIcon, SearchIcon } from '@chakra-ui/icons'
import {
    Alert,
    AlertDescription,
    AlertIcon,
    AlertTitle,
    Button,
    HStack,
    VStack,
} from '@chakra-ui/react'
import type { FC } from 'react'
import { useTranslation } from 'react-i18next'
import { useNavigate } from 'react-router-dom'

interface ErrorPanelProps {
    errorMessage: string
    refetchFunction: () => void
}

export const ErrorPanel: FC<ErrorPanelProps> = ({ errorMessage, refetchFunction }) => {
    const { t } = useTranslation()
    const navigate = useNavigate()

    const handleNavigate = (): void => {
        navigate('/')
    }
    return (
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
                        {t('error-notification')}
                    </AlertTitle>
                    <AlertDescription>{errorMessage}</AlertDescription>
                </Alert>
                <HStack alignContent='center' justifyContent='center' spacing={3} mt='1rem'>
                    <Button leftIcon={<RepeatIcon />} onClick={refetchFunction}>
                        {t('try-again')}
                    </Button>
                    <Button leftIcon={<SearchIcon />} onClick={handleNavigate}>
                        {t('search-another-topic')}
                    </Button>
                </HStack>
            </VStack>
        </>
    )
}
