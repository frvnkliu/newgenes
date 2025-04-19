import Image from 'next/image'
import { cn } from '@/lib/utils'

export const Logo = ({ className }: { className?: string }) => {
    return (
        <Image
            src="/logo2.png"
            alt="Logo"
            width={156}
            height={36}
            className={cn('h-10 w-auto brightness-0 dark:invert', className)}
        />
    )
}

export const LogoIcon = ({ className }: { className?: string }) => {
    return (
        <Image
            src="/logo2.png"
            alt="Logo Icon"
            width={36}
            height={36}
            className={cn('size-10 brightness-0 dark:invert', className)}
        />
    )
}

export const LogoStroke = ({ className }: { className?: string }) => {
    return (
        <Image
            src="/logo2.png"
            alt="Logo Stroke"
            width={142}
            height={50}
            className={cn('size-14 w-14 brightness-0 dark:invert', className)}
        />
    )
}
