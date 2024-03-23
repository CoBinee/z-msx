; Back.inc : 背景
;


; マクロの定義
;

; 背景
BACK_STATE                      =   0x00
BACK_FLAG                       =   0x01
BACK_LENGTH                     =   0x02

; 状態
BACK_STATE_NULL                 =   0x00

; フラグ
BACK_FLAG_NULL                  =   0x00
BACK_FLAG_PATTERN_NAME_BIT      =   0x00
BACK_FLAG_PATTERN_NAME          =   (1 << BACK_FLAG_PATTERN_NAME_BIT)

; ヒット判定
BACK_HIT_NULL                   =   0x00
BACK_HIT_LAND                   =   0x01
BACK_HIT_MISS                   =   0x80

; 外部関数宣言
;

    .globl  _BackInitialize
    .globl  _BackUpdate
    .globl  _BackRender
    .globl  _BackIsHit

; 外部変数宣言
;

    .globl  _back
