; Sound.s : サウンド
;


; モジュール宣言
;
    .module Sound

; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Sound.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; サウンドを初期化する
;
_SoundInitialize:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; BGM を再生する
;
_SoundPlayBgm::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < BGM

    ; 現在再生している BGM の取得
    ld      bc, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_HEAD)

    ; サウンドの再生
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundBgm
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      a, e
    cp      c
    jr      nz, 10$
    ld      a, d
    cp      b
    jr      z, 19$
10$:
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_REQUEST), de
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; SE を再生する
;
_SoundPlaySe::

    ; レジスタの保存
    push    hl
    push    de

    ; a < SE

    ; サウンドの再生
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundSe
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; サウンドを停止する
;
_SoundStop::

    ; レジスタの保存

    ; サウンドの停止
    call    _SystemStopSound

    ; レジスタの復帰

    ; 終了
    ret

; BGM が再生中かどうかを判定する
;
_SoundIsPlayBgm::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; SE が再生中かどうかを判定する
;
_SoundIsPlaySe::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 共通
;
soundNull:

    .ascii  "T1@0"
    .db     0x00

; BGM
;
soundBgm:

    .dw     soundNull, soundNull, soundNull
    .dw     soundBgmTitle0, soundBgmTitle1, soundBgmTitle2
    .dw     soundBgmClear0, soundBgmClear1, soundBgmClear2
    .dw     soundBgmResult0, soundBgmResult1, soundBgmResult2

; タイトル
soundBgmTitle0:

    .ascii  "T2@10V15,3"
    .ascii  "L3O5GO6C5O5B-5G5E-FE-FE-O4GB-6O5C5R5R7R9"
    .db     0x00

soundBgmTitle1:

    .ascii  "T2@10V15,3"
    .ascii  "L3O4GO5C5O4B-5G5E-FE-FE-O3GB-6O4C5R5R7R9"
    .db     0x00
    
soundBgmTitle2:

    .ascii  "T2@3V15,3"
    .ascii  "L3O2C5R5D7C7GG6O3C5R5O2G5R5O3CC5O2G5R5"
    .db     0x00

; クリア
soundBgmClear0:

    .ascii  "T2@10"
    .ascii  "V15,4L5O5RGGG"
    .ascii  "V15,6L9O5G"
    .db     0x00

soundBgmClear1:

    .ascii  "T2@10"
    .ascii  "V15,4L5O4RGGG"
    .ascii  "V15,3L5O4GG3GF3G"
    .db     0x00

soundBgmClear2:

    .ascii  "T2@10"
    .ascii  "V15,3L5O3RGGG"
    .ascii  "V15,6L9O3G"
    .db     0x00

; 結果
soundBgmResult0:

    .ascii  "T2@10V15,6O5G9"
    .db     0x00

soundBgmResult1:

    .ascii  "T2@10V15,6O4G9"
    .db     0x00

soundBgmResult2:

    .ascii  "T2@10V15,6O6C9"
    .db     0x00

; SE
;
soundSe:

    .dw     soundNull
    .dw     soundSeBoot
    .dw     soundSeClick
    .dw     soundSeJet
    .dw     soundSeBomb

; ブート
soundSeBoot:

    .ascii  "T2@0V15L3O6BO5BR9"
    .db     0x00

; クリック
soundSeClick:

    .ascii  "T2@0V15O4B0"
    .db     0x00

; 噴射音
soundSeJet:

    .ascii  "T1@0"
    .ascii  "V15O5L0BA"
    .ascii  "V11O5L0BA"
    .db     0x00

; 爆発
soundSeBomb:

    .ascii  "T1@0"
    .ascii  "V15L0O4GFEDCO3BAG"
    .ascii  "V14L0O4GFEDCO3BAG"
    .ascii  "V13L0O4GFEDCO3BAG"
    .ascii  "V12L0O4GFEDCO3BAG"
    .ascii  "V11L0O4GFEDCO3BAG"
    .ascii  "V10L0O4GFEDCO3BAG"
    .ascii  "V9L0O4GFEDCO3BAG"
    .ascii  "V8L0O4GFEDCO3BAG"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;
