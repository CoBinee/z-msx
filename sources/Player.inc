; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_STATE                    =   0x00
PLAYER_FLAG                     =   0x01
PLAYER_POSITION_X_L             =   0x02
PLAYER_POSITION_X_H             =   0x03
PLAYER_POSITION_Y_L             =   0x04
PLAYER_POSITION_Y_H             =   0x05
PLAYER_SPEED_X_L                =   0x06
PLAYER_SPEED_X_H                =   0x07
PLAYER_SPEED_Y_L                =   0x08
PLAYER_SPEED_Y_H                =   0x09
PLAYER_ANIMATION                =   0x0a
PLAYER_LENGTH                   =   0x10

; 状態
PLAYER_STATE_NULL               =   0x00
PLAYER_STATE_PLAY               =   0x10
PLAYER_STATE_BOMB               =   0x20
PLAYER_STATE_ON                 =   0x30

; フラグ
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_ASCENT_BIT          =   0x00
PLAYER_FLAG_ASCENT              =   (1 << PLAYER_FLAG_ASCENT_BIT)
PLAYER_FLAG_MISS_BIT            =   0x01
PLAYER_FLAG_MISS                =   (1 << PLAYER_FLAG_MISS_BIT)
PLAYER_FLAG_LAND_BIT            =   0x02
PLAYER_FLAG_LAND                =   (1 << PLAYER_FLAG_LAND_BIT)
PLAYER_FLAG_BOMB_BIT            =   0x07
PLAYER_FLAG_BOMB                =   (1 << PLAYER_FLAG_BOMB_BIT)

; 位置
PLAYER_POSITION_NULL            =   0x0000
PLAYER_POSITION_LEFT            =   0x0700
PLAYER_POSITION_RIGHT           =   0xf800
PLAYER_POSITION_TOP             =   0x1000
PLAYER_POSITION_BOTTOM          =   0xb900

; 速度
PLAYER_SPEED_NULL               =   0x0000
PLAYER_SPEED_X_MAXIMUM          =   0x0200
PLAYER_SPEED_X_ACCEL            =   0x0004
PLAYER_SPEED_Y_MAXIMUM          =   0x0200
PLAYER_SPEED_Y_ASCENT           =   0x0004
PLAYER_SPEED_Y_GRAVITY          =   0x0002

; アニメーション
PLAYER_ANIMATION_NULL           =   0x00

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerSetBomb
    .globl  _PlayerIsJust

; 外部変数宣言
;

    .globl  _player

