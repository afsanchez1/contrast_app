import { type FC } from 'react'
import {
    Button,
    Card,
    CardFooter,
    CardHeader,
    Center,
    DrawerBody,
    DrawerFooter,
    Text,
    VStack,
    useColorMode,
} from '@chakra-ui/react'
import { CustomDrawer } from '..'
import { useTranslation } from 'react-i18next'
import { useAppSelector } from '../../app/hooks'
import { selectCartItems, selectCartTotalItems } from '../articleCart'
import { parseDateTime } from '../../utils'
import { SearchIcon } from '@chakra-ui/icons'
import { useNavigate } from 'react-router-dom'

/**
 * Props for ArticleSelector
 */
export interface ArticleSelectorProps {
    /**
     * boolean for handling ArticleSelector opening
     */
    isOpen: boolean
    /**
     * function for handling ArticleSelector closing
     */
    onClose: () => void
}
/**
 * ArticleSelector is a custom React component for selecting articles for further comparison
 * @returns {JSX.Element}
 */
export const ArticleSelector: FC<ArticleSelectorProps> = ({ isOpen, onClose }) => {
    const { colorMode } = useColorMode()
    const { t } = useTranslation()
    const navigate = useNavigate()
    const selectedArticles = useAppSelector(state => selectCartItems(state))
    const selectTotalItems = useAppSelector(state => selectCartTotalItems(state))

    const handleNavigate = (): void => {
        navigate('/')
    }

    return (
        <CustomDrawer
            headerTitle={t('select-article')}
            isOpen={isOpen}
            onClose={onClose}
            placement={'right'}
        >
            <DrawerBody mt='1rem'>
                {selectTotalItems > 0 ? (
                    selectedArticles.map((artSumm, index) => {
                        return (
                            <Card
                                key={index}
                                mb='1rem'
                                boxShadow='md'
                                bgColor={colorMode === 'light' ? 'gray.50' : 'blackAlpha.400'}
                            >
                                <CardHeader>
                                    <Text fontSize='lg' fontWeight='bold'>
                                        {artSumm.title}
                                    </Text>
                                </CardHeader>
                                <CardFooter>
                                    <VStack align='left'>
                                        <Text fontSize='sm'>{artSumm.newspaper}</Text>
                                        <Text fontSize='sm'>
                                            {parseDateTime(artSumm.date_time)}
                                        </Text>
                                    </VStack>
                                </CardFooter>
                                <Button
                                    aria-label='remove-article'
                                    m='1rem'
                                    size='sm'
                                    onClick={() => {
                                        console.log('add article')
                                    }}
                                >
                                    <Text>{t('select')}</Text>
                                </Button>
                            </Card>
                        )
                    })
                ) : (
                    <Center h='90%' textAlign='center'>
                        <VStack>
                            <Text fontWeight='medium' fontSize={'xl'}>
                                {t('no-articles-selected-yet')}
                            </Text>
                            <Button
                                data-testid='search-another-topic-button'
                                leftIcon={<SearchIcon />}
                                onClick={handleNavigate}
                            >
                                {t('search-articles')}
                            </Button>
                        </VStack>
                    </Center>
                )}
            </DrawerBody>
            <DrawerFooter justifyContent='center' borderTopWidth='thin' zIndex='2'>
                <Button onClick={onClose}>{t('cancel')}</Button>
            </DrawerFooter>
        </CustomDrawer>
    )
}
