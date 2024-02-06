import { Button, Card, CardBody, useDisclosure } from '@chakra-ui/react'
import { type FC } from 'react'
import { ArticleSelector } from '.'
/**
 * ArticleDisplayer is a custom React component for managing article comparison
 * @returns {JSX.Element}
 */
export const ArticleDisplayer: FC = () => {
    const { isOpen, onOpen, onClose } = useDisclosure()
    return (
        <Card>
            <CardBody>
                <Button onClick={onOpen} />
                <ArticleSelector isOpen={isOpen} onClose={onClose} />
            </CardBody>
        </Card>
    )
}
