import { Button, HStack, Text } from '@chakra-ui/react'

/**
 * CartDisplayer is a custom React component for displaying cart contents
 * @returns {JSX.Element}
 */

export const CartDisplayer = (): JSX.Element => {
    return (
        <Button>
            <HStack>
                <Text>Show selected articles</Text>
            </HStack>
        </Button>
    )
}
