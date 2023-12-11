import type { FC } from 'react'
import { Divider, Heading, List, ListItem, Flex, Link as ChakraLink } from '@chakra-ui/react'
import { NavLink } from 'react-router-dom'
import { useTranslation } from 'react-i18next'

export const SideBar: FC = () => {
    const { t } = useTranslation()

    return (
        <Flex direction={'column'} p={5}>
            <Heading as='h2'>{t('menu')}</Heading>
            <Divider mt={'3rem'} mb={'3rem'} />
            <List fontSize='1.2em' spacing={4}>
                <ListItem>
                    <ChakraLink as={NavLink} to='/'>
                        {t('search-articles')}
                    </ChakraLink>
                </ListItem>
            </List>
        </Flex>
    )
}
