if SERVER then
   resource.AddWorkshop( "233067112" )
end

if CLIENT then

   SWEP.PrintName = "Golden Gun"
   SWEP.Slot      = 6
   SWEP.EquipMenuData = {
      type = "Arma",
      desc = "Atire em um traidor, mate o traidor. \nAtire em um inocente, se mate. \nSomente pode ser utilizada depois de 1:30 de rodada."
   };


   SWEP.ViewModelFOV  = 72
   SWEP.ViewModelFlip = true

   SWEP.Icon = "vgui/ttt/icon_goldendeagle.png"
end

SWEP.Base        = "weapon_tttbase"

--- Standard GMod values

SWEP.HoldType            = "pistol"

SWEP.Primary.Delay       = 1
SWEP.Primary.Recoil      = 1.2
SWEP.Primary.Automatic   = true
SWEP.Primary.Cone        = 0.025
SWEP.Primary.Ammo        = "none"
SWEP.Primary.ClipSize    = 1
SWEP.Primary.ClipMax     = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Sound       = Sound( "Weapon_Deagle.Single" )

SWEP.ViewModel           = "models/weapons/v_powerdeagle.mdl"
SWEP.WorldModel          = "models/weapons/w_powerdeagle.mdl"

SWEP.Kind                = WEAPON_EQUIP1
SWEP.WeaponID            = AMMO_GOLDENGUN
SWEP.AutoSpawnable       = false
SWEP.AmmoEnt             = "none"
SWEP.CanBuy              = { ROLE_DETECTIVE }
SWEP.InLoadoutFor        = nil
SWEP.LimitedStock        = true
SWEP.AllowDrop           = true
SWEP.IsSilent            = false
SWEP.NoSights            = false
SWEP.fingerprints        = {}

local function SetGoldenGunInnocentMaterial(target)
   target:SetMaterial("effects/golden")
   timer.Simple(10, function()
      target:SetMaterial("")  
   end)
end

local function GoldenGunDamage(attacker, trace, dmg)
   if SERVER then

      if !attacker or !trace or !dmg then return end

      local target = trace.Entity
      if !target:IsPlayer() then return end 

      dmg:SetAttacker(attacker)
      dmg:SetInflictor(attacker:GetActiveWeapon())
      dmg:SetDamage(4000)
      dmg:SetDamageType(DMG_BULLET)
      dmg:SetDamagePosition(attacker:GetPos())

      if !target:IsRole(ROLE_TRAITOR) then 
         
         attacker:TakeDamageInfo(dmg)

         SetGoldenGunInnocentMaterial(target)

         dmg:SetDamage(0)
         dmg:ScaleDamage(0)

         --target:TakeDamageInfo(dmg)

         dmg = nil

         return
      end

      target:TakeDamageInfo(dmg)

      return
   end
end

hook.Add('TTTBeginRound', "TTTGoldenGunTimerCheck", function()

   if timer.Exists("GoldenGunTimerDelay") then
      
      timer.Remove("GoldenGunTimerDelay")

      return
   end

   timer.Create("GoldenGunTimerDelay", 90, 0, function()

      timer.Remove("GoldenGunTimerDelay")

      return
   end)
end)

function SWEP:CanPrimaryAttack()
   if not IsValid(self:GetOwner()) then return end

   if self:Clip1() <= 0 then

      self:DryFire(self.SetNextPrimaryFire)

      return false
   end

   return !timer.Exists("GoldenGunTimerDelay")
end

function SWEP:PrimaryAttack()

   if !self:CanPrimaryAttack() then
      
      if !timer.Exists(self:GetOwner():Nick() .. "_golden_message") then

         if !timer.Exists("GoldenGunTimerDelay") then return end

         local timeleft = math.floor(timer.TimeLeft("GoldenGunTimerDelay"))

         -- since we are already running on the client, we don't need any checks here
         chat.AddText(Color(230, 15, 15), "Você não pode utilizar a Golden Gun ainda! Espere mais " .. timeleft .. " segundo", (timeleft > 1 and "s!" or "!") )
      
         self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
         
         timer.Create(self:GetOwner():Nick() .. "_golden_message", 5, 0, function() 
            
            timer.Remove(self:GetOwner():Nick() .. "_golden_message")

            return
         end)

         return
      end

      return 
   end

   self:TakePrimaryAmmo(1)
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self.Weapon:EmitSound(Sound( "Weapon_Deagle.Single" ))
   self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
   local owner = self:GetOwner()

   local dmg = DamageInfo()

   bullet = {}
   bullet.Attacker = owner
   bullet.Num = self.Primary.NumberofShots
   bullet.Src = owner:GetShootPos()
   bullet.Dir = owner:GetAimVector()
   bullet.Spread = Vector( 0, 0, 0 )
   bullet.Tracer = 0
   bullet.Callback = function(attacker, tr, dmg)
      GoldenGunDamage(attacker, tr, dmg)
   end

   owner:FireBullets(bullet)
   
   return
end
