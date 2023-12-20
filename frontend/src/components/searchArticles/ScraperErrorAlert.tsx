import type { FC } from 'react'
import type { SearchArticlesErrorResult } from '../../types'
import {
    Alert,
    AlertDescription,
    AlertIcon,
    AlertTitle,
    CloseButton,
    VStack,
    useDisclosure,
    Text,
    Spacer,
    UnorderedList,
    ListItem,
} from '@chakra-ui/react'
import { useTranslation } from 'react-i18next'

function getNewspaperName(scraperName: string): string {
    if (scraperName === 'el-pais') return 'El País'
    return 'Unknown newspaper'
}

interface ScraperErrorAlertProps {
    scraperErrors: SearchArticlesErrorResult[]
}

export const ScraperErrorAlert: FC<ScraperErrorAlertProps> = ({ scraperErrors }) => {
    const { isOpen: isVisible, onClose } = useDisclosure({ defaultIsOpen: true })

    const { t } = useTranslation()

    return isVisible ? (
        scraperErrors.length > 0 ? (
            <Alert status='warning'>
                <AlertIcon boxSize='1.75rem' />
                <Spacer />
                <VStack spacing='0.5rem' align='center' justify='center' textAlign='center'>
                    <AlertTitle>{t('no-results-scraper-error') + ': '}</AlertTitle>
                    <AlertDescription>
                        <UnorderedList>
                            {scraperErrors.map((scraperError, index) => {
                                return (
                                    <ListItem key={index} textAlign='left'>
                                        <Text>
                                            {getNewspaperName(Object.keys(scraperError.error)[0])}
                                        </Text>
                                    </ListItem>
                                )
                            })}
                        </UnorderedList>
                    </AlertDescription>
                </VStack>
                <Spacer />
                <CloseButton
                    data-testid='scraper-alert-close-button'
                    alignSelf='flex-start'
                    position='relative'
                    right={-1}
                    top={-1}
                    onClick={onClose}
                />
            </Alert>
        ) : null
    ) : null
}
