; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include    "Back.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存

    ; プレイヤの初期化
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      a, (_player + PLAYER_POSITION_X_H)
    ld      c, a
    ld      a, (_player + PLAYER_POSITION_Y_H)
    ld      b, a
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_BOMB_BIT, a
    jr      nz, 10$
    ld      hl, #(playerSprite + 0x0000)
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    call    16$
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_LAND_BIT, a
    jr      nz, 19$
    push    de
    ld      a, (_player + PLAYER_FLAG)
    and     #PLAYER_FLAG_ASCENT
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      a, (_player + PLAYER_ANIMATION)
    and     #0x04
    add     a, e
    ld      e, a
    ld      d, #0x00
    add     hl, de
    pop     de
    call    16$
    jr      19$
10$:
    ld      hl, #(playerSprite + 0x0014)
    ld      de, #(_sprite + GAME_SPRITE_BOMB)
    call    16$
    call    16$
    call    16$
    call    16$
    jr      19$
16$:
    push    bc
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
    add     a, (hl)
    bit     #0x07, c
    jr      nz, 17$
    add     a, #0x20
17$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    bit     #0x07, c
    jr      nz, 18$
    or      #0x80
18$:
    ld      (de), a
    inc     hl
    inc     de
    pop     bc
    ret
19$:

    ; レジスタの復帰

    ; 終了
    ret
    
; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを操作する
;
PlayerPlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 上昇／下降の操作
    ld      hl, #(_player + PLAYER_FLAG)
    ld      de, (_player + PLAYER_SPEED_Y_L)
    ld      a, (_input + INPUT_BUTTON_SPACE)
    or      a
    jr      z, 11$
    set     #PLAYER_FLAG_ASCENT_BIT, (hl)
    ex      de, hl
    ld      bc, #PLAYER_SPEED_Y_ASCENT
    or      a
    sbc     hl, bc
    ld      a, h
    or      a
    jp      p, 19$
    cp      #-((PLAYER_SPEED_Y_MAXIMUM + 0x0100) >> 8)
    jr      z, 10$
    jr      nc, 19$
10$:
    ld      hl, #-PLAYER_SPEED_Y_MAXIMUM
    jr      19$
11$:
    res     #PLAYER_FLAG_ASCENT_BIT, (hl)
    ex      de, hl
    ld      bc, #PLAYER_SPEED_Y_GRAVITY
    add     hl, bc
    ld      a, h
    or      a
    jp      m, 19$
    cp      #(PLAYER_SPEED_Y_MAXIMUM >> 8)
    jr      c, 19$
    ld      hl, #PLAYER_SPEED_Y_MAXIMUM
;   jr      19$
19$:
    ld      (_player + PLAYER_SPEED_Y_L), hl

    ; 左右移動の操作
    ld      hl, (_player + PLAYER_SPEED_X_L)
    ld      de, #PLAYER_SPEED_X_ACCEL
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 21$
    or      a
    sbc     hl, de
    ld      a, h
    or      a
    jp      p, 28$
    cp      #-((PLAYER_SPEED_X_MAXIMUM + 0x0100) >> 8)
    jr      z, 20$
    jr      nc, 28$
20$:
    ld      hl, #-PLAYER_SPEED_X_MAXIMUM
    jr      28$
21$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 29$
    add     hl, de
    ld      a, h
    or      a
    jp      m, 28$
    cp      #(PLAYER_SPEED_X_MAXIMUM >> 8)
    jr      c, 28$
    ld      hl, #PLAYER_SPEED_X_MAXIMUM
;   jr      28$
28$:
    ld      (_player + PLAYER_SPEED_X_L), hl
29$:

    ; 上下の移動
    ld      hl, (_player + PLAYER_POSITION_Y_L)
    ld      de, (_player + PLAYER_SPEED_Y_L)
    add     hl, de
    ld      a, h
    cp      #(PLAYER_POSITION_TOP >> 8)
    jr      nc, 30$
    ld      hl, #PLAYER_POSITION_TOP
    jr      38$
30$:
    cp      #(PLAYER_POSITION_BOTTOM >> 8)
    jr      c, 39$
    ld      hl, #PLAYER_POSITION_BOTTOM
    jr      39$
38$:
    ld      a, d
    cpl
    ld      d, a
    ld      a, e
    cpl
    ld      e, a
    inc     de
    ld      (_player + PLAYER_SPEED_Y_L), de
39$:
    ld      (_player + PLAYER_POSITION_Y_L), hl

    ; 左右の移動
    ld      hl, (_player + PLAYER_POSITION_X_L)
    ld      de, (_player + PLAYER_SPEED_X_L)
    add     hl, de
    ld      a, h
    cp      #(PLAYER_POSITION_LEFT >> 8)
    jr      nc, 40$
    ld      hl, #PLAYER_POSITION_LEFT
    jr      48$
40$:
    cp      #(PLAYER_POSITION_RIGHT >> 8)
    jr      c, 49$
    ld      hl, #PLAYER_POSITION_RIGHT
;   jr      48$
48$:
    ld      a, d
    cpl
    ld      d, a
    ld      a, e
    cpl
    ld      e, a
    inc     de
    ld      (_player + PLAYER_SPEED_X_L), de
49$:
    ld      (_player + PLAYER_POSITION_X_L), hl

    ; アニメーションの更新
    ld      hl, #(_player + PLAYER_ANIMATION)
    inc     (hl)

    ; コリジョンの判定
    ld      hl, #(_player + PLAYER_FLAG)
    ld      a, (_player + PLAYER_POSITION_X_H)
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y_H)
    ld      d, a
    
    ; エネミーとの判定
    call    _EnemyHit
    jr      nc, 509$
    set     #PLAYER_FLAG_MISS_BIT, (hl)
    jr      59$
509$:

    ; 背景との判定
    ld      a, d
    add     a, #0x05
    ld      d, a
    call    _BackIsHit
    cp      #BACK_HIT_LAND
    jr      nz, 511$
    ld      a, (_player + PLAYER_SPEED_Y_H)
    or      a
    jp      m, 510$
    jr      nz, 512$
    ld      a, (_player + PLAYER_SPEED_Y_L)
    cp      #0x80
    jr      nc, 512$
510$:
    set     #PLAYER_FLAG_LAND_BIT, (hl)
    jr      59$
511$:
    cp      #BACK_HIT_MISS
    jr      nz, 519$
512$:
    set     #PLAYER_FLAG_MISS_BIT, (hl)
    jr      59$
519$:

    ; コリジョン判定の完了
59$:

    ; フラグの判定
    ld      a, (_player + PLAYER_FLAG)

    ; SE の再生
    push    af
    bit     #PLAYER_FLAG_ASCENT_BIT, a
    jr      z, 90$
    call    _SoundIsPlaySe
    jr      c, 90$
    ld      a, #SOUND_SE_JET
    call    _SoundPlaySe
90$:
    pop     af

    ; 着地した
    bit     #PLAYER_FLAG_LAND_BIT, a
    jr      z, 91$
    ld      a, #PLAYER_STATE_ON
    ld      (_player + PLAYER_STATE), a
    jr      99$
91$:

    ; ミスの判定
    bit     #PLAYER_FLAG_MISS_BIT, a
    jr      z, 92$
    ld      a, #PLAYER_STATE_BOMB
    ld      (_player + PLAYER_STATE), a
;   jr      99$
92$:

    ; フラグ判定の完了
99$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが爆発する
;
PlayerBomb:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; アニメーションの設定
    ld      a, #0xc0
    ld      (_player + PLAYER_ANIMATION), a

    ; SE の再生
    ld      a, #SOUND_SE_BOMB
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ;  爆発の取得
    ld      hl, #(_player + PLAYER_FLAG)
    ld      a, (_player + PLAYER_ANIMATION)
    and     #0x08
    jr      nz, 10$
    set     #PLAYER_FLAG_BOMB_BIT, (hl)
    jr      19$
10$:
    res     #PLAYER_FLAG_BOMB_BIT, (hl)
;   jr      19$
19$:

    ; アニメーションの更新
    ld      hl, #(_player + PLAYER_ANIMATION)
    dec     (hl)
    jr      nz, 29$

    ; ゲームオーバーの判定
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_OVER_BIT, (hl)
29$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがパイルダーオンした
;
PlayerOn:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; ゲームクリアの設定
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_CLEAR_BIT, (hl)

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを爆発させる
;
_PlayerSetBomb::

    ; レジスタの保存

    ; 状態の更新
    ld      hl, #(_player + PLAYER_STATE)
    ld      a, (hl)
    and     #0xf0
    cp      #PLAYER_STATE_BOMB
    jr      z, 10$
    ld      (hl), #PLAYER_STATE_BOMB
10$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがジャストかどうかを判定する
;
_PlayerIsJust::

    ; レジスタの保存

    ; ジャストの判定
    ld      a, (_player + PLAYER_POSITION_X_H)
    cp      #0x80
    jr      z, 10$
    or      a
    jr      19$
10$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
playerProc:
    
    .dw     PlayerNull
    .dw     PlayerPlay
    .dw     PlayerBomb
    .dw     PlayerOn

; プレイヤの初期値
;
playerDefault:

    .db     PLAYER_STATE_PLAY
    .db     PLAYER_FLAG_NULL
    .dw     0x8080 ; PLAYER_POSITION_NULL
    .dw     0x1000 ; PLAYER_POSITION_NULL
    .dw     PLAYER_SPEED_NULL
    .dw     PLAYER_SPEED_NULL
    .db     PLAYER_ANIMATION_NULL
    .db     0x00, 0x00, 0x00, 0x00, 0x00
    
; スプライト
;
playerSprite:

    ; PILDER
    .db     0xf8 - 0x01, 0xf8, 0x08, VDP_COLOR_DARK_RED
    ; FIRE - OFF
    .db     0x06 - 0x01, 0xf8, 0x10, VDP_COLOR_LIGHT_RED
    .db     0x06 - 0x01, 0xf8, 0x14, VDP_COLOR_LIGHT_YELLOW
    ; FIRE - ON
    .db     0x06 - 0x01, 0xf8, 0x18, VDP_COLOR_LIGHT_RED
    .db     0x06 - 0x01, 0xf8, 0x1c, VDP_COLOR_LIGHT_YELLOW
    ; BOMB
    .db     0xf0 - 0x01, 0xf0, 0x30, VDP_COLOR_LIGHT_RED
    .db     0xf0 - 0x01, 0x00, 0x34, VDP_COLOR_LIGHT_RED
    .db     0x00 - 0x01, 0xf0, 0x38, VDP_COLOR_LIGHT_RED
    .db     0x00 - 0x01, 0x00, 0x3c, VDP_COLOR_LIGHT_RED


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH

