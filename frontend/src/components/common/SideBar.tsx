import type { FC } from 'react'
import { Divider, Heading, List, ListItem, Flex } from '@chakra-ui/react'
import { NavLink } from 'react-router-dom'

export const SideBar: FC = () => {
    return (
        <Flex direction={'column'} p={5}>
            <Heading as='h2'>Menú</Heading>
            <Divider mt={'3rem'} mb={'3rem'} />
            <List fontSize='1.2em' spacing={4}>
                <ListItem>
                    <NavLink to='/'>Buscar artículos</NavLink>
                </ListItem>
            </List>
        </Flex>
    )
}
