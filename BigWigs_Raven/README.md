# BigWigs_Raven

BigWigs v36 (Classic Era 1.14.2) + кастомный контент RavenCraft: Изумрудное
святилище, Каражаy (Crypt / Lower Halls / Tower), Логово Племени Древа, Чёрные
топи и мировые боссы.

Аддон не заменяет BigWigs, а **дополняет** его: ставится рядом с `BigWigs`,
`BigWigs_Core`, `BigWigs_Plugins` и `BigWigs_Options`.

```
Interface\AddOns\BigWigs\            (v36-classic)
Interface\AddOns\BigWigs_Core\
Interface\AddOns\BigWigs_Plugins\
Interface\AddOns\BigWigs_Options\
Interface\AddOns\BigWigs_Raven\      ← этот аддон
```

## Зачем он нужен

BigWigs v36 знает только классические инстансы: его таблица зон (`zoneTbl`)
статична, а боссы включаются по `encounterID` или `mobID`. У кастомных боссов
RavenCraft нет ни записей в журнале, ни известных аддону id, поэтому:

1. **Зоны** — аддон один раз при входе сканирует `GetRealZoneText(id)` и сам
   находит id кастомных карт (они есть в клиенте, но не в BigWigs).
2. **Включение босса** — по имени цели/наведения, а не по `mobID`.
3. **Триггеры** — переписаны с чат-строк 1.12 (`"X begins to cast Y."`) на
   боевой лог 1.14 (`SPELL_CAST_START`, `SPELL_AURA_APPLIED` и т.д.).

Всё остальное — штатный BigWigs: полосы, сообщения, звуки, настройки.

## Команды

| Команда | Что делает |
|---|---|
| `/bwr status` | версия, сколько модулей зарегистрировано, загружено ли ядро, найдены ли зоны |
| `/bwr zones` | скан зон клиента → `Logs\RavenBW_zones.txt` (id + название) |
| `/bwr find <текст>` | то же с фильтром по названию |
| `/bwr build` | перерегистрировать модули (после `/reload` не нужно) |
| `/bwr probe` | 180 секунд писать боевой лог в `Logs\RavenBW_probe.txt` (для порта новых боссов) |
| `/bwr probe stop` | остановить запись сразу |
| `/bwr combatlog on/off` | включить/выключить слушатель боевого лога |

## Что уже портировано

| Рейд | Боссы | Статус |
|---|---|---|
| Emerald Sanctum | Erennius, Solnius, Sanctum Wyrm, Wyrmkin, Dreamer, Supressor, Dragonkin | **готово (7/7)** |
| Karazhan Crypt | — | не начато |
| Lower Karazhan Halls | Moroes, Brood Queen Araxxna, Clawlord Howlfang, Grizikil, Lord Blackwald II, Dark Rider Champion, Phantom Servant | не начато |
| Tower of Karazhan | Mephistroth, Anomalus, Incantagos, Kruul, Rupturan, Sanv Tasdal, Echo of Medivh, Keeper Gnarlmoon, Chess, trash | не начато |
| Timbermaw Hold | Ursol, Kronn, Karrsh, Loktanag, Ormanos, Partath, Perotharn, Rotgrowl, Selenaxx, Trioch, trash | не начато |
| Black Morass | Chronar, Antnormi, Epidamu, Mossheart, Rotmaw, Drifting Avatar, Time-Lord Epochronos | не начато |
| World | Azuregos, Kazzak, Emeriss, Lethon, Taerar, Ysondre, Ostarius, Concavius, Dr. Weavil, Atiesh, Dark Reaver, Nerubian Overseer, Twilight Corrupter | не начато |

## Как добавить босса

```lua
RavenBW:AddBoss("Имя юнита", "Название зоны", function(zoneId)
	local mod = BigWigs:NewBoss("Имя юнита", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.ability = "Ability"
		L.ability_desc = "Warn for Ability."
		L.abilityBar = "Ability"
	end
	L = mod:GetLocale()

	function mod:GetOptions() return { "ability" } end
	function mod:OnBossEnable()
		self:Log("SPELL_CAST_START", "Ability", "Ability Name")
	end
	function mod:Ability()
		self:Bar("ability", 10, L.abilityBar, "Spell_Nature_Lightning")
	end
	return mod
end)
```

Ключевые моменты:

* `"Имя юнита"` — **ровно** `UnitName("target")` (по нему работает включение);
* `"Название зоны"` — как в клиенте (`GetRealZoneText`), иначе используется
  запасная зона `-947`;
* `self:Log(...)` принимает **имя заклинания** (строка) или его id;
* `Bar/StopBar` работают по тексту полосы, `Message` — по ключу опции.

## Известные неизвестности

* Имена заклинаний кастомных боссов взяты из триггеров 1.18; на RavenCraft они
  могут отличаться. `/bwr probe` в бою даёт точные `spellName`/`spellId`.
* `encounterID` у кастомных боссов нет — победа определяется по смерти цели,
  поражение — по выходу из боя без цели.
* Настройки BigWigs для кастомных зон появляются в общем списке; отдельного
  меню «RavenCraft» пока нет.
