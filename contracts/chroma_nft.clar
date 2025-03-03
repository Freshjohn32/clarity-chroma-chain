;; ChromaChain NFT Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-invalid-token (err u102))
(define-constant err-listing-not-found (err u103))
(define-constant err-batch-limit (err u104))
(define-constant err-invalid-price (err u105))
(define-constant err-empty-attributes (err u106))
(define-constant err-duplicate-token-id (err u107))
(define-constant err-listing-exists (err u108))

;; Data Variables
(define-data-var last-token-id uint u0)
(define-data-var royalty-percent uint u5)
(define-data-var max-batch-size uint u50)

;; NFT Definition
(define-non-fungible-token chroma-nft uint)

;; Data Maps
(define-map token-metadata
    uint
    {
        creator: principal,
        name: (string-utf8 256),
        description: (string-utf8 1024),
        image-uri: (string-utf8 256),
        attributes: (list 10 {trait: (string-utf8 64), value: (string-utf8 64)})
    }
)

(define-map token-listings
    uint
    {
        price: uint,
        seller: principal
    }
)

;; Private Functions
(define-private (is-token-owner (token-id uint) (address principal))
    (is-eq (nft-get-owner? chroma-nft token-id) (ok address))
)

(define-private (check-duplicate-tokens (token-ids (list 50 uint)))
    (let ((sorted-ids (sort token-ids)))
        (fold check-adjacent-tokens (unwrap-panic (as-max-len? (append sorted-ids u0) u50)) true)
    )
)

(define-private (check-adjacent-tokens (id uint) (is-unique bool))
    (and is-unique (if (is-eq id u0) 
        true 
        (not (is-eq id (elem-at (unwrap-panic (as-max-len? sorted-ids u50)) (- (len sorted-ids) u1))))
    ))
)

;; Rest of the contract functions remain the same until batch-list

(define-public (batch-list (token-ids (list 50 uint)) (price uint))
    (begin
        (asserts! (> price u0) err-invalid-price)
        (asserts! (check-duplicate-tokens token-ids) err-duplicate-token-id)
        (fold list-batch-item token-ids (ok { price: price }))
    )
)

(define-private (list-batch-item (token-id uint) (prior-result (response { price: uint } uint)))
    (begin
        (try! prior-result)
        (let (
            (token-owner (unwrap! (nft-get-owner? chroma-nft token-id) err-invalid-token))
            (existing-listing (map-get? token-listings token-id))
        )
            (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
            (asserts! (is-none existing-listing) err-listing-exists)
            (ok (map-set token-listings token-id {
                price: (get price (unwrap-panic prior-result)),
                seller: tx-sender
            }))
        )
    )
)

(define-public (cancel-listing (token-id uint))
    (let ((listing (unwrap! (map-get? token-listings token-id) err-listing-not-found)))
        (asserts! (is-eq tx-sender (get seller listing)) err-not-token-owner)
        (ok (map-delete token-listings token-id))
    )
)
