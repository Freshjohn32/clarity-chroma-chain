;; ChromaChain NFT Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-invalid-token (err u102))
(define-constant err-listing-not-found (err u103))

;; Data Variables
(define-data-var last-token-id uint u0)
(define-data-var royalty-percent uint u5)

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

;; Public Functions
(define-public (mint (name (string-utf8 256)) 
                    (description (string-utf8 1024))
                    (image-uri (string-utf8 256))
                    (attributes (list 10 {trait: (string-utf8 64), value: (string-utf8 64)})))
    (let
        ((token-id (+ (var-get last-token-id) u1)))
        (try! (nft-mint? chroma-nft token-id tx-sender))
        (map-set token-metadata token-id {
            creator: tx-sender,
            name: name,
            description: description,
            image-uri: image-uri,
            attributes: attributes
        })
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-public (update-metadata (token-id uint)
                              (name (string-utf8 256))
                              (description (string-utf8 1024))
                              (image-uri (string-utf8 256))
                              (attributes (list 10 {trait: (string-utf8 64), value: (string-utf8 64)})))
    (let ((token-owner (unwrap! (nft-get-owner? chroma-nft token-id) err-invalid-token)))
        (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
        (ok (map-set token-metadata token-id {
            creator: (get creator (unwrap! (map-get? token-metadata token-id) err-invalid-token)),
            name: name,
            description: description,
            image-uri: image-uri,
            attributes: attributes
        }))
    )
)

(define-public (list-token (token-id uint) (price uint))
    (let ((token-owner (unwrap! (nft-get-owner? chroma-nft token-id) err-invalid-token)))
        (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
        (ok (map-set token-listings token-id {
            price: price,
            seller: tx-sender
        }))
    )
)

(define-public (purchase-token (token-id uint))
    (let (
        (listing (unwrap! (map-get? token-listings token-id) err-listing-not-found))
        (price (get price listing))
        (seller (get seller listing))
        (royalty (/ (* price (var-get royalty-percent)) u100))
        (seller-amount (- price royalty))
    )
        (try! (stx-transfer? price tx-sender seller))
        (try! (stx-transfer? royalty tx-sender (get creator (unwrap! (map-get? token-metadata token-id) err-invalid-token))))
        (try! (nft-transfer? chroma-nft token-id seller tx-sender))
        (map-delete token-listings token-id)
        (ok true)
    )
)

;; Read-only functions
(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id)
)

(define-read-only (get-listing (token-id uint))
    (map-get? token-listings token-id)
)

(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)