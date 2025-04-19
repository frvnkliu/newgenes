import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Card, CardContent } from '@/components/ui/card'

type Testimonial = {
    name: string
    role: string
    image: string
    quote: string
}

const testimonials: Testimonial[] = [
    {
        name: 'Sarah Johnson',
        role: 'Mother of two',
        image: 'https://randomuser.me/api/portraits/women/1.jpg',
        quote: 'After losing my first pregnancy to a rare genetic disorder, we were terrified of trying again. The comprehensive screening gave us the confidence to move forward, and now we have two beautiful, healthy children.',
    },
    {
        name: 'Michael Chen',
        role: 'Expectant Father',
        image: 'https://randomuser.me/api/portraits/men/90.jpg',
        quote: 'With Tay-Sachs running in my family, my wife and I were hesitant about having children. The genetic counselors walked us through everything and helped us understand our options. We are now expecting our first child.',
    },
    {
        name: 'Dr. Amara Patel',
        role: 'Obstetrician',
        image: 'https://randomuser.me/api/portraits/women/7.jpg',
        quote: 'The detailed reports have transformed how I practice. Being able to identify potential genetic concerns early allows me to connect patients with specialists before complications arise. It&apos;s preventive medicine at its finest.',
    },
    {
        name: 'Thomas & Emma Wilson',
        role: 'Parents',
        image: 'https://randomuser.me/api/portraits/men/8.jpg',
        quote: 'Our first child was diagnosed with cystic fibrosis at birth. For our second pregnancy, we chose to screen early. That advance knowledge allowed us to assemble a medical team before delivery and start treatments immediately. The difference in outcomes has been night and day.',
    },
    {
        name: 'Olivia Rodriguez',
        role: 'Genetic Counselor',
        image: 'https://randomuser.me/api/portraits/women/4.jpg',
        quote: 'What impresses me most is how the screening results are presented to patients. The reports strike a perfect balance - scientifically accurate but accessible to non-specialists. This dramatically improves the quality of conversations I can have with prospective parents.',
    },
    {
        name: 'James Anderson',
        role: 'Father',
        image: 'https://randomuser.me/api/portraits/men/2.jpg',
        quote: 'The screening revealed our baby had a treatable metabolic condition. Because we knew before birth, doctors started treatment on day one. Our son is now a thriving three-year-old with no developmental delays. Without early detection, the outcome could have been devastating.',
    },
    {
        name: 'Maria & Carlos Sanchez',
        role: 'Parents of twins',
        image: 'https://randomuser.me/api/portraits/women/5.jpg',
        quote: "After three failed IVF cycles, we discovered through genetic screening that certain embryo combinations were unlikely to thrive due to a recessive trait we both carried. This insight completely changed our approach and led to the healthy twins sleeping upstairs right now.",
    },
    {
        name: 'Dr. Robert Kim',
        role: 'Pediatric Specialist',
        image: 'https://randomuser.me/api/portraits/men/9.jpg',
        quote: 'I&apos;ve seen firsthand how early detection transforms outcomes for children with genetic conditions. When parents have time to prepare and we can start interventions at or before birth, we often achieve developmental milestones that would otherwise be missed.',
    },
    {
        name: 'Sophia Williams',
        role: 'Prenatal Nurse',
        image: 'https://randomuser.me/api/portraits/women/10.jpg',
        quote: "The most powerful moments in my career come when I see the relief on parents' faces when they understand what to expect and have a plan. Knowledge replaces fear, and that's invaluable during pregnancy.",
    },
    {
        name: 'David & Hannah Taylor',
        role: 'Parents',
        image: 'https://randomuser.me/api/portraits/men/11.jpg',
        quote: 'Both our families have histories of genetic heart conditions. The screening identified that our baby had a 50% chance of inheriting one of them. This allowed us to arrange for a pediatric cardiologist to be present at birth and start monitoring immediately.',
    },
    {
        name: 'Dr. Elizabeth Foster',
        role: 'Reproductive Endocrinologist',
        image: 'https://randomuser.me/api/portraits/women/12.jpg',
        quote: 'For my patients undergoing fertility treatments, genetic screening has become an essential step. The information helps us select the healthiest embryos and gives couples tremendous peace of mind during an already stressful process.',
    },
    {
        name: 'Marcus & Julia Bennett',
        role: 'Expecting Parents',
        image: 'https://randomuser.me/api/portraits/men/13.jpg',
        quote: 'We were hesitant to do genetic screening - worried it would just give us more to worry about. Instead, it&apos;s been incredibly reassuring. We discovered we&apos;re not carriers for any of the conditions we were concerned about, and can focus on enjoying this pregnancy.',
    },
]

const chunkArray = (array: Testimonial[], chunkSize: number): Testimonial[][] => {
    const result: Testimonial[][] = []
    for (let i = 0; i < array.length; i += chunkSize) {
        result.push(array.slice(i, i + chunkSize))
    }
    return result
}

const testimonialChunks = chunkArray(testimonials, Math.ceil(testimonials.length / 3))

export default function WallOfLoveSection() {
    return (
        <section>
            <div className="py-16 md:py-32">
                <div className="mx-auto max-w-6xl px-6">
                    <div className="text-center">
                        <h2 className="text-title text-3xl font-semibold">Loved by the Community</h2>
                        <p className="text-body mt-6">Harum quae dolore orrupti aut temporibus ariatur.</p>
                    </div>
                    <div className="mt-8 grid gap-3 sm:grid-cols-2 md:mt-12 lg:grid-cols-3">
                        {testimonialChunks.map((chunk, chunkIndex) => (
                            <div key={chunkIndex} className="space-y-3">
                                {chunk.map(({ name, role, quote, image }, index) => (
                                    <Card key={index}>
                                        <CardContent className="grid grid-cols-[auto_1fr] gap-3 pt-6">
                                            <Avatar className="size-9">
                                                <AvatarImage alt={name} src={image} loading="lazy" width="120" height="120" />
                                                <AvatarFallback>ST</AvatarFallback>
                                            </Avatar>

                                            <div>
                                                <h3 className="font-medium">{name}</h3>

                                                <span className="text-muted-foreground block text-sm tracking-wide">{role}</span>

                                                <blockquote className="mt-3">
                                                    <p className="text-gray-700 dark:text-gray-300">{quote}</p>
                                                </blockquote>
                                            </div>
                                        </CardContent>
                                    </Card>
                                ))}
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </section>
    )
}
