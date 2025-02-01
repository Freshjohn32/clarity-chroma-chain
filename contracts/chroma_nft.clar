;; ChromaChain NFT Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-invalid-token (err u102))
(define-constant err-listing-not-found (err u103))
(define-constant err-batch-limit (err u104))

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

(define-private (mint-single 
                (name (string-utf8 256))
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

;; Public Functions
(define-public (mint (name (string-utf8 256)) 
                (description (string-utf8 1024))
                (image-uri (string-utf8 256))
                (attributes (list 10 {trait: (string-utf8 64), value: (string-utf8 64)})))
    (mint-single name description image-uri attributes)
)

(define-public (batch-mint 
                (count uint)
                (base-name (string-utf8 256))
                (description (string-utf8 1024))
                (base-uri (string-utf8 256))
                (attributes (list 10 {trait: (string-utf8 64), value: (string-utf8 64)})))
    (begin
        (asserts! (<= count (var-get max-batch-size)) err-batch-limit)
        (let ((initial-id (var-get last-token-id)))
            (fold mint-batch-item (list count) (ok initial-id))
        )
    )
)

(define-private (mint-batch-item (index uint) (prior-result (response uint uint)))
    (let ((prior-id (unwrap! prior-result prior-result)))
        (mint-single 
            (concat (concat base-name "#") (to-string (+ index u1)))
            description
            (concat base-uri (to-string (+ index u1)))
            attributes
        )
    )
)

(define-public (batch-list (token-ids (list 50 uint)) (price uint))
    (fold list-batch-item token-ids (ok true))
)

(define-private (list-batch-item (token-id uint) (prior-result (response bool uint)))
    (begin
        (try! prior-result)
        (let ((token-owner (unwrap! (nft-get-owner? chroma-nft token-id) err-invalid-token)))
            (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
            (ok (map-set token-listings token-id {
                price: price,
                seller: tx-sender
            }))
        )
    )
)

;; Existing functions remain unchanged...
[rest of original contract functions]
