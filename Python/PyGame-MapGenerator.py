import pygame
import sys
import random
from pygame.locals import *

# initiates pygame
pygame.init()
clock = pygame.time.Clock()

# Constants
WINDOW_SIZE = (640, 480)     # 640/16 = 40, 480/16 -2 =28 ! -2 for UI rows
BIOME = 6
RUNNING = True

# Variables
mouse_pos = ()

# Generates the Map
tiles = [[random.randint(1, BIOME) for x in range(40)] for y in range(28)]
game_map = tiles
print(str("Generated:"), tiles)

# Display and Screen Settings
font = pygame.font.SysFont("bitstreamverasans", 12)
pygame.display.set_caption('PXLS')
screen = pygame.display.set_mode(WINDOW_SIZE, 0, 32)
display = pygame.Surface((640, 480))  # used as the  surface for rendering, which is scaled

# Artwork assignment
grass_img = pygame.image.load('img/grass.png')
dirt_img = pygame.image.load('img/dirt.png')
water_img = pygame.image.load("img/water.png")
plains_img = pygame.image.load("img/plains.png")

# resources
cost = 0  # for later use
water = 0
dirt = 0
grass = 0

# Functions
def get_biome(number):
    if number <= 4:
        return 'dirt'
    elif number <= 5:
        return 'grass'
    elif number <= 6:
        return 'water'
    else:
        return None


def get_img(number):
    if number <= 4:
        return dirt_img
    elif number <= 5:
        return grass_img
    elif number <= 6:
        return water_img
    else:
        return None


def assign_res(number):
    global dirt
    global water
    global grass
    if number <= 4:
        dirt += 1
    elif number <= 5:
        grass += 1
    elif number <= 6:
        water += 1


# UI elements
def gui_draw():
    global dirt
    global water
    global grass
    text = font.render(str(dirt), True, (128, 0, 0))
    display.blit(text, (16 + 24, 16 * 28 + 4))
    text = font.render(str(grass), True, (0, 255, 0))
    display.blit(text, (64 + 24, 16 * 28 + 4))
    text = font.render(str(water), True, (0, 0, 255))
    display.blit(text, (112 + 24, 16 * 28 + 4))


def tile_drawer():
    global dirt
    global water
    global grass
    display.blit(get_img(1), (16, 16 * 28 + 8))
    display.blit(get_img(5), (64, 16 * 28 + 8))
    display.blit(get_img(6), (112, 16 * 28 + 8))


def tile_builder():
    tile_rects = []
    pos_y = 0
    for layer in game_map:
        pox_x = 0
        for tile in layer:
            if get_img(tile) is not None:
                display.blit(get_img(tile), (pox_x * 16, pos_y * 16))
            else:
                tile_rects.append(pygame.Rect(pox_x * 16, pos_y * 16, 16, 16))
            pox_x += 1
        pos_y += 1


def left_mb():
    global mouse_pos
    if pygame.mouse.get_pressed()[0]:
        pos = pygame.mouse.get_pos()
        mouse_pos = pos[0] // 16, pos[1] // 16
        try:
            info = get_biome(tiles[mouse_pos[1]][mouse_pos[0]])
            assign_res(tiles[mouse_pos[1]][mouse_pos[0]])
        except IndexError:
            info = "menü"
        print(mouse_pos, info)


# game loop
while RUNNING:
    display.fill((0, 0, 0))  # clear screen by filling it with black
    tile_builder()
    tile_drawer()
    # event check loop
    for event in pygame.event.get():
        if event.type == QUIT:
            RUNNING = False
            pygame.quit()
            sys.exit()
        elif event.type == pygame.MOUSEBUTTONDOWN:
            left_mb()
            pass
    gui_draw()
    screen.blit(pygame.transform.scale(display, WINDOW_SIZE), (0, 0))
    # screen.blit(text, (320 - text.get_width() // 2, 240 - text.get_height() // 2))
    pygame.display.update()
    clock.tick(60)
