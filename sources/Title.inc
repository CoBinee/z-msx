; Title.inc : タイトル
;


; マクロの定義
;

; 状態
TITLE_STATE_NULL                =   0x00
TITLE_STATE_LOOP                =   0x10
TITLE_STATE_START               =   0x20

; スプライト
TITLE_SPRITE_NULL               =   0x00
TITLE_SPRITE_LOGO               =   0x00

; フレーム
TITLE_FRAME_NULL                =   0x00

; 外部関数宣言
;

    .globl  _TitleInitialize
    .globl  _TitleUpdate

; 外部変数宣言
;

