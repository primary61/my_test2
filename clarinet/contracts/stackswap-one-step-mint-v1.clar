(use-trait sip-010-token .trait-sip-010.sip-010-trait)
(use-trait liquidity-token .trait-liquidity-token.liquidity-token-trait)
(use-trait initable-sip010 .initializable-token-trait.initializable-sip010-token-trait)
(use-trait initable-poxl .initializable-token-trait.initializable-poxl-token-trait)
(use-trait initable-liquidity .initializable-token-trait.initializable-liquidity-token-trait)
(use-trait stackswap-swap .trait-stackswap-swap.stackswap-swap)

(define-constant ERR_INVALID_ROUTER (err u4001))
(define-constant ERR_DAO_ACCESS (err u4003))
(define-constant ERR_LP_TOKEN_NOT_VALID (err u4004))
(define-constant ERR_NO_SOFT_TOKEN (err u4005))
(define-constant ERR_NO_POXL_TOKEN (err u4006))
(define-constant ERR_NO_LP_TOKEN (err u4007))
(define-constant ERR_CALLER_MISMATCH (err u4008))

(define-data-var soft-token-list (list 200 principal) (list))
(define-data-var poxl-token-list (list 200 principal) (list))
(define-data-var liquidity-token-list (list 200 principal) (list))

(define-data-var rem-item principal tx-sender)

(define-read-only (get-soft-token-list)
  (ok (var-get soft-token-list)))

(define-read-only (get-poxl-token-list)
  (ok (var-get poxl-token-list)))

(define-read-only (get-liquidity-token-list)
  (ok (var-get liquidity-token-list)))

(define-private (remove-filter (a principal)) (not (is-eq a (var-get rem-item))))


(define-public (remove-soft-token (ritem principal))
  (begin
    (try! (is-valid-caller contract-caller))
    (try! (remove-soft-token-inner ritem))
    (ok true)
  )
)

(define-public (remove-poxl-token (ritem principal))
  (begin
    (try! (is-valid-caller contract-caller))
    (try! (remove-poxl-token-inner ritem))
    (ok true)
  )
)

(define-public (remove-liquidity-token (ritem principal))
  (begin
    (try! (is-valid-caller contract-caller))
    (try! (remove-liquidity-token-inner ritem))
    (ok true)
  )
)


(define-private (remove-soft-token-inner (ritem principal))
  (begin
    (var-set rem-item ritem)
    (unwrap! (index-of (var-get soft-token-list) ritem)  ERR_NO_SOFT_TOKEN)
    (var-set soft-token-list (unwrap-panic (as-max-len? (filter remove-filter (var-get soft-token-list)) u200)))
    (ok true)
  )
)

(define-private (remove-poxl-token-inner (ritem principal))
  (begin
    (var-set rem-item ritem)
    (unwrap! (index-of (var-get poxl-token-list) ritem)  ERR_NO_POXL_TOKEN)
    (var-set poxl-token-list (unwrap-panic (as-max-len? (filter remove-filter (var-get poxl-token-list)) u200)))
    (ok true)
  )
)
(define-private (remove-liquidity-token-inner (ritem principal))
  (begin
    (var-set rem-item ritem)
    (unwrap! (index-of (var-get liquidity-token-list) ritem)  ERR_NO_LP_TOKEN)
    (var-set liquidity-token-list (unwrap-panic (as-max-len? (filter remove-filter (var-get liquidity-token-list)) u200)))
    (ok true)
  )
)


(define-public (add-soft-token (new-token principal))
  (begin
    (try! (is-valid-caller contract-caller))
    (ok (var-set soft-token-list (unwrap-panic (as-max-len? (append (var-get soft-token-list) new-token) u200))))))

(define-public (add-poxl-token (new-token principal))
  (begin
    (try! (is-valid-caller contract-caller))
    (ok (var-set poxl-token-list (unwrap-panic (as-max-len? (append (var-get poxl-token-list) new-token) u200))))))

(define-public (add-liquidity-token (new-token principal))
  (begin
    (try! (is-valid-caller contract-caller))
    (ok (var-set liquidity-token-list (unwrap-panic (as-max-len? (append (var-get liquidity-token-list) new-token) u200))))))
    

(define-public (add-soft-tokens (new-tokens (list 100 principal)))
  (begin
    (try! (is-valid-caller contract-caller))
    (ok (var-set soft-token-list (unwrap-panic (as-max-len? (concat (var-get soft-token-list) new-tokens) u200))))))

(define-public (add-poxl-tokens (new-tokens (list 100 principal)))
  (begin
    (try! (is-valid-caller contract-caller))
    (ok (var-set poxl-token-list (unwrap-panic (as-max-len? (concat (var-get poxl-token-list) new-tokens) u200))))))

(define-public (add-liquidity-tokens (new-tokens (list 100 principal)))
  (begin
    (try! (is-valid-caller contract-caller))
    (ok (var-set liquidity-token-list (unwrap-panic (as-max-len? (concat (var-get liquidity-token-list) new-tokens) u200))))))

(define-public (create-pair-new-sip10-token-with-stx (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint) (token-y-init-trait <initable-sip010>) (token-liquidity-soft <initable-liquidity>)  (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256)) (website-to-set (string-utf8 256))  (initial-amount uint) (swap-contract <stackswap-swap>))
  (begin
    (asserts! (is-eq (contract-of token-liquidity-trait) (contract-of token-liquidity-soft)) ERR_LP_TOKEN_NOT_VALID)
    (asserts! (contract-call? .stackswap-security-list is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)
    (try! (contract-call? token-y-init-trait initialize name-to-set symbol-to-set decimals-to-set uri-to-set website-to-set tx-sender initial-amount))
    (try! (create-pair-new-liquidity-token .wstx-token token-y-trait token-liquidity-trait pair-name x y token-liquidity-soft swap-contract))
    (try! (remove-soft-token-inner (contract-of token-y-trait)))
    (ok true)
  )
)

(define-public (create-pair-new-poxl-token-with-stx (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint) (token-y-init-trait <initable-poxl>) (token-liquidity-soft <initable-liquidity>)  (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256)) (website-to-set (string-utf8 256))  (initial-amount uint)  (first-stacking-block-to-set uint) (reward-cycle-lengh-to-set uint) (token-reward-maturity-to-set uint) (coinbase-reward-to-set uint) (swap-contract <stackswap-swap>) )
  (begin
    (asserts! (is-eq (contract-of token-liquidity-trait) (contract-of token-liquidity-soft)) ERR_LP_TOKEN_NOT_VALID)
    (asserts! (contract-call? .stackswap-security-list is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)
    (try! (contract-call? token-y-init-trait initialize name-to-set symbol-to-set decimals-to-set uri-to-set website-to-set initial-amount first-stacking-block-to-set reward-cycle-lengh-to-set token-reward-maturity-to-set coinbase-reward-to-set))
    (try! (create-pair-new-liquidity-token .wstx-token token-y-trait token-liquidity-trait pair-name x y token-liquidity-soft swap-contract))
    (try! (remove-poxl-token-inner (contract-of token-y-trait)))
    (ok true)
  )
)

(define-public (create-pair-new-sip10-token-with-stsw (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint) (token-y-init-trait <initable-sip010>) (token-liquidity-soft <initable-liquidity>)  (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256)) (website-to-set (string-utf8 256))  (initial-amount uint) (swap-contract <stackswap-swap>))
  (begin
    (asserts! (is-eq (contract-of token-liquidity-trait) (contract-of token-liquidity-soft)) ERR_LP_TOKEN_NOT_VALID)
    (asserts! (contract-call? .stackswap-security-list is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)
    (try! (contract-call? token-y-init-trait initialize name-to-set symbol-to-set decimals-to-set uri-to-set website-to-set tx-sender initial-amount))
    (try! (create-pair-new-liquidity-token .stsw-token token-y-trait token-liquidity-trait pair-name x y token-liquidity-soft swap-contract))
    (try! (remove-soft-token-inner (contract-of token-y-trait)))
    (ok true)
  )
)

(define-public (create-pair-new-poxl-token-with-stsw (token-y-trait <sip-010-token>) (token-liquidity-trait <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint) (token-y-init-trait <initable-poxl>) (token-liquidity-soft <initable-liquidity>)  (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256)) (website-to-set (string-utf8 256))  (initial-amount uint)  (first-stacking-block-to-set uint) (reward-cycle-lengh-to-set uint) (token-reward-maturity-to-set uint) (coinbase-reward-to-set uint) (swap-contract <stackswap-swap>) )
  (begin
    (asserts! (is-eq (contract-of token-liquidity-trait) (contract-of token-liquidity-soft)) ERR_LP_TOKEN_NOT_VALID)
    (asserts! (contract-call? .stackswap-security-list is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)
    (try! (contract-call? token-y-init-trait initialize name-to-set symbol-to-set decimals-to-set uri-to-set website-to-set initial-amount first-stacking-block-to-set reward-cycle-lengh-to-set token-reward-maturity-to-set coinbase-reward-to-set))
    (try! (create-pair-new-liquidity-token .stsw-token token-y-trait token-liquidity-trait pair-name x y token-liquidity-soft swap-contract))
    (try! (remove-poxl-token-inner (contract-of token-y-trait)))
    (ok true)
  )
)

(define-public (create-pair-new-liquidity-token (token-x-trait <sip-010-token>) (token-y-trait <sip-010-token>)  (token-liquidity <liquidity-token>) (pair-name (string-ascii 32)) (x uint) (y uint) (token-liquidity-soft <initable-liquidity>) (swap-contract <stackswap-swap>) )
  (begin
    (asserts! (contract-call? .stackswap-security-list is-secure-router-or-user contract-caller) ERR_INVALID_ROUTER)
    (try! (contract-call? token-liquidity-soft initialize pair-name pair-name u6 u""))
    (asserts! (is-eq (contract-of swap-contract) (unwrap-panic (contract-call? .stackswap-dao get-qualified-name-by-name "swap"))) ERR_DAO_ACCESS)
    (try! (contract-call? swap-contract create-pair token-x-trait token-y-trait token-liquidity pair-name x y))
    (try! (remove-liquidity-token-inner (contract-of token-liquidity)))
    (ok true)
  )
)

(define-private (is-valid-caller (caller principal))
  (begin
    (asserts! (is-eq caller (unwrap-panic (contract-call? .stackswap-dao get-qualified-name-by-name "lp-deployer"))) ERR_DAO_ACCESS)
    (ok true)
  )
)
