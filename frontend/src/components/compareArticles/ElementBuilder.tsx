import { Text } from '@chakra-ui/react'
import { type FC } from 'react'
/**
 * Props for ComponentBuilder
 */
export interface ComponentBuilderProps {
    /**
     * The component object
     */
    component: Record<string, string>
}
export const ComponentBuilder: FC<ComponentBuilderProps> = ({ component }) => {
    return <Text>{Object.entries(component).at(0)}</Text>
}
