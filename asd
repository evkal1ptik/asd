import disnake
import requests
import os
import datetime
from server import keep_alive
from disnake.ext import commands

client = commands.Bot(command_prefix ='s.', help_command=None, intents = disnake.Intents.all())

@client.event
async def on_ready():
  await client.change_presence(status = disnake.Status.idle, activity = disnake.Activity(type = disnake.ActivityType.playing, name = 'Merry Christmas ! | /help | v. 0.5.5'))
  print("Connected")
  
@client.event
async def on_member_join(member):
  if member.guild.id == 1104866181833293854:
    role = member.guild.get_role(1117558579080208434)
    channel = client.get_channel(1117739478203764756)

    embed = disnake.Embed(
        title = "На сервере новый участник!",
        description=f"Добро пожаловать, {member.mention} (`{member}`)",
      
        color = disnake.Colour.orange()
    )

    await member.add_roles(role)
    await channel.send(embed=embed)

@client.event
async def on_member_remove(member):
  if member.guild.id == 1104866181833293854:
    channel = client.get_channel(1120119053487439932)
    embed = disnake.Embed(
      title = "Оу нет, нас пользователь покинул нас",
      description=f"Пока, {member.mention} (`{member}`)",
      color = disnake.Colour.orange()
      )
    await channel.send(embed=embed)

@client.event
async def on_slash_command_error(inter, error):
    print(error)

    if isinstance(error, commands.MissingPermissions):
        await inter.send(f"{inter.author}, у вас недостаточно прав для выполнения данной команды ({','.join(perm for perm in error.missing_permissions)})")
    if isinstance(error, commands.UserInputError):
        await inter.send(embed=disnake.Embed(
        description=f"Правильное использование команды: '{inter.prefix}{inter.command.name}' ({inter.command.brief})\nExample: {inter.prefix}{inter.command.usage}"
        ))


@client.event
async def on_guild_join(guild):
    gguild = client.get_guild(1104866181833293854)
    logchann = gguild.get_channel(1119931032725094410)
    try:
        em = disnake.Embed(color=disnake.Color.green(), description=f"Имя: {guild.name} ({guild.id})\n\nВладелец: {guild.owner} ({guild.owner.id})").set_author(name="У бота новый сервер")
        if guild.icon is not None:
            em.set_thumbnail(url=guild.icon.url)
        em.set_footer(text=f"Серверов: {len(client.guilds)}")
        em.add_field(name="Участников:", value=f"{len(guild.members)} | {len([i.id for i in guild.members if not i.bot])} | {len([i.id for i in guild.members if i.bot])}")
        await logchann.send(embed=em)
    except:
        pass

@client.event
async def on_guild_remove(guild):
    gguild = client.get_guild(1104866181833293854)
    logchann = gguild.get_channel(1119931032725094410)
    try:
        em = disnake.Embed(color=disnake.Color.red(), description=f"Имя: {guild.name} ({guild.id})\n\nВладелец: {guild.owner} ({guild.owner.id})").set_author(name="Бота исключили с сервера")
        if guild.icon is not None:
            em.set_thumbnail(url=guild.icon.url)
        em.set_footer(text=f"Серверов: {len(client.guilds)}")
        em.add_field(name="Участников:", value=f"{len(guild.members)} | {len([i.id for i in guild.members if not i.bot])} | {len([i.id for i in guild.members if i.bot])}")
        await logchann.send(embed=em)
    except:
        pass
      
@client.slash_command(name="help", description="Вывод списка команд бота")
async def help(inter):
    await inter.response.defer()
    embed = disnake.Embed(
        color = disnake.Colour.orange(),
        timestamp=datetime.datetime.now()
        )
    embed.add_field(name = ':gear: Основные', value = '`avatar` `help` `say` `donate`', inline = False)
    embed.add_field(name = ':tools: Модерация', value = '`kick` `ban` `clear` `mute` `unmute`', inline = False)
    embed.add_field(name = ':underage: nsfw', value = '`nsfw`', inline = False)
    embed.add_field(name = ':people_wrestling: Взаимодействия', value = '`cry` `hug` `kiss` `kill` `lick` `poke` `dance` `smile` `wave`', inline = False)
    embed.set_thumbnail(url = 'https://cdn.discordapp.com/avatars/1101190218553503816/2f0535e21ca21cf801a96cf0d28629e1.png?size=1024')
    embed.set_footer(text = f'{inter.author.name} ', icon_url = inter.author.avatar)
    await inter.send(embed = embed)

@client.slash_command(name="kick", description="Исключает участника с сервера", options=[disnake.Option(name="member", description="Выбор участника", type=disnake.OptionType.user, required=True), disnake.Option(name="reason", description="Причина кика", required=False, type=disnake.OptionType.string)])
@commands.has_permissions(kick_members=True, administrator=True)
async def kick(inter, member, *, reason = "Нарушение правил"):
    await inter.response.defer()
    await member.kick(reason = reason)
    await inter.send(f"Администратор {inter.author.mention} исключил пользователя {member.mention}")

@client.slash_command(name="ban", description="Бан", options=[disnake.Option(name="member", description="Выбор участника", type=disnake.OptionType.user, required=True), disnake.Option(name="reason", description="Причина бана", required=False, type=disnake.OptionType.string)])
@commands.has_permissions(ban_members=True, administrator=True)
async def ban(inter, member, *, reason = "Нарушение правил"):
      await inter.response.defer()
      await member.ban(reason = reason)
      await inter.send(f"Администратор {inter.author.mention} забанил пользователя пользователя {member.mention}")

@client.slash_command(description = 'Мьют пользователя')
async def mute(self, inter, member: disnake.Member, time, reason: str="Нет"):
  await inter.response.defer()

  if member == inter.author:
      await inter.send(content="<:error:1093211159160688710> Ты не можешь наказать сам себя", ephemeral=True)
      return
  
  if member not in inter.guild.members:
      await inter.send("<:error:1093211159160688710> Пользователя нет на сервере.", ephemeral=True)
      return

  try:
    if 's' in time:
        timem=int(time[:-1])
    elif 'm' in time:
        timem=int(time[:-1]) * 60
    elif 'h' in time:
        timem=int(time[:-1]) * 60 * 60
    elif 'd' in time:
        timem=int(time[:-1]) * 60 * 60 * 24
    else:
        await inter.send(content="<:error:1093211159160688710> Указана неверная продолжительность", ephemeral=True)
        return
  except:
    return await inter.send(content="<:error:1093211159160688710> Указана неверная продолжительность", ephemeral=True)
  try: 
    await member.timeout(reason = reason, duration = timem)
  except:
    return await inter.send("<:error:1093211159160688710> Ошибка при попытке мьюта")
  await inter.send(f"Timed out {member.mention} for {datetime.timedelta(seconds=timem)} for {reason}")

@client.slash_command(description = 'Снять мьют с пользователя')
async def unmute(self, inter, member: disnake.Member, reason: str="Нет"):
  await member.timeout(reason = None, duration = None)
  await inter.send(f"Untimed out {member.mention}")

@client.slash_command(name="avatar", description="Показывает аватар пользователя")
async def avatar(inter, member:disnake.User=None):
    await inter.response.defer()
    if member is None:
      member = inter.author
    embed = disnake.Embed(
        color = disnake.Colour.orange()
        )
    embed.set_author(name=f"Аватар пользователя {member.name}:")
    embed.set_image(url = member.avatar.url)
    await inter.send(embed = embed)
  

@client.slash_command(name="clear", description="Очистка сообщений", options=[disnake.Option(name="amount", description="Число сообщений для очистки", required=True, type=disnake.OptionType.integer)])
@commands.has_permissions(administrator=True)
async def clear(inter, amount: int):
    await inter.response.defer(ephemeral=True)
    if amount <=0:
        return await inter.send("Число не может быть отрицательным")
    purged=await inter.channel.purge(limit = int(amount))
    embed = disnake.Embed(
        color = disnake.Colour.green(),
        description=f"Сообщений очищено: **`{len(purged)}`**"
        )
    await inter.delete_original_response()
    await inter.channel.send(embed = embed)

@client.slash_command(name='cry', description='(Эмоция) Плакать')
async def cry(inter):
    await inter.response.defer()
    embed = disnake.Embed(
        color = disnake.Colour.orange()
        )
    response = requests.get('https://api.waifu.pics/sfw/cry').json()['url']
    embed.set_author(name=f"{inter.author.name} плачет")
    embed.set_image(url = response)
    await inter.send(embed = embed)

@client.slash_command(name='hug', description='(Эмоция) Обнимать')
async def hug(inter, member:disnake.User=None):
    await inter.response.defer()
    if member is None or member == inter.author:
        text=f"{inter.author.name}, бля, ну обнимать самого себя уже слишком..."
    else:
        text=f"{inter.author.name} обнимает {member.name}"
    embed = disnake.Embed(
        color = disnake.Colour.orange()
        )
    response = requests.get('https://api.waifu.pics/sfw/hug').json()['url']
    embed.set_author(name=text)
    embed.set_image(url = response)
    await inter.send(embed = embed)

@client.slash_command(name='kiss', description='(Эмоция) Целовать')
async def kiss(inter, member:disnake.User=None):
    await inter.response.defer()
    if member is None or member == inter.author:
        text=f"{inter.author.name} целует сам себя... cтоп, что?"
    else:
        text=f"{inter.author.name} целует {member.name}"
    embed = disnake.Embed(
        color = disnake.Colour.orange()
        )
    response = requests.get('https://api.waifu.pics/sfw/kiss').json()['url']
    embed.set_author(name=text)
    embed.set_image(url = response)
    await inter.send(embed = embed)

@client.slash_command(name='kill', description='(Эмоция) Убить')
async def kill(inter, member:disnake.User=None):
    await inter.response.defer()
    if member is None or member == inter.author:
        text=f"{inter.author.name} решил суициднутся"
    else:
        text=f"{inter.author.name} убивает {member.name}"
    embed = disnake.Embed(
        color = disnake.Colour.orange()
        )
    response = requests.get('https://api.waifu.pics/sfw/kill').json()['url']
    embed.set_author(name=text)
    embed.set_image(url = response)
    await inter.send(embed = embed)

@client.slash_command(name='lick', description='(Эмоция) Облизать')
async def lick(inter, member:disnake.User=None):
    await inter.response.defer()
    if member is None or member == inter.author:
        text=f"{inter.author.name} облизывает себя.... вопрос зачем?"
    else:
        text=f"{inter.author.name} облизывает {member.name}"
    embed = disnake.Embed(
        color = disnake.Colour.orange()
        )
    response = requests.get('https://api.waifu.pics/sfw/lick').json()['url']
    embed.set_author(name=text)
    embed.set_image(url = response)
    await inter.send(embed = embed)

@client.slash_command(name='poke', description='(Эмоция) Тыкнуть')
async def poke(inter, member:disnake.User=None):
    await inter.response.defer()
    if member is None or member == inter.author:
        text=f"{inter.author.name} тыкает всех (вот, заняться человеку нечем)"
    else:
        text=f"{inter.author.name} тыкает {member.name}"
    embed = disnake.Embed(
        color = disnake.Colour.orange()
        )
    response = requests.get('https://api.waifu.pics/sfw/poke').json()['url']
    embed.set_author(name=text)
    embed.set_image(url = response)
    await inter.send(embed = embed)

@client.slash_command(name='dance', description='(Эмоция) Танцевать')
async def dance(inter, member:disnake.User=None):
    await inter.response.defer()
    if member is None or member == inter.author:
        text=f"{inter.author.name} танцует в одиночестве..."
    else:
        text=f"{inter.author.name} танцует с {member.name}"
    embed = disnake.Embed(
        color = disnake.Colour.orange()
        )
    response = requests.get('https://api.waifu.pics/sfw/dance').json()['url']
    embed.set_author(name=text)
    embed.set_image(url = response)
    await inter.send(embed = embed)

@client.slash_command(name='smile', description='(Эмоция) Улыбаться')
async def smile(inter, member:disnake.User=None):
    await inter.response.defer()
    if member is None or member == inter.author:
        text=f"{inter.author.name} улыбается"
    else:
        text=f"{inter.author.name} улыбается {member.name}"
    embed = disnake.Embed(
        color = disnake.Colour.orange()
        )
    response = requests.get('https://api.waifu.pics/sfw/smile').json()['url']
    embed.set_author(name=text)
    embed.set_image(url = response)
    await inter.send(embed = embed)

  
@client.slash_command(name='wave', description='(Эмоция) Приветствовать')
async def wave(inter, member:disnake.User=None):
    await inter.response.defer()
    if member is None or member == inter.author:
        text=f"{inter.author.name} приветствует всех"
    else:
        text=f"{inter.author.name} приветствует {member.name}"
    embed = disnake.Embed(
        color = disnake.Colour.orange()
        )
    response = requests.get('https://api.waifu.pics/sfw/wave').json()['url']
    embed.set_author(name=text)
    embed.set_image(url = response)
    await inter.send(embed = embed)

@client.slash_command(name="nsfw", description="🔞🤫", nsfw=True)
async def nnsfw(inter):
    await inter.response.defer()
    embed = disnake.Embed(
        color = disnake.Colour.orange()
        )
    response = requests.get('https://api.waifu.pics/nsfw/waifu').json()['url']
    embed.set_image(url = response)
    await inter.send(embed = embed)
      
@client.slash_command(description= 'Сказать что-то от имени бота',options=[disnake.Option(name="имя", description="Нужно ли указывать имя автора", choices={"Да":"yes", "Нет":"no"}, required=True), disnake.Option(name="текст", type=disnake.OptionType.string, required=True)])
async def say(inter, имя, текст):
    await inter.response.defer(ephemeral=True)
    em=disnake.Embed(color=disnake.Color.orange(), description=текст)
    if имя == "yes":
        em.set_footer(text=f"Отправлено: {inter.author}", icon_url = inter.author.avatar.url if inter.author.avatar is not None else '')
    await inter.channel.send(embed=em)
    await inter.send("ok", ephemeral=True)

@client.slash_command(name="donate", description="Донатик")
async def donate(inter):
    await inter.response.defer()
    embed = disnake.Embed(
      timestamp=datetime.datetime.now(),
      color = disnake.Colour.orange() 
        )
    embed.set_thumbnail(url = 'https://cdn.discordapp.com/avatars/1101190218553503816/2f0535e21ca21cf801a96cf0d28629e1.png?size=1024')
    embed.set_footer(text = 'Вы можете поддержать проект, задонатив по кнопке снизу')
    components=[
    disnake.ui.Button(label="QIWI", style=disnake.ButtonStyle.url,
url = 'https://bit.ly/suckapunkakeqiwi'),
    disnake.ui.Button(label="TINKOFF", style=disnake.ButtonStyle.url,
url = 'https://bit.ly/suckapunkaketinkoff'),
      disnake.ui.Button(label="Boosty", style=disnake.ButtonStyle.url,
url = 'https://bit.ly/suckapunkakeboosty')
    ]    
    await inter.send(embed = embed, components = components)

@client.slash_command(name="user", description="Информация о пользователе")
async def user(inter):
    await inter.response.defer()
    user_info = f"""
Имя: {inter.user.name}
ID: {inter.user.id}
Аккаунт создан: <t:{int(datetime.datetime.fromisoformat(f'{inter.user.created_at}').timestamp())}:f>
Присоединился: <t:{int(datetime.datetime.fromisoformat(f'{inter.user.joined_at}').timestamp())}:f>
Роли: {' '.join([role.mention for role in inter.author.roles])}
"""
    embed = disnake.Embed(
      timestamp=datetime.datetime.now(),
      color = disnake.Colour.orange() 
        )
    embed.add_field(name = 'Информация о пользователе:', value = user_info)
    embed.set_thumbnail(url = f'{inter.author.avatar}')
    await inter.send(embed = embed)
          
keep_alive()
client.run('OTYxOTI5MzUwNjkxODI3NzUy.GyoG7h.a0nQNKDf5YsXblnKSPy6kkShc_bDYKXJcwU1IA')
