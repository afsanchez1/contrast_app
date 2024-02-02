import { HamburgerIcon } from '@chakra-ui/icons'
import { DrawerBody, IconButton, useDisclosure } from '@chakra-ui/react'
import { CustomDrawer } from '.'
import { useTranslation } from 'react-i18next'

/**
 * SideBarDisplayer is a custom React component for displaying the application sidebar
 * @returns {JSX.Element}
 */
export const SideBarDisplayer = (): JSX.Element => {
    const { isOpen, onOpen, onClose } = useDisclosure()
    const { t } = useTranslation()

    return (
        <>
            <IconButton aria-label='sidebar-button' icon={<HamburgerIcon />} onClick={onOpen} />
            <CustomDrawer
                headerTitle={t('menu')}
                isOpen={isOpen}
                onClose={onClose}
                placement={'left'}
            >
                <DrawerBody>this is a sidebar</DrawerBody>
            </CustomDrawer>
        </>
    )
}
