;; CraftLore - Digital Crafting Community Platform
;; A blockchain-based platform for craft tutorials, project logs,
;; and artisan community rewards

;; Contract constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))

;; Token constants
(define-constant token-name "CraftLore Maker Token")
(define-constant token-symbol "CMT")
(define-constant token-decimals u6)
(define-constant token-max-supply u45000000000) ;; 45k tokens with 6 decimals

;; Reward amounts (in micro-tokens)
(define-constant reward-project u2600000) ;; 2.6 CMT
(define-constant reward-tutorial u3200000) ;; 3.2 CMT
(define-constant reward-milestone u7900000) ;; 7.9 CMT

;; Data variables
(define-data-var total-supply uint u0)
(define-data-var next-tutorial-id uint u1)
(define-data-var next-project-id uint u1)

;; Token balances
(define-map token-balances principal uint)

;; Artisan profiles
(define-map artisan-profiles
  principal
  {
    username: (string-ascii 24),
    craft-type: (string-ascii 12), ;; "woodwork", "pottery", "textiles", "jewelry", "leather"
    projects-made: uint,
    tutorials-shared: uint,
    mastery-level: uint, ;; 1-5
    total-hours: uint,
    join-date: uint
  }
)

;; Craft tutorials
(define-map craft-tutorials
  uint
  {
    tutorial-title: (string-ascii 10),
    craft-category: (string-ascii 12),
    difficulty: (string-ascii 6), ;; "easy", "medium", "hard"
    time-needed: uint, ;; hours
    materials-cost: uint, ;; dollars
    tools-required: (string-ascii 8),
    creator: principal,
    project-count: uint,
    success-rate: uint ;; percentage * 10
  }
)

;; Project logs
(define-map project-logs
  uint
  {
    tutorial-id: uint,
    artisan: principal,
    project-name: (string-ascii 10),
    time-spent: uint, ;; hours
    material-cost: uint, ;; dollars
    difficulty-faced: uint, ;; 1-5
    satisfaction: uint, ;; 1-5
    skill-gained: uint, ;; 1-5
    project-notes: (string-ascii 20),
    project-date: uint,
    completed: bool
  }
)

;; Tutorial reviews
(define-map tutorial-reviews
  { tutorial-id: uint, reviewer: principal }
  {
    rating: uint, ;; 1-10
    review-text: (string-ascii 20),
    clarity: (string-ascii 5), ;; "clear", "okay", "vague"
    review-date: uint,
    handy-votes: uint
  }
)

;; Artisan milestones
(define-map artisan-milestones
  { artisan: principal, milestone: (string-ascii 12) }
  {
    achievement-date: uint,
    project-count: uint
  }
)

;; Helper function to get or create profile
(define-private (get-or-create-profile (artisan principal))
  (match (map-get? artisan-profiles artisan)
    profile profile
    {
      username: "",
      craft-type: "woodwork",
      projects-made: u0,
      tutorials-shared: u0,
      mastery-level: u1,
      total-hours: u0,
      join-date: stacks-block-height
    }
  )
)

;; Token functions
(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (user principal))
  (ok (default-to u0 (map-get? token-balances user)))
)

(define-private (mint-tokens (recipient principal) (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? token-balances recipient)))
    (new-balance (+ current-balance amount))
    (new-total-supply (+ (var-get total-supply) amount))
  )
    (asserts! (<= new-total-supply token-max-supply) err-invalid-input)
    (map-set token-balances recipient new-balance)
    (var-set total-supply new-total-supply)
    (ok amount)
  )
)

;; Create craft tutorial
(define-public (create-craft-tutorial (tutorial-title (string-ascii 10)) (craft-category (string-ascii 12)) (difficulty (string-ascii 6)) (time-needed uint) (materials-cost uint) (tools-required (string-ascii 8)))
  (let (
    (tutorial-id (var-get next-tutorial-id))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len tutorial-title) u0) err-invalid-input)
    (asserts! (> time-needed u0) err-invalid-input)
    (asserts! (>= materials-cost u0) err-invalid-input)
    
    (map-set craft-tutorials tutorial-id {
      tutorial-title: tutorial-title,
      craft-category: craft-category,
      difficulty: difficulty,
      time-needed: time-needed,
      materials-cost: materials-cost,
      tools-required: tools-required,
      creator: tx-sender,
      project-count: u0,
      success-rate: u0
    })
    
    ;; Update profile
    (map-set artisan-profiles tx-sender
      (merge profile {tutorials-shared: (+ (get tutorials-shared profile) u1)})
    )
    
    ;; Award tutorial creation tokens
    (try! (mint-tokens tx-sender reward-tutorial))
    
    (var-set next-tutorial-id (+ tutorial-id u1))
    (print {action: "craft-tutorial-created", tutorial-id: tutorial-id, creator: tx-sender})
    (ok tutorial-id)
  )
)

;; Log project work
(define-public (log-project (tutorial-id uint) (project-name (string-ascii 10)) (time-spent uint) (material-cost uint) (difficulty-faced uint) (satisfaction uint) (skill-gained uint) (project-notes (string-ascii 20)) (completed bool))
  (let (
    (project-id (var-get next-project-id))
    (tutorial (unwrap! (map-get? craft-tutorials tutorial-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len project-name) u0) err-invalid-input)
    (asserts! (> time-spent u0) err-invalid-input)
    (asserts! (and (>= difficulty-faced u1) (<= difficulty-faced u5)) err-invalid-input)
    (asserts! (and (>= satisfaction u1) (<= satisfaction u5)) err-invalid-input)
    (asserts! (and (>= skill-gained u1) (<= skill-gained u5)) err-invalid-input)
    
    (map-set project-logs project-id {
      tutorial-id: tutorial-id,
      artisan: tx-sender,
      project-name: project-name,
      time-spent: time-spent,
      material-cost: material-cost,
      difficulty-faced: difficulty-faced,
      satisfaction: satisfaction,
      skill-gained: skill-gained,
      project-notes: project-notes,
      project-date: stacks-block-height,
      completed: completed
    })
    
    ;; Update tutorial stats if completed
    (if completed
      (let (
        (new-project-count (+ (get project-count tutorial) u1))
        (current-success (* (get success-rate tutorial) (get project-count tutorial)))
        (new-success-rate (/ (+ current-success u1000) new-project-count))
      )
        (map-set craft-tutorials tutorial-id
          (merge tutorial {
            project-count: new-project-count,
            success-rate: new-success-rate
          })
        )
        true
      )
      true
    )
    
    ;; Update profile
    (if completed
      (begin
        (map-set artisan-profiles tx-sender
          (merge profile {
            projects-made: (+ (get projects-made profile) u1),
            total-hours: (+ (get total-hours profile) time-spent),
            mastery-level: (+ (get mastery-level profile) (/ skill-gained u12))
          })
        )
        (try! (mint-tokens tx-sender reward-project))
        true
      )
      (begin
        (try! (mint-tokens tx-sender (/ reward-project u4)))
        true
      )
    )
    
    (var-set next-project-id (+ project-id u1))
    (print {action: "project-logged", project-id: project-id, tutorial-id: tutorial-id})
    (ok project-id)
  )
)

;; Write tutorial review
(define-public (write-review (tutorial-id uint) (rating uint) (review-text (string-ascii 20)) (clarity (string-ascii 5)))
  (let (
    (tutorial (unwrap! (map-get? craft-tutorials tutorial-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (and (>= rating u1) (<= rating u10)) err-invalid-input)
    (asserts! (> (len review-text) u0) err-invalid-input)
    (asserts! (is-none (map-get? tutorial-reviews {tutorial-id: tutorial-id, reviewer: tx-sender})) err-already-exists)
    
    (map-set tutorial-reviews {tutorial-id: tutorial-id, reviewer: tx-sender} {
      rating: rating,
      review-text: review-text,
      clarity: clarity,
      review-date: stacks-block-height,
      handy-votes: u0
    })
    
    (print {action: "review-written", tutorial-id: tutorial-id, reviewer: tx-sender})
    (ok true)
  )
)

;; Vote review handy
(define-public (vote-handy (tutorial-id uint) (reviewer principal))
  (let (
    (review (unwrap! (map-get? tutorial-reviews {tutorial-id: tutorial-id, reviewer: reviewer}) err-not-found))
  )
    (asserts! (not (is-eq tx-sender reviewer)) err-unauthorized)
    
    (map-set tutorial-reviews {tutorial-id: tutorial-id, reviewer: reviewer}
      (merge review {handy-votes: (+ (get handy-votes review) u1)})
    )
    
    (print {action: "review-voted-handy", tutorial-id: tutorial-id, reviewer: reviewer})
    (ok true)
  )
)

;; Update craft type
(define-public (update-craft-type (new-craft-type (string-ascii 12)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-craft-type) u0) err-invalid-input)
    
    (map-set artisan-profiles tx-sender (merge profile {craft-type: new-craft-type}))
    
    (print {action: "craft-type-updated", artisan: tx-sender, type: new-craft-type})
    (ok true)
  )
)

;; Claim milestone
(define-public (claim-milestone (milestone (string-ascii 12)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (is-none (map-get? artisan-milestones {artisan: tx-sender, milestone: milestone})) err-already-exists)
    
    ;; Check milestone requirements
    (let (
      (milestone-met
        (if (is-eq milestone "maker-110") (>= (get projects-made profile) u110)
        (if (is-eq milestone "teacher-21") (>= (get tutorials-shared profile) u21)
        false)))
    )
      (asserts! milestone-met err-unauthorized)
      
      ;; Record milestone
      (map-set artisan-milestones {artisan: tx-sender, milestone: milestone} {
        achievement-date: stacks-block-height,
        project-count: (get projects-made profile)
      })
      
      ;; Award milestone tokens
      (try! (mint-tokens tx-sender reward-milestone))
      
      (print {action: "milestone-claimed", artisan: tx-sender, milestone: milestone})
      (ok true)
    )
  )
)

;; Update username
(define-public (update-username (new-username (string-ascii 24)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-username) u0) err-invalid-input)
    (map-set artisan-profiles tx-sender (merge profile {username: new-username}))
    (print {action: "username-updated", artisan: tx-sender})
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-artisan-profile (artisan principal))
  (map-get? artisan-profiles artisan)
)

(define-read-only (get-craft-tutorial (tutorial-id uint))
  (map-get? craft-tutorials tutorial-id)
)

(define-read-only (get-project-log (project-id uint))
  (map-get? project-logs project-id)
)

(define-read-only (get-tutorial-review (tutorial-id uint) (reviewer principal))
  (map-get? tutorial-reviews {tutorial-id: tutorial-id, reviewer: reviewer})
)

(define-read-only (get-milestone (artisan principal) (milestone (string-ascii 12)))
  (map-get? artisan-milestones {artisan: artisan, milestone: milestone})
)