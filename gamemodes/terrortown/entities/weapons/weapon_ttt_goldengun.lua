if SERVER then
	resource.AddWorkshop( "233067112" )
end

if CLIENT then

   SWEP.PrintName = "Golden Gun"
   SWEP.Slot      = 6 -- add 1 to get the slot number key
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

SWEP.Primary.Delay       = 0.08
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


function SWEP:PrimaryAttack()
   if !self:CanPrimaryAttack() then return end

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
