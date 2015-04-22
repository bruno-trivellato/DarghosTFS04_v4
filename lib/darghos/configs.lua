-- Arquivo de configurações dos aspectos do Darghos

-- Distro utilizada
-- opções: opentibia, tfs
darghos_distro = "tfs"

-- Sistema de stages personalizado do Darghos
-- opções: true(ativo), false (desativo)
-- Obs: 
--	* Para evitar problemas certificar que todas rates estão configuradas como 1x no config.lua e eventual stages.xml da distro
darghos_use_stages = true

-- Sistema de reborn
-- opções: true (ativo), false (desativo)
-- Obs:
--	* para true é necessario que as vocações de reborn estejam devidamente configuradas em vocations.xml
darghos_use_reborn = false

-- Sistema de backup a cada Auto Save
darghos_server_save_backup = true

-- Sistema de recordes personalizado
-- opções: true (ativo), false (desativo)
darghos_use_record = false

-- Trainers
darghos_enable_trainers = true

-- Darghos rates (double,  triple,  etc)
darghos_exp_multipler = 1.0
darghos_skills_multipler = 1.0

-- Darghos receive premium test level
darghos_premium_test_level = 0 -- set 0 to disable
darghos_premium_test_quanty = 4

-- Pacific & Agressives world configuration
darghos_world_configuration = WORLD_CONF_AGRESSIVE_ONLY

-- Change pvp (CHANGE_ALLOWED)
darghos_change_pvp_debuff_percent = 50
darghos_change_pvp_days_cooldown = 30
darghos_change_pvp_premdays_cooldown = 10
darghos_change_pvp_premdays_cost = 20
darghos_remove_change_pvp_debuff_cost = 25

-- Change pvp (WEECLY_CHANGE)
darghos_weecly_change_day = WEEKDAY.FRIDAY
darghos_weecly_change_max_level_any_day = 99

-- Darghos spoof players
-- opções: true (ativo), false (desativo)
darghos_spoof_players = getConfigInfo('spoofPlayersEnabled')
darghos_players_to_spoof = getConfigInfo('spoofPlayersCount')
darghos_spoof_start_in = getConfigInfo('spoofPlayersStarts')

-- Define se é necessario comer para recuperar life/mana
darghos_need_eat = true

-- Special Events
darghos_kill_dark_general_exp_bonus_days = 3
darghos_kill_dark_general_exp_bonus_percent = 10

-- Define se jogadores em area non-pvp/pacificos usarão um estagio de exp diferenciado do normal
darghos_use_protected_stages = false

darghos_enable_portals = true