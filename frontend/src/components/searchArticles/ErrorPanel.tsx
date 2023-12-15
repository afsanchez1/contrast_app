import { RepeatIcon } from '@chakra-ui/icons'
import {
    Alert,
    AlertDescription,
    AlertIcon,
    AlertTitle,
    IconButton,
    VStack,
} from '@chakra-ui/react'
import type { FC } from 'react'
import { useTranslation } from 'react-i18next'

interface ErrorPanelProps {
    errorMessage: string
    refetchFunction: () => void
}
export const ErrorPanel: FC<ErrorPanelProps> = ({ errorMessage, refetchFunction }) => {
    const { t } = useTranslation()
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
                    <AlertDescription>{t(errorMessage)}</AlertDescription>
                    <IconButton
                        aria-label='refresh'
                        icon={<RepeatIcon />}
                        variant='ghost'
                        onClick={refetchFunction}
                    />
                </Alert>
            </VStack>
        </>
    )
}
