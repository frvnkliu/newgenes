import ContentSection from '@/components/content-2';
import ContentSections from '@/components/content-3';
import FAQs from '@/components/faqs-2';
import FeaturesSection from '@/components/features-8';
import FooterSection from '@/components/footer';
import HeroSection from '@/components/hero-section';
import TestimonialsSection from '@/components/testimonials';

export default function HomePage() {
  return (
    <main>
      <HeroSection />
      <FeaturesSection />
      <ContentSection />
      <ContentSections />
      <TestimonialsSection /> 
      <FAQs />
      <FooterSection />
    </main>
  );
}