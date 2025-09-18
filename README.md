# CraftLore - Digital Crafting Community Platform

A blockchain-based platform built on Stacks that connects artisans and craft enthusiasts through tutorial sharing, project logging, and community-driven skill development, rewarding creative contributions with tokenized incentives.

## Overview

CraftLore transforms traditional crafting into a collaborative digital ecosystem where:
- **Artisans share tutorials** with detailed instructions and material specifications
- **Craft projects are documented** with time, cost, and skill progression tracking
- **Community reviews** help identify the most effective tutorials
- **Skills develop** through tracked project completion and mastery levels
- **Crafting knowledge** is preserved and shared across generations

## Key Features

### Artisan Profiles
- Customizable usernames and craft specializations
- Mastery level progression (1-5) based on project completion and skill gained
- Track projects completed, tutorials shared, and total crafting hours
- Support for major craft types: Woodwork, Pottery, Textiles, Jewelry, Leather

### Comprehensive Tutorial System
- Detailed tutorial creation with difficulty classifications
- Time requirements and material cost estimates
- Tool specifications for project preparation
- Success rate tracking based on community project completions
- Category-based organization for easy discovery

### Project Logging System
- Detailed project documentation with time and cost tracking
- Difficulty assessment and satisfaction ratings
- Skill development measurement (1-5 scale)
- Personal project notes for future reference
- Completion status tracking with partial rewards for attempts

### Community Review System
- 10-point rating system for tutorial effectiveness
- Clarity assessments (clear/okay/vague)
- Handy voting system for highlighting useful reviews
- Anti-spam protection (one review per tutorial per artisan)

### Achievement System
- **maker-110**: Master Craftsperson (110+ projects completed)
- **teacher-21**: Tutorial Master (21+ tutorials shared)
- Milestone rewards: 7.9 CMT tokens per achievement

## CraftLore Maker Token (CMT)

### Token Economics
- **Symbol**: CMT
- **Decimals**: 6
- **Max Supply**: 45,000 CMT
- **Distribution**: Merit-based rewards for crafting contributions

### Reward Structure
- **Completed Project**: 2.6 CMT tokens
- **Tutorial Creation**: 3.2 CMT tokens
- **Milestone Achievement**: 7.9 CMT tokens
- **Partial Project**: 0.65 CMT tokens (encouragement for learning attempts)

## Technical Architecture

### Smart Contract Functions

#### Public Functions
- `create-craft-tutorial`: Share new crafting tutorials with detailed specifications
- `log-project`: Record project work with time, cost, and skill tracking
- `write-review`: Provide feedback on tutorial effectiveness
- `vote-handy`: Highlight helpful reviews for community benefit
- `update-craft-type`: Change crafting specialization
- `claim-milestone`: Unlock achievement rewards
- `update-username`: Personalize artisan identity

#### Read-Only Functions
- `get-artisan-profile`: Retrieve artisan statistics and specializations
- `get-craft-tutorial`: Access tutorial details and success rates
- `get-project-log`: View project completion records
- `get-tutorial-review`: Read community tutorial feedback
- `get-milestone`: Check achievement status

### Data Structures

#### Artisan Profile
```clarity
{
  username: (string-ascii 24),
  craft-type: (string-ascii 12),
  projects-made: uint,
  tutorials-shared: uint,
  mastery-level: uint,
  total-hours: uint,
  join-date: uint
}
```

#### Craft Tutorial
```clarity
{
  tutorial-title: (string-ascii 10),
  craft-category: (string-ascii 12),
  difficulty: (string-ascii 6),
  time-needed: uint,
  materials-cost: uint,
  tools-required: (string-ascii 8),
  creator: principal,
  project-count: uint,
  success-rate: uint
}
```

#### Project Log
```clarity
{
  tutorial-id: uint,
  artisan: principal,
  project-name: (string-ascii 10),
  time-spent: uint,
  material-cost: uint,
  difficulty-faced: uint,
  satisfaction: uint,
  skill-gained: uint,
  project-notes: (string-ascii 20),
  completed: bool
}
```

## Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) development environment
- Stacks wallet for blockchain interactions
- Basic understanding of crafting terminology

### Installation
```bash
# Clone the repository
git clone https://github.com/your-org/craftlore-platform
cd craftlore-platform

# Install dependencies
clarinet install

# Run tests
clarinet test

# Deploy to testnet
clarinet deploy --testnet
```

### Usage Examples

#### Create a Craft Tutorial
```clarity
(contract-call? .craftlore create-craft-tutorial 
  "Wood Bowl" 
  "woodwork" 
  "medium" 
  u8 
  u25 
  "lathe")
```

#### Log a Project
```clarity
(contract-call? .craftlore log-project
  u1
  "Oak Bowl"
  u10
  u30
  u3
  u5
  u4
  "Great learning experience"
  true)
```

#### Write a Tutorial Review
```clarity
(contract-call? .craftlore write-review
  u1
  u9
  "Excellent instructions"
  "clear")
```

#### Claim an Achievement
```clarity
(contract-call? .craftlore claim-milestone "maker-110")
```

## Platform Features

### Tutorial Quality Assurance
- Success rate calculation based on completed projects
- Community review system with clarity assessments
- Handy voting to surface the most useful feedback
- Project count tracking to validate tutorial effectiveness

### Skill Development Tracking
- Dynamic mastery level calculation based on skill gained per project
- Total hours tracking for crafting dedication measurement
- Difficulty progression from easy through hard tutorials
- Personal satisfaction ratings for project enjoyment

### Cost and Time Management
- Material cost tracking for budget planning
- Time estimation accuracy through actual vs. estimated comparisons
- Tool requirement specifications for proper preparation
- Project planning support through detailed tutorial information

### Community Learning
- Shared project notes for tips and modifications
- Tutorial creator recognition through project completion counts
- Review system for tutorial improvement feedback
- Knowledge preservation through blockchain storage

## Security Features

- **Input validation** on all user-provided data
- **Duplicate prevention** for reviews per tutorial per artisan
- **Rating bounds checking** for all assessment scales
- **Supply cap protection** for token minting
- **Authorization verification** for profile updates

## Use Cases

### For Craft Beginners
- Discover tutorials appropriate for skill level
- Track learning progress through project completion
- Receive guidance through community reviews and ratings
- Build confidence with partial rewards for attempts

### For Experienced Artisans
- Share expertise through detailed tutorial creation
- Build reputation in the crafting community
- Earn rewards for knowledge contribution
- Connect with other artisans in specialized crafts

### for Craft Educators
- Document teaching materials with success metrics
- Track student progress through project logs
- Access community-validated tutorials for curriculum
- Build professional credibility through tutorial reviews

### For Craft Businesses
- Showcase techniques and build brand recognition
- Gather feedback on tutorial effectiveness
- Access market insights through project cost and time data
- Connect with potential customers through quality tutorials

## Future Enhancements

- **Craft Marketplace**: Token-based trading of handmade items
- **Video Tutorial Integration**: Multimedia instruction support
- **Live Workshop Coordination**: Real-time crafting sessions
- **Material Supplier Directory**: Sourcing support for projects
- **Craft Competition System**: Community challenges and judging

## Contributing

We welcome contributions from the crafting community! Areas for contribution include:
- **Smart Contract Development**: Additional features and optimizations
- **Frontend Development**: User interface improvements
- **Content Creation**: High-quality tutorials and project documentation
- **Community Moderation**: Quality assurance and platform culture

## Technical Considerations

### Gas Optimization
- Efficient storage patterns minimize transaction costs
- Simplified success rate calculations reduce computational overhead
- Profile lazy loading for cost-effective user onboarding

### Data Validation
- Comprehensive bounds checking for ratings and assessments
- Required field validation ensures tutorial completeness
- Cost and time validation prevents unrealistic entries

### Scalability
- Modular tutorial categories support craft expansion
- Extensible data structures for additional craft types
- Efficient mapping patterns for quick data retrieval

## Community Guidelines

### Quality Standards
- Accurate tutorial instructions with realistic time and cost estimates
- Honest project logs reflecting actual crafting experiences
- Constructive reviews that help improve tutorial quality
- Respectful interactions that encourage learning

### Platform Etiquette
- One review per tutorial to prevent spam
- Detailed project notes for community learning
- Recognition of different skill levels and learning styles
- Support for experimental and creative project variations

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Community

- **Discord**: Join crafting discussions and share project photos
- **Twitter**: Follow @CraftLoreDAO for platform updates
- **Blog**: Read about crafting innovations and featured projects

---

*CraftLore: Where traditional craftsmanship meets digital innovation, preserving skills for future generations while rewarding today's artisans.*
