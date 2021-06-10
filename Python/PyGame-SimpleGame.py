import math
import random
import time
import pygame

pygame.init()

clock = pygame.time.Clock()

screen = pygame.display.set_mode((800, 600))
# background
background = pygame.image.load("bg.png")
# player constants
player_img = pygame.image.load("wiz.png")
player_x = 370
player_y = 480
player_x_change = 0
player_y_change = 0
# enemy constants
enemy_img = pygame.image.load("en.png")
enemy_x = random.randint(0, 735)
enemy_y = random.randint(50, 200)
enemy_x_change = 1
enemy_y_change = 16
# bullet constants
bullet_img = pygame.image.load("ammo.png")
bullet_x = 0
bullet_y = 480
bullet_x_change = 0
bullet_y_change = 8
bullet_state = "ready"  # Bullet in motion or not

score = 0


def player(x, y):
    screen.blit(player_img, (x, y))


def enemy(x, y):
    screen.blit(enemy_img, (x, y))


def fire_arrow(x, y):
    global bullet_state
    bullet_state = "fire"
    screen.blit(bullet_img, (x + 16, y + 10))


def is_collision(enemy_x, enemy_y, bullet_x, bullet_y):
    distance = math.sqrt(math.pow(enemy_x - bullet_x, 2)) + (math.pow(enemy_y - bullet_y, 2))
    if distance < 27:
        return True
    else:
        return False


running = True
while running:
    clock.tick(60)
    screen.fill((0, 0, 0))
    # bg image
    screen.blit(background, (0, 0))

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        # if keystroke is pressed check wether its left or right
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_LEFT:
                player_x_change = -4
            if event.key == pygame.K_RIGHT:
                player_x_change = 4
            if event.key == pygame.K_SPACE:
                if bullet_state is "ready":
                    bullet_x = player_x
                    fire_arrow(bullet_x, bullet_y)
        if event.type == pygame.KEYUP:
            if event.key == pygame.K_LEFT or event.key == pygame.K_RIGHT:
                player_x_change = 0

    player_x += player_x_change

    if player_x <= 0:
        player_x = 0
    elif player_x >= 736:
        player_x = 736

    if bullet_y <= 0:
        bullet_y = 480
        bullet_state = "ready"

    if bullet_state is "fire":
        fire_arrow(bullet_x, bullet_y)
        bullet_y -= bullet_y_change

    enemy_x += enemy_x_change

    if enemy_x <= 0:
        enemy_x_change = 3
        enemy_y += enemy_y_change
    elif enemy_x >= 736:
        enemy_x_change = -3
        enemy_y += enemy_y_change
    # collision
    collision = is_collision(enemy_x, enemy_y, bullet_x, bullet_y)
    if collision:
        bullet_y = 480
        bullet_state = "ready"
        score += 1
        print(score)
        enemy_x = random.randint(0, 735)
        enemy_y = random.randint(50, 200)

    player(player_x, player_y)
    enemy(enemy_x, enemy_y)
    pygame.display.update()
